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
//  The SRAM module to implement all SRAMs
//
// ====================================================================

`include "e203_defines.v"

module e203_srams(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/e203_srams/e203_srams.v:grp:port_section:000001 file=e203_hbirdv2/e203_srams/e203_srams.v lines=31-63

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_srams/e203_srams.v:pp_blk:000001 file=e203_hbirdv2/e203_srams/e203_srams.v lines=32-45
  `ifdef E203_HtAS_ITCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_srams/e203_srams.v:pp_blk:000001 file=e203_hbirdv2/e203_srams/e203_srams.v lines=32-45
  input  itcm_ram_sd,
  input  itcm_ram_ds,
  input  itcm_ram_ls,

  input                          itcm_ram_cs,  
  input                          itcm_ram_we,  
  input  [`E203_ITCM_RAM_AW-1:0] itcm_ram_addr, 
  input  [`E203_ITCM_RAM_MW-1:0] itcm_ram_wem,
  input  [`E203_ITCM_RAM_DW-1:0] itcm_ram_din,          
  output [`E203_ITCM_RAM_DW-1:0] itcm_ram_dout,
  input                          clk_itcm_ram,
  input  rst_itcm,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_srams/e203_srams.v:pp_blk:000001 file=e203_hbirdv2/e203_srams/e203_srams.v lines=32-45
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_srams/e203_srams.v:pp_blk:000001 file=e203_hbirdv2/e203_srams/e203_srams.v lines=32-45

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_srams/e203_srams.v:pp_blk:000002 file=e203_hbirdv2/e203_srams/e203_srams.v lines=47-60
  `ifdef E203_HAS_DTCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_srams/e203_srams.v:pp_blk:000002 file=e203_hbirdv2/e203_srams/e203_srams.v lines=47-60
  input  dtcm_ram_sd,
  input  dtcm_ram_ds,
  input  dtcm_ram_ls,

  input                          dtcm_ram_cs,  
  input                          dtcm_ram_we,  
  input  [`E203_DTCM_RAM_AW-1:0] dtcm_ram_addr, 
  input  [`E203_DTCM_RAM_MW-1:0] dtcm_ram_wem,
  input  [`E203_DTCM_RAM_DW-1:0] dtcm_ram_din,          
  output [`E203_DTCM_RAM_DW-1:0] dtcm_ram_dout,
  input                          clk_dtcm_ram,
  input  rst_dtcm,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_srams/e203_srams.v:pp_blk:000002 file=e203_hbirdv2/e203_srams/e203_srams.v lines=47-60
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_srams/e203_srams.v:pp_blk:000002 file=e203_hbirdv2/e203_srams/e203_srams.v lines=47-60

  input  test_mode

//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/e203_srams/e203_srams.v:grp:port_section:000001 file=e203_hbirdv2/e203_srams/e203_srams.v lines=31-63
);


                                                      
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_srams/e203_srams.v:pp_blk:000003 file=e203_hbirdv2/e203_srams/e203_srams.v lines=68-89
  `ifdef E203_HAS_ITCM //{
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_srams/e203_srams.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_srams/e203_srams.v lines=69-69
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_srams/e203_srams.v:pp_blk:000003 file=e203_hbirdv2/e203_srams/e203_srams.v lines=68-89
  wire [`E203_ITCM_RAM_DW-1:0]  itcm_ram_dout_pre;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_srams/e203_srams.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_srams/e203_srams.v lines=69-69

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_srams/e203_srams.v:inst:000001 file=e203_hbirdv2/e203_srams/e203_srams.v lines=71-84
  e203_itcm_ram u_e203_itcm_ram (
    .sd   (itcm_ram_sd),
    .ds   (itcm_ram_ds),
    .ls   (itcm_ram_ls),
  
    .cs   (itcm_ram_cs   ),
    .we   (itcm_ram_we   ),
    .addr (itcm_ram_addr ),
    .wem  (itcm_ram_wem  ),
    .din  (itcm_ram_din  ),
    .dout (itcm_ram_dout_pre ),
    .rst_n(rst_itcm      ),
    .clk  (clk_itcm_ram  )
    );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_srams/e203_srams.v:inst:000001 file=e203_hbirdv2/e203_srams/e203_srams.v lines=71-84
    
  // Bob: we dont need this bypass here, actually the DFT tools will handle this SRAM black box 
  //assign itcm_ram_dout = test_mode ? itcm_ram_din : itcm_ram_dout_pre;
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_srams/e203_srams.v:assign:000001 file=e203_hbirdv2/e203_srams/e203_srams.v lines=88-88
  assign itcm_ram_dout = itcm_ram_dout_pre;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_srams/e203_srams.v:assign:000001 file=e203_hbirdv2/e203_srams/e203_srams.v lines=88-88
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_srams/e203_srams.v:pp_blk:000003 file=e203_hbirdv2/e203_srams/e203_srams.v lines=68-89
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_srams/e203_srams.v:pp_blk:000003 file=e203_hbirdv2/e203_srams/e203_srams.v lines=68-89

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_srams/e203_srams.v:pp_blk:000004 file=e203_hbirdv2/e203_srams/e203_srams.v lines=91-112
  `ifdef E203_HAS_DTCM //{
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_srams/e203_srams.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_srams/e203_srams.v lines=92-92
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_srams/e203_srams.v:pp_blk:000004 file=e203_hbirdv2/e203_srams/e203_srams.v lines=91-112
  wire [`E203_DTCM_RAM_DW-1:0]  dtcm_ram_dout_pre;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_srams/e203_srams.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_srams/e203_srams.v lines=92-92

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_srams/e203_srams.v:inst:000002 file=e203_hbirdv2/e203_srams/e203_srams.v lines=94-107
  e203_dtcm_ram u_e203_dtcm_ram (
    .sd   (dtcm_ram_sd),
    .ds   (dtcm_ram_ds),
    .ls   (dtcm_ram_ls),
  
    .cs   (dtcm_ram_cs   ),
    .we   (dtcm_ram_we   ),
    .addr (dtcm_ram_addr ),
    .wem  (dtcm_ram_wem  ),
    .din  (dtcm_ram_din  ),
    .dout (dtcm_ram_dout_pre ),
    .rst_n(rst_dtcm      ),
    .clk  (clk_dtcm_ram  )
    );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_srams/e203_srams.v:inst:000002 file=e203_hbirdv2/e203_srams/e203_srams.v lines=94-107
    
  // Bob: we dont need this bypass here, actually the DFT tools will handle this SRAM black box 
  //assign dtcm_ram_dout = test_mode ? dtcm_ram_din : dtcm_ram_dout_pre;
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_srams/e203_srams.v:assign:000002 file=e203_hbirdv2/e203_srams/e203_srams.v lines=111-111
  assign dtcm_ram_dout = dtcm_ram_dout_pre;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_srams/e203_srams.v:assign:000002 file=e203_hbirdv2/e203_srams/e203_srams.v lines=111-111
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_srams/e203_srams.v:pp_blk:000004 file=e203_hbirdv2/e203_srams/e203_srams.v lines=91-112
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_srams/e203_srams.v:pp_blk:000004 file=e203_hbirdv2/e203_srams/e203_srams.v lines=91-112

endmodule
