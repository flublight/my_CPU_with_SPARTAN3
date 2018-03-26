//top file
`timescale 1ns/1ps

module Counter(
    input clk,
    input rst,
    output [6:0]sec_out,
    output [20:0]clk_out);

    reg[6:0] cnt_sec;
    reg[20:0] cnt_clk;
    assign sec_out=cnt_sec;
    assign clk_out=cnt_clk;

    //count up timing
    always @(posedge clk,negedge rst)begin

      if(~rst)begin
        cnt_clk<=0;
        cnt_sec<=0;
        end
      else if(cnt_sec==100)cnt_sec<=0;
      else if(cnt_clk==50) begin
      cnt_sec<=cnt_sec+1;
      cnt_clk<=1;
      end

      else begin
        cnt_clk<=cnt_clk+1;
      end
    end

endmodule


module my_Peocessing_System_top(
  input INCLK,
  input RESET,
  input UART_RX,
  output UART_TX,
  input[3:0] BTN,
  output[1:0] LED,
  output[7:0] LED7SEG1,
  output[7:0] LED7SEG2
);

//reset
wire RST=RESET|BTN[0];

//clock generator
wire sys_clk,sys_clk_,Chip_RST;
CLK_gen generator(INCLK,RST,sys_clk,sys_clk_,Chip_RST);

//processor
processor processor(
  sys_clk,
  sys_clk_,
  Chip_RST,
  UART_RX,
  UART_TX
  )

//counter test
wire[6:0] cnt_sec;
wire[20:0] cnt_clk;
Counter counter(INCLK,RST,cnt_sec,cnt_clk);

reg[6:0]past_sec;
reg start;
wire[3:0]q_7seg,r_7seg;

always@(posedge INCLK or negedge RST)begin
  if(~RST)begin
    past_sec<=0;
    start<=0;
  end
  else if(past_sec!=cnt_sec)start<=1;
  else begin
    start<=0;
    past_sec<=cnt_sec;
  end
end
wire rfd;
//dev devFor7seg(8'b10110110,4'b1010,start,INCLK,RST,q_seg,r_seg);
div_gen_v3_0_0 devFor7seg(rfd,INCLK,cnt_sec,q_seg,4'b1010,r_seg);


//7seg_decode
   function [7:0] decoder(input [3:0] in);
     begin
      case(in[3:0])
           0:decoder=8'b11000000;
           1:decoder=8'b11111001;
           2:decoder=8'b10100100;
           3:decoder=8'b10110000;
           4:decoder=8'b10011001;
           5:decoder=8'b10010010;
           6:decoder=8'b10000010;
           7:decoder=8'b11111000;
           8:decoder=8'b10000000;
           9:decoder=8'b10010000;
      endcase
      end
   endfunction
assign LED[1:0]=BTN[3:2];
assign LED7SEG1=decoder(q_7seg);
assign LED7SEG2=decoder(r_7seg);
endmodule
