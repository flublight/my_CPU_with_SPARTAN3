//top file
`timescale 1ns/1ps
module my_Peocessing_System_top(
  input CLK,
  input RST,
  output [15:0]CNT_out
);

//clock generator
wire sys_clk,sys_clk_,Chip_RST;
CLK_gen generator(CLK,RST,sys_clk,sys_clk_,Chip_RST);


//counter test
reg[15:0] CNT;
assign CNT_out=CNT;
always @(posedge CLK,negedge RST)begin
  if(RST==0)begin
    CNT<=0;
    end
  else begin
    CNT<=CNT+1;
  end
end
endmodule


module Sim;
  reg        Clk=0, Reset;
  wire[15:0] cnt;
  parameter Clk_CYCLE = 10;

 my_Peocessing_System_top test
   (
   Clk,
   Reset,
   cnt[15:0]
   );
  //  always #(Clk_CYCLE/2) Clk = ~Clk;
	always begin
		Clk=~Clk; #(Clk_CYCLE/2);
		end
  initial begin
/*
    $dumpfile("PS_simulations.vcd"); // vcd file name
    $dumpvars(0,test);     // dump targetã¯ã€Œï¿½éƒ¨?½?½
	 $monitor($time, " reset=%b, Clk=%b, count=%d",
	 Reset,Clk,test.CNT);
	 */
    Reset = 1;    
	#(Clk_CYCLE*1.5)
		
    Reset <= 0;
	repeat(30) @(posedge Clk);
    Reset <= 1;
    repeat(30) @(posedge Clk);
    Reset <= 0;
    repeat(30) @(posedge Clk);
    $finish;
  end
endmodule
