


module mux_merge(clock, instruction, data_inb, data_inc, mux_out);

input clock;
input [15:0]instruction;
input [15:0] data_inb;
input [15:0] data_inc;

output reg[41:0] mux_out;

reg [3:0] temp_op;
reg [3:0] temp_a;
reg [3:0] temp_b;
reg [3:0] temp_c;

reg async;

initial async = 0;

always @(posedge clock) begin

	if(async) begin
		//         
		mux_out = {temp_op, temp_a, temp_b, data_inb, temp_c, data_inc};
		async   = !async;
	end
	if(!async) begin
		temp_op = instruction[15:12];
		temp_a  = instruction[11:08];
		temp_b  = instruction[07:04];
		temp_c  = instruction[03:00];
		async = !async;
	end

end


endmodule

