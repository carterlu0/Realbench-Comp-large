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
// Designer   : Bob Hu
//
// Description:
//  The Write-Back module to arbitrate the write-back request from all 
//  long pipe modules
//
// ====================================================================

`include "e203_defines.v"

module e203_exu_longpwbck(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=31-84




  //////////////////////////////////////////////////////////////
  // The LSU Write-Back Interface
  input  lsu_wbck_i_valid, // Handshake valid
  output lsu_wbck_i_ready, // Handshake ready
  input  [`E203_XLEN-1:0] lsu_wbck_i_wdat,
  input  [`E203_ITAG_WIDTH -1:0] lsu_wbck_i_itag,
  input  lsu_wbck_i_err , // The error exception generated
  input  lsu_cmt_i_buserr ,
  input  [`E203_ADDR_SIZE -1:0] lsu_cmt_i_badaddr,
  input  lsu_cmt_i_ld, 
  input  lsu_cmt_i_st, 

  //////////////////////////////////////////////////////////////
  // The Long pipe instruction Wback interface to final wbck module
  output longp_wbck_o_valid, // Handshake valid
  input  longp_wbck_o_ready, // Handshake ready
  output [`E203_FLEN-1:0] longp_wbck_o_wdat,
  output [5-1:0] longp_wbck_o_flags,
  output [`E203_RFIDX_WIDTH -1:0] longp_wbck_o_rdidx,
  output longp_wbck_o_rdfpu,
  //
  // The Long pipe instruction Exception interface to commit stage
  output  longp_excp_o_valid,
  input   longp_excp_o_ready,
  output  longp_excp_o_insterr,
  output  longp_excp_o_ld,
  output  longp_excp_o_st,
  output  longp_excp_o_buserr , // The load/store bus-error exception generated
  output [`E203_ADDR_SIZE-1:0] longp_excp_o_badaddr,
  output [`E203_PC_SIZE -1:0] longp_excp_o_pc,
  //
  //The itag of toppest entry of OITF
  input  oitf_empty,
  input  [`E203_ITAG_WIDTH -1:0] oitf_ret_ptr,
  input  [`E203_RFIDX_WIDTH-1:0] oitf_ret_rdidx,
  input  [`E203_PC_SIZE-1:0] oitf_ret_pc,
  input  oitf_ret_rdwen,   
  input  oitf_ret_rdfpu,   
  output oitf_ret_ena,
 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=75-81
  `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=75-81
  input  nice_longp_wbck_i_valid , 
  output nice_longp_wbck_i_ready ,
  input  [`E203_XLEN-1:0]  nice_longp_wbck_i_wdat ,
  input  [`E203_ITAG_WIDTH-1:0]  nice_longp_wbck_i_itag ,
  input  nice_longp_wbck_i_err,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=75-81
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=75-81

  input  clk,
  input  rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=31-84
  );


  // The Long-pipe instruction can write-back only when it's itag 
  //   is same as the itag of toppest entry of OITF
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=90-96
  wire wbck_ready4lsu = (lsu_wbck_i_itag == oitf_ret_ptr) & (~oitf_empty);
  wire wbck_sel_lsu = lsu_wbck_i_valid & wbck_ready4lsu;

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=93-96
  `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=93-96
  wire wbck_ready4nice = (nice_longp_wbck_i_itag == oitf_ret_ptr) & (~oitf_empty);
  wire wbck_sel_nice = nice_longp_wbck_i_valid & wbck_ready4nice; 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=93-96
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=93-96
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=90-96

  //assign longp_excp_o_ld   = wbck_sel_lsu & lsu_cmt_i_ld;
  //assign longp_excp_o_st   = wbck_sel_lsu & lsu_cmt_i_st;
  //assign longp_excp_o_buserr = wbck_sel_lsu & lsu_cmt_i_buserr;
  //assign longp_excp_o_badaddr = wbck_sel_lsu ? lsu_cmt_i_badaddr : `E203_ADDR_SIZE'b0;

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000001 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=103-117
  assign {
         longp_excp_o_insterr
        ,longp_excp_o_ld   
        ,longp_excp_o_st  
        ,longp_excp_o_buserr
        ,longp_excp_o_badaddr } = 
             ({`E203_ADDR_SIZE+4{wbck_sel_lsu}} & 
              {
                1'b0,
                lsu_cmt_i_ld,
                lsu_cmt_i_st,
                lsu_cmt_i_buserr,
                lsu_cmt_i_badaddr
              }) 
              ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000001 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=103-117

  //////////////////////////////////////////////////////////////
  // The Final arbitrated Write-Back Interface
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=121-129
  wire wbck_i_ready;
  wire wbck_i_valid;
  wire [`E203_FLEN-1:0] wbck_i_wdat;
  wire [5-1:0] wbck_i_flags;
  wire [`E203_RFIDX_WIDTH-1:0] wbck_i_rdidx;
  wire [`E203_PC_SIZE-1:0] wbck_i_pc;
  wire wbck_i_rdwen;
  wire wbck_i_rdfpu;
  wire wbck_i_err ;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=121-129

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=131-137
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:grp:handshake:000001 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=131-137
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000002 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=131-131
  assign lsu_wbck_i_ready = wbck_ready4lsu & wbck_i_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000002 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=131-131

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000003 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=133-137
  assign wbck_i_valid =   ({1{wbck_sel_lsu}} & lsu_wbck_i_valid)
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=134-136
                        `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=134-136
                        |  ({1{wbck_sel_nice}} & nice_longp_wbck_i_valid)
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=134-136
                        `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=134-136
                         ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000003 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=133-137
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=131-137
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:grp:handshake:000001 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=131-137
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000004 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=138-142
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000004:br:000001 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=138-139
  `ifdef E203_FLEN_IS_32 //{
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=139-145
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000004 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=138-142
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000004:br:000001 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=138-139
  wire [`E203_FLEN-1:0] lsu_wbck_i_wdat_exd = lsu_wbck_i_wdat;
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000004:br:000001 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=138-139
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000004:br:000001 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=138-139
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000004:br:000002 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=140-141
  `else//}{
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000004:br:000002 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=140-141
  wire [`E203_FLEN-1:0] lsu_wbck_i_wdat_exd = {{`E203_FLEN-`E203_XLEN{1'b0}},lsu_wbck_i_wdat};
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000004:br:000002 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=140-141
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000004:br:000002 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=140-141
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000004 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=138-142
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000004 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=138-142
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000005 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=143-145
  `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000005 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=143-145
  wire [`E203_FLEN-1:0] nice_wbck_i_wdat_exd = {{`E203_FLEN-`E203_XLEN{1'b0}},nice_longp_wbck_i_wdat};
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000005 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=143-145
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000005 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=143-145
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=139-145
  
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=147-153
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000004 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=147-151
  assign wbck_i_wdat  = ({`E203_FLEN{wbck_sel_lsu}} & lsu_wbck_i_wdat_exd )
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000006 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=148-150
                        `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000006 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=148-150
                        | ({`E203_FLEN{wbck_sel_nice}} & nice_wbck_i_wdat_exd )
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000006 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=148-150
                        `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000006 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=148-150
                         ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000004 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=147-151
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000005 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=152-153
  assign wbck_i_flags  = 5'b0
                         ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000005 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=152-153
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=147-153
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000007 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=154-156
  `ifdef E203_HAS_NICE//{
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=155-156
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000007 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=154-156
  wire nice_wbck_i_err = nice_longp_wbck_i_err;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000007 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=154-156
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000007 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=154-156
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=155-156

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=158-163
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000006 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=158-159
  assign wbck_i_err   = wbck_sel_lsu & lsu_wbck_i_err 
                         ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000006 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=158-159
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000007 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=160-160
  assign wbck_i_pc    = oitf_ret_pc;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000007 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=160-160
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000008 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=161-161
  assign wbck_i_rdidx = oitf_ret_rdidx;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000008 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=161-161
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000009 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=162-162
  assign wbck_i_rdwen = oitf_ret_rdwen;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000009 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=162-162
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000010 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=163-163
  assign wbck_i_rdfpu = oitf_ret_rdfpu;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000010 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=163-163
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=158-163

  // If the instruction have no error and it have the rdwen, then it need to 
  //   write back into regfile, otherwise, it does not need to write regfile
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:grp:internal_signal:000005 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=167-172
  wire need_wbck = wbck_i_rdwen & (~wbck_i_err);

  // If the long pipe instruction have error result, then it need to handshake
  //   with the commit module.
  wire need_excp = wbck_i_err
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000008 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=172-174
                   `ifdef E203_HAS_NICE//{
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:grp:internal_signal:000005 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=167-172
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000008 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=172-174
                   & (~ (wbck_sel_nice & nice_wbck_i_err))   
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000008 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=172-174
                   `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000008 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=172-174
                   ;

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:grp:assign_cluster:000004 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=177-192
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:grp:bus_cluster:000001 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=177-183
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:grp:handshake:000002 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=177-183
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000011 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=177-179
  assign wbck_i_ready = 
       (need_wbck ? longp_wbck_o_ready : 1'b1)
     & (need_excp ? longp_excp_o_ready : 1'b1);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000011 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=177-179


//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000012 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=182-182
  assign longp_wbck_o_valid = need_wbck & wbck_i_valid & (need_excp ? longp_excp_o_ready : 1'b1);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000012 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=182-182
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000013 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=183-183
  assign longp_excp_o_valid = need_excp & wbck_i_valid & (need_wbck ? longp_wbck_o_ready : 1'b1);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000013 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=183-183
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:grp:bus_cluster:000001 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=177-183
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:grp:handshake:000002 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=177-183

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000014 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=185-185
  assign longp_wbck_o_wdat  = wbck_i_wdat ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000014 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=185-185
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000015 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=186-186
  assign longp_wbck_o_flags = wbck_i_flags ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000015 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=186-186
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000016 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=187-187
  assign longp_wbck_o_rdfpu = wbck_i_rdfpu ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000016 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=187-187
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000017 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=188-188
  assign longp_wbck_o_rdidx = wbck_i_rdidx;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000017 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=188-188

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000018 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=190-190
  assign longp_excp_o_pc    = wbck_i_pc;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000018 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=190-190

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000019 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=192-192
  assign oitf_ret_ena = wbck_i_valid & wbck_i_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000019 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=192-192
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:grp:assign_cluster:000004 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=177-192

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000009 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=194-196
  `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000009 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=194-196
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000020 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=195-195
  assign nice_longp_wbck_i_ready = wbck_ready4nice & wbck_i_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:assign:000020 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=195-195
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000009 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=194-196
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v:pp_blk:000009 file=e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v lines=194-196

endmodule                                      
                                               
                                               
                                               
