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
//  The ITCM-SRAM module to implement ITCM SRAM
//
// ====================================================================

`include "e203_defines.v"

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ram/e203_itcm_ram.v:pp_blk:000002 file=e203_hbirdv2/e203_itcm_ram/e203_itcm_ram.v lines=29-72
  `ifdef E203_HAS_ITCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ram/e203_itcm_ram.v:pp_blk:000002 file=e203_hbirdv2/e203_itcm_ram/e203_itcm_ram.v lines=29-72
module e203_itcm_ram(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/e203_itcm_ram/e203_itcm_ram.v:grp:port_section:000001 file=e203_hbirdv2/e203_itcm_ram/e203_itcm_ram.v lines=31-44

  input                              sd,
  input                              ds,
  input                              ls,

  input                              cs,  
  input                              we,  
  input  [`E203_ITCM_RAM_AW-1:0] addr, 
  input  [`E203_ITCM_RAM_MW-1:0] wem,
  input  [`E203_ITCM_RAM_DW-1:0] din,          
  output [`E203_ITCM_RAM_DW-1:0] dout,
  input                              rst_n,
  input                              clk

//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/e203_itcm_ram/e203_itcm_ram.v:grp:port_section:000001 file=e203_hbirdv2/e203_itcm_ram/e203_itcm_ram.v lines=31-44
);

 
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_itcm_ram/e203_itcm_ram.v:inst:000001 file=e203_hbirdv2/e203_itcm_ram/e203_itcm_ram.v lines=48-69
  sirv_gnrl_ram #(
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_itcm_ram/e203_itcm_ram.v:pp_blk:000001 file=e203_hbirdv2/e203_itcm_ram/e203_itcm_ram.v lines=49-51
      `ifndef E203_HAS_ECC//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_itcm_ram/e203_itcm_ram.v:pp_blk:000001 file=e203_hbirdv2/e203_itcm_ram/e203_itcm_ram.v lines=49-51
    .FORCE_X2ZERO(0),
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_itcm_ram/e203_itcm_ram.v:pp_blk:000001 file=e203_hbirdv2/e203_itcm_ram/e203_itcm_ram.v lines=49-51
      `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_itcm_ram/e203_itcm_ram.v:pp_blk:000001 file=e203_hbirdv2/e203_itcm_ram/e203_itcm_ram.v lines=49-51
    .DP(`E203_ITCM_RAM_DP),
    .DW(`E203_ITCM_RAM_DW),
    .MW(`E203_ITCM_RAM_MW),
    .AW(`E203_ITCM_RAM_AW) 
  ) u_e203_itcm_gnrl_ram(
  .sd  (sd  ),
  .ds  (ds  ),
  .ls  (ls  ),

  .rst_n (rst_n ),
  .clk (clk ),
  .cs  (cs  ),
  .we  (we  ),
  .addr(addr),
  .din (din ),
  .wem (wem ),
  .dout(dout)
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_itcm_ram/e203_itcm_ram.v:inst:000001 file=e203_hbirdv2/e203_itcm_ram/e203_itcm_ram.v lines=48-69
                                                      
endmodule
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ram/e203_itcm_ram.v:pp_blk:000002 file=e203_hbirdv2/e203_itcm_ram/e203_itcm_ram.v lines=29-72
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ram/e203_itcm_ram.v:pp_blk:000002 file=e203_hbirdv2/e203_itcm_ram/e203_itcm_ram.v lines=29-72
