`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/03/07 16:13:43
// Design Name: 
// Module Name: spm
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
`define WORD_ADDR_W 12  // address width 1word

`define WORD_MSB `WORD-1
`define WORD_ADDR_MSB `WORD_ADDR_W-1
module spm(
    input clk,
    input if_as,
    input if_rw,
    input[`WORD_ADDR_MSB:0]if_addr,    
    input [`WORD_MSB:0]if_wr_data,
    output [`WORD_MSB:0]if_rd_data,
    input mem_as,
    input mem_rw,
    input[`WORD_ADDR_MSB:0] mem_addr,
    input[`WORD_MSB:0] mem_wr_data,
    output [`WORD_MSB:0]mem_rd_data
    );
    reg wea,web;
    
    always@(*)begin
        if(if_as && if_rw==1)wea=1;
        else wea=0;
        
        if(mem_as && mem_rw==1)web=1;
        else web=0;
                        
    end
    x_s3e_dpram x_s3e_dpram (
    		.clka  (clk),			  // ?N???b?N
    		.addra (if_spm_addr),	  // ?A?h???X
    		.dina  (if_spm_wr_data),  // ????????f?[?^?i??????j
    		.wea   (wea),			  // ????????L???i?l?Q?[?g?j
    		.douta (if_spm_rd_data),  // ???o???f?[?^
    		/********** ?|?[?g B : MEM?X?e?[?W **********/
    		.clkb  (clk),			  // ?N???b?N
    		.addrb (mem_spm_addr),	  // ?A?h???X
    		.dinb  (mem_spm_wr_data), // ????????f?[?^
    		.web   (web),			  // ????????L??
    		.doutb (mem_spm_rd_data)  // ???o???f?[?^
    	);

endmodule
