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
//  The dtcm_ctrl module control the DTCM access requests 
//
// ====================================================================
`include "e203_defines.v"

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000015 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=29-344
  `ifdef E203_HAS_DTCM //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000015 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=29-344

module e203_dtcm_ctrl(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:grp:port_section:000001 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=32-93
  output dtcm_active,
  // The cgstop is coming from CSR (0xBFE mcgstop)'s filed 1
  // // This register is our self-defined CSR register to disable the 
      // DTCM SRAM clock gating for debugging purpose
  input  tcm_cgstop,
  // Note: the DTCM ICB interface only support the single-transaction
  
  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // LSU ICB to DTCM
  //    * Bus cmd channel
  input  lsu2dtcm_icb_cmd_valid, // Handshake valid
  output lsu2dtcm_icb_cmd_ready, // Handshake ready
            // Note: The data on rdata or wdata channel must be naturally
            //       aligned, this is in line with the AXI definition
  input  [`E203_DTCM_ADDR_WIDTH-1:0]   lsu2dtcm_icb_cmd_addr, // Bus transaction start addr 
  input  lsu2dtcm_icb_cmd_read,   // Read or write
  input  [32-1:0] lsu2dtcm_icb_cmd_wdata, 
  input  [4-1:0] lsu2dtcm_icb_cmd_wmask, 

  //    * Bus RSP channel
  output lsu2dtcm_icb_rsp_valid, // Response valid 
  input  lsu2dtcm_icb_rsp_ready, // Response ready
  output lsu2dtcm_icb_rsp_err,   // Response error
            // Note: the RSP rdata is inline with AXI definition
  output [32-1:0] lsu2dtcm_icb_rsp_rdata, 



//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000001 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=61-81
  `ifdef E203_HAS_DTCM_EXTITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000001 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=61-81
  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // External-agent ICB to DTCM
  //    * Bus cmd channel
  input  ext2dtcm_icb_cmd_valid, // Handshake valid
  output ext2dtcm_icb_cmd_ready, // Handshake ready
            // Note: The data on rdata or wdata channel must be naturally
            //       aligned, this is in line with the AXI definition
  input  [`E203_DTCM_ADDR_WIDTH-1:0]   ext2dtcm_icb_cmd_addr, // Bus transaction start addr 
  input  ext2dtcm_icb_cmd_read,   // Read or write
  input  [32-1:0] ext2dtcm_icb_cmd_wdata, 
  input  [ 4-1:0] ext2dtcm_icb_cmd_wmask, 

  //    * Bus RSP channel
  output ext2dtcm_icb_rsp_valid, // Response valid 
  input  ext2dtcm_icb_rsp_ready, // Response ready
  output ext2dtcm_icb_rsp_err,   // Response error
            // Note: the RSP rdata is inline with AXI definition
  output [32-1:0] ext2dtcm_icb_rsp_rdata, 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000001 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=61-81
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000001 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=61-81

  output                         dtcm_ram_cs,  
  output                         dtcm_ram_we,  
  output [`E203_DTCM_RAM_AW-1:0] dtcm_ram_addr, 
  output [`E203_DTCM_RAM_MW-1:0] dtcm_ram_wem,
  output [`E203_DTCM_RAM_DW-1:0] dtcm_ram_din,          
  input  [`E203_DTCM_RAM_DW-1:0] dtcm_ram_dout,
  output                         clk_dtcm_ram,

  input  test_mode,
  input  clk,
  input  rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:grp:port_section:000001 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=32-93
  );


//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=97-109
  wire arbt_icb_cmd_valid;
  wire arbt_icb_cmd_ready;
  wire [`E203_DTCM_ADDR_WIDTH-1:0] arbt_icb_cmd_addr;
  wire arbt_icb_cmd_read;
  wire [`E203_DTCM_DATA_WIDTH-1:0] arbt_icb_cmd_wdata;
  wire [`E203_DTCM_WMSK_WIDTH-1:0] arbt_icb_cmd_wmask;

  wire arbt_icb_rsp_valid;
  wire arbt_icb_rsp_ready;
  wire arbt_icb_rsp_err;
  wire [`E203_DTCM_DATA_WIDTH-1:0] arbt_icb_rsp_rdata;

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000002 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=109-115
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000002:br:000001 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=109-111
  `ifdef E203_HAS_DTCM_EXTITF //{
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=97-109
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:grp:param_decl:000001 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=110-115
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000002 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=109-115
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000002:br:000001 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=109-111
      localparam DTCM_ARBT_I_NUM = 2;
      localparam DTCM_ARBT_I_PTR_W = 1;
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000002:br:000001 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=109-111
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000002:br:000001 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=109-111
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000002:br:000002 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=112-114
  `else//}{
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000002:br:000002 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=112-114
      localparam DTCM_ARBT_I_NUM = 1;
      localparam DTCM_ARBT_I_PTR_W = 1;
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000002:br:000002 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=112-114
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000002:br:000002 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=112-114
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000002 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=109-115
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000002 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=109-115
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:grp:param_decl:000001 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=110-115

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=117-127
  wire [DTCM_ARBT_I_NUM*1-1:0] arbt_bus_icb_cmd_valid;
  wire [DTCM_ARBT_I_NUM*1-1:0] arbt_bus_icb_cmd_ready;
  wire [DTCM_ARBT_I_NUM*`E203_DTCM_ADDR_WIDTH-1:0] arbt_bus_icb_cmd_addr;
  wire [DTCM_ARBT_I_NUM*1-1:0] arbt_bus_icb_cmd_read;
  wire [DTCM_ARBT_I_NUM*`E203_DTCM_DATA_WIDTH-1:0] arbt_bus_icb_cmd_wdata;
  wire [DTCM_ARBT_I_NUM*`E203_DTCM_WMSK_WIDTH-1:0] arbt_bus_icb_cmd_wmask;

  wire [DTCM_ARBT_I_NUM*1-1:0] arbt_bus_icb_rsp_valid;
  wire [DTCM_ARBT_I_NUM*1-1:0] arbt_bus_icb_rsp_ready;
  wire [DTCM_ARBT_I_NUM*1-1:0] arbt_bus_icb_rsp_err;
  wire [DTCM_ARBT_I_NUM*`E203_DTCM_DATA_WIDTH-1:0] arbt_bus_icb_rsp_rdata;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=117-127

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=129-196
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:grp:bus_cluster:000001 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=129-196
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000001 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=129-136
  assign arbt_bus_icb_cmd_valid =
      //LSU take higher priority
                           {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000003 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=132-134
                      `ifdef E203_HAS_DTCM_EXTITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000003 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=132-134
                             ext2dtcm_icb_cmd_valid,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000003 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=132-134
                      `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000003 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=132-134
                             lsu2dtcm_icb_cmd_valid
                           } ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000001 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=129-136
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000002 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=137-143
  assign arbt_bus_icb_cmd_addr =
                           {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000004 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=139-141
                      `ifdef E203_HAS_DTCM_EXTITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000004 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=139-141
                             ext2dtcm_icb_cmd_addr,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000004 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=139-141
                      `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000004 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=139-141
                             lsu2dtcm_icb_cmd_addr
                           } ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000002 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=137-143
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000003 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=144-150
  assign arbt_bus_icb_cmd_read =
                           {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000005 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=146-148
                      `ifdef E203_HAS_DTCM_EXTITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000005 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=146-148
                             ext2dtcm_icb_cmd_read,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000005 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=146-148
                      `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000005 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=146-148
                             lsu2dtcm_icb_cmd_read
                           } ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000003 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=144-150
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000004 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=151-157
  assign arbt_bus_icb_cmd_wdata =
                           {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000006 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=153-155
                      `ifdef E203_HAS_DTCM_EXTITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000006 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=153-155
                             ext2dtcm_icb_cmd_wdata,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000006 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=153-155
                      `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000006 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=153-155
                             lsu2dtcm_icb_cmd_wdata
                           } ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000004 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=151-157
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000005 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=158-164
  assign arbt_bus_icb_cmd_wmask =
                           {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000007 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=160-162
                      `ifdef E203_HAS_DTCM_EXTITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000007 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=160-162
                             ext2dtcm_icb_cmd_wmask,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000007 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=160-162
                      `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000007 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=160-162
                             lsu2dtcm_icb_cmd_wmask
                           } ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000005 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=158-164
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:grp:handshake:000001 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=165-178
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000006 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=165-170
  assign                   {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000008 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=166-168
                      `ifdef E203_HAS_DTCM_EXTITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000008 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=166-168
                             ext2dtcm_icb_cmd_ready,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000008 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=166-168
                      `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000008 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=166-168
                             lsu2dtcm_icb_cmd_ready
                           } = arbt_bus_icb_cmd_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000006 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=165-170


//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000007 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=173-178
  assign                   {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000009 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=174-176
                      `ifdef E203_HAS_DTCM_EXTITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000009 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=174-176
                             ext2dtcm_icb_rsp_valid,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000009 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=174-176
                      `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000009 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=174-176
                             lsu2dtcm_icb_rsp_valid
                           } = arbt_bus_icb_rsp_valid;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000007 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=173-178
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:grp:handshake:000001 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=165-178
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000008 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=179-184
  assign                   {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000010 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=180-182
                      `ifdef E203_HAS_DTCM_EXTITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000010 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=180-182
                             ext2dtcm_icb_rsp_err,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000010 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=180-182
                      `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000010 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=180-182
                             lsu2dtcm_icb_rsp_err
                           } = arbt_bus_icb_rsp_err;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000008 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=179-184
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000009 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=185-190
  assign                   {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000011 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=186-188
                      `ifdef E203_HAS_DTCM_EXTITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000011 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=186-188
                             ext2dtcm_icb_rsp_rdata,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000011 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=186-188
                      `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000011 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=186-188
                             lsu2dtcm_icb_rsp_rdata
                           } = arbt_bus_icb_rsp_rdata;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000009 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=185-190
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000010 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=191-196
  assign arbt_bus_icb_rsp_ready = {
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000012 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=192-194
                      `ifdef E203_HAS_DTCM_EXTITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000012 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=192-194
                             ext2dtcm_icb_rsp_ready,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000012 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=192-194
                      `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000012 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=192-194
                             lsu2dtcm_icb_rsp_ready
                           };
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000010 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=191-196
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=129-196
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:grp:bus_cluster:000001 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=129-196

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:inst:000001 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=198-253
  sirv_gnrl_icb_arbt # (
  .ARBT_SCHEME (0),// Priority based
  .ALLOW_0CYCL_RSP (0),// Dont allow the 0 cycle response because for ITCM and DTCM, 
                       //   Dcache, .etc, definitely they cannot reponse as 0 cycle
  .FIFO_OUTS_NUM   (`E203_DTCM_OUTS_NUM),
  .FIFO_CUT_READY(0),
  .USR_W      (1),
  .ARBT_NUM   (DTCM_ARBT_I_NUM  ),
  .ARBT_PTR_W (DTCM_ARBT_I_PTR_W),
  .AW         (`E203_DTCM_ADDR_WIDTH),
  .DW         (`E203_DTCM_DATA_WIDTH) 
  ) u_dtcm_icb_arbt(
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
  .i_bus_icb_cmd_burst    ({2*DTCM_ARBT_I_NUM{1'b0}}) ,
  .i_bus_icb_cmd_beat     ({2*DTCM_ARBT_I_NUM{1'b0}}) ,
  .i_bus_icb_cmd_lock     ({1*DTCM_ARBT_I_NUM{1'b0}}),
  .i_bus_icb_cmd_excl     ({1*DTCM_ARBT_I_NUM{1'b0}}),
  .i_bus_icb_cmd_size     ({2*DTCM_ARBT_I_NUM{1'b0}}),
  .i_bus_icb_cmd_usr      ({1*DTCM_ARBT_I_NUM{1'b0}}),

                                
  .i_bus_icb_rsp_valid    (arbt_bus_icb_rsp_valid ) ,
  .i_bus_icb_rsp_ready    (arbt_bus_icb_rsp_ready ) ,
  .i_bus_icb_rsp_err      (arbt_bus_icb_rsp_err)    ,
  .i_bus_icb_rsp_rdata    (arbt_bus_icb_rsp_rdata ) ,
  .i_bus_icb_rsp_usr      (),
  .i_bus_icb_rsp_excl_ok  (),
                             
  .clk                    (clk  )                     ,
  .rst_n                  (rst_n)
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:inst:000001 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=198-253




//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=258-263
  wire sram_icb_cmd_ready;
  wire sram_icb_cmd_valid;
  wire [`E203_DTCM_ADDR_WIDTH-1:0] sram_icb_cmd_addr;
  wire sram_icb_cmd_read;
  wire [`E203_DTCM_DATA_WIDTH-1:0] sram_icb_cmd_wdata;
  wire [`E203_DTCM_WMSK_WIDTH-1:0] sram_icb_cmd_wmask;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:grp:internal_signal:000003 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=258-263

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=265-271
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:grp:bus_cluster:000002 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=265-271
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:grp:handshake:000002 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=265-267
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000011 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=265-265
  assign arbt_icb_cmd_ready = sram_icb_cmd_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000011 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=265-265

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000012 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=267-267
  assign sram_icb_cmd_valid = arbt_icb_cmd_valid;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000012 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=267-267
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:grp:handshake:000002 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=265-267
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000013 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=268-268
  assign sram_icb_cmd_addr  = arbt_icb_cmd_addr;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000013 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=268-268
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000014 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=269-269
  assign sram_icb_cmd_read  = arbt_icb_cmd_read;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000014 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=269-269
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000015 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=270-270
  assign sram_icb_cmd_wdata = arbt_icb_cmd_wdata;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000015 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=270-270
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000016 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=271-271
  assign sram_icb_cmd_wmask = arbt_icb_cmd_wmask;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000016 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=271-271
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=265-271
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:grp:bus_cluster:000002 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=265-271

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=273-285
  wire sram_icb_rsp_valid;
  wire sram_icb_rsp_ready;
  wire [`E203_DTCM_DATA_WIDTH-1:0] sram_icb_rsp_rdata;
  wire sram_icb_rsp_err;


  wire dtcm_sram_ctrl_active;


  wire sram_icb_rsp_read;


//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000013 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=285-323
 `ifndef E203_HAS_ECC //{
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:grp:internal_signal:000004 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=273-285
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000013 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=285-323
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:inst:000002 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=286-320
  sirv_sram_icb_ctrl #(
      .DW     (`E203_DTCM_DATA_WIDTH),
      .AW     (`E203_DTCM_ADDR_WIDTH),
      .MW     (`E203_DTCM_WMSK_WIDTH),
      .AW_LSB (2),// DTCM is 32bits wide, so the LSB is 2
      .USR_W  (1) 
  ) u_sram_icb_ctrl (
     .sram_ctrl_active (dtcm_sram_ctrl_active),
     .tcm_cgstop       (tcm_cgstop),
     
     .i_icb_cmd_valid (sram_icb_cmd_valid),
     .i_icb_cmd_ready (sram_icb_cmd_ready),
     .i_icb_cmd_read  (sram_icb_cmd_read ),
     .i_icb_cmd_addr  (sram_icb_cmd_addr ), 
     .i_icb_cmd_wdata (sram_icb_cmd_wdata), 
     .i_icb_cmd_wmask (sram_icb_cmd_wmask), 
     .i_icb_cmd_usr   (sram_icb_cmd_read ),
  
     .i_icb_rsp_valid (sram_icb_rsp_valid),
     .i_icb_rsp_ready (sram_icb_rsp_ready),
     .i_icb_rsp_rdata (sram_icb_rsp_rdata),
     .i_icb_rsp_usr   (sram_icb_rsp_read),
  
     .ram_cs   (dtcm_ram_cs  ),  
     .ram_we   (dtcm_ram_we  ),  
     .ram_addr (dtcm_ram_addr), 
     .ram_wem  (dtcm_ram_wem ),
     .ram_din  (dtcm_ram_din ),          
     .ram_dout (dtcm_ram_dout),
     .clk_ram  (clk_dtcm_ram ),
  
     .test_mode(test_mode  ),
     .clk  (clk  ),
     .rst_n(rst_n)  
    );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:inst:000002 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=286-320

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000017 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=322-322
  assign sram_icb_rsp_err = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000017 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=322-322
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000013 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=285-323
  `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000013 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=285-323

    

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=327-338
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:grp:bus_cluster:000003 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=327-338
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:grp:handshake:000003 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=327-329
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000018 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=327-327
  assign sram_icb_rsp_ready = arbt_icb_rsp_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000018 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=327-327

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000019 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=329-329
  assign arbt_icb_rsp_valid = sram_icb_rsp_valid;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000019 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=329-329
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:grp:handshake:000003 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=327-329
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000020 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=330-330
  assign arbt_icb_rsp_err   = sram_icb_rsp_err;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000020 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=330-330
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000021 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=331-331
  assign arbt_icb_rsp_rdata = sram_icb_rsp_rdata;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000021 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=331-331


//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000022 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=334-338
  assign dtcm_active = lsu2dtcm_icb_cmd_valid | dtcm_sram_ctrl_active
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000014 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=335-337
       `ifdef E203_HAS_DTCM_EXTITF //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000014 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=335-337
                     | ext2dtcm_icb_cmd_valid
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000014 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=335-337
       `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000014 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=335-337
          ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:assign:000022 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=334-338
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:grp:assign_cluster:000003 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=327-338
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:grp:bus_cluster:000003 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=327-338



endmodule

//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000015 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=29-344
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v:pp_blk:000015 file=e203_hbirdv2/e203_dtcm_ctrl/e203_dtcm_ctrl.v lines=29-344
