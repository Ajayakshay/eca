`timescale 1ps/1ps

module CustomCore#(
    // --- SET BY THE TEST BENCH. DO NOT CHANGE ---
    parameter REGISTER_WIDTH = 32,
    parameter REGISTER_ADDRESS_WDITH = 5,   // (sic) testbench overrides this misspelled name; it must exist or iverilog errors
    parameter INSTRUCTION_MEMORY_ADDRESS_WIDTH = 5,
    parameter DATA_MEMORY_ADDRESS_WIDTH = 5
) (
    input wire                                            clock,
    input wire                                            reset,

    input wire[(REGISTER_WIDTH - 1): 0]                   instruction_memory_read,
    input wire[(REGISTER_WIDTH - 1): 0]                   data_memory_read,

    output wire[(INSTRUCTION_MEMORY_ADDRESS_WIDTH - 1):0] instruction_memory_address,
    output wire[(DATA_MEMORY_ADDRESS_WIDTH - 1):0]        data_memory_address,
    output wire[(REGISTER_WIDTH - 1):0]                   data_write_value,
    output wire                                           data_write_enable,
    output wire                                           core_finish_signal
);
    localparam W  = REGISTER_WIDTH;
    localparam IW = INSTRUCTION_MEMORY_ADDRESS_WIDTH;
    localparam DW = DATA_MEMORY_ADDRESS_WIDTH;

    // ------------------------------------------------------------ signals
    reg  finish_q;
    wire stall, redirect;
    wire [IW-1:0] redirect_target;
    wire [W-1:0]  wb_data;

    // ================================================================ IF
    reg [IW-1:0] pc;
    assign instruction_memory_address = pc;          // ROM is word-addressed, async read

    always @(posedge clock) begin
        if (reset)            pc <= 0;
        else if (!finish_q) begin
            if (redirect)     pc <= redirect_target;
            else if (!stall)  pc <= pc + 1'b1;
        end
    end

    // ============================================================ IF/ID
    reg [W-1:0]  if_id_instr;
    reg [IW-1:0] if_id_pc;

    always @(posedge clock) begin
        if (reset || redirect) if_id_instr <= 0;     // 0 = bubble (decodes to no-op)
        else if (!stall) begin
            if_id_instr <= instruction_memory_read;
            if_id_pc    <= pc;
        end
    end

    // ================================================================ ID
    wire [4:0] id_rs1 = if_id_instr[19:15];
    wire [4:0] id_rs2 = if_id_instr[24:20];
    wire [4:0] id_rd  = if_id_instr[11:7];

    wire id_reg_write, id_mem_read, id_mem_write, id_alu_src, id_is_branch, id_is_jalr, id_is_jal;
    wire id_uses_rs1, id_uses_rs2;
    wire [2:0] id_alu_op;
    wire [W-1:0] id_imm;

    decoder #(.W(W)) u_dec (
        .instr(if_id_instr), .reg_write(id_reg_write), .mem_read(id_mem_read),
        .mem_write(id_mem_write), .alu_src_imm(id_alu_src), .is_branch(id_is_branch),
        .is_jalr(id_is_jalr), .uses_rs1(id_uses_rs1), .uses_rs2(id_uses_rs2),
        .alu_op(id_alu_op), .imm(id_imm), .is_jal(id_is_jal)
    );

    wire [W-1:0] id_rs1_val, id_rs2_val;
    reg          mem_wb_reg_write;
    reg  [4:0]   mem_wb_rd;

    regfile #(.W(W), .AW(5)) u_rf (
        .clock(clock), .reset(reset),
        .we(mem_wb_reg_write), .waddr(mem_wb_rd), .wdata(wb_data),
        .raddr1(id_rs1), .raddr2(id_rs2), .rdata1(id_rs1_val), .rdata2(id_rs2_val)
    );

    reg id_ex_mem_read;
    reg [4:0] id_ex_rd;

    hazard_unit u_haz (
        .id_ex_mem_read(id_ex_mem_read), .id_ex_rd(id_ex_rd),
        .if_id_rs1(id_rs1), .if_id_rs2(id_rs2),
        .uses_rs1(id_uses_rs1), .uses_rs2(id_uses_rs2), .stall(stall)
    );

    // ============================================================ ID/EX
    reg [IW-1:0] id_ex_pc;
    reg [W-1:0]  id_ex_rs1_val, id_ex_rs2_val, id_ex_imm;
    reg [4:0]    id_ex_rs1, id_ex_rs2;
    reg          id_ex_reg_write, id_ex_mem_write, id_ex_alu_src, id_ex_is_branch, id_ex_is_jalr, id_ex_is_jal;
    reg [2:0]    id_ex_alu_op;
    reg [2:0]    id_ex_funct3;

    always @(posedge clock) begin
        if (reset || redirect || stall) begin        // insert bubble (control only)
            id_ex_reg_write <= 0; id_ex_mem_read <= 0; id_ex_mem_write <= 0;
            id_ex_is_branch <= 0; id_ex_is_jalr  <= 0; id_ex_is_jal <= 0;
        end else begin
            id_ex_reg_write <= id_reg_write; id_ex_mem_read <= id_mem_read;
            id_ex_mem_write <= id_mem_write; id_ex_is_branch <= id_is_branch;
            id_ex_is_jalr   <= id_is_jalr;
            id_ex_is_jal   <= id_is_jal;
        end
        if (!stall) begin
            id_ex_pc <= if_id_pc;
            id_ex_rs1_val <= id_rs1_val; id_ex_rs2_val <= id_rs2_val; id_ex_imm <= id_imm;
            id_ex_rs1 <= id_rs1; id_ex_rs2 <= id_rs2; id_ex_rd <= id_rd;
            id_ex_alu_src <= id_alu_src; id_ex_alu_op <= id_alu_op;
            id_ex_funct3 <= if_id_instr[14:12];
        end
    end

    // ================================================================ EX
    reg [W-1:0] ex_mem_result;
    reg [4:0]   ex_mem_rd;
    reg         ex_mem_reg_write, ex_mem_mem_read, ex_mem_mem_write;
    reg [W-1:0] ex_mem_store_data;

    wire [1:0] fwd_a, fwd_b;
    forwarding_unit u_fwd (
        .id_ex_rs1(id_ex_rs1), .id_ex_rs2(id_ex_rs2),
        .ex_mem_rd(ex_mem_rd), .ex_mem_reg_write(ex_mem_reg_write),
        .mem_wb_rd(mem_wb_rd), .mem_wb_reg_write(mem_wb_reg_write),
        .fwd_a(fwd_a), .fwd_b(fwd_b)
    );

    wire [W-1:0] rs1_fwd = (fwd_a == 2'b01) ? ex_mem_result : (fwd_a == 2'b10) ? wb_data : id_ex_rs1_val;
    wire [W-1:0] rs2_fwd = (fwd_b == 2'b01) ? ex_mem_result : (fwd_b == 2'b10) ? wb_data : id_ex_rs2_val;
    wire [W-1:0] alu_b   = id_ex_alu_src ? id_ex_imm : rs2_fwd;
    wire [W-1:0] alu_result;

    alu #(.W(W)) u_alu (.a(rs1_fwd), .b(alu_b), .op(id_ex_alu_op), .result(alu_result));

    reg branch_cond;
    always @* begin
        case (id_ex_funct3)
        3'b000: branch_cond = (rs1_fwd == rs2_fwd);//beq
        3'b001: branch_cond = (rs1_fwd != rs2_fwd);//bne
        3'b100: branch_cond = ($signed(rs1_fwd) < $signed(rs2_fwd) );//blt
        3'b101: branch_cond = ($signed(rs1_fwd) >= $signed(rs2_fwd));//bge
        3'b110: branch_cond = (rs1_fwd < rs2_fwd);//bltu
        3'b111: branch_cond = (rs1_fwd >= rs2_fwd);//bgeu
        default: branch_cond = 1'b0;
        endcase
    end
    wire branch_taken = id_ex_is_branch && branch_cond;

    wire [IW-1:0] branch_target = id_ex_pc + id_ex_imm[IW+1:2];
    wire [IW-1:0] jalr_target   = alu_result[IW+1:2];

    assign redirect        = branch_taken | id_ex_is_jal | id_ex_is_jalr;
    assign redirect_target = id_ex_is_jalr ? jalr_target : branch_target;

    wire [W-1:0] link   = {{(W-IW-2){1'b0}}, id_ex_pc + 1'b1, 2'b00};
    wire [W-1:0] ex_res = (id_ex_is_jalr | id_ex_is_jal) ? link : alu_result;

    // ret to address 0 => program done
    always @(posedge clock) begin
        if (reset)                                     finish_q <= 1'b0;
        else if (id_ex_is_jalr && jalr_target == 0)    finish_q <= 1'b1;
    end
    assign core_finish_signal = finish_q;

    // =========================================================== EX/MEM
    always @(posedge clock) begin
        if (reset) begin
            ex_mem_reg_write <= 0; ex_mem_mem_read <= 0; ex_mem_mem_write <= 0;
        end else begin
            ex_mem_reg_write <= id_ex_reg_write; ex_mem_mem_read <= id_ex_mem_read;
            ex_mem_mem_write <= id_ex_mem_write;
        end
        ex_mem_result     <= ex_res;
        ex_mem_store_data <= rs2_fwd;
        ex_mem_rd         <= id_ex_rd;
    end

    // ================================================================ MEM
    // RAM has 1-cycle read latency: data_memory_read is valid during WB.
    assign data_memory_address = ex_mem_result[DW+1:2];
    assign data_write_value    = ex_mem_store_data;
    assign data_write_enable   = ex_mem_mem_write & ~finish_q;

    // =========================================================== MEM/WB
    reg [W-1:0] mem_wb_result;
    reg         mem_wb_is_load;

    always @(posedge clock) begin
        if (reset) mem_wb_reg_write <= 0;
        else       mem_wb_reg_write <= ex_mem_reg_write;
        mem_wb_result  <= ex_mem_result;
        mem_wb_is_load <= ex_mem_mem_read;
        mem_wb_rd      <= ex_mem_rd;
    end

    // ================================================================ WB
    assign wb_data = mem_wb_is_load ? data_memory_read : mem_wb_result;

endmodule