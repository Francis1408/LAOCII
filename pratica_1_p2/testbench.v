
`timescale 1ps / 1ps
module \testbench.v   ; 
 
  reg    clock   ; 
  wire  [7:0]  data_out   ; 
  memory  
   DUT  ( 
       .clock (clock ) ,
      .data_out (data_out ) ); 



// "Clock Pattern" : dutyCycle = 50
// Start Time = 0 ps, End Time = 1 ns, Period = 100 ps
  initial
  begin
   repeat(10)
   begin
	   clock  = 1'b1  ;
	  #50  clock  = 1'b0  ;
	  #50 ;
// 1 ns, repeat pattern in loop.
   end
	#100 ;
  end

  initial
	#2200 $stop;
endmodule
