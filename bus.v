`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/02/28 14:39:13
// Design Name:
// Module Name: bus
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

module bus_slave_mux(
input[7:0]s_cs,
input[7:0]s_rdy,
input[`WORD_MSB:0]s0_data,
input[`WORD_MSB:0]s1_data,
input[`WORD_MSB:0]s2_data,
input[`WORD_MSB:0]s3_data,
input[`WORD_MSB:0]s4_data,
input[`WORD_MSB:0]s5_data,
input[`WORD_MSB:0]s6_data,
input[`WORD_MSB:0]s7_data,

output reg [`WORD_MSB:0] m_data,
output reg m_rdy
);
always@(*)begin
  if(s_cs[0]==1)begin
    m_rdy=s_rdy[0];
    m_data=s0_data;
  end
  if(s_cs[1]==1)begin
    m_rdy=s_rdy[1];
    m_data=s1_data;
  end
  if(s_cs[2]==1)begin
    m_rdy=s_rdy[2];
    m_data=s2_data;
  end
  if(s_cs[3]==1)begin
    m_rdy=s_rdy[3];
    m_data=s3_data;
  end
  if(s_cs[4]==1)begin
    m_rdy=s_rdy[4];
    m_data=s4_data;
  end
  if(s_cs[5]==1)begin
    m_rdy=s_rdy[5];
    m_data=s5_data;
  end
  if(s_cs[6]==1)begin
    m_rdy=s_rdy[6];
    m_data=s6_data;
  end
  if(s_cs[7]==1)begin
    m_rdy=s_rdy[7];
    m_data=s7_data;
  end
end

endmodule
module bus_addr_decoder(
    input[`WORD_ADDR_MSB:0]s_addr,
    output reg[7:0] s_cs
    );
    wire[2:0]s_index=s_addr[`WORD_ADDR_MSB:`WORD_ADDR_MSB-2];

    always@(*)begin
          s_cs=0;
          case (s_index)
          0:s_cs[0]=1;//ROM
          1:s_cs[1]=1;//scratch pad memory
          2:s_cs[2]=1;//timer
          3:s_cs[3]=1;//UART?
          4:s_cs[4]=1;//GPIO?
          5:s_cs[5]=1;
          6:s_cs[6]=1;
          7:s_cs[7]=1;
          endcase
    end

endmodule

module bus_master_mux(
    input[3:0]grnt,
    input[3:0]m_as,
    input[3:0]rw,

    input[`WORD_MSB:0]m0_data,
    input[`WORD_ADDR_MSB:0]m0_addr,
    input[`WORD_MSB:0]m1_data,
    input[`WORD_ADDR_MSB:0]m1_addr,
    input[`WORD_MSB:0]m2_data,
    input[`WORD_ADDR_MSB:0]m2_addr,
    input[`WORD_MSB:0]m3_data,
    input[`WORD_ADDR_MSB:0]m3_addr,

    output reg[`WORD_MSB:0]s_wr_data,
    output reg[`WORD_ADDR_MSB:0]s_addr,
    output reg s_rw,
    output reg s_as
    );
    always@(*)begin

    if(grnt[0]==1)begin
      s_wr_data=m0_data;
      s_addr=m0_addr;
      s_rw=rw[0];
      s_as=m_as[0];
    end
    if(grnt[1]==1)begin
      s_wr_data=m1_data;
      s_addr=m1_addr;
      s_rw=rw[1];
      s_as=m_as[1];
    end
    if(grnt[2]==1)begin
      s_wr_data=m2_data;
      s_addr=m2_addr;
      s_rw=rw[2];
      s_as=m_as[2];

    end
    if(grnt[3]==1)begin
      s_wr_data=m3_data;
      s_addr=m3_addr;
      s_rw=rw[3];
      s_as=m_as[3];
    end
    end
endmodule
module bus_arbiter(
    input clk,
    input rst,
    input[3:0]req,
    output reg [3:0]grnt
  );
    reg [1:0] owner;

    //bus arbitor
    always@(posedge clk or negedge rst)begin
      if(~rst)owner<=0;
      else begin
        case (owner)
        0:
          begin
            if(req==1)owner<=0;
            else if(req==2)owner<=1;
            else if(req==4)owner<=2;
            else if(req==8)owner<=3;
          end
        1:
            begin
              if(req==2)owner<=1;
              else if(req==4)owner<=2;
              else if(req==8)owner<=3;
              else if(req==1)owner<=0;
            end
        2:
              begin
                if(req==4)owner<=2;
                else if(req==8)owner<=3;
                else if(req==1)owner<=0;
                else if(req==2)owner<=1;
              end
        3:
                begin
                  if(req==8)owner<=3;
                  else if(req==1)owner<=0;
                  else if(req==2)owner<=1;
                  else if(req==4)owner<=2;
                end
        endcase
      end
    end
  //bus syoyuuken
  always@(*)begin
        grnt=0;
        case (owner)
        0:grnt[0]=1;
        1:grnt[1]=1;
        2:grnt[2]=1;
        3:grnt[3]=1;
        endcase
  end
endmodule
module bus(
    input clk,
    input rst,
    input [`WORD_MSB:0]m0_rw_data,
    input [`WORD_ADDR_MSB:0]m0_addr,
    input [`WORD_MSB:0]m1_rw_data,
    input [`WORD_ADDR_MSB:0]m1_addr,
    input [`WORD_MSB:0]m2_rw_data,
    input [`WORD_ADDR_MSB:0]m2_addr,
    input [`WORD_MSB:0]m3_rw_data,
    input [`WORD_ADDR_MSB:0]m3_addr,

    input m0_req_,
    input m1_req_,
    input m2_req_,
    input m3_req_,
    input m0_as_,
    input m1_as_,
    input m2_as_,
    input m3_as_,
    input m0_rw_,
    input m1_rw_,
    input m2_rw_,
    input m3_rw_,
    output m0_grnt_,
    output m1_grnt_,
    output m2_grnt_,
    output m3_grnt_,

    input s0_rdy_,
    input s1_rdy_,
    input s2_rdy_,
    input s3_rdy_,
    input s4_rdy_,
    input s5_rdy_,
    input s6_rdy_,
    input s7_rdy_,

    input[`WORD_MSB:0]s0_rd_data,
    input[`WORD_MSB:0]s1_rd_data,
    input[`WORD_MSB:0]s2_rd_data,
    input[`WORD_MSB:0]s3_rd_data,
    input[`WORD_MSB:0]s4_rd_data,
    input[`WORD_MSB:0]s5_rd_data,
    input[`WORD_MSB:0]s6_rd_data,
    input[`WORD_MSB:0]s7_rd_data,

    output [`WORD_MSB:0]m_rd_data,
    output m_rdy,

    output s0_cs_,
    output s1_cs_,
    output s2_cs_,
    output s3_cs_,
    output s4_cs_,
    output s5_cs_,
    output s6_cs_,
    output s7_cs_,
    output[`WORD_ADDR_MSB:0] s_addr,	   // ?�A?�h?�?�?�X
    output s_as_,	   // ?�A?�h?�?�?�X?�X?�g?�?�?�[?�u
    output s_rw,	   // ?�ǂ݁^?�?�?�?�
    output [`WORD_MSB:0]s_wr_data
    );

    wire[3:0] req={m3_req_,m2_req_,m1_req_,m0_req_};
    wire[3:0]m_as={m3_as_,m2_as_,m1_as_,m0_as_};
    wire[3:0]m_rw={m3_rw,m2_rw,m1_rw,m0_rw};

    wire[3:0]grnt;
    wire[7:0]s_chip;
    assign m0_grnt_=grant[0];
    assign m1_grnt_=grant[1];
    assign m2_grnt_=grant[2];
    assign m3_grnt_=grant[3];
    assign s0_cs_=s_chip[0];
    assign s1_cs_=s_chip[1];
    assign s2_cs_=s_chip[2];
    assign s3_cs_=s_chip[3];
    assign s4_cs_=s_chip[4];
    assign s5_cs_=s_chip[5];
    assign s6_cs_=s_chip[6];
    assign s7_cs_=s_chip[7];



    /********** ?�o?�X?�A?�[?�r?�^ **********/
    bus_arbiter bus_arbiter (
  		.clk		(clk),
  		.rst		(rst),
  		.req(req),
  		.grnt(grnt)
  	);


    /********** ?�o?�X?�}?�X?�^?�}?�?�?�`?�v?�?�?�N?�T **********/
    bus_master_mux bus_master_mux (
      /********** ?�o?�X?�}?�X?�^?�M?�?� **********/
      .grnt(grnt),
      .m_as(m_as),
      .m0_addr	(m0_addr),	  // ?�A?�h?�?�?�X
      .m0_data (m0_rw_data), // ?�?�?�?�?�?�?�݃f?�[?�^
      .m1_addr	(m1_addr),	  // ?�A?�h?�?�?�X
      .m1_data (m1_rw_data), // ?�?�?�?�?�?�?�݃f?�[?�^
      .m2_addr	(m2_addr),	  // ?�A?�h?�?�?�X
      .m2_data (m2_rw_data), // ?�?�?�?�?�?�?�݃f?�[?�^
      .m3_addr	(m3_addr),	  // ?�A?�h?�?�?�X
      .m3_data (m3_rw_data), // ?�?�?�?�?�?�?�݃f?�[?�^

      .s_addr		(s_addr),	  // ?�A?�h?�?�?�X
      .s_as		(s_as_),	  // ?�A?�h?�?�?�X?�X?�g?�?�?�[?�u
      .s_rw		(s_rw),		  // ?�ǂ݁^?�?�?�?�
      .s_wr_data	(s_wr_data)	  // ?�?�?�?�?�?�?�݃f?�[?�^
    );

    /********** ?�A?�h?�?�?�X?�f?�R?�[?�_ **********/
    bus_addr_decoder bus_addr_decoder (
      /********** ?�A?�h?�?�?�X **********/
      .s_addr		(s_addr),	  // ?�A?�h?�?�?�X
      .s_cs   (s_chip)
    );

    /********** ?�o?�X?�X?�?�?�[?�u?�}?�?�?�`?�v?�?�?�N?�T **********/
    bus_slave_mux bus_slave_mux (
      .s_cs	(s_chip),	  // ?�o?�X?�X?�?�?�[?�u0?�?�
      .s_rdy	(s_rdy),	  // ?�?�?�f?�B

      /********** ?�o?�X?�X?�?�?�[?�u?�M?�?� **********/
      // ?�o?�X?�X?�?�?�[?�u0?�?�
      .s0_data (s0_rd_data), // ?�ǂݏo?�?�?�f?�[?�^
      .s1_data (s1_rd_data), // ?�ǂݏo?�?�?�f?�[?�^
      .s2_data (s2_rd_data), // ?�ǂݏo?�?�?�f?�[?�^
      .s3_data (s3_rd_data), // ?�ǂݏo?�?�?�f?�[?�^
      .s4_data (s4_rd_data), // ?�ǂݏo?�?�?�f?�[?�^
      .s5_data (s5_rd_data), // ?�ǂݏo?�?�?�f?�[?�^
      .s6_data (s6_rd_data), // ?�ǂݏo?�?�?�f?�[?�^
      .s7_data (s7_rd_data), // ?�ǂݏo?�?�?�f?�[?�^
      /********** ?�o?�X?�}?�X?�^?�?�?�ʐM?�?� **********/
      .m_data	(m_rd_data),  // ?�ǂݏo?�?�?�f?�[?�^
      .m_rdy		(m_rdy)	  // ?�?�?�f?�B
    );

endmodule
