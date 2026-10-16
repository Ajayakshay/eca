`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.10.2026 16:45:06
// Design Name: 
// Module Name: decoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module decoder #(parameter W = 32)(
    input  wire [W-1:0] instr,
    output reg          reg_write,
    output reg          mem_read,
    output reg          mem_write,
    output reg          alu_src_imm,
    output reg          is_branch,
    output reg          is_jalr,
    output reg          uses_rs1,
    output reg          uses_rs2,
    output reg  [2:0]   alu_op,
    output reg  [W-1:0] imm,
    output reg          is_jal
);
    localparam OP_IMM = 7'b0010011, OP = 7'b0110011, LOAD = 7'b0000011,
               STORE  = 7'b0100011, BRANCH = 7'b1100011, JALR = 7'b1100111,
               JAL    = 7'b1101111, LUI = 7'b0110111;
    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];

    always @* begin

        reg_write = 0; mem_read = 0; mem_write = 0; alu_src_imm = 0;
        is_branch = 0; is_jalr = 0; uses_rs1 = 0; uses_rs2 = 0; alu_op = 3'd0;
        imm = {{(W-12){instr[31]}}, instr[31:20]};                    // I-type
        is_jal = 0;
        case (opcode)
            OP_IMM: begin
                if (funct3 == 3'b000) begin                          // addi
                    reg_write = 1; uses_rs1 = 1; alu_src_imm = 1;
                end else if (funct3 == 3'b001 && funct7 == 7'b0) begin  // slli
                    reg_write = 1; uses_rs1 = 1; alu_src_imm = 1; alu_op = 3'd1;
                end
            end
            OP: begin
                if(funct3 == 3'b000) begin
                    if(funct7 == 7'b0000000) begin
                        reg_write = 1; uses_rs1 = 1; uses_rs2 = 1;
                    end else if(funct7 == 7'b0100000) begin
                        reg_write = 1; uses_rs1 = 1; uses_rs2 = 1; alu_op = 3'd3;
                    end else if(funct7 == 7'b0000001) begin
                        reg_write = 1; uses_rs1 = 1; uses_rs2 = 1; alu_op = 3'd2;
                    end          
                end
            end
            LOAD: begin
                reg_write = 1; mem_read = 1; uses_rs1 = 1; alu_src_imm = 1;
            end
            STORE: begin
                mem_write = 1; uses_rs1 = 1; uses_rs2 = 1; alu_src_imm = 1;
                imm = {{(W-12){instr[31]}}, instr[31:25], instr[11:7]};   // S-type
            end
            BRANCH: begin
                is_branch = 1; uses_rs1 = 1; uses_rs2 = 1;
                imm = {{(W-13){instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}; // B-type
            end
            JALR: begin
                reg_write = 1; is_jalr = 1; uses_rs1 = 1; alu_src_imm = 1;
            end
            JAL: begin
                reg_write = 1; is_jal = 1;
                imm = {{(W-21){instr[31]}}, instr[31], instr[19:12],instr[20],instr[30:21], 1'b0};
            end
            LUI: begin                                               // lui
                reg_write = 1; alu_src_imm = 1; alu_op = 3'd4;
                imm = {instr[31:12], 12'b0};
            end
            default: ;   // bubble / unknown = no-op
        endcase
    end
endmodule