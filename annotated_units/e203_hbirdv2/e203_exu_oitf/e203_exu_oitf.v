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
//  The OITF (Oustanding Instructions Track FIFO) to hold all the non-ALU long
//  pipeline instruction's status and information
//
// ====================================================================
`include "e203_defines.v"

module e203_exu_oitf(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=30-64
  output dis_ready,

  input  dis_ena,
  input  ret_ena,

  output [`E203_ITAG_WIDTH-1:0] dis_ptr,
  output [`E203_ITAG_WIDTH-1:0] ret_ptr,

  output [`E203_RFIDX_WIDTH-1:0] ret_rdidx,
  output ret_rdwen,
  output ret_rdfpu,
  output [`E203_PC_SIZE-1:0] ret_pc,

  input  disp_i_rs1en,
  input  disp_i_rs2en,
  input  disp_i_rs3en,
  input  disp_i_rdwen,
  input  disp_i_rs1fpu,
  input  disp_i_rs2fpu,
  input  disp_i_rs3fpu,
  input  disp_i_rdfpu,
  input  [`E203_RFIDX_WIDTH-1:0] disp_i_rs1idx,
  input  [`E203_RFIDX_WIDTH-1:0] disp_i_rs2idx,
  input  [`E203_RFIDX_WIDTH-1:0] disp_i_rs3idx,
  input  [`E203_RFIDX_WIDTH-1:0] disp_i_rdidx,
  input  [`E203_PC_SIZE    -1:0] disp_i_pc,

  output oitfrd_match_disprs1,
  output oitfrd_match_disprs2,
  output oitfrd_match_disprs3,
  output oitfrd_match_disprd,

  output oitf_empty,
  input  clk,
  input  rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=30-64
);

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=67-85
  wire [`E203_OITF_DEPTH-1:0] vld_set;
  wire [`E203_OITF_DEPTH-1:0] vld_clr;
  wire [`E203_OITF_DEPTH-1:0] vld_ena;
  wire [`E203_OITF_DEPTH-1:0] vld_nxt;
  wire [`E203_OITF_DEPTH-1:0] vld_r;
  wire [`E203_OITF_DEPTH-1:0] rdwen_r;
  wire [`E203_OITF_DEPTH-1:0] rdfpu_r;
  wire [`E203_RFIDX_WIDTH-1:0] rdidx_r[`E203_OITF_DEPTH-1:0];
  // The PC here is to be used at wback stage to track out the
  //  PC of exception of long-pipe instruction
  wire [`E203_PC_SIZE-1:0] pc_r[`E203_OITF_DEPTH-1:0];

  wire alc_ptr_ena = dis_ena;
  wire ret_ptr_ena = ret_ena;

  wire oitf_full ;
  
  wire [`E203_ITAG_WIDTH-1:0] alc_ptr_r;
  wire [`E203_ITAG_WIDTH-1:0] ret_ptr_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=67-85

//__RB_CUT_BEGIN__ type=generate id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:generate:000001 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=87-123
  generate
//__RB_CUT_BODY__ type=generate id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:generate:000001 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=87-123
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:begin_end:000001 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=88-116
  if(`E203_OITF_DEPTH > 1) begin: depth_gt1//{
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=89-91
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:begin_end:000001 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=88-116
      wire alc_ptr_flg_r;
      wire alc_ptr_flg_nxt = ~alc_ptr_flg_r;
      wire alc_ptr_flg_ena = (alc_ptr_r == ($unsigned(`E203_OITF_DEPTH-1))) & alc_ptr_ena;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=89-91
      
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:inst:000001 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=93-93
      sirv_gnrl_dfflr #(1) alc_ptr_flg_dfflrs(alc_ptr_flg_ena, alc_ptr_flg_nxt, alc_ptr_flg_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:inst:000001 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=93-93
      
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=95-95
      wire [`E203_ITAG_WIDTH-1:0] alc_ptr_nxt; 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=95-95
      
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000001 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=97-97
      assign alc_ptr_nxt = alc_ptr_flg_ena ? `E203_ITAG_WIDTH'b0 : (alc_ptr_r + 1'b1);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000001 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=97-97
      
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:inst:000002 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=99-99
      sirv_gnrl_dfflr #(`E203_ITAG_WIDTH) alc_ptr_dfflrs(alc_ptr_ena, alc_ptr_nxt, alc_ptr_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:inst:000002 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=99-99
      
      
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=102-104
      wire ret_ptr_flg_r;
      wire ret_ptr_flg_nxt = ~ret_ptr_flg_r;
      wire ret_ptr_flg_ena = (ret_ptr_r == ($unsigned(`E203_OITF_DEPTH-1))) & ret_ptr_ena;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=102-104
      
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:inst:000003 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=106-106
      sirv_gnrl_dfflr #(1) ret_ptr_flg_dfflrs(ret_ptr_flg_ena, ret_ptr_flg_nxt, ret_ptr_flg_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:inst:000003 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=106-106
      
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:grp:internal_signal:000005 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=108-108
      wire [`E203_ITAG_WIDTH-1:0] ret_ptr_nxt; 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:grp:internal_signal:000005 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=108-108
      
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000002 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=110-110
      assign ret_ptr_nxt = ret_ptr_flg_ena ? `E203_ITAG_WIDTH'b0 : (ret_ptr_r + 1'b1);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000002 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=110-110

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:inst:000004 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=112-112
      sirv_gnrl_dfflr #(`E203_ITAG_WIDTH) ret_ptr_dfflrs(ret_ptr_ena, ret_ptr_nxt, ret_ptr_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:inst:000004 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=112-112

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=114-115
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000003 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=114-114
      assign oitf_empty = (ret_ptr_r == alc_ptr_r) &   (ret_ptr_flg_r == alc_ptr_flg_r);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000003 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=114-114
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000004 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=115-115
      assign oitf_full  = (ret_ptr_r == alc_ptr_r) & (~(ret_ptr_flg_r == alc_ptr_flg_r));
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000004 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=115-115
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=114-115
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:begin_end:000001 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=88-116
  end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:begin_end:000001 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=88-116
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:begin_end:000002 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=117-122
  else begin: depth_eq1//}{
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=118-121
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:begin_end:000002 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=117-122
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000005 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=118-118
      assign alc_ptr_r =1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000005 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=118-118
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000006 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=119-119
      assign ret_ptr_r =1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000006 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=119-119
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000007 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=120-120
      assign oitf_empty = ~vld_r[0];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000007 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=120-120
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000008 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=121-121
      assign oitf_full  = vld_r[0];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000008 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=121-121
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=118-121
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:begin_end:000002 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=117-122
  end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:begin_end:000002 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=117-122
//__RB_CUT_TAIL__ type=generate id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:generate:000001 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=87-123
  endgenerate//}
//__RB_CUT_END__ type=generate id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:generate:000001 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=87-123

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=125-133
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000009 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=125-125
  assign ret_ptr = ret_ptr_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000009 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=125-125
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000010 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=126-126
  assign dis_ptr = alc_ptr_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000010 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=126-126

 //// 
 //// // If the OITF is not full, or it is under retiring, then it is ready to accept new dispatch
 //// assign dis_ready = (~oitf_full) | ret_ena;
 // To cut down the loop between ALU write-back valid --> oitf_ret_ena --> oitf_ready ---> dispatch_ready --- > alu_i_valid
 //   we exclude the ret_ena from the ready signal
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000011 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=133-133
 assign dis_ready = (~oitf_full);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000011 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=133-133
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=125-133
  
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:grp:internal_signal:000006 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=135-138
  wire [`E203_OITF_DEPTH-1:0] rd_match_rs1idx;
  wire [`E203_OITF_DEPTH-1:0] rd_match_rs2idx;
  wire [`E203_OITF_DEPTH-1:0] rd_match_rs3idx;
  wire [`E203_OITF_DEPTH-1:0] rd_match_rdidx;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:grp:internal_signal:000006 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=135-138

  genvar i;
//__RB_CUT_BEGIN__ type=generate id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:generate:000002 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=141-162
  generate //{
//__RB_CUT_BODY__ type=generate id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:generate:000002 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=141-162
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:begin_end:000003 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=142-161
      for (i=0; i<`E203_OITF_DEPTH; i=i+1) begin:oitf_entries//{
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:begin_end:000003 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=142-161
  
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:grp:assign_cluster:000004 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=144-147
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000012 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=144-144
        assign vld_set[i] = alc_ptr_ena & (alc_ptr_r == i);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000012 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=144-144
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000013 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=145-145
        assign vld_clr[i] = ret_ptr_ena & (ret_ptr_r == i);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000013 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=145-145
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000014 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=146-146
        assign vld_ena[i] = vld_set[i] |   vld_clr[i];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000014 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=146-146
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000015 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=147-147
        assign vld_nxt[i] = vld_set[i] | (~vld_clr[i]);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000015 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=147-147
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:grp:assign_cluster:000004 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=144-147
  
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:inst:000005 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=149-149
        sirv_gnrl_dfflr #(1) vld_dfflrs(vld_ena[i], vld_nxt[i], vld_r[i], clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:inst:000005 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=149-149
        //Payload only set, no need to clear
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:inst:000006 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=151-151
        sirv_gnrl_dffl #(`E203_RFIDX_WIDTH) rdidx_dfflrs(vld_set[i], disp_i_rdidx, rdidx_r[i], clk);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:inst:000006 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=151-151
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:inst:000007 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=152-152
        sirv_gnrl_dffl #(`E203_PC_SIZE    ) pc_dfflrs   (vld_set[i], disp_i_pc   , pc_r[i]   , clk);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:inst:000007 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=152-152
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:inst:000008 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=153-153
        sirv_gnrl_dffl #(1)                 rdwen_dfflrs(vld_set[i], disp_i_rdwen, rdwen_r[i], clk);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:inst:000008 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=153-153
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:inst:000009 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=154-154
        sirv_gnrl_dffl #(1)                 rdfpu_dfflrs(vld_set[i], disp_i_rdfpu, rdfpu_r[i], clk);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:inst:000009 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=154-154

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:grp:assign_cluster:000005 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=156-159
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000016 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=156-156
        assign rd_match_rs1idx[i] = vld_r[i] & rdwen_r[i] & disp_i_rs1en & (rdfpu_r[i] == disp_i_rs1fpu) & (rdidx_r[i] == disp_i_rs1idx);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000016 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=156-156
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000017 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=157-157
        assign rd_match_rs2idx[i] = vld_r[i] & rdwen_r[i] & disp_i_rs2en & (rdfpu_r[i] == disp_i_rs2fpu) & (rdidx_r[i] == disp_i_rs2idx);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000017 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=157-157
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000018 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=158-158
        assign rd_match_rs3idx[i] = vld_r[i] & rdwen_r[i] & disp_i_rs3en & (rdfpu_r[i] == disp_i_rs3fpu) & (rdidx_r[i] == disp_i_rs3idx);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000018 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=158-158
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000019 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=159-159
        assign rd_match_rdidx [i] = vld_r[i] & rdwen_r[i] & disp_i_rdwen & (rdfpu_r[i] == disp_i_rdfpu ) & (rdidx_r[i] == disp_i_rdidx );
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000019 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=159-159
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:grp:assign_cluster:000005 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=156-159
  
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:begin_end:000003 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=142-161
      end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:begin_end:000003 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=142-161
//__RB_CUT_TAIL__ type=generate id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:generate:000002 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=141-162
  endgenerate//}
//__RB_CUT_END__ type=generate id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:generate:000002 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=141-162

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:grp:assign_cluster:000006 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=164-172
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000020 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=164-164
  assign oitfrd_match_disprs1 = |rd_match_rs1idx;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000020 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=164-164
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000021 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=165-165
  assign oitfrd_match_disprs2 = |rd_match_rs2idx;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000021 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=165-165
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000022 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=166-166
  assign oitfrd_match_disprs3 = |rd_match_rs3idx;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000022 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=166-166
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000023 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=167-167
  assign oitfrd_match_disprd  = |rd_match_rdidx ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000023 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=167-167

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000024 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=169-169
  assign ret_rdidx = rdidx_r[ret_ptr];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000024 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=169-169
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000025 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=170-170
  assign ret_pc    = pc_r [ret_ptr];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000025 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=170-170
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000026 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=171-171
  assign ret_rdwen = rdwen_r[ret_ptr];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000026 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=171-171
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000027 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=172-172
  assign ret_rdfpu = rdfpu_r[ret_ptr];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:assign:000027 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=172-172
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v:grp:assign_cluster:000006 file=e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v lines=164-172

endmodule


