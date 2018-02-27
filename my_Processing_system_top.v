//top file
`timescale 1ns/1ps
module my_Peocessing_System_top(
  input INCLK,
  input RESET,
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


//counter test
reg[6:0] cnt_sec;
reg[20:0] cnt_clk;
always @(posedge INCLK,negedge RST)begin
  if(~RST)begin
    cnt_clk<=0;
    cnt_sec<=0;
    end
  else if(cnt_sec==99)cnt_sec<=0;  
  else if(cnt_clk==10000000/5) begin
  cnt_sec<=cnt_sec+1;
  cnt_clk<=1;
  end
  
  else begin
    cnt_clk<=cnt_clk+1;
  end
end

//7seg_decode
   function [7:0] decoder1(input [6:0] in);
     begin
      case(in[3:0])
           0:decoder1=7'b11000000;
           1:decoder1=7'b11111001;
           2:decoder1=7'b10100100;
           3:decoder1=7'b10110000;
           4:decoder1=7'b10011001;
           5:decoder1=7'b10010010;
           6:decoder1=7'b10000010;
           7:decoder1=7'b11111000;
           8:decoder1=7'b10000000;
           9:decoder1=7'b10010000;
      endcase
      end
   endfunction
   function [7:0] decoder2(input [6:0] in);
    begin
    //tmp;
    case(in)
      0:decoder2=7'b11000000;
      1:decoder2=7'b11111001;
      2:decoder2=7'b10100100;
      3:decoder2=7'b10110000;
      4:decoder2=7'b10011001;
      5:decoder2=7'b10010010;
      6:decoder2=7'b10000010;
      7:decoder2=7'b11111000;
      8:decoder2=7'b10000000;
      9:decoder2=7'b10010000;
            endcase
    end        
    endfunction
assign LED[1:0]=BTN[3:2];
assign LED7SEG1=decoder1(cnt_sec);
assign LED7SEG2=decoder2(cnt_sec);
endmodule

