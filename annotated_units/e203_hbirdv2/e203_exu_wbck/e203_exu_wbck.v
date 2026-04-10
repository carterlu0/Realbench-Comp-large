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
//  The Write-Back module to arbitrate the write-back request to regfile
//
// ====================================================================

`include "e203_defines.v"

module e203_exu_wbck(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=31-59

  //////////////////////////////////////////////////////////////
  // The ALU Write-Back Interface
  input  alu_wbck_i_valid, // Handshake valid
  output alu_wbck_i_ready, // Handshake ready
  input  [`E203_XLEN-1:0] alu_wbck_i_wdat,
  input  [`E203_RFIDX_WIDTH-1:0] alu_wbck_i_rdidx,
  // If ALU have error, it will not generate the wback_valid to wback module
      // so we dont need the alu_wbck_i_err here

  //////////////////////////////////////////////////////////////
  // The Longp Write-Back Interface
  input  longp_wbck_i_valid, // Handshake valid
  output longp_wbck_i_ready, // Handshake ready
  input  [`E203_FLEN-1:0] longp_wbck_i_wdat,
  input  [5-1:0] longp_wbck_i_flags,
  input  [`E203_RFIDX_WIDTH-1:0] longp_wbck_i_rdidx,
  input  longp_wbck_i_rdfpu,

  //////////////////////////////////////////////////////////////
  // The Final arbitrated Write-Back Interface to Regfile
  output  rf_wbck_o_ena,
  output  [`E203_XLEN-1:0] rf_wbck_o_wdat,
  output  [`E203_RFIDX_WIDTH-1:0] rf_wbck_o_rdidx,


  
  input  clk,
  input  rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=31-59
  );


  // The ALU instruction can write-back only when there is no any 
  //  long pipeline instruction writing-back
  //    * Since ALU is the 1 cycle instructions, it have lowest 
  //      priority in arbitration
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=67-84
  wire wbck_ready4alu = (~longp_wbck_i_valid);
  wire wbck_sel_alu = alu_wbck_i_valid & wbck_ready4alu;
  // The Long-pipe instruction can always write-back since it have high priority 
  wire wbck_ready4longp = 1'b1;
  wire wbck_sel_longp = longp_wbck_i_valid & wbck_ready4longp;



  //////////////////////////////////////////////////////////////
  // The Final arbitrated Write-Back Interface
  wire rf_wbck_o_ready = 1'b1; // Regfile is always ready to be write because it just has 1 w-port

  wire wbck_i_ready;
  wire wbck_i_valid;
  wire [`E203_FLEN-1:0] wbck_i_wdat;
  wire [5-1:0] wbck_i_flags;
  wire [`E203_RFIDX_WIDTH-1:0] wbck_i_rdidx;
  wire wbck_i_rdfpu;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=67-84

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=86-89
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:grp:handshake:000001 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=86-89
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:assign:000001 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=86-86
  assign alu_wbck_i_ready   = wbck_ready4alu   & wbck_i_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:assign:000001 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=86-86
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:assign:000002 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=87-87
  assign longp_wbck_i_ready = wbck_ready4longp & wbck_i_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:assign:000002 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=87-87

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:assign:000003 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=89-89
  assign wbck_i_valid = wbck_sel_alu ? alu_wbck_i_valid : longp_wbck_i_valid;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:assign:000003 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=89-89
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=86-89
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:grp:handshake:000001 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=86-89
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=90-94
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:pp_blk:000001:br:000001 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=90-91
  `ifdef E203_FLEN_IS_32//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=90-94
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:pp_blk:000001:br:000001 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=90-91
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:assign:000004 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=91-91
  assign wbck_i_wdat  = wbck_sel_alu ? alu_wbck_i_wdat  : longp_wbck_i_wdat;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:assign:000004 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=91-91
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:pp_blk:000001:br:000001 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=90-91
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:pp_blk:000001:br:000001 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=90-91
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:pp_blk:000001:br:000002 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=92-93
  `else//}{
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:pp_blk:000001:br:000002 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=92-93
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:assign:000005 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=93-93
  assign wbck_i_wdat  = wbck_sel_alu ? {{`E203_FLEN-`E203_XLEN{1'b0}},alu_wbck_i_wdat}  : longp_wbck_i_wdat;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:assign:000005 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=93-93
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:pp_blk:000001:br:000002 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=92-93
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:pp_blk:000001:br:000002 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=92-93
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=90-94
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=90-94
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=95-102
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:assign:000006 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=95-95
  assign wbck_i_flags = wbck_sel_alu ? 5'b0  : longp_wbck_i_flags;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:assign:000006 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=95-95
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:assign:000007 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=96-96
  assign wbck_i_rdidx = wbck_sel_alu ? alu_wbck_i_rdidx : longp_wbck_i_rdidx;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:assign:000007 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=96-96
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:assign:000008 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=97-97
  assign wbck_i_rdfpu = wbck_sel_alu ? 1'b0 : longp_wbck_i_rdfpu;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:assign:000008 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=97-97

  // If it have error or non-rdwen it will not be send to this module
  //   instead have been killed at EU level, so it is always need to 
  //   write back into regfile at here
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:assign:000009 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=102-102
  assign wbck_i_ready  = rf_wbck_o_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:assign:000009 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=102-102
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=95-102
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=103-105
  wire rf_wbck_o_valid = wbck_i_valid;

  wire wbck_o_ena   = rf_wbck_o_valid & rf_wbck_o_ready;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=103-105

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=107-109
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:assign:000010 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=107-107
  assign rf_wbck_o_ena   = wbck_o_ena & (~wbck_i_rdfpu);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:assign:000010 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=107-107
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:assign:000011 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=108-108
  assign rf_wbck_o_wdat  = wbck_i_wdat[`E203_XLEN-1:0];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:assign:000011 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=108-108
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:assign:000012 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=109-109
  assign rf_wbck_o_rdidx = wbck_i_rdidx;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:assign:000012 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=109-109
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_exu_wbck/e203_exu_wbck.v lines=107-109


endmodule                                      
                                               
                                               
                                               
