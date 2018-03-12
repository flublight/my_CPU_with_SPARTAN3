`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/03/08 17:54:41
// Design Name:
// Module Name: stage_MEM
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

/*
 -- ============================================================================
 -- FILE NAME	: mem_stage.v
 -- DESCRIPTION : MEM�X�e�[�W
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	 Comment
 -- 1.0.0	  2011/06/27  suito		 �V�K�쐬
 -- ============================================================================
*/


`define WORD 32  // 1word
`define WORD_ADDR_W 30  // address width 1word

`define WORD_MSB `WORD-1
`define WORD_ADDR_MSB `WORD_ADDR_W-1
module mem_ctrl (
  input ex_en,
  input ex_mem_op,
  input ex_mem_wr_data,
  input ex_out,
  input rd_data,
  output reg addr,
  output reg as_,
  output reg rw,
  output reg wr_data,
  output reg out,
  output reg miss_align
  );
  wire offset[1:0];

  always @ ( * ) begin
    if(ex_en)begin

    end
  end


endmodule //mem_ctrl
module mem_stage (
	/********** �N���b�N & ���Z�b�g **********/
	input  wire				   clk,			   // �N���b�N
	input  wire				   reset,		   // �񓯊����Z�b�g
	/********** �p�C�v���C�������M�� **********/
	input  wire				   stall,		   // �X�g�[��
	input  wire				   flush,		   // �t���b�V��
	output wire				   busy,		   // �r�W�[�M��
	/********** �t�H���[�f�B���O **********/
	output wire [`WORD_MSB:0] fwd_data,	   // �t�H���[�f�B���O�f�[�^
	/********** SPM�C���^�t�F�[�X **********/
	input  wire [`WORD_MSB:0] spm_rd_data,	   // �ǂݏo���f�[�^
	output wire [`WORD_ADDR_MSB:0] spm_addr,	   // �A�h���X
	output wire				   spm_as_,		   // �A�h���X�X�g���[�u
	output wire				   spm_rw,		   // �ǂ݁^����
	output wire [`WORD_MSB:0] spm_wr_data,	   // �������݃f�[�^
	/********** �o�X�C���^�t�F�[�X **********/
	input  wire [`WORD_MSB:0] bus_rd_data,	   // �ǂݏo���f�[�^
	input  wire				   bus_rdy_,	   // ���f�B
	input  wire				   bus_grnt_,	   // �o�X�O�����g
	output wire				   bus_req_,	   // �o�X���N�G�X�g
	output wire [`WORD_ADDR_MSB:0] bus_addr,	   // �A�h���X
	output wire				   bus_as_,		   // �A�h���X�X�g���[�u
	output wire				   bus_rw,		   // �ǂ݁^����
	output wire [`WORD_MSB:0] bus_wr_data,	   // �������݃f�[�^
	/********** EX/MEM�p�C�v���C�����W�X�^ **********/
	input  wire [`WORD_ADDR_MSB:0] ex_pc,		   // �v���O�����J�E���^
	input  wire				   ex_en,		   // �p�C�v���C���f�[�^�̗L��
	input  wire				   ex_br_flag,	   // �����t���O
	input  wire [1:0]	   ex_mem_op,	   // �������I�y���[�V����
	input  wire [`WORD_MSB:0] ex_mem_wr_data, // �������������݃f�[�^
	input  wire [1:0]   ex_ctrl_op,	   // ���䃌�W�X�^�I�y���[�V����
	input  wire [5:0]  ex_dst_addr,	   // �ėp���W�X�^�������݃A�h���X
	input  wire				   ex_gpr_we_,	   // �ėp���W�X�^�������ݗL��
	input  wire [2:0]   ex_exp_code,	   // ���O�R�[�h
	input  wire [`WORD_MSB:0] ex_out,		   // ��������
	/********** MEM/WB�p�C�v���C�����W�X�^ **********/
	output wire [`WORD_ADDR_MSB:0] mem_pc,		   // �v���O�����J�E���^
	output wire				   mem_en,		   // �p�C�v���C���f�[�^�̗L��
	output wire				   mem_br_flag,	   // �����t���O
	output wire [1:0]   mem_ctrl_op,	   // ���䃌�W�X�^�I�y���[�V����
	output wire [5:0]  mem_dst_addr,   // �ėp���W�X�^�������݃A�h���X
	output wire				   mem_gpr_we_,	   // �ėp���W�X�^�������ݗL��
	output wire [2:0]   mem_exp_code,   // ���O�R�[�h
	output wire [`WORD_MSB:0] mem_out		   // ��������
);

	/********** �����M�� **********/
	wire [`WORD_MSB:0]		   rd_data;		   // �ǂݏo���f�[�^
	wire [`WORD_ADDR_MSB:0]		   addr;		   // �A�h���X
	wire					   as_;			   // �A�h���X�L��
	wire					   rw;			   // �ǂ݁^����
	wire [`WORD_MSB:0]		   wr_data;		   // �������݃f�[�^
	wire [`WORD_MSB:0]		   out;			   // �������A�N�Z�X����
	wire					   miss_align;	   // �~�X�A���C��

	/********** ���ʂ̃t�H���[�f�B���O **********/
	assign fwd_data	 = out;

	/********** �������A�N�Z�X���䃆�j�b�g **********/
	mem_ctrl mem_ctrl (
		/********** EX/MEM�p�C�v���C�����W�X�^ **********/
		.ex_en			(ex_en),			   // �p�C�v���C���f�[�^�̗L��
		.ex_mem_op		(ex_mem_op),		   // �������I�y���[�V����
		.ex_mem_wr_data (ex_mem_wr_data),	   // �������������݃f�[�^
		.ex_out			(ex_out),			   // ��������
		/********** �������A�N�Z�X�C���^�t�F�[�X **********/
		.rd_data		(rd_data),			   // �ǂݏo���f�[�^
		.addr			(addr),				   // �A�h���X
		.as_			(as_),				   // �A�h���X�L��
		.rw				(rw),				   // �ǂ݁^����
		.wr_data		(wr_data),			   // �������݃f�[�^
		/********** �������A�N�Z�X���� **********/
		.out			(out),				   // �������A�N�Z�X����
		.miss_align		(miss_align)		   // �~�X�A���C��
	);

	/********** �o�X�C���^�t�F�[�X **********/
	bus_if bus_if (
		/********** �N���b�N & ���Z�b�g **********/
		.clk		 (clk),					   // �N���b�N
		.reset		 (reset),				   // �񓯊����Z�b�g
		/********** �p�C�v���C�������M�� **********/
		.stall		 (stall),				   // �X�g�[��
		.flush		 (flush),				   // �t���b�V���M��
		.busy		 (busy),				   // �r�W�[�M��
		/********** CPU�C���^�t�F�[�X **********/
		.addr		 (addr),				   // �A�h���X
		.as_		 (as_),					   // �A�h���X�L��
		.rw			 (rw),					   // �ǂ݁^����
		.wr_data	 (wr_data),				   // �������݃f�[�^
		.rd_data	 (rd_data),				   // �ǂݏo���f�[�^
		/********** �X�N���b�`�p�b�h�������C���^�t�F�[�X **********/
		.spm_rd_data (spm_rd_data),			   // �ǂݏo���f�[�^
		.spm_addr	 (spm_addr),			   // �A�h���X
		.spm_as_	 (spm_as_),				   // �A�h���X�X�g���[�u
		.spm_rw		 (spm_rw),				   // �ǂ݁^����
		.spm_wr_data (spm_wr_data),			   // �������݃f�[�^
		/********** �o�X�C���^�t�F�[�X **********/
		.bus_rd_data (bus_rd_data),			   // �ǂݏo���f�[�^
		.bus_rdy_	 (bus_rdy_),			   // ���f�B
		.bus_grnt_	 (bus_grnt_),			   // �o�X�O�����g
		.bus_req_	 (bus_req_),			   // �o�X���N�G�X�g
		.bus_addr	 (bus_addr),			   // �A�h���X
		.bus_as_	 (bus_as_),				   // �A�h���X�X�g���[�u
		.bus_rw		 (bus_rw),				   // �ǂ݁^����
		.bus_wr_data (bus_wr_data)			   // �������݃f�[�^
	);

	/********** MEM�X�e�[�W�p�C�v���C�����W�X�^ **********/
	mem_reg mem_reg (
		/********** �N���b�N & ���Z�b�g **********/
		.clk		  (clk),				   // �N���b�N
		.reset		  (reset),				   // �񓯊����Z�b�g
		/********** �������A�N�Z�X���� **********/
		.out		  (out),				   // ����
		.miss_align	  (miss_align),			   // �~�X�A���C��
		/********** �p�C�v���C�������M�� **********/
		.stall		  (stall),				   // �X�g�[��
		.flush		  (flush),				   // �t���b�V��
		/********** EX/MEM�p�C�v���C�����W�X�^ **********/
		.ex_pc		  (ex_pc),				   // �v���O�����J�E���^
		.ex_en		  (ex_en),				   // �p�C�v���C���f�[�^�̗L��
		.ex_br_flag	  (ex_br_flag),			   // �����t���O
		.ex_ctrl_op	  (ex_ctrl_op),			   // ���䃌�W�X�^�I�y���[�V����
		.ex_dst_addr  (ex_dst_addr),		   // �ėp���W�X�^�������݃A�h���X
		.ex_gpr_we_	  (ex_gpr_we_),			   // �ėp���W�X�^�������ݗL��
		.ex_exp_code  (ex_exp_code),		   // ���O�R�[�h
		/********** MEM/WB�p�C�v���C�����W�X�^ **********/
		.mem_pc		  (mem_pc),				   // �v���O�����J�E���^
		.mem_en		  (mem_en),				   // �p�C�v���C���f�[�^�̗L��
		.mem_br_flag  (mem_br_flag),		   // �����t���O
		.mem_ctrl_op  (mem_ctrl_op),		   // ���䃌�W�X�^�I�y���[�V����
		.mem_dst_addr (mem_dst_addr),		   // �ėp���W�X�^�������݃A�h���X
		.mem_gpr_we_  (mem_gpr_we_),		   // �ėp���W�X�^�������ݗL��
		.mem_exp_code (mem_exp_code),		   // ���O�R�[�h
		.mem_out	  (mem_out)				   // ��������
	);

endmodule
