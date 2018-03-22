`timescale 100ps / 10ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/03/22 12:37:49
// Design Name: 
// Module Name: uart_sim
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


module uart_sim();
parameter Clk_CYCLE = 10;
reg Clk=0, Reset,cs,as,rw,addr,rx;
reg [31:0] rd_data=0;
wire[31:0] wr_data;
wire rdy,irq_rx,irq_tx,tx;

uart uart(
   Clk,
   Reset,
   cs,
   as,
   rw,
   addr,
   wr_data,
   rd_data,
   rdy,
   irq_rx,
   irq_tx,
   rx,
   tx
);

    always begin
     Clk=~Clk; #(Clk_CYCLE/2);
     end
    always begin
     rd_data<=rd_data+13; #(30*Clk_CYCLE);
    end

  initial begin
    Reset = 1;    
	#(2)		
    Reset <= 0;
	repeat(2) @(posedge Clk);
    Reset <= 1;
    cs=1;as=1;
    rw=1;
    addr=1;
    repeat(100) @(posedge Clk);
    cs=1;as=1;
    rw=1;
    addr=1;
    repeat(100) @(posedge Clk);
    cs=1;as=1;
    rw=0;
    addr=1;
    repeat(100) @(posedge Clk);
    cs=1;as=1;
    rw=1;
    addr=0;
    repeat(100) @(posedge Clk);
    cs=1;as=1;
    rw=0;
    addr=0;
    repeat(100) @(posedge Clk);
    $stop;
  end
endmodule
