`include "sd_defines.v"//nononw
module sd_clock_divider (
//__RB_CUT_GROUP_BEGIN__ type=port_section id=sdc/sd_clock_divider/sd_clock_divider.v:grp:port_section:000001 file=sdc/sd_clock_divider/sd_clock_divider.v lines=3-6
  input wire CLK,
  input  [7:0] DIVIDER,
  input wire RST,
  output  SD_CLK 
//__RB_CUT_GROUP_END__ type=port_section id=sdc/sd_clock_divider/sd_clock_divider.v:grp:port_section:000001 file=sdc/sd_clock_divider/sd_clock_divider.v lines=3-6
  );
  
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=sdc/sd_clock_divider/sd_clock_divider.v:grp:internal_signal:000001 file=sdc/sd_clock_divider/sd_clock_divider.v lines=9-12
  reg [7:0] ClockDiv;
  reg SD_CLK_O;
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sd_clock_divider/sd_clock_divider.v:pp_blk:000002 file=sdc/sd_clock_divider/sd_clock_divider.v lines=11-18
`ifdef SYN
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sd_clock_divider/sd_clock_divider.v:pp_blk:000002 file=sdc/sd_clock_divider/sd_clock_divider.v lines=11-18
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sd_clock_divider/sd_clock_divider.v:pp_blk:000001 file=sdc/sd_clock_divider/sd_clock_divider.v lines=12-17
  `ifdef ACTEL
//__RB_CUT_GROUP_END__ type=internal_signal id=sdc/sd_clock_divider/sd_clock_divider.v:grp:internal_signal:000001 file=sdc/sd_clock_divider/sd_clock_divider.v lines=9-12
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sd_clock_divider/sd_clock_divider.v:pp_blk:000001 file=sdc/sd_clock_divider/sd_clock_divider.v lines=12-17
//__RB_CUT_BEGIN__ type=instantiation id=sdc/sd_clock_divider/sd_clock_divider.v:inst:000001 file=sdc/sd_clock_divider/sd_clock_divider.v lines=13-16
  CLKINT CLKA
  (.A (SD_CLK_O),
   .Y (SD_CLK) 
   );
//__RB_CUT_END__ type=instantiation id=sdc/sd_clock_divider/sd_clock_divider.v:inst:000001 file=sdc/sd_clock_divider/sd_clock_divider.v lines=13-16
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sd_clock_divider/sd_clock_divider.v:pp_blk:000001 file=sdc/sd_clock_divider/sd_clock_divider.v lines=12-17
   `endif
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sd_clock_divider/sd_clock_divider.v:pp_blk:000001 file=sdc/sd_clock_divider/sd_clock_divider.v lines=12-17
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sd_clock_divider/sd_clock_divider.v:pp_blk:000002 file=sdc/sd_clock_divider/sd_clock_divider.v lines=11-18
 `endif
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sd_clock_divider/sd_clock_divider.v:pp_blk:000002 file=sdc/sd_clock_divider/sd_clock_divider.v lines=11-18
 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sd_clock_divider/sd_clock_divider.v:pp_blk:000003 file=sdc/sd_clock_divider/sd_clock_divider.v lines=20-22
 `ifdef SIM
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sd_clock_divider/sd_clock_divider.v:pp_blk:000003 file=sdc/sd_clock_divider/sd_clock_divider.v lines=20-22
//__RB_CUT_BEGIN__ type=assign id=sdc/sd_clock_divider/sd_clock_divider.v:assign:000001 file=sdc/sd_clock_divider/sd_clock_divider.v lines=21-21
   assign SD_CLK = SD_CLK_O;
//__RB_CUT_END__ type=assign id=sdc/sd_clock_divider/sd_clock_divider.v:assign:000001 file=sdc/sd_clock_divider/sd_clock_divider.v lines=21-21
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sd_clock_divider/sd_clock_divider.v:pp_blk:000003 file=sdc/sd_clock_divider/sd_clock_divider.v lines=20-22
`endif 
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sd_clock_divider/sd_clock_divider.v:pp_blk:000003 file=sdc/sd_clock_divider/sd_clock_divider.v lines=20-22
 
//__RB_CUT_BEGIN__ type=always id=sdc/sd_clock_divider/sd_clock_divider.v:proc:000001 file=sdc/sd_clock_divider/sd_clock_divider.v lines=24-38
always @ (posedge CLK or posedge RST)
//__RB_CUT_BODY__ type=always id=sdc/sd_clock_divider/sd_clock_divider.v:proc:000001 file=sdc/sd_clock_divider/sd_clock_divider.v lines=24-38
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_clock_divider/sd_clock_divider.v:begin_end:000004 file=sdc/sd_clock_divider/sd_clock_divider.v lines=25-38
begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_clock_divider/sd_clock_divider.v:begin_end:000004 file=sdc/sd_clock_divider/sd_clock_divider.v lines=25-38
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_clock_divider/sd_clock_divider.v:begin_end:000001 file=sdc/sd_clock_divider/sd_clock_divider.v lines=26-29
 if (RST) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_clock_divider/sd_clock_divider.v:begin_end:000001 file=sdc/sd_clock_divider/sd_clock_divider.v lines=26-29
    ClockDiv <=8'b0000_0000;
    SD_CLK_O  <= 0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_clock_divider/sd_clock_divider.v:begin_end:000001 file=sdc/sd_clock_divider/sd_clock_divider.v lines=26-29
 end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_clock_divider/sd_clock_divider.v:begin_end:000001 file=sdc/sd_clock_divider/sd_clock_divider.v lines=26-29
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_clock_divider/sd_clock_divider.v:begin_end:000002 file=sdc/sd_clock_divider/sd_clock_divider.v lines=30-33
 else if (ClockDiv == DIVIDER )begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_clock_divider/sd_clock_divider.v:begin_end:000002 file=sdc/sd_clock_divider/sd_clock_divider.v lines=30-33
    ClockDiv  <= 0;
    SD_CLK_O <=  ~SD_CLK_O;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_clock_divider/sd_clock_divider.v:begin_end:000002 file=sdc/sd_clock_divider/sd_clock_divider.v lines=30-33
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_clock_divider/sd_clock_divider.v:begin_end:000003 file=sdc/sd_clock_divider/sd_clock_divider.v lines=33-36
 end else begin
//__RB_CUT_END__ type=begin_end id=sdc/sd_clock_divider/sd_clock_divider.v:begin_end:000002 file=sdc/sd_clock_divider/sd_clock_divider.v lines=30-33
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_clock_divider/sd_clock_divider.v:begin_end:000003 file=sdc/sd_clock_divider/sd_clock_divider.v lines=33-36
    ClockDiv  <= ClockDiv + 1;
    SD_CLK_O <=  SD_CLK_O;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_clock_divider/sd_clock_divider.v:begin_end:000003 file=sdc/sd_clock_divider/sd_clock_divider.v lines=33-36
end
//__RB_CUT_END__ type=begin_end id=sdc/sd_clock_divider/sd_clock_divider.v:begin_end:000003 file=sdc/sd_clock_divider/sd_clock_divider.v lines=33-36
 
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_clock_divider/sd_clock_divider.v:begin_end:000004 file=sdc/sd_clock_divider/sd_clock_divider.v lines=25-38
end
//__RB_CUT_END__ type=begin_end id=sdc/sd_clock_divider/sd_clock_divider.v:begin_end:000004 file=sdc/sd_clock_divider/sd_clock_divider.v lines=25-38
//__RB_CUT_TAIL__ type=always id=sdc/sd_clock_divider/sd_clock_divider.v:proc:000001 file=sdc/sd_clock_divider/sd_clock_divider.v lines=24-38
//__RB_CUT_END__ type=always id=sdc/sd_clock_divider/sd_clock_divider.v:proc:000001 file=sdc/sd_clock_divider/sd_clock_divider.v lines=24-38
 endmodule
 
 
