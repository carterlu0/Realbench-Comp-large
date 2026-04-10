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
//  The mini-decode module to decode the instruction in IFU 
//
// ====================================================================
`include "e203_defines.v"

module e203_ifu_minidec(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/e203_ifu_minidec/e203_ifu_minidec.v:grp:port_section:000001 file=e203_hbirdv2/e203_ifu_minidec/e203_ifu_minidec.v lines=29-57

  //////////////////////////////////////////////////////////////
  // The IR stage to Decoder
  input  [`E203_INSTR_SIZE-1:0] instr,
  
  //////////////////////////////////////////////////////////////
  // The Decoded Info-Bus


  output dec_rs1en,
  output dec_rs2en,
  output [`E203_RFIDX_WIDTH-1:0] dec_rs1idx,
  output [`E203_RFIDX_WIDTH-1:0] dec_rs2idx,

  output dec_mulhsu,
  output dec_mul   ,
  output dec_div   ,
  output dec_rem   ,
  output dec_divu  ,
  output dec_remu  ,

  output dec_rv32,
  output dec_bjp,
  output dec_jal,
  output dec_jalr,
  output dec_bxx,
  output [`E203_RFIDX_WIDTH-1:0] dec_jalr_rs1idx,
  output [`E203_XLEN-1:0] dec_bjp_imm 

//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/e203_ifu_minidec/e203_ifu_minidec.v:grp:port_section:000001 file=e203_hbirdv2/e203_ifu_minidec/e203_ifu_minidec.v lines=29-57
  );

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_ifu_minidec/e203_ifu_minidec.v:inst:000001 file=e203_hbirdv2/e203_ifu_minidec/e203_ifu_minidec.v lines=60-109
  e203_exu_decode u_e203_exu_decode(

  .i_instr(instr),
  .i_pc(`E203_PC_SIZE'b0),
  .i_prdt_taken(1'b0), 
  .i_muldiv_b2b(1'b0), 

  .i_misalgn (1'b0),
  .i_buserr  (1'b0),

  .dbg_mode  (1'b0),

  .dec_misalgn(),
  .dec_buserr(),
  .dec_ilegl(),

  .dec_rs1x0(),
  .dec_rs2x0(),
  .dec_rs1en(dec_rs1en),
  .dec_rs2en(dec_rs2en),
  .dec_rdwen(),
  .dec_rs1idx(dec_rs1idx),
  .dec_rs2idx(dec_rs2idx),
  .dec_rdidx(),
  .dec_info(),  
  .dec_imm(),
  .dec_pc(),

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_minidec/e203_ifu_minidec.v:pp_blk:000001 file=e203_hbirdv2/e203_ifu_minidec/e203_ifu_minidec.v lines=88-92
`ifdef E203_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_minidec/e203_ifu_minidec.v:pp_blk:000001 file=e203_hbirdv2/e203_ifu_minidec/e203_ifu_minidec.v lines=88-92
  .dec_nice   (),
  .nice_xs_off(1'b0),  
  .nice_cmt_off_ilgl_o(),
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_minidec/e203_ifu_minidec.v:pp_blk:000001 file=e203_hbirdv2/e203_ifu_minidec/e203_ifu_minidec.v lines=88-92
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_ifu_minidec/e203_ifu_minidec.v:pp_blk:000001 file=e203_hbirdv2/e203_ifu_minidec/e203_ifu_minidec.v lines=88-92

  .dec_mulhsu(dec_mulhsu),
  .dec_mul   (dec_mul   ),
  .dec_div   (dec_div   ),
  .dec_rem   (dec_rem   ),
  .dec_divu  (dec_divu  ),
  .dec_remu  (dec_remu  ),

  .dec_rv32(dec_rv32),
  .dec_bjp (dec_bjp ),
  .dec_jal (dec_jal ),
  .dec_jalr(dec_jalr),
  .dec_bxx (dec_bxx ),

  .dec_jalr_rs1idx(dec_jalr_rs1idx),
  .dec_bjp_imm    (dec_bjp_imm    )  
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_ifu_minidec/e203_ifu_minidec.v:inst:000001 file=e203_hbirdv2/e203_ifu_minidec/e203_ifu_minidec.v lines=60-109


endmodule
