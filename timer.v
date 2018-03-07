`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/02/28 14:29:25
// Design Name:
// Module Name: timer
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


`define WORD 32  // 1word
`define WORD_ADDR_W 30  // address width 1word

`define WORD_MSB `WORD-1
`define WORD_ADDR_MSB `WORD_ADDR_W-1

module timer(
    input clk,
    input rst,

    //access from bus
    input cs,
    input as,
    input rw,
    input [1:0]addr,//0:mode,start 1:irq,2:expr,3:counter

    input [`WORD_MSB:0]wr_data,
    output reg[`WORD_MSB:0]rd_data,
    output reg rdy,
    output reg irq
    );
reg mode,start;
reg[`WORD_MSB:0]expr_val,counter;
wire expr_flg;

always@(posedge clk or negedge rst)begin
  if(~rst)begin
    rd_data<=0;
    rdy<=0;
    irq<=0;
    expr_val<=0;
    counter<=0;
    mode<=0;
    start<=0;
  end
  else begin

    if(cs&&as && ~rw)begin//read access
    case(addr)
      0:rd_data<=mode*2+start;//{{`WORD-2}{1'b0},mode,start};
      1:rd_data<=irq;//{{`WORD-1}{1'b0},irq};
      2:rd_data<=expr_val;
      3:rd_data<=counter;
    endcase
    end
    else rd_data<=0;

    //write access
    if(cs&&as && rw && addr==0)begin
        start<=wr_data[0];
        mode<=wr_data[1];
    end
    else if(~expr_flg)start<=0;

    if(expr_flg)irq<=0;
    else if(cs&&as&&rw&&addr==1)irq<=wr_data[0];

    if(cs&&as&&rw&&addr==2)expr_val<=wr_data;

    if(cs&&as&&rw&&addr==3)counter<=wr_data;
    else if(expr_flg)counter<=0;
    else if(start)counter<=counter+1;

    if(cs&&as)rdy<=1;
    else rdy<=0;

  end
end
endmodule
