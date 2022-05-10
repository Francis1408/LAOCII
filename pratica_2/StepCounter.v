module StepCounter (
	input clk,    // Clock
	input reset_n,
	input clear, // Done
	output reg [1:0] counter
);

always @(posedge clk ) begin

	if(reset_n || clear ) begin
		counter <= 2'b0;
	end else begin
		counter <= counter + 1;
	end
end

endmodule 