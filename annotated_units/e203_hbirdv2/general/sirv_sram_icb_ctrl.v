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
//  The icb_ecc_ctrl module control the ICB access requests to SRAM 
//
// ====================================================================


module sirv_sram_icb_ctrl #(
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_sram_icb_ctrl.v:grp:param_decl:000001 file=e203_hbirdv2/general/sirv_sram_icb_ctrl.v lines=30-34
    parameter DW = 32,// Can only support 32 or 64bits, no others supported
    parameter MW = 4,
    parameter AW = 32,
    parameter AW_LSB = 3,
    parameter USR_W = 3 
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_sram_icb_ctrl.v:grp:param_decl:000001 file=e203_hbirdv2/general/sirv_sram_icb_ctrl.v lines=30-34
)(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/general/sirv_sram_icb_ctrl.v:grp:port_section:000001 file=e203_hbirdv2/general/sirv_sram_icb_ctrl.v lines=36-69
  output sram_ctrl_active,
  // The cgstop is coming from CSR (0xBFE mcgstop)'s filed 1
  // // This register is our self-defined CSR register to disable the 
      // ITCM SRAM clock gating for debugging purpose
  input  tcm_cgstop,
  
  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  //    * Cmd channel
  input  i_icb_cmd_valid, // Handshake valid
  output i_icb_cmd_ready, // Handshake ready
  input  i_icb_cmd_read,  // Read or write
  input  [AW-1:0] i_icb_cmd_addr, 
  input  [DW-1:0] i_icb_cmd_wdata, 
  input  [MW-1:0] i_icb_cmd_wmask, 
  input  [USR_W-1:0] i_icb_cmd_usr, 

  //    * RSP channel
  output i_icb_rsp_valid, // Response valid 
  input  i_icb_rsp_ready, // Response ready
  output [DW-1:0] i_icb_rsp_rdata, 
  output [USR_W-1:0] i_icb_rsp_usr, 

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
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/general/sirv_sram_icb_ctrl.v:grp:port_section:000001 file=e203_hbirdv2/general/sirv_sram_icb_ctrl.v lines=36-69
  );

    // We need to use bypbuf to flop one stage for the i_cmd channel to cut 
    //   down the back-pressure ready signal 
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_sram_icb_ctrl.v:grp:internal_signal:000001 file=e203_hbirdv2/general/sirv_sram_icb_ctrl.v lines=74-80
  wire  byp_icb_cmd_valid;
  wire  byp_icb_cmd_ready;
  wire  byp_icb_cmd_read;
  wire  [AW-1:0] byp_icb_cmd_addr; 
  wire  [DW-1:0] byp_icb_cmd_wdata; 
  wire  [MW-1:0] byp_icb_cmd_wmask; 
  wire  [USR_W-1:0] byp_icb_cmd_usr; 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_sram_icb_ctrl.v:grp:internal_signal:000001 file=e203_hbirdv2/general/sirv_sram_icb_ctrl.v lines=74-80

//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_sram_icb_ctrl.v:grp:param_decl:000002 file=e203_hbirdv2/general/sirv_sram_icb_ctrl.v lines=82-82
  localparam BUF_CMD_PACK_W = (AW+DW+MW+USR_W+1);
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_sram_icb_ctrl.v:grp:param_decl:000002 file=e203_hbirdv2/general/sirv_sram_icb_ctrl.v lines=82-82
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_sram_icb_ctrl.v:grp:internal_signal:000002 file=e203_hbirdv2/general/sirv_sram_icb_ctrl.v lines=83-84
  wire [BUF_CMD_PACK_W-1:0] byp_icb_cmd_o_pack;
  wire [BUF_CMD_PACK_W-1:0] byp_icb_cmd_i_pack =  {
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_sram_icb_ctrl.v:grp:internal_signal:000002 file=e203_hbirdv2/general/sirv_sram_icb_ctrl.v lines=83-84
                      i_icb_cmd_read, 
                      i_icb_cmd_addr, 
                      i_icb_cmd_wdata, 
                      i_icb_cmd_wmask, 
                      i_icb_cmd_usr  
                    };
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_sram_icb_ctrl.v:assign:000001 file=e203_hbirdv2/general/sirv_sram_icb_ctrl.v lines=91-97
  assign {
                      byp_icb_cmd_read, 
                      byp_icb_cmd_addr, 
                      byp_icb_cmd_wdata, 
                      byp_icb_cmd_wmask, 
                      byp_icb_cmd_usr  
                    } = byp_icb_cmd_o_pack;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_sram_icb_ctrl.v:assign:000001 file=e203_hbirdv2/general/sirv_sram_icb_ctrl.v lines=91-97

     
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_sram_icb_ctrl.v:inst:000001 file=e203_hbirdv2/general/sirv_sram_icb_ctrl.v lines=100-113
  sirv_gnrl_bypbuf # (
   .DP(1),// We really use bypbuf here
   .DW(BUF_CMD_PACK_W)
  ) u_byp_icb_cmd_buf(
    .i_vld(i_icb_cmd_valid), 
    .i_rdy(i_icb_cmd_ready), 
    .i_dat(byp_icb_cmd_i_pack),
    .o_vld(byp_icb_cmd_valid), 
    .o_rdy(byp_icb_cmd_ready), 
    .o_dat(byp_icb_cmd_o_pack),
  
    .clk  (clk  ),
    .rst_n(rst_n)  
   );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_sram_icb_ctrl.v:inst:000001 file=e203_hbirdv2/general/sirv_sram_icb_ctrl.v lines=100-113


  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // Instantiated the SRAM Ctrl
  //
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_sram_icb_ctrl.v:grp:internal_signal:000003 file=e203_hbirdv2/general/sirv_sram_icb_ctrl.v lines=120-120
  wire sram_active;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_sram_icb_ctrl.v:grp:internal_signal:000003 file=e203_hbirdv2/general/sirv_sram_icb_ctrl.v lines=120-120

//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/general/sirv_sram_icb_ctrl.v:inst:000002 file=e203_hbirdv2/general/sirv_sram_icb_ctrl.v lines=122-156
  sirv_1cyc_sram_ctrl #(
      .DW     (DW),
      .AW     (AW),
      .MW     (MW),
      .AW_LSB (AW_LSB),
      .USR_W  (USR_W) 
  ) u_sirv_1cyc_sram_ctrl(
     .sram_ctrl_active (sram_active),
     .tcm_cgstop       (tcm_cgstop),
     
     .uop_cmd_valid (byp_icb_cmd_valid),
     .uop_cmd_ready (byp_icb_cmd_ready),
     .uop_cmd_read  (byp_icb_cmd_read ),
     .uop_cmd_addr  (byp_icb_cmd_addr ), 
     .uop_cmd_wdata (byp_icb_cmd_wdata), 
     .uop_cmd_wmask (byp_icb_cmd_wmask), 
     .uop_cmd_usr   (byp_icb_cmd_usr  ),
  
     .uop_rsp_valid (i_icb_rsp_valid),
     .uop_rsp_ready (i_icb_rsp_ready),
     .uop_rsp_rdata (i_icb_rsp_rdata),
     .uop_rsp_usr   (i_icb_rsp_usr  ),
  
     .ram_cs   (ram_cs  ),  
     .ram_we   (ram_we  ),  
     .ram_addr (ram_addr), 
     .ram_wem  (ram_wem ),
     .ram_din  (ram_din ),          
     .ram_dout (ram_dout),
     .clk_ram  (clk_ram ),
  
     .test_mode(test_mode  ),
     .clk  (clk  ),
     .rst_n(rst_n)  
    );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/general/sirv_sram_icb_ctrl.v:inst:000002 file=e203_hbirdv2/general/sirv_sram_icb_ctrl.v lines=122-156


//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_sram_icb_ctrl.v:assign:000002 file=e203_hbirdv2/general/sirv_sram_icb_ctrl.v lines=159-164
  assign sram_ctrl_active = 
                       i_icb_cmd_valid // Input command
                     | byp_icb_cmd_valid // Byp input command
                     | sram_active  // SRAM active
                     | i_icb_rsp_valid // Output Response
                     ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_sram_icb_ctrl.v:assign:000002 file=e203_hbirdv2/general/sirv_sram_icb_ctrl.v lines=159-164

endmodule

