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
//  The itcm_ctrl module control the ITCM access requests 
//
// ====================================================================
`include "e203_defines.v"

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000018 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=29-571
  `ifdef E203_HAS_ITCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000018 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=29-571

module e203_itcm_ctrl(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:port_section:000001 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=32-116
  output itcm_active,
  // The cgstop is coming from CSR (0xBFE mcgstop)'s filed 1
  // // This register is our self-defined CSR register to disable the 
      // ITCM SRAM clock gating for debugging purpose
  input  tcm_cgstop,
  // Note: the ITCM ICB interface only support the single-transaction
  
  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // IFU ICB to ITCM
  //    * Bus cmd channel
  input  ifu2itcm_icb_cmd_valid, // Handshake valid
  output ifu2itcm_icb_cmd_ready, // Handshake ready
            // Note: The data on rdata or wdata channel must be naturally
            //       aligned, this is in line with the AXI definition
  input  [`E203_ITCM_ADDR_WIDTH-1:0] ifu2itcm_icb_cmd_addr, // Bus transaction start addr 
  input  ifu2itcm_icb_cmd_read,   // Read or write
  input  [`E203_ITCM_DATA_WIDTH-1:0] ifu2itcm_icb_cmd_wdata, 
  input  [`E203_ITCM_WMSK_WIDTH-1:0] ifu2itcm_icb_cmd_wmask, 

  //    * Bus RSP channel
  output ifu2itcm_icb_rsp_valid, // Response valid 
  input  ifu2itcm_icb_rsp_ready, // Response ready
  output ifu2itcm_icb_rsp_err,   // Response error
            // Note: the RSP rdata is inline with AXI definition
  output [`E203_ITCM_DATA_WIDTH-1:0] ifu2itcm_icb_rsp_rdata, 
  
  output ifu2itcm_holdup,
  //output ifu2itcm_replay,

  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // LSU ICB to ITCM
  //    * Bus cmd channel
  input  lsu2itcm_icb_cmd_valid, // Handshake valid
  output lsu2itcm_icb_cmd_ready, // Handshake ready
            // Note: The data on rdata or wdata channel must be naturally
            //       aligned, this is in line with the AXI definition
  input  [`E203_ITCM_ADDR_WIDTH-1:0]   lsu2itcm_icb_cmd_addr, // Bus transaction start addr 
  input  lsu2itcm_icb_cmd_read,   // Read or write
  input  [32-1:0] lsu2itcm_icb_cmd_wdata, 
  input  [4-1:0] lsu2itcm_icb_cmd_wmask, 

  //    * Bus RSP channel
  output lsu2itcm_icb_rsp_valid, // Response valid 
  input  lsu2itcm_icb_rsp_ready, // Response ready
  output lsu2itcm_icb_rsp_err,   // Response error
            // Note: the RSP rdata is inline with AXI definition
  output [32-1:0] lsu2itcm_icb_rsp_rdata, 



//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000001 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=84-104
  `ifdef E203_HAS_ITCM_EXTITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000001 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=84-104
  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // External-agent ICB to ITCM
  //    * Bus cmd channel
  input  ext2itcm_icb_cmd_valid, // Handshake valid
  output ext2itcm_icb_cmd_ready, // Handshake ready
            // Note: The data on rdata or wdata channel must be naturally
            //       aligned, this is in line with the AXI definition
  input  [`E203_ITCM_ADDR_WIDTH-1:0]   ext2itcm_icb_cmd_addr, // Bus transaction start addr 
  input  ext2itcm_icb_cmd_read,   // Read or write
  input  [32-1:0] ext2itcm_icb_cmd_wdata, 
  input  [ 4-1:0] ext2itcm_icb_cmd_wmask, 

  //    * Bus RSP channel
  output ext2itcm_icb_rsp_valid, // Response valid 
  input  ext2itcm_icb_rsp_ready, // Response ready
  output ext2itcm_icb_rsp_err,   // Response error
            // Note: the RSP rdata is inline with AXI definition
  output [32-1:0] ext2itcm_icb_rsp_rdata, 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000001 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=84-104
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000001 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=84-104

  output                         itcm_ram_cs,  
  output                         itcm_ram_we,  
  output [`E203_ITCM_RAM_AW-1:0] itcm_ram_addr, 
  output [`E203_ITCM_RAM_MW-1:0] itcm_ram_wem,
  output [`E203_ITCM_RAM_DW-1:0] itcm_ram_din,          
  input  [`E203_ITCM_RAM_DW-1:0] itcm_ram_dout,
  output                         clk_itcm_ram,

  input  test_mode,
  input  clk,
  input  rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:port_section:000001 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=32-116
  );

    // LSU2ITCM converted to ICM data width
  //    * Bus cmd channel
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=121-132
  wire lsu_icb_cmd_valid;
  wire lsu_icb_cmd_ready;
  wire [`E203_ITCM_ADDR_WIDTH-1:0] lsu_icb_cmd_addr;
  wire lsu_icb_cmd_read;
  wire [`E203_ITCM_DATA_WIDTH-1:0] lsu_icb_cmd_wdata;
  wire [`E203_ITCM_DATA_WIDTH/8-1:0] lsu_icb_cmd_wmask;

  //    * Bus RSP channel
  wire lsu_icb_rsp_valid;
  wire lsu_icb_rsp_ready;
  wire lsu_icb_rsp_err;
  wire [`E203_ITCM_DATA_WIDTH-1:0] lsu_icb_rsp_rdata; 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=121-132

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:inst:000001 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=134-184
  sirv_gnrl_icb_n2w # (
  .FIFO_OUTS_NUM   (`E203_ITCM_OUTS_NUM),
  .FIFO_CUT_READY  (0),
  .USR_W      (1),
  .AW         (`E203_ITCM_ADDR_WIDTH),
  .X_W        (32),
  .Y_W        (`E203_ITCM_DATA_WIDTH) 
  ) u_itcm_icb_lsu2itcm_n2w(
  .i_icb_cmd_valid        (lsu2itcm_icb_cmd_valid ),  
  .i_icb_cmd_ready        (lsu2itcm_icb_cmd_ready ),
  .i_icb_cmd_read         (lsu2itcm_icb_cmd_read ) ,
  .i_icb_cmd_addr         (lsu2itcm_icb_cmd_addr ) ,
  .i_icb_cmd_wdata        (lsu2itcm_icb_cmd_wdata ),
  .i_icb_cmd_wmask        (lsu2itcm_icb_cmd_wmask) ,
  .i_icb_cmd_burst        (2'b0)                   ,
  .i_icb_cmd_beat         (2'b0)                   ,
  .i_icb_cmd_lock         (1'b0),
  .i_icb_cmd_excl         (1'b0),
  .i_icb_cmd_size         (2'b0),
  .i_icb_cmd_usr          (1'b0),
   
  .i_icb_rsp_valid        (lsu2itcm_icb_rsp_valid ),
  .i_icb_rsp_ready        (lsu2itcm_icb_rsp_ready ),
  .i_icb_rsp_err          (lsu2itcm_icb_rsp_err)   ,
  .i_icb_rsp_excl_ok      ()   ,
  .i_icb_rsp_rdata        (lsu2itcm_icb_rsp_rdata ),
  .i_icb_rsp_usr          (),
                                                
  .o_icb_cmd_valid        (lsu_icb_cmd_valid ),  
  .o_icb_cmd_ready        (lsu_icb_cmd_ready ),
  .o_icb_cmd_read         (lsu_icb_cmd_read ) ,
  .o_icb_cmd_addr         (lsu_icb_cmd_addr ) ,
  .o_icb_cmd_wdata        (lsu_icb_cmd_wdata ),
  .o_icb_cmd_wmask        (lsu_icb_cmd_wmask) ,
  .o_icb_cmd_burst        ()                   ,
  .o_icb_cmd_beat         ()                   ,
  .o_icb_cmd_lock         (),
  .o_icb_cmd_excl         (),
  .o_icb_cmd_size         (),
  .o_icb_cmd_usr          (),
   
  .o_icb_rsp_valid        (lsu_icb_rsp_valid ),
  .o_icb_rsp_ready        (lsu_icb_rsp_ready ),
  .o_icb_rsp_err          (lsu_icb_rsp_err)   ,
  .o_icb_rsp_excl_ok      (1'b0)   ,
  .o_icb_rsp_rdata        (lsu_icb_rsp_rdata ),
  .o_icb_rsp_usr          (1'b0),

  .clk                    (clk   )                  ,
  .rst_n                  (rst_n )                 
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:inst:000001 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=134-184

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000004 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=186-262
  `ifdef E203_HAS_ITCM_EXTITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000004 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=186-262
  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // EXTITF converted to ICM data width
  //    * Bus cmd channel
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=191-205
  wire ext_icb_cmd_valid;
  wire ext_icb_cmd_ready;
  wire [`E203_ITCM_ADDR_WIDTH-1:0] ext_icb_cmd_addr;
  wire ext_icb_cmd_read;
  wire [`E203_ITCM_DATA_WIDTH-1:0] ext_icb_cmd_wdata;
  wire [`E203_ITCM_WMSK_WIDTH-1:0] ext_icb_cmd_wmask;

  //    * Bus RSP channel
  wire ext_icb_rsp_valid;
  wire ext_icb_rsp_ready;
  wire ext_icb_rsp_err;
  wire [`E203_ITCM_DATA_WIDTH-1:0] ext_icb_rsp_rdata; 

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000003 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=204-261
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000003:br:000001 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=204-257
  `ifdef E203_SYSMEM_DATA_WIDTH_IS_32 //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000003 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=204-261
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000003:br:000001 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=204-257
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000002 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=205-257
  `ifdef E203_ITCM_DATA_WIDTH_IS_64 //{
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=191-205
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000002 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=205-257
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:inst:000002 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=206-256
  sirv_gnrl_icb_n2w # (
  .USR_W      (1),
  .FIFO_OUTS_NUM   (`E203_ITCM_OUTS_NUM),
  .FIFO_CUT_READY  (0),
  .AW         (`E203_ITCM_ADDR_WIDTH),
  .X_W        (`E203_SYSMEM_DATA_WIDTH), 
  .Y_W        (`E203_ITCM_DATA_WIDTH) 
  ) u_itcm_icb_ext2itcm_n2w(
  .i_icb_cmd_valid        (ext2itcm_icb_cmd_valid ),  
  .i_icb_cmd_ready        (ext2itcm_icb_cmd_ready ),
  .i_icb_cmd_read         (ext2itcm_icb_cmd_read ) ,
  .i_icb_cmd_addr         (ext2itcm_icb_cmd_addr ) ,
  .i_icb_cmd_wdata        (ext2itcm_icb_cmd_wdata ),
  .i_icb_cmd_wmask        (ext2itcm_icb_cmd_wmask) ,
  .i_icb_cmd_burst        (2'b0)                   ,
  .i_icb_cmd_beat         (2'b0)                   ,
  .i_icb_cmd_lock         (1'b0),
  .i_icb_cmd_excl         (1'b0),
  .i_icb_cmd_size         (2'b0),
  .i_icb_cmd_usr          (1'b0),
   
  .i_icb_rsp_valid        (ext2itcm_icb_rsp_valid ),
  .i_icb_rsp_ready        (ext2itcm_icb_rsp_ready ),
  .i_icb_rsp_err          (ext2itcm_icb_rsp_err)   ,
  .i_icb_rsp_excl_ok      ()   ,
  .i_icb_rsp_rdata        (ext2itcm_icb_rsp_rdata ),
  .i_icb_rsp_usr          (),
                                                
  .o_icb_cmd_valid        (ext_icb_cmd_valid ),  
  .o_icb_cmd_ready        (ext_icb_cmd_ready ),
  .o_icb_cmd_read         (ext_icb_cmd_read ) ,
  .o_icb_cmd_addr         (ext_icb_cmd_addr ) ,
  .o_icb_cmd_wdata        (ext_icb_cmd_wdata ),
  .o_icb_cmd_wmask        (ext_icb_cmd_wmask) ,
  .o_icb_cmd_burst        ()                   ,
  .o_icb_cmd_beat         ()                   ,
  .o_icb_cmd_lock         (),
  .o_icb_cmd_excl         (),
  .o_icb_cmd_size         (),
  .o_icb_cmd_usr          (),
   
  .o_icb_rsp_valid        (ext_icb_rsp_valid ),
  .o_icb_rsp_ready        (ext_icb_rsp_ready ),
  .o_icb_rsp_err          (ext_icb_rsp_err)   ,
  .o_icb_rsp_excl_ok      (1'b0),
  .o_icb_rsp_rdata        (ext_icb_rsp_rdata ),
  .o_icb_rsp_usr          (1'b0),

  .clk                    (clk  ) ,
  .rst_n                  (rst_n)                 
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:inst:000002 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=206-256
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000002 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=205-257
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000002 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=205-257
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000003:br:000001 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=204-257
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000003:br:000001 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=204-257
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000003:br:000002 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=258-260
  `else//}{
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000003:br:000002 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=258-260
      !!! ERROR: There must be something wrong, our System interface
                must be 32bits and ITCM must be 64bits to save area and powers!!!
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000003:br:000002 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=258-260
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000003:br:000002 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=258-260
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000003 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=204-261
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000003 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=204-261
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000004 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=186-262
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000004 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=186-262

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=264-276
  wire arbt_icb_cmd_valid;
  wire arbt_icb_cmd_ready;
  wire [`E203_ITCM_ADDR_WIDTH-1:0] arbt_icb_cmd_addr;
  wire arbt_icb_cmd_read;
  wire [`E203_ITCM_DATA_WIDTH-1:0] arbt_icb_cmd_wdata;
  wire [`E203_ITCM_WMSK_WIDTH-1:0] arbt_icb_cmd_wmask;

  wire arbt_icb_rsp_valid;
  wire arbt_icb_rsp_ready;
  wire arbt_icb_rsp_err;
  wire [`E203_ITCM_DATA_WIDTH-1:0] arbt_icb_rsp_rdata;

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000005 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=276-282
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000005:br:000001 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=276-278
  `ifdef E203_HAS_ITCM_EXTITF //{
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=264-276
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:param_decl:000001 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=277-282
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000005 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=276-282
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000005:br:000001 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=276-278
      localparam ITCM_ARBT_I_NUM = 2;
      localparam ITCM_ARBT_I_PTR_W = 1;
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000005:br:000001 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=276-278
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000005:br:000001 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=276-278
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000005:br:000002 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=279-281
  `else//}{
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000005:br:000002 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=279-281
      localparam ITCM_ARBT_I_NUM = 1;
      localparam ITCM_ARBT_I_PTR_W = 1;
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000005:br:000002 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=279-281
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000005:br:000002 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=279-281
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000005 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=276-282
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000005 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=276-282
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:param_decl:000001 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=277-282

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=284-294
  wire [ITCM_ARBT_I_NUM*1-1:0] arbt_bus_icb_cmd_valid;
  wire [ITCM_ARBT_I_NUM*1-1:0] arbt_bus_icb_cmd_ready;
  wire [ITCM_ARBT_I_NUM*`E203_ITCM_ADDR_WIDTH-1:0] arbt_bus_icb_cmd_addr;
  wire [ITCM_ARBT_I_NUM*1-1:0] arbt_bus_icb_cmd_read;
  wire [ITCM_ARBT_I_NUM*`E203_ITCM_DATA_WIDTH-1:0] arbt_bus_icb_cmd_wdata;
  wire [ITCM_ARBT_I_NUM*`E203_ITCM_WMSK_WIDTH-1:0] arbt_bus_icb_cmd_wmask;

  wire [ITCM_ARBT_I_NUM*1-1:0] arbt_bus_icb_rsp_valid;
  wire [ITCM_ARBT_I_NUM*1-1:0] arbt_bus_icb_rsp_ready;
  wire [ITCM_ARBT_I_NUM*1-1:0] arbt_bus_icb_rsp_err;
  wire [ITCM_ARBT_I_NUM*`E203_ITCM_DATA_WIDTH-1:0] arbt_bus_icb_rsp_rdata;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=284-294

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=296-363
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:bus_cluster:000001 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=296-363
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000001 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=296-303
  assign arbt_bus_icb_cmd_valid =
      // LSU take higher priority
                           {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000006 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=299-301
                      `ifdef E203_HAS_ITCM_EXTITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000006 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=299-301
                             ext_icb_cmd_valid,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000006 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=299-301
                      `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000006 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=299-301
                             lsu_icb_cmd_valid
                           } ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000001 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=296-303
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000002 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=304-310
  assign arbt_bus_icb_cmd_addr =
                           {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000007 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=306-308
                      `ifdef E203_HAS_ITCM_EXTITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000007 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=306-308
                             ext_icb_cmd_addr,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000007 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=306-308
                      `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000007 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=306-308
                             lsu_icb_cmd_addr
                           } ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000002 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=304-310
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000003 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=311-317
  assign arbt_bus_icb_cmd_read =
                           {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000008 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=313-315
                      `ifdef E203_HAS_ITCM_EXTITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000008 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=313-315
                             ext_icb_cmd_read,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000008 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=313-315
                      `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000008 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=313-315
                             lsu_icb_cmd_read
                           } ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000003 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=311-317
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000004 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=318-324
  assign arbt_bus_icb_cmd_wdata =
                           {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000009 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=320-322
                      `ifdef E203_HAS_ITCM_EXTITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000009 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=320-322
                             ext_icb_cmd_wdata,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000009 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=320-322
                      `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000009 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=320-322
                             lsu_icb_cmd_wdata
                           } ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000004 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=318-324
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000005 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=325-331
  assign arbt_bus_icb_cmd_wmask =
                           {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000010 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=327-329
                      `ifdef E203_HAS_ITCM_EXTITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000010 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=327-329
                             ext_icb_cmd_wmask,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000010 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=327-329
                      `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000010 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=327-329
                             lsu_icb_cmd_wmask
                           } ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000005 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=325-331
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:handshake:000001 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=332-345
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000006 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=332-337
  assign                   {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000011 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=333-335
                      `ifdef E203_HAS_ITCM_EXTITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000011 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=333-335
                             ext_icb_cmd_ready,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000011 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=333-335
                      `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000011 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=333-335
                             lsu_icb_cmd_ready
                           } = arbt_bus_icb_cmd_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000006 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=332-337


//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000007 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=340-345
  assign                   {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000012 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=341-343
                      `ifdef E203_HAS_ITCM_EXTITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000012 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=341-343
                             ext_icb_rsp_valid,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000012 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=341-343
                      `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000012 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=341-343
                             lsu_icb_rsp_valid
                           } = arbt_bus_icb_rsp_valid;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000007 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=340-345
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:handshake:000001 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=332-345
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000008 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=346-351
  assign                   {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000013 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=347-349
                      `ifdef E203_HAS_ITCM_EXTITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000013 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=347-349
                             ext_icb_rsp_err,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000013 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=347-349
                      `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000013 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=347-349
                             lsu_icb_rsp_err
                           } = arbt_bus_icb_rsp_err;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000008 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=346-351
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000009 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=352-357
  assign                   {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000014 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=353-355
                      `ifdef E203_HAS_ITCM_EXTITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000014 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=353-355
                             ext_icb_rsp_rdata,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000014 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=353-355
                      `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000014 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=353-355
                             lsu_icb_rsp_rdata
                           } = arbt_bus_icb_rsp_rdata;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000009 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=352-357
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000010 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=358-363
  assign arbt_bus_icb_rsp_ready = {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000015 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=359-361
                      `ifdef E203_HAS_ITCM_EXTITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000015 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=359-361
                             ext_icb_rsp_ready,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000015 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=359-361
                      `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000015 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=359-361
                             lsu_icb_rsp_ready
                           };
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000010 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=358-363
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=296-363
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:bus_cluster:000001 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=296-363

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:inst:000003 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=365-420
  sirv_gnrl_icb_arbt # (
  .ARBT_SCHEME (0),// Priority based
  .ALLOW_0CYCL_RSP (0),// Dont allow the 0 cycle response because for ITCM and DTCM, 
                       //   Dcache, .etc, definitely they cannot reponse as 0 cycle
  .FIFO_OUTS_NUM   (`E203_ITCM_OUTS_NUM),
  .FIFO_CUT_READY(0),
  .USR_W      (1),
  .ARBT_NUM   (ITCM_ARBT_I_NUM  ),
  .ARBT_PTR_W (ITCM_ARBT_I_PTR_W),
  .AW         (`E203_ITCM_ADDR_WIDTH),
  .DW         (`E203_ITCM_DATA_WIDTH) 
  ) u_itcm_icb_arbt(
  .o_icb_cmd_valid        (arbt_icb_cmd_valid )     ,
  .o_icb_cmd_ready        (arbt_icb_cmd_ready )     ,
  .o_icb_cmd_read         (arbt_icb_cmd_read )      ,
  .o_icb_cmd_addr         (arbt_icb_cmd_addr )      ,
  .o_icb_cmd_wdata        (arbt_icb_cmd_wdata )     ,
  .o_icb_cmd_wmask        (arbt_icb_cmd_wmask)      ,
  .o_icb_cmd_burst        ()     ,
  .o_icb_cmd_beat         ()     ,
  .o_icb_cmd_lock         ()     ,
  .o_icb_cmd_excl         ()     ,
  .o_icb_cmd_size         ()     ,
  .o_icb_cmd_usr          ()     ,
                                
  .o_icb_rsp_valid        (arbt_icb_rsp_valid )     ,
  .o_icb_rsp_ready        (arbt_icb_rsp_ready )     ,
  .o_icb_rsp_err          (arbt_icb_rsp_err)        ,
  .o_icb_rsp_rdata        (arbt_icb_rsp_rdata )     ,
  .o_icb_rsp_usr          (1'b0),
  .o_icb_rsp_excl_ok      (1'b0),
                               
  .i_bus_icb_cmd_ready    (arbt_bus_icb_cmd_ready ) ,
  .i_bus_icb_cmd_valid    (arbt_bus_icb_cmd_valid ) ,
  .i_bus_icb_cmd_read     (arbt_bus_icb_cmd_read )  ,
  .i_bus_icb_cmd_addr     (arbt_bus_icb_cmd_addr )  ,
  .i_bus_icb_cmd_wdata    (arbt_bus_icb_cmd_wdata ) ,
  .i_bus_icb_cmd_wmask    (arbt_bus_icb_cmd_wmask)  ,
  .i_bus_icb_cmd_burst    ({2*ITCM_ARBT_I_NUM{1'b0}}) ,
  .i_bus_icb_cmd_beat     ({2*ITCM_ARBT_I_NUM{1'b0}}) ,
  .i_bus_icb_cmd_lock     ({1*ITCM_ARBT_I_NUM{1'b0}}),
  .i_bus_icb_cmd_excl     ({1*ITCM_ARBT_I_NUM{1'b0}}),
  .i_bus_icb_cmd_size     ({2*ITCM_ARBT_I_NUM{1'b0}}),
  .i_bus_icb_cmd_usr      ({1*ITCM_ARBT_I_NUM{1'b0}}),

                                
  .i_bus_icb_rsp_valid    (arbt_bus_icb_rsp_valid ) ,
  .i_bus_icb_rsp_ready    (arbt_bus_icb_rsp_ready ) ,
  .i_bus_icb_rsp_err      (arbt_bus_icb_rsp_err)    ,
  .i_bus_icb_rsp_rdata    (arbt_bus_icb_rsp_rdata ) ,
  .i_bus_icb_rsp_usr      (),
  .i_bus_icb_rsp_excl_ok  (),
                             
  .clk                    (clk  )                     ,
  .rst_n                  (rst_n)
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:inst:000003 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=365-420





//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:internal_signal:000005 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=426-426
  wire sram_ready2ifu = 1'b1
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:internal_signal:000005 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=426-426
                   //The EXT and load/store have higher priotry than the ifetch
                      & (~arbt_icb_cmd_valid)
                   ;

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:internal_signal:000006 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=431-431
  wire sram_ready2arbt = 1'b1
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:internal_signal:000006 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=431-431
                  ;


//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:internal_signal:000007 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=435-439
  wire sram_sel_ifu  = sram_ready2ifu  & ifu2itcm_icb_cmd_valid;
  wire sram_sel_arbt = sram_ready2arbt & arbt_icb_cmd_valid;

  wire sram_icb_cmd_ready;
  wire sram_icb_cmd_valid;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:internal_signal:000007 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=435-439

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=441-442
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:handshake:000002 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=441-442
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000011 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=441-441
  assign ifu2itcm_icb_cmd_ready = sram_ready2ifu   & sram_icb_cmd_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000011 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=441-441
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000012 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=442-442
  assign arbt_icb_cmd_ready = sram_ready2arbt  & sram_icb_cmd_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000012 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=442-442
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=441-442
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:handshake:000002 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=441-442



//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:internal_signal:000008 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=446-449
  wire [`E203_ITCM_ADDR_WIDTH-1:0] sram_icb_cmd_addr;
  wire sram_icb_cmd_read;
  wire [`E203_ITCM_DATA_WIDTH-1:0] sram_icb_cmd_wdata;
  wire [`E203_ITCM_WMSK_WIDTH-1:0] sram_icb_cmd_wmask;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:internal_signal:000008 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=446-449

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=451-461
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:bus_cluster:000002 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=451-461
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000013 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=451-452
  assign sram_icb_cmd_valid = (sram_sel_ifu   & ifu2itcm_icb_cmd_valid)
                            | (sram_sel_arbt  & arbt_icb_cmd_valid);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000013 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=451-452

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000014 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=454-455
  assign sram_icb_cmd_addr  = ({`E203_ITCM_ADDR_WIDTH{sram_sel_ifu  }} & ifu2itcm_icb_cmd_addr)
                            | ({`E203_ITCM_ADDR_WIDTH{sram_sel_arbt }} & arbt_icb_cmd_addr);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000014 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=454-455
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000015 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=456-457
  assign sram_icb_cmd_read  = (sram_sel_ifu   & ifu2itcm_icb_cmd_read)
                            | (sram_sel_arbt  & arbt_icb_cmd_read);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000015 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=456-457
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000016 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=458-459
  assign sram_icb_cmd_wdata = ({`E203_ITCM_DATA_WIDTH{sram_sel_ifu  }} & ifu2itcm_icb_cmd_wdata)
                            | ({`E203_ITCM_DATA_WIDTH{sram_sel_arbt }} & arbt_icb_cmd_wdata);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000016 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=458-459
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000017 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=460-461
  assign sram_icb_cmd_wmask = ({`E203_ITCM_WMSK_WIDTH{sram_sel_ifu  }} & ifu2itcm_icb_cmd_wmask)
                            | ({`E203_ITCM_WMSK_WIDTH{sram_sel_arbt }} & arbt_icb_cmd_wmask);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000017 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=460-461
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=451-461
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:bus_cluster:000002 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=451-461

                        
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:internal_signal:000009 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=464-470
  wire sram_icb_cmd_ifu = sram_sel_ifu;


  wire  [1:0] sram_icb_rsp_usr;
  wire  [1:0] sram_icb_cmd_usr =  {sram_icb_cmd_ifu,sram_icb_cmd_read};
  wire sram_icb_rsp_ifu ;
  wire sram_icb_rsp_read; 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:internal_signal:000009 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=464-470
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000018 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=471-471
  assign {sram_icb_rsp_ifu, sram_icb_rsp_read} = sram_icb_rsp_usr;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000018 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=471-471
  
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:internal_signal:000010 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=473-480
  wire itcm_sram_ctrl_active;

  wire sram_icb_rsp_valid;
  wire sram_icb_rsp_ready;
  wire [`E203_ITCM_DATA_WIDTH-1:0] sram_icb_rsp_rdata;
  wire sram_icb_rsp_err;

//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000016 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=480-518
  `ifndef E203_HAS_ECC //{
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:internal_signal:000010 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=473-480
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000016 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=480-518
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:inst:000004 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=481-515
  sirv_sram_icb_ctrl #(
      .DW     (`E203_ITCM_DATA_WIDTH),
      .AW     (`E203_ITCM_ADDR_WIDTH),
      .MW     (`E203_ITCM_WMSK_WIDTH),
      .AW_LSB (3),// ITCM is 64bits wide, so the LSB is 3
      .USR_W  (2) 
  ) u_sram_icb_ctrl(
     .sram_ctrl_active (itcm_sram_ctrl_active),
     .tcm_cgstop       (tcm_cgstop),
     
     .i_icb_cmd_valid (sram_icb_cmd_valid),
     .i_icb_cmd_ready (sram_icb_cmd_ready),
     .i_icb_cmd_read  (sram_icb_cmd_read ),
     .i_icb_cmd_addr  (sram_icb_cmd_addr ), 
     .i_icb_cmd_wdata (sram_icb_cmd_wdata), 
     .i_icb_cmd_wmask (sram_icb_cmd_wmask), 
     .i_icb_cmd_usr   (sram_icb_cmd_usr  ),
  
     .i_icb_rsp_valid (sram_icb_rsp_valid),
     .i_icb_rsp_ready (sram_icb_rsp_ready),
     .i_icb_rsp_rdata (sram_icb_rsp_rdata),
     .i_icb_rsp_usr   (sram_icb_rsp_usr  ),
  
     .ram_cs   (itcm_ram_cs  ),  
     .ram_we   (itcm_ram_we  ),  
     .ram_addr (itcm_ram_addr), 
     .ram_wem  (itcm_ram_wem ),
     .ram_din  (itcm_ram_din ),          
     .ram_dout (itcm_ram_dout),
     .clk_ram  (clk_itcm_ram ),
  
     .test_mode(test_mode  ),
     .clk  (clk  ),
     .rst_n(rst_n)  
    );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:inst:000004 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=481-515

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000019 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=517-517
    assign sram_icb_rsp_err = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000019 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=517-517
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000016 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=480-518
  `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000016 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=480-518

  



  // The E2 pass to IFU RSP channel only when it is IFU access 
  // The E2 pass to ARBT RSP channel only when it is not IFU access
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:assign_cluster:000004 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=526-535
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:bus_cluster:000003 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=526-535
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:handshake:000003 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=526-529
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000020 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=526-527
  assign sram_icb_rsp_ready = sram_icb_rsp_ifu ? 
                    ifu2itcm_icb_rsp_ready : arbt_icb_rsp_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000020 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=526-527

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000021 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=529-529
  assign ifu2itcm_icb_rsp_valid = sram_icb_rsp_valid & sram_icb_rsp_ifu;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000021 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=529-529
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:handshake:000003 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=526-529
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000022 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=530-530
  assign ifu2itcm_icb_rsp_err   = sram_icb_rsp_err;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000022 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=530-530
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000023 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=531-531
  assign ifu2itcm_icb_rsp_rdata = sram_icb_rsp_rdata;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000023 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=531-531

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000024 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=533-533
  assign arbt_icb_rsp_valid = sram_icb_rsp_valid & (~sram_icb_rsp_ifu);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000024 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=533-533
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000025 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=534-534
  assign arbt_icb_rsp_err   = sram_icb_rsp_err;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000025 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=534-534
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000026 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=535-535
  assign arbt_icb_rsp_rdata = sram_icb_rsp_rdata;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000026 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=535-535
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:assign_cluster:000004 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=526-535
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:bus_cluster:000003 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=526-535

 


  // The holdup indicating the target is not accessed by other agents 
  // since last accessed by IFU, and the output of it is holding up
  // last value. Hence,
  //   * The holdup flag it set when there is a succuess (no-error) ifetch
  //       accessed this target
  //   * The holdup flag it clear when when 
  //         ** other agent (non-IFU) accessed this target
  //         ** other agent (non-IFU) accessed this target
                //for example:
                //   *** The external agent accessed the ITCM
                //   *** I$ updated by cache maintaineice operation
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:internal_signal:000011 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=551-557
  wire ifu_holdup_r;
  // The IFU holdup will be set after last time accessed by a IFU access
  wire ifu_holdup_set =   sram_icb_cmd_ifu & itcm_ram_cs;
  // The IFU holdup will be cleared after last time accessed by a non-IFU access
  wire ifu_holdup_clr = (~sram_icb_cmd_ifu) & itcm_ram_cs;
  wire ifu_holdup_ena = ifu_holdup_set | ifu_holdup_clr;
  wire ifu_holdup_nxt = ifu_holdup_set & (~ifu_holdup_clr);
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:internal_signal:000011 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=551-557
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:inst:000005 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=558-558
  sirv_gnrl_dfflr #(1)ifu_holdup_dffl(ifu_holdup_ena, ifu_holdup_nxt, ifu_holdup_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:inst:000005 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=558-558
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:assign_cluster:000005 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=559-567
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000027 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=559-560
  assign ifu2itcm_holdup = ifu_holdup_r 
                            ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000027 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=559-560


//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000028 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=563-567
  assign itcm_active = ifu2itcm_icb_cmd_valid | lsu2itcm_icb_cmd_valid | itcm_sram_ctrl_active
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000017 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=564-566
                  `ifdef E203_HAS_ITCM_EXTITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000017 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=564-566
                      | ext2itcm_icb_cmd_valid
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000017 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=564-566
                  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000017 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=564-566
                      ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:assign:000028 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=563-567
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:grp:assign_cluster:000005 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=559-567

endmodule

//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000018 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=29-571
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v:pp_blk:000018 file=e203_hbirdv2/e203_itcm_ctrl/e203_itcm_ctrl.v lines=29-571
