
`include "sd_defines.v"
module sd_tx_fifo
  (
//__RB_CUT_GROUP_BEGIN__ type=port_section id=sdc/sd_tx_fifo/sd_tx_fifo.v:grp:port_section:000001 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=5-14
   input [32-1:0] d,
   input wr,
   input wclk,
   output [32-1:0] q,
   input rd,
   output full,
   output empty,
   output [5:0] mem_empt,
   input rclk,
   input rst
//__RB_CUT_GROUP_END__ type=port_section id=sdc/sd_tx_fifo/sd_tx_fifo.v:grp:port_section:000001 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=5-14
   );
   
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=sdc/sd_tx_fifo/sd_tx_fifo.v:grp:internal_signal:000001 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=17-20
   reg [32-1:0] ram [0:`FIFO_TX_MEM_DEPTH-1]; //synthesis syn_ramstyle = "no_rw_check"
   reg [`FIFO_TX_MEM_ADR_SIZE-1:0] adr_i, adr_o;
   wire ram_we;
   wire [32-1:0] ram_din;
//__RB_CUT_GROUP_END__ type=internal_signal id=sdc/sd_tx_fifo/sd_tx_fifo.v:grp:internal_signal:000001 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=17-20
    

       
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=sdc/sd_tx_fifo/sd_tx_fifo.v:grp:assign_cluster:000001 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=24-25
//__RB_CUT_BEGIN__ type=assign id=sdc/sd_tx_fifo/sd_tx_fifo.v:assign:000001 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=24-24
   assign ram_we = wr & ~full;
//__RB_CUT_END__ type=assign id=sdc/sd_tx_fifo/sd_tx_fifo.v:assign:000001 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=24-24
//__RB_CUT_BEGIN__ type=assign id=sdc/sd_tx_fifo/sd_tx_fifo.v:assign:000002 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=25-25
   assign ram_din = d;
//__RB_CUT_END__ type=assign id=sdc/sd_tx_fifo/sd_tx_fifo.v:assign:000002 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=25-25
//__RB_CUT_GROUP_END__ type=assign_cluster id=sdc/sd_tx_fifo/sd_tx_fifo.v:grp:assign_cluster:000001 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=24-25
   
//__RB_CUT_BEGIN__ type=always id=sdc/sd_tx_fifo/sd_tx_fifo.v:proc:000001 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=27-29
   always @ (posedge wclk)
//__RB_CUT_BODY__ type=always id=sdc/sd_tx_fifo/sd_tx_fifo.v:proc:000001 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=27-29
     if (ram_we)
       ram[adr_i[`FIFO_TX_MEM_ADR_SIZE-2:0]] <= ram_din;
//__RB_CUT_TAIL__ type=always id=sdc/sd_tx_fifo/sd_tx_fifo.v:proc:000001 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=27-29
//__RB_CUT_END__ type=always id=sdc/sd_tx_fifo/sd_tx_fifo.v:proc:000001 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=27-29
   
//__RB_CUT_BEGIN__ type=always id=sdc/sd_tx_fifo/sd_tx_fifo.v:proc:000002 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=31-41
   always @ (posedge wclk or posedge rst)
//__RB_CUT_BODY__ type=always id=sdc/sd_tx_fifo/sd_tx_fifo.v:proc:000002 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=31-41
     if (rst)
       adr_i <= `FIFO_TX_MEM_ADR_SIZE'h0;
     else
       if (ram_we)
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_tx_fifo/sd_tx_fifo.v:begin_end:000001 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=36-39
      	 if (adr_i == `FIFO_TX_MEM_DEPTH-1) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_tx_fifo/sd_tx_fifo.v:begin_end:000001 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=36-39
	        adr_i[`FIFO_TX_MEM_ADR_SIZE-2:0] <=0;	   
	        adr_i[`FIFO_TX_MEM_ADR_SIZE-1]<=~adr_i[`FIFO_TX_MEM_ADR_SIZE-1];
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_tx_fifo/sd_tx_fifo.v:begin_end:000001 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=36-39
	    end  
//__RB_CUT_END__ type=begin_end id=sdc/sd_tx_fifo/sd_tx_fifo.v:begin_end:000001 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=36-39
	     else
	      adr_i <= adr_i + `FIFO_TX_MEM_ADR_SIZE'h1;
//__RB_CUT_TAIL__ type=always id=sdc/sd_tx_fifo/sd_tx_fifo.v:proc:000002 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=31-41
//__RB_CUT_END__ type=always id=sdc/sd_tx_fifo/sd_tx_fifo.v:proc:000002 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=31-41
	   
	   
//__RB_CUT_BEGIN__ type=always id=sdc/sd_tx_fifo/sd_tx_fifo.v:proc:000003 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=44-56
   always @ (posedge rclk or posedge rst)
//__RB_CUT_BODY__ type=always id=sdc/sd_tx_fifo/sd_tx_fifo.v:proc:000003 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=44-56
     if (rst)
       adr_o <= `FIFO_TX_MEM_ADR_SIZE'h0;
     else
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_tx_fifo/sd_tx_fifo.v:begin_end:000003 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=48-56
       if (!empty & rd) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_tx_fifo/sd_tx_fifo.v:begin_end:000003 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=48-56
	
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_tx_fifo/sd_tx_fifo.v:begin_end:000002 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=50-53
	 if (adr_o == `FIFO_TX_MEM_DEPTH-1) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_tx_fifo/sd_tx_fifo.v:begin_end:000002 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=50-53
	    adr_o[`FIFO_TX_MEM_ADR_SIZE-2:0] <=0;
	    adr_o[`FIFO_TX_MEM_ADR_SIZE-1] <=~adr_o[`FIFO_TX_MEM_ADR_SIZE-1];
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_tx_fifo/sd_tx_fifo.v:begin_end:000002 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=50-53
	 end  
//__RB_CUT_END__ type=begin_end id=sdc/sd_tx_fifo/sd_tx_fifo.v:begin_end:000002 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=50-53
	 else
	   adr_o <= adr_o + `FIFO_TX_MEM_ADR_SIZE'h1;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_tx_fifo/sd_tx_fifo.v:begin_end:000003 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=48-56
	 end
//__RB_CUT_END__ type=begin_end id=sdc/sd_tx_fifo/sd_tx_fifo.v:begin_end:000003 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=48-56
//__RB_CUT_TAIL__ type=always id=sdc/sd_tx_fifo/sd_tx_fifo.v:proc:000003 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=44-56
//__RB_CUT_END__ type=always id=sdc/sd_tx_fifo/sd_tx_fifo.v:proc:000003 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=44-56
//------------------------------------------------------------------
// Simplified version of the three necessary full-tests:
// assign wfull_val=((wgnext[ADDRSIZE] !=wq2_rptr[ADDRSIZE] ) &&
// (wgnext[ADDRSIZE-1] !=wq2_rptr[ADDRSIZE-1]) &&
// (wgnext[ADDRSIZE-2:0]==wq2_rptr[ADDRSIZE-2:0]));
//------------------------------------------------------------------
	   
	   
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=sdc/sd_tx_fifo/sd_tx_fifo.v:grp:assign_cluster:000002 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=65-69
//__RB_CUT_BEGIN__ type=assign id=sdc/sd_tx_fifo/sd_tx_fifo.v:assign:000003 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=65-65
   assign full=  ( adr_i[`FIFO_TX_MEM_ADR_SIZE-2:0] == adr_o[`FIFO_TX_MEM_ADR_SIZE-2:0] ) &  (adr_i[`FIFO_TX_MEM_ADR_SIZE-1] ^ adr_o[`FIFO_TX_MEM_ADR_SIZE-1]) ;
//__RB_CUT_END__ type=assign id=sdc/sd_tx_fifo/sd_tx_fifo.v:assign:000003 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=65-65
//__RB_CUT_BEGIN__ type=assign id=sdc/sd_tx_fifo/sd_tx_fifo.v:assign:000004 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=66-66
   assign empty = (adr_i == adr_o) ;
//__RB_CUT_END__ type=assign id=sdc/sd_tx_fifo/sd_tx_fifo.v:assign:000004 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=66-66
   
//__RB_CUT_BEGIN__ type=assign id=sdc/sd_tx_fifo/sd_tx_fifo.v:assign:000005 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=68-68
   assign mem_empt = ( adr_i-adr_o);
//__RB_CUT_END__ type=assign id=sdc/sd_tx_fifo/sd_tx_fifo.v:assign:000005 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=68-68
//__RB_CUT_BEGIN__ type=assign id=sdc/sd_tx_fifo/sd_tx_fifo.v:assign:000006 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=69-69
   assign q = ram[adr_o[`FIFO_TX_MEM_ADR_SIZE-2:0]];
//__RB_CUT_END__ type=assign id=sdc/sd_tx_fifo/sd_tx_fifo.v:assign:000006 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=69-69
//__RB_CUT_GROUP_END__ type=assign_cluster id=sdc/sd_tx_fifo/sd_tx_fifo.v:grp:assign_cluster:000002 file=sdc/sd_tx_fifo/sd_tx_fifo.v lines=65-69
endmodule

