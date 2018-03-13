`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/03/13 14:32:53
// Design Name:
// Module Name: ctlr_cpu
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
/********** アドレスマップ **********/
`define CREG_ADDR_STATUS	 5'h0  // ステータス
`define CREG_ADDR_PRE_STATUS 5'h1  // 前のステータス
`define CREG_ADDR_PC		 5'h2  // プログラムカウンタ
`define CREG_ADDR_EPC		 5'h3  // 例外プログラムカウンタ
`define CREG_ADDR_EXP_VECTOR 5'h4  // 例外ベクタ
`define CREG_ADDR_CAUSE		 5'h5  // 例外原因レジスタ
`define CREG_ADDR_INT_MASK	 5'h6  // 割り込みマスク
`define CREG_ADDR_IRQ		 5'h7  // 割り込み要求
// 読み出し専用領域
`define CREG_ADDR_ROM_SIZE	 5'h1d // ROMサイズ
`define CREG_ADDR_SPM_SIZE	 5'h1e // SPMサイズ
`define CREG_ADDR_CPU_INFO	 5'h1f // CPU情報
/********** ビットマップ **********/
`define CregExeModeLoc		 0	   // 実行モードの位置
`define CregIntEnableLoc	 1	   // 割り込み有効の位置
`define CregExpCodeLoc		 2:0   // 例外コードの位置
`define CregDlyFlagLoc		 3	   // ディレイスロットフラグの位置

module ctrl_cpu(
    input clk,
    input rst,
    input[4:0] creg_rd_addr,
    output reg [`WORD_MSB:0]creg_rd_data,
    output reg exe_mode,
    input [7:0]irq,
    output reg int_detect,

    input [`WORD_ADDR_MSB:0]id_pc,

    input [`WORD_ADDR_MSB:0]mem_pc,
    input mem_en,
    input mem_br_flag,
    input [1:0]mem_ctrl_op,
    input [4:0]mem_dst_addr,
    input mem_gpr_we_,
    input [2:0]mem_exp_code,
    output reg [`WORD_MSB:0]mem_out,

    input if_busy,
    input ld_hazard,
    input mem_busy,

    output if_stall,
    output id_stall,
    output ex_stall,
    output mem_stall,
    output if_flush,
    output id_flush,
    output ex_flush,
    output mem_flush,

    output reg[`WORD_ADDR_MSB:0]new_pc
    );
    reg int_en,pre_exe_mode,pre_int_en,dly_flag,br_flag;
    reg [`WORD_ADDR_MSB:0]epc,exp_vector,pre_pc;
    reg[2:0]exp_code;
    reg[7:0]mask;


    wire stall=if_busy|mem_busy;
    assign if_stall=stall|ld_hazard;
    assign id_stall=stall;
    assign ex_stall=stall;
    assign mem_stall=stall;

    reg flush;
    assign if_flush=stall;
    assign id_flush=stall|ld_hazard;
    assign ex_flush=stall;
    assign mem_flush=stall;

    //pipeline flush cntl
    always @ ( * ) begin
      new_pc=0;
      flush=0;
      if(mem_en)begin
        if(mem_exp_code!=0)begin//exception op
          new_pc=exp_vector;
          flush=1;
        end
        else if(mem_ctrl_op==2)begin//recovery from exception
          new_pc=epc;
          flush=1;
        end
        else if(mem_exp_code==1)begin//write to ctrl_reg
          new_pc=mem_pc;
          flush=1;
        end
      end
    end

    //detect interrupt
    always @ ( * ) begin
      if(int_en && (|(~mask & irq)) )int_detect=1;
      else int_detect=0;
    end

    //read ctrl_reg
    always @ ( * ) begin
      case(creg_rd_addr)

      `CREG_ADDR_STATUS	    :creg_rd_data={{30'b0},int_en,exe_mode};// 現在のステータス
      `CREG_ADDR_PRE_STATUS :creg_rd_data={{{30'b0},pre_int_en,pre_exe_mode}}; // 前のステータス
      `CREG_ADDR_PC		      :creg_rd_data={id_pc,{2'b0}};// プログラムカウンタ
      `CREG_ADDR_EPC		    :creg_rd_data={epc,0,0};// 例外プログラムカウンタ
      `CREG_ADDR_EXP_VECTOR :creg_rd_data={{exp_vector,0,0}}; // 例外ベクタ
      `CREG_ADDR_CAUSE		  :creg_rd_data={{28'b0},dly_flag,exp_code};// 例外原因レジスタ
      `CREG_ADDR_INT_MASK	  :creg_rd_data={{24'b0},mask};// 割り込みマスク
      `CREG_ADDR_IRQ		    :creg_rd_data={{24'b0},irq};// 割り込み要求

      `CREG_ADDR_ROM_SIZE	  :creg_rd_data=$unsigned(8192);// ROMサイズ
      `CREG_ADDR_SPM_SIZE	  :creg_rd_data=$unsigned(8192*2);// SPMサイズ
      `CREG_ADDR_CPU_INFO	  :creg_rd_data=$unsigned(114514);// CPU情報
      endcase
    end

    always @ (posedge clk or negedge rst) begin
      if(~rst)begin
        exe_mode<=0;//CPU_KERNEL_MODE
        int_en<=0;
        pre_exe_mode<=0;//CPU_KERNEL_MODE
        pre_int_en<=0;
        exp_code<=0;
        mask<=8'b1;
        dly_flag<=0;
        epc<=0;
        exp_vector<=0;
        pre_pc<=0;
        br_flag<=0;
      end
      else begin
        if(mem_en && ~stall)begin//update cpu status
          pre_pc<=mem_pc;
          br_flag<=mem_br_flag;
          if(mem_exp_code!=0)begin //exception
            exe_mode<=0;
            int_en<=0;
            pre_exe_mode<=exe_mode;
            pre_int_en<=int_en;
            exp_code<=mem_exp_code;
            dly_flag<=br_flag;
            epc<=pre_int_en;
          end
          else if(mem_ctrl_op==2)begin//recovery from exception
            exe_mode<=pre_exe_mode;
            int_en<=pre_int_en;
          end
          else if(mem_ctrl_op==1)begin //write cntl reg
            case(mem_dst_addr)
            `CREG_ADDR_STATUS	    :begin
              exe_mode=mem_out[0];// 現在のステータス
              int_en=mem_out[1];
            end
            `CREG_ADDR_PRE_STATUS :begin
              pre_exe_mode=mem_out[0];// 前のステータス
              pre_int_en=mem_out[1];
            end
            `CREG_ADDR_EPC		    :begin
              epc=mem_out[31:2];// 例外プログラムカウンタ
            end
            `CREG_ADDR_EXP_VECTOR :begin
              exp_vector=mem_out[31:2];// 例外ベクタ
            end
            `CREG_ADDR_CAUSE		  :begin
              dly_flag=mem_out[3];// 例外原因レジスタ
              exp_code=mem_out[2:0];// 例外原因レジスタ
            end
            `CREG_ADDR_INT_MASK	  :begin
              mask=mem_out[7:0];// 割り込みマスク
            end
            endcase
          end
        end
      end
    end

endmodule
