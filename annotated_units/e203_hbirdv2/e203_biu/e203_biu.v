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
//  The BIU module control the ICB request to external memory system
//
// ====================================================================
`include "e203_defines.v"

module e203_biu(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/e203_biu/e203_biu.v:grp:port_section:000001 file=e203_hbirdv2/e203_biu/e203_biu.v lines=30-212

  output                         biu_active,
  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // The ICB Interface from LSU 
  input                          lsu2biu_icb_cmd_valid,
  output                         lsu2biu_icb_cmd_ready,
  input  [`E203_ADDR_SIZE-1:0]   lsu2biu_icb_cmd_addr, 
  input                          lsu2biu_icb_cmd_read, 
  input  [`E203_XLEN-1:0]        lsu2biu_icb_cmd_wdata,
  input  [`E203_XLEN/8-1:0]      lsu2biu_icb_cmd_wmask,
  input  [1:0]                   lsu2biu_icb_cmd_burst,
  input  [1:0]                   lsu2biu_icb_cmd_beat,
  input                          lsu2biu_icb_cmd_lock,
  input                          lsu2biu_icb_cmd_excl,
  input  [1:0]                   lsu2biu_icb_cmd_size,
  
  output                         lsu2biu_icb_rsp_valid,
  input                          lsu2biu_icb_rsp_ready,
  output                         lsu2biu_icb_rsp_err  ,
  output                         lsu2biu_icb_rsp_excl_ok,
  output [`E203_XLEN-1:0]        lsu2biu_icb_rsp_rdata,

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000001 file=e203_hbirdv2/e203_biu/e203_biu.v lines=53-79
  `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000001 file=e203_hbirdv2/e203_biu/e203_biu.v lines=53-79
  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // the icb interface from ifetch 
  //
  //    * bus cmd channel
  input                          ifu2biu_icb_cmd_valid,
  output                         ifu2biu_icb_cmd_ready,
  input  [`E203_ADDR_SIZE-1:0]   ifu2biu_icb_cmd_addr, 
  input                          ifu2biu_icb_cmd_read, 
  input  [`E203_XLEN-1:0]        ifu2biu_icb_cmd_wdata,
  input  [`E203_XLEN/8-1:0]      ifu2biu_icb_cmd_wmask,
  input  [1:0]                   ifu2biu_icb_cmd_burst,
  input  [1:0]                   ifu2biu_icb_cmd_beat,
  input                          ifu2biu_icb_cmd_lock,
  input                          ifu2biu_icb_cmd_excl,
  input  [1:0]                   ifu2biu_icb_cmd_size,
  //
  //    * bus rsp channel
  output                         ifu2biu_icb_rsp_valid,
  input                          ifu2biu_icb_rsp_ready,
  output                         ifu2biu_icb_rsp_err  ,
  output                         ifu2biu_icb_rsp_excl_ok,
  output [`E203_XLEN-1:0]        ifu2biu_icb_rsp_rdata,

  //output                         ifu2biu_replay,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000001 file=e203_hbirdv2/e203_biu/e203_biu.v lines=53-79
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000001 file=e203_hbirdv2/e203_biu/e203_biu.v lines=53-79



  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // The ICB Interface to Private Peripheral Interface
  //
  input [`E203_ADDR_SIZE-1:0]    ppi_region_indic,
  input                          ppi_icb_enable,
  //    * Bus cmd channel
  output                         ppi_icb_cmd_valid,
  input                          ppi_icb_cmd_ready,
  output [`E203_ADDR_SIZE-1:0]   ppi_icb_cmd_addr, 
  output                         ppi_icb_cmd_read, 
  output [`E203_XLEN-1:0]        ppi_icb_cmd_wdata,
  output [`E203_XLEN/8-1:0]      ppi_icb_cmd_wmask,
  output [1:0]                   ppi_icb_cmd_burst,
  output [1:0]                   ppi_icb_cmd_beat,
  output                         ppi_icb_cmd_lock,
  output                         ppi_icb_cmd_excl,
  output [1:0]                   ppi_icb_cmd_size,
  //
  //    * Bus RSP channel
  input                          ppi_icb_rsp_valid,
  output                         ppi_icb_rsp_ready,
  input                          ppi_icb_rsp_err  ,
  input                          ppi_icb_rsp_excl_ok,
  input  [`E203_XLEN-1:0]        ppi_icb_rsp_rdata,

    //
  input [`E203_ADDR_SIZE-1:0]    clint_region_indic,
  input                          clint_icb_enable,
  //    * Bus cmd channel
  output                         clint_icb_cmd_valid,
  input                          clint_icb_cmd_ready,
  output [`E203_ADDR_SIZE-1:0]   clint_icb_cmd_addr, 
  output                         clint_icb_cmd_read, 
  output [`E203_XLEN-1:0]        clint_icb_cmd_wdata,
  output [`E203_XLEN/8-1:0]      clint_icb_cmd_wmask,
  output [1:0]                   clint_icb_cmd_burst,
  output [1:0]                   clint_icb_cmd_beat,
  output                         clint_icb_cmd_lock,
  output                         clint_icb_cmd_excl,
  output [1:0]                   clint_icb_cmd_size,
  //
  //    * Bus RSP channel
  input                          clint_icb_rsp_valid,
  output                         clint_icb_rsp_ready,
  input                          clint_icb_rsp_err  ,
  input                          clint_icb_rsp_excl_ok,
  input  [`E203_XLEN-1:0]        clint_icb_rsp_rdata,

      //
  input [`E203_ADDR_SIZE-1:0]    plic_region_indic,
  input                          plic_icb_enable,
  //    * Bus cmd channel
  output                         plic_icb_cmd_valid,
  input                          plic_icb_cmd_ready,
  output [`E203_ADDR_SIZE-1:0]   plic_icb_cmd_addr, 
  output                         plic_icb_cmd_read, 
  output [`E203_XLEN-1:0]        plic_icb_cmd_wdata,
  output [`E203_XLEN/8-1:0]      plic_icb_cmd_wmask,
  output [1:0]                   plic_icb_cmd_burst,
  output [1:0]                   plic_icb_cmd_beat,
  output                         plic_icb_cmd_lock,
  output                         plic_icb_cmd_excl,
  output [1:0]                   plic_icb_cmd_size,
  //
  //    * Bus RSP channel
  input                          plic_icb_rsp_valid,
  output                         plic_icb_rsp_ready,
  input                          plic_icb_rsp_err  ,
  input                          plic_icb_rsp_excl_ok,
  input  [`E203_XLEN-1:0]        plic_icb_rsp_rdata,


//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000002 file=e203_hbirdv2/e203_biu/e203_biu.v lines=156-182
  `ifdef E203_HAS_FIO //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000002 file=e203_hbirdv2/e203_biu/e203_biu.v lines=156-182
  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // The ICB Interface to Fast I/O
  input [`E203_ADDR_SIZE-1:0]    fio_region_indic,
  input                          fio_icb_enable,
  //
  //    * Bus cmd channel
  output                         fio_icb_cmd_valid,
  input                          fio_icb_cmd_ready,
  output [`E203_ADDR_SIZE-1:0]   fio_icb_cmd_addr, 
  output                         fio_icb_cmd_read, 
  output [`E203_XLEN-1:0]        fio_icb_cmd_wdata,
  output [`E203_XLEN/8-1:0]      fio_icb_cmd_wmask,
  output [1:0]                   fio_icb_cmd_burst,
  output [1:0]                   fio_icb_cmd_beat,
  output                         fio_icb_cmd_lock,
  output                         fio_icb_cmd_excl,
  output [1:0]                   fio_icb_cmd_size,
  //
  //    * Bus RSP channel
  input                          fio_icb_rsp_valid,
  output                         fio_icb_rsp_ready,
  input                          fio_icb_rsp_err  ,
  input                          fio_icb_rsp_excl_ok,
  input  [`E203_XLEN-1:0]        fio_icb_rsp_rdata,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000002 file=e203_hbirdv2/e203_biu/e203_biu.v lines=156-182
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000002 file=e203_hbirdv2/e203_biu/e203_biu.v lines=156-182

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000003 file=e203_hbirdv2/e203_biu/e203_biu.v lines=184-209
  `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000003 file=e203_hbirdv2/e203_biu/e203_biu.v lines=184-209
  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // The ICB Interface from Ifetch 
  //
  input                          mem_icb_enable,
  //    * Bus cmd channel
  output                         mem_icb_cmd_valid,
  input                          mem_icb_cmd_ready,
  output [`E203_ADDR_SIZE-1:0]   mem_icb_cmd_addr, 
  output                         mem_icb_cmd_read, 
  output [`E203_XLEN-1:0]        mem_icb_cmd_wdata,
  output [`E203_XLEN/8-1:0]      mem_icb_cmd_wmask,
  output [1:0]                   mem_icb_cmd_burst,
  output [1:0]                   mem_icb_cmd_beat,
  output                         mem_icb_cmd_lock,
  output                         mem_icb_cmd_excl,
  output [1:0]                   mem_icb_cmd_size,
  //
  //    * Bus RSP channel
  input                          mem_icb_rsp_valid,
  output                         mem_icb_rsp_ready,
  input                          mem_icb_rsp_err  ,
  input                          mem_icb_rsp_excl_ok,
  input  [`E203_XLEN-1:0]        mem_icb_rsp_rdata,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000003 file=e203_hbirdv2/e203_biu/e203_biu.v lines=184-209
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000003 file=e203_hbirdv2/e203_biu/e203_biu.v lines=184-209

  input  clk,
  input  rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/e203_biu/e203_biu.v:grp:port_section:000001 file=e203_hbirdv2/e203_biu/e203_biu.v lines=30-212
  );


//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000004 file=e203_hbirdv2/e203_biu/e203_biu.v lines=216-222
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000004:br:000001 file=e203_hbirdv2/e203_biu/e203_biu.v lines=216-218
  `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/e203_biu/e203_biu.v:grp:param_decl:000001 file=e203_hbirdv2/e203_biu/e203_biu.v lines=217-241
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000004 file=e203_hbirdv2/e203_biu/e203_biu.v lines=216-222
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000004:br:000001 file=e203_hbirdv2/e203_biu/e203_biu.v lines=216-218
      localparam BIU_ARBT_I_NUM = 2;
      localparam BIU_ARBT_I_PTR_W = 1;
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000004:br:000001 file=e203_hbirdv2/e203_biu/e203_biu.v lines=216-218
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000004:br:000001 file=e203_hbirdv2/e203_biu/e203_biu.v lines=216-218
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000004:br:000002 file=e203_hbirdv2/e203_biu/e203_biu.v lines=219-221
  `else//}{
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000004:br:000002 file=e203_hbirdv2/e203_biu/e203_biu.v lines=219-221
      localparam BIU_ARBT_I_NUM = 1;
      localparam BIU_ARBT_I_PTR_W = 1;
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000004:br:000002 file=e203_hbirdv2/e203_biu/e203_biu.v lines=219-221
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000004:br:000002 file=e203_hbirdv2/e203_biu/e203_biu.v lines=219-221
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000004 file=e203_hbirdv2/e203_biu/e203_biu.v lines=216-222
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000004 file=e203_hbirdv2/e203_biu/e203_biu.v lines=216-222

  
  // The SPLT_NUM is the sum of following components
  //   * ppi, clint, plic, SystemITF, Fast-IO, IFU-err 
      localparam BIU_SPLT_I_NUM_0 = 4;

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000005 file=e203_hbirdv2/e203_biu/e203_biu.v lines=229-233
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000005:br:000001 file=e203_hbirdv2/e203_biu/e203_biu.v lines=229-230
  `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000005 file=e203_hbirdv2/e203_biu/e203_biu.v lines=229-233
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000005:br:000001 file=e203_hbirdv2/e203_biu/e203_biu.v lines=229-230
      localparam BIU_SPLT_I_NUM_1 = (BIU_SPLT_I_NUM_0 + 1);
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000005:br:000001 file=e203_hbirdv2/e203_biu/e203_biu.v lines=229-230
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000005:br:000001 file=e203_hbirdv2/e203_biu/e203_biu.v lines=229-230
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000005:br:000002 file=e203_hbirdv2/e203_biu/e203_biu.v lines=231-232
  `else//}{
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000005:br:000002 file=e203_hbirdv2/e203_biu/e203_biu.v lines=231-232
      localparam BIU_SPLT_I_NUM_1 = BIU_SPLT_I_NUM_0;
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000005:br:000002 file=e203_hbirdv2/e203_biu/e203_biu.v lines=231-232
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000005:br:000002 file=e203_hbirdv2/e203_biu/e203_biu.v lines=231-232
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000005 file=e203_hbirdv2/e203_biu/e203_biu.v lines=229-233
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000005 file=e203_hbirdv2/e203_biu/e203_biu.v lines=229-233

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000006 file=e203_hbirdv2/e203_biu/e203_biu.v lines=235-239
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000006:br:000001 file=e203_hbirdv2/e203_biu/e203_biu.v lines=235-236
  `ifdef E203_HAS_FIO //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000006 file=e203_hbirdv2/e203_biu/e203_biu.v lines=235-239
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000006:br:000001 file=e203_hbirdv2/e203_biu/e203_biu.v lines=235-236
      localparam BIU_SPLT_I_NUM_2 = (BIU_SPLT_I_NUM_1 + 1);
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000006:br:000001 file=e203_hbirdv2/e203_biu/e203_biu.v lines=235-236
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000006:br:000001 file=e203_hbirdv2/e203_biu/e203_biu.v lines=235-236
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000006:br:000002 file=e203_hbirdv2/e203_biu/e203_biu.v lines=237-238
  `else//}{
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000006:br:000002 file=e203_hbirdv2/e203_biu/e203_biu.v lines=237-238
      localparam BIU_SPLT_I_NUM_2 = BIU_SPLT_I_NUM_1;
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000006:br:000002 file=e203_hbirdv2/e203_biu/e203_biu.v lines=237-238
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000006:br:000002 file=e203_hbirdv2/e203_biu/e203_biu.v lines=237-238
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000006 file=e203_hbirdv2/e203_biu/e203_biu.v lines=235-239
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000006 file=e203_hbirdv2/e203_biu/e203_biu.v lines=235-239

      localparam BIU_SPLT_I_NUM   = BIU_SPLT_I_NUM_2;
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/e203_biu/e203_biu.v:grp:param_decl:000001 file=e203_hbirdv2/e203_biu/e203_biu.v lines=217-241

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_biu/e203_biu.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_biu/e203_biu.v lines=243-298
  wire                         ifuerr_icb_cmd_valid;
  wire                         ifuerr_icb_cmd_ready;
  wire [`E203_ADDR_SIZE-1:0]   ifuerr_icb_cmd_addr; 
  wire                         ifuerr_icb_cmd_read; 
  wire [2-1:0]                 ifuerr_icb_cmd_burst;
  wire [2-1:0]                 ifuerr_icb_cmd_beat;
  wire [`E203_XLEN-1:0]        ifuerr_icb_cmd_wdata;
  wire [`E203_XLEN/8-1:0]      ifuerr_icb_cmd_wmask;
  wire                         ifuerr_icb_cmd_lock;
  wire                         ifuerr_icb_cmd_excl;
  wire [1:0]                   ifuerr_icb_cmd_size;
  
  wire                         ifuerr_icb_rsp_valid;
  wire                         ifuerr_icb_rsp_ready;
  wire                         ifuerr_icb_rsp_err  ;
  wire                         ifuerr_icb_rsp_excl_ok;
  wire [`E203_XLEN-1:0]        ifuerr_icb_rsp_rdata;

  wire arbt_icb_cmd_valid;
  wire arbt_icb_cmd_ready;
  wire [`E203_ADDR_SIZE-1:0] arbt_icb_cmd_addr;
  wire arbt_icb_cmd_read;
  wire [`E203_XLEN-1:0] arbt_icb_cmd_wdata;
  wire [`E203_XLEN/8-1:0] arbt_icb_cmd_wmask;
  wire [1:0] arbt_icb_cmd_burst;
  wire [1:0] arbt_icb_cmd_beat;
  wire arbt_icb_cmd_lock;
  wire arbt_icb_cmd_excl;
  wire [1:0] arbt_icb_cmd_size;
  wire arbt_icb_cmd_usr;


  wire arbt_icb_rsp_valid;
  wire arbt_icb_rsp_ready;
  wire arbt_icb_rsp_err;
  wire arbt_icb_rsp_excl_ok;
  wire [`E203_XLEN-1:0] arbt_icb_rsp_rdata;

  wire [BIU_ARBT_I_NUM*1-1:0] arbt_bus_icb_cmd_valid;
  wire [BIU_ARBT_I_NUM*1-1:0] arbt_bus_icb_cmd_ready;
  wire [BIU_ARBT_I_NUM*`E203_ADDR_SIZE-1:0] arbt_bus_icb_cmd_addr;
  wire [BIU_ARBT_I_NUM*1-1:0] arbt_bus_icb_cmd_read;
  wire [BIU_ARBT_I_NUM*`E203_XLEN-1:0] arbt_bus_icb_cmd_wdata;
  wire [BIU_ARBT_I_NUM*`E203_XLEN/8-1:0] arbt_bus_icb_cmd_wmask;
  wire [BIU_ARBT_I_NUM*2-1:0] arbt_bus_icb_cmd_burst;
  wire [BIU_ARBT_I_NUM*2-1:0] arbt_bus_icb_cmd_beat;
  wire [BIU_ARBT_I_NUM*1-1:0] arbt_bus_icb_cmd_lock;
  wire [BIU_ARBT_I_NUM*1-1:0] arbt_bus_icb_cmd_excl;
  wire [BIU_ARBT_I_NUM*2-1:0] arbt_bus_icb_cmd_size;
  wire [BIU_ARBT_I_NUM*1-1:0] arbt_bus_icb_cmd_usr;

  wire [BIU_ARBT_I_NUM*1-1:0] arbt_bus_icb_rsp_valid;
  wire [BIU_ARBT_I_NUM*1-1:0] arbt_bus_icb_rsp_ready;
  wire [BIU_ARBT_I_NUM*1-1:0] arbt_bus_icb_rsp_err;
  wire [BIU_ARBT_I_NUM*1-1:0] arbt_bus_icb_rsp_excl_ok;
  wire [BIU_ARBT_I_NUM*`E203_XLEN-1:0] arbt_bus_icb_rsp_rdata;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_biu/e203_biu.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_biu/e203_biu.v lines=243-298

  //CMD Channel
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_biu/e203_biu.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_biu/e203_biu.v lines=301-380
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/e203_biu/e203_biu.v:grp:bus_cluster:000001 file=e203_hbirdv2/e203_biu/e203_biu.v lines=301-380
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000001 file=e203_hbirdv2/e203_biu/e203_biu.v lines=301-308
  assign arbt_bus_icb_cmd_valid =
      // The  LSU take higher priority
                           {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000007 file=e203_hbirdv2/e203_biu/e203_biu.v lines=304-306
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000007 file=e203_hbirdv2/e203_biu/e203_biu.v lines=304-306
                             ifu2biu_icb_cmd_valid,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000007 file=e203_hbirdv2/e203_biu/e203_biu.v lines=304-306
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000007 file=e203_hbirdv2/e203_biu/e203_biu.v lines=304-306
                             lsu2biu_icb_cmd_valid
                           } ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000001 file=e203_hbirdv2/e203_biu/e203_biu.v lines=301-308

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000002 file=e203_hbirdv2/e203_biu/e203_biu.v lines=310-316
  assign arbt_bus_icb_cmd_addr =
                           {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000008 file=e203_hbirdv2/e203_biu/e203_biu.v lines=312-314
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000008 file=e203_hbirdv2/e203_biu/e203_biu.v lines=312-314
                             ifu2biu_icb_cmd_addr,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000008 file=e203_hbirdv2/e203_biu/e203_biu.v lines=312-314
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000008 file=e203_hbirdv2/e203_biu/e203_biu.v lines=312-314
                             lsu2biu_icb_cmd_addr
                           } ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000002 file=e203_hbirdv2/e203_biu/e203_biu.v lines=310-316

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000003 file=e203_hbirdv2/e203_biu/e203_biu.v lines=318-324
  assign arbt_bus_icb_cmd_read =
                           {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000009 file=e203_hbirdv2/e203_biu/e203_biu.v lines=320-322
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000009 file=e203_hbirdv2/e203_biu/e203_biu.v lines=320-322
                             ifu2biu_icb_cmd_read,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000009 file=e203_hbirdv2/e203_biu/e203_biu.v lines=320-322
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000009 file=e203_hbirdv2/e203_biu/e203_biu.v lines=320-322
                             lsu2biu_icb_cmd_read
                           } ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000003 file=e203_hbirdv2/e203_biu/e203_biu.v lines=318-324

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000004 file=e203_hbirdv2/e203_biu/e203_biu.v lines=326-332
  assign arbt_bus_icb_cmd_wdata =
                           {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000010 file=e203_hbirdv2/e203_biu/e203_biu.v lines=328-330
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000010 file=e203_hbirdv2/e203_biu/e203_biu.v lines=328-330
                             ifu2biu_icb_cmd_wdata,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000010 file=e203_hbirdv2/e203_biu/e203_biu.v lines=328-330
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000010 file=e203_hbirdv2/e203_biu/e203_biu.v lines=328-330
                             lsu2biu_icb_cmd_wdata
                           } ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000004 file=e203_hbirdv2/e203_biu/e203_biu.v lines=326-332

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000005 file=e203_hbirdv2/e203_biu/e203_biu.v lines=334-340
  assign arbt_bus_icb_cmd_wmask =
                           {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000011 file=e203_hbirdv2/e203_biu/e203_biu.v lines=336-338
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000011 file=e203_hbirdv2/e203_biu/e203_biu.v lines=336-338
                             ifu2biu_icb_cmd_wmask,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000011 file=e203_hbirdv2/e203_biu/e203_biu.v lines=336-338
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000011 file=e203_hbirdv2/e203_biu/e203_biu.v lines=336-338
                             lsu2biu_icb_cmd_wmask
                           } ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000005 file=e203_hbirdv2/e203_biu/e203_biu.v lines=334-340
                         
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000006 file=e203_hbirdv2/e203_biu/e203_biu.v lines=342-348
  assign arbt_bus_icb_cmd_burst =
                           {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000012 file=e203_hbirdv2/e203_biu/e203_biu.v lines=344-346
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000012 file=e203_hbirdv2/e203_biu/e203_biu.v lines=344-346
                             ifu2biu_icb_cmd_burst,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000012 file=e203_hbirdv2/e203_biu/e203_biu.v lines=344-346
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000012 file=e203_hbirdv2/e203_biu/e203_biu.v lines=344-346
                             lsu2biu_icb_cmd_burst
                           } ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000006 file=e203_hbirdv2/e203_biu/e203_biu.v lines=342-348
                         
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000007 file=e203_hbirdv2/e203_biu/e203_biu.v lines=350-356
  assign arbt_bus_icb_cmd_beat =
                           {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000013 file=e203_hbirdv2/e203_biu/e203_biu.v lines=352-354
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000013 file=e203_hbirdv2/e203_biu/e203_biu.v lines=352-354
                             ifu2biu_icb_cmd_beat,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000013 file=e203_hbirdv2/e203_biu/e203_biu.v lines=352-354
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000013 file=e203_hbirdv2/e203_biu/e203_biu.v lines=352-354
                             lsu2biu_icb_cmd_beat
                           } ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000007 file=e203_hbirdv2/e203_biu/e203_biu.v lines=350-356
                         
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000008 file=e203_hbirdv2/e203_biu/e203_biu.v lines=358-364
  assign arbt_bus_icb_cmd_lock =
                           {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000014 file=e203_hbirdv2/e203_biu/e203_biu.v lines=360-362
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000014 file=e203_hbirdv2/e203_biu/e203_biu.v lines=360-362
                             ifu2biu_icb_cmd_lock,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000014 file=e203_hbirdv2/e203_biu/e203_biu.v lines=360-362
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000014 file=e203_hbirdv2/e203_biu/e203_biu.v lines=360-362
                             lsu2biu_icb_cmd_lock
                           } ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000008 file=e203_hbirdv2/e203_biu/e203_biu.v lines=358-364

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000009 file=e203_hbirdv2/e203_biu/e203_biu.v lines=366-372
  assign arbt_bus_icb_cmd_excl =
                           {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000015 file=e203_hbirdv2/e203_biu/e203_biu.v lines=368-370
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000015 file=e203_hbirdv2/e203_biu/e203_biu.v lines=368-370
                             ifu2biu_icb_cmd_excl,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000015 file=e203_hbirdv2/e203_biu/e203_biu.v lines=368-370
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000015 file=e203_hbirdv2/e203_biu/e203_biu.v lines=368-370
                             lsu2biu_icb_cmd_excl
                           } ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000009 file=e203_hbirdv2/e203_biu/e203_biu.v lines=366-372
                           
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000010 file=e203_hbirdv2/e203_biu/e203_biu.v lines=374-380
  assign arbt_bus_icb_cmd_size =
                           {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000016 file=e203_hbirdv2/e203_biu/e203_biu.v lines=376-378
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000016 file=e203_hbirdv2/e203_biu/e203_biu.v lines=376-378
                             ifu2biu_icb_cmd_size,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000016 file=e203_hbirdv2/e203_biu/e203_biu.v lines=376-378
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000016 file=e203_hbirdv2/e203_biu/e203_biu.v lines=376-378
                             lsu2biu_icb_cmd_size
                           } ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000010 file=e203_hbirdv2/e203_biu/e203_biu.v lines=374-380
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_biu/e203_biu.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_biu/e203_biu.v lines=301-380
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/e203_biu/e203_biu.v:grp:bus_cluster:000001 file=e203_hbirdv2/e203_biu/e203_biu.v lines=301-380

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_biu/e203_biu.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_biu/e203_biu.v lines=382-383
 wire ifu2biu_icb_cmd_ifu = 1'b1;
 wire lsu2biu_icb_cmd_ifu = 1'b0;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_biu/e203_biu.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_biu/e203_biu.v lines=382-383
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_biu/e203_biu.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_biu/e203_biu.v lines=384-433
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/e203_biu/e203_biu.v:grp:bus_cluster:000002 file=e203_hbirdv2/e203_biu/e203_biu.v lines=384-433
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000011 file=e203_hbirdv2/e203_biu/e203_biu.v lines=384-390
 assign arbt_bus_icb_cmd_usr =
                           {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000017 file=e203_hbirdv2/e203_biu/e203_biu.v lines=386-388
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000017 file=e203_hbirdv2/e203_biu/e203_biu.v lines=386-388
                             ifu2biu_icb_cmd_ifu,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000017 file=e203_hbirdv2/e203_biu/e203_biu.v lines=386-388
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000017 file=e203_hbirdv2/e203_biu/e203_biu.v lines=386-388
                             lsu2biu_icb_cmd_ifu
                           } ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000011 file=e203_hbirdv2/e203_biu/e203_biu.v lines=384-390

//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_biu/e203_biu.v:grp:handshake:000001 file=e203_hbirdv2/e203_biu/e203_biu.v lines=392-405
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000012 file=e203_hbirdv2/e203_biu/e203_biu.v lines=392-397
  assign                   {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000018 file=e203_hbirdv2/e203_biu/e203_biu.v lines=393-395
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000018 file=e203_hbirdv2/e203_biu/e203_biu.v lines=393-395
                             ifu2biu_icb_cmd_ready,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000018 file=e203_hbirdv2/e203_biu/e203_biu.v lines=393-395
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000018 file=e203_hbirdv2/e203_biu/e203_biu.v lines=393-395
                             lsu2biu_icb_cmd_ready
                           } = arbt_bus_icb_cmd_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000012 file=e203_hbirdv2/e203_biu/e203_biu.v lines=392-397

  //RSP Channel
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000013 file=e203_hbirdv2/e203_biu/e203_biu.v lines=400-405
  assign                   {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000019 file=e203_hbirdv2/e203_biu/e203_biu.v lines=401-403
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000019 file=e203_hbirdv2/e203_biu/e203_biu.v lines=401-403
                             ifu2biu_icb_rsp_valid,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000019 file=e203_hbirdv2/e203_biu/e203_biu.v lines=401-403
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000019 file=e203_hbirdv2/e203_biu/e203_biu.v lines=401-403
                             lsu2biu_icb_rsp_valid
                           } = arbt_bus_icb_rsp_valid;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000013 file=e203_hbirdv2/e203_biu/e203_biu.v lines=400-405
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_biu/e203_biu.v:grp:handshake:000001 file=e203_hbirdv2/e203_biu/e203_biu.v lines=392-405

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000014 file=e203_hbirdv2/e203_biu/e203_biu.v lines=407-412
  assign                   {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000020 file=e203_hbirdv2/e203_biu/e203_biu.v lines=408-410
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000020 file=e203_hbirdv2/e203_biu/e203_biu.v lines=408-410
                             ifu2biu_icb_rsp_err,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000020 file=e203_hbirdv2/e203_biu/e203_biu.v lines=408-410
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000020 file=e203_hbirdv2/e203_biu/e203_biu.v lines=408-410
                             lsu2biu_icb_rsp_err
                           } = arbt_bus_icb_rsp_err;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000014 file=e203_hbirdv2/e203_biu/e203_biu.v lines=407-412

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000015 file=e203_hbirdv2/e203_biu/e203_biu.v lines=414-419
  assign                   {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000021 file=e203_hbirdv2/e203_biu/e203_biu.v lines=415-417
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000021 file=e203_hbirdv2/e203_biu/e203_biu.v lines=415-417
                             ifu2biu_icb_rsp_excl_ok,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000021 file=e203_hbirdv2/e203_biu/e203_biu.v lines=415-417
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000021 file=e203_hbirdv2/e203_biu/e203_biu.v lines=415-417
                             lsu2biu_icb_rsp_excl_ok
                           } = arbt_bus_icb_rsp_excl_ok;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000015 file=e203_hbirdv2/e203_biu/e203_biu.v lines=414-419
                           
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000016 file=e203_hbirdv2/e203_biu/e203_biu.v lines=421-426
  assign                   {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000022 file=e203_hbirdv2/e203_biu/e203_biu.v lines=422-424
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000022 file=e203_hbirdv2/e203_biu/e203_biu.v lines=422-424
                             ifu2biu_icb_rsp_rdata,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000022 file=e203_hbirdv2/e203_biu/e203_biu.v lines=422-424
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000022 file=e203_hbirdv2/e203_biu/e203_biu.v lines=422-424
                             lsu2biu_icb_rsp_rdata
                           } = arbt_bus_icb_rsp_rdata;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000016 file=e203_hbirdv2/e203_biu/e203_biu.v lines=421-426

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000017 file=e203_hbirdv2/e203_biu/e203_biu.v lines=428-433
  assign arbt_bus_icb_rsp_ready = {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000023 file=e203_hbirdv2/e203_biu/e203_biu.v lines=429-431
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000023 file=e203_hbirdv2/e203_biu/e203_biu.v lines=429-431
                             ifu2biu_icb_rsp_ready,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000023 file=e203_hbirdv2/e203_biu/e203_biu.v lines=429-431
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000023 file=e203_hbirdv2/e203_biu/e203_biu.v lines=429-431
                             lsu2biu_icb_rsp_ready
                           };
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000017 file=e203_hbirdv2/e203_biu/e203_biu.v lines=428-433
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_biu/e203_biu.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_biu/e203_biu.v lines=384-433
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/e203_biu/e203_biu.v:grp:bus_cluster:000002 file=e203_hbirdv2/e203_biu/e203_biu.v lines=384-433

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_biu/e203_biu.v:inst:000001 file=e203_hbirdv2/e203_biu/e203_biu.v lines=435-489
  sirv_gnrl_icb_arbt # (
  .ARBT_SCHEME (0),// Priority based
  .ALLOW_0CYCL_RSP (0),// Dont allow the 0 cycle response because in BIU we always have CMD_DP larger than 0
                       //   when the response come back from the external bus, it is at least 1 cycle later
  .FIFO_OUTS_NUM   (`E203_BIU_OUTS_NUM),
  .FIFO_CUT_READY  (`E203_BIU_CMD_CUT_READY),
  .ARBT_NUM   (BIU_ARBT_I_NUM),
  .ARBT_PTR_W (BIU_ARBT_I_PTR_W),
  .USR_W      (1),
  .AW         (`E203_ADDR_SIZE),
  .DW         (`E203_XLEN) 
  ) u_biu_icb_arbt(
  .o_icb_cmd_valid        (arbt_icb_cmd_valid )     ,
  .o_icb_cmd_ready        (arbt_icb_cmd_ready )     ,
  .o_icb_cmd_read         (arbt_icb_cmd_read )      ,
  .o_icb_cmd_addr         (arbt_icb_cmd_addr )      ,
  .o_icb_cmd_wdata        (arbt_icb_cmd_wdata )     ,
  .o_icb_cmd_wmask        (arbt_icb_cmd_wmask)      ,
  .o_icb_cmd_burst        (arbt_icb_cmd_burst)     ,
  .o_icb_cmd_beat         (arbt_icb_cmd_beat )     ,
  .o_icb_cmd_excl         (arbt_icb_cmd_excl )     ,
  .o_icb_cmd_lock         (arbt_icb_cmd_lock )     ,
  .o_icb_cmd_size         (arbt_icb_cmd_size )     ,
  .o_icb_cmd_usr          (arbt_icb_cmd_usr  )     ,
                                
  .o_icb_rsp_valid        (arbt_icb_rsp_valid )     ,
  .o_icb_rsp_ready        (arbt_icb_rsp_ready )     ,
  .o_icb_rsp_err          (arbt_icb_rsp_err)        ,
  .o_icb_rsp_excl_ok      (arbt_icb_rsp_excl_ok)    ,
  .o_icb_rsp_rdata        (arbt_icb_rsp_rdata )     ,
  .o_icb_rsp_usr          (1'b0   )     ,
                               
  .i_bus_icb_cmd_ready    (arbt_bus_icb_cmd_ready ) ,
  .i_bus_icb_cmd_valid    (arbt_bus_icb_cmd_valid ) ,
  .i_bus_icb_cmd_read     (arbt_bus_icb_cmd_read )  ,
  .i_bus_icb_cmd_addr     (arbt_bus_icb_cmd_addr )  ,
  .i_bus_icb_cmd_wdata    (arbt_bus_icb_cmd_wdata ) ,
  .i_bus_icb_cmd_wmask    (arbt_bus_icb_cmd_wmask)  ,
  .i_bus_icb_cmd_burst    (arbt_bus_icb_cmd_burst),
  .i_bus_icb_cmd_beat     (arbt_bus_icb_cmd_beat ),
  .i_bus_icb_cmd_excl     (arbt_bus_icb_cmd_excl ),
  .i_bus_icb_cmd_lock     (arbt_bus_icb_cmd_lock ),
  .i_bus_icb_cmd_size     (arbt_bus_icb_cmd_size ),
  .i_bus_icb_cmd_usr      (arbt_bus_icb_cmd_usr ),
                                
  .i_bus_icb_rsp_valid    (arbt_bus_icb_rsp_valid ) ,
  .i_bus_icb_rsp_ready    (arbt_bus_icb_rsp_ready ) ,
  .i_bus_icb_rsp_err      (arbt_bus_icb_rsp_err)    ,
  .i_bus_icb_rsp_excl_ok  (arbt_bus_icb_rsp_excl_ok),
  .i_bus_icb_rsp_rdata    (arbt_bus_icb_rsp_rdata ) ,
  .i_bus_icb_rsp_usr      () ,
                             
  .clk                    (clk  )                     ,
  .rst_n                  (rst_n)
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_biu/e203_biu.v:inst:000001 file=e203_hbirdv2/e203_biu/e203_biu.v lines=435-489

  //// To breakup the dead-lock cases, when incoming load/store request to the BIU but not granted 
  ////  This kind of potential deadlock case only happened at the low end core, where the ifetch response
  ////  provided to IFU, but IFU cannot accept it because it is waiting the IR stage to be cleared, and IR
  ////  stage is waiting the LSU to be cleared, and LSU is waiting this BIU to be cleared.
  //// At any mid of high end core (or with multiple oustandings), we definitely will update IFU
  ////  to make sure it always can accept any oustanding transactions traded with area cost.
  //// So back to this very low end core, to save areas, we prefetch without knowing if IR can accept
  ////  the response or not, and also in very low end core it is just 1 oustanding (multiple oustanding 
  ////  belong to mid or high end core), so to cut off this deadlocks, we just let the BIU to trigger
  ////  and replay indication if LSU cannot get granted, if IFU just overkilly forced to be replayed, it
  ////  just lost performance, but we dont care, because in low end core, ifetch to system mem is not
  ////  guranteed by performance. If IFU really suppose to be replayed, then good luck to break this deadlock.
  //wire ifu_replay_r;
  //// The IFU replay will be set when:
  ////    * Accessed by non-IFU access
  ////    * Or non-IFU access is to access ITCM, but not granted
  //wire ifu_replay_set = (arbt_icb_cmd_valid & arbt_icb_cmd_ready & lsu2biu_icb_cmd_valid)
  //               | (lsu2biu_icb_cmd_valid & (~lsu2biu_icb_cmd_ready));
  //// The IFU replay will be cleared after accessed by a IFU access
  //wire ifu_replay_clr = (arbt_icb_cmd_valid & arbt_icb_cmd_ready & ifu2biu_icb_cmd_valid);
  //wire ifu_replay_ena = ifu_replay_set | ifu_replay_clr;
  //wire ifu_replay_nxt = ifu_replay_set | (~ifu_replay_clr);
  //sirv_gnrl_dfflr #(1)ifu_replay_dffl(ifu_replay_ena, ifu_replay_nxt, ifu_replay_r, clk, rst_n);
  //assign ifu2biu_replay = ifu_replay_r;

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_biu/e203_biu.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_biu/e203_biu.v lines=516-537
  wire buf_icb_cmd_valid;
  wire buf_icb_cmd_ready;
  wire [`E203_ADDR_SIZE-1:0] buf_icb_cmd_addr;
  wire buf_icb_cmd_read;
  wire [`E203_XLEN-1:0] buf_icb_cmd_wdata;
  wire [`E203_XLEN/8-1:0] buf_icb_cmd_wmask;
  wire [1:0] buf_icb_cmd_burst;
  wire [1:0] buf_icb_cmd_beat;
  wire buf_icb_cmd_lock;
  wire buf_icb_cmd_excl;
  wire [1:0] buf_icb_cmd_size;
  wire buf_icb_cmd_usr;

  wire buf_icb_cmd_ifu = buf_icb_cmd_usr;

  wire buf_icb_rsp_valid;
  wire buf_icb_rsp_ready;
  wire buf_icb_rsp_err;
  wire buf_icb_rsp_excl_ok;
  wire [`E203_XLEN-1:0] buf_icb_rsp_rdata;

  wire icb_buffer_active;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_biu/e203_biu.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_biu/e203_biu.v lines=516-537

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_biu/e203_biu.v:inst:000002 file=e203_hbirdv2/e203_biu/e203_biu.v lines=539-592
  sirv_gnrl_icb_buffer # (
    .OUTS_CNT_W   (`E203_BIU_OUTS_CNT_W),
    .AW    (`E203_ADDR_SIZE),
    .DW    (`E203_XLEN), 
    .CMD_DP(`E203_BIU_CMD_DP),
    .RSP_DP(`E203_BIU_RSP_DP),
    .CMD_CUT_READY (`E203_BIU_CMD_CUT_READY),
    .RSP_CUT_READY (`E203_BIU_RSP_CUT_READY),
    .USR_W (1)
  )u_sirv_gnrl_icb_buffer(
    .icb_buffer_active      (icb_buffer_active),
    .i_icb_cmd_valid        (arbt_icb_cmd_valid),
    .i_icb_cmd_ready        (arbt_icb_cmd_ready),
    .i_icb_cmd_read         (arbt_icb_cmd_read ),
    .i_icb_cmd_addr         (arbt_icb_cmd_addr ),
    .i_icb_cmd_wdata        (arbt_icb_cmd_wdata),
    .i_icb_cmd_wmask        (arbt_icb_cmd_wmask),
    .i_icb_cmd_lock         (arbt_icb_cmd_lock ),
    .i_icb_cmd_excl         (arbt_icb_cmd_excl ),
    .i_icb_cmd_size         (arbt_icb_cmd_size ),
    .i_icb_cmd_burst        (arbt_icb_cmd_burst),
    .i_icb_cmd_beat         (arbt_icb_cmd_beat ),
    .i_icb_cmd_usr          (arbt_icb_cmd_usr  ),
                     
    .i_icb_rsp_valid        (arbt_icb_rsp_valid),
    .i_icb_rsp_ready        (arbt_icb_rsp_ready),
    .i_icb_rsp_err          (arbt_icb_rsp_err  ),
    .i_icb_rsp_excl_ok      (arbt_icb_rsp_excl_ok),
    .i_icb_rsp_rdata        (arbt_icb_rsp_rdata),
    .i_icb_rsp_usr          (),
    
    .o_icb_cmd_valid        (buf_icb_cmd_valid),
    .o_icb_cmd_ready        (buf_icb_cmd_ready),
    .o_icb_cmd_read         (buf_icb_cmd_read ),
    .o_icb_cmd_addr         (buf_icb_cmd_addr ),
    .o_icb_cmd_wdata        (buf_icb_cmd_wdata),
    .o_icb_cmd_wmask        (buf_icb_cmd_wmask),
    .o_icb_cmd_lock         (buf_icb_cmd_lock ),
    .o_icb_cmd_excl         (buf_icb_cmd_excl ),
    .o_icb_cmd_size         (buf_icb_cmd_size ),
    .o_icb_cmd_burst        (buf_icb_cmd_burst),
    .o_icb_cmd_beat         (buf_icb_cmd_beat ),
    .o_icb_cmd_usr          (buf_icb_cmd_usr),
                         
    .o_icb_rsp_valid        (buf_icb_rsp_valid),
    .o_icb_rsp_ready        (buf_icb_rsp_ready),
    .o_icb_rsp_err          (buf_icb_rsp_err  ),
    .o_icb_rsp_excl_ok      (buf_icb_rsp_excl_ok),
    .o_icb_rsp_rdata        (buf_icb_rsp_rdata),
    .o_icb_rsp_usr          (1'b0  ),

    .clk                    (clk  ),
    .rst_n                  (rst_n)
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_biu/e203_biu.v:inst:000002 file=e203_hbirdv2/e203_biu/e203_biu.v lines=539-592

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_biu/e203_biu.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_biu/e203_biu.v lines=594-610
  wire [BIU_SPLT_I_NUM*1-1:0] splt_bus_icb_cmd_valid;
  wire [BIU_SPLT_I_NUM*1-1:0] splt_bus_icb_cmd_ready;
  wire [BIU_SPLT_I_NUM*`E203_ADDR_SIZE-1:0] splt_bus_icb_cmd_addr;
  wire [BIU_SPLT_I_NUM*1-1:0] splt_bus_icb_cmd_read;
  wire [BIU_SPLT_I_NUM*`E203_XLEN-1:0] splt_bus_icb_cmd_wdata;
  wire [BIU_SPLT_I_NUM*`E203_XLEN/8-1:0] splt_bus_icb_cmd_wmask;
  wire [BIU_SPLT_I_NUM*2-1:0] splt_bus_icb_cmd_burst;
  wire [BIU_SPLT_I_NUM*2-1:0] splt_bus_icb_cmd_beat;
  wire [BIU_SPLT_I_NUM*1-1:0] splt_bus_icb_cmd_lock;
  wire [BIU_SPLT_I_NUM*1-1:0] splt_bus_icb_cmd_excl;
  wire [BIU_SPLT_I_NUM*2-1:0] splt_bus_icb_cmd_size;

  wire [BIU_SPLT_I_NUM*1-1:0] splt_bus_icb_rsp_valid;
  wire [BIU_SPLT_I_NUM*1-1:0] splt_bus_icb_rsp_ready;
  wire [BIU_SPLT_I_NUM*1-1:0] splt_bus_icb_rsp_err;
  wire [BIU_SPLT_I_NUM*1-1:0] splt_bus_icb_rsp_excl_ok;
  wire [BIU_SPLT_I_NUM*`E203_XLEN-1:0] splt_bus_icb_rsp_rdata;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_biu/e203_biu.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_biu/e203_biu.v lines=594-610

  //CMD Channel
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_biu/e203_biu.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_biu/e203_biu.v lines=613-820
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/e203_biu/e203_biu.v:grp:bus_cluster:000003 file=e203_hbirdv2/e203_biu/e203_biu.v lines=613-820
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000018 file=e203_hbirdv2/e203_biu/e203_biu.v lines=613-624
  assign {
                             ifuerr_icb_cmd_valid
                           , ppi_icb_cmd_valid
                           , clint_icb_cmd_valid
                           , plic_icb_cmd_valid
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000024 file=e203_hbirdv2/e203_biu/e203_biu.v lines=618-620
                           `ifdef E203_HAS_FIO //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000024 file=e203_hbirdv2/e203_biu/e203_biu.v lines=618-620
                           , fio_icb_cmd_valid
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000024 file=e203_hbirdv2/e203_biu/e203_biu.v lines=618-620
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000024 file=e203_hbirdv2/e203_biu/e203_biu.v lines=618-620
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000025 file=e203_hbirdv2/e203_biu/e203_biu.v lines=621-623
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000025 file=e203_hbirdv2/e203_biu/e203_biu.v lines=621-623
                           , mem_icb_cmd_valid
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000025 file=e203_hbirdv2/e203_biu/e203_biu.v lines=621-623
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000025 file=e203_hbirdv2/e203_biu/e203_biu.v lines=621-623
                           } = splt_bus_icb_cmd_valid;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000018 file=e203_hbirdv2/e203_biu/e203_biu.v lines=613-624

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000019 file=e203_hbirdv2/e203_biu/e203_biu.v lines=626-637
  assign {
                             ifuerr_icb_cmd_addr
                           , ppi_icb_cmd_addr
                           , clint_icb_cmd_addr
                           , plic_icb_cmd_addr
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000026 file=e203_hbirdv2/e203_biu/e203_biu.v lines=631-633
                           `ifdef E203_HAS_FIO //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000026 file=e203_hbirdv2/e203_biu/e203_biu.v lines=631-633
                           , fio_icb_cmd_addr
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000026 file=e203_hbirdv2/e203_biu/e203_biu.v lines=631-633
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000026 file=e203_hbirdv2/e203_biu/e203_biu.v lines=631-633
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000027 file=e203_hbirdv2/e203_biu/e203_biu.v lines=634-636
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000027 file=e203_hbirdv2/e203_biu/e203_biu.v lines=634-636
                           , mem_icb_cmd_addr
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000027 file=e203_hbirdv2/e203_biu/e203_biu.v lines=634-636
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000027 file=e203_hbirdv2/e203_biu/e203_biu.v lines=634-636
                           } = splt_bus_icb_cmd_addr;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000019 file=e203_hbirdv2/e203_biu/e203_biu.v lines=626-637

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000020 file=e203_hbirdv2/e203_biu/e203_biu.v lines=639-650
  assign {
                             ifuerr_icb_cmd_read
                           , ppi_icb_cmd_read
                           , clint_icb_cmd_read
                           , plic_icb_cmd_read
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000028 file=e203_hbirdv2/e203_biu/e203_biu.v lines=644-646
                           `ifdef E203_HAS_FIO //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000028 file=e203_hbirdv2/e203_biu/e203_biu.v lines=644-646
                           , fio_icb_cmd_read
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000028 file=e203_hbirdv2/e203_biu/e203_biu.v lines=644-646
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000028 file=e203_hbirdv2/e203_biu/e203_biu.v lines=644-646
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000029 file=e203_hbirdv2/e203_biu/e203_biu.v lines=647-649
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000029 file=e203_hbirdv2/e203_biu/e203_biu.v lines=647-649
                           , mem_icb_cmd_read
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000029 file=e203_hbirdv2/e203_biu/e203_biu.v lines=647-649
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000029 file=e203_hbirdv2/e203_biu/e203_biu.v lines=647-649
                           } = splt_bus_icb_cmd_read;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000020 file=e203_hbirdv2/e203_biu/e203_biu.v lines=639-650

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000021 file=e203_hbirdv2/e203_biu/e203_biu.v lines=652-663
  assign {
                             ifuerr_icb_cmd_wdata
                           , ppi_icb_cmd_wdata
                           , clint_icb_cmd_wdata
                           , plic_icb_cmd_wdata
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000030 file=e203_hbirdv2/e203_biu/e203_biu.v lines=657-659
                           `ifdef E203_HAS_FIO //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000030 file=e203_hbirdv2/e203_biu/e203_biu.v lines=657-659
                           , fio_icb_cmd_wdata
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000030 file=e203_hbirdv2/e203_biu/e203_biu.v lines=657-659
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000030 file=e203_hbirdv2/e203_biu/e203_biu.v lines=657-659
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000031 file=e203_hbirdv2/e203_biu/e203_biu.v lines=660-662
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000031 file=e203_hbirdv2/e203_biu/e203_biu.v lines=660-662
                           , mem_icb_cmd_wdata
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000031 file=e203_hbirdv2/e203_biu/e203_biu.v lines=660-662
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000031 file=e203_hbirdv2/e203_biu/e203_biu.v lines=660-662
                           } = splt_bus_icb_cmd_wdata;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000021 file=e203_hbirdv2/e203_biu/e203_biu.v lines=652-663

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000022 file=e203_hbirdv2/e203_biu/e203_biu.v lines=665-676
  assign {
                             ifuerr_icb_cmd_wmask
                           , ppi_icb_cmd_wmask
                           , clint_icb_cmd_wmask
                           , plic_icb_cmd_wmask
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000032 file=e203_hbirdv2/e203_biu/e203_biu.v lines=670-672
                           `ifdef E203_HAS_FIO //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000032 file=e203_hbirdv2/e203_biu/e203_biu.v lines=670-672
                           , fio_icb_cmd_wmask
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000032 file=e203_hbirdv2/e203_biu/e203_biu.v lines=670-672
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000032 file=e203_hbirdv2/e203_biu/e203_biu.v lines=670-672
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000033 file=e203_hbirdv2/e203_biu/e203_biu.v lines=673-675
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000033 file=e203_hbirdv2/e203_biu/e203_biu.v lines=673-675
                           , mem_icb_cmd_wmask
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000033 file=e203_hbirdv2/e203_biu/e203_biu.v lines=673-675
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000033 file=e203_hbirdv2/e203_biu/e203_biu.v lines=673-675
                           } = splt_bus_icb_cmd_wmask;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000022 file=e203_hbirdv2/e203_biu/e203_biu.v lines=665-676
                         
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000023 file=e203_hbirdv2/e203_biu/e203_biu.v lines=678-689
  assign {
                             ifuerr_icb_cmd_burst
                           , ppi_icb_cmd_burst
                           , clint_icb_cmd_burst
                           , plic_icb_cmd_burst
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000034 file=e203_hbirdv2/e203_biu/e203_biu.v lines=683-685
                           `ifdef E203_HAS_FIO //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000034 file=e203_hbirdv2/e203_biu/e203_biu.v lines=683-685
                           , fio_icb_cmd_burst
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000034 file=e203_hbirdv2/e203_biu/e203_biu.v lines=683-685
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000034 file=e203_hbirdv2/e203_biu/e203_biu.v lines=683-685
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000035 file=e203_hbirdv2/e203_biu/e203_biu.v lines=686-688
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000035 file=e203_hbirdv2/e203_biu/e203_biu.v lines=686-688
                           , mem_icb_cmd_burst
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000035 file=e203_hbirdv2/e203_biu/e203_biu.v lines=686-688
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000035 file=e203_hbirdv2/e203_biu/e203_biu.v lines=686-688
                           } = splt_bus_icb_cmd_burst;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000023 file=e203_hbirdv2/e203_biu/e203_biu.v lines=678-689
                         
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000024 file=e203_hbirdv2/e203_biu/e203_biu.v lines=691-702
  assign {
                             ifuerr_icb_cmd_beat
                           , ppi_icb_cmd_beat
                           , clint_icb_cmd_beat
                           , plic_icb_cmd_beat
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000036 file=e203_hbirdv2/e203_biu/e203_biu.v lines=696-698
                           `ifdef E203_HAS_FIO //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000036 file=e203_hbirdv2/e203_biu/e203_biu.v lines=696-698
                           , fio_icb_cmd_beat
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000036 file=e203_hbirdv2/e203_biu/e203_biu.v lines=696-698
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000036 file=e203_hbirdv2/e203_biu/e203_biu.v lines=696-698
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000037 file=e203_hbirdv2/e203_biu/e203_biu.v lines=699-701
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000037 file=e203_hbirdv2/e203_biu/e203_biu.v lines=699-701
                           , mem_icb_cmd_beat
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000037 file=e203_hbirdv2/e203_biu/e203_biu.v lines=699-701
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000037 file=e203_hbirdv2/e203_biu/e203_biu.v lines=699-701
                           } = splt_bus_icb_cmd_beat;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000024 file=e203_hbirdv2/e203_biu/e203_biu.v lines=691-702
                         
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000025 file=e203_hbirdv2/e203_biu/e203_biu.v lines=704-715
  assign {
                             ifuerr_icb_cmd_lock
                           , ppi_icb_cmd_lock
                           , clint_icb_cmd_lock
                           , plic_icb_cmd_lock
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000038 file=e203_hbirdv2/e203_biu/e203_biu.v lines=709-711
                           `ifdef E203_HAS_FIO //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000038 file=e203_hbirdv2/e203_biu/e203_biu.v lines=709-711
                           , fio_icb_cmd_lock
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000038 file=e203_hbirdv2/e203_biu/e203_biu.v lines=709-711
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000038 file=e203_hbirdv2/e203_biu/e203_biu.v lines=709-711
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000039 file=e203_hbirdv2/e203_biu/e203_biu.v lines=712-714
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000039 file=e203_hbirdv2/e203_biu/e203_biu.v lines=712-714
                           , mem_icb_cmd_lock
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000039 file=e203_hbirdv2/e203_biu/e203_biu.v lines=712-714
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000039 file=e203_hbirdv2/e203_biu/e203_biu.v lines=712-714
                           } = splt_bus_icb_cmd_lock;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000025 file=e203_hbirdv2/e203_biu/e203_biu.v lines=704-715

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000026 file=e203_hbirdv2/e203_biu/e203_biu.v lines=717-728
  assign {
                             ifuerr_icb_cmd_excl
                           , ppi_icb_cmd_excl
                           , clint_icb_cmd_excl
                           , plic_icb_cmd_excl
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000040 file=e203_hbirdv2/e203_biu/e203_biu.v lines=722-724
                           `ifdef E203_HAS_FIO //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000040 file=e203_hbirdv2/e203_biu/e203_biu.v lines=722-724
                           , fio_icb_cmd_excl
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000040 file=e203_hbirdv2/e203_biu/e203_biu.v lines=722-724
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000040 file=e203_hbirdv2/e203_biu/e203_biu.v lines=722-724
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000041 file=e203_hbirdv2/e203_biu/e203_biu.v lines=725-727
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000041 file=e203_hbirdv2/e203_biu/e203_biu.v lines=725-727
                           , mem_icb_cmd_excl
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000041 file=e203_hbirdv2/e203_biu/e203_biu.v lines=725-727
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000041 file=e203_hbirdv2/e203_biu/e203_biu.v lines=725-727
                           } = splt_bus_icb_cmd_excl;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000026 file=e203_hbirdv2/e203_biu/e203_biu.v lines=717-728
                           
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000027 file=e203_hbirdv2/e203_biu/e203_biu.v lines=730-741
  assign {
                             ifuerr_icb_cmd_size
                           , ppi_icb_cmd_size
                           , clint_icb_cmd_size
                           , plic_icb_cmd_size
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000042 file=e203_hbirdv2/e203_biu/e203_biu.v lines=735-737
                           `ifdef E203_HAS_FIO //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000042 file=e203_hbirdv2/e203_biu/e203_biu.v lines=735-737
                           , fio_icb_cmd_size
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000042 file=e203_hbirdv2/e203_biu/e203_biu.v lines=735-737
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000042 file=e203_hbirdv2/e203_biu/e203_biu.v lines=735-737
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000043 file=e203_hbirdv2/e203_biu/e203_biu.v lines=738-740
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000043 file=e203_hbirdv2/e203_biu/e203_biu.v lines=738-740
                           , mem_icb_cmd_size
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000043 file=e203_hbirdv2/e203_biu/e203_biu.v lines=738-740
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000043 file=e203_hbirdv2/e203_biu/e203_biu.v lines=738-740
                           } = splt_bus_icb_cmd_size;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000027 file=e203_hbirdv2/e203_biu/e203_biu.v lines=730-741

//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_biu/e203_biu.v:grp:handshake:000002 file=e203_hbirdv2/e203_biu/e203_biu.v lines=743-768
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000028 file=e203_hbirdv2/e203_biu/e203_biu.v lines=743-754
  assign splt_bus_icb_cmd_ready = {
                             ifuerr_icb_cmd_ready
                           , ppi_icb_cmd_ready
                           , clint_icb_cmd_ready
                           , plic_icb_cmd_ready
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000044 file=e203_hbirdv2/e203_biu/e203_biu.v lines=748-750
                           `ifdef E203_HAS_FIO //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000044 file=e203_hbirdv2/e203_biu/e203_biu.v lines=748-750
                           , fio_icb_cmd_ready
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000044 file=e203_hbirdv2/e203_biu/e203_biu.v lines=748-750
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000044 file=e203_hbirdv2/e203_biu/e203_biu.v lines=748-750
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000045 file=e203_hbirdv2/e203_biu/e203_biu.v lines=751-753
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000045 file=e203_hbirdv2/e203_biu/e203_biu.v lines=751-753
                           , mem_icb_cmd_ready
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000045 file=e203_hbirdv2/e203_biu/e203_biu.v lines=751-753
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000045 file=e203_hbirdv2/e203_biu/e203_biu.v lines=751-753
                           };
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000028 file=e203_hbirdv2/e203_biu/e203_biu.v lines=743-754

  //RSP Channel
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000029 file=e203_hbirdv2/e203_biu/e203_biu.v lines=757-768
  assign splt_bus_icb_rsp_valid = {
                             ifuerr_icb_rsp_valid
                           , ppi_icb_rsp_valid
                           , clint_icb_rsp_valid
                           , plic_icb_rsp_valid
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000046 file=e203_hbirdv2/e203_biu/e203_biu.v lines=762-764
                           `ifdef E203_HAS_FIO //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000046 file=e203_hbirdv2/e203_biu/e203_biu.v lines=762-764
                           , fio_icb_rsp_valid
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000046 file=e203_hbirdv2/e203_biu/e203_biu.v lines=762-764
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000046 file=e203_hbirdv2/e203_biu/e203_biu.v lines=762-764
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000047 file=e203_hbirdv2/e203_biu/e203_biu.v lines=765-767
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000047 file=e203_hbirdv2/e203_biu/e203_biu.v lines=765-767
                           , mem_icb_rsp_valid
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000047 file=e203_hbirdv2/e203_biu/e203_biu.v lines=765-767
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000047 file=e203_hbirdv2/e203_biu/e203_biu.v lines=765-767
                           };
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000029 file=e203_hbirdv2/e203_biu/e203_biu.v lines=757-768
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_biu/e203_biu.v:grp:handshake:000002 file=e203_hbirdv2/e203_biu/e203_biu.v lines=743-768

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000030 file=e203_hbirdv2/e203_biu/e203_biu.v lines=770-781
  assign splt_bus_icb_rsp_err = {
                             ifuerr_icb_rsp_err
                           , ppi_icb_rsp_err
                           , clint_icb_rsp_err
                           , plic_icb_rsp_err
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000048 file=e203_hbirdv2/e203_biu/e203_biu.v lines=775-777
                           `ifdef E203_HAS_FIO //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000048 file=e203_hbirdv2/e203_biu/e203_biu.v lines=775-777
                           , fio_icb_rsp_err
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000048 file=e203_hbirdv2/e203_biu/e203_biu.v lines=775-777
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000048 file=e203_hbirdv2/e203_biu/e203_biu.v lines=775-777
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000049 file=e203_hbirdv2/e203_biu/e203_biu.v lines=778-780
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000049 file=e203_hbirdv2/e203_biu/e203_biu.v lines=778-780
                           , mem_icb_rsp_err
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000049 file=e203_hbirdv2/e203_biu/e203_biu.v lines=778-780
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000049 file=e203_hbirdv2/e203_biu/e203_biu.v lines=778-780
                           };
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000030 file=e203_hbirdv2/e203_biu/e203_biu.v lines=770-781

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000031 file=e203_hbirdv2/e203_biu/e203_biu.v lines=783-794
  assign splt_bus_icb_rsp_excl_ok = {
                             ifuerr_icb_rsp_excl_ok
                           , ppi_icb_rsp_excl_ok
                           , clint_icb_rsp_excl_ok
                           , plic_icb_rsp_excl_ok
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000050 file=e203_hbirdv2/e203_biu/e203_biu.v lines=788-790
                           `ifdef E203_HAS_FIO //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000050 file=e203_hbirdv2/e203_biu/e203_biu.v lines=788-790
                           , fio_icb_rsp_excl_ok
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000050 file=e203_hbirdv2/e203_biu/e203_biu.v lines=788-790
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000050 file=e203_hbirdv2/e203_biu/e203_biu.v lines=788-790
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000051 file=e203_hbirdv2/e203_biu/e203_biu.v lines=791-793
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000051 file=e203_hbirdv2/e203_biu/e203_biu.v lines=791-793
                           , mem_icb_rsp_excl_ok
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000051 file=e203_hbirdv2/e203_biu/e203_biu.v lines=791-793
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000051 file=e203_hbirdv2/e203_biu/e203_biu.v lines=791-793
                           };
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000031 file=e203_hbirdv2/e203_biu/e203_biu.v lines=783-794

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000032 file=e203_hbirdv2/e203_biu/e203_biu.v lines=796-807
  assign splt_bus_icb_rsp_rdata = {
                             ifuerr_icb_rsp_rdata
                           , ppi_icb_rsp_rdata
                           , clint_icb_rsp_rdata
                           , plic_icb_rsp_rdata
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000052 file=e203_hbirdv2/e203_biu/e203_biu.v lines=801-803
                           `ifdef E203_HAS_FIO //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000052 file=e203_hbirdv2/e203_biu/e203_biu.v lines=801-803
                           , fio_icb_rsp_rdata
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000052 file=e203_hbirdv2/e203_biu/e203_biu.v lines=801-803
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000052 file=e203_hbirdv2/e203_biu/e203_biu.v lines=801-803
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000053 file=e203_hbirdv2/e203_biu/e203_biu.v lines=804-806
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000053 file=e203_hbirdv2/e203_biu/e203_biu.v lines=804-806
                           , mem_icb_rsp_rdata
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000053 file=e203_hbirdv2/e203_biu/e203_biu.v lines=804-806
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000053 file=e203_hbirdv2/e203_biu/e203_biu.v lines=804-806
                           };
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000032 file=e203_hbirdv2/e203_biu/e203_biu.v lines=796-807

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000033 file=e203_hbirdv2/e203_biu/e203_biu.v lines=809-820
  assign {
                             ifuerr_icb_rsp_ready
                           , ppi_icb_rsp_ready
                           , clint_icb_rsp_ready
                           , plic_icb_rsp_ready
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000054 file=e203_hbirdv2/e203_biu/e203_biu.v lines=814-816
                           `ifdef E203_HAS_FIO //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000054 file=e203_hbirdv2/e203_biu/e203_biu.v lines=814-816
                           , fio_icb_rsp_ready
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000054 file=e203_hbirdv2/e203_biu/e203_biu.v lines=814-816
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000054 file=e203_hbirdv2/e203_biu/e203_biu.v lines=814-816
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000055 file=e203_hbirdv2/e203_biu/e203_biu.v lines=817-819
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000055 file=e203_hbirdv2/e203_biu/e203_biu.v lines=817-819
                           , mem_icb_rsp_ready
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000055 file=e203_hbirdv2/e203_biu/e203_biu.v lines=817-819
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000055 file=e203_hbirdv2/e203_biu/e203_biu.v lines=817-819
                           } = splt_bus_icb_rsp_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000033 file=e203_hbirdv2/e203_biu/e203_biu.v lines=809-820
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_biu/e203_biu.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_biu/e203_biu.v lines=613-820
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/e203_biu/e203_biu.v:grp:bus_cluster:000003 file=e203_hbirdv2/e203_biu/e203_biu.v lines=613-820

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_biu/e203_biu.v:grp:internal_signal:000005 file=e203_hbirdv2/e203_biu/e203_biu.v lines=822-836
  wire buf_icb_cmd_ppi = ppi_icb_enable & (buf_icb_cmd_addr[`E203_PPI_BASE_REGION] ==  ppi_region_indic[`E203_PPI_BASE_REGION]);
  wire buf_icb_sel_ppi = buf_icb_cmd_ppi & (~buf_icb_cmd_ifu);

  wire buf_icb_cmd_clint = clint_icb_enable & (buf_icb_cmd_addr[`E203_CLINT_BASE_REGION] ==  clint_region_indic[`E203_CLINT_BASE_REGION]);
  wire buf_icb_sel_clint = buf_icb_cmd_clint & (~buf_icb_cmd_ifu);

  wire buf_icb_cmd_plic = plic_icb_enable & (buf_icb_cmd_addr[`E203_PLIC_BASE_REGION] ==  plic_region_indic[`E203_PLIC_BASE_REGION]);
  wire buf_icb_sel_plic = buf_icb_cmd_plic & (~buf_icb_cmd_ifu);

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000056 file=e203_hbirdv2/e203_biu/e203_biu.v lines=831-834
  `ifdef E203_HAS_FIO //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000056 file=e203_hbirdv2/e203_biu/e203_biu.v lines=831-834
  wire buf_icb_cmd_fio = fio_icb_enable & (buf_icb_cmd_addr[`E203_FIO_BASE_REGION] ==  fio_region_indic[`E203_FIO_BASE_REGION]);
  wire buf_icb_sel_fio = buf_icb_cmd_fio & (~buf_icb_cmd_ifu);
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000056 file=e203_hbirdv2/e203_biu/e203_biu.v lines=831-834
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000056 file=e203_hbirdv2/e203_biu/e203_biu.v lines=831-834

  wire buf_icb_sel_ifuerr =(
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_biu/e203_biu.v:grp:internal_signal:000005 file=e203_hbirdv2/e203_biu/e203_biu.v lines=822-836
                            buf_icb_cmd_ppi 
                          | buf_icb_cmd_clint 
                          | buf_icb_cmd_plic
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000057 file=e203_hbirdv2/e203_biu/e203_biu.v lines=840-842
                           `ifdef E203_HAS_FIO //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000057 file=e203_hbirdv2/e203_biu/e203_biu.v lines=840-842
                          | buf_icb_cmd_fio
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000057 file=e203_hbirdv2/e203_biu/e203_biu.v lines=840-842
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000057 file=e203_hbirdv2/e203_biu/e203_biu.v lines=840-842
                           ) & buf_icb_cmd_ifu;

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000059 file=e203_hbirdv2/e203_biu/e203_biu.v lines=845-855
  `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_biu/e203_biu.v:grp:internal_signal:000006 file=e203_hbirdv2/e203_biu/e203_biu.v lines=846-846
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000059 file=e203_hbirdv2/e203_biu/e203_biu.v lines=845-855
  wire buf_icb_sel_mem = mem_icb_enable 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_biu/e203_biu.v:grp:internal_signal:000006 file=e203_hbirdv2/e203_biu/e203_biu.v lines=846-846
                             & (~buf_icb_sel_ifuerr)
                             & (~buf_icb_sel_ppi)
                             & (~buf_icb_sel_clint)
                             & (~buf_icb_sel_plic)
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000058 file=e203_hbirdv2/e203_biu/e203_biu.v lines=851-853
                          `ifdef E203_HAS_FIO //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000058 file=e203_hbirdv2/e203_biu/e203_biu.v lines=851-853
                             & (~buf_icb_sel_fio)
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000058 file=e203_hbirdv2/e203_biu/e203_biu.v lines=851-853
                          `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000058 file=e203_hbirdv2/e203_biu/e203_biu.v lines=851-853
                             ;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000059 file=e203_hbirdv2/e203_biu/e203_biu.v lines=845-855
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000059 file=e203_hbirdv2/e203_biu/e203_biu.v lines=845-855

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_biu/e203_biu.v:grp:internal_signal:000007 file=e203_hbirdv2/e203_biu/e203_biu.v lines=857-857
  wire [BIU_SPLT_I_NUM-1:0] buf_icb_splt_indic = 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_biu/e203_biu.v:grp:internal_signal:000007 file=e203_hbirdv2/e203_biu/e203_biu.v lines=857-857
      {
                             buf_icb_sel_ifuerr
                           , buf_icb_sel_ppi
                           , buf_icb_sel_clint
                           , buf_icb_sel_plic
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000060 file=e203_hbirdv2/e203_biu/e203_biu.v lines=863-865
                           `ifdef E203_HAS_FIO //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000060 file=e203_hbirdv2/e203_biu/e203_biu.v lines=863-865
                           , buf_icb_sel_fio
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000060 file=e203_hbirdv2/e203_biu/e203_biu.v lines=863-865
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000060 file=e203_hbirdv2/e203_biu/e203_biu.v lines=863-865
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000061 file=e203_hbirdv2/e203_biu/e203_biu.v lines=866-868
                           `ifdef E203_HAS_MEM_ITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000061 file=e203_hbirdv2/e203_biu/e203_biu.v lines=866-868
                           , buf_icb_sel_mem
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000061 file=e203_hbirdv2/e203_biu/e203_biu.v lines=866-868
                           `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_biu/e203_biu.v:pp_blk:000061 file=e203_hbirdv2/e203_biu/e203_biu.v lines=866-868
      };

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_biu/e203_biu.v:inst:000003 file=e203_hbirdv2/e203_biu/e203_biu.v lines=871-929
  sirv_gnrl_icb_splt # (
  .ALLOW_DIFF (0),// Dont allow different branches oustanding
  .ALLOW_0CYCL_RSP (1),// Allow the 0 cycle response because in BIU the splt
                       //  is after the buffer, and will directly talk to the external
                       //  bus, where maybe the ROM is 0 cycle responsed.
  .FIFO_OUTS_NUM   (`E203_BIU_OUTS_NUM),
  .FIFO_CUT_READY  (`E203_BIU_CMD_CUT_READY),
  .SPLT_NUM   (BIU_SPLT_I_NUM),
  .SPLT_PTR_W (BIU_SPLT_I_NUM),
  .SPLT_PTR_1HOT (1),
  .USR_W      (1),
  .AW         (`E203_ADDR_SIZE),
  .DW         (`E203_XLEN) 
  ) u_biu_icb_splt(
  .i_icb_splt_indic       (buf_icb_splt_indic),        

  .i_icb_cmd_valid        (buf_icb_cmd_valid )     ,
  .i_icb_cmd_ready        (buf_icb_cmd_ready )     ,
  .i_icb_cmd_read         (buf_icb_cmd_read )      ,
  .i_icb_cmd_addr         (buf_icb_cmd_addr )      ,
  .i_icb_cmd_wdata        (buf_icb_cmd_wdata )     ,
  .i_icb_cmd_wmask        (buf_icb_cmd_wmask)      ,
  .i_icb_cmd_burst        (buf_icb_cmd_burst)     ,
  .i_icb_cmd_beat         (buf_icb_cmd_beat )     ,
  .i_icb_cmd_excl         (buf_icb_cmd_excl )     ,
  .i_icb_cmd_lock         (buf_icb_cmd_lock )     ,
  .i_icb_cmd_size         (buf_icb_cmd_size )     ,
  .i_icb_cmd_usr          (1'b0   )     ,
 
  .i_icb_rsp_valid        (buf_icb_rsp_valid )     ,
  .i_icb_rsp_ready        (buf_icb_rsp_ready )     ,
  .i_icb_rsp_err          (buf_icb_rsp_err)        ,
  .i_icb_rsp_excl_ok      (buf_icb_rsp_excl_ok)    ,
  .i_icb_rsp_rdata        (buf_icb_rsp_rdata )     ,
  .i_icb_rsp_usr          ( )     ,
                               
  .o_bus_icb_cmd_ready    (splt_bus_icb_cmd_ready ) ,
  .o_bus_icb_cmd_valid    (splt_bus_icb_cmd_valid ) ,
  .o_bus_icb_cmd_read     (splt_bus_icb_cmd_read )  ,
  .o_bus_icb_cmd_addr     (splt_bus_icb_cmd_addr )  ,
  .o_bus_icb_cmd_wdata    (splt_bus_icb_cmd_wdata ) ,
  .o_bus_icb_cmd_wmask    (splt_bus_icb_cmd_wmask)  ,
  .o_bus_icb_cmd_burst    (splt_bus_icb_cmd_burst),
  .o_bus_icb_cmd_beat     (splt_bus_icb_cmd_beat ),
  .o_bus_icb_cmd_excl     (splt_bus_icb_cmd_excl ),
  .o_bus_icb_cmd_lock     (splt_bus_icb_cmd_lock ),
  .o_bus_icb_cmd_size     (splt_bus_icb_cmd_size ),
  .o_bus_icb_cmd_usr      ()     ,
  
  .o_bus_icb_rsp_valid    (splt_bus_icb_rsp_valid ) ,
  .o_bus_icb_rsp_ready    (splt_bus_icb_rsp_ready ) ,
  .o_bus_icb_rsp_err      (splt_bus_icb_rsp_err)    ,
  .o_bus_icb_rsp_excl_ok  (splt_bus_icb_rsp_excl_ok),
  .o_bus_icb_rsp_rdata    (splt_bus_icb_rsp_rdata ) ,
  .o_bus_icb_rsp_usr      ({BIU_SPLT_I_NUM{1'b0}}) ,
                             
  .clk                    (clk  )                     ,
  .rst_n                  (rst_n)
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_biu/e203_biu.v:inst:000003 file=e203_hbirdv2/e203_biu/e203_biu.v lines=871-929


//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000034 file=e203_hbirdv2/e203_biu/e203_biu.v lines=932-932
  assign biu_active = ifu2biu_icb_cmd_valid | lsu2biu_icb_cmd_valid | icb_buffer_active; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000034 file=e203_hbirdv2/e203_biu/e203_biu.v lines=932-932

  ///////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////
  // Implement the IFU-accessed-Peripheral region error
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_biu/e203_biu.v:grp:assign_cluster:000004 file=e203_hbirdv2/e203_biu/e203_biu.v lines=938-944
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/e203_biu/e203_biu.v:grp:bus_cluster:000004 file=e203_hbirdv2/e203_biu/e203_biu.v lines=938-944
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_biu/e203_biu.v:grp:handshake:000003 file=e203_hbirdv2/e203_biu/e203_biu.v lines=938-941
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000035 file=e203_hbirdv2/e203_biu/e203_biu.v lines=938-938
  assign  ifuerr_icb_cmd_ready = ifuerr_icb_rsp_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000035 file=e203_hbirdv2/e203_biu/e203_biu.v lines=938-938
  
     // 0 Cycle response
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000036 file=e203_hbirdv2/e203_biu/e203_biu.v lines=941-941
  assign  ifuerr_icb_rsp_valid = ifuerr_icb_cmd_valid;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000036 file=e203_hbirdv2/e203_biu/e203_biu.v lines=941-941
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_biu/e203_biu.v:grp:handshake:000003 file=e203_hbirdv2/e203_biu/e203_biu.v lines=938-941
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000037 file=e203_hbirdv2/e203_biu/e203_biu.v lines=942-942
  assign  ifuerr_icb_rsp_err   = 1'b1;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000037 file=e203_hbirdv2/e203_biu/e203_biu.v lines=942-942
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000038 file=e203_hbirdv2/e203_biu/e203_biu.v lines=943-943
  assign  ifuerr_icb_rsp_excl_ok = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000038 file=e203_hbirdv2/e203_biu/e203_biu.v lines=943-943
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000039 file=e203_hbirdv2/e203_biu/e203_biu.v lines=944-944
  assign  ifuerr_icb_rsp_rdata   = {`E203_XLEN{1'b0}};
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_biu/e203_biu.v:assign:000039 file=e203_hbirdv2/e203_biu/e203_biu.v lines=944-944
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_biu/e203_biu.v:grp:assign_cluster:000004 file=e203_hbirdv2/e203_biu/e203_biu.v lines=938-944
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/e203_biu/e203_biu.v:grp:bus_cluster:000004 file=e203_hbirdv2/e203_biu/e203_biu.v lines=938-944


endmodule

