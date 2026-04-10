/////////////////////////////////////////////////////////////////////
////                                                             ////
////  AES Key Expand Block (for 128 bit keys)                    ////
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
//  $Id: aes_key_expand_128.v,v 1.1.1.1 2002-11-09 11:22:38 rudi Exp $
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

module aes_key_expand_128(clk, kld, key, wo_0, wo_1, wo_2, wo_3);
//__RB_CUT_GROUP_BEGIN__ type=port_section id=aes/aes_key_expand_128/aes_key_expand_128.v:grp:port_section:000001 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=60-63
input		clk;
input		kld;
input	[127:0]	key;
output	[31:0]	wo_0, wo_1, wo_2, wo_3;
//__RB_CUT_GROUP_END__ type=port_section id=aes/aes_key_expand_128/aes_key_expand_128.v:grp:port_section:000001 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=60-63
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=aes/aes_key_expand_128/aes_key_expand_128.v:grp:internal_signal:000001 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=64-67
reg	[31:0]	w[3:0];
wire	[31:0]	tmp_w;
wire	[31:0]	subword;
wire	[31:0]	rcon;
//__RB_CUT_GROUP_END__ type=internal_signal id=aes/aes_key_expand_128/aes_key_expand_128.v:grp:internal_signal:000001 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=64-67

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=aes/aes_key_expand_128/aes_key_expand_128.v:grp:assign_cluster:000001 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=69-72
//__RB_CUT_BEGIN__ type=assign id=aes/aes_key_expand_128/aes_key_expand_128.v:assign:000001 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=69-69
assign wo_0 = w[0];
//__RB_CUT_END__ type=assign id=aes/aes_key_expand_128/aes_key_expand_128.v:assign:000001 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=69-69
//__RB_CUT_BEGIN__ type=assign id=aes/aes_key_expand_128/aes_key_expand_128.v:assign:000002 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=70-70
assign wo_1 = w[1];
//__RB_CUT_END__ type=assign id=aes/aes_key_expand_128/aes_key_expand_128.v:assign:000002 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=70-70
//__RB_CUT_BEGIN__ type=assign id=aes/aes_key_expand_128/aes_key_expand_128.v:assign:000003 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=71-71
assign wo_2 = w[2];
//__RB_CUT_END__ type=assign id=aes/aes_key_expand_128/aes_key_expand_128.v:assign:000003 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=71-71
//__RB_CUT_BEGIN__ type=assign id=aes/aes_key_expand_128/aes_key_expand_128.v:assign:000004 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=72-72
assign wo_3 = w[3];
//__RB_CUT_END__ type=assign id=aes/aes_key_expand_128/aes_key_expand_128.v:assign:000004 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=72-72
//__RB_CUT_GROUP_END__ type=assign_cluster id=aes/aes_key_expand_128/aes_key_expand_128.v:grp:assign_cluster:000001 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=69-72
//__RB_CUT_GROUP_BEGIN__ type=reg_cluster id=aes/aes_key_expand_128/aes_key_expand_128.v:grp:reg_cluster:000001 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=73-76
//__RB_CUT_BEGIN__ type=always id=aes/aes_key_expand_128/aes_key_expand_128.v:proc:000001 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=73-73
always @(posedge clk)	w[0] <=  kld ? key[127:096] : w[0]^subword^rcon;
//__RB_CUT_END__ type=always id=aes/aes_key_expand_128/aes_key_expand_128.v:proc:000001 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=73-73
//__RB_CUT_BEGIN__ type=always id=aes/aes_key_expand_128/aes_key_expand_128.v:proc:000002 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=74-74
always @(posedge clk)	w[1] <=  kld ? key[095:064] : w[0]^w[1]^subword^rcon;
//__RB_CUT_END__ type=always id=aes/aes_key_expand_128/aes_key_expand_128.v:proc:000002 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=74-74
//__RB_CUT_BEGIN__ type=always id=aes/aes_key_expand_128/aes_key_expand_128.v:proc:000003 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=75-75
always @(posedge clk)	w[2] <=  kld ? key[063:032] : w[0]^w[2]^w[1]^subword^rcon;
//__RB_CUT_END__ type=always id=aes/aes_key_expand_128/aes_key_expand_128.v:proc:000003 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=75-75
//__RB_CUT_BEGIN__ type=always id=aes/aes_key_expand_128/aes_key_expand_128.v:proc:000004 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=76-76
always @(posedge clk)	w[3] <=  kld ? key[031:000] : w[0]^w[3]^w[2]^w[1]^subword^rcon;
//__RB_CUT_END__ type=always id=aes/aes_key_expand_128/aes_key_expand_128.v:proc:000004 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=76-76
//__RB_CUT_GROUP_END__ type=reg_cluster id=aes/aes_key_expand_128/aes_key_expand_128.v:grp:reg_cluster:000001 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=73-76
//__RB_CUT_BEGIN__ type=assign id=aes/aes_key_expand_128/aes_key_expand_128.v:assign:000005 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=77-77
assign tmp_w = w[3];
//__RB_CUT_END__ type=assign id=aes/aes_key_expand_128/aes_key_expand_128.v:assign:000005 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=77-77
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_key_expand_128/aes_key_expand_128.v:inst:000001 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=78-78
aes_sbox u0(	.a(tmp_w[23:16]), .b(subword[31:24]));
//__RB_CUT_END__ type=instantiation id=aes/aes_key_expand_128/aes_key_expand_128.v:inst:000001 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=78-78
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_key_expand_128/aes_key_expand_128.v:inst:000002 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=79-79
aes_sbox u1(	.a(tmp_w[15:08]), .b(subword[23:16]));
//__RB_CUT_END__ type=instantiation id=aes/aes_key_expand_128/aes_key_expand_128.v:inst:000002 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=79-79
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_key_expand_128/aes_key_expand_128.v:inst:000003 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=80-80
aes_sbox u2(	.a(tmp_w[07:00]), .b(subword[15:08]));
//__RB_CUT_END__ type=instantiation id=aes/aes_key_expand_128/aes_key_expand_128.v:inst:000003 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=80-80
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_key_expand_128/aes_key_expand_128.v:inst:000004 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=81-81
aes_sbox u3(	.a(tmp_w[31:24]), .b(subword[07:00]));
//__RB_CUT_END__ type=instantiation id=aes/aes_key_expand_128/aes_key_expand_128.v:inst:000004 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=81-81
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_key_expand_128/aes_key_expand_128.v:inst:000005 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=82-82
aes_rcon r0(	.clk(clk), .kld(kld), .out(rcon));
//__RB_CUT_END__ type=instantiation id=aes/aes_key_expand_128/aes_key_expand_128.v:inst:000005 file=aes/aes_key_expand_128/aes_key_expand_128.v lines=82-82
endmodule