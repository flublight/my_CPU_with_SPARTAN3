`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/03/12 18:30:37
// Design Name:
// Module Name: cpu_sim
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

`define GPR_ADDR_MSB 5-1

`define WORD_MSB `WORD-1
`define WORD_ADDR_MSB `WORD_ADDR_W-1

`define RegAddrBus `GPR_ADDR_MSB:0
`define WordAddrBus `WORD_ADDR_MSB:0
`define WordDataBus `WORD_MSB:0

module cpu_sim();

	/********** ?�N?�?�?�b?�N & ?�?�?�Z?�b?�g **********/
	reg					  clk;			   // ?�N?�?�?�b?�N
	wire				  clk_;			   // ?�?�?�]?�N?�?�?�b?�N
	reg					  reset;		   // ?�񓯊�?�?�?�Z?�b?�g
	/********** ?�o?�X?�C?�?�?�^?�t?�F?�[?�X **********/
	// IF Stage
	reg [`WordDataBus]	  if_bus_rd_data;  // ?�ǂݏo?�?�?�f?�[?�^
	reg					  if_bus_rdy_;	   // ?�?�?�f?�B
	reg					  if_bus_grnt_;	   // ?�o?�X?�O?�?�?�?�?�g
	wire					  if_bus_req_;	   // ?�o?�X?�?�?�N?�G?�X?�g
	wire [`WordAddrBus]	  if_bus_addr;	   // ?�A?�h?�?�?�X
	wire					  if_bus_as_;	   // ?�A?�h?�?�?�X?�X?�g?�?�?�[?�u
	wire					  if_bus_rw;	   // ?�ǂ݁^?�?�?�?�
	wire [`WordDataBus]	  if_bus_wr_data;  // ?�?�?�?�?�?�?�݃f?�[?�^
	// MEM Stage
	reg [`WordDataBus]	  mem_bus_rd_data; // ?�ǂݏo?�?�?�f?�[?�^
	reg					  mem_bus_rdy_;	   // ?�?�?�f?�B
	reg					  mem_bus_grnt_;   // ?�o?�X?�O?�?�?�?�?�g
	wire					  mem_bus_req_;	   // ?�o?�X?�?�?�N?�G?�X?�g
	wire [`WordAddrBus]	  mem_bus_addr;	   // ?�A?�h?�?�?�X
	wire					  mem_bus_as_;	   // ?�A?�h?�?�?�X?�X?�g?�?�?�[?�u
	wire					  mem_bus_rw;	   // ?�ǂ݁^?�?�?�?�
	wire [`WordDataBus]	  mem_bus_wr_data; // ?�?�?�?�?�?�?�݃f?�[?�^
	/********** ?�?�?�荞�?� **********/
	reg [7:0] cpu_irq;		   // ?�?�?�荞�ݗv?�?�

  assign clk_=~clk;

  CPU_top test(
    clk,clk_,reset,
    if_bus_rd_data,
    if_bus_rdy_,
    if_bus_grnt_,
    if_bus_req_,
    if_bus_addr,
    if_bus_as_,
    if_bus_rw,
    if_bus_wr_data,

    mem_bus_rd_data,
    mem_bus_rdy_,
    mem_bus_grnt_,
    mem_bus_req_,
    mem_bus_addr,
    mem_bus_as_,
    mem_bus_rw,
    mem_bus_wr_data
    );

  always begin
     clk=~clk; #(5);
  end

  initial begin
    reset = 1;
	#(2)
    reset <= 0;
	repeat(2) @(posedge clk);
    reset <= 1;
    repeat(1000) @(posedge clk);
    $finish;
  end

endmodule