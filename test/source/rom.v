`timescale 1ps/1ps

module ProgramMemoryFile#(
    parameter DATA_WIDTH = 32,
    parameter ADDRESS_WIDTH = 5
) (
    input wire                          clock,
    input wire                          reset,

    input wire[(ADDRESS_WIDTH - 1):0]   register_address,

    output wire[(DATA_WIDTH - 1):0]     read_data
);

localparam integer NUM_REGISTERS = 1 << ADDRESS_WIDTH;
integer i;

reg[(DATA_WIDTH - 1):0] memory[0:(NUM_REGISTERS - 1)];

assign read_data = memory[register_address];

initial begin
    for (i = 0; i < NUM_REGISTERS; i = i + 1) memory[i] = 0;
    $readmemh("test/program.hex", memory);
end

endmodule
