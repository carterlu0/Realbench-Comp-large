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
//  This module to implement the Conditional Branch Instructions,
//  which is mostly share the datapath with ALU adder to resolve the comparasion
//  result to save gatecount to mininum
//
//
// ====================================================================
`include "e203_defines.v"

module e203_exu_alu_bjp(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=33-83

  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // The Handshake Interface
  //
  input  bjp_i_valid, // Handshake valid
  output bjp_i_ready, // Handshake ready

  input  [`E203_XLEN-1:0] bjp_i_rs1,
  input  [`E203_XLEN-1:0] bjp_i_rs2,
  input  [`E203_XLEN-1:0] bjp_i_imm,
  input  [`E203_PC_SIZE-1:0] bjp_i_pc,
  input  [`E203_DECINFO_BJP_WIDTH-1:0] bjp_i_info,
  
  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // The BJP Commit Interface
  output bjp_o_valid, // Handshake valid
  input  bjp_o_ready, // Handshake ready
    //   The Write-Back Result for JAL and JALR
  output [`E203_XLEN-1:0] bjp_o_wbck_wdat,
  output bjp_o_wbck_err,
    //   The Commit Result for BJP
  output bjp_o_cmt_bjp,
  output bjp_o_cmt_mret,
  output bjp_o_cmt_dret,
  output bjp_o_cmt_fencei,
  output bjp_o_cmt_prdt,// The predicted ture/false  
  output bjp_o_cmt_rslv,// The resolved ture/false

  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // To share the ALU datapath
  // 
     // The operands and info to ALU

  output [`E203_XLEN-1:0] bjp_req_alu_op1,
  output [`E203_XLEN-1:0] bjp_req_alu_op2,
  output bjp_req_alu_cmp_eq ,
  output bjp_req_alu_cmp_ne ,
  output bjp_req_alu_cmp_lt ,
  output bjp_req_alu_cmp_gt ,
  output bjp_req_alu_cmp_ltu,
  output bjp_req_alu_cmp_gtu,
  output bjp_req_alu_add,

  input  bjp_req_alu_cmp_res,
  input  [`E203_XLEN-1:0] bjp_req_alu_add_res,

  input  clk,
  input  rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=33-83
  );


//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=87-96
  wire mret   = bjp_i_info [`E203_DECINFO_BJP_MRET ]; 
  wire dret   = bjp_i_info [`E203_DECINFO_BJP_DRET ]; 
  wire fencei = bjp_i_info [`E203_DECINFO_BJP_FENCEI ]; 
  wire bxx   = bjp_i_info [`E203_DECINFO_BJP_BXX ]; 
  wire jump  = bjp_i_info [`E203_DECINFO_BJP_JUMP ]; 
  wire rv32  = bjp_i_info [`E203_DECINFO_RV32]; 

  wire wbck_link = jump;

  wire bjp_i_bprdt = bjp_i_info [`E203_DECINFO_BJP_BPRDT ];
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=87-96

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=98-125
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:grp:handshake:000001 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=98-103
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000001 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=98-100
  assign bjp_req_alu_op1 = wbck_link ? 
                            bjp_i_pc 
                          : bjp_i_rs1;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000001 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=98-100
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000002 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=101-103
  assign bjp_req_alu_op2 = wbck_link ? 
                            (rv32 ? `E203_XLEN'd4 : `E203_XLEN'd2)
                          : bjp_i_rs2;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000002 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=101-103
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:grp:handshake:000001 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=98-103

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000003 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=105-105
  assign bjp_o_cmt_bjp = bxx | jump;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000003 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=105-105
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000004 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=106-106
  assign bjp_o_cmt_mret = mret;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000004 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=106-106
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000005 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=107-107
  assign bjp_o_cmt_dret = dret;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000005 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=107-107
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000006 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=108-108
  assign bjp_o_cmt_fencei = fencei;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000006 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=108-108

//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:grp:handshake:000002 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=110-120
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000007 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=110-110
  assign bjp_req_alu_cmp_eq  = bjp_i_info [`E203_DECINFO_BJP_BEQ  ]; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000007 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=110-110
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000008 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=111-111
  assign bjp_req_alu_cmp_ne  = bjp_i_info [`E203_DECINFO_BJP_BNE  ]; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000008 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=111-111
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000009 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=112-112
  assign bjp_req_alu_cmp_lt  = bjp_i_info [`E203_DECINFO_BJP_BLT  ]; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000009 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=112-112
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000010 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=113-113
  assign bjp_req_alu_cmp_gt  = bjp_i_info [`E203_DECINFO_BJP_BGT  ]; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000010 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=113-113
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000011 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=114-114
  assign bjp_req_alu_cmp_ltu = bjp_i_info [`E203_DECINFO_BJP_BLTU ]; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000011 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=114-114
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000012 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=115-115
  assign bjp_req_alu_cmp_gtu = bjp_i_info [`E203_DECINFO_BJP_BGTU ]; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000012 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=115-115

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000013 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=117-117
  assign bjp_req_alu_add  = wbck_link;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000013 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=117-117

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000014 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=119-119
  assign bjp_o_valid     = bjp_i_valid;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000014 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=119-119
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000015 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=120-120
  assign bjp_i_ready     = bjp_o_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000015 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=120-120
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:grp:handshake:000002 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=110-120
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000016 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=121-121
  assign bjp_o_cmt_prdt  = bjp_i_bprdt;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000016 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=121-121
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:grp:handshake:000003 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=122-124
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000017 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=122-122
  assign bjp_o_cmt_rslv  = jump ? 1'b1 : bjp_req_alu_cmp_res;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000017 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=122-122

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000018 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=124-124
  assign bjp_o_wbck_wdat  = bjp_req_alu_add_res;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000018 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=124-124
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:grp:handshake:000003 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=122-124
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000019 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=125-125
  assign bjp_o_wbck_err   = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:assign:000019 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=125-125
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_alu_bjp/e203_exu_alu_bjp.v lines=98-125

endmodule
