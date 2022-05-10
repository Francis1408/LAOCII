module Mux16x2 (
	input [15:0] input1, input2,
	input mux_selector,
	output reg [15:0] out
	
);

always @(*) begin 
	if(mux_selector == 1'b1) begin
		 out <= input1;
		 
	end else begin
		 out <= input2 ;
	end
end
endmodule 