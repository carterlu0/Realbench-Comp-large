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
//  The ift2icb module convert the fetch request to ICB (Internal Chip bus) 
//  and dispatch to different targets including ITCM, ICache or Sys-MEM.
//
// ====================================================================
`include "e203_defines.v"

module e203_ifu_ift2icb(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:port_section:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=31-115


  input  itcm_nohold,
  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // Fetch Interface to memory system, internal protocol
  //    * IFetch REQ channel
  input  ifu_req_valid, // Handshake valid
  output ifu_req_ready, // Handshake ready
            // Note: the req-addr can be unaligned with the length indicated
            //       by req_len signal.
            //       The targetd (ITCM, ICache or Sys-MEM) ctrl modules 
            //       will handle the unalign cases and split-and-merge works
  input  [`E203_PC_SIZE-1:0] ifu_req_pc, // Fetch PC
  input  ifu_req_seq, // This request is a sequential instruction fetch
  input  ifu_req_seq_rv32, // This request is incremented 32bits fetch
  input  [`E203_PC_SIZE-1:0] ifu_req_last_pc, // The last accessed
                                           // PC address (i.e., pc_r)
                             
  //    * IFetch RSP channel
  output ifu_rsp_valid, // Response valid 
  input  ifu_rsp_ready, // Response ready
  output ifu_rsp_err,   // Response error
            // Note: the RSP channel always return a valid instruction
            //   fetched from the fetching start PC address.
            //   The targetd (ITCM, ICache or Sys-MEM) ctrl modules 
            //   will handle the unalign cases and split-and-merge works
  //output ifu_rsp_replay,   // Response error
  output [32-1:0] ifu_rsp_instr, // Response instruction

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=61-81
  `ifdef E203_HAS_ITCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=61-81
  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // The ITCM address region indication signal
  input [`E203_ADDR_SIZE-1:0] itcm_region_indic,
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

//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=61-81
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=61-81


//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000002 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=84-103
  `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000002 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=84-103
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
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000002 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=84-103
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000002 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=84-103


  // The holdup indicating the target is not accessed by other agents 
  // since last accessed by IFU, and the output of it is holding up
  // last value. 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000003 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=109-112
  `ifdef E203_HAS_ITCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000003 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=109-112
  input  ifu2itcm_holdup,
  //input  ifu2itcm_replay,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000003 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=109-112
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000003 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=109-112

  input  clk,
  input  rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:port_section:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=31-115
  );

//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000005 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=118-122
`ifndef E203_HAS_ITCM
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000005 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=118-122
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000004 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=119-121
  `ifndef E203_HAS_MEM_ITF
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000004 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=119-121
    !!! ERROR: There is no ITCM and no System interface, where to fetch the instructions? must be wrong configuration.
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000004 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=119-121
  `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000004 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=119-121
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000005 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=118-122
`endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000005 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=118-122


/////////////////////////////////////////////////////////
// We need to instante this bypbuf for several reasons:
//   * The IR stage ready signal is generated from EXU stage which 
//      incoperated several timing critical source (e.g., ECC error check, .etc)
//      and this ready signal will be back-pressure to ifetch rsponse channel here
//   * If there is no such bypbuf, the ifetch response channel may stuck waiting
//      the IR stage to be cleared, and this may end up with a deadlock, becuase 
//      EXU stage may access the BIU or ITCM and they are waiting the IFU to accept
//      last instruction access to make way of BIU and ITCM for LSU to access
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=134-139
  wire i_ifu_rsp_valid;
  wire i_ifu_rsp_ready;
  wire i_ifu_rsp_err;
  wire [`E203_INSTR_SIZE-1:0] i_ifu_rsp_instr;
  wire [`E203_INSTR_SIZE+1-1:0]ifu_rsp_bypbuf_i_data;
  wire [`E203_INSTR_SIZE+1-1:0]ifu_rsp_bypbuf_o_data;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=134-139

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=141-149
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=141-144
  assign ifu_rsp_bypbuf_i_data = {
                          i_ifu_rsp_err,
                          i_ifu_rsp_instr
                          };
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=141-144

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000002 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=146-149
  assign {
                          ifu_rsp_err,
                          ifu_rsp_instr
                          } = ifu_rsp_bypbuf_o_data;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000002 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=146-149
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=141-149

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:inst:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=151-166
  sirv_gnrl_bypbuf # (
    .DP(1),
    .DW(`E203_INSTR_SIZE+1) 
  ) u_e203_ifetch_rsp_bypbuf(
      .i_vld   (i_ifu_rsp_valid),
      .i_rdy   (i_ifu_rsp_ready),

      .o_vld   (ifu_rsp_valid),
      .o_rdy   (ifu_rsp_ready),

      .i_dat   (ifu_rsp_bypbuf_i_data),
      .o_dat   (ifu_rsp_bypbuf_o_data),
  
      .clk     (clk  ),
      .rst_n   (rst_n)
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:inst:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=151-166

// ===========================================================================
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
/////// The itfctrl scheme introduction
//
// The instruction fetch is very tricky due to two reasons and purposes:
//   (1) We want to save area and dynamic power as much as possible
//   (2) The 32bits-length instructon may be in unaligned address
//
// In order to acheive above-mentioned purposes we define the tricky
//   fetch scheme detailed as below.
//
///////
// Firstly, several phrases are introduced here:
//   * Fetching target: the target address region including
//         ITCM,
//         System Memory Fetch Interface or ICache
//            (Note: Sys Mem and I cache are Exclusive with each other)
//   * Fetching target's Lane: The Lane here means the fetching 
//       target can read out one lane of data at one time. 
//       For example: 
//        * ITCM is 64bits wide SRAM, then it can read out one 
//          aligned 64bits one time (as a lane)
//        * System Memory is 32bits wide bus, then it can read out one 
//          aligned 32bits one time (as a lane)
//        * ICache line is N-Bytes wide SRAM, then it can read out one 
//          aligned N-Bytes one time (as a lane)
//   * Lane holding-up: The read-out Lane could be holding up there
//       For examaple:
//        * ITCM is impelemented as SRAM, the output of SRAM (readout lane)
//          will keep holding up and not change until next time the SRAM
//          is accessed (CS asserted) by new transaction
//        * ICache data ram is impelemented as SRAM, the output of
//          SRAM (readout lane) will keep holding up and not change until
//          next time the SRAM is accessed (CS asserted) by new transaction
//        * The system memory bus is from outside core peripheral or memory
//          we dont know if it will hold-up. Hence, we assume it is not
//          hoding up
//   * Crossing Lane: Since the 32bits-length instruction maybe unaligned with 
//       word address boundry, then it could be in a cross-lane address
//       For example: 
//        * If it is crossing 64bits boundry, then it is crossing ITCM Lane
//        * If it is crossing 32bits boundry, then it is crossing System Memory Lane
//        * If it is crossing N-Bytes boundry, then it is crossing ICache Lane
//   * IR register: The fetch instruction will be put into IR register which 
//       is to be used by decoder to decoding it at EXU stage
//       The Lower 16bits of IR will always be loaded with new coming
//       instructions, but in order to save dynamic power, the higher 
//       16bits IR will only be loaded when incoming instruction is
//       32bits-length (checked by mini-decode module upfront IR 
//       register)
//       Note: The source of IR register Din depends on different
//         situations described in detailed fetching sheme
//   * Leftover buffer: The ifetch will always speculatively fetch a 32bits
//       back since we dont know the instruction to be fetched is 32bits or
//       16bits length (until after it read-back and decoded by mini-decoder).
//       When the new fetch is crossing lane-boundry from current lane
//       to next lane, and if the current lane read-out value is holding up.
//       Then new 32bits instruction to be fetched can be concatated by 
//       "current holding-up lane's upper 16bits" and "next lane's lower 16bits".
//       To make it in one cycle, we push the "current holding-up lane's 
//       upper 16bits" into leftover buffer (16bits) and only issue one ifetch
//       request to memory system, and when it responded with rdata-back, 
//       directly concatate the upper 16bits rdata-back with leftover buffer
//       to become the full 32bits instruction.
//
// The new ifetch request could encounter several cases:
//   * If the new ifetch address is in the same lane portion as last fetch
//     address (current PC):
//     ** If it is crossing the lane boundry, and the current lane rdout is 
//        holding up, then
//        ---- Push current lane rdout's upper 16bits into leftover buffer
//        ---- Issue ICB cmd request with next lane address 
//        ---- After the response rdata back:
//            ---- Put the leftover buffer value into IR lower 16bits
//            ---- Put rdata lower 16bits into IR upper 16bits if instr is 32bits-long
//
//     ** If it is crossing the lane boundry, but the current lane rdout is not 
//        holding up, then
//        ---- First cycle Issue ICB cmd request with current lane address 
//            ---- Put rdata upper 16bits into leftover buffer
//        ---- Second cycle Issue ICB cmd request with next lane address 
//            ---- Put the leftover buffer value into IR lower 16bits
//            ---- Put rdata upper 16bits into IR upper 16bits if instr is 32bits-long
//
//     ** If it is not crossing the lane boundry, and the current lane rdout is 
//        holding up, then
//        ---- Not issue ICB cmd request, just directly use current holding rdata
//            ---- Put aligned rdata into IR (upper 16bits 
//                    only loaded when instr is 32bits-long)
//
//     ** If it is not crossing the lane boundry, but the current lane rdout is 
//        not holding up, then
//        ---- Issue ICB cmd request with current lane address, just directly use
//               current holding rdata
//            ---- Put aligned rdata into IR (upper 16bits 
//                    only loaded when instr is 32bits-long)
//   
//
//   * If the new ifetch address is in the different lane portion as last fetch
//     address (current PC):
//     ** If it is crossing the lane boundry, regardless the current lane rdout is 
//        holding up or not, then
//        ---- First cycle Issue ICB cmd reqeust with current lane address 
//            ---- Put rdata upper 16bits into leftover buffer
//        ---- Second cycle Issue ICB cmd reqeust with next lane address 
//            ---- Put the leftover buffer value into IR lower 16bits
//            ---- Put rdata upper 16bits into IR upper 16bits if instr is 32bits-long
//
//     ** If it is not crossing the lane boundry, then
//        ---- Issue ICB cmd request with current lane address, just directly use
//               current holding rdata
//            ---- Put aligned rdata into IR (upper 16bits 
//                    only loaded when instr is 32bits-long)
//
// ===========================================================================

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000006 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=285-287
  `ifdef E203_HAS_ITCM //{
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=286-291
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000006 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=285-287
  wire ifu_req_pc2itcm = (ifu_req_pc[`E203_ITCM_BASE_REGION] == itcm_region_indic[`E203_ITCM_BASE_REGION]); 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000006 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=285-287
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000006 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=285-287

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000008 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=289-295
  `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000008 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=289-295
  wire ifu_req_pc2mem = 1'b1
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000007 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=291-293
            `ifdef E203_HAS_ITCM //{
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=286-291
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000007 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=291-293
              & ~(ifu_req_pc2itcm)
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000007 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=291-293
            `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000007 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=291-293
              ;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000008 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=289-295
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000008 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=289-295

  // The current accessing PC is crossing the lane boundry
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=298-299
  wire ifu_req_lane_cross = 1'b0
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000011 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=299-309
                    `ifdef E203_HAS_ITCM //{
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=298-299
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000011 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=299-309
                         | (
                            ifu_req_pc2itcm   
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000009 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=302-304
                         `ifdef E203_ITCM_DATA_WIDTH_IS_32 //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000009 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=302-304
                            & (ifu_req_pc[1] == 1'b1)
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000009 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=302-304
                         `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000009 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=302-304
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000010 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=305-307
                         `ifdef E203_ITCM_DATA_WIDTH_IS_64 //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000010 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=305-307
                            & (ifu_req_pc[2:1] == 2'b11)
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000010 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=305-307
                         `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000010 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=305-307
                           )
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000011 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=299-309
                    `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000011 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=299-309
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000014 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=310-320
                    `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000014 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=310-320
                         | (
                            ifu_req_pc2mem   
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000012 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=313-315
                         `ifdef E203_SYSMEM_DATA_WIDTH_IS_32 //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000012 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=313-315
                            & (ifu_req_pc[1] == 1'b1)
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000012 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=313-315
                         `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000012 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=313-315
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000013 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=316-318
                         `ifdef E203_SYSMEM_DATA_WIDTH_IS_64 //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000013 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=316-318
                            & (ifu_req_pc[2:1] == 2'b11)
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000013 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=316-318
                         `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000013 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=316-318
                           )
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000014 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=310-320
                    `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000014 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=310-320
                    ;

  // The current accessing PC is begining of the lane boundry
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=324-325
  wire ifu_req_lane_begin = 1'b0
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000017 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=325-335
                    `ifdef E203_HAS_ITCM //{
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=324-325
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000017 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=325-335
                         | (
                            ifu_req_pc2itcm   
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000015 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=328-330
                         `ifdef E203_ITCM_DATA_WIDTH_IS_32 //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000015 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=328-330
                            & (ifu_req_pc[1] == 1'b0)
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000015 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=328-330
                         `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000015 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=328-330
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000016 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=331-333
                         `ifdef E203_ITCM_DATA_WIDTH_IS_64 //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000016 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=331-333
                            & (ifu_req_pc[2:1] == 2'b00)
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000016 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=331-333
                         `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000016 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=331-333
                           )
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000017 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=325-335
                    `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000017 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=325-335
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000020 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=336-346
                    `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000020 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=336-346
                         | (
                            ifu_req_pc2mem   
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000018 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=339-341
                         `ifdef E203_SYSMEM_DATA_WIDTH_IS_32 //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000018 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=339-341
                            & (ifu_req_pc[1] == 1'b0)
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000018 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=339-341
                         `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000018 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=339-341
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000019 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=342-344
                         `ifdef E203_SYSMEM_DATA_WIDTH_IS_64 //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000019 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=342-344
                            & (ifu_req_pc[2:1] == 2'b00)
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000019 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=342-344
                         `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000019 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=342-344
                           )
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000020 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=336-346
                    `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000020 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=336-346
                    ;
  

  // The scheme to check if the current accessing PC is same as last accessed ICB address
  //   is as below:
  //     * We only treat this case as true when it is sequentially instruction-fetch
  //         reqeust, and it is crossing the boundry as unalgned (1st 16bits and 2nd 16bits
  //         is crossing the boundry)
  //         ** If the ifetch request is the begining of lane boundry, and sequential fetch,
  //            Then:
  //                 **** If the last time it was prefetched ahead, then this time is accessing
  //                        the same address as last time. Otherwise not.
  //         ** If the ifetch request is not the begining of lane boundry, and sequential fetch,
  //            Then:
  //                 **** It must be access the same address as last time.
  //     * Note: All other non-sequential cases (e.g., flush, branch or replay) are not
  //          treated as this case
  //  
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000005 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=365-370
  wire req_lane_cross_r;
  wire ifu_req_lane_same = ifu_req_seq & (ifu_req_lane_begin ? req_lane_cross_r : 1'b1);
  
  // The current accessing PC is same as last accessed ICB address
  wire ifu_req_lane_holdup = 1'b0
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000021 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=370-372
            `ifdef E203_HAS_ITCM //{
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000005 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=365-370
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000021 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=370-372
            | (ifu_req_pc2itcm & ifu2itcm_holdup & (~itcm_nohold)) 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000021 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=370-372
            `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000021 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=370-372
            ;

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000006 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=375-389
  wire ifu_req_hsked = ifu_req_valid & ifu_req_ready;
  wire i_ifu_rsp_hsked = i_ifu_rsp_valid & i_ifu_rsp_ready;
  wire ifu_icb_cmd_valid;
  wire ifu_icb_cmd_ready;
  wire ifu_icb_cmd_hsked = ifu_icb_cmd_valid & ifu_icb_cmd_ready;
  wire ifu_icb_rsp_valid;
  wire ifu_icb_rsp_ready;
  wire ifu_icb_rsp_hsked = ifu_icb_rsp_valid & ifu_icb_rsp_ready;


  /////////////////////////////////////////////////////////////////////////////////
  // Implement the state machine for the ifetch req interface
  //
  wire req_need_2uop_r;
  wire req_need_0uop_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000006 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=375-389


//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:param_decl:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=392-400
  localparam ICB_STATE_WIDTH  = 2;
  // State 0: The idle state, means there is no any oustanding ifetch request
  localparam ICB_STATE_IDLE = 2'd0;
  // State 1: Issued first request and wait response
  localparam ICB_STATE_1ST  = 2'd1;
  // State 2: Wait to issue second request 
  localparam ICB_STATE_WAIT2ND  = 2'd2;
  // State 3: Issued second request and wait response
  localparam ICB_STATE_2ND  = 2'd3;
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:param_decl:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=392-400
  
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000007 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=402-418
  wire [ICB_STATE_WIDTH-1:0] icb_state_nxt;
  wire [ICB_STATE_WIDTH-1:0] icb_state_r;
  wire icb_state_ena;
  wire [ICB_STATE_WIDTH-1:0] state_idle_nxt   ;
  wire [ICB_STATE_WIDTH-1:0] state_1st_nxt    ;
  wire [ICB_STATE_WIDTH-1:0] state_wait2nd_nxt;
  wire [ICB_STATE_WIDTH-1:0] state_2nd_nxt    ;
  wire state_idle_exit_ena     ;
  wire state_1st_exit_ena      ;
  wire state_wait2nd_exit_ena  ;
  wire state_2nd_exit_ena      ;

  // Define some common signals and reused later to save gatecounts
  wire icb_sta_is_idle    = (icb_state_r == ICB_STATE_IDLE   );
  wire icb_sta_is_1st     = (icb_state_r == ICB_STATE_1ST    );
  wire icb_sta_is_wait2nd = (icb_state_r == ICB_STATE_WAIT2ND);
  wire icb_sta_is_2nd     = (icb_state_r == ICB_STATE_2ND    );
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000007 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=402-418

      // **** If the current state is idle,
          // If a new request come, next state is ICB_STATE_1ST
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=422-423
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000003 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=422-422
  assign state_idle_exit_ena = icb_sta_is_idle & ifu_req_hsked;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000003 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=422-422
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000004 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=423-423
  assign state_idle_nxt      = ICB_STATE_1ST;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000004 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=423-423
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=422-423

      // **** If the current state is 1st,
          // If a response come, exit this state
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000008 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=427-427
  wire ifu_icb_rsp2leftover;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000008 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=427-427
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=428-472
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:bus_cluster:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=428-472
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000005 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=428-429
  assign state_1st_exit_ena  = icb_sta_is_1st & (
                ifu_icb_rsp2leftover ? ifu_icb_rsp_hsked : i_ifu_rsp_hsked);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000005 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=428-429
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:handshake:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=430-448
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000006 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=430-444
  assign state_1st_nxt     = 
                (
              // If it need two requests but the ifetch request is not ready to be 
              //   accepted, then next state is ICB_STATE_WAIT2ND
                  (req_need_2uop_r & (~ifu_icb_cmd_ready)) ?  ICB_STATE_WAIT2ND
              // If it need two requests and the ifetch request is ready to be 
              //   accepted, then next state is ICB_STATE_2ND
                  : (req_need_2uop_r & (ifu_icb_cmd_ready)) ?  ICB_STATE_2ND 
              // If it need zero or one requests and new req handshaked, then 
              //   next state is ICB_STATE_1ST
              // If it need zero or one requests and no new req handshaked, then
              //   next state is ICB_STATE_IDLE
                  :  ifu_req_hsked  ?  ICB_STATE_1ST 
                                    : ICB_STATE_IDLE 
                ) ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000006 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=430-444

      // **** If the current state is wait-2nd,
              // If the ICB CMD is ready, then next state is ICB_STATE_2ND
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000007 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=448-448
  assign state_wait2nd_exit_ena = icb_sta_is_wait2nd &  ifu_icb_cmd_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000007 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=448-448
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:handshake:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=430-448
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000008 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=449-449
  assign state_wait2nd_nxt      = ICB_STATE_2ND;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000008 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=449-449

      // **** If the current state is 2nd,
          // If a response come, exit this state
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000009 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=453-453
  assign state_2nd_exit_ena     =  icb_sta_is_2nd &  i_ifu_rsp_hsked;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000009 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=453-453
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000010 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=454-460
  assign state_2nd_nxt          = 
                (
              // If meanwhile new req handshaked, then next state is ICB_STATE_1ST
                  ifu_req_hsked  ?  ICB_STATE_1ST : 
                      // otherwise, back to IDLE
                      ICB_STATE_IDLE
                );
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000010 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=454-460

  // The state will only toggle when each state is meeting the condition to exit:
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000011 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=463-464
  assign icb_state_ena = 
            state_idle_exit_ena | state_1st_exit_ena | state_wait2nd_exit_ena | state_2nd_exit_ena;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000011 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=463-464

  // The next-state is onehot mux to select different entries
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000012 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=467-472
  assign icb_state_nxt = 
              ({ICB_STATE_WIDTH{state_idle_exit_ena   }} & state_idle_nxt   )
            | ({ICB_STATE_WIDTH{state_1st_exit_ena    }} & state_1st_nxt    )
            | ({ICB_STATE_WIDTH{state_wait2nd_exit_ena}} & state_wait2nd_nxt)
            | ({ICB_STATE_WIDTH{state_2nd_exit_ena    }} & state_2nd_nxt    )
              ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000012 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=467-472
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=428-472
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:bus_cluster:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=428-472

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:inst:000002 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=474-474
  sirv_gnrl_dfflr #(ICB_STATE_WIDTH) icb_state_dfflr (icb_state_ena, icb_state_nxt, icb_state_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:inst:000002 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=474-474

  /////////////////////////////////////////////////////////////////////////////////
  // Save the same_cross_holdup flags for this ifetch request to be used
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000009 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=478-481
  wire req_same_cross_holdup_r;

  wire req_same_cross_holdup = ifu_req_lane_same & ifu_req_lane_cross & ifu_req_lane_holdup;
  wire req_need_2uop         = (  ifu_req_lane_same  & ifu_req_lane_cross & (~ifu_req_lane_holdup))
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000009 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=478-481
                             | ((~ifu_req_lane_same) & ifu_req_lane_cross);
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000010 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=483-483
  wire req_need_0uop         = ifu_req_lane_same & (~ifu_req_lane_cross) & ifu_req_lane_holdup;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000010 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=483-483

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:inst:000003 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=485-485
  sirv_gnrl_dfflr #(1) req_same_cross_holdup_dfflr (ifu_req_hsked, req_same_cross_holdup, req_same_cross_holdup_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:inst:000003 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=485-485
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:inst:000004 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=486-486
  sirv_gnrl_dfflr #(1) req_need_2uop_dfflr         (ifu_req_hsked, req_need_2uop,         req_need_2uop_r,         clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:inst:000004 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=486-486
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:inst:000005 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=487-487
  sirv_gnrl_dfflr #(1) req_need_0uop_dfflr         (ifu_req_hsked, req_need_0uop,         req_need_0uop_r,         clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:inst:000005 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=487-487
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:inst:000006 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=488-488
  sirv_gnrl_dfflr #(1) req_lane_cross_dfflr        (ifu_req_hsked, ifu_req_lane_cross,    req_lane_cross_r,        clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:inst:000006 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=488-488

  /////////////////////////////////////////////////////////////////////////////////
  // Save the indicate flags for this ICB transaction to be used
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000011 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=492-495
  wire [`E203_PC_SIZE-1:0] ifu_icb_cmd_addr;
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000022 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=493-497
  `ifdef E203_HAS_ITCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000022 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=493-497
  wire ifu_icb_cmd2itcm;
  wire icb_cmd2itcm_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000011 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=492-495
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:inst:000007 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=496-496
  sirv_gnrl_dfflr #(1) icb2itcm_dfflr(ifu_icb_cmd_hsked, ifu_icb_cmd2itcm, icb_cmd2itcm_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:inst:000007 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=496-496
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000022 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=493-497
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000022 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=493-497
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000023 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=498-502
  `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000012 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=499-500
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000023 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=498-502
  wire ifu_icb_cmd2biu ;
  wire icb_cmd2biu_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000012 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=499-500
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:inst:000008 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=501-501
  sirv_gnrl_dfflr #(1) icb2mem_dfflr (ifu_icb_cmd_hsked, ifu_icb_cmd2biu , icb_cmd2biu_r,  clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:inst:000008 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=501-501
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000023 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=498-502
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000023 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=498-502
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000013 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=503-504
  wire icb_cmd_addr_2_1_ena = ifu_icb_cmd_hsked | ifu_req_hsked;
  wire [1:0] icb_cmd_addr_2_1_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000013 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=503-504
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:inst:000009 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=505-505
  sirv_gnrl_dffl #(2)icb_addr_2_1_dffl(icb_cmd_addr_2_1_ena, ifu_icb_cmd_addr[2:1], icb_cmd_addr_2_1_r, clk);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:inst:000009 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=505-505

  /////////////////////////////////////////////////////////////////////////////////
  // Implement Leftover Buffer
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000014 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=509-523
  wire leftover_ena; 
  wire [15:0] leftover_nxt; 
  wire [15:0] leftover_r; 
  wire leftover_err_nxt; 
  wire leftover_err_r; 

  // The leftover buffer will be loaded into two cases
  // Please see "The itfctrl scheme introduction" for more details 
  //    * Case #1: Loaded when the last holdup upper 16bits put into leftover
  //    * Case #2: Loaded when the 1st request uop rdata upper 16bits put into leftover 
  wire holdup2leftover_sel = req_same_cross_holdup;
  wire holdup2leftover_ena = ifu_req_hsked & holdup2leftover_sel;
  wire [15:0]  put2leftover_data = 16'b0   
  //wire [15:0]  holdup2leftover_data = 16'b0   
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000024 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=523-525
                     `ifdef E203_HAS_ITCM //{
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000014 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=509-523
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000024 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=523-525
                      | ({16{icb_cmd2itcm_r}} & ifu2itcm_icb_rsp_rdata[`E203_ITCM_DATA_WIDTH-1:`E203_ITCM_DATA_WIDTH-16]) 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000024 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=523-525
                     `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000024 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=523-525
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000025 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=526-528
                     `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000025 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=526-528
                      | ({16{icb_cmd2biu_r}} & ifu2biu_icb_rsp_rdata [`E203_SYSMEM_DATA_WIDTH-1:`E203_SYSMEM_DATA_WIDTH-16]) 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000025 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=526-528
                     `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000025 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=526-528
                      ;

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000015 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=531-544
  wire uop1st2leftover_sel = ifu_icb_rsp2leftover;
  wire uop1st2leftover_ena = ifu_icb_rsp_hsked & uop1st2leftover_sel;

  //wire [15:0]  uop1st2leftover_data = 16'b0   
  //                   `ifdef E203_HAS_ITCM //{
  //                    | ({16{icb_cmd2itcm_r}} & ifu2itcm_icb_rsp_rdata[`E203_ITCM_DATA_WIDTH-1:`E203_ITCM_DATA_WIDTH-16]) 
  //                   `endif//}
  //                   `ifdef E203_HAS_MEM_ITF //{
  //                    | ({16{icb_cmd2biu_r}} & ifu2biu_icb_rsp_rdata [`E203_SYSMEM_DATA_WIDTH-1:`E203_SYSMEM_DATA_WIDTH-16]) 
  //                   `endif//}
  //                    ;

  wire uop1st2leftover_err = 1'b0   
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000026 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=544-546
                     `ifdef E203_HAS_ITCM //{
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000015 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=531-544
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000026 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=544-546
                      | (icb_cmd2itcm_r & ifu2itcm_icb_rsp_err)
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000026 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=544-546
                     `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000026 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=544-546
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000027 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=547-549
                     `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000027 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=547-549
                      | (icb_cmd2biu_r & ifu2biu_icb_rsp_err)
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000027 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=547-549
                     `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000027 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=547-549
                      ;

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:assign_cluster:000004 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=552-564
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000013 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=552-553
  assign leftover_ena = holdup2leftover_ena 
                      | uop1st2leftover_ena;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000013 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=552-553

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000014 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=555-559
  assign leftover_nxt = 
                      //  ({16{holdup2leftover_sel}} & holdup2leftover_data[15:0]) 
                      //| ({16{uop1st2leftover_sel}} & uop1st2leftover_data[15:0]) 
                        put2leftover_data[15:0] 
                      ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000014 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=555-559

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000015 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=561-564
  assign leftover_err_nxt = 
                        (holdup2leftover_sel & 1'b0)
                      | (uop1st2leftover_sel & uop1st2leftover_err) 
                      ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000015 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=561-564
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:assign_cluster:000004 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=552-564

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:inst:000010 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=566-566
  sirv_gnrl_dffl #(16) leftover_dffl     (leftover_ena, leftover_nxt,     leftover_r,     clk);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:inst:000010 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=566-566
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:inst:000011 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=567-567
  sirv_gnrl_dfflr #(1) leftover_err_dfflr(leftover_ena, leftover_err_nxt, leftover_err_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:inst:000011 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=567-567
  
  /////////////////////////////////////////////////////////////////////////////////
  // Generate the ifetch response channel
  // 
  // The ifetch response instr will have 2 sources
  // Please see "The itfctrl scheme introduction" for more details 
  //    * Source #1: The concatenation by {rdata[15:0],leftover}, when
  //          ** the state is in 2ND uop
  //          ** the state is in 1ND uop but it is same-cross-holdup case
  //    * Source #2: The rdata-aligned, when
  //           ** not selecting leftover
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000016 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=579-579
  wire rsp_instr_sel_leftover = (   icb_sta_is_1st
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000016 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=579-579
                                  & req_same_cross_holdup_r
                                )
                              | icb_sta_is_2nd;

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000017 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=584-587
  wire rsp_instr_sel_icb_rsp = ~rsp_instr_sel_leftover;

  wire [16-1:0] ifu_icb_rsp_rdata_lsb16 = 16'b0
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000028 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=587-589
                     `ifdef E203_HAS_ITCM //{
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000017 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=584-587
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000028 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=587-589
                       | ({16{icb_cmd2itcm_r}} & ifu2itcm_icb_rsp_rdata[15:0])
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000028 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=587-589
                     `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000028 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=587-589
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000029 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=590-592
                     `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000029 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=590-592
                       | ({16{icb_cmd2biu_r}}  & ifu2biu_icb_rsp_rdata[15:0])
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000029 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=590-592
                     `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000029 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=590-592
                        ;


  // The fetched instruction from ICB rdata bus need to be aligned by PC LSB bits
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000032 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=597-613
  `ifdef E203_HAS_ITCM //{
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000018 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=598-599
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000032 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=597-613
  wire[31:0] ifu2itcm_icb_rsp_instr = 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000031 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=599-612
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000031:br:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=599-600
     `ifdef E203_ITCM_DATA_WIDTH_IS_32 //{
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000018 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=598-599
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000031 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=599-612
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000031:br:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=599-600
                    ifu2itcm_icb_rsp_rdata;
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000031:br:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=599-600
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000031:br:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=599-600
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000031:br:000002 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=601-611
     `else//}{
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000031:br:000002 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=601-611
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000030 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=602-611
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000030:br:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=602-606
        `ifdef E203_ITCM_DATA_WIDTH_IS_64
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000030 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=602-611
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000030:br:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=602-606
                    ({32{icb_cmd_addr_2_1_r == 2'b00}} & ifu2itcm_icb_rsp_rdata[31: 0]) 
                  | ({32{icb_cmd_addr_2_1_r == 2'b01}} & ifu2itcm_icb_rsp_rdata[47:16]) 
                  | ({32{icb_cmd_addr_2_1_r == 2'b10}} & ifu2itcm_icb_rsp_rdata[63:32])
                     ;
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000030:br:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=602-606
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000030:br:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=602-606
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000030:br:000002 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=607-610
        `else//}{
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000030:br:000002 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=607-610
            !!! ERROR: There must be something wrong, we dont support the width 
            other than 32bits and 64bits, leave this message to catch this error by 
            compilation message.
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000030:br:000002 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=607-610
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000030:br:000002 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=607-610
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000030 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=602-611
        `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000030 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=602-611
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000031:br:000002 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=601-611
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000031:br:000002 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=601-611
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000031 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=599-612
     `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000031 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=599-612
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000032 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=597-613
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000032 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=597-613

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000035 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=615-631
  `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000019 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=616-617
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000035 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=615-631
  wire[31:0] ifu2biu_icb_rsp_instr = 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000034 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=617-630
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000034:br:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=617-618
     `ifdef E203_SYSMEM_DATA_WIDTH_IS_32 //{
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000019 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=616-617
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000034 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=617-630
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000034:br:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=617-618
                    ifu2biu_icb_rsp_rdata;
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000034:br:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=617-618
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000034:br:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=617-618
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000034:br:000002 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=619-629
     `else//}{
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000034:br:000002 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=619-629
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000033 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=620-629
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000033:br:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=620-624
        `ifdef E203_SYSMEM_DATA_WIDTH_IS_64//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000033 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=620-629
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000033:br:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=620-624
                    ({32{icb_cmd_addr_2_1_r == 2'b00}} & ifu2biu_icb_rsp_rdata[31: 0]) 
                    ({32{icb_cmd_addr_2_1_r == 2'b01}} & ifu2biu_icb_rsp_rdata[47:16]) 
                    ({32{icb_cmd_addr_2_1_r == 2'b10}} & ifu2biu_icb_rsp_rdata[63:32])
                     ;
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000033:br:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=620-624
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000033:br:000001 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=620-624
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000033:br:000002 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=625-628
        `else//}{
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000033:br:000002 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=625-628
            !!! ERROR: There must be something wrong, we dont support the width 
            other than 32bits and 64bits, leave this message to catch this error by 
            compilation message.
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000033:br:000002 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=625-628
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000033:br:000002 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=625-628
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000033 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=620-629
        `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000033 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=620-629
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000034:br:000002 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=619-629
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000034:br:000002 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=619-629
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000034 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=617-630
     `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000034 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=617-630
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000035 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=615-631
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000035 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=615-631

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000020 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=633-634
  wire [32-1:0] ifu_icb_rsp_instr = 32'b0
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000036 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=634-636
                     `ifdef E203_HAS_ITCM //{
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000020 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=633-634
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000036 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=634-636
                       | ({32{icb_cmd2itcm_r}} & ifu2itcm_icb_rsp_instr)
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000036 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=634-636
                     `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000036 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=634-636
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000037 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=637-639
                     `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000037 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=637-639
                       | ({32{icb_cmd2biu_r}}  & ifu2biu_icb_rsp_instr)
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000037 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=637-639
                     `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000037 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=637-639
                        ;

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000021 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=642-643
  wire ifu_icb_rsp_err = 1'b0
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000038 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=643-645
                     `ifdef E203_HAS_ITCM //{
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000021 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=642-643
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000038 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=643-645
                       | (icb_cmd2itcm_r & ifu2itcm_icb_rsp_err)
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000038 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=643-645
                     `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000038 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=643-645
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000039 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=646-648
                     `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000039 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=646-648
                       | (icb_cmd2biu_r  & ifu2biu_icb_rsp_err)
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000039 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=646-648
                     `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000039 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=646-648
                        ;

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:assign_cluster:000005 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=651-656
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000016 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=651-653
  assign i_ifu_rsp_instr = 
              ({32{rsp_instr_sel_leftover}} & {ifu_icb_rsp_rdata_lsb16, leftover_r})
            | ({32{rsp_instr_sel_icb_rsp }} & ifu_icb_rsp_instr);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000016 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=651-653
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000017 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=654-656
  assign i_ifu_rsp_err = 
              (rsp_instr_sel_leftover & (|{ifu_icb_rsp_err, leftover_err_r}))
            | (rsp_instr_sel_icb_rsp  & ifu_icb_rsp_err);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000017 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=654-656
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:assign_cluster:000005 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=651-656
  ////If the response is to leftover, it is always can be accepted,
  ////  so there is no chance to turn over the value, and no need 
  ////  to replay, but the data from the response channel (from
  ////  ITCM) may be turned over, so need to be replayed
  //wire ifu_icb_rsp_replay;
  //assign ifu_rsp_replay = 
  //            (rsp_instr_sel_leftover & (|{ifu_icb_rsp_replay, 1'b0}))
  //          | (rsp_instr_sel_icb_rsp  & ifu_icb_rsp_replay);
            
  // The ifetch response valid will have 2 sources
  //    Source #1: Did not issue ICB CMD request, and just use last holdup values, then
  //               we generate a fake response valid
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000022 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=669-669
  wire holdup_gen_fake_rsp_valid = icb_sta_is_1st & req_need_0uop_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000022 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=669-669
  //    Source #2: Did issue ICB CMD request, use ICB response valid. But not each response
  //               valid will be sent to ifetch-response. The ICB response data will put 
  //               into the leftover buffer when:
  //                    It need two uops and itf-state is in 1ST stage (the leftover
  //                    buffer is always ready to accept this)
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000018 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=675-675
  assign ifu_icb_rsp2leftover = req_need_2uop_r & icb_sta_is_1st;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000018 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=675-675
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000023 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=676-678
  wire ifu_icb_rsp2ir_ready;

  wire ifu_icb_rsp2ir_valid = ifu_icb_rsp2leftover ? 1'b0 : ifu_icb_rsp_valid;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000023 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=676-678
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:assign_cluster:000006 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=679-683
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:bus_cluster:000002 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=679-683
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:handshake:000002 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=679-683
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000019 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=679-679
  assign ifu_icb_rsp_ready  = ifu_icb_rsp2leftover ? 1'b1 : ifu_icb_rsp2ir_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000019 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=679-679
  //

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000020 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=682-682
  assign i_ifu_rsp_valid = holdup_gen_fake_rsp_valid | ifu_icb_rsp2ir_valid;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000020 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=682-682
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000021 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=683-683
  assign ifu_icb_rsp2ir_ready = i_ifu_rsp_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000021 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=683-683
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:assign_cluster:000006 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=679-683
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:bus_cluster:000002 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=679-683
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:handshake:000002 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=679-683


  /////////////////////////////////////////////////////////////////////////////////
  // Generate the ICB response channel
  //
  // The ICB response valid to ifetch generated in two cases:
  //    * Case #1: The itf need two uops, and it is in 2ND state response
  //    * Case #2: The itf need only one uop, and it is in 1ND state response
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000022 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=692-699
  assign ifu_icb_rsp_valid = 1'b0
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000040 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=693-695
                     `ifdef E203_HAS_ITCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000040 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=693-695
                       | (icb_cmd2itcm_r & ifu2itcm_icb_rsp_valid)
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000040 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=693-695
                     `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000040 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=693-695
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000041 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=696-698
                     `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000041 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=696-698
                       | (icb_cmd2biu_r  & ifu2biu_icb_rsp_valid)
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000041 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=696-698
                     `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000041 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=696-698
                        ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000022 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=692-699
 
   //  //   Explain the performance impacts
   //  //      because there is a over killing, that the very 1st time ifu to access ITCM it actually
   //  //      does not need to be replayed, but it just did replay becuase the holdup is not set but we dont care
   //assign ifu_icb_rsp_replay = 1'b0
   //                  `ifdef E203_HAS_ITCM //{
   //                    | (icb_cmd2itcm_r & ifu2itcm_replay)
   //                  `endif//}
   //                  `ifdef E203_HAS_MEM_ITF //{
   //                    | (icb_cmd2biu_r & ifu2biu_replay)
   //                  `endif//}
   //                     ;

  /////////////////////////////////////////////////////////////////////////////////
  // Generate the ICB command channel
  //
  // The ICB cmd valid will be generated in two cases:
  //   * Case #1: When the new ifetch-request is coming, and it is not "need zero 
  //              uops"
  //   * Case #2: When the ongoing ifetch is "need 2 uops", and:
  //                ** itf-state is in 1ST state and its response is handshaking (about
  //                    to finish the 1ST state)
  //                ** or it is already in WAIT2ND state
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000024 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=723-723
  wire ifu_req_valid_pos;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000024 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=723-723
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000023 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=724-733
  assign ifu_icb_cmd_valid = 
                   (ifu_req_valid_pos & (~req_need_0uop))
                 | ( 
                     req_need_2uop_r &
                     (
                         ((icb_sta_is_1st & ifu_icb_rsp_hsked)
                       |  icb_sta_is_wait2nd)
                     )
                   ) 
                     ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000023 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=724-733
                     
  // The ICB cmd address will be generated in 3 cases:
  //   * Case #1: Use next lane-aligned address, when 
  //                 ** It is same-cross-holdup case for 1st uop
  //                 The next-lane-aligned address can be generated by 
  //                 current request-PC plus 16bits. To optimize the
  //                 timing, we try to use last-fetched-PC (flop clean)
  //                 to caculate. So we caculate it by 
  //                 last-fetched-PC (flopped value pc_r) truncated
  //                 with lane-offset and plus a lane siz
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000025 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=744-750
  wire icb_addr_sel_1stnxtalgn = holdup2leftover_sel;
  //
  //   * Case #2: Use next lane-aligned address, when
  //                 ** It need 2 uops, and it is 1ST or WAIT2ND stage
  //                 The next-lane-aligned address can be generated by
  //                 last request-PC plus 16bits. 
  wire icb_addr_sel_2ndnxtalgn = req_need_2uop_r &
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000025 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=744-750
                     (
                          icb_sta_is_1st 
                       |  icb_sta_is_wait2nd
                     );
  //
  //   * Case #3: Use current ifetch address in 1st uop, when 
  //                 ** It is not above two cases
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000026 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=758-760
  wire icb_addr_sel_cur = (~icb_addr_sel_1stnxtalgn) & (~icb_addr_sel_2ndnxtalgn);

  wire [`E203_PC_SIZE-1:0] nxtalgn_plus_offset = 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000026 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=758-760
               icb_addr_sel_2ndnxtalgn ? `E203_PC_SIZE'd2 :
               ifu_req_seq_rv32        ? `E203_PC_SIZE'd6 :
                                         `E203_PC_SIZE'd4;
  // Since we always fetch 32bits
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000027 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=765-765
  wire [`E203_PC_SIZE-1:0] icb_algn_nxt_lane_addr = ifu_req_last_pc + nxtalgn_plus_offset;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000027 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=765-765

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000024 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=767-769
  assign ifu_icb_cmd_addr = 
      ({`E203_PC_SIZE{icb_addr_sel_1stnxtalgn | icb_addr_sel_2ndnxtalgn}} & icb_algn_nxt_lane_addr)
    | ({`E203_PC_SIZE{icb_addr_sel_cur}} & ifu_req_pc);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000024 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=767-769

  /////////////////////////////////////////////////////////////////////////////////
  // Generate the ifetch req channel ready signal
  //
  // Ifu req channel will be ready when the ICB CMD channel is ready and 
  //    * the itf-state is idle
  //    * or only need zero or one uop, and in 1ST state response is backing
  //    * or need two uops, and in 2ND state response is backing
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000028 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=778-778
  wire ifu_req_ready_condi = 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000028 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=778-778
                (
                    icb_sta_is_idle 
                  | ((~req_need_2uop_r) & icb_sta_is_1st & i_ifu_rsp_hsked)
                  | (  req_need_2uop_r  & icb_sta_is_2nd & i_ifu_rsp_hsked) 
                );
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:assign_cluster:000007 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=784-785
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:handshake:000003 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=784-785
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000025 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=784-784
  assign ifu_req_ready     = ifu_icb_cmd_ready & ifu_req_ready_condi; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000025 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=784-784
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000026 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=785-785
  assign ifu_req_valid_pos = ifu_req_valid     & ifu_req_ready_condi; // Handshake valid
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000026 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=785-785
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:assign_cluster:000007 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=784-785
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:handshake:000003 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=784-785




  ///////////////////////////////////////////////////////
  // Dispatch the ICB CMD and RSP Channel to ITCM and System Memory
  //   according to the address range
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000042 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=793-800
  `ifdef E203_HAS_ITCM //{
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:assign_cluster:000008 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=794-799
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:bus_cluster:000003 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=794-799
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000042 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=793-800
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000027 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=794-794
  assign ifu_icb_cmd2itcm = (ifu_icb_cmd_addr[`E203_ITCM_BASE_REGION] == itcm_region_indic[`E203_ITCM_BASE_REGION]);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000027 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=794-794

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000028 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=796-796
  assign ifu2itcm_icb_cmd_valid = ifu_icb_cmd_valid & ifu_icb_cmd2itcm;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000028 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=796-796
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000029 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=797-797
  assign ifu2itcm_icb_cmd_addr = ifu_icb_cmd_addr[`E203_ITCM_ADDR_WIDTH-1:0];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000029 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=797-797

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000030 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=799-799
  assign ifu2itcm_icb_rsp_ready = ifu_icb_rsp_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000030 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=799-799
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:assign_cluster:000008 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=794-799
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:bus_cluster:000003 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=794-799
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000042 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=793-800
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000042 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=793-800

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000044 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=802-814
  `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000044 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=802-814
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000031 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=803-807
  assign ifu_icb_cmd2biu = 1'b1
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000043 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=804-806
            `ifdef E203_HAS_ITCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000043 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=804-806
              & ~(ifu_icb_cmd2itcm)
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000043 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=804-806
            `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000043 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=804-806
              ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000031 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=803-807
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000029 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=808-809
  wire ifu2biu_icb_cmd_valid_pre  = ifu_icb_cmd_valid & ifu_icb_cmd2biu;
  wire [`E203_ADDR_SIZE-1:0]   ifu2biu_icb_cmd_addr_pre = ifu_icb_cmd_addr[`E203_ADDR_SIZE-1:0];
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000029 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=808-809

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000032 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=811-811
  assign ifu2biu_icb_rsp_ready = ifu_icb_rsp_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000032 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=811-811

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000030 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=813-814
  wire ifu2biu_icb_cmd_ready_pre;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000044 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=802-814
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000044 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=802-814
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:internal_signal:000030 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=813-814

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000033 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=816-823
  assign ifu_icb_cmd_ready = 1'b0
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000045 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=817-819
    `ifdef E203_HAS_ITCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000045 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=817-819
        | (ifu_icb_cmd2itcm & ifu2itcm_icb_cmd_ready) 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000045 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=817-819
    `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000045 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=817-819
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000046 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=820-822
    `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000046 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=820-822
        | (ifu_icb_cmd2biu  & ifu2biu_icb_cmd_ready_pre ) 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000046 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=820-822
    `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000046 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=820-822
        ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000033 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=816-823

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000047 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=825-852
    `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000047 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=825-852
  //sirv_gnrl_pipe_stage # (
  //      // We must not cut ready, otherwise it cannot accept ifetch back-to-back,
  //      //   and then when the external bus is 0 cycle response, it will trigger 
  //      //   the replay scheme time by time, and never end, endup with a deadlock replay
  //      .CUT_READY (0),
  //      // We must have this stage and configure DP as 1, otherwise the BIU only 
  //      //   have 1 DP entry stage and with CUT_READY=1, and then when the external bus 
  //      //   is 0 cycle response, it will trigger the replay scheme time by time,
  //      //   and never end, endup with a deadlock replay
  //      .DP  (1),
  //      .DW  (`E203_ADDR_SIZE)
  //    ) u_e203_ifu2biu_cmd_stage (
  //      .i_vld(ifu2biu_icb_cmd_valid_pre),
  //      .i_rdy(ifu2biu_icb_cmd_ready_pre),
  //      .i_dat(ifu2biu_icb_cmd_addr_pre),
  //      .o_vld(ifu2biu_icb_cmd_valid),
  //      .o_rdy(ifu2biu_icb_cmd_ready),  
  //      .o_dat(ifu2biu_icb_cmd_addr),
  //    
  //      .clk  (clk),
  //      .rst_n(rst_n)
  //    );

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:assign_cluster:000009 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=849-851
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:bus_cluster:000004 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=849-851
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000034 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=849-849
     assign ifu2biu_icb_cmd_addr      = ifu2biu_icb_cmd_addr_pre;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000034 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=849-849
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:handshake:000004 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=850-851
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000035 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=850-850
     assign ifu2biu_icb_cmd_valid     = ifu2biu_icb_cmd_valid_pre;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000035 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=850-850
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000036 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=851-851
     assign ifu2biu_icb_cmd_ready_pre = ifu2biu_icb_cmd_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:assign:000036 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=851-851
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:handshake:000004 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=850-851
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:assign_cluster:000009 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=849-851
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:grp:bus_cluster:000004 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=849-851
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000047 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=825-852
    `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v:pp_blk:000047 file=e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v lines=825-852


endmodule

