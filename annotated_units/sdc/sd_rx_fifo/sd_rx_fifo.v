`include "sd_defines.v"

module sd_rx_fifo
  (
//__RB_CUT_GROUP_BEGIN__ type=port_section id=sdc/sd_rx_fifo/sd_rx_fifo.v:grp:port_section:000001 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=5-14
   input [4-1:0] d,
   input wr,
   input wclk,
   output [32-1:0] q,
   input rd,
   output full,
   output empty,
   output [1:0] mem_empt,
   input rclk,
   input rst
//__RB_CUT_GROUP_END__ type=port_section id=sdc/sd_rx_fifo/sd_rx_fifo.v:grp:port_section:000001 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=5-14
   );
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=sdc/sd_rx_fifo/sd_rx_fifo.v:grp:internal_signal:000001 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=16-22
   reg [32-1:0] ram [0:`FIFO_RX_MEM_DEPTH-1]; //synthesis syn_ramstyle = "no_rw_check
   reg [`FIFO_RX_MEM_ADR_SIZE-1:0] adr_i, adr_o;
   wire ram_we;
   wire [32-1:0] ram_din;
   reg [8-1:0] we;
   reg [4*(8)-1:0] tmp;
   reg ft;
//__RB_CUT_GROUP_END__ type=internal_signal id=sdc/sd_rx_fifo/sd_rx_fifo.v:grp:internal_signal:000001 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=16-22
//__RB_CUT_GROUP_BEGIN__ type=reg_cluster id=sdc/sd_rx_fifo/sd_rx_fifo.v:grp:reg_cluster:000001 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=23-77
//__RB_CUT_BEGIN__ type=always id=sdc/sd_rx_fifo/sd_rx_fifo.v:proc:000001 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=23-28
   always @ (posedge wclk or posedge rst)
//__RB_CUT_BODY__ type=always id=sdc/sd_rx_fifo/sd_rx_fifo.v:proc:000001 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=23-28
     if (rst)
       we <= 8'h1;
     else
       if (wr)
	 we <= {we[8-2:0],we[8-1]};
//__RB_CUT_TAIL__ type=always id=sdc/sd_rx_fifo/sd_rx_fifo.v:proc:000001 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=23-28
//__RB_CUT_END__ type=always id=sdc/sd_rx_fifo/sd_rx_fifo.v:proc:000001 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=23-28
	 
//__RB_CUT_BEGIN__ type=always id=sdc/sd_rx_fifo/sd_rx_fifo.v:proc:000002 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=30-77
   always @ (posedge wclk or posedge rst)
//__RB_CUT_BODY__ type=always id=sdc/sd_rx_fifo/sd_rx_fifo.v:proc:000002 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=30-77
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_rx_fifo/sd_rx_fifo.v:begin_end:000001 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=31-34
     if (rst) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_rx_fifo/sd_rx_fifo.v:begin_end:000001 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=31-34
       tmp <= {4*(8-1){1'b0}};
         ft<=0; 
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_rx_fifo/sd_rx_fifo.v:begin_end:000001 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=31-34
   end    
//__RB_CUT_END__ type=begin_end id=sdc/sd_rx_fifo/sd_rx_fifo.v:begin_end:000001 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=31-34
     else
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_rx_fifo/sd_rx_fifo.v:begin_end:000004 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=36-77
       begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_rx_fifo/sd_rx_fifo.v:begin_end:000004 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=36-77
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sd_rx_fifo/sd_rx_fifo.v:pp_blk:000001 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=37-56
	 `ifdef BIG_ENDIAN
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sd_rx_fifo/sd_rx_fifo.v:pp_blk:000001 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=37-56
	   
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_rx_fifo/sd_rx_fifo.v:begin_end:000002 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=39-41
	  if (wr & we[7]) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_rx_fifo/sd_rx_fifo.v:begin_end:000002 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=39-41
	    tmp[4*1-1:4*0] <= d;	 
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_rx_fifo/sd_rx_fifo.v:begin_end:000002 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=39-41
	    ft<=1; end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_rx_fifo/sd_rx_fifo.v:begin_end:000002 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=39-41
	  if (wr & we[6])
	    tmp[4*2-1:4*1] <= d; 
	  if (wr & we[5])
	    tmp[4*3-1:4*2] <= d;	  
	  if (wr & we[4])
	    tmp[4*4-1:4*3] <= d;	  
	  if (wr & we[3])
	    tmp[4*5-1:4*4] <= d;	  
	  if (wr & we[2])
	    tmp[4*6-1:4*5] <= d;	  
	  if (wr & we[1]) 
	    tmp[4*7-1:4*6] <= d;	 
 	  if (wr & we[0]) 
	    tmp[4*8-1:4*7] <= d;	 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sd_rx_fifo/sd_rx_fifo.v:pp_blk:000001 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=37-56
	 `endif 
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sd_rx_fifo/sd_rx_fifo.v:pp_blk:000001 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=37-56
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sd_rx_fifo/sd_rx_fifo.v:pp_blk:000002 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=57-76
	 `ifdef LITTLE_ENDIAN 
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sd_rx_fifo/sd_rx_fifo.v:pp_blk:000002 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=57-76
	  if (wr & we[0])
	   tmp[4*1-1:4*0] <= d;	 
	  if (wr & we[1])
	    tmp[4*2-1:4*1] <= d;   
	  if (wr & we[2])
	    tmp[4*3-1:4*2] <= d;   
	  if (wr & we[3])
	   tmp[4*4-1:4*3] <= d;	     
	  if (wr & we[4])
	   tmp[4*5-1:4*4] <= d; 
	  if (wr & we[5])
	   tmp[4*6-1:4*5] <= d;	 
	  if (wr & we[6]) 
	   tmp[4*7-1:4*6] <= d;	  	  
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_rx_fifo/sd_rx_fifo.v:begin_end:000003 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=72-75
	  if (wr & we[7]) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_rx_fifo/sd_rx_fifo.v:begin_end:000003 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=72-75
	   tmp[4*8-1:4*7] <= d;
	       ft<=1; 
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_rx_fifo/sd_rx_fifo.v:begin_end:000003 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=72-75
     end
//__RB_CUT_END__ type=begin_end id=sdc/sd_rx_fifo/sd_rx_fifo.v:begin_end:000003 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=72-75
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sd_rx_fifo/sd_rx_fifo.v:pp_blk:000002 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=57-76
      `endif 
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sd_rx_fifo/sd_rx_fifo.v:pp_blk:000002 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=57-76
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_rx_fifo/sd_rx_fifo.v:begin_end:000004 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=36-77
  end
//__RB_CUT_END__ type=begin_end id=sdc/sd_rx_fifo/sd_rx_fifo.v:begin_end:000004 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=36-77
//__RB_CUT_TAIL__ type=always id=sdc/sd_rx_fifo/sd_rx_fifo.v:proc:000002 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=30-77
//__RB_CUT_END__ type=always id=sdc/sd_rx_fifo/sd_rx_fifo.v:proc:000002 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=30-77
//__RB_CUT_GROUP_END__ type=reg_cluster id=sdc/sd_rx_fifo/sd_rx_fifo.v:grp:reg_cluster:000001 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=23-77
       
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=sdc/sd_rx_fifo/sd_rx_fifo.v:grp:assign_cluster:000001 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=79-80
//__RB_CUT_BEGIN__ type=assign id=sdc/sd_rx_fifo/sd_rx_fifo.v:assign:000001 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=79-79
   assign ram_we = wr & we[0] &ft;
//__RB_CUT_END__ type=assign id=sdc/sd_rx_fifo/sd_rx_fifo.v:assign:000001 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=79-79
//__RB_CUT_BEGIN__ type=assign id=sdc/sd_rx_fifo/sd_rx_fifo.v:assign:000002 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=80-80
   assign ram_din = tmp;
//__RB_CUT_END__ type=assign id=sdc/sd_rx_fifo/sd_rx_fifo.v:assign:000002 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=80-80
//__RB_CUT_GROUP_END__ type=assign_cluster id=sdc/sd_rx_fifo/sd_rx_fifo.v:grp:assign_cluster:000001 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=79-80
//__RB_CUT_BEGIN__ type=always id=sdc/sd_rx_fifo/sd_rx_fifo.v:proc:000003 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=81-83
   always @ (posedge wclk)
//__RB_CUT_BODY__ type=always id=sdc/sd_rx_fifo/sd_rx_fifo.v:proc:000003 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=81-83
     if (ram_we)
       ram[adr_i[`FIFO_RX_MEM_ADR_SIZE-2:0]] <= ram_din;
//__RB_CUT_TAIL__ type=always id=sdc/sd_rx_fifo/sd_rx_fifo.v:proc:000003 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=81-83
//__RB_CUT_END__ type=always id=sdc/sd_rx_fifo/sd_rx_fifo.v:proc:000003 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=81-83
//__RB_CUT_BEGIN__ type=always id=sdc/sd_rx_fifo/sd_rx_fifo.v:proc:000004 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=84-94
   always @ (posedge wclk or posedge rst)
//__RB_CUT_BODY__ type=always id=sdc/sd_rx_fifo/sd_rx_fifo.v:proc:000004 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=84-94
     if (rst)
       adr_i <= `FIFO_RX_MEM_ADR_SIZE'h0;
     else
       if (ram_we)
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_rx_fifo/sd_rx_fifo.v:begin_end:000005 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=89-92
	 if (adr_i == `FIFO_RX_MEM_DEPTH-1) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_rx_fifo/sd_rx_fifo.v:begin_end:000005 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=89-92
	   adr_i[`FIFO_RX_MEM_ADR_SIZE-2:0] <=0;	   
	   adr_i[`FIFO_RX_MEM_ADR_SIZE-1]<=~adr_i[`FIFO_RX_MEM_ADR_SIZE-1];
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_rx_fifo/sd_rx_fifo.v:begin_end:000005 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=89-92
	 end  
//__RB_CUT_END__ type=begin_end id=sdc/sd_rx_fifo/sd_rx_fifo.v:begin_end:000005 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=89-92
	 else
	   adr_i <= adr_i + `FIFO_RX_MEM_ADR_SIZE'h1;
//__RB_CUT_TAIL__ type=always id=sdc/sd_rx_fifo/sd_rx_fifo.v:proc:000004 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=84-94
//__RB_CUT_END__ type=always id=sdc/sd_rx_fifo/sd_rx_fifo.v:proc:000004 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=84-94
	   
//__RB_CUT_BEGIN__ type=always id=sdc/sd_rx_fifo/sd_rx_fifo.v:proc:000005 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=96-107
   always @ (posedge rclk or posedge rst)
//__RB_CUT_BODY__ type=always id=sdc/sd_rx_fifo/sd_rx_fifo.v:proc:000005 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=96-107
     if (rst)
       adr_o <= `FIFO_RX_MEM_ADR_SIZE'h0;
     else
       if (!empty & rd)
	
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_rx_fifo/sd_rx_fifo.v:begin_end:000006 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=102-105
	 if (adr_o == `FIFO_RX_MEM_DEPTH-1) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_rx_fifo/sd_rx_fifo.v:begin_end:000006 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=102-105
	    adr_o[`FIFO_RX_MEM_ADR_SIZE-2:0] <=0;
	    adr_o[`FIFO_RX_MEM_ADR_SIZE-1] <=~adr_o[`FIFO_RX_MEM_ADR_SIZE-1];
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_rx_fifo/sd_rx_fifo.v:begin_end:000006 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=102-105
	 end  
//__RB_CUT_END__ type=begin_end id=sdc/sd_rx_fifo/sd_rx_fifo.v:begin_end:000006 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=102-105
	 else
	   adr_o <= adr_o + `FIFO_RX_MEM_ADR_SIZE'h1;
//__RB_CUT_TAIL__ type=always id=sdc/sd_rx_fifo/sd_rx_fifo.v:proc:000005 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=96-107
//__RB_CUT_END__ type=always id=sdc/sd_rx_fifo/sd_rx_fifo.v:proc:000005 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=96-107
	 
//------------------------------------------------------------------
// Simplified version of the three necessary full-tests:
// assign wfull_val=((wgnext[ADDRSIZE] !=wq2_rptr[ADDRSIZE] ) &&
// (wgnext[ADDRSIZE-1] !=wq2_rptr[ADDRSIZE-1]) &&
// (wgnext[ADDRSIZE-2:0]==wq2_rptr[ADDRSIZE-2:0]));
//------------------------------------------------------------------
	   
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=sdc/sd_rx_fifo/sd_rx_fifo.v:grp:assign_cluster:000002 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=116-120
//__RB_CUT_BEGIN__ type=assign id=sdc/sd_rx_fifo/sd_rx_fifo.v:assign:000003 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=116-116
   assign full =  (adr_i[`FIFO_RX_MEM_ADR_SIZE-2:0] == adr_o[`FIFO_RX_MEM_ADR_SIZE-2:0] ) & (adr_i[`FIFO_RX_MEM_ADR_SIZE-1] ^ adr_o[`FIFO_RX_MEM_ADR_SIZE-1]) ;
//__RB_CUT_END__ type=assign id=sdc/sd_rx_fifo/sd_rx_fifo.v:assign:000003 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=116-116
//__RB_CUT_BEGIN__ type=assign id=sdc/sd_rx_fifo/sd_rx_fifo.v:assign:000004 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=117-117
   assign empty = (adr_i == adr_o) ;
//__RB_CUT_END__ type=assign id=sdc/sd_rx_fifo/sd_rx_fifo.v:assign:000004 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=117-117
   
//__RB_CUT_BEGIN__ type=assign id=sdc/sd_rx_fifo/sd_rx_fifo.v:assign:000005 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=119-119
   assign mem_empt = ( adr_i-adr_o);
//__RB_CUT_END__ type=assign id=sdc/sd_rx_fifo/sd_rx_fifo.v:assign:000005 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=119-119
//__RB_CUT_BEGIN__ type=assign id=sdc/sd_rx_fifo/sd_rx_fifo.v:assign:000006 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=120-120
   assign q = ram[adr_o[`FIFO_RX_MEM_ADR_SIZE-2:0]];
//__RB_CUT_END__ type=assign id=sdc/sd_rx_fifo/sd_rx_fifo.v:assign:000006 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=120-120
//__RB_CUT_GROUP_END__ type=assign_cluster id=sdc/sd_rx_fifo/sd_rx_fifo.v:grp:assign_cluster:000002 file=sdc/sd_rx_fifo/sd_rx_fifo.v lines=116-120
endmodule
