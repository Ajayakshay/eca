`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.10.2026 16:44:24
// Design Name: 
// Module Name: alu
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

module alu #(parameter W = 32)(
    input  wire [W-1:0] a,
    input  wire [W-1:0] b,
    input  wire [1:0]   op,      // 0 ADD, 1 SLL, 2 MUL
    output reg  [W-1:0] result
);
    always @* begin
        case (op)
            2'd1:    result = a << b[4:0];
            2'd2:    result = a * b;        // low W bits
            default: result = a + b;
        endcase
    end
endmodule