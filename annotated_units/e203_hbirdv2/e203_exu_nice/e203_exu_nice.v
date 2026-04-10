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
//  The NICE module 
//
// ====================================================================
`include "e203_defines.v"

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=29-124
`ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=29-124
module e203_exu_nice(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=31-67

  input  nice_i_xs_off,
  input  nice_i_valid, // Handshake valid
  output nice_i_ready, // Handshake ready
  input [`E203_XLEN-1:0]   nice_i_instr,
  input [`E203_XLEN-1:0]   nice_i_rs1,
  input [`E203_XLEN-1:0]   nice_i_rs2,
  //input                    nice_i_mmode , // O: current insns' mmode 
  input  [`E203_ITAG_WIDTH-1:0] nice_i_itag,
  output nice_o_longpipe,

  // The nice Commit Interface
  output                        nice_o_valid, // Handshake valid
  input                         nice_o_ready, // Handshake ready

  //////////////////////////////////////////////////////////////
  // The nice write-back Interface
  output                        nice_o_itag_valid, // Handshake valid
  input                         nice_o_itag_ready, // Handshake ready
  output [`E203_ITAG_WIDTH-1:0] nice_o_itag,   

  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // The nice Request Interface
  input                          nice_rsp_multicyc_valid , //I: current insn is multi-cycle.
  output                         nice_rsp_multicyc_ready , //O:                             

  output                         nice_req_valid, // Handshake valid
  input                          nice_req_ready, // Handshake ready
  output [`E203_XLEN-1:0]        nice_req_instr,
  output [`E203_XLEN-1:0]        nice_req_rs1,
  output [`E203_XLEN-1:0]        nice_req_rs2,
  //output                         nice_req_mmode , // O: current insns' mmode 


  input  clk,
  input  rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=31-67
  );

  //assign nice_req_mmode = nice_i_mmode;

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=72-74
  wire  nice_i_hsked = nice_i_valid & nice_i_ready;
  // when there is a valid insn and the cmt is ready, then send out the insn.
  wire   nice_req_valid_pos = nice_i_valid & nice_o_ready;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=72-74
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:assign:000001 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=75-75
  assign nice_req_valid = ~nice_i_xs_off &  nice_req_valid_pos;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:assign:000001 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=75-75
  // when nice is disable, its req_ready is assumed to 1.
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=77-77
  wire   nice_req_ready_pos = nice_i_xs_off ? 1'b1 : nice_req_ready;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=77-77
  // nice reports ready to decode when its cmt is ready and the nice core is ready.
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=79-81
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:grp:handshake:000001 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=79-81
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:assign:000002 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=79-79
  assign nice_i_ready   = nice_req_ready_pos & nice_o_ready  ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:assign:000002 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=79-79
  // the nice isns is about to cmt when it is truly a valid nice insn and the nice core has accepted.
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:assign:000003 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=81-81
  assign nice_o_valid   = nice_i_valid   & nice_req_ready_pos;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:assign:000003 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=81-81
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=79-81
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:grp:handshake:000001 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=79-81

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=83-83
  wire   fifo_o_vld;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=83-83
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=84-91
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:grp:handshake:000002 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=84-89
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:assign:000004 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=84-84
  assign nice_rsp_multicyc_ready = nice_o_itag_ready & fifo_o_vld;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:assign:000004 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=84-84


//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:assign:000005 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=87-87
  assign nice_req_instr = nice_i_instr;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:assign:000005 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=87-87
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:assign:000006 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=88-88
  assign nice_req_rs1 = nice_i_rs1;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:assign:000006 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=88-88
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:assign:000007 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=89-89
  assign nice_req_rs2 = nice_i_rs2;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:assign:000007 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=89-89
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:grp:handshake:000002 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=84-89

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:assign:000008 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=91-91
  assign nice_o_longpipe = ~nice_i_xs_off;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:assign:000008 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=91-91
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=84-91


//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=94-102
 wire itag_fifo_wen = nice_o_longpipe & (nice_req_valid & nice_req_ready); 
 wire itag_fifo_ren = nice_rsp_multicyc_valid & nice_rsp_multicyc_ready; 

wire          fifo_i_vld  = itag_fifo_wen;
wire          fifo_i_rdy;
wire [`E203_ITAG_WIDTH-1:0] fifo_i_dat = nice_i_itag;

wire          fifo_o_rdy = itag_fifo_ren;
wire [`E203_ITAG_WIDTH-1:0] fifo_o_dat; 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=94-102
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=103-106
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:assign:000009 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=103-103
assign nice_o_itag_valid = fifo_o_vld & nice_rsp_multicyc_valid;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:assign:000009 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=103-103
//assign nice_o_itag = {`E203_ITAG_WIDTH{nice_o_itag_valid}} & fifo_o_dat;
//ctrl path must be independent with data path to avoid timing-loop.
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:assign:000010 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=106-106
assign nice_o_itag = fifo_o_dat;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:assign:000010 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=106-106
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=103-106

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:inst:000001 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=108-121
 sirv_gnrl_fifo # (
       .DP(4),
       .DW(`E203_ITAG_WIDTH),
       .CUT_READY(1) 
  ) u_nice_itag_fifo(
    .i_vld   (fifo_i_vld),
    .i_rdy   (fifo_i_rdy),
    .i_dat   (fifo_i_dat),
    .o_vld   (fifo_o_vld),
    .o_rdy   (fifo_o_rdy),
    .o_dat   (fifo_o_dat),
    .clk     (clk  ),
    .rst_n   (rst_n)
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:inst:000001 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=108-121
  
endmodule     
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=29-124
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_nice/e203_exu_nice.v lines=29-124
