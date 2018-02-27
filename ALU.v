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
wire      pq=~sb[8];
wire[3:0] mx=(sb[4])?pr[3:0]:sb[3:0];
wire[15:0] zw={mx,zr[10:0],pq};      

assign p=zr[7:0];
assign q=zr[11:8];
always@(posedge clk or negedge rst) begin
    if(start)begin
     zr<={8'h00,z};
     dr<=d;
    end
    else if(en_seq)zr <=zw;
end

endmodule


/*
module ALU(

    );
endmodule
*/