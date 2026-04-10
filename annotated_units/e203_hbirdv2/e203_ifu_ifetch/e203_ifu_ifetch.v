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
//  The ifetch module to generate next PC and bus request
//
// ====================================================================
`include "e203_defines.v"

module e203_ifu_ifetch(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:port_section:000001 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=30-106
  output[`E203_PC_SIZE-1:0] inspect_pc,


  input  [`E203_PC_SIZE-1:0] pc_rtvec,  
  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // Fetch Interface to memory system, internal protocol
  //    * IFetch REQ channel
  output ifu_req_valid, // Handshake valid
  input  ifu_req_ready, // Handshake ready
            // Note: the req-addr can be unaligned with the length indicated
            //       by req_len signal.
            //       The targetd (ITCM, ICache or Sys-MEM) ctrl modules 
            //       will handle the unalign cases and split-and-merge works
  output [`E203_PC_SIZE-1:0] ifu_req_pc, // Fetch PC
  output ifu_req_seq, // This request is a sequential instruction fetch
  output ifu_req_seq_rv32, // This request is incremented 32bits fetch
  output [`E203_PC_SIZE-1:0] ifu_req_last_pc, // The last accessed
                                           // PC address (i.e., pc_r)
  //    * IFetch RSP channel
  input  ifu_rsp_valid, // Response valid 
  output ifu_rsp_ready, // Response ready
  input  ifu_rsp_err,   // Response error
            // Note: the RSP channel always return a valid instruction
            //   fetched from the fetching start PC address.
            //   The targetd (ITCM, ICache or Sys-MEM) ctrl modules 
            //   will handle the unalign cases and split-and-merge works
  //input  ifu_rsp_replay,
  input  [`E203_INSTR_SIZE-1:0] ifu_rsp_instr, // Response instruction

  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // The IR stage to EXU interface
  output [`E203_INSTR_SIZE-1:0] ifu_o_ir,// The instruction register
  output [`E203_PC_SIZE-1:0] ifu_o_pc,   // The PC register along with
  output ifu_o_pc_vld,
  output [`E203_RFIDX_WIDTH-1:0] ifu_o_rs1idx,
  output [`E203_RFIDX_WIDTH-1:0] ifu_o_rs2idx,
  output ifu_o_prdt_taken,               // The Bxx is predicted as taken
  output ifu_o_misalgn,                  // The fetch misalign 
  output ifu_o_buserr,                   // The fetch bus error
  output ifu_o_muldiv_b2b,               // The mul/div back2back case
  output ifu_o_valid, // Handshake signals with EXU stage
  input  ifu_o_ready,

  output  pipe_flush_ack,
  input   pipe_flush_req,
  input   [`E203_PC_SIZE-1:0] pipe_flush_add_op1,  
  input   [`E203_PC_SIZE-1:0] pipe_flush_add_op2,
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000001 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=79-81
  `ifdef E203_TIMING_BOOST//}
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000001 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=79-81
  input   [`E203_PC_SIZE-1:0] pipe_flush_pc,  
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000001 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=79-81
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000001 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=79-81

      
  // The halt request come from other commit stage
  //   If the ifu_halt_req is asserting, then IFU will stop fetching new 
  //     instructions and after the oustanding transactions are completed,
  //     asserting the ifu_halt_ack as the response.
  //   The IFU will resume fetching only after the ifu_halt_req is deasserted
  input  ifu_halt_req,
  output ifu_halt_ack,


  input  oitf_empty,
  input  [`E203_XLEN-1:0] rf2ifu_x1,
  input  [`E203_XLEN-1:0] rf2ifu_rs1,
  input  dec2ifu_rs1en,
  input  dec2ifu_rden,
  input  [`E203_RFIDX_WIDTH-1:0] dec2ifu_rdidx,
  input  dec2ifu_mulhsu,
  input  dec2ifu_div   ,
  input  dec2ifu_rem   ,
  input  dec2ifu_divu  ,
  input  dec2ifu_remu  ,

  input  clk,
  input  rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:port_section:000001 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=30-106
  );

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=109-119
  wire ifu_req_hsked  = (ifu_req_valid & ifu_req_ready) ;
  wire ifu_rsp_hsked  = (ifu_rsp_valid & ifu_rsp_ready) ;
  wire ifu_ir_o_hsked = (ifu_o_valid & ifu_o_ready) ;
  wire pipe_flush_hsked = pipe_flush_req & pipe_flush_ack;

  
 // The rst_flag is the synced version of rst_n
 //    * rst_n is asserted 
 // The rst_flag will be clear when
 //    * rst_n is de-asserted 
  wire reset_flag_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=109-119
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000001 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=120-120
  sirv_gnrl_dffrs #(1) reset_flag_dffrs (1'b0, reset_flag_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000001 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=120-120
 //
 // The reset_req valid is set when 
 //    * Currently reset_flag is asserting
 // The reset_req valid is clear when 
 //    * Currently reset_req is asserting
 //    * Currently the flush can be accepted by IFU
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=127-131
  wire reset_req_r;
  wire reset_req_set = (~reset_req_r) & reset_flag_r;
  wire reset_req_clr = reset_req_r & ifu_req_hsked;
  wire reset_req_ena = reset_req_set | reset_req_clr;
  wire reset_req_nxt = reset_req_set | (~reset_req_clr);
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=127-131

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000002 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=133-133
  sirv_gnrl_dfflr #(1) reset_req_dfflr (reset_req_ena, reset_req_nxt, reset_req_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000002 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=133-133

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=135-155
  wire ifu_reset_req = reset_req_r;





  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // The halt ack generation
  wire halt_ack_set;
  wire halt_ack_clr;
  wire halt_ack_ena;
  wire halt_ack_r;
  wire halt_ack_nxt;

     // The halt_ack will be set when
     //    * Currently halt_req is asserting
     //    * Currently halt_ack is not asserting
     //    * Currently the ifetch REQ channel is ready, means
     //        there is no oustanding transactions
  wire ifu_no_outs;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=135-155
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=156-163
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:handshake:000001 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=156-163
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000001 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=156-156
  assign halt_ack_set = ifu_halt_req & (~halt_ack_r) & ifu_no_outs;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000001 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=156-156
     // The halt_ack_r valid is cleared when 
     //    * Currently halt_ack is asserting
     //    * Currently halt_req is de-asserting
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000002 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=160-160
  assign halt_ack_clr = halt_ack_r & (~ifu_halt_req);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000002 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=160-160

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000003 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=162-162
  assign halt_ack_ena = halt_ack_set | halt_ack_clr;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000003 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=162-162
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000004 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=163-163
  assign halt_ack_nxt = halt_ack_set | (~halt_ack_clr);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000004 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=163-163
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=156-163
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:handshake:000001 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=156-163

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000003 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=165-165
  sirv_gnrl_dfflr #(1) halt_ack_dfflr (halt_ack_ena, halt_ack_nxt, halt_ack_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000003 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=165-165

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000005 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=167-167
  assign ifu_halt_ack = halt_ack_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000005 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=167-167


  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // The flush ack signal generation
   //
   //   Ideally the flush is acked when the ifetch interface is ready
   //     or there is rsponse valid 
   //   But to cut the comb loop between EXU and IFU, we always accept
   //     the flush, when it is not really acknowledged, we use a 
   //     delayed flush indication to remember this flush
   //   Note: Even if there is a delayed flush pending there, we
   //     still can accept new flush request
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000006 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=181-181
   assign pipe_flush_ack = 1'b1;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000006 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=181-181

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=183-191
   wire dly_flush_set;
   wire dly_flush_clr;
   wire dly_flush_ena;
   wire dly_flush_nxt;

      // The dly_flush will be set when
      //    * There is a flush requst is coming, but the ifu
      //        is not ready to accept new fetch request
   wire dly_flush_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=183-191
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=192-197
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:handshake:000002 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=192-195
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000007 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=192-192
   assign dly_flush_set = pipe_flush_req & (~ifu_req_hsked);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000007 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=192-192
      // The dly_flush_r valid is cleared when 
      //    * The delayed flush is issued
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000008 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=195-195
   assign dly_flush_clr = dly_flush_r & ifu_req_hsked;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000008 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=195-195
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:handshake:000002 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=192-195
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000009 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=196-196
   assign dly_flush_ena = dly_flush_set | dly_flush_clr;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000009 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=196-196
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000010 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=197-197
   assign dly_flush_nxt = dly_flush_set | (~dly_flush_clr);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000010 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=197-197
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=192-197

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000004 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=199-199
   sirv_gnrl_dfflr #(1) dly_flush_dfflr (dly_flush_ena, dly_flush_nxt, dly_flush_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000004 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=199-199

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000005 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=201-226
   wire dly_pipe_flush_req = dly_flush_r;
   wire pipe_flush_req_real = pipe_flush_req | dly_pipe_flush_req;



  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // The IR register to be used in EXU for decoding
  wire ir_valid_set;
  wire ir_valid_clr;
  wire ir_valid_ena;
  wire ir_valid_r;
  wire ir_valid_nxt;

  wire ir_pc_vld_set;
  wire ir_pc_vld_clr;
  wire ir_pc_vld_ena;
  wire ir_pc_vld_r;
  wire ir_pc_vld_nxt;


     // The ir valid is set when there is new instruction fetched *and* 
     //   no flush happening 
  wire ifu_rsp_need_replay;
  wire pc_newpend_r;
  wire ifu_ir_i_ready;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000005 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=201-226
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=227-237
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:handshake:000003 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=227-235
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000011 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=227-227
  assign ir_valid_set  = ifu_rsp_hsked & (~pipe_flush_req_real) & (~ifu_rsp_need_replay);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000011 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=227-227
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000012 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=228-228
  assign ir_pc_vld_set = pc_newpend_r & ifu_ir_i_ready & (~pipe_flush_req_real) & (~ifu_rsp_need_replay);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000012 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=228-228
     // The ir valid is cleared when it is accepted by EXU stage *or*
     //   the flush happening 
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000013 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=231-231
  assign ir_valid_clr  = ifu_ir_o_hsked | (pipe_flush_hsked & ir_valid_r);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000013 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=231-231
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000014 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=232-232
  assign ir_pc_vld_clr = ir_valid_clr;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000014 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=232-232

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000015 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=234-234
  assign ir_valid_ena  = ir_valid_set  | ir_valid_clr;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000015 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=234-234
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000016 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=235-235
  assign ir_valid_nxt  = ir_valid_set  | (~ir_valid_clr);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000016 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=235-235
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:handshake:000003 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=227-235
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000017 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=236-236
  assign ir_pc_vld_ena = ir_pc_vld_set | ir_pc_vld_clr;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000017 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=236-236
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000018 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=237-237
  assign ir_pc_vld_nxt = ir_pc_vld_set | (~ir_pc_vld_clr);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000018 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=237-237
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=227-237

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000005 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=239-239
  sirv_gnrl_dfflr #(1) ir_valid_dfflr (ir_valid_ena, ir_valid_nxt, ir_valid_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000005 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=239-239
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000006 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=240-240
  sirv_gnrl_dfflr #(1) ir_pc_vld_dfflr (ir_pc_vld_ena, ir_pc_vld_nxt, ir_pc_vld_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000006 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=240-240

     // IFU-IR loaded with the returned instruction from the IFetch RSP channel
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000006 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=243-248
  wire [`E203_INSTR_SIZE-1:0] ifu_ir_nxt = ifu_rsp_instr;
     // IFU-PC loaded with the current PC
  wire                     ifu_err_nxt = ifu_rsp_err;

     // IFU-IR and IFU-PC as the datapath register, only loaded and toggle when the valid reg is set
  wire ifu_err_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000006 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=243-248
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000007 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=249-249
  sirv_gnrl_dfflr #(1) ifu_err_dfflr(ir_valid_set, ifu_err_nxt, ifu_err_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000007 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=249-249
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000007 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=250-251
  wire prdt_taken;  
  wire ifu_prdt_taken_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000007 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=250-251
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000008 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=252-252
  sirv_gnrl_dfflr #(1) ifu_prdt_taken_dfflr (ir_valid_set, prdt_taken, ifu_prdt_taken_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000008 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=252-252
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000008 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=253-254
  wire ifu_muldiv_b2b_nxt;
  wire ifu_muldiv_b2b_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000008 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=253-254
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000009 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=255-255
  sirv_gnrl_dfflr #(1) ir_muldiv_b2b_dfflr (ir_valid_set, ifu_muldiv_b2b_nxt, ifu_muldiv_b2b_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000009 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=255-255
     //To save power the H-16bits only loaded when it is 32bits length instru 
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000009 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=257-260
  wire [`E203_INSTR_SIZE-1:0] ifu_ir_r;// The instruction register
  wire minidec_rv32;
  wire ir_hi_ena = ir_valid_set & minidec_rv32;
  wire ir_lo_ena = ir_valid_set;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000009 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=257-260
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000010 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=261-261
  sirv_gnrl_dfflr #(`E203_INSTR_SIZE/2) ifu_hi_ir_dfflr (ir_hi_ena, ifu_ir_nxt[31:16], ifu_ir_r[31:16], clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000010 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=261-261
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000011 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=262-262
  sirv_gnrl_dfflr #(`E203_INSTR_SIZE/2) ifu_lo_ir_dfflr (ir_lo_ena, ifu_ir_nxt[15: 0], ifu_ir_r[15: 0], clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000011 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=262-262

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000010 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=264-288
  wire minidec_rs1en;
  wire minidec_rs2en;
  wire [`E203_RFIDX_WIDTH-1:0] minidec_rs1idx;
  wire [`E203_RFIDX_WIDTH-1:0] minidec_rs2idx;

//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000002 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=269-279
  `ifndef E203_HAS_FPU//}
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000002 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=269-279
  wire minidec_fpu        = 1'b0;
  wire minidec_fpu_rs1en  = 1'b0;
  wire minidec_fpu_rs2en  = 1'b0;
  wire minidec_fpu_rs3en  = 1'b0;
  wire minidec_fpu_rs1fpu = 1'b0;
  wire minidec_fpu_rs2fpu = 1'b0;
  wire minidec_fpu_rs3fpu = 1'b0;
  wire [`E203_RFIDX_WIDTH-1:0] minidec_fpu_rs1idx = `E203_RFIDX_WIDTH'b0;
  wire [`E203_RFIDX_WIDTH-1:0] minidec_fpu_rs2idx = `E203_RFIDX_WIDTH'b0;
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000002 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=269-279
  `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000002 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=269-279

  wire [`E203_RFIDX_WIDTH-1:0] ir_rs1idx_r;
  wire [`E203_RFIDX_WIDTH-1:0] ir_rs2idx_r;
  wire bpu2rf_rs1_ena;
  //FPU: if it is FPU instruction. we still need to put it into the IR register, but we need to mask off the non-integer regfile index to save power
  wire ir_rs1idx_ena = (minidec_fpu & ir_valid_set & minidec_fpu_rs1en & (~minidec_fpu_rs1fpu)) | ((~minidec_fpu) & ir_valid_set & minidec_rs1en) | bpu2rf_rs1_ena;
  wire ir_rs2idx_ena = (minidec_fpu & ir_valid_set & minidec_fpu_rs2en & (~minidec_fpu_rs2fpu)) | ((~minidec_fpu) & ir_valid_set & minidec_rs2en);
  wire [`E203_RFIDX_WIDTH-1:0] ir_rs1idx_nxt = minidec_fpu ? minidec_fpu_rs1idx : minidec_rs1idx;
  wire [`E203_RFIDX_WIDTH-1:0] ir_rs2idx_nxt = minidec_fpu ? minidec_fpu_rs2idx : minidec_rs2idx;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000010 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=264-288
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000012 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=289-289
  sirv_gnrl_dfflr #(`E203_RFIDX_WIDTH) ir_rs1idx_dfflr (ir_rs1idx_ena, ir_rs1idx_nxt, ir_rs1idx_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000012 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=289-289
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000013 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=290-290
  sirv_gnrl_dfflr #(`E203_RFIDX_WIDTH) ir_rs2idx_dfflr (ir_rs2idx_ena, ir_rs2idx_nxt, ir_rs2idx_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000013 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=290-290

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000011 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=292-294
  wire [`E203_PC_SIZE-1:0] pc_r;
  wire [`E203_PC_SIZE-1:0] ifu_pc_nxt = pc_r;
  wire [`E203_PC_SIZE-1:0] ifu_pc_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000011 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=292-294
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000014 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=295-295
  sirv_gnrl_dfflr #(`E203_PC_SIZE) ifu_pc_dfflr (ir_pc_vld_set, ifu_pc_nxt,  ifu_pc_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000014 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=295-295

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:assign_cluster:000004 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=297-312
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000019 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=297-297
  assign ifu_o_ir  = ifu_ir_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000019 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=297-297
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000020 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=298-298
  assign ifu_o_pc  = ifu_pc_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000020 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=298-298
    // Instruction fetch misaligned exceptions are not possible on machines that support extensions
    // with 16-bit aligned instructions, such as the compressed instruction set extension, C.
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000021 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=301-301
  assign ifu_o_misalgn = 1'b0;// Never happen in RV32C configuration 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000021 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=301-301
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000022 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=302-302
  assign ifu_o_buserr  = ifu_err_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000022 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=302-302
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000023 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=303-303
  assign ifu_o_rs1idx = ir_rs1idx_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000023 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=303-303
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000024 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=304-304
  assign ifu_o_rs2idx = ir_rs2idx_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000024 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=304-304
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000025 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=305-305
  assign ifu_o_prdt_taken = ifu_prdt_taken_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000025 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=305-305
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000026 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=306-306
  assign ifu_o_muldiv_b2b = ifu_muldiv_b2b_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000026 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=306-306

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000027 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=308-308
  assign ifu_o_valid  = ir_valid_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000027 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=308-308
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000028 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=309-309
  assign ifu_o_pc_vld = ir_pc_vld_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000028 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=309-309

  // The IFU-IR stage will be ready when it is empty or under-clearing
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000029 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=312-312
  assign ifu_ir_i_ready   = (~ir_valid_r) | ir_valid_clr;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000029 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=312-312
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:assign_cluster:000004 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=297-312

  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // JALR instruction dependency check
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000012 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=317-333
  wire ir_empty = ~ir_valid_r;
  wire ir_rs1en = dec2ifu_rs1en;
  wire ir_rden = dec2ifu_rden;
  wire [`E203_RFIDX_WIDTH-1:0] ir_rdidx = dec2ifu_rdidx;
  wire [`E203_RFIDX_WIDTH-1:0] minidec_jalr_rs1idx;
  wire jalr_rs1idx_cam_irrdidx = ir_rden & (minidec_jalr_rs1idx == ir_rdidx) & ir_valid_r;

  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // MULDIV BACK2BACK Fusing
  // To detect the sequence of MULH[[S]U] rdh, rs1, rs2;    MUL rdl, rs1, rs2
  // To detect the sequence of     DIV[U] rdq, rs1, rs2; REM[U] rdr, rs1, rs2  
  wire minidec_mul ;
  wire minidec_div ;
  wire minidec_rem ;
  wire minidec_divu;
  wire minidec_remu;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000012 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=317-333
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000030 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=334-356
  assign ifu_muldiv_b2b_nxt = 
      (
          // For multiplicaiton, only the MUL instruction following
          //    MULH/MULHU/MULSU can be treated as back2back
          ( minidec_mul & dec2ifu_mulhsu)
          // For divider and reminder instructions, only the following cases
          //    can be treated as back2back
          //      * DIV--REM
          //      * REM--DIV
          //      * DIVU--REMU
          //      * REMU--DIVU
        | ( minidec_div  & dec2ifu_rem)
        | ( minidec_rem  & dec2ifu_div)
        | ( minidec_divu & dec2ifu_remu)
        | ( minidec_remu & dec2ifu_divu)
      )
      // The last rs1 and rs2 indexes are same as this instruction
      & (ir_rs1idx_r == ir_rs1idx_nxt)
      & (ir_rs2idx_r == ir_rs2idx_nxt)
      // The last rs1 and rs2 indexes are not same as last RD index
      & (~(ir_rs1idx_r == ir_rdidx))
      & (~(ir_rs2idx_r == ir_rdidx))
      ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000030 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=334-356

  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // Next PC generation
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000013 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=361-365
  wire minidec_bjp;
  wire minidec_jal;
  wire minidec_jalr;
  wire minidec_bxx;
  wire [`E203_XLEN-1:0] minidec_bjp_imm;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000013 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=361-365

  // The mini-decoder to check instruciton length and branch type 
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000015 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=368-394
  e203_ifu_minidec u_e203_ifu_minidec (
      .instr       (ifu_ir_nxt         ),

      .dec_rs1en   (minidec_rs1en      ),
      .dec_rs2en   (minidec_rs2en      ),
      .dec_rs1idx  (minidec_rs1idx     ),
      .dec_rs2idx  (minidec_rs2idx     ),

      .dec_rv32    (minidec_rv32       ),
      .dec_bjp     (minidec_bjp        ),
      .dec_jal     (minidec_jal        ),
      .dec_jalr    (minidec_jalr       ),
      .dec_bxx     (minidec_bxx        ),

      .dec_mulhsu  (),
      .dec_mul     (minidec_mul ),
      .dec_div     (minidec_div ),
      .dec_rem     (minidec_rem ),
      .dec_divu    (minidec_divu),
      .dec_remu    (minidec_remu),



      .dec_jalr_rs1idx (minidec_jalr_rs1idx),
      .dec_bjp_imm (minidec_bjp_imm    )

  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000015 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=368-394

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000014 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=396-398
  wire bpu_wait;
  wire [`E203_PC_SIZE-1:0] prdt_pc_add_op1;  
  wire [`E203_PC_SIZE-1:0] prdt_pc_add_op2;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000014 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=396-398

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000016 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=400-430
  e203_ifu_litebpu u_e203_ifu_litebpu(

    .pc                       (pc_r),
                              
    .dec_jal                  (minidec_jal  ),
    .dec_jalr                 (minidec_jalr ),
    .dec_bxx                  (minidec_bxx  ),
    .dec_bjp_imm              (minidec_bjp_imm  ),
    .dec_jalr_rs1idx          (minidec_jalr_rs1idx  ),

    .dec_i_valid              (ifu_rsp_valid),
    .ir_valid_clr             (ir_valid_clr),
                
    .oitf_empty               (oitf_empty),
    .ir_empty                 (ir_empty  ),
    .ir_rs1en                 (ir_rs1en  ),

    .jalr_rs1idx_cam_irrdidx  (jalr_rs1idx_cam_irrdidx),
  
    .bpu_wait                 (bpu_wait       ),  
    .prdt_taken               (prdt_taken     ),  
    .prdt_pc_add_op1          (prdt_pc_add_op1),  
    .prdt_pc_add_op2          (prdt_pc_add_op2),

    .bpu2rf_rs1_ena           (bpu2rf_rs1_ena),
    .rf2bpu_x1                (rf2ifu_x1    ),
    .rf2bpu_rs1               (rf2ifu_rs1   ),

    .clk                      (clk  ) ,
    .rst_n                    (rst_n )                 
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000016 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=400-430
  // If the instruciton is 32bits length, increament 4, otherwise 2
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000015 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=432-442
  wire [2:0] pc_incr_ofst = minidec_rv32 ? 3'd4 : 3'd2;

  wire [`E203_PC_SIZE-1:0] pc_nxt_pre;
  wire [`E203_PC_SIZE-1:0] pc_nxt;

  wire bjp_req = minidec_bjp & prdt_taken;

  wire ifetch_replay_req;

  wire [`E203_PC_SIZE-1:0] pc_add_op1 = 
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000003 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=442-445
                            `ifndef E203_TIMING_BOOST//}
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000015 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=432-442
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000003 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=442-445
                               pipe_flush_req  ? pipe_flush_add_op1 :
                               dly_pipe_flush_req  ? pc_r :
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000003 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=442-445
                            `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000003 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=442-445
                               ifetch_replay_req  ? pc_r :
                               bjp_req ? prdt_pc_add_op1    :
                               ifu_reset_req   ? pc_rtvec :
                                                 pc_r;

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000016 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=451-452
  wire [`E203_PC_SIZE-1:0] pc_add_op2 =  
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000004 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=452-455
                            `ifndef E203_TIMING_BOOST//}
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000016 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=451-452
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000004 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=452-455
                               pipe_flush_req  ? pipe_flush_add_op2 :
                               dly_pipe_flush_req  ? `E203_PC_SIZE'b0 :
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000004 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=452-455
                            `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000004 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=452-455
                               ifetch_replay_req  ? `E203_PC_SIZE'b0 :
                               bjp_req ? prdt_pc_add_op2    :
                               ifu_reset_req   ? `E203_PC_SIZE'b0 :
                                                 pc_incr_ofst ;

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:assign_cluster:000005 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=461-465
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:handshake:000004 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=461-463
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000031 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=461-461
  assign ifu_req_seq = (~pipe_flush_req_real) & (~ifu_reset_req) & (~ifetch_replay_req) & (~bjp_req);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000031 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=461-461
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000032 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=462-462
  assign ifu_req_seq_rv32 = minidec_rv32;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000032 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=462-462
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000033 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=463-463
  assign ifu_req_last_pc = pc_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000033 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=463-463
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:handshake:000004 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=461-463

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000034 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=465-465
  assign pc_nxt_pre = pc_add_op1 + pc_add_op2;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000034 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=465-465
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:assign_cluster:000005 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=461-465
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000005 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=466-473
//__RB_CUT_BEGIN__ type=pp_ifndef_branch id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000005:br:000001 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=466-467
  `ifndef E203_TIMING_BOOST//}
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000005 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=466-473
//__RB_CUT_BODY__ type=pp_ifndef_branch id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000005:br:000001 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=466-467
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000035 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=467-467
  assign pc_nxt = {pc_nxt_pre[`E203_PC_SIZE-1:1],1'b0};
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000035 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=467-467
//__RB_CUT_TAIL__ type=pp_ifndef_branch id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000005:br:000001 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=466-467
//__RB_CUT_END__ type=pp_ifndef_branch id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000005:br:000001 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=466-467
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000005:br:000002 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=468-472
  `else//}{
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000005:br:000002 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=468-472
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000036 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=469-472
  assign pc_nxt = 
               pipe_flush_req ? {pipe_flush_pc[`E203_PC_SIZE-1:1],1'b0} :
               dly_pipe_flush_req ? {pc_r[`E203_PC_SIZE-1:1],1'b0} :
               {pc_nxt_pre[`E203_PC_SIZE-1:1],1'b0};
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000036 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=469-472
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000005:br:000002 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=468-472
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000005:br:000002 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=468-472
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000005 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=466-473
  `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000005 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=466-473

  // The Ifetch issue new ifetch request when
  //   * If it is a bjp insturction, and it does not need to wait, and it is not a replay-set cycle
  //   * and there is no halt_request
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000017 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=478-489
  wire ifu_new_req = (~bpu_wait) & (~ifu_halt_req) & (~reset_flag_r) & (~ifu_rsp_need_replay);

  // The fetch request valid is triggering when
  //      * New ifetch request
  //      * or The flush-request is pending
  wire ifu_req_valid_pre = ifu_new_req | ifu_reset_req | pipe_flush_req_real | ifetch_replay_req;
  // The new request ready condition is:
  //   * No outstanding reqeusts
  //   * Or if there is outstanding, but it is reponse valid back
  wire out_flag_clr;
  wire out_flag_r;
  wire new_req_condi = (~out_flag_r) | out_flag_clr;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000017 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=478-489
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:assign_cluster:000006 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=490-495
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:handshake:000005 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=490-495
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000037 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=490-490
  assign ifu_no_outs   = (~out_flag_r) | ifu_rsp_valid;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000037 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=490-490
        // Here we use the rsp_valid rather than the out_flag_clr (ifu_rsp_hsked) because
        //   as long as the rsp_valid is asserting then means last request have returned the
        //   response back, in WFI case, we cannot expect it to be handshaked (otherwise deadlock)

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000038 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=495-495
  assign ifu_req_valid = ifu_req_valid_pre & new_req_condi;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000038 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=495-495
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:assign_cluster:000006 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=490-495
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:handshake:000005 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=490-495

  //wire ifu_rsp2ir_ready = (ifu_rsp_replay | pipe_flush_req_real) ? 1'b1 : (ifu_ir_i_ready & (~bpu_wait));
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000018 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=498-498
  wire ifu_rsp2ir_ready = (pipe_flush_req_real) ? 1'b1 : (ifu_ir_i_ready & ifu_req_ready & (~bpu_wait));
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000018 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=498-498

  // Response channel only ready when:
  //   * IR is ready to accept new instructions
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000039 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=502-502
  assign ifu_rsp_ready = ifu_rsp2ir_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000039 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=502-502

  // The PC will need to be updated when ifu req channel handshaked or a flush is incoming
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000019 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=505-505
  wire pc_ena = ifu_req_hsked | pipe_flush_hsked;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000019 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=505-505

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000017 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=507-507
  sirv_gnrl_dfflr #(`E203_PC_SIZE) pc_dfflr (pc_ena, pc_nxt, pc_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000017 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=507-507


//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:assign_cluster:000007 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=510-513
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000040 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=510-510
 assign inspect_pc = pc_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000040 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=510-510


//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000041 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=513-513
  assign ifu_req_pc    = pc_nxt;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000041 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=513-513
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:assign_cluster:000007 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=510-513

     // The out_flag will be set if there is a new request handshaked
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000020 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=516-516
  wire out_flag_set = ifu_req_hsked;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000020 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=516-516
     // The out_flag will be cleared if there is a request response handshaked
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000042 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=518-518
  assign out_flag_clr = ifu_rsp_hsked;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000042 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=518-518
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000021 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=519-521
  wire out_flag_ena = out_flag_set | out_flag_clr;
     // If meanwhile set and clear, then set preempt
  wire out_flag_nxt = out_flag_set | (~out_flag_clr);
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000021 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=519-521

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000018 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=523-523
  sirv_gnrl_dfflr #(1) out_flag_dfflr (out_flag_ena, out_flag_nxt, out_flag_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000018 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=523-523

       // The pc_newpend will be set if there is a new PC loaded
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000022 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=526-531
  wire pc_newpend_set = pc_ena;
     // The pc_newpend will be cleared if have already loaded into the IR-PC stage
  wire pc_newpend_clr = ir_pc_vld_set;
  wire pc_newpend_ena = pc_newpend_set | pc_newpend_clr;
     // If meanwhile set and clear, then set preempt
  wire pc_newpend_nxt = pc_newpend_set | (~pc_newpend_clr);
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:internal_signal:000022 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=526-531

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000019 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=533-533
  sirv_gnrl_dfflr #(1) pc_newpend_dfflr (pc_newpend_ena, pc_newpend_nxt, pc_newpend_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:inst:000019 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=533-533


//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:assign_cluster:000008 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=536-537
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000043 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=536-536
  assign ifu_rsp_need_replay = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000043 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=536-536
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000044 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=537-537
  assign ifetch_replay_req = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:assign:000044 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=537-537
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:grp:assign_cluster:000008 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=536-537

//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000007 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=539-551
  `ifndef FPGA_SOURCE//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000007 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=539-551
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000006 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=540-550
  `ifndef DISABLE_SV_ASSERTION//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000006 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=540-550
//synopsys translate_off

CHECK_IFU_REQ_VALID_NO_X:
  assert property (@(posedge clk) disable iff (~rst_n)
                     (ifu_req_valid !== 1'bx)
                  )
  else $fatal ("\n Error: Oops, detected X value for ifu_req_valid !!! This should never happen. \n");

//synopsys translate_on
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000006 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=540-550
`endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000006 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=540-550
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000007 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=539-551
`endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v:pp_blk:000007 file=e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v lines=539-551

endmodule

