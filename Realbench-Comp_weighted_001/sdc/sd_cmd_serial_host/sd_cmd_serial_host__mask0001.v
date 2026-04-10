`include "sd_defines.v"
//-------------------------
//-------------------------
module sd_cmd_serial_host ( SD_CLK_IN, RST_IN, SETTING_IN ,CMD_IN, REQ_IN, ACK_OUT, REQ_OUT,ACK_IN, CMD_OUT, STATUS, cmd_dat_i, cmd_out_o, cmd_oe_o, st_dat_t);
//---------------Input ports---------------
input SD_CLK_IN;
input  RST_IN;
input [15:0] SETTING_IN;   
                      
input [39:0] CMD_IN;
input   REQ_IN;
input ACK_IN;
input cmd_dat_i;

//---------------Output ports---------------
output [39:0] CMD_OUT;
output ACK_OUT;
output REQ_OUT;
output [7:0] STATUS;
output reg cmd_oe_o; 
output reg cmd_out_o;
output reg [1:0] st_dat_t;
//---------------Input ports Data Type------  
wire SD_CLK_IN;
wire RST_IN;
wire [15:0] SETTING_IN;
wire [39:0] CMD_IN;
wire REQ_IN;
wire ACK_IN;

//---------------Output ports Data Type------  
reg  [39:0] CMD_OUT;
wire ACK_OUT  ;
reg  [7:0] STATUS;
reg  REQ_OUT;

//-------------Internal Constant-------------

`ifdef SIM
 `define INIT_DELAY 2
`else
  `define INIT_DELAY 64
 `endif
  
`define NCR 2 
parameter SEND_SIZE = 48;
parameter SIZE = 10;
parameter CONTENT_SIZE = 40;
parameter 
    INIT   =  10'b0000_0000_01,
    IDLE   =  10'b0000_0000_10,
    WRITE_WR	    =  10'b0000_0001_00,
    DLY_WR       =  10'b0000_0010_00,
    READ_WR      =  10'b0000_0100_00,
	  DLY_READ    	=  10'b0000_1000_00, 
 	  ACK_WR		     =  10'b0001_0000_00, 
	  WRITE_WO	    =  10'b0010_0000_00, 
	  DLY_WO	      =  10'b0100_0000_00, 
	  ACK_WO	      =  10'b1000_0000_00;
parameter Read_Delay = 7;	
parameter EIGHT_PAD = 8;
//---------------Internal variable----------- 
//-Internal settings/buffers
reg [6:0] Response_Size;
reg [2:0] Delay_Cycler;
reg [CONTENT_SIZE-1:0] In_Buff; 
reg [39:0] Out_Buff;
//-Internal State input
reg Write_Read;
reg Write_Only; 

//-CRC
reg [4:0] word_select_counter;
reg CRC_RST;
reg [6:0]CRC_IN;
wire [6:0] CRC_VAL; 
reg CRC_Enable;
reg CRC_OUT;
reg CRC_Check_On;
reg Crc_Buffering;
reg CRC_Valid;
//-Internal Counterns
  //6 bit sent counter
reg [7:0]Cmd_Cnt; //8 bit recive counter
reg [2:0]Delay_Cnt; //3 bit Delay counter
//-State Variable
reg [SIZE-1:0] state;
reg [SIZE-1:0] next_state;
//Misc
`define Vector_Index  (CONTENT_SIZE-1-Cmd_Cnt) 
`define Bit_Nr (SEND_SIZE-Cmd_Cnt)
	
//TRI-STATE
reg block_write;
reg block_read;


//
reg [1:0]word_select;
reg FSM_ACK;
reg DECODER_ACK;

reg q;
reg Req_internal_in;
reg q1;
reg Ack_internal_in;
//------------------------------------------   
sd_crc_7 CRC_7( 
CRC_OUT,
CRC_Enable,
SD_CLK_IN,
CRC_RST,
CRC_VAL);
//------------------------------------------  
// <masked:to be completed>
  
  
endmodule


