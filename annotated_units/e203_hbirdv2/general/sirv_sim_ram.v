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
//  The simulation model of SRAM
//
// ====================================================================
module sirv_sim_ram 
#(parameter DP = 512,
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=e203_hbirdv2/general/sirv_sim_ram.v:grp:param_decl:000001 file=e203_hbirdv2/general/sirv_sim_ram.v lines=29-32
  parameter FORCE_X2ZERO = 0,
  parameter DW = 32,
  parameter MW = 4,
  parameter AW = 32 
//__RB_CUT_GROUP_END__ type=param_decl id=e203_hbirdv2/general/sirv_sim_ram.v:grp:param_decl:000001 file=e203_hbirdv2/general/sirv_sim_ram.v lines=29-32
)
(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=e203_hbirdv2/general/sirv_sim_ram.v:grp:port_section:000001 file=e203_hbirdv2/general/sirv_sim_ram.v lines=35-41
  input             clk, 
  input  [DW-1  :0] din, 
  input  [AW-1  :0] addr,
  input             cs,
  input             we,
  input  [MW-1:0]   wem,
  output [DW-1:0]   dout
//__RB_CUT_GROUP_END__ type=port_section id=e203_hbirdv2/general/sirv_sim_ram.v:grp:port_section:000001 file=e203_hbirdv2/general/sirv_sim_ram.v lines=35-41
);

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_sim_ram.v:grp:internal_signal:000001 file=e203_hbirdv2/general/sirv_sim_ram.v lines=44-47
    reg [DW-1:0] mem_r [0:DP-1];
    reg [AW-1:0] addr_r;
    wire [MW-1:0] wen;
    wire ren;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_sim_ram.v:grp:internal_signal:000001 file=e203_hbirdv2/general/sirv_sim_ram.v lines=44-47

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=e203_hbirdv2/general/sirv_sim_ram.v:grp:assign_cluster:000001 file=e203_hbirdv2/general/sirv_sim_ram.v lines=49-50
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_sim_ram.v:assign:000001 file=e203_hbirdv2/general/sirv_sim_ram.v lines=49-49
    assign ren = cs & (~we);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_sim_ram.v:assign:000001 file=e203_hbirdv2/general/sirv_sim_ram.v lines=49-49
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_sim_ram.v:assign:000002 file=e203_hbirdv2/general/sirv_sim_ram.v lines=50-50
    assign wen = ({MW{cs & we}} & wem);
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_sim_ram.v:assign:000002 file=e203_hbirdv2/general/sirv_sim_ram.v lines=50-50
//__RB_CUT_GROUP_END__ type=assign_cluster id=e203_hbirdv2/general/sirv_sim_ram.v:grp:assign_cluster:000001 file=e203_hbirdv2/general/sirv_sim_ram.v lines=49-50



    genvar i;

//__RB_CUT_BEGIN__ type=always id=e203_hbirdv2/general/sirv_sim_ram.v:proc:000001 file=e203_hbirdv2/general/sirv_sim_ram.v lines=56-61
    always @(posedge clk)
//__RB_CUT_BODY__ type=always id=e203_hbirdv2/general/sirv_sim_ram.v:proc:000001 file=e203_hbirdv2/general/sirv_sim_ram.v lines=56-61
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000002 file=e203_hbirdv2/general/sirv_sim_ram.v lines=57-61
    begin
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000002 file=e203_hbirdv2/general/sirv_sim_ram.v lines=57-61
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000001 file=e203_hbirdv2/general/sirv_sim_ram.v lines=58-60
        if (ren) begin
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000001 file=e203_hbirdv2/general/sirv_sim_ram.v lines=58-60
            addr_r <= addr;
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000001 file=e203_hbirdv2/general/sirv_sim_ram.v lines=58-60
        end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000001 file=e203_hbirdv2/general/sirv_sim_ram.v lines=58-60
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000002 file=e203_hbirdv2/general/sirv_sim_ram.v lines=57-61
    end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000002 file=e203_hbirdv2/general/sirv_sim_ram.v lines=57-61
//__RB_CUT_TAIL__ type=always id=e203_hbirdv2/general/sirv_sim_ram.v:proc:000001 file=e203_hbirdv2/general/sirv_sim_ram.v lines=56-61
//__RB_CUT_END__ type=always id=e203_hbirdv2/general/sirv_sim_ram.v:proc:000001 file=e203_hbirdv2/general/sirv_sim_ram.v lines=56-61

//__RB_CUT_BEGIN__ type=generate id=e203_hbirdv2/general/sirv_sim_ram.v:generate:000001 file=e203_hbirdv2/general/sirv_sim_ram.v lines=63-80
    generate
//__RB_CUT_BODY__ type=generate id=e203_hbirdv2/general/sirv_sim_ram.v:generate:000001 file=e203_hbirdv2/general/sirv_sim_ram.v lines=63-80
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000009 file=e203_hbirdv2/general/sirv_sim_ram.v lines=64-79
      for (i = 0; i < MW; i = i+1) begin :mem
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000009 file=e203_hbirdv2/general/sirv_sim_ram.v lines=64-79
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000005 file=e203_hbirdv2/general/sirv_sim_ram.v lines=65-71
        if((8*i+8) > DW ) begin: last
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000005 file=e203_hbirdv2/general/sirv_sim_ram.v lines=65-71
//__RB_CUT_BEGIN__ type=always id=e203_hbirdv2/general/sirv_sim_ram.v:proc:000002 file=e203_hbirdv2/general/sirv_sim_ram.v lines=66-70
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000004 file=e203_hbirdv2/general/sirv_sim_ram.v lines=66-70
          always @(posedge clk) begin
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000004 file=e203_hbirdv2/general/sirv_sim_ram.v lines=66-70
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000003 file=e203_hbirdv2/general/sirv_sim_ram.v lines=67-69
            if (wen[i]) begin
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000003 file=e203_hbirdv2/general/sirv_sim_ram.v lines=67-69
               mem_r[addr][DW-1:8*i] <= din[DW-1:8*i];
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000003 file=e203_hbirdv2/general/sirv_sim_ram.v lines=67-69
            end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000003 file=e203_hbirdv2/general/sirv_sim_ram.v lines=67-69
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000004 file=e203_hbirdv2/general/sirv_sim_ram.v lines=66-70
          end
//__RB_CUT_TAIL__ type=always id=e203_hbirdv2/general/sirv_sim_ram.v:proc:000002 file=e203_hbirdv2/general/sirv_sim_ram.v lines=66-70
//__RB_CUT_END__ type=always id=e203_hbirdv2/general/sirv_sim_ram.v:proc:000002 file=e203_hbirdv2/general/sirv_sim_ram.v lines=66-70
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000004 file=e203_hbirdv2/general/sirv_sim_ram.v lines=66-70
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000005 file=e203_hbirdv2/general/sirv_sim_ram.v lines=65-71
        end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000005 file=e203_hbirdv2/general/sirv_sim_ram.v lines=65-71
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000008 file=e203_hbirdv2/general/sirv_sim_ram.v lines=72-78
        else begin: non_last
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000008 file=e203_hbirdv2/general/sirv_sim_ram.v lines=72-78
//__RB_CUT_BEGIN__ type=always id=e203_hbirdv2/general/sirv_sim_ram.v:proc:000003 file=e203_hbirdv2/general/sirv_sim_ram.v lines=73-77
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000007 file=e203_hbirdv2/general/sirv_sim_ram.v lines=73-77
          always @(posedge clk) begin
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000007 file=e203_hbirdv2/general/sirv_sim_ram.v lines=73-77
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000006 file=e203_hbirdv2/general/sirv_sim_ram.v lines=74-76
            if (wen[i]) begin
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000006 file=e203_hbirdv2/general/sirv_sim_ram.v lines=74-76
               mem_r[addr][8*i+7:8*i] <= din[8*i+7:8*i];
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000006 file=e203_hbirdv2/general/sirv_sim_ram.v lines=74-76
            end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000006 file=e203_hbirdv2/general/sirv_sim_ram.v lines=74-76
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000007 file=e203_hbirdv2/general/sirv_sim_ram.v lines=73-77
          end
//__RB_CUT_TAIL__ type=always id=e203_hbirdv2/general/sirv_sim_ram.v:proc:000003 file=e203_hbirdv2/general/sirv_sim_ram.v lines=73-77
//__RB_CUT_END__ type=always id=e203_hbirdv2/general/sirv_sim_ram.v:proc:000003 file=e203_hbirdv2/general/sirv_sim_ram.v lines=73-77
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000007 file=e203_hbirdv2/general/sirv_sim_ram.v lines=73-77
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000008 file=e203_hbirdv2/general/sirv_sim_ram.v lines=72-78
        end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000008 file=e203_hbirdv2/general/sirv_sim_ram.v lines=72-78
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000009 file=e203_hbirdv2/general/sirv_sim_ram.v lines=64-79
      end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000009 file=e203_hbirdv2/general/sirv_sim_ram.v lines=64-79
//__RB_CUT_TAIL__ type=generate id=e203_hbirdv2/general/sirv_sim_ram.v:generate:000001 file=e203_hbirdv2/general/sirv_sim_ram.v lines=63-80
    endgenerate
//__RB_CUT_END__ type=generate id=e203_hbirdv2/general/sirv_sim_ram.v:generate:000001 file=e203_hbirdv2/general/sirv_sim_ram.v lines=63-80

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=e203_hbirdv2/general/sirv_sim_ram.v:grp:internal_signal:000002 file=e203_hbirdv2/general/sirv_sim_ram.v lines=82-82
  wire [DW-1:0] dout_pre;
//__RB_CUT_GROUP_END__ type=internal_signal id=e203_hbirdv2/general/sirv_sim_ram.v:grp:internal_signal:000002 file=e203_hbirdv2/general/sirv_sim_ram.v lines=82-82
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_sim_ram.v:assign:000003 file=e203_hbirdv2/general/sirv_sim_ram.v lines=83-83
  assign dout_pre = mem_r[addr_r];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_sim_ram.v:assign:000003 file=e203_hbirdv2/general/sirv_sim_ram.v lines=83-83

//__RB_CUT_BEGIN__ type=generate id=e203_hbirdv2/general/sirv_sim_ram.v:generate:000002 file=e203_hbirdv2/general/sirv_sim_ram.v lines=85-98
  generate
//__RB_CUT_BODY__ type=generate id=e203_hbirdv2/general/sirv_sim_ram.v:generate:000002 file=e203_hbirdv2/general/sirv_sim_ram.v lines=85-98
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000011 file=e203_hbirdv2/general/sirv_sim_ram.v lines=86-94
   if(FORCE_X2ZERO == 1) begin: force_x_to_zero
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000011 file=e203_hbirdv2/general/sirv_sim_ram.v lines=86-94
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000010 file=e203_hbirdv2/general/sirv_sim_ram.v lines=87-93
      for (i = 0; i < DW; i = i+1) begin:force_x_gen 
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000010 file=e203_hbirdv2/general/sirv_sim_ram.v lines=87-93
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_sim_ram.v:pp_blk:000001 file=e203_hbirdv2/general/sirv_sim_ram.v lines=88-92
//__RB_CUT_BEGIN__ type=pp_ifndef_branch id=e203_hbirdv2/general/sirv_sim_ram.v:pp_blk:000001:br:000001 file=e203_hbirdv2/general/sirv_sim_ram.v lines=88-89
          `ifndef SYNTHESIS//{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_sim_ram.v:pp_blk:000001 file=e203_hbirdv2/general/sirv_sim_ram.v lines=88-92
//__RB_CUT_BODY__ type=pp_ifndef_branch id=e203_hbirdv2/general/sirv_sim_ram.v:pp_blk:000001:br:000001 file=e203_hbirdv2/general/sirv_sim_ram.v lines=88-89
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_sim_ram.v:assign:000004 file=e203_hbirdv2/general/sirv_sim_ram.v lines=89-89
         assign dout[i] = (dout_pre[i] === 1'bx) ? 1'b0 : dout_pre[i];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_sim_ram.v:assign:000004 file=e203_hbirdv2/general/sirv_sim_ram.v lines=89-89
//__RB_CUT_TAIL__ type=pp_ifndef_branch id=e203_hbirdv2/general/sirv_sim_ram.v:pp_blk:000001:br:000001 file=e203_hbirdv2/general/sirv_sim_ram.v lines=88-89
//__RB_CUT_END__ type=pp_ifndef_branch id=e203_hbirdv2/general/sirv_sim_ram.v:pp_blk:000001:br:000001 file=e203_hbirdv2/general/sirv_sim_ram.v lines=88-89
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/general/sirv_sim_ram.v:pp_blk:000001:br:000002 file=e203_hbirdv2/general/sirv_sim_ram.v lines=90-91
          `else//}{
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/general/sirv_sim_ram.v:pp_blk:000001:br:000002 file=e203_hbirdv2/general/sirv_sim_ram.v lines=90-91
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_sim_ram.v:assign:000005 file=e203_hbirdv2/general/sirv_sim_ram.v lines=91-91
         assign dout[i] = dout_pre[i];
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_sim_ram.v:assign:000005 file=e203_hbirdv2/general/sirv_sim_ram.v lines=91-91
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/general/sirv_sim_ram.v:pp_blk:000001:br:000002 file=e203_hbirdv2/general/sirv_sim_ram.v lines=90-91
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/general/sirv_sim_ram.v:pp_blk:000001:br:000002 file=e203_hbirdv2/general/sirv_sim_ram.v lines=90-91
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_sim_ram.v:pp_blk:000001 file=e203_hbirdv2/general/sirv_sim_ram.v lines=88-92
          `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/general/sirv_sim_ram.v:pp_blk:000001 file=e203_hbirdv2/general/sirv_sim_ram.v lines=88-92
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000010 file=e203_hbirdv2/general/sirv_sim_ram.v lines=87-93
      end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000010 file=e203_hbirdv2/general/sirv_sim_ram.v lines=87-93
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000011 file=e203_hbirdv2/general/sirv_sim_ram.v lines=86-94
   end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000011 file=e203_hbirdv2/general/sirv_sim_ram.v lines=86-94
//__RB_CUT_BEGIN__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000012 file=e203_hbirdv2/general/sirv_sim_ram.v lines=95-97
   else begin:no_force_x_to_zero
//__RB_CUT_BODY__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000012 file=e203_hbirdv2/general/sirv_sim_ram.v lines=95-97
//__RB_CUT_BEGIN__ type=assign id=e203_hbirdv2/general/sirv_sim_ram.v:assign:000006 file=e203_hbirdv2/general/sirv_sim_ram.v lines=96-96
     assign dout = dout_pre;
//__RB_CUT_END__ type=assign id=e203_hbirdv2/general/sirv_sim_ram.v:assign:000006 file=e203_hbirdv2/general/sirv_sim_ram.v lines=96-96
//__RB_CUT_TAIL__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000012 file=e203_hbirdv2/general/sirv_sim_ram.v lines=95-97
   end
//__RB_CUT_END__ type=begin_end id=e203_hbirdv2/general/sirv_sim_ram.v:begin_end:000012 file=e203_hbirdv2/general/sirv_sim_ram.v lines=95-97
//__RB_CUT_TAIL__ type=generate id=e203_hbirdv2/general/sirv_sim_ram.v:generate:000002 file=e203_hbirdv2/general/sirv_sim_ram.v lines=85-98
  endgenerate
//__RB_CUT_END__ type=generate id=e203_hbirdv2/general/sirv_sim_ram.v:generate:000002 file=e203_hbirdv2/general/sirv_sim_ram.v lines=85-98

 
endmodule
