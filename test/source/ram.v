`timescale 1ps/1ps

module DataMemoryFile#(
    parameter DATA_WIDTH = 32,
    parameter ADDRESS_WIDTH = 5
) (
    input wire                          clock,
    input wire                          reset,
    input wire                          write_enable,

    input wire[(DATA_WIDTH - 1):0]      write_data,
    input wire[(ADDRESS_WIDTH - 1):0]   register_address,

    output wire[(DATA_WIDTH - 1):0]     read_data
);

localparam integer NUM_REGISTERS = 1 << ADDRESS_WIDTH;
integer i;

reg[(DATA_WIDTH - 1):0] memory[(NUM_REGISTERS - 1):0];
reg[(DATA_WIDTH - 1):0] output_data;

assign read_data = output_data;

always @(posedge clock) begin
    if (reset) begin
        // for (i=0; i<NUM_REGISTERS; i=i+1) begin
        //     memory[i] <= 0;
        // end 

        output_data <= 0;
    end else begin
        output_data <= 0;

        if (write_enable)
            memory[register_address] <= write_data;
        else
            output_data <= memory[register_address];
    end
end

endmodule
