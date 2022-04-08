module main (

);

reg clock;
reg wren;
reg [4:0] address;
reg [7:0] data;

initial begin
	#0 clock = 0;
	forever #5 clock = ~clock;

	#0 wren = 1'b1;
	#0 address = 8'b00000100;
	#0 data = 8'b00000100;
	#10 address = 8'b00010000;
	#10 data = 8'b0001100;
	#15 wren = 1'b0;
	#15 address = 8'b00000100;
	#30 address = 8'b00010000;

end

ramlpm _RAM_(
	.address(address),
	.clock(clock),
	.data(data),
	.wren(wren),
	);

endmodule 