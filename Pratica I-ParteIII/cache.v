module cache #(
		parameter DEPTH, TAG_SIZE
)(
	input clk, write, 
	input [7:0] address,
	input [15:0] dataIn,
	output reg [15:0] dataOut,
	output reg writeback,
	output reg hit
	);

wire tag = address[DEPTH-1:DEPTH-TAG_SIZE];
wire index = address[DEPTH-TAG_SIZE-1:0];

reg [15:0] way1_data [0:DEPTH-1];
reg [TAG_SIZE:0] way1_tag [0:DEPTH-1];
reg [DEPTH-1:0] way1_valid;
reg [DEPTH-1:0] way1_lru;
reg [DEPTH-1:0] way1_dirty;

// way2 regs

reg [15:0] way2_data [0:DEPTH-1];
reg [TAG_SIZE:0] way2_tag [0:DEPTH-1];
reg [DEPTH-1:0] way2_valid;
reg [DEPTH-1:0] way2_lru;
reg [DEPTH-1:0] way2_dirty;

always @(posedge clk) begin 

	valid1 = !way1_valid[index];
	valid2 = !way2_valid[index];

	
	case(write)
		1'b0 : begin
		
			if(way1_valid[index] == 0 && (way2_valid[index] == 0)
				begin
					miss = 1;
					way1_valid = 1;
					way2_lru = 1;
					way1_tag = TAG;
					data_out = way1_data[index];
				end
			else
			if ((way1_valid[index] == 1 && way1_tag[index] == tag) || !valid1) begin
				dataOut <= way1_data[index];
				way1_valid[index] = 1;
				hit <= 1'b1; // Ocurred a Hit
				way1_lru[index] <= 1'b1;
				way2_lru[index] <= 1'b0;
			end
			else if ((way2_valid[index] == 1 && way2_tag[index] == tag) || !valid2) begin
				dataOut <= way2_data[index];
				hit <= 1'b1; // Ocurred a Hit
				way2_lru[index] <= 1'b1;
				way1_lru[index] <= 1'b0;
			end
			else
			begin
				if(way1_lru)
				begin
					miss = 1;
					way1_valid = 1;
					way2_lru = 1;
					way1_tag = TAG;
					data_out = way1_data[index];	
				end
				else
				begin
					miss = 1;
					way1_valid = 1;
					way2_lru = 1;
					way1_tag = TAG;
					data_out = way1_data[index];

				end

			end

		end
		// Write command in cache
		1'b1 : begin
			// WRITES ON THE WAY 1 WITH SAME TAG
			 if(way1_tag[index] == tag && way1_valid[index] == 1) begin
				way1_data[index] <= dataIn;
				way1_lru[index] <= 1'b1;
				way2_lru[index] <= 1'b0;
				hit <= 1'b1; // Ocurred a Hit
					if(way1_dirty[index] != 0)begin 
						way1_dirty[index] <= 1'b0; 
						writeback <= 1'b1; // Calls the writeback
					end
					else way1_dirty[index] <= 1'b1; // If it is clear, dirt it
				end
			// WRITES ON THE WAY 2 WITH SAME TAG
			else if(way2_tag[index] == tag && way2_valid[index] == 1) begin
				way2_data[index] <= dataIn;
				way2_lru[index] <= 1'b1;
				way1_lru[index] <= 1'b0;
				hit <= 1'b1; // Ocurred a Hit
					if(way2_dirty[index] != 0)begin // If the bit is already dirty
						writeback <= 1'b1; // Calls the writeback
					end
					else way2_dirty[index] <= 1'b1; // If it is clear, dirt it
				end
			else hit <= 1'b0; //Ocurred a Miss 
		end
	endcase
end


endmodule





