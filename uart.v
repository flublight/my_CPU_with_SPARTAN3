`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/03/20 15:41:49
// Design Name:
// Module Name: uart
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


module uart_tx(
  input clk,
  input rst,
  input tx_start,
  input[7:0] tx_data,
  output reg tx_end,
  output wire tx_busy,
  output reg tx
  );

  reg state;
  reg [8:0]div_cnt;
  reg [3:0]bit_cnt;
  reg [7:0]shit_reg;

  assign tx_busy = state;

  always @ (posedge clk or negedge rst) begin
    if(~rst)begin
      state<=0;
      div_cnt<=0;
      bit_cnt<=0;
      shit_reg<=0;
      tx_end<=0;
      tx<=0;
    end
    else begin
      case (state)
      0:begin//idle
        if(tx_start)begin
          state<=1;
          shit_reg<=tx_data;
          tx<=1;//start bit
        end
        tx_end<=0;
      end
      1:begin//send data
        if(div_cnt==0)begin
          case(bit_cnt)
            8:begin//bps ctrl
              bit_cnt<=9;//send stop bit
              tx<=0;
            end
            9:begin //send complete
                state<=0;
                bit_cnt<=0;
                tx_end<=0;
            end
            default :begin
                bit_cnt<=bit_cnt+1;
                shit_reg<=shit_reg<<1'b1;
                tx<=shit_reg[0];
            end
          endcase
          div_cnt<=260;//bunsyuu tate
          end
          else div_cnt<=div_cnt-1;//cnt down
      end
      endcase
    end
  end
endmodule

module uart_rx(
  input clk,
  input rst,
  output reg[7:0] rx_data,
  output wire rx_busy,
  output reg rx_end,
  input  rx
  );

  //rx==1:startbit
  //rx==0:stoptbit

  reg state;
  reg [8:0]div_cnt;
  reg [3:0]bit_cnt;

  assign rx_busy=~state;

  always @ (posedge clk or negedge rst) begin
    if(~rst)begin
      state<=0;
      div_cnt<=0;
      bit_cnt<=0;
      rx_end<=0;
      rx_data<=0;
    end
    else begin
      case (state)
      0:begin//idle
        if(~rx)begin //recieve start bit
          state<=1;
        end
        rx_end<=0;
      end
      1:begin//recieve data
        if(div_cnt==0)begin
          case(bit_cnt)
            9:begin//recieve stop_bit
              state<=0;
              bit_cnt<=0;//send stop bit
              div_cnt<=130;
              if(rx)rx_end<=1; //
            end
            default :begin
                bit_cnt<=bit_cnt+1;
                div_cnt<=260;
                rx_data<={rx,rx_data[7:1]};
            end
          endcase
        end
        else div_cnt<=div_cnt-1;//cnt down
      end
      endcase
    end
  end
endmodule

module uart_ctrl (
  input clk,
  input rst,

  input cs,
  input as,
  input rw,
  input addr,
  input [31:0] wr_data,
  output reg[31:0] rd_data,
  output reg rdy,

  output reg irq_rx,
  output reg irq_tx,

  input rx_busy,
  input rx_end,
  input[7:0] rx_data,
  input tx_busy,
  input tx_end,
  output reg tx_start,
  output reg[7:0] tx_data
);

  reg [7:0]rx_buf;

  always @ (posedge clk or negedge rst) begin
    if(~rst)begin
      irq_rx<=0;
      irq_tx<=0;
      rdy<=0;
      rd_data<=0;
      tx_start<=0;
    end
    else begin
      if(cs && as) rdy<=1;
      else rdy<=0;

      //read access
      if(cs && as && rw==0)begin
        if(~addr)rd_data<={28'b0,tx_busy,rx_busy,irq_tx,irq_rx}; //status
        else rd_data<={24'b0,rx_buf};
      end
      else rd_data<=0;

      //write access
      if(tx_end) //interrupt send complete signal
        irq_tx<=1;
      else if(cs && as && rw && ~addr)irq_tx<=wr_data[1];

      if(rx_end)//interrupt send complete signal
        irq_rx<=0;
      else if(cs && as && rw && ~addr)irq_tx<=wr_data[0];

      if(cs && as && rw && addr)begin //wite to reg1
        tx_start<=1;
        tx_data<=wr_data[7:0];
      end
      else begin
        tx_start<=0;
        tx_data<=0;
      end

      if(rx_end)rx_buf<=rx_data;
    end
  end
endmodule // uart_ctrl


module uart (
	/********** ?�N?�?�?�b?�N & ?�?�?�Z?�b?�g **********/
	input  wire				   clk,		 // ?�N?�?�?�b?�N
	input  wire				   reset,	 // ?�񓯊�?�?�?�Z?�b?�g
	/********** ?�o?�X?�C?�?�?�^?�t?�F?�[?�X **********/
	input  wire				   cs_,		 // ?�`?�b?�v?�Z?�?�?�N?�g
	input  wire				   as_,		 // ?�A?�h?�?�?�X?�X?�g?�?�?�[?�u
	input  wire				   rw,		 // Read / Write
	input  wire  addr,	 // ?�A?�h?�?�?�X
	input  wire [31:0] wr_data,	 // ?�?�?�?�?�?�?�݃f?�[?�^
	output wire [31:0] rd_data,	 // ?�ǂݏo?�?�?�f?�[?�^
	output wire				   rdy_,	 // ?�?�?�f?�B
	/********** ?�?�?�荞�?� **********/
	output wire				   irq_rx,	 // ?�?�?�M?�?�?�?�?�?�?�荞�?�
	output wire				   irq_tx,	 // ?�?�?�M?�?�?�?�?�?�?�荞�?�
	/********** UART?�?�?�?�?�M?�M?�?�	**********/
	input  wire				   rx,		 // UART?�?�?�M?�M?�?�
	output wire				   tx		 // UART?�?�?�M?�M?�?�
);

	/********** ?�?�?�?�?�M?�?� **********/
	// ?�?�?�M?�?�?�?�
	wire					   rx_busy;	 // ?�?�?�M?�?�?�t?�?�?�O
	wire					   rx_end;	 // ?�?�?�M?�?�?�?�?�M?�?�
	wire [7:0]		   rx_data;	 // ?�?�?�M?�f?�[?�^
	// ?�?�?�M?�?�?�?�
	wire					   tx_busy;	 // ?�?�?�M?�?�?�t?�?�?�O
	wire					   tx_end;	 // ?�?�?�M?�?�?�?�?�M?�?�
	wire					   tx_start; // ?�?�?�M?�J?�n?�M?�?�
	wire [7:0]		   tx_data;	 // ?�?�?�M?�f?�[?�^

	/********** UART?�?�?�䃂�W?�?�?�[?�?� **********/
	uart_ctrl uart_ctrl (
		/********** ?�N?�?�?�b?�N & ?�?�?�Z?�b?�g **********/
		.clk	  (clk),	   // ?�N?�?�?�b?�N
		.rst	  (reset),	   // ?�񓯊�?�?�?�Z?�b?�g
		/********** Host Interface **********/
		.cs	  (cs_),	   // ?�`?�b?�v?�Z?�?�?�N?�g
		.as	  (as_),	   // ?�A?�h?�?�?�X?�X?�g?�?�?�[?�u
		.rw		  (rw),		   // Read / Write
		.addr	  (addr),	   // ?�A?�h?�?�?�X
		.wr_data  (wr_data),   // ?�?�?�?�?�?�?�݃f?�[?�^
		.rd_data  (rd_data),   // ?�ǂݏo?�?�?�f?�[?�^
		.rdy	  (rdy_),	   // ?�?�?�f?�B
		/********** Interrupt  **********/
		.irq_rx	  (irq_rx),	   // ?�?�?�M?�?�?�?�?�?�?�荞�?�
		.irq_tx	  (irq_tx),	   // ?�?�?�M?�?�?�?�?�?�?�荞�?�
		/********** ?�?�?�?�?�M?�?� **********/
		// ?�?�?�M?�?�?�?�
		.rx_busy  (rx_busy),   // ?�?�?�M?�?�?�t?�?�?�O
		.rx_end	  (rx_end),	   // ?�?�?�M?�?�?�?�?�M?�?�
		.rx_data  (rx_data),   // ?�?�?�M?�f?�[?�^
		// ?�?�?�M?�?�?�?�
		.tx_busy  (tx_busy),   // ?�?�?�M?�?�?�t?�?�?�O
		.tx_end	  (tx_end),	   // ?�?�?�M?�?�?�?�?�M?�?�
		.tx_start (tx_start),  // ?�?�?�M?�J?�n?�M?�?�
		.tx_data  (tx_data)	   // ?�?�?�M?�f?�[?�^
	);

	/********** UART?�?�?�M?�?�?�W?�?�?�[?�?� **********/
	uart_tx uart_tx (
		/********** ?�N?�?�?�b?�N & ?�?�?�Z?�b?�g **********/
		.clk	  (clk),	   // ?�N?�?�?�b?�N
		.rst	  (reset),	   // ?�񓯊�?�?�?�Z?�b?�g
		/********** ?�?�?�?�?�M?�?� **********/
		.tx_start (tx_start),  // ?�?�?�M?�J?�n?�M?�?�
		.tx_data  (tx_data),   // ?�?�?�M?�f?�[?�^
		.tx_busy  (tx_busy),   // ?�?�?�M?�?�?�t?�?�?�O
		.tx_end	  (tx_end),	   // ?�?�?�M?�?�?�?�?�M?�?�
		/********** Transmit Signal **********/
		.tx		  (tx)		   // UART?�?�?�M?�M?�?�
	);

	/********** UART?�?�?�M?�?�?�W?�?�?�[?�?� **********/
	uart_rx uart_rx (
		/********** ?�N?�?�?�b?�N & ?�?�?�Z?�b?�g **********/
		.clk	  (clk),	   // ?�N?�?�?�b?�N
		.rst	  (reset),	   // ?�񓯊�?�?�?�Z?�b?�g
		/********** ?�?�?�?�?�M?�?� **********/
		.rx_busy  (rx_busy),   // ?�?�?�M?�?�?�t?�?�?�O
		.rx_end	  (rx_end),	   // ?�?�?�M?�?�?�?�?�M?�?�
		.rx_data  (rx_data),   // ?�?�?�M?�f?�[?�^
		/********** Receive Signal **********/
		.rx		  (rx)		   // UART?�?�?�M?�M?�?�
	);

endmodule
