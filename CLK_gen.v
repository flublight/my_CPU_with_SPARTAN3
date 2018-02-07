`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/02/07 16:22:55
// Design Name: 
// Module Name: CLK_gen
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


module DCM(
    input CLK,
    input RST,
    output CLK_OUT,
    output CLK_OUT180,
    output LOCKED //if true, LOCK inable
    );
    assign CLK_OUT180=~CLK;
    assign CLK_OUT=CLK;
    reg[3:0] L_cnt=0;
    assign LOCKED=L_cnt[3];
    
    always@(posedge CLK)begin
    L_cnt<=L_cnt+1;
    end    

endmodule

module CLK_gen(
    input CLK,
    input RST,
    output CLK_OUT,
    output CLK_OUT180,
    output Chip_RST
    );
    wire DCM_RST= (RST==1)? 1:0;
    wire LOCKED;
    assign Chip_RST= (RST==1||LOCKED==0)? 1:0;// rst or not lock  
    
    DCM dcm(
    CLK,RST,CLK_OUT,CLK_OUT180,LOCKED
    );
            
endmodule
