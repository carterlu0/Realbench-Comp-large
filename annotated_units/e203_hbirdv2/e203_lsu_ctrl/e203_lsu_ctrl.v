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
//  The lsu_ctrl module control the LSU access requests 
//
// ====================================================================
`include "e203_defines.v"

module e203_lsu_ctrl(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:port_section:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=29-204
  input  commit_mret,
  input  commit_trap,
  output lsu_ctrl_active,
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=32-34
  `ifdef E203_HAS_ITCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=32-34
  input [`E203_ADDR_SIZE-1:0] itcm_region_indic,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=32-34
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=32-34
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=35-37
  `ifdef E203_HAS_DTCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=35-37
  input [`E203_ADDR_SIZE-1:0] dtcm_region_indic,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=35-37
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=35-37

  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // The LSU Write-Back Interface
  output lsu_o_valid, // Handshake valid
  input  lsu_o_ready, // Handshake ready
  output [`E203_XLEN-1:0] lsu_o_wbck_wdat,
  output [`E203_ITAG_WIDTH -1:0] lsu_o_wbck_itag,
  output lsu_o_wbck_err , // The error no need to write back regfile
  output lsu_o_cmt_buserr, // The bus-error exception generated
  output [`E203_ADDR_SIZE -1:0] lsu_o_cmt_badaddr,
  output lsu_o_cmt_ld,
  output lsu_o_cmt_st,
  

  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // The AGU ICB Interface to LSU-ctrl
  //    * Bus cmd channel
  input                          agu_icb_cmd_valid, // Handshake valid
  output                         agu_icb_cmd_ready, // Handshake ready
  input  [`E203_ADDR_SIZE-1:0]   agu_icb_cmd_addr, // Bus transaction start addr 
  input                          agu_icb_cmd_read,   // Read or write
  input  [`E203_XLEN-1:0]        agu_icb_cmd_wdata, 
  input  [`E203_XLEN/8-1:0]      agu_icb_cmd_wmask, 
  input                          agu_icb_cmd_lock,
  input                          agu_icb_cmd_excl,
  input  [1:0]                   agu_icb_cmd_size,
           // Several additional side channel signals
           //   Indicate LSU-ctrl module to
           //     return the ICB response channel back to AGU
           //     this is only used by AMO or unaligned load/store 1st uop
           //     to return the response
  input                          agu_icb_cmd_back2agu, 
           //   Sign extension or not
  input                          agu_icb_cmd_usign,
           //   RD Regfile index
  input  [`E203_ITAG_WIDTH -1:0] agu_icb_cmd_itag,

  //    * Bus RSP channel
  output                         agu_icb_rsp_valid, // Response valid 
  input                          agu_icb_rsp_ready, // Response ready
  output                         agu_icb_rsp_err  , // Response error
  output                         agu_icb_rsp_excl_ok,// Response exclusive okay
  output [`E203_XLEN-1:0]        agu_icb_rsp_rdata,

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000003 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=84-106
`ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000003 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=84-106
  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // The NICE ICB Interface to LSU-ctrl
  input                          nice_mem_holdup,
  //    * Bus cmd channel
  input                          nice_icb_cmd_valid,
  output                         nice_icb_cmd_ready,
  input  [`E203_ADDR_SIZE-1:0]   nice_icb_cmd_addr, 
  input                          nice_icb_cmd_read, 
  input  [`E203_XLEN-1:0]        nice_icb_cmd_wdata,
  input  [`E203_XLEN/8-1:0]      nice_icb_cmd_wmask,
  input                          nice_icb_cmd_lock,
  input                          nice_icb_cmd_excl,
  input  [1:0]                   nice_icb_cmd_size,

  //    * Bus RSP channel
  output                         nice_icb_rsp_valid,
  input                          nice_icb_rsp_ready,
  output                         nice_icb_rsp_err  ,
  output                         nice_icb_rsp_excl_ok,
  output [`E203_XLEN-1:0]        nice_icb_rsp_rdata,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000003 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=84-106
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000003 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=84-106


//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000004 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=109-131
  `ifdef E203_HAS_DCACHE //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000004 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=109-131
  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // The ICB Interface to DCache
  //
  //    * Bus cmd channel
  output                         dcache_icb_cmd_valid,
  input                          dcache_icb_cmd_ready,
  output [`E203_ADDR_SIZE-1:0]   dcache_icb_cmd_addr, 
  output                         dcache_icb_cmd_read, 
  output [`E203_XLEN-1:0]        dcache_icb_cmd_wdata,
  output [`E203_XLEN/8-1:0]      dcache_icb_cmd_wmask,
  output                         dcache_icb_cmd_lock,
  output                         dcache_icb_cmd_excl,
  output [1:0]                   dcache_icb_cmd_size,
  //
  //    * Bus RSP channel
  input                          dcache_icb_rsp_valid,
  output                         dcache_icb_rsp_ready,
  input                          dcache_icb_rsp_err  ,
  output                         dcache_icb_rsp_excl_ok,
  input  [`E203_XLEN-1:0]        dcache_icb_rsp_rdata,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000004 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=109-131
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000004 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=109-131

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000005 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=133-155
  `ifdef E203_HAS_DTCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000005 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=133-155
  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // The ICB Interface to DTCM
  //
  //    * Bus cmd channel
  output                         dtcm_icb_cmd_valid,
  input                          dtcm_icb_cmd_ready,
  output [`E203_DTCM_ADDR_WIDTH-1:0]   dtcm_icb_cmd_addr, 
  output                         dtcm_icb_cmd_read, 
  output [`E203_XLEN-1:0]        dtcm_icb_cmd_wdata,
  output [`E203_XLEN/8-1:0]      dtcm_icb_cmd_wmask,
  output                         dtcm_icb_cmd_lock,
  output                         dtcm_icb_cmd_excl,
  output [1:0]                   dtcm_icb_cmd_size,
  //
  //    * Bus RSP channel
  input                          dtcm_icb_rsp_valid,
  output                         dtcm_icb_rsp_ready,
  input                          dtcm_icb_rsp_err  ,
  input                          dtcm_icb_rsp_excl_ok,
  input  [`E203_XLEN-1:0]        dtcm_icb_rsp_rdata,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000005 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=133-155
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000005 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=133-155

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000006 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=157-179
  `ifdef E203_HAS_ITCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000006 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=157-179
  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // The ICB Interface to ITCM
  //
  //    * Bus cmd channel
  output                         itcm_icb_cmd_valid,
  input                          itcm_icb_cmd_ready,
  output [`E203_ITCM_ADDR_WIDTH-1:0]   itcm_icb_cmd_addr, 
  output                         itcm_icb_cmd_read, 
  output [`E203_XLEN-1:0]        itcm_icb_cmd_wdata,
  output [`E203_XLEN/8-1:0]      itcm_icb_cmd_wmask,
  output                         itcm_icb_cmd_lock,
  output                         itcm_icb_cmd_excl,
  output [1:0]                   itcm_icb_cmd_size,
  //
  //    * Bus RSP channel
  input                          itcm_icb_rsp_valid,
  output                         itcm_icb_rsp_ready,
  input                          itcm_icb_rsp_err  ,
  input                          itcm_icb_rsp_excl_ok  ,
  input  [`E203_XLEN-1:0]        itcm_icb_rsp_rdata,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000006 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=157-179
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000006 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=157-179

  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // The ICB Interface to BIU
  //
  //    * Bus cmd channel
  output                         biu_icb_cmd_valid,
  input                          biu_icb_cmd_ready,
  output [`E203_ADDR_SIZE-1:0]   biu_icb_cmd_addr, 
  output                         biu_icb_cmd_read, 
  output [`E203_XLEN-1:0]        biu_icb_cmd_wdata,
  output [`E203_XLEN/8-1:0]      biu_icb_cmd_wmask,
  output                         biu_icb_cmd_lock,
  output                         biu_icb_cmd_excl,
  output [1:0]                   biu_icb_cmd_size,
  //
  //    * Bus RSP channel
  input                          biu_icb_rsp_valid,
  output                         biu_icb_rsp_ready,
  input                          biu_icb_rsp_err  ,
  input                          biu_icb_rsp_excl_ok  ,
  input  [`E203_XLEN-1:0]        biu_icb_rsp_rdata,

  input  clk,
  input  rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:port_section:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=29-204
  );

  // The NICE mem holdup signal will override other request to LSU-Ctrl
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=208-209
  wire agu_icb_cmd_valid_pos;
  wire agu_icb_cmd_ready_pos;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=208-209
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=210-219
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:handshake:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=210-219
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=210-214
  assign agu_icb_cmd_valid_pos = agu_icb_cmd_valid
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000007 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=211-213
                                 `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000007 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=211-213
                                 & (~nice_mem_holdup)
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000007 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=211-213
                                 `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000007 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=211-213
                                 ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=210-214
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=215-219
  assign agu_icb_cmd_ready     = agu_icb_cmd_ready_pos
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000008 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=216-218
                                 `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000008 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=216-218
                                 & (~nice_mem_holdup)
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000008 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=216-218
                                 `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000008 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=216-218
                                 ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=215-219
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=210-219
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:handshake:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=210-219

//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000011 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=221-229
`ifndef E203_HAS_FPU
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:param_decl:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=222-238
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000011 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=221-229
  localparam LSU_ARBT_I_PTR_W = 1;
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000009 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=223-225
`ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000009 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=223-225
  localparam LSU_ARBT_I_NUM   = 2;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000009 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=223-225
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000009 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=223-225
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000010 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=226-228
`ifndef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000010 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=226-228
  localparam LSU_ARBT_I_NUM   = 1;
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000010 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=226-228
`endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000010 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=226-228
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000011 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=221-229
`endif
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000011 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=221-229

  
  // NOTE:
  //   * PPI is a must to have
  //   * Either DCache, ITCM, DTCM or SystemITF is must to have
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000015 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=235-244
  `ifndef E203_HAS_DTCM //{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000015 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=235-244
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000014 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=236-243
    `ifndef E203_HAS_DCACHE //{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000014 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=236-243
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000013 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=237-242
      `ifndef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000013 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=237-242
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000012 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=238-241
        `ifndef E203_HAS_ITCM //{
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:param_decl:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=222-238
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000012 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=238-241
      !!! ERROR: There must be something wrong, Either DCache, DTCM, ITCM or SystemITF is must to have. 
                 Otherwise where to access the data?
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000012 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=238-241
        `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000012 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=238-241
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000013 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=237-242
      `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000013 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=237-242
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000014 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=236-243
    `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000014 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=236-243
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000015 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=235-244
  `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000015 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=235-244
  //


//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000016 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=248-253
`ifdef E203_HAS_NICE//{
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=249-249
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000016 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=248-253
  wire [`E203_XLEN_MW-1:0] nice_icb_cmd_wr_mask = 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=249-249
            ({`E203_XLEN_MW{nice_icb_cmd_size == 2'b00 }} & (4'b0001 << nice_icb_cmd_addr[1:0]))
          | ({`E203_XLEN_MW{nice_icb_cmd_size == 2'b01 }} & (4'b0011 << {nice_icb_cmd_addr[1],1'b0}))
          | ({`E203_XLEN_MW{nice_icb_cmd_size == 2'b10 }} & (4'b1111));
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000016 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=248-253
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000016 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=248-253

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=255-267
  wire                  pre_agu_icb_rsp_valid;
  wire                  pre_agu_icb_rsp_ready;
  wire                  pre_agu_icb_rsp_err  ;
  wire                  pre_agu_icb_rsp_excl_ok;
  wire [`E203_XLEN-1:0] pre_agu_icb_rsp_rdata;

  wire                         pre_agu_icb_rsp_back2agu; 
  wire                         pre_agu_icb_rsp_usign;
  wire                         pre_agu_icb_rsp_read;
  wire                         pre_agu_icb_rsp_excl;
  wire [2-1:0]                 pre_agu_icb_rsp_size;
  wire [`E203_ITAG_WIDTH -1:0] pre_agu_icb_rsp_itag;
  wire [`E203_ADDR_SIZE-1:0]   pre_agu_icb_rsp_addr;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=255-267

//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:param_decl:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=269-270
  localparam USR_W = (`E203_ITAG_WIDTH+6+`E203_ADDR_SIZE);
  localparam USR_PACK_EXCL = 0;// The cmd_excl is in the user 0 bit
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:param_decl:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=269-270
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=271-271
  wire [USR_W-1:0] agu_icb_cmd_usr =
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=271-271
      {
         agu_icb_cmd_back2agu  
        ,agu_icb_cmd_usign
        ,agu_icb_cmd_read
        ,agu_icb_cmd_size
        ,agu_icb_cmd_itag 
        ,agu_icb_cmd_addr 
        ,agu_icb_cmd_excl 
      };

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000017 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=282-284
`ifdef E203_HAS_NICE//{
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000005 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=283-288
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000017 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=282-284
  wire [USR_W-1:0] nice_icb_cmd_usr = {USR_W-1{1'b0}};
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000017 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=282-284
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000017 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=282-284

  wire [USR_W-1:0] fpu_icb_cmd_usr = {USR_W-1{1'b0}};

  wire [USR_W-1:0]      pre_agu_icb_rsp_usr;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000005 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=283-288

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000003 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=290-299
  assign 
      {
         pre_agu_icb_rsp_back2agu  
        ,pre_agu_icb_rsp_usign
        ,pre_agu_icb_rsp_read
        ,pre_agu_icb_rsp_size
        ,pre_agu_icb_rsp_itag 
        ,pre_agu_icb_rsp_addr
        ,pre_agu_icb_rsp_excl 
      } = pre_agu_icb_rsp_usr;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000003 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=290-299

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000018 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=301-303
`ifdef E203_HAS_NICE//{
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000006 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=302-348
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000018 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=301-303
  wire [USR_W-1:0] nice_icb_rsp_usr;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000018 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=301-303
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000018 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=301-303

  wire [USR_W-1:0] fpu_icb_rsp_usr;

  wire arbt_icb_cmd_valid;
  wire arbt_icb_cmd_ready;
  wire [`E203_ADDR_SIZE-1:0] arbt_icb_cmd_addr;
  wire arbt_icb_cmd_read;
  wire [`E203_XLEN-1:0] arbt_icb_cmd_wdata;
  wire [`E203_XLEN/8-1:0] arbt_icb_cmd_wmask;
  wire arbt_icb_cmd_lock;
  wire arbt_icb_cmd_excl;
  wire [1:0] arbt_icb_cmd_size;
  wire [1:0] arbt_icb_cmd_burst;
  wire [1:0] arbt_icb_cmd_beat;
  wire [USR_W-1:0] arbt_icb_cmd_usr;

  wire arbt_icb_rsp_valid;
  wire arbt_icb_rsp_ready;
  wire arbt_icb_rsp_err;
  wire arbt_icb_rsp_excl_ok;
  wire [`E203_XLEN-1:0] arbt_icb_rsp_rdata;
  wire [USR_W-1:0] arbt_icb_rsp_usr;

  wire [LSU_ARBT_I_NUM*1-1:0] arbt_bus_icb_cmd_valid;
  wire [LSU_ARBT_I_NUM*1-1:0] arbt_bus_icb_cmd_ready;
  wire [LSU_ARBT_I_NUM*`E203_ADDR_SIZE-1:0] arbt_bus_icb_cmd_addr;
  wire [LSU_ARBT_I_NUM*1-1:0] arbt_bus_icb_cmd_read;
  wire [LSU_ARBT_I_NUM*`E203_XLEN-1:0] arbt_bus_icb_cmd_wdata;
  wire [LSU_ARBT_I_NUM*`E203_XLEN/8-1:0] arbt_bus_icb_cmd_wmask;
  wire [LSU_ARBT_I_NUM*1-1:0] arbt_bus_icb_cmd_lock;
  wire [LSU_ARBT_I_NUM*1-1:0] arbt_bus_icb_cmd_excl;
  wire [LSU_ARBT_I_NUM*2-1:0] arbt_bus_icb_cmd_size;
  wire [LSU_ARBT_I_NUM*USR_W-1:0] arbt_bus_icb_cmd_usr;
  wire [LSU_ARBT_I_NUM*2-1:0] arbt_bus_icb_cmd_burst;
  wire [LSU_ARBT_I_NUM*2-1:0] arbt_bus_icb_cmd_beat;

  wire [LSU_ARBT_I_NUM*1-1:0] arbt_bus_icb_rsp_valid;
  wire [LSU_ARBT_I_NUM*1-1:0] arbt_bus_icb_rsp_ready;
  wire [LSU_ARBT_I_NUM*1-1:0] arbt_bus_icb_rsp_err;
  wire [LSU_ARBT_I_NUM*1-1:0] arbt_bus_icb_rsp_excl_ok;
  wire [LSU_ARBT_I_NUM*`E203_XLEN-1:0] arbt_bus_icb_rsp_rdata;
  wire [LSU_ARBT_I_NUM*USR_W-1:0] arbt_bus_icb_rsp_usr;

  //CMD Channel
  wire [LSU_ARBT_I_NUM*1-1:0] arbt_bus_icb_cmd_valid_raw;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000006 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=302-348
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=349-497
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:bus_cluster:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=349-497
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:handshake:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=349-365
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000004 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=349-356
  assign arbt_bus_icb_cmd_valid_raw =
      // The NICE take higher priority
                           {
                             agu_icb_cmd_valid
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000019 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=353-355
                           `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000019 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=353-355
                           , nice_icb_cmd_valid
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000019 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=353-355
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000019 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=353-355
                           } ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000004 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=349-356

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000005 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=358-365
  assign arbt_bus_icb_cmd_valid =
      // The NICE take higher priority
                           {
                             agu_icb_cmd_valid_pos
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000020 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=362-364
                           `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000020 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=362-364
                           , nice_icb_cmd_valid
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000020 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=362-364
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000020 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=362-364
                           } ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000005 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=358-365
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:handshake:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=349-365

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000006 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=367-373
  assign arbt_bus_icb_cmd_addr =
                           {
                             agu_icb_cmd_addr
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000021 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=370-372
                           `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000021 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=370-372
                           , nice_icb_cmd_addr
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000021 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=370-372
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000021 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=370-372
                           } ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000006 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=367-373

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000007 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=375-381
  assign arbt_bus_icb_cmd_read =
                           {
                             agu_icb_cmd_read
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000022 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=378-380
                           `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000022 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=378-380
                           , nice_icb_cmd_read
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000022 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=378-380
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000022 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=378-380
                           } ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000007 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=375-381

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000008 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=383-389
  assign arbt_bus_icb_cmd_wdata =
                           {
                             agu_icb_cmd_wdata
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000023 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=386-388
                           `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000023 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=386-388
                           , nice_icb_cmd_wdata
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000023 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=386-388
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000023 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=386-388
                           } ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000008 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=383-389

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000009 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=391-397
  assign arbt_bus_icb_cmd_wmask =
                           {
                             agu_icb_cmd_wmask
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000024 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=394-396
                           `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000024 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=394-396
                           ,nice_icb_cmd_wr_mask
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000024 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=394-396
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000024 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=394-396
                           } ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000009 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=391-397
                         
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000010 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=399-405
  assign arbt_bus_icb_cmd_lock =
                           {
                             agu_icb_cmd_lock
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000025 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=402-404
                           `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000025 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=402-404
                           , nice_icb_cmd_lock
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000025 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=402-404
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000025 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=402-404
                           } ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000010 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=399-405

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000011 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=407-413
  assign arbt_bus_icb_cmd_burst =
                           {
                             2'b0
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000026 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=410-412
                           `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000026 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=410-412
                           , 2'b0
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000026 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=410-412
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000026 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=410-412
                           } ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000011 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=407-413

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000012 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=415-421
  assign arbt_bus_icb_cmd_beat =
                           {
                             1'b0
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000027 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=418-420
                           `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000027 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=418-420
                           , 1'b0
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000027 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=418-420
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000027 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=418-420
                           } ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000012 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=415-421

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000013 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=423-429
  assign arbt_bus_icb_cmd_excl =
                           {
                             agu_icb_cmd_excl
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000028 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=426-428
                           `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000028 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=426-428
                           , nice_icb_cmd_excl
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000028 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=426-428
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000028 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=426-428
                           } ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000013 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=423-429
                           
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000014 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=431-437
  assign arbt_bus_icb_cmd_size =
                           {
                             agu_icb_cmd_size
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000029 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=434-436
                           `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000029 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=434-436
                           , nice_icb_cmd_size
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000029 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=434-436
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000029 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=434-436
                           } ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000014 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=431-437

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000015 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=439-445
  assign arbt_bus_icb_cmd_usr =
                           {
                             agu_icb_cmd_usr
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000030 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=442-444
                           `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000030 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=442-444
                           , nice_icb_cmd_usr
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000030 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=442-444
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000030 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=442-444
                           } ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000015 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=439-445

//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:handshake:000003 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=447-461
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000016 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=447-452
  assign                   {
                             agu_icb_cmd_ready_pos
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000031 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=449-451
                           `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000031 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=449-451
                           , nice_icb_cmd_ready
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000031 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=449-451
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000031 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=449-451
                           } = arbt_bus_icb_cmd_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000016 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=447-452
                           

  //RSP Channel
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000017 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=456-461
  assign                   {
                             pre_agu_icb_rsp_valid
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000032 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=458-460
                           `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000032 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=458-460
                           , nice_icb_rsp_valid
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000032 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=458-460
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000032 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=458-460
                           } = arbt_bus_icb_rsp_valid;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000017 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=456-461
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:handshake:000003 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=447-461

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000018 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=463-468
  assign                   {
                             pre_agu_icb_rsp_err
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000033 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=465-467
                           `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000033 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=465-467
                           , nice_icb_rsp_err
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000033 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=465-467
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000033 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=465-467
                           } = arbt_bus_icb_rsp_err;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000018 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=463-468

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000019 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=470-475
  assign                   {
                             pre_agu_icb_rsp_excl_ok
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000034 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=472-474
                           `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000034 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=472-474
                           , nice_icb_rsp_excl_ok
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000034 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=472-474
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000034 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=472-474
                           } = arbt_bus_icb_rsp_excl_ok;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000019 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=470-475


//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000020 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=478-483
  assign                   {
                             pre_agu_icb_rsp_rdata
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000035 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=480-482
                           `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000035 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=480-482
                           , nice_icb_rsp_rdata
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000035 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=480-482
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000035 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=480-482
                           } = arbt_bus_icb_rsp_rdata;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000020 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=478-483

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000021 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=485-490
  assign                   {
                             pre_agu_icb_rsp_usr
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000036 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=487-489
                           `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000036 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=487-489
                           , nice_icb_rsp_usr
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000036 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=487-489
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000036 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=487-489
                           } = arbt_bus_icb_rsp_usr;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000021 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=485-490

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000022 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=492-497
  assign arbt_bus_icb_rsp_ready = {
                             pre_agu_icb_rsp_ready
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000037 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=494-496
                           `ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000037 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=494-496
                           , nice_icb_rsp_ready
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000037 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=494-496
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000037 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=494-496
                           };
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000022 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=492-497
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=349-497
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:bus_cluster:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=349-497

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:inst:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=499-554
  sirv_gnrl_icb_arbt # (
  .ARBT_SCHEME (0),// Priority based
  .ALLOW_0CYCL_RSP (0),// Dont allow the 0 cycle response because in BIU we always have CMD_DP larger than 0
                       //   when the response come back from the external bus, it is at least 1 cycle later
                       //   for ITCM and DTCM, Dcache, .etc, definitely they cannot reponse as 0 cycle
  .FIFO_OUTS_NUM   (`E203_LSU_OUTS_NUM),
  .FIFO_CUT_READY  (0),
  .ARBT_NUM   (LSU_ARBT_I_NUM),
  .ARBT_PTR_W (LSU_ARBT_I_PTR_W),
  .USR_W      (USR_W),
  .AW         (`E203_ADDR_SIZE),
  .DW         (`E203_XLEN) 
  ) u_lsu_icb_arbt(
  .o_icb_cmd_valid        (arbt_icb_cmd_valid )     ,
  .o_icb_cmd_ready        (arbt_icb_cmd_ready )     ,
  .o_icb_cmd_read         (arbt_icb_cmd_read )      ,
  .o_icb_cmd_addr         (arbt_icb_cmd_addr )      ,
  .o_icb_cmd_wdata        (arbt_icb_cmd_wdata )     ,
  .o_icb_cmd_wmask        (arbt_icb_cmd_wmask)      ,
  .o_icb_cmd_burst        (arbt_icb_cmd_burst)     ,
  .o_icb_cmd_beat         (arbt_icb_cmd_beat )     ,
  .o_icb_cmd_excl         (arbt_icb_cmd_excl )     ,
  .o_icb_cmd_lock         (arbt_icb_cmd_lock )     ,
  .o_icb_cmd_size         (arbt_icb_cmd_size )     ,
  .o_icb_cmd_usr          (arbt_icb_cmd_usr  )     ,
                                
  .o_icb_rsp_valid        (arbt_icb_rsp_valid )     ,
  .o_icb_rsp_ready        (arbt_icb_rsp_ready )     ,
  .o_icb_rsp_err          (arbt_icb_rsp_err)        ,
  .o_icb_rsp_excl_ok      (arbt_icb_rsp_excl_ok)    ,
  .o_icb_rsp_rdata        (arbt_icb_rsp_rdata )     ,
  .o_icb_rsp_usr          (arbt_icb_rsp_usr   )     ,
                               
  .i_bus_icb_cmd_ready    (arbt_bus_icb_cmd_ready ) ,
  .i_bus_icb_cmd_valid    (arbt_bus_icb_cmd_valid ) ,
  .i_bus_icb_cmd_read     (arbt_bus_icb_cmd_read )  ,
  .i_bus_icb_cmd_addr     (arbt_bus_icb_cmd_addr )  ,
  .i_bus_icb_cmd_wdata    (arbt_bus_icb_cmd_wdata ) ,
  .i_bus_icb_cmd_wmask    (arbt_bus_icb_cmd_wmask)  ,
  .i_bus_icb_cmd_burst    (arbt_bus_icb_cmd_burst)  ,
  .i_bus_icb_cmd_beat     (arbt_bus_icb_cmd_beat )  ,
  .i_bus_icb_cmd_excl     (arbt_bus_icb_cmd_excl )  ,
  .i_bus_icb_cmd_lock     (arbt_bus_icb_cmd_lock )  ,
  .i_bus_icb_cmd_size     (arbt_bus_icb_cmd_size )  ,
  .i_bus_icb_cmd_usr      (arbt_bus_icb_cmd_usr  )  ,
                                
  .i_bus_icb_rsp_valid    (arbt_bus_icb_rsp_valid ) ,
  .i_bus_icb_rsp_ready    (arbt_bus_icb_rsp_ready ) ,
  .i_bus_icb_rsp_err      (arbt_bus_icb_rsp_err)    ,
  .i_bus_icb_rsp_excl_ok  (arbt_bus_icb_rsp_excl_ok),
  .i_bus_icb_rsp_rdata    (arbt_bus_icb_rsp_rdata ) ,
  .i_bus_icb_rsp_usr      (arbt_bus_icb_rsp_usr) ,
                             
  .clk                    (clk  ),
  .rst_n                  (rst_n)
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:inst:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=499-554



  /////////////////////////////////////////////////////////////////////////////////
  // Implement a FIFO to save the outstanding info
  //
  //  * The FIFO will be pushed when a ICB CMD handshaked
  //  * The FIFO will be poped  when a ICB RSP handshaked
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000038 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=563-567
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000038:br:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=563-564
  `ifdef E203_HAS_ITCM //{
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000007 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=564-595
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000038 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=563-567
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000038:br:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=563-564
  wire arbt_icb_cmd_itcm = (arbt_icb_cmd_addr[`E203_ITCM_BASE_REGION] ==  itcm_region_indic[`E203_ITCM_BASE_REGION]);
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000038:br:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=563-564
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000038:br:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=563-564
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000038:br:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=565-566
  `else//}{
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000038:br:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=565-566
  wire arbt_icb_cmd_itcm = 1'b0;
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000038:br:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=565-566
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000038:br:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=565-566
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000038 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=563-567
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000038 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=563-567
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000039 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=568-572
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000039:br:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=568-569
  `ifdef E203_HAS_DTCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000039 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=568-572
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000039:br:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=568-569
  wire arbt_icb_cmd_dtcm = (arbt_icb_cmd_addr[`E203_DTCM_BASE_REGION] ==  dtcm_region_indic[`E203_DTCM_BASE_REGION]);
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000039:br:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=568-569
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000039:br:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=568-569
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000039:br:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=570-571
  `else//}{
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000039:br:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=570-571
  wire arbt_icb_cmd_dtcm = 1'b0;
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000039:br:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=570-571
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000039:br:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=570-571
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000039 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=568-572
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000039 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=568-572
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000040 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=573-577
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000040:br:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=573-574
  `ifdef E203_HAS_DCACHE //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000040 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=573-577
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000040:br:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=573-574
  wire arbt_icb_cmd_dcache = (arbt_icb_cmd_addr[`E203_DCACHE_BASE_REGION] ==  dcache_region_indic[`E203_DCACHE_BASE_REGION]);
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000040:br:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=573-574
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000040:br:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=573-574
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000040:br:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=575-576
  `else//}{
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000040:br:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=575-576
  wire arbt_icb_cmd_dcache = 1'b0;
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000040:br:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=575-576
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000040:br:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=575-576
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000040 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=573-577
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000040 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=573-577

  wire arbt_icb_cmd_biu    = (~arbt_icb_cmd_itcm) & (~arbt_icb_cmd_dtcm) & (~arbt_icb_cmd_dcache);

  wire splt_fifo_wen = arbt_icb_cmd_valid & arbt_icb_cmd_ready;
  wire splt_fifo_ren = arbt_icb_rsp_valid & arbt_icb_rsp_ready;

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000041 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=584-609
  `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000041 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=584-609
       // In E200 single core config, we always assume the store-condition is checked by the core itself
       //    because no other core to race
       
  wire excl_flg_r;
  wire [`E203_ADDR_SIZE-1:0] excl_addr_r;
  wire icb_cmdaddr_eq_excladdr = (arbt_icb_cmd_addr == excl_addr_r);
  // Set when the Excl-load instruction going
  wire excl_flg_set = splt_fifo_wen & arbt_icb_cmd_usr[USR_PACK_EXCL] & arbt_icb_cmd_read & arbt_icb_cmd_excl;
  // Clear when any going store hit the same address
  //   also clear if there is any trap happened
  wire excl_flg_clr = (splt_fifo_wen & (~arbt_icb_cmd_read) & icb_cmdaddr_eq_excladdr & excl_flg_r) 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000007 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=564-595
                    | commit_trap | commit_mret;
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000008 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=597-598
  wire excl_flg_ena = excl_flg_set | excl_flg_clr;
  wire excl_flg_nxt = excl_flg_set | (~excl_flg_clr);
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000008 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=597-598
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:inst:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=599-599
  sirv_gnrl_dfflr #(1) excl_flg_dffl (excl_flg_ena, excl_flg_nxt, excl_flg_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:inst:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=599-599
  //
  // The address is set when excl-load instruction going
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000009 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=602-603
  wire excl_addr_ena = excl_flg_set;
  wire [`E203_ADDR_SIZE-1:0] excl_addr_nxt = arbt_icb_cmd_addr;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000009 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=602-603
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:inst:000003 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=604-604
  sirv_gnrl_dfflr #(`E203_ADDR_SIZE) excl_addr_dffl (excl_addr_ena, excl_addr_nxt, excl_addr_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:inst:000003 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=604-604

  // For excl-store (scond) instruction, it will be true if the flag is true and the address is matching
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000010 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=607-626
  wire arbt_icb_cmd_scond = arbt_icb_cmd_usr[USR_PACK_EXCL] & (~arbt_icb_cmd_read);
  wire arbt_icb_cmd_scond_true = arbt_icb_cmd_scond & icb_cmdaddr_eq_excladdr & excl_flg_r;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000041 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=584-609
  `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000041 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=584-609

  //

  wire splt_fifo_i_ready;
  wire splt_fifo_i_valid = splt_fifo_wen;
  wire splt_fifo_full    = (~splt_fifo_i_ready);
  wire splt_fifo_o_valid;
  wire splt_fifo_o_ready = splt_fifo_ren;
  wire splt_fifo_empty   = (~splt_fifo_o_valid);

  wire arbt_icb_rsp_biu;
  wire arbt_icb_rsp_dcache;
  wire arbt_icb_rsp_dtcm;
  wire arbt_icb_rsp_itcm;
  wire arbt_icb_rsp_scond_true;

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000042 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=626-630
  `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000010 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=607-626
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:param_decl:000003 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=627-627
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000042 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=626-630
  localparam SPLT_FIFO_W = (USR_W+5);
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:param_decl:000003 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=627-627
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000011 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=628-628
  wire [`E203_XLEN/8-1:0] arbt_icb_cmd_wmask_pos = 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000011 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=628-628
      (arbt_icb_cmd_scond & (~arbt_icb_cmd_scond_true)) ? {`E203_XLEN/8{1'b0}} : arbt_icb_cmd_wmask;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000042 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=626-630
  `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000042 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=626-630

//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000043 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=632-635
  `ifndef E203_SUPPORT_AMO//{
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:param_decl:000004 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=633-633
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000043 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=632-635
  localparam SPLT_FIFO_W = (USR_W+4);
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:param_decl:000004 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=633-633
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000012 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=634-638
  wire [`E203_XLEN/8-1:0] arbt_icb_cmd_wmask_pos = arbt_icb_cmd_wmask;
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000043 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=632-635
  `endif
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000043 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=632-635

  wire [SPLT_FIFO_W-1:0] splt_fifo_wdat;
  wire [SPLT_FIFO_W-1:0] splt_fifo_rdat;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000012 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=634-638

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=640-661
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000023 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=640-649
  assign splt_fifo_wdat =  {
          arbt_icb_cmd_biu,
          arbt_icb_cmd_dcache,
          arbt_icb_cmd_dtcm,
          arbt_icb_cmd_itcm,
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000044 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=645-647
  `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000044 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=645-647
          arbt_icb_cmd_scond_true,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000044 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=645-647
  `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000044 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=645-647
          arbt_icb_cmd_usr 
          };
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000023 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=640-649

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000024 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=651-661
  assign   
      {
          arbt_icb_rsp_biu,
          arbt_icb_rsp_dcache,
          arbt_icb_rsp_dtcm,
          arbt_icb_rsp_itcm,
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000045 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=657-659
  `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000045 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=657-659
          arbt_icb_rsp_scond_true, 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000045 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=657-659
  `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000045 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=657-659
          arbt_icb_rsp_usr 
          } = splt_fifo_rdat & {SPLT_FIFO_W{splt_fifo_o_valid}};
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000024 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=651-661
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=640-661
          // The output signals will be used as 
          //   control signals, so need to be masked

  
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000046 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=666-699
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000046:br:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=666-681
  `ifdef E203_LSU_OUTS_NUM_IS_1 //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000046 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=666-699
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000046:br:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=666-681
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:inst:000004 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=667-681
  sirv_gnrl_pipe_stage # (
    .CUT_READY(0),
    .DP(1),
    .DW(SPLT_FIFO_W)
  ) u_e203_lsu_splt_stage (
    .i_vld  (splt_fifo_i_valid),
    .i_rdy  (splt_fifo_i_ready),
    .i_dat  (splt_fifo_wdat ),
    .o_vld  (splt_fifo_o_valid),
    .o_rdy  (splt_fifo_o_ready),  
    .o_dat  (splt_fifo_rdat ),  
  
    .clk  (clk),
    .rst_n(rst_n)
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:inst:000004 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=667-681
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000046:br:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=666-681
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000046:br:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=666-681
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000046:br:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=682-698
  `else//}{
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000046:br:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=682-698
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:inst:000005 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=683-698
  sirv_gnrl_fifo # (
    .CUT_READY (0),// When entry is clearing, it can also accept new one
    .MSKO      (0),
    // The depth of OITF determined how many oustanding can be dispatched to long pipeline
    .DP  (`E203_LSU_OUTS_NUM),
    .DW  (SPLT_FIFO_W)//
  ) u_e203_lsu_splt_fifo (
    .i_vld  (splt_fifo_i_valid),
    .i_rdy  (splt_fifo_i_ready),
    .i_dat  (splt_fifo_wdat ),
    .o_vld  (splt_fifo_o_valid),
    .o_rdy  (splt_fifo_o_ready),  
    .o_dat  (splt_fifo_rdat ),  
    .clk  (clk),
    .rst_n(rst_n)
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:inst:000005 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=683-698
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000046:br:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=682-698
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000046:br:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=682-698
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000046 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=666-699
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000046 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=666-699



  /////////////////////////////////////////////////////////////////////////////////
  // Implement the ICB Splitting

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000047 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=706-717
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000047:br:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=706-709
  `ifdef E203_LSU_OUTS_NUM_IS_1 //{
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000013 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=707-713
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000047 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=706-717
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000047:br:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=706-709
  wire cmd_diff_branch = 1'b0; // If the LSU outstanding is only 1, there is no chance to 
                               //   happen several outsanding ops, not to mention 
                               //   with different branches
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000047:br:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=706-709
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000047:br:000001 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=706-709
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000047:br:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=710-716
  `else//}{
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000047:br:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=710-716
  // The next transaction can only be issued if there is no any outstanding 
  //   transactions to different targets
  wire cmd_diff_branch = (~splt_fifo_empty) & 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000013 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=707-713
        (~({arbt_icb_cmd_biu, arbt_icb_cmd_dcache, arbt_icb_cmd_dtcm, arbt_icb_cmd_itcm}
        == {arbt_icb_rsp_biu, arbt_icb_rsp_dcache, arbt_icb_rsp_dtcm, arbt_icb_rsp_itcm}));

//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000047:br:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=710-716
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000047:br:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=710-716
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000047 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=706-717
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000047 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=706-717

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000014 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=719-722
  wire arbt_icb_cmd_addi_condi = (~splt_fifo_full) & (~cmd_diff_branch);
  wire arbt_icb_cmd_ready_pos;

  wire arbt_icb_cmd_valid_pos = arbt_icb_cmd_addi_condi & arbt_icb_cmd_valid;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000014 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=719-722
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000025 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=723-723
  assign arbt_icb_cmd_ready     = arbt_icb_cmd_addi_condi & arbt_icb_cmd_ready_pos;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000025 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=723-723

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000015 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=725-731
  wire all_icb_cmd_ready;
  wire all_icb_cmd_ready_excp_biu;
  wire all_icb_cmd_ready_excp_dcach;
  wire all_icb_cmd_ready_excp_dtcm;
  wire all_icb_cmd_ready_excp_itcm;

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000048 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=731-740
  `ifdef E203_HAS_DCACHE //{
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000015 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=725-731
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:assign_cluster:000004 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=732-739
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:bus_cluster:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=732-739
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000048 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=731-740
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000026 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=732-732
  assign dcache_icb_cmd_valid = arbt_icb_cmd_valid_pos & arbt_icb_cmd_dcache & all_icb_cmd_ready_excp_dcach;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000026 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=732-732
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000027 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=733-733
  assign dcache_icb_cmd_addr  = arbt_icb_cmd_addr ; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000027 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=733-733
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000028 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=734-734
  assign dcache_icb_cmd_read  = arbt_icb_cmd_read ; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000028 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=734-734
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000029 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=735-735
  assign dcache_icb_cmd_wdata = arbt_icb_cmd_wdata;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000029 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=735-735
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000030 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=736-736
  assign dcache_icb_cmd_wmask = arbt_icb_cmd_wmask_pos;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000030 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=736-736
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000031 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=737-737
  assign dcache_icb_cmd_lock  = arbt_icb_cmd_lock ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000031 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=737-737
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000032 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=738-738
  assign dcache_icb_cmd_excl  = arbt_icb_cmd_excl ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000032 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=738-738
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000033 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=739-739
  assign dcache_icb_cmd_size  = arbt_icb_cmd_size ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000033 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=739-739
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:assign_cluster:000004 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=732-739
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:bus_cluster:000002 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=732-739
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000048 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=731-740
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000048 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=731-740

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000049 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=742-751
  `ifdef E203_HAS_DTCM //{
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:assign_cluster:000005 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=743-750
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:bus_cluster:000003 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=743-750
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000049 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=742-751
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000034 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=743-743
  assign dtcm_icb_cmd_valid = arbt_icb_cmd_valid_pos & arbt_icb_cmd_dtcm & all_icb_cmd_ready_excp_dtcm;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000034 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=743-743
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000035 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=744-744
  assign dtcm_icb_cmd_addr  = arbt_icb_cmd_addr [`E203_DTCM_ADDR_WIDTH-1:0]; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000035 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=744-744
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000036 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=745-745
  assign dtcm_icb_cmd_read  = arbt_icb_cmd_read ; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000036 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=745-745
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000037 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=746-746
  assign dtcm_icb_cmd_wdata = arbt_icb_cmd_wdata;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000037 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=746-746
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000038 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=747-747
  assign dtcm_icb_cmd_wmask = arbt_icb_cmd_wmask_pos;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000038 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=747-747
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000039 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=748-748
  assign dtcm_icb_cmd_lock  = arbt_icb_cmd_lock ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000039 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=748-748
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000040 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=749-749
  assign dtcm_icb_cmd_excl  = arbt_icb_cmd_excl ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000040 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=749-749
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000041 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=750-750
  assign dtcm_icb_cmd_size  = arbt_icb_cmd_size ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000041 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=750-750
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:assign_cluster:000005 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=743-750
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:bus_cluster:000003 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=743-750
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000049 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=742-751
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000049 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=742-751

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000050 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=753-762
  `ifdef E203_HAS_ITCM //{
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:assign_cluster:000006 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=754-761
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:bus_cluster:000004 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=754-761
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000050 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=753-762
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000042 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=754-754
  assign itcm_icb_cmd_valid = arbt_icb_cmd_valid_pos & arbt_icb_cmd_itcm & all_icb_cmd_ready_excp_itcm;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000042 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=754-754
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000043 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=755-755
  assign itcm_icb_cmd_addr  = arbt_icb_cmd_addr [`E203_ITCM_ADDR_WIDTH-1:0]; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000043 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=755-755
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000044 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=756-756
  assign itcm_icb_cmd_read  = arbt_icb_cmd_read ; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000044 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=756-756
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000045 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=757-757
  assign itcm_icb_cmd_wdata = arbt_icb_cmd_wdata;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000045 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=757-757
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000046 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=758-758
  assign itcm_icb_cmd_wmask = arbt_icb_cmd_wmask_pos;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000046 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=758-758
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000047 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=759-759
  assign itcm_icb_cmd_lock  = arbt_icb_cmd_lock ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000047 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=759-759
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000048 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=760-760
  assign itcm_icb_cmd_excl  = arbt_icb_cmd_excl ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000048 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=760-760
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000049 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=761-761
  assign itcm_icb_cmd_size  = arbt_icb_cmd_size ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000049 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=761-761
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:assign_cluster:000006 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=754-761
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:bus_cluster:000004 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=754-761
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000050 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=753-762
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000050 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=753-762

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:assign_cluster:000007 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=764-900
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:bus_cluster:000005 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=764-900
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000050 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=764-764
  assign biu_icb_cmd_valid = arbt_icb_cmd_valid_pos & arbt_icb_cmd_biu & all_icb_cmd_ready_excp_biu;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000050 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=764-764
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000051 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=765-765
  assign biu_icb_cmd_addr  = arbt_icb_cmd_addr ; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000051 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=765-765
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000052 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=766-766
  assign biu_icb_cmd_read  = arbt_icb_cmd_read ; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000052 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=766-766
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000053 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=767-767
  assign biu_icb_cmd_wdata = arbt_icb_cmd_wdata;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000053 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=767-767
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000054 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=768-768
  assign biu_icb_cmd_wmask = arbt_icb_cmd_wmask_pos;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000054 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=768-768
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000055 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=769-769
  assign biu_icb_cmd_lock  = arbt_icb_cmd_lock ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000055 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=769-769
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000056 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=770-770
  assign biu_icb_cmd_excl  = arbt_icb_cmd_excl ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000056 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=770-770
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000057 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=771-771
  assign biu_icb_cmd_size  = arbt_icb_cmd_size ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000057 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=771-771
  
  ////assign arbt_icb_cmd_ready_pos =  
  ////          (arbt_icb_cmd_biu & biu_icb_cmd_ready ) 
  ////           `ifdef E203_HAS_DCACHE //{
  ////        | (arbt_icb_cmd_dcache & dcache_icb_cmd_ready) 
  ////           `endif//}
  ////           `ifdef E203_HAS_DTCM //{
  ////        | (arbt_icb_cmd_dtcm & dtcm_icb_cmd_ready) 
  ////           `endif//}
  ////           `ifdef E203_HAS_ITCM //{
  ////        | (arbt_icb_cmd_itcm & itcm_icb_cmd_ready) 
  ////           `endif//}
  ////           ;
  // To cut the in2out path from addr to the cmd_ready signal
  //   we just always use the simplified logic
  //   to always ask for all of the downstream components
  //   to be ready, this may impact performance a little
  //   bit in corner case, but doesnt really hurt the common 
  //   case
  //
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:handshake:000004 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=792-900
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000058 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=792-803
  assign all_icb_cmd_ready =  
            (biu_icb_cmd_ready ) 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000051 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=794-796
             `ifdef E203_HAS_DCACHE //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000051 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=794-796
          & (dcache_icb_cmd_ready) 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000051 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=794-796
             `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000051 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=794-796
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000052 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=797-799
             `ifdef E203_HAS_DTCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000052 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=797-799
          & (dtcm_icb_cmd_ready) 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000052 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=797-799
             `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000052 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=797-799
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000053 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=800-802
             `ifdef E203_HAS_ITCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000053 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=800-802
          & (itcm_icb_cmd_ready) 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000053 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=800-802
             `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000053 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=800-802
             ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000058 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=792-803

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000059 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=805-816
  assign all_icb_cmd_ready_excp_biu =  
            1'b1
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000054 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=807-809
             `ifdef E203_HAS_DCACHE //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000054 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=807-809
          & (dcache_icb_cmd_ready) 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000054 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=807-809
             `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000054 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=807-809
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000055 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=810-812
             `ifdef E203_HAS_DTCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000055 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=810-812
          & (dtcm_icb_cmd_ready) 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000055 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=810-812
             `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000055 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=810-812
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000056 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=813-815
             `ifdef E203_HAS_ITCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000056 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=813-815
          & (itcm_icb_cmd_ready) 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000056 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=813-815
             `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000056 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=813-815
             ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000059 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=805-816

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000060 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=818-829
  assign all_icb_cmd_ready_excp_dcach =  
            (biu_icb_cmd_ready ) 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000057 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=820-822
             `ifdef E203_HAS_DCACHE //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000057 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=820-822
          & 1'b1
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000057 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=820-822
             `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000057 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=820-822
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000058 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=823-825
             `ifdef E203_HAS_DTCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000058 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=823-825
          & (dtcm_icb_cmd_ready) 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000058 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=823-825
             `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000058 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=823-825
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000059 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=826-828
             `ifdef E203_HAS_ITCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000059 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=826-828
          & (itcm_icb_cmd_ready) 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000059 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=826-828
             `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000059 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=826-828
             ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000060 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=818-829
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000061 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=830-841
  assign all_icb_cmd_ready_excp_dtcm =  
            (biu_icb_cmd_ready ) 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000060 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=832-834
             `ifdef E203_HAS_DCACHE //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000060 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=832-834
          & (dcache_icb_cmd_ready) 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000060 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=832-834
             `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000060 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=832-834
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000061 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=835-837
             `ifdef E203_HAS_DTCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000061 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=835-837
          & 1'b1
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000061 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=835-837
             `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000061 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=835-837
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000062 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=838-840
             `ifdef E203_HAS_ITCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000062 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=838-840
          & (itcm_icb_cmd_ready) 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000062 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=838-840
             `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000062 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=838-840
             ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000061 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=830-841

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000062 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=843-854
 assign all_icb_cmd_ready_excp_itcm =  
            (biu_icb_cmd_ready ) 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000063 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=845-847
             `ifdef E203_HAS_DCACHE //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000063 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=845-847
          & (dcache_icb_cmd_ready) 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000063 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=845-847
             `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000063 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=845-847
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000064 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=848-850
             `ifdef E203_HAS_DTCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000064 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=848-850
          & (dtcm_icb_cmd_ready) 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000064 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=848-850
             `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000064 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=848-850
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000065 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=851-853
             `ifdef E203_HAS_ITCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000065 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=851-853
          & 1'b1
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000065 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=851-853
             `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000065 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=851-853
             ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000062 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=843-854

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000063 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=856-856
  assign arbt_icb_cmd_ready_pos = all_icb_cmd_ready;  
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000063 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=856-856

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000064 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=858-898
  assign {
          arbt_icb_rsp_valid 
        , arbt_icb_rsp_err 
        , arbt_icb_rsp_excl_ok 
        , arbt_icb_rsp_rdata 
         } =
            ({`E203_XLEN+3{arbt_icb_rsp_biu}} &
                        { biu_icb_rsp_valid 
                        , biu_icb_rsp_err 
                        , biu_icb_rsp_excl_ok 
                        , biu_icb_rsp_rdata 
                        }
            ) 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000066 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=871-879
             `ifdef E203_HAS_DCACHE //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000066 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=871-879
          | ({`E203_XLEN+3{arbt_icb_rsp_dcache}} &
                        { dcache_icb_rsp_valid 
                        , dcache_icb_rsp_err 
                        , dcache_icb_rsp_excl_ok 
                        , dcache_icb_rsp_rdata 
                        }
            ) 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000066 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=871-879
             `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000066 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=871-879
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000067 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=880-888
             `ifdef E203_HAS_DTCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000067 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=880-888
          | ({`E203_XLEN+3{arbt_icb_rsp_dtcm}} &
                        { dtcm_icb_rsp_valid 
                        , dtcm_icb_rsp_err 
                        , dtcm_icb_rsp_excl_ok 
                        , dtcm_icb_rsp_rdata 
                        }
            ) 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000067 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=880-888
             `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000067 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=880-888
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000068 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=889-897
             `ifdef E203_HAS_ITCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000068 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=889-897
          | ({`E203_XLEN+3{arbt_icb_rsp_itcm}} &
                        { itcm_icb_rsp_valid 
                        , itcm_icb_rsp_err 
                        , itcm_icb_rsp_excl_ok 
                        , itcm_icb_rsp_rdata 
                        }
            ) 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000068 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=889-897
             `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000068 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=889-897
             ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000064 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=858-898

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000065 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=900-900
  assign biu_icb_rsp_ready    = arbt_icb_rsp_biu    & arbt_icb_rsp_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000065 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=900-900
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:handshake:000004 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=792-900
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:assign_cluster:000007 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=764-900
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:bus_cluster:000005 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=764-900
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000069 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=901-903
             `ifdef E203_HAS_DCACHE //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000069 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=901-903
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000066 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=902-902
  assign dcache_icb_rsp_ready = arbt_icb_rsp_dcache & arbt_icb_rsp_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000066 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=902-902
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000069 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=901-903
             `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000069 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=901-903
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000070 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=904-906
             `ifdef E203_HAS_DTCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000070 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=904-906
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000067 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=905-905
  assign dtcm_icb_rsp_ready   = arbt_icb_rsp_dtcm   & arbt_icb_rsp_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000067 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=905-905
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000070 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=904-906
             `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000070 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=904-906
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000071 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=907-909
             `ifdef E203_HAS_ITCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000071 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=907-909
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000068 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=908-908
  assign itcm_icb_rsp_ready   = arbt_icb_rsp_itcm   & arbt_icb_rsp_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000068 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=908-908
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000071 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=907-909
             `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000071 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=907-909


  /////////////////////////////////////////////////////////////////////////////////
  // Pass the ICB response back to AGU or LSU-Writeback if it need back2agu or not
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:assign_cluster:000008 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=914-924
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:bus_cluster:000006 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=914-924
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:handshake:000005 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=914-918
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000069 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=914-914
  assign lsu_o_valid       = pre_agu_icb_rsp_valid & (~pre_agu_icb_rsp_back2agu);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000069 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=914-914
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000070 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=915-915
  assign agu_icb_rsp_valid = pre_agu_icb_rsp_valid &   pre_agu_icb_rsp_back2agu;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000070 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=915-915

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000071 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=917-918
  assign pre_agu_icb_rsp_ready =
      pre_agu_icb_rsp_back2agu ?  agu_icb_rsp_ready : lsu_o_ready; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000071 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=917-918
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:handshake:000005 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=914-918

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000072 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=920-920
  assign agu_icb_rsp_err   = pre_agu_icb_rsp_err  ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000072 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=920-920
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000073 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=921-921
  assign agu_icb_rsp_excl_ok = pre_agu_icb_rsp_excl_ok  ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000073 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=921-921
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000074 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=922-922
  assign agu_icb_rsp_rdata = pre_agu_icb_rsp_rdata;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000074 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=922-922

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000075 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=924-924
  assign lsu_o_wbck_itag   = pre_agu_icb_rsp_itag;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000075 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=924-924
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:assign_cluster:000008 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=914-924
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:bus_cluster:000006 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=914-924

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000016 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=926-926
  wire [`E203_XLEN-1:0] rdata_algn = 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000016 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=926-926
      (pre_agu_icb_rsp_rdata >> {pre_agu_icb_rsp_addr[1:0],3'b0});

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000017 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=929-940
  wire rsp_lbu = (pre_agu_icb_rsp_size == 2'b00) & (pre_agu_icb_rsp_usign == 1'b1);
  wire rsp_lb  = (pre_agu_icb_rsp_size == 2'b00) & (pre_agu_icb_rsp_usign == 1'b0);
  wire rsp_lhu = (pre_agu_icb_rsp_size == 2'b01) & (pre_agu_icb_rsp_usign == 1'b1);
  wire rsp_lh  = (pre_agu_icb_rsp_size == 2'b01) & (pre_agu_icb_rsp_usign == 1'b0);
  wire rsp_lw  = (pre_agu_icb_rsp_size == 2'b10);

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000072 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=935-943
  `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000072 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=935-943
       // In E200 single core config, we always assume the store-condition is checked by the core itself
       //    because no other core to race. So we dont use the returned excl-ok, but use the LSU tracked
       //    scond_true
  //wire [`E203_XLEN-1:0] sc_excl_wdata = pre_agu_icb_rsp_excl_ok ? `E203_XLEN'd0 : `E203_XLEN'd1; 
  wire [`E203_XLEN-1:0] sc_excl_wdata = arbt_icb_rsp_scond_true ? `E203_XLEN'd0 : `E203_XLEN'd1; 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:internal_signal:000017 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=929-940
                // If it is scond (excl-write), then need to update the regfile
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:assign_cluster:000009 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=942-961
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:bus_cluster:000007 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=942-961
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000076 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=942-953
  assign lsu_o_wbck_wdat   = ((~pre_agu_icb_rsp_read) & pre_agu_icb_rsp_excl) ? sc_excl_wdata :
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000072 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=935-943
  `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000072 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=935-943
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000073 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=944-948
  `ifndef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000073 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=944-948
       // If not support the store-condition instructions, then we have no chance to issue excl transaction
           // no need to consider the store-condition result write-back
  assign lsu_o_wbck_wdat   = 
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000073 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=944-948
  `endif
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:pp_blk:000073 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=944-948
          ( ({`E203_XLEN{rsp_lbu}} & {{24{          1'b0}}, rdata_algn[ 7:0]})
          | ({`E203_XLEN{rsp_lb }} & {{24{rdata_algn[ 7]}}, rdata_algn[ 7:0]})
          | ({`E203_XLEN{rsp_lhu}} & {{16{          1'b0}}, rdata_algn[15:0]})
          | ({`E203_XLEN{rsp_lh }} & {{16{rdata_algn[15]}}, rdata_algn[15:0]}) 
          | ({`E203_XLEN{rsp_lw }} & rdata_algn[31:0]));
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000076 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=942-953
          
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000077 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=955-955
  assign lsu_o_wbck_err    = pre_agu_icb_rsp_err;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000077 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=955-955
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000078 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=956-956
  assign lsu_o_cmt_buserr  = pre_agu_icb_rsp_err;// The bus-error exception generated
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000078 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=956-956
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000079 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=957-957
  assign lsu_o_cmt_badaddr = pre_agu_icb_rsp_addr;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000079 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=957-957
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000080 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=958-958
  assign lsu_o_cmt_ld=  pre_agu_icb_rsp_read;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000080 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=958-958
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000081 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=959-959
  assign lsu_o_cmt_st= ~pre_agu_icb_rsp_read;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000081 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=959-959

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000082 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=961-961
  assign lsu_ctrl_active = (|arbt_bus_icb_cmd_valid_raw) | splt_fifo_o_valid;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:assign:000082 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=961-961
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:assign_cluster:000009 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=942-961
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v:grp:bus_cluster:000007 file=e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v lines=942-961

endmodule

