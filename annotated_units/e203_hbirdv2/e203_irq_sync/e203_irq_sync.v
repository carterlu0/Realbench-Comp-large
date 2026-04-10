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
//  The IRQ and Event Sync module
//
// ====================================================================

`include "e203_defines.v"

module e203_irq_sync #(
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:grp:param_decl:000001 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=30-30
  parameter MASTER = 1 
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:grp:param_decl:000001 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=30-30
) (
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:grp:port_section:000001 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=32-43
  input  clk,    
  input  rst_n,   

  input  ext_irq_a,
  input  sft_irq_a,
  input  tmr_irq_a,
  input  dbg_irq_a,

  output ext_irq_r,
  output sft_irq_r,
  output tmr_irq_r,
  output dbg_irq_r 
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:grp:port_section:000001 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=32-43
);
//__RB_CUT_BEGIN__ type=generate id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:generate:000001 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=45-107
generate 
//__RB_CUT_BODY__ type=generate id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:generate:000001 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=45-107
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:begin_end:000001 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=46-98
  if(MASTER == 1) begin:master_gen
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:begin_end:000001 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=46-98
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:pp_blk:000002 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=47-95
      `ifndef E203_HAS_LOCKSTEP//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:pp_blk:000002 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=47-95
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:pp_blk:000001 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=48-94
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:pp_blk:000001:br:000001 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=48-88
      `ifdef E203_IRQ_NEED_SYNC//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:pp_blk:000001 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=48-94
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:pp_blk:000001:br:000001 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=48-88
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:inst:000001 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=49-57
      sirv_gnrl_sync # (
        .DP(`E203_ASYNC_FF_LEVELS),
        .DW(1)
      ) u_dbg_irq_sync(
          .din_a    (dbg_irq_a),
          .dout     (dbg_irq_r),
          .clk      (clk  ),
          .rst_n    (rst_n) 
      );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:inst:000001 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=49-57
      
      
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:inst:000002 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=60-68
      sirv_gnrl_sync # (
        .DP(`E203_ASYNC_FF_LEVELS),
        .DW(1)
      ) u_ext_irq_sync(
          .din_a    (ext_irq_a),
          .dout     (ext_irq_r),
          .clk      (clk  ),
          .rst_n    (rst_n) 
      );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:inst:000002 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=60-68
      
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:inst:000003 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=70-78
      sirv_gnrl_sync # (
        .DP(`E203_ASYNC_FF_LEVELS),
        .DW(1)
      ) u_sft_irq_sync(
          .din_a    (sft_irq_a),
          .dout     (sft_irq_r),
          .clk      (clk  ),
          .rst_n    (rst_n) 
      );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:inst:000003 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=70-78
      
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:inst:000004 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=80-88
      sirv_gnrl_sync # (
        .DP(`E203_ASYNC_FF_LEVELS),
        .DW(1)
      ) u_tmr_irq_sync(
          .din_a    (tmr_irq_a),
          .dout     (tmr_irq_r),
          .clk      (clk  ),
          .rst_n    (rst_n) 
      );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:inst:000004 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=80-88
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:pp_blk:000001:br:000001 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=48-88
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:pp_blk:000001:br:000001 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=48-88
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:pp_blk:000001:br:000002 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=89-93
      `else//}{
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=90-93
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:pp_blk:000001:br:000002 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=89-93
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:assign:000001 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=90-90
        assign ext_irq_r = ext_irq_a;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:assign:000001 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=90-90
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:assign:000002 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=91-91
        assign sft_irq_r = sft_irq_a;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:assign:000002 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=91-91
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:assign:000003 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=92-92
        assign tmr_irq_r = tmr_irq_a;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:assign:000003 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=92-92
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:assign:000004 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=93-93
        assign dbg_irq_r = dbg_irq_a;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:assign:000004 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=93-93
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:pp_blk:000001:br:000002 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=89-93
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:pp_blk:000001:br:000002 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=89-93
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=90-93
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:pp_blk:000001 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=48-94
      `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:pp_blk:000001 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=48-94
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:pp_blk:000002 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=47-95
      `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:pp_blk:000002 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=47-95
      
      
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:begin_end:000001 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=46-98
  end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:begin_end:000001 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=46-98
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:begin_end:000002 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=99-106
  else begin:slave_gen
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:begin_end:000002 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=99-106
         // Just pass through for slave in lockstep mode
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=101-104
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:assign:000005 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=101-101
     assign ext_irq_r = ext_irq_a;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:assign:000005 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=101-101
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:assign:000006 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=102-102
     assign sft_irq_r = sft_irq_a;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:assign:000006 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=102-102
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:assign:000007 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=103-103
     assign tmr_irq_r = tmr_irq_a;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:assign:000007 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=103-103
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:assign:000008 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=104-104
     assign dbg_irq_r = dbg_irq_a;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:assign:000008 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=104-104
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=101-104
   
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:begin_end:000002 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=99-106
  end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:begin_end:000002 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=99-106
//__RB_CUT_TAIL__ type=generate id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:generate:000001 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=45-107
endgenerate
//__RB_CUT_END__ type=generate id=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v:generate:000001 file=e203_hbirdv2/e203_irq_sync/e203_irq_sync.v lines=45-107


endmodule

