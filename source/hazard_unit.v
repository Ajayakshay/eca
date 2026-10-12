`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.10.2026 16:47:39
// Design Name: 
// Module Name: hazard_unit
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

module hazard_unit(
    input  wire       id_ex_mem_read,   // load currently in EX
    input  wire [4:0] id_ex_rd,
    input  wire [4:0] if_id_rs1,
    input  wire [4:0] if_id_rs2,
    input  wire       uses_rs1,         // from decoder (instruction in ID)
    input  wire       uses_rs2,
    output wire       stall             // hold PC + IF/ID, bubble into ID/EX
);
    assign stall = id_ex_mem_read && (id_ex_rd != 0) &&
                   ((uses_rs1 && id_ex_rd == if_id_rs1) ||
                    (uses_rs2 && id_ex_rd == if_id_rs2));
endmodule
