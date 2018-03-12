`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/03/08 17:54:41
// Design Name:
// Module Name: stage_EX
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

`define GPR_ADDR_MSB 5-1

`define WORD_MSB `WORD-1
`define WORD_ADDR_MSB `WORD_ADDR_W-1
`define RegAddrBus `GPR_ADDR_MSB:0


module reg_EX (
input  wire				   clk,			   // �N���b�N
input  wire				   rst,		   // �񓯊����Z�b�g
/********** �p�C�v���C�������M�� **********/
input  wire				   stall,		   // �X�g�[��
input  wire				   flush,		   // �t���b�V��
input  wire				   int_detect,	   // ���荞�݌��o
/********** �t�H���[�f�B���O **********/
output wire [`WORD_MSB:0] fwd_data,	   // �t�H���[�f�B���O�f�[�^
/********** ID/EX�p�C�v���C�����W�X�^ **********/
input  wire [`WORD_ADDR_MSB:0] id_pc,		   // �v���O�����J�E���^
input  wire				   id_en,		   // �p�C�v���C���f�[�^�̗L��
input  wire [3:0]	   alu_of,	   // ALU�I�y���[�V����
input  wire [`WORD_MSB:0] alu_out,	   // ALU���� 0
input  wire				   id_br_flag,	   // �����t���O
input  wire [1:0]	   id_mem_op,	   // �������I�y���[�V����
input  wire [`WORD_MSB:0] id_mem_wr_data, // �������������݃f�[�^
input  wire [1:0]   id_ctrl_op,	   // ���䃌�W�X�^�I�y���[�V����
input  wire [`RegAddrBus]  id_dst_addr,	   // �ėp���W�X�^�������݃A�h���X
input  wire				   id_gpr_we_,	   // �ėp���W�X�^�������ݗL��
input  wire [2:0]   id_exp_code,	   // ���O�R�[�h
/********** EX/MEM�p�C�v���C�����W�X�^ **********/
output reg [`WORD_ADDR_MSB:0] ex_pc,		   // �v���O�����J�E���^
output reg				   ex_en,		   // �p�C�v���C���f�[�^�̗L��
output reg				   ex_br_flag,	   // �����t���O
output reg [1:0]	   ex_mem_op,	   // �������I�y���[�V����
output reg [`WORD_MSB:0] ex_mem_wr_data, // �������������݃f�[�^
output reg [1:0]   ex_ctrl_op,	   // ���䃌�W�X�^�I�y���[�V����
output reg [`RegAddrBus]  ex_dst_addr,	   // �ėp���W�X�^�������݃A�h���X
output reg				   ex_gpr_we_,	   // �ėp���W�X�^�������ݗL��
output reg [2:0]   ex_exp_code,	   // ���O�R�[�h
output reg [`WORD_MSB:0] ex_out		   // ��������
);


		  always@(posedge clk or negedge rst)begin//bus access control
		    if(~rst)begin
		      ex_pc<=0;
		      ex_en<=0;
					ex_br_flag<=0;
					ex_mem_op<=0;
					ex_mem_wr_data<=0;
					ex_ctrl_op<=0;
					ex_dst_addr<=0;
					ex_gpr_we_<=0;
					ex_exp_code<=0;
          ex_out<=0;
				end
		    else if(~stall)begin
					if(flush)begin
						ex_pc<=0;
		      	ex_en<=0;
						ex_br_flag<=0;
						ex_mem_op<=0;
						ex_mem_wr_data<=0;
						ex_ctrl_op<=0;
						ex_dst_addr<=0;
						ex_gpr_we_<=0;
						ex_exp_code<=0;
            ex_out<=0;
					end
          else if (int_detect)begin
						ex_pc<=id_pc;
						ex_en<=id_en;
						ex_br_flag<=id_br_flag;
						ex_mem_op<=0;
						ex_mem_wr_data<=0;
						ex_ctrl_op<=0;
						ex_dst_addr<=0;
						ex_gpr_we_<=0;
						ex_exp_code<=1;//interrupt
            ex_out<=0;
          end
          else if (alu_of)begin
						ex_pc<=id_pc;
						ex_en<=id_en;
						ex_br_flag<=id_br_flag;
						ex_mem_op<=0;
						ex_mem_wr_data<=0;
						ex_ctrl_op<=0;
						ex_dst_addr<=0;
						ex_gpr_we_<=0;
						ex_exp_code<=3;//overflow
            ex_out<=0;
          end

					else begin
						ex_pc<=id_pc;
						ex_en<=id_en;
						ex_br_flag<=id_br_flag;
						ex_mem_op<=id_mem_op;
						ex_mem_wr_data<=id_mem_wr_data;
						ex_ctrl_op<=id_ctrl_op;
						ex_dst_addr<=id_dst_addr;
						ex_gpr_we_<=id_gpr_we_;
						ex_exp_code<=id_exp_code;
            ex_out<=alu_out;
					end
				end
			end

endmodule //reg_EX


module stage_EX(

  	/********** �N���b�N & ���Z�b�g **********/
  	input  wire				   clk,			   // �N���b�N
  	input  wire				   reset,		   // �񓯊����Z�b�g
  	/********** �p�C�v���C�������M�� **********/
  	input  wire				   stall,		   // �X�g�[��
  	input  wire				   flush,		   // �t���b�V��
  	input  wire				   int_detect,	   // ���荞�݌��o

  	input  wire [`WORD_ADDR_MSB:0] id_pc,		   // �v���O�����J�E���^
  	input  wire				   id_en,		   // �p�C�v���C���f�[�^�̗L��
  	input  wire				   id_br_flag,	   // �����t���O
  	input  wire [1:0]	   id_mem_op,	   // �������I�y���[�V����
  	input  wire [`WORD_MSB:0] id_mem_wr_data, // �������������݃f�[�^
  	input  wire [1:0]   id_ctrl_op,	   // ���䃌�W�X�^�I�y���[�V����
  	input  wire [`RegAddrBus]  id_dst_addr,	   // �ėp���W�X�^�������݃A�h���X
  	input  wire				   id_gpr_we_,	   // �ėp���W�X�^�������ݗL��
  	input  wire [2:0]   id_exp_code,	   // ���O�R�[�h
  	/********** EX/MEM�p�C�v���C�����W�X�^ **********/
  	output reg [`WORD_ADDR_MSB:0] ex_pc,		   // �v���O�����J�E���^
  	output reg				   ex_en,		   // �p�C�v���C���f�[�^�̗L��
  	output reg				   ex_br_flag,	   // �����t���O
  	output reg [1:0]	   ex_mem_op,	   // �������I�y���[�V����
  	output reg [`WORD_MSB:0] ex_mem_wr_data, // �������������݃f�[�^
  	output reg [1:0]   ex_ctrl_op,	   // ���䃌�W�X�^�I�y���[�V����
  	output reg [`RegAddrBus]  ex_dst_addr,	   // �ėp���W�X�^�������݃A�h���X
  	output reg				   ex_gpr_we_,	   // �ėp���W�X�^�������ݗL��
  	output reg [2:0]   ex_exp_code,	   // ���O�R�[�h
  	output reg [`WORD_MSB:0] ex_out		   // ��������
  );

  	/********** ALU�̏o�� **********/
  	wire [`WORD_MSB:0]		   alu_out;		   // ���Z����
  	wire					   alu_of;		   // �I�[�o�t���[

  	/********** ���Z���ʂ̃t�H���[�f�B���O **********/
  	assign fwd_data = alu_out;

  	/********** ALU **********/
  	alu alu (
  		.in_0			(id_alu_in_0),	  // ���� 0
  		.in_1			(id_alu_in_1),	  // ���� 1
  		.op				(id_alu_op),	  // �I�y���[�V����
  		.out			(alu_out),		  // �o��
  		.of				(alu_of)		  // �I�[�o�t���[
  	);

  	/********** �p�C�v���C�����W�X�^ **********/
  	ex_reg ex_reg (
  		/********** �N���b�N & ���Z�b�g **********/
  		.clk			(clk),			  // �N���b�N
  		.rst			(reset),		  // �񓯊����Z�b�g
  		/********** ALU�̏o�� **********/
  		.alu_out		(alu_out),		  // ���Z����
  		.alu_of			(alu_of),		  // �I�[�o�t���[
  		/********** �p�C�v���C�������M�� **********/
  		.stall			(stall),		  // �X�g�[��
  		.flush			(flush),		  // �t���b�V��
  		.int_detect		(int_detect),	  // ���荞�݌��o
  		/********** ID/EX�p�C�v���C�����W�X�^ **********/
  		.id_pc			(id_pc),		  // �v���O�����J�E���^
  		.id_en			(id_en),		  // �p�C�v���C���f�[�^�̗L��
  		.id_br_flag		(id_br_flag),	  // �����t���O
  		.id_mem_op		(id_mem_op),	  // �������I�y���[�V����
  		.id_mem_wr_data (id_mem_wr_data), // �������������݃f�[�^
  		.id_ctrl_op		(id_ctrl_op),	  // ���䃌�W�X�^�I�y���[�V����
  		.id_dst_addr	(id_dst_addr),	  // �ėp���W�X�^�������݃A�h���X
  		.id_gpr_we_		(id_gpr_we_),	  // �ėp���W�X�^�������ݗL��
  		.id_exp_code	(id_exp_code),	  // ���O�R�[�h
  		/********** EX/MEM�p�C�v���C�����W�X�^ **********/
  		.ex_pc			(ex_pc),		  // �v���O�����J�E���^
  		.ex_en			(ex_en),		  // �p�C�v���C���f�[�^�̗L��
  		.ex_br_flag		(ex_br_flag),	  // �����t���O
  		.ex_mem_op		(ex_mem_op),	  // �������I�y���[�V����
  		.ex_mem_wr_data (ex_mem_wr_data), // �������������݃f�[�^
  		.ex_ctrl_op		(ex_ctrl_op),	  // ���䃌�W�X�^�I�y���[�V����
  		.ex_dst_addr	(ex_dst_addr),	  // �ėp���W�X�^�������݃A�h���X
  		.ex_gpr_we_		(ex_gpr_we_),	  // �ėp���W�X�^�������ݗL��
  		.ex_exp_code	(ex_exp_code),	  // ���O�R�[�h
  		.ex_out			(ex_out)		  // ��������
  	);

endmodule
