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
//  The clock gating cell
//
// ====================================================================
`include "e203_defines.v"

module e203_clkgate (
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/e203_clkgate/e203_clkgate.v:grp:port_section:000001 file=e203_hbirdv2/e203_clkgate/e203_clkgate.v lines=29-32
  input   clk_in,
  input   test_mode,
  input   clock_en,
  output  clk_out
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/e203_clkgate/e203_clkgate.v:grp:port_section:000001 file=e203_hbirdv2/e203_clkgate/e203_clkgate.v lines=29-32
);

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_clkgate/e203_clkgate.v:pp_blk:000001 file=e203_hbirdv2/e203_clkgate/e203_clkgate.v lines=35-38
`ifdef FPGA_SOURCE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_clkgate/e203_clkgate.v:pp_blk:000001 file=e203_hbirdv2/e203_clkgate/e203_clkgate.v lines=35-38
    // In the FPGA, the clock gating is just pass through
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_clkgate/e203_clkgate.v:assign:000001 file=e203_hbirdv2/e203_clkgate/e203_clkgate.v lines=37-37
    assign clk_out = clk_in;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_clkgate/e203_clkgate.v:assign:000001 file=e203_hbirdv2/e203_clkgate/e203_clkgate.v lines=37-37
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_clkgate/e203_clkgate.v:pp_blk:000001 file=e203_hbirdv2/e203_clkgate/e203_clkgate.v lines=35-38
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_clkgate/e203_clkgate.v:pp_blk:000001 file=e203_hbirdv2/e203_clkgate/e203_clkgate.v lines=35-38

//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_clkgate/e203_clkgate.v:pp_blk:000002 file=e203_hbirdv2/e203_clkgate/e203_clkgate.v lines=40-50
`ifndef FPGA_SOURCE//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_clkgate/e203_clkgate.v:pp_blk:000002 file=e203_hbirdv2/e203_clkgate/e203_clkgate.v lines=40-50

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_clkgate/e203_clkgate.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_clkgate/e203_clkgate.v lines=42-42
reg enb;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_clkgate/e203_clkgate.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_clkgate/e203_clkgate.v lines=42-42

//__RB_CUT_BEGIN__ type=always id=e203_hbirdv2/e203_clkgate/e203_clkgate.v:proc:000001 file=e203_hbirdv2/e203_clkgate/e203_clkgate.v lines=44-46
always@(*)
//__RB_CUT_BODY__ type=always id=e203_hbirdv2/e203_clkgate/e203_clkgate.v:proc:000001 file=e203_hbirdv2/e203_clkgate/e203_clkgate.v lines=44-46
  if (!clk_in)
    enb = (clock_en | test_mode);
//__RB_CUT_TAIL__ type=always id=e203_hbirdv2/e203_clkgate/e203_clkgate.v:proc:000001 file=e203_hbirdv2/e203_clkgate/e203_clkgate.v lines=44-46
//__RB_CUT_END__ type=always id=e203_hbirdv2/e203_clkgate/e203_clkgate.v:proc:000001 file=e203_hbirdv2/e203_clkgate/e203_clkgate.v lines=44-46

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_clkgate/e203_clkgate.v:assign:000002 file=e203_hbirdv2/e203_clkgate/e203_clkgate.v lines=48-48
assign clk_out = enb & clk_in;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_clkgate/e203_clkgate.v:assign:000002 file=e203_hbirdv2/e203_clkgate/e203_clkgate.v lines=48-48

//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_clkgate/e203_clkgate.v:pp_blk:000002 file=e203_hbirdv2/e203_clkgate/e203_clkgate.v lines=40-50
`endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_clkgate/e203_clkgate.v:pp_blk:000002 file=e203_hbirdv2/e203_clkgate/e203_clkgate.v lines=40-50

endmodule 

