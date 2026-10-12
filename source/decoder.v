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
    output reg  [1:0]   alu_op,
    output reg  [W-1:0] imm
);
    localparam OP_IMM = 7'b0010011, OP = 7'b0110011, LOAD = 7'b0000011,
               STORE  = 7'b0100011, BRANCH = 7'b1100011, JALR = 7'b1100111;

    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];

    always @* begin
        reg_write = 0; mem_read = 0; mem_write = 0; alu_src_imm = 0;
        is_branch = 0; is_jalr = 0; uses_rs1 = 0; uses_rs2 = 0; alu_op = 2'd0;
        imm = {{(W-12){instr[31]}}, instr[31:20]};                    // I-type

        case (opcode)
            OP_IMM: begin
                reg_write = 1; uses_rs1 = 1; alu_src_imm = 1;
                if (funct3 == 3'b001) alu_op = 2'd1;                  // slli
            end
            OP: begin
                reg_write = 1; uses_rs1 = 1; uses_rs2 = 1;
                if (funct7 == 7'b0000001) alu_op = 2'd2;              // mul
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
            default: ;   // bubble / unknown = no-op
        endcase
    end
endmodule
