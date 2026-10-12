`timescale 1ps/1ps

module tb;

localparam DATA_WIDTH = 32;
localparam RAM_ADDRESS_WIDTH = 9;
localparam ROM_ADDRESS_WIDTH = 7;

// Automation
// ----------------------------------
integer X;
integer fd;
string mat_file;
string kernel_file;

// Clock and Reset
// ----------------------------------
reg clock;
reg reset;
reg core_finish;

// TestBench bindings
// -----------------------------------
reg ram_write_enable;
reg [(DATA_WIDTH - 1) : 0] ram_write_data;
reg [(RAM_ADDRESS_WIDTH - 1) : 0] ram_register_address;
reg [(ROM_ADDRESS_WIDTH - 1) : 0] rom_register_address;

wire [(DATA_WIDTH - 1) : 0] ram_read_data; 
wire [(DATA_WIDTH - 1) : 0] rom_read_data;

// RAM & ROM
// ------------------------------------
reg [(DATA_WIDTH - 1) : 0] matrix_values[169];
reg [(DATA_WIDTH - 1) : 0] kernel_values[4];

integer k;

DataMemoryFile#(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDRESS_WIDTH(RAM_ADDRESS_WIDTH)
) ram (
    .clock(clock),
    .reset(reset),
    .write_enable(ram_write_enable),
    .write_data(ram_write_data),
    .register_address(ram_register_address),
    .read_data(ram_read_data)
);

ProgramMemoryFile#(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDRESS_WIDTH(ROM_ADDRESS_WIDTH)
) rom (
    .clock(clock),
    .reset(reset),
    .register_address(rom_register_address),
    .read_data(rom_read_data)
);

// Core
// -----------------------------------

CustomCore#(
    .REGISTER_WIDTH(DATA_WIDTH),
    .REGISTER_ADDRESS_WDITH(5),
    .DATA_MEMORY_ADDRESS_WIDTH(RAM_ADDRESS_WIDTH),
    .INSTRUCTION_MEMORY_ADDRESS_WIDTH(ROM_ADDRESS_WIDTH)
) dut (
    .clock(clock),
    .reset(reset),
    .instruction_memory_read(rom_read_data),
    .instruction_memory_address(rom_register_address),
    .data_write_enable(ram_write_enable),
    .data_write_value(ram_write_data),
    .data_memory_read(ram_read_data),
    .data_memory_address(ram_register_address),
    .core_finish_signal(core_finish)
);

// Initialization
// ------------------------------------

initial begin
    clock = 1'b0;
    forever #5 clock = ~clock;
end

initial begin
    reset = 1'b1;
    @(posedge clock);
    @(posedge clock);

    // Read test number from command line
    if (!$value$plusargs("X=%d", X)) begin
        $display("ERROR: Missing test number.");
        $finish;
    end

    mat_file = $sformatf("test/input/test%0d.in", X);
    kernel_file = $sformatf("test/input/test%0d.kernel", X);

    $readmemh(mat_file, matrix_values);
    $readmemh(kernel_file, kernel_values);

    for (k = 0; k < 169; k = k + 1) begin
        ram.memory[k] = matrix_values[k];
    
        if (k < 4) begin
            ram.memory[169 + k] = kernel_values[k];
        end 
    end

    reset = 1'b0;
    wait (core_finish == 1'b1);

    // Dump the result of the convolution
    fd = $fopen("test_result.out", "w");
    if (fd == 0) begin
        $display("ERROR: could not open test_result.out");
        $finish;
    end

    for (k = 0; k < 121; k = k + 1) begin
        // %08h = zero-padded 8 hex digits (32-bit)
        $fdisplay(fd, "%08h", ram.memory[173 + k]);
    end

    $fclose(fd);
    $finish;
end

initial begin
  $dumpfile("wave.vcd");
  $dumpvars(0, tb);   // dump tb and everything under it (may be large)
end

endmodule