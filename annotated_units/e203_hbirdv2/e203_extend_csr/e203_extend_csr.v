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
//  This module to implement the extended CSR
//    current this is an empty module, user can hack it 
//    become a real one if they want
//
//
// ====================================================================
`include "e203_defines.v"

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_extend_csr/e203_extend_csr.v:pp_blk:000001 file=e203_hbirdv2/e203_extend_csr/e203_extend_csr.v lines=31-52
`ifdef E203_HAS_CSR_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_extend_csr/e203_extend_csr.v:pp_blk:000001 file=e203_hbirdv2/e203_extend_csr/e203_extend_csr.v lines=31-52
module e203_extend_csr(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/e203_extend_csr/e203_extend_csr.v:grp:port_section:000001 file=e203_hbirdv2/e203_extend_csr/e203_extend_csr.v lines=33-44

  // The Handshake Interface 
  input          nice_csr_valid,
  output         nice_csr_ready,

  input   [31:0] nice_csr_addr,
  input          nice_csr_wr,
  input   [31:0] nice_csr_wdata,
  output  [31:0] nice_csr_rdata,

  input  clk,
  input  rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/e203_extend_csr/e203_extend_csr.v:grp:port_section:000001 file=e203_hbirdv2/e203_extend_csr/e203_extend_csr.v lines=33-44
  );

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_extend_csr/e203_extend_csr.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_extend_csr/e203_extend_csr.v lines=47-48
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_extend_csr/e203_extend_csr.v:assign:000001 file=e203_hbirdv2/e203_extend_csr/e203_extend_csr.v lines=47-47
  assign nice_csr_ready = 1'b1;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_extend_csr/e203_extend_csr.v:assign:000001 file=e203_hbirdv2/e203_extend_csr/e203_extend_csr.v lines=47-47
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_extend_csr/e203_extend_csr.v:assign:000002 file=e203_hbirdv2/e203_extend_csr/e203_extend_csr.v lines=48-48
  assign nice_csr_rdata = 32'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_extend_csr/e203_extend_csr.v:assign:000002 file=e203_hbirdv2/e203_extend_csr/e203_extend_csr.v lines=48-48
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_extend_csr/e203_extend_csr.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_extend_csr/e203_extend_csr.v lines=47-48


endmodule
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_extend_csr/e203_extend_csr.v:pp_blk:000001 file=e203_hbirdv2/e203_extend_csr/e203_extend_csr.v lines=31-52
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_extend_csr/e203_extend_csr.v:pp_blk:000001 file=e203_hbirdv2/e203_extend_csr/e203_extend_csr.v lines=31-52
