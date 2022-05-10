module A (
	input clk,    // Clock
	input reset_n,  
	input write,
	input [15:0] data_in,
	output [15:0] data_out
	
);

reg [15:0] a_reg;

always @(posedge clk or posedge reset_n) begin 
	if(reset_n == 1) begin
		a_reg <= 16'b0; 
	end 
	else if(write == 1) begin
		a_reg <= data_in;
	end
end

assign data_out = a_reg;

endmodule 