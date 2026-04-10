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
//  The Commit module to commit instructions or flush pipeline
//
// ====================================================================


`include "e203_defines.v"

module e203_exu_commit(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=32-148
  output  commit_mret,
  output  commit_trap,
  output  core_wfi,
  output  nonflush_cmt_ena,

  output  excp_active,

  input   amo_wait,

  output  wfi_halt_ifu_req,
  output  wfi_halt_exu_req,
  input   wfi_halt_ifu_ack,
  input   wfi_halt_exu_ack,

  input  dbg_irq_r,
  input  [`E203_LIRQ_NUM-1:0] lcl_irq_r,
  input  ext_irq_r,
  input  sft_irq_r,
  input  tmr_irq_r,
  input  [`E203_EVT_NUM-1:0] evt_r,

  input   status_mie_r,
  input   mtie_r,
  input   msie_r,
  input   meie_r,

  input                      alu_cmt_i_valid,
  output                     alu_cmt_i_ready,
  input  [`E203_PC_SIZE-1:0] alu_cmt_i_pc,  
  input  [`E203_INSTR_SIZE-1:0] alu_cmt_i_instr,  
  input                      alu_cmt_i_pc_vld,  
  input  [`E203_XLEN-1:0]    alu_cmt_i_imm,
  input                      alu_cmt_i_rv32,
    //   The Branch Commit
  input                      alu_cmt_i_bjp,
  input                      alu_cmt_i_wfi,
  input                      alu_cmt_i_fencei,
  input                      alu_cmt_i_mret,
  input                      alu_cmt_i_dret,
  input                      alu_cmt_i_ecall,
  input                      alu_cmt_i_ebreak,
  input                      alu_cmt_i_ifu_misalgn ,
  input                      alu_cmt_i_ifu_buserr ,
  input                      alu_cmt_i_ifu_ilegl ,
  input                      alu_cmt_i_bjp_prdt,// The predicted ture/false  
  input                      alu_cmt_i_bjp_rslv,// The resolved ture/false
    //   The AGU Exception 
  input                      alu_cmt_i_misalgn, // The misalign exception generated
  input                      alu_cmt_i_ld,
  input                      alu_cmt_i_stamo,
  input                      alu_cmt_i_buserr , // The bus-error exception generated
  input [`E203_ADDR_SIZE-1:0]alu_cmt_i_badaddr,
  
  output  [`E203_ADDR_SIZE-1:0] cmt_badaddr,
  output  cmt_badaddr_ena,
  output  [`E203_PC_SIZE-1:0] cmt_epc,
  output  cmt_epc_ena,
  output  [`E203_XLEN-1:0] cmt_cause,
  output  cmt_cause_ena,
  output  cmt_instret_ena,
  output  cmt_status_ena,

  output  [`E203_PC_SIZE-1:0] cmt_dpc,
  output  cmt_dpc_ena,
  output  [3-1:0] cmt_dcause,
  output  cmt_dcause_ena,

  output                     cmt_mret_ena,

  input [`E203_PC_SIZE-1:0]  csr_epc_r,
  input [`E203_PC_SIZE-1:0]  csr_dpc_r,
  input [`E203_XLEN-1:0]     csr_mtvec_r,

  input   dbg_mode,
  input   dbg_halt_r,
  input   dbg_step_r,
  input   dbg_ebreakm_r,


  input   oitf_empty,
  
  input   u_mode,
  input   s_mode,
  input   h_mode,
  input   m_mode,

  output                     longp_excp_i_ready,
  input                      longp_excp_i_valid,
  input                      longp_excp_i_ld,
  input                      longp_excp_i_st,
  input                      longp_excp_i_buserr , // The load/store bus-error exception generated
  input [`E203_ADDR_SIZE-1:0]longp_excp_i_badaddr,
  input                      longp_excp_i_insterr,
  input [`E203_PC_SIZE-1:0]  longp_excp_i_pc,

  //////////////////////////////////////////////////////////////
  // The Flush interface to IFU
  //
  //   To save the gatecount, when we need to flush pipeline with new PC, 
  //     we want to reuse the adder in IFU, so we will not pass flush-PC
  //     to IFU, instead, we pass the flush-pc-adder-op1/op2 to IFU
  //     and IFU will just use its adder to caculate the flush-pc-adder-result
  //
  output  flush_pulse,
       // To cut the combinational loop, we need this flush_req from non-alu source to flush ALU pipeline (e.g., MUL-div statemachine)
  output  flush_req,

  input   pipe_flush_ack,
  output  pipe_flush_req,
  output  [`E203_PC_SIZE-1:0] pipe_flush_add_op1,  
  output  [`E203_PC_SIZE-1:0] pipe_flush_add_op2,  
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=143-145
  `ifdef E203_TIMING_BOOST//}
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=143-145
  output  [`E203_PC_SIZE-1:0] pipe_flush_pc,  
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=143-145
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=143-145

  input  clk,
  input  rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=32-148
  );


//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=152-163
  wire                      alu_brchmis_flush_ack;
  wire                      alu_brchmis_flush_req;
  wire  [`E203_PC_SIZE-1:0] alu_brchmis_flush_add_op1;  
  wire  [`E203_PC_SIZE-1:0] alu_brchmis_flush_add_op2;
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=156-158
  `ifdef E203_TIMING_BOOST//}
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=156-158
  wire [`E203_PC_SIZE-1:0] alu_brchmis_flush_pc;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=156-158
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=156-158
  wire                      alu_brchmis_cmt_i_ready;

  wire                      cmt_dret_ena;

  wire nonalu_excpirq_flush_req_raw;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=152-163

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:inst:000001 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=165-196
  e203_exu_branchslv u_e203_exu_branchslv(
    .cmt_i_ready             (alu_brchmis_cmt_i_ready    ),
    .cmt_i_valid             (alu_cmt_i_valid   ),  
    .cmt_i_rv32              (alu_cmt_i_rv32    ),  
    .cmt_i_bjp               (alu_cmt_i_bjp     ),  
    .cmt_i_fencei            (alu_cmt_i_fencei  ),
    .cmt_i_mret              (alu_cmt_i_mret     ),
    .cmt_i_dret              (alu_cmt_i_dret     ),
    .cmt_i_bjp_prdt          (alu_cmt_i_bjp_prdt),
    .cmt_i_bjp_rslv          (alu_cmt_i_bjp_rslv),
    .cmt_i_pc                (alu_cmt_i_pc      ),
    .cmt_i_imm               (alu_cmt_i_imm     ),
                         
    .cmt_mret_ena            (cmt_mret_ena       ),
    .cmt_dret_ena            (cmt_dret_ena       ),
    .cmt_fencei_ena          (),
    .csr_epc_r               (csr_epc_r         ),
    .csr_dpc_r               (csr_dpc_r         ),


    .nonalu_excpirq_flush_req_raw(nonalu_excpirq_flush_req_raw ),
    .brchmis_flush_ack       (alu_brchmis_flush_ack    ),
    .brchmis_flush_req       (alu_brchmis_flush_req    ),
    .brchmis_flush_add_op1   (alu_brchmis_flush_add_op1),  
    .brchmis_flush_add_op2   (alu_brchmis_flush_add_op2),  
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=190-192
  `ifdef E203_TIMING_BOOST//}
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=190-192
    .brchmis_flush_pc        (alu_brchmis_flush_pc),  
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=190-192
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=190-192

    .clk   (clk  ),
    .rst_n (rst_n)
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:inst:000001 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=165-196

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=198-208
  wire excpirq_flush_ack;
  wire excpirq_flush_req;
  wire [`E203_PC_SIZE-1:0] excpirq_flush_add_op1;  
  wire [`E203_PC_SIZE-1:0] excpirq_flush_add_op2;
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:pp_blk:000004 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=202-204
  `ifdef E203_TIMING_BOOST//}
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:pp_blk:000004 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=202-204
  wire [`E203_PC_SIZE-1:0] excpirq_flush_pc;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:pp_blk:000004 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=202-204
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:pp_blk:000004 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=202-204
  wire [`E203_XLEN-1:0] excpirq_cause;
  wire alu_excp_cmt_i_ready;

  wire cmt_ena;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=198-208


//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:inst:000002 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=211-300
  e203_exu_excp u_e203_exu_excp(
    .commit_trap           (commit_trap     ),
    .core_wfi              (core_wfi        ),
    .wfi_halt_ifu_req      (wfi_halt_ifu_req),
    .wfi_halt_exu_req      (wfi_halt_exu_req),
    .wfi_halt_ifu_ack      (wfi_halt_ifu_ack),
    .wfi_halt_exu_ack      (wfi_halt_exu_ack),

    .cmt_badaddr           (cmt_badaddr    ), 
    .cmt_badaddr_ena       (cmt_badaddr_ena),
    .cmt_epc               (cmt_epc        ),
    .cmt_epc_ena           (cmt_epc_ena    ),
    .cmt_cause             (cmt_cause      ),
    .cmt_cause_ena         (cmt_cause_ena  ),
    .cmt_status_ena        (cmt_status_ena ),
                           
    .cmt_dpc               (cmt_dpc        ),
    .cmt_dpc_ena           (cmt_dpc_ena    ),
    .cmt_dcause            (cmt_dcause     ),
    .cmt_dcause_ena        (cmt_dcause_ena ),

    .cmt_dret_ena          (cmt_dret_ena   ),
    .cmt_ena               (cmt_ena        ),

    .alu_excp_i_valid      (alu_cmt_i_valid  ),
    .alu_excp_i_ready      (alu_excp_cmt_i_ready    ),
    .alu_excp_i_misalgn    (alu_cmt_i_misalgn),
    .alu_excp_i_ld         (alu_cmt_i_ld     ),
    .alu_excp_i_stamo      (alu_cmt_i_stamo  ),
    .alu_excp_i_buserr     (alu_cmt_i_buserr ),
    .alu_excp_i_pc         (alu_cmt_i_pc     ),
    .alu_excp_i_instr      (alu_cmt_i_instr  ),
    .alu_excp_i_pc_vld     (alu_cmt_i_pc_vld ),
    .alu_excp_i_badaddr    (alu_cmt_i_badaddr ),
    .alu_excp_i_ecall      (alu_cmt_i_ecall   ),
    .alu_excp_i_ebreak     (alu_cmt_i_ebreak  ),
    .alu_excp_i_wfi        (alu_cmt_i_wfi  ),
    .alu_excp_i_ifu_misalgn(alu_cmt_i_ifu_misalgn),
    .alu_excp_i_ifu_buserr (alu_cmt_i_ifu_buserr ),
    .alu_excp_i_ifu_ilegl  (alu_cmt_i_ifu_ilegl  ),
                         
    .longp_excp_i_ready    (longp_excp_i_ready  ),
    .longp_excp_i_valid    (longp_excp_i_valid  ),
    .longp_excp_i_ld       (longp_excp_i_ld     ),
    .longp_excp_i_st       (longp_excp_i_st     ),
    .longp_excp_i_buserr   (longp_excp_i_buserr ),
    .longp_excp_i_badaddr  (longp_excp_i_badaddr),
    .longp_excp_i_insterr  (longp_excp_i_insterr),
    .longp_excp_i_pc       (longp_excp_i_pc     ),

    .csr_mtvec_r           (csr_mtvec_r       ),

    .dbg_irq_r             (dbg_irq_r),
    .lcl_irq_r             (lcl_irq_r),
    .ext_irq_r             (ext_irq_r),
    .sft_irq_r             (sft_irq_r),
    .tmr_irq_r             (tmr_irq_r),

    .status_mie_r          (status_mie_r),
    .mtie_r                (mtie_r      ),
    .msie_r                (msie_r      ),
    .meie_r                (meie_r      ),


    .dbg_mode              (dbg_mode),
    .dbg_halt_r            (dbg_halt_r),
    .dbg_step_r            (dbg_step_r),
    .dbg_ebreakm_r         (dbg_ebreakm_r),
    .oitf_empty            (oitf_empty),

    .u_mode                (u_mode),
    .s_mode                (s_mode),
    .h_mode                (h_mode),
    .m_mode                (m_mode),

    .excpirq_flush_ack        (excpirq_flush_ack       ),
    .excpirq_flush_req        (excpirq_flush_req       ),
    .nonalu_excpirq_flush_req_raw (nonalu_excpirq_flush_req_raw ),
    .excpirq_flush_add_op1    (excpirq_flush_add_op1),  
    .excpirq_flush_add_op2    (excpirq_flush_add_op2),  
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:pp_blk:000005 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=291-293
  `ifdef E203_TIMING_BOOST//}
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:pp_blk:000005 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=291-293
    .excpirq_flush_pc         (excpirq_flush_pc),
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:pp_blk:000005 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=291-293
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:pp_blk:000005 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=291-293

    .excp_active (excp_active),
    .amo_wait (amo_wait),

    .clk   (clk  ),
    .rst_n (rst_n)
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:inst:000002 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=211-300

 

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=304-312
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:grp:handshake:000001 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=304-312
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:assign:000001 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=304-304
  assign excpirq_flush_ack = pipe_flush_ack;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:assign:000001 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=304-304
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:assign:000002 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=305-305
  assign alu_brchmis_flush_ack = pipe_flush_ack;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:assign:000002 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=305-305

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:assign:000003 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=307-307
  assign pipe_flush_req = excpirq_flush_req | alu_brchmis_flush_req;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:assign:000003 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=307-307
            
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:assign:000004 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=309-309
  assign alu_cmt_i_ready = alu_excp_cmt_i_ready & alu_brchmis_cmt_i_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:assign:000004 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=309-309

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:assign:000005 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=311-311
  assign pipe_flush_add_op1 = excpirq_flush_req ? excpirq_flush_add_op1 : alu_brchmis_flush_add_op1;  
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:assign:000005 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=311-311
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:assign:000006 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=312-312
  assign pipe_flush_add_op2 = excpirq_flush_req ? excpirq_flush_add_op2 : alu_brchmis_flush_add_op2;  
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:assign:000006 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=312-312
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=304-312
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:grp:handshake:000001 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=304-312
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:pp_blk:000006 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=313-315
  `ifdef E203_TIMING_BOOST//}
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:pp_blk:000006 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=313-315
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:assign:000007 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=314-314
  assign pipe_flush_pc      = excpirq_flush_req ? excpirq_flush_pc : alu_brchmis_flush_pc;  
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:assign:000007 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=314-314
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:pp_blk:000006 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=313-315
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:pp_blk:000006 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=313-315

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=317-327
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:grp:handshake:000002 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=317-325
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:assign:000008 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=317-317
  assign cmt_ena = alu_cmt_i_valid & alu_cmt_i_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:assign:000008 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=317-317
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:assign:000009 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=318-318
  assign cmt_instret_ena = cmt_ena & (~alu_brchmis_flush_req);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:assign:000009 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=318-318

  // Generate the signal as the real-commit enable (non-flush)
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:assign:000010 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=321-321
  assign nonflush_cmt_ena = cmt_ena & (~pipe_flush_req);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:assign:000010 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=321-321


//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:assign:000011 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=324-324
  assign flush_pulse = pipe_flush_ack & pipe_flush_req;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:assign:000011 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=324-324
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:assign:000012 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=325-325
  assign flush_req   = nonalu_excpirq_flush_req_raw;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:assign:000012 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=325-325
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:grp:handshake:000002 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=317-325

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:assign:000013 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=327-327
  assign commit_mret = cmt_mret_ena;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:assign:000013 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=327-327
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=317-327

//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:pp_blk:000008 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=329-336
`ifndef FPGA_SOURCE//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:pp_blk:000008 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=329-336
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:pp_blk:000007 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=330-335
`ifndef DISABLE_SV_ASSERTION//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:pp_blk:000007 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=330-335
//synopsys translate_off


//synopsys translate_on
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:pp_blk:000007 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=330-335
`endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:pp_blk:000007 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=330-335
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:pp_blk:000008 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=329-336
`endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v:pp_blk:000008 file=e203_hbirdv2/e203_exu_commit/e203_exu_commit.v lines=329-336

endmodule                                      
                                               
                                               
                                               
