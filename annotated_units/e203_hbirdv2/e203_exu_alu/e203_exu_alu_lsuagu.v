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
//  This module to implement the AGU (address generation unit for load/store 
//  and AMO instructions), which is mostly share the datapath with ALU module
//  to save gatecount to mininum
//
//
// ====================================================================
`include "e203_defines.v"

module e203_exu_alu_lsuagu(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=33-127

  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // The Issue Handshake Interface to AGU 
  //
  input  agu_i_valid, // Handshake valid
  output agu_i_ready, // Handshake ready

  input  [`E203_XLEN-1:0] agu_i_rs1,
  input  [`E203_XLEN-1:0] agu_i_rs2,
  input  [`E203_XLEN-1:0] agu_i_imm,
  input  [`E203_DECINFO_AGU_WIDTH-1:0] agu_i_info,
  input  [`E203_ITAG_WIDTH-1:0] agu_i_itag,

  output agu_i_longpipe,

  input  flush_req,
  input  flush_pulse,

  output amo_wait,
  input  oitf_empty,

  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // The AGU Write-Back/Commit Interface
  output agu_o_valid, // Handshake valid
  input  agu_o_ready, // Handshake ready
  output [`E203_XLEN-1:0] agu_o_wbck_wdat,
  output agu_o_wbck_err,   
  //   The Commit Interface for all ldst and amo instructions
  output agu_o_cmt_misalgn, // The misalign exception generated
  output agu_o_cmt_ld, 
  output agu_o_cmt_stamo,
  output agu_o_cmt_buserr, // The bus-error exception generated
  output [`E203_ADDR_SIZE-1:0] agu_o_cmt_badaddr,

  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // The ICB Interface to LSU-ctrl
  //    * Bus cmd channel
  output                       agu_icb_cmd_valid, // Handshake valid
  input                        agu_icb_cmd_ready, // Handshake ready
            // Note: The data on rdata or wdata channel must be naturally
            //       aligned, this is in line with the AXI definition
  output [`E203_ADDR_SIZE-1:0] agu_icb_cmd_addr, // Bus transaction start addr 
  output                       agu_icb_cmd_read,   // Read or write
  output [`E203_XLEN-1:0]      agu_icb_cmd_wdata, 
  output [`E203_XLEN/8-1:0]    agu_icb_cmd_wmask, 
  output                       agu_icb_cmd_back2agu, 
  output                       agu_icb_cmd_lock,
  output                       agu_icb_cmd_excl,
  output [1:0]                 agu_icb_cmd_size,
  output [`E203_ITAG_WIDTH-1:0]agu_icb_cmd_itag,
  output                       agu_icb_cmd_usign,

  //    * Bus RSP channel
  input                        agu_icb_rsp_valid, // Response valid 
  output                       agu_icb_rsp_ready, // Response ready
  input                        agu_icb_rsp_err  , // Response error
  input                        agu_icb_rsp_excl_ok,
            // Note: the RSP rdata is inline with AXI definition
  input  [`E203_XLEN-1:0]      agu_icb_rsp_rdata,


  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // To share the ALU datapath, generate interface to ALU
  //   for single-issue machine, seems the AGU must be shared with ALU, otherwise
  //   it wasted the area for no points 
  // 
     // The operands and info to ALU
  output [`E203_XLEN-1:0] agu_req_alu_op1,
  output [`E203_XLEN-1:0] agu_req_alu_op2,
  output agu_req_alu_swap,
  output agu_req_alu_add ,
  output agu_req_alu_and ,
  output agu_req_alu_or  ,
  output agu_req_alu_xor ,
  output agu_req_alu_max ,
  output agu_req_alu_min ,
  output agu_req_alu_maxu,
  output agu_req_alu_minu,
  input  [`E203_XLEN-1:0] agu_req_alu_res,

     // The Shared-Buffer interface to ALU-Shared-Buffer
  output agu_sbf_0_ena,
  output [`E203_XLEN-1:0] agu_sbf_0_nxt,
  input  [`E203_XLEN-1:0] agu_sbf_0_r,

  output agu_sbf_1_ena,
  output [`E203_XLEN-1:0] agu_sbf_1_nxt,
  input  [`E203_XLEN-1:0] agu_sbf_1_r,

  input  clk,
  input  rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=33-127
  );

  //

      // When there is a nonalu_flush which is going to flush the ALU, then we need to mask off it
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=133-170
  wire       icb_sta_is_idle;
  wire       flush_block = flush_req & icb_sta_is_idle; 

  wire       agu_i_load    = agu_i_info [`E203_DECINFO_AGU_LOAD   ] & (~flush_block);
  wire       agu_i_store   = agu_i_info [`E203_DECINFO_AGU_STORE  ] & (~flush_block);
  wire       agu_i_amo     = agu_i_info [`E203_DECINFO_AGU_AMO    ] & (~flush_block);

  wire [1:0] agu_i_size    = agu_i_info [`E203_DECINFO_AGU_SIZE   ];
  wire       agu_i_usign   = agu_i_info [`E203_DECINFO_AGU_USIGN  ];
  wire       agu_i_excl    = agu_i_info [`E203_DECINFO_AGU_EXCL   ];
  wire       agu_i_amoswap = agu_i_info [`E203_DECINFO_AGU_AMOSWAP];
  wire       agu_i_amoadd  = agu_i_info [`E203_DECINFO_AGU_AMOADD ];
  wire       agu_i_amoand  = agu_i_info [`E203_DECINFO_AGU_AMOAND ];
  wire       agu_i_amoor   = agu_i_info [`E203_DECINFO_AGU_AMOOR  ];
  wire       agu_i_amoxor  = agu_i_info [`E203_DECINFO_AGU_AMOXOR ];
  wire       agu_i_amomax  = agu_i_info [`E203_DECINFO_AGU_AMOMAX ];
  wire       agu_i_amomin  = agu_i_info [`E203_DECINFO_AGU_AMOMIN ];
  wire       agu_i_amomaxu = agu_i_info [`E203_DECINFO_AGU_AMOMAXU];
  wire       agu_i_amominu = agu_i_info [`E203_DECINFO_AGU_AMOMINU];


  wire agu_icb_cmd_hsked = agu_icb_cmd_valid & agu_icb_cmd_ready; 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=155-157
  `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=155-157
  wire agu_icb_rsp_hsked = agu_icb_rsp_valid & agu_icb_rsp_ready; 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=155-157
  `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=155-157
    // These strange ifdef/ifndef rather than the ifdef-else, because of 
    //   our internal text processing scripts need this style
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=160-164
  `ifndef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=160-164
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=161-163
    `ifndef E203_SUPPORT_UNALGNLDST//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=161-163
  wire agu_icb_rsp_hsked = 1'b0;
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=161-163
    `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=161-163
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=160-164
  `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=160-164

  wire agu_i_size_b  = (agu_i_size == 2'b00);
  wire agu_i_size_hw = (agu_i_size == 2'b01);
  wire agu_i_size_w  = (agu_i_size == 2'b10);

  wire agu_i_addr_unalgn = 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=133-170
            (agu_i_size_hw &  agu_icb_cmd_addr[0])
          | (agu_i_size_w  &  (|agu_icb_cmd_addr[1:0]));

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=174-183
  wire state_last_exit_ena;
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=175-185
  `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=175-185
  wire state_idle_exit_ena;
  wire unalgn_flg_r;
  // Set when the ICB state is starting and it is unalign
  wire unalgn_flg_set = agu_i_addr_unalgn & state_idle_exit_ena;
  // Clear when the ICB state is entering
  wire unalgn_flg_clr = unalgn_flg_r & state_last_exit_ena;
  wire unalgn_flg_ena = unalgn_flg_set | unalgn_flg_clr;
  wire unalgn_flg_nxt = unalgn_flg_set | (~unalgn_flg_clr);
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=174-183
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:inst:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=184-184
  sirv_gnrl_dfflr #(1) unalgn_flg_dffl (unalgn_flg_ena, unalgn_flg_nxt, unalgn_flg_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:inst:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=184-184
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=175-185
  `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=175-185

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=187-189
  wire agu_addr_unalgn = 
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=188-195
  `ifndef E203_SUPPORT_UNALGNLDST//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=188-195
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=189-191
      `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=187-189
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=189-191
      icb_sta_is_idle ? agu_i_addr_unalgn : unalgn_flg_r;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=189-191
      `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=189-191
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=192-194
      `ifndef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=192-194
      agu_i_addr_unalgn;
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=192-194
      `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=192-194
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=188-195
  `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=188-195

 
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=198-198
  wire agu_i_unalgnld = (agu_addr_unalgn & agu_i_load)
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=198-198
                      ;
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=200-200
  wire agu_i_unalgnst = (agu_addr_unalgn & agu_i_store) 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=200-200
                      ;
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=202-202
  wire agu_i_unalgnldst = (agu_i_unalgnld | agu_i_unalgnst)
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=202-202
                      ;
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=204-204
  wire agu_i_algnld = (~agu_addr_unalgn) & agu_i_load
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=204-204
                      ;
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=206-206
  wire agu_i_algnst = (~agu_addr_unalgn) & agu_i_store
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=206-206
                      ;
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=208-208
  wire agu_i_algnldst = (agu_i_algnld | agu_i_algnst)
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=208-208
                      ;

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=211-216
  `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000010 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=212-212
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=211-216
  wire agu_i_unalgnamo = (agu_addr_unalgn & agu_i_amo) 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000010 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=212-212
                        ;
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000011 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=214-214
  wire agu_i_algnamo = ((~agu_addr_unalgn) & agu_i_amo) 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000011 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=214-214
                        ;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=211-216
  `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=211-216

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000012 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=218-218
  wire agu_i_ofst0  = agu_i_amo | ((agu_i_load | agu_i_store) & agu_i_excl); 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000012 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=218-218


//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:param_decl:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=221-221
  localparam ICB_STATE_WIDTH = 4;
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:param_decl:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=221-221

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000013 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=223-225
  wire icb_state_ena;
  wire [ICB_STATE_WIDTH-1:0] icb_state_nxt;
  wire [ICB_STATE_WIDTH-1:0] icb_state_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000013 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=223-225

  // State 0: The idle state, means there is no any oustanding ifetch request
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:param_decl:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=228-250
  localparam ICB_STATE_IDLE = 4'd0;
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=229-245
  `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=229-245
  // State  : Issued first request and wait response
  localparam ICB_STATE_1ST  = 4'd1;
  // State  : Wait to issue second request 
  localparam ICB_STATE_WAIT2ND  = 4'd2;
  // State  : Issued second request and wait response
  localparam ICB_STATE_2ND  = 4'd3;
  // State  : For AMO instructions, in this state, read-data was in leftover
  //            buffer for ALU calculation 
  localparam ICB_STATE_AMOALU  = 4'd4;
  // State  : For AMO instructions, in this state, ALU have caculated the new
  //            result and put into leftover buffer again 
  localparam ICB_STATE_AMORDY  = 4'd5;
  // State  : For AMO instructions, in this state, the response data have been returned
  //            and the write back result to commit/wback interface
  localparam ICB_STATE_WBCK  = 4'd6;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=229-245
  `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=229-245
  
   
  
 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000010 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=250-258
  `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:param_decl:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=228-250
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000014 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=251-266
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000010 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=250-258
  wire [ICB_STATE_WIDTH-1:0] state_idle_nxt   ;
  wire [ICB_STATE_WIDTH-1:0] state_1st_nxt    ;
  wire [ICB_STATE_WIDTH-1:0] state_wait2nd_nxt;
  wire [ICB_STATE_WIDTH-1:0] state_2nd_nxt    ;
  wire [ICB_STATE_WIDTH-1:0] state_amoalu_nxt ;
  wire [ICB_STATE_WIDTH-1:0] state_amordy_nxt ;
  wire [ICB_STATE_WIDTH-1:0] state_wbck_nxt ;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000010 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=250-258
  `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000010 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=250-258
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000011 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=259-266
  `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000011 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=259-266
  wire state_1st_exit_ena      ;
  wire state_wait2nd_exit_ena  ;
  wire state_2nd_exit_ena      ;
  wire state_amoalu_exit_ena   ;
  wire state_amordy_exit_ena   ;
  wire state_wbck_exit_ena   ;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000011 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=259-266
  `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000011 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=259-266
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000014 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=251-266

  // Define some common signals and reused later to save gatecounts
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=269-269
  assign icb_sta_is_idle    = (icb_state_r == ICB_STATE_IDLE   );
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=269-269
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000012 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=270-277
  `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000015 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=271-284
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000012 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=270-277
  wire   icb_sta_is_1st     = (icb_state_r == ICB_STATE_1ST    );
  wire   icb_sta_is_amoalu  = (icb_state_r == ICB_STATE_AMOALU );
  wire   icb_sta_is_amordy  = (icb_state_r == ICB_STATE_AMORDY );
  wire   icb_sta_is_wait2nd = (icb_state_r == ICB_STATE_WAIT2ND);
  wire   icb_sta_is_2nd     = (icb_state_r == ICB_STATE_2ND    );
  wire   icb_sta_is_wbck    = (icb_state_r == ICB_STATE_WBCK    );
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000012 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=270-277
  `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000012 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=270-277


//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000013 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=280-348
  `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000013 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=280-348
      // **** If the current state is idle,
          // If a new load-store come and the ICB cmd channel is handshaked, next
          //   state is ICB_STATE_1ST
  wire state_idle_to_exit =    (( agu_i_algnamo
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000015 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=271-284
                                  // Why do we add an oitf empty signal here? because
                                  //   it is better to start AMO state-machine when the 
                                  //   long-pipes are completed, to avoid the long-pipes 
                                  //   have error-return which need to flush the pipeline
                                  //   and which also need to wait the AMO state-machine
                                  //   to complete first, in corner cases it may end 
                                  //   up with deadlock.
                                  // Force to wait oitf empty before doing amo state-machine
                                  //   may hurt performance, but we dont care it. In e203 implementation
                                  //   the AMO was not target for performance.
                                  & oitf_empty)
                                 );
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=297-347
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:bus_cluster:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=297-347
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=297-298
  assign state_idle_exit_ena = icb_sta_is_idle & state_idle_to_exit 
                               & agu_icb_cmd_hsked & (~flush_pulse);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=297-298
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=299-299
  assign state_idle_nxt      = ICB_STATE_1ST;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=299-299

      // **** If the current state is 1st,
          // If a response come, exit this state
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=303-303
  assign state_1st_exit_ena = icb_sta_is_1st & (agu_icb_rsp_hsked | flush_pulse);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=303-303
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=304-309
  assign state_1st_nxt      = flush_pulse ? ICB_STATE_IDLE : 
                (
                 // (agu_i_algnamo) ?  // No need this condition, because it will be either
                                       // amo or unalgn load-store in this state
                  ICB_STATE_AMOALU
                );
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=304-309
            
      // **** If the current state is AMOALU 
              // Since the ALU is must be holdoff now, it can always be
              //   served and then enter into next state
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=314-314
  assign state_amoalu_exit_ena = icb_sta_is_amoalu & ( 1'b1 | flush_pulse);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=314-314
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=315-315
  assign state_amoalu_nxt      = flush_pulse ? ICB_STATE_IDLE : ICB_STATE_AMORDY;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=315-315
            
      // **** If the current state is AMORDY
              // It always enter into next state
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=319-319
  assign state_amordy_exit_ena = icb_sta_is_amordy & ( 1'b1 | flush_pulse);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=319-319
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:handshake:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=320-329
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=320-326
  assign state_amordy_nxt      = flush_pulse ? ICB_STATE_IDLE : 
            (
              // AMO after caculated read-modify-result, need to issue 2nd uop as store
              //   back to memory, hence two ICB needed and we dont care the performance,
              //   so always let it jump to wait2nd state
                                       ICB_STATE_WAIT2ND
            );
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=320-326

      // **** If the current state is wait-2nd,
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000010 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=329-329
  assign state_wait2nd_exit_ena = icb_sta_is_wait2nd & (agu_icb_cmd_ready | flush_pulse);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000010 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=329-329
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:handshake:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=320-329
              // If the ICB CMD is ready, then next state is ICB_STATE_2ND
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000011 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=331-331
  assign state_wait2nd_nxt      = flush_pulse ? ICB_STATE_IDLE : ICB_STATE_2ND;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000011 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=331-331
  
      // **** If the current state is 2nd,
          // If a response come, exit this state
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000012 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=335-335
  assign state_2nd_exit_ena = icb_sta_is_2nd & (agu_icb_rsp_hsked | flush_pulse);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000012 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=335-335
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000013 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=336-339
  assign state_2nd_nxt      = flush_pulse ? ICB_STATE_IDLE : 
                (
                  ICB_STATE_WBCK 
                );
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000013 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=336-339

       // **** If the current state is wbck,
          // If it can be write back, exit this state
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000014 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=343-343
  assign state_wbck_exit_ena = icb_sta_is_wbck & (agu_o_ready | flush_pulse);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000014 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=343-343
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000015 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=344-347
  assign state_wbck_nxt      = flush_pulse ? ICB_STATE_IDLE : 
                (
                  ICB_STATE_IDLE 
                );
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000015 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=344-347
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=297-347
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:bus_cluster:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=297-347
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000013 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=280-348
  `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000013 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=280-348

    // The state will only toggle when each state is meeting the condition to exit:
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=351-372
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000016 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=351-358
  assign icb_state_ena = 1'b0 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000014 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=352-357
         `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000014 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=352-357
            | state_idle_exit_ena | state_1st_exit_ena  
            | state_amoalu_exit_ena  | state_amordy_exit_ena  
            | state_wait2nd_exit_ena | state_2nd_exit_ena   
            | state_wbck_exit_ena 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000014 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=352-357
          `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000014 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=352-357
          ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000016 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=351-358

  // The next-state is onehot mux to select different entries
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000017 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=361-372
  assign icb_state_nxt = 
              ({ICB_STATE_WIDTH{1'b0}})
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000015 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=363-371
         `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000015 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=363-371
            | ({ICB_STATE_WIDTH{state_idle_exit_ena   }} & state_idle_nxt   )
            | ({ICB_STATE_WIDTH{state_1st_exit_ena    }} & state_1st_nxt    )
            | ({ICB_STATE_WIDTH{state_amoalu_exit_ena }} & state_amoalu_nxt )
            | ({ICB_STATE_WIDTH{state_amordy_exit_ena }} & state_amordy_nxt )
            | ({ICB_STATE_WIDTH{state_wait2nd_exit_ena}} & state_wait2nd_nxt)
            | ({ICB_STATE_WIDTH{state_2nd_exit_ena    }} & state_2nd_nxt    )
            | ({ICB_STATE_WIDTH{state_wbck_exit_ena   }} & state_wbck_nxt   )
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000015 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=363-371
          `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000015 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=363-371
              ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000017 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=361-372
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=351-372


//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:inst:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=375-375
  sirv_gnrl_dfflr #(ICB_STATE_WIDTH) icb_state_dfflr (icb_state_ena, icb_state_nxt, icb_state_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:inst:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=375-375


//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000016 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=378-380
  `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000016 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=379-385
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000016 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=378-380
  wire  icb_sta_is_last = icb_sta_is_wbck;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000016 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=378-380
  `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000016 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=378-380
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000017 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=381-383
  `ifndef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000017 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=381-383
  wire  icb_sta_is_last = 1'b0; 
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000017 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=381-383
  `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000017 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=381-383

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000018 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=385-387
  `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000016 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=379-385
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000018 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=385-387
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000018 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=386-386
  assign state_last_exit_ena = state_wbck_exit_ena;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000018 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=386-386
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000018 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=385-387
  `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000018 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=385-387
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000019 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=388-390
  `ifndef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000019 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=388-390
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000019 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=389-389
  assign state_last_exit_ena = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000019 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=389-389
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000019 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=388-390
  `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000019 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=388-390

//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000021 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=392-397
//__RB_CUT_BEGIN__ type=pp_ifndef_branch id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000021:br:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=392-392
  `ifndef E203_SUPPORT_UNALGNLDST//{
//__RB_CUT_TAIL__ type=pp_ifndef_branch id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000021:br:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=392-392
//__RB_CUT_END__ type=pp_ifndef_branch id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000021:br:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=392-392
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000021 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=392-397
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000021:br:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=393-396
  `else//}{
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000021:br:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=393-396
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000020 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=394-396
      `ifndef E203_SUPPORT_AMO 
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000020 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=394-396
  !!!! ERROR: This config is not supported, must be something wrong 
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000020 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=394-396
      `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000020 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=394-396
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000021:br:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=393-396
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000021:br:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=393-396
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000021 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=392-397
  `endif//
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000021 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=392-397


      // Indicate there is no oustanding memory transactions
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000022 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=401-407
  `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000022 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=401-407
                    // As long as the statemachine started, we must wait it to be empty
                    // We cannot really kill this instruction when IRQ comes, becuase
                    // the AMO uop alreay write data into the memory, and we must commit
                    // this instructions
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000020 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=406-406
  assign amo_wait = ~icb_sta_is_idle;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000020 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=406-406
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000022 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=401-407
  `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000022 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=401-407
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000023 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=408-410
  `ifndef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000023 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=408-410
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000021 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=409-409
  assign amo_wait = 1'b0;// If no AMO or UNaligned supported, then always 0
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000021 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=409-409
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000023 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=408-410
  `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000023 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=408-410
  //
  /////////////////////////////////////////////////////////////////////////////////
  // Implement the leftover 0 buffer
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000017 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=414-427
  wire leftover_ena;
  wire [`E203_XLEN-1:0] leftover_nxt;
  wire [`E203_XLEN-1:0] leftover_r;
  wire leftover_err_nxt;
  wire leftover_err_r;

  wire [`E203_XLEN-1:0] leftover_1_r;
  wire leftover_1_ena;
  wire [`E203_XLEN-1:0] leftover_1_nxt;
  //
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000024 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=424-427
 `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000024 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=424-427
  wire amo_1stuop = icb_sta_is_1st & agu_i_algnamo;
  wire amo_2nduop = icb_sta_is_2nd & agu_i_algnamo;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000024 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=424-427
 `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000024 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=424-427
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000017 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=414-427
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=428-453
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:bus_cluster:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=428-448
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000022 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=428-434
  assign leftover_ena = agu_icb_rsp_hsked & (
                   1'b0
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000025 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=430-433
                   `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000025 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=430-433
                   | amo_1stuop 
                   | amo_2nduop 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000025 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=430-433
                   `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000025 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=430-433
                   );
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000022 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=428-434
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000023 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=435-441
  assign leftover_nxt = 
              {`E203_XLEN{1'b0}}
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000026 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=437-440
         `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000026 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=437-440
            | ({`E203_XLEN{amo_1stuop        }} & agu_icb_rsp_rdata)// Load the data from bus
            | ({`E203_XLEN{amo_2nduop        }} & leftover_r)// Unchange the value of leftover_r
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000026 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=437-440
         `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000026 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=437-440
            ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000023 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=435-441
                                   
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000024 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=443-448
  assign leftover_err_nxt = 1'b0 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000027 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=444-447
         `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000027 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=444-447
            | ({{amo_1stuop        }} & agu_icb_rsp_err)// 1st error from the bus
            | ({{amo_2nduop        }} & (agu_icb_rsp_err | leftover_err_r))// second error merged
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000027 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=444-447
         `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000027 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=444-447
         ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000024 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=443-448
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:bus_cluster:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=428-448
  //
  // The instantiation of leftover buffer is actually shared with the ALU SBF-0 Buffer
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000025 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=451-451
  assign agu_sbf_0_ena = leftover_ena;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000025 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=451-451
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000026 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=452-452
  assign agu_sbf_0_nxt = leftover_nxt;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000026 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=452-452
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000027 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=453-453
  assign leftover_r    = agu_sbf_0_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000027 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=453-453
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=428-453

  // The error bit is implemented here
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:inst:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=456-456
  sirv_gnrl_dfflr #(1) icb_leftover_err_dfflr (leftover_ena, leftover_err_nxt, leftover_err_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:inst:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=456-456
  
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:assign_cluster:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=458-491
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000028 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=458-462
  assign leftover_1_ena = 1'b0 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000028 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=459-461
         `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000028 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=459-461
           | icb_sta_is_amoalu 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000028 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=459-461
         `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000028 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=459-461
         ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000028 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=458-462
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000029 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=463-463
  assign leftover_1_nxt = agu_req_alu_res;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000029 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=463-463
  //
  // The instantiation of last_icb_addr buffer is actually shared with the ALU SBF-1 Buffer
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000030 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=466-466
  assign agu_sbf_1_ena   = leftover_1_ena;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000030 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=466-466
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000031 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=467-467
  assign agu_sbf_1_nxt   = leftover_1_nxt;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000031 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=467-467
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000032 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=468-468
  assign leftover_1_r = agu_sbf_1_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000032 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=468-468


//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:handshake:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=471-491
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000033 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=471-480
  assign agu_req_alu_add  = 1'b0
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000029 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=472-476
                     `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000029 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=472-476
                           | (icb_sta_is_amoalu & agu_i_amoadd)
                             // In order to let AMO 2nd uop have correct address
                           | (agu_i_amo & (icb_sta_is_wait2nd | icb_sta_is_2nd | icb_sta_is_wbck))
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000029 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=472-476
                     `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000029 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=472-476
                           // To cut down the timing loop from agu_i_valid // | (icb_sta_is_idle & agu_i_valid)
                           //   we dont need this signal at all
                           | icb_sta_is_idle
                           ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000033 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=471-480

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000034 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=482-491
  assign agu_req_alu_op1 =  icb_sta_is_idle   ? agu_i_rs1
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000030 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=483-487
                     `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000030 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=483-487
                          : icb_sta_is_amoalu ? leftover_r
                             // In order to let AMO 2nd uop have correct address
                          : (agu_i_amo & (icb_sta_is_wait2nd | icb_sta_is_2nd | icb_sta_is_wbck)) ? agu_i_rs1
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000030 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=483-487
                     `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000030 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=483-487
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000031 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=488-490
                     `ifndef E203_SUPPORT_UNALGNLDST//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000031 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=488-490
                          : `E203_XLEN'd0 
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000031 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=488-490
                     `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000031 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=488-490
                     ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000034 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=482-491
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:handshake:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=471-491
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:assign_cluster:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=458-491

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000018 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=493-493
  wire [`E203_XLEN-1:0] agu_addr_gen_op2 = agu_i_ofst0 ? `E203_XLEN'b0 : agu_i_imm;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000018 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=493-493
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000035 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=494-503
  assign agu_req_alu_op2 =  icb_sta_is_idle   ? agu_addr_gen_op2 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000032 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=495-499
                     `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000032 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=495-499
                          : icb_sta_is_amoalu ? agu_i_rs2
                             // In order to let AMO 2nd uop have correct address
                          : (agu_i_amo & (icb_sta_is_wait2nd | icb_sta_is_2nd | icb_sta_is_wbck)) ? agu_addr_gen_op2
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000032 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=495-499
                     `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000032 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=495-499
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000033 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=500-502
                     `ifndef E203_SUPPORT_UNALGNLDST//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000033 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=500-502
                          : `E203_XLEN'd0 
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000033 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=500-502
                     `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000033 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=500-502
                     ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000035 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=494-503

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000034 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=505-514
  `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:assign_cluster:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=506-513
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:bus_cluster:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=506-513
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:handshake:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=506-513
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000034 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=505-514
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000036 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=506-506
  assign agu_req_alu_swap = (icb_sta_is_amoalu & agu_i_amoswap );
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000036 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=506-506
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000037 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=507-507
  assign agu_req_alu_and  = (icb_sta_is_amoalu & agu_i_amoand  );
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000037 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=507-507
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000038 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=508-508
  assign agu_req_alu_or   = (icb_sta_is_amoalu & agu_i_amoor   );
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000038 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=508-508
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000039 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=509-509
  assign agu_req_alu_xor  = (icb_sta_is_amoalu & agu_i_amoxor  );
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000039 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=509-509
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000040 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=510-510
  assign agu_req_alu_max  = (icb_sta_is_amoalu & agu_i_amomax  );
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000040 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=510-510
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000041 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=511-511
  assign agu_req_alu_min  = (icb_sta_is_amoalu & agu_i_amomin  );
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000041 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=511-511
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000042 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=512-512
  assign agu_req_alu_maxu = (icb_sta_is_amoalu & agu_i_amomaxu );
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000042 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=512-512
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000043 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=513-513
  assign agu_req_alu_minu = (icb_sta_is_amoalu & agu_i_amominu );
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000043 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=513-513
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:assign_cluster:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=506-513
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:bus_cluster:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=506-513
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:handshake:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=506-513
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000034 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=505-514
  `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000034 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=505-514
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000035 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=515-524
  `ifndef E203_SUPPORT_AMO//{
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:assign_cluster:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=516-523
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:handshake:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=516-523
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000035 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=515-524
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000044 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=516-516
  assign agu_req_alu_swap = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000044 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=516-516
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000045 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=517-517
  assign agu_req_alu_and  = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000045 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=517-517
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000046 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=518-518
  assign agu_req_alu_or   = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000046 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=518-518
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000047 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=519-519
  assign agu_req_alu_xor  = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000047 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=519-519
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000048 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=520-520
  assign agu_req_alu_max  = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000048 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=520-520
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000049 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=521-521
  assign agu_req_alu_min  = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000049 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=521-521
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000050 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=522-522
  assign agu_req_alu_maxu = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000050 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=522-522
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000051 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=523-523
  assign agu_req_alu_minu = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000051 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=523-523
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:assign_cluster:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=516-523
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:handshake:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=516-523
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000035 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=515-524
  `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000035 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=515-524


/////////////////////////////////////////////////////////////////////////////////
// Implement the AGU op handshake ready signal
//
// The AGU op handshakeke interface will be ready when
//   * If it is unaligned instructions, then it will just 
//       directly pass out the write-back interface, hence it will only be 
//       ready when the write-back interface is ready
//   * If it is not unaligned load/store instructions, then it will just 
//       directly pass out the instruction to LSU-ctrl interface, hence it need to check
//       the AGU ICB interface is ready, but it also need to ask write-back interface 
//       for commit, so, also need to check if write-back interfac is ready
//       
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000036 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=539-542
//__RB_CUT_BEGIN__ type=pp_ifndef_branch id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000036:br:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=539-539
  `ifndef E203_SUPPORT_UNALGNLDST//{
//__RB_CUT_TAIL__ type=pp_ifndef_branch id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000036:br:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=539-539
//__RB_CUT_END__ type=pp_ifndef_branch id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000036:br:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=539-539
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000036 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=539-542
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000036:br:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=540-541
  `else//}{
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000036:br:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=540-541
  !!!! ERROR: This UNALIGNED load/store is not supported, must be something wrong 
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000036:br:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=540-541
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000036:br:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=540-541
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000036 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=539-542
  `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000036 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=539-542

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:assign_cluster:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=544-554
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000052 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=544-550
  assign agu_i_ready =
      ( 1'b0
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000037 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=546-548
  `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000037 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=546-548
       | agu_i_algnamo 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000037 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=546-548
  `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000037 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=546-548
       ) ? state_last_exit_ena :
      (agu_icb_cmd_ready & agu_o_ready) ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000052 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=544-550
  
  // The aligned load/store instruction will be dispatched to LSU as long pipeline
  //   instructions
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000053 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=554-554
  assign agu_i_longpipe = agu_i_algnldst;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000053 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=554-554
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:assign_cluster:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=544-554
  

  //
  /////////////////////////////////////////////////////////////////////////////////
  // Implement the Write-back interfaces (unaligned and AMO instructions) 

  // The AGU write-back will be valid when:
  //   * For the aligned load/store
  //       Directly passed to ICB interface, but also need to pass 
  //       to write-back interface asking for commit
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:assign_cluster:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=565-657
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000054 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=565-593
  assign agu_o_valid = 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000038 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=566-571
        `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000038 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=566-571
      // For the unaligned load/store and aligned AMO, it will enter 
      //   into the state machine and let the last state to send back
      //   to the commit stage
      icb_sta_is_last 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000038 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=566-571
        `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000038 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=566-571
      // For the aligned load/store and unaligned AMO, it will be send
      //   to the commit stage right the same cycle of agu_i_valid
      |(
         agu_i_valid & ( agu_i_algnldst 
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000039 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=576-582
        `ifndef E203_SUPPORT_UNALGNLDST//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000039 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=576-582
           // If not support the unaligned load/store by hardware, then 
               // the unaligned load/store will be treated as exception
               // and it will also be send to the commit stage right the
               // same cycle of agu_i_valid
           | agu_i_unalgnldst
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000039 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=576-582
        `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000039 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=576-582
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000040 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=583-585
        `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000040 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=583-585
           | agu_i_unalgnamo 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000040 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=583-585
        `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000040 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=583-585
         )
          ////  // Since it is issuing to commit stage and 
          ////  // LSU at same cycle, so we must qualify the icb_cmd_ready signal from LSU
          ////  // to make sure it is out to commit/LSU at same cycle
               // To cut the critical timing  path from longpipe signal
               // we always assume the AGU will need icb_cmd_ready
          & agu_icb_cmd_ready
      );
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000054 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=565-593

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000055 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=595-600
  assign agu_o_wbck_wdat = {`E203_XLEN{1'b0 }}
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000041 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=596-599
       `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000041 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=596-599
                    | ({`E203_XLEN{agu_i_algnamo  }} & leftover_r) 
                    | ({`E203_XLEN{agu_i_unalgnamo}} & `E203_XLEN'b0) 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000041 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=596-599
       `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000041 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=596-599
       ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000055 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=595-600

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000056 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=602-608
  assign agu_o_cmt_buserr = (1'b0 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000042 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=603-606
                `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000042 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=603-606
                      | (agu_i_algnamo    & leftover_err_r) 
                      | (agu_i_unalgnamo  & 1'b0) 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000042 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=603-606
                `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000042 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=603-606
                      )
                ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000056 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=602-608
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000057 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=609-609
  assign agu_o_cmt_badaddr = agu_icb_cmd_addr;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000057 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=609-609


//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000058 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=612-618
  assign agu_o_cmt_misalgn = (1'b0
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000043 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=613-615
                `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000043 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=613-615
                       | agu_i_unalgnamo 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000043 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=613-615
                `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000043 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=613-615
                       | (agu_i_unalgnldst) //& agu_i_excl) We dont support unaligned load/store regardless it is AMO or not
                       )
                       ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000058 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=612-618
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000059 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=619-619
  assign agu_o_cmt_ld      = agu_i_load & (~agu_i_excl); 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000059 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=619-619
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000060 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=620-620
  assign agu_o_cmt_stamo   = agu_i_store | agu_i_amo | agu_i_excl;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000060 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=620-620

  
  // The exception or error result cannot write-back
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000061 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=624-625
  assign agu_o_wbck_err = agu_o_cmt_buserr | agu_o_cmt_misalgn
                          ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000061 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=624-625


//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:bus_cluster:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=628-657
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:handshake:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=628-649
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000062 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=628-628
  assign agu_icb_rsp_ready = 1'b1;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000062 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=628-628


  

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000063 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=633-648
  assign agu_icb_cmd_valid = 
            ((agu_i_algnldst & agu_i_valid)
              // We must qualify the agu_o_ready signal from commit stage
              // to make sure it is out to commit/LSU at same cycle
              & (agu_o_ready)
            )
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000044 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=639-647
          `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000044 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=639-647
            | (agu_i_algnamo & (
                         (icb_sta_is_idle & agu_i_valid 
                             // We must qualify the agu_o_ready signal from commit stage
                             // to make sure it is out to commit/LSU at same cycle
                             & agu_o_ready)
                       | (icb_sta_is_wait2nd)))
            | (agu_i_unalgnamo & 1'b0) 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000044 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=639-647
          `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000044 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=639-647
            ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000063 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=633-648
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000064 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=649-649
  assign agu_icb_cmd_addr = agu_req_alu_res[`E203_ADDR_SIZE-1:0];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000064 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=649-649
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:handshake:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=628-649

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000065 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=651-657
  assign agu_icb_cmd_read = 
            (agu_i_algnldst & agu_i_load) 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000045 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=653-656
          `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000045 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=653-656
          | (agu_i_algnamo & icb_sta_is_idle & 1'b1)
          | (agu_i_algnamo & icb_sta_is_wait2nd & 1'b0) 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000045 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=653-656
          `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000045 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=653-656
          ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000065 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=651-657
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:bus_cluster:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=628-657
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:assign_cluster:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=565-657
     // The AGU ICB CMD Wdata sources:
     //   * For the aligned store instructions
     //       Directly passed to AGU ICB, wdata is op2 repetitive form, 
     //       wmask is generated according to the LSB and size


//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000019 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=664-664
  wire [`E203_XLEN-1:0] algnst_wdata = 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000019 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=664-664
            ({`E203_XLEN{agu_i_size_b }} & {4{agu_i_rs2[ 7:0]}})
          | ({`E203_XLEN{agu_i_size_hw}} & {2{agu_i_rs2[15:0]}})
          | ({`E203_XLEN{agu_i_size_w }} & {1{agu_i_rs2[31:0]}});
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000020 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=668-668
  wire [`E203_XLEN/8-1:0] algnst_wmask = 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:internal_signal:000020 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=668-668
            ({`E203_XLEN/8{agu_i_size_b }} & (4'b0001 << agu_icb_cmd_addr[1:0]))
          | ({`E203_XLEN/8{agu_i_size_hw}} & (4'b0011 << {agu_icb_cmd_addr[1],1'b0}))
          | ({`E203_XLEN/8{agu_i_size_w }} & (4'b1111));

          
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:assign_cluster:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=674-707
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:bus_cluster:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=674-707
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000066 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=674-678
  assign agu_icb_cmd_wdata = 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000046 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=675-677
  `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000046 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=675-677
      agu_i_amo ? leftover_1_r :
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000046 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=675-677
  `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000046 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=675-677
      algnst_wdata;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000066 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=674-678

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000067 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=680-685
  assign agu_icb_cmd_wmask =
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000047 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=681-684
  `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000047 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=681-684
         // If the 1st uop have bus-error, then not write the data for 2nd uop
      agu_i_amo ? (leftover_err_r ? 4'h0 : 4'hF) :
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000047 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=681-684
  `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000047 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=681-684
      algnst_wmask; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000067 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=680-685

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000068 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=687-691
  assign agu_icb_cmd_back2agu = 1'b0 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000048 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=688-690
             `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000048 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=688-690
                | agu_i_algnamo  
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000048 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=688-690
             `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000048 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=688-690
             ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000068 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=687-691
  //We dont support lock and exclusive in such 2 stage simple implementation
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000069 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=693-697
  assign agu_icb_cmd_lock     = 1'b0 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000049 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=694-696
             `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000049 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=694-696
                 | (agu_i_algnamo & icb_sta_is_idle)
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000049 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=694-696
             `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000049 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=694-696
                 ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000069 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=693-697
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000070 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=698-702
  assign agu_icb_cmd_excl     = 1'b0
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000050 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=699-701
             `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000050 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=699-701
                 | agu_i_excl
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000050 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=699-701
             `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:pp_blk:000050 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=699-701
                 ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000070 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=698-702

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000071 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=704-704
  assign agu_icb_cmd_itag     = agu_i_itag;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000071 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=704-704
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000072 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=705-705
  assign agu_icb_cmd_usign    = agu_i_usign;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000072 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=705-705
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000073 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=706-707
  assign agu_icb_cmd_size     = 
                agu_i_size;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:assign:000073 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=706-707
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:assign_cluster:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=674-707
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v:grp:bus_cluster:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_lsuagu.v lines=674-707


endmodule                                      
                                               
                                               
                                               
