`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/03/07 15:42:55
// Design Name: 
// Module Name: GPregistor
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
`define WORD_ADDR_W 5  // address width 1word

`define WORD_MSB `WORD-1
`define WORD_ADDR_MSB `WORD_ADDR_W-1
module GPregistor(
    input clk,
    input rst,
    input [`WORD_ADDR_MSB:0]rd_addr_0,
    input [`WORD_ADDR_MSB:0]rd_addr_1,
    output [`WORD_MSB:0]rd_data_0,
    output [`WORD_MSB:0]rd_data_1,
    input we,
    input [`WORD_MSB:0] wr_addr,
    input [`WORD_MSB:0] wr_data
   );
   reg [`WORD_MSB:0] gpr[31:0];
   integer i;
   //write data to reg
   assign rd_data_0=(we && wr_addr==rd_addr_0)? wr_data:gpr[rd_addr_0];
   assign rd_data_1=(we && wr_addr==rd_addr_1)? wr_data:gpr[rd_addr_1];
   
   
   always@(posedge clk or negedge rst)begin
     if(~rst)begin
      for(i=0;i<32;i=i+1)gpr[i]<=0;
      end
      
     else begin
        if(we)gpr[wr_addr]<=wr_data;//write data to reg
     end
   end
endmodule
