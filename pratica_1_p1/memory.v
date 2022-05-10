module memory(clock,data_out);


input clock;
output [7:0] data_out;

reg wren;
reg [7:0] address;
reg [7:0] data_in;

initial
begin

	// Escrita
	wren = 1;
	address = 8'b00001111;
	data_in = 8'b00011110; //30 numero de chamada
	#50;
	
	wren = 1;
	address = 8'b11110000;
	data_in = 8'b00000011; // 3 numero de chamada
	#100;
	
	// Leitura
	wren = 0;
	address = 8'b00001111;
	#150;
	
	wren = 0;
	address = 8'b11110000;
	#200;


end


// Modulo de acessoa 'a memoria
ram_memory  _RAM_ (address,clock,data_in,wren,data_out);