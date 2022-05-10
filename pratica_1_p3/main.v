module main (clock, instruction, miss, wback, data_out) ;

input clock;
input [8:0]instruction;

output miss;
output wback;
output [2:0] data_out;

cache cache_memory(clock, instruction, miss, wback, data_out);

endmodule