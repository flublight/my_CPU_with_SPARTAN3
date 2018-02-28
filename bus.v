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

`define WORD = 32  // 1word
`define WORD_ADDR_W = 30  // address width 1word

`define WORD_MSB =WORD-1
`define WORD_ADDR_MSB =WORD_ADDR_W-1;

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

output[`WORD_MSB:0] m_data,
output m_rdy
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
module bus_addr_decodor(
    input[`WORD_ADDR_MSB:0]s_addr,
    output[7:0] s_sc
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

endmodule;

module bus_master_mux(
    input[3:0]grnt,
    input[3:0]as,
    input[3:0]rw,

    input[`WORD_MSB:0]m0_data,
    input[`WORD_ADDR_MSB:0]m0_addr,
    input[`WORD_MSB:0]m1_data,
    input[`WORD_ADDR_MSB:0]m1_addr,
    input[`WORD_MSB:0]m2_data,
    input[`WORD_ADDR_MSB:0]m2_addr,
    input[`WORD_MSB:0]m3_data,
    input[`WORD_ADDR_MSB:0]m3_addr,

    output[`WORD_MSB:0]s_data,
    output[`WORD_ADDR_MSB:0]s_addr,
    output s_rw,
    output s_as
    );
    always@(*)begin

    if(grnt[0]==1)begin
      s_data=m0_data;
      s_addr=m0_addr;
      s_rw=m0_rw;
      s_as=m0_as;
    end
    if(grnt[1]==1)begin
      s_data=m1_data;
      s_addr=m1_addr;
      s_rw=m1_rw;
      s_as=m1_as;
    end
    if(grnt[2]==1)begin
      s_data=m2_data;
      s_addr=m2_addr;
      s_rw=m2_rw;
      s_as=m2_as;
    end
    if(grnt[3]==1)begin
      s_data=m3_data;
      s_addr=m3_addr;
      s_rw=m3_rw;
      s_as=m3_as;
    end
    end
endmodule

module bus(
    input clk,
    input rst
    );
    reg[3:0] grnt,req,chip,addrstr,rw,rdy;
    reg[1:0] owner;
    reg [`WORD_MSB:0]w_data,r_data;
    reg[`WORD_ADDR_MSB:0] addr;

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
endmodule
