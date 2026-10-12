`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.10.2026 16:47:10
// Design Name: 
// Module Name: forwarding_unit
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

module forwarding_unit(
    input  wire [4:0] id_ex_rs1,
    input  wire [4:0] id_ex_rs2,
    input  wire [4:0] ex_mem_rd,
    input  wire       ex_mem_reg_write,
    input  wire [4:0] mem_wb_rd,
    input  wire       mem_wb_reg_write,
    output reg  [1:0] fwd_a,     // 00 regfile, 01 EX/MEM result, 10 WB data
    output reg  [1:0] fwd_b
);
    always @* begin
        fwd_a = 2'b00;
        fwd_b = 2'b00;
        if (mem_wb_reg_write && mem_wb_rd != 0 && mem_wb_rd == id_ex_rs1) fwd_a = 2'b10;
        if (mem_wb_reg_write && mem_wb_rd != 0 && mem_wb_rd == id_ex_rs2) fwd_b = 2'b10;
        // newer value wins
        if (ex_mem_reg_write && ex_mem_rd != 0 && ex_mem_rd == id_ex_rs1) fwd_a = 2'b01;
        if (ex_mem_reg_write && ex_mem_rd != 0 && ex_mem_rd == id_ex_rs2) fwd_b = 2'b01;
    end
endmodule
