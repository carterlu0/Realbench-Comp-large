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
//  This module to implement the regular ALU instructions
//
//
// ====================================================================
`include "e203_defines.v"

module e203_exu_alu_rglr(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=31-81

  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // The Handshake Interface 
  //
  input  alu_i_valid, // Handshake valid
  output alu_i_ready, // Handshake ready

  input  [`E203_XLEN-1:0] alu_i_rs1,
  input  [`E203_XLEN-1:0] alu_i_rs2,
  input  [`E203_XLEN-1:0] alu_i_imm,
  input  [`E203_PC_SIZE-1:0] alu_i_pc,
  input  [`E203_DECINFO_ALU_WIDTH-1:0] alu_i_info,

  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // The ALU Write-back/Commit Interface
  output alu_o_valid, // Handshake valid
  input  alu_o_ready, // Handshake ready
  //   The Write-Back Interface for Special (unaligned ldst and AMO instructions) 
  output [`E203_XLEN-1:0] alu_o_wbck_wdat,
  output alu_o_wbck_err,   
  output alu_o_cmt_ecall,   
  output alu_o_cmt_ebreak,   
  output alu_o_cmt_wfi,   


  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // To share the ALU datapath
  // 
  // The operands and info to ALU
  output alu_req_alu_add ,
  output alu_req_alu_sub ,
  output alu_req_alu_xor ,
  output alu_req_alu_sll ,
  output alu_req_alu_srl ,
  output alu_req_alu_sra ,
  output alu_req_alu_or  ,
  output alu_req_alu_and ,
  output alu_req_alu_slt ,
  output alu_req_alu_sltu,
  output alu_req_alu_lui ,
  output [`E203_XLEN-1:0] alu_req_alu_op1,
  output [`E203_XLEN-1:0] alu_req_alu_op2,


  input  [`E203_XLEN-1:0] alu_req_alu_res,

  input  clk,
  input  rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=31-81
  );

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=84-85
  wire op2imm  = alu_i_info [`E203_DECINFO_ALU_OP2IMM ];
  wire op1pc   = alu_i_info [`E203_DECINFO_ALU_OP1PC  ];
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=84-85

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=87-88
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:grp:handshake:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=87-88
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=87-87
  assign alu_req_alu_op1  = op1pc  ? alu_i_pc  : alu_i_rs1;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=87-87
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=88-88
  assign alu_req_alu_op2  = op2imm ? alu_i_imm : alu_i_rs2;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=88-88
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=87-88
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:grp:handshake:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=87-88

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=90-93
  wire nop    = alu_i_info [`E203_DECINFO_ALU_NOP ] ;
  wire ecall  = alu_i_info [`E203_DECINFO_ALU_ECAL ];
  wire ebreak = alu_i_info [`E203_DECINFO_ALU_EBRK ];
  wire wfi    = alu_i_info [`E203_DECINFO_ALU_WFI ];
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=90-93

     // The NOP is encoded as ADDI, so need to uncheck it
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=96-117
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:grp:handshake:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=96-110
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=96-96
  assign alu_req_alu_add  = alu_i_info [`E203_DECINFO_ALU_ADD ] & (~nop);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=96-96
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=97-97
  assign alu_req_alu_sub  = alu_i_info [`E203_DECINFO_ALU_SUB ];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=97-97
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=98-98
  assign alu_req_alu_xor  = alu_i_info [`E203_DECINFO_ALU_XOR ];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=98-98
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=99-99
  assign alu_req_alu_sll  = alu_i_info [`E203_DECINFO_ALU_SLL ];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=99-99
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=100-100
  assign alu_req_alu_srl  = alu_i_info [`E203_DECINFO_ALU_SRL ];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=100-100
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=101-101
  assign alu_req_alu_sra  = alu_i_info [`E203_DECINFO_ALU_SRA ];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=101-101
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=102-102
  assign alu_req_alu_or   = alu_i_info [`E203_DECINFO_ALU_OR  ];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=102-102
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000010 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=103-103
  assign alu_req_alu_and  = alu_i_info [`E203_DECINFO_ALU_AND ];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000010 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=103-103
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000011 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=104-104
  assign alu_req_alu_slt  = alu_i_info [`E203_DECINFO_ALU_SLT ];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000011 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=104-104
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000012 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=105-105
  assign alu_req_alu_sltu = alu_i_info [`E203_DECINFO_ALU_SLTU];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000012 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=105-105
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000013 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=106-106
  assign alu_req_alu_lui  = alu_i_info [`E203_DECINFO_ALU_LUI ];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000013 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=106-106

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000014 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=108-108
  assign alu_o_valid = alu_i_valid;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000014 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=108-108
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000015 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=109-109
  assign alu_i_ready = alu_o_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000015 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=109-109
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000016 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=110-110
  assign alu_o_wbck_wdat = alu_req_alu_res;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000016 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=110-110
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:grp:handshake:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=96-110

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000017 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=112-112
  assign alu_o_cmt_ecall  = ecall;   
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000017 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=112-112
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000018 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=113-113
  assign alu_o_cmt_ebreak = ebreak;   
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000018 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=113-113
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000019 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=114-114
  assign alu_o_cmt_wfi = wfi;   
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000019 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=114-114
  
  // The exception or error result cannot write-back
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000020 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=117-117
  assign alu_o_wbck_err = alu_o_cmt_ecall | alu_o_cmt_ebreak | alu_o_cmt_wfi;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:assign:000020 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=117-117
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_rglr.v lines=96-117

endmodule
