/////////////////////////////////////////////////////////////////////
////                                                             ////
////  AES RCON Block                                             ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/aes_core/  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: aes_rcon.v,v 1.1.1.1 2002-11-09 11:22:38 rudi Exp $
//
//  $Date: 2002-11-09 11:22:38 $
//  $Revision: 1.1.1.1 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//
//
//
//
//

// `include "timescale.v"

module aes_rcon(clk, kld, out);
//__RB_CUT_GROUP_BEGIN__ type=port_section id=aes/aes_rcon/aes_rcon.v:grp:port_section:000001 file=aes/aes_rcon/aes_rcon.v lines=60-62
input		clk;
input		kld;
output	[31:0]	out;
//__RB_CUT_GROUP_END__ type=port_section id=aes/aes_rcon/aes_rcon.v:grp:port_section:000001 file=aes/aes_rcon/aes_rcon.v lines=60-62
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=aes/aes_rcon/aes_rcon.v:grp:internal_signal:000001 file=aes/aes_rcon/aes_rcon.v lines=63-65
reg	[31:0]	out;
reg	[3:0]	rcnt;
wire	[3:0]	rcnt_next;
//__RB_CUT_GROUP_END__ type=internal_signal id=aes/aes_rcon/aes_rcon.v:grp:internal_signal:000001 file=aes/aes_rcon/aes_rcon.v lines=63-65

//__RB_CUT_GROUP_BEGIN__ type=counter_cluster id=aes/aes_rcon/aes_rcon.v:grp:counter_cluster:000002 file=aes/aes_rcon/aes_rcon.v lines=67-74
//__RB_CUT_BEGIN__ type=always id=aes/aes_rcon/aes_rcon.v:proc:000001 file=aes/aes_rcon/aes_rcon.v lines=67-69
always @(posedge clk)
//__RB_CUT_BODY__ type=always id=aes/aes_rcon/aes_rcon.v:proc:000001 file=aes/aes_rcon/aes_rcon.v lines=67-69
	if(kld)		out <=  32'h01_00_00_00;
	else		out <=  frcon(rcnt_next);
//__RB_CUT_TAIL__ type=always id=aes/aes_rcon/aes_rcon.v:proc:000001 file=aes/aes_rcon/aes_rcon.v lines=67-69
//__RB_CUT_END__ type=always id=aes/aes_rcon/aes_rcon.v:proc:000001 file=aes/aes_rcon/aes_rcon.v lines=67-69

//__RB_CUT_BEGIN__ type=assign id=aes/aes_rcon/aes_rcon.v:assign:000001 file=aes/aes_rcon/aes_rcon.v lines=71-71
assign rcnt_next = rcnt + 4'h1;
//__RB_CUT_END__ type=assign id=aes/aes_rcon/aes_rcon.v:assign:000001 file=aes/aes_rcon/aes_rcon.v lines=71-71
//__RB_CUT_BEGIN__ type=always id=aes/aes_rcon/aes_rcon.v:proc:000002 file=aes/aes_rcon/aes_rcon.v lines=72-74
always @(posedge clk)
//__RB_CUT_BODY__ type=always id=aes/aes_rcon/aes_rcon.v:proc:000002 file=aes/aes_rcon/aes_rcon.v lines=72-74
	if(kld)		rcnt <=  4'h0;
	else		rcnt <=  rcnt_next;
//__RB_CUT_TAIL__ type=always id=aes/aes_rcon/aes_rcon.v:proc:000002 file=aes/aes_rcon/aes_rcon.v lines=72-74
//__RB_CUT_END__ type=always id=aes/aes_rcon/aes_rcon.v:proc:000002 file=aes/aes_rcon/aes_rcon.v lines=72-74
//__RB_CUT_GROUP_END__ type=counter_cluster id=aes/aes_rcon/aes_rcon.v:grp:counter_cluster:000002 file=aes/aes_rcon/aes_rcon.v lines=67-74

//__RB_CUT_BEGIN__ type=function id=aes/aes_rcon/aes_rcon.v:function:000001 file=aes/aes_rcon/aes_rcon.v lines=76-91
function [31:0]	frcon;
//__RB_CUT_HEAD__ type=function id=aes/aes_rcon/aes_rcon.v:function:000001 file=aes/aes_rcon/aes_rcon.v lines=76-91
input	[3:0]	i;
//__RB_CUT_BODY__ type=function id=aes/aes_rcon/aes_rcon.v:function:000001 file=aes/aes_rcon/aes_rcon.v lines=76-91
//__RB_CUT_BEGIN__ type=case id=aes/aes_rcon/aes_rcon.v:case:000001 file=aes/aes_rcon/aes_rcon.v lines=78-90
case(i)	// synopsys parallel_case
   4'h0: frcon=32'h01_00_00_00;
   4'h1: frcon=32'h02_00_00_00;
   4'h2: frcon=32'h04_00_00_00;
   4'h3: frcon=32'h08_00_00_00;
   4'h4: frcon=32'h10_00_00_00;
   4'h5: frcon=32'h20_00_00_00;
   4'h6: frcon=32'h40_00_00_00;
   4'h7: frcon=32'h80_00_00_00;
   4'h8: frcon=32'h1b_00_00_00;
   4'h9: frcon=32'h36_00_00_00;
   default: frcon=32'h00_00_00_00;
//__RB_CUT_TAIL__ type=case id=aes/aes_rcon/aes_rcon.v:case:000001 file=aes/aes_rcon/aes_rcon.v lines=78-90
endcase
//__RB_CUT_END__ type=case id=aes/aes_rcon/aes_rcon.v:case:000001 file=aes/aes_rcon/aes_rcon.v lines=78-90
//__RB_CUT_TAIL__ type=function id=aes/aes_rcon/aes_rcon.v:function:000001 file=aes/aes_rcon/aes_rcon.v lines=76-91
endfunction
//__RB_CUT_END__ type=function id=aes/aes_rcon/aes_rcon.v:function:000001 file=aes/aes_rcon/aes_rcon.v lines=76-91

endmodule