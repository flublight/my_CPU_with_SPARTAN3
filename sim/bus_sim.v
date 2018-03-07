`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/02/28 17:44:20
// Design Name: 
// Module Name: bus_sim
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

module bus_sim;
parameter Clk_CYCLE = 10;

reg Clk=0, Reset;
reg [3:0]mreq=0;
reg [`WORD_MSB:0]m0_rw_data;
reg [`WORD_ADDR_MSB:0]m0_addr;
reg [`WORD_MSB:0]m1_rw_data;
reg [`WORD_ADDR_MSB:0]m1_addr;
reg [`WORD_MSB:0]m2_rw_data;
reg [`WORD_ADDR_MSB:0]m2_addr;
reg [`WORD_MSB:0]m3_rw_data;
reg [`WORD_ADDR_MSB:0]m3_addr;    
reg[3:0]addrstr;
reg[3:0]rw;
reg[7:0]rdy;
reg[3:0]m_as;
reg[`WORD_MSB:0]s0_rd_data;
reg[`WORD_MSB:0]s1_rd_data;
reg[`WORD_MSB:0]s2_rd_data;
reg[`WORD_MSB:0]s3_rd_data;
reg[`WORD_MSB:0]s4_rd_data;
reg[`WORD_MSB:0]s5_rd_data;
reg[`WORD_MSB:0]s6_rd_data;
reg[`WORD_MSB:0]s7_rd_data;
wire[7:0]s_chip;
wire[`WORD_MSB:0]m_rd_data;
wire [`WORD_ADDR_MSB:0] s_addr;
wire s_as;
wire s_rw;
wire m_rdy;
wire[3:0]grnt;
wire[`WORD_MSB:0]s_wr_data;
bus test
   (
   Clk,
   Reset,
   mreq, 
   m_as,
   m0_rw_data,
   m0_addr,
   m1_rw_data,
   m1_addr,
   m2_rw_data,
   m2_addr,
   m3_rw_data,
   m3_addr,
   addrstr,
   rw,
 
   rdy,
   s0_rd_data,
   s1_rd_data,
   s2_rd_data,
   s3_rd_data,
   s4_rd_data,
   s5_rd_data,
   s6_rd_data,
   s7_rd_data,
   
   m_rd_data,
   m_rdy,   

   grnt,
   s_chip,
   s_addr,
   s_as,
   s_rw,
   s_wr_data
    );
    always begin
     Clk=~Clk; #(Clk_CYCLE/2);
     end
    always begin
        mreq =mreq + 1;#(Clk_CYCLE);
    end
  initial begin
    Reset = 1;    
	#(2)		
    Reset <= 0;
	repeat(2) @(posedge Clk);
    Reset <= 1;
    m0_rw_data=32'h00000000;
    m1_rw_data=32'h00000001;
    m2_rw_data=32'h00000002;
    m3_rw_data=32'h00000003;
    m0_addr=32'hFFFF0000;
    m1_addr=32'hFFFF0001;
    m2_addr=32'hFFFF0002;
    m3_addr=32'hFFFF0003;
    s0_rd_data=32'hFFFFFFFF;
    s1_rd_data=32'hFFFFFFFE;
    s2_rd_data=32'hFFFFFFFD;
    s3_rd_data=32'hFFFFFFFC;
    s4_rd_data=32'hFFFFFFFB;
    s5_rd_data=32'hFFFFFFFA;
    s6_rd_data=32'hFFFFFFF9;
    s7_rd_data=32'hFFFFFFF8;
    repeat(1000) @(posedge Clk);
    $finish;
  end
endmodule
