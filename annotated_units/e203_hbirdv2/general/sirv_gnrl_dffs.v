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
//  All of the general DFF and Latch modules
//
// ====================================================================

//


//
// ===========================================================================
//
// Description:
//  Verilog module sirv_gnrl DFF with Load-enable and Reset
//  Default reset value is 1
//
// ===========================================================================

module sirv_gnrl_dfflrs # (
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:port_section:000001 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=41-49
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:param_decl:000001 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=41-41
  parameter DW = 32
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:param_decl:000001 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=41-41
) (

  input               lden, 
  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,

  input               clk,
  input               rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:port_section:000001 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=41-49
);

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:internal_signal:000001 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=52-52
reg [DW-1:0] qout_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:internal_signal:000001 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=52-52

//__RB_CUT_BEGIN__ type=always id=e203_hbirdv2/general/sirv_gnrl_dffs.v:proc:000001 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=54-60
always @(posedge clk or negedge rst_n)
//__RB_CUT_BODY__ type=always id=e203_hbirdv2/general/sirv_gnrl_dffs.v:proc:000001 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=54-60
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_dffs.v:begin_end:000001 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=55-60
begin : DFFLRS_PROC
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_dffs.v:begin_end:000001 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=55-60
  if (rst_n == 1'b0)
    qout_r <= {DW{1'b1}};
  else if (lden == 1'b1)
    qout_r <= #1 dnxt;
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_dffs.v:begin_end:000001 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=55-60
end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_dffs.v:begin_end:000001 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=55-60
//__RB_CUT_TAIL__ type=always id=e203_hbirdv2/general/sirv_gnrl_dffs.v:proc:000001 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=54-60
//__RB_CUT_END__ type=always id=e203_hbirdv2/general/sirv_gnrl_dffs.v:proc:000001 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=54-60

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_dffs.v:assign:000001 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=62-62
assign qout = qout_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_dffs.v:assign:000001 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=62-62

//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_dffs.v:pp_blk:000002 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=64-75
`ifndef FPGA_SOURCE//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_dffs.v:pp_blk:000002 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=64-75
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_dffs.v:pp_blk:000001 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=65-74
`ifndef DISABLE_SV_ASSERTION//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_dffs.v:pp_blk:000001 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=65-74
//synopsys translate_off
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_dffs.v:inst:000001 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=67-72
sirv_gnrl_xchecker # (
  .DW(1)
) sirv_gnrl_xchecker(
  .i_dat(lden),
  .clk  (clk)
);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_dffs.v:inst:000001 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=67-72
//synopsys translate_on
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_dffs.v:pp_blk:000001 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=65-74
`endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_dffs.v:pp_blk:000001 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=65-74
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_dffs.v:pp_blk:000002 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=64-75
`endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_dffs.v:pp_blk:000002 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=64-75
    

endmodule
// ===========================================================================
//
// Description:
//  Verilog module sirv_gnrl DFF with Load-enable and Reset
//  Default reset value is 0
//
// ===========================================================================

module sirv_gnrl_dfflr # (
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:port_section:000002 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=88-96
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:param_decl:000002 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=88-88
  parameter DW = 32
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:param_decl:000002 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=88-88
) (

  input               lden, 
  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,

  input               clk,
  input               rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:port_section:000002 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=88-96
);

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:internal_signal:000002 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=99-99
reg [DW-1:0] qout_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:internal_signal:000002 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=99-99

//__RB_CUT_BEGIN__ type=always id=e203_hbirdv2/general/sirv_gnrl_dffs.v:proc:000002 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=101-107
always @(posedge clk or negedge rst_n)
//__RB_CUT_BODY__ type=always id=e203_hbirdv2/general/sirv_gnrl_dffs.v:proc:000002 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=101-107
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_dffs.v:begin_end:000002 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=102-107
begin : DFFLR_PROC
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_dffs.v:begin_end:000002 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=102-107
  if (rst_n == 1'b0)
    qout_r <= {DW{1'b0}};
  else if (lden == 1'b1)
    qout_r <= #1 dnxt;
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_dffs.v:begin_end:000002 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=102-107
end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_dffs.v:begin_end:000002 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=102-107
//__RB_CUT_TAIL__ type=always id=e203_hbirdv2/general/sirv_gnrl_dffs.v:proc:000002 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=101-107
//__RB_CUT_END__ type=always id=e203_hbirdv2/general/sirv_gnrl_dffs.v:proc:000002 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=101-107

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_dffs.v:assign:000002 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=109-109
assign qout = qout_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_dffs.v:assign:000002 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=109-109

//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_dffs.v:pp_blk:000004 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=111-122
`ifndef FPGA_SOURCE//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_dffs.v:pp_blk:000004 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=111-122
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_dffs.v:pp_blk:000003 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=112-121
`ifndef DISABLE_SV_ASSERTION//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_dffs.v:pp_blk:000003 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=112-121
//synopsys translate_off
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_dffs.v:inst:000002 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=114-119
sirv_gnrl_xchecker # (
  .DW(1)
) sirv_gnrl_xchecker(
  .i_dat(lden),
  .clk  (clk)
);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_dffs.v:inst:000002 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=114-119
//synopsys translate_on
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_dffs.v:pp_blk:000003 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=112-121
`endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_dffs.v:pp_blk:000003 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=112-121
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_dffs.v:pp_blk:000004 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=111-122
`endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_dffs.v:pp_blk:000004 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=111-122
    

endmodule
// ===========================================================================
//
// Description:
//  Verilog module sirv_gnrl DFF with Load-enable, no reset 
//
// ===========================================================================

module sirv_gnrl_dffl # (
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:port_section:000003 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=134-141
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:param_decl:000003 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=134-134
  parameter DW = 32
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:param_decl:000003 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=134-134
) (

  input               lden, 
  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,

  input               clk 
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:port_section:000003 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=134-141
);

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:internal_signal:000003 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=144-144
reg [DW-1:0] qout_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:internal_signal:000003 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=144-144

//__RB_CUT_BEGIN__ type=always id=e203_hbirdv2/general/sirv_gnrl_dffs.v:proc:000003 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=146-150
always @(posedge clk)
//__RB_CUT_BODY__ type=always id=e203_hbirdv2/general/sirv_gnrl_dffs.v:proc:000003 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=146-150
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_dffs.v:begin_end:000003 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=147-150
begin : DFFL_PROC
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_dffs.v:begin_end:000003 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=147-150
  if (lden == 1'b1)
    qout_r <= #1 dnxt;
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_dffs.v:begin_end:000003 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=147-150
end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_dffs.v:begin_end:000003 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=147-150
//__RB_CUT_TAIL__ type=always id=e203_hbirdv2/general/sirv_gnrl_dffs.v:proc:000003 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=146-150
//__RB_CUT_END__ type=always id=e203_hbirdv2/general/sirv_gnrl_dffs.v:proc:000003 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=146-150

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_dffs.v:assign:000003 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=152-152
assign qout = qout_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_dffs.v:assign:000003 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=152-152

//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_dffs.v:pp_blk:000006 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=154-165
`ifndef FPGA_SOURCE//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_dffs.v:pp_blk:000006 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=154-165
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_dffs.v:pp_blk:000005 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=155-164
`ifndef DISABLE_SV_ASSERTION//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_dffs.v:pp_blk:000005 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=155-164
//synopsys translate_off
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_dffs.v:inst:000003 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=157-162
sirv_gnrl_xchecker # (
  .DW(1)
) sirv_gnrl_xchecker(
  .i_dat(lden),
  .clk  (clk)
);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_dffs.v:inst:000003 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=157-162
//synopsys translate_on
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_dffs.v:pp_blk:000005 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=155-164
`endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_dffs.v:pp_blk:000005 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=155-164
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_dffs.v:pp_blk:000006 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=154-165
`endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_dffs.v:pp_blk:000006 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=154-165
    

endmodule
// ===========================================================================
//
// Description:
//  Verilog module sirv_gnrl DFF with Reset, no load-enable
//  Default reset value is 1
//
// ===========================================================================

module sirv_gnrl_dffrs # (
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:port_section:000004 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=178-185
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:param_decl:000004 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=178-178
  parameter DW = 32
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:param_decl:000004 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=178-178
) (

  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,

  input               clk,
  input               rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:port_section:000004 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=178-185
);

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:internal_signal:000004 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=188-188
reg [DW-1:0] qout_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:internal_signal:000004 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=188-188

//__RB_CUT_BEGIN__ type=always id=e203_hbirdv2/general/sirv_gnrl_dffs.v:proc:000004 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=190-196
always @(posedge clk or negedge rst_n)
//__RB_CUT_BODY__ type=always id=e203_hbirdv2/general/sirv_gnrl_dffs.v:proc:000004 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=190-196
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_dffs.v:begin_end:000004 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=191-196
begin : DFFRS_PROC
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_dffs.v:begin_end:000004 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=191-196
  if (rst_n == 1'b0)
    qout_r <= {DW{1'b1}};
  else                  
    qout_r <= #1 dnxt;
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_dffs.v:begin_end:000004 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=191-196
end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_dffs.v:begin_end:000004 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=191-196
//__RB_CUT_TAIL__ type=always id=e203_hbirdv2/general/sirv_gnrl_dffs.v:proc:000004 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=190-196
//__RB_CUT_END__ type=always id=e203_hbirdv2/general/sirv_gnrl_dffs.v:proc:000004 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=190-196

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_dffs.v:assign:000004 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=198-198
assign qout = qout_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_dffs.v:assign:000004 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=198-198

endmodule
// ===========================================================================
//
// Description:
//  Verilog module sirv_gnrl DFF with Reset, no load-enable
//  Default reset value is 0
//
// ===========================================================================

module sirv_gnrl_dffr # (
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:port_section:000005 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=210-217
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:param_decl:000005 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=210-210
  parameter DW = 32
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:param_decl:000005 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=210-210
) (

  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,

  input               clk,
  input               rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:port_section:000005 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=210-217
);

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:internal_signal:000005 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=220-220
reg [DW-1:0] qout_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:internal_signal:000005 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=220-220

//__RB_CUT_BEGIN__ type=always id=e203_hbirdv2/general/sirv_gnrl_dffs.v:proc:000005 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=222-228
always @(posedge clk or negedge rst_n)
//__RB_CUT_BODY__ type=always id=e203_hbirdv2/general/sirv_gnrl_dffs.v:proc:000005 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=222-228
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_dffs.v:begin_end:000005 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=223-228
begin : DFFR_PROC
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_dffs.v:begin_end:000005 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=223-228
  if (rst_n == 1'b0)
    qout_r <= {DW{1'b0}};
  else                  
    qout_r <= #1 dnxt;
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_dffs.v:begin_end:000005 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=223-228
end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_dffs.v:begin_end:000005 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=223-228
//__RB_CUT_TAIL__ type=always id=e203_hbirdv2/general/sirv_gnrl_dffs.v:proc:000005 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=222-228
//__RB_CUT_END__ type=always id=e203_hbirdv2/general/sirv_gnrl_dffs.v:proc:000005 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=222-228

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_dffs.v:assign:000005 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=230-230
assign qout = qout_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_dffs.v:assign:000005 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=230-230

endmodule
// ===========================================================================
//
// Description:
//  Verilog module for general latch 
//
// ===========================================================================

module sirv_gnrl_ltch # (
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:port_section:000006 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=241-247
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:param_decl:000006 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=241-241
  parameter DW = 32
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:param_decl:000006 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=241-241
) (

  //input               test_mode,
  input               lden, 
  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:port_section:000006 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=241-247
);

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:internal_signal:000006 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=250-250
reg [DW-1:0] qout_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_dffs.v:grp:internal_signal:000006 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=250-250

//__RB_CUT_BEGIN__ type=always id=e203_hbirdv2/general/sirv_gnrl_dffs.v:proc:000006 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=252-256
always @ * 
//__RB_CUT_BODY__ type=always id=e203_hbirdv2/general/sirv_gnrl_dffs.v:proc:000006 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=252-256
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_dffs.v:begin_end:000006 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=253-256
begin : LTCH_PROC
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_dffs.v:begin_end:000006 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=253-256
  if (lden == 1'b1)
    qout_r <= dnxt;
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_dffs.v:begin_end:000006 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=253-256
end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_dffs.v:begin_end:000006 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=253-256
//__RB_CUT_TAIL__ type=always id=e203_hbirdv2/general/sirv_gnrl_dffs.v:proc:000006 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=252-256
//__RB_CUT_END__ type=always id=e203_hbirdv2/general/sirv_gnrl_dffs.v:proc:000006 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=252-256

//assign qout = test_mode ? dnxt : qout_r;
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_dffs.v:assign:000006 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=259-259
assign qout = qout_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_dffs.v:assign:000006 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=259-259

//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_dffs.v:pp_blk:000008 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=261-273
`ifndef FPGA_SOURCE//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_dffs.v:pp_blk:000008 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=261-273
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_dffs.v:pp_blk:000007 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=262-272
`ifndef DISABLE_SV_ASSERTION//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_dffs.v:pp_blk:000007 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=262-272
//synopsys translate_off
//__RB_CUT_BEGIN__ type=always_comb id=e203_hbirdv2/general/sirv_gnrl_dffs.v:proc:000007 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=264-269
always_comb
//__RB_CUT_BODY__ type=always_comb id=e203_hbirdv2/general/sirv_gnrl_dffs.v:proc:000007 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=264-269
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_dffs.v:begin_end:000007 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=265-269
begin
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_dffs.v:begin_end:000007 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=265-269
  CHECK_THE_X_VALUE:
    assert (lden !== 1'bx) 
    else $fatal ("\n Error: Oops, detected a X value!!! This should never happen. \n");
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_dffs.v:begin_end:000007 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=265-269
end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_dffs.v:begin_end:000007 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=265-269
//__RB_CUT_TAIL__ type=always_comb id=e203_hbirdv2/general/sirv_gnrl_dffs.v:proc:000007 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=264-269
//__RB_CUT_END__ type=always_comb id=e203_hbirdv2/general/sirv_gnrl_dffs.v:proc:000007 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=264-269

//synopsys translate_on
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_dffs.v:pp_blk:000007 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=262-272
`endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_dffs.v:pp_blk:000007 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=262-272
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_dffs.v:pp_blk:000008 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=261-273
`endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_gnrl_dffs.v:pp_blk:000008 file=e203_hbirdv2/general/sirv_gnrl_dffs.v lines=261-273
    

endmodule
