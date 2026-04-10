// ==========================================================================
// CRC Generation Unit - Linear Feedback Shift Register implementation
// (c) Kay Gorontzi, GHSi.de, distributed under the terms of LGPL
// https://www.ghsi.de/CRC/index.php?

// https://www.ghsi.de/CRC/index.php?
// =========================================================================
module sd_crc_16(BITVAL, Enable, CLK, RST, CRC);
 input        BITVAL;// Next input bit
   input Enable;
   input        CLK;                           // Current bit valid (Clock)
   input        RST;                             // Init CRC value
   output reg [15:0] CRC;                               // Current output CRC value

   
                     // We need output registers
   wire         inv;
   
   assign inv = BITVAL ^ CRC[15];                   // XOR required?
   
  always @(posedge CLK or posedge RST) begin
		if (RST) begin
			CRC <= 0;   
		
        end
      else begin
        // <masked:to be completed>
         end
      end
   
endmodule
