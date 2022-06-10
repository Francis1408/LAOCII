


module tomasulo(clock);

input clock;


// ROM
wire [15:0]rom_out;
wire rom_read;


// HEAP
wire [15:0] heap_in;
wire [15:0] heap_out;
wire heap_rom_read;
wire heap_read;


// DYNAMIC
wire [15:0]dy_in;
wire dy_heap_read;


// MUX
wire [15:00] instruction;
wire [15:00] data_inb;
wire [15:00] data_inc;
wire [41:00] mux_out;



// REGISTER_DB
wire read_db;
wire store_db;
wire [03:00] add_a;
wire [03:00] add_b;
wire [03:00] add_c;

wire [15:00] out_b;
wire [15:00] out_c;



ROM                module_rm(clock, rom_read, rom_out);

heap               module_hp(clock, heap_in, heap_read, heap_out, read_out, heap_rom_read);

mux_merge          module_mx(clock, instruction, data_inb, data_inc, mux_out);

register_db        module_db(clock, read_db, store_db, add_a, add_b, add_c, data_in, out_b, out_c);

//reserve_station    module_dy(clock, dy_in, dy_heap_read);

assign heap_in = rom_out;        // saida da rom para a heap
assign rom_read = heap_rom_read; // sinal de controle de leitura da heap para a rom
assign instruction = heap_out;   // saida da heap para o mux
assign read_db = read_out;       // sinal de controle da heap que informa que uma instrução foi despachada

// assim 
assign add_a = heap_out[11:08];
assign add_b = heap_out[07:04];
assign add_c = heap_out[03:00];


assign data_inb = out_b;
assign data_inc = out_c;

endmodule