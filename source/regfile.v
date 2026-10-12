`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.10.2026 16:46:34
// Design Name: 
// Module Name: regfile
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

module regfile #(parameter W = 32, parameter AW = 5)(
    input  wire          clock,
    input  wire          reset,
    input  wire          we,
    input  wire [AW-1:0] waddr,
    input  wire [W-1:0]  wdata,
    input  wire [AW-1:0] raddr1,
    input  wire [AW-1:0] raddr2,
    output wire [W-1:0]  rdata1,
    output wire [W-1:0]  rdata2
);
    reg [W-1:0] regs [0:(1<<AW)-1];
    integer i;

    always @(posedge clock) begin
        if (reset) begin
            for (i = 0; i < (1<<AW); i = i + 1) regs[i] <= 0;   // ra must be 0 for the final ret
        end else if (we && waddr != 0) begin
            regs[waddr] <= wdata;
        end
    end

    // async read, x0 = 0, write-through bypass (WB -> ID same cycle)
    assign rdata1 = (raddr1 == 0) ? {W{1'b0}} : (we && waddr == raddr1) ? wdata : regs[raddr1];
    assign rdata2 = (raddr2 == 0) ? {W{1'b0}} : (we && waddr == raddr2) ? wdata : regs[raddr2];
endmodule
