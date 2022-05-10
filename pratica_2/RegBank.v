module RegBank(
	input clk,    // Clock
	input reset_n, //Reset
	input write, // If is a write command
	input [2:0] reg_selected_read, reg_selected_write, // Register selected for reading or writing
	input [15:0] data_in, //Data In
	input increment_pc,
	output [15:0] data_out, // Data Out
	output [15:0] reg7_data // Register 7 data
	
);


reg [15:0] RegBank [0:7]; // Declaring the bank


integer i;

initial begin
	for (i = 0; i < 8; i=i+1) begin
		RegBank[i] <= 16'b0; 
	end
end


always @(posedge clk or posedge reset_n) begin 
	if(reset_n == 1) begin // if refresh is on
		for (i = 0; i < 8; i=i+1) begin
			RegBank[i] <= 16'b0; // Clear data from RegBank
		end
	end 
	else if (write == 1) begin
		RegBank[reg_selected_write] <= data_in;
	end

	$display("Reg 0: %b Reg 1: %b Reg 2: %b Reg 3: %b",RegBank[0], RegBank[1], RegBank[2], RegBank[3]);
end
	
assign data_out = RegBank[reg_selected_read];



assign reg7_data = RegBank[7];

endmodule 