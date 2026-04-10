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
//  This module to implement the datapath of ALU
//
// ====================================================================
`include "e203_defines.v"

module e203_exu_alu_dpath(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=30-115

  //////////////////////////////////////////////////////
  // ALU request the datapath
  input  alu_req_alu,

  input  alu_req_alu_add ,
  input  alu_req_alu_sub ,
  input  alu_req_alu_xor ,
  input  alu_req_alu_sll ,
  input  alu_req_alu_srl ,
  input  alu_req_alu_sra ,
  input  alu_req_alu_or  ,
  input  alu_req_alu_and ,
  input  alu_req_alu_slt ,
  input  alu_req_alu_sltu,
  input  alu_req_alu_lui ,
  input  [`E203_XLEN-1:0] alu_req_alu_op1,
  input  [`E203_XLEN-1:0] alu_req_alu_op2,

  output [`E203_XLEN-1:0] alu_req_alu_res,

  //////////////////////////////////////////////////////
  // BJP request the datapath
  input  bjp_req_alu,

  input  [`E203_XLEN-1:0] bjp_req_alu_op1,
  input  [`E203_XLEN-1:0] bjp_req_alu_op2,
  input  bjp_req_alu_cmp_eq ,
  input  bjp_req_alu_cmp_ne ,
  input  bjp_req_alu_cmp_lt ,
  input  bjp_req_alu_cmp_gt ,
  input  bjp_req_alu_cmp_ltu,
  input  bjp_req_alu_cmp_gtu,
  input  bjp_req_alu_add,

  output bjp_req_alu_cmp_res,
  output [`E203_XLEN-1:0] bjp_req_alu_add_res,

  //////////////////////////////////////////////////////
  // AGU request the datapath
  input  agu_req_alu,

  input  [`E203_XLEN-1:0] agu_req_alu_op1,
  input  [`E203_XLEN-1:0] agu_req_alu_op2,
  input  agu_req_alu_swap,
  input  agu_req_alu_add ,
  input  agu_req_alu_and ,
  input  agu_req_alu_or  ,
  input  agu_req_alu_xor ,
  input  agu_req_alu_max ,
  input  agu_req_alu_min ,
  input  agu_req_alu_maxu,
  input  agu_req_alu_minu,

  output [`E203_XLEN-1:0] agu_req_alu_res,

  input  agu_sbf_0_ena,
  input  [`E203_XLEN-1:0] agu_sbf_0_nxt,
  output [`E203_XLEN-1:0] agu_sbf_0_r,

  input  agu_sbf_1_ena,
  input  [`E203_XLEN-1:0] agu_sbf_1_nxt,
  output [`E203_XLEN-1:0] agu_sbf_1_r,

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=94-112
`ifdef E203_SUPPORT_SHARE_MULDIV //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=94-112
  //////////////////////////////////////////////////////
  // MULDIV request the datapath
  input  muldiv_req_alu,

  input  [`E203_ALU_ADDER_WIDTH-1:0] muldiv_req_alu_op1,
  input  [`E203_ALU_ADDER_WIDTH-1:0] muldiv_req_alu_op2,
  input                              muldiv_req_alu_add,
  input                              muldiv_req_alu_sub,
  output [`E203_ALU_ADDER_WIDTH-1:0] muldiv_req_alu_res,

  input           muldiv_sbf_0_ena,
  input  [33-1:0] muldiv_sbf_0_nxt,
  output [33-1:0] muldiv_sbf_0_r,

  input           muldiv_sbf_1_ena,
  input  [33-1:0] muldiv_sbf_1_nxt,
  output [33-1:0] muldiv_sbf_1_r,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=94-112
`endif//E203_SUPPORT_SHARE_MULDIV}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=94-112

  input  clk,
  input  rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=30-115
  );

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=118-122
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000002:br:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=118-119
  `ifdef E203_XLEN_IS_32
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=118-122
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000002:br:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=118-119
      // This is the correct config since E200 is 32bits core
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000002:br:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=118-119
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000002:br:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=118-119
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000002:br:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=120-121
  `else
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000002:br:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=120-121
      !!! ERROR: There must be something wrong, our core must be 32bits wide !!!
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000002:br:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=120-121
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000002:br:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=120-121
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=118-122
  `endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=118-122

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=124-184
  wire [`E203_XLEN-1:0] mux_op1;
  wire [`E203_XLEN-1:0] mux_op2;

  wire [`E203_XLEN-1:0] misc_op1 = mux_op1[`E203_XLEN-1:0];
  wire [`E203_XLEN-1:0] misc_op2 = mux_op2[`E203_XLEN-1:0];

  // Only the regular ALU use shifter
  wire [`E203_XLEN-1:0] shifter_op1 = alu_req_alu_op1[`E203_XLEN-1:0];
  wire [`E203_XLEN-1:0] shifter_op2 = alu_req_alu_op2[`E203_XLEN-1:0];

  wire op_max;  
  wire op_min ; 
  wire op_maxu;
  wire op_minu;

  wire op_add;
  wire op_sub;
  wire op_addsub = op_add | op_sub; 

  wire op_or;
  wire op_xor;
  wire op_and;

  wire op_sll;
  wire op_srl;
  wire op_sra;

  wire op_slt;
  wire op_sltu;

  wire op_mvop2;


  wire op_cmp_eq ;
  wire op_cmp_ne ;
  wire op_cmp_lt ;
  wire op_cmp_gt ;
  wire op_cmp_ltu;
  wire op_cmp_gtu;

  wire cmp_res;

  wire sbf_0_ena;
  wire [33-1:0] sbf_0_nxt;
  wire [33-1:0] sbf_0_r;

  wire sbf_1_ena;
  wire [33-1:0] sbf_1_nxt;
  wire [33-1:0] sbf_1_r;


  //////////////////////////////////////////////////////////////
  // Impelment the Left-Shifter
  //
  // The Left-Shifter will be used to handle the shift op
  wire [`E203_XLEN-1:0] shifter_in1;
  wire [5-1:0] shifter_in2;
  wire [`E203_XLEN-1:0] shifter_res;


  wire op_shift = op_sra | op_sll | op_srl; 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=124-184
  
     // Make sure to use logic-gating to gateoff the 
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=187-205
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=187-202
  assign shifter_in1 = {`E203_XLEN{op_shift}} &
          //   In order to save area and just use one left-shifter, we
          //   convert the right-shift op into left-shift operation
           (
               (op_sra | op_srl) ? 
                 {
    shifter_op1[00],shifter_op1[01],shifter_op1[02],shifter_op1[03],
    shifter_op1[04],shifter_op1[05],shifter_op1[06],shifter_op1[07],
    shifter_op1[08],shifter_op1[09],shifter_op1[10],shifter_op1[11],
    shifter_op1[12],shifter_op1[13],shifter_op1[14],shifter_op1[15],
    shifter_op1[16],shifter_op1[17],shifter_op1[18],shifter_op1[19],
    shifter_op1[20],shifter_op1[21],shifter_op1[22],shifter_op1[23],
    shifter_op1[24],shifter_op1[25],shifter_op1[26],shifter_op1[27],
    shifter_op1[28],shifter_op1[29],shifter_op1[30],shifter_op1[31]
                 } : shifter_op1
           );
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=187-202
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=203-203
  assign shifter_in2 = {5{op_shift}} & shifter_op2[4:0];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=203-203

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=205-205
  assign shifter_res = (shifter_in1 << shifter_in2);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=205-205
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=187-205

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=207-208
  wire [`E203_XLEN-1:0] sll_res = shifter_res;
  wire [`E203_XLEN-1:0] srl_res =  
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=207-208
                 {
    shifter_res[00],shifter_res[01],shifter_res[02],shifter_res[03],
    shifter_res[04],shifter_res[05],shifter_res[06],shifter_res[07],
    shifter_res[08],shifter_res[09],shifter_res[10],shifter_res[11],
    shifter_res[12],shifter_res[13],shifter_res[14],shifter_res[15],
    shifter_res[16],shifter_res[17],shifter_res[18],shifter_res[19],
    shifter_res[20],shifter_res[21],shifter_res[22],shifter_res[23],
    shifter_res[24],shifter_res[25],shifter_res[26],shifter_res[27],
    shifter_res[28],shifter_res[29],shifter_res[30],shifter_res[31]
                 };
  
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=220-221
  wire [`E203_XLEN-1:0] eff_mask = (~(`E203_XLEN'b0)) >> shifter_in2;
  wire [`E203_XLEN-1:0] sra_res =
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=220-221
               (srl_res & eff_mask) | ({32{shifter_op1[31]}} & (~eff_mask));



  //////////////////////////////////////////////////////////////
  // Impelment the Adder
  //
  // The Adder will be reused to handle the add/sub/compare op

     // Only the MULDIV request ALU-adder with 35bits operand with sign extended 
     // already, all other unit request ALU-adder with 32bits opereand without sign extended
     //   For non-MULDIV operands
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=234-235
  wire op_unsigned = op_sltu | op_cmp_ltu | op_cmp_gtu | op_maxu | op_minu;
  wire [`E203_ALU_ADDER_WIDTH-1:0] misc_adder_op1 =
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=234-235
      {{`E203_ALU_ADDER_WIDTH-`E203_XLEN{(~op_unsigned) & misc_op1[`E203_XLEN-1]}},misc_op1};
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:internal_signal:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=237-237
  wire [`E203_ALU_ADDER_WIDTH-1:0] misc_adder_op2 =
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:internal_signal:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=237-237
      {{`E203_ALU_ADDER_WIDTH-`E203_XLEN{(~op_unsigned) & misc_op2[`E203_XLEN-1]}},misc_op2};


//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:internal_signal:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=241-242
  wire [`E203_ALU_ADDER_WIDTH-1:0] adder_op1 = 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=242-244
`ifdef E203_SUPPORT_SHARE_MULDIV //{
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:internal_signal:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=241-242
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=242-244
      muldiv_req_alu ? muldiv_req_alu_op1 :
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=242-244
`endif//E203_SUPPORT_SHARE_MULDIV}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=242-244
      misc_adder_op1;
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:internal_signal:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=246-247
  wire [`E203_ALU_ADDER_WIDTH-1:0] adder_op2 = 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=247-249
`ifdef E203_SUPPORT_SHARE_MULDIV //{
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:internal_signal:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=246-247
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=247-249
      muldiv_req_alu ? muldiv_req_alu_op2 :
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=247-249
`endif//E203_SUPPORT_SHARE_MULDIV}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=247-249
      misc_adder_op2;

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:internal_signal:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=252-258
  wire adder_cin;
  wire [`E203_ALU_ADDER_WIDTH-1:0] adder_in1;
  wire [`E203_ALU_ADDER_WIDTH-1:0] adder_in2;
  wire [`E203_ALU_ADDER_WIDTH-1:0] adder_res;

  wire adder_add;
  wire adder_sub;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:internal_signal:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=252-258

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=260-278
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:handshake:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=260-278
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=260-264
  assign adder_add =
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=261-263
`ifdef E203_SUPPORT_SHARE_MULDIV //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=261-263
      muldiv_req_alu ? muldiv_req_alu_add :
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=261-263
`endif//E203_SUPPORT_SHARE_MULDIV}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=261-263
      op_add; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=260-264
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=265-278
  assign adder_sub =
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=266-268
`ifdef E203_SUPPORT_SHARE_MULDIV //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=266-268
      muldiv_req_alu ? muldiv_req_alu_sub :
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=266-268
`endif//E203_SUPPORT_SHARE_MULDIV}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=266-268
               (
                   // The original sub instruction
               (op_sub) 
                   // The compare lt or gt instruction
             | (op_cmp_lt | op_cmp_gt | 
                op_cmp_ltu | op_cmp_gtu |
                op_max | op_maxu |
                op_min | op_minu |
                op_slt | op_sltu 
               ));
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=265-278
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=260-278
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:handshake:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=260-278

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:internal_signal:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=280-280
  wire adder_addsub = adder_add | adder_sub; 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:internal_signal:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=280-280
  

     // Make sure to use logic-gating to gateoff the 
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=284-288
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=284-284
  assign adder_in1 = {`E203_ALU_ADDER_WIDTH{adder_addsub}} & (adder_op1);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=284-284
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=285-285
  assign adder_in2 = {`E203_ALU_ADDER_WIDTH{adder_addsub}} & (adder_sub ? (~adder_op2) : adder_op2);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=285-285
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=286-286
  assign adder_cin = adder_addsub & adder_sub;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=286-286

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=288-288
  assign adder_res = adder_in1 + adder_in2 + adder_cin;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=288-288
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=284-288



  //////////////////////////////////////////////////////////////
  // Impelment the XOR-er
  //
  // The XOR-er will be reused to handle the XOR and compare op

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:internal_signal:000010 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=297-300
  wire [`E203_XLEN-1:0] xorer_in1;
  wire [`E203_XLEN-1:0] xorer_in2;

  wire xorer_op = 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:internal_signal:000010 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=297-300
               op_xor
                   // The compare eq or ne instruction
             | (op_cmp_eq | op_cmp_ne); 

     // Make sure to use logic-gating to gateoff the 
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:assign_cluster:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=306-307
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000010 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=306-306
  assign xorer_in1 = {`E203_XLEN{xorer_op}} & misc_op1;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000010 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=306-306
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000011 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=307-307
  assign xorer_in2 = {`E203_XLEN{xorer_op}} & misc_op2;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000011 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=307-307
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:assign_cluster:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=306-307

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:internal_signal:000011 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=309-328
  wire [`E203_XLEN-1:0] xorer_res = xorer_in1 ^ xorer_in2;
     // The OR and AND is too light-weight, so no need to gate off
  wire [`E203_XLEN-1:0] orer_res  = misc_op1 | misc_op2; 
  wire [`E203_XLEN-1:0] ander_res = misc_op1 & misc_op2; 


  //////////////////////////////////////////////////////////////
  // Generate the CMP operation result
       // It is Non-Equal if the XOR result have any bit non-zero
  wire neq  = (|xorer_res); 
  wire cmp_res_ne  = (op_cmp_ne  & neq);
       // It is Equal if it is not Non-Equal
  wire cmp_res_eq  = op_cmp_eq  & (~neq);
       // It is Less-Than if the adder result is negative
  wire cmp_res_lt  = op_cmp_lt  & adder_res[`E203_XLEN];
  wire cmp_res_ltu = op_cmp_ltu & adder_res[`E203_XLEN];
       // It is Greater-Than if the adder result is postive
  wire op1_gt_op2  = (~adder_res[`E203_XLEN]);
  wire cmp_res_gt  = op_cmp_gt  & op1_gt_op2;
  wire cmp_res_gtu = op_cmp_gtu & op1_gt_op2;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:internal_signal:000011 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=309-328

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000012 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=330-335
  assign cmp_res = cmp_res_eq 
                 | cmp_res_ne 
                 | cmp_res_lt 
                 | cmp_res_gt  
                 | cmp_res_ltu 
                 | cmp_res_gtu; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000012 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=330-335

  //////////////////////////////////////////////////////////////
  // Generate the mvop2 result
  //   Just directly use op2 since the op2 will be the immediate
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:internal_signal:000012 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=340-349
  wire [`E203_XLEN-1:0] mvop2_res = misc_op2;

  //////////////////////////////////////////////////////////////
  // Generate the SLT and SLTU result
  //   Just directly use op2 since the op2 will be the immediate
  wire op_slttu = (op_slt | op_sltu);
  //   The SLT and SLTU is reusing the adder to do the comparasion
       // It is Less-Than if the adder result is negative
  wire slttu_cmp_lt = op_slttu & adder_res[`E203_XLEN];
  wire [`E203_XLEN-1:0] slttu_res = 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:internal_signal:000012 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=340-349
               slttu_cmp_lt ?
               `E203_XLEN'b1 : `E203_XLEN'b0;

  //////////////////////////////////////////////////////////////
  // Generate the Max/Min result
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:internal_signal:000013 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=355-355
  wire maxmin_sel_op1 =  ((op_max | op_maxu) &   op1_gt_op2) 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:internal_signal:000013 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=355-355
                      |  ((op_min | op_minu) & (~op1_gt_op2));

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:internal_signal:000014 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=358-362
  wire [`E203_XLEN-1:0] maxmin_res  = maxmin_sel_op1 ? misc_op1 : misc_op2;  

  //////////////////////////////////////////////////////////////
  // Generate the final result
  wire [`E203_XLEN-1:0] alu_dpath_res = 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:internal_signal:000014 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=358-362
        ({`E203_XLEN{op_or       }} & orer_res )
      | ({`E203_XLEN{op_and      }} & ander_res)
      | ({`E203_XLEN{op_xor      }} & xorer_res)
      | ({`E203_XLEN{op_addsub   }} & adder_res[`E203_XLEN-1:0])
      | ({`E203_XLEN{op_srl      }} & srl_res)
      | ({`E203_XLEN{op_sll      }} & sll_res)
      | ({`E203_XLEN{op_sra      }} & sra_res)
      | ({`E203_XLEN{op_mvop2    }} & mvop2_res)
      | ({`E203_XLEN{op_slttu    }} & slttu_res)
      | ({`E203_XLEN{op_max | op_maxu | op_min | op_minu}} & maxmin_res)
        ;

  //////////////////////////////////////////////////////////////
  // Implement the SBF: Shared Buffers
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:inst:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=377-377
  sirv_gnrl_dffl #(33) sbf_0_dffl (sbf_0_ena, sbf_0_nxt, sbf_0_r, clk);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:inst:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=377-377
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:inst:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=378-378
  sirv_gnrl_dffl #(33) sbf_1_dffl (sbf_1_ena, sbf_1_nxt, sbf_1_r, clk);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:inst:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=378-378

  /////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////
  //  The ALU-Datapath Mux for the requestors 

//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:param_decl:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=385-385
  localparam DPATH_MUX_WIDTH = ((`E203_XLEN*2)+21);
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:param_decl:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=385-385

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:assign_cluster:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=387-494
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:handshake:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=387-494
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000013 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=387-489
  assign  {
     mux_op1
    ,mux_op2
    ,op_max  
    ,op_min  
    ,op_maxu 
    ,op_minu 
    ,op_add
    ,op_sub
    ,op_or
    ,op_xor
    ,op_and
    ,op_sll
    ,op_srl
    ,op_sra
    ,op_slt
    ,op_sltu
    ,op_mvop2
    ,op_cmp_eq 
    ,op_cmp_ne 
    ,op_cmp_lt 
    ,op_cmp_gt 
    ,op_cmp_ltu
    ,op_cmp_gtu
    }
    = 
        ({DPATH_MUX_WIDTH{alu_req_alu}} & {
             alu_req_alu_op1
            ,alu_req_alu_op2
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
            ,alu_req_alu_add
            ,alu_req_alu_sub
            ,alu_req_alu_or
            ,alu_req_alu_xor
            ,alu_req_alu_and
            ,alu_req_alu_sll
            ,alu_req_alu_srl
            ,alu_req_alu_sra
            ,alu_req_alu_slt
            ,alu_req_alu_sltu
            ,alu_req_alu_lui// LUI just move-Op2 operation
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
        })
      | ({DPATH_MUX_WIDTH{bjp_req_alu}} & {
             bjp_req_alu_op1
            ,bjp_req_alu_op2
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
            ,bjp_req_alu_add
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
            ,bjp_req_alu_cmp_eq 
            ,bjp_req_alu_cmp_ne 
            ,bjp_req_alu_cmp_lt 
            ,bjp_req_alu_cmp_gt 
            ,bjp_req_alu_cmp_ltu
            ,bjp_req_alu_cmp_gtu

        })
      | ({DPATH_MUX_WIDTH{agu_req_alu}} & {
             agu_req_alu_op1
            ,agu_req_alu_op2
            ,agu_req_alu_max  
            ,agu_req_alu_min  
            ,agu_req_alu_maxu 
            ,agu_req_alu_minu 
            ,agu_req_alu_add
            ,1'b0
            ,agu_req_alu_or
            ,agu_req_alu_xor
            ,agu_req_alu_and
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
            ,agu_req_alu_swap// SWAP just move-Op2 operation
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
        })
        ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000013 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=387-489
  
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000014 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=491-491
  assign alu_req_alu_res     = alu_dpath_res[`E203_XLEN-1:0];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000014 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=491-491
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000015 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=492-492
  assign agu_req_alu_res     = alu_dpath_res[`E203_XLEN-1:0];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000015 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=492-492
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000016 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=493-493
  assign bjp_req_alu_add_res = alu_dpath_res[`E203_XLEN-1:0];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000016 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=493-493
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000017 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=494-494
  assign bjp_req_alu_cmp_res = cmp_res;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000017 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=494-494
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:assign_cluster:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=387-494
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:handshake:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=387-494
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=495-497
`ifdef E203_SUPPORT_SHARE_MULDIV //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=495-497
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000018 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=496-496
  assign muldiv_req_alu_res  = adder_res;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000018 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=496-496
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=495-497
`endif//E203_SUPPORT_SHARE_MULDIV}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=495-497

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:assign_cluster:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=499-522
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:handshake:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=499-519
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000019 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=499-503
  assign sbf_0_ena = 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=500-502
`ifdef E203_SUPPORT_SHARE_MULDIV //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=500-502
      muldiv_req_alu ? muldiv_sbf_0_ena : 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=500-502
`endif//E203_SUPPORT_SHARE_MULDIV}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=500-502
                 agu_sbf_0_ena;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000019 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=499-503
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000020 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=504-508
  assign sbf_1_ena = 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=505-507
`ifdef E203_SUPPORT_SHARE_MULDIV //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=505-507
      muldiv_req_alu ? muldiv_sbf_1_ena : 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=505-507
`endif//E203_SUPPORT_SHARE_MULDIV}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=505-507
                 agu_sbf_1_ena;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000020 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=504-508

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000021 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=510-514
  assign sbf_0_nxt = 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000010 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=511-513
`ifdef E203_SUPPORT_SHARE_MULDIV //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000010 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=511-513
      muldiv_req_alu ? muldiv_sbf_0_nxt : 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000010 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=511-513
`endif//E203_SUPPORT_SHARE_MULDIV}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000010 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=511-513
                 {1'b0,agu_sbf_0_nxt};
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000021 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=510-514
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000022 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=515-519
  assign sbf_1_nxt = 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000011 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=516-518
`ifdef E203_SUPPORT_SHARE_MULDIV //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000011 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=516-518
      muldiv_req_alu ? muldiv_sbf_1_nxt : 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000011 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=516-518
`endif//E203_SUPPORT_SHARE_MULDIV}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000011 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=516-518
                 {1'b0,agu_sbf_1_nxt};
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000022 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=515-519
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:handshake:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=499-519

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000023 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=521-521
  assign agu_sbf_0_r = sbf_0_r[`E203_XLEN-1:0];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000023 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=521-521
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000024 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=522-522
  assign agu_sbf_1_r = sbf_1_r[`E203_XLEN-1:0];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000024 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=522-522
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:assign_cluster:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=499-522

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000012 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=524-527
`ifdef E203_SUPPORT_SHARE_MULDIV //{
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:assign_cluster:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=525-526
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000012 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=524-527
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000025 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=525-525
  assign muldiv_sbf_0_r = sbf_0_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000025 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=525-525
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000026 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=526-526
  assign muldiv_sbf_1_r = sbf_1_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:assign:000026 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=526-526
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:grp:assign_cluster:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=525-526
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000012 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=524-527
`endif//E203_SUPPORT_SHARE_MULDIV}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v:pp_blk:000012 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_dpath.v lines=524-527

endmodule                                      
                                               
                                               
                                               
