`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/03/07 16:35:44
// Design Name:
// Module Name: bus_IF
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

module bus_IF(
    input clk,
    input rst,
    input stall,
    input flush,
    output reg busy,
    //cpu_interface
    input [`WORD_ADDR_MSB:0]addr,
    input as,
    input rw,
    output reg [`WORD_MSB:0]rd_data,
    input [`WORD_MSB:0]wr_data,
    //spm
    input [`WORD_MSB:0]spm_rd_data,
    output [`WORD_ADDR_MSB:0]spm_addr,
    output reg spm_as,
    output spm_rw,
    output [`WORD_MSB:0]spm_wr_data,
    //bus
    input [`WORD_MSB:0]bus_rd_data,
    input bus_rdy,
    input bus_grnt,
    output reg[`WORD_ADDR_MSB:0]bus_addr,
    output reg[`WORD_MSB:0]bus_wr_data,
    output reg bus_req,
    output reg bus_rw,
    output reg bus_as
    );
reg [1:0]state;//0:idle,1:bus_req,2:bus_access,3:stull
reg[`WORD_MSB:0]rd_buf;
wire s_index;
assign s_index = addr[29:27];//slave_index

assign spm_rw=rw;
assign spm_wr_data=wr_data;
assign spm_addr=addr;



always@(*)begin//memory access control
      rd_data=0;
      spm_as=0;
      busy=0;
      case(state)
      0:begin
        if(~flush&&as)
          if(s_index==1)begin
            if(~stall)begin
              spm_as=1;
              if(rw==0)rd_data=spm_rd_data;//read
            end
          end
          else busy=1;
        end

      1:busy=1;

      2:begin
        if(bus_rdy)begin
          if(rw==0)rd_data=bus_rd_data;//read
        end
        else busy=1;
        end

      3:if(rw==0)rd_data=rd_buf;

      endcase
    end
    always@(posedge clk or negedge rst)begin//bus access control
      if(~rst)begin
        state<=0;
        bus_req<=0;
        bus_addr<=0;
        bus_as<=0;
        bus_rw<=0;
        bus_wr_data<=0;
        rd_buf<=0;
      end
      else begin
          case (state)
          0:
          if(~flush&&as)
            if(s_index!=1)begin
              state<=1;
              bus_req<=1;
              bus_addr<=addr;
              bus_rw<=rw;
              bus_wr_data<=wr_data;
          end
            1:if(bus_grnt)begin
                state<=2;
                bus_as<=1;
              end
            2:begin
                bus_as<=0;
                if(bus_rdy)begin
                bus_req<=0;
                bus_addr<=0;
                bus_rw<=0;
                bus_wr_data<=0;
                //store read data
                if(bus_rw==0)rd_buf<=bus_rd_data;

                //check stall
                if(stall)state<=3;
                else state<=0;
                end
              end

            3:if(~stall)state<=0;
          endcase
        end
     end
endmodule
