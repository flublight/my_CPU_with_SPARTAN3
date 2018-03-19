`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/02/27 12:24:13
// Design Name:
// Module Name: ALU
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

//ALU Operation
`define ALU_OP_NOP			 4'h0 // No Operation
`define ALU_OP_AND			 4'h1 // AND
`define ALU_OP_OR			 4'h2 // OR
`define ALU_OP_XOR			 4'h3 // XOR
`define ALU_OP_ADDS			 4'h4 // ç¬¦å·ä»˜ã??½??½???½?
`define ALU_OP_ADDU			 4'h5 // ç¬¦å·ãªã—åŠ ??½??½?
`define ALU_OP_SUBS			 4'h6 // ç¬¦å·ä»˜ãæ¸›ï¿½??½?
`define ALU_OP_SUBU			 4'h7 // ç¬¦å·ãªã—æ¸›ï¿½??½?
`define ALU_OP_SHRL			 4'h8 // è«–ç†å³ã‚·ãƒ•ãƒˆ
`define ALU_OP_SHLL			 4'h9 // è«–ç†å·¦ã‚·ãƒ•ãƒˆ


`define WORD 32  // 1word
`define WORD_ADDR_W 30  // address width 1word

`define GPR_ADDR_MSB 5-1

`define WORD_MSB `WORD-1
`define WORD_ADDR_MSB `WORD_ADDR_W-1
`define RegAddrBus `GPR_ADDR_MSB:0

//for 7seg
module dev(
input [7:0]z, //will_deved_num
input [3:0]d, //dev_num
input start,
input clk,
input rst,
output [3:0]p,
output [3:0]q
);

reg[4:0] i;
reg[15:0] zr;
reg[3:0] dr;

wire en_seq=(i>0);//sequencer
always@(posedge clk or negedge rst) begin
    if(~rst) i<=0;
    else if(start)i<=5'h10;
    else if(en_seq)i <=i-1;
end

//calculate

wire[4:0] pr=zr[15:11];
wire[4:0] sb=pr-{1'b0,dr};
wire      pq=~sb[4];
wire[3:0] mx=(sb[4])?pr[3:0]:sb[3:0];
wire[15:0] zw={mx,zr[10:0],pq};
wire[15:0]tmp={8'b00000000,z};
assign p=zr[7:0];
assign q=zr[11:8];
always@(posedge clk) begin
    if(start)begin
      dr<=d;
      zr<=tmp;
    end
    else if(en_seq)zr <=zw;

end

endmodule


module ALU(
  input [`WORD_MSB:0]in_0,
  input [`WORD_MSB:0]in_1,
  input [3:0]op,

  output reg [`WORD_MSB:0]out,
  output reg of
);
  wire signed [`WORD_MSB:0]s_in_0=$signed(in_0);
  wire signed [`WORD_MSB:0]s_in_1=$signed(in_1);
  wire signed [`WORD_MSB:0]s_out=$signed(out);

  always @(*) begin
		case (op)
			`ALU_OP_AND	 : begin // ??½_??½??½??½ÏiAND??½j
				out	  = in_0 & in_1;
			end
			`ALU_OP_OR	 : begin // ??½_??½??½??½a??½iOR??½j
				out	  = in_0 | in_1;
			end
			`ALU_OP_XOR	 : begin // ??½r??½??½??½I??½_??½??½??½a??½iXOR??½j
				out	  = in_0 ^ in_1;
			end
			`ALU_OP_ADDS : begin // ??½??½??½??½??½t??½??½??½??½??½Z
				out	  = in_0 + in_1;
			end
			`ALU_OP_ADDU : begin // ??½??½??½??½??½È‚ï¿½??½??½??½Z
				out	  = in_0 + in_1;
			end
			`ALU_OP_SUBS : begin // ??½??½??½??½??½t??½??½??½??½??½Z
				out	  = in_0 - in_1;
			end
			`ALU_OP_SUBU : begin // ??½??½??½??½??½È‚ï¿½??½??½??½Z
				out	  = in_0 - in_1;
			end
			`ALU_OP_SHRL : begin // ??½_??½??½??½E??½V??½t??½g
				out	  = in_0 >> in_1[4:0];
			end
			`ALU_OP_SHLL : begin // ??½_??½??½??½??½??½V??½t??½g
				out	  = in_0 << in_1[4:0];
			end
			default		 : begin // ??½f??½t??½H??½??½??½g??½l (No Operation)
				out	  = in_0;
			end
		endcase
	end

	/********** ??½I??½[??½o??½t??½??½??½[??½`??½F??½b??½N **********/
	always @(*) begin
		case (op)
			`ALU_OP_ADDS : begin // ??½??½??½Z??½I??½[??½o??½t??½??½??½[??½Ìƒ`??½F??½b??½N
				if (((s_in_0 > 0) && (s_in_1 > 0) && (s_out < 0)) ||
					((s_in_0 < 0) && (s_in_1 < 0) && (s_out > 0))) begin
					of = 1;
				end else begin
					of = 0;
				end
			end
			`ALU_OP_SUBS : begin // ??½??½??½Z??½I??½[??½o??½t??½??½??½[??½Ìƒ`??½F??½b??½N
				if (((s_in_0 < 0) && (s_in_1 > 0) && (s_out > 0)) ||
					((s_in_0 > 0) && (s_in_1 < 0) && (s_out < 0))) begin
					of = 1;
				end else begin
					of = 0;
				end
			end
			default		: begin // ??½f??½t??½H??½??½??½g??½l
				of = 0;
			end
		endcase
	end
endmodule
