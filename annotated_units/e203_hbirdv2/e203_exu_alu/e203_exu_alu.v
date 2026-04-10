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
//  The ALU module to implement the compute function unit
//    and the AGU (address generate unit) for LSU is also handled by ALU
//    additionaly, the shared-impelmentation of MUL and DIV instruction 
//    is also shared by ALU in E200
//
// ====================================================================
`include "e203_defines.v"

module e203_exu_alu(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=33-174

  //////////////////////////////////////////////////////////////
  // The operands and decode info from dispatch
  input  i_valid, 
  output i_ready, 

  output i_longpipe, // Indicate this instruction is 
                     //   issued as a long pipe instruction

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=42-49
  `ifdef E203_HAS_CSR_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=42-49
  output         nice_csr_valid,
  input          nice_csr_ready,
  output  [31:0] nice_csr_addr,
  output         nice_csr_wr,
  output  [31:0] nice_csr_wdata,
  input   [31:0] nice_csr_rdata,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=42-49
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=42-49

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=51-53
  `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=51-53
  input  nice_xs_off,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=51-53
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=51-53

  output amo_wait,
  input  oitf_empty,

                     
  input  [`E203_ITAG_WIDTH-1:0] i_itag,
  input  [`E203_XLEN-1:0] i_rs1,
  input  [`E203_XLEN-1:0] i_rs2,
  input  [`E203_XLEN-1:0] i_imm,
  input  [`E203_DECINFO_WIDTH-1:0]  i_info,  
  input  [`E203_PC_SIZE-1:0] i_pc,
  input  [`E203_INSTR_SIZE-1:0] i_instr,
  input  i_pc_vld,
  input  [`E203_RFIDX_WIDTH-1:0] i_rdidx,
  input  i_rdwen,
  input  i_ilegl,
  input  i_buserr,
  input  i_misalgn,

  input  flush_req,
  input  flush_pulse,

  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // The Commit Interface
  output cmt_o_valid, // Handshake valid
  input  cmt_o_ready, // Handshake ready
  output cmt_o_pc_vld,  
  output [`E203_PC_SIZE-1:0] cmt_o_pc,  
  output [`E203_INSTR_SIZE-1:0] cmt_o_instr,  
  output [`E203_XLEN-1:0]    cmt_o_imm,// The resolved ture/false
    //   The Branch and Jump Commit
  output cmt_o_rv32,// The predicted ture/false  
  output cmt_o_bjp,
  output cmt_o_mret,
  output cmt_o_dret,
  output cmt_o_ecall,
  output cmt_o_ebreak,
  output cmt_o_fencei,
  output cmt_o_wfi,
  output cmt_o_ifu_misalgn,
  output cmt_o_ifu_buserr,
  output cmt_o_ifu_ilegl,
  output cmt_o_bjp_prdt,// The predicted ture/false  
  output cmt_o_bjp_rslv,// The resolved ture/false
    //   The AGU Exception 
  output cmt_o_misalgn, // The misalign exception generated
  output cmt_o_ld,
  output cmt_o_stamo,
  output cmt_o_buserr , // The bus-error exception generated
  output [`E203_ADDR_SIZE-1:0] cmt_o_badaddr,


  //////////////////////////////////////////////////////////////
  // The ALU Write-Back Interface
  output wbck_o_valid, // Handshake valid
  input  wbck_o_ready, // Handshake ready
  output [`E203_XLEN-1:0] wbck_o_wdat,
  output [`E203_RFIDX_WIDTH-1:0] wbck_o_rdidx,
  
  input  mdv_nob2b,

  //////////////////////////////////////////////////////////////
  // The CSR Interface
  output csr_ena,
  output csr_wr_en,
  output csr_rd_en,
  output [12-1:0] csr_idx,

  input  nonflush_cmt_ena,
  input  csr_access_ilgl,
  input  [`E203_XLEN-1:0] read_csr_dat,
  output [`E203_XLEN-1:0] wbck_csr_dat,

  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // The AGU ICB Interface to LSU-ctrl
  //    * Bus cmd channel
  output                         agu_icb_cmd_valid, // Handshake valid
  input                          agu_icb_cmd_ready, // Handshake ready
  output [`E203_ADDR_SIZE-1:0]   agu_icb_cmd_addr, // Bus transaction start addr 
  output                         agu_icb_cmd_read,   // Read or write
  output [`E203_XLEN-1:0]        agu_icb_cmd_wdata, 
  output [`E203_XLEN/8-1:0]      agu_icb_cmd_wmask, 
  output                         agu_icb_cmd_lock,
  output                         agu_icb_cmd_excl,
  output [1:0]                   agu_icb_cmd_size,
  output                         agu_icb_cmd_back2agu, 
  output                         agu_icb_cmd_usign,
  output [`E203_ITAG_WIDTH -1:0] agu_icb_cmd_itag,
  //    * Bus RSP channel
  input                          agu_icb_rsp_valid, // Response valid 
  output                         agu_icb_rsp_ready, // Response ready
  input                          agu_icb_rsp_err  , // Response error
  input                          agu_icb_rsp_excl_ok,
  input  [`E203_XLEN-1:0]        agu_icb_rsp_rdata,
  
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=151-171
  `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=151-171
  //////////////////////////////////////////////////////////////
  // The nice interface
  //    * cmd channel
  output                         nice_req_valid, // Handshake valid
  input                          nice_req_ready, // Handshake ready
  output [`E203_XLEN -1:0]       nice_req_instr,                               
  output [`E203_XLEN -1:0]       nice_req_rs1, 
  output [`E203_XLEN -1:0]       nice_req_rs2, 
  //output                         nice_req_mmode , // O: current insns' mmode 

  //    * RSP channel will be directly pass to longp-wback module
  input                          nice_rsp_multicyc_valid, //I: current insn is multi-cycle.
  output                         nice_rsp_multicyc_ready, //O:                             

  output                         nice_longp_wbck_valid, // Handshake valid
  input                          nice_longp_wbck_ready, // Handshake ready
  output [`E203_ITAG_WIDTH -1:0] nice_o_itag, 

  input                          i_nice_cmt_off_ilgl,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=151-171
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=151-171

  input  clk,
  input  rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=33-174
  );



  //////////////////////////////////////////////////////////////
  // Dispatch to different sub-modules according to their types

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=182-219
  wire ifu_excp_op = i_ilegl | i_buserr | i_misalgn;
  wire alu_op = (~ifu_excp_op) & (i_info[`E203_DECINFO_GRP] == `E203_DECINFO_GRP_ALU); 
  wire agu_op = (~ifu_excp_op) & (i_info[`E203_DECINFO_GRP] == `E203_DECINFO_GRP_AGU); 
  wire bjp_op = (~ifu_excp_op) & (i_info[`E203_DECINFO_GRP] == `E203_DECINFO_GRP_BJP); 
  wire csr_op = (~ifu_excp_op) & (i_info[`E203_DECINFO_GRP] == `E203_DECINFO_GRP_CSR); 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=187-189
`ifdef E203_SUPPORT_SHARE_MULDIV //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=187-189
  wire mdv_op = (~ifu_excp_op) & (i_info[`E203_DECINFO_GRP] == `E203_DECINFO_GRP_MULDIV); 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=187-189
`endif//E203_SUPPORT_SHARE_MULDIV}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=187-189
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=190-192
`ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=190-192
  wire nice_op = (~ifu_excp_op) & (i_info[`E203_DECINFO_GRP] == `E203_DECINFO_GRP_NICE);
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=190-192
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=190-192

  // The ALU incoming instruction may go to several different targets:
  //   * The ALUDATAPATH if it is a regular ALU instructions
  //   * The Branch-cmp if it is a BJP instructions
  //   * The AGU if it is a load/store relevant instructions
  //   * The MULDIV if it is a MUL/DIV relevant instructions and MULDIV
  //       is reusing the ALU adder
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=200-202
`ifdef E203_SUPPORT_SHARE_MULDIV //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=200-202
  wire mdv_i_valid = i_valid & mdv_op;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=200-202
`endif//E203_SUPPORT_SHARE_MULDIV}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=200-202
  wire agu_i_valid = i_valid & agu_op;
  wire alu_i_valid = i_valid & alu_op;
  wire bjp_i_valid = i_valid & bjp_op;
  wire csr_i_valid = i_valid & csr_op;
  wire ifu_excp_i_valid = i_valid & ifu_excp_op;
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=208-211
`ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=208-211
  wire nice_i_valid = i_valid & nice_op;
  wire nice_i_ready;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=208-211
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=208-211
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=212-214
`ifdef E203_SUPPORT_SHARE_MULDIV //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=212-214
  wire mdv_i_ready;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=212-214
`endif//E203_SUPPORT_SHARE_MULDIV}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=212-214
  wire agu_i_ready;
  wire alu_i_ready;
  wire bjp_i_ready;
  wire csr_i_ready;
  wire ifu_excp_i_ready;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=182-219

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=221-232
  assign i_ready =   (agu_i_ready & agu_op)
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=222-224
                   `ifdef E203_SUPPORT_SHARE_MULDIV //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=222-224
                   | (mdv_i_ready & mdv_op)
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=222-224
                   `endif//E203_SUPPORT_SHARE_MULDIV}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=222-224
                   | (alu_i_ready & alu_op)
                   | (ifu_excp_i_ready & ifu_excp_op)
                   | (bjp_i_ready & bjp_op)
                   | (csr_i_ready & csr_op)
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000010 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=229-231
                   `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000010 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=229-231
                   | (nice_i_ready & nice_op)
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000010 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=229-231
		   `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000010 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=229-231
                     ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=221-232

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=234-241
  wire agu_i_longpipe;
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000011 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=235-237
`ifdef E203_SUPPORT_SHARE_MULDIV //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000011 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=235-237
  wire mdv_i_longpipe;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000011 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=235-237
`endif//E203_SUPPORT_SHARE_MULDIV}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000011 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=235-237
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000012 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=238-241
`ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000012 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=238-241
  wire nice_o_longpipe;
  wire nice_i_longpipe = nice_o_longpipe;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000012 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=238-241
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000012 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=238-241
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=234-241

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=243-250
  assign i_longpipe = (agu_i_longpipe & agu_op) 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000013 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=244-246
                   `ifdef E203_SUPPORT_SHARE_MULDIV //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000013 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=244-246
                    | (mdv_i_longpipe & mdv_op) 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000013 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=244-246
                   `endif//E203_SUPPORT_SHARE_MULDIV}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000013 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=244-246
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000014 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=247-249
                   `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000014 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=247-249
                    | (nice_i_longpipe & nice_op)
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000014 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=247-249
		   `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000014 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=247-249
                   ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=243-250

  //////////////////////////////////////////////////////////////
  // Instantiate the CSR module
  //
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=255-277
  wire csr_o_valid;
  wire csr_o_ready;
  wire [`E203_XLEN-1:0] csr_o_wbck_wdat;
  wire csr_o_wbck_err;

  wire  [`E203_XLEN-1:0]           csr_i_rs1   = {`E203_XLEN         {csr_op}} & i_rs1;
  wire  [`E203_XLEN-1:0]           csr_i_rs2   = {`E203_XLEN         {csr_op}} & i_rs2;
  wire  [`E203_XLEN-1:0]           csr_i_imm   = {`E203_XLEN         {csr_op}} & i_imm;
  wire  [`E203_DECINFO_WIDTH-1:0]  csr_i_info  = {`E203_DECINFO_WIDTH{csr_op}} & i_info;  
  wire                             csr_i_rdwen =                      csr_op   & i_rdwen;  

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000015 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=266-268
  `ifdef E203_HAS_CSR_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000015 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=266-268
  wire csr_sel_nice;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000015 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=266-268
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000015 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=266-268

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000016 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=270-314
  `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000016 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=270-314
  wire [`E203_XLEN-1:0]           nice_i_rs1  = {`E203_XLEN         {nice_op}} & i_rs1;
  wire [`E203_XLEN-1:0]           nice_i_rs2  = {`E203_XLEN         {nice_op}} & i_rs2;
  wire [`E203_ITAG_WIDTH-1:0]     nice_i_itag = {`E203_ITAG_WIDTH   {nice_op}} & i_itag;  
  wire nice_o_valid; 
  wire nice_o_ready;
  //wire [`E203_XLEN-1:0] nice_o_wbck_wdat;
  wire nice_o_wbck_err = i_nice_cmt_off_ilgl;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=255-277
  //wire nice_i_mmode = nice_op & i_mmode;


//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:inst:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=281-313
  e203_exu_nice   u_e203_exu_nice (

  .nice_i_xs_off      (nice_xs_off),
  .nice_i_valid       (nice_i_valid), // Handshake valid
  .nice_i_ready       (nice_i_ready), // Handshake ready
  .nice_i_instr       (i_instr),
  .nice_i_rs1         (nice_i_rs1), // Handshake valid
  .nice_i_rs2         (nice_i_rs2), // Handshake ready
  //.nice_i_mmode       (nice_i_mmode), // Handshake ready
  .nice_i_itag        (nice_i_itag),
  .nice_o_longpipe    (nice_o_longpipe),
  // The nice Commit Interface
  .nice_o_valid       (nice_o_valid), // Handshake valid
  .nice_o_ready       (nice_o_ready), // Handshake ready

  .nice_o_itag_valid  (nice_longp_wbck_valid), // Handshake valid
  .nice_o_itag_ready  (nice_longp_wbck_ready), // Handshake ready
  .nice_o_itag        (nice_o_itag),   
  // The nice Response Interface
  .nice_rsp_multicyc_valid(nice_rsp_multicyc_valid), //I: current insn is multi-cycle.
  .nice_rsp_multicyc_ready(nice_rsp_multicyc_ready), //O:                             
  // The nice Request Interface
  .nice_req_valid     (nice_req_valid), // Handshake valid
  .nice_req_ready     (nice_req_ready), // Handshake ready
  .nice_req_instr     (nice_req_instr), // Handshake ready
  .nice_req_rs1       (nice_req_rs1), // Handshake valid
  .nice_req_rs2       (nice_req_rs2), // Handshake ready
  //.nice_req_mmode     (nice_req_mmode), // Handshake ready

  .clk               (clk),
  .rst_n             (rst_n)       

  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:inst:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=281-313
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000016 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=270-314
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000016 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=270-314

  
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:inst:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=317-352
  e203_exu_alu_csrctrl u_e203_exu_alu_csrctrl(

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000017 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=319-328
  `ifdef E203_HAS_CSR_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000017 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=319-328
    .nice_xs_off       (nice_xs_off),
    .csr_sel_nice      (csr_sel_nice),
    .nice_csr_valid    (nice_csr_valid),
    .nice_csr_ready    (nice_csr_ready),
    .nice_csr_addr     (nice_csr_addr ),
    .nice_csr_wr       (nice_csr_wr ),
    .nice_csr_wdata    (nice_csr_wdata),
    .nice_csr_rdata    (nice_csr_rdata),
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000017 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=319-328
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000017 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=319-328
    .csr_access_ilgl  (csr_access_ilgl),

    .csr_i_valid      (csr_i_valid),
    .csr_i_ready      (csr_i_ready),

    .csr_i_rs1        (csr_i_rs1  ),
    .csr_i_info       (csr_i_info[`E203_DECINFO_CSR_WIDTH-1:0]),
    .csr_i_rdwen      (csr_i_rdwen),

    .csr_ena          (csr_ena),
    .csr_idx          (csr_idx),
    .csr_rd_en        (csr_rd_en),
    .csr_wr_en        (csr_wr_en),
    .read_csr_dat     (read_csr_dat),
    .wbck_csr_dat     (wbck_csr_dat),

    .csr_o_valid      (csr_o_valid      ),   
    .csr_o_ready      (csr_o_ready      ),   
    .csr_o_wbck_wdat  (csr_o_wbck_wdat  ),
    .csr_o_wbck_err   (csr_o_wbck_err   ),

     .clk             (clk),
     .rst_n           (rst_n)
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:inst:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=317-352

  //////////////////////////////////////////////////////////////
  // Instantiate the BJP module
  //
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=357-384
  wire bjp_o_valid; 
  wire bjp_o_ready; 
  wire [`E203_XLEN-1:0] bjp_o_wbck_wdat;
  wire bjp_o_wbck_err;
  wire bjp_o_cmt_bjp;
  wire bjp_o_cmt_mret;
  wire bjp_o_cmt_dret;
  wire bjp_o_cmt_fencei;
  wire bjp_o_cmt_prdt;
  wire bjp_o_cmt_rslv;

  wire [`E203_XLEN-1:0] bjp_req_alu_op1;
  wire [`E203_XLEN-1:0] bjp_req_alu_op2;
  wire bjp_req_alu_cmp_eq ;
  wire bjp_req_alu_cmp_ne ;
  wire bjp_req_alu_cmp_lt ;
  wire bjp_req_alu_cmp_gt ;
  wire bjp_req_alu_cmp_ltu;
  wire bjp_req_alu_cmp_gtu;
  wire bjp_req_alu_add;
  wire bjp_req_alu_cmp_res;
  wire [`E203_XLEN-1:0] bjp_req_alu_add_res;

  wire  [`E203_XLEN-1:0]           bjp_i_rs1  = {`E203_XLEN         {bjp_op}} & i_rs1;
  wire  [`E203_XLEN-1:0]           bjp_i_rs2  = {`E203_XLEN         {bjp_op}} & i_rs2;
  wire  [`E203_XLEN-1:0]           bjp_i_imm  = {`E203_XLEN         {bjp_op}} & i_imm;
  wire  [`E203_DECINFO_WIDTH-1:0]  bjp_i_info = {`E203_DECINFO_WIDTH{bjp_op}} & i_info;  
  wire  [`E203_PC_SIZE-1:0]        bjp_i_pc   = {`E203_PC_SIZE      {bjp_op}} & i_pc;  
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=357-384

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:inst:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=386-421
  e203_exu_alu_bjp u_e203_exu_alu_bjp(
      .bjp_i_valid         (bjp_i_valid         ),
      .bjp_i_ready         (bjp_i_ready         ),
      .bjp_i_rs1           (bjp_i_rs1           ),
      .bjp_i_rs2           (bjp_i_rs2           ),
      .bjp_i_info          (bjp_i_info[`E203_DECINFO_BJP_WIDTH-1:0]),
      .bjp_i_imm           (bjp_i_imm           ),
      .bjp_i_pc            (bjp_i_pc            ),

      .bjp_o_valid         (bjp_o_valid      ),
      .bjp_o_ready         (bjp_o_ready      ),
      .bjp_o_wbck_wdat     (bjp_o_wbck_wdat  ),
      .bjp_o_wbck_err      (bjp_o_wbck_err   ),

      .bjp_o_cmt_bjp       (bjp_o_cmt_bjp    ),
      .bjp_o_cmt_mret      (bjp_o_cmt_mret    ),
      .bjp_o_cmt_dret      (bjp_o_cmt_dret    ),
      .bjp_o_cmt_fencei    (bjp_o_cmt_fencei  ),
      .bjp_o_cmt_prdt      (bjp_o_cmt_prdt   ),
      .bjp_o_cmt_rslv      (bjp_o_cmt_rslv   ),

      .bjp_req_alu_op1     (bjp_req_alu_op1       ),
      .bjp_req_alu_op2     (bjp_req_alu_op2       ),
      .bjp_req_alu_cmp_eq  (bjp_req_alu_cmp_eq    ),
      .bjp_req_alu_cmp_ne  (bjp_req_alu_cmp_ne    ),
      .bjp_req_alu_cmp_lt  (bjp_req_alu_cmp_lt    ),
      .bjp_req_alu_cmp_gt  (bjp_req_alu_cmp_gt    ),
      .bjp_req_alu_cmp_ltu (bjp_req_alu_cmp_ltu   ),
      .bjp_req_alu_cmp_gtu (bjp_req_alu_cmp_gtu   ),
      .bjp_req_alu_add     (bjp_req_alu_add       ),
      .bjp_req_alu_cmp_res (bjp_req_alu_cmp_res   ),
      .bjp_req_alu_add_res (bjp_req_alu_add_res   ),

      .clk                 (clk),
      .rst_n               (rst_n)
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:inst:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=386-421



  
  //////////////////////////////////////////////////////////////
  // Instantiate the AGU module
  //
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:internal_signal:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=429-465
  wire agu_o_valid; 
  wire agu_o_ready; 
  
  wire [`E203_XLEN-1:0] agu_o_wbck_wdat;
  wire agu_o_wbck_err;   
  
  wire agu_o_cmt_misalgn; 
  wire agu_o_cmt_ld; 
  wire agu_o_cmt_stamo; 
  wire agu_o_cmt_buserr ; 
  wire [`E203_ADDR_SIZE-1:0]agu_o_cmt_badaddr ; 
  
  wire [`E203_XLEN-1:0] agu_req_alu_op1;
  wire [`E203_XLEN-1:0] agu_req_alu_op2;
  wire agu_req_alu_swap;
  wire agu_req_alu_add ;
  wire agu_req_alu_and ;
  wire agu_req_alu_or  ;
  wire agu_req_alu_xor ;
  wire agu_req_alu_max ;
  wire agu_req_alu_min ;
  wire agu_req_alu_maxu;
  wire agu_req_alu_minu;
  wire [`E203_XLEN-1:0] agu_req_alu_res;
     
  wire agu_sbf_0_ena;
  wire [`E203_XLEN-1:0] agu_sbf_0_nxt;
  wire [`E203_XLEN-1:0] agu_sbf_0_r;
  wire agu_sbf_1_ena;
  wire [`E203_XLEN-1:0] agu_sbf_1_nxt;
  wire [`E203_XLEN-1:0] agu_sbf_1_r;

  wire  [`E203_XLEN-1:0]           agu_i_rs1  = {`E203_XLEN         {agu_op}} & i_rs1;
  wire  [`E203_XLEN-1:0]           agu_i_rs2  = {`E203_XLEN         {agu_op}} & i_rs2;
  wire  [`E203_XLEN-1:0]           agu_i_imm  = {`E203_XLEN         {agu_op}} & i_imm;
  wire  [`E203_DECINFO_WIDTH-1:0]  agu_i_info = {`E203_DECINFO_WIDTH{agu_op}} & i_info;  
  wire  [`E203_ITAG_WIDTH-1:0]     agu_i_itag = {`E203_ITAG_WIDTH   {agu_op}} & i_itag;  
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:internal_signal:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=429-465


//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:inst:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=468-535
  e203_exu_alu_lsuagu u_e203_exu_alu_lsuagu(

      .agu_i_valid         (agu_i_valid     ),
      .agu_i_ready         (agu_i_ready     ),
      .agu_i_rs1           (agu_i_rs1       ),
      .agu_i_rs2           (agu_i_rs2       ),
      .agu_i_imm           (agu_i_imm       ),
      .agu_i_info          (agu_i_info[`E203_DECINFO_AGU_WIDTH-1:0]),
      .agu_i_longpipe      (agu_i_longpipe  ),
      .agu_i_itag          (agu_i_itag      ),

      .flush_pulse         (flush_pulse    ),
      .flush_req           (flush_req      ),
      .amo_wait            (amo_wait),
      .oitf_empty          (oitf_empty),

      .agu_o_valid         (agu_o_valid         ),
      .agu_o_ready         (agu_o_ready         ),
      .agu_o_wbck_wdat     (agu_o_wbck_wdat     ),
      .agu_o_wbck_err      (agu_o_wbck_err      ),
      .agu_o_cmt_misalgn   (agu_o_cmt_misalgn   ),
      .agu_o_cmt_ld        (agu_o_cmt_ld        ),
      .agu_o_cmt_stamo     (agu_o_cmt_stamo     ),
      .agu_o_cmt_buserr    (agu_o_cmt_buserr    ),
      .agu_o_cmt_badaddr   (agu_o_cmt_badaddr   ),
                                                
      .agu_icb_cmd_valid   (agu_icb_cmd_valid   ),
      .agu_icb_cmd_ready   (agu_icb_cmd_ready   ),
      .agu_icb_cmd_addr    (agu_icb_cmd_addr    ),
      .agu_icb_cmd_read    (agu_icb_cmd_read    ),
      .agu_icb_cmd_wdata   (agu_icb_cmd_wdata   ),
      .agu_icb_cmd_wmask   (agu_icb_cmd_wmask   ),
      .agu_icb_cmd_lock    (agu_icb_cmd_lock    ),
      .agu_icb_cmd_excl    (agu_icb_cmd_excl    ),
      .agu_icb_cmd_size    (agu_icb_cmd_size    ),
      .agu_icb_cmd_back2agu(agu_icb_cmd_back2agu),
      .agu_icb_cmd_usign   (agu_icb_cmd_usign   ),
      .agu_icb_cmd_itag    (agu_icb_cmd_itag    ),
      .agu_icb_rsp_valid   (agu_icb_rsp_valid   ),
      .agu_icb_rsp_ready   (agu_icb_rsp_ready   ),
      .agu_icb_rsp_err     (agu_icb_rsp_err     ),
      .agu_icb_rsp_excl_ok (agu_icb_rsp_excl_ok ),
      .agu_icb_rsp_rdata   (agu_icb_rsp_rdata   ),
                                                
      .agu_req_alu_op1     (agu_req_alu_op1     ),
      .agu_req_alu_op2     (agu_req_alu_op2     ),
      .agu_req_alu_swap    (agu_req_alu_swap    ),
      .agu_req_alu_add     (agu_req_alu_add     ),
      .agu_req_alu_and     (agu_req_alu_and     ),
      .agu_req_alu_or      (agu_req_alu_or      ),
      .agu_req_alu_xor     (agu_req_alu_xor     ),
      .agu_req_alu_max     (agu_req_alu_max     ),
      .agu_req_alu_min     (agu_req_alu_min     ),
      .agu_req_alu_maxu    (agu_req_alu_maxu    ),
      .agu_req_alu_minu    (agu_req_alu_minu    ),
      .agu_req_alu_res     (agu_req_alu_res     ),
                                                
      .agu_sbf_0_ena       (agu_sbf_0_ena       ),
      .agu_sbf_0_nxt       (agu_sbf_0_nxt       ),
      .agu_sbf_0_r         (agu_sbf_0_r         ),
                                                
      .agu_sbf_1_ena       (agu_sbf_1_ena       ),
      .agu_sbf_1_nxt       (agu_sbf_1_nxt       ),
      .agu_sbf_1_r         (agu_sbf_1_r         ),
     
      .clk                 (clk),
      .rst_n               (rst_n)
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:inst:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=468-535

  //////////////////////////////////////////////////////////////
  // Instantiate the regular ALU module
  //
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:internal_signal:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=540-567
  wire alu_o_valid; 
  wire alu_o_ready; 
  wire [`E203_XLEN-1:0] alu_o_wbck_wdat;
  wire alu_o_wbck_err;   
  wire alu_o_cmt_ecall;
  wire alu_o_cmt_ebreak;
  wire alu_o_cmt_wfi;

  wire alu_req_alu_add ;
  wire alu_req_alu_sub ;
  wire alu_req_alu_xor ;
  wire alu_req_alu_sll ;
  wire alu_req_alu_srl ;
  wire alu_req_alu_sra ;
  wire alu_req_alu_or  ;
  wire alu_req_alu_and ;
  wire alu_req_alu_slt ;
  wire alu_req_alu_sltu;
  wire alu_req_alu_lui ;
  wire [`E203_XLEN-1:0] alu_req_alu_op1;
  wire [`E203_XLEN-1:0] alu_req_alu_op2;
  wire [`E203_XLEN-1:0] alu_req_alu_res;

  wire  [`E203_XLEN-1:0]           alu_i_rs1  = {`E203_XLEN         {alu_op}} & i_rs1;
  wire  [`E203_XLEN-1:0]           alu_i_rs2  = {`E203_XLEN         {alu_op}} & i_rs2;
  wire  [`E203_XLEN-1:0]           alu_i_imm  = {`E203_XLEN         {alu_op}} & i_imm;
  wire  [`E203_DECINFO_WIDTH-1:0]  alu_i_info = {`E203_DECINFO_WIDTH{alu_op}} & i_info;  
  wire  [`E203_PC_SIZE-1:0]        alu_i_pc   = {`E203_PC_SIZE      {alu_op}} & i_pc;  
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:internal_signal:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=540-567

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:inst:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=569-604
  e203_exu_alu_rglr u_e203_exu_alu_rglr(

      .alu_i_valid         (alu_i_valid     ),
      .alu_i_ready         (alu_i_ready     ),
      .alu_i_rs1           (alu_i_rs1           ),
      .alu_i_rs2           (alu_i_rs2           ),
      .alu_i_info          (alu_i_info[`E203_DECINFO_ALU_WIDTH-1:0]),
      .alu_i_imm           (alu_i_imm           ),
      .alu_i_pc            (alu_i_pc            ),

      .alu_o_valid         (alu_o_valid         ),
      .alu_o_ready         (alu_o_ready         ),
      .alu_o_wbck_wdat     (alu_o_wbck_wdat     ),
      .alu_o_wbck_err      (alu_o_wbck_err      ),
      .alu_o_cmt_ecall     (alu_o_cmt_ecall ),
      .alu_o_cmt_ebreak    (alu_o_cmt_ebreak),
      .alu_o_cmt_wfi       (alu_o_cmt_wfi   ),

      .alu_req_alu_add     (alu_req_alu_add       ),
      .alu_req_alu_sub     (alu_req_alu_sub       ),
      .alu_req_alu_xor     (alu_req_alu_xor       ),
      .alu_req_alu_sll     (alu_req_alu_sll       ),
      .alu_req_alu_srl     (alu_req_alu_srl       ),
      .alu_req_alu_sra     (alu_req_alu_sra       ),
      .alu_req_alu_or      (alu_req_alu_or        ),
      .alu_req_alu_and     (alu_req_alu_and       ),
      .alu_req_alu_slt     (alu_req_alu_slt       ),
      .alu_req_alu_sltu    (alu_req_alu_sltu      ),
      .alu_req_alu_lui     (alu_req_alu_lui       ),
      .alu_req_alu_op1     (alu_req_alu_op1       ),
      .alu_req_alu_op2     (alu_req_alu_op2       ),
      .alu_req_alu_res     (alu_req_alu_res       ),

      .clk                 (clk           ),
      .rst_n               (rst_n         ) 
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:inst:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=569-604

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000018 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=606-672
`ifdef E203_SUPPORT_SHARE_MULDIV //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000018 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=606-672
  //////////////////////////////////////////////////////
  // Instantiate the MULDIV module
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:internal_signal:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=609-632
  wire [`E203_XLEN-1:0]           mdv_i_rs1  = {`E203_XLEN         {mdv_op}} & i_rs1;
  wire [`E203_XLEN-1:0]           mdv_i_rs2  = {`E203_XLEN         {mdv_op}} & i_rs2;
  wire [`E203_XLEN-1:0]           mdv_i_imm  = {`E203_XLEN         {mdv_op}} & i_imm;
  wire [`E203_DECINFO_WIDTH-1:0]  mdv_i_info = {`E203_DECINFO_WIDTH{mdv_op}} & i_info;  
  wire  [`E203_ITAG_WIDTH-1:0]    mdv_i_itag = {`E203_ITAG_WIDTH   {mdv_op}} & i_itag;  

  wire mdv_o_valid; 
  wire mdv_o_ready;
  wire [`E203_XLEN-1:0] mdv_o_wbck_wdat;
  wire mdv_o_wbck_err;

  wire [`E203_ALU_ADDER_WIDTH-1:0] muldiv_req_alu_op1;
  wire [`E203_ALU_ADDER_WIDTH-1:0] muldiv_req_alu_op2;
  wire                             muldiv_req_alu_add ;
  wire                             muldiv_req_alu_sub ;
  wire [`E203_ALU_ADDER_WIDTH-1:0] muldiv_req_alu_res;

  wire          muldiv_sbf_0_ena;
  wire [33-1:0] muldiv_sbf_0_nxt;
  wire [33-1:0] muldiv_sbf_0_r;

  wire          muldiv_sbf_1_ena;
  wire [33-1:0] muldiv_sbf_1_nxt;
  wire [33-1:0] muldiv_sbf_1_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:internal_signal:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=609-632

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:inst:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=634-671
  e203_exu_alu_muldiv u_e203_exu_alu_muldiv(
      .mdv_nob2b           (mdv_nob2b),

      .muldiv_i_valid      (mdv_i_valid    ),
      .muldiv_i_ready      (mdv_i_ready    ),
                           
      .muldiv_i_rs1        (mdv_i_rs1      ),
      .muldiv_i_rs2        (mdv_i_rs2      ),
      .muldiv_i_imm        (mdv_i_imm      ),
      .muldiv_i_info       (mdv_i_info[`E203_DECINFO_MULDIV_WIDTH-1:0]),
      .muldiv_i_longpipe   (mdv_i_longpipe ),
      .muldiv_i_itag       (mdv_i_itag     ),
                          

      .flush_pulse         (flush_pulse    ),

      .muldiv_o_valid      (mdv_o_valid    ),
      .muldiv_o_ready      (mdv_o_ready    ),
      .muldiv_o_wbck_wdat  (mdv_o_wbck_wdat),
      .muldiv_o_wbck_err   (mdv_o_wbck_err ),

      .muldiv_req_alu_op1  (muldiv_req_alu_op1),
      .muldiv_req_alu_op2  (muldiv_req_alu_op2),
      .muldiv_req_alu_add  (muldiv_req_alu_add),
      .muldiv_req_alu_sub  (muldiv_req_alu_sub),
      .muldiv_req_alu_res  (muldiv_req_alu_res),
      
      .muldiv_sbf_0_ena    (muldiv_sbf_0_ena  ),
      .muldiv_sbf_0_nxt    (muldiv_sbf_0_nxt  ),
      .muldiv_sbf_0_r      (muldiv_sbf_0_r    ),
     
      .muldiv_sbf_1_ena    (muldiv_sbf_1_ena  ),
      .muldiv_sbf_1_nxt    (muldiv_sbf_1_nxt  ),
      .muldiv_sbf_1_r      (muldiv_sbf_1_r    ),

      .clk                 (clk               ),
      .rst_n               (rst_n             ) 
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:inst:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=634-671
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000018 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=606-672
`endif//E203_SUPPORT_SHARE_MULDIV}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000018 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=606-672





  //////////////////////////////////////////////////////////////
  // Instantiate the Shared Datapath module
  //
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:internal_signal:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=681-686
  wire alu_req_alu = alu_op & i_rdwen;// Regular ALU only req datapath when it need to write-back
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000019 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=682-684
`ifdef E203_SUPPORT_SHARE_MULDIV //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000019 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=682-684
  wire muldiv_req_alu = mdv_op;// Since MULDIV have no point to let rd=0, so always need ALU datapath
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000019 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=682-684
`endif//E203_SUPPORT_SHARE_MULDIV}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000019 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=682-684
  wire bjp_req_alu = bjp_op;// Since BJP may not write-back, but still need ALU datapath
  wire agu_req_alu = agu_op;// Since AGU may have some other features, so always need ALU datapath
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:internal_signal:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=681-686

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:inst:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=688-760
  e203_exu_alu_dpath u_e203_exu_alu_dpath(
      .alu_req_alu         (alu_req_alu           ),    
      .alu_req_alu_add     (alu_req_alu_add       ),
      .alu_req_alu_sub     (alu_req_alu_sub       ),
      .alu_req_alu_xor     (alu_req_alu_xor       ),
      .alu_req_alu_sll     (alu_req_alu_sll       ),
      .alu_req_alu_srl     (alu_req_alu_srl       ),
      .alu_req_alu_sra     (alu_req_alu_sra       ),
      .alu_req_alu_or      (alu_req_alu_or        ),
      .alu_req_alu_and     (alu_req_alu_and       ),
      .alu_req_alu_slt     (alu_req_alu_slt       ),
      .alu_req_alu_sltu    (alu_req_alu_sltu      ),
      .alu_req_alu_lui     (alu_req_alu_lui       ),
      .alu_req_alu_op1     (alu_req_alu_op1       ),
      .alu_req_alu_op2     (alu_req_alu_op2       ),
      .alu_req_alu_res     (alu_req_alu_res       ),
           
      .bjp_req_alu         (bjp_req_alu           ),
      .bjp_req_alu_op1     (bjp_req_alu_op1       ),
      .bjp_req_alu_op2     (bjp_req_alu_op2       ),
      .bjp_req_alu_cmp_eq  (bjp_req_alu_cmp_eq    ),
      .bjp_req_alu_cmp_ne  (bjp_req_alu_cmp_ne    ),
      .bjp_req_alu_cmp_lt  (bjp_req_alu_cmp_lt    ),
      .bjp_req_alu_cmp_gt  (bjp_req_alu_cmp_gt    ),
      .bjp_req_alu_cmp_ltu (bjp_req_alu_cmp_ltu   ),
      .bjp_req_alu_cmp_gtu (bjp_req_alu_cmp_gtu   ),
      .bjp_req_alu_add     (bjp_req_alu_add       ),
      .bjp_req_alu_cmp_res (bjp_req_alu_cmp_res   ),
      .bjp_req_alu_add_res (bjp_req_alu_add_res   ),
             
      .agu_req_alu         (agu_req_alu           ),
      .agu_req_alu_op1     (agu_req_alu_op1       ),
      .agu_req_alu_op2     (agu_req_alu_op2       ),
      .agu_req_alu_swap    (agu_req_alu_swap      ),
      .agu_req_alu_add     (agu_req_alu_add       ),
      .agu_req_alu_and     (agu_req_alu_and       ),
      .agu_req_alu_or      (agu_req_alu_or        ),
      .agu_req_alu_xor     (agu_req_alu_xor       ),
      .agu_req_alu_max     (agu_req_alu_max       ),
      .agu_req_alu_min     (agu_req_alu_min       ),
      .agu_req_alu_maxu    (agu_req_alu_maxu      ),
      .agu_req_alu_minu    (agu_req_alu_minu      ),
      .agu_req_alu_res     (agu_req_alu_res       ),
             
      .agu_sbf_0_ena       (agu_sbf_0_ena         ),
      .agu_sbf_0_nxt       (agu_sbf_0_nxt         ),
      .agu_sbf_0_r         (agu_sbf_0_r           ),
            
      .agu_sbf_1_ena       (agu_sbf_1_ena         ),
      .agu_sbf_1_nxt       (agu_sbf_1_nxt         ),
      .agu_sbf_1_r         (agu_sbf_1_r           ),      

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000020 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=740-756
`ifdef E203_SUPPORT_SHARE_MULDIV //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000020 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=740-756
      .muldiv_req_alu      (muldiv_req_alu    ),

      .muldiv_req_alu_op1  (muldiv_req_alu_op1),
      .muldiv_req_alu_op2  (muldiv_req_alu_op2),
      .muldiv_req_alu_add  (muldiv_req_alu_add),
      .muldiv_req_alu_sub  (muldiv_req_alu_sub),
      .muldiv_req_alu_res  (muldiv_req_alu_res),
      
      .muldiv_sbf_0_ena    (muldiv_sbf_0_ena  ),
      .muldiv_sbf_0_nxt    (muldiv_sbf_0_nxt  ),
      .muldiv_sbf_0_r      (muldiv_sbf_0_r    ),
     
      .muldiv_sbf_1_ena    (muldiv_sbf_1_ena  ),
      .muldiv_sbf_1_nxt    (muldiv_sbf_1_nxt  ),
      .muldiv_sbf_1_r      (muldiv_sbf_1_r    ),
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000020 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=740-756
`endif//E203_SUPPORT_SHARE_MULDIV}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000020 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=740-756

      .clk                 (clk           ),
      .rst_n               (rst_n         ) 
    );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:inst:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=688-760

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:internal_signal:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=762-765
  wire ifu_excp_o_valid;
  wire ifu_excp_o_ready;
  wire [`E203_XLEN-1:0] ifu_excp_o_wbck_wdat;
  wire ifu_excp_o_wbck_err;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:internal_signal:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=762-765

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=767-770
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:handshake:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=767-768
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=767-767
  assign ifu_excp_i_ready = ifu_excp_o_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=767-767
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=768-768
  assign ifu_excp_o_valid = ifu_excp_i_valid;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=768-768
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:handshake:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=767-768
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=769-769
  assign ifu_excp_o_wbck_wdat = `E203_XLEN'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=769-769
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=770-770
  assign ifu_excp_o_wbck_err  = 1'b1;// IFU illegal instruction always treat as error
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=770-770
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=767-770

  //////////////////////////////////////////////////////////////
  // Aribtrate the Result and generate output interfaces
  // 
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:internal_signal:000010 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=775-788
  wire o_valid;
  wire o_ready;

  wire o_sel_ifu_excp = ifu_excp_op;
  wire o_sel_alu = alu_op;
  wire o_sel_bjp = bjp_op;
  wire o_sel_csr = csr_op;
  wire o_sel_agu = agu_op;
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000021 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=783-785
`ifdef E203_SUPPORT_SHARE_MULDIV //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000021 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=783-785
  wire o_sel_mdv = mdv_op;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000021 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=783-785
`endif//E203_SUPPORT_SHARE_MULDIV}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000021 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=783-785
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000022 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=786-788
`ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000022 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=786-788
  wire o_sel_nice = nice_op;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000022 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=786-788
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000022 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=786-788
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:internal_signal:000010 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=775-788

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=790-805
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:handshake:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=790-805
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=790-801
  assign o_valid =     (o_sel_alu      & alu_o_valid     )
                     | (o_sel_bjp      & bjp_o_valid     )
                     | (o_sel_csr      & csr_o_valid     )
                     | (o_sel_agu      & agu_o_valid     )
                     | (o_sel_ifu_excp & ifu_excp_o_valid)
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000023 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=795-797
                      `ifdef E203_SUPPORT_SHARE_MULDIV //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000023 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=795-797
                     | (o_sel_mdv      & mdv_o_valid     )
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000023 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=795-797
                      `endif//E203_SUPPORT_SHARE_MULDIV}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000023 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=795-797
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000024 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=798-800
                      `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000024 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=798-800
                     | (o_sel_nice      & nice_o_valid     )
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000024 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=798-800
                      `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000024 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=798-800
                     ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=790-801

//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:bus_cluster:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=803-805
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=803-803
  assign ifu_excp_o_ready = o_sel_ifu_excp & o_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=803-803
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=804-804
  assign alu_o_ready      = o_sel_alu & o_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=804-804
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000010 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=805-805
  assign agu_o_ready      = o_sel_agu & o_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000010 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=805-805
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:bus_cluster:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=803-805
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=790-805
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:handshake:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=790-805
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000025 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=806-808
`ifdef E203_SUPPORT_SHARE_MULDIV //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000025 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=806-808
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000011 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=807-807
  assign mdv_o_ready      = o_sel_mdv & o_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000011 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=807-807
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000025 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=806-808
`endif//E203_SUPPORT_SHARE_MULDIV}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000025 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=806-808
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=809-810
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:handshake:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=809-810
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000012 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=809-809
  assign bjp_o_ready      = o_sel_bjp & o_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000012 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=809-809
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000013 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=810-810
  assign csr_o_ready      = o_sel_csr & o_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000013 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=810-810
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=809-810
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:handshake:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=809-810
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000026 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=811-813
`ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000026 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=811-813
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000014 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=812-812
  assign nice_o_ready      = o_sel_nice & o_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000014 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=812-812
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000026 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=811-813
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000026 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=811-813

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:assign_cluster:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=815-827
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000015 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=815-825
  assign wbck_o_wdat = 
                    ({`E203_XLEN{o_sel_alu}} & alu_o_wbck_wdat)
                  | ({`E203_XLEN{o_sel_bjp}} & bjp_o_wbck_wdat)
                  | ({`E203_XLEN{o_sel_csr}} & csr_o_wbck_wdat)
                  | ({`E203_XLEN{o_sel_agu}} & agu_o_wbck_wdat)
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000027 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=820-822
                      `ifdef E203_SUPPORT_SHARE_MULDIV //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000027 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=820-822
                  | ({`E203_XLEN{o_sel_mdv}} & mdv_o_wbck_wdat)
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000027 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=820-822
                      `endif//E203_SUPPORT_SHARE_MULDIV}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000027 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=820-822
                  | ({`E203_XLEN{o_sel_ifu_excp}} & ifu_excp_o_wbck_wdat)
                  //| ({`E203_XLEN{o_sel_nice}} & nice_o_wbck_wdat)
                  ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000015 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=815-825

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000016 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=827-827
  assign wbck_o_rdidx = i_rdidx; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000016 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=827-827
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:assign_cluster:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=815-827

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:internal_signal:000011 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=829-831
  wire wbck_o_rdwen = i_rdwen;
                  
  wire wbck_o_err = 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:internal_signal:000011 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=829-831
                    ({1{o_sel_alu}} & alu_o_wbck_err)
                  | ({1{o_sel_bjp}} & bjp_o_wbck_err)
                  | ({1{o_sel_csr}} & csr_o_wbck_err)
                  | ({1{o_sel_agu}} & agu_o_wbck_err)
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000028 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=836-838
                      `ifdef E203_SUPPORT_SHARE_MULDIV //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000028 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=836-838
                  | ({1{o_sel_mdv}} & mdv_o_wbck_err)
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000028 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=836-838
                      `endif//E203_SUPPORT_SHARE_MULDIV}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000028 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=836-838
                  | ({1{o_sel_ifu_excp}} & ifu_excp_o_wbck_err)
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000029 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=840-842
                    `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000029 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=840-842
                  | ({1{o_sel_nice}} & nice_o_wbck_err)
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000029 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=840-842
                    `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:pp_blk:000029 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=840-842
                  ;

  //  Each Instruction need to commit or write-back
  //   * The write-back only needed when the unit need to write-back
  //     the result (need to write RD), and it is not a long-pipe uop
  //     (need to be write back by its long-pipe write-back, not here)
  //   * Each instruction need to be commited 
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:internal_signal:000012 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=850-851
  wire o_need_wbck = wbck_o_rdwen & (~i_longpipe) & (~wbck_o_err);
  wire o_need_cmt  = 1'b1;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:internal_signal:000012 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=850-851
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:assign_cluster:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=852-898
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:bus_cluster:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=852-857
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:handshake:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=852-857
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000017 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=852-854
  assign o_ready = 
           (o_need_cmt  ? cmt_o_ready  : 1'b1)  
         & (o_need_wbck ? wbck_o_ready : 1'b1); 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000017 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=852-854

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000018 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=856-856
  assign wbck_o_valid = o_need_wbck & o_valid & (o_need_cmt  ? cmt_o_ready  : 1'b1);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000018 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=856-856
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000019 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=857-857
  assign cmt_o_valid  = o_need_cmt  & o_valid & (o_need_wbck ? wbck_o_ready : 1'b1);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000019 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=857-857
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:bus_cluster:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=852-857
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:handshake:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=852-857
  // 
  //  The commint interface have some special signals
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000020 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=860-860
  assign cmt_o_instr   = i_instr;  
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000020 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=860-860
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000021 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=861-861
  assign cmt_o_pc   = i_pc;  
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000021 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=861-861
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000022 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=862-862
  assign cmt_o_imm  = i_imm;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000022 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=862-862
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000023 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=863-863
  assign cmt_o_rv32 = i_info[`E203_DECINFO_RV32]; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000023 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=863-863
    // The cmt_o_pc_vld is used by the commit stage to check
    // if current instruction is outputing a valid current PC
    //   to guarante the commit to flush pipeline safely, this
    //   vld only be asserted when:
    //     * There is a valid instruction here
    //        --- otherwise, the commit stage may use wrong PC
    //             value to stored in DPC or EPC
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000024 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=871-873
  assign cmt_o_pc_vld      =
              // Otherwise, just use the i_pc_vld
                              i_pc_vld;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000024 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=871-873

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000025 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=875-876
  assign cmt_o_misalgn     = (o_sel_agu & agu_o_cmt_misalgn) 
                           ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000025 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=875-876
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000026 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=877-878
  assign cmt_o_ld          = (o_sel_agu & agu_o_cmt_ld)      
                           ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000026 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=877-878
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000027 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=879-880
  assign cmt_o_badaddr     = ({`E203_ADDR_SIZE{o_sel_agu}} & agu_o_cmt_badaddr)  
                           ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000027 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=879-880
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000028 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=881-881
  assign cmt_o_buserr      = o_sel_agu & agu_o_cmt_buserr;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000028 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=881-881
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000029 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=882-882
  assign cmt_o_stamo       = o_sel_agu & agu_o_cmt_stamo ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000029 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=882-882

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000030 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=884-884
  assign cmt_o_bjp         = o_sel_bjp & bjp_o_cmt_bjp;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000030 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=884-884
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000031 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=885-885
  assign cmt_o_mret        = o_sel_bjp & bjp_o_cmt_mret;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000031 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=885-885
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000032 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=886-886
  assign cmt_o_dret        = o_sel_bjp & bjp_o_cmt_dret;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000032 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=886-886
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000033 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=887-887
  assign cmt_o_bjp_prdt    = o_sel_bjp & bjp_o_cmt_prdt;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000033 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=887-887
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000034 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=888-888
  assign cmt_o_bjp_rslv    = o_sel_bjp & bjp_o_cmt_rslv;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000034 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=888-888
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000035 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=889-889
  assign cmt_o_fencei      = o_sel_bjp & bjp_o_cmt_fencei;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000035 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=889-889

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000036 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=891-891
  assign cmt_o_ecall       = o_sel_alu & alu_o_cmt_ecall;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000036 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=891-891
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000037 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=892-892
  assign cmt_o_ebreak      = o_sel_alu & alu_o_cmt_ebreak;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000037 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=892-892
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000038 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=893-893
  assign cmt_o_wfi         = o_sel_alu & alu_o_cmt_wfi;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000038 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=893-893
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000039 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=894-894
  assign cmt_o_ifu_misalgn = i_misalgn;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000039 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=894-894
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000040 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=895-895
  assign cmt_o_ifu_buserr  = i_buserr;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000040 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=895-895
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000041 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=896-898
  assign cmt_o_ifu_ilegl   = i_ilegl
                           | (o_sel_csr & csr_access_ilgl)
                        ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:assign:000041 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=896-898
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v:grp:assign_cluster:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu.v lines=852-898

endmodule                                      
                                               
                                               
                                               
