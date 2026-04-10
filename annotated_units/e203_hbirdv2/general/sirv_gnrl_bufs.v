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
//  Some of the basic functions like pipeline stage and buffers
//
// ====================================================================

module sirv_gnrl_pipe_stage # (
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:port_section:000001 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=29-43
  // When the depth is 1, the ready signal may relevant to next stage's ready, hence become logic
  // chains. Use CUT_READY to control it
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:param_decl:000001 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=31-33
  parameter CUT_READY = 0,
  parameter DP = 1,
  parameter DW = 32
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:param_decl:000001 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=31-33
) (
  input           i_vld, 
  output          i_rdy, 
  input  [DW-1:0] i_dat,
  output          o_vld, 
  input           o_rdy, 
  output [DW-1:0] o_dat,

  input           clk,
  input           rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:port_section:000001 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=29-43
);

  genvar i;
//__RB_CUT_BEGIN__ type=generate id=e203_hbirdv2/general/sirv_gnrl_bufs.v:generate:000001 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=47-87
  generate //{
//__RB_CUT_BODY__ type=generate id=e203_hbirdv2/general/sirv_gnrl_bufs.v:generate:000001 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=47-87

//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000001 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=49-55
  if(DP == 0) begin: dp_eq_0//{ pass through
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000001 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=49-55

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:assign_cluster:000001 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=51-53
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000001 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=51-51
      assign o_vld = i_vld;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000001 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=51-51
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000002 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=52-52
      assign i_rdy = o_rdy;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000002 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=52-52
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000003 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=53-53
      assign o_dat = i_dat;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000003 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=53-53
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:assign_cluster:000001 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=51-53

//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000001 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=49-55
  end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000001 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=49-55
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000004 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=56-86
  else begin: dp_gt_0//{
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000004 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=56-86

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:internal_signal:000001 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=58-62
      wire vld_set;
      wire vld_clr;
      wire vld_ena;
      wire vld_r;
      wire vld_nxt;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:internal_signal:000001 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=58-62

      // The valid will be set when input handshaked
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:assign_cluster:000002 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=65-70
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000004 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=65-65
      assign vld_set = i_vld & i_rdy;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000004 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=65-65
      // The valid will be clr when output handshaked
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000005 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=67-67
      assign vld_clr = o_vld & o_rdy;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000005 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=67-67

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000006 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=69-69
      assign vld_ena = vld_set | vld_clr;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000006 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=69-69
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000007 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=70-70
      assign vld_nxt = vld_set | (~vld_clr);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000007 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=70-70
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:assign_cluster:000002 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=65-70

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000001 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=72-72
      sirv_gnrl_dfflr #(1) vld_dfflr (vld_ena, vld_nxt, vld_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000001 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=72-72

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000008 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=74-74
      assign o_vld = vld_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000008 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=74-74

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000002 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=76-76
      sirv_gnrl_dffl #(DW) dat_dfflr (vld_set, i_dat, o_dat, clk);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000002 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=76-76

//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000002 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=78-81
      if(CUT_READY == 1) begin:cut_ready//{
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000002 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=78-81
          // If cut ready, then only accept when stage is not full
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000009 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=80-80
          assign i_rdy = (~vld_r);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000009 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=80-80
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000002 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=78-81
      end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000002 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=78-81
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000003 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=82-85
      else begin:no_cut_ready//{
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000003 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=82-85
          // If not cut ready, then can accept when stage is not full or it is popping 
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000010 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=84-84
          assign i_rdy = (~vld_r) | vld_clr;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000010 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=84-84
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000003 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=82-85
      end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000003 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=82-85
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000004 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=56-86
  end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000004 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=56-86
//__RB_CUT_TAIL__ type=generate id=e203_hbirdv2/general/sirv_gnrl_bufs.v:generate:000001 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=47-87
  endgenerate//}
//__RB_CUT_END__ type=generate id=e203_hbirdv2/general/sirv_gnrl_bufs.v:generate:000001 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=47-87


endmodule 

// ===========================================================================
//
// Description:
//  Syncer to sync async signal to synced as general module
//
// ===========================================================================

module sirv_gnrl_sync # (
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:port_section:000002 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=100-107
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:param_decl:000002 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=100-101
  parameter DP = 2,
  parameter DW = 32
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:param_decl:000002 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=100-101
) (
  input  [DW-1:0] din_a,
  output [DW-1:0] dout,

  input           rst_n, 
  input           clk 
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:port_section:000002 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=100-107
);

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:internal_signal:000002 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=110-110
  wire [DW-1:0] sync_dat [DP-1:0];
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:internal_signal:000002 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=110-110
    
  genvar i;

//__RB_CUT_BEGIN__ type=generate id=e203_hbirdv2/general/sirv_gnrl_bufs.v:generate:000002 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=114-123
  generate 
//__RB_CUT_BODY__ type=generate id=e203_hbirdv2/general/sirv_gnrl_bufs.v:generate:000002 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=114-123
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000007 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=115-122
    for(i=0;i<DP;i=i+1) begin:sync_gen
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000007 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=115-122
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000005 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=116-118
      if(i==0) begin:i_is_0
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000005 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=116-118
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000003 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=117-117
        sirv_gnrl_dffr #(DW) sync_dffr(din_a,         sync_dat[0], clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000003 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=117-117
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000005 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=116-118
      end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000005 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=116-118
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000006 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=119-121
      else begin:i_is_not_0
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000006 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=119-121
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000004 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=120-120
        sirv_gnrl_dffr #(DW) sync_dffr(sync_dat[i-1], sync_dat[i], clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000004 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=120-120
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000006 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=119-121
      end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000006 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=119-121
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000007 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=115-122
    end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000007 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=115-122
//__RB_CUT_TAIL__ type=generate id=e203_hbirdv2/general/sirv_gnrl_bufs.v:generate:000002 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=114-123
  endgenerate
//__RB_CUT_END__ type=generate id=e203_hbirdv2/general/sirv_gnrl_bufs.v:generate:000002 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=114-123

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000011 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=125-125
  assign dout = sync_dat[DP-1];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000011 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=125-125
  
endmodule
// ===========================================================================
//
// Description:
//  Verilog module for round-robin arbitration
//
// ===========================================================================


// ====================================================================
// Description:
//  Verilog module sirv_gnrl cdc rx to receive the async handshake interface 
//
// ====================================================================
//
module sirv_gnrl_cdc_rx
# (
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:port_section:000003 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=144-163
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:param_decl:000003 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=144-145
  parameter DW = 32,
  parameter SYNC_DP = 2
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:param_decl:000003 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=144-145
) (
  // The 4-phases handshake interface at in-side
  //     There are 4 steps required for a full transaction. 
  //         (1) The i_vld is asserted high 
  //         (2) The i_rdy is asserted high
  //         (3) The i_vld is asserted low 
  //         (4) The i_rdy is asserted low
  input  i_vld_a, 
  output i_rdy, 
  input  [DW-1:0] i_dat,
  // The regular handshake interface at out-side
  //         Just the regular handshake o_vld & o_rdy like AXI
  output o_vld, 
  input  o_rdy, 
  output [DW-1:0] o_dat,

  input  clk,
  input  rst_n 
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:port_section:000003 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=144-163
);

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:internal_signal:000003 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=166-166
wire i_vld_sync;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:internal_signal:000003 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=166-166
// Sync the async signal first
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000005 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=168-173
sirv_gnrl_sync #(.DP(SYNC_DP), .DW(1)) u_i_vld_sync (
     .clk   (clk),
     .rst_n (rst_n),
     .din_a (i_vld_a),
     .dout  (i_vld_sync)
    );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000005 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=168-173

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:internal_signal:000004 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=175-175
wire i_vld_sync_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:internal_signal:000004 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=175-175
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000006 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=176-176
sirv_gnrl_dffr #(1) i_vld_sync_dffr(i_vld_sync, i_vld_sync_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000006 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=176-176
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:internal_signal:000005 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=177-187
wire i_vld_sync_nedge = (~i_vld_sync) & i_vld_sync_r;

wire buf_rdy;
wire i_rdy_r;
// Because it is a 4-phases handshake, so 
//   The i_rdy is set (assert to high) when the buf is ready (can save data) and incoming valid detected
//   The i_rdy is clear when i_vld neg-edge is detected
wire i_rdy_set = buf_rdy & i_vld_sync & (~i_rdy_r);
wire i_rdy_clr = i_vld_sync_nedge;
wire i_rdy_ena = i_rdy_set |   i_rdy_clr;
wire i_rdy_nxt = i_rdy_set | (~i_rdy_clr);
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:internal_signal:000005 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=177-187
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000007 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=188-188
sirv_gnrl_dfflr #(1) i_rdy_dfflr(i_rdy_ena, i_rdy_nxt, i_rdy_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000007 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=188-188
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000012 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=189-189
assign i_rdy = i_rdy_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000012 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=189-189


//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:internal_signal:000006 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=192-197
wire buf_vld_r;
wire [DW-1:0] buf_dat_r;

// The buf is loaded with data when i_rdy is set high (i.e., 
//   when the buf is ready (can save data) and incoming valid detected
wire buf_dat_ena = i_rdy_set;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:internal_signal:000006 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=192-197
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000008 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=198-198
sirv_gnrl_dfflr #(DW) buf_dat_dfflr(buf_dat_ena, i_dat, buf_dat_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000008 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=198-198

// The buf_vld is set when the buf is loaded with data
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:internal_signal:000007 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=201-205
wire buf_vld_set = buf_dat_ena;
// The buf_vld is clr when the buf is handshaked at the out-end
wire buf_vld_clr = o_vld & o_rdy;
wire buf_vld_ena = buf_vld_set | buf_vld_clr;
wire buf_vld_nxt = buf_vld_set | (~buf_vld_clr);
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:internal_signal:000007 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=201-205
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000009 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=206-206
sirv_gnrl_dfflr #(1) buf_vld_dfflr(buf_vld_ena, buf_vld_nxt, buf_vld_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000009 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=206-206
// The buf is ready when the buf is empty
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:assign_cluster:000003 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=208-211
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000013 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=208-208
assign buf_rdy = (~buf_vld_r);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000013 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=208-208

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000014 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=210-210
assign o_vld = buf_vld_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000014 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=210-210
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000015 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=211-211
assign o_dat = buf_dat_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000015 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=211-211
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:assign_cluster:000003 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=208-211

endmodule 

// ===========================================================================
//
// Description:
//  Verilog module sirv_gnrl cdc tx to transmit the async handshake interface 
//
// ===========================================================================
// Configuration-dependent macro definitions
//
module sirv_gnrl_cdc_tx
# (
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:port_section:000004 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=225-245
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:param_decl:000004 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=225-226
  parameter DW = 32,
  parameter SYNC_DP = 2
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:param_decl:000004 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=225-226
) (
  // The regular handshake interface at in-side
  //         Just the regular handshake o_vld & o_rdy like AXI
  input  i_vld, 
  output i_rdy, 
  input  [DW-1:0] i_dat,

  // The 4-phases handshake interface at out-side
  //     There are 4 steps required for a full transaction. 
  //         (1) The i_vld is asserted high 
  //         (2) The i_rdy is asserted high
  //         (3) The i_vld is asserted low 
  //         (4) The i_rdy is asserted low
  output o_vld, 
  input  o_rdy_a, 
  output [DW-1:0] o_dat,

  input  clk,
  input  rst_n 
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:port_section:000004 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=225-245
);

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:internal_signal:000008 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=248-248
wire o_rdy_sync;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:internal_signal:000008 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=248-248

// Sync the async signal first
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000010 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=251-259
sirv_gnrl_sync #(
    .DP(SYNC_DP), 
    .DW(1)
) u_o_rdy_sync (
         .clk   (clk),
         .rst_n (rst_n),
         .din_a (o_rdy_a),
         .dout  (o_rdy_sync)
        );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000010 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=251-259

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:internal_signal:000009 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=261-269
wire vld_r;
wire [DW-1:0] dat_r;

// Valid set when it is handshaked
wire vld_set = i_vld & i_rdy;
// Valid clr when the TX o_rdy is high
wire vld_clr = o_vld & o_rdy_sync;
wire vld_ena = vld_set | vld_clr;
wire vld_nxt = vld_set | (~vld_clr);
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:internal_signal:000009 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=261-269
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000011 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=270-270
sirv_gnrl_dfflr #(1) vld_dfflr(vld_ena, vld_nxt, vld_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000011 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=270-270
// The data buf is only loaded when the vld is set 
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000012 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=272-272
sirv_gnrl_dfflr #(DW) dat_dfflr(vld_set, i_dat, dat_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000012 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=272-272

        // Detect the neg-edge
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:internal_signal:000010 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=275-275
wire o_rdy_sync_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:internal_signal:000010 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=275-275
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000013 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=276-276
sirv_gnrl_dffr #(1) o_rdy_sync_dffr(o_rdy_sync, o_rdy_sync_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000013 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=276-276
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:internal_signal:000011 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=277-286
wire o_rdy_nedge = (~o_rdy_sync) & o_rdy_sync_r;

// Not-ready indication
wire nrdy_r;
// Not-ready is set when the vld_r is set
wire nrdy_set = vld_set;
// Not-ready is clr when the o_rdy neg-edge is detected
wire nrdy_clr = o_rdy_nedge;
wire nrdy_ena = nrdy_set | nrdy_clr;
wire nrdy_nxt = nrdy_set | (~nrdy_clr);
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:internal_signal:000011 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=277-286
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000014 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=287-287
sirv_gnrl_dfflr #(1) buf_nrdy_dfflr(nrdy_ena, nrdy_nxt, nrdy_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000014 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=287-287

//  The output valid
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:assign_cluster:000004 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=290-295
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000016 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=290-290
assign o_vld = vld_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000016 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=290-290
//  The output data
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000017 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=292-292
assign o_dat = dat_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000017 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=292-292

// The input is ready when the  Not-ready indication is low or under clearing
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000018 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=295-295
assign i_rdy = (~nrdy_r) | nrdy_clr;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000018 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=295-295
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:assign_cluster:000004 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=290-295

endmodule 

//=====================================================================
//
// Description:
//  Verilog module as bypass buffer
//
// ====================================================================

module sirv_gnrl_bypbuf # (
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:port_section:000005 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=307-319
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:param_decl:000005 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=307-308
  parameter DP = 8,
  parameter DW = 32
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:param_decl:000005 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=307-308
) (
  input           i_vld,
  output          i_rdy,
  input  [DW-1:0] i_dat,

  output          o_vld,
  input           o_rdy,
  output [DW-1:0] o_dat,

  input           clk,
  input           rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:port_section:000005 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=307-319
);


//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:internal_signal:000012 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=323-329
  wire          fifo_i_vld;
  wire          fifo_i_rdy;
  wire [DW-1:0] fifo_i_dat;
  
  wire          fifo_o_vld;
  wire          fifo_o_rdy;
  wire [DW-1:0] fifo_o_dat;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:internal_signal:000012 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=323-329
  
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000015 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=331-344
  sirv_gnrl_fifo # (
       .DP(DP),
       .DW(DW),
       .CUT_READY(1) 
  ) u_bypbuf_fifo(
    .i_vld   (fifo_i_vld),
    .i_rdy   (fifo_i_rdy),
    .i_dat   (fifo_i_dat),
    .o_vld   (fifo_o_vld),
    .o_rdy   (fifo_o_rdy),
    .o_dat   (fifo_o_dat),
    .clk     (clk  ),
    .rst_n   (rst_n)
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000015 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=331-344
  
   // This module is a super-weapon for timing fix,
   // but it is tricky, think it harder when you are reading, or contact Bob Hu
  
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000019 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=349-349
  assign i_rdy = fifo_i_rdy;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000019 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=349-349
  
  // The FIFO is bypassed when:
  //   * fifo is empty, and o_rdy is high
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:internal_signal:000013 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=353-353
  wire byp = i_vld & o_rdy & (~fifo_o_vld);
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:internal_signal:000013 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=353-353

  // FIFO o-ready just use the o_rdy
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:assign_cluster:000005 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=356-367
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000020 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=356-356
  assign fifo_o_rdy = o_rdy;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000020 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=356-356
  
  // The output is valid if FIFO or input have valid
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000021 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=359-359
  assign o_vld = fifo_o_vld | i_vld;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000021 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=359-359

  // The output data select the FIFO as high priority
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000022 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=362-362
  assign o_dat = fifo_o_vld ? fifo_o_dat : i_dat;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000022 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=362-362

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000023 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=364-364
  assign fifo_i_dat  = i_dat; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000023 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=364-364

  // Only pass to FIFO i-valid if FIFO is not bypassed
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000024 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=367-367
  assign fifo_i_vld = i_vld & (~byp);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000024 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=367-367
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:assign_cluster:000005 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=356-367


endmodule 

//=====================================================================
//
// Designer   : Bob Hu
//
// Description:
//  The general sync FIFO module
//
// ====================================================================

module sirv_gnrl_fifo # (
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:port_section:000006 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=382-403
  // When the depth is 1, the ready signal may relevant to next stage's ready, hence become logic
  // chains. Use CUT_READY to control it
  // When fifo depth is 1, the fifo is a signle stage
       // if CUT_READY is set, then the back-pressure ready signal will be cut
       //      off, and it can only pass 1 data every 2 cycles
  // When fifo depth is > 1, then it is actually a really fifo
       //      The CUT_READY parameter have no impact to any logics
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:param_decl:000006 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=389-392
  parameter CUT_READY = 0,
  parameter MSKO = 0,// Mask out the data with valid or not
  parameter DP   = 8,// FIFO depth
  parameter DW   = 32// FIFO width
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:param_decl:000006 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=389-392
) (

  input           i_vld, 
  output          i_rdy, 
  input  [DW-1:0] i_dat,
  output          o_vld, 
  input           o_rdy, 
  output [DW-1:0] o_dat,

  input           clk,
  input           rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:port_section:000006 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=382-403
);

genvar i;
//__RB_CUT_BEGIN__ type=generate id=e203_hbirdv2/general/sirv_gnrl_bufs.v:generate:000003 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=407-520
generate //{
//__RB_CUT_BODY__ type=generate id=e203_hbirdv2/general/sirv_gnrl_bufs.v:generate:000003 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=407-520

//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000008 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=409-415
  if(DP == 0) begin: dp_eq1//{ pass through when it is 0 entries
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000008 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=409-415

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:assign_cluster:000006 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=411-413
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000025 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=411-411
     assign o_vld = i_vld;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000025 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=411-411
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000026 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=412-412
     assign i_rdy = o_rdy;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000026 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=412-412
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000027 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=413-413
     assign o_dat = i_dat;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000027 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=413-413
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:assign_cluster:000006 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=411-413

//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000008 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=409-415
  end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000008 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=409-415
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000023 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=416-519
  else begin: dp_gt0//{
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000023 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=416-519

    // FIFO registers
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:internal_signal:000014 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=419-431
    wire [DW-1:0] fifo_rf_r [DP-1:0];
    wire [DP-1:0] fifo_rf_en;

    // read/write enable
    wire wen = i_vld & i_rdy;
    wire ren = o_vld & o_rdy;
    
    ////////////////
    ///////// Read-Pointer and Write-Pointer
    wire [DP-1:0] rptr_vec_nxt; 
    wire [DP-1:0] rptr_vec_r;
    wire [DP-1:0] wptr_vec_nxt; 
    wire [DP-1:0] wptr_vec_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:internal_signal:000014 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=419-431

//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000009 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=433-435
    if(DP == 1) begin:rptr_dp_1
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000009 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=433-435
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000028 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=434-434
      assign rptr_vec_nxt = 1'b1; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000028 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=434-434
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000009 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=433-435
    end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000009 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=433-435
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000010 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=436-440
    else begin:rptr_dp_not_1
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000010 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=436-440
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000029 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=437-439
      assign rptr_vec_nxt = 
          rptr_vec_r[DP-1] ? {{DP-1{1'b0}}, 1'b1} :
                          (rptr_vec_r << 1);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000029 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=437-439
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000010 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=436-440
    end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000010 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=436-440

//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000011 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=442-444
    if(DP == 1) begin:wptr_dp_1
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000011 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=442-444
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000030 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=443-443
      assign wptr_vec_nxt = 1'b1; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000030 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=443-443
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000011 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=442-444
    end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000011 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=442-444
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000012 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=445-449
    else begin:wptr_dp_not_1
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000012 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=445-449
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000031 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=446-448
      assign wptr_vec_nxt =
          wptr_vec_r[DP-1] ? {{DP-1{1'b0}}, 1'b1} :
                          (wptr_vec_r << 1);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000031 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=446-448
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000012 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=445-449
    end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000012 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=445-449

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000016 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=451-451
    sirv_gnrl_dfflrs #(1)    rptr_vec_0_dfflrs  (ren, rptr_vec_nxt[0]     , rptr_vec_r[0]     , clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000016 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=451-451
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000017 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=452-452
    sirv_gnrl_dfflrs #(1)    wptr_vec_0_dfflrs  (wen, wptr_vec_nxt[0]     , wptr_vec_r[0]     , clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000017 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=452-452
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000013 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=453-456
    if(DP > 1) begin:dp_gt1
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000013 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=453-456
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000018 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=454-454
    sirv_gnrl_dfflr  #(DP-1) rptr_vec_31_dfflr  (ren, rptr_vec_nxt[DP-1:1], rptr_vec_r[DP-1:1], clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000018 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=454-454
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000019 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=455-455
    sirv_gnrl_dfflr  #(DP-1) wptr_vec_31_dfflr  (wen, wptr_vec_nxt[DP-1:1], wptr_vec_r[DP-1:1], clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000019 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=455-455
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000013 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=453-456
    end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000013 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=453-456

    ////////////////
    ///////// Vec register to easy full and empty and the o_vld generation with flop-clean
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:internal_signal:000015 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=460-465
    wire [DP:0] i_vec;
    wire [DP:0] o_vec;
    wire [DP:0] vec_nxt; 
    wire [DP:0] vec_r;

    wire vec_en = (ren ^ wen );
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:internal_signal:000015 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=460-465
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000032 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=466-466
    assign vec_nxt = wen ? {vec_r[DP-1:0], 1'b1} : (vec_r >> 1);  
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000032 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=466-466
    
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000020 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=468-468
    sirv_gnrl_dfflrs #(1)  vec_0_dfflrs     (vec_en, vec_nxt[0]     , vec_r[0]     ,     clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000020 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=468-468
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000021 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=469-469
    sirv_gnrl_dfflr  #(DP) vec_31_dfflr     (vec_en, vec_nxt[DP:1], vec_r[DP:1],     clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000021 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=469-469
    
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:assign_cluster:000007 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=471-472
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000033 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=471-471
    assign i_vec = {1'b0,vec_r[DP:1]};
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000033 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=471-471
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000034 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=472-472
    assign o_vec = {1'b0,vec_r[DP:1]};
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000034 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=472-472
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:assign_cluster:000007 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=471-472

//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000016 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=474-483
    if(DP == 1) begin:cut_dp_eq1//{
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000016 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=474-483
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000014 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=475-478
        if(CUT_READY == 1) begin:cut_ready//{
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000014 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=475-478
          // If cut ready, then only accept when fifo is not full
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000035 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=477-477
          assign i_rdy = (~i_vec[DP-1]);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000035 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=477-477
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000014 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=475-478
        end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000014 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=475-478
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000015 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=479-482
        else begin:no_cut_ready//{
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000015 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=479-482
          // If not cut ready, then can accept when fifo is not full or it is popping 
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000036 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=481-481
          assign i_rdy = (~i_vec[DP-1]) | ren;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000036 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=481-481
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000015 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=479-482
        end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000015 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=479-482
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000016 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=474-483
    end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000016 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=474-483
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000017 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=484-486
    else begin : no_cut_dp_gt1//}{
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000017 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=484-486
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000037 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=485-485
      assign i_rdy = (~i_vec[DP-1]);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000037 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=485-485
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000017 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=484-486
    end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000017 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=484-486


    ///////// write fifo
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000018 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=490-494
    for (i=0; i<DP; i=i+1) begin:fifo_rf//{
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000018 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=490-494
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000038 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=491-491
      assign fifo_rf_en[i] = wen & wptr_vec_r[i];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000038 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=491-491
      // Write the FIFO registers
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000022 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=493-493
      sirv_gnrl_dffl  #(DW) fifo_rf_dffl (fifo_rf_en[i], i_dat, fifo_rf_r[i], clk);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_bufs.v:inst:000022 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=493-493
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000018 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=490-494
    end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000018 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=490-494

    /////////One-Hot Mux as the read path
    integer j;
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:internal_signal:000016 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=498-498
    reg [DW-1:0] mux_rdat;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_bufs.v:grp:internal_signal:000016 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=498-498
//__RB_CUT_BEGIN__ type=always id=e203_hbirdv2/general/sirv_gnrl_bufs.v:proc:000001 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=499-505
    always @*
//__RB_CUT_BODY__ type=always id=e203_hbirdv2/general/sirv_gnrl_bufs.v:proc:000001 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=499-505
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000020 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=500-505
    begin : rd_port_PROC//{
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000020 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=500-505
      mux_rdat = {DW{1'b0}};
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000019 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=502-504
      for(j=0; j<DP; j=j+1) begin
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000019 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=502-504
        mux_rdat = mux_rdat | ({DW{rptr_vec_r[j]}} & fifo_rf_r[j]);
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000019 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=502-504
      end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000019 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=502-504
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000020 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=500-505
    end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000020 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=500-505
//__RB_CUT_TAIL__ type=always id=e203_hbirdv2/general/sirv_gnrl_bufs.v:proc:000001 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=499-505
//__RB_CUT_END__ type=always id=e203_hbirdv2/general/sirv_gnrl_bufs.v:proc:000001 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=499-505
    
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000021 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=507-510
    if(MSKO == 1) begin:mask_output//{
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000021 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=507-510
        // Mask the data with valid since the FIFO register is not reset and as X 
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000039 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=509-509
        assign o_dat = {DW{o_vld}} & mux_rdat;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000039 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=509-509
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000021 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=507-510
    end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000021 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=507-510
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000022 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=511-514
    else begin:no_mask_output//{
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000022 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=511-514
        // Not Mask the data with valid since no care with X for datapth
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000040 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=513-513
        assign o_dat = mux_rdat;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000040 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=513-513
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000022 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=511-514
    end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000022 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=511-514
    
    // o_vld as flop-clean
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000041 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=517-517
    assign o_vld = (o_vec[0]);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_bufs.v:assign:000041 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=517-517
    
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000023 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=416-519
  end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_bufs.v:begin_end:000023 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=416-519
//__RB_CUT_TAIL__ type=generate id=e203_hbirdv2/general/sirv_gnrl_bufs.v:generate:000003 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=407-520
endgenerate//}
//__RB_CUT_END__ type=generate id=e203_hbirdv2/general/sirv_gnrl_bufs.v:generate:000003 file=e203_hbirdv2/general/sirv_gnrl_bufs.v lines=407-520

endmodule 

