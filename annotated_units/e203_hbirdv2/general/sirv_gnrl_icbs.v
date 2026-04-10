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
//  All of the general modules for ICB relevant functions
//
// ====================================================================



// ===========================================================================
//
// Description:
//  The module to handle the ICB bus arbitration
//
// ===========================================================================

module sirv_gnrl_icb_arbt # (
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:port_section:000001 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=38-91
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:param_decl:000001 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=38-48
  parameter AW = 32,
  parameter DW = 64,
  parameter USR_W = 1,
  parameter ARBT_SCHEME = 0,//0: priority based; 1: rrobin
  // The number of outstanding transactions supported
  parameter FIFO_OUTS_NUM = 1,
  parameter FIFO_CUT_READY = 0,
  // ARBT_NUM=4 ICB ports, so 2 bits for port id
  parameter ARBT_NUM = 4,
  parameter ALLOW_0CYCL_RSP = 1,
  parameter ARBT_PTR_W = 2
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:param_decl:000001 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=38-48
) (
  output             o_icb_cmd_valid, 
  input              o_icb_cmd_ready, 
  output [1-1:0]     o_icb_cmd_read, 
  output [AW-1:0]    o_icb_cmd_addr, 
  output [DW-1:0]    o_icb_cmd_wdata, 
  output [DW/8-1:0]  o_icb_cmd_wmask,
  output [2-1:0]     o_icb_cmd_burst, 
  output [2-1:0]     o_icb_cmd_beat, 
  output             o_icb_cmd_lock,
  output             o_icb_cmd_excl,
  output [1:0]       o_icb_cmd_size,
  output [USR_W-1:0] o_icb_cmd_usr,

  input              o_icb_rsp_valid, 
  output             o_icb_rsp_ready, 
  input              o_icb_rsp_err,
  input              o_icb_rsp_excl_ok,
  input  [DW-1:0]    o_icb_rsp_rdata, 
  input  [USR_W-1:0] o_icb_rsp_usr, 
  
  output [ARBT_NUM*1-1:0]     i_bus_icb_cmd_ready, 
  input  [ARBT_NUM*1-1:0]     i_bus_icb_cmd_valid, 
  input  [ARBT_NUM*1-1:0]     i_bus_icb_cmd_read, 
  input  [ARBT_NUM*AW-1:0]    i_bus_icb_cmd_addr, 
  input  [ARBT_NUM*DW-1:0]    i_bus_icb_cmd_wdata, 
  input  [ARBT_NUM*DW/8-1:0]  i_bus_icb_cmd_wmask,
  input  [ARBT_NUM*2-1:0]     i_bus_icb_cmd_burst,
  input  [ARBT_NUM*2-1:0]     i_bus_icb_cmd_beat ,
  input  [ARBT_NUM*1-1:0]     i_bus_icb_cmd_lock ,
  input  [ARBT_NUM*1-1:0]     i_bus_icb_cmd_excl ,
  input  [ARBT_NUM*2-1:0]     i_bus_icb_cmd_size ,
  input  [ARBT_NUM*USR_W-1:0] i_bus_icb_cmd_usr  ,

  output [ARBT_NUM*1-1:0]     i_bus_icb_rsp_valid, 
  input  [ARBT_NUM*1-1:0]     i_bus_icb_rsp_ready, 
  output [ARBT_NUM*1-1:0]     i_bus_icb_rsp_err,
  output [ARBT_NUM*1-1:0]     i_bus_icb_rsp_excl_ok,
  output [ARBT_NUM*DW-1:0]    i_bus_icb_rsp_rdata, 
  output [ARBT_NUM*USR_W-1:0] i_bus_icb_rsp_usr, 

  input  clk,  
  input  rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:port_section:000001 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=38-91
  );


integer j;
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000001 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=96-148
wire [ARBT_NUM-1:0] i_bus_icb_cmd_grt_vec; 
wire [ARBT_NUM-1:0] i_bus_icb_cmd_sel; 
wire o_icb_cmd_valid_real; 
wire o_icb_cmd_ready_real; 

wire [1-1:0]    i_icb_cmd_read [ARBT_NUM-1:0]; 
wire [AW-1:0]   i_icb_cmd_addr [ARBT_NUM-1:0]; 
wire [DW-1:0]   i_icb_cmd_wdata[ARBT_NUM-1:0]; 
wire [DW/8-1:0] i_icb_cmd_wmask[ARBT_NUM-1:0];
wire [2-1:0]    i_icb_cmd_burst[ARBT_NUM-1:0];
wire [2-1:0]    i_icb_cmd_beat [ARBT_NUM-1:0];
wire [1-1:0]    i_icb_cmd_lock [ARBT_NUM-1:0];
wire [1-1:0]    i_icb_cmd_excl [ARBT_NUM-1:0];
wire [2-1:0]    i_icb_cmd_size [ARBT_NUM-1:0];
wire [USR_W-1:0]i_icb_cmd_usr  [ARBT_NUM-1:0];

reg [1-1:0]    sel_o_icb_cmd_read; 
reg [AW-1:0]   sel_o_icb_cmd_addr; 
reg [DW-1:0]   sel_o_icb_cmd_wdata; 
reg [DW/8-1:0] sel_o_icb_cmd_wmask;
reg [2-1:0]    sel_o_icb_cmd_burst;
reg [2-1:0]    sel_o_icb_cmd_beat ;
reg [1-1:0]    sel_o_icb_cmd_lock ;
reg [1-1:0]    sel_o_icb_cmd_excl ;
reg [2-1:0]    sel_o_icb_cmd_size ;
reg [USR_W-1:0]sel_o_icb_cmd_usr  ;

wire o_icb_rsp_ready_pre; 
wire o_icb_rsp_valid_pre;

wire rspid_fifo_bypass;
wire rspid_fifo_wen;
wire rspid_fifo_ren;

wire [ARBT_PTR_W-1:0] i_icb_rsp_port_id;

wire rspid_fifo_i_valid;
wire rspid_fifo_o_valid;
wire rspid_fifo_i_ready;
wire rspid_fifo_o_ready;
wire [ARBT_PTR_W-1:0] rspid_fifo_rdat;
wire [ARBT_PTR_W-1:0] rspid_fifo_wdat;

wire rspid_fifo_full;       
wire rspid_fifo_empty;       
reg [ARBT_PTR_W-1:0] i_arbt_indic_id;

wire i_icb_cmd_ready_pre;
wire i_icb_cmd_valid_pre;

wire arbt_ena;
    
wire [ARBT_PTR_W-1:0] o_icb_rsp_port_id;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000001 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=96-148

genvar i;
//__RB_CUT_BEGIN__ type=generate id=e203_hbirdv2/general/sirv_gnrl_icbs.v:generate:000001 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=151-340
generate //{
//__RB_CUT_BODY__ type=generate id=e203_hbirdv2/general/sirv_gnrl_icbs.v:generate:000001 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=151-340
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000001 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=152-173
  if(ARBT_NUM == 1) begin:arbt_num_eq_1_gen// {
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000001 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=153-171
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000001 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=153-171
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000001 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=153-154
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000001 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=152-173
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000001 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=153-153
    assign i_bus_icb_cmd_ready = o_icb_cmd_ready    ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000001 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=153-153
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000002 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=154-154
    assign o_icb_cmd_valid     = i_bus_icb_cmd_valid;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000002 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=154-154
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000001 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=153-154
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000003 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=155-155
    assign o_icb_cmd_read      = i_bus_icb_cmd_read ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000003 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=155-155
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000004 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=156-156
    assign o_icb_cmd_addr      = i_bus_icb_cmd_addr ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000004 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=156-156
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000005 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=157-157
    assign o_icb_cmd_wdata     = i_bus_icb_cmd_wdata;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000005 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=157-157
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000006 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=158-158
    assign o_icb_cmd_wmask     = i_bus_icb_cmd_wmask;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000006 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=158-158
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000007 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=159-159
    assign o_icb_cmd_burst     = i_bus_icb_cmd_burst;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000007 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=159-159
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000008 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=160-160
    assign o_icb_cmd_beat      = i_bus_icb_cmd_beat ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000008 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=160-160
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000009 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=161-161
    assign o_icb_cmd_lock      = i_bus_icb_cmd_lock ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000009 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=161-161
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000010 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=162-162
    assign o_icb_cmd_excl      = i_bus_icb_cmd_excl ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000010 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=162-162
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000011 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=163-163
    assign o_icb_cmd_size      = i_bus_icb_cmd_size ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000011 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=163-163
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000012 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=164-164
    assign o_icb_cmd_usr       = i_bus_icb_cmd_usr  ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000012 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=164-164
                               
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000002 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=166-167
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000013 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=166-166
    assign o_icb_rsp_ready     = i_bus_icb_rsp_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000013 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=166-166
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000014 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=167-167
    assign i_bus_icb_rsp_valid = o_icb_rsp_valid    ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000014 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=167-167
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000002 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=166-167
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000015 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=168-168
    assign i_bus_icb_rsp_err   = o_icb_rsp_err      ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000015 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=168-168
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000016 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=169-169
    assign i_bus_icb_rsp_excl_ok   = o_icb_rsp_excl_ok      ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000016 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=169-169
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000017 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=170-170
    assign i_bus_icb_rsp_rdata = o_icb_rsp_rdata    ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000017 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=170-170
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000018 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=171-171
    assign i_bus_icb_rsp_usr   = o_icb_rsp_usr      ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000018 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=171-171
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000001 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=153-171
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000001 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=153-171

//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000001 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=152-173
  end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000001 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=152-173
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000016 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=174-339
  else begin:arbt_num_gt_1_gen//{
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000016 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=174-339

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000002 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=176-177
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000003 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=176-177
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000019 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=176-176
    assign o_icb_cmd_valid = o_icb_cmd_valid_real & (~rspid_fifo_full);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000019 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=176-176
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000020 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=177-177
    assign o_icb_cmd_ready_real = o_icb_cmd_ready & (~rspid_fifo_full); 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000020 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=177-177
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000002 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=176-177
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000003 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=176-177
    // Distract the icb from the bus declared ports

    for(i = 0; i < ARBT_NUM; i = i+1)//{
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000002 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=181-195
    begin:icb_distract_gen
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000003 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=182-194
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000002 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=182-194
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000002 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=181-195
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000021 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=182-182
      assign i_icb_cmd_read [i] = i_bus_icb_cmd_read [(i+1)*1     -1 : i*1     ];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000021 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=182-182
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000022 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=183-183
      assign i_icb_cmd_addr [i] = i_bus_icb_cmd_addr [(i+1)*AW    -1 : i*AW    ];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000022 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=183-183
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000023 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=184-184
      assign i_icb_cmd_wdata[i] = i_bus_icb_cmd_wdata[(i+1)*DW    -1 : i*DW    ];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000023 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=184-184
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000024 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=185-185
      assign i_icb_cmd_wmask[i] = i_bus_icb_cmd_wmask[(i+1)*(DW/8)-1 : i*(DW/8)];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000024 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=185-185
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000025 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=186-186
      assign i_icb_cmd_burst[i] = i_bus_icb_cmd_burst[(i+1)*2     -1 : i*2     ];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000025 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=186-186
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000026 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=187-187
      assign i_icb_cmd_beat [i] = i_bus_icb_cmd_beat [(i+1)*2     -1 : i*2     ];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000026 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=187-187
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000027 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=188-188
      assign i_icb_cmd_lock [i] = i_bus_icb_cmd_lock [(i+1)*1     -1 : i*1     ];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000027 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=188-188
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000028 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=189-189
      assign i_icb_cmd_excl [i] = i_bus_icb_cmd_excl [(i+1)*1     -1 : i*1     ];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000028 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=189-189
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000029 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=190-190
      assign i_icb_cmd_size [i] = i_bus_icb_cmd_size [(i+1)*2     -1 : i*2     ];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000029 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=190-190
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000030 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=191-191
      assign i_icb_cmd_usr  [i] = i_bus_icb_cmd_usr  [(i+1)*USR_W -1 : i*USR_W ];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000030 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=191-191

//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000004 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=193-194
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000031 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=193-193
      assign i_bus_icb_cmd_ready[i] = i_bus_icb_cmd_grt_vec[i] & o_icb_cmd_ready_real;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000031 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=193-193
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000032 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=194-194
      assign i_bus_icb_rsp_valid[i] = o_icb_rsp_valid_pre & (o_icb_rsp_port_id == i); 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000032 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=194-194
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000004 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=193-194
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000003 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=182-194
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000002 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=182-194
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000002 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=181-195
    end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000002 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=181-195

//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000006 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=197-209
    if(ARBT_SCHEME == 0) begin:priorty_arbt//{
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000002 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=198-198
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000006 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=197-209
      wire arbt_ena = 1'b0;//No use
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000002 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=198-198
      for(i = 0; i < ARBT_NUM; i = i+1)//{
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000005 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=200-208
      begin:priroty_grt_vec_gen
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000005 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=200-208
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000003 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=201-203
        if(i==0) begin: i_is_0
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000003 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=201-203
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000033 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=202-202
          assign i_bus_icb_cmd_grt_vec[i] =  1'b1;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000033 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=202-202
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000003 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=201-203
        end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000003 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=201-203
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000004 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=204-206
        else begin:i_is_not_0
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000004 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=204-206
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000034 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=205-205
          assign i_bus_icb_cmd_grt_vec[i] =  ~(|i_bus_icb_cmd_valid[i-1:0]);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000034 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=205-205
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000004 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=204-206
        end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000004 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=204-206
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000035 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=207-207
        assign i_bus_icb_cmd_sel[i] = i_bus_icb_cmd_grt_vec[i] & i_bus_icb_cmd_valid[i];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000035 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=207-207
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000005 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=200-208
      end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000005 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=200-208
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000006 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=197-209
    end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000006 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=197-209
    
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000007 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=211-223
    if(ARBT_SCHEME == 1) begin:rrobin_arbt//{
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000007 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=211-223
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000036 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=212-212
      assign arbt_ena = o_icb_cmd_valid & o_icb_cmd_ready; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000036 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=212-212
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000001 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=213-221
      sirv_gnrl_rrobin # (
          .ARBT_NUM(ARBT_NUM)
      )u_sirv_gnrl_rrobin(
        .grt_vec  (i_bus_icb_cmd_grt_vec),  
        .req_vec  (i_bus_icb_cmd_valid),  
        .arbt_ena (arbt_ena),   
        .clk      (clk),
        .rst_n    (rst_n)
      );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000001 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=213-221
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000037 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=222-222
      assign i_bus_icb_cmd_sel = i_bus_icb_cmd_grt_vec;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000037 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=222-222
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000007 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=211-223
    end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000007 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=211-223


//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000003 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=226-260
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000005 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=226-250
//__RB_CUT_BEGIN__ type=always id=e203_hbirdv2/general/sirv_gnrl_icbs.v:proc:000001 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=226-249
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000009 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=226-249
    always @ (*) begin : sel_o_apb_cmd_ready_PROC
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000009 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=226-249
      sel_o_icb_cmd_read  = {1   {1'b0}};
      sel_o_icb_cmd_addr  = {AW  {1'b0}};
      sel_o_icb_cmd_wdata = {DW  {1'b0}};
      sel_o_icb_cmd_wmask = {DW/8{1'b0}};
      sel_o_icb_cmd_burst = {2   {1'b0}};
      sel_o_icb_cmd_beat  = {2   {1'b0}};
      sel_o_icb_cmd_lock  = {1   {1'b0}};
      sel_o_icb_cmd_excl  = {1   {1'b0}};
      sel_o_icb_cmd_size  = {2   {1'b0}};
      sel_o_icb_cmd_usr   = {USR_W{1'b0}};
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000008 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=237-248
      for(j = 0; j < ARBT_NUM; j = j+1) begin//{
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000008 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=237-248
        sel_o_icb_cmd_read  = sel_o_icb_cmd_read  | ({1    {i_bus_icb_cmd_sel[j]}} & i_icb_cmd_read [j]);
        sel_o_icb_cmd_addr  = sel_o_icb_cmd_addr  | ({AW   {i_bus_icb_cmd_sel[j]}} & i_icb_cmd_addr [j]);
        sel_o_icb_cmd_wdata = sel_o_icb_cmd_wdata | ({DW   {i_bus_icb_cmd_sel[j]}} & i_icb_cmd_wdata[j]);
        sel_o_icb_cmd_wmask = sel_o_icb_cmd_wmask | ({DW/8 {i_bus_icb_cmd_sel[j]}} & i_icb_cmd_wmask[j]);
        sel_o_icb_cmd_burst = sel_o_icb_cmd_burst | ({2    {i_bus_icb_cmd_sel[j]}} & i_icb_cmd_burst[j]);
        sel_o_icb_cmd_beat  = sel_o_icb_cmd_beat  | ({2    {i_bus_icb_cmd_sel[j]}} & i_icb_cmd_beat [j]);
        sel_o_icb_cmd_lock  = sel_o_icb_cmd_lock  | ({1    {i_bus_icb_cmd_sel[j]}} & i_icb_cmd_lock [j]);
        sel_o_icb_cmd_excl  = sel_o_icb_cmd_excl  | ({1    {i_bus_icb_cmd_sel[j]}} & i_icb_cmd_excl [j]);
        sel_o_icb_cmd_size  = sel_o_icb_cmd_size  | ({2    {i_bus_icb_cmd_sel[j]}} & i_icb_cmd_size [j]);
        sel_o_icb_cmd_usr   = sel_o_icb_cmd_usr   | ({USR_W{i_bus_icb_cmd_sel[j]}} & i_icb_cmd_usr  [j]);
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000008 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=237-248
      end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000008 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=237-248
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000009 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=226-249
    end
//__RB_CUT_TAIL__ type=always id=e203_hbirdv2/general/sirv_gnrl_icbs.v:proc:000001 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=226-249
//__RB_CUT_END__ type=always id=e203_hbirdv2/general/sirv_gnrl_icbs.v:proc:000001 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=226-249
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000009 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=226-249
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000038 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=250-250
    assign o_icb_cmd_valid_real = |i_bus_icb_cmd_valid; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000038 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=250-250
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000005 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=226-250

//__RB_CUT_BEGIN__ type=always id=e203_hbirdv2/general/sirv_gnrl_icbs.v:proc:000002 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=252-257
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000011 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=252-257
    always @ (*) begin : i_arbt_indic_id_PROC
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000011 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=252-257
      i_arbt_indic_id = {ARBT_PTR_W{1'b0}};
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000010 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=254-256
      for(j = 0; j < ARBT_NUM; j = j+1) begin//{
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000010 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=254-256
        i_arbt_indic_id = i_arbt_indic_id | {ARBT_PTR_W{i_bus_icb_cmd_sel[j]}} & $unsigned(j);
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000010 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=254-256
      end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000010 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=254-256
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000011 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=252-257
    end
//__RB_CUT_TAIL__ type=always id=e203_hbirdv2/general/sirv_gnrl_icbs.v:proc:000002 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=252-257
//__RB_CUT_END__ type=always id=e203_hbirdv2/general/sirv_gnrl_icbs.v:proc:000002 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=252-257
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000011 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=252-257

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000004 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=259-260
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000006 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=259-260
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000039 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=259-259
    assign rspid_fifo_wen = o_icb_cmd_valid & o_icb_cmd_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000039 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=259-259
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000040 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=260-260
    assign rspid_fifo_ren = o_icb_rsp_valid & o_icb_rsp_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000040 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=260-260
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000004 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=259-260
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000006 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=259-260
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000003 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=226-260

    
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000012 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=263-269
    if(ALLOW_0CYCL_RSP == 1) begin: allow_0rsp
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000005 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=264-268
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000004 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=264-268
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000012 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=263-269
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000041 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=264-264
        assign rspid_fifo_bypass = rspid_fifo_empty & rspid_fifo_wen & rspid_fifo_ren;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000041 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=264-264
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000042 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=265-265
        assign o_icb_rsp_port_id = rspid_fifo_empty ? rspid_fifo_wdat : rspid_fifo_rdat;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000042 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=265-265
        // We dont need this empty qualifications because we allow the 0 cyle response
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000007 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=267-268
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000043 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=267-267
        assign o_icb_rsp_valid_pre = o_icb_rsp_valid;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000043 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=267-267
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000044 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=268-268
        assign o_icb_rsp_ready     = o_icb_rsp_ready_pre;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000044 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=268-268
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000007 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=267-268
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000005 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=264-268
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000004 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=264-268
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000012 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=263-269
    end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000012 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=263-269
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000013 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=270-275
    else begin: no_allow_0rsp
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000006 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=271-274
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000005 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=271-274
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000013 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=270-275
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000045 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=271-271
        assign rspid_fifo_bypass   = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000045 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=271-271
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000046 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=272-272
        assign o_icb_rsp_port_id   = rspid_fifo_empty ? {ARBT_PTR_W{1'b0}} : rspid_fifo_rdat;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000046 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=272-272
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000008 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=273-274
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000047 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=273-273
        assign o_icb_rsp_valid_pre = (~rspid_fifo_empty) & o_icb_rsp_valid;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000047 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=273-273
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000048 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=274-274
        assign o_icb_rsp_ready     = (~rspid_fifo_empty) & o_icb_rsp_ready_pre;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000048 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=274-274
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000008 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=273-274
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000006 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=271-274
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000005 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=271-274
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000013 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=270-275
    end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000013 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=270-275

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000007 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=277-282
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000006 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=277-282
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000009 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=277-280
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000049 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=277-277
    assign rspid_fifo_i_valid = rspid_fifo_wen & (~rspid_fifo_bypass);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000049 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=277-277
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000050 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=278-278
    assign rspid_fifo_full    = (~rspid_fifo_i_ready);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000050 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=278-278
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000051 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=279-279
    assign rspid_fifo_o_ready = rspid_fifo_ren & (~rspid_fifo_bypass);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000051 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=279-279
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000052 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=280-280
    assign rspid_fifo_empty   = (~rspid_fifo_o_valid);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000052 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=280-280
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000009 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=277-280

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000053 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=282-282
    assign rspid_fifo_wdat   = i_arbt_indic_id;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000053 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=282-282
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000007 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=277-282
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000006 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=277-282
 
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000014 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=284-300
    if(FIFO_OUTS_NUM == 1) begin:dp_1//{
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000014 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=284-300
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000002 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=285-298
      sirv_gnrl_pipe_stage # (
        .CUT_READY (FIFO_CUT_READY),
        .DP  (1),
        .DW  (ARBT_PTR_W)
      ) u_sirv_gnrl_rspid_fifo (
        .i_vld(rspid_fifo_i_valid),
        .i_rdy(rspid_fifo_i_ready),
        .i_dat(rspid_fifo_wdat ),
        .o_vld(rspid_fifo_o_valid),
        .o_rdy(rspid_fifo_o_ready),  
        .o_dat(rspid_fifo_rdat ),  
        .clk  (clk),
        .rst_n(rst_n)
      );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000002 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=285-298

//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000014 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=284-300
    end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000014 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=284-300
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000015 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=301-318
    else begin: dp_gt1//{
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000015 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=301-318
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000003 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=302-317
      sirv_gnrl_fifo # (
        .CUT_READY (FIFO_CUT_READY),
        .MSKO      (0),
        .DP  (FIFO_OUTS_NUM),
        .DW  (ARBT_PTR_W)
      ) u_sirv_gnrl_rspid_fifo (
        .i_vld(rspid_fifo_i_valid),
        .i_rdy(rspid_fifo_i_ready),
        .i_dat(rspid_fifo_wdat ),
        .o_vld(rspid_fifo_o_valid),
        .o_rdy(rspid_fifo_o_ready),  
        .o_dat(rspid_fifo_rdat ),  
      
        .clk  (clk),
        .rst_n(rst_n)
      );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000003 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=302-317
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000015 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=301-318
    end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000015 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=301-318

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000008 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=320-338
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000007 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=320-338
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000054 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=320-320
    assign o_icb_cmd_read  = sel_o_icb_cmd_read ; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000054 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=320-320
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000055 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=321-321
    assign o_icb_cmd_addr  = sel_o_icb_cmd_addr ; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000055 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=321-321
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000056 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=322-322
    assign o_icb_cmd_wdata = sel_o_icb_cmd_wdata; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000056 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=322-322
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000057 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=323-323
    assign o_icb_cmd_wmask = sel_o_icb_cmd_wmask;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000057 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=323-323
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000058 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=324-324
    assign o_icb_cmd_burst = sel_o_icb_cmd_burst;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000058 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=324-324
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000059 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=325-325
    assign o_icb_cmd_beat  = sel_o_icb_cmd_beat ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000059 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=325-325
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000060 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=326-326
    assign o_icb_cmd_lock  = sel_o_icb_cmd_lock ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000060 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=326-326
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000061 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=327-327
    assign o_icb_cmd_excl  = sel_o_icb_cmd_excl ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000061 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=327-327
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000062 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=328-328
    assign o_icb_cmd_size  = sel_o_icb_cmd_size ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000062 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=328-328
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000063 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=329-329
    assign o_icb_cmd_usr   = sel_o_icb_cmd_usr  ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000063 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=329-329

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000064 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=331-331
    assign o_icb_rsp_ready_pre = i_bus_icb_rsp_ready[o_icb_rsp_port_id]; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000064 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=331-331



//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000065 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=335-335
    assign i_bus_icb_rsp_err     = {ARBT_NUM{o_icb_rsp_err  }};  
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000065 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=335-335
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000066 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=336-336
    assign i_bus_icb_rsp_excl_ok = {ARBT_NUM{o_icb_rsp_excl_ok}};  
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000066 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=336-336
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000067 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=337-337
    assign i_bus_icb_rsp_rdata   = {ARBT_NUM{o_icb_rsp_rdata}}; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000067 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=337-337
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000068 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=338-338
    assign i_bus_icb_rsp_usr     = {ARBT_NUM{o_icb_rsp_usr}}; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000068 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=338-338
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000008 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=320-338
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000007 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=320-338
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000016 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=174-339
  end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000016 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=174-339
//__RB_CUT_TAIL__ type=generate id=e203_hbirdv2/general/sirv_gnrl_icbs.v:generate:000001 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=151-340
  endgenerate //}
//__RB_CUT_END__ type=generate id=e203_hbirdv2/general/sirv_gnrl_icbs.v:generate:000001 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=151-340

endmodule

// ===========================================================================
//
// Description:
//  The module to handle the ICB bus buffer stages
//
// ===========================================================================

module sirv_gnrl_icb_buffer # (
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:port_section:000002 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=352-404
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:param_decl:000002 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=352-359
  parameter OUTS_CNT_W = 1,
  parameter AW = 32,
  parameter DW = 32,
  parameter CMD_CUT_READY = 0,
  parameter RSP_CUT_READY = 0,
  parameter CMD_DP = 0,
  parameter RSP_DP = 0,
  parameter USR_W = 1
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:param_decl:000002 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=352-359
) (
  output             icb_buffer_active,

  input              i_icb_cmd_valid, 
  output             i_icb_cmd_ready, 
  input  [1-1:0]     i_icb_cmd_read, 
  input  [AW-1:0]    i_icb_cmd_addr, 
  input  [DW-1:0]    i_icb_cmd_wdata, 
  input  [DW/8-1:0]  i_icb_cmd_wmask,
  input              i_icb_cmd_lock,
  input              i_icb_cmd_excl,
  input  [1:0]       i_icb_cmd_size,
  input  [1:0]       i_icb_cmd_burst,
  input  [1:0]       i_icb_cmd_beat,
  input  [USR_W-1:0] i_icb_cmd_usr,

  output             i_icb_rsp_valid, 
  input              i_icb_rsp_ready, 
  output             i_icb_rsp_err,
  output             i_icb_rsp_excl_ok,
  output [DW-1:0]    i_icb_rsp_rdata, 
  output [USR_W-1:0] i_icb_rsp_usr,
  
  output             o_icb_cmd_valid, 
  input              o_icb_cmd_ready, 
  output [1-1:0]     o_icb_cmd_read, 
  output [AW-1:0]    o_icb_cmd_addr, 
  output [DW-1:0]    o_icb_cmd_wdata, 
  output [DW/8-1:0]  o_icb_cmd_wmask,
  output             o_icb_cmd_lock,
  output             o_icb_cmd_excl,
  output [1:0]       o_icb_cmd_size,
  output [1:0]       o_icb_cmd_burst,
  output [1:0]       o_icb_cmd_beat,
  output [USR_W-1:0] o_icb_cmd_usr,

  input              o_icb_rsp_valid, 
  output             o_icb_rsp_ready, 
  input              o_icb_rsp_err,
  input              o_icb_rsp_excl_ok,
  input  [DW-1:0]    o_icb_rsp_rdata, 
  input  [USR_W-1:0] o_icb_rsp_usr,

  input  clk,  
  input  rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:port_section:000002 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=352-404
  );

//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:param_decl:000003 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=407-407
  localparam CMD_PACK_W = (1+AW+DW+(DW/8)+1+1+2+2+2+USR_W);
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:param_decl:000003 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=407-407

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000003 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=409-409
  wire [CMD_PACK_W-1:0] cmd_fifo_i_dat = {
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000003 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=409-409
                                 i_icb_cmd_read, 
                                 i_icb_cmd_addr, 
                                 i_icb_cmd_wdata, 
                                 i_icb_cmd_wmask,
                                 i_icb_cmd_lock,
                                 i_icb_cmd_excl,
                                 i_icb_cmd_size,
                                 i_icb_cmd_burst,
                                 i_icb_cmd_beat,
                                 i_icb_cmd_usr};

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000004 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=421-421
  wire [CMD_PACK_W-1:0] cmd_fifo_o_dat;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000004 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=421-421

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000069 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=423-433
  assign {
                                 o_icb_cmd_read, 
                                 o_icb_cmd_addr, 
                                 o_icb_cmd_wdata, 
                                 o_icb_cmd_wmask,
                                 o_icb_cmd_lock,
                                 o_icb_cmd_excl,
                                 o_icb_cmd_size,
                                 o_icb_cmd_burst,
                                 o_icb_cmd_beat,
                                 o_icb_cmd_usr} = cmd_fifo_o_dat;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000069 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=423-433
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000004 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=434-449
  sirv_gnrl_fifo # (
    .CUT_READY (CMD_CUT_READY),
    .MSKO      (0),
    .DP  (CMD_DP),
    .DW  (CMD_PACK_W)
  ) u_sirv_gnrl_cmd_fifo (
    .i_vld(i_icb_cmd_valid),
    .i_rdy(i_icb_cmd_ready),
    .i_dat(cmd_fifo_i_dat ),
    .o_vld(o_icb_cmd_valid),
    .o_rdy(o_icb_cmd_ready),  
    .o_dat(cmd_fifo_o_dat ),  
  
    .clk  (clk),
    .rst_n(rst_n)
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000004 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=434-449


//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:param_decl:000004 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=452-452
  localparam RSP_PACK_W = (2+DW+USR_W);
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:param_decl:000004 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=452-452
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000005 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=453-453
  wire [RSP_PACK_W-1:0] rsp_fifo_i_dat = {
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000005 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=453-453
                                 o_icb_rsp_err,
                                 o_icb_rsp_excl_ok,
                                 o_icb_rsp_rdata, 
                                 o_icb_rsp_usr};

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000006 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=459-459
  wire [RSP_PACK_W-1:0] rsp_fifo_o_dat;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000006 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=459-459

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000070 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=461-465
  assign {
                                 i_icb_rsp_err,
                                 i_icb_rsp_excl_ok,
                                 i_icb_rsp_rdata, 
                                 i_icb_rsp_usr} = rsp_fifo_o_dat;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000070 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=461-465
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000005 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=466-481
  sirv_gnrl_fifo # (
    .CUT_READY (RSP_CUT_READY),
    .MSKO      (0),
    .DP  (RSP_DP),
    .DW  (RSP_PACK_W)
  ) u_sirv_gnrl_rsp_fifo (
    .i_vld(o_icb_rsp_valid),
    .i_rdy(o_icb_rsp_ready),
    .i_dat(rsp_fifo_i_dat ),
    .o_vld(i_icb_rsp_valid),
    .o_rdy(i_icb_rsp_ready),  
    .o_dat(rsp_fifo_o_dat ),  
  
    .clk  (clk),
    .rst_n(rst_n)
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000005 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=466-481

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000007 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=483-489
  wire outs_cnt_inc = i_icb_cmd_valid & i_icb_cmd_ready;
  wire outs_cnt_dec = i_icb_rsp_valid & i_icb_rsp_ready;
     // If meanwhile no or have set and clear, then no changes
  wire outs_cnt_ena = outs_cnt_inc ^ outs_cnt_dec;
     // If only inc or only dec
  wire outs_cnt_r;
  wire outs_cnt_nxt = outs_cnt_inc ? (outs_cnt_r + 1'b1) : (outs_cnt_r - 1'b1);
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000007 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=483-489
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000006 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=490-490
  sirv_gnrl_dfflr #(OUTS_CNT_W) outs_cnt_dfflr (outs_cnt_ena, outs_cnt_nxt, outs_cnt_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000006 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=490-490

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000071 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=492-492
  assign icb_buffer_active = i_icb_cmd_valid | (~(outs_cnt_r == {OUTS_CNT_W{1'b0}}));
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000071 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=492-492

endmodule

// ===========================================================================
//
// Description:
//  The module to handle the ICB bus width conversion from 32bits to 64bits
//
// ===========================================================================

module sirv_gnrl_icb_n2w # (
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:port_section:000003 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=504-552
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:param_decl:000005 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=504-509
  parameter AW = 32,
  parameter USR_W = 1,
  parameter FIFO_OUTS_NUM = 8,
  parameter FIFO_CUT_READY = 0,
  parameter X_W = 32,
  parameter Y_W = 64
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:param_decl:000005 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=504-509
) (
  input              i_icb_cmd_valid, 
  output             i_icb_cmd_ready, 
  input  [1-1:0]     i_icb_cmd_read, 
  input  [AW-1:0]    i_icb_cmd_addr, 
  input  [X_W-1:0]   i_icb_cmd_wdata, 
  input  [X_W/8-1:0] i_icb_cmd_wmask,
  input              i_icb_cmd_lock,
  input              i_icb_cmd_excl,
  input  [1:0]       i_icb_cmd_size,
  input  [1:0]       i_icb_cmd_burst,
  input  [1:0]       i_icb_cmd_beat,
  input  [USR_W-1:0] i_icb_cmd_usr,

  output             i_icb_rsp_valid, 
  input              i_icb_rsp_ready, 
  output             i_icb_rsp_err,
  output             i_icb_rsp_excl_ok,
  output [X_W-1:0]   i_icb_rsp_rdata, 
  output [USR_W-1:0] i_icb_rsp_usr,
  
  output             o_icb_cmd_valid, 
  input              o_icb_cmd_ready, 
  output [1-1:0]     o_icb_cmd_read, 
  output [AW-1:0]    o_icb_cmd_addr, 
  output [Y_W-1:0]   o_icb_cmd_wdata, 
  output [Y_W/8-1:0] o_icb_cmd_wmask,
  output             o_icb_cmd_lock,
  output             o_icb_cmd_excl,
  output [1:0]       o_icb_cmd_size,
  output [1:0]       o_icb_cmd_burst,
  output [1:0]       o_icb_cmd_beat,
  output [USR_W-1:0] o_icb_cmd_usr,

  input              o_icb_rsp_valid, 
  output             o_icb_rsp_ready, 
  input              o_icb_rsp_err,
  input              o_icb_rsp_excl_ok,
  input  [Y_W-1:0]   o_icb_rsp_rdata, 
  input  [USR_W-1:0] o_icb_rsp_usr,

  input  clk,  
  input  rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:port_section:000003 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=504-552
  );


//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000008 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=556-567
    wire cmd_y_lo_hi;
    wire rsp_y_lo_hi;
        
    wire n2w_fifo_wen = i_icb_cmd_valid & i_icb_cmd_ready;
    wire n2w_fifo_ren = i_icb_rsp_valid & i_icb_rsp_ready;

    wire n2w_fifo_i_ready;
    wire n2w_fifo_i_valid = n2w_fifo_wen;
    wire n2w_fifo_full    = (~n2w_fifo_i_ready);
    wire n2w_fifo_o_valid ;
    wire n2w_fifo_o_ready = n2w_fifo_ren;
    wire n2w_fifo_empty   = (~n2w_fifo_o_valid);
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000008 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=556-567

//__RB_CUT_BEGIN__ type=generate id=e203_hbirdv2/general/sirv_gnrl_icbs.v:generate:000002 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=569-606
  generate
//__RB_CUT_BODY__ type=generate id=e203_hbirdv2/general/sirv_gnrl_icbs.v:generate:000002 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=569-606
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000017 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=570-587
    if(FIFO_OUTS_NUM == 1) begin:fifo_dp_1//{
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000017 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=570-587
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000007 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=571-585
      sirv_gnrl_pipe_stage # (
        .CUT_READY (FIFO_CUT_READY),
        .DP  (1),
        .DW  (1)
      ) u_sirv_gnrl_n2w_fifo (
        .i_vld(n2w_fifo_i_valid),
        .i_rdy(n2w_fifo_i_ready),
        .i_dat(cmd_y_lo_hi ),
        .o_vld(n2w_fifo_o_valid),
        .o_rdy(n2w_fifo_o_ready),  
        .o_dat(rsp_y_lo_hi ),  
      
        .clk  (clk),
        .rst_n(rst_n)
      );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000007 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=571-585

//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000017 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=570-587
    end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000017 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=570-587
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000018 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=588-605
    else begin: fifo_dp_gt_1//{
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000018 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=588-605
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000008 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=589-604
      sirv_gnrl_fifo # (
        .CUT_READY (FIFO_CUT_READY),
        .MSKO      (0),
        .DP  (FIFO_OUTS_NUM),
        .DW  (1)
      ) u_sirv_gnrl_n2w_fifo (
        .i_vld(n2w_fifo_i_valid),
        .i_rdy(n2w_fifo_i_ready),
        .i_dat(cmd_y_lo_hi ),
        .o_vld(n2w_fifo_o_valid),
        .o_rdy(n2w_fifo_o_ready),  
        .o_dat(rsp_y_lo_hi ),  
      
        .clk  (clk),
        .rst_n(rst_n)
      );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000008 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=589-604
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000018 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=588-605
    end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000018 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=588-605
//__RB_CUT_TAIL__ type=generate id=e203_hbirdv2/general/sirv_gnrl_icbs.v:generate:000002 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=569-606
  endgenerate
//__RB_CUT_END__ type=generate id=e203_hbirdv2/general/sirv_gnrl_icbs.v:generate:000002 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=569-606



//__RB_CUT_BEGIN__ type=generate id=e203_hbirdv2/general/sirv_gnrl_icbs.v:generate:000003 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=610-616
  generate
//__RB_CUT_BODY__ type=generate id=e203_hbirdv2/general/sirv_gnrl_icbs.v:generate:000003 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=610-616
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000020 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=611-615
    if(X_W == 32) begin: x_w_32//{
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000020 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=611-615
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000019 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=612-614
      if(Y_W == 64) begin: y_w_64//{
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000019 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=612-614
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000072 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=613-613
        assign cmd_y_lo_hi = i_icb_cmd_addr[2]; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000072 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=613-613
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000019 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=612-614
      end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000019 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=612-614
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000020 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=611-615
    end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000020 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=611-615
//__RB_CUT_TAIL__ type=generate id=e203_hbirdv2/general/sirv_gnrl_icbs.v:generate:000003 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=610-616
  endgenerate
//__RB_CUT_END__ type=generate id=e203_hbirdv2/general/sirv_gnrl_icbs.v:generate:000003 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=610-616

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000009 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=618-637
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000008 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=618-637
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000010 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=618-619
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000073 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=618-618
  assign o_icb_cmd_valid = (~n2w_fifo_full) & i_icb_cmd_valid; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000073 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=618-618
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000074 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=619-619
  assign i_icb_cmd_ready = (~n2w_fifo_full) & o_icb_cmd_ready; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000074 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=619-619
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000010 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=618-619
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000075 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=620-620
  assign o_icb_cmd_read  = i_icb_cmd_read ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000075 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=620-620
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000076 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=621-621
  assign o_icb_cmd_addr  = i_icb_cmd_addr ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000076 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=621-621
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000077 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=622-622
  assign o_icb_cmd_lock  = i_icb_cmd_lock ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000077 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=622-622
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000078 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=623-623
  assign o_icb_cmd_excl  = i_icb_cmd_excl ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000078 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=623-623
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000079 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=624-624
  assign o_icb_cmd_size  = i_icb_cmd_size ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000079 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=624-624
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000080 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=625-625
  assign o_icb_cmd_burst = i_icb_cmd_burst;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000080 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=625-625
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000081 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=626-626
  assign o_icb_cmd_beat  = i_icb_cmd_beat ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000081 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=626-626
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000082 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=627-627
  assign o_icb_cmd_usr   = i_icb_cmd_usr  ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000082 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=627-627

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000083 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=629-629
  assign o_icb_cmd_wdata = {i_icb_cmd_wdata,i_icb_cmd_wdata};
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000083 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=629-629
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000084 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=630-630
  assign o_icb_cmd_wmask = cmd_y_lo_hi ?  {i_icb_cmd_wmask,  {X_W/8{1'b0}}} : {  {X_W/8{1'b0}},i_icb_cmd_wmask};
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000084 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=630-630

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000085 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=632-632
  assign i_icb_rsp_valid = o_icb_rsp_valid ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000085 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=632-632
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000086 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=633-633
  assign i_icb_rsp_err   = o_icb_rsp_err   ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000086 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=633-633
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000087 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=634-634
  assign i_icb_rsp_excl_ok   = o_icb_rsp_excl_ok   ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000087 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=634-634
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000088 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=635-635
  assign i_icb_rsp_rdata = rsp_y_lo_hi ?  o_icb_rsp_rdata[Y_W-1:X_W] : o_icb_rsp_rdata[X_W-1:0] ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000088 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=635-635
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000089 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=636-636
  assign i_icb_rsp_usr   = o_icb_rsp_usr   ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000089 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=636-636
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000090 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=637-637
  assign o_icb_rsp_ready = i_icb_rsp_ready;  
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000090 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=637-637
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000009 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=618-637
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000008 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=618-637

endmodule

// ===========================================================================
//
// Description:
//  The module to handle the ICB bus de-mux
//
// ===========================================================================

module sirv_gnrl_icb_splt # (
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:port_section:000004 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=649-707
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:param_decl:000006 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=649-662
  parameter AW = 32,
  parameter DW = 64,
  // The number of outstanding supported
  parameter FIFO_OUTS_NUM = 8,
  parameter FIFO_CUT_READY = 0,
  // SPLT_NUM=4 ports, so 2 bits for port id
  parameter SPLT_NUM = 4,
  parameter SPLT_PTR_1HOT = 1,// Currently we always use 1HOT (i.e., this is configured as 1)
                                // do not try to configure it as 0, becuase we never use it and verify it
  parameter SPLT_PTR_W = 4,
  parameter ALLOW_DIFF = 1,
  parameter ALLOW_0CYCL_RSP = 1,
  parameter VLD_MSK_PAYLOAD = 0,
  parameter USR_W = 1 
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:param_decl:000006 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=649-662
) (
  input  [SPLT_NUM-1:0] i_icb_splt_indic,        

  input  i_icb_cmd_valid, 
  output i_icb_cmd_ready, 
  input  [1-1:0]    i_icb_cmd_read, 
  input  [AW-1:0]   i_icb_cmd_addr, 
  input  [DW-1:0]   i_icb_cmd_wdata, 
  input  [DW/8-1:0] i_icb_cmd_wmask,
  input  [1:0]      i_icb_cmd_burst,
  input  [1:0]      i_icb_cmd_beat,
  input             i_icb_cmd_lock,
  input             i_icb_cmd_excl,
  input  [1:0]      i_icb_cmd_size,
  input  [USR_W-1:0]i_icb_cmd_usr,

  output i_icb_rsp_valid, 
  input  i_icb_rsp_ready, 
  output i_icb_rsp_err,
  output i_icb_rsp_excl_ok,
  output [DW-1:0] i_icb_rsp_rdata, 
  output [USR_W-1:0] i_icb_rsp_usr, 
  
  input  [SPLT_NUM*1-1:0]    o_bus_icb_cmd_ready, 
  output [SPLT_NUM*1-1:0]    o_bus_icb_cmd_valid, 
  output [SPLT_NUM*1-1:0]    o_bus_icb_cmd_read, 
  output [SPLT_NUM*AW-1:0]   o_bus_icb_cmd_addr, 
  output [SPLT_NUM*DW-1:0]   o_bus_icb_cmd_wdata, 
  output [SPLT_NUM*DW/8-1:0] o_bus_icb_cmd_wmask,
  output [SPLT_NUM*2-1:0]    o_bus_icb_cmd_burst,
  output [SPLT_NUM*2-1:0]    o_bus_icb_cmd_beat,
  output [SPLT_NUM*1-1:0]    o_bus_icb_cmd_lock,
  output [SPLT_NUM*1-1:0]    o_bus_icb_cmd_excl,
  output [SPLT_NUM*2-1:0]    o_bus_icb_cmd_size,
  output [SPLT_NUM*USR_W-1:0]o_bus_icb_cmd_usr,

  input  [SPLT_NUM*1-1:0]  o_bus_icb_rsp_valid, 
  output [SPLT_NUM*1-1:0]  o_bus_icb_rsp_ready, 
  input  [SPLT_NUM*1-1:0]  o_bus_icb_rsp_err,
  input  [SPLT_NUM*1-1:0]  o_bus_icb_rsp_excl_ok,
  input  [SPLT_NUM*DW-1:0] o_bus_icb_rsp_rdata, 
  input  [SPLT_NUM*USR_W-1:0] o_bus_icb_rsp_usr, 

  input  clk,  
  input  rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:port_section:000004 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=649-707
  );


integer j;

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000009 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=713-757
wire [SPLT_NUM-1:0] o_icb_cmd_valid; 
wire [SPLT_NUM-1:0] o_icb_cmd_ready; 

wire [1-1:0]    o_icb_cmd_read [SPLT_NUM-1:0]; 
wire [AW-1:0]   o_icb_cmd_addr [SPLT_NUM-1:0]; 
wire [DW-1:0]   o_icb_cmd_wdata[SPLT_NUM-1:0]; 
wire [DW/8-1:0] o_icb_cmd_wmask[SPLT_NUM-1:0];
wire [1:0]      o_icb_cmd_burst[SPLT_NUM-1:0];
wire [1:0]      o_icb_cmd_beat [SPLT_NUM-1:0];
wire            o_icb_cmd_lock [SPLT_NUM-1:0];
wire            o_icb_cmd_excl [SPLT_NUM-1:0];
wire [1:0]      o_icb_cmd_size [SPLT_NUM-1:0];
wire [USR_W-1:0]o_icb_cmd_usr  [SPLT_NUM-1:0];

wire [SPLT_NUM-1:0] o_icb_rsp_valid; 
wire [SPLT_NUM-1:0] o_icb_rsp_ready; 
wire [SPLT_NUM-1:0] o_icb_rsp_err  ;
wire [SPLT_NUM-1:0] o_icb_rsp_excl_ok  ;
wire [DW-1:0] o_icb_rsp_rdata  [SPLT_NUM-1:0];
wire [USR_W-1:0] o_icb_rsp_usr [SPLT_NUM-1:0];

reg sel_o_apb_cmd_ready;

wire rspid_fifo_bypass;
wire rspid_fifo_wen;
wire rspid_fifo_ren;

wire [SPLT_PTR_W-1:0] o_icb_rsp_port_id;

wire rspid_fifo_i_valid;
wire rspid_fifo_o_valid;
wire rspid_fifo_i_ready;
wire rspid_fifo_o_ready;
wire [SPLT_PTR_W-1:0] rspid_fifo_rdat;
wire [SPLT_PTR_W-1:0] rspid_fifo_wdat;

wire rspid_fifo_full;       
wire rspid_fifo_empty;       
reg [SPLT_PTR_W-1:0] i_splt_indic_id;

wire i_icb_cmd_ready_pre;
wire i_icb_cmd_valid_pre;
    
wire i_icb_rsp_ready_pre; 
wire i_icb_rsp_valid_pre;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000009 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=713-757


genvar i;
//__RB_CUT_BEGIN__ type=generate id=e203_hbirdv2/general/sirv_gnrl_icbs.v:generate:000004 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=761-996
generate //{
//__RB_CUT_BODY__ type=generate id=e203_hbirdv2/general/sirv_gnrl_icbs.v:generate:000004 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=761-996
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000021 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=762-783
  if(SPLT_NUM == 1) begin:splt_num_eq_1_gen// {
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000010 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=763-781
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000009 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=763-781
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000011 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=763-764
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000021 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=762-783
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000091 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=763-763
    assign i_icb_cmd_ready     = o_bus_icb_cmd_ready; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000091 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=763-763
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000092 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=764-764
    assign o_bus_icb_cmd_valid = i_icb_cmd_valid; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000092 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=764-764
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000011 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=763-764
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000093 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=765-765
    assign o_bus_icb_cmd_read  = i_icb_cmd_read ; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000093 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=765-765
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000094 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=766-766
    assign o_bus_icb_cmd_addr  = i_icb_cmd_addr ; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000094 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=766-766
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000095 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=767-767
    assign o_bus_icb_cmd_wdata = i_icb_cmd_wdata; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000095 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=767-767
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000096 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=768-768
    assign o_bus_icb_cmd_wmask = i_icb_cmd_wmask;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000096 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=768-768
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000097 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=769-769
    assign o_bus_icb_cmd_burst = i_icb_cmd_burst;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000097 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=769-769
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000098 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=770-770
    assign o_bus_icb_cmd_beat  = i_icb_cmd_beat ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000098 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=770-770
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000099 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=771-771
    assign o_bus_icb_cmd_lock  = i_icb_cmd_lock ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000099 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=771-771
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000100 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=772-772
    assign o_bus_icb_cmd_excl  = i_icb_cmd_excl ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000100 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=772-772
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000101 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=773-773
    assign o_bus_icb_cmd_size  = i_icb_cmd_size ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000101 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=773-773
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000102 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=774-774
    assign o_bus_icb_cmd_usr   = i_icb_cmd_usr  ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000102 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=774-774

//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000012 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=776-777
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000103 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=776-776
    assign o_bus_icb_rsp_ready = i_icb_rsp_ready; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000103 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=776-776
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000104 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=777-777
    assign i_icb_rsp_valid     = o_bus_icb_rsp_valid; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000104 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=777-777
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000012 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=776-777
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000105 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=778-778
    assign i_icb_rsp_err       = o_bus_icb_rsp_err  ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000105 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=778-778
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000106 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=779-779
    assign i_icb_rsp_excl_ok   = o_bus_icb_rsp_excl_ok  ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000106 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=779-779
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000107 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=780-780
    assign i_icb_rsp_rdata     = o_bus_icb_rsp_rdata;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000107 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=780-780
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000108 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=781-781
    assign i_icb_rsp_usr       = o_bus_icb_rsp_usr;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000108 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=781-781
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000010 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=763-781
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000009 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=763-781

//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000021 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=762-783
  end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000021 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=762-783
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000045 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=784-995
  else begin:splt_num_gt_1_gen//{
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000045 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=784-995

    for(i = 0; i < SPLT_NUM; i = i+1)//{
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000022 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=787-807
    begin:icb_distract_gen
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000011 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=788-806
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000010 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=788-806
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000013 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=788-789
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000022 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=787-807
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000109 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=788-788
      assign o_icb_cmd_ready[i]                             = o_bus_icb_cmd_ready[(i+1)*1     -1 : (i)*1     ]; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000109 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=788-788
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000110 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=789-789
      assign o_bus_icb_cmd_valid[(i+1)*1     -1 : i*1     ] = o_icb_cmd_valid[i];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000110 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=789-789
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000013 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=788-789
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000111 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=790-790
      assign o_bus_icb_cmd_read [(i+1)*1     -1 : i*1     ] = o_icb_cmd_read [i];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000111 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=790-790
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000112 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=791-791
      assign o_bus_icb_cmd_addr [(i+1)*AW    -1 : i*AW    ] = o_icb_cmd_addr [i];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000112 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=791-791
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000113 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=792-792
      assign o_bus_icb_cmd_wdata[(i+1)*DW    -1 : i*DW    ] = o_icb_cmd_wdata[i];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000113 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=792-792
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000114 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=793-793
      assign o_bus_icb_cmd_wmask[(i+1)*(DW/8)-1 : i*(DW/8)] = o_icb_cmd_wmask[i];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000114 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=793-793
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000115 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=794-794
      assign o_bus_icb_cmd_burst[(i+1)*2     -1 : i*2     ] = o_icb_cmd_burst[i];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000115 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=794-794
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000116 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=795-795
      assign o_bus_icb_cmd_beat [(i+1)*2     -1 : i*2     ] = o_icb_cmd_beat [i];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000116 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=795-795
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000117 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=796-796
      assign o_bus_icb_cmd_lock [(i+1)*1     -1 : i*1     ] = o_icb_cmd_lock [i];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000117 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=796-796
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000118 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=797-797
      assign o_bus_icb_cmd_excl [(i+1)*1     -1 : i*1     ] = o_icb_cmd_excl [i];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000118 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=797-797
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000119 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=798-798
      assign o_bus_icb_cmd_size [(i+1)*2     -1 : i*2     ] = o_icb_cmd_size [i];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000119 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=798-798
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000120 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=799-799
      assign o_bus_icb_cmd_usr  [(i+1)*USR_W -1 : i*USR_W ] = o_icb_cmd_usr  [i];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000120 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=799-799

//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000014 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=801-802
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000121 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=801-801
      assign o_bus_icb_rsp_ready[(i+1)*1-1 :i*1 ] = o_icb_rsp_ready[i]; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000121 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=801-801
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000122 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=802-802
      assign o_icb_rsp_valid[i]                   = o_bus_icb_rsp_valid[(i+1)*1-1 :i*1 ]; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000122 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=802-802
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000014 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=801-802
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000123 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=803-803
      assign o_icb_rsp_err  [i]                   = o_bus_icb_rsp_err  [(i+1)*1-1 :i*1 ];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000123 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=803-803
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000124 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=804-804
      assign o_icb_rsp_excl_ok  [i]               = o_bus_icb_rsp_excl_ok  [(i+1)*1-1 :i*1 ];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000124 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=804-804
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000125 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=805-805
      assign o_icb_rsp_rdata[i]                   = o_bus_icb_rsp_rdata[(i+1)*DW-1:i*DW];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000125 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=805-805
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000126 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=806-806
      assign o_icb_rsp_usr  [i]                   = o_bus_icb_rsp_usr  [(i+1)*USR_W-1:i*USR_W];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000126 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=806-806
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000011 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=788-806
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000010 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=788-806
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000022 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=787-807
    end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000022 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=787-807

    ///////////////////////
    // Input ICB will be accepted when
    // (*) The targeted icb have "ready" asserted
    // (*) The FIFO is not full
    
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000015 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=814-821
//__RB_CUT_BEGIN__ type=always id=e203_hbirdv2/general/sirv_gnrl_icbs.v:proc:000003 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=814-819
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000024 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=814-819
    always @ (*) begin : sel_o_apb_cmd_ready_PROC
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000024 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=814-819
      sel_o_apb_cmd_ready = 1'b0;
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000023 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=816-818
      for(j = 0; j < SPLT_NUM; j = j+1) begin//{
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000023 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=816-818
        sel_o_apb_cmd_ready = sel_o_apb_cmd_ready | (i_icb_splt_indic[j] & o_icb_cmd_ready[j]);
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000023 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=816-818
      end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000023 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=816-818
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000024 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=814-819
    end
//__RB_CUT_TAIL__ type=always id=e203_hbirdv2/general/sirv_gnrl_icbs.v:proc:000003 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=814-819
//__RB_CUT_END__ type=always id=e203_hbirdv2/general/sirv_gnrl_icbs.v:proc:000003 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=814-819
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000024 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=814-819

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000127 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=821-821
    assign i_icb_cmd_ready_pre = sel_o_apb_cmd_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000127 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=821-821
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000015 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=814-821

//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000025 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=823-826
    if(ALLOW_DIFF == 1) begin:allow_diff// {
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000012 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=824-825
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000016 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=824-825
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000025 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=823-826
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000128 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=824-824
       assign i_icb_cmd_valid_pre = i_icb_cmd_valid     & (~rspid_fifo_full);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000128 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=824-824
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000129 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=825-825
       assign i_icb_cmd_ready     = i_icb_cmd_ready_pre & (~rspid_fifo_full);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000129 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=825-825
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000012 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=824-825
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000016 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=824-825
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000025 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=823-826
    end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000025 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=823-826
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000026 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=827-833
    else begin:not_allow_diff
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000026 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=827-833
       // The next transaction can only be issued if there is no any outstanding 
       //   transactions to different targets
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000010 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=830-830
       wire cmd_diff_branch = (~rspid_fifo_empty) & (~(rspid_fifo_wdat == rspid_fifo_rdat));
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000010 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=830-830
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000013 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=831-832
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000017 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=831-832
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000130 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=831-831
       assign i_icb_cmd_valid_pre = i_icb_cmd_valid     & (~cmd_diff_branch) & (~rspid_fifo_full);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000130 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=831-831
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000131 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=832-832
       assign i_icb_cmd_ready     = i_icb_cmd_ready_pre & (~cmd_diff_branch) & (~rspid_fifo_full);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000131 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=832-832
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000013 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=831-832
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000017 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=831-832
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000026 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=827-833
    end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000026 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=827-833
    
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000028 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=835-839
    if(SPLT_PTR_1HOT == 1) begin:ptr_1hot// {
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000028 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=835-839
//__RB_CUT_BEGIN__ type=always id=e203_hbirdv2/general/sirv_gnrl_icbs.v:proc:000004 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=836-838
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000027 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=836-838
       always @ (*) begin : i_splt_indic_id_PROC
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000027 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=836-838
         i_splt_indic_id = i_icb_splt_indic;
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000027 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=836-838
       end
//__RB_CUT_TAIL__ type=always id=e203_hbirdv2/general/sirv_gnrl_icbs.v:proc:000004 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=836-838
//__RB_CUT_END__ type=always id=e203_hbirdv2/general/sirv_gnrl_icbs.v:proc:000004 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=836-838
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000027 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=836-838
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000028 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=835-839
    end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000028 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=835-839
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000031 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=840-847
    else begin:ptr_not_1hot//}{
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000031 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=840-847
//__RB_CUT_BEGIN__ type=always id=e203_hbirdv2/general/sirv_gnrl_icbs.v:proc:000005 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=841-846
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000030 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=841-846
       always @ (*) begin : i_splt_indic_id_PROC
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000030 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=841-846
         i_splt_indic_id = {SPLT_PTR_W{1'b0}};
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000029 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=843-845
         for(j = 0; j < SPLT_NUM; j = j+1) begin//{
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000029 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=843-845
           i_splt_indic_id = i_splt_indic_id | ({SPLT_PTR_W{i_icb_splt_indic[j]}} & $unsigned(j));
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000029 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=843-845
         end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000029 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=843-845
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000030 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=841-846
       end
//__RB_CUT_TAIL__ type=always id=e203_hbirdv2/general/sirv_gnrl_icbs.v:proc:000005 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=841-846
//__RB_CUT_END__ type=always id=e203_hbirdv2/general/sirv_gnrl_icbs.v:proc:000005 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=841-846
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000030 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=841-846
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000031 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=840-847
    end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000031 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=840-847
        
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000014 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=849-850
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000018 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=849-850
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000132 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=849-849
    assign rspid_fifo_wen = i_icb_cmd_valid & i_icb_cmd_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000132 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=849-849
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000133 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=850-850
    assign rspid_fifo_ren = i_icb_rsp_valid & i_icb_rsp_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000133 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=850-850
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000014 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=849-850
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000018 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=849-850

//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000032 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=852-858
    if(ALLOW_0CYCL_RSP == 1) begin: allow_0rsp
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000015 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=853-857
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000011 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=853-857
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000032 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=852-858
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000134 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=853-853
        assign rspid_fifo_bypass = rspid_fifo_empty & rspid_fifo_wen & rspid_fifo_ren;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000134 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=853-853
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000135 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=854-854
        assign o_icb_rsp_port_id = rspid_fifo_empty ? rspid_fifo_wdat : rspid_fifo_rdat;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000135 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=854-854
        // We dont need this empty qualifications because we allow the 0 cyle response
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000019 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=856-857
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000136 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=856-856
        assign i_icb_rsp_valid     = i_icb_rsp_valid_pre;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000136 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=856-856
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000137 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=857-857
        assign i_icb_rsp_ready_pre = i_icb_rsp_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000137 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=857-857
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000019 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=856-857
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000015 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=853-857
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000011 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=853-857
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000032 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=852-858
    end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000032 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=852-858
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000033 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=859-864
    else begin: no_allow_0rsp
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000016 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=860-863
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000012 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=860-863
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000033 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=859-864
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000138 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=860-860
        assign rspid_fifo_bypass = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000138 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=860-860
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000139 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=861-861
        assign o_icb_rsp_port_id = rspid_fifo_empty ? {SPLT_PTR_W{1'b0}} : rspid_fifo_rdat;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000139 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=861-861
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000020 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=862-863
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000140 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=862-862
        assign i_icb_rsp_valid     = (~rspid_fifo_empty) & i_icb_rsp_valid_pre;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000140 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=862-862
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000141 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=863-863
        assign i_icb_rsp_ready_pre = (~rspid_fifo_empty) & i_icb_rsp_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000141 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=863-863
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000020 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=862-863
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000016 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=860-863
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000012 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=860-863
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000033 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=859-864
    end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000033 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=859-864

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000017 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=866-871
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000013 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=866-871
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000021 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=866-869
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000142 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=866-866
    assign rspid_fifo_i_valid = rspid_fifo_wen & (~rspid_fifo_bypass);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000142 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=866-866
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000143 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=867-867
    assign rspid_fifo_full    = (~rspid_fifo_i_ready);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000143 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=867-867
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000144 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=868-868
    assign rspid_fifo_o_ready = rspid_fifo_ren & (~rspid_fifo_bypass);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000144 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=868-868
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000145 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=869-869
    assign rspid_fifo_empty   = (~rspid_fifo_o_valid);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000145 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=869-869
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000021 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=866-869

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000146 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=871-871
    assign rspid_fifo_wdat   = i_splt_indic_id;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000146 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=871-871
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000017 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=866-871
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000013 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=866-871
 
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000034 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=873-890
    if(FIFO_OUTS_NUM == 1) begin:fifo_dp_1//{
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000034 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=873-890
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000009 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=874-888
      sirv_gnrl_pipe_stage # (
        .CUT_READY (FIFO_CUT_READY),
        .DP  (1),
        .DW  (SPLT_PTR_W)
      ) u_sirv_gnrl_rspid_fifo (
        .i_vld(rspid_fifo_i_valid),
        .i_rdy(rspid_fifo_i_ready),
        .i_dat(rspid_fifo_wdat ),
        .o_vld(rspid_fifo_o_valid),
        .o_rdy(rspid_fifo_o_ready),  
        .o_dat(rspid_fifo_rdat ),  
      
        .clk  (clk),
        .rst_n(rst_n)
      );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000009 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=874-888

//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000034 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=873-890
    end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000034 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=873-890
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000035 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=891-908
    else begin: fifo_dp_gt_1//{
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000035 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=891-908
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000010 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=892-907
      sirv_gnrl_fifo # (
        .CUT_READY (FIFO_CUT_READY),
        .MSKO      (0),
        .DP  (FIFO_OUTS_NUM),
        .DW  (SPLT_PTR_W)
      ) u_sirv_gnrl_rspid_fifo (
        .i_vld(rspid_fifo_i_valid),
        .i_rdy(rspid_fifo_i_ready),
        .i_dat(rspid_fifo_wdat ),
        .o_vld(rspid_fifo_o_valid),
        .o_rdy(rspid_fifo_o_ready),  
        .o_dat(rspid_fifo_rdat ),  
      
        .clk  (clk),
        .rst_n(rst_n)
      );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000010 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=892-907
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000035 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=891-908
    end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000035 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=891-908

    ///////////////////////
    // 
    for(i = 0; i < SPLT_NUM; i = i+1)//{
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000038 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=913-939
    begin:o_icb_cmd_valid_gen
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000038 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=913-939
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000147 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=914-914
      assign o_icb_cmd_valid[i] = i_icb_splt_indic[i] & i_icb_cmd_valid_pre;         
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000147 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=914-914
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000036 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=915-926
      if(VLD_MSK_PAYLOAD == 0) begin: no_vld_msk_payload
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000018 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=916-925
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000014 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=916-925
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000036 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=915-926
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000148 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=916-916
          assign o_icb_cmd_read [i] = i_icb_cmd_read ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000148 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=916-916
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000149 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=917-917
          assign o_icb_cmd_addr [i] = i_icb_cmd_addr ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000149 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=917-917
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000150 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=918-918
          assign o_icb_cmd_wdata[i] = i_icb_cmd_wdata;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000150 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=918-918
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000151 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=919-919
          assign o_icb_cmd_wmask[i] = i_icb_cmd_wmask;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000151 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=919-919
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000152 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=920-920
          assign o_icb_cmd_burst[i] = i_icb_cmd_burst;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000152 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=920-920
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000153 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=921-921
          assign o_icb_cmd_beat [i] = i_icb_cmd_beat ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000153 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=921-921
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000154 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=922-922
          assign o_icb_cmd_lock [i] = i_icb_cmd_lock ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000154 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=922-922
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000155 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=923-923
          assign o_icb_cmd_excl [i] = i_icb_cmd_excl ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000155 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=923-923
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000156 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=924-924
          assign o_icb_cmd_size [i] = i_icb_cmd_size ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000156 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=924-924
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000157 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=925-925
          assign o_icb_cmd_usr  [i] = i_icb_cmd_usr  ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000157 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=925-925
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000018 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=916-925
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000014 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=916-925
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000036 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=915-926
      end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000036 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=915-926
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000037 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=927-938
      else begin: vld_msk_payload
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000019 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=928-937
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000015 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=928-937
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000022 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=928-937
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000037 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=927-938
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000158 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=928-928
          assign o_icb_cmd_read [i] = {1    {o_icb_cmd_valid[i]}} & i_icb_cmd_read ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000158 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=928-928
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000159 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=929-929
          assign o_icb_cmd_addr [i] = {AW   {o_icb_cmd_valid[i]}} & i_icb_cmd_addr ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000159 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=929-929
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000160 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=930-930
          assign o_icb_cmd_wdata[i] = {DW   {o_icb_cmd_valid[i]}} & i_icb_cmd_wdata;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000160 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=930-930
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000161 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=931-931
          assign o_icb_cmd_wmask[i] = {DW/8 {o_icb_cmd_valid[i]}} & i_icb_cmd_wmask;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000161 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=931-931
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000162 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=932-932
          assign o_icb_cmd_burst[i] = {2    {o_icb_cmd_valid[i]}} & i_icb_cmd_burst;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000162 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=932-932
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000163 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=933-933
          assign o_icb_cmd_beat [i] = {2    {o_icb_cmd_valid[i]}} & i_icb_cmd_beat ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000163 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=933-933
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000164 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=934-934
          assign o_icb_cmd_lock [i] = {1    {o_icb_cmd_valid[i]}} & i_icb_cmd_lock ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000164 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=934-934
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000165 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=935-935
          assign o_icb_cmd_excl [i] = {1    {o_icb_cmd_valid[i]}} & i_icb_cmd_excl ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000165 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=935-935
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000166 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=936-936
          assign o_icb_cmd_size [i] = {2    {o_icb_cmd_valid[i]}} & i_icb_cmd_size ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000166 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=936-936
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000167 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=937-937
          assign o_icb_cmd_usr  [i] = {USR_W{o_icb_cmd_valid[i]}} & i_icb_cmd_usr  ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000167 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=937-937
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000019 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=928-937
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000015 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=928-937
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000022 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=928-937
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000037 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=927-938
      end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000037 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=927-938
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000038 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=913-939
    end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000038 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=913-939
    //
    
    ///////////////////////
    // 
    //
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000042 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=945-978
    if(SPLT_PTR_1HOT == 1) begin:ptr_1hot_rsp// {
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000042 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=945-978

        for(i = 0; i < SPLT_NUM; i = i+1)//{
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000039 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=948-950
        begin:o_icb_rsp_ready_gen
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000039 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=948-950
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000168 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=949-949
          assign o_icb_rsp_ready[i] = (o_icb_rsp_port_id[i] & i_icb_rsp_ready_pre);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000168 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=949-949
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000039 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=948-950
        end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000039 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=948-950
        //
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000169 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=952-952
        assign i_icb_rsp_valid_pre = |(o_icb_rsp_valid & o_icb_rsp_port_id);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000169 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=952-952


//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000011 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=955-958
        reg sel_i_icb_rsp_err;
        reg sel_i_icb_rsp_excl_ok;
        reg [DW-1:0] sel_i_icb_rsp_rdata; 
        reg [USR_W-1:0] sel_i_icb_rsp_usr; 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000011 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=955-958

//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000016 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=960-976
//__RB_CUT_BEGIN__ type=always id=e203_hbirdv2/general/sirv_gnrl_icbs.v:proc:000006 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=960-971
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000041 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=960-971
        always @ (*) begin : sel_icb_rsp_PROC
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000041 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=960-971
          sel_i_icb_rsp_err   = 1'b0;
          sel_i_icb_rsp_excl_ok   = 1'b0;
          sel_i_icb_rsp_rdata = {DW   {1'b0}};
          sel_i_icb_rsp_usr   = {USR_W{1'b0}};
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000040 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=965-970
          for(j = 0; j < SPLT_NUM; j = j+1) begin//{
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000040 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=965-970
            sel_i_icb_rsp_err     = sel_i_icb_rsp_err     | (       o_icb_rsp_port_id[j]   & o_icb_rsp_err[j]);
            sel_i_icb_rsp_excl_ok = sel_i_icb_rsp_excl_ok | (       o_icb_rsp_port_id[j]   & o_icb_rsp_excl_ok[j]);
            sel_i_icb_rsp_rdata   = sel_i_icb_rsp_rdata   | ({DW   {o_icb_rsp_port_id[j]}} & o_icb_rsp_rdata[j]);
            sel_i_icb_rsp_usr     = sel_i_icb_rsp_usr     | ({USR_W{o_icb_rsp_port_id[j]}} & o_icb_rsp_usr[j]);
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000040 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=965-970
          end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000040 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=965-970
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000041 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=960-971
        end
//__RB_CUT_TAIL__ type=always id=e203_hbirdv2/general/sirv_gnrl_icbs.v:proc:000006 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=960-971
//__RB_CUT_END__ type=always id=e203_hbirdv2/general/sirv_gnrl_icbs.v:proc:000006 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=960-971
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000041 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=960-971

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000020 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=973-976
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000170 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=973-973
        assign i_icb_rsp_err   = sel_i_icb_rsp_err  ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000170 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=973-973
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000171 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=974-974
        assign i_icb_rsp_excl_ok   = sel_i_icb_rsp_excl_ok  ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000171 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=974-974
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000172 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=975-975
        assign i_icb_rsp_rdata = sel_i_icb_rsp_rdata;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000172 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=975-975
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000173 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=976-976
        assign i_icb_rsp_usr   = sel_i_icb_rsp_usr  ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000173 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=976-976
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000020 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=973-976
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000016 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=960-976

//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000042 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=945-978
    end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000042 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=945-978
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000044 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=979-993
    else begin:ptr_not_1hot_rsp//}{
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000044 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=979-993

        for(i = 0; i < SPLT_NUM; i = i+1)//{
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000043 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=982-984
        begin:o_icb_rsp_ready_gen
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000043 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=982-984
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000174 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=983-983
          assign o_icb_rsp_ready[i] = (o_icb_rsp_port_id == i) & i_icb_rsp_ready_pre;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000174 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=983-983
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000043 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=982-984
        end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000043 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=982-984
        //
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000021 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=986-992
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000017 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=986-992
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000175 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=986-986
        assign i_icb_rsp_valid_pre = o_icb_rsp_valid[o_icb_rsp_port_id]; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000175 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=986-986


//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000176 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=989-989
        assign i_icb_rsp_err     = o_icb_rsp_err    [o_icb_rsp_port_id]; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000176 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=989-989
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000177 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=990-990
        assign i_icb_rsp_excl_ok = o_icb_rsp_excl_ok[o_icb_rsp_port_id]; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000177 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=990-990
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000178 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=991-991
        assign i_icb_rsp_rdata   = o_icb_rsp_rdata  [o_icb_rsp_port_id]; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000178 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=991-991
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000179 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=992-992
        assign i_icb_rsp_usr     = o_icb_rsp_usr    [o_icb_rsp_port_id]; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000179 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=992-992
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000021 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=986-992
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000017 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=986-992
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000044 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=979-993
    end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000044 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=979-993
    
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000045 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=784-995
  end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000045 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=784-995
//__RB_CUT_TAIL__ type=generate id=e203_hbirdv2/general/sirv_gnrl_icbs.v:generate:000004 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=761-996
  endgenerate //}
//__RB_CUT_END__ type=generate id=e203_hbirdv2/general/sirv_gnrl_icbs.v:generate:000004 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=761-996

endmodule

// ===========================================================================
//
// Description:
//  The module to handle the simple-ICB bus to AXI bus conversion 
//
// ===========================================================================

module sirv_gnrl_icb2axi # (
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:port_section:000005 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1008-1067
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:param_decl:000007 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1008-1015
  parameter AXI_FIFO_DP = 0, // This is to optionally add the pipeline stage for AXI bus
                             //   if the depth is 0, then means pass through, not add pipeline
                             //   if the depth is 2, then means added one ping-pong buffer stage
  parameter AXI_FIFO_CUT_READY = 1, // This is to cut the back-pressure signal if you set as 1
  parameter AW = 32,
  parameter FIFO_OUTS_NUM = 8,
  parameter FIFO_CUT_READY = 0,
  parameter DW = 64 // 64 or 32 bits
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:param_decl:000007 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1008-1015
) (
  input              i_icb_cmd_valid, 
  output             i_icb_cmd_ready, 
  input  [1-1:0]     i_icb_cmd_read, 
  input  [AW-1:0]    i_icb_cmd_addr, 
  input  [DW-1:0]    i_icb_cmd_wdata, 
  input  [DW/8-1:0]  i_icb_cmd_wmask,
  input  [1:0]       i_icb_cmd_size,

  output             i_icb_rsp_valid, 
  input              i_icb_rsp_ready, 
  output             i_icb_rsp_err,
  output [DW-1:0]    i_icb_rsp_rdata, 
  
  output o_axi_arvalid,
  input  o_axi_arready,
  output [AW-1:0] o_axi_araddr,
  output [3:0] o_axi_arcache,
  output [2:0] o_axi_arprot,
  output [1:0] o_axi_arlock,
  output [1:0] o_axi_arburst,
  output [3:0] o_axi_arlen,
  output [2:0] o_axi_arsize,

  output o_axi_awvalid,
  input  o_axi_awready,
  output [AW-1:0] o_axi_awaddr,
  output [3:0] o_axi_awcache,
  output [2:0] o_axi_awprot,
  output [1:0] o_axi_awlock,
  output [1:0] o_axi_awburst,
  output [3:0] o_axi_awlen,
  output [2:0] o_axi_awsize,

  input  o_axi_rvalid,
  output o_axi_rready,
  input  [DW-1:0] o_axi_rdata,
  input  [1:0] o_axi_rresp,
  input  o_axi_rlast,

  output o_axi_wvalid,
  input  o_axi_wready,
  output [DW-1:0] o_axi_wdata,
  output [(DW/8)-1:0] o_axi_wstrb,
  output o_axi_wlast,

  input  o_axi_bvalid,
  output o_axi_bready,
  input  [1:0] o_axi_bresp,

  input  clk,  
  input  rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:port_section:000005 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1008-1067
  );

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000012 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1070-1104
  wire i_axi_arvalid;
  wire i_axi_arready;
  wire [AW-1:0] i_axi_araddr;
  wire [3:0] i_axi_arcache;
  wire [2:0] i_axi_arprot;
  wire [1:0] i_axi_arlock;
  wire [1:0] i_axi_arburst;
  wire [3:0] i_axi_arlen;
  wire [2:0] i_axi_arsize;

  wire i_axi_awvalid;
  wire i_axi_awready;
  wire [AW-1:0] i_axi_awaddr;
  wire [3:0] i_axi_awcache;
  wire [2:0] i_axi_awprot;
  wire [1:0] i_axi_awlock;
  wire [1:0] i_axi_awburst;
  wire [3:0] i_axi_awlen;
  wire [2:0] i_axi_awsize;

  wire i_axi_rvalid;
  wire i_axi_rready;
  wire [DW-1:0] i_axi_rdata;
  wire [1:0] i_axi_rresp;
  wire i_axi_rlast;

  wire i_axi_wvalid;
  wire i_axi_wready;
  wire [DW-1:0] i_axi_wdata;
  wire [(DW/8)-1:0] i_axi_wstrb;
  wire i_axi_wlast;

  wire i_axi_bvalid;
  wire i_axi_bready;
  wire [1:0] i_axi_bresp;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000012 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1070-1104


  //////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////
  // Convert the ICB to AXI Read/Write address and Wdata channel
  //
  //   Generate the AXI address channel valid which is direct got 
  //     from ICB command channel
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000180 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1113-1113
  assign i_axi_arvalid = i_icb_cmd_valid & i_icb_cmd_read;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000180 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1113-1113
  
  // If it is the read transaction, need to pass to AR channel only
  // If it is the write transaction, need to pass to AW and W channel both
      // But in all case, need to check FIFO is not ful
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000013 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1118-1118
  wire rw_fifo_full;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000013 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1118-1118
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000022 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1119-1143
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000018 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1119-1143
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000023 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1119-1122
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000181 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1119-1120
  assign i_icb_cmd_ready = (~rw_fifo_full) & 
             (i_icb_cmd_read ? i_axi_arready : (i_axi_awready & i_axi_wready));
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000181 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1119-1120
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000182 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1121-1121
  assign i_axi_awvalid = i_icb_cmd_valid & (~i_icb_cmd_read) & i_axi_wready  & (~rw_fifo_full);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000182 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1121-1121
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000183 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1122-1122
  assign i_axi_wvalid  = i_icb_cmd_valid & (~i_icb_cmd_read) & i_axi_awready & (~rw_fifo_full); 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000183 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1122-1122
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000023 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1119-1122
  //
  
  //   Generate the AXI address channel address which is direct got 
  //     from ICB command channel
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000184 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1127-1127
  assign i_axi_araddr = i_icb_cmd_addr;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000184 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1127-1127
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000185 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1128-1128
  assign i_axi_awaddr = i_icb_cmd_addr;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000185 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1128-1128
  
  //
  // For these attribute signals we just make it tied to zero
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000186 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1132-1132
  assign i_axi_arcache = 4'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000186 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1132-1132
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000187 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1133-1133
  assign i_axi_awcache = 4'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000187 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1133-1133
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000188 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1134-1134
  assign i_axi_arprot =  3'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000188 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1134-1134
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000189 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1135-1135
  assign i_axi_awprot =  3'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000189 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1135-1135
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000190 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1136-1136
  assign i_axi_arlock = 2'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000190 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1136-1136
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000191 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1137-1137
  assign i_axi_awlock = 2'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000191 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1137-1137
  //
  // The ICB does not support burst now, so just make it fixed
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000192 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1140-1140
  assign i_axi_arburst = 2'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000192 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1140-1140
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000193 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1141-1141
  assign i_axi_awburst = 2'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000193 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1141-1141
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000194 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1142-1142
  assign i_axi_arlen = 4'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000194 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1142-1142
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000195 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1143-1143
  assign i_axi_awlen = 4'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000195 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1143-1143
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000022 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1119-1143
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000018 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1119-1143
  
//__RB_CUT_BEGIN__ type=generate id=e203_hbirdv2/general/sirv_gnrl_icbs.v:generate:000005 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1145-1154
  generate 
//__RB_CUT_BODY__ type=generate id=e203_hbirdv2/general/sirv_gnrl_icbs.v:generate:000005 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1145-1154
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000046 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1146-1149
    if(DW==32) begin:dw_32
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000023 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1147-1148
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000046 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1146-1149
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000196 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1147-1147
      assign i_axi_arsize = 3'b10;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000196 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1147-1147
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000197 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1148-1148
      assign i_axi_awsize = 3'b10;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000197 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1148-1148
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000023 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1147-1148
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000046 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1146-1149
    end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000046 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1146-1149
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000047 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1150-1153
    if(DW==64) begin:dw_64
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000024 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1151-1152
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000047 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1150-1153
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000198 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1151-1151
      assign i_axi_arsize = 3'b11;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000198 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1151-1151
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000199 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1152-1152
      assign i_axi_awsize = 3'b11;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000199 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1152-1152
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000024 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1151-1152
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000047 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1150-1153
    end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_gnrl_icbs.v:begin_end:000047 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1150-1153
//__RB_CUT_TAIL__ type=generate id=e203_hbirdv2/general/sirv_gnrl_icbs.v:generate:000005 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1145-1154
  endgenerate
//__RB_CUT_END__ type=generate id=e203_hbirdv2/general/sirv_gnrl_icbs.v:generate:000005 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1145-1154
  
  // Generate the Write data channel
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000025 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1157-1159
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000019 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1157-1159
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000200 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1157-1157
  assign i_axi_wdata = i_icb_cmd_wdata;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000200 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1157-1157
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000201 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1158-1158
  assign i_axi_wstrb = i_icb_cmd_wmask;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000201 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1158-1158
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000202 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1159-1159
  assign i_axi_wlast = 1'b1;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000202 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1159-1159
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000025 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1157-1159
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000019 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1157-1159

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000014 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1161-1167
  wire rw_fifo_wen = i_icb_cmd_valid & i_icb_cmd_ready;
  wire rw_fifo_ren = i_icb_rsp_valid & i_icb_rsp_ready;

  wire rw_fifo_i_ready;
  wire rw_fifo_i_valid = rw_fifo_wen;
  wire rw_fifo_o_valid ;
  wire rw_fifo_o_ready = rw_fifo_ren;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000014 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1161-1167

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000203 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1169-1169
  assign rw_fifo_full    = (~rw_fifo_i_ready);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000203 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1169-1169
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000015 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1170-1172
  wire rw_fifo_empty   = (~rw_fifo_o_valid);

  wire i_icb_rsp_read;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000015 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1170-1172

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000011 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1174-1189
  sirv_gnrl_fifo # (
    .CUT_READY (FIFO_CUT_READY),
    .MSKO      (1),
    .DP  (FIFO_OUTS_NUM),
    .DW  (1)
  ) u_sirv_gnrl_rw_fifo (
    .i_vld(rw_fifo_i_valid),
    .i_rdy(rw_fifo_i_ready),
    .i_dat(i_icb_cmd_read ),
    .o_vld(rw_fifo_o_valid),
    .o_rdy(rw_fifo_o_ready),  
    .o_dat(i_icb_rsp_read ),  
  
    .clk  (clk),
    .rst_n(rst_n)
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000011 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1174-1189


//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
// Generate the response channel
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000026 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1195-1201
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000020 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1195-1201
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000024 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1195-1197
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000204 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1195-1195
  assign i_icb_rsp_valid = i_icb_rsp_read ? i_axi_rvalid : i_axi_bvalid;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000204 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1195-1195
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000205 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1196-1196
  assign i_axi_rready = i_icb_rsp_read & i_icb_rsp_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000205 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1196-1196
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000206 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1197-1197
  assign i_axi_bready = (~i_icb_rsp_read) & i_icb_rsp_ready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000206 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1197-1197
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000024 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1195-1197

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000207 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1199-1200
  assign i_icb_rsp_err = i_icb_rsp_read ? i_axi_rresp[1] //SLVERR or DECERR 
                                        : i_axi_bresp[1];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000207 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1199-1200
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000208 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1201-1201
  assign i_icb_rsp_rdata = i_icb_rsp_read ? i_axi_rdata : {DW{1'b0}}; 
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000208 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1201-1201
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000026 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1195-1201
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000020 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1195-1201
  

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000012 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1204-1284
  sirv_gnrl_axi_buffer #(
     .CHNL_FIFO_DP         (AXI_FIFO_DP       ), 
     .CHNL_FIFO_CUT_READY  (AXI_FIFO_CUT_READY),
     .AW                   (AW),
     .DW                   (DW) 
    ) u_sirv_gnrl_axi_buffer (
    .i_axi_arvalid   (i_axi_arvalid),
    .i_axi_arready   (i_axi_arready),
    .i_axi_araddr    (i_axi_araddr ),
    .i_axi_arcache   (i_axi_arcache),
    .i_axi_arprot    (i_axi_arprot ),
    .i_axi_arlock    (i_axi_arlock ),
    .i_axi_arburst   (i_axi_arburst),
    .i_axi_arlen     (i_axi_arlen  ),
    .i_axi_arsize    (i_axi_arsize ),
                                   
    .i_axi_awvalid   (i_axi_awvalid),
    .i_axi_awready   (i_axi_awready),
    .i_axi_awaddr    (i_axi_awaddr ),
    .i_axi_awcache   (i_axi_awcache),
    .i_axi_awprot    (i_axi_awprot ),
    .i_axi_awlock    (i_axi_awlock ),
    .i_axi_awburst   (i_axi_awburst),
    .i_axi_awlen     (i_axi_awlen  ),
    .i_axi_awsize    (i_axi_awsize ),
                                   
    .i_axi_rvalid    (i_axi_rvalid ),
    .i_axi_rready    (i_axi_rready ),
    .i_axi_rdata     (i_axi_rdata  ),
    .i_axi_rresp     (i_axi_rresp  ),
    .i_axi_rlast     (i_axi_rlast  ),
                                   
    .i_axi_wvalid    (i_axi_wvalid ),
    .i_axi_wready    (i_axi_wready ),
    .i_axi_wdata     (i_axi_wdata  ),
    .i_axi_wstrb     (i_axi_wstrb  ),
    .i_axi_wlast     (i_axi_wlast  ),
                                   
    .i_axi_bvalid    (i_axi_bvalid ),
    .i_axi_bready    (i_axi_bready ),
    .i_axi_bresp     (i_axi_bresp  ),
                                   
    .o_axi_arvalid   (o_axi_arvalid),
    .o_axi_arready   (o_axi_arready),
    .o_axi_araddr    (o_axi_araddr ),
    .o_axi_arcache   (o_axi_arcache),
    .o_axi_arprot    (o_axi_arprot ),
    .o_axi_arlock    (o_axi_arlock ),
    .o_axi_arburst   (o_axi_arburst),
    .o_axi_arlen     (o_axi_arlen  ),
    .o_axi_arsize    (o_axi_arsize ),
                      
    .o_axi_awvalid   (o_axi_awvalid),
    .o_axi_awready   (o_axi_awready),
    .o_axi_awaddr    (o_axi_awaddr ),
    .o_axi_awcache   (o_axi_awcache),
    .o_axi_awprot    (o_axi_awprot ),
    .o_axi_awlock    (o_axi_awlock ),
    .o_axi_awburst   (o_axi_awburst),
    .o_axi_awlen     (o_axi_awlen  ),
    .o_axi_awsize    (o_axi_awsize ),
                     
    .o_axi_rvalid    (o_axi_rvalid ),
    .o_axi_rready    (o_axi_rready ),
    .o_axi_rdata     (o_axi_rdata  ),
    .o_axi_rresp     (o_axi_rresp  ),
    .o_axi_rlast     (o_axi_rlast  ),
                    
    .o_axi_wvalid    (o_axi_wvalid ),
    .o_axi_wready    (o_axi_wready ),
    .o_axi_wdata     (o_axi_wdata  ),
    .o_axi_wstrb     (o_axi_wstrb  ),
    .o_axi_wlast     (o_axi_wlast  ),
                   
    .o_axi_bvalid    (o_axi_bvalid ),
    .o_axi_bready    (o_axi_bready ),
    .o_axi_bresp     (o_axi_bresp  ),
       
    .clk  (clk),
    .rst_n(rst_n)
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000012 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1204-1284


endmodule


// ===========================================================================
//
// Description:
//  The module to handle the simple-ICB bus to Wishbone bus conversion 
//  Note: in order to support the open source I2C IP, which is 8 bits
//       wide bus and byte-addresable, so here this module is just ICB to 
//       wishbone 8-bits bus conversion
//
// ===========================================================================

module sirv_gnrl_icb32towishb8 # (
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:port_section:000006 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1301-1326
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:param_decl:000008 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1301-1301
  parameter AW = 32 
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:param_decl:000008 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1301-1301
) (
  input              i_icb_cmd_valid, 
  output             i_icb_cmd_ready, 
  input  [1-1:0]     i_icb_cmd_read, 
  input  [AW-1:0]    i_icb_cmd_addr, 
  input  [32-1:0]    i_icb_cmd_wdata, 
  input  [32/8-1:0]  i_icb_cmd_wmask,
  input  [1:0]       i_icb_cmd_size,

  output             i_icb_rsp_valid, 
  input              i_icb_rsp_ready, 
  output             i_icb_rsp_err,
  output [32-1:0]    i_icb_rsp_rdata, 
  
  // The 8bits wishbone slave (e.g., I2C) must be accessed by load/store byte instructions
  output  [AW-1:0] wb_adr,     // lower address bits
  output  [8-1:0]  wb_dat_w,   // databus input
  input   [8-1:0]  wb_dat_r,   // databus output
  output           wb_we,      // write enable input
  output           wb_stb,     // stobe/core select signal
  output           wb_cyc,     // valid bus cycle input
  input            wb_ack,     // bus cycle acknowledge output

  input  clk,  
  input  rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:port_section:000006 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1301-1326
  );

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000027 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1329-1338
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000021 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1329-1338
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000209 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1329-1329
  assign wb_adr   = i_icb_cmd_addr;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000209 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1329-1329
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000210 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1330-1330
  assign wb_we    = ~i_icb_cmd_read;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000210 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1330-1330

  // The 32bits bus to 8bits bus remapping
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000211 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1333-1338
  assign wb_dat_w = 
             i_icb_cmd_wmask[3] ? i_icb_cmd_wdata[31:24] :
             i_icb_cmd_wmask[2] ? i_icb_cmd_wdata[23:16] :
             i_icb_cmd_wmask[1] ? i_icb_cmd_wdata[15:8] :
             i_icb_cmd_wmask[0] ? i_icb_cmd_wdata[7:0] :
                                  8'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000211 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1333-1338
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000027 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1329-1338
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000021 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1329-1338
             
             
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000016 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1341-1341
  wire  [32-1:0]  wb_dat_r_remap = 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000016 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1341-1341
                 {24'b0,wb_dat_r} << {i_icb_cmd_addr[1:0],3'b0};
             
  // Since the Wishbone reponse channel does not have handhake scheme, but the
  //   ICB have, so the response may not be accepted by the upstream master
  //   So in order to make sure the functionality is correct, we must put
  //   a reponse bypass-buffer here, to always be able to accept response from wishbone
  //
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000013 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1349-1364
  sirv_gnrl_fifo # (
   .CUT_READY (1),
   .MSKO      (0),
   .DP(1),
   .DW(32)
  ) u_rsp_fifo(
    .i_vld(wb_ack), 
    .i_rdy(), 
    .i_dat(wb_dat_r_remap),
    .o_vld(i_icb_rsp_valid), 
    .o_rdy(i_icb_rsp_ready), 
    .o_dat(i_icb_rsp_rdata),
  
    .clk  (clk  ),
    .rst_n(rst_n)  
   );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000013 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1349-1364

  // We only initiate the reqeust when the response buffer is empty, to make
  //   sure when the response back from wishbone we can alway be able to 
  //   accept it
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000028 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1369-1374
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000022 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1369-1374
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000025 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1369-1371
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000212 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1369-1369
  assign wb_stb          = (~i_icb_rsp_valid) & i_icb_cmd_valid;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000212 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1369-1369
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000213 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1370-1370
  assign wb_cyc          = (~i_icb_rsp_valid) & i_icb_cmd_valid;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000213 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1370-1370
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000214 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1371-1371
  assign i_icb_cmd_ready = (~i_icb_rsp_valid) & wb_ack;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000214 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1371-1371
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000025 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1369-1371


//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000215 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1374-1374
  assign i_icb_rsp_err = 1'b0;// Wishbone have no error response
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000215 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1374-1374
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000028 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1369-1374
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000022 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1369-1374

endmodule

// ===========================================================================
//
// Description:
//  The module to handle the simple-ICB bus to APB bus conversion 
//
// ===========================================================================

module sirv_gnrl_icb2apb # (
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:port_section:000007 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1386-1412
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:param_decl:000009 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1386-1389
  parameter AW = 32,
  parameter FIFO_OUTS_NUM = 8,
  parameter FIFO_CUT_READY = 0,
  parameter DW = 64 // 64 or 32 bits
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:param_decl:000009 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1386-1389
) (
  input              i_icb_cmd_valid, 
  output             i_icb_cmd_ready, 
  input  [1-1:0]     i_icb_cmd_read, 
  input  [AW-1:0]    i_icb_cmd_addr, 
  input  [DW-1:0]    i_icb_cmd_wdata, 
  input  [DW/8-1:0]  i_icb_cmd_wmask,
  input  [1:0]       i_icb_cmd_size,

  output             i_icb_rsp_valid, 
  input              i_icb_rsp_ready, 
  output             i_icb_rsp_err,
  output [DW-1:0]    i_icb_rsp_rdata, 
  
  output [AW-1:0] apb_paddr,
  output          apb_pwrite,
  output          apb_pselx,
  output          apb_penable,
  output [DW-1:0] apb_pwdata,
  input  [DW-1:0] apb_prdata,

  input  clk,  
  input  rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:port_section:000007 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1386-1412
  );

  // Since the APB reponse channel does not have handhake scheme, but the
  //   ICB have, so the response may not be accepted by the upstream master
  //   So in order to make sure the functionality is correct, we must put
  //   a reponse bypass-buffer here, to always be able to accept response from apb
  //
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000017 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1420-1420
  wire apb_enable_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000017 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1420-1420

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000014 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1422-1437
  sirv_gnrl_fifo # (
   .CUT_READY (1),
   .MSKO      (0),
   .DP(1),
   .DW(DW)
  ) u_rsp_fifo(
    .i_vld(apb_enable_r), 
    .i_rdy(), 
    .i_dat(apb_prdata),
    .o_vld(i_icb_rsp_valid), 
    .o_rdy(i_icb_rsp_ready), 
    .o_dat(i_icb_rsp_rdata),
  
    .clk  (clk  ),
    .rst_n(rst_n)  
   );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000014 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1422-1437

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000216 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1439-1439
  assign i_icb_rsp_err = 1'b0;// Wishbone have no error response
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000216 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1439-1439

    // apb enable will be set if it is now not set and the new icb valid is coming
          // And we only initiate the reqeust when the response buffer is empty, to make
          //   sure when the response back from APB we can alway be able to 
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000018 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1444-1448
  wire apb_enable_set = (~apb_enable_r) & i_icb_cmd_valid & (~i_icb_rsp_valid);
    // apb enable will be clear if it is now already set
  wire apb_enable_clr = apb_enable_r;
  wire apb_enable_ena = apb_enable_set | apb_enable_clr;
  wire apb_enable_nxt = apb_enable_set & (~apb_enable_clr);
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000018 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1444-1448
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000015 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1449-1449
  sirv_gnrl_dfflr #(1) apb_enable_dfflr (apb_enable_ena, apb_enable_nxt, apb_enable_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000015 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1449-1449

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000029 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1451-1457
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000023 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1451-1457
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000217 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1451-1451
  assign i_icb_cmd_ready = apb_enable_r & (~i_icb_rsp_valid);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000217 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1451-1451

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000218 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1453-1453
  assign apb_paddr  = i_icb_cmd_addr;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000218 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1453-1453
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000219 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1454-1454
  assign apb_pwrite = (~i_icb_cmd_read);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000219 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1454-1454
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000220 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1455-1455
  assign apb_pselx  = i_icb_cmd_valid;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000220 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1455-1455
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000221 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1456-1456
  assign apb_penable= apb_enable_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000221 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1456-1456
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000222 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1457-1457
  assign apb_pwdata = i_icb_cmd_wdata;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000222 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1457-1457
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000029 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1451-1457
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000023 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1451-1457

endmodule


// ===========================================================================
//
// Description:
//  The module to handle the simple-ICB bus to AHB-lite bus conversion 
//
// ===========================================================================
module sirv_gnrl_icb2ahbl #(
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:param_decl:000010 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1469-1470
    parameter AW = 32,
    parameter DW = 32 
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:param_decl:000010 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1469-1470
) (
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:port_section:000008 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1472-1508

  input              icb_cmd_valid,
  output             icb_cmd_ready,
  input              icb_cmd_read,
  input  [AW-1:0]    icb_cmd_addr,
  input  [DW-1:0]    icb_cmd_wdata,
  input  [DW/8-1:0]  icb_cmd_wmask,
  input  [1:0]       icb_cmd_size,
  input              icb_cmd_lock,
  input              icb_cmd_excl,
  input  [1:0]       icb_cmd_burst, 
  input  [1:0]       icb_cmd_beat, 

  output             icb_rsp_valid, 
  input              icb_rsp_ready, 
  output             icb_rsp_err,
  output             icb_rsp_excl_ok,
  output [DW-1:0]    icb_rsp_rdata, 

  output [1:0]       ahbl_htrans,   
  output             ahbl_hwrite,   
  output [AW-1:0]    ahbl_haddr,    
  output [2:0]       ahbl_hsize,    
  output             ahbl_hlock,   
  output             ahbl_hexcl,   
  output [2:0]       ahbl_hburst,   
  output [DW-1:0]    ahbl_hwdata,   
  output [3:0]       ahbl_hprot, 
  output [1:0]       ahbl_hattri,
  output [1:0]       ahbl_master,
  input  [DW-1:0]    ahbl_hrdata,   
  input  [1:0]       ahbl_hresp,    
  input              ahbl_hresp_exok,    
  input              ahbl_hready,   
       
  input              clk,          
  input              rst_n         
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:port_section:000008 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1472-1508
  );

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000019 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1511-1511
  wire ahbl_eff_trans = ahbl_hready & ahbl_htrans[1];
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000019 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1511-1511

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000030 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1513-1515
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000024 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1513-1515
//__RB_CUT_GROUP_BEGIN__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000026 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1513-1514
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000223 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1513-1513
  assign icb_cmd_ready  = ahbl_hready;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000223 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1513-1513
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000224 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1514-1514
  assign ahbl_htrans[1] = icb_cmd_valid;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000224 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1514-1514
//__RB_CUT_GROUP_END__ type=handshake id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:handshake:000026 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1513-1514
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000225 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1515-1515
  assign ahbl_htrans[0] = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000225 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1515-1515
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000030 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1513-1515
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000024 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1513-1515

  /////////////////////////////////////////////////////////////
  // FSM to check the AHB state
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:param_decl:000011 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1519-1522
  localparam FSM_W  = 2;
  localparam STA_AR = 2'b00; 
  localparam STA_WD = 2'b01;
  localparam STA_RD = 2'b10;
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:param_decl:000011 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1519-1522

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000020 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1524-1531
  wire[FSM_W-1:0] ahbl_sta_r;
  wire[FSM_W-1:0] ahbl_sta_nxt;

  wire to_wd_sta = ahbl_eff_trans & ahbl_hwrite;
  wire to_rd_sta = ahbl_eff_trans & (~ahbl_hwrite);
  wire to_ar_sta = ahbl_hready    & (~ahbl_htrans[1]);

  wire  ahbl_sta_is_ar = (ahbl_sta_r == STA_AR);
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000020 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1524-1531

  // FSM Next state comb logics
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000226 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1534-1538
  assign ahbl_sta_nxt = ahbl_hready ?  (
                               {FSM_W{to_ar_sta}} & (STA_AR) 
                             | {FSM_W{to_wd_sta}} & (STA_WD)
                             | {FSM_W{to_rd_sta}} & (STA_RD)
                         ) : ahbl_sta_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000226 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1534-1538

  // FSM sequential logics
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000016 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1541-1541
  sirv_gnrl_dffr #(FSM_W) ahbl_sta_dffr (ahbl_sta_nxt, ahbl_sta_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000016 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1541-1541
  
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000021 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1543-1544
  wire [DW-1:0]ahbl_hwdata_r;
  wire ahbl_hwdata_ena = to_wd_sta;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000021 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1543-1544
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000017 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1545-1545
  sirv_gnrl_dfflr #(DW) ahbl_hwdata_dfflr (ahbl_hwdata_ena, icb_cmd_wdata, ahbl_hwdata_r, clk, rst_n);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000017 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1545-1545

  // AHB control signal generation

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000031 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1549-1564
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000025 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1549-1564
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000227 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1549-1549
  assign ahbl_hwrite = ~icb_cmd_read;    
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000227 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1549-1549
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000228 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1550-1550
  assign ahbl_haddr  = icb_cmd_addr;    
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000228 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1550-1550
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000229 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1551-1551
  assign ahbl_hsize  = {1'b0,icb_cmd_size};    
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000229 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1551-1551
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000230 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1552-1552
  assign ahbl_hexcl  = icb_cmd_excl;    
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000230 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1552-1552
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000231 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1553-1553
  assign ahbl_hwdata = ahbl_hwdata_r;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000231 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1553-1553

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000232 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1555-1555
  assign ahbl_hprot  = 4'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000232 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1555-1555
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000233 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1556-1556
  assign ahbl_hattri = 2'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000233 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1556-1556
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000234 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1557-1557
  assign ahbl_hlock  = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000234 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1557-1557
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000235 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1558-1558
  assign ahbl_master = 2'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000235 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1558-1558
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000236 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1559-1559
  assign ahbl_hburst = 3'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000236 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1559-1559

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000237 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1561-1561
  assign icb_rsp_valid     = ahbl_hready & (~ahbl_sta_is_ar);  
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000237 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1561-1561
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000238 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1562-1562
  assign icb_rsp_rdata     = ahbl_hrdata;   
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000238 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1562-1562
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000239 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1563-1563
  assign icb_rsp_err       = ahbl_hresp[0];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000239 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1563-1563
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000240 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1564-1564
  assign icb_rsp_excl_ok   = ahbl_hresp_exok;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000240 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1564-1564
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:assign_cluster:000031 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1549-1564
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:bus_cluster:000025 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1549-1564


endmodule


// ===========================================================================
//
// Description:
//  Verilog module for the AXI bus pipeline stage
//
// ===========================================================================

module sirv_gnrl_axi_buffer
  #(
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:param_decl:000012 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1579-1582
    parameter CHNL_FIFO_DP = 2,
    parameter CHNL_FIFO_CUT_READY = 2,
    parameter AW = 32,
    parameter DW = 32 
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:param_decl:000012 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1579-1582
    )
  (
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:port_section:000009 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1585-1658
  input  i_axi_arvalid,
  output i_axi_arready,
  input  [AW-1:0] i_axi_araddr,
  input  [3:0] i_axi_arcache,
  input  [2:0] i_axi_arprot,
  input  [1:0] i_axi_arlock,
  input  [1:0] i_axi_arburst,
  input  [3:0] i_axi_arlen,
  input  [2:0] i_axi_arsize,

  input  i_axi_awvalid,
  output i_axi_awready,
  input  [AW-1:0] i_axi_awaddr,
  input  [3:0] i_axi_awcache,
  input  [2:0] i_axi_awprot,
  input  [1:0] i_axi_awlock,
  input  [1:0] i_axi_awburst,
  input  [3:0] i_axi_awlen,
  input  [2:0] i_axi_awsize,

  output i_axi_rvalid,
  input  i_axi_rready,
  output [DW-1:0] i_axi_rdata,
  output [1:0] i_axi_rresp,
  output i_axi_rlast,

  input  i_axi_wvalid,
  output i_axi_wready,
  input  [DW-1:0] i_axi_wdata,
  input  [(DW/8)-1:0] i_axi_wstrb,
  input  i_axi_wlast,

  output i_axi_bvalid,
  input  i_axi_bready,
  output [1:0] i_axi_bresp,

  output o_axi_arvalid,
  input  o_axi_arready,
  output [AW-1:0] o_axi_araddr,
  output [3:0] o_axi_arcache,
  output [2:0] o_axi_arprot,
  output [1:0] o_axi_arlock,
  output [1:0] o_axi_arburst,
  output [3:0] o_axi_arlen,
  output [2:0] o_axi_arsize,

  output o_axi_awvalid,
  input  o_axi_awready,
  output [AW-1:0] o_axi_awaddr,
  output [3:0] o_axi_awcache,
  output [2:0] o_axi_awprot,
  output [1:0] o_axi_awlock,
  output [1:0] o_axi_awburst,
  output [3:0] o_axi_awlen,
  output [2:0] o_axi_awsize,

  input  o_axi_rvalid,
  output o_axi_rready,
  input  [DW-1:0] o_axi_rdata,
  input  [1:0] o_axi_rresp,
  input  o_axi_rlast,

  output o_axi_wvalid,
  input  o_axi_wready,
  output [DW-1:0] o_axi_wdata,
  output [(DW/8)-1:0] o_axi_wstrb,
  output o_axi_wlast,

  input  o_axi_bvalid,
  output o_axi_bready,
  input  [1:0] o_axi_bresp,
       
  input  clk,  
  input  rst_n 
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:port_section:000009 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1585-1658
  );


//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:param_decl:000013 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1662-1663
localparam AR_CHNL_W = 4+3+2+4+3+2+AW;
localparam AW_CHNL_W = AR_CHNL_W;
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:param_decl:000013 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1662-1663

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000022 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1665-1665
wire [AR_CHNL_W -1:0] i_axi_ar_chnl = 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000022 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1665-1665
    {
    i_axi_araddr,
    i_axi_arcache,
    i_axi_arprot ,
    i_axi_arlock ,
    i_axi_arburst,
    i_axi_arlen  ,
    i_axi_arsize  
    };

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000023 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1676-1676
wire [AR_CHNL_W -1:0] o_axi_ar_chnl;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000023 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1676-1676
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000241 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1677-1685
assign   {
    o_axi_araddr,
    o_axi_arcache,
    o_axi_arprot ,
    o_axi_arlock ,
    o_axi_arburst,
    o_axi_arlen  ,
    o_axi_arsize   
    } = o_axi_ar_chnl;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000241 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1677-1685

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000018 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1687-1703
sirv_gnrl_fifo #(
    .CUT_READY (CHNL_FIFO_CUT_READY),
    .MSKO      (0),
    .DP  (CHNL_FIFO_DP),
    .DW  (AR_CHNL_W)
) o_axi_ar_fifo (
  .i_rdy    (i_axi_arready),
  .i_vld    (i_axi_arvalid),
  .i_dat    (i_axi_ar_chnl),

  .o_rdy    (o_axi_arready),
  .o_vld    (o_axi_arvalid),
  .o_dat    (o_axi_ar_chnl),

  .clk      (clk  ),
  .rst_n    (rst_n)
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000018 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1687-1703


//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000024 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1706-1706
wire [AW_CHNL_W-1:0] i_axi_aw_chnl = 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000024 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1706-1706
    {
    i_axi_awaddr,
    i_axi_awcache,
    i_axi_awprot ,
    i_axi_awlock ,
    i_axi_awburst,
    i_axi_awlen  ,
    i_axi_awsize  
    };

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000025 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1717-1717
wire [AW_CHNL_W-1:0] o_axi_aw_chnl;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000025 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1717-1717
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000242 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1718-1726
assign   {
    o_axi_awaddr,
    o_axi_awcache,
    o_axi_awprot ,
    o_axi_awlock ,
    o_axi_awburst,
    o_axi_awlen  ,
    o_axi_awsize  
    } = o_axi_aw_chnl;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000242 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1718-1726

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000019 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1728-1744
sirv_gnrl_fifo #(
    .CUT_READY (CHNL_FIFO_CUT_READY),
    .MSKO      (0),
    .DP  (CHNL_FIFO_DP),
    .DW  (AW_CHNL_W)
) o_axi_aw_fifo (
  .i_rdy    (i_axi_awready),
  .i_vld    (i_axi_awvalid),
  .i_dat    (i_axi_aw_chnl ),

  .o_rdy    (o_axi_awready ),
  .o_vld    (o_axi_awvalid ),
  .o_dat    (o_axi_aw_chnl),

  .clk      (clk  ),
  .rst_n    (rst_n)
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000019 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1728-1744


//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:param_decl:000014 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1747-1747
localparam W_CHNL_W = DW+(DW/8)+1;
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:param_decl:000014 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1747-1747
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000026 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1748-1748
wire [W_CHNL_W-1:0] i_axi_w_chnl = {
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000026 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1748-1748
                                                i_axi_wdata,
                                                i_axi_wstrb,
                                                i_axi_wlast
                                                 };
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000027 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1753-1753
wire [W_CHNL_W-1:0] o_axi_w_chnl;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000027 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1753-1753
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000243 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1754-1757
assign { 
         o_axi_wdata,
         o_axi_wstrb,
         o_axi_wlast} = o_axi_w_chnl;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000243 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1754-1757

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000020 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1759-1775
sirv_gnrl_fifo #(
    .CUT_READY (CHNL_FIFO_CUT_READY),
    .MSKO      (0),
    .DP  (CHNL_FIFO_DP),
    .DW  (W_CHNL_W)
) o_axi_wdata_fifo(
  .i_rdy    (i_axi_wready),
  .i_vld    (i_axi_wvalid),
  .i_dat    (i_axi_w_chnl ),

  .o_rdy    (o_axi_wready),
  .o_vld    (o_axi_wvalid),
  .o_dat    (o_axi_w_chnl),

  .clk        (clk  ),
  .rst_n      (rst_n)
);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000020 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1759-1775
//


//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:param_decl:000015 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1779-1779
localparam R_CHNL_W = DW+2+1;
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:param_decl:000015 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1779-1779
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000028 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1780-1780
wire [R_CHNL_W-1:0] o_axi_r_chnl = {
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000028 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1780-1780
                                                o_axi_rdata,
                                                o_axi_rresp,
                                                o_axi_rlast 
                                                 };
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000029 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1785-1785
wire [R_CHNL_W-1:0] i_axi_r_chnl;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000029 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1785-1785
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000244 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1786-1789
assign {
        i_axi_rdata,
        i_axi_rresp,
        i_axi_rlast} = i_axi_r_chnl;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000244 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1786-1789

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000021 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1791-1807
sirv_gnrl_fifo # (
    .CUT_READY (CHNL_FIFO_CUT_READY),
    .MSKO      (0),
    .DP  (CHNL_FIFO_DP),
    .DW  (R_CHNL_W)
) o_axi_rdata_fifo(
  .i_rdy    (o_axi_rready),
  .i_vld    (o_axi_rvalid),
  .i_dat    (o_axi_r_chnl ),


  .o_rdy    (i_axi_rready),
  .o_vld    (i_axi_rvalid),
  .o_dat    (i_axi_r_chnl),
  .clk      (clk  ),
  .rst_n    (rst_n)
);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000021 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1791-1807
//


//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:param_decl:000016 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1811-1811
localparam B_CHNL_W = 2;
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:param_decl:000016 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1811-1811

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000030 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1813-1813
wire [B_CHNL_W -1:0] o_axi_b_chnl = {
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000030 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1813-1813
           o_axi_bresp
           };

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000031 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1817-1817
wire [B_CHNL_W -1:0] i_axi_b_chnl;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_gnrl_icbs.v:grp:internal_signal:000031 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1817-1817
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000245 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1818-1820
assign {
           i_axi_bresp
           } = i_axi_b_chnl;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_gnrl_icbs.v:assign:000245 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1818-1820

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000022 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1822-1838
sirv_gnrl_fifo #(
    .CUT_READY (CHNL_FIFO_CUT_READY),
    .MSKO      (0),
    .DP  (CHNL_FIFO_DP),
    .DW  (B_CHNL_W)
) o_axi_bresp_fifo (
  .i_rdy    (o_axi_bready     ),
  .i_vld    (o_axi_bvalid     ),
  .i_dat    (o_axi_b_chnl),

  .o_rdy    (i_axi_bready),
  .o_vld    (i_axi_bvalid),
  .o_dat    (i_axi_b_chnl),

  .clk       (clk  ),
  .rst_n     (rst_n)
  );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_gnrl_icbs.v:inst:000022 file=e203_hbirdv2/general/sirv_gnrl_icbs.v lines=1822-1838



endmodule 

