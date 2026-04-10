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
//  The Branch Resolve module to resolve the branch instructions
//
// ====================================================================
`include "e203_defines.v"


module e203_exu_branchslv(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=31-63

  //   The BJP condition final result need to be resolved at ALU
  input  cmt_i_valid,  
  output cmt_i_ready,
  input  cmt_i_rv32,  
  input  cmt_i_dret,// The dret instruction
  input  cmt_i_mret,// The ret instruction
  input  cmt_i_fencei,// The fencei instruction
  input  cmt_i_bjp,  
  input  cmt_i_bjp_prdt,// The predicted ture/false  
  input  cmt_i_bjp_rslv,// The resolved ture/false
  input  [`E203_PC_SIZE-1:0] cmt_i_pc,  
  input  [`E203_XLEN-1:0] cmt_i_imm,

  input  [`E203_PC_SIZE-1:0] csr_epc_r,
  input  [`E203_PC_SIZE-1:0] csr_dpc_r,


  input  nonalu_excpirq_flush_req_raw,
  input  brchmis_flush_ack,
  output brchmis_flush_req,
  output [`E203_PC_SIZE-1:0] brchmis_flush_add_op1,  
  output [`E203_PC_SIZE-1:0] brchmis_flush_add_op2,  
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=54-56
  `ifdef E203_TIMING_BOOST//}
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=54-56
  output [`E203_PC_SIZE-1:0] brchmis_flush_pc,  
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=54-56
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=54-56

  output  cmt_mret_ena,
  output  cmt_dret_ena,
  output  cmt_fencei_ena,

  input  clk,
  input  rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=31-63
  );

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=66-67
  wire brchmis_flush_ack_pre;
  wire brchmis_flush_req_pre;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=66-67

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=69-70
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:grp:handshake:000001 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=69-70
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:assign:000001 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=69-69
  assign brchmis_flush_req = brchmis_flush_req_pre & (~nonalu_excpirq_flush_req_raw);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:assign:000001 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=69-69
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:assign:000002 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=70-70
  assign brchmis_flush_ack_pre = brchmis_flush_ack & (~nonalu_excpirq_flush_req_raw);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:assign:000002 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=70-70
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=69-70
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:grp:handshake:000001 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=69-70
  // In Two stage impelmentation, several branch instructions are handled as below:
  //   * It is predicted at IFU, and target is handled in IFU. But 
  //             we need to check if it is predicted correctly or not. If not,
  //             we need to flush the pipeline
  //             Note: the JUMP instrution will always jump, hence they will be
  //                   both predicted and resolved as true
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=77-77
  wire brchmis_need_flush = (
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=77-77
        (cmt_i_bjp & (cmt_i_bjp_prdt ^ cmt_i_bjp_rslv)) 
  //   If it is a FenceI instruction, it is always Flush 
       | cmt_i_fencei 
  //   If it is a RET instruction, it is always jump 
       | cmt_i_mret 
  //   If it is a DRET instruction, it is always jump 
       | cmt_i_dret 
      );

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=87-87
  wire cmt_i_is_branch = (
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=87-87
         cmt_i_bjp 
       | cmt_i_fencei 
       | cmt_i_mret 
       | cmt_i_dret 
      );

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=94-105
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:assign:000003 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=94-94
  assign brchmis_flush_req_pre = cmt_i_valid & brchmis_need_flush;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:assign:000003 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=94-94

  // * If it is a DRET instruction, the new target PC is DPC register
  // * If it is a RET instruction, the new target PC is EPC register
  // * If predicted as taken, but actually it is not taken, then 
  //     The new target PC should caculated by PC+2/4
  // * If predicted as not taken, but actually it is taken, then 
  //     The new target PC should caculated by PC+offset
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:assign:000004 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=102-102
  assign brchmis_flush_add_op1 = cmt_i_dret ? csr_dpc_r : cmt_i_mret ? csr_epc_r : cmt_i_pc; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:assign:000004 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=102-102
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:assign:000005 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=103-105
  assign brchmis_flush_add_op2 = cmt_i_dret ? `E203_PC_SIZE'b0 : cmt_i_mret ? `E203_PC_SIZE'b0 :
                                 (cmt_i_fencei | cmt_i_bjp_prdt) ? (cmt_i_rv32 ? `E203_PC_SIZE'd4 : `E203_PC_SIZE'd2)
                                    : cmt_i_imm[`E203_PC_SIZE-1:0];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:assign:000005 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=103-105
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=94-105
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=106-116
  `ifdef E203_TIMING_BOOST//}
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=106-116
      // Replicated two adders here to trade area with timing
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:assign:000006 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=108-114
  assign brchmis_flush_pc = 
                                // The fenceI is also need to trigger the flush to its next instructions
                          (cmt_i_fencei | (cmt_i_bjp & cmt_i_bjp_prdt)) ? (cmt_i_pc + (cmt_i_rv32 ? `E203_PC_SIZE'd4 : `E203_PC_SIZE'd2)) :
                          (cmt_i_bjp & (~cmt_i_bjp_prdt)) ? (cmt_i_pc + cmt_i_imm[`E203_PC_SIZE-1:0]) :
                          cmt_i_dret ? csr_dpc_r :
                          //cmt_i_mret ? csr_epc_r :
                                       csr_epc_r ;// Last condition cmt_i_mret commented
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:assign:000006 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=108-114
                                                  //   to save gatecount and timing
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=106-116
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=106-116

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=118-118
  wire brchmis_flush_hsked = brchmis_flush_req & brchmis_flush_ack;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=118-118
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=119-128
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:assign:000007 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=119-119
  assign cmt_mret_ena = cmt_i_mret & brchmis_flush_hsked;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:assign:000007 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=119-119
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:assign:000008 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=120-120
  assign cmt_dret_ena = cmt_i_dret & brchmis_flush_hsked;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:assign:000008 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=120-120
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:assign:000009 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=121-121
  assign cmt_fencei_ena = cmt_i_fencei & brchmis_flush_hsked;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:assign:000009 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=121-121

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:assign:000010 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=123-128
  assign cmt_i_ready = (~cmt_i_is_branch) | 
                             (
                                 (brchmis_need_flush ? brchmis_flush_ack_pre : 1'b1) 
                               // The Non-ALU flush will override the ALU flush
                                     & (~nonalu_excpirq_flush_req_raw) 
                             );
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:assign:000010 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=123-128
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_exu_branchslv/e203_exu_branchslv.v lines=119-128

endmodule                                      
                                               
                                               
                                               
