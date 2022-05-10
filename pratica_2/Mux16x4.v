module Mux16x4 (
	input [15:0] input1, input2, input3,
	input [1:0] mux_selector,
	output reg [15:0] out
	
);

always @(*) begin
	case (mux_selector)
		2'b00: out = input1;
		2'b01: out = input2;
		2'b10: out = input3;
	endcase
end

endmodule