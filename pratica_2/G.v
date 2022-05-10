module G (
	input clk,    // Clock
	input reset_n, 
	input write,
	input [15:0] data_in,
	output [15:0] data_out
);

reg [15:0] g_reg;

always @(posedge clk or posedge reset_n) begin 

	if(reset_n == 1) begin
		g_reg <= 16'b0; 
	end 
	else if(write == 1) begin
		g_reg <= data_in;
	end

	$display("%b", g_reg);
end

assign data_out = g_reg;

endmodule 