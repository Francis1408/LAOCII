module Mux3x2 (
	input [2:0] input1, input2,
	input mux_selector,
	output reg [2:0] out
	
);

always @(*) begin 
	if(mux_selector == 1) begin
		 out <= input1;
		 
	end else begin
		 out <= input2 ;
	end
end

endmodule 