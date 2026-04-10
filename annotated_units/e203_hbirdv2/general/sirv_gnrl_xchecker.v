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
//  Verilog module for X checker
//
// ====================================================================


//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_xchecker.v:pp_blk:000002 file=e203_hbirdv2/general/sirv_gnrl_xchecker.v lines=29-49
`ifndef FPGA_SOURCE//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_xchecker.v:pp_blk:000002 file=e203_hbirdv2/general/sirv_gnrl_xchecker.v lines=29-49
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_xchecker.v:pp_blk:000001 file=e203_hbirdv2/general/sirv_gnrl_xchecker.v lines=30-48
`ifndef DISABLE_SV_ASSERTION//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_xchecker.v:pp_blk:000001 file=e203_hbirdv2/general/sirv_gnrl_xchecker.v lines=30-48
//synopsys translate_off
module sirv_gnrl_xchecker # (
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_xchecker.v:grp:port_section:000001 file=e203_hbirdv2/general/sirv_gnrl_xchecker.v lines=33-36
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_xchecker.v:grp:param_decl:000001 file=e203_hbirdv2/general/sirv_gnrl_xchecker.v lines=33-33
  parameter DW = 32
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_xchecker.v:grp:param_decl:000001 file=e203_hbirdv2/general/sirv_gnrl_xchecker.v lines=33-33
) (
  input  [DW-1:0] i_dat,
  input clk
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_xchecker.v:grp:port_section:000001 file=e203_hbirdv2/general/sirv_gnrl_xchecker.v lines=33-36
);


CHECK_THE_X_VALUE:
  assert property (@(posedge clk) 
                     ((^(i_dat)) !== 1'bx)
                  )
  else $fatal ("\n Error: Oops, detected a X value!!! This should never happen. \n");

endmodule
//synopsys translate_on
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_xchecker.v:pp_blk:000001 file=e203_hbirdv2/general/sirv_gnrl_xchecker.v lines=30-48
`endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_xchecker.v:pp_blk:000001 file=e203_hbirdv2/general/sirv_gnrl_xchecker.v lines=30-48
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_xchecker.v:pp_blk:000002 file=e203_hbirdv2/general/sirv_gnrl_xchecker.v lines=29-49
`endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_xchecker.v:pp_blk:000002 file=e203_hbirdv2/general/sirv_gnrl_xchecker.v lines=29-49
