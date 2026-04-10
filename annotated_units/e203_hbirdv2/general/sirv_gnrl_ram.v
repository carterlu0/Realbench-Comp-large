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
//  The top level RAM module
//
// ====================================================================

module sirv_gnrl_ram
#(parameter DP = 32,
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_ram.v:grp:param_decl:000001 file=e203_hbirdv2/general/sirv_gnrl_ram.v lines=30-33
  parameter DW = 32,
  parameter FORCE_X2ZERO = 1,
  parameter MW = 4,
  parameter AW = 15 
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_ram.v:grp:param_decl:000001 file=e203_hbirdv2/general/sirv_gnrl_ram.v lines=30-33
  ) (
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_ram.v:grp:port_section:000001 file=e203_hbirdv2/general/sirv_gnrl_ram.v lines=35-46
  input            sd,
  input            ds,
  input            ls,

  input            rst_n,
  input            clk,
  input            cs,
  input            we,
  input [AW-1:0]   addr,
  input [DW-1:0]   din,
  input [MW-1:0]   wem,
  output[DW-1:0]   dout
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_ram.v:grp:port_section:000001 file=e203_hbirdv2/general/sirv_gnrl_ram.v lines=35-46
);

//To add the ASIC or FPGA or Sim-model control here
// This is the Sim-model
//
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/general/sirv_gnrl_ram.v:pp_blk:000001 file=e203_hbirdv2/general/sirv_gnrl_ram.v lines=52-85
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/general/sirv_gnrl_ram.v:pp_blk:000001:br:000001 file=e203_hbirdv2/general/sirv_gnrl_ram.v lines=52-67
`ifdef FPGA_SOURCE
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/general/sirv_gnrl_ram.v:pp_blk:000001 file=e203_hbirdv2/general/sirv_gnrl_ram.v lines=52-85
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/general/sirv_gnrl_ram.v:pp_blk:000001:br:000001 file=e203_hbirdv2/general/sirv_gnrl_ram.v lines=52-67
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_ram.v:inst:000001 file=e203_hbirdv2/general/sirv_gnrl_ram.v lines=53-67
sirv_sim_ram #(
    .FORCE_X2ZERO (1'b0),
    .DP (DP),
    .AW (AW),
    .MW (MW),
    .DW (DW) 
)u_sirv_sim_ram (
    .clk   (clk),
    .din   (din),
    .addr  (addr),
    .cs    (cs),
    .we    (we),
    .wem   (wem),
    .dout  (dout)
);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_ram.v:inst:000001 file=e203_hbirdv2/general/sirv_gnrl_ram.v lines=53-67
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/general/sirv_gnrl_ram.v:pp_blk:000001:br:000001 file=e203_hbirdv2/general/sirv_gnrl_ram.v lines=52-67
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/general/sirv_gnrl_ram.v:pp_blk:000001:br:000001 file=e203_hbirdv2/general/sirv_gnrl_ram.v lines=52-67
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/general/sirv_gnrl_ram.v:pp_blk:000001:br:000002 file=e203_hbirdv2/general/sirv_gnrl_ram.v lines=68-84
`else
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/general/sirv_gnrl_ram.v:pp_blk:000001:br:000002 file=e203_hbirdv2/general/sirv_gnrl_ram.v lines=68-84

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_ram.v:inst:000002 file=e203_hbirdv2/general/sirv_gnrl_ram.v lines=70-84
sirv_sim_ram #(
    .FORCE_X2ZERO (FORCE_X2ZERO),
    .DP (DP),
    .AW (AW),
    .MW (MW),
    .DW (DW) 
)u_sirv_sim_ram (
    .clk   (clk),
    .din   (din),
    .addr  (addr),
    .cs    (cs),
    .we    (we),
    .wem   (wem),
    .dout  (dout)
);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_ram.v:inst:000002 file=e203_hbirdv2/general/sirv_gnrl_ram.v lines=70-84
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/general/sirv_gnrl_ram.v:pp_blk:000001:br:000002 file=e203_hbirdv2/general/sirv_gnrl_ram.v lines=68-84
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/general/sirv_gnrl_ram.v:pp_blk:000001:br:000002 file=e203_hbirdv2/general/sirv_gnrl_ram.v lines=68-84
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/general/sirv_gnrl_ram.v:pp_blk:000001 file=e203_hbirdv2/general/sirv_gnrl_ram.v lines=52-85
`endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/general/sirv_gnrl_ram.v:pp_blk:000001 file=e203_hbirdv2/general/sirv_gnrl_ram.v lines=52-85

endmodule
