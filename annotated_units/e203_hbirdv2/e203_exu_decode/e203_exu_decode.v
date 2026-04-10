 /*                                                                      
 Copyright 2018-2020 Nuclei System Technology, Inc.                
                                                                         
 Licensed under the Apache License, Version 2.0 (the "License");         
 you may not use this file except in compliance with the License.        
 You may obtain a copy of the License at                                 
                                                                         
     http://www.apache.org/licenses/LICENSE-2.0                          
                                                                         
  Unless required by applicable law or agreed to in writing, software    
 distributed under the License is distributed on an "AS IS" BASIS,       
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and     
 limitations under the License.                                          
 */                                                                      
                                                                         
                                                                         
                                                                         
//=====================================================================
//
// Designer   : Bob Hu
//
// Description:
//  The decode module to decode the instruction details
//
// ====================================================================
`include "e203_defines.v"

module e203_exu_decode(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=30-82

  //////////////////////////////////////////////////////////////
  // The IR stage to Decoder
  input  [`E203_INSTR_SIZE-1:0] i_instr,
  input  [`E203_PC_SIZE-1:0] i_pc,
  input  i_prdt_taken, 
  input  i_misalgn,              // The fetch misalign
  input  i_buserr,               // The fetch bus error
  input  i_muldiv_b2b,           // The back2back case for mul/div

  input  dbg_mode,
  //////////////////////////////////////////////////////////////
  // The Decoded Info-Bus

  output dec_rs1x0,
  output dec_rs2x0,
  output dec_rs1en,
  output dec_rs2en,
  output dec_rdwen,
  output [`E203_RFIDX_WIDTH-1:0] dec_rs1idx,
  output [`E203_RFIDX_WIDTH-1:0] dec_rs2idx,
  output [`E203_RFIDX_WIDTH-1:0] dec_rdidx,
  output [`E203_DECINFO_WIDTH-1:0] dec_info,  
  output [`E203_XLEN-1:0] dec_imm,
  output [`E203_PC_SIZE-1:0] dec_pc,
  output dec_misalgn,
  output dec_buserr,
  output dec_ilegl,

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=59-66
  `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=59-66
  //////////////////////////////////////
  //nice decode
  input  nice_xs_off,  
  output dec_nice,
  output nice_cmt_off_ilgl_o,      
  /////////////////////////////////////
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=59-66
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=59-66

  output dec_mulhsu,
  output dec_mul   ,
  output dec_div   ,
  output dec_rem   ,
  output dec_divu  ,
  output dec_remu  ,

  output dec_rv32,
  output dec_bjp,
  output dec_jal,
  output dec_jalr,
  output dec_bxx,

  output [`E203_RFIDX_WIDTH-1:0] dec_jalr_rs1idx,
  output [`E203_XLEN-1:0] dec_bjp_imm 
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=30-82
  );



//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=87-263
  wire [32-1:0] rv32_instr = i_instr;
  wire [16-1:0] rv16_instr = i_instr[15:0];

  wire [6:0]  opcode = rv32_instr[6:0];

  wire opcode_1_0_00  = (opcode[1:0] == 2'b00);
  wire opcode_1_0_01  = (opcode[1:0] == 2'b01);
  wire opcode_1_0_10  = (opcode[1:0] == 2'b10);
  wire opcode_1_0_11  = (opcode[1:0] == 2'b11);

  wire rv32 = (~(i_instr[4:2] == 3'b111)) & opcode_1_0_11;

  wire [4:0]  rv32_rd     = rv32_instr[11:7];
  wire [2:0]  rv32_func3  = rv32_instr[14:12];
  wire [4:0]  rv32_rs1    = rv32_instr[19:15];
  wire [4:0]  rv32_rs2    = rv32_instr[24:20];
  wire [6:0]  rv32_func7  = rv32_instr[31:25];

  wire [4:0]  rv16_rd     = rv32_rd;
  wire [4:0]  rv16_rs1    = rv16_rd; 
  wire [4:0]  rv16_rs2    = rv32_instr[6:2];

  wire [4:0]  rv16_rdd    = {2'b01,rv32_instr[4:2]};
  wire [4:0]  rv16_rss1   = {2'b01,rv32_instr[9:7]};
  wire [4:0]  rv16_rss2   = rv16_rdd;

  wire [2:0]  rv16_func3  = rv32_instr[15:13];

  
  // We generate the signals and reused them as much as possible to save gatecounts
  wire opcode_4_2_000 = (opcode[4:2] == 3'b000);
  wire opcode_4_2_001 = (opcode[4:2] == 3'b001);
  wire opcode_4_2_010 = (opcode[4:2] == 3'b010);
  wire opcode_4_2_011 = (opcode[4:2] == 3'b011);
  wire opcode_4_2_100 = (opcode[4:2] == 3'b100);
  wire opcode_4_2_101 = (opcode[4:2] == 3'b101);
  wire opcode_4_2_110 = (opcode[4:2] == 3'b110);
  wire opcode_4_2_111 = (opcode[4:2] == 3'b111);
  wire opcode_6_5_00  = (opcode[6:5] == 2'b00);
  wire opcode_6_5_01  = (opcode[6:5] == 2'b01);
  wire opcode_6_5_10  = (opcode[6:5] == 2'b10);
  wire opcode_6_5_11  = (opcode[6:5] == 2'b11);

  wire rv32_func3_000 = (rv32_func3 == 3'b000);
  wire rv32_func3_001 = (rv32_func3 == 3'b001);
  wire rv32_func3_010 = (rv32_func3 == 3'b010);
  wire rv32_func3_011 = (rv32_func3 == 3'b011);
  wire rv32_func3_100 = (rv32_func3 == 3'b100);
  wire rv32_func3_101 = (rv32_func3 == 3'b101);
  wire rv32_func3_110 = (rv32_func3 == 3'b110);
  wire rv32_func3_111 = (rv32_func3 == 3'b111);

  wire rv16_func3_000 = (rv16_func3 == 3'b000);
  wire rv16_func3_001 = (rv16_func3 == 3'b001);
  wire rv16_func3_010 = (rv16_func3 == 3'b010);
  wire rv16_func3_011 = (rv16_func3 == 3'b011);
  wire rv16_func3_100 = (rv16_func3 == 3'b100);
  wire rv16_func3_101 = (rv16_func3 == 3'b101);
  wire rv16_func3_110 = (rv16_func3 == 3'b110);
  wire rv16_func3_111 = (rv16_func3 == 3'b111);

  wire rv32_func7_0000000 = (rv32_func7 == 7'b0000000);
  wire rv32_func7_0100000 = (rv32_func7 == 7'b0100000);
  wire rv32_func7_0000001 = (rv32_func7 == 7'b0000001);
  wire rv32_func7_0000101 = (rv32_func7 == 7'b0000101);
  wire rv32_func7_0001001 = (rv32_func7 == 7'b0001001);
  wire rv32_func7_0001101 = (rv32_func7 == 7'b0001101);
  wire rv32_func7_0010101 = (rv32_func7 == 7'b0010101);
  wire rv32_func7_0100001 = (rv32_func7 == 7'b0100001);
  wire rv32_func7_0010001 = (rv32_func7 == 7'b0010001);
  wire rv32_func7_0101101 = (rv32_func7 == 7'b0101101);
  wire rv32_func7_1111111 = (rv32_func7 == 7'b1111111);
  wire rv32_func7_0000100 = (rv32_func7 == 7'b0000100); 
  wire rv32_func7_0001000 = (rv32_func7 == 7'b0001000); 
  wire rv32_func7_0001100 = (rv32_func7 == 7'b0001100); 
  wire rv32_func7_0101100 = (rv32_func7 == 7'b0101100); 
  wire rv32_func7_0010000 = (rv32_func7 == 7'b0010000); 
  wire rv32_func7_0010100 = (rv32_func7 == 7'b0010100); 
  wire rv32_func7_1100000 = (rv32_func7 == 7'b1100000); 
  wire rv32_func7_1110000 = (rv32_func7 == 7'b1110000); 
  wire rv32_func7_1010000 = (rv32_func7 == 7'b1010000); 
  wire rv32_func7_1101000 = (rv32_func7 == 7'b1101000); 
  wire rv32_func7_1111000 = (rv32_func7 == 7'b1111000); 
  wire rv32_func7_1010001 = (rv32_func7 == 7'b1010001);  
  wire rv32_func7_1110001 = (rv32_func7 == 7'b1110001);  
  wire rv32_func7_1100001 = (rv32_func7 == 7'b1100001);  
  wire rv32_func7_1101001 = (rv32_func7 == 7'b1101001);  

  wire rv32_rs1_x0 = (rv32_rs1 == 5'b00000);
  wire rv32_rs2_x0 = (rv32_rs2 == 5'b00000);
  wire rv32_rs2_x1 = (rv32_rs2 == 5'b00001);
  wire rv32_rd_x0  = (rv32_rd  == 5'b00000);
  wire rv32_rd_x2  = (rv32_rd  == 5'b00010);

  wire rv16_rs1_x0 = (rv16_rs1 == 5'b00000);
  wire rv16_rs2_x0 = (rv16_rs2 == 5'b00000);
  wire rv16_rd_x0  = (rv16_rd  == 5'b00000);
  wire rv16_rd_x2  = (rv16_rd  == 5'b00010);

  wire rv32_rs1_x31 = (rv32_rs1 == 5'b11111);
  wire rv32_rs2_x31 = (rv32_rs2 == 5'b11111);
  wire rv32_rd_x31  = (rv32_rd  == 5'b11111);

  wire rv32_load     = opcode_6_5_00 & opcode_4_2_000 & opcode_1_0_11; 
  wire rv32_store    = opcode_6_5_01 & opcode_4_2_000 & opcode_1_0_11; 
  wire rv32_madd     = opcode_6_5_10 & opcode_4_2_000 & opcode_1_0_11; 
  wire rv32_branch   = opcode_6_5_11 & opcode_4_2_000 & opcode_1_0_11; 

  wire rv32_load_fp  = opcode_6_5_00 & opcode_4_2_001 & opcode_1_0_11; 
  wire rv32_store_fp = opcode_6_5_01 & opcode_4_2_001 & opcode_1_0_11; 
  wire rv32_msub     = opcode_6_5_10 & opcode_4_2_001 & opcode_1_0_11; 
  wire rv32_jalr     = opcode_6_5_11 & opcode_4_2_001 & opcode_1_0_11; 

  wire rv32_custom0  = opcode_6_5_00 & opcode_4_2_010 & opcode_1_0_11; 
  wire rv32_custom1  = opcode_6_5_01 & opcode_4_2_010 & opcode_1_0_11; 
  wire rv32_nmsub    = opcode_6_5_10 & opcode_4_2_010 & opcode_1_0_11; 
  wire rv32_resved0  = opcode_6_5_11 & opcode_4_2_010 & opcode_1_0_11; 

  wire rv32_miscmem  = opcode_6_5_00 & opcode_4_2_011 & opcode_1_0_11; 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=206-208
  `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=206-208
  wire rv32_amo      = opcode_6_5_01 & opcode_4_2_011 & opcode_1_0_11; 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=206-208
  `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=206-208
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=209-211
  `ifndef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=209-211
  wire rv32_amo      = 1'b0;
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=209-211
  `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=209-211
  wire rv32_nmadd    = opcode_6_5_10 & opcode_4_2_011 & opcode_1_0_11; 
  wire rv32_jal      = opcode_6_5_11 & opcode_4_2_011 & opcode_1_0_11; 

  wire rv32_op_imm   = opcode_6_5_00 & opcode_4_2_100 & opcode_1_0_11; 
  wire rv32_op       = opcode_6_5_01 & opcode_4_2_100 & opcode_1_0_11; 
  wire rv32_op_fp    = opcode_6_5_10 & opcode_4_2_100 & opcode_1_0_11; 
  wire rv32_system   = opcode_6_5_11 & opcode_4_2_100 & opcode_1_0_11; 

  wire rv32_auipc    = opcode_6_5_00 & opcode_4_2_101 & opcode_1_0_11; 
  wire rv32_lui      = opcode_6_5_01 & opcode_4_2_101 & opcode_1_0_11; 
  wire rv32_resved1  = opcode_6_5_10 & opcode_4_2_101 & opcode_1_0_11; 
  wire rv32_resved2  = opcode_6_5_11 & opcode_4_2_101 & opcode_1_0_11; 

  wire rv32_op_imm_32= opcode_6_5_00 & opcode_4_2_110 & opcode_1_0_11; 
  wire rv32_op_32    = opcode_6_5_01 & opcode_4_2_110 & opcode_1_0_11; 
  wire rv32_custom2  = opcode_6_5_10 & opcode_4_2_110 & opcode_1_0_11; 
  wire rv32_custom3  = opcode_6_5_11 & opcode_4_2_110 & opcode_1_0_11; 

  wire rv16_addi4spn     = opcode_1_0_00 & rv16_func3_000;//
  wire rv16_lw           = opcode_1_0_00 & rv16_func3_010;//
  wire rv16_sw           = opcode_1_0_00 & rv16_func3_110;//


  wire rv16_addi         = opcode_1_0_01 & rv16_func3_000;//
  wire rv16_jal          = opcode_1_0_01 & rv16_func3_001;//
  wire rv16_li           = opcode_1_0_01 & rv16_func3_010;//
  wire rv16_lui_addi16sp = opcode_1_0_01 & rv16_func3_011;//--
  wire rv16_miscalu      = opcode_1_0_01 & rv16_func3_100;//--
  wire rv16_j            = opcode_1_0_01 & rv16_func3_101;//
  wire rv16_beqz         = opcode_1_0_01 & rv16_func3_110;//
  wire rv16_bnez         = opcode_1_0_01 & rv16_func3_111;//


  wire rv16_slli         = opcode_1_0_10 & rv16_func3_000;//
  wire rv16_lwsp         = opcode_1_0_10 & rv16_func3_010;//
  wire rv16_jalr_mv_add  = opcode_1_0_10 & rv16_func3_100;//--
  wire rv16_swsp         = opcode_1_0_10 & rv16_func3_110;//

//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000004 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=250-259
  `ifndef E203_HAS_FPU//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000004 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=250-259
  wire rv16_flw          = 1'b0;
  wire rv16_fld          = 1'b0;
  wire rv16_fsw          = 1'b0;
  wire rv16_fsd          = 1'b0;
  wire rv16_fldsp        = 1'b0;
  wire rv16_flwsp        = 1'b0;
  wire rv16_fsdsp        = 1'b0;
  wire rv16_fswsp        = 1'b0;
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000004 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=250-259
  `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000004 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=250-259

  wire rv16_lwsp_ilgl    = rv16_lwsp & rv16_rd_x0;//(RES, rd=0)

  wire rv16_nop          = rv16_addi  
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=87-263
                         & (~rv16_instr[12]) & (rv16_rd_x0) & (rv16_rs2_x0);

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=266-273
  wire rv16_srli         = rv16_miscalu  & (rv16_instr[11:10] == 2'b00);
  wire rv16_srai         = rv16_miscalu  & (rv16_instr[11:10] == 2'b01);
  wire rv16_andi         = rv16_miscalu  & (rv16_instr[11:10] == 2'b10);

  wire rv16_instr_12_is0   = (rv16_instr[12] == 1'b0);
  wire rv16_instr_6_2_is0s = (rv16_instr[6:2] == 5'b0);

  wire rv16_sxxi_shamt_legl = 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=266-273
                 rv16_instr_12_is0 //shamt[5] must be zero for RV32C
               & (~(rv16_instr_6_2_is0s)) //shamt[4:0] must be non-zero for RV32C
                 ;
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=277-298
  wire rv16_sxxi_shamt_ilgl =  (rv16_slli | rv16_srli | rv16_srai) & (~rv16_sxxi_shamt_legl);

  wire rv16_addi16sp     = rv16_lui_addi16sp & rv32_rd_x2;//
  wire rv16_lui          = rv16_lui_addi16sp & (~rv32_rd_x0) & (~rv32_rd_x2);//
  
  //C.LI is only valid when rd!=x0.
  wire rv16_li_ilgl = rv16_li & (rv16_rd_x0);
  //C.LUI is only valid when rd!=x0 or x2, and when the immediate is not equal to zero.
  wire rv16_lui_ilgl = rv16_lui & (rv16_rd_x0 | rv16_rd_x2 | (rv16_instr_6_2_is0s & rv16_instr_12_is0));

  wire rv16_li_lui_ilgl = rv16_li_ilgl | rv16_lui_ilgl;

  wire rv16_addi4spn_ilgl = rv16_addi4spn & (rv16_instr_12_is0 & rv16_rd_x0 & opcode_6_5_00);//(RES, nzimm=0, bits[12:5])
  wire rv16_addi16sp_ilgl = rv16_addi16sp & rv16_instr_12_is0 & rv16_instr_6_2_is0s; //(RES, nzimm=0, bits 12,6:2)

  wire rv16_subxororand  = rv16_miscalu  & (rv16_instr[12:10] == 3'b011);//
  wire rv16_sub          = rv16_subxororand & (rv16_instr[6:5] == 2'b00);//
  wire rv16_xor          = rv16_subxororand & (rv16_instr[6:5] == 2'b01);//
  wire rv16_or           = rv16_subxororand & (rv16_instr[6:5] == 2'b10);//
  wire rv16_and          = rv16_subxororand & (rv16_instr[6:5] == 2'b11);//

  wire rv16_jr           = rv16_jalr_mv_add //
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=277-298
                         & (~rv16_instr[12]) & (~rv16_rs1_x0) & (rv16_rs2_x0);// The RES rs1=0 illegal is already covered here
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=300-300
  wire rv16_mv           = rv16_jalr_mv_add //
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=300-300
                         & (~rv16_instr[12]) & (~rv16_rd_x0) & (~rv16_rs2_x0);
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000005 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=302-302
  wire rv16_ebreak       = rv16_jalr_mv_add //
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000005 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=302-302
                         & (rv16_instr[12]) & (rv16_rd_x0) & (rv16_rs2_x0);
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000006 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=304-304
  wire rv16_jalr         = rv16_jalr_mv_add //
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000006 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=304-304
                         & (rv16_instr[12]) & (~rv16_rs1_x0) & (rv16_rs2_x0);
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000007 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=306-306
  wire rv16_add          = rv16_jalr_mv_add // 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000007 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=306-306
                         & (rv16_instr[12]) & (~rv16_rd_x0) & (~rv16_rs2_x0);

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000005 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=309-327
  `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000005 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=309-327
  // ==========================================================================
  // add nice logic 

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000008 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=313-318
  wire nice_need_rs1 = rv32_instr[13];
  wire nice_need_rs2 = rv32_instr[12];
  wire nice_need_rd  = rv32_instr[14];
  wire [31:5] nice_instr  = rv32_instr[31:5];

  wire nice_op = rv32_custom0 | rv32_custom1 | rv32_custom2 | rv32_custom3;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000008 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=313-318
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=319-321
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000001 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=319-319
  assign dec_nice = nice_op;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000001 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=319-319
  
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000002 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=321-321
  assign nice_cmt_off_ilgl_o = nice_xs_off & nice_op;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000002 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=321-321
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=319-321

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000009 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=323-323
  wire [`E203_DECINFO_NICE_WIDTH-1:0] nice_info_bus;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000009 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=323-323
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=324-326
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000003 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=324-324
  assign nice_info_bus[`E203_DECINFO_GRP    ]    = `E203_DECINFO_GRP_NICE;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000003 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=324-324
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000004 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=325-325
  assign nice_info_bus[`E203_DECINFO_RV32   ]    = rv32;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000004 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=325-325
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000005 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=326-326
  assign nice_info_bus[`E203_DECINFO_NICE_INSTR]  = nice_instr;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000005 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=326-326
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=324-326
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000005 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=309-327
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000005 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=309-327

  // ===========================================================================
  // Branch Instructions
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000010 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=331-357
  wire rv32_beq      = rv32_branch & rv32_func3_000;
  wire rv32_bne      = rv32_branch & rv32_func3_001;
  wire rv32_blt      = rv32_branch & rv32_func3_100;
  wire rv32_bgt      = rv32_branch & rv32_func3_101;
  wire rv32_bltu     = rv32_branch & rv32_func3_110;
  wire rv32_bgtu     = rv32_branch & rv32_func3_111;

  // ===========================================================================
  // System Instructions
  wire rv32_ecall    = rv32_system & rv32_func3_000 & (rv32_instr[31:20] == 12'b0000_0000_0000);
  wire rv32_ebreak   = rv32_system & rv32_func3_000 & (rv32_instr[31:20] == 12'b0000_0000_0001);
  wire rv32_mret     = rv32_system & rv32_func3_000 & (rv32_instr[31:20] == 12'b0011_0000_0010);
  wire rv32_dret     = rv32_system & rv32_func3_000 & (rv32_instr[31:20] == 12'b0111_1011_0010);
  wire rv32_wfi      = rv32_system & rv32_func3_000 & (rv32_instr[31:20] == 12'b0001_0000_0101);
  // We dont implement the WFI and MRET illegal exception when the rs and rd is not zeros

  wire rv32_csrrw    = rv32_system & rv32_func3_001; 
  wire rv32_csrrs    = rv32_system & rv32_func3_010; 
  wire rv32_csrrc    = rv32_system & rv32_func3_011; 
  wire rv32_csrrwi   = rv32_system & rv32_func3_101; 
  wire rv32_csrrsi   = rv32_system & rv32_func3_110; 
  wire rv32_csrrci   = rv32_system & rv32_func3_111; 

  wire rv32_dret_ilgl = rv32_dret & (~dbg_mode);

  wire rv32_ecall_ebreak_ret_wfi = rv32_system & rv32_func3_000;
  wire rv32_csr          = rv32_system & (~rv32_func3_000);
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000010 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=331-357


  // ===========================================================================
    // The Branch and system group of instructions will be handled by BJP

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=363-366
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000006 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=363-363
  assign dec_jal     = rv32_jal    | rv16_jal  | rv16_j;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000006 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=363-363
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000007 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=364-364
  assign dec_jalr    = rv32_jalr   | rv16_jalr | rv16_jr;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000007 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=364-364
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000008 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=365-365
  assign dec_bxx     = rv32_branch | rv16_beqz | rv16_bnez;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000008 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=365-365
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000009 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=366-366
  assign dec_bjp     = dec_jal | dec_jalr | dec_bxx;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000009 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=366-366
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=363-366


//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000011 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=369-374
  wire rv32_fence  ;
  wire rv32_fence_i;
  wire rv32_fence_fencei;
  wire bjp_op = dec_bjp | rv32_mret | (rv32_dret & (~rv32_dret_ilgl)) | rv32_fence_fencei;

  wire [`E203_DECINFO_BJP_WIDTH-1:0] bjp_info_bus;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000011 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=369-374
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:assign_cluster:000004 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=375-389
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000010 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=375-375
  assign bjp_info_bus[`E203_DECINFO_GRP    ]    = `E203_DECINFO_GRP_BJP;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000010 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=375-375
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000011 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=376-376
  assign bjp_info_bus[`E203_DECINFO_RV32   ]    = rv32;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000011 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=376-376
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000012 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=377-377
  assign bjp_info_bus[`E203_DECINFO_BJP_JUMP ]  = dec_jal | dec_jalr;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000012 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=377-377
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000013 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=378-378
  assign bjp_info_bus[`E203_DECINFO_BJP_BPRDT]  = i_prdt_taken;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000013 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=378-378
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000014 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=379-379
  assign bjp_info_bus[`E203_DECINFO_BJP_BEQ  ]  = rv32_beq | rv16_beqz;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000014 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=379-379
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000015 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=380-380
  assign bjp_info_bus[`E203_DECINFO_BJP_BNE  ]  = rv32_bne | rv16_bnez;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000015 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=380-380
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000016 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=381-381
  assign bjp_info_bus[`E203_DECINFO_BJP_BLT  ]  = rv32_blt; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000016 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=381-381
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000017 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=382-382
  assign bjp_info_bus[`E203_DECINFO_BJP_BGT  ]  = rv32_bgt ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000017 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=382-382
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000018 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=383-383
  assign bjp_info_bus[`E203_DECINFO_BJP_BLTU ]  = rv32_bltu;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000018 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=383-383
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000019 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=384-384
  assign bjp_info_bus[`E203_DECINFO_BJP_BGTU ]  = rv32_bgtu;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000019 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=384-384
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000020 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=385-385
  assign bjp_info_bus[`E203_DECINFO_BJP_BXX  ]  = dec_bxx;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000020 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=385-385
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000021 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=386-386
  assign bjp_info_bus[`E203_DECINFO_BJP_MRET ]  = rv32_mret;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000021 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=386-386
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000022 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=387-387
  assign bjp_info_bus[`E203_DECINFO_BJP_DRET ]  = rv32_dret;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000022 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=387-387
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000023 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=388-388
  assign bjp_info_bus[`E203_DECINFO_BJP_FENCE ]  = rv32_fence;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000023 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=388-388
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000024 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=389-389
  assign bjp_info_bus[`E203_DECINFO_BJP_FENCEI]  = rv32_fence_i;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000024 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=389-389
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:assign_cluster:000004 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=375-389


  // ===========================================================================
  // ALU Instructions
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000012 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=394-423
  wire rv32_addi     = rv32_op_imm & rv32_func3_000;
  wire rv32_slti     = rv32_op_imm & rv32_func3_010;
  wire rv32_sltiu    = rv32_op_imm & rv32_func3_011;
  wire rv32_xori     = rv32_op_imm & rv32_func3_100;
  wire rv32_ori      = rv32_op_imm & rv32_func3_110;
  wire rv32_andi     = rv32_op_imm & rv32_func3_111;

  wire rv32_slli     = rv32_op_imm & rv32_func3_001 & (rv32_instr[31:26] == 6'b000000);
  wire rv32_srli     = rv32_op_imm & rv32_func3_101 & (rv32_instr[31:26] == 6'b000000);
  wire rv32_srai     = rv32_op_imm & rv32_func3_101 & (rv32_instr[31:26] == 6'b010000);

  wire rv32_sxxi_shamt_legl = (rv32_instr[25] == 1'b0); //shamt[5] must be zero for RV32I
  wire rv32_sxxi_shamt_ilgl =  (rv32_slli | rv32_srli | rv32_srai) & (~rv32_sxxi_shamt_legl);

  wire rv32_add      = rv32_op     & rv32_func3_000 & rv32_func7_0000000;
  wire rv32_sub      = rv32_op     & rv32_func3_000 & rv32_func7_0100000;
  wire rv32_sll      = rv32_op     & rv32_func3_001 & rv32_func7_0000000;
  wire rv32_slt      = rv32_op     & rv32_func3_010 & rv32_func7_0000000;
  wire rv32_sltu     = rv32_op     & rv32_func3_011 & rv32_func7_0000000;
  wire rv32_xor      = rv32_op     & rv32_func3_100 & rv32_func7_0000000;
  wire rv32_srl      = rv32_op     & rv32_func3_101 & rv32_func7_0000000;
  wire rv32_sra      = rv32_op     & rv32_func3_101 & rv32_func7_0100000;
  wire rv32_or       = rv32_op     & rv32_func3_110 & rv32_func7_0000000;
  wire rv32_and      = rv32_op     & rv32_func3_111 & rv32_func7_0000000;

  wire rv32_nop      = rv32_addi & rv32_rs1_x0 & rv32_rd_x0 & (~(|rv32_instr[31:20]));
  // The ALU group of instructions will be handled by 1cycle ALU-datapath
  wire ecall_ebreak = rv32_ecall | rv32_ebreak | rv16_ebreak;

  wire alu_op = (~rv32_sxxi_shamt_ilgl) & (~rv16_sxxi_shamt_ilgl) 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000012 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=394-423
              & (~rv16_li_lui_ilgl) & (~rv16_addi4spn_ilgl) & (~rv16_addi16sp_ilgl) & 
              ( rv32_op_imm 
              | rv32_op & (~rv32_func7_0000001) // Exclude the MULDIV
              | rv32_auipc
              | rv32_lui
              | rv16_addi4spn
              | rv16_addi         
              | rv16_lui_addi16sp 
              | rv16_li | rv16_mv
              | rv16_slli         
              | rv16_miscalu  
              | rv16_add
              | rv16_nop | rv32_nop
              | rv32_wfi // We just put WFI into ALU and do nothing in ALU
              | ecall_ebreak)
              ;
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000013 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=440-441
  wire need_imm;
  wire [`E203_DECINFO_ALU_WIDTH-1:0] alu_info_bus;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000013 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=440-441
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:assign_cluster:000005 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=442-464
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000025 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=442-442
  assign alu_info_bus[`E203_DECINFO_GRP    ]    = `E203_DECINFO_GRP_ALU;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000025 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=442-442
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000026 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=443-443
  assign alu_info_bus[`E203_DECINFO_RV32   ]    = rv32;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000026 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=443-443
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000027 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=444-448
  assign alu_info_bus[`E203_DECINFO_ALU_ADD]    = rv32_add  | rv32_addi | rv32_auipc |
                                                  rv16_addi4spn | rv16_addi | rv16_addi16sp | rv16_add |
                            // We also decode LI and MV as the add instruction, becuase
                            //   they all add x0 with a RS2 or Immeidate, and then write into RD
                                                  rv16_li | rv16_mv;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000027 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=444-448
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000028 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=449-449
  assign alu_info_bus[`E203_DECINFO_ALU_SUB]    = rv32_sub  | rv16_sub;      
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000028 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=449-449
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000029 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=450-450
  assign alu_info_bus[`E203_DECINFO_ALU_SLT]    = rv32_slt  | rv32_slti;     
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000029 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=450-450
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000030 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=451-451
  assign alu_info_bus[`E203_DECINFO_ALU_SLTU]   = rv32_sltu | rv32_sltiu;  
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000030 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=451-451
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000031 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=452-452
  assign alu_info_bus[`E203_DECINFO_ALU_XOR]    = rv32_xor  | rv32_xori | rv16_xor;    
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000031 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=452-452
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000032 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=453-453
  assign alu_info_bus[`E203_DECINFO_ALU_SLL]    = rv32_sll  | rv32_slli | rv16_slli;   
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000032 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=453-453
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000033 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=454-454
  assign alu_info_bus[`E203_DECINFO_ALU_SRL]    = rv32_srl  | rv32_srli | rv16_srli;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000033 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=454-454
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000034 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=455-455
  assign alu_info_bus[`E203_DECINFO_ALU_SRA]    = rv32_sra  | rv32_srai | rv16_srai;   
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000034 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=455-455
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000035 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=456-456
  assign alu_info_bus[`E203_DECINFO_ALU_OR ]    = rv32_or   | rv32_ori  | rv16_or;     
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000035 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=456-456
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000036 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=457-457
  assign alu_info_bus[`E203_DECINFO_ALU_AND]    = rv32_and  | rv32_andi | rv16_andi | rv16_and;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000036 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=457-457
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000037 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=458-458
  assign alu_info_bus[`E203_DECINFO_ALU_LUI]    = rv32_lui  | rv16_lui; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000037 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=458-458
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000038 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=459-459
  assign alu_info_bus[`E203_DECINFO_ALU_OP2IMM] = need_imm; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000038 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=459-459
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000039 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=460-460
  assign alu_info_bus[`E203_DECINFO_ALU_OP1PC ] = rv32_auipc;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000039 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=460-460
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000040 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=461-461
  assign alu_info_bus[`E203_DECINFO_ALU_NOP ]   = rv16_nop | rv32_nop;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000040 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=461-461
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000041 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=462-462
  assign alu_info_bus[`E203_DECINFO_ALU_ECAL ]  = rv32_ecall; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000041 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=462-462
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000042 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=463-463
  assign alu_info_bus[`E203_DECINFO_ALU_EBRK ]  = rv32_ebreak | rv16_ebreak;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000042 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=463-463
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000043 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=464-464
  assign alu_info_bus[`E203_DECINFO_ALU_WFI  ]  = rv32_wfi;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000043 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=464-464
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:assign_cluster:000005 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=442-464


  
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000014 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=468-469
  wire csr_op = rv32_csr;
  wire [`E203_DECINFO_CSR_WIDTH-1:0] csr_info_bus;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000014 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=468-469
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:assign_cluster:000006 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=470-478
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000044 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=470-470
  assign csr_info_bus[`E203_DECINFO_GRP    ]    = `E203_DECINFO_GRP_CSR;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000044 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=470-470
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000045 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=471-471
  assign csr_info_bus[`E203_DECINFO_RV32   ]    = rv32;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000045 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=471-471
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000046 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=472-472
  assign csr_info_bus[`E203_DECINFO_CSR_CSRRW ] = rv32_csrrw | rv32_csrrwi; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000046 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=472-472
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000047 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=473-473
  assign csr_info_bus[`E203_DECINFO_CSR_CSRRS ] = rv32_csrrs | rv32_csrrsi;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000047 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=473-473
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000048 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=474-474
  assign csr_info_bus[`E203_DECINFO_CSR_CSRRC ] = rv32_csrrc | rv32_csrrci;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000048 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=474-474
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000049 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=475-475
  assign csr_info_bus[`E203_DECINFO_CSR_RS1IMM] = rv32_csrrwi | rv32_csrrsi | rv32_csrrci;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000049 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=475-475
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000050 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=476-476
  assign csr_info_bus[`E203_DECINFO_CSR_ZIMMM ] = rv32_rs1;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000050 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=476-476
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000051 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=477-477
  assign csr_info_bus[`E203_DECINFO_CSR_RS1IS0] = rv32_rs1_x0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000051 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=477-477
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000052 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=478-478
  assign csr_info_bus[`E203_DECINFO_CSR_CSRIDX] = rv32_instr[31:20];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000052 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=478-478
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:assign_cluster:000006 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=470-478

  
  // ===========================================================================
  // Memory Order Instructions
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:assign_cluster:000007 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=483-486
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000053 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=483-483
  assign rv32_fence    = rv32_miscmem & rv32_func3_000;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000053 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=483-483
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000054 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=484-484
  assign rv32_fence_i  = rv32_miscmem & rv32_func3_001;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000054 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=484-484

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000055 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=486-486
  assign rv32_fence_fencei  = rv32_miscmem;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000055 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=486-486
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:assign_cluster:000007 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=483-486


  // ===========================================================================
  // MUL/DIV Instructions
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000015 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=491-508
  wire rv32_mul      = rv32_op     & rv32_func3_000 & rv32_func7_0000001;
  wire rv32_mulh     = rv32_op     & rv32_func3_001 & rv32_func7_0000001;
  wire rv32_mulhsu   = rv32_op     & rv32_func3_010 & rv32_func7_0000001;
  wire rv32_mulhu    = rv32_op     & rv32_func3_011 & rv32_func7_0000001;
  wire rv32_div      = rv32_op     & rv32_func3_100 & rv32_func7_0000001;
  wire rv32_divu     = rv32_op     & rv32_func3_101 & rv32_func7_0000001;
  wire rv32_rem      = rv32_op     & rv32_func3_110 & rv32_func7_0000001;
  wire rv32_remu     = rv32_op     & rv32_func3_111 & rv32_func7_0000001;
  
  // The MULDIV group of instructions will be handled by MUL-DIV-datapath
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000006 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=501-503
  `ifdef E203_SUPPORT_MULDIV//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000006 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=501-503
  wire muldiv_op = rv32_op & rv32_func7_0000001;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000006 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=501-503
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000006 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=501-503
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000007 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=504-506
  `ifndef E203_SUPPORT_MULDIV//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000007 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=504-506
  wire muldiv_op = 1'b0;
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000007 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=504-506
  `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000007 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=504-506

  wire [`E203_DECINFO_MULDIV_WIDTH-1:0] muldiv_info_bus;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000015 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=491-508
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:assign_cluster:000008 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=509-526
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000056 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=509-509
  assign muldiv_info_bus[`E203_DECINFO_GRP          ] = `E203_DECINFO_GRP_MULDIV;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000056 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=509-509
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000057 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=510-510
  assign muldiv_info_bus[`E203_DECINFO_RV32         ] = rv32        ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000057 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=510-510
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000058 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=511-511
  assign muldiv_info_bus[`E203_DECINFO_MULDIV_MUL   ] = rv32_mul    ;   
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000058 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=511-511
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000059 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=512-512
  assign muldiv_info_bus[`E203_DECINFO_MULDIV_MULH  ] = rv32_mulh   ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000059 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=512-512
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000060 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=513-513
  assign muldiv_info_bus[`E203_DECINFO_MULDIV_MULHSU] = rv32_mulhsu ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000060 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=513-513
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000061 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=514-514
  assign muldiv_info_bus[`E203_DECINFO_MULDIV_MULHU ] = rv32_mulhu  ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000061 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=514-514
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000062 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=515-515
  assign muldiv_info_bus[`E203_DECINFO_MULDIV_DIV   ] = rv32_div    ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000062 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=515-515
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000063 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=516-516
  assign muldiv_info_bus[`E203_DECINFO_MULDIV_DIVU  ] = rv32_divu   ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000063 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=516-516
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000064 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=517-517
  assign muldiv_info_bus[`E203_DECINFO_MULDIV_REM   ] = rv32_rem    ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000064 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=517-517
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000065 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=518-518
  assign muldiv_info_bus[`E203_DECINFO_MULDIV_REMU  ] = rv32_remu   ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000065 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=518-518
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000066 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=519-519
  assign muldiv_info_bus[`E203_DECINFO_MULDIV_B2B   ] = i_muldiv_b2b;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000066 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=519-519

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000067 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=521-521
  assign dec_mulhsu = rv32_mulh | rv32_mulhsu | rv32_mulhu;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000067 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=521-521
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000068 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=522-522
  assign dec_mul    = rv32_mul;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000068 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=522-522
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000069 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=523-523
  assign dec_div    = rv32_div ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000069 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=523-523
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000070 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=524-524
  assign dec_divu   = rv32_divu;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000070 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=524-524
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000071 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=525-525
  assign dec_rem    = rv32_rem;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000071 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=525-525
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000072 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=526-526
  assign dec_remu   = rv32_remu;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000072 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=526-526
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:assign_cluster:000008 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=509-526
 
  // ===========================================================================
  // Load/Store Instructions
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000016 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=530-578
  wire rv32_lb       = rv32_load   & rv32_func3_000;
  wire rv32_lh       = rv32_load   & rv32_func3_001;
  wire rv32_lw       = rv32_load   & rv32_func3_010;
  wire rv32_lbu      = rv32_load   & rv32_func3_100;
  wire rv32_lhu      = rv32_load   & rv32_func3_101;

  wire rv32_sb       = rv32_store  & rv32_func3_000;
  wire rv32_sh       = rv32_store  & rv32_func3_001;
  wire rv32_sw       = rv32_store  & rv32_func3_010;


  // ===========================================================================
  // Atomic Instructions
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000008 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=543-556
  `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000008 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=543-556
  wire rv32_lr_w      = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b00010);
  wire rv32_sc_w      = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b00011);
  wire rv32_amoswap_w = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b00001);
  wire rv32_amoadd_w  = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b00000);
  wire rv32_amoxor_w  = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b00100);
  wire rv32_amoand_w  = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b01100);
  wire rv32_amoor_w   = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b01000);
  wire rv32_amomin_w  = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b10000);
  wire rv32_amomax_w  = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b10100);
  wire rv32_amominu_w = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b11000);
  wire rv32_amomaxu_w = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b11100);

//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000008 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=543-556
  `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000008 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=543-556
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000009 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=557-570
  `ifndef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000009 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=557-570
  wire rv32_lr_w      = 1'b0;
  wire rv32_sc_w      = 1'b0;
  wire rv32_amoswap_w = 1'b0;
  wire rv32_amoadd_w  = 1'b0;
  wire rv32_amoxor_w  = 1'b0;
  wire rv32_amoand_w  = 1'b0;
  wire rv32_amoor_w   = 1'b0;
  wire rv32_amomin_w  = 1'b0;
  wire rv32_amomax_w  = 1'b0;
  wire rv32_amominu_w = 1'b0;
  wire rv32_amomaxu_w = 1'b0;

//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000009 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=557-570
  `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000009 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=557-570

  wire   amoldst_op = rv32_amo | rv32_load | rv32_store | rv16_lw | rv16_sw | (rv16_lwsp & (~rv16_lwsp_ilgl)) | rv16_swsp;
    // The RV16 always is word
  wire [1:0] lsu_info_size  = rv32 ? rv32_func3[1:0] : 2'b10;
    // The RV16 always is signed
  wire       lsu_info_usign = rv32? rv32_func3[2] : 1'b0;

  wire [`E203_DECINFO_AGU_WIDTH-1:0] agu_info_bus;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000016 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=530-578
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:assign_cluster:000009 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=579-596
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000073 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=579-579
  assign agu_info_bus[`E203_DECINFO_GRP    ] = `E203_DECINFO_GRP_AGU;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000073 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=579-579
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000074 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=580-580
  assign agu_info_bus[`E203_DECINFO_RV32   ] = rv32;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000074 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=580-580
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000075 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=581-581
  assign agu_info_bus[`E203_DECINFO_AGU_LOAD   ] = rv32_load  | rv32_lr_w | rv16_lw | rv16_lwsp;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000075 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=581-581
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000076 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=582-582
  assign agu_info_bus[`E203_DECINFO_AGU_STORE  ] = rv32_store | rv32_sc_w | rv16_sw | rv16_swsp;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000076 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=582-582
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000077 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=583-583
  assign agu_info_bus[`E203_DECINFO_AGU_SIZE   ] = lsu_info_size;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000077 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=583-583
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000078 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=584-584
  assign agu_info_bus[`E203_DECINFO_AGU_USIGN  ] = lsu_info_usign;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000078 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=584-584
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000079 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=585-585
  assign agu_info_bus[`E203_DECINFO_AGU_EXCL   ] = rv32_lr_w | rv32_sc_w;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000079 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=585-585
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000080 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=586-586
  assign agu_info_bus[`E203_DECINFO_AGU_AMO    ] = rv32_amo & (~(rv32_lr_w | rv32_sc_w));// We seperated the EXCL out of AMO in LSU handling
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000080 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=586-586
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000081 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=587-587
  assign agu_info_bus[`E203_DECINFO_AGU_AMOSWAP] = rv32_amoswap_w;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000081 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=587-587
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000082 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=588-588
  assign agu_info_bus[`E203_DECINFO_AGU_AMOADD ] = rv32_amoadd_w ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000082 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=588-588
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000083 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=589-589
  assign agu_info_bus[`E203_DECINFO_AGU_AMOAND ] = rv32_amoand_w ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000083 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=589-589
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000084 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=590-590
  assign agu_info_bus[`E203_DECINFO_AGU_AMOOR  ] = rv32_amoor_w ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000084 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=590-590
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000085 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=591-591
  assign agu_info_bus[`E203_DECINFO_AGU_AMOXOR ] = rv32_amoxor_w  ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000085 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=591-591
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000086 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=592-592
  assign agu_info_bus[`E203_DECINFO_AGU_AMOMAX ] = rv32_amomax_w ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000086 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=592-592
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000087 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=593-593
  assign agu_info_bus[`E203_DECINFO_AGU_AMOMIN ] = rv32_amomin_w ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000087 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=593-593
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000088 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=594-594
  assign agu_info_bus[`E203_DECINFO_AGU_AMOMAXU] = rv32_amomaxu_w;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000088 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=594-594
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000089 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=595-595
  assign agu_info_bus[`E203_DECINFO_AGU_AMOMINU] = rv32_amominu_w;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000089 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=595-595
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000090 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=596-596
  assign agu_info_bus[`E203_DECINFO_AGU_OP2IMM ] = need_imm; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000090 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=596-596
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:assign_cluster:000009 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=579-596




  // Reuse the common signals as much as possible to save gatecounts
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000017 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=602-602
  wire rv32_all0s_ilgl  = rv32_func7_0000000 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000017 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=602-602
                        & rv32_rs2_x0 
                        & rv32_rs1_x0 
                        & rv32_func3_000 
                        & rv32_rd_x0 
                        & opcode_6_5_00 
                        & opcode_4_2_000 
                        & (opcode[1:0] == 2'b00); 

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000018 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=611-611
  wire rv32_all1s_ilgl  = rv32_func7_1111111 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000018 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=611-611
                        & rv32_rs2_x31 
                        & rv32_rs1_x31 
                        & rv32_func3_111 
                        & rv32_rd_x31 
                        & opcode_6_5_11 
                        & opcode_4_2_111 
                        & (opcode[1:0] == 2'b11); 

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000019 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=620-620
  wire rv16_all0s_ilgl  = rv16_func3_000 //rv16_func3  = rv32_instr[15:13];
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000019 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=620-620
                        & rv32_func3_000 //rv32_func3  = rv32_instr[14:12];
                        & rv32_rd_x0     //rv32_rd     = rv32_instr[11:7];
                        & opcode_6_5_00 
                        & opcode_4_2_000 
                        & (opcode[1:0] == 2'b00); 

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000020 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=627-627
  wire rv16_all1s_ilgl  = rv16_func3_111
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000020 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=627-627
                        & rv32_func3_111 
                        & rv32_rd_x31 
                        & opcode_6_5_11 
                        & opcode_4_2_111 
                        & (opcode[1:0] == 2'b11);
  
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000021 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=634-634
  wire rv_all0s1s_ilgl = rv32 ?  (rv32_all0s_ilgl | rv32_all1s_ilgl)
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000021 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=634-634
                              :  (rv16_all0s_ilgl | rv16_all1s_ilgl);

  //
  // All the RV32IMA need RD register except the
  //   * Branch, Store,
  //   * fence, fence_i 
  //   * ecall, ebreak  
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000022 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=642-642
  wire rv32_need_rd = 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000022 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=642-642
                      (~rv32_rd_x0) & (
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000010 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=644-646
                      `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000010 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=644-646
                      nice_op ? nice_need_rd :
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000010 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=644-646
                      `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000010 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=644-646
                    (
                      (~rv32_branch) & (~rv32_store)
                    & (~rv32_fence_fencei)
                    & (~rv32_ecall_ebreak_ret_wfi) 
                    )
                   );

  // All the RV32IMA need RS1 register except the
  //   * lui
  //   * auipc
  //   * jal
  //   * fence, fence_i 
  //   * ecall, ebreak  
  //   * csrrwi
  //   * csrrsi
  //   * csrrci
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000023 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=663-663
  wire rv32_need_rs1 =
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000023 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=663-663
                      (~rv32_rs1_x0) & (
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000011 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=665-667
                      `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000011 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=665-667
                      nice_op ? nice_need_rs1 :
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000011 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=665-667
                      `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000011 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=665-667
                    (
                      (~rv32_lui)
                    & (~rv32_auipc)
                    & (~rv32_jal)
                    & (~rv32_fence_fencei)
                    & (~rv32_ecall_ebreak_ret_wfi)
                    & (~rv32_csrrwi)
                    & (~rv32_csrrsi)
                    & (~rv32_csrrci)
                    )
                  );
                    
  // Following RV32IMA instructions need RS2 register
  //   * branch
  //   * store
  //   * rv32_op
  //   * rv32_amo except the rv32_lr_w
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000024 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=685-686
  wire rv32_need_rs2 = (~rv32_rs2_x0) & (
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000012 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=686-688
                 `ifdef E203_HAS_NICE//{
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000024 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=685-686
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000012 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=686-688
                 nice_op ? nice_need_rs2 :
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000012 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=686-688
                 `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000012 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=686-688
                (
                 (rv32_branch)
               | (rv32_store)
               | (rv32_op)
               | (rv32_amo & (~rv32_lr_w))
                 )
                 );

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000025 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=697-697
  wire [31:0]  rv32_i_imm = { 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000025 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=697-697
                               {20{rv32_instr[31]}} 
                              , rv32_instr[31:20]
                             };

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000026 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=702-702
  wire [31:0]  rv32_s_imm = {
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000026 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=702-702
                               {20{rv32_instr[31]}} 
                              , rv32_instr[31:25] 
                              , rv32_instr[11:7]
                             };


//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000027 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=709-709
  wire [31:0]  rv32_b_imm = {
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000027 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=709-709
                               {19{rv32_instr[31]}} 
                              , rv32_instr[31] 
                              , rv32_instr[7] 
                              , rv32_instr[30:25] 
                              , rv32_instr[11:8]
                              , 1'b0
                              };

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000028 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=718-720
  wire [31:0]  rv32_u_imm = {rv32_instr[31:12],12'b0};

  wire [31:0]  rv32_j_imm = {
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000028 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=718-720
                               {11{rv32_instr[31]}} 
                              , rv32_instr[31] 
                              , rv32_instr[19:12] 
                              , rv32_instr[20] 
                              , rv32_instr[30:21]
                              , 1'b0
                              };

                   // It will select i-type immediate when
                   //    * rv32_op_imm
                   //    * rv32_jalr
                   //    * rv32_load
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000029 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=733-766
  wire rv32_imm_sel_i = rv32_op_imm | rv32_jalr | rv32_load;
  wire rv32_imm_sel_jalr = rv32_jalr;
  wire [31:0]  rv32_jalr_imm = rv32_i_imm;

                   // It will select u-type immediate when
                   //    * rv32_lui, rv32_auipc 
  wire rv32_imm_sel_u = rv32_lui | rv32_auipc;

                   // It will select j-type immediate when
                   //    * rv32_jal
  wire rv32_imm_sel_j = rv32_jal;
  wire rv32_imm_sel_jal = rv32_jal;
  wire [31:0]  rv32_jal_imm = rv32_j_imm;

                   // It will select b-type immediate when
                   //    * rv32_branch
  wire rv32_imm_sel_b = rv32_branch;
  wire rv32_imm_sel_bxx = rv32_branch;
  wire [31:0]  rv32_bxx_imm = rv32_b_imm;
                   
                   // It will select s-type immediate when
                   //    * rv32_store
  wire rv32_imm_sel_s = rv32_store;



  //   * Note: this CIS/CILI/CILUI/CI16SP-type is named by myself, because in 
  //           ISA doc, the CI format for LWSP is different
  //           with other CI formats in terms of immediate
  
                   // It will select CIS-type immediate when
                   //    * rv16_lwsp
  wire rv16_imm_sel_cis = rv16_lwsp;
  wire [31:0]  rv16_cis_imm ={
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000029 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=733-766
                          24'b0
                        , rv16_instr[3:2]
                        , rv16_instr[12]
                        , rv16_instr[6:4]
                        , 2'b0
                         };
                   
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000030 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=774-774
  wire [31:0]  rv16_cis_d_imm ={
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000030 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=774-774
                          23'b0
                        , rv16_instr[4:2]
                        , rv16_instr[12]
                        , rv16_instr[6:5]
                        , 3'b0
                         };
                   // It will select CILI-type immediate when
                   //    * rv16_li
                   //    * rv16_addi
                   //    * rv16_slli
                   //    * rv16_srai
                   //    * rv16_srli
                   //    * rv16_andi
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000031 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=788-788
  wire rv16_imm_sel_cili = rv16_li | rv16_addi | rv16_slli
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000031 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=788-788
                   | rv16_srai | rv16_srli | rv16_andi;
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000032 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=790-790
  wire [31:0]  rv16_cili_imm ={
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000032 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=790-790
                          {26{rv16_instr[12]}}
                        , rv16_instr[12]
                        , rv16_instr[6:2]
                         };
                   
                   // It will select CILUI-type immediate when
                   //    * rv16_lui
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000033 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=798-799
  wire rv16_imm_sel_cilui = rv16_lui;
  wire [31:0]  rv16_cilui_imm ={
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000033 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=798-799
                          {14{rv16_instr[12]}}
                        , rv16_instr[12]
                        , rv16_instr[6:2]
                        , 12'b0
                         };
                   
                   // It will select CI16SP-type immediate when
                   //    * rv16_addi16sp
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000034 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=808-809
  wire rv16_imm_sel_ci16sp = rv16_addi16sp;
  wire [31:0]  rv16_ci16sp_imm ={
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000034 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=808-809
                          {22{rv16_instr[12]}}
                        , rv16_instr[12]
                        , rv16_instr[4]
                        , rv16_instr[3]
                        , rv16_instr[5]
                        , rv16_instr[2]
                        , rv16_instr[6]
                        , 4'b0
                         };
                   
                   // It will select CSS-type immediate when
                   //    * rv16_swsp
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000035 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=822-823
  wire rv16_imm_sel_css = rv16_swsp;
  wire [31:0]  rv16_css_imm ={
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000035 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=822-823
                          24'b0
                        , rv16_instr[8:7]
                        , rv16_instr[12:9]
                        , 2'b0
                         };
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000036 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=829-829
  wire [31:0]  rv16_css_d_imm ={
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000036 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=829-829
                          23'b0
                        , rv16_instr[9:7]
                        , rv16_instr[12:10]
                        , 3'b0
                         };
                   // It will select CIW-type immediate when
                   //    * rv16_addi4spn
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000037 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=837-838
  wire rv16_imm_sel_ciw = rv16_addi4spn;
  wire [31:0]  rv16_ciw_imm ={
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000037 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=837-838
                          22'b0
                        , rv16_instr[10:7]
                        , rv16_instr[12]
                        , rv16_instr[11]
                        , rv16_instr[5]
                        , rv16_instr[6]
                        , 2'b0
                         };

                   // It will select CL-type immediate when
                   //    * rv16_lw
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000038 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=850-851
  wire rv16_imm_sel_cl = rv16_lw;
  wire [31:0]  rv16_cl_imm ={
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000038 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=850-851
                          25'b0
                        , rv16_instr[5]
                        , rv16_instr[12]
                        , rv16_instr[11]
                        , rv16_instr[10]
                        , rv16_instr[6]
                        , 2'b0
                         };
                   
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000039 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=861-861
  wire [31:0]  rv16_cl_d_imm ={
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000039 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=861-861
                          24'b0
                        , rv16_instr[6]
                        , rv16_instr[5]
                        , rv16_instr[12]
                        , rv16_instr[11]
                        , rv16_instr[10]
                        , 3'b0
                         };
                   // It will select CS-type immediate when
                   //    * rv16_sw
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000040 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=872-873
  wire rv16_imm_sel_cs = rv16_sw;
  wire [31:0]  rv16_cs_imm ={
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000040 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=872-873
                          25'b0
                        , rv16_instr[5]
                        , rv16_instr[12]
                        , rv16_instr[11]
                        , rv16_instr[10]
                        , rv16_instr[6]
                        , 2'b0
                         };
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000041 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=882-882
   wire [31:0]  rv16_cs_d_imm ={
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000041 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=882-882
                          24'b0
                        , rv16_instr[6]
                        , rv16_instr[5]
                        , rv16_instr[12]
                        , rv16_instr[11]
                        , rv16_instr[10]
                        , 3'b0
                         };

                   // It will select CB-type immediate when
                   //    * rv16_beqz
                   //    * rv16_bnez
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000042 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=895-896
  wire rv16_imm_sel_cb = rv16_beqz | rv16_bnez;
  wire [31:0]  rv16_cb_imm ={
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000042 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=895-896
                          {23{rv16_instr[12]}}
                        , rv16_instr[12]
                        , rv16_instr[6:5]
                        , rv16_instr[2]
                        , rv16_instr[11:10]
                        , rv16_instr[4:3]
                        , 1'b0
                         };
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000043 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=905-911
  wire [31:0]  rv16_bxx_imm = rv16_cb_imm;

                   // It will select CJ-type immediate when
                   //    * rv16_j
                   //    * rv16_jal
  wire rv16_imm_sel_cj = rv16_j | rv16_jal;
  wire [31:0]  rv16_cj_imm ={
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000043 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=905-911
                          {20{rv16_instr[12]}}
                        , rv16_instr[12]
                        , rv16_instr[8]
                        , rv16_instr[10:9]
                        , rv16_instr[6]
                        , rv16_instr[7]
                        , rv16_instr[2]
                        , rv16_instr[11]
                        , rv16_instr[5:3]
                        , 1'b0
                         };
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000044 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=923-935
  wire [31:0]  rv16_jjal_imm = rv16_cj_imm;

                   // It will select CR-type register (no-imm) when
                   //    * rv16_jalr_mv_add
  wire [31:0]  rv16_jrjalr_imm = 32'b0;
                   
                   // It will select CSR-type register (no-imm) when
                   //    * rv16_subxororand

                   
  wire [31:0]  rv32_load_fp_imm  = rv32_i_imm;
  wire [31:0]  rv32_store_fp_imm = rv32_s_imm;
  wire [31:0]  rv32_imm = 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000044 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=923-935
                     ({32{rv32_imm_sel_i}} & rv32_i_imm)
                   | ({32{rv32_imm_sel_s}} & rv32_s_imm)
                   | ({32{rv32_imm_sel_b}} & rv32_b_imm)
                   | ({32{rv32_imm_sel_u}} & rv32_u_imm)
                   | ({32{rv32_imm_sel_j}} & rv32_j_imm)
                   ;
                   
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000045 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=943-943
  wire  rv32_need_imm = 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000045 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=943-943
                     rv32_imm_sel_i
                   | rv32_imm_sel_s
                   | rv32_imm_sel_b
                   | rv32_imm_sel_u
                   | rv32_imm_sel_j
                   ;

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000046 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=951-951
  wire [31:0]  rv16_imm = 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000046 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=951-951
                     ({32{rv16_imm_sel_cis   }} & rv16_cis_imm)
                   | ({32{rv16_imm_sel_cili  }} & rv16_cili_imm)
                   | ({32{rv16_imm_sel_cilui }} & rv16_cilui_imm)
                   | ({32{rv16_imm_sel_ci16sp}} & rv16_ci16sp_imm)
                   | ({32{rv16_imm_sel_css   }} & rv16_css_imm)
                   | ({32{rv16_imm_sel_ciw   }} & rv16_ciw_imm)
                   | ({32{rv16_imm_sel_cl    }} & rv16_cl_imm)
                   | ({32{rv16_imm_sel_cs    }} & rv16_cs_imm)
                   | ({32{rv16_imm_sel_cb    }} & rv16_cb_imm)
                   | ({32{rv16_imm_sel_cj    }} & rv16_cj_imm)
                   ;

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000047 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=964-964
  wire rv16_need_imm = 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000047 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=964-964
                     rv16_imm_sel_cis   
                   | rv16_imm_sel_cili  
                   | rv16_imm_sel_cilui 
                   | rv16_imm_sel_ci16sp
                   | rv16_imm_sel_css   
                   | rv16_imm_sel_ciw   
                   | rv16_imm_sel_cl    
                   | rv16_imm_sel_cs    
                   | rv16_imm_sel_cb    
                   | rv16_imm_sel_cj    
                   ;


//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:assign_cluster:000010 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=978-994
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000091 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=978-978
  assign need_imm = rv32 ? rv32_need_imm : rv16_need_imm; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000091 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=978-978

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000092 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=980-980
  assign dec_imm = rv32 ? rv32_imm : rv16_imm;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000092 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=980-980
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000093 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=981-981
  assign dec_pc  = i_pc;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000093 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=981-981

  

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000094 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=985-994
  assign dec_info = 
              ({`E203_DECINFO_WIDTH{alu_op}}     & {{`E203_DECINFO_WIDTH-`E203_DECINFO_ALU_WIDTH{1'b0}},alu_info_bus})
            | ({`E203_DECINFO_WIDTH{amoldst_op}} & {{`E203_DECINFO_WIDTH-`E203_DECINFO_AGU_WIDTH{1'b0}},agu_info_bus})
            | ({`E203_DECINFO_WIDTH{bjp_op}}     & {{`E203_DECINFO_WIDTH-`E203_DECINFO_BJP_WIDTH{1'b0}},bjp_info_bus})
            | ({`E203_DECINFO_WIDTH{csr_op}}     & {{`E203_DECINFO_WIDTH-`E203_DECINFO_CSR_WIDTH{1'b0}},csr_info_bus})
            | ({`E203_DECINFO_WIDTH{muldiv_op}}  & {{`E203_DECINFO_WIDTH-`E203_DECINFO_MULDIV_WIDTH{1'b0}},muldiv_info_bus})
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000013 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=991-993
           `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000013 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=991-993
            | ({`E203_DECINFO_WIDTH{nice_op}}     & {{`E203_DECINFO_WIDTH-`E203_DECINFO_NICE_WIDTH{1'b0}},nice_info_bus})
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000013 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=991-993
           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000013 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=991-993
              ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000094 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=985-994
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:assign_cluster:000010 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=978-994


//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000048 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=997-997
  wire legl_ops = 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000048 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=997-997
              alu_op
            | amoldst_op
            | bjp_op
            | csr_op
            | muldiv_op
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000014 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1003-1005
           `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000014 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1003-1005
            | nice_op
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000014 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1003-1005
           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000014 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1003-1005
            ;

  // To decode the registers for Rv16, divided into 8 groups
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000049 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1009-1031
  wire rv16_format_cr  = rv16_jalr_mv_add;
  wire rv16_format_ci  = rv16_lwsp | rv16_flwsp | rv16_fldsp | rv16_li | rv16_lui_addi16sp | rv16_addi | rv16_slli; 
  wire rv16_format_css = rv16_swsp | rv16_fswsp | rv16_fsdsp; 
  wire rv16_format_ciw = rv16_addi4spn; 
  wire rv16_format_cl  = rv16_lw | rv16_flw | rv16_fld; 
  wire rv16_format_cs  = rv16_sw | rv16_fsw | rv16_fsd | rv16_subxororand; 
  wire rv16_format_cb  = rv16_beqz | rv16_bnez | rv16_srli | rv16_srai | rv16_andi; 
  wire rv16_format_cj  = rv16_j | rv16_jal; 


  // In CR Cases:
  //   * JR:     rs1= rs1(coded),     rs2= x0 (coded),   rd = x0 (implicit)
  //   * JALR:   rs1= rs1(coded),     rs2= x0 (coded),   rd = x1 (implicit)
  //   * MV:     rs1= x0 (implicit),  rs2= rs2(coded),   rd = rd (coded)
  //   * ADD:    rs1= rs1(coded),     rs2= rs2(coded),   rd = rd (coded)
  //   * eBreak: rs1= rs1(coded),     rs2= x0 (coded),   rd = x0 (coded)
  wire rv16_need_cr_rs1   = rv16_format_cr & 1'b1;
  wire rv16_need_cr_rs2   = rv16_format_cr & 1'b1;
  wire rv16_need_cr_rd    = rv16_format_cr & 1'b1;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_cr_rs1 = rv16_mv ? `E203_RFIDX_WIDTH'd0 : rv16_rs1[`E203_RFIDX_WIDTH-1:0];
  wire [`E203_RFIDX_WIDTH-1:0] rv16_cr_rs2 = rv16_rs2[`E203_RFIDX_WIDTH-1:0];
     // The JALR and JR difference in encoding is just the rv16_instr[12]
  wire [`E203_RFIDX_WIDTH-1:0] rv16_cr_rd  = (rv16_jalr | rv16_jr)? 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000049 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1009-1031
                 {{`E203_RFIDX_WIDTH-1{1'b0}},rv16_instr[12]} : rv16_rd[`E203_RFIDX_WIDTH-1:0];
                         
  // In CI Cases:
  //   * LWSP:     rs1= x2 (implicit),  rd = rd 
  //   * LI/LUI:   rs1= x0 (implicit),  rd = rd
  //   * ADDI:     rs1= rs1(implicit),  rd = rd
  //   * ADDI16SP: rs1= rs1(implicit),  rd = rd
  //   * SLLI:     rs1= rs1(implicit),  rd = rd
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000050 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1040-1043
  wire rv16_need_ci_rs1   = rv16_format_ci & 1'b1;
  wire rv16_need_ci_rs2   = rv16_format_ci & 1'b0;
  wire rv16_need_ci_rd    = rv16_format_ci & 1'b1;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_ci_rs1 = (rv16_lwsp | rv16_flwsp | rv16_fldsp) ? `E203_RFIDX_WIDTH'd2 :
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000050 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1040-1043
                                  (rv16_li | rv16_lui) ? `E203_RFIDX_WIDTH'd0 : rv16_rs1[`E203_RFIDX_WIDTH-1:0];
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000051 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1045-1127
  wire [`E203_RFIDX_WIDTH-1:0] rv16_ci_rs2 = `E203_RFIDX_WIDTH'd0;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_ci_rd  = rv16_rd[`E203_RFIDX_WIDTH-1:0];
                        
  // In CSS Cases:
  //   * SWSP:     rs1 = x2 (implicit), rs2= rs2 
  wire rv16_need_css_rs1  = rv16_format_css & 1'b1;
  wire rv16_need_css_rs2  = rv16_format_css & 1'b1;
  wire rv16_need_css_rd   = rv16_format_css & 1'b0;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_css_rs1 = `E203_RFIDX_WIDTH'd2;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_css_rs2 = rv16_rs2[`E203_RFIDX_WIDTH-1:0];
  wire [`E203_RFIDX_WIDTH-1:0] rv16_css_rd  = `E203_RFIDX_WIDTH'd0;
                       
  // In CIW cases:
  //   * ADDI4SPN:   rdd = rdd, rss1= x2 (implicit)
  wire rv16_need_ciw_rss1 = rv16_format_ciw & 1'b1;
  wire rv16_need_ciw_rss2 = rv16_format_ciw & 1'b0;
  wire rv16_need_ciw_rdd  = rv16_format_ciw & 1'b1;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_ciw_rss1  = `E203_RFIDX_WIDTH'd2;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_ciw_rss2  = `E203_RFIDX_WIDTH'd0;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_ciw_rdd  = rv16_rdd[`E203_RFIDX_WIDTH-1:0];
                      
  // In CL cases:
  //   * LW:   rss1 = rss1, rdd= rdd
  wire rv16_need_cl_rss1  = rv16_format_cl & 1'b1;
  wire rv16_need_cl_rss2  = rv16_format_cl & 1'b0;
  wire rv16_need_cl_rdd   = rv16_format_cl & 1'b1;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_cl_rss1 = rv16_rss1[`E203_RFIDX_WIDTH-1:0];
  wire [`E203_RFIDX_WIDTH-1:0] rv16_cl_rss2 = `E203_RFIDX_WIDTH'd0;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_cl_rdd  = rv16_rdd[`E203_RFIDX_WIDTH-1:0];
                     
  // In CS cases:
  //   * SW:            rdd = none(implicit), rss1= rss1       , rss2=rss2
  //   * SUBXORORAND:   rdd = rss1,           rss1= rss1(coded), rss2=rss2
  wire rv16_need_cs_rss1  = rv16_format_cs & 1'b1;
  wire rv16_need_cs_rss2  = rv16_format_cs & 1'b1;
  wire rv16_need_cs_rdd   = rv16_format_cs & rv16_subxororand;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_cs_rss1 = rv16_rss1[`E203_RFIDX_WIDTH-1:0];
  wire [`E203_RFIDX_WIDTH-1:0] rv16_cs_rss2 = rv16_rss2[`E203_RFIDX_WIDTH-1:0];
  wire [`E203_RFIDX_WIDTH-1:0] rv16_cs_rdd  = rv16_rss1[`E203_RFIDX_WIDTH-1:0];
                    
  // In CB cases:
  //   * BEQ/BNE:            rdd = none(implicit), rss1= rss1, rss2=x0(implicit)
  //   * SRLI/SRAI/ANDI:     rdd = rss1          , rss1= rss1, rss2=none(implicit)
  wire rv16_need_cb_rss1  = rv16_format_cb & 1'b1;
  wire rv16_need_cb_rss2  = rv16_format_cb & (rv16_beqz | rv16_bnez);
  wire rv16_need_cb_rdd   = rv16_format_cb & (~(rv16_beqz | rv16_bnez));
  wire [`E203_RFIDX_WIDTH-1:0] rv16_cb_rss1 = rv16_rss1[`E203_RFIDX_WIDTH-1:0];
  wire [`E203_RFIDX_WIDTH-1:0] rv16_cb_rss2 = `E203_RFIDX_WIDTH'd0;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_cb_rdd  = rv16_rss1[`E203_RFIDX_WIDTH-1:0];
  
  // In CJ cases:
  //   * J:            rdd = x0(implicit)
  //   * JAL:          rdd = x1(implicit)
  wire rv16_need_cj_rss1  = rv16_format_cj & 1'b0;
  wire rv16_need_cj_rss2  = rv16_format_cj & 1'b0;
  wire rv16_need_cj_rdd   = rv16_format_cj & 1'b1;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_cj_rss1 = `E203_RFIDX_WIDTH'd0;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_cj_rss2 = `E203_RFIDX_WIDTH'd0;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_cj_rdd  = rv16_j ? `E203_RFIDX_WIDTH'd0 : `E203_RFIDX_WIDTH'd1;

  // rv16_format_cr  
  // rv16_format_ci  
  // rv16_format_css 
  // rv16_format_ciw 
  // rv16_format_cl  
  // rv16_format_cs  
  // rv16_format_cb  
  // rv16_format_cj  
  wire rv16_need_rs1 = rv16_need_cr_rs1 | rv16_need_ci_rs1 | rv16_need_css_rs1;
  wire rv16_need_rs2 = rv16_need_cr_rs2 | rv16_need_ci_rs2 | rv16_need_css_rs2;
  wire rv16_need_rd  = rv16_need_cr_rd  | rv16_need_ci_rd  | rv16_need_css_rd;

  wire rv16_need_rss1 = rv16_need_ciw_rss1|rv16_need_cl_rss1|rv16_need_cs_rss1|rv16_need_cb_rss1|rv16_need_cj_rss1;
  wire rv16_need_rss2 = rv16_need_ciw_rss2|rv16_need_cl_rss2|rv16_need_cs_rss2|rv16_need_cb_rss2|rv16_need_cj_rss2;
  wire rv16_need_rdd  = rv16_need_ciw_rdd |rv16_need_cl_rdd |rv16_need_cs_rdd |rv16_need_cb_rdd |rv16_need_cj_rdd ;

  wire rv16_rs1en = (rv16_need_rs1 | rv16_need_rss1);
  wire rv16_rs2en = (rv16_need_rs2 | rv16_need_rss2);
  wire rv16_rden  = (rv16_need_rd  | rv16_need_rdd );

  wire [`E203_RFIDX_WIDTH-1:0] rv16_rs1idx;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_rs2idx;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_rdidx ;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000051 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1045-1127

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:assign_cluster:000011 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1129-1172
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000095 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1129-1138
  assign rv16_rs1idx = 
         ({`E203_RFIDX_WIDTH{rv16_need_cr_rs1 }} & rv16_cr_rs1)
       | ({`E203_RFIDX_WIDTH{rv16_need_ci_rs1 }} & rv16_ci_rs1)
       | ({`E203_RFIDX_WIDTH{rv16_need_css_rs1}} & rv16_css_rs1)
       | ({`E203_RFIDX_WIDTH{rv16_need_ciw_rss1}} & rv16_ciw_rss1)
       | ({`E203_RFIDX_WIDTH{rv16_need_cl_rss1}}  & rv16_cl_rss1)
       | ({`E203_RFIDX_WIDTH{rv16_need_cs_rss1}}  & rv16_cs_rss1)
       | ({`E203_RFIDX_WIDTH{rv16_need_cb_rss1}}  & rv16_cb_rss1)
       | ({`E203_RFIDX_WIDTH{rv16_need_cj_rss1}}  & rv16_cj_rss1)
       ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000095 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1129-1138

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000096 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1140-1149
  assign rv16_rs2idx = 
         ({`E203_RFIDX_WIDTH{rv16_need_cr_rs2 }} & rv16_cr_rs2)
       | ({`E203_RFIDX_WIDTH{rv16_need_ci_rs2 }} & rv16_ci_rs2)
       | ({`E203_RFIDX_WIDTH{rv16_need_css_rs2}} & rv16_css_rs2)
       | ({`E203_RFIDX_WIDTH{rv16_need_ciw_rss2}} & rv16_ciw_rss2)
       | ({`E203_RFIDX_WIDTH{rv16_need_cl_rss2}}  & rv16_cl_rss2)
       | ({`E203_RFIDX_WIDTH{rv16_need_cs_rss2}}  & rv16_cs_rss2)
       | ({`E203_RFIDX_WIDTH{rv16_need_cb_rss2}}  & rv16_cb_rss2)
       | ({`E203_RFIDX_WIDTH{rv16_need_cj_rss2}}  & rv16_cj_rss2)
       ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000096 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1140-1149

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000097 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1151-1160
  assign rv16_rdidx = 
         ({`E203_RFIDX_WIDTH{rv16_need_cr_rd }} & rv16_cr_rd)
       | ({`E203_RFIDX_WIDTH{rv16_need_ci_rd }} & rv16_ci_rd)
       | ({`E203_RFIDX_WIDTH{rv16_need_css_rd}} & rv16_css_rd)
       | ({`E203_RFIDX_WIDTH{rv16_need_ciw_rdd}} & rv16_ciw_rdd)
       | ({`E203_RFIDX_WIDTH{rv16_need_cl_rdd}}  & rv16_cl_rdd)
       | ({`E203_RFIDX_WIDTH{rv16_need_cs_rdd}}  & rv16_cs_rdd)
       | ({`E203_RFIDX_WIDTH{rv16_need_cb_rdd}}  & rv16_cb_rdd)
       | ({`E203_RFIDX_WIDTH{rv16_need_cj_rdd}}  & rv16_cj_rdd)
       ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000097 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1151-1160

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000098 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1162-1162
  assign dec_rs1idx = rv32 ? rv32_rs1[`E203_RFIDX_WIDTH-1:0] : rv16_rs1idx;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000098 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1162-1162
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000099 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1163-1163
  assign dec_rs2idx = rv32 ? rv32_rs2[`E203_RFIDX_WIDTH-1:0] : rv16_rs2idx;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000099 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1163-1163
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000100 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1164-1164
  assign dec_rdidx  = rv32 ? rv32_rd [`E203_RFIDX_WIDTH-1:0] : rv16_rdidx ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000100 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1164-1164


//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000101 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1167-1167
  assign dec_rs1en = rv32 ? rv32_need_rs1 : (rv16_rs1en & (~(rv16_rs1idx == `E203_RFIDX_WIDTH'b0))); 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000101 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1167-1167
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000102 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1168-1168
  assign dec_rs2en = rv32 ? rv32_need_rs2 : (rv16_rs2en & (~(rv16_rs2idx == `E203_RFIDX_WIDTH'b0)));
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000102 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1168-1168
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000103 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1169-1169
  assign dec_rdwen = rv32 ? rv32_need_rd  : (rv16_rden  & (~(rv16_rdidx  == `E203_RFIDX_WIDTH'b0)));
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000103 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1169-1169

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000104 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1171-1171
  assign dec_rs1x0 = (dec_rs1idx == `E203_RFIDX_WIDTH'b0);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000104 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1171-1171
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000105 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1172-1172
  assign dec_rs2x0 = (dec_rs2idx == `E203_RFIDX_WIDTH'b0);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000105 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1172-1172
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:assign_cluster:000011 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1129-1172
                     
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000052 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1174-1175
  wire rv_index_ilgl;
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000015 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1175-1181
  `ifdef E203_RFREG_NUM_IS_4 //{ 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:internal_signal:000052 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1174-1175
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000015 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1175-1181
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000106 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1176-1180
  assign rv_index_ilgl =
                 (| dec_rs1idx[`E203_RFIDX_WIDTH-1:2])
                |(| dec_rs2idx[`E203_RFIDX_WIDTH-1:2])
                |(| dec_rdidx [`E203_RFIDX_WIDTH-1:2])
                ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000106 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1176-1180
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000015 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1175-1181
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000015 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1175-1181
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000016 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1182-1188
  `ifdef E203_RFREG_NUM_IS_8 //{ 
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000016 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1182-1188
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000107 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1183-1187
  assign rv_index_ilgl =
                 (| dec_rs1idx[`E203_RFIDX_WIDTH-1:3])
                |(| dec_rs2idx[`E203_RFIDX_WIDTH-1:3])
                |(| dec_rdidx [`E203_RFIDX_WIDTH-1:3])
                ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000107 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1183-1187
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000016 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1182-1188
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000016 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1182-1188
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000017 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1189-1195
  `ifdef E203_RFREG_NUM_IS_16 //{ 
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000017 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1189-1195
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000108 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1190-1194
  assign rv_index_ilgl =
                 (| dec_rs1idx[`E203_RFIDX_WIDTH-1:4])
                |(| dec_rs2idx[`E203_RFIDX_WIDTH-1:4])
                |(| dec_rdidx [`E203_RFIDX_WIDTH-1:4])
                ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000108 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1190-1194
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000017 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1189-1195
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000017 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1189-1195
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000018 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1196-1199
  `ifdef E203_RFREG_NUM_IS_32 //{ 
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000018 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1196-1199
      //Never happen this illegal exception
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000109 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1198-1198
  assign rv_index_ilgl = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000109 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1198-1198
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000018 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1196-1199
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:pp_blk:000018 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1196-1199

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:assign_cluster:000012 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1201-1228
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000110 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1201-1201
  assign dec_rv32 = rv32;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000110 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1201-1201

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000111 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1203-1210
  assign dec_bjp_imm = 
                     ({32{rv16_jal | rv16_j     }} & rv16_jjal_imm)
                   | ({32{rv16_jalr_mv_add      }} & rv16_jrjalr_imm)
                   | ({32{rv16_beqz | rv16_bnez }} & rv16_bxx_imm)
                   | ({32{rv32_jal              }} & rv32_jal_imm)
                   | ({32{rv32_jalr             }} & rv32_jalr_imm)
                   | ({32{rv32_branch           }} & rv32_bxx_imm)
                   ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000111 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1203-1210

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000112 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1212-1212
  assign dec_jalr_rs1idx = rv32 ? rv32_rs1[`E203_RFIDX_WIDTH-1:0] : rv16_rs1[`E203_RFIDX_WIDTH-1:0]; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000112 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1212-1212

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000113 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1214-1214
  assign dec_misalgn = i_misalgn;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000113 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1214-1214
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000114 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1215-1215
  assign dec_buserr  = i_buserr ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000114 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1215-1215


//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000115 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1218-1228
  assign dec_ilegl = 
            (rv_all0s1s_ilgl) 
          | (rv_index_ilgl) 
          | (rv16_addi16sp_ilgl)
          | (rv16_addi4spn_ilgl)
          | (rv16_li_lui_ilgl)
          | (rv16_sxxi_shamt_ilgl)
          | (rv32_sxxi_shamt_ilgl)
          | (rv32_dret_ilgl)
          | (rv16_lwsp_ilgl)
          | (~legl_ops);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:assign:000115 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1218-1228
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v:grp:assign_cluster:000012 file=e203_hbirdv2/e203_exu_decode/e203_exu_decode.v lines=1201-1228


endmodule                                      
                                               
                                               
                                               
