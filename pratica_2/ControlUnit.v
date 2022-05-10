module ControlUnit (
	input reset_n, run,
	input [9:0] instruction,
	input [1:0] counter,
	input move_enable, 
	output reg done,
	output reg [1:0] mux_selector,
	output reg reg_write,
	output reg reg_selection,
	output reg ir_write,
	output reg a_write, g_write,
	output reg addr_write, dout_write,
	output reg mem_write,
	output reg din_selector,
	output reg increment_pc,
	output reg [3:0] alu_opcode,
	output [2:0] reg_x, reg_y
	
);

initial begin
	din_selector = 1'b0;
	reg_write = 1'b0;
	ir_write = 1'b1;
	mem_write = 1'b0;
	addr_write = 1'b0;
	dout_write = 1'b0;
	done = 1'b0;
end

wire [3:0] opcode;
assign opcode = instruction[9:6];
assign reg_x = instruction[5:3];
assign reg_y = instruction[2:0];

always @(*) begin 

	$display(" opcode: %b stepcounter: %b", opcode, counter);

	case (opcode) 
		4'b0000: begin // mv
			case (counter)
				2'b00: begin
					ir_write <= 1'b1; //IRin
					din_selector <= 1'b0; // Read instruction from ROM
					increment_pc <= 1'b0;
				end

				2'b01: begin
					reg_selection <= 1'b1;
					mux_selector <= 2'b00; // Get data from Register Bank
					reg_write <= 1'b1;
					a_write <= 1'b0;
					g_write <= 1'b0;
					alu_opcode <= 4'b0;
					ir_write <= 1'b0;
					dout_write <= 1'b0;
					addr_write <= 1'b0; 
					mem_write <= 1'b0;
					din_selector <= 1'b0;

					if(reg_x == 3'b111) begin
						increment_pc <= 1'b0;
					end else begin
						increment_pc <= 1'b1;
					end

				end
			endcase
		end

		4'b0001: begin //mvi
			case (counter)
				2'b00: begin
					ir_write <= 1'b1; //IRin
					din_selector <= 1'b0; // Read instruction from ROM
					increment_pc <= 1'b1;
				end

				2'b01: begin
					//reg_selection (irrelevant)
					mux_selector <= 2'b01; // Get data from DIN
					reg_write <= 1'b1;
					a_write <= 1'b0;
					g_write <= 1'b0;
					alu_opcode <= 4'b0;
					ir_write <= 1'b0;
					dout_write <= 1'b0;
					addr_write <= 1'b0; 
					mem_write <= 1'b0;
					din_selector <= 1'b0;

					if(reg_x == 3'b111) begin
						increment_pc <= 1'b0;
					end else begin
						increment_pc <= 1'b1;
					end

				end	
			endcase
		end
		
		4'b0010, 4'b0011, 4'b0111, 4'b1000, 4'b1001, 4'b1010: begin //add, sub, and, slt, sll, srl
			case (counter)
				2'b00: begin
					ir_write <= 1'b1; //IRin
					din_selector <= 1'b0; // Read instruction from ROM
					increment_pc <= 1'b0;
				end

				2'b01: begin
					reg_selection <= 1'b0; // RXout
					mux_selector <= 2'b00; // Get data from Register Bank
					reg_write <= 1'b0;
					a_write <= 1'b1; // Ain
					g_write <= 1'b0;
					alu_opcode <= 4'b0;
					ir_write <= 1'b0;
					dout_write <= 1'b0;
					addr_write <= 1'b0; 
					mem_write <= 1'b0;
					din_selector <= 1'b0;

					increment_pc <= 1'b1;
				end

				2'b10: begin
					reg_selection <= 1'b1; // RYout
					mux_selector <= 2'b00; // Get data from Register Bank
					reg_write <= 1'b0;
					a_write <= 1'b0;
					g_write <= 1'b1; // Gin
					alu_opcode <= opcode; 
					ir_write <= 1'b0;
					dout_write <= 1'b0;
					addr_write <= 1'b0; 
					mem_write <= 1'b0;
					din_selector <= 1'b0;

					increment_pc <= 1'b0;
				end

				2'b11: begin
					reg_selection <= 1'b0; // Rx Selected
					mux_selector <= 2'b10; // Get data from G Register 
					reg_write <= 1'b1; //RXin
					a_write <= 1'b0;
					g_write <= 1'b0; 
					alu_opcode <= 4'b0; 
					ir_write <= 1'b0;
					dout_write <= 1'b0;
					addr_write <= 1'b0; 
					mem_write <= 1'b0;
					din_selector <= 1'b0;

					increment_pc <= 1'b1;
				end
			endcase
		end

		4'b0100: begin // ld
			case (counter)
				2'b00: begin
					ir_write <= 1'b1; // IRin
					din_selector <= 1'b0; // Read instruction from ROM
					increment_pc <= 1'b0;
				end

				2'b01: begin
					reg_selection <= 1'b1; // RYout (Address)
					mux_selector <= 2'b00; // Get data from Register Bank
					reg_write <= 1'b0;
					a_write <= 1'b0;
					g_write <= 1'b0; 
					alu_opcode <= 4'b0; 
					ir_write <= 1'b0;
					dout_write <= 1'b0;
					addr_write <= 1'b1; //Write on ADDR Register
					mem_write <= 1'b0;
					din_selector <= 1'b0;

					increment_pc <= 1'b0;
				end

				2'b10: begin
					reg_selection <= 1'b0; // RXout 
					mux_selector <=  2'b01; // Get data from DIN
					reg_write <= 1'b1; // Load information in register
					a_write <= 1'b0;
					g_write <= 1'b0;
					alu_opcode <= 4'b0; 
					ir_write <= 1'b0;
					dout_write <= 1'b0;
					addr_write <= 1'b0;
					mem_write <= 1'b0;
					din_selector <= 1'b1; // Read data from memory

					increment_pc <= 1'b1;
				end
			endcase
		end

		4'b0101: begin // st
			case (counter)
				2'b00: begin
					ir_write <= 1'b1; //IRin
					din_selector <= 1'b0; // Read instruction from ROM
					increment_pc <= 1'b0;
				end

				2'b01: begin
					reg_selection <= 1'b1; //RYout (Address)
					mux_selector <= 2'b00; //Get data from Register Bank
					reg_write <= 1'b0;
					a_write <= 1'b0;
					g_write <= 1'b0;
					alu_opcode <= 4'b0;
					ir_write <= 1'b0;
					dout_write <= 1'b0;
					addr_write <= 1'b1; // Write on ADDR Register
					mem_write <= 1'b0;

				end

				2'b10: begin
					reg_selection <=1'b0; //Rxout (Data)
					mux_selector <= 2'b00; // Get data from Register Bank
					reg_write <= 1'b0;
					a_write <= 1'b0;
					g_write <= 1'b0;
					alu_opcode <= 4'b0;
					ir_write <= 1'b0;
					dout_write <= 1'b1; // Write on DOUT Register
					addr_write <= 1'b0;
					mem_write <= 1'b1; //Write on memory

					increment_pc <= 1'b1;

				end
			endcase
		end

		4'b0110: begin //mvnz
			case (counter)
				2'b00: begin
					ir_write <= 1'b1; //IRin
					din_selector <= 1'b0; // Read instruction from ROM
					increment_pc <= 1'b0;
				end
				2'b01: begin
					reg_selection <= 1'b1; // RYout (Address)
					mux_selector <= 2'b00; // Get data from Register Bank
					a_write <= 1'b0;
					g_write <= 1'b0; 
					alu_opcode <= 4'b0; 
					ir_write <= 1'b0;
					dout_write <= 1'b0;
					addr_write <= 1'b0; 
					mem_write <= 1'b0;
					din_selector <= 1'b0;

					if(move_enable == 1'b1) begin
						reg_write <= 1'b1; 
					end else begin
						reg_write <= 1'b0;
					end

					if(reg_x == 3'b111 && move_enable == 1'b1) begin
						increment_pc <= 1'b0;
					end else begin
						increment_pc <= 1'b1;
					end
				end
			endcase
		end 
		4'b1011 : begin
			done <= 1'b1;
		end
		default: begin
			done <= 1'b1;
		end
	endcase
end

endmodule