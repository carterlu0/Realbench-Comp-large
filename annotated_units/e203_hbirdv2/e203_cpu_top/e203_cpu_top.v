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
//  The CPU-TOP module to implement CPU and SRAMs
//
// ====================================================================

`include "e203_defines.v"

module e203_cpu_top(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:grp:port_section:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=31-234
  output [`E203_PC_SIZE-1:0] inspect_pc,
  output inspect_dbg_irq      ,
  output inspect_mem_cmd_valid,
  output inspect_mem_cmd_ready,
  output inspect_mem_rsp_valid,
  output inspect_mem_rsp_ready,
  output inspect_core_clk     ,

  output core_csr_clk         ,

    

    // If this signal is high, then indicate the Core have executed WFI instruction
    //   and entered into the sleep state
  output core_wfi,

    // This signal is from our self-defined COUNTERSTOP (0xBFF) CSR's TM field
    //   software can programe this CSR to turn off the MTIME timer to save power
    // If this signal is high, then the MTIME timer from CLINT module will stop counting
  output tm_stop,

    // This signal can be used to indicate the PC value for the core after reset
  input  [`E203_PC_SIZE-1:0] pc_rtvec,

  ///////////////////////////////////////
  // The interface to Debug Module: Begin
  //
    // The synced debug interrupt back to Debug module 
  output  dbg_irq_r,

    // The debug mode CSR registers control interface from/to Debug module
  output  [`E203_PC_SIZE-1:0] cmt_dpc,
  output  cmt_dpc_ena,
  output  [3-1:0] cmt_dcause,
  output  cmt_dcause_ena,
  output  wr_dcsr_ena    ,
  output  wr_dpc_ena     ,
  output  wr_dscratch_ena,
  output  [32-1:0] wr_csr_nxt    ,
  input  [32-1:0] dcsr_r    ,
  input  [`E203_PC_SIZE-1:0] dpc_r     ,
  input  [32-1:0] dscratch_r,

    // The debug mode control signals from Debug Module
  input  dbg_mode,
  input  dbg_halt_r,
  input  dbg_step_r,
  input  dbg_ebreakm_r,
  input  dbg_stopcycle,
  input  dbg_irq_a,
  // The interface to Debug Module: End


    // This signal can be used to indicate the HART ID for this core
  input  [`E203_HART_ID_W-1:0] core_mhartid,  

    // The External Interrupt signal from PLIC
  input  ext_irq_a,
    // The Software Interrupt signal from CLINT
  input  sft_irq_a,
    // The Timer Interrupt signal from CLINT
  input  tmr_irq_a,
  
  
    // The PMU control signal from PMU to control the TCM Shutdown
  input tcm_sd,
    // The PMU control signal from PMU to control the TCM Deep-Sleep
  input tcm_ds,
    
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=100-117
  `ifdef E203_HAS_ITCM_EXTITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=100-117
  //////////////////////////////////////////////////////////////
  // External interface (ICB) to access ITCM: Begin
  //    * Bus cmd channel
  input                          ext2itcm_icb_cmd_valid,
  output                         ext2itcm_icb_cmd_ready,
  input  [`E203_ITCM_ADDR_WIDTH-1:0]   ext2itcm_icb_cmd_addr, 
  input                          ext2itcm_icb_cmd_read, 
  input  [`E203_XLEN-1:0]        ext2itcm_icb_cmd_wdata,
  input  [`E203_XLEN/8-1:0]      ext2itcm_icb_cmd_wmask,
  //
  //    * Bus RSP channel
  output                         ext2itcm_icb_rsp_valid,
  input                          ext2itcm_icb_rsp_ready,
  output                         ext2itcm_icb_rsp_err  ,
  output [`E203_XLEN-1:0]        ext2itcm_icb_rsp_rdata,
  // External interface (ICB) to access ITCM: End
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=100-117
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=100-117

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000002 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=119-136
  `ifdef E203_HAS_DTCM_EXTITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000002 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=119-136
  //////////////////////////////////////////////////////////////
  // External interface (ICB) to access DTCM: Start
  //    * Bus cmd channel
  input                          ext2dtcm_icb_cmd_valid,
  output                         ext2dtcm_icb_cmd_ready,
  input  [`E203_DTCM_ADDR_WIDTH-1:0]   ext2dtcm_icb_cmd_addr, 
  input                          ext2dtcm_icb_cmd_read, 
  input  [`E203_XLEN-1:0]        ext2dtcm_icb_cmd_wdata,
  input  [`E203_XLEN/8-1:0]      ext2dtcm_icb_cmd_wmask,
  //
  //    * Bus RSP channel
  output                         ext2dtcm_icb_rsp_valid,
  input                          ext2dtcm_icb_rsp_ready,
  output                         ext2dtcm_icb_rsp_err  ,
  output [`E203_XLEN-1:0]        ext2dtcm_icb_rsp_rdata,
  // External interface (ICB) to access DTCM: End
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000002 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=119-136
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000002 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=119-136

  
  //////////////////////////////////////////////////////////////
  // The Private Peripheral Interface (ICB): Begin
  //
  //    * Bus cmd channel
  output                         ppi_icb_cmd_valid,
  input                          ppi_icb_cmd_ready,
  output [`E203_ADDR_SIZE-1:0]   ppi_icb_cmd_addr, 
  output                         ppi_icb_cmd_read, 
  output [`E203_XLEN-1:0]        ppi_icb_cmd_wdata,
  output [`E203_XLEN/8-1:0]      ppi_icb_cmd_wmask,
  //
  //    * Bus RSP channel
  input                          ppi_icb_rsp_valid,
  output                         ppi_icb_rsp_ready,
  input                          ppi_icb_rsp_err  ,
  input  [`E203_XLEN-1:0]        ppi_icb_rsp_rdata,
  // The Private Peripheral Interface (ICB): End

  //////////////////////////////////////////////////////////////
  // The CLINT Interface (ICB): Begin
  output                         clint_icb_cmd_valid,
  input                          clint_icb_cmd_ready,
  output [`E203_ADDR_SIZE-1:0]   clint_icb_cmd_addr, 
  output                         clint_icb_cmd_read, 
  output [`E203_XLEN-1:0]        clint_icb_cmd_wdata,
  output [`E203_XLEN/8-1:0]      clint_icb_cmd_wmask,
  //
  //    * Bus RSP channel
  input                          clint_icb_rsp_valid,
  output                         clint_icb_rsp_ready,
  input                          clint_icb_rsp_err  ,
  input  [`E203_XLEN-1:0]        clint_icb_rsp_rdata,
  // The CLINT Interface (ICB): End

  //////////////////////////////////////////////////////////////
  // The PLIC Interface (ICB): Begin
  output                         plic_icb_cmd_valid,
  input                          plic_icb_cmd_ready,
  output [`E203_ADDR_SIZE-1:0]   plic_icb_cmd_addr, 
  output                         plic_icb_cmd_read, 
  output [`E203_XLEN-1:0]        plic_icb_cmd_wdata,
  output [`E203_XLEN/8-1:0]      plic_icb_cmd_wmask,
  //
  //    * Bus RSP channel
  input                          plic_icb_rsp_valid,
  output                         plic_icb_rsp_ready,
  input                          plic_icb_rsp_err  ,
  input  [`E203_XLEN-1:0]        plic_icb_rsp_rdata,
  // The PLIC Interface (ICB): End


  //////////////////////////////////////////////////////////////
  // The Fast IO Interface (ICB): Begin
  //
  //    * Bus cmd channel
  output                         fio_icb_cmd_valid,
  input                          fio_icb_cmd_ready,
  output [`E203_ADDR_SIZE-1:0]   fio_icb_cmd_addr, 
  output                         fio_icb_cmd_read, 
  output [`E203_XLEN-1:0]        fio_icb_cmd_wdata,
  output [`E203_XLEN/8-1:0]      fio_icb_cmd_wmask,
  //
  //    * Bus RSP channel
  input                          fio_icb_rsp_valid,
  output                         fio_icb_rsp_ready,
  input                          fio_icb_rsp_err  ,
  input  [`E203_XLEN-1:0]        fio_icb_rsp_rdata,
  // The Fast IO Interface (ICB): End

  //////////////////////////////////////////////////////////////
  // The System Memory Interface (ICB): Begin
  //
  //    * Bus cmd channel
  output                         mem_icb_cmd_valid,
  input                          mem_icb_cmd_ready,
  output [`E203_ADDR_SIZE-1:0]   mem_icb_cmd_addr, 
  output                         mem_icb_cmd_read, 
  output [`E203_XLEN-1:0]        mem_icb_cmd_wdata,
  output [`E203_XLEN/8-1:0]      mem_icb_cmd_wmask,
  //
  //    * Bus RSP channel
  input                          mem_icb_rsp_valid,
  output                         mem_icb_rsp_ready,
  input                          mem_icb_rsp_err  ,
  input  [`E203_XLEN-1:0]        mem_icb_rsp_rdata,
  // The System Memory Interface (ICB): End


  // The test mode signal
  input  test_mode,

  // The Clock
  input  clk,

  // The low-level active reset signal, treated as async
  input  rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:grp:port_section:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=31-234
  );

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000004 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=237-251
  `ifdef E203_HAS_ITCM //{
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=238-302
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000004 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=237-251
  wire  itcm_ls;

  wire rst_itcm;

  wire                          itcm_ram_cs  ;
  wire                          itcm_ram_we  ;
  wire  [`E203_ITCM_RAM_AW-1:0] itcm_ram_addr;
  wire  [`E203_ITCM_RAM_MW-1:0] itcm_ram_wem ;
  wire  [`E203_ITCM_RAM_DW-1:0] itcm_ram_din ;
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000003 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=247-249
    `ifndef E203_HAS_LOCKSTEP//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000003 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=247-249
  wire  [`E203_ITCM_RAM_DW-1:0] itcm_ram_dout;
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000003 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=247-249
    `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000003 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=247-249
  wire                          clk_itcm_ram ;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000004 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=237-251
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000004 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=237-251

  
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000006 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=254-267
  `ifdef E203_HAS_DTCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000006 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=254-267
  wire  dtcm_ls;

  wire rst_dtcm;
  wire                          dtcm_ram_cs  ;
  wire                          dtcm_ram_we  ;
  wire  [`E203_DTCM_RAM_AW-1:0] dtcm_ram_addr;
  wire  [`E203_DTCM_RAM_MW-1:0] dtcm_ram_wem ;
  wire  [`E203_DTCM_RAM_DW-1:0] dtcm_ram_din ;
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000005 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=263-265
    `ifndef E203_HAS_LOCKSTEP//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000005 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=263-265
  wire  [`E203_DTCM_RAM_DW-1:0] dtcm_ram_dout;
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000005 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=263-265
    `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000005 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=263-265
  wire                          clk_dtcm_ram ;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000006 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=254-267
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000006 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=254-267


//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000012 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=270-302
`ifndef E203_HAS_LOCKSTEP//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000012 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=270-302
  wire ppi_icb_rsp_excl_ok   ;
  wire fio_icb_rsp_excl_ok   ;
  wire plic_icb_rsp_excl_ok  ;
  wire clint_icb_rsp_excl_ok ;
  wire mem_icb_rsp_excl_ok   ;


//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000007 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=278-281
    `ifdef E203_HAS_PPI
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000007 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=278-281
  wire ppi_icb_enable;
  wire [`E203_ADDR_SIZE-1:0] ppi_region_indic;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000007 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=278-281
    `endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000007 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=278-281

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000008 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=283-286
    `ifdef E203_HAS_PLIC
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000008 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=283-286
  wire plic_icb_enable;
  wire [`E203_ADDR_SIZE-1:0] plic_region_indic;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000008 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=283-286
    `endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000008 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=283-286

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000009 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=288-291
    `ifdef E203_HAS_CLINT
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000009 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=288-291
  wire clint_icb_enable;
  wire [`E203_ADDR_SIZE-1:0] clint_region_indic;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000009 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=288-291
    `endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000009 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=288-291

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000010 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=293-295
    `ifdef E203_HAS_MEM_ITF
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000010 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=293-295
  wire mem_icb_enable;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000010 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=293-295
    `endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000010 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=293-295

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000011 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=297-300
    `ifdef E203_HAS_FIO
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000011 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=297-300
  wire fio_icb_enable;
  wire [`E203_ADDR_SIZE-1:0] fio_region_indic;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000011 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=297-300
    `endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000011 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=297-300

//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000012 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=270-302
`endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000012 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=270-302
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=238-302

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=304-308
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:grp:bus_cluster:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=304-308
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=304-304
    assign ppi_icb_rsp_excl_ok   = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=304-304
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000002 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=305-305
    assign fio_icb_rsp_excl_ok   = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000002 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=305-305
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000003 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=306-306
    assign plic_icb_rsp_excl_ok  = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000003 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=306-306
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000004 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=307-307
    assign clint_icb_rsp_excl_ok = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000004 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=307-307
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000005 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=308-308
    assign mem_icb_rsp_excl_ok   = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000005 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=308-308
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=304-308
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:grp:bus_cluster:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=304-308


//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000013 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=311-316
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000013:br:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=311-313
    `ifdef E203_HAS_PPI
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=312-313
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000013 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=311-316
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000013:br:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=311-313
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000006 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=312-312
    assign ppi_icb_enable = 1'b1;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000006 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=312-312
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000007 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=313-313
    assign ppi_region_indic = `E203_PPI_ADDR_BASE;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000007 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=313-313
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000013:br:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=311-313
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000013:br:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=311-313
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=312-313
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000013:br:000002 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=314-315
    `else
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000013:br:000002 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=314-315
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000008 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=315-315
    assign ppi_icb_enable = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000008 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=315-315
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000013:br:000002 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=314-315
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000013:br:000002 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=314-315
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000013 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=311-316
    `endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000013 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=311-316

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000014 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=318-323
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000014:br:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=318-320
    `ifdef E203_HAS_PLIC
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=319-320
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000014 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=318-323
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000014:br:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=318-320
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000009 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=319-319
    assign plic_icb_enable = 1'b1;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000009 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=319-319
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000010 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=320-320
    assign plic_region_indic = `E203_PLIC_ADDR_BASE;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000010 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=320-320
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000014:br:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=318-320
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000014:br:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=318-320
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=319-320
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000014:br:000002 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=321-322
    `else
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000014:br:000002 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=321-322
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000011 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=322-322
    assign plic_icb_enable = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000011 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=322-322
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000014:br:000002 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=321-322
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000014:br:000002 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=321-322
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000014 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=318-323
    `endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000014 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=318-323

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000015 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=325-330
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000015:br:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=325-327
    `ifdef E203_HAS_CLINT
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:grp:assign_cluster:000004 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=326-327
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000015 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=325-330
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000015:br:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=325-327
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000012 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=326-326
    assign clint_icb_enable = 1'b1;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000012 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=326-326
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000013 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=327-327
    assign clint_region_indic = `E203_CLINT_ADDR_BASE;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000013 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=327-327
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000015:br:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=325-327
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000015:br:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=325-327
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:grp:assign_cluster:000004 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=326-327
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000015:br:000002 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=328-329
    `else
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000015:br:000002 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=328-329
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000014 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=329-329
    assign clint_icb_enable = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000014 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=329-329
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000015:br:000002 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=328-329
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000015:br:000002 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=328-329
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000015 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=325-330
    `endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000015 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=325-330

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000016 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=332-336
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000016:br:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=332-333
    `ifdef E203_HAS_MEM_ITF
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000016 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=332-336
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000016:br:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=332-333
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000015 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=333-333
    assign mem_icb_enable = 1'b1;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000015 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=333-333
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000016:br:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=332-333
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000016:br:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=332-333
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000016:br:000002 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=334-335
    `else
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000016:br:000002 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=334-335
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000016 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=335-335
    assign mem_icb_enable = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000016 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=335-335
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000016:br:000002 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=334-335
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000016:br:000002 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=334-335
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000016 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=332-336
    `endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000016 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=332-336

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000017 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=338-343
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000017:br:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=338-340
    `ifdef E203_HAS_FIO
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:grp:assign_cluster:000005 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=339-340
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000017 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=338-343
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000017:br:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=338-340
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000017 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=339-339
    assign fio_icb_enable = 1'b1;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000017 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=339-339
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000018 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=340-340
    assign fio_region_indic = `E203_FIO_ADDR_BASE;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000018 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=340-340
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000017:br:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=338-340
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000017:br:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=338-340
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:grp:assign_cluster:000005 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=339-340
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000017:br:000002 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=341-342
    `else
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000017:br:000002 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=341-342
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000019 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=342-342
    assign fio_icb_enable = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:assign:000019 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=342-342
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000017:br:000002 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=341-342
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000017:br:000002 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=341-342
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000017 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=338-343
    `endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000017 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=338-343

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:inst:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=345-551
  e203_cpu #(.MASTER(1)) u_e203_cpu(
    .inspect_pc               (inspect_pc), 
    .inspect_dbg_irq          (inspect_dbg_irq      ),
    .inspect_mem_cmd_valid    (inspect_mem_cmd_valid), 
    .inspect_mem_cmd_ready    (inspect_mem_cmd_ready), 
    .inspect_mem_rsp_valid    (inspect_mem_rsp_valid),
    .inspect_mem_rsp_ready    (inspect_mem_rsp_ready),
    .inspect_core_clk         (inspect_core_clk     ),


    .core_csr_clk          (core_csr_clk      ),


    .tm_stop (tm_stop),
    .pc_rtvec(pc_rtvec),
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000018 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=360-362
  `ifdef E203_HAS_ITCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000018 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=360-362
    .itcm_ls (itcm_ls),
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000018 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=360-362
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000018 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=360-362
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000019 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=363-365
  `ifdef E203_HAS_DTCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000019 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=363-365
    .dtcm_ls (dtcm_ls),
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000019 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=363-365
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000019 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=363-365
    .core_wfi        (core_wfi),
    .dbg_irq_r       (dbg_irq_r      ),

    .cmt_dpc         (cmt_dpc        ),
    .cmt_dpc_ena     (cmt_dpc_ena    ),
    .cmt_dcause      (cmt_dcause     ),
    .cmt_dcause_ena  (cmt_dcause_ena ),

    .wr_dcsr_ena     (wr_dcsr_ena    ),
    .wr_dpc_ena      (wr_dpc_ena     ),
    .wr_dscratch_ena (wr_dscratch_ena),


                                     
    .wr_csr_nxt      (wr_csr_nxt    ),
                                     
    .dcsr_r          (dcsr_r         ),
    .dpc_r           (dpc_r          ),
    .dscratch_r      (dscratch_r     ),

    .dbg_mode        (dbg_mode),
    .dbg_halt_r      (dbg_halt_r),
    .dbg_step_r      (dbg_step_r),
    .dbg_ebreakm_r   (dbg_ebreakm_r),
    .dbg_stopcycle   (dbg_stopcycle),

    .core_mhartid    (core_mhartid),  
    .dbg_irq_a       (dbg_irq_a),
    .ext_irq_a       (ext_irq_a),
    .sft_irq_a       (sft_irq_a),
    .tmr_irq_a       (tmr_irq_a),

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000020 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=398-410
  `ifdef E203_HAS_ITCM_EXTITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000020 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=398-410
    .ext2itcm_icb_cmd_valid  (ext2itcm_icb_cmd_valid),
    .ext2itcm_icb_cmd_ready  (ext2itcm_icb_cmd_ready),
    .ext2itcm_icb_cmd_addr   (ext2itcm_icb_cmd_addr ),
    .ext2itcm_icb_cmd_read   (ext2itcm_icb_cmd_read ),
    .ext2itcm_icb_cmd_wdata  (ext2itcm_icb_cmd_wdata),
    .ext2itcm_icb_cmd_wmask  (ext2itcm_icb_cmd_wmask),
    
    .ext2itcm_icb_rsp_valid  (ext2itcm_icb_rsp_valid),
    .ext2itcm_icb_rsp_ready  (ext2itcm_icb_rsp_ready),
    .ext2itcm_icb_rsp_err    (ext2itcm_icb_rsp_err  ),
    .ext2itcm_icb_rsp_rdata  (ext2itcm_icb_rsp_rdata),
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000020 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=398-410
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000020 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=398-410

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000021 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=412-424
  `ifdef E203_HAS_DTCM_EXTITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000021 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=412-424
    .ext2dtcm_icb_cmd_valid  (ext2dtcm_icb_cmd_valid),
    .ext2dtcm_icb_cmd_ready  (ext2dtcm_icb_cmd_ready),
    .ext2dtcm_icb_cmd_addr   (ext2dtcm_icb_cmd_addr ),
    .ext2dtcm_icb_cmd_read   (ext2dtcm_icb_cmd_read ),
    .ext2dtcm_icb_cmd_wdata  (ext2dtcm_icb_cmd_wdata),
    .ext2dtcm_icb_cmd_wmask  (ext2dtcm_icb_cmd_wmask),
    
    .ext2dtcm_icb_rsp_valid  (ext2dtcm_icb_rsp_valid),
    .ext2dtcm_icb_rsp_ready  (ext2dtcm_icb_rsp_ready),
    .ext2dtcm_icb_rsp_err    (ext2dtcm_icb_rsp_err  ),
    .ext2dtcm_icb_rsp_rdata  (ext2dtcm_icb_rsp_rdata),
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000021 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=412-424
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000021 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=412-424


    .ppi_region_indic      (ppi_region_indic),
    .ppi_icb_enable        (ppi_icb_enable),
    .ppi_icb_cmd_valid     (ppi_icb_cmd_valid),
    .ppi_icb_cmd_ready     (ppi_icb_cmd_ready),
    .ppi_icb_cmd_addr      (ppi_icb_cmd_addr ),
    .ppi_icb_cmd_read      (ppi_icb_cmd_read ),
    .ppi_icb_cmd_wdata     (ppi_icb_cmd_wdata),
    .ppi_icb_cmd_wmask     (ppi_icb_cmd_wmask),
    .ppi_icb_cmd_lock      (),
    .ppi_icb_cmd_excl      (),
    .ppi_icb_cmd_size      (),
    
    .ppi_icb_rsp_valid     (ppi_icb_rsp_valid),
    .ppi_icb_rsp_ready     (ppi_icb_rsp_ready),
    .ppi_icb_rsp_err       (ppi_icb_rsp_err  ),
    .ppi_icb_rsp_excl_ok   (ppi_icb_rsp_excl_ok  ),
    .ppi_icb_rsp_rdata     (ppi_icb_rsp_rdata),

    .clint_region_indic      (clint_region_indic),
    .clint_icb_enable        (clint_icb_enable),
    .clint_icb_cmd_valid     (clint_icb_cmd_valid),
    .clint_icb_cmd_ready     (clint_icb_cmd_ready),
    .clint_icb_cmd_addr      (clint_icb_cmd_addr ),
    .clint_icb_cmd_read      (clint_icb_cmd_read ),
    .clint_icb_cmd_wdata     (clint_icb_cmd_wdata),
    .clint_icb_cmd_wmask     (clint_icb_cmd_wmask),
    .clint_icb_cmd_lock      (),
    .clint_icb_cmd_excl      (),
    .clint_icb_cmd_size      (),
    
    .clint_icb_rsp_valid     (clint_icb_rsp_valid),
    .clint_icb_rsp_ready     (clint_icb_rsp_ready),
    .clint_icb_rsp_err       (clint_icb_rsp_err  ),
    .clint_icb_rsp_excl_ok   (clint_icb_rsp_excl_ok  ),
    .clint_icb_rsp_rdata     (clint_icb_rsp_rdata),

    .plic_region_indic      (plic_region_indic),
    .plic_icb_enable        (plic_icb_enable),
    .plic_icb_cmd_valid     (plic_icb_cmd_valid),
    .plic_icb_cmd_ready     (plic_icb_cmd_ready),
    .plic_icb_cmd_addr      (plic_icb_cmd_addr ),
    .plic_icb_cmd_read      (plic_icb_cmd_read ),
    .plic_icb_cmd_wdata     (plic_icb_cmd_wdata),
    .plic_icb_cmd_wmask     (plic_icb_cmd_wmask),
    .plic_icb_cmd_lock      (),
    .plic_icb_cmd_excl      (),
    .plic_icb_cmd_size      (),
    
    .plic_icb_rsp_valid     (plic_icb_rsp_valid),
    .plic_icb_rsp_ready     (plic_icb_rsp_ready),
    .plic_icb_rsp_err       (plic_icb_rsp_err  ),
    .plic_icb_rsp_excl_ok   (plic_icb_rsp_excl_ok  ),
    .plic_icb_rsp_rdata     (plic_icb_rsp_rdata),


//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000022 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=482-500
  `ifdef E203_HAS_FIO //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000022 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=482-500
    .fio_icb_enable        (fio_icb_enable),
    .fio_region_indic      (fio_region_indic),
    .fio_icb_cmd_valid     (fio_icb_cmd_valid),
    .fio_icb_cmd_ready     (fio_icb_cmd_ready),
    .fio_icb_cmd_addr      (fio_icb_cmd_addr ),
    .fio_icb_cmd_read      (fio_icb_cmd_read ),
    .fio_icb_cmd_wdata     (fio_icb_cmd_wdata),
    .fio_icb_cmd_wmask     (fio_icb_cmd_wmask),
    .fio_icb_cmd_lock      (),
    .fio_icb_cmd_excl      (),
    .fio_icb_cmd_size      (),
    
    .fio_icb_rsp_valid     (fio_icb_rsp_valid),
    .fio_icb_rsp_ready     (fio_icb_rsp_ready),
    .fio_icb_rsp_err       (fio_icb_rsp_err  ),
    .fio_icb_rsp_excl_ok   (fio_icb_rsp_excl_ok  ),
    .fio_icb_rsp_rdata     (fio_icb_rsp_rdata),
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000022 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=482-500
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000022 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=482-500

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000023 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=502-521
  `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000023 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=502-521
    .mem_icb_enable     (mem_icb_enable),
    .mem_icb_cmd_valid  (mem_icb_cmd_valid),
    .mem_icb_cmd_ready  (mem_icb_cmd_ready),
    .mem_icb_cmd_addr   (mem_icb_cmd_addr ),
    .mem_icb_cmd_read   (mem_icb_cmd_read ),
    .mem_icb_cmd_wdata  (mem_icb_cmd_wdata),
    .mem_icb_cmd_wmask  (mem_icb_cmd_wmask),
    .mem_icb_cmd_lock   (),
    .mem_icb_cmd_excl   (),
    .mem_icb_cmd_size   (),
    .mem_icb_cmd_burst  (),
    .mem_icb_cmd_beat   (),
    
    .mem_icb_rsp_valid  (mem_icb_rsp_valid),
    .mem_icb_rsp_ready  (mem_icb_rsp_ready),
    .mem_icb_rsp_err    (mem_icb_rsp_err  ),
    .mem_icb_rsp_excl_ok(mem_icb_rsp_excl_ok  ),
    .mem_icb_rsp_rdata  (mem_icb_rsp_rdata),
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000023 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=502-521
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000023 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=502-521

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000024 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=523-532
  `ifdef E203_HAS_ITCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000024 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=523-532
    .itcm_ram_cs   (itcm_ram_cs  ),
    .itcm_ram_we   (itcm_ram_we  ),
    .itcm_ram_addr (itcm_ram_addr), 
    .itcm_ram_wem  (itcm_ram_wem ),
    .itcm_ram_din  (itcm_ram_din ),         
    .itcm_ram_dout (itcm_ram_dout),
    .clk_itcm_ram  (clk_itcm_ram ),  
    .rst_itcm(rst_itcm),
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000024 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=523-532
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000024 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=523-532

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000025 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=534-543
  `ifdef E203_HAS_DTCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000025 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=534-543
    .dtcm_ram_cs   (dtcm_ram_cs  ),
    .dtcm_ram_we   (dtcm_ram_we  ),
    .dtcm_ram_addr (dtcm_ram_addr), 
    .dtcm_ram_wem  (dtcm_ram_wem ),
    .dtcm_ram_din  (dtcm_ram_din ),         
    .dtcm_ram_dout (dtcm_ram_dout),
    .clk_dtcm_ram  (clk_dtcm_ram ),  
    .rst_dtcm(rst_dtcm),
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000025 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=534-543
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000025 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=534-543

    .test_mode     (test_mode), 
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000026 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=546-547
  `ifndef E203_HAS_LOCKSTEP//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000026 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=546-547
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000026 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=546-547
  `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000026 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=546-547
    .rst_n         (rst_n),
    .clk           (clk  ) 

  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:inst:000001 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=345-551

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:inst:000002 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=553-584
  e203_srams u_e203_srams(
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000027 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=554-567
  `ifdef E203_HAS_DTCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000027 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=554-567
   .dtcm_ram_sd (tcm_sd),
   .dtcm_ram_ds (tcm_ds),
   .dtcm_ram_ls (dtcm_ls),

   .dtcm_ram_cs   (dtcm_ram_cs  ),
   .dtcm_ram_we   (dtcm_ram_we  ),
   .dtcm_ram_addr (dtcm_ram_addr), 
   .dtcm_ram_wem  (dtcm_ram_wem ),
   .dtcm_ram_din  (dtcm_ram_din ),         
   .dtcm_ram_dout (dtcm_ram_dout),
   .clk_dtcm_ram  (clk_dtcm_ram ),  
   .rst_dtcm(rst_dtcm),
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000027 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=554-567
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000027 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=554-567

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000028 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=569-582
  `ifdef E203_HAS_ITCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000028 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=569-582
   .itcm_ram_sd (tcm_sd),
   .itcm_ram_ds (tcm_ds),
   .itcm_ram_ls (itcm_ls),

   .itcm_ram_cs   (itcm_ram_cs  ),
   .itcm_ram_we   (itcm_ram_we  ),
   .itcm_ram_addr (itcm_ram_addr), 
   .itcm_ram_wem  (itcm_ram_wem ),
   .itcm_ram_din  (itcm_ram_din ),         
   .itcm_ram_dout (itcm_ram_dout),
   .clk_itcm_ram  (clk_itcm_ram ),  
   .rst_itcm(rst_itcm),
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000028 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=569-582
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:pp_blk:000028 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=569-582
   .test_mode (test_mode) 
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v:inst:000002 file=e203_hbirdv2/e203_cpu_top/e203_cpu_top.v lines=553-584

  


endmodule
