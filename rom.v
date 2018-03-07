`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/03/07 13:47:47
// Design Name: 
// Module Name: rom
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


module rom(
    input clk,
    input rst,
    input cs,
    input as,
    input [11:0] addr,
    output[`WORD_MSB:0] data,
    output reg rdy
    );
    x_s3e_sprom x_s3e_sprom (
    		.clka  (clk),					// ?N???b?N
    		.addra (addr),					// ?A?h???X
    		.douta (data)				// ???o???f?[?^
    	);        
    always@(posedge clk or negedge rst)begin
      if(~rst)begin
        rdy<=0;
      end
      else if(cs&&as)begin
        rdy<=1;
      end
      else rdy<=0;
    end
endmodule
