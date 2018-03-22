`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/03/19 16:10:43
// Design Name:
// Module Name: IF_sim
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


module WR_sim();
	reg				   clk=0;			// ????N????????????b????N
	reg				   reset;		// ???????????????????????????Z????b????g
  reg[4:0] creg_rd_addr;
  wire [`WORD_MSB:0]creg_rd_data;
  wire exe_mode;
  reg [7:0]irq;
  wire int_detect;

  reg [`WORD_ADDR_MSB:0]id_pc;

  reg [`WORD_ADDR_MSB:0]mem_pc;
  reg mem_en;
  reg mem_br_flag;
  reg [1:0]mem_ctrl_op;
  reg [4:0]mem_dst_addr;
  reg mem_gpr_we_;
  reg [2:0]mem_exp_code;



  wire [`WORD_MSB:0]mem_out;

  reg if_busy;
  reg ld_hazard;
  reg mem_busy;
  wire if_stall;
  wire id_stall;
  wire ex_stall;
  wire mem_stall;
  wire if_flush;
  wire id_flush;
  wire ex_flush;
  wire mem_flush;
  wire[`WORD_ADDR_MSB:0]new_pc;

  ctrl_cpu test(
    clk,
    reset,
    creg_rd_addr,
    creg_rd_data,
    exe_mode,
    irq,
    int_detect,

    id_pc,

    mem_pc,
    mem_en,
    mem_br_flag,
    mem_ctrl_op,
    mem_dst_addr,
    mem_gpr_we_,
    mem_exp_code,
    mem_out,

    if_busy,
    ld_hazard,
    mem_busy,

    if_stall,
    id_stall,
    ex_stall,
    mem_stall,
    if_flush,
    id_flush,
    ex_flush,
    mem_flush,
    new_pc

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
		mem_en<=0;
		mem_br_flag=0;
		mem_gpr_we_=0;
		mem_exp_code=0;
		if_busy=0;
		ld_hazard=0;
		mem_busy=0;

		mem_ctrl_op=1;
		mem_dst_addr=4;
		id_pc=4;
		mem_pc=8;
		irq=0;
		creg_rd_addr=0;
		repeat(200) @(posedge clk);

    repeat(200) @(posedge clk);

    $finish;
  end

endmodule
