module multicicle_processor (
	
);

reg clock;
reg reset_n;

// ROM wires
wire [15:0] rom_data_out;
wire [7:0] rom_address;

// RAM wires
wire [15:0] ram_data_in;
wire [7:0] ram_address;
wire [15:0] ram_data_out;
wire ram_write;

// Processor wires
wire [15:0] processor_din;
wire processor_run;
wire processor_done;
wire processor_mem_write;
wire [15:0] processor_addr;
wire [15:0] processor_dout;
wire [15:0] processor_program_counter;
wire processor_din_selector;


Processor _CPU_(
	.clk(clock),
	.DIN(processor_din),
	.run(processor_run),
	.reset_n(reset_n),
	.done(processor_done),
	.addr(processor_addr),
	.dout(processor_dout),
	.mem_write(processor_mem_write),
	.din_selector(processor_din_selector),
	.program_counter(processor_program_counter)
);

Mux16x2 _MUX16X2_(
	.input1(ram_data_out),
	.input2(rom_data_out),
	.mux_selector(processor_din_selector),
	.out(processor_din)
);

assign rom_address = processor_program_counter[7:0];

ROM _ROM_(
	.address(rom_address),
	.clock(clock),
	.q(rom_data_out)
);


assign ram_address = processor_addr[7:0];
assign ram_data_in = processor_dout;
assign ram_write = processor_mem_write;

RAM _RAM_(
	.clock(clock),
	.address(ram_address),
	.data(ram_data_in),
	.q(ram_data_out),
	.wren(ram_write)
);

endmodule