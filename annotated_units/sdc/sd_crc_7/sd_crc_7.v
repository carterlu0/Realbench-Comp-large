module sd_crc_7(BITVAL, Enable, CLK, RST, CRC);
//__RB_CUT_GROUP_BEGIN__ type=port_section id=sdc/sd_crc_7/sd_crc_7.v:grp:port_section:000001 file=sdc/sd_crc_7/sd_crc_7.v lines=2-6
   input        BITVAL;// Next input bit
   input Enable;
   input        CLK;                           // Current bit valid (Clock)
   input        RST;                             // Init CRC value
   output [6:0] CRC;                               // Current output CRC value
//__RB_CUT_GROUP_END__ type=port_section id=sdc/sd_crc_7/sd_crc_7.v:grp:port_section:000001 file=sdc/sd_crc_7/sd_crc_7.v lines=2-6

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=sdc/sd_crc_7/sd_crc_7.v:grp:internal_signal:000001 file=sdc/sd_crc_7/sd_crc_7.v lines=8-10
   reg    [6:0] CRC;   
                     // We need output registers
   wire         inv;
//__RB_CUT_GROUP_END__ type=internal_signal id=sdc/sd_crc_7/sd_crc_7.v:grp:internal_signal:000001 file=sdc/sd_crc_7/sd_crc_7.v lines=8-10
   
//__RB_CUT_BEGIN__ type=assign id=sdc/sd_crc_7/sd_crc_7.v:assign:000001 file=sdc/sd_crc_7/sd_crc_7.v lines=12-12
   assign inv = BITVAL ^ CRC[6];                   // XOR required?
//__RB_CUT_END__ type=assign id=sdc/sd_crc_7/sd_crc_7.v:assign:000001 file=sdc/sd_crc_7/sd_crc_7.v lines=12-12
   
   
//__RB_CUT_BEGIN__ type=always id=sdc/sd_crc_7/sd_crc_7.v:proc:000001 file=sdc/sd_crc_7/sd_crc_7.v lines=15-31
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_crc_7/sd_crc_7.v:begin_end:000004 file=sdc/sd_crc_7/sd_crc_7.v lines=15-31
    always @(posedge CLK or posedge RST) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_crc_7/sd_crc_7.v:begin_end:000004 file=sdc/sd_crc_7/sd_crc_7.v lines=15-31
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_crc_7/sd_crc_7.v:begin_end:000001 file=sdc/sd_crc_7/sd_crc_7.v lines=16-19
		if (RST) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_crc_7/sd_crc_7.v:begin_end:000001 file=sdc/sd_crc_7/sd_crc_7.v lines=16-19
			CRC <= 0;   
		
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_crc_7/sd_crc_7.v:begin_end:000001 file=sdc/sd_crc_7/sd_crc_7.v lines=16-19
        end
//__RB_CUT_END__ type=begin_end id=sdc/sd_crc_7/sd_crc_7.v:begin_end:000001 file=sdc/sd_crc_7/sd_crc_7.v lines=16-19
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_crc_7/sd_crc_7.v:begin_end:000003 file=sdc/sd_crc_7/sd_crc_7.v lines=20-30
		else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_crc_7/sd_crc_7.v:begin_end:000003 file=sdc/sd_crc_7/sd_crc_7.v lines=20-30
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_crc_7/sd_crc_7.v:begin_end:000002 file=sdc/sd_crc_7/sd_crc_7.v lines=21-29
			if (Enable==1) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_crc_7/sd_crc_7.v:begin_end:000002 file=sdc/sd_crc_7/sd_crc_7.v lines=21-29
				CRC[6] <= CRC[5];
				CRC[5] <= CRC[4];
				CRC[4] <= CRC[3];
				CRC[3] <= CRC[2] ^ inv;
				CRC[2] <= CRC[1];
				CRC[1] <= CRC[0];
				CRC[0] <= inv;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_crc_7/sd_crc_7.v:begin_end:000002 file=sdc/sd_crc_7/sd_crc_7.v lines=21-29
			end
//__RB_CUT_END__ type=begin_end id=sdc/sd_crc_7/sd_crc_7.v:begin_end:000002 file=sdc/sd_crc_7/sd_crc_7.v lines=21-29
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_crc_7/sd_crc_7.v:begin_end:000003 file=sdc/sd_crc_7/sd_crc_7.v lines=20-30
		end
//__RB_CUT_END__ type=begin_end id=sdc/sd_crc_7/sd_crc_7.v:begin_end:000003 file=sdc/sd_crc_7/sd_crc_7.v lines=20-30
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_crc_7/sd_crc_7.v:begin_end:000004 file=sdc/sd_crc_7/sd_crc_7.v lines=15-31
     end
//__RB_CUT_TAIL__ type=always id=sdc/sd_crc_7/sd_crc_7.v:proc:000001 file=sdc/sd_crc_7/sd_crc_7.v lines=15-31
//__RB_CUT_END__ type=always id=sdc/sd_crc_7/sd_crc_7.v:proc:000001 file=sdc/sd_crc_7/sd_crc_7.v lines=15-31
//__RB_CUT_END__ type=begin_end id=sdc/sd_crc_7/sd_crc_7.v:begin_end:000004 file=sdc/sd_crc_7/sd_crc_7.v lines=15-31
   
endmodule

