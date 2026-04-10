module sd_crc_7(BITVAL, Enable, CLK, RST, CRC);
   input        BITVAL;// Next input bit
   input Enable;
   input        CLK;                           // Current bit valid (Clock)
   input        RST;                             // Init CRC value
   output [6:0] CRC;                               // Current output CRC value

   reg    [6:0] CRC;   
                     // We need output registers
   wire         inv;
   
   assign inv = BITVAL ^ CRC[6];                   // XOR required?
   
   
    always @(posedge CLK or posedge RST) begin
		if (RST) begin
			CRC <= 0;   
		
        end
		else begin
			// <masked:to be completed>
		end
     end
   
endmodule

