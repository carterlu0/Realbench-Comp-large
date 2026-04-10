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
//  The Clock Ctrl module to implement Clock control
//
// ====================================================================

`include "e203_defines.v"

module e203_clk_ctrl (
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:grp:port_section:000001 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=31-71
  input  clk,        // clock
  input  rst_n,      // async reset
  input  test_mode,  // test mode 

  // The cgstop is coming from CSR (0xBFE mcgstop)'s filed 0
  // // This register is our self-defined CSR register to disable the 
      // automaticall clock gating for CPU logics for debugging purpose
  input  core_cgstop,

  // The Top always on clk and rst
  output clk_aon,



  input  core_ifu_active,
  input  core_exu_active,
  input  core_lsu_active,
  input  core_biu_active,
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:pp_blk:000001 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=49-52
  `ifdef E203_HAS_ITCM
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:pp_blk:000001 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=49-52
  input  itcm_active,
  output itcm_ls,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:pp_blk:000001 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=49-52
  `endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:pp_blk:000001 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=49-52
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:pp_blk:000002 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=53-56
  `ifdef E203_HAS_DTCM
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:pp_blk:000002 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=53-56
  input  dtcm_active,
  output dtcm_ls,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:pp_blk:000002 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=53-56
  `endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:pp_blk:000002 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=53-56
    // The core's clk and rst
  output clk_core_ifu,
  output clk_core_exu,
  output clk_core_lsu,
  output clk_core_biu,

    // The ITCM/DTCM clk and rst
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:pp_blk:000003 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=64-66
  `ifdef E203_HAS_ITCM
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:pp_blk:000003 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=64-66
  output clk_itcm,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:pp_blk:000003 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=64-66
  `endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:pp_blk:000003 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=64-66
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:pp_blk:000004 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=67-69
  `ifdef E203_HAS_DTCM
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:pp_blk:000004 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=67-69
  output clk_dtcm,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:pp_blk:000004 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=67-69
  `endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:pp_blk:000004 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=67-69

  input  core_wfi
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:grp:port_section:000001 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=31-71
);

  // The CSR control bit CGSTOP will override the automatical clock gating here for special debug purpose

      // The IFU is always actively fetching unless it is WFI to override it
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=77-84
  wire ifu_clk_en = core_cgstop | (core_ifu_active & (~core_wfi));
      // The EXU, LSU and BIU module's clock gating does not need to check
      //  WFI because it may have request from external agent
      //  and also, it actually will automactically become inactive regardess
      //  currently is WFI or not, hence we dont need WFI here
  wire exu_clk_en = core_cgstop | (core_exu_active);
  wire lsu_clk_en = core_cgstop | (core_lsu_active);
  wire biu_clk_en = core_cgstop | (core_biu_active);
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=77-84




//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:inst:000001 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=89-94
  e203_clkgate u_ifu_clkgate(
    .clk_in   (clk        ),
    .test_mode(test_mode  ),
    .clock_en (ifu_clk_en),
    .clk_out  (clk_core_ifu)
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:inst:000001 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=89-94

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:inst:000002 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=96-101
  e203_clkgate u_exu_clkgate(
    .clk_in   (clk        ),
    .test_mode(test_mode  ),
    .clock_en (exu_clk_en),
    .clk_out  (clk_core_exu)
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:inst:000002 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=96-101

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:inst:000003 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=103-108
  e203_clkgate u_lsu_clkgate(
    .clk_in   (clk        ),
    .test_mode(test_mode  ),
    .clock_en (lsu_clk_en),
    .clk_out  (clk_core_lsu)
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:inst:000003 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=103-108

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:inst:000004 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=110-115
  e203_clkgate u_biu_clkgate(
    .clk_in   (clk        ),
    .test_mode(test_mode  ),
    .clock_en (biu_clk_en),
    .clk_out  (clk_core_biu)
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:inst:000004 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=110-115

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:pp_blk:000005 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=117-133
  `ifdef E203_HAS_ITCM
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:pp_blk:000005 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=117-133
      // The ITCM and DTCM Ctrl module's clock gating does not need to check
      //  WFI because it may have request from external agent
      //  and also, it actually will automactically become inactive regardess
      //  currently is WFI or not, hence we dont need WFI here
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=122-122
  wire itcm_active_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=122-122
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:inst:000005 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=123-123
  sirv_gnrl_dffr #(1)itcm_active_dffr(itcm_active, itcm_active_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:inst:000005 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=123-123
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=124-124
  wire itcm_clk_en = core_cgstop | itcm_active | itcm_active_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=124-124
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:assign:000001 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=125-125
  assign itcm_ls = ~itcm_clk_en;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:assign:000001 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=125-125

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:inst:000006 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=127-132
  e203_clkgate u_itcm_clkgate(
    .clk_in   (clk        ),
    .test_mode(test_mode  ),
    .clock_en (itcm_clk_en),
    .clk_out  (clk_itcm)
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:inst:000006 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=127-132
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:pp_blk:000005 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=117-133
  `endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:pp_blk:000005 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=117-133

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:pp_blk:000006 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=135-147
  `ifdef E203_HAS_DTCM
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=136-136
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:pp_blk:000006 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=135-147
  wire dtcm_active_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=136-136
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:inst:000007 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=137-137
  sirv_gnrl_dffr #(1)dtcm_active_dffr(dtcm_active, dtcm_active_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:inst:000007 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=137-137
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:grp:internal_signal:000005 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=138-138
  wire dtcm_clk_en = core_cgstop | dtcm_active | dtcm_active_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:grp:internal_signal:000005 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=138-138
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:assign:000002 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=139-139
  assign dtcm_ls = ~dtcm_clk_en;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:assign:000002 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=139-139

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:inst:000008 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=141-146
  e203_clkgate u_dtcm_clkgate(
    .clk_in   (clk        ),
    .test_mode(test_mode  ),
    .clock_en (dtcm_clk_en),
    .clk_out  (clk_dtcm)
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:inst:000008 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=141-146
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:pp_blk:000006 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=135-147
  `endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:pp_blk:000006 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=135-147


  // The Top always on clk and rst
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:assign:000003 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=151-151
  assign clk_aon = clk;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v:assign:000003 file=e203_hbirdv2/e203_clk_ctrl/e203_clk_ctrl.v lines=151-151

endmodule

