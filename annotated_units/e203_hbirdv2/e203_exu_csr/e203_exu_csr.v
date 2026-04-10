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
//  The module to implement the core's CSRs
//
// ====================================================================
`include "e203_defines.v"

module e203_exu_csr(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=30-98
  input nonflush_cmt_ena,
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=31-33
`ifdef E203_HAS_NICE
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=31-33
  output nice_xs_off,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=31-33
`endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=31-33

  input csr_ena,
  input csr_wr_en,
  input csr_rd_en,
  input [12-1:0] csr_idx,

  output csr_access_ilgl,
  output tm_stop,
  output core_cgstop,
  output tcm_cgstop,
  output itcm_nohold,
  output mdv_nob2b,


  output [`E203_XLEN-1:0] read_csr_dat,
  input  [`E203_XLEN-1:0] wbck_csr_dat,
   
  input  [`E203_HART_ID_W-1:0] core_mhartid,
  input  ext_irq_r,
  input  sft_irq_r,
  input  tmr_irq_r,

  output status_mie_r,
  output mtie_r,
  output msie_r,
  output meie_r,

  output wr_dcsr_ena    ,
  output wr_dpc_ena     ,
  output wr_dscratch_ena,


  input [`E203_XLEN-1:0] dcsr_r    ,
  input [`E203_PC_SIZE-1:0] dpc_r     ,
  input [`E203_XLEN-1:0] dscratch_r,

  output [`E203_XLEN-1:0] wr_csr_nxt    ,

  input  dbg_mode,
  input  dbg_stopcycle,

  output u_mode,
  output s_mode,
  output h_mode,
  output m_mode,

  input [`E203_ADDR_SIZE-1:0] cmt_badaddr,
  input cmt_badaddr_ena,
  input [`E203_PC_SIZE-1:0] cmt_epc,
  input cmt_epc_ena,
  input [`E203_XLEN-1:0] cmt_cause,
  input cmt_cause_ena,
  input cmt_status_ena,
  input cmt_instret_ena,

  input                      cmt_mret_ena,
  output[`E203_PC_SIZE-1:0]  csr_epc_r,
  output[`E203_PC_SIZE-1:0]  csr_dpc_r,
  output[`E203_XLEN-1:0]     csr_mtvec_r,


  input  clk_aon,
  input  clk,
  input  rst_n

//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=30-98
  );



//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=103-104
assign csr_access_ilgl = 1'b0
                ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=103-104

// Only toggle when need to read or write to save power
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=107-110
wire wbck_csr_wen = csr_wr_en & csr_ena & (~csr_access_ilgl);
wire read_csr_ena = csr_rd_en & csr_ena & (~csr_access_ilgl);

wire [1:0] priv_mode = u_mode ? 2'b00 : 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=107-110
                       s_mode ? 2'b01 :
                       h_mode ? 2'b10 : 
                       m_mode ? 2'b11 : 
                                2'b11;

//0x000 URW ustatus User status register.
//    * Since we support the user-level interrupt, hence we need to support UIE
//0x300 MRW mstatus Machine status register.
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=119-137
wire sel_ustatus = (csr_idx == 12'h000);
wire sel_mstatus = (csr_idx == 12'h300);

wire rd_ustatus = sel_ustatus & csr_rd_en;
wire rd_mstatus = sel_mstatus & csr_rd_en;
wire wr_ustatus = sel_ustatus & csr_wr_en;
wire wr_mstatus = sel_mstatus & csr_wr_en;


/////////////////////////////////////////////////////////////////////
// Note: the below implementation only apply to Machine-mode config,
//       if other mode is also supported, these logics need to be updated

//////////////////////////
// Implement MPIE field
//
wire status_mpie_r;
    // The MPIE Feilds will be updates when: 
wire status_mpie_ena  = 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=119-137
        // The CSR is written by CSR instructions
        (wr_mstatus & wbck_csr_wen) |
        // The MRET instruction commited
        cmt_mret_ena |
        // The Trap is taken
        cmt_status_ena;

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=145-145
wire status_mpie_nxt    = 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=145-145
    //   See Priv SPEC:
    //       When a trap is taken from privilege mode y into privilege
    //       mode x, xPIE is set to the value of xIE;
    // So, When the Trap is taken, the MPIE is updated with the current MIE value
    cmt_status_ena ? status_mie_r :
    //   See Priv SPEC:
    //       When executing an xRET instruction, supposing xPP holds the value y, xIE
    //       is set to xPIE; the privilege mode is changed to y; 
    //       xPIE is set to 1;
    // So, When the MRET instruction commited, the MPIE is updated with 1
    cmt_mret_ena  ? 1'b1 :
    // When the CSR is written by CSR instructions
    (wr_mstatus & wbck_csr_wen) ? wbck_csr_dat[7] : // MPIE is in field 7 of mstatus
                  status_mpie_r; // Unchanged 

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=161-161
sirv_gnrl_dfflr #(1) status_mpie_dfflr (status_mpie_ena, status_mpie_nxt, status_mpie_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=161-161

//////////////////////////
// Implement MIE field
//
    // The MIE Feilds will be updates same as MPIE
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=167-168
wire status_mie_ena  = status_mpie_ena; 
wire status_mie_nxt    = 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=167-168
    //   See Priv SPEC:
    //       When a trap is taken from privilege mode y into privilege
    //       mode x, xPIE is set to the value of xIE,
    //       xIE is set to 0;
    // So, When the Trap is taken, the MIE is updated with 0
     cmt_status_ena ? 1'b0 :
    //   See Priv SPEC:
    //       When executing an xRET instruction, supposing xPP holds the value y, xIE
    //       is set to xPIE; the privilege mode is changed to y, xPIE is set to 1;
    // So, When the MRET instruction commited, the MIE is updated with MPIE
    cmt_mret_ena ? status_mpie_r :
    // When the CSR is written by CSR instructions
    (wr_mstatus & wbck_csr_wen) ? wbck_csr_dat[3] : // MIE is in field 3 of mstatus
                  status_mie_r; // Unchanged 

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000002 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=184-184
sirv_gnrl_dfflr #(1) status_mie_dfflr (status_mie_ena, status_mie_nxt, status_mie_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000002 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=184-184

//////////////////////////
// Implement SD field
//
//  See Priv SPEC:
//    The SD bit is read-only 
//    And is set when either the FS or XS bits encode a Dirty
//      state (i.e., SD=((FS==11) OR (XS==11))).
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000005 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=193-195
wire [1:0] status_fs_r;
wire [1:0] status_xs_r;
wire status_sd_r = (status_fs_r == 2'b11) | (status_xs_r == 2'b11);
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000005 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=193-195

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000002 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=197-197
assign status_xs_r = 2'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000002 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=197-197

//////////////////////////
// Implement XS field
//
//  See Priv SPEC:
//    XS field is read-only
//    The XS field represents a summary of all extensions' status
    // But in E200 we implement XS exactly same as FS to make it usable by software to 
    //   disable extended accelerators
    
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=208-211
`ifdef E203_HAS_NICE
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=208-211
   // If no NICE coprocessor interface configured, the XS is just hardwired to 0
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000003 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=210-210
assign nice_xs_off = 1'b0;// We just make this signal to 0
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000003 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=210-210
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=208-211
`endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=208-211

//////////////////////////
// Implement FS field
//

//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=217-220
`ifndef E203_HAS_FPU
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=217-220
   // If no FPU configured, the FS is just hardwired to 0
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000004 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=219-219
assign status_fs_r = 2'b0; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000004 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=219-219
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=217-220
`endif
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=217-220

//////////////////////////
// Pack to the full mstatus register
//
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000006 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=225-225
wire [`E203_XLEN-1:0] status_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000006 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=225-225
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=226-241
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000005 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=226-226
assign status_r[31]    = status_sd_r;                        //SD
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000005 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=226-226
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000006 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=227-227
assign status_r[30:23] = 8'b0; // Reserved
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000006 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=227-227
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000007 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=228-228
assign status_r[22:17] = 6'b0;               // TSR--MPRV
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000007 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=228-228
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000008 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=229-229
assign status_r[16:15] = status_xs_r;                        // XS
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000008 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=229-229
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000009 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=230-230
assign status_r[14:13] = status_fs_r;                        // FS
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000009 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=230-230
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000010 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=231-231
assign status_r[12:11] = 2'b11;              // MPP 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000010 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=231-231
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000011 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=232-232
assign status_r[10:9]  = 2'b0; // Reserved
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000011 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=232-232
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000012 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=233-233
assign status_r[8]     = 1'b0;               // SPP
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000012 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=233-233
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000013 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=234-234
assign status_r[7]     = status_mpie_r;                      // MPIE
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000013 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=234-234
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000014 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=235-235
assign status_r[6]     = 1'b0; // Reserved
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000014 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=235-235
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000015 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=236-236
assign status_r[5]     = 1'b0;               // SPIE 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000015 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=236-236
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000016 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=237-237
assign status_r[4]     = 1'b0;               // UPIE 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000016 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=237-237
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000017 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=238-238
assign status_r[3]     = status_mie_r;                       // MIE
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000017 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=238-238
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000018 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=239-239
assign status_r[2]     = 1'b0; // Reserved
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000018 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=239-239
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000019 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=240-240
assign status_r[1]     = 1'b0;               // SIE 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000019 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=240-240
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000020 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=241-241
assign status_r[0]     = 1'b0;               // UIE 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000020 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=241-241
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=226-241

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000007 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=243-253
wire [`E203_XLEN-1:0] csr_mstatus = status_r;

//0x004 URW uie User interrupt-enable register.
//    * Since we dont delegate interrupt to user mode, hence it is as all 0s
//0x304 MRW mie Machine interrupt-enable register.
wire sel_mie = (csr_idx == 12'h304);
wire rd_mie = sel_mie & csr_rd_en;
wire wr_mie = sel_mie & csr_wr_en;
wire mie_ena = wr_mie & wbck_csr_wen;
wire [`E203_XLEN-1:0] mie_r;
wire [`E203_XLEN-1:0] mie_nxt;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000007 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=243-253
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=254-260
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000021 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=254-254
assign mie_nxt[31:12] = 20'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000021 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=254-254
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000022 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=255-255
assign mie_nxt[11] = wbck_csr_dat[11];//MEIE
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000022 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=255-255
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000023 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=256-256
assign mie_nxt[10:8] = 3'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000023 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=256-256
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000024 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=257-257
assign mie_nxt[ 7] = wbck_csr_dat[ 7];//MTIE
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000024 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=257-257
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000025 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=258-258
assign mie_nxt[6:4] = 3'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000025 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=258-258
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000026 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=259-259
assign mie_nxt[ 3] = wbck_csr_dat[ 3];//MSIE
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000026 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=259-259
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000027 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=260-260
assign mie_nxt[2:0] = 3'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000027 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=260-260
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=254-260
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000003 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=261-261
sirv_gnrl_dfflr #(`E203_XLEN) mie_dfflr (mie_ena, mie_nxt, mie_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000003 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=261-261
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000008 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=262-262
wire [`E203_XLEN-1:0] csr_mie = mie_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000008 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=262-262

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=264-266
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000028 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=264-264
assign meie_r = csr_mie[11];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000028 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=264-264
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000029 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=265-265
assign mtie_r = csr_mie[ 7];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000029 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=265-265
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000030 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=266-266
assign msie_r = csr_mie[ 3];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000030 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=266-266
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=264-266

//0x044 URW uip User interrupt pending.
//  We dont support delegation scheme, so no need to support the uip
//0x344 MRW mip Machine interrupt pending
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000009 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=271-277
wire sel_mip = (csr_idx == 12'h344);
wire rd_mip = sel_mip & csr_rd_en;
//wire wr_mip = sel_mip & csr_wr_en;
// The MxIP is read-only
wire meip_r;
wire msip_r;
wire mtip_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000009 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=271-277
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000004 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=278-278
sirv_gnrl_dffr #(1) meip_dffr (ext_irq_r, meip_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000004 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=278-278
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000005 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=279-279
sirv_gnrl_dffr #(1) msip_dffr (sft_irq_r, msip_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000005 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=279-279
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000006 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=280-280
sirv_gnrl_dffr #(1) mtip_dffr (tmr_irq_r, mtip_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000006 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=280-280

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000010 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=282-282
wire [`E203_XLEN-1:0] ip_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000010 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=282-282
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:assign_cluster:000004 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=283-289
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000031 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=283-283
assign ip_r[31:12] = 20'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000031 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=283-283
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000032 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=284-284
assign ip_r[11] = meip_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000032 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=284-284
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000033 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=285-285
assign ip_r[10:8] = 3'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000033 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=285-285
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000034 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=286-286
assign ip_r[ 7] = mtip_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000034 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=286-286
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000035 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=287-287
assign ip_r[6:4] = 3'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000035 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=287-287
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000036 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=288-288
assign ip_r[ 3] = msip_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000036 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=288-288
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000037 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=289-289
assign ip_r[2:0] = 3'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000037 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=289-289
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:assign_cluster:000004 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=283-289
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000011 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=290-302
wire [`E203_XLEN-1:0] csr_mip = ip_r;
//

//0x005 URW utvec User trap handler base address.
//  We dont support user trap, so no utvec needed
//0x305 MRW mtvec Machine trap-handler base address.
wire sel_mtvec = (csr_idx == 12'h305);
wire rd_mtvec = csr_rd_en & sel_mtvec;
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000004 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=298-308
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000004:br:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=298-304
`ifdef E203_SUPPORT_MTVEC //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000004 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=298-308
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000004:br:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=298-304
wire wr_mtvec = sel_mtvec & csr_wr_en;
wire mtvec_ena = (wr_mtvec & wbck_csr_wen);
wire [`E203_XLEN-1:0] mtvec_r;
wire [`E203_XLEN-1:0] mtvec_nxt = wbck_csr_dat;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000011 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=290-302
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000007 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=303-303
sirv_gnrl_dfflr #(`E203_XLEN) mtvec_dfflr (mtvec_ena, mtvec_nxt, mtvec_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000007 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=303-303
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000012 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=304-308
wire [`E203_XLEN-1:0] csr_mtvec = mtvec_r;
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000004:br:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=298-304
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000004:br:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=298-304
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000004:br:000002 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=305-307
`else//}{
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000004:br:000002 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=305-307
  // THe vector table base is a configurable parameter, so we dont support writeable to it
wire [`E203_XLEN-1:0] csr_mtvec = `E203_MTVEC_TRAP_BASE;
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000004:br:000002 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=305-307
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000004:br:000002 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=305-307
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000004 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=298-308
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000004 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=298-308
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000012 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=304-308
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000038 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=309-309
assign csr_mtvec_r = csr_mtvec;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000038 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=309-309

//0x340 MRW mscratch 
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000013 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=312-318
wire sel_mscratch = (csr_idx == 12'h340);
wire rd_mscratch = sel_mscratch & csr_rd_en;
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000005 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=314-323
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000005:br:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=314-320
`ifdef E203_SUPPORT_MSCRATCH //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000005 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=314-323
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000005:br:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=314-320
wire wr_mscratch = sel_mscratch & csr_wr_en;
wire mscratch_ena = (wr_mscratch & wbck_csr_wen);
wire [`E203_XLEN-1:0] mscratch_r;
wire [`E203_XLEN-1:0] mscratch_nxt = wbck_csr_dat;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000013 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=312-318
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000008 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=319-319
sirv_gnrl_dfflr #(`E203_XLEN) mscratch_dfflr (mscratch_ena, mscratch_nxt, mscratch_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000008 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=319-319
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000014 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=320-393
wire [`E203_XLEN-1:0] csr_mscratch = mscratch_r;
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000005:br:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=314-320
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000005:br:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=314-320
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000005:br:000002 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=321-322
`else//}{
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000005:br:000002 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=321-322
wire [`E203_XLEN-1:0] csr_mscratch = `E203_XLEN'b0;
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000005:br:000002 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=321-322
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000005:br:000002 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=321-322
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000005 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=314-323
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000005 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=314-323

// 0xB00 MRW mcycle 
// 0xB02 MRW minstret 
// 0xB80 MRW mcycleh
// 0xB82 MRW minstreth 
wire sel_mcycle    = (csr_idx == 12'hB00);
wire sel_mcycleh   = (csr_idx == 12'hB80);
wire sel_minstret  = (csr_idx == 12'hB02);
wire sel_minstreth = (csr_idx == 12'hB82);

// 0xBFF MRW counterstop 
      // This register is our self-defined register to stop
      // the cycle/time/instret counters to save dynamic powers
wire sel_counterstop = (csr_idx == 12'hBFF);// This address is not used by ISA
// 0xBFE MRW mcgstop 
      // This register is our self-defined register to disable the 
      // automaticall clock gating for CPU logics for debugging purpose
wire sel_mcgstop = (csr_idx == 12'hBFE);// This address is not used by ISA
// 0xBFD MRW itcmnohold 
      // This register is our self-defined register to disble the 
      // ITCM SRAM output holdup feature, if set, then we assume
      // ITCM SRAM output cannot holdup last read value
wire sel_itcmnohold = (csr_idx == 12'hBFD);// This address is not used by ISA
// 0xBF0 MRW mdvnob2b 
      // This register is our self-defined register to disble the 
      // Mul/div back2back feature
wire sel_mdvnob2b = (csr_idx == 12'hBF0);// This address is not used by ISA


wire rd_mcycle     = csr_rd_en & sel_mcycle   ;
wire rd_mcycleh    = csr_rd_en & sel_mcycleh  ;
wire rd_minstret   = csr_rd_en & sel_minstret ;
wire rd_minstreth  = csr_rd_en & sel_minstreth;

wire rd_itcmnohold   = csr_rd_en & sel_itcmnohold;
wire rd_mdvnob2b   = csr_rd_en & sel_mdvnob2b;
wire rd_counterstop  = csr_rd_en & sel_counterstop;
wire rd_mcgstop       = csr_rd_en & sel_mcgstop;

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000006 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=363-429
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000006:br:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=363-422
`ifdef E203_SUPPORT_MCYCLE_MINSTRET //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000006 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=363-429
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000006:br:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=363-422
wire wr_mcycle     = csr_wr_en & sel_mcycle   ;
wire wr_mcycleh    = csr_wr_en & sel_mcycleh  ;
wire wr_minstret   = csr_wr_en & sel_minstret ;
wire wr_minstreth  = csr_wr_en & sel_minstreth;

wire wr_itcmnohold   = csr_wr_en & sel_itcmnohold ;
wire wr_mdvnob2b   = csr_wr_en & sel_mdvnob2b ;
wire wr_counterstop  = csr_wr_en & sel_counterstop;
wire wr_mcgstop       = csr_wr_en & sel_mcgstop     ;

wire mcycle_wr_ena    = (wr_mcycle    & wbck_csr_wen);
wire mcycleh_wr_ena   = (wr_mcycleh   & wbck_csr_wen);
wire minstret_wr_ena  = (wr_minstret  & wbck_csr_wen);
wire minstreth_wr_ena = (wr_minstreth & wbck_csr_wen);

wire itcmnohold_wr_ena  = (wr_itcmnohold  & wbck_csr_wen);
wire mdvnob2b_wr_ena  = (wr_mdvnob2b  & wbck_csr_wen);
wire counterstop_wr_ena = (wr_counterstop & wbck_csr_wen);
wire mcgstop_wr_ena      = (wr_mcgstop      & wbck_csr_wen);

wire [`E203_XLEN-1:0] mcycle_r   ;
wire [`E203_XLEN-1:0] mcycleh_r  ;
wire [`E203_XLEN-1:0] minstret_r ;
wire [`E203_XLEN-1:0] minstreth_r;

wire cy_stop;
wire ir_stop;

wire stop_cycle_in_dbg = dbg_stopcycle & dbg_mode;
wire mcycle_ena    = mcycle_wr_ena    | 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000014 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=320-393
                     ((~cy_stop) & (~stop_cycle_in_dbg) & (1'b1));
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000015 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=395-395
wire mcycleh_ena   = mcycleh_wr_ena   | 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000015 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=395-395
                     ((~cy_stop) & (~stop_cycle_in_dbg) & ((mcycle_r == (~(`E203_XLEN'b0)))));
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000016 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=397-397
wire minstret_ena  = minstret_wr_ena  |
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000016 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=397-397
                     ((~ir_stop) & (~stop_cycle_in_dbg) & (cmt_instret_ena));
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000017 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=399-399
wire minstreth_ena = minstreth_wr_ena |
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000017 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=399-399
                     ((~ir_stop) & (~stop_cycle_in_dbg) & ((cmt_instret_ena & (minstret_r == (~(`E203_XLEN'b0))))));

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000018 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=402-405
wire [`E203_XLEN-1:0] mcycle_nxt    = mcycle_wr_ena    ? wbck_csr_dat : (mcycle_r    + 1'b1);
wire [`E203_XLEN-1:0] mcycleh_nxt   = mcycleh_wr_ena   ? wbck_csr_dat : (mcycleh_r   + 1'b1);
wire [`E203_XLEN-1:0] minstret_nxt  = minstret_wr_ena  ? wbck_csr_dat : (minstret_r  + 1'b1);
wire [`E203_XLEN-1:0] minstreth_nxt = minstreth_wr_ena ? wbck_csr_dat : (minstreth_r + 1'b1);
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000018 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=402-405

//We need to use the always-on clock for this counter
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000009 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=408-408
sirv_gnrl_dfflr #(`E203_XLEN) mcycle_dfflr (mcycle_ena, mcycle_nxt, mcycle_r   , clk_aon, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000009 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=408-408
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000010 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=409-409
sirv_gnrl_dfflr #(`E203_XLEN) mcycleh_dfflr (mcycleh_ena, mcycleh_nxt, mcycleh_r  , clk_aon, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000010 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=409-409
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000011 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=410-410
sirv_gnrl_dfflr #(`E203_XLEN) minstret_dfflr (minstret_ena, minstret_nxt, minstret_r , clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000011 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=410-410
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000012 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=411-411
sirv_gnrl_dfflr #(`E203_XLEN) minstreth_dfflr (minstreth_ena, minstreth_nxt, minstreth_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000012 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=411-411

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000019 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=413-415
wire [`E203_XLEN-1:0] counterstop_r;
wire counterstop_ena = counterstop_wr_ena;
wire [`E203_XLEN-1:0] counterstop_nxt = {29'b0,wbck_csr_dat[2:0]};// Only LSB 3bits are useful
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000019 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=413-415
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000013 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=416-416
sirv_gnrl_dfflr #(`E203_XLEN) counterstop_dfflr (counterstop_ena, counterstop_nxt, counterstop_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000013 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=416-416

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000020 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=418-433
wire [`E203_XLEN-1:0] csr_mcycle    = mcycle_r;
wire [`E203_XLEN-1:0] csr_mcycleh   = mcycleh_r;
wire [`E203_XLEN-1:0] csr_minstret  = minstret_r;
wire [`E203_XLEN-1:0] csr_minstreth = minstreth_r;
wire [`E203_XLEN-1:0] csr_counterstop = counterstop_r;
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000006:br:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=363-422
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000006:br:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=363-422
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000006:br:000002 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=423-428
`else//}{
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000006:br:000002 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=423-428
wire [`E203_XLEN-1:0] csr_mcycle    = `E203_XLEN'b0;
wire [`E203_XLEN-1:0] csr_mcycleh   = `E203_XLEN'b0;
wire [`E203_XLEN-1:0] csr_minstret  = `E203_XLEN'b0;
wire [`E203_XLEN-1:0] csr_minstreth = `E203_XLEN'b0;
wire [`E203_XLEN-1:0] csr_counterstop = `E203_XLEN'b0;
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000006:br:000002 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=423-428
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000006:br:000002 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=423-428
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000006 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=363-429
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000006 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=363-429

wire [`E203_XLEN-1:0] itcmnohold_r;
wire itcmnohold_ena = itcmnohold_wr_ena;
wire [`E203_XLEN-1:0] itcmnohold_nxt = {31'b0,wbck_csr_dat[0]};// Only LSB 1bits are useful
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000020 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=418-433
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000014 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=434-434
sirv_gnrl_dfflr #(`E203_XLEN) itcmnohold_dfflr (itcmnohold_ena, itcmnohold_nxt, itcmnohold_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000014 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=434-434

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000021 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=436-440
wire [`E203_XLEN-1:0] csr_itcmnohold  = itcmnohold_r;

wire [`E203_XLEN-1:0] mdvnob2b_r;
wire mdvnob2b_ena = mdvnob2b_wr_ena;
wire [`E203_XLEN-1:0] mdvnob2b_nxt = {31'b0,wbck_csr_dat[0]};// Only LSB 1bits are useful
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000021 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=436-440
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000015 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=441-441
sirv_gnrl_dfflr #(`E203_XLEN) mdvnob2b_dfflr (mdvnob2b_ena, mdvnob2b_nxt, mdvnob2b_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000015 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=441-441

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000022 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=443-443
wire [`E203_XLEN-1:0] csr_mdvnob2b  = mdvnob2b_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000022 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=443-443

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:assign_cluster:000005 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=445-450
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000039 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=445-445
assign cy_stop = counterstop_r[0];// Stop CYCLE   counter
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000039 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=445-445
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000040 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=446-446
assign tm_stop = counterstop_r[1];// Stop TIME    counter
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000040 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=446-446
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000041 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=447-447
assign ir_stop = counterstop_r[2];// Stop INSTRET counter
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000041 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=447-447

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000042 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=449-449
assign itcm_nohold = itcmnohold_r[0];// ITCM no-hold up feature
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000042 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=449-449
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000043 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=450-450
assign mdv_nob2b = mdvnob2b_r[0];// Mul/Div no back2back feature
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000043 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=450-450
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:assign_cluster:000005 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=445-450



//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000023 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=454-456
wire [`E203_XLEN-1:0] mcgstop_r;
wire mcgstop_ena = mcgstop_wr_ena;
wire [`E203_XLEN-1:0] mcgstop_nxt = {30'b0,wbck_csr_dat[1:0]};// Only LSB 2bits are useful
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000023 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=454-456
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000016 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=457-457
sirv_gnrl_dfflr #(`E203_XLEN) mcgstop_dfflr (mcgstop_ena, mcgstop_nxt, mcgstop_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000016 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=457-457
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000024 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=458-458
wire [`E203_XLEN-1:0] csr_mcgstop = mcgstop_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000024 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=458-458
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:assign_cluster:000006 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=459-460
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000044 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=459-459
assign core_cgstop = mcgstop_r[0];// Stop Core clock gating
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000044 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=459-459
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000045 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=460-460
assign tcm_cgstop = mcgstop_r[1];// Stop TCM  clock gating
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000045 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=460-460
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:assign_cluster:000006 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=459-460


//`ifdef E203_SUPPORT_CYCLE //{
////0xC00 URO cycle 
////0xC80 URO cycleh
//wire sel_cycle  = (csr_idx == 12'hc00);
//wire sel_cycleh = (csr_idx == 12'hc80);
//wire rd_cycle = sel_cycle & csr_rd_en;
//wire wr_cycle = sel_cycle & csr_wr_en;
//wire cycle_ena = (wr_cycle & wbck_csr_wen);
//wire rd_cycleh = sel_cycleh & csr_rd_en;
//wire wr_cycleh = sel_cycleh & csr_wr_en;
//wire cycleh_ena = (wr_cycleh & wbck_csr_wen);
//wire [`E203_XLEN-1:0] cycle_r;
//wire [`E203_XLEN-1:0] cycleh_r;
//wire [`E203_XLEN-1:0] cycle_nxt = wbck_csr_dat;
//wire [`E203_XLEN-1:0] cycleh_nxt = wbck_csr_dat;
//sirv_gnrl_dfflr #(`E203_XLEN) cycle_dfflr (cycle_ena, cycle_nxt, cycle_r, clk, rst_n);
//sirv_gnrl_dfflr #(`E203_XLEN) cycleh_dfflr(cycleh_ena,cycleh_nxt,cycleh_r,clk, rst_n);
//wire [`E203_XLEN-1:0] csr_cycle  = cycle_r;
//wire [`E203_XLEN-1:0] csr_cycleh = cycleh_r;
//`else//}{
//wire [`E203_XLEN-1:0] csr_cycle = `E203_XLEN'b0;
//wire [`E203_XLEN-1:0] csr_cycleh = `E203_XLEN'b0;
//`endif//}

//
//0x041 URW uepc User exception program counter.
//  We dont support user trap, so no uepc needed
//0x341 MRW mepc Machine exception program counter.
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000025 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=491-496
wire sel_mepc = (csr_idx == 12'h341);
wire rd_mepc = sel_mepc & csr_rd_en;
wire wr_mepc = sel_mepc & csr_wr_en;
wire epc_ena = (wr_mepc & wbck_csr_wen) | cmt_epc_ena;
wire [`E203_PC_SIZE-1:0] epc_r;
wire [`E203_PC_SIZE-1:0] epc_nxt;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000025 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=491-496
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:assign_cluster:000007 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=497-498
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000046 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=497-497
assign epc_nxt[`E203_PC_SIZE-1:1] = cmt_epc_ena ? cmt_epc[`E203_PC_SIZE-1:1] : wbck_csr_dat[`E203_PC_SIZE-1:1];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000046 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=497-497
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000047 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=498-498
assign epc_nxt[0] = 1'b0;// Must not hold PC which will generate the misalign exception according to ISA
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000047 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=498-498
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:assign_cluster:000007 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=497-498
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000017 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=499-499
sirv_gnrl_dfflr #(`E203_PC_SIZE) epc_dfflr (epc_ena, epc_nxt, epc_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000017 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=499-499
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000026 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=500-501
wire [`E203_XLEN-1:0] csr_mepc;
wire dummy_0;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000026 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=500-501
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:assign_cluster:000008 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=502-503
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000048 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=502-502
assign {dummy_0,csr_mepc} = {{`E203_XLEN+1-`E203_PC_SIZE{1'b0}},epc_r};
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000048 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=502-502
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000049 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=503-503
assign csr_epc_r = csr_mepc;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000049 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=503-503
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:assign_cluster:000008 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=502-503

//0x042 URW ucause User trap cause.
//  We dont support user trap, so no ucause needed
//0x342 MRW mcause Machine trap cause.
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000027 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=508-513
wire sel_mcause = (csr_idx == 12'h342);
wire rd_mcause = sel_mcause & csr_rd_en;
wire wr_mcause = sel_mcause & csr_wr_en;
wire cause_ena = (wr_mcause & wbck_csr_wen) | cmt_cause_ena;
wire [`E203_XLEN-1:0] cause_r;
wire [`E203_XLEN-1:0] cause_nxt;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000027 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=508-513
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:assign_cluster:000009 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=514-516
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000050 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=514-514
assign cause_nxt[31]  = cmt_cause_ena ? cmt_cause[31] : wbck_csr_dat[31];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000050 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=514-514
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000051 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=515-515
assign cause_nxt[30:4] = 27'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000051 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=515-515
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000052 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=516-516
assign cause_nxt[3:0] = cmt_cause_ena ? cmt_cause[3:0] : wbck_csr_dat[3:0];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000052 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=516-516
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:assign_cluster:000009 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=514-516
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000018 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=517-517
sirv_gnrl_dfflr #(`E203_XLEN) cause_dfflr (cause_ena, cause_nxt, cause_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000018 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=517-517
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000028 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=518-530
wire [`E203_XLEN-1:0] csr_mcause = cause_r;


//0x043 URW ubadaddr User bad address.
//  We dont support user trap, so no ubadaddr needed
//0x343 MRW mbadaddr Machine bad address.
wire sel_mbadaddr = (csr_idx == 12'h343);
wire rd_mbadaddr = sel_mbadaddr & csr_rd_en;
wire wr_mbadaddr = sel_mbadaddr & csr_wr_en;
wire cmt_trap_badaddr_ena = cmt_badaddr_ena;
wire badaddr_ena = (wr_mbadaddr & wbck_csr_wen) | cmt_trap_badaddr_ena;
wire [`E203_ADDR_SIZE-1:0] badaddr_r;
wire [`E203_ADDR_SIZE-1:0] badaddr_nxt;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000028 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=518-530
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000053 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=531-531
assign badaddr_nxt = cmt_trap_badaddr_ena ? cmt_badaddr : wbck_csr_dat[`E203_ADDR_SIZE-1:0];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000053 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=531-531
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000019 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=532-532
sirv_gnrl_dfflr #(`E203_ADDR_SIZE) badaddr_dfflr (badaddr_ena, badaddr_nxt, badaddr_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:inst:000019 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=532-532
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000029 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=533-534
wire [`E203_XLEN-1:0] csr_mbadaddr;
wire dummy_1;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000029 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=533-534
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000054 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=535-535
assign {dummy_1,csr_mbadaddr} = {{`E203_XLEN+1-`E203_ADDR_SIZE{1'b0}},badaddr_r};
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000054 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=535-535

// We dont support the delegation scheme, so no need to implement
//   delegete registers


//0x301 MRW misa ISA and extensions
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000030 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=542-545
wire sel_misa = (csr_idx == 12'h301);
wire rd_misa = sel_misa & csr_rd_en;
// Only implemented the M mode, IMC or EMC
wire [`E203_XLEN-1:0] csr_misa = {
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000030 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=542-545
    2'b1
   ,4'b0 //WIRI
   ,1'b0 //              25 Z Reserved
   ,1'b0 //              24 Y Reserved
   ,1'b0 //              23 X Non-standard extensions present
   ,1'b0 //              22 W Reserved
   ,1'b0 //              21 V Tentatively reserved for Vector extension 20 U User mode implemented
   ,1'b0 //              20 U User mode implemented
   ,1'b0 //              19 T Tentatively reserved for Transactional Memory extension
   ,1'b0 //              18 S Supervisor mode implemented
   ,1'b0 //              17 R Reserved
   ,1'b0 //              16 Q Quad-precision floating-point extension
   ,1'b0 //              15 P Tentatively reserved for Packed-SIMD extension
   ,1'b0 //              14 O Reserved
   ,1'b0 //              13 N User-level interrupts supported
   ,1'b1 // 12 M Integer Multiply/Divide extension
   ,1'b0 //              11 L Tentatively reserved for Decimal Floating-Point extension
   ,1'b0 //              10 K Reserved
   ,1'b0 //              9 J Reserved
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000007 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=565-569
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000007:br:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=565-566
   `ifdef E203_RFREG_NUM_IS_32
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000007 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=565-569
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000007:br:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=565-566
   ,1'b1 // 8 I RV32I/64I/128I base ISA
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000007:br:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=565-566
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000007:br:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=565-566
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000007:br:000002 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=567-568
   `else
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000007:br:000002 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=567-568
   ,1'b0
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000007:br:000002 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=567-568
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000007:br:000002 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=567-568
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000007 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=565-569
   `endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000007 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=565-569
   ,1'b0 //              7 H Hypervisor mode implemented
   ,1'b0 //              6 G Additional standard extensions present
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000008 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=572-574
  `ifndef E203_HAS_FPU//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000008 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=572-574
   ,1'b0 //              5 F Single-precision floating-point extension
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000008 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=572-574
  `endif//
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000008 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=572-574
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000009 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=575-579
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000009:br:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=575-576
   `ifdef E203_RFREG_NUM_IS_32
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000009 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=575-579
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000009:br:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=575-576
   ,1'b0 //              4 E RV32E base ISA
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000009:br:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=575-576
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000009:br:000001 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=575-576
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000009:br:000002 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=577-578
   `else
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000009:br:000002 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=577-578
   ,1'b1 //              
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000009:br:000002 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=577-578
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000009:br:000002 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=577-578
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000009 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=575-579
   `endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000009 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=575-579
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000010 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=580-582
  `ifndef E203_HAS_FPU//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000010 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=580-582
   ,1'b0 //              3 D Double-precision floating-point extension
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000010 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=580-582
  `endif//
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000010 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=580-582
   ,1'b1 // 2 C Compressed extension
   ,1'b0 //              1 B Tentatively reserved for Bit operations extension
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000011 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=585-587
  `ifdef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000011 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=585-587
   ,1'b1 //              0 A Atomic extension
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000011 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=585-587
  `endif//E203_SUPPORT_AMO}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000011 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=585-587
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000012 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=588-590
  `ifndef E203_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000012 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=588-590
   ,1'b0 //              0 A Atomic extension
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000012 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=588-590
  `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000012 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=588-590
                           };

//Machine Information Registers
//0xF11 MRO mvendorid Vendor ID.
//0xF12 MRO marchid Architecture ID.
//0xF13 MRO mimpid Implementation ID.
//0xF14 MRO mhartid Hardware thread ID.
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000031 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=598-617
wire [`E203_XLEN-1:0] csr_mvendorid = `E203_XLEN'h536;
wire [`E203_XLEN-1:0] csr_marchid   = `E203_XLEN'hE203;
wire [`E203_XLEN-1:0] csr_mimpid    = `E203_XLEN'h1;
wire [`E203_XLEN-1:0] csr_mhartid   = {{`E203_XLEN-`E203_HART_ID_W{1'b0}},core_mhartid};
wire rd_mvendorid = csr_rd_en & (csr_idx == 12'hF11);
wire rd_marchid   = csr_rd_en & (csr_idx == 12'hF12);
wire rd_mimpid    = csr_rd_en & (csr_idx == 12'hF13);
wire rd_mhartid   = csr_rd_en & (csr_idx == 12'hF14);

//0x7b0 Debug Control and Status
//0x7b1 Debug PC
//0x7b2 Debug Scratch Register
//0x7a0 Trigger selection register
wire sel_dcsr     = (csr_idx == 12'h7b0);
wire sel_dpc      = (csr_idx == 12'h7b1);
wire sel_dscratch = (csr_idx == 12'h7b2);

wire rd_dcsr     = dbg_mode & csr_rd_en & sel_dcsr    ;
wire rd_dpc      = dbg_mode & csr_rd_en & sel_dpc     ;
wire rd_dscratch = dbg_mode & csr_rd_en & sel_dscratch;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000031 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=598-617


//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:assign_cluster:000010 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=620-625
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000055 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=620-620
assign wr_dcsr_ena     = dbg_mode & csr_wr_en & sel_dcsr    ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000055 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=620-620
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000056 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=621-621
assign wr_dpc_ena      = dbg_mode & csr_wr_en & sel_dpc     ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000056 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=621-621
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000057 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=622-622
assign wr_dscratch_ena = dbg_mode & csr_wr_en & sel_dscratch;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000057 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=622-622


//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000058 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=625-625
assign wr_csr_nxt     = wbck_csr_dat;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000058 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=625-625
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:assign_cluster:000010 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=620-625


//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000032 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=628-638
wire [`E203_XLEN-1:0] csr_dcsr     = dcsr_r    ;
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000013 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=629-631
`ifdef E203_PC_SIZE_IS_16
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000013 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=629-631
wire [`E203_XLEN-1:0] csr_dpc      = {{`E203_XLEN-`E203_PC_SIZE{1'b0}},dpc_r};
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000013 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=629-631
`endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000013 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=629-631
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000014 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=632-634
`ifdef E203_PC_SIZE_IS_24
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000014 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=632-634
wire [`E203_XLEN-1:0] csr_dpc      = {{`E203_XLEN-`E203_PC_SIZE{1'b0}},dpc_r};
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000014 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=632-634
`endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000014 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=632-634
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000015 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=635-637
`ifdef E203_PC_SIZE_IS_32
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000015 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=635-637
wire [`E203_XLEN-1:0] csr_dpc      = dpc_r     ;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000015 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=635-637
`endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:pp_blk:000015 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=635-637
wire [`E203_XLEN-1:0] csr_dscratch = dscratch_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:internal_signal:000032 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=628-638

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000059 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=640-640
assign csr_dpc_r = dpc_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000059 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=640-640

/////////////////////////////////////////////////////////////////////
//  Generate the Read path
  //Currently we only support the M mode to simplify the implementation and 
  //      reduce the gatecount because we are a privite core
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:assign_cluster:000011 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=646-676
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000060 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=646-646
assign u_mode = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000060 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=646-646
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000061 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=647-647
assign s_mode = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000061 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=647-647
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000062 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=648-648
assign h_mode = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000062 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=648-648
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000063 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=649-649
assign m_mode = 1'b1;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000063 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=649-649
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000064 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=650-676
assign read_csr_dat = `E203_XLEN'b0 
               //| ({`E203_XLEN{rd_ustatus  }} & csr_ustatus  )
               | ({`E203_XLEN{rd_mstatus  }} & csr_mstatus  )
               | ({`E203_XLEN{rd_mie      }} & csr_mie      )
               | ({`E203_XLEN{rd_mtvec    }} & csr_mtvec    )
               | ({`E203_XLEN{rd_mepc     }} & csr_mepc     )
               | ({`E203_XLEN{rd_mscratch }} & csr_mscratch )
               | ({`E203_XLEN{rd_mcause   }} & csr_mcause   )
               | ({`E203_XLEN{rd_mbadaddr }} & csr_mbadaddr )
               | ({`E203_XLEN{rd_mip      }} & csr_mip      )
               | ({`E203_XLEN{rd_misa     }} & csr_misa      )
               | ({`E203_XLEN{rd_mvendorid}} & csr_mvendorid)
               | ({`E203_XLEN{rd_marchid  }} & csr_marchid  )
               | ({`E203_XLEN{rd_mimpid   }} & csr_mimpid   )
               | ({`E203_XLEN{rd_mhartid  }} & csr_mhartid  )
               | ({`E203_XLEN{rd_mcycle   }} & csr_mcycle   )
               | ({`E203_XLEN{rd_mcycleh  }} & csr_mcycleh  )
               | ({`E203_XLEN{rd_minstret }} & csr_minstret )
               | ({`E203_XLEN{rd_minstreth}} & csr_minstreth)
               | ({`E203_XLEN{rd_counterstop}} & csr_counterstop)// Self-defined
               | ({`E203_XLEN{rd_mcgstop}} & csr_mcgstop)// Self-defined
               | ({`E203_XLEN{rd_itcmnohold}} & csr_itcmnohold)// Self-defined
               | ({`E203_XLEN{rd_mdvnob2b}} & csr_mdvnob2b)// Self-defined
               | ({`E203_XLEN{rd_dcsr     }} & csr_dcsr    )
               | ({`E203_XLEN{rd_dpc      }} & csr_dpc     )
               | ({`E203_XLEN{rd_dscratch }} & csr_dscratch)
               ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:assign:000064 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=650-676
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v:grp:assign_cluster:000011 file=e203_hbirdv2/e203_exu_csr/e203_exu_csr.v lines=646-676


endmodule

