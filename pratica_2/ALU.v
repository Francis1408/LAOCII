module ALU (
	input [3:0] opcode,
	input [15:0] data1, data2,
	output reg [15:0] data_out
);

always @(opcode or data1 or data2) begin

	$display("opcode: %b", opcode);

	case (opcode)
		4'b0010: begin // add
			data_out <= data1 + data2;
		end

	  	4'b0011: begin // sub
	  		data_out <= data1 - data2;
		end

		4'b0111: begin // and
			if(data1 && data2) begin
				data_out <= 16'b1;
			end else begin
				data_out <= 16'b0;
			end
		end

		4'b1000: begin //slt
			data_out <= data1 < data2 ? 16'b1 : 16'b0;
		end

		4'b1001: begin // sll
			if(data1 << data2) begin
				data_out <= 16'b1;
			end else begin
				data_out <= 16'b0;
			end
		end
		
		4'b1001: begin // srl
			if(data1 >> data2) begin
				data_out <= 16'b1;
			end else begin
				data_out <= 16'b0;
			end
		end

	  	default : data_out <= 16'b0;
	  	
	endcase  
end

endmodule 