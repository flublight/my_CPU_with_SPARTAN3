`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/02/27 10:16:01
// Design Name:
// Module Name: sim_top
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module Sim;
  reg        Clk=0, Reset;
  reg [3:0] btn;
  reg[1:0] led;
  reg[7:0] Lseg1,Lseg2;
  parameter Clk_CYCLE = 10;
 my_Peocessing_System_top test
   (
   Clk,
   Reset,
   btn[3:0],
   led[1:0],
   Lseg1[7:0],
   Lseg2[7:0]
   );
  //  always #(Clk_CYCLE/2) Clk = ~Clk;
	always begin
		Clk=~Clk; #(Clk_CYCLE/2);
		end
  initial begin
    Reset = 1;
    btn=0;
	#(Clk_CYCLE*1.5)

    Reset <= 0;
	repeat(2) @(posedge Clk);
    Reset <= 1;
    repeat(500) @(posedge Clk);
    $finish;
  end
endmodule
