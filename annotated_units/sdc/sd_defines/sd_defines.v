//Read the documentation before changing values

`define BIG_ENDIAN
//`define LITLE_ENDIAN

`define SIM
//`define SYN

`define SDC_IRQ_ENABLE

`define ACTEL

//`define CUSTOM
//`define ALTERA
//`define XLINX
//`define SIMULATOR

`define RESEND_MAX_CNT 3

//MAX 255 BD
//BD size/4 

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sd_defines/sd_defines.v:pp_blk:000001 file=sdc/sd_defines/sd_defines.v lines=23-29
`ifdef ACTEL
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sd_defines/sd_defines.v:pp_blk:000001 file=sdc/sd_defines/sd_defines.v lines=23-29
	`define BD_WIDTH 5
	`define BD_SIZE 32      
	`define RAM_MEM_WIDTH_16
	`define RAM_MEM_WIDTH 16
  
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sd_defines/sd_defines.v:pp_blk:000001 file=sdc/sd_defines/sd_defines.v lines=23-29
`endif
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sd_defines/sd_defines.v:pp_blk:000001 file=sdc/sd_defines/sd_defines.v lines=23-29

//`ifdef CUSTOM
 //  `define NR_O_BD_4 
//   `define BD_WIDTH 5
//   `define BD_SIZE 32      
//   `define RAM_MEM_WIDTH_32
//   `define RAM_MEM_WIDTH 32
//`endif



//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sd_defines/sd_defines.v:pp_blk:000002 file=sdc/sd_defines/sd_defines.v lines=41-44
`ifdef SYN
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sd_defines/sd_defines.v:pp_blk:000002 file=sdc/sd_defines/sd_defines.v lines=41-44
  `define RESET_CLK_DIV 0
  `define MEM_OFFSET 4
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sd_defines/sd_defines.v:pp_blk:000002 file=sdc/sd_defines/sd_defines.v lines=41-44
`endif
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sd_defines/sd_defines.v:pp_blk:000002 file=sdc/sd_defines/sd_defines.v lines=41-44

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sd_defines/sd_defines.v:pp_blk:000003 file=sdc/sd_defines/sd_defines.v lines=46-49
`ifdef SIM
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sd_defines/sd_defines.v:pp_blk:000003 file=sdc/sd_defines/sd_defines.v lines=46-49
  `define RESET_CLK_DIV 0
  `define MEM_OFFSET 4
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sd_defines/sd_defines.v:pp_blk:000003 file=sdc/sd_defines/sd_defines.v lines=46-49
`endif
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sd_defines/sd_defines.v:pp_blk:000003 file=sdc/sd_defines/sd_defines.v lines=46-49

//SD-Clock Defines ---------
//Use bus clock or a seperate clock
`define SDC_CLK_BUS_CLK
//`define SDC_CLK_SEP

// Use of internal clock divider
//`define SDC_CLK_STATIC
`define SDC_CLK_DYNAMIC


//SD DATA-transfer defines---
`define BLOCK_SIZE 512
`define SD_BUS_WIDTH_4
`define SD_BUS_W 4

//at 512 bytes per block, equal 1024 4 bytes writings with a bus width of 4, add 2 for startbit and Z bit.
//Add 18 for crc, endbit and z.
`define BIT_BLOCK 1044
`define CRC_OFF 19
`define BIT_BLOCK_REC 1024
`define BIT_CRC_CYCLE 16


//FIFO defines---------------
`define FIFO_RX_MEM_DEPTH 8
`define FIFO_RX_MEM_ADR_SIZE 4

`define FIFO_TX_MEM_DEPTH 8
`define FIFO_TX_MEM_ADR_SIZE 4
//---------------------------









