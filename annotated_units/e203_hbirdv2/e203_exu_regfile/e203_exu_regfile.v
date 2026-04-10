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
//  The Regfile module to implement the core's general purpose registers file
//
// ====================================================================
`include "e203_defines.v"

module e203_exu_regfile(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=29-42
  input  [`E203_RFIDX_WIDTH-1:0] read_src1_idx,
  input  [`E203_RFIDX_WIDTH-1:0] read_src2_idx,
  output [`E203_XLEN-1:0] read_src1_dat,
  output [`E203_XLEN-1:0] read_src2_dat,

  input  wbck_dest_wen,
  input  [`E203_RFIDX_WIDTH-1:0] wbck_dest_idx,
  input  [`E203_XLEN-1:0] wbck_dest_dat,

  output [`E203_XLEN-1:0] x1_r,

  input  test_mode,
  input  clk,
  input  rst_n
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:grp:port_section:000001 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=29-42
  );

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=45-50
  wire [`E203_XLEN-1:0] rf_r [`E203_RFREG_NUM-1:0];// rf_r 和 x1_r 的r的含义
  wire [`E203_RFREG_NUM-1:0] rf_wen;
  
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=48-53
  `ifdef E203_REGFILE_LATCH_BASED //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=48-53
  // Use DFF to buffer the write-port
  wire [`E203_XLEN-1:0] wbck_dest_dat_r;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:grp:internal_signal:000001 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=45-50
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:inst:000001 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=51-51
  sirv_gnrl_dffl #(`E203_XLEN) wbck_dat_dffl (wbck_dest_wen, wbck_dest_dat, wbck_dest_dat_r, clk);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:inst:000001 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=51-51
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=52-53
  wire [`E203_RFREG_NUM-1:0] clk_rf_ltch;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=48-53
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:pp_blk:000001 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=48-53
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:grp:internal_signal:000002 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=52-53

  
  genvar i;
//__RB_CUT_BEGIN__ type=generate id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:generate:000001 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=57-86
  generate //{
//__RB_CUT_BODY__ type=generate id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:generate:000001 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=57-86
  
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:begin_end:000003 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=59-85
      for (i=0; i<`E203_RFREG_NUM; i=i+1) begin:regfile//{
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:begin_end:000003 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=59-85
  
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:begin_end:000001 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=61-68
        if(i==0) begin: rf0
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:begin_end:000001 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=61-68
            // x0 cannot be wrote since it is constant-zeros
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=63-64
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:assign:000001 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=63-63
            assign rf_wen[i] = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:assign:000001 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=63-63
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:assign:000002 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=64-64
            assign rf_r[i] = `E203_XLEN'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:assign:000002 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=64-64
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:grp:assign_cluster:000001 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=63-64
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=65-67
          `ifdef E203_REGFILE_LATCH_BASED //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=65-67
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:assign:000003 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=66-66
            assign clk_rf_ltch[i] = 1'b0;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:assign:000003 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=66-66
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=65-67
          `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:pp_blk:000002 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=65-67
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:begin_end:000001 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=61-68
        end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:begin_end:000001 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=61-68
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:begin_end:000002 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=69-83
        else begin: rfno0
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:begin_end:000002 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=69-83
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:assign:000004 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=70-70
            assign rf_wen[i] = wbck_dest_wen & (wbck_dest_idx == i) ;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:assign:000004 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=70-70
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=71-82
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:pp_blk:000003:br:000001 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=71-79
          `ifdef E203_REGFILE_LATCH_BASED //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=71-82
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:pp_blk:000003:br:000001 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=71-79
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:inst:000002 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=72-77
            e203_clkgate u_e203_clkgate(
              .clk_in  (clk  ),
              .test_mode(test_mode),
              .clock_en(rf_wen[i]),
              .clk_out (clk_rf_ltch[i])
            );
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:inst:000002 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=72-77
                //from write-enable to clk_rf_ltch to rf_ltch
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:inst:000003 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=79-79
            sirv_gnrl_ltch #(`E203_XLEN) rf_ltch (clk_rf_ltch[i], wbck_dest_dat_r, rf_r[i]);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:inst:000003 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=79-79
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:pp_blk:000003:br:000001 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=71-79
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:pp_blk:000003:br:000001 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=71-79
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:pp_blk:000003:br:000002 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=80-81
          `else//}{
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:pp_blk:000003:br:000002 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=80-81
//__RB_CUT_BEGIN__ type=instantiation id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:inst:000004 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=81-81
            sirv_gnrl_dffl #(`E203_XLEN) rf_dffl (rf_wen[i], wbck_dest_dat, rf_r[i], clk);
//__RB_CUT_END__ type=instantiation id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:inst:000004 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=81-81
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:pp_blk:000003:br:000002 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=80-81
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:pp_blk:000003:br:000002 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=80-81
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=71-82
          `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:pp_blk:000003 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=71-82
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:begin_end:000002 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=69-83
        end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:begin_end:000002 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=69-83
  
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:begin_end:000003 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=59-85
      end//}
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:begin_end:000003 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=59-85
//__RB_CUT_TAIL__ type=generate id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:generate:000001 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=57-86
  endgenerate//}
//__RB_CUT_END__ type=generate id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:generate:000001 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=57-86
  
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=88-91
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:assign:000005 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=88-88
  assign read_src1_dat = rf_r[read_src1_idx];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:assign:000005 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=88-88
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:assign:000006 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=89-89
  assign read_src2_dat = rf_r[read_src2_idx];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:assign:000006 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=89-89

//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:assign:000007 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=91-91
  assign x1_r = rf_r[1];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:assign:000007 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=91-91
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v:grp:assign_cluster:000002 file=e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v lines=88-91
      
endmodule

