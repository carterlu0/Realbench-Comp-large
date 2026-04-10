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
//  The Reset Ctrl module to implement reset control
//
// ====================================================================

`include "e203_defines.v"

module e203_reset_ctrl #(
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:grp:param_decl:000001 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=30-30
    parameter MASTER = 1
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:grp:param_decl:000001 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=30-30
)(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:grp:port_section:000001 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=32-50
  input  clk,        // clock
  input  rst_n,      // async reset
  input  test_mode,  // test mode 

  
  // The core's clk and rst
  output rst_core,

  // The ITCM/DTCM clk and rst
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:pp_blk:000001 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=41-43
  `ifdef E203_HAS_ITCM
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:pp_blk:000001 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=41-43
  output rst_itcm,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:pp_blk:000001 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=41-43
  `endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:pp_blk:000001 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=41-43
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:pp_blk:000002 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=44-46
  `ifdef E203_HAS_DTCM
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:pp_blk:000002 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=44-46
  output rst_dtcm,
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:pp_blk:000002 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=44-46
  `endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:pp_blk:000002 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=44-46

  // The Top always on clk and rst
  output rst_aon 

//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:grp:port_section:000001 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=32-50
);

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=53-56
wire rst_sync_n;


//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:pp_blk:000003 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=56-58
      `ifndef E203_HAS_LOCKSTEP//{
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=53-56
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:grp:param_decl:000002 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=57-58
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:pp_blk:000003 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=56-58
localparam RST_SYNC_LEVEL = `E203_ASYNC_FF_LEVELS;
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:pp_blk:000003 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=56-58
      `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:pp_blk:000003 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=56-58
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:grp:param_decl:000002 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=57-58

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=60-60
reg [RST_SYNC_LEVEL-1:0] rst_sync_r; 
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=60-60


//__RB_CUT_BEGIN__ type=generate id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:generate:000001 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=63-91
generate 
//__RB_CUT_BODY__ type=generate id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:generate:000001 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=63-91
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:begin_end:000004 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=64-82
  if(MASTER == 1) begin:master_gen
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:begin_end:000004 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=64-82

     
//__RB_CUT_BEGIN__ type=always id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:proc:000001 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=67-77
     always @(posedge clk or negedge rst_n)
//__RB_CUT_BODY__ type=always id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:proc:000001 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=67-77
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:begin_end:000003 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=68-77
     begin:rst_sync_PROC
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:begin_end:000003 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=68-77
       if(rst_n == 1'b0)
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:begin_end:000001 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=70-72
         begin
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:begin_end:000001 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=70-72
           rst_sync_r[RST_SYNC_LEVEL-1:0] <= {RST_SYNC_LEVEL{1'b0}};
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:begin_end:000001 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=70-72
         end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:begin_end:000001 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=70-72
       else
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:begin_end:000002 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=74-76
         begin
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:begin_end:000002 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=74-76
           rst_sync_r[RST_SYNC_LEVEL-1:0] <= {rst_sync_r[RST_SYNC_LEVEL-2:0],1'b1};
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:begin_end:000002 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=74-76
         end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:begin_end:000002 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=74-76
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:begin_end:000003 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=68-77
     end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:begin_end:000003 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=68-77
//__RB_CUT_TAIL__ type=always id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:proc:000001 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=67-77
//__RB_CUT_END__ type=always id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:proc:000001 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=67-77
     
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:assign:000001 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=79-79
     assign rst_sync_n     = test_mode ? rst_n : rst_sync_r[`E203_ASYNC_FF_LEVELS-1];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:assign:000001 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=79-79
     

//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:begin_end:000004 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=64-82
  end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:begin_end:000004 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=64-82
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:begin_end:000006 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=83-90
  else begin:slave_gen
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:begin_end:000006 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=83-90
         // Just pass through for slave in lockstep mode
//__RB_CUT_BEGIN__ type=always id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:proc:000002 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=85-88
     always @ * 
//__RB_CUT_BODY__ type=always id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:proc:000002 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=85-88
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:begin_end:000005 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=86-88
     begin:rst_sync_PROC
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:begin_end:000005 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=86-88
       rst_sync_r = {RST_SYNC_LEVEL{1'b0}}; 
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:begin_end:000005 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=86-88
     end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:begin_end:000005 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=86-88
//__RB_CUT_TAIL__ type=always id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:proc:000002 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=85-88
//__RB_CUT_END__ type=always id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:proc:000002 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=85-88
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:assign:000002 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=89-89
     assign rst_sync_n = rst_n;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:assign:000002 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=89-89
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:begin_end:000006 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=83-90
  end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:begin_end:000006 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=83-90
//__RB_CUT_TAIL__ type=generate id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:generate:000001 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=63-91
endgenerate
//__RB_CUT_END__ type=generate id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:generate:000001 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=63-91

   // The core's clk and rst
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:assign:000003 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=94-94
 assign rst_core = rst_sync_n;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:assign:000003 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=94-94
 
   // The ITCM/DTCM clk and rst
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:pp_blk:000004 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=97-99
   `ifdef E203_HAS_ITCM
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:pp_blk:000004 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=97-99
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:assign:000004 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=98-98
 assign rst_itcm = rst_sync_n;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:assign:000004 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=98-98
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:pp_blk:000004 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=97-99
   `endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:pp_blk:000004 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=97-99
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:pp_blk:000005 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=100-102
   `ifdef E203_HAS_DTCM
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:pp_blk:000005 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=100-102
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:assign:000005 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=101-101
 assign rst_dtcm = rst_sync_n;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:assign:000005 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=101-101
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:pp_blk:000005 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=100-102
   `endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:pp_blk:000005 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=100-102
 
   // The Top always on clk and rst
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:assign:000006 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=105-105
 assign rst_aon = rst_sync_n;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v:assign:000006 file=e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v lines=105-105

endmodule

