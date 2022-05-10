module memory(clock,data_out);


input clock;
output [7:0] data_out;

reg wren;
reg [7:0] address;
reg [7:0] data_in;

initial
begin
	wren = 0;
	address = 8'b00000000;
	#100;
end


// Contador para percorrer todas as posicoes da memoria
always @(posedge clock)
begin
	address = address + 1;
end

// Módulo LPM
ram_memory  _RAM_ (address,clock,data_in,wren,data_out);




endmodule