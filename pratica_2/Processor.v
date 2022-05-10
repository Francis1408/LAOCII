module Processor (
	input [15:0] DIN,
	input clk, run, reset_n,
	output done,
	output [15:0] addr,
	output [15:0] dout,
	output mem_write,
	output din_selector,
	output [15:0] program_counter
);
	
/* 
			    INSTRUCTIONS
---------------------------------------------
0000 -> mv Rx, Ry    |   Rx <- [Ry]
0001 -> mvi Rx, #D   |	 Rx <- D
0010 -> add Rx, Ry   |	 Rx <- [Rx] + [Ry]
0011 -> sub Rx, Ry   |	 Rx <- [Rx] - [Ry]
0100 -> ld  Rx,[Ry]  |   Rx <- [[Ry]]
0101 -> st  Rx,[Ry]  |   [Ry] <- [Rx]
0110 -> mvnz Rx, Ry  |   if G!= 0, Rx <- [Ry]
0111 -> and Rx, Ry   |   Rx <- [Rx] & [Ry]
1000 -> slt Rx, Ry   |   if(Rx < Ry) [Rx] = 1
						 else [Rx] = 0
1001 -> sll Rx, Ry   |   Rx = [Rx] << [Ry]
1010 -> srl Rx, Ry   |   Rx = [Rx] >> [Ry]
1011 -> Halt
---------------------------------------------

			  MULTIPLEXER PORTS
---------------------------------------------
00 -> Bus = Register Data
01 -> Bus = DIN
10 -> Bus = Register G Data
---------------------------------------------

*/

// ControlUnit wires
wire [9:0] ctrlunit_instruction;
wire [1:0] ctrlunit_counter;
wire ctrlunit_done, ctrlunit_run;
wire ctrlunit_reg_selection;
wire [1:0] ctrlunit_mux_selector;
wire ctrlunit_g_write, ctrlunit_a_write, ctrlunit_reg_write, ctrlunit_ir_write;
wire ctrlunit_mem_write, ctrlunit_addr_write, ctrlunit_dout_write, ctrlunit_din_selector, ctrlunit_increment_pc;
wire ctrlunit_move_enable;
wire [3:0] ctrlunit_alu_opcode;
wire [2:0] ctrlunit_reg_x, ctrlunit_reg_y;



// Register Bank wires
wire rb_write;
wire [15:0] rb_data_in;
wire [15:0] rb_data_out;
wire [2:0] rb_select_read, rb_select_write;
wire [15:0] rb_reg7_data;
wire rb_increment_pc;


// G register wires
wire g_write;
wire [15:0] g_data_in;
wire [15:0] g_data_out;

// A register wires
wire a_write;
wire [15:0] a_data_in;
wire [15:0] a_data_out;

// ALU wires
wire [3:0]  alu_opcode;
wire [15:0] alu_data1, alu_data2;
wire [15:0] alu_data_out;

// IR register wires
wire ir_write;
wire [9:0] ir_instruction_in;
wire [9:0] ir_instruction_out;

// ADDR register wires
wire addr_write;
wire [15:0] addr_data_in;
wire [15:0] addr_data_out;

// DOUT register wires
wire dout_write;
wire [15:0] dout_data_in;
wire [15:0] dout_data_out;

// Counter
wire [1:0] step_counter;

// Bus
wire [15:0] bus;


always @(posedge clk) begin 
	$display("%b", bus);
end

// IR Input
assign ir_instruction_in = DIN [15:6];
assign ir_write = ctrlunit_ir_write;

// IR Module
IR_IRREG_ ir(
	.clk(clk),
	.reset_n(reset_n),
	.write(ir_write),
	.instruction_in(ir_instruction_in),
	.instruction_out(ir_instruction_out)
);

// Control Unit Input
assign ctrlunit_counter = step_counter;
assign ctrlunit_instruction = ir_instruction_out;
assign ctrlunit_move_enable = g_data_out != 16'b0 ? 1'b1 : 1'b0; // ~(| g_data_out)

// Control Unit Module
ControlUnit _CTRLUNIT_(
	.reset_n(reset_n),
	.run(ctrlunit_run),
	.instruction(ctrlunit_instruction),
	.move_enable(ctrlunit_move_enable),
	.counter(ctrlunit_counter),
	.done(ctrlunit_done),
	.mux_selector (ctrlunit_mux_selector),
	.reg_write(ctrlunit_reg_write),
	.reg_selection(ctrlunit_reg_selection),
	.a_write(ctrlunit_a_write),
	.g_write(ctrlunit_g_write),
	.ir_write(ctrlunit_ir_write),
	.addr_write(ctrlunit_addr_write),
	.dout_write(ctrlunit_dout_write),
	.mem_write(ctrlunit_mem_write),
	.alu_opcode(ctrlunit_alu_opcode),
	.din_selector(ctrlunit_din_selector),
	.increment_pc(ctrlunit_increment_pc),
	.reg_x(ctrlunit_reg_x),
	.reg_y(ctrlunit_reg_y)

);

// Mux3x2 Module
Mux3x2 _MUX3X2_(
	.input1(ctrlunit_reg_x),
	.input2(ctrlunit_reg_y),
	.mux_selector(ctrlunit_reg_selection),
	.out(rb_select_read) 

);

// Mux16x4 Module
Mux16x4 _MUX16X4_(
	.input1(rb_data_out),
	.input2(DIN),
	.input3(g_data_out),
	.mux_selector(ctrlunit_mux_selector),
	.out(bus)
);

// Register Bank Input
assign rb_data_in = bus;
assign rb_write = ctrlunit_reg_write;
assign rb_increment_pc = ctrlunit_increment_pc;
assign rb_select_write = ctrlunit_reg_x;

// Register Bank Module
RegBank _RB_(
	.clk(clk), 
	.reset_n(reset_n), 
	.write(rb_write), 
	.reg_selected_read(rb_select_read),
	.reg_selected_write(rb_select_write),
	.data_in(rb_data_in),
	.data_out(rb_data_out),
	.increment_pc(rb_increment_pc),
	.reg7_data(rb_reg7_data) 
);

// A register Input
assign a_data_in = bus;
assign a_write = ctrlunit_a_write;

// A register Module
A _AREG_(
	.clk(clk),
	.reset_n(reset_n),
	.write(a_write),
	.data_in(a_data_in),
	.data_out(a_data_out)
);

// ALU Input
assign alu_data1 = a_data_out;
assign alu_data2 = bus;
assign alu_opcode = ctrlunit_alu_opcode;

// Alu Module
ALU _ALU_(
	.opcode(alu_opcode),
	.data1(alu_data1),
	.data2(alu_data2),
	.data_out(alu_data_out)
);

// G register Input
assign g_data_in = alu_data_out;
assign g_write = ctrlunit_g_write;

// G Module
G _GREG_(
	.clk(clk),
	.reset_n(reset_n),
	.write(g_write),
	.data_in(g_data_in),
	.data_out(g_data_out)
);

// Step Counter Module
StepCounter _STEPCOUNTER_(
	.clk(clk),
	.reset_n(reset_n),
	.clear(ctrlunit_done),
	.counter(step_counter)

);

// ADDR Input
assign addr_data_in = bus;
assign addr_write = ctrlunit_addr_write;

// ADDR Module
ADDR _ADDR_(
	.clk(clk),
	.reset_n(reset_n),
	.write(addr_write),
	.data_in(addr_data_in),
	.data_out(addr_data_out)
);

// DOUT Input
assign dout_data_in = bus;
assign dout_write = ctrlunit_dout_write;

// DOUT Module
DOUT _DOUT_(
	.clk(clk),
	.reset_n(reset_n),
	.write(dout_write),
	.data_in(dout_data_in),
	.data_out(dout_data_out)
);



// Processor output
assign addr = addr_data_out;
assign dout = dout_data_out;
assign done = ctrlunit_done;
assign mem_write = ctrlunit_mem_write;
assign program_counter = rb_reg7_data;
assign din_selector = ctrlunit_din_selector;

endmodule 