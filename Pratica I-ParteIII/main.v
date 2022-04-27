module main(input clk);

	// cpu wires
	wire cpu_write;
	wire cpu_address;
	wire cpu_data;

	cpu _CPU_(
		.clk(clk),
		// -- outs
		.write(cpu_write),
		.address(cpu_address),
		.data(cpu_data)
);

	// cache l1 wires
	wire l1_write;
	wire l1_rewrite;
	wire l1_address;
	wire l1_dataIn;
	wire l1_dataOut;
	wire l1_writeback;
	wire l1_hit;

	// ------ CPU and L1 communication -----
	assign l1_address = cpu_address;
	assign l1_write = cpu_write;
	assign l1_dataIn = cpu_data;
	assign l1_rewrite = 1'b0;
	// --------------------------------------

	cache #(
		.DEPTH(2),
		.TAG_SIZE(7)
		) 
		_L1_(
		.clk(clk),
		.write(l1_write),
		.address(l1_address),
		.dataIn(l1_dataIn),
		.dataOut(l1_dataOut),
		.writeback(l1_writeback),
		.hit(l1_hit)
		);

	// cache l2 wires
	wire l2_write;
	wire l2_rewrite;
	wire l2_address;
	wire l2_dataIn;
	wire l2_dataOut;
	wire l2_writeback;
	wire l2_hit;

	// --------- L1 and L2 communication ------
	assign l2_write = l1_write;
	assign l2_address = l1_address;
	assign l2_dataIn = l1_dataOut;


	cache #(
		.DEPTH(4),
		.TAG_SIZE(5)
		)
		_L2_(
		.clk(clk),
		.write(l2_write),
		.address(l2_address),
		.dataIn(l2_dataIn),
		.dataOut(l2_dataOut),
		.writeback(l2_writeback),
		.hit(l2_hit)
		);


	// ram wires
	wire ram_write;
	wire ram_address;
	wire ram_dataIn;
	wire ram_dataOut;

// --------- L2 and RAM communication ------
	assign ram_address = l2_address;
	assign ram_dataIn = l2_dataOut;
	assign ram_write = l2_write;
// -----------------------------------------

	ram _MEM_(
		.address(ram_address),
		.clk(clk), 
		.dataIn(ram_dataIn),
		.write(ram_write),
		.dataOut(ram_dataOut)
	);



endmodule // main
