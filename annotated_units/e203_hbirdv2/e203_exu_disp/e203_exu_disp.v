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
//  The Dispatch module to dispatch instructions to different functional units
//
// ====================================================================
`include "e203_defines.v"

module e203_exu_disp(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=30-110
  input  wfi_halt_exu_req,
  output wfi_halt_exu_ack,

  input  oitf_empty,
  input  amo_wait,
  //////////////////////////////////////////////////////////////
  // The operands and decode info from dispatch
  input  disp_i_valid, // Handshake valid
  output disp_i_ready, // Handshake ready 

  // The operand 1/2 read-enable signals and indexes
  input  disp_i_rs1x0,
  input  disp_i_rs2x0,
  input  disp_i_rs1en,
  input  disp_i_rs2en,
  input  [`E203_RFIDX_WIDTH-1:0] disp_i_rs1idx,
  input  [`E203_RFIDX_WIDTH-1:0] disp_i_rs2idx,
  input  [`E203_XLEN-1:0] disp_i_rs1,
  input  [`E203_XLEN-1:0] disp_i_rs2,
  input  disp_i_rdwen,
  input  [`E203_RFIDX_WIDTH-1:0] disp_i_rdidx,
  input  [`E203_DECINFO_WIDTH-1:0]  disp_i_info,  
  input  [`E203_XLEN-1:0] disp_i_imm,
  input  [`E203_PC_SIZE-1:0] disp_i_pc,
  input  disp_i_misalgn,
  input  disp_i_buserr ,
  input  disp_i_ilegl  ,


  //////////////////////////////////////////////////////////////
  // Dispatch to ALU
  output disp_o_alu_valid, 
  input  disp_o_alu_ready,

  input  disp_o_alu_longpipe,

  output [`E203_XLEN-1:0] disp_o_alu_rs1,

  
  output [`E203_XLEN-1:0] disp_o_alu_rs2,
  output disp_o_alu_rdwen,
  output [`E203_RFIDX_WIDTH-1:0] disp_o_alu_rdidx,
  output [`E203_DECINFO_WIDTH-1:0]  disp_o_alu_info,  
  output [`E203_XLEN-1:0] disp_o_alu_imm,
  output [`E203_PC_SIZE-1:0] disp_o_alu_pc,
  output [`E203_ITAG_WIDTH-1:0] disp_o_alu_itag,
  output disp_o_alu_misalgn,
  output disp_o_alu_buserr ,
  output disp_o_alu_ilegl  ,

  //////////////////////////////////////////////////////////////
  // Dispatch to OITF
  input  oitfrd_match_disprs1,
  input  oitfrd_match_disprs2,
  input  oitfrd_match_disprs3,
  input  oitfrd_match_disprd,
  input  [`E203_ITAG_WIDTH-1:0] disp_oitf_ptr ,

  output disp_oitf_ena,
  input  disp_oitf_ready,

  output disp_oitf_rs1fpu,
  output disp_oitf_rs2fpu,
  output disp_oitf_rs3fpu,
  output disp_oitf_rdfpu ,

  output disp_oitf_rs1en ,
  output disp_oitf_rs2en ,
  output disp_oitf_rs3en ,
  output disp_oitf_rdwen ,

  output [`E203_RFIDX_WIDTH-1:0] disp_oitf_rs1idx,
  output [`E203_RFIDX_WIDTH-1:0] disp_oitf_rs2idx,
  output [`E203_RFIDX_WIDTH-1:0] disp_oitf_rs3idx,
  output [`E203_RFIDX_WIDTH-1:0] disp_oitf_rdidx ,

  output [`E203_PC_SIZE-1:0] disp_oitf_pc ,

  
  input  clk,
  input  rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=30-110
  );


//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=114-130
  wire [`E203_DECINFO_GRP_WIDTH-1:0] disp_i_info_grp  = disp_i_info [`E203_DECINFO_GRP];

  // Based on current 2 pipe stage implementation, the 2nd stage need to have all instruction
  //   to be commited via ALU interface, so every instruction need to be dispatched to ALU,
  //   regardless it is long pipe or not, and inside ALU it will issue instructions to different
  //   other longpipes
  //wire disp_alu  = (disp_i_info_grp == `E203_DECINFO_GRP_ALU) 
  //               | (disp_i_info_grp == `E203_DECINFO_GRP_BJP) 
  //               | (disp_i_info_grp == `E203_DECINFO_GRP_CSR) 
  //              `ifdef E203_SUPPORT_SHARE_MULDIV //{
  //               | (disp_i_info_grp == `E203_DECINFO_GRP_MULDIV) 
  //              `endif//E203_SUPPORT_SHARE_MULDIV}
  //               | (disp_i_info_grp == `E203_DECINFO_GRP_AGU);

  wire disp_csr = (disp_i_info_grp == `E203_DECINFO_GRP_CSR); 

  wire disp_alu_longp_prdt = (disp_i_info_grp == `E203_DECINFO_GRP_AGU)  
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=114-130
                             ;

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=133-136
  wire disp_alu_longp_real = disp_o_alu_longpipe;

  // Both fence and fencei need to make sure all outstanding instruction have been completed
  wire disp_fence_fencei   = (disp_i_info_grp == `E203_DECINFO_GRP_BJP) & 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=133-136
                               ( disp_i_info [`E203_DECINFO_BJP_FENCE] | disp_i_info [`E203_DECINFO_BJP_FENCEI]);   

  // Since any instruction will need to be dispatched to ALU, we dont need the gate here
  //   wire   disp_i_ready_pos = disp_alu & disp_o_alu_ready;
  //   assign disp_o_alu_valid = disp_alu & disp_i_valid_pos; 
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=142-143
  wire disp_i_valid_pos; 
  wire   disp_i_ready_pos = disp_o_alu_ready;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=142-143
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000001 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=144-144
  assign disp_o_alu_valid = disp_i_valid_pos; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000001 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=144-144
  
  //////////////////////////////////////////////////////////////
  // The Dispatch Scheme Introduction for two-pipeline stage
  //  #1: The instruction after dispatched must have already have operand fetched, so
  //      there is no any WAR dependency happened.
  //  #2: The ALU-instruction are dispatched and executed in-order inside ALU, so
  //      there is no any WAW dependency happened among ALU instructions.
  //      Note: LSU since its AGU is handled inside ALU, so it is treated as a ALU instruction
  //  #3: The non-ALU-instruction are all tracked by OITF, and must be write-back in-order, so 
  //      it is like ALU in-ordered. So there is no any WAW dependency happened among
  //      non-ALU instructions.
  //  Then what dependency will we have?
  //  * RAW: This is the real dependency
  //  * WAW: The WAW between ALU an non-ALU instructions
  //
  //  So #1, The dispatching ALU instruction can not proceed and must be stalled when
  //      ** RAW: The ALU reading operands have data dependency with OITF entries
  //         *** Note: since it is 2 pipeline stage, any last ALU instruction have already
  //             write-back into the regfile. So there is no chance for ALU instr to depend 
  //             on last ALU instructions as RAW. 
  //             Note: if it is 3 pipeline stages, then we also need to consider the ALU-to-ALU 
  //                   RAW dependency.
  //      ** WAW: The ALU writing result have no any data dependency with OITF entries
  //           Note: Since the ALU instruction handled by ALU may surpass non-ALU OITF instructions
  //                 so we must check this.
  //  And #2, The dispatching non-ALU instruction can not proceed and must be stalled when
  //      ** RAW: The non-ALU reading operands have data dependency with OITF entries
  //         *** Note: since it is 2 pipeline stage, any last ALU instruction have already
  //             write-back into the regfile. So there is no chance for non-ALU instr to depend 
  //             on last ALU instructions as RAW. 
  //             Note: if it is 3 pipeline stages, then we also need to consider the non-ALU-to-ALU 
  //                   RAW dependency.

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=178-178
  wire raw_dep =  ((oitfrd_match_disprs1) |
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=178-178
                   (oitfrd_match_disprs2) |
                   (oitfrd_match_disprs3)); 
               // Only check the longp instructions (non-ALU) for WAW, here if we 
               //   use the precise version (disp_alu_longp_real), it will hurt timing very much, but
               //   if we use imprecise version of disp_alu_longp_prdt, it is kind of tricky and in 
               //   some corner case. For example, the AGU (treated as longp) will actually not dispatch
               //   to longp but just directly commited, then it become a normal ALU instruction, and should
               //   check the WAW dependency, but this only happened when it is AMO or unaligned-uop, so
               //   ideally we dont need to worry about it, because
               //     * We dont support AMO in 2 stage CPU here
               //     * We dont support Unalign load-store in 2 stage CPU here, which 
               //         will be triggered as exception, so will not really write-back
               //         into regfile
               //     * But it depends on some assumption, so it is still risky if in the future something changed.
               // Nevertheless: using this condition only waiver the longpipe WAW case, that is, two
               //   longp instruction write-back same reg back2back. Is it possible or is it common? 
               //   after we checking the benmark result we found if we remove this complexity here 
               //   it just does not change any benchmark number, so just remove that condition out. Means
               //   all of the instructions will check waw_dep
  //wire alu_waw_dep = (~disp_alu_longp_prdt) & (oitfrd_match_disprd & disp_i_rdwen); 
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:grp:internal_signal:000005 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=199-201
  wire waw_dep = (oitfrd_match_disprd); 

  wire dep = raw_dep | waw_dep;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:grp:internal_signal:000005 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=199-201

  // The WFI halt exu ack will be asserted when the OITF is empty
  //    and also there is no AMO oustanding uops 
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000002 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=205-205
  assign wfi_halt_exu_ack = oitf_empty & (~amo_wait);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000002 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=205-205

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:grp:internal_signal:000006 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=207-207
  wire disp_condition = 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:grp:internal_signal:000006 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=207-207
                 // To be more conservtive, any accessing CSR instruction need to wait the oitf to be empty.
                 // Theoretically speaking, it should also flush pipeline after the CSR have been updated
                 //  to make sure the subsequent instruction get correct CSR values, but in our 2-pipeline stage
                 //  implementation, CSR is updated after EXU stage, and subsequent are all executed at EXU stage,
                 //  no chance to got wrong CSR values, so we dont need to worry about this.
                 (disp_csr ? oitf_empty : 1'b1)
                 // To handle the Fence: just stall dispatch until the OITF is empty
               & (disp_fence_fencei ? oitf_empty : 1'b1)
                 // If it was a WFI instruction commited halt req, then it will stall the disaptch
               & (~wfi_halt_exu_req)   
                 // No dependency
               & (~dep)   
               ////  // If dispatch to ALU as long pipeline, then must check
               ////  //   the OITF is ready
               //// & ((disp_alu & disp_o_alu_longpipe) ? disp_oitf_ready : 1'b1);
               // To cut the critical timing  path from longpipe signal
               // we always assume the LSU will need oitf ready
               & (disp_alu_longp_prdt ? disp_oitf_ready : 1'b1);

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=227-228
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:grp:handshake:000001 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=227-228
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000003 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=227-227
  assign disp_i_valid_pos = disp_condition & disp_i_valid; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000003 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=227-227
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000004 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=228-228
  assign disp_i_ready     = disp_condition & disp_i_ready_pos; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000004 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=228-228
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=227-228
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:grp:handshake:000001 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=227-228


//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:grp:internal_signal:000007 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=231-232
  wire [`E203_XLEN-1:0] disp_i_rs1_msked = disp_i_rs1 & {`E203_XLEN{~disp_i_rs1x0}};
  wire [`E203_XLEN-1:0] disp_i_rs2_msked = disp_i_rs2 & {`E203_XLEN{~disp_i_rs2x0}};
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:grp:internal_signal:000007 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=231-232
    // Since we always dispatch any instructions into ALU, so we dont need to gate ops here
  //assign disp_o_alu_rs1   = {`E203_XLEN{disp_alu}} & disp_i_rs1_msked;
  //assign disp_o_alu_rs2   = {`E203_XLEN{disp_alu}} & disp_i_rs2_msked;
  //assign disp_o_alu_rdwen = disp_alu & disp_i_rdwen;
  //assign disp_o_alu_rdidx = {`E203_RFIDX_WIDTH{disp_alu}} & disp_i_rdidx;
  //assign disp_o_alu_info  = {`E203_DECINFO_WIDTH{disp_alu}} & disp_i_info;  
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=239-254
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000005 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=239-239
  assign disp_o_alu_rs1   = disp_i_rs1_msked;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000005 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=239-239
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000006 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=240-240
  assign disp_o_alu_rs2   = disp_i_rs2_msked;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000006 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=240-240
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000007 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=241-241
  assign disp_o_alu_rdwen = disp_i_rdwen;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000007 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=241-241
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000008 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=242-242
  assign disp_o_alu_rdidx = disp_i_rdidx;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000008 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=242-242
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000009 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=243-243
  assign disp_o_alu_info  = disp_i_info;  
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000009 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=243-243
  
    // Why we use precise version of disp_longp here, because
    //   only when it is really dispatched as long pipe then allocate the OITF
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000010 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=247-247
  assign disp_oitf_ena = disp_o_alu_valid & disp_o_alu_ready & disp_alu_longp_real;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000010 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=247-247

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000011 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=249-249
  assign disp_o_alu_imm  = disp_i_imm;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000011 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=249-249
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000012 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=250-250
  assign disp_o_alu_pc   = disp_i_pc;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000012 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=250-250
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000013 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=251-251
  assign disp_o_alu_itag = disp_oitf_ptr;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000013 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=251-251
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000014 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=252-252
  assign disp_o_alu_misalgn= disp_i_misalgn;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000014 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=252-252
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000015 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=253-253
  assign disp_o_alu_buserr = disp_i_buserr ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000015 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=253-253
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000016 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=254-254
  assign disp_o_alu_ilegl  = disp_i_ilegl  ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000016 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=254-254
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=239-254



//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=258-272
  `ifndef E203_HAS_FPU//{
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:grp:internal_signal:000008 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=259-272
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=258-272
  wire disp_i_fpu       = 1'b0;
  wire disp_i_fpu_rs1en = 1'b0;
  wire disp_i_fpu_rs2en = 1'b0;
  wire disp_i_fpu_rs3en = 1'b0;
  wire disp_i_fpu_rdwen = 1'b0;
  wire [`E203_RFIDX_WIDTH-1:0] disp_i_fpu_rs1idx = `E203_RFIDX_WIDTH'b0;
  wire [`E203_RFIDX_WIDTH-1:0] disp_i_fpu_rs2idx = `E203_RFIDX_WIDTH'b0;
  wire [`E203_RFIDX_WIDTH-1:0] disp_i_fpu_rs3idx = `E203_RFIDX_WIDTH'b0;
  wire [`E203_RFIDX_WIDTH-1:0] disp_i_fpu_rdidx  = `E203_RFIDX_WIDTH'b0;
  wire disp_i_fpu_rs1fpu = 1'b0;
  wire disp_i_fpu_rs2fpu = 1'b0;
  wire disp_i_fpu_rs3fpu = 1'b0;
  wire disp_i_fpu_rdfpu  = 1'b0;
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=258-272
  `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=258-272
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:grp:internal_signal:000008 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=259-272
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=273-288
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000017 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=273-273
  assign disp_oitf_rs1fpu = disp_i_fpu ? (disp_i_fpu_rs1en & disp_i_fpu_rs1fpu) : 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000017 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=273-273
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000018 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=274-274
  assign disp_oitf_rs2fpu = disp_i_fpu ? (disp_i_fpu_rs2en & disp_i_fpu_rs2fpu) : 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000018 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=274-274
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000019 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=275-275
  assign disp_oitf_rs3fpu = disp_i_fpu ? (disp_i_fpu_rs3en & disp_i_fpu_rs3fpu) : 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000019 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=275-275
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000020 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=276-276
  assign disp_oitf_rdfpu  = disp_i_fpu ? (disp_i_fpu_rdwen & disp_i_fpu_rdfpu ) : 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000020 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=276-276

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000021 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=278-278
  assign disp_oitf_rs1en  = disp_i_fpu ? disp_i_fpu_rs1en : disp_i_rs1en;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000021 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=278-278
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000022 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=279-279
  assign disp_oitf_rs2en  = disp_i_fpu ? disp_i_fpu_rs2en : disp_i_rs2en;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000022 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=279-279
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000023 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=280-280
  assign disp_oitf_rs3en  = disp_i_fpu ? disp_i_fpu_rs3en : 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000023 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=280-280
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000024 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=281-281
  assign disp_oitf_rdwen  = disp_i_fpu ? disp_i_fpu_rdwen : disp_i_rdwen;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000024 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=281-281

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000025 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=283-283
  assign disp_oitf_rs1idx = disp_i_fpu ? disp_i_fpu_rs1idx : disp_i_rs1idx;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000025 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=283-283
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000026 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=284-284
  assign disp_oitf_rs2idx = disp_i_fpu ? disp_i_fpu_rs2idx : disp_i_rs2idx;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000026 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=284-284
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000027 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=285-285
  assign disp_oitf_rs3idx = disp_i_fpu ? disp_i_fpu_rs3idx : `E203_RFIDX_WIDTH'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000027 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=285-285
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000028 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=286-286
  assign disp_oitf_rdidx  = disp_i_fpu ? disp_i_fpu_rdidx  : disp_i_rdidx;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000028 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=286-286

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000029 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=288-288
  assign disp_oitf_pc  = disp_i_pc;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:assign:000029 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=288-288
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_exu_disp/e203_exu_disp.v lines=273-288

endmodule                                      
