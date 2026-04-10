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
//  The 1cyc_sram_ctrl module control the 1 Cycle SRAM access requests 
//
// ====================================================================


module sirv_1cyc_sram_ctrl #(
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v:grp:param_decl:000001 file=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v lines=30-34
    parameter DW = 32,
    parameter MW = 4,
    parameter AW = 32,
    parameter AW_LSB = 3,
    parameter USR_W = 3 
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v:grp:param_decl:000001 file=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v lines=30-34
)(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v:grp:port_section:000001 file=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v lines=36-69
  output sram_ctrl_active,
  // The cgstop is coming from CSR (0xBFE mcgstop)'s filed 1
  // // This register is our self-defined CSR register to disable the 
      // ITCM SRAM clock gating for debugging purpose
  input  tcm_cgstop,
  
  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  //    * Cmd channel
  input  uop_cmd_valid, // Handshake valid
  output uop_cmd_ready, // Handshake ready
  input  uop_cmd_read,  // Read or write
  input  [AW-1:0] uop_cmd_addr, 
  input  [DW-1:0] uop_cmd_wdata, 
  input  [MW-1:0] uop_cmd_wmask, 
  input  [USR_W-1:0] uop_cmd_usr, 

  //    * RSP channel
  output uop_rsp_valid, // Response valid 
  input  uop_rsp_ready, // Response ready
  output [DW-1:0] uop_rsp_rdata, 
  output [USR_W-1:0] uop_rsp_usr, 

  output          ram_cs,  
  output          ram_we,  
  output [AW-AW_LSB-1:0] ram_addr, 
  output [MW-1:0] ram_wem,
  output [DW-1:0] ram_din,          
  input  [DW-1:0] ram_dout,
  output          clk_ram,

  input  test_mode,
  input  clk,
  input  rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v:grp:port_section:000001 file=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v lines=36-69
  );


//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v:inst:000001 file=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v lines=73-87
  sirv_gnrl_pipe_stage # (
   .CUT_READY(0),
   .DP(1),
   .DW(USR_W)
  ) u_e1_stage (
    .i_vld(uop_cmd_valid), 
    .i_rdy(uop_cmd_ready), 
    .i_dat(uop_cmd_usr),
    .o_vld(uop_rsp_valid), 
    .o_rdy(uop_rsp_ready), 
    .o_dat(uop_rsp_usr),
  
    .clk  (clk  ),
    .rst_n(rst_n)  
   );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v:inst:000001 file=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v lines=73-87

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v:grp:assign_cluster:000001 file=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v lines=89-93
//__RB_CUT_GROUP_BEGIN__ type=bus_cluster id=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v:grp:bus_cluster:000001 file=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v lines=89-93
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v:assign:000001 file=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v lines=89-89
   assign ram_cs = uop_cmd_valid & uop_cmd_ready;  
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v:assign:000001 file=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v lines=89-89
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v:assign:000002 file=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v lines=90-90
   assign ram_we = (~uop_cmd_read);  
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v:assign:000002 file=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v lines=90-90
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v:assign:000003 file=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v lines=91-91
   assign ram_addr= uop_cmd_addr [AW-1:AW_LSB];          
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v:assign:000003 file=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v lines=91-91
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v:assign:000004 file=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v lines=92-92
   assign ram_wem = uop_cmd_wmask[MW-1:0];          
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v:assign:000004 file=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v lines=92-92
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v:assign:000005 file=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v lines=93-93
   assign ram_din = uop_cmd_wdata[DW-1:0];          
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v:assign:000005 file=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v lines=93-93
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v:grp:assign_cluster:000001 file=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v lines=89-93
//__RB_CUT_GROUP_END__ type=bus_cluster id=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v:grp:bus_cluster:000001 file=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v lines=89-93

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v:grp:internal_signal:000001 file=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v lines=95-95
   wire ram_clk_en = ram_cs | tcm_cgstop;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v:grp:internal_signal:000001 file=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v lines=95-95

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v:inst:000002 file=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v lines=97-102
   e203_clkgate u_ram_clkgate(
     .clk_in   (clk        ),
     .test_mode(test_mode  ),
     .clock_en (ram_clk_en),
     .clk_out  (clk_ram)
   );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v:inst:000002 file=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v lines=97-102

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v:grp:assign_cluster:000002 file=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v lines=104-106
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v:assign:000006 file=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v lines=104-104
   assign uop_rsp_rdata = ram_dout;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v:assign:000006 file=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v lines=104-104

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v:assign:000007 file=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v lines=106-106
   assign sram_ctrl_active = uop_cmd_valid | uop_rsp_valid;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v:assign:000007 file=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v lines=106-106
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v:grp:assign_cluster:000002 file=e203_hbirdv2/general/sirv_1cyc_sram_ctrl.v lines=104-106

endmodule

