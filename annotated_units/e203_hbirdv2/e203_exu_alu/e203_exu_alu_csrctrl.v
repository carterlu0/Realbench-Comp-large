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
//  This module to implement the CSR instructions
//
//
// ====================================================================
`include "e203_defines.v"

module e203_exu_alu_csrctrl(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=30-74

  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // The Handshake Interface 
  //
  input  csr_i_valid, // Handshake valid
  output csr_i_ready, // Handshake ready

  input  [`E203_XLEN-1:0] csr_i_rs1,
  input  [`E203_DECINFO_CSR_WIDTH-1:0] csr_i_info,
  input  csr_i_rdwen,   

  output csr_ena,
  output csr_wr_en,
  output csr_rd_en,
  output [12-1:0] csr_idx,

  input  csr_access_ilgl,
  input  [`E203_XLEN-1:0] read_csr_dat,
  output [`E203_XLEN-1:0] wbck_csr_dat,

  
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=52-61
  `ifdef E203_HAS_CSR_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=52-61
  input          nice_xs_off,
  output         csr_sel_nice,
  output         nice_csr_valid,
  input          nice_csr_ready,
  output  [31:0] nice_csr_addr,
  output         nice_csr_wr,
  output  [31:0] nice_csr_wdata,
  input   [31:0] nice_csr_rdata,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=52-61
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=52-61


  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // The CSR Write-back/Commit Interface
  output csr_o_valid, // Handshake valid
  input  csr_o_ready, // Handshake ready
  //   The Write-Back Interface for Special (unaligned ldst and AMO instructions) 
  output [`E203_XLEN-1:0] csr_o_wbck_wdat,
  output csr_o_wbck_err,   

  input  clk,
  input  rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=30-74
  );


//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=78-105
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:pp_blk:000002:br:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=78-98
  `ifdef E203_HAS_CSR_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=78-105
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:pp_blk:000002:br:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=78-98
      // If accessed the NICE CSR range then we need to check if the NICE CSR is ready
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=80-80
  assign csr_sel_nice        = (csr_idx[11:8] == 4'hE);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=80-80
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=81-82
  wire sel_nice            = csr_sel_nice & (~nice_xs_off);
  wire addi_condi         = sel_nice ? nice_csr_ready : 1'b1; 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=81-82

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=84-98
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:grp:bus_cluster:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=84-91
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:grp:handshake:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=84-91
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=84-85
  assign csr_o_valid      = csr_i_valid
                            & addi_condi; // Need to make sure the nice_csr-ready is ready to make sure
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=84-85
                                          //  it can be sent to NICE and O interface same cycle
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=87-88
  assign nice_csr_valid    = sel_nice & csr_i_valid & 
                            csr_o_ready;// Need to make sure the o-ready is ready to make sure
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=87-88
                                        //  it can be sent to NICE and O interface same cycle

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=91-91
  assign csr_i_ready      = sel_nice ? (nice_csr_ready & csr_o_ready) : csr_o_ready; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000004 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=91-91
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:grp:bus_cluster:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=84-91
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:grp:handshake:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=84-91

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=93-93
  assign csr_o_wbck_err   = csr_access_ilgl;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000005 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=93-93
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=94-94
  assign csr_o_wbck_wdat  = sel_nice ? nice_csr_rdata : read_csr_dat;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000006 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=94-94

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=96-96
  assign nice_csr_addr = csr_idx;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000007 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=96-96
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=97-97
  assign nice_csr_wr   = csr_wr_en;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000008 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=97-97
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=98-98
  assign nice_csr_wdata = wbck_csr_dat;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000009 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=98-98
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:pp_blk:000002:br:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=78-98
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:pp_blk:000002:br:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=78-98
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=84-98
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:pp_blk:000002:br:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=99-104
  `else//}{
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=100-100
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:pp_blk:000002:br:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=99-104
  wire   sel_nice      = 1'b0;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=100-100
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=101-104
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:grp:handshake:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=101-102
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000010 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=101-101
  assign csr_o_valid      = csr_i_valid;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000010 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=101-101
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000011 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=102-102
  assign csr_i_ready      = csr_o_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000011 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=102-102
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:grp:handshake:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=101-102
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000012 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=103-103
  assign csr_o_wbck_err   = csr_access_ilgl;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000012 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=103-103
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000013 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=104-104
  assign csr_o_wbck_wdat  = read_csr_dat;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000013 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=104-104
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:pp_blk:000002:br:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=99-104
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:pp_blk:000002:br:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=99-104
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=101-104
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=78-105
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=78-105


//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=108-116
  wire        csrrw  = csr_i_info[`E203_DECINFO_CSR_CSRRW ];
  wire        csrrs  = csr_i_info[`E203_DECINFO_CSR_CSRRS ];
  wire        csrrc  = csr_i_info[`E203_DECINFO_CSR_CSRRC ];
  wire        rs1imm = csr_i_info[`E203_DECINFO_CSR_RS1IMM];
  wire        rs1is0 = csr_i_info[`E203_DECINFO_CSR_RS1IS0];
  wire [4:0]  zimm   = csr_i_info[`E203_DECINFO_CSR_ZIMMM ];
  wire [11:0] csridx = csr_i_info[`E203_DECINFO_CSR_CSRIDX];

  wire [`E203_XLEN-1:0] csr_op1 = rs1imm ? {27'b0,zimm} : csr_i_rs1;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=108-116

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=118-135
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:grp:handshake:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=118-126
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000014 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=118-122
  assign csr_rd_en = csr_i_valid & 
    (
      (csrrw ? csr_i_rdwen : 1'b0) // the CSRRW only read when the destination reg need to be writen
      | csrrs | csrrc // The set and clear operation always need to read CSR
     );
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000014 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=118-122
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000015 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=123-126
  assign csr_wr_en = csr_i_valid & (
                csrrw // CSRRW always write the original RS1 value into the CSR
               | ((csrrs | csrrc) & (~rs1is0)) // for CSRRS/RC, if the RS is x0, then should not really write                                        
            );                                                                           
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000015 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=123-126
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:grp:handshake:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=118-126
                                                                                         
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000016 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=128-128
  assign csr_idx = csridx;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000016 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=128-128

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000017 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=130-130
  assign csr_ena = csr_o_valid & csr_o_ready & (~sel_nice);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000017 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=130-130

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000018 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=132-135
  assign wbck_csr_dat = 
              ({`E203_XLEN{csrrw}} & csr_op1)
            | ({`E203_XLEN{csrrs}} & (  csr_op1  | read_csr_dat))
            | ({`E203_XLEN{csrrc}} & ((~csr_op1) & read_csr_dat));
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:assign:000018 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=132-135
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_exu_alu/e203_exu_alu_csrctrl.v lines=118-135

endmodule
