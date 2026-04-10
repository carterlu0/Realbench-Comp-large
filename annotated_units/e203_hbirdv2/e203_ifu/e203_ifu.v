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
//  The IFU to implement entire instruction fetch unit.
//
// ====================================================================
`include "e203_defines.v"

module e203_ifu(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/e203_ifu/e203_ifu.v:grp:port_section:000001 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=30-126
  output[`E203_PC_SIZE-1:0] inspect_pc,
  output ifu_active,
  input  itcm_nohold,

  input  [`E203_PC_SIZE-1:0] pc_rtvec,  
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu/e203_ifu.v:pp_blk:000001 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=35-58
  `ifdef E203_HAS_ITCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu/e203_ifu.v:pp_blk:000001 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=35-58
  input  ifu2itcm_holdup,
  //input  ifu2itcm_replay,

  // The ITCM address region indication signal
  input [`E203_ADDR_SIZE-1:0] itcm_region_indic,

  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // Bus Interface to ITCM, internal protocol called ICB (Internal Chip Bus)
  //    * Bus cmd channel
  output ifu2itcm_icb_cmd_valid, // Handshake valid
  input  ifu2itcm_icb_cmd_ready, // Handshake ready
            // Note: The data on rdata or wdata channel must be naturally
            //       aligned, this is in line with the AXI definition
  output [`E203_ITCM_ADDR_WIDTH-1:0]   ifu2itcm_icb_cmd_addr, // Bus transaction start addr 

  //    * Bus RSP channel
  input  ifu2itcm_icb_rsp_valid, // Response valid 
  output ifu2itcm_icb_rsp_ready, // Response ready
  input  ifu2itcm_icb_rsp_err,   // Response error
            // Note: the RSP rdata is inline with AXI definition
  input  [`E203_ITCM_DATA_WIDTH-1:0] ifu2itcm_icb_rsp_rdata, 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu/e203_ifu.v:pp_blk:000001 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=35-58
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu/e203_ifu.v:pp_blk:000001 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=35-58

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu/e203_ifu.v:pp_blk:000002 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=60-79
  `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu/e203_ifu.v:pp_blk:000002 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=60-79
  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // Bus Interface to System Memory, internal protocol called ICB (Internal Chip Bus)
  //    * Bus cmd channel
  output ifu2biu_icb_cmd_valid, // Handshake valid
  input  ifu2biu_icb_cmd_ready, // Handshake ready
            // Note: The data on rdata or wdata channel must be naturally
            //       aligned, this is in line with the AXI definition
  output [`E203_ADDR_SIZE-1:0]   ifu2biu_icb_cmd_addr, // Bus transaction start addr 

  //    * Bus RSP channel
  input  ifu2biu_icb_rsp_valid, // Response valid 
  output ifu2biu_icb_rsp_ready, // Response ready
  input  ifu2biu_icb_rsp_err,   // Response error
            // Note: the RSP rdata is inline with AXI definition
  input  [`E203_SYSMEM_DATA_WIDTH-1:0] ifu2biu_icb_rsp_rdata, 

  //input  ifu2biu_replay,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu/e203_ifu.v:pp_blk:000002 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=60-79
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu/e203_ifu.v:pp_blk:000002 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=60-79

  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // The IR stage to EXU interface
  output [`E203_INSTR_SIZE-1:0] ifu_o_ir,// The instruction register
  output [`E203_PC_SIZE-1:0] ifu_o_pc,   // The PC register along with
  output ifu_o_pc_vld,
  output ifu_o_misalgn,                  // The fetch misalign 
  output ifu_o_buserr,                   // The fetch bus error
  output [`E203_RFIDX_WIDTH-1:0] ifu_o_rs1idx,
  output [`E203_RFIDX_WIDTH-1:0] ifu_o_rs2idx,
  output ifu_o_prdt_taken,               // The Bxx is predicted as taken
  output ifu_o_muldiv_b2b,               
  output ifu_o_valid, // Handshake signals with EXU stage
  input  ifu_o_ready,

  output  pipe_flush_ack,
  input   pipe_flush_req,
  input   [`E203_PC_SIZE-1:0] pipe_flush_add_op1,  
  input   [`E203_PC_SIZE-1:0] pipe_flush_add_op2,
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu/e203_ifu.v:pp_blk:000003 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=100-102
  `ifdef E203_TIMING_BOOST//}
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu/e203_ifu.v:pp_blk:000003 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=100-102
  input   [`E203_PC_SIZE-1:0] pipe_flush_pc,  
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu/e203_ifu.v:pp_blk:000003 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=100-102
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu/e203_ifu.v:pp_blk:000003 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=100-102

      
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
  input  dec2ifu_rden,
  input  dec2ifu_rs1en,
  input  [`E203_RFIDX_WIDTH-1:0] dec2ifu_rdidx,
  input  dec2ifu_mulhsu,
  input  dec2ifu_div   ,
  input  dec2ifu_rem   ,
  input  dec2ifu_divu  ,
  input  dec2ifu_remu  ,

  input  clk,
  input  rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/e203_ifu/e203_ifu.v:grp:port_section:000001 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=30-126
  );

  
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu/e203_ifu.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=130-140
  wire ifu_req_valid; 
  wire ifu_req_ready; 
  wire [`E203_PC_SIZE-1:0]   ifu_req_pc; 
  wire ifu_req_seq;
  wire ifu_req_seq_rv32;
  wire [`E203_PC_SIZE-1:0] ifu_req_last_pc;
  wire ifu_rsp_valid; 
  wire ifu_rsp_ready; 
  wire ifu_rsp_err;   
  //wire ifu_rsp_replay;   
  wire [`E203_INSTR_SIZE-1:0] ifu_rsp_instr; 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu/e203_ifu.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=130-140

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_ifu/e203_ifu.v:inst:000001 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=142-191
  e203_ifu_ifetch u_e203_ifu_ifetch(
    .inspect_pc   (inspect_pc),
    .pc_rtvec      (pc_rtvec),  
    .ifu_req_valid (ifu_req_valid),
    .ifu_req_ready (ifu_req_ready),
    .ifu_req_pc    (ifu_req_pc   ),
    .ifu_req_seq     (ifu_req_seq     ),
    .ifu_req_seq_rv32(ifu_req_seq_rv32),
    .ifu_req_last_pc (ifu_req_last_pc ),
    .ifu_rsp_valid (ifu_rsp_valid),
    .ifu_rsp_ready (ifu_rsp_ready),
    .ifu_rsp_err   (ifu_rsp_err  ),
    //.ifu_rsp_replay(ifu_rsp_replay),
    .ifu_rsp_instr (ifu_rsp_instr),
    .ifu_o_ir      (ifu_o_ir     ),
    .ifu_o_pc      (ifu_o_pc     ),
    .ifu_o_pc_vld  (ifu_o_pc_vld ),
    .ifu_o_misalgn (ifu_o_misalgn),
    .ifu_o_buserr  (ifu_o_buserr ),
    .ifu_o_rs1idx  (ifu_o_rs1idx),
    .ifu_o_rs2idx  (ifu_o_rs2idx),
    .ifu_o_prdt_taken(ifu_o_prdt_taken),
    .ifu_o_muldiv_b2b(ifu_o_muldiv_b2b),
    .ifu_o_valid   (ifu_o_valid  ),
    .ifu_o_ready   (ifu_o_ready  ),
    .pipe_flush_ack     (pipe_flush_ack    ), 
    .pipe_flush_req     (pipe_flush_req    ),
    .pipe_flush_add_op1 (pipe_flush_add_op1),     
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu/e203_ifu.v:pp_blk:000004 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=170-172
  `ifdef E203_TIMING_BOOST//}
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu/e203_ifu.v:pp_blk:000004 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=170-172
    .pipe_flush_pc      (pipe_flush_pc),  
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu/e203_ifu.v:pp_blk:000004 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=170-172
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu/e203_ifu.v:pp_blk:000004 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=170-172
    .pipe_flush_add_op2 (pipe_flush_add_op2), 
    .ifu_halt_req  (ifu_halt_req ),
    .ifu_halt_ack  (ifu_halt_ack ),

    .oitf_empty    (oitf_empty   ),
    .rf2ifu_x1     (rf2ifu_x1    ),
    .rf2ifu_rs1    (rf2ifu_rs1   ),
    .dec2ifu_rden  (dec2ifu_rden ),
    .dec2ifu_rs1en (dec2ifu_rs1en),
    .dec2ifu_rdidx (dec2ifu_rdidx),
    .dec2ifu_mulhsu(dec2ifu_mulhsu),
    .dec2ifu_div   (dec2ifu_div   ),
    .dec2ifu_rem   (dec2ifu_rem   ),
    .dec2ifu_divu  (dec2ifu_divu  ),
    .dec2ifu_remu  (dec2ifu_remu  ),

    .clk           (clk          ),
    .rst_n         (rst_n        ) 
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_ifu/e203_ifu.v:inst:000001 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=142-191



//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_ifu/e203_ifu.v:inst:000002 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=195-239
  e203_ifu_ift2icb u_e203_ifu_ift2icb (
    .ifu_req_valid (ifu_req_valid),
    .ifu_req_ready (ifu_req_ready),
    .ifu_req_pc    (ifu_req_pc   ),
    .ifu_req_seq     (ifu_req_seq     ),
    .ifu_req_seq_rv32(ifu_req_seq_rv32),
    .ifu_req_last_pc (ifu_req_last_pc ),
    .ifu_rsp_valid (ifu_rsp_valid),
    .ifu_rsp_ready (ifu_rsp_ready),
    .ifu_rsp_err   (ifu_rsp_err  ),
    //.ifu_rsp_replay(ifu_rsp_replay),
    .ifu_rsp_instr (ifu_rsp_instr),
    .itcm_nohold   (itcm_nohold),

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu/e203_ifu.v:pp_blk:000005 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=209-218
  `ifdef E203_HAS_ITCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu/e203_ifu.v:pp_blk:000005 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=209-218
    .itcm_region_indic (itcm_region_indic),
    .ifu2itcm_icb_cmd_valid(ifu2itcm_icb_cmd_valid),
    .ifu2itcm_icb_cmd_ready(ifu2itcm_icb_cmd_ready),
    .ifu2itcm_icb_cmd_addr (ifu2itcm_icb_cmd_addr ),
    .ifu2itcm_icb_rsp_valid(ifu2itcm_icb_rsp_valid),
    .ifu2itcm_icb_rsp_ready(ifu2itcm_icb_rsp_ready),
    .ifu2itcm_icb_rsp_err  (ifu2itcm_icb_rsp_err  ),
    .ifu2itcm_icb_rsp_rdata(ifu2itcm_icb_rsp_rdata),
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu/e203_ifu.v:pp_blk:000005 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=209-218
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu/e203_ifu.v:pp_blk:000005 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=209-218


//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu/e203_ifu.v:pp_blk:000006 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=221-230
  `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu/e203_ifu.v:pp_blk:000006 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=221-230
    .ifu2biu_icb_cmd_valid(ifu2biu_icb_cmd_valid),
    .ifu2biu_icb_cmd_ready(ifu2biu_icb_cmd_ready),
    .ifu2biu_icb_cmd_addr (ifu2biu_icb_cmd_addr ),
    .ifu2biu_icb_rsp_valid(ifu2biu_icb_rsp_valid),
    .ifu2biu_icb_rsp_ready(ifu2biu_icb_rsp_ready),
    .ifu2biu_icb_rsp_err  (ifu2biu_icb_rsp_err  ),
    .ifu2biu_icb_rsp_rdata(ifu2biu_icb_rsp_rdata),
    //.ifu2biu_replay (ifu2biu_replay),
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu/e203_ifu.v:pp_blk:000006 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=221-230
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu/e203_ifu.v:pp_blk:000006 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=221-230

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu/e203_ifu.v:pp_blk:000007 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=232-235
  `ifdef E203_HAS_ITCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu/e203_ifu.v:pp_blk:000007 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=232-235
    .ifu2itcm_holdup (ifu2itcm_holdup),
    //.ifu2itcm_replay (ifu2itcm_replay),
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu/e203_ifu.v:pp_blk:000007 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=232-235
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu/e203_ifu.v:pp_blk:000007 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=232-235

    .clk           (clk          ),
    .rst_n         (rst_n        ) 
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_ifu/e203_ifu.v:inst:000002 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=195-239

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu/e203_ifu.v:assign:000001 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=241-241
  assign ifu_active = 1'b1;// Seems the IFU never rest at block level
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu/e203_ifu.v:assign:000001 file=e203_hbirdv2/e203_ifu/e203_ifu.v lines=241-241
  
endmodule

