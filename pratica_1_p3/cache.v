



module cache (clock, instruction, miss, wback, data_out);


input clock;
input [8:0]instruction;


output reg miss;
output reg wback;
output reg [2:0] data_out;



// instruction
// [   [8:8]    [7:6]      [5:3]   [2:0]  ]
// [    [wr]   [index]     [TAG]   [DATA]  ]
// [  [1 bit] [ 2 bits ] [3 bits] [3 bits] ]

// Chanel 1
// word   -> [    [8:8]       [7:7]       [6:6]      [5:3]     [2:0]    ] <- Positions on array
// word   -> [  [ valid ]   [ dirty ]    [ LRU ]    [ TAG ]   [ DATA ]  ] <- Representation
// Size   -> [   [1 bit]     [1 bit]     [1 bit]    [3 bits]  [3 bits]  ] <- Size
reg [8:0]cache[7:0];

reg [1:0] index;
reg [2:0] tag;

initial 
begin
	index = 2'b00;
	cache[00] = 9'b000000000;
end


always @(posedge clock)

begin
	
	index = instruction[7:6];
	tag = instruction[5:3];
	
		case(instruction[8:8])
			// Read
			1'b0 :  	begin
		
	
							if(!cache[index][8:8] && !cache[index+4][8:8])
							begin
								miss <= 1;                     // miss
								cache[index][8:8] <= 1;        // valid
								cache[index][7:7] <= 0;			 // dirt	
								cache[index][6:6] <= 1;        // LRU 
								cache[index][5:3] <= tag;      // TAG
								data_out <= cache[index][2:0]; // leitura
							end
							else
							if((cache[index][8:8] == 1 && cache[index][5:3] == tag) || !cache[index][8:8])
								begin
									miss <= 0 || !cache[index][8:8]; // Miss
									wback = cache[index][7:7] || 0;  // wback
									cache[index][8:8] <= 1;          // Valid
									cache[index][7:7] <= 0;			   // dirt
									cache[index][6:6] <=1;           // LRU
									cache[index+4][6:6] <=0;         // LRU from way 2
									cache[index][5:3] <= tag;        // TAG
									data_out <= cache[index][2:0];   // reading
								end
								else
								if((cache[index+4][8:8] == 1 && cache[index+4][5:3] == tag) || !cache[index+4][8:8])
								begin 
									miss <= 0 || !cache[index+4][8:8]; // Miss
									wback = cache[index + 4][7:7] || 0;// wback
									cache[index+4][8:8] <= 1;          // Valid
									cache[index+4][7:7] <= 0;			  // dirt
									cache[index+4][6:6] <=1;           // LRU 
									cache[index][6:6] <=0;             // LRU from way 1
									cache[index+4][5:3] <= tag;        // TAG
									data_out <= cache[index+4][2:0];   // reading
								end
								else
								begin
									if(!cache[index+4][6:6])
										begin
										miss <= 1;
										wback = cache[index + 4][7:7] || 0;// wback
										cache[index + 4][8:8] <= 1;       // Valid
										cache[index + 4][7:7] <= 0;		 // dirt
										cache[index + 4][6:6] <=1;        // LRU
										cache[index][6:6] <=0;            // LRU from another way
										cache[index+4][5:3] <= tag;       // TAG
										data_out <= cache[index+4][2:0];  // reading
									end
									else
									if(!cache[index][6:6])
										begin
										miss <= 1;
										wback = cache[index][7:7] || 0;   
										cache[index ][8:8] <= 1;          // Valid
										cache[index ][7:7] <= 0;			 // dirt
										cache[index ][6:6] <=1;           // LRU
										cache[index + 4][6:6] <=0;        // LRU from another way 
										cache[index][5:3] <= tag;         // TAG
										data_out <= cache[index][2:0];    // reading
									end
								end
						end
			// Write
			1'b1 : 	begin
			
							if(!cache[index][8:8] && !cache[index+4][8:8])
							begin
								miss <= 1;                             // miss
								cache[index][8:8] <= 1;                // valid
								cache[index][7:7] <= 1;			         // dirt	
								cache[index][6:6] <= 1;                // LRU 
								cache[index][5:3] <= tag;              // TAG
								cache[index][2:0] <= instruction[2:0]; // leitura
							end
							else
			
							if((cache[index][8:8] == 1 && cache[index][5:3] == tag))
							begin
								miss <= 0;                              // miss
								wback = cache[index][7:7] || 0;         // wback
								cache[index][8:8] <= 1;                 // valid
								cache[index][7:7] <= 1;			          // dirt	
								cache[index][6:6] <= 1;                 // LRU
								cache[index+4][6:6] <= 0;               // LRU from another way
								cache[index][5:3] <= tag;               // TAG
								cache[index][2:0] <= instruction[2:0];  // leitura
							end
							else
							if((cache[index+4][8:8] == 1 && cache[index+4][5:3] == tag))
							begin
								miss <= 0;                               // miss
								wback = cache[index+4][7:7] || 0;        // wback
								cache[index+4][8:8] <= 1;                // valid
								cache[index+4][7:7] <= 1;			        // dirt	
								cache[index+4][6:6] <= 1;                // LRU
								cache[index][6:6] <= 0;                  // LRU from another way	
								cache[index+4][5:3] <= tag;              // TAG
								cache[index+4][2:0] <= instruction[2:0]; // leitura
							end
							else
							begin
								if(!cache[index+4][6:6])
										begin
										miss <= 1;                               // miss
										wback = cache[index+4][7:7] || 0;        // wback
										cache[index + 4][8:8] <= 1;              // Valid
										cache[index + 4][7:7] <= 1;			     // dirt
										cache[index + 4][6:6] <=1;               // LRU
										cache[index][6:6] <=0;                   // LRU from another way
										cache[index][5:3] <= tag;                // TAG
										cache[index+4][2:0] <= instruction[2:0]; // reading
									end
									else
									if(!cache[index][6:6])
										begin
										miss <= 1;
										wback = cache[index][7:7] || 0;
										cache[index ][8:8] <= 1;                // Valid
										cache[index ][7:7] <= 1;			       // dirt
										cache[index ][6:6] <=1;                 // LRU
										cache[index + 4][6:6] <=0;              // LRU from another way
										cache[index][5:3] <= tag;                // TAG
										cache[index][2:0] <= instruction[2:0];  // reading
									end
							end
					end
						
		endcase

end




endmodule