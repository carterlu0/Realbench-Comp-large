// ==========================================================================
// CRC Generation Unit - Linear Feedback Shift Register implementation
// (c) Kay Gorontzi, GHSi.de, distributed under the terms of LGPL
// https://www.ghsi.de/CRC/index.php?

// https://www.ghsi.de/CRC/index.php?
// =========================================================================
module sd_crc_16(BITVAL, Enable, CLK, RST, CRC);
//__RB_CUT_GROUP_BEGIN__ type=port_section id=sdc/sd_crc_16/sd_crc_16.v:grp:port_section:000001 file=sdc/sd_crc_16/sd_crc_16.v lines=9-13
 input        BITVAL;// Next input bit
   input Enable;
   input        CLK;                           // Current bit valid (Clock)
   input        RST;                             // Init CRC value
   output reg [15:0] CRC;                               // Current output CRC value
//__RB_CUT_GROUP_END__ type=port_section id=sdc/sd_crc_16/sd_crc_16.v:grp:port_section:000001 file=sdc/sd_crc_16/sd_crc_16.v lines=9-13

   
                     // We need output registers
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=sdc/sd_crc_16/sd_crc_16.v:grp:internal_signal:000001 file=sdc/sd_crc_16/sd_crc_16.v lines=17-17
   wire         inv;
//__RB_CUT_GROUP_END__ type=internal_signal id=sdc/sd_crc_16/sd_crc_16.v:grp:internal_signal:000001 file=sdc/sd_crc_16/sd_crc_16.v lines=17-17
   
//__RB_CUT_BEGIN__ type=assign id=sdc/sd_crc_16/sd_crc_16.v:assign:000001 file=sdc/sd_crc_16/sd_crc_16.v lines=19-19
   assign inv = BITVAL ^ CRC[15];                   // XOR required?
//__RB_CUT_END__ type=assign id=sdc/sd_crc_16/sd_crc_16.v:assign:000001 file=sdc/sd_crc_16/sd_crc_16.v lines=19-19
   
//__RB_CUT_BEGIN__ type=always id=sdc/sd_crc_16/sd_crc_16.v:proc:000001 file=sdc/sd_crc_16/sd_crc_16.v lines=21-46
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_crc_16/sd_crc_16.v:begin_end:000004 file=sdc/sd_crc_16/sd_crc_16.v lines=21-46
  always @(posedge CLK or posedge RST) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_crc_16/sd_crc_16.v:begin_end:000004 file=sdc/sd_crc_16/sd_crc_16.v lines=21-46
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_crc_16/sd_crc_16.v:begin_end:000001 file=sdc/sd_crc_16/sd_crc_16.v lines=22-25
		if (RST) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_crc_16/sd_crc_16.v:begin_end:000001 file=sdc/sd_crc_16/sd_crc_16.v lines=22-25
			CRC <= 0;   
		
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_crc_16/sd_crc_16.v:begin_end:000001 file=sdc/sd_crc_16/sd_crc_16.v lines=22-25
        end
//__RB_CUT_END__ type=begin_end id=sdc/sd_crc_16/sd_crc_16.v:begin_end:000001 file=sdc/sd_crc_16/sd_crc_16.v lines=22-25
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_crc_16/sd_crc_16.v:begin_end:000003 file=sdc/sd_crc_16/sd_crc_16.v lines=26-45
      else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_crc_16/sd_crc_16.v:begin_end:000003 file=sdc/sd_crc_16/sd_crc_16.v lines=26-45
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_crc_16/sd_crc_16.v:begin_end:000002 file=sdc/sd_crc_16/sd_crc_16.v lines=27-44
        if (Enable==1) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_crc_16/sd_crc_16.v:begin_end:000002 file=sdc/sd_crc_16/sd_crc_16.v lines=27-44
         CRC[15] <= CRC[14];
         CRC[14] <= CRC[13];
         CRC[13] <= CRC[12];
         CRC[12] <= CRC[11] ^ inv;
         CRC[11] <= CRC[10];
         CRC[10] <= CRC[9];
         CRC[9] <= CRC[8];
         CRC[8] <= CRC[7];
         CRC[7] <= CRC[6];
         CRC[6] <= CRC[5];
         CRC[5] <= CRC[4] ^ inv;
         CRC[4] <= CRC[3];
         CRC[3] <= CRC[2];
         CRC[2] <= CRC[1];
         CRC[1] <= CRC[0];
         CRC[0] <= inv;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_crc_16/sd_crc_16.v:begin_end:000002 file=sdc/sd_crc_16/sd_crc_16.v lines=27-44
        end
//__RB_CUT_END__ type=begin_end id=sdc/sd_crc_16/sd_crc_16.v:begin_end:000002 file=sdc/sd_crc_16/sd_crc_16.v lines=27-44
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_crc_16/sd_crc_16.v:begin_end:000003 file=sdc/sd_crc_16/sd_crc_16.v lines=26-45
         end
//__RB_CUT_END__ type=begin_end id=sdc/sd_crc_16/sd_crc_16.v:begin_end:000003 file=sdc/sd_crc_16/sd_crc_16.v lines=26-45
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_crc_16/sd_crc_16.v:begin_end:000004 file=sdc/sd_crc_16/sd_crc_16.v lines=21-46
      end
//__RB_CUT_TAIL__ type=always id=sdc/sd_crc_16/sd_crc_16.v:proc:000001 file=sdc/sd_crc_16/sd_crc_16.v lines=21-46
//__RB_CUT_END__ type=always id=sdc/sd_crc_16/sd_crc_16.v:proc:000001 file=sdc/sd_crc_16/sd_crc_16.v lines=21-46
//__RB_CUT_END__ type=begin_end id=sdc/sd_crc_16/sd_crc_16.v:begin_end:000004 file=sdc/sd_crc_16/sd_crc_16.v lines=21-46
   
endmodule
