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
//  This module to implement the 17cycles MUL and 33 cycles DIV unit, which is mostly 
//  share the datapath with ALU_DPATH module to save gatecount to mininum
//
//
// ====================================================================
`include "e203_defines.v"

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=31-633
`ifdef E203_SUPPORT_MULDIV //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=31-633
module e203_exu_alu_muldiv(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=33-82
  input  mdv_nob2b,

  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // The Issue Handshake Interface to MULDIV 
  //
  input  muldiv_i_valid, // Handshake valid
  output muldiv_i_ready, // Handshake ready

  input  [`E203_XLEN-1:0] muldiv_i_rs1,
  input  [`E203_XLEN-1:0] muldiv_i_rs2,
  input  [`E203_XLEN-1:0] muldiv_i_imm,
  input  [`E203_DECINFO_MULDIV_WIDTH-1:0] muldiv_i_info,
  input  [`E203_ITAG_WIDTH-1:0] muldiv_i_itag,

  output muldiv_i_longpipe,

  input  flush_pulse,

  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // The MULDIV Write-Back/Commit Interface
  output muldiv_o_valid, // Handshake valid
  input  muldiv_o_ready, // Handshake ready
  output [`E203_XLEN-1:0] muldiv_o_wbck_wdat,
  output muldiv_o_wbck_err,   
  //   There is no exception cases for MULDIV, so no addtional cmt signals

  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // To share the ALU datapath, generate interface to ALU
  // 
     // The operands and info to ALU
  output [`E203_MULDIV_ADDER_WIDTH-1:0] muldiv_req_alu_op1,
  output [`E203_MULDIV_ADDER_WIDTH-1:0] muldiv_req_alu_op2,
  output                                muldiv_req_alu_add ,
  output                                muldiv_req_alu_sub ,
  input  [`E203_MULDIV_ADDER_WIDTH-1:0] muldiv_req_alu_res,

     // The Shared-Buffer interface to ALU-Shared-Buffer
  output          muldiv_sbf_0_ena,
  output [33-1:0] muldiv_sbf_0_nxt,
  input  [33-1:0] muldiv_sbf_0_r,

  output          muldiv_sbf_1_ena,
  output [33-1:0] muldiv_sbf_1_nxt,
  input  [33-1:0] muldiv_sbf_1_r,

  input  clk,
  input  rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=33-82
  );

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=85-92
  wire muldiv_i_hsked = muldiv_i_valid & muldiv_i_ready;
  wire muldiv_o_hsked = muldiv_o_valid & muldiv_o_ready;

  wire flushed_r;
  wire flushed_set = flush_pulse;
  wire flushed_clr = muldiv_o_hsked & (~flush_pulse);
  wire flushed_ena = flushed_set | flushed_clr;
  wire flushed_nxt = flushed_set | (~flushed_clr);
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=85-92
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:inst:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=93-93
  sirv_gnrl_dfflr #(1) flushed_dfflr (flushed_ena, flushed_nxt, flushed_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:inst:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=93-93



//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=97-117
  wire i_mul    = muldiv_i_info[`E203_DECINFO_MULDIV_MUL   ];// We treat this as signed X signed
  wire i_mulh   = muldiv_i_info[`E203_DECINFO_MULDIV_MULH  ];
  wire i_mulhsu = muldiv_i_info[`E203_DECINFO_MULDIV_MULHSU];
  wire i_mulhu  = muldiv_i_info[`E203_DECINFO_MULDIV_MULHU ];
  wire i_div    = muldiv_i_info[`E203_DECINFO_MULDIV_DIV   ];
  wire i_divu   = muldiv_i_info[`E203_DECINFO_MULDIV_DIVU  ];
  wire i_rem    = muldiv_i_info[`E203_DECINFO_MULDIV_REM   ];
  wire i_remu   = muldiv_i_info[`E203_DECINFO_MULDIV_REMU  ];
      // If it is flushed then it is not back2back real case
  wire i_b2b    = muldiv_i_info[`E203_DECINFO_MULDIV_B2B   ] & (~flushed_r) & (~mdv_nob2b);

  wire back2back_seq = i_b2b;

  wire mul_rs1_sign = (i_mulhu)            ? 1'b0 : muldiv_i_rs1[`E203_XLEN-1];
  wire mul_rs2_sign = (i_mulhsu | i_mulhu) ? 1'b0 : muldiv_i_rs2[`E203_XLEN-1];

  wire [32:0] mul_op1 = {mul_rs1_sign, muldiv_i_rs1};
  wire [32:0] mul_op2 = {mul_rs2_sign, muldiv_i_rs2};

  wire i_op_mul = i_mul | i_mulh | i_mulhsu | i_mulhu;
  wire i_op_div = i_div | i_divu | i_rem    | i_remu;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=97-117


  /////////////////////////////////////////////////////////////////////////////////
  // Implement the state machine for 
  //    (1) The MUL instructions
  //    (2) The DIV instructions
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:param_decl:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=124-124
  localparam MULDIV_STATE_WIDTH = 3;
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:param_decl:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=124-124

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=126-128
  wire [MULDIV_STATE_WIDTH-1:0] muldiv_state_nxt;
  wire [MULDIV_STATE_WIDTH-1:0] muldiv_state_r;
  wire muldiv_state_ena;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=126-128

  // State 0: The 0th state, means this is the 1 cycle see the operand inputs
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:param_decl:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=131-139
  localparam MULDIV_STATE_0TH = 3'd0;
  // State 1: Executing the instructions
  localparam MULDIV_STATE_EXEC = 3'd1;
  // State 2: Div check if need correction
  localparam MULDIV_STATE_REMD_CHCK = 3'd2;
  // State 3: Quotient correction
  localparam MULDIV_STATE_QUOT_CORR = 3'd3;
  // State 4: Reminder correction
  localparam MULDIV_STATE_REMD_CORR = 3'd4;
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:param_decl:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=131-139
  
 
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=142-161
  wire [MULDIV_STATE_WIDTH-1:0] state_0th_nxt;
  wire [MULDIV_STATE_WIDTH-1:0] state_exec_nxt;
  wire [MULDIV_STATE_WIDTH-1:0] state_remd_chck_nxt;
  wire [MULDIV_STATE_WIDTH-1:0] state_quot_corr_nxt;
  wire [MULDIV_STATE_WIDTH-1:0] state_remd_corr_nxt;
  wire state_0th_exit_ena;
  wire state_exec_exit_ena;
  wire state_remd_chck_exit_ena;
  wire state_quot_corr_exit_ena;
  wire state_remd_corr_exit_ena;

  wire special_cases;
  wire muldiv_i_valid_nb2b = muldiv_i_valid & (~back2back_seq) & (~special_cases);

  // Define some common signals and reused later to save gatecounts
  wire   muldiv_sta_is_0th       = (muldiv_state_r == MULDIV_STATE_0TH   );
  wire   muldiv_sta_is_exec      = (muldiv_state_r == MULDIV_STATE_EXEC   );
  wire   muldiv_sta_is_remd_chck  = (muldiv_state_r == MULDIV_STATE_REMD_CHCK   );
  wire   muldiv_sta_is_quot_corr = (muldiv_state_r == MULDIV_STATE_QUOT_CORR   );
  wire   muldiv_sta_is_remd_corr = (muldiv_state_r == MULDIV_STATE_REMD_CORR   );
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=142-161

      // **** If the current state is 0th,
          // If a new instruction come (non back2back), next state is MULDIV_STATE_EXEC
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=165-166
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=165-165
  assign state_0th_exit_ena = muldiv_sta_is_0th & muldiv_i_valid_nb2b & (~flush_pulse);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=165-165
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=166-166
  assign state_0th_nxt      = MULDIV_STATE_EXEC;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=166-166
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=165-166

      // **** If the current state is exec,
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=169-172
  wire div_need_corrct; 
  wire mul_exec_last_cycle; 
  wire div_exec_last_cycle; 
  wire exec_last_cycle; 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=169-172
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=173-230
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=173-180
  assign state_exec_exit_ena =  muldiv_sta_is_exec & ((
          // If it is the last cycle (16th or 32rd cycles), 
                           exec_last_cycle 
              // If it is div op, then jump to DIV_CHECK state
                         & (i_op_div ? 1'b1
              // If it is not div-need-correction, then jump to 0th 
                                            : muldiv_o_hsked))
            | flush_pulse);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=173-180
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=181-188
  assign state_exec_nxt      = 
                (
                         flush_pulse ? MULDIV_STATE_0TH :
              // If it is div op, then jump to DIV_CHECK state
                         i_op_div ? MULDIV_STATE_REMD_CHCK
              // If it is not div-need-correction, then jump to 0th 
                                         : MULDIV_STATE_0TH
                );
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=181-188

      // **** If the current state is REMD_CHCK,
          // If it is div-need-correction, then jump to QUOT_CORR state
          //   otherwise jump to the 0th
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=193-198
  assign state_remd_chck_exit_ena = (muldiv_sta_is_remd_chck & ( 
              // If it is div op, then jump to DIV_CHECK state
                                              (div_need_corrct ? 1'b1
              // If it is not div-need-correction, then jump to 0th 
                                                         : muldiv_o_hsked) 
                                              | flush_pulse )) ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=193-198
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=199-203
  assign state_remd_chck_nxt      = flush_pulse ? MULDIV_STATE_0TH :
              // If it is div-need-correction, then jump to QUOT_CORR state
                         div_need_corrct ? MULDIV_STATE_QUOT_CORR
              // If it is not div-need-correction, then jump to 0th 
                                         : MULDIV_STATE_0TH;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=199-203

      // **** If the current state is QUOT_CORR,
          // Always jump to REMD_CORR state
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=207-207
  assign state_quot_corr_exit_ena = (muldiv_sta_is_quot_corr & (flush_pulse | 1'b1));
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=207-207
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=208-208
  assign state_quot_corr_nxt      = flush_pulse ? MULDIV_STATE_0TH : MULDIV_STATE_REMD_CORR;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=208-208

                
      // **** If the current state is REMD_CORR,
              // Then jump to 0th 
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=213-213
  assign state_remd_corr_exit_ena = (muldiv_sta_is_remd_corr & (flush_pulse | muldiv_o_hsked));
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=213-213
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000010 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=214-214
  assign state_remd_corr_nxt      = flush_pulse ? MULDIV_STATE_0TH : MULDIV_STATE_0TH;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000010 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=214-214

  // The state will only toggle when each state is meeting the condition to exit 
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000011 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=217-221
  assign muldiv_state_ena = state_0th_exit_ena 
                          | state_exec_exit_ena  
                          | state_remd_chck_exit_ena  
                          | state_quot_corr_exit_ena  
                          | state_remd_corr_exit_ena;  
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000011 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=217-221

  // The next-state is onehot mux to select different entries
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000012 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=224-230
  assign muldiv_state_nxt = 
              ({MULDIV_STATE_WIDTH{state_0th_exit_ena      }} & state_0th_nxt      )
            | ({MULDIV_STATE_WIDTH{state_exec_exit_ena     }} & state_exec_nxt     )
            | ({MULDIV_STATE_WIDTH{state_remd_chck_exit_ena}} & state_remd_chck_nxt)
            | ({MULDIV_STATE_WIDTH{state_quot_corr_exit_ena}} & state_quot_corr_nxt)
            | ({MULDIV_STATE_WIDTH{state_remd_corr_exit_ena}} & state_remd_corr_nxt)
              ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000012 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=224-230
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=173-230

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:inst:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=232-232
  sirv_gnrl_dfflr #(MULDIV_STATE_WIDTH) muldiv_state_dfflr (muldiv_state_ena, muldiv_state_nxt, muldiv_state_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:inst:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=232-232

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=234-234
  wire state_exec_enter_ena = muldiv_state_ena & (muldiv_state_nxt == MULDIV_STATE_EXEC);
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=234-234

//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:param_decl:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=236-239
  localparam EXEC_CNT_W  = 6;
  localparam EXEC_CNT_1  = 6'd1 ;
  localparam EXEC_CNT_16 = 6'd16;
  localparam EXEC_CNT_32 = 6'd32;
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:param_decl:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=236-239

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=241-246
  wire[EXEC_CNT_W-1:0] exec_cnt_r;
  wire exec_cnt_set = state_exec_enter_ena;
  wire exec_cnt_inc = muldiv_sta_is_exec & (~exec_last_cycle); 
  wire exec_cnt_ena = exec_cnt_inc | exec_cnt_set; 
    // When set, the counter is set to 1, because the 0th state also counted as 0th cycle
  wire[EXEC_CNT_W-1:0] exec_cnt_nxt = exec_cnt_set ? EXEC_CNT_1 : (exec_cnt_r + 1'b1);
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=241-246
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:inst:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=247-247
  sirv_gnrl_dfflr #(EXEC_CNT_W) exec_cnt_dfflr (exec_cnt_ena, exec_cnt_nxt, exec_cnt_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:inst:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=247-247
  // The exec state is the last cycle when the exec_cnt_r is reaching the last cycle (16 or 32cycles)

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=250-252
  wire cycle_0th  = muldiv_sta_is_0th;
  wire cycle_16th = (exec_cnt_r == EXEC_CNT_16);
  wire cycle_32nd = (exec_cnt_r == EXEC_CNT_32);
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=250-252
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=253-255
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000013 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=253-253
  assign mul_exec_last_cycle = cycle_16th;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000013 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=253-253
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000014 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=254-254
  assign div_exec_last_cycle = cycle_32nd;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000014 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=254-254
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000015 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=255-255
  assign exec_last_cycle = i_op_mul ? mul_exec_last_cycle : div_exec_last_cycle;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000015 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=255-255
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=253-255



///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
// Use booth-4 algorithm to conduct the multiplication

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=264-270
  wire [32:0] part_prdt_hi_r;
  wire [32:0] part_prdt_lo_r;
  wire [32:0] part_prdt_hi_nxt;
  wire [32:0] part_prdt_lo_nxt;

  wire part_prdt_sft1_r;
  wire [2:0] booth_code = cycle_0th  ? {muldiv_i_rs1[1:0],1'b0}
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=264-270
                        : cycle_16th ? {mul_rs1_sign,part_prdt_lo_r[0],part_prdt_sft1_r}
                        : {part_prdt_lo_r[1:0],part_prdt_sft1_r};
      //booth_code == 3'b000 =  0
      //booth_code == 3'b001 =  1
      //booth_code == 3'b010 =  1
      //booth_code == 3'b011 =  2
      //booth_code == 3'b100 = -2
      //booth_code == 3'b101 = -1
      //booth_code == 3'b110 = -1
      //booth_code == 3'b111 = -0
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000010 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=281-288
  wire booth_sel_zero = (booth_code == 3'b000) | (booth_code == 3'b111);
  wire booth_sel_two  = (booth_code == 3'b011) | (booth_code == 3'b100);
  wire booth_sel_one  = (~booth_sel_zero) & (~booth_sel_two);
  wire booth_sel_sub  = booth_code[2];  

  // 35 bits adder needed
  wire [`E203_MULDIV_ADDER_WIDTH-1:0] mul_exe_alu_res = muldiv_req_alu_res;
  wire [`E203_MULDIV_ADDER_WIDTH-1:0] mul_exe_alu_op2 = 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000010 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=281-288
      ({`E203_MULDIV_ADDER_WIDTH{booth_sel_zero}} & `E203_MULDIV_ADDER_WIDTH'b0) 
    | ({`E203_MULDIV_ADDER_WIDTH{booth_sel_one }} & {mul_rs2_sign,mul_rs2_sign,mul_rs2_sign,muldiv_i_rs2}) 
    | ({`E203_MULDIV_ADDER_WIDTH{booth_sel_two }} & {mul_rs2_sign,mul_rs2_sign,muldiv_i_rs2,1'b0}) 
      ;
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000011 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=293-293
  wire [`E203_MULDIV_ADDER_WIDTH-1:0] mul_exe_alu_op1 =
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000011 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=293-293
       cycle_0th ? `E203_MULDIV_ADDER_WIDTH'b0 : {part_prdt_hi_r[32],part_prdt_hi_r[32],part_prdt_hi_r};  
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000012 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=295-296
  wire mul_exe_alu_add = (~booth_sel_sub);
  wire mul_exe_alu_sub = booth_sel_sub;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000012 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=295-296

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:assign_cluster:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=298-301
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000016 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=298-298
  assign part_prdt_hi_nxt = mul_exe_alu_res[34:2];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000016 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=298-298
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000017 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=299-301
  assign part_prdt_lo_nxt = {mul_exe_alu_res[1:0],
                         (cycle_0th ? {mul_rs1_sign,muldiv_i_rs1[31:2]} : part_prdt_lo_r[32:2])
                         };
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000017 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=299-301
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:assign_cluster:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=298-301
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000013 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=302-308
  wire part_prdt_sft1_nxt = cycle_0th ? muldiv_i_rs1[1] : part_prdt_lo_r[1];

  wire mul_exe_cnt_set = exec_cnt_set & i_op_mul;
  wire mul_exe_cnt_inc = exec_cnt_inc & i_op_mul; 

  wire part_prdt_hi_ena = mul_exe_cnt_set | mul_exe_cnt_inc | state_exec_exit_ena;
  wire part_prdt_lo_ena = part_prdt_hi_ena;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000013 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=302-308

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:inst:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=310-310
  sirv_gnrl_dfflr #(1) part_prdt_sft1_dfflr (part_prdt_lo_ena, part_prdt_sft1_nxt, part_prdt_sft1_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:inst:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=310-310

    // This mul_res is not back2back case, so directly from the adder result
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000014 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=313-348
  wire[`E203_XLEN-1:0] mul_res = i_mul ? part_prdt_lo_r[32:1] : mul_exe_alu_res[31:0];




///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
// The Divider Implementation, using the non-restoring signed division 
  wire [32:0] part_remd_r;
  wire [32:0] part_quot_r;

  wire div_rs1_sign = (i_divu | i_remu) ? 1'b0 : muldiv_i_rs1[`E203_XLEN-1];
  wire div_rs2_sign = (i_divu | i_remu) ? 1'b0 : muldiv_i_rs2[`E203_XLEN-1];

  wire [65:0] dividend = {{33{div_rs1_sign}}, div_rs1_sign, muldiv_i_rs1};
  wire [33:0] divisor  = {div_rs2_sign, div_rs2_sign, muldiv_i_rs2};

  wire quot_0cycl = (dividend[65] ^ divisor[33]) ? 1'b0 : 1'b1;// If the sign(s0)!=sign(d), then set q_1st = -1

  wire [66:0] dividend_lsft1 = {dividend[65:0],quot_0cycl};


  wire prev_quot = cycle_0th ? quot_0cycl : part_quot_r[0];

  wire part_remd_sft1_r;
  // 34 bits adder needed
  wire [33:0] div_exe_alu_res = muldiv_req_alu_res[33:0];
  wire [33:0] div_exe_alu_op1 = cycle_0th ? dividend_lsft1[66:33] : {part_remd_sft1_r, part_remd_r[32:0]};
  wire [33:0] div_exe_alu_op2 = divisor;
  wire div_exe_alu_add = (~prev_quot);
  wire div_exe_alu_sub =   prev_quot ;

  wire current_quot = (div_exe_alu_res[33] ^ divisor[33]) ? 1'b0 : 1'b1;

  wire [66:0] div_exe_part_remd;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000014 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=313-348
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:assign_cluster:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=349-350
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000018 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=349-349
  assign div_exe_part_remd[66:33] = div_exe_alu_res;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000018 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=349-349
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000019 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=350-350
  assign div_exe_part_remd[32: 0] = cycle_0th ? dividend_lsft1[32:0] : part_quot_r[32:0];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000019 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=350-350
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:assign_cluster:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=349-350

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000015 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=352-354
  wire [67:0] div_exe_part_remd_lsft1 = {div_exe_part_remd[66:0],current_quot};

  wire part_remd_ena;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000015 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=352-354
    // Since the part_remd_r is only save 33bits (after left shifted), so the adder result MSB bit we need to save
    //   it here, which will be used at next round
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:inst:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=357-357
  sirv_gnrl_dfflr #(1) part_remd_sft1_dfflr (part_remd_ena, div_exe_alu_res[32], part_remd_sft1_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:inst:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=357-357
  
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000016 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=359-371
  wire div_exe_cnt_set = exec_cnt_set & i_op_div;
  wire div_exe_cnt_inc = exec_cnt_inc & i_op_div; 

  wire corrct_phase = muldiv_sta_is_remd_corr | muldiv_sta_is_quot_corr;
  wire check_phase  = muldiv_sta_is_remd_chck;

  wire [33:0] div_quot_corr_alu_res;
  wire [33:0] div_remd_corr_alu_res;
       // Note: in last cycle, the reminder value is the non-shifted value
       //   but the quotient value is the shifted value, and last bit of quotient value is shifted always by 1 
       // If need corrective, the correct quot first, and then reminder, so reminder output as comb logic directly to 
           // save a cycle
  wire [32:0] div_remd = check_phase  ? part_remd_r [32:0]:
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000016 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=359-371
                         corrct_phase ? div_remd_corr_alu_res[32:0] :
                                        div_exe_part_remd[65:33];
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000017 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=374-374
  wire [32:0] div_quot = check_phase  ? part_quot_r [32:0]:
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000017 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=374-374
                         corrct_phase ? part_quot_r [32:0]: 
                                        {div_exe_part_remd[31:0],1'b1};

  // The partial reminder and quotient   
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000018 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=379-379
  wire [32:0] part_remd_nxt = corrct_phase ? div_remd_corr_alu_res[32:0] :
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000018 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=379-379
                              (muldiv_sta_is_exec & div_exec_last_cycle) ? div_remd :
                                                          div_exe_part_remd_lsft1[65:33];
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000019 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=382-382
  wire [32:0] part_quot_nxt = corrct_phase ? div_quot_corr_alu_res[32:0] :
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000019 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=382-382
                              (muldiv_sta_is_exec & div_exec_last_cycle) ? div_quot :
                                                          div_exe_part_remd_lsft1[32: 0];

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000020 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=386-394
  wire [33:0] div_remd_chck_alu_res = muldiv_req_alu_res[33:0];
  wire [33:0] div_remd_chck_alu_op1 = {part_remd_r[32], part_remd_r};
  wire [33:0] div_remd_chck_alu_op2 = divisor;
  wire div_remd_chck_alu_add = 1'b1;
  wire div_remd_chck_alu_sub = 1'b0;

  wire remd_is_0 = ~(|part_remd_r);
  wire remd_is_neg_divs = ~(|div_remd_chck_alu_res); 
  wire remd_is_divs = (part_remd_r == divisor[32:0]);
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000020 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=386-394
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000020 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=395-399
  assign div_need_corrct = i_op_div & (
                                ((part_remd_r[32] ^ dividend[65]) & (~remd_is_0))
                              | remd_is_neg_divs
                              | remd_is_divs
                            );
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000020 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=395-399

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000021 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=401-401
  wire remd_inc_quot_dec = (part_remd_r[32] ^ divisor[33]);
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000021 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=401-401

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000021 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=403-403
  assign div_quot_corr_alu_res = muldiv_req_alu_res[33:0];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000021 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=403-403
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000022 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=404-407
  wire [33:0] div_quot_corr_alu_op1 = {part_quot_r[32], part_quot_r};
  wire [33:0] div_quot_corr_alu_op2 = 34'b1;
  wire div_quot_corr_alu_add = (~remd_inc_quot_dec);
  wire div_quot_corr_alu_sub = remd_inc_quot_dec;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000022 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=404-407

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000022 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=409-409
  assign div_remd_corr_alu_res = muldiv_req_alu_res[33:0];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000022 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=409-409
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000023 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=410-413
  wire [33:0] div_remd_corr_alu_op1 = {part_remd_r[32], part_remd_r};
  wire [33:0] div_remd_corr_alu_op2 = divisor;
  wire div_remd_corr_alu_add = remd_inc_quot_dec;
  wire div_remd_corr_alu_sub = ~remd_inc_quot_dec;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000023 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=410-413

  // The partial reminder register will be loaded in the exe state, and in reminder correction cycle
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000023 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=416-416
  assign part_remd_ena = div_exe_cnt_set | div_exe_cnt_inc | state_exec_exit_ena | state_remd_corr_exit_ena;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000023 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=416-416
  // The partial quotient register will be loaded in the exe state, and in quotient correction cycle
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000024 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=418-425
  wire part_quot_ena = div_exe_cnt_set | div_exe_cnt_inc | state_exec_exit_ena | state_quot_corr_exit_ena;

  wire[`E203_XLEN-1:0] div_res = (i_div | i_divu) ? div_quot[`E203_XLEN-1:0] : div_remd[`E203_XLEN-1:0];



  wire div_by_0 = ~(|muldiv_i_rs2);// Divisor is all zeros
  wire div_ovf  = (i_div | i_rem) & (&muldiv_i_rs2)  // Divisor is all ones, means -1
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000024 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=418-425
                        //Dividend is 10000...000, means -(2^xlen -1)
                & muldiv_i_rs1[`E203_XLEN-1] & (~(|muldiv_i_rs1[`E203_XLEN-2:0]));

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000025 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=429-438
  wire[`E203_XLEN-1:0] div_by_0_res_quot = ~`E203_XLEN'b0;
  wire[`E203_XLEN-1:0] div_by_0_res_remd = dividend[`E203_XLEN-1:0];
  wire[`E203_XLEN-1:0] div_by_0_res = (i_div | i_divu) ? div_by_0_res_quot : div_by_0_res_remd;

  wire[`E203_XLEN-1:0] div_ovf_res_quot  = {1'b1,{`E203_XLEN-1{1'b0}}};
  wire[`E203_XLEN-1:0] div_ovf_res_remd  = `E203_XLEN'b0;
  wire[`E203_XLEN-1:0] div_ovf_res = (i_div | i_divu) ? div_ovf_res_quot : div_ovf_res_remd;

  wire div_special_cases = i_op_div & (div_by_0 | div_ovf);
  wire[`E203_XLEN-1:0] div_special_res = div_by_0 ? div_by_0_res : div_ovf_res;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000025 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=429-438



///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
// Output generateion
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000024 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=446-446
  assign special_cases = div_special_cases;// Only divider have special cases
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000024 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=446-446
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000026 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=447-454
  wire[`E203_XLEN-1:0] special_res = div_special_res;// Only divider have special cases

  // To detect the sequence of MULH[[S]U] rdh, rs1, rs2;    MUL rdl, rs1, rs2
  // To detect the sequence of     DIV[U] rdq, rs1, rs2; REM[U] rdr, rs1, rs2  
  wire [`E203_XLEN-1:0] back2back_mul_res = {part_prdt_lo_r[`E203_XLEN-2:0],part_prdt_sft1_r};// Only the MUL will be treated as back2back
  wire [`E203_XLEN-1:0] back2back_mul_rem = part_remd_r[`E203_XLEN-1:0];
  wire [`E203_XLEN-1:0] back2back_mul_div = part_quot_r[`E203_XLEN-1:0];
  wire [`E203_XLEN-1:0] back2back_res = (
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000026 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=447-454
             ({`E203_XLEN{i_mul         }} & back2back_mul_res)
           | ({`E203_XLEN{i_rem | i_remu}} & back2back_mul_rem)
           | ({`E203_XLEN{i_div | i_divu}} & back2back_mul_div)
     );

    // The output will be valid:
    //   * If it is back2back and sepcial cases, just directly pass out from input
    //   * If it is not back2back sequence when it is the last cycle of exec state 
    //     (not div need correction) or last correct state;
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000027 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=464-464
  wire wbck_condi = (back2back_seq | special_cases) ? 1'b1 : 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000027 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=464-464
                       (
                           (muldiv_sta_is_exec & exec_last_cycle & (~i_op_div))
                         | (muldiv_sta_is_remd_chck & (~div_need_corrct)) 
                         | muldiv_sta_is_remd_corr 
                       );
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:assign_cluster:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=470-471
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:handshake:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=470-471
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000025 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=470-470
  assign muldiv_o_valid = wbck_condi & muldiv_i_valid;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000025 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=470-470
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000026 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=471-471
  assign muldiv_i_ready = wbck_condi & muldiv_o_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000026 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=471-471
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:assign_cluster:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=470-471
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:handshake:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=470-471
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000028 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=472-475
  wire res_sel_spl = special_cases;
  wire res_sel_b2b  = back2back_seq & (~special_cases);
  wire res_sel_div  = (~back2back_seq) & (~special_cases) & i_op_div;
  wire res_sel_mul  = (~back2back_seq) & (~special_cases) & i_op_mul;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000028 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=472-475
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:assign_cluster:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=476-483
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000027 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=476-480
  assign muldiv_o_wbck_wdat = 
               ({`E203_XLEN{res_sel_b2b}} & back2back_res)
             | ({`E203_XLEN{res_sel_spl}} & special_res)
             | ({`E203_XLEN{res_sel_div}} & div_res)
             | ({`E203_XLEN{res_sel_mul}} & mul_res);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000027 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=476-480

  //   There is no exception cases for MULDIV, so no addtional cmt signals
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000028 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=483-483
  assign muldiv_o_wbck_err = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000028 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=483-483
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:assign_cluster:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=476-483

     // The operands and info to ALU
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000029 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=486-490
  wire req_alu_sel1 = i_op_mul;
  wire req_alu_sel2 = i_op_div & (muldiv_sta_is_0th | muldiv_sta_is_exec);
  wire req_alu_sel3 = i_op_div & muldiv_sta_is_quot_corr;
  wire req_alu_sel4 = i_op_div & muldiv_sta_is_remd_corr;
  wire req_alu_sel5 = i_op_div & muldiv_sta_is_remd_chck;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000029 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=486-490

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:assign_cluster:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=492-531
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:handshake:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=492-518
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000029 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=492-497
  assign muldiv_req_alu_op1 = 
             ({`E203_MULDIV_ADDER_WIDTH{req_alu_sel1}} & mul_exe_alu_op1      )
           | ({`E203_MULDIV_ADDER_WIDTH{req_alu_sel2}} & {{`E203_MULDIV_ADDER_WIDTH-34{1'b0}},div_exe_alu_op1      })
           | ({`E203_MULDIV_ADDER_WIDTH{req_alu_sel3}} & {{`E203_MULDIV_ADDER_WIDTH-34{1'b0}},div_quot_corr_alu_op1})
           | ({`E203_MULDIV_ADDER_WIDTH{req_alu_sel4}} & {{`E203_MULDIV_ADDER_WIDTH-34{1'b0}},div_remd_corr_alu_op1}) 
           | ({`E203_MULDIV_ADDER_WIDTH{req_alu_sel5}} & {{`E203_MULDIV_ADDER_WIDTH-34{1'b0}},div_remd_chck_alu_op1});
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000029 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=492-497

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000030 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=499-504
  assign muldiv_req_alu_op2 = 
             ({`E203_MULDIV_ADDER_WIDTH{req_alu_sel1}} & mul_exe_alu_op2      )
           | ({`E203_MULDIV_ADDER_WIDTH{req_alu_sel2}} & {{`E203_MULDIV_ADDER_WIDTH-34{1'b0}},div_exe_alu_op2      })
           | ({`E203_MULDIV_ADDER_WIDTH{req_alu_sel3}} & {{`E203_MULDIV_ADDER_WIDTH-34{1'b0}},div_quot_corr_alu_op2})
           | ({`E203_MULDIV_ADDER_WIDTH{req_alu_sel4}} & {{`E203_MULDIV_ADDER_WIDTH-34{1'b0}},div_remd_corr_alu_op2}) 
           | ({`E203_MULDIV_ADDER_WIDTH{req_alu_sel5}} & {{`E203_MULDIV_ADDER_WIDTH-34{1'b0}},div_remd_chck_alu_op2});
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000030 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=499-504

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000031 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=506-511
  assign muldiv_req_alu_add  = 
             (req_alu_sel1 & mul_exe_alu_add      )
           | (req_alu_sel2 & div_exe_alu_add      )
           | (req_alu_sel3 & div_quot_corr_alu_add)
           | (req_alu_sel4 & div_remd_corr_alu_add) 
           | (req_alu_sel5 & div_remd_chck_alu_add);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000031 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=506-511

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000032 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=513-518
  assign muldiv_req_alu_sub  = 
             (req_alu_sel1 & mul_exe_alu_sub      )
           | (req_alu_sel2 & div_exe_alu_sub      )
           | (req_alu_sel3 & div_quot_corr_alu_sub)
           | (req_alu_sel4 & div_remd_corr_alu_sub) 
           | (req_alu_sel5 & div_remd_chck_alu_sub);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000032 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=513-518
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:handshake:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=492-518

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000033 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=520-520
  assign muldiv_sbf_0_ena = part_remd_ena | part_prdt_hi_ena;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000033 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=520-520
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000034 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=521-521
  assign muldiv_sbf_0_nxt = i_op_mul ? part_prdt_hi_nxt : part_remd_nxt;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000034 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=521-521

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000035 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=523-523
  assign muldiv_sbf_1_ena = part_quot_ena | part_prdt_lo_ena;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000035 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=523-523
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000036 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=524-524
  assign muldiv_sbf_1_nxt = i_op_mul ? part_prdt_lo_nxt : part_quot_nxt;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000036 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=524-524

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000037 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=526-526
  assign part_remd_r = muldiv_sbf_0_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000037 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=526-526
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000038 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=527-527
  assign part_quot_r = muldiv_sbf_1_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000038 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=527-527
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000039 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=528-528
  assign part_prdt_hi_r = muldiv_sbf_0_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000039 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=528-528
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000040 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=529-529
  assign part_prdt_lo_r = muldiv_sbf_1_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000040 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=529-529

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000041 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=531-531
  assign muldiv_i_longpipe = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:assign:000041 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=531-531
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:assign_cluster:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=492-531





//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=537-629
`ifndef FPGA_SOURCE//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=537-629
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=538-628
`ifndef DISABLE_SV_ASSERTION//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=538-628
//synopsys translate_off
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
// These below code are used for reference check with assertion
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000030 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=544-548
  wire [31:0] golden0_mul_op1 = mul_op1[32] ? (~mul_op1[31:0]+1) : mul_op1[31:0];
  wire [31:0] golden0_mul_op2 = mul_op2[32] ? (~mul_op2[31:0]+1) : mul_op2[31:0];
  wire [63:0] golden0_mul_res_pre = golden0_mul_op1 * golden0_mul_op2;
  wire [63:0] golden0_mul_res = (mul_op1[32]^mul_op2[32]) ? (~golden0_mul_res_pre + 1) : golden0_mul_res_pre;
  wire [63:0] golden1_mul_res = $signed(mul_op1) * $signed(mul_op2); 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000030 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=544-548
  
  // To check the signed * operation is really get what we wanted
    CHECK_SIGNED_OP_CORRECT:
      assert property (@(posedge clk) disable iff ((~rst_n) | (~muldiv_o_valid))  ((golden0_mul_res == golden1_mul_res)))
      else $fatal ("\n Error: Oops, This should never happen. \n");

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000031 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=555-568
  wire [31:0] golden1_res_mul    = golden1_mul_res[31:0];
  wire [31:0] golden1_res_mulh   = golden1_mul_res[63:32];                       
  wire [31:0] golden1_res_mulhsu = golden1_mul_res[63:32];                                              
  wire [31:0] golden1_res_mulhu  = golden1_mul_res[63:32];                                                

  wire [63:0] golden2_res_mul_SxS = $signed(muldiv_i_rs1)   * $signed(muldiv_i_rs2);
  wire [63:0] golden2_res_mul_SxU = $signed(muldiv_i_rs1)   * $unsigned(muldiv_i_rs2);
  wire [63:0] golden2_res_mul_UxS = $unsigned(muldiv_i_rs1) * $signed(muldiv_i_rs2);
  wire [63:0] golden2_res_mul_UxU = $unsigned(muldiv_i_rs1) * $unsigned(muldiv_i_rs2);
  
  wire [31:0] golden2_res_mul    = golden2_res_mul_SxS[31:0];
  wire [31:0] golden2_res_mulh   = golden2_res_mul_SxS[63:32];                       
  wire [31:0] golden2_res_mulhsu = golden2_res_mul_SxU[63:32];                                              
  wire [31:0] golden2_res_mulhu  = golden2_res_mul_UxU[63:32];                                                
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000031 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=555-568

  // To check four different combination will all generate same lower 32bits result
    CHECK_FOUR_COMB_SAME_RES:
      assert property (@(posedge clk) disable iff ((~rst_n) | (~muldiv_o_valid))
          (golden2_res_mul_SxS[31:0] == golden2_res_mul_SxU[31:0])
        & (golden2_res_mul_UxS[31:0] == golden2_res_mul_UxU[31:0])
        & (golden2_res_mul_SxU[31:0] == golden2_res_mul_UxS[31:0])
       )
      else $fatal ("\n Error: Oops, This should never happen. \n");

      // Seems the golden2 result is not correct in case of mulhsu, so have to comment it out
 // // To check golden1 and golden2 result are same
 //   CHECK_GOLD1_AND_GOLD2_SAME:
 //     assert property (@(posedge clk) disable iff ((~rst_n) | (~muldiv_o_valid))
 //         (i_mul    ? (golden1_res_mul    == golden2_res_mul   ) : 1'b1)
 //        &(i_mulh   ? (golden1_res_mulh   == golden2_res_mulh  ) : 1'b1)
 //        &(i_mulhsu ? (golden1_res_mulhsu == golden2_res_mulhsu) : 1'b1)
 //        &(i_mulhu  ? (golden1_res_mulhu  == golden2_res_mulhu ) : 1'b1)
 //      )
 //     else $fatal ("\n Error: Oops, This should never happen. \n");
      
     // The special case will need to be handled specially
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000032 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=591-591
  wire [32:0] golden_res_div  = div_special_cases ? div_special_res : 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000032 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=591-591
     (  $signed({div_rs1_sign,muldiv_i_rs1})   / ((div_by_0 | div_ovf) ? 1 :   $signed({div_rs2_sign,muldiv_i_rs2})));
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000033 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=593-593
  wire [32:0] golden_res_divu  = div_special_cases ? div_special_res : 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000033 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=593-593
     ($unsigned({div_rs1_sign,muldiv_i_rs1})   / ((div_by_0 | div_ovf) ? 1 : $unsigned({div_rs2_sign,muldiv_i_rs2})));
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000034 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=595-595
  wire [32:0] golden_res_rem  = div_special_cases ? div_special_res : 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000034 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=595-595
     (  $signed({div_rs1_sign,muldiv_i_rs1})   % ((div_by_0 | div_ovf) ? 1 :   $signed({div_rs2_sign,muldiv_i_rs2})));
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000035 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=597-597
  wire [32:0] golden_res_remu  = div_special_cases ? div_special_res : 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000035 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=597-597
     ($unsigned({div_rs1_sign,muldiv_i_rs1})   % ((div_by_0 | div_ovf) ? 1 : $unsigned({div_rs2_sign,muldiv_i_rs2})));
 
  // To check golden and actual result are same
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000036 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=601-601
  wire [`E203_XLEN-1:0] golden_res = 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:grp:internal_signal:000036 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=601-601
         i_mul    ? golden1_res_mul    :
         i_mulh   ? golden1_res_mulh   :
         i_mulhsu ? golden1_res_mulhsu :
         i_mulhu  ? golden1_res_mulhu  :
         i_div    ? golden_res_div [31:0]    :
         i_divu   ? golden_res_divu[31:0]    :
         i_rem    ? golden_res_rem [31:0]    :
         i_remu   ? golden_res_remu[31:0]    :
                    `E203_XLEN'b0;

  CHECK_GOLD_AND_ACTUAL_SAME:
        // Since the printed value is not aligned with posedge clock, so change it to negetive
    assert property (@(negedge clk) disable iff ((~rst_n) | flush_pulse)
        (muldiv_o_valid ? (golden_res == muldiv_o_wbck_wdat   ) : 1'b1)
     )
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:begin_end:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=617-625
    else begin
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:begin_end:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=617-625
        $display("??????????????????????????????????????????");
        $display("??????????????????????????????????????????");
        $display("{i_mul,i_mulh,i_mulhsu,i_mulhu,i_div,i_divu,i_rem,i_remu}=%d%d%d%d%d%d%d%d",i_mul,i_mulh,i_mulhsu,i_mulhu,i_div,i_divu,i_rem,i_remu);
        $display("muldiv_i_rs1=%h\nmuldiv_i_rs2=%h\n",muldiv_i_rs1,muldiv_i_rs2);     
        $display("golden_res=%h\nmuldiv_o_wbck_wdat=%h",golden_res,muldiv_o_wbck_wdat);     
        $display("??????????????????????????????????????????");
        $fatal ("\n Error: Oops, This should never happen. \n");
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:begin_end:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=617-625
      end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:begin_end:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=617-625

//synopsys translate_on
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=538-628
`endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=538-628
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=537-629
`endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=537-629


endmodule                                      
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=31-633
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_muldiv.v lines=31-633
                                               
                                               
                                               
