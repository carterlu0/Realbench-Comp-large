 /*                                                                      
 Copyright 2018-2020 Nuclei System Technology, Inc.                
                                                                         
 Licensed under the Apache License, Version 2.0 (the "License");         
 you may not use this file except in compliance with the License.        
 You may obtain a copy of the License at                                 
                                                                         
     http://www.apache.org/licenses/LICENSE-2.0                          
                                                                         
  Unless required by applicable law or agreed to in writing, software    
 distributed under the License is distributed on an "AS IS" BASIS,       
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and     
 limitations under the License.                                          
 */                                                                      
                                                                         
                                                                         
                                                                         
//=====================================================================
//
// Designer   : Bob Hu
//
// Description:
//  The files to include all the macro defines
//
// ====================================================================
`include "config.v"

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////// ISA relevant macro
//
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000001 file=e203_hbirdv2/e203_defines/e203_defines.v lines=34-39
`ifdef E203_CFG_ADDR_SIZE_IS_16
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000001 file=e203_hbirdv2/e203_defines/e203_defines.v lines=34-39
   `define E203_ADDR_SIZE_IS_16
   `define E203_PC_SIZE_IS_16
   `define E203_ADDR_SIZE   16
   `define E203_PC_SIZE     16
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000001 file=e203_hbirdv2/e203_defines/e203_defines.v lines=34-39
`endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000001 file=e203_hbirdv2/e203_defines/e203_defines.v lines=34-39
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000002 file=e203_hbirdv2/e203_defines/e203_defines.v lines=40-45
`ifdef E203_CFG_ADDR_SIZE_IS_32
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000002 file=e203_hbirdv2/e203_defines/e203_defines.v lines=40-45
   `define E203_ADDR_SIZE_IS_32
   `define E203_PC_SIZE_IS_32
   `define E203_ADDR_SIZE   32
   `define E203_PC_SIZE     32
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000002 file=e203_hbirdv2/e203_defines/e203_defines.v lines=40-45
`endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000002 file=e203_hbirdv2/e203_defines/e203_defines.v lines=40-45
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000003 file=e203_hbirdv2/e203_defines/e203_defines.v lines=46-51
`ifdef E203_CFG_ADDR_SIZE_IS_24
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000003 file=e203_hbirdv2/e203_defines/e203_defines.v lines=46-51
   `define E203_ADDR_SIZE_IS_24
   `define E203_PC_SIZE_IS_24
   `define E203_ADDR_SIZE   24
   `define E203_PC_SIZE     24
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000003 file=e203_hbirdv2/e203_defines/e203_defines.v lines=46-51
`endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000003 file=e203_hbirdv2/e203_defines/e203_defines.v lines=46-51


//`ifdef E203_CFG_SUPPORT_MSCRATCH
   `define E203_SUPPORT_MSCRATCH 
//`endif
//`ifdef E203_CFG_SUPPORT_MTVEC
   `define E203_SUPPORT_MTVEC
//`endif
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000004 file=e203_hbirdv2/e203_defines/e203_defines.v lines=60-62
`ifdef E203_CFG_SUPPORT_MCYCLE_MINSTRET
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000004 file=e203_hbirdv2/e203_defines/e203_defines.v lines=60-62
   `define E203_SUPPORT_MCYCLE_MINSTRET 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000004 file=e203_hbirdv2/e203_defines/e203_defines.v lines=60-62
`endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000004 file=e203_hbirdv2/e203_defines/e203_defines.v lines=60-62


`define E203_CFG_XLEN_IS_32
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000005 file=e203_hbirdv2/e203_defines/e203_defines.v lines=66-70
`ifdef E203_CFG_XLEN_IS_32//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000005 file=e203_hbirdv2/e203_defines/e203_defines.v lines=66-70
  `define E203_XLEN_IS_32 
  `define E203_XLEN          32
  `define E203_XLEN_MW       4
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000005 file=e203_hbirdv2/e203_defines/e203_defines.v lines=66-70
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000005 file=e203_hbirdv2/e203_defines/e203_defines.v lines=66-70

`define E203_INSTR_SIZE    32

//
`define E203_RFIDX_WIDTH   5
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000006 file=e203_hbirdv2/e203_defines/e203_defines.v lines=76-79
`ifdef E203_CFG_REGNUM_IS_32//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000006 file=e203_hbirdv2/e203_defines/e203_defines.v lines=76-79
  `define E203_RFREG_NUM_IS_32 
  `define E203_RFREG_NUM     32
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000006 file=e203_hbirdv2/e203_defines/e203_defines.v lines=76-79
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000006 file=e203_hbirdv2/e203_defines/e203_defines.v lines=76-79
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000007 file=e203_hbirdv2/e203_defines/e203_defines.v lines=80-83
`ifdef E203_CFG_REGNUM_IS_16//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000007 file=e203_hbirdv2/e203_defines/e203_defines.v lines=80-83
  `define E203_RFREG_NUM_IS_16 
  `define E203_RFREG_NUM     16
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000007 file=e203_hbirdv2/e203_defines/e203_defines.v lines=80-83
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000007 file=e203_hbirdv2/e203_defines/e203_defines.v lines=80-83
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000008 file=e203_hbirdv2/e203_defines/e203_defines.v lines=84-87
`ifdef E203_CFG_REGNUM_IS_8//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000008 file=e203_hbirdv2/e203_defines/e203_defines.v lines=84-87
  `define E203_RFREG_NUM_IS_8 
  `define E203_RFREG_NUM     8
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000008 file=e203_hbirdv2/e203_defines/e203_defines.v lines=84-87
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000008 file=e203_hbirdv2/e203_defines/e203_defines.v lines=84-87
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000009 file=e203_hbirdv2/e203_defines/e203_defines.v lines=88-91
`ifdef E203_CFG_REGNUM_IS_4//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000009 file=e203_hbirdv2/e203_defines/e203_defines.v lines=88-91
  `define E203_RFREG_NUM_IS_4 
  `define E203_RFREG_NUM     4
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000009 file=e203_hbirdv2/e203_defines/e203_defines.v lines=88-91
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000009 file=e203_hbirdv2/e203_defines/e203_defines.v lines=88-91

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000011 file=e203_hbirdv2/e203_defines/e203_defines.v lines=93-97
`ifdef E203_CFG_REGFILE_LATCH_BASED//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000011 file=e203_hbirdv2/e203_defines/e203_defines.v lines=93-97
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000010 file=e203_hbirdv2/e203_defines/e203_defines.v lines=94-96
    `ifndef FPGA_SOURCE//{ Only If there is not on FPGA
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000010 file=e203_hbirdv2/e203_defines/e203_defines.v lines=94-96
        `define E203_REGFILE_LATCH_BASED 
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000010 file=e203_hbirdv2/e203_defines/e203_defines.v lines=94-96
    `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000010 file=e203_hbirdv2/e203_defines/e203_defines.v lines=94-96
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000011 file=e203_hbirdv2/e203_defines/e203_defines.v lines=93-97
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000011 file=e203_hbirdv2/e203_defines/e203_defines.v lines=93-97

`define E203_PPI_ADDR_BASE    `E203_CFG_PPI_ADDR_BASE  
`define E203_PPI_BASE_REGION  `E203_CFG_PPI_BASE_REGION
`define E203_CLINT_ADDR_BASE    `E203_CFG_CLINT_ADDR_BASE  
`define E203_CLINT_BASE_REGION  `E203_CFG_CLINT_BASE_REGION
`define E203_PLIC_ADDR_BASE    `E203_CFG_PLIC_ADDR_BASE  
`define E203_PLIC_BASE_REGION  `E203_CFG_PLIC_BASE_REGION
`define E203_FIO_ADDR_BASE    `E203_CFG_FIO_ADDR_BASE  
`define E203_FIO_BASE_REGION  `E203_CFG_FIO_BASE_REGION
                              
`define E203_DTCM_ADDR_BASE   `E203_CFG_DTCM_ADDR_BASE 
`define E203_ITCM_ADDR_BASE   `E203_CFG_ITCM_ADDR_BASE 
                             



/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////// Interface relevant macro
//
`define E203_HART_NUM   1
`define E203_HART_ID_W  1
`define E203_LIRQ_NUM   1
`define E203_EVT_NUM    1

`define E203_CFG_DEBUG_HAS_DM
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000012 file=e203_hbirdv2/e203_defines/e203_defines.v lines=125-127
`ifdef E203_CFG_DEBUG_HAS_DM//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000012 file=e203_hbirdv2/e203_defines/e203_defines.v lines=125-127
   `define E203_DEBUG_HAS_DM 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000012 file=e203_hbirdv2/e203_defines/e203_defines.v lines=125-127
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000012 file=e203_hbirdv2/e203_defines/e203_defines.v lines=125-127

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000013 file=e203_hbirdv2/e203_defines/e203_defines.v lines=129-131
`ifdef E203_CFG_IRQ_NEED_SYNC//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000013 file=e203_hbirdv2/e203_defines/e203_defines.v lines=129-131
   `define E203_IRQ_NEED_SYNC 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000013 file=e203_hbirdv2/e203_defines/e203_defines.v lines=129-131
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000013 file=e203_hbirdv2/e203_defines/e203_defines.v lines=129-131

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000014 file=e203_hbirdv2/e203_defines/e203_defines.v lines=133-135
`ifdef E203_CFG_DEBUG_HAS_JTAG//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000014 file=e203_hbirdv2/e203_defines/e203_defines.v lines=133-135
   `define E203_DEBUG_HAS_JTAG 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000014 file=e203_hbirdv2/e203_defines/e203_defines.v lines=133-135
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000014 file=e203_hbirdv2/e203_defines/e203_defines.v lines=133-135

`define E203_HAS_MEM_ITF
`define E203_CFG_SYSMEM_DATA_WIDTH_IS_32
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000015 file=e203_hbirdv2/e203_defines/e203_defines.v lines=139-142
`ifdef E203_CFG_SYSMEM_DATA_WIDTH_IS_32
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000015 file=e203_hbirdv2/e203_defines/e203_defines.v lines=139-142
    `define E203_SYSMEM_DATA_WIDTH_IS_32
    `define E203_SYSMEM_DATA_WIDTH   32
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000015 file=e203_hbirdv2/e203_defines/e203_defines.v lines=139-142
`endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000015 file=e203_hbirdv2/e203_defines/e203_defines.v lines=139-142
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000016 file=e203_hbirdv2/e203_defines/e203_defines.v lines=143-146
`ifdef E203_CFG_SYSMEM_DATA_WIDTH_IS_64
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000016 file=e203_hbirdv2/e203_defines/e203_defines.v lines=143-146
    `define E203_SYSMEM_DATA_WIDTH_IS_64
    `define E203_SYSMEM_DATA_WIDTH   64
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000016 file=e203_hbirdv2/e203_defines/e203_defines.v lines=143-146
`endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000016 file=e203_hbirdv2/e203_defines/e203_defines.v lines=143-146

//`ifdef E203_CFG_HAS_FIO//{
//  `define E203_HAS_FIO 
//`endif//}

`define E203_HAS_PPI 
`define E203_HAS_PLIC 
`define E203_HAS_CLINT 
`define E203_HAS_FIO 

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000017 file=e203_hbirdv2/e203_defines/e203_defines.v lines=157-158
`ifdef E203_CFG_HAS_ECC//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000017 file=e203_hbirdv2/e203_defines/e203_defines.v lines=157-158
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000017 file=e203_hbirdv2/e203_defines/e203_defines.v lines=157-158
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000017 file=e203_hbirdv2/e203_defines/e203_defines.v lines=157-158
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000018 file=e203_hbirdv2/e203_defines/e203_defines.v lines=159-162
`ifdef E203_CFG_HAS_NICE//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000018 file=e203_hbirdv2/e203_defines/e203_defines.v lines=159-162
   `define E203_HAS_NICE
   //`define E203_HAS_CSR_NICE 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000018 file=e203_hbirdv2/e203_defines/e203_defines.v lines=159-162
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000018 file=e203_hbirdv2/e203_defines/e203_defines.v lines=159-162

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000019 file=e203_hbirdv2/e203_defines/e203_defines.v lines=164-165
`ifdef E203_CFG_HAS_LOCKSTEP//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000019 file=e203_hbirdv2/e203_defines/e203_defines.v lines=164-165
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000019 file=e203_hbirdv2/e203_defines/e203_defines.v lines=164-165
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000019 file=e203_hbirdv2/e203_defines/e203_defines.v lines=164-165

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////// ITCM relevant macro
//
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000022 file=e203_hbirdv2/e203_defines/e203_defines.v lines=172-198
`ifdef E203_CFG_HAS_ITCM//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000022 file=e203_hbirdv2/e203_defines/e203_defines.v lines=172-198
  `define E203_HAS_ITCM 1
  `define E203_ITCM_ADDR_WIDTH  `E203_CFG_ITCM_ADDR_WIDTH
  // The ITCM size is 2^addr_width bytes, and ITCM is 64bits wide (8 bytes)
  //  so the DP is 2^addr_wdith/8
  //  so the AW is addr_wdith - 3
  `define E203_ITCM_RAM_DP      (1<<(`E203_CFG_ITCM_ADDR_WIDTH-3)) 
  `define E203_ITCM_RAM_AW          (`E203_CFG_ITCM_ADDR_WIDTH-3) 
  `define E203_ITCM_BASE_REGION  `E203_ADDR_SIZE-1:`E203_ITCM_ADDR_WIDTH
  
  `define E203_CFG_ITCM_DATA_WIDTH_IS_64
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000020 file=e203_hbirdv2/e203_defines/e203_defines.v lines=183-190
  `ifdef E203_CFG_ITCM_DATA_WIDTH_IS_64
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000020 file=e203_hbirdv2/e203_defines/e203_defines.v lines=183-190
    `define E203_ITCM_DATA_WIDTH_IS_64
    `define E203_ITCM_DATA_WIDTH  64
    `define E203_ITCM_WMSK_WIDTH  8
  
    `define E203_ITCM_RAM_ECC_DW  8
    `define E203_ITCM_RAM_ECC_MW  1
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000020 file=e203_hbirdv2/e203_defines/e203_defines.v lines=183-190
  `endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000020 file=e203_hbirdv2/e203_defines/e203_defines.v lines=183-190
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000021 file=e203_hbirdv2/e203_defines/e203_defines.v lines=191-195
  `ifndef E203_HAS_ECC //{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000021 file=e203_hbirdv2/e203_defines/e203_defines.v lines=191-195
    `define E203_ITCM_RAM_DW      `E203_ITCM_DATA_WIDTH
    `define E203_ITCM_RAM_MW      `E203_ITCM_WMSK_WIDTH
    `define E203_ITCM_OUTS_NUM 1 // If no-ECC, ITCM is 1 cycle latency then only allow 1 oustanding for external agent
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000021 file=e203_hbirdv2/e203_defines/e203_defines.v lines=191-195
  `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000021 file=e203_hbirdv2/e203_defines/e203_defines.v lines=191-195

  `define E203_HAS_ITCM_EXTITF
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000022 file=e203_hbirdv2/e203_defines/e203_defines.v lines=172-198
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000022 file=e203_hbirdv2/e203_defines/e203_defines.v lines=172-198

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////// DTCM relevant macro
//
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000024 file=e203_hbirdv2/e203_defines/e203_defines.v lines=205-229
`ifdef E203_CFG_HAS_DTCM//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000024 file=e203_hbirdv2/e203_defines/e203_defines.v lines=205-229
  `define E203_HAS_DTCM 1
  `define E203_DTCM_ADDR_WIDTH  `E203_CFG_DTCM_ADDR_WIDTH
  // The DTCM size is 2^addr_width bytes, and DTCM is 32bits wide (4 bytes)
  //  so the DP is 2^addr_wdith/4
  //  so the AW is addr_wdith - 2
  `define E203_DTCM_RAM_DP      (1<<(`E203_CFG_DTCM_ADDR_WIDTH-2)) 
  `define E203_DTCM_RAM_AW          (`E203_CFG_DTCM_ADDR_WIDTH-2) 
  `define E203_DTCM_BASE_REGION `E203_ADDR_SIZE-1:`E203_DTCM_ADDR_WIDTH
  
    `define E203_DTCM_DATA_WIDTH  32
    `define E203_DTCM_WMSK_WIDTH  4
  
    `define E203_DTCM_RAM_ECC_DW  7
    `define E203_DTCM_RAM_ECC_MW  1

//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000023 file=e203_hbirdv2/e203_defines/e203_defines.v lines=221-225
  `ifndef E203_HAS_ECC //{
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000023 file=e203_hbirdv2/e203_defines/e203_defines.v lines=221-225
    `define E203_DTCM_RAM_DW      `E203_DTCM_DATA_WIDTH
    `define E203_DTCM_RAM_MW      `E203_DTCM_WMSK_WIDTH
    `define E203_DTCM_OUTS_NUM 1 // If no-ECC, DTCM is 1 cycle latency then only allow 1 oustanding for external agent
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000023 file=e203_hbirdv2/e203_defines/e203_defines.v lines=221-225
  `endif//}
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000023 file=e203_hbirdv2/e203_defines/e203_defines.v lines=221-225


  `define E203_HAS_DTCM_EXTITF
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000024 file=e203_hbirdv2/e203_defines/e203_defines.v lines=205-229
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000024 file=e203_hbirdv2/e203_defines/e203_defines.v lines=205-229








/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////// MULDIV relevant macro
//
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000025 file=e203_hbirdv2/e203_defines/e203_defines.v lines=243-246
  `ifdef E203_CFG_SUPPORT_SHARE_MULDIV//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000025 file=e203_hbirdv2/e203_defines/e203_defines.v lines=243-246
`define E203_SUPPORT_MULDIV
`define E203_SUPPORT_SHARE_MULDIV
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000025 file=e203_hbirdv2/e203_defines/e203_defines.v lines=243-246
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000025 file=e203_hbirdv2/e203_defines/e203_defines.v lines=243-246

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000026 file=e203_hbirdv2/e203_defines/e203_defines.v lines=248-251
  `ifdef E203_CFG_SUPPORT_INDEP_MULDIV//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000026 file=e203_hbirdv2/e203_defines/e203_defines.v lines=248-251
`define E203_SUPPORT_MULDIV
`define E203_SUPPORT_INDEP_MUL_1CYC
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000026 file=e203_hbirdv2/e203_defines/e203_defines.v lines=248-251
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000026 file=e203_hbirdv2/e203_defines/e203_defines.v lines=248-251


/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////// ALU relevant macro
//
`define E203_MULDIV_ADDER_WIDTH 35

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000027 file=e203_hbirdv2/e203_defines/e203_defines.v lines=261-263
  `ifdef E203_CFG_SUPPORT_SHARE_MULDIV
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000027 file=e203_hbirdv2/e203_defines/e203_defines.v lines=261-263
`define E203_ALU_ADDER_WIDTH `E203_MULDIV_ADDER_WIDTH
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000027 file=e203_hbirdv2/e203_defines/e203_defines.v lines=261-263
  `endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000027 file=e203_hbirdv2/e203_defines/e203_defines.v lines=261-263
//__RB_CUT_BEGIN__ type=pp_ifndef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000028 file=e203_hbirdv2/e203_defines/e203_defines.v lines=264-266
  `ifndef E203_CFG_SUPPORT_SHARE_MULDIV
//__RB_CUT_BODY__ type=pp_ifndef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000028 file=e203_hbirdv2/e203_defines/e203_defines.v lines=264-266
`define E203_ALU_ADDER_WIDTH (`E203_XLEN+1)
//__RB_CUT_TAIL__ type=pp_ifndef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000028 file=e203_hbirdv2/e203_defines/e203_defines.v lines=264-266
  `endif
//__RB_CUT_END__ type=pp_ifndef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000028 file=e203_hbirdv2/e203_defines/e203_defines.v lines=264-266


/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////// MAS relevant macro
//
`define E203_ASYNC_FF_LEVELS   2
//`ifdef E203_CFG_OITF_DEPTH_IS_1
//  `define E203_OITF_DEPTH     1
//  `define E203_OITF_DEPTH_IS_1
//`endif
 // To cut down the loop between ALU write-back valid --> oitf_ret_ena --> oitf_ready ---> dispatch_ready --- > alu_i_valid
 //   we exclude the ret_ena from the ready signal
 //   so in order to back2back dispatch, we need at least 2 entries in OITF
`define E203_CFG_OITF_DEPTH_IS_2
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000029 file=e203_hbirdv2/e203_defines/e203_defines.v lines=283-285
`ifdef E203_CFG_SUPPORT_INDEP_MULDIV//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000029 file=e203_hbirdv2/e203_defines/e203_defines.v lines=283-285
  `define E203_CFG_OITF_DEPTH_IS_4
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000029 file=e203_hbirdv2/e203_defines/e203_defines.v lines=283-285
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000029 file=e203_hbirdv2/e203_defines/e203_defines.v lines=283-285
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000030 file=e203_hbirdv2/e203_defines/e203_defines.v lines=286-288
`ifdef E203_CFG_HAS_FPU//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000030 file=e203_hbirdv2/e203_defines/e203_defines.v lines=286-288
  `define E203_CFG_OITF_DEPTH_IS_4
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000030 file=e203_hbirdv2/e203_defines/e203_defines.v lines=286-288
`endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000030 file=e203_hbirdv2/e203_defines/e203_defines.v lines=286-288

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000031 file=e203_hbirdv2/e203_defines/e203_defines.v lines=290-298
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000031:br:000001 file=e203_hbirdv2/e203_defines/e203_defines.v lines=290-293
`ifdef E203_CFG_OITF_DEPTH_IS_4
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000031 file=e203_hbirdv2/e203_defines/e203_defines.v lines=290-298
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000031:br:000001 file=e203_hbirdv2/e203_defines/e203_defines.v lines=290-293
  `define E203_OITF_DEPTH     4
  `define E203_OITF_DEPTH_IS_4
  `define E203_ITAG_WIDTH  2
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000031:br:000001 file=e203_hbirdv2/e203_defines/e203_defines.v lines=290-293
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000031:br:000001 file=e203_hbirdv2/e203_defines/e203_defines.v lines=290-293
//__RB_CUT_BEGIN__ type=pp_elsif_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000031:br:000002 file=e203_hbirdv2/e203_defines/e203_defines.v lines=294-297
`elsif E203_CFG_OITF_DEPTH_IS_2
//__RB_CUT_BODY__ type=pp_elsif_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000031:br:000002 file=e203_hbirdv2/e203_defines/e203_defines.v lines=294-297
  `define E203_OITF_DEPTH     2
  `define E203_OITF_DEPTH_IS_2
  `define E203_ITAG_WIDTH  1
//__RB_CUT_TAIL__ type=pp_elsif_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000031:br:000002 file=e203_hbirdv2/e203_defines/e203_defines.v lines=294-297
//__RB_CUT_END__ type=pp_elsif_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000031:br:000002 file=e203_hbirdv2/e203_defines/e203_defines.v lines=294-297
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000031 file=e203_hbirdv2/e203_defines/e203_defines.v lines=290-298
`endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000031 file=e203_hbirdv2/e203_defines/e203_defines.v lines=290-298

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000033 file=e203_hbirdv2/e203_defines/e203_defines.v lines=300-309
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000033:br:000001 file=e203_hbirdv2/e203_defines/e203_defines.v lines=300-306
`ifdef E203_CFG_HAS_FPU
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000033 file=e203_hbirdv2/e203_defines/e203_defines.v lines=300-309
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000033:br:000001 file=e203_hbirdv2/e203_defines/e203_defines.v lines=300-306
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000032 file=e203_hbirdv2/e203_defines/e203_defines.v lines=301-306
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000032:br:000001 file=e203_hbirdv2/e203_defines/e203_defines.v lines=301-303
  `ifdef E203_CFG_FPU_DOUBLE
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000032 file=e203_hbirdv2/e203_defines/e203_defines.v lines=301-306
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000032:br:000001 file=e203_hbirdv2/e203_defines/e203_defines.v lines=301-303
    `define E203_FPU_DOUBLE     
    `define E203_FLEN 64
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000032:br:000001 file=e203_hbirdv2/e203_defines/e203_defines.v lines=301-303
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000032:br:000001 file=e203_hbirdv2/e203_defines/e203_defines.v lines=301-303
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000032:br:000002 file=e203_hbirdv2/e203_defines/e203_defines.v lines=304-305
  `else
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000032:br:000002 file=e203_hbirdv2/e203_defines/e203_defines.v lines=304-305
    `define E203_FLEN 32
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000032:br:000002 file=e203_hbirdv2/e203_defines/e203_defines.v lines=304-305
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000032:br:000002 file=e203_hbirdv2/e203_defines/e203_defines.v lines=304-305
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000032 file=e203_hbirdv2/e203_defines/e203_defines.v lines=301-306
  `endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000032 file=e203_hbirdv2/e203_defines/e203_defines.v lines=301-306
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000033:br:000001 file=e203_hbirdv2/e203_defines/e203_defines.v lines=300-306
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000033:br:000001 file=e203_hbirdv2/e203_defines/e203_defines.v lines=300-306
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000033:br:000002 file=e203_hbirdv2/e203_defines/e203_defines.v lines=307-308
`else
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000033:br:000002 file=e203_hbirdv2/e203_defines/e203_defines.v lines=307-308
    `define E203_FLEN 32
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000033:br:000002 file=e203_hbirdv2/e203_defines/e203_defines.v lines=307-308
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000033:br:000002 file=e203_hbirdv2/e203_defines/e203_defines.v lines=307-308
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000033 file=e203_hbirdv2/e203_defines/e203_defines.v lines=300-309
`endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000033 file=e203_hbirdv2/e203_defines/e203_defines.v lines=300-309


/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////// Decode relevant macro
//
  `define E203_DECINFO_GRP_WIDTH    3
  `define E203_DECINFO_GRP_ALU      `E203_DECINFO_GRP_WIDTH'd0
  `define E203_DECINFO_GRP_AGU      `E203_DECINFO_GRP_WIDTH'd1
  `define E203_DECINFO_GRP_BJP      `E203_DECINFO_GRP_WIDTH'd2
  `define E203_DECINFO_GRP_CSR      `E203_DECINFO_GRP_WIDTH'd3
  `define E203_DECINFO_GRP_MULDIV   `E203_DECINFO_GRP_WIDTH'd4
  `define E203_DECINFO_GRP_NICE      `E203_DECINFO_GRP_WIDTH'd5
  `define E203_DECINFO_GRP_FPU      `E203_DECINFO_GRP_WIDTH'd6

  `define E203_DECINFO_GRP_FPU_WIDTH    2
  `define E203_DECINFO_GRP_FPU_FLSU     `E203_DECINFO_GRP_FPU_WIDTH'd0
  `define E203_DECINFO_GRP_FPU_FMAC     `E203_DECINFO_GRP_FPU_WIDTH'd1
  `define E203_DECINFO_GRP_FPU_FDIV     `E203_DECINFO_GRP_FPU_WIDTH'd2
  `define E203_DECINFO_GRP_FPU_FMIS     `E203_DECINFO_GRP_FPU_WIDTH'd3

      `define E203_DECINFO_GRP_LSB  0
      `define E203_DECINFO_GRP_MSB  (`E203_DECINFO_GRP_LSB+`E203_DECINFO_GRP_WIDTH-1)
  `define E203_DECINFO_GRP          `E203_DECINFO_GRP_MSB:`E203_DECINFO_GRP_LSB
      `define E203_DECINFO_RV32_LSB  (`E203_DECINFO_GRP_MSB+1)
      `define E203_DECINFO_RV32_MSB  (`E203_DECINFO_RV32_LSB+1-1)
  `define E203_DECINFO_RV32          `E203_DECINFO_RV32_MSB:`E203_DECINFO_RV32_LSB

  `define E203_DECINFO_SUBDECINFO_LSB    (`E203_DECINFO_RV32_MSB+1)

  // ALU group
      `define E203_DECINFO_ALU_ADD_LSB    `E203_DECINFO_SUBDECINFO_LSB
      `define E203_DECINFO_ALU_ADD_MSB    (`E203_DECINFO_ALU_ADD_LSB+1-1)
  `define E203_DECINFO_ALU_ADD    `E203_DECINFO_ALU_ADD_MSB :`E203_DECINFO_ALU_ADD_LSB 
      `define E203_DECINFO_ALU_SUB_LSB    (`E203_DECINFO_ALU_ADD_MSB+1)
      `define E203_DECINFO_ALU_SUB_MSB    (`E203_DECINFO_ALU_SUB_LSB+1-1)
  `define E203_DECINFO_ALU_SUB    `E203_DECINFO_ALU_SUB_MSB :`E203_DECINFO_ALU_SUB_LSB 
      `define E203_DECINFO_ALU_XOR_LSB    (`E203_DECINFO_ALU_SUB_MSB+1)
      `define E203_DECINFO_ALU_XOR_MSB    (`E203_DECINFO_ALU_XOR_LSB+1-1)
  `define E203_DECINFO_ALU_XOR    `E203_DECINFO_ALU_XOR_MSB :`E203_DECINFO_ALU_XOR_LSB 
      `define E203_DECINFO_ALU_SLL_LSB    (`E203_DECINFO_ALU_XOR_MSB+1)
      `define E203_DECINFO_ALU_SLL_MSB    (`E203_DECINFO_ALU_SLL_LSB+1-1)
  `define E203_DECINFO_ALU_SLL    `E203_DECINFO_ALU_SLL_MSB :`E203_DECINFO_ALU_SLL_LSB 
      `define E203_DECINFO_ALU_SRL_LSB    (`E203_DECINFO_ALU_SLL_MSB+1)
      `define E203_DECINFO_ALU_SRL_MSB    (`E203_DECINFO_ALU_SRL_LSB+1-1)
  `define E203_DECINFO_ALU_SRL    `E203_DECINFO_ALU_SRL_MSB :`E203_DECINFO_ALU_SRL_LSB 
      `define E203_DECINFO_ALU_SRA_LSB    (`E203_DECINFO_ALU_SRL_MSB+1)
      `define E203_DECINFO_ALU_SRA_MSB    (`E203_DECINFO_ALU_SRA_LSB+1-1)
  `define E203_DECINFO_ALU_SRA    `E203_DECINFO_ALU_SRA_MSB :`E203_DECINFO_ALU_SRA_LSB 
      `define E203_DECINFO_ALU_OR_LSB    (`E203_DECINFO_ALU_SRA_MSB+1)
      `define E203_DECINFO_ALU_OR_MSB    (`E203_DECINFO_ALU_OR_LSB+1-1)
  `define E203_DECINFO_ALU_OR     `E203_DECINFO_ALU_OR_MSB  :`E203_DECINFO_ALU_OR_LSB  
      `define E203_DECINFO_ALU_AND_LSB    (`E203_DECINFO_ALU_OR_MSB+1)
      `define E203_DECINFO_ALU_AND_MSB    (`E203_DECINFO_ALU_AND_LSB+1-1)
  `define E203_DECINFO_ALU_AND    `E203_DECINFO_ALU_AND_MSB :`E203_DECINFO_ALU_AND_LSB 
      `define E203_DECINFO_ALU_SLT_LSB    (`E203_DECINFO_ALU_AND_MSB+1)
      `define E203_DECINFO_ALU_SLT_MSB    (`E203_DECINFO_ALU_SLT_LSB+1-1)
  `define E203_DECINFO_ALU_SLT    `E203_DECINFO_ALU_SLT_MSB :`E203_DECINFO_ALU_SLT_LSB 
      `define E203_DECINFO_ALU_SLTU_LSB    (`E203_DECINFO_ALU_SLT_MSB+1)
      `define E203_DECINFO_ALU_SLTU_MSB    (`E203_DECINFO_ALU_SLTU_LSB+1-1)
  `define E203_DECINFO_ALU_SLTU   `E203_DECINFO_ALU_SLTU_MSB:`E203_DECINFO_ALU_SLTU_LSB
      `define E203_DECINFO_ALU_LUI_LSB    (`E203_DECINFO_ALU_SLTU_MSB+1)
      `define E203_DECINFO_ALU_LUI_MSB    (`E203_DECINFO_ALU_LUI_LSB+1-1)
  `define E203_DECINFO_ALU_LUI    `E203_DECINFO_ALU_LUI_MSB :`E203_DECINFO_ALU_LUI_LSB 
      `define E203_DECINFO_ALU_OP2IMM_LSB    (`E203_DECINFO_ALU_LUI_MSB+1)
      `define E203_DECINFO_ALU_OP2IMM_MSB    (`E203_DECINFO_ALU_OP2IMM_LSB+1-1)
  `define E203_DECINFO_ALU_OP2IMM    `E203_DECINFO_ALU_OP2IMM_MSB :`E203_DECINFO_ALU_OP2IMM_LSB 
      `define E203_DECINFO_ALU_OP1PC_LSB    (`E203_DECINFO_ALU_OP2IMM_MSB+1)
      `define E203_DECINFO_ALU_OP1PC_MSB    (`E203_DECINFO_ALU_OP1PC_LSB+1-1)
  `define E203_DECINFO_ALU_OP1PC    `E203_DECINFO_ALU_OP1PC_MSB :`E203_DECINFO_ALU_OP1PC_LSB 
      `define E203_DECINFO_ALU_NOP_LSB    (`E203_DECINFO_ALU_OP1PC_MSB+1)
      `define E203_DECINFO_ALU_NOP_MSB    (`E203_DECINFO_ALU_NOP_LSB+1-1)
  `define E203_DECINFO_ALU_NOP    `E203_DECINFO_ALU_NOP_MSB :`E203_DECINFO_ALU_NOP_LSB 
      `define E203_DECINFO_ALU_ECAL_LSB  (`E203_DECINFO_ALU_NOP_MSB+1)
      `define E203_DECINFO_ALU_ECAL_MSB  (`E203_DECINFO_ALU_ECAL_LSB+1-1)
  `define E203_DECINFO_ALU_ECAL   `E203_DECINFO_ALU_ECAL_MSB:`E203_DECINFO_ALU_ECAL_LSB 
      `define E203_DECINFO_ALU_EBRK_LSB  (`E203_DECINFO_ALU_ECAL_MSB+1)
      `define E203_DECINFO_ALU_EBRK_MSB  (`E203_DECINFO_ALU_EBRK_LSB+1-1)
  `define E203_DECINFO_ALU_EBRK   `E203_DECINFO_ALU_EBRK_MSB:`E203_DECINFO_ALU_EBRK_LSB 
      `define E203_DECINFO_ALU_WFI_LSB  (`E203_DECINFO_ALU_EBRK_MSB+1)
      `define E203_DECINFO_ALU_WFI_MSB  (`E203_DECINFO_ALU_WFI_LSB+1-1)
  `define E203_DECINFO_ALU_WFI   `E203_DECINFO_ALU_WFI_MSB:`E203_DECINFO_ALU_WFI_LSB 

  `define E203_DECINFO_ALU_WIDTH    (`E203_DECINFO_ALU_WFI_MSB+1)

   //AGU group
    `define E203_DECINFO_AGU_LOAD_LSB      `E203_DECINFO_SUBDECINFO_LSB
    `define E203_DECINFO_AGU_LOAD_MSB      (`E203_DECINFO_AGU_LOAD_LSB+1-1)   
  `define E203_DECINFO_AGU_LOAD      `E203_DECINFO_AGU_LOAD_MSB   :`E203_DECINFO_AGU_LOAD_LSB   
    `define E203_DECINFO_AGU_STORE_LSB      (`E203_DECINFO_AGU_LOAD_MSB+1)
    `define E203_DECINFO_AGU_STORE_MSB      (`E203_DECINFO_AGU_STORE_LSB+1-1)   
  `define E203_DECINFO_AGU_STORE     `E203_DECINFO_AGU_STORE_MSB  :`E203_DECINFO_AGU_STORE_LSB  
    `define E203_DECINFO_AGU_SIZE_LSB      (`E203_DECINFO_AGU_STORE_MSB+1)
    `define E203_DECINFO_AGU_SIZE_MSB      (`E203_DECINFO_AGU_SIZE_LSB+2-1)   
  `define E203_DECINFO_AGU_SIZE      `E203_DECINFO_AGU_SIZE_MSB   :`E203_DECINFO_AGU_SIZE_LSB   
    `define E203_DECINFO_AGU_USIGN_LSB      (`E203_DECINFO_AGU_SIZE_MSB+1)
    `define E203_DECINFO_AGU_USIGN_MSB      (`E203_DECINFO_AGU_USIGN_LSB+1-1)   
  `define E203_DECINFO_AGU_USIGN     `E203_DECINFO_AGU_USIGN_MSB  :`E203_DECINFO_AGU_USIGN_LSB  
    `define E203_DECINFO_AGU_EXCL_LSB      (`E203_DECINFO_AGU_USIGN_MSB+1)
    `define E203_DECINFO_AGU_EXCL_MSB      (`E203_DECINFO_AGU_EXCL_LSB+1-1)   
  `define E203_DECINFO_AGU_EXCL      `E203_DECINFO_AGU_EXCL_MSB   :`E203_DECINFO_AGU_EXCL_LSB   
    `define E203_DECINFO_AGU_AMO_LSB      (`E203_DECINFO_AGU_EXCL_MSB+1)
    `define E203_DECINFO_AGU_AMO_MSB      (`E203_DECINFO_AGU_AMO_LSB+1-1)   
  `define E203_DECINFO_AGU_AMO       `E203_DECINFO_AGU_AMO_MSB    :`E203_DECINFO_AGU_AMO_LSB    
    `define E203_DECINFO_AGU_AMOSWAP_LSB      (`E203_DECINFO_AGU_AMO_MSB+1)
    `define E203_DECINFO_AGU_AMOSWAP_MSB      (`E203_DECINFO_AGU_AMOSWAP_LSB+1-1)   
  `define E203_DECINFO_AGU_AMOSWAP   `E203_DECINFO_AGU_AMOSWAP_MSB:`E203_DECINFO_AGU_AMOSWAP_LSB
    `define E203_DECINFO_AGU_AMOADD_LSB      (`E203_DECINFO_AGU_AMOSWAP_MSB+1)
    `define E203_DECINFO_AGU_AMOADD_MSB      (`E203_DECINFO_AGU_AMOADD_LSB+1-1)   
  `define E203_DECINFO_AGU_AMOADD    `E203_DECINFO_AGU_AMOADD_MSB :`E203_DECINFO_AGU_AMOADD_LSB 
    `define E203_DECINFO_AGU_AMOAND_LSB      (`E203_DECINFO_AGU_AMOADD_MSB+1)
    `define E203_DECINFO_AGU_AMOAND_MSB      (`E203_DECINFO_AGU_AMOAND_LSB+1-1)   
  `define E203_DECINFO_AGU_AMOAND    `E203_DECINFO_AGU_AMOAND_MSB :`E203_DECINFO_AGU_AMOAND_LSB 
    `define E203_DECINFO_AGU_AMOOR_LSB      (`E203_DECINFO_AGU_AMOAND_MSB+1)
    `define E203_DECINFO_AGU_AMOOR_MSB      (`E203_DECINFO_AGU_AMOOR_LSB+1-1)   
  `define E203_DECINFO_AGU_AMOOR     `E203_DECINFO_AGU_AMOOR_MSB  :`E203_DECINFO_AGU_AMOOR_LSB  
    `define E203_DECINFO_AGU_AMOXOR_LSB      (`E203_DECINFO_AGU_AMOOR_MSB+1)
    `define E203_DECINFO_AGU_AMOXOR_MSB      (`E203_DECINFO_AGU_AMOXOR_LSB+1-1)   
  `define E203_DECINFO_AGU_AMOXOR    `E203_DECINFO_AGU_AMOXOR_MSB :`E203_DECINFO_AGU_AMOXOR_LSB 
    `define E203_DECINFO_AGU_AMOMAX_LSB      (`E203_DECINFO_AGU_AMOXOR_MSB+1)
    `define E203_DECINFO_AGU_AMOMAX_MSB      (`E203_DECINFO_AGU_AMOMAX_LSB+1-1)   
  `define E203_DECINFO_AGU_AMOMAX    `E203_DECINFO_AGU_AMOMAX_MSB :`E203_DECINFO_AGU_AMOMAX_LSB 
    `define E203_DECINFO_AGU_AMOMIN_LSB      (`E203_DECINFO_AGU_AMOMAX_MSB+1)
    `define E203_DECINFO_AGU_AMOMIN_MSB      (`E203_DECINFO_AGU_AMOMIN_LSB+1-1)   
  `define E203_DECINFO_AGU_AMOMIN    `E203_DECINFO_AGU_AMOMIN_MSB :`E203_DECINFO_AGU_AMOMIN_LSB 
    `define E203_DECINFO_AGU_AMOMAXU_LSB      (`E203_DECINFO_AGU_AMOMIN_MSB+1)
    `define E203_DECINFO_AGU_AMOMAXU_MSB      (`E203_DECINFO_AGU_AMOMAXU_LSB+1-1)   
  `define E203_DECINFO_AGU_AMOMAXU   `E203_DECINFO_AGU_AMOMAXU_MSB:`E203_DECINFO_AGU_AMOMAXU_LSB
    `define E203_DECINFO_AGU_AMOMINU_LSB      (`E203_DECINFO_AGU_AMOMAXU_MSB+1)
    `define E203_DECINFO_AGU_AMOMINU_MSB      (`E203_DECINFO_AGU_AMOMINU_LSB+1-1)   
  `define E203_DECINFO_AGU_AMOMINU   `E203_DECINFO_AGU_AMOMINU_MSB:`E203_DECINFO_AGU_AMOMINU_LSB
    `define E203_DECINFO_AGU_OP2IMM_LSB      (`E203_DECINFO_AGU_AMOMINU_MSB+1)
    `define E203_DECINFO_AGU_OP2IMM_MSB      (`E203_DECINFO_AGU_OP2IMM_LSB+1-1)   
  `define E203_DECINFO_AGU_OP2IMM   `E203_DECINFO_AGU_OP2IMM_MSB:`E203_DECINFO_AGU_OP2IMM_LSB

  `define E203_DECINFO_AGU_WIDTH    (`E203_DECINFO_AGU_OP2IMM_MSB+1)

  // Bxx group
      `define E203_DECINFO_BJP_JUMP_LSB `E203_DECINFO_SUBDECINFO_LSB
      `define E203_DECINFO_BJP_JUMP_MSB (`E203_DECINFO_BJP_JUMP_LSB+1-1)
  `define E203_DECINFO_BJP_JUMP   `E203_DECINFO_BJP_JUMP_MSB :`E203_DECINFO_BJP_JUMP_LSB 
      `define E203_DECINFO_BJP_BPRDT_LSB (`E203_DECINFO_BJP_JUMP_MSB+1)
      `define E203_DECINFO_BJP_BPRDT_MSB (`E203_DECINFO_BJP_BPRDT_LSB+1-1)
  `define E203_DECINFO_BJP_BPRDT  `E203_DECINFO_BJP_BPRDT_MSB:`E203_DECINFO_BJP_BPRDT_LSB
      `define E203_DECINFO_BJP_BEQ_LSB (`E203_DECINFO_BJP_BPRDT_MSB+1)
      `define E203_DECINFO_BJP_BEQ_MSB (`E203_DECINFO_BJP_BEQ_LSB+1-1)
  `define E203_DECINFO_BJP_BEQ    `E203_DECINFO_BJP_BEQ_MSB  :`E203_DECINFO_BJP_BEQ_LSB  
      `define E203_DECINFO_BJP_BNE_LSB (`E203_DECINFO_BJP_BEQ_MSB+1)
      `define E203_DECINFO_BJP_BNE_MSB (`E203_DECINFO_BJP_BNE_LSB+1-1)
  `define E203_DECINFO_BJP_BNE    `E203_DECINFO_BJP_BNE_MSB  :`E203_DECINFO_BJP_BNE_LSB  
      `define E203_DECINFO_BJP_BLT_LSB (`E203_DECINFO_BJP_BNE_MSB+1)
      `define E203_DECINFO_BJP_BLT_MSB (`E203_DECINFO_BJP_BLT_LSB+1-1)
  `define E203_DECINFO_BJP_BLT    `E203_DECINFO_BJP_BLT_MSB  :`E203_DECINFO_BJP_BLT_LSB  
      `define E203_DECINFO_BJP_BGT_LSB (`E203_DECINFO_BJP_BLT_MSB+1)
      `define E203_DECINFO_BJP_BGT_MSB (`E203_DECINFO_BJP_BGT_LSB+1-1)
  `define E203_DECINFO_BJP_BGT    `E203_DECINFO_BJP_BGT_MSB  :`E203_DECINFO_BJP_BGT_LSB  
      `define E203_DECINFO_BJP_BLTU_LSB (`E203_DECINFO_BJP_BGT_MSB+1)
      `define E203_DECINFO_BJP_BLTU_MSB (`E203_DECINFO_BJP_BLTU_LSB+1-1)
  `define E203_DECINFO_BJP_BLTU   `E203_DECINFO_BJP_BLTU_MSB :`E203_DECINFO_BJP_BLTU_LSB 
      `define E203_DECINFO_BJP_BGTU_LSB (`E203_DECINFO_BJP_BLTU_MSB+1)
      `define E203_DECINFO_BJP_BGTU_MSB (`E203_DECINFO_BJP_BGTU_LSB+1-1)
  `define E203_DECINFO_BJP_BGTU   `E203_DECINFO_BJP_BGTU_MSB :`E203_DECINFO_BJP_BGTU_LSB 
      `define E203_DECINFO_BJP_BXX_LSB  (`E203_DECINFO_BJP_BGTU_MSB+1)
      `define E203_DECINFO_BJP_BXX_MSB  (`E203_DECINFO_BJP_BXX_LSB+1-1)
  `define E203_DECINFO_BJP_BXX    `E203_DECINFO_BJP_BXX_MSB :`E203_DECINFO_BJP_BXX_LSB
      `define E203_DECINFO_BJP_MRET_LSB  (`E203_DECINFO_BJP_BXX_MSB+1)
      `define E203_DECINFO_BJP_MRET_MSB  (`E203_DECINFO_BJP_MRET_LSB+1-1)
  `define E203_DECINFO_BJP_MRET    `E203_DECINFO_BJP_MRET_MSB :`E203_DECINFO_BJP_MRET_LSB
      `define E203_DECINFO_BJP_DRET_LSB  (`E203_DECINFO_BJP_MRET_MSB+1)
      `define E203_DECINFO_BJP_DRET_MSB  (`E203_DECINFO_BJP_DRET_LSB+1-1)
  `define E203_DECINFO_BJP_DRET    `E203_DECINFO_BJP_DRET_MSB :`E203_DECINFO_BJP_DRET_LSB
      `define E203_DECINFO_BJP_FENCE_LSB  (`E203_DECINFO_BJP_DRET_MSB+1)
      `define E203_DECINFO_BJP_FENCE_MSB  (`E203_DECINFO_BJP_FENCE_LSB+1-1)
  `define E203_DECINFO_BJP_FENCE    `E203_DECINFO_BJP_FENCE_MSB :`E203_DECINFO_BJP_FENCE_LSB
      `define E203_DECINFO_BJP_FENCEI_LSB  (`E203_DECINFO_BJP_FENCE_MSB+1)
      `define E203_DECINFO_BJP_FENCEI_MSB  (`E203_DECINFO_BJP_FENCEI_LSB+1-1)
  `define E203_DECINFO_BJP_FENCEI    `E203_DECINFO_BJP_FENCEI_MSB :`E203_DECINFO_BJP_FENCEI_LSB

`define E203_DECINFO_BJP_WIDTH  (`E203_DECINFO_BJP_FENCEI_MSB+1)


  // CSR group
      `define E203_DECINFO_CSR_CSRRW_LSB   `E203_DECINFO_SUBDECINFO_LSB
      `define E203_DECINFO_CSR_CSRRW_MSB   (`E203_DECINFO_CSR_CSRRW_LSB+1-1)    
  `define E203_DECINFO_CSR_CSRRW   `E203_DECINFO_CSR_CSRRW_MSB:`E203_DECINFO_CSR_CSRRW_LSB    
      `define E203_DECINFO_CSR_CSRRS_LSB   (`E203_DECINFO_CSR_CSRRW_MSB+1)
      `define E203_DECINFO_CSR_CSRRS_MSB   (`E203_DECINFO_CSR_CSRRS_LSB+1-1)    
  `define E203_DECINFO_CSR_CSRRS   `E203_DECINFO_CSR_CSRRS_MSB:`E203_DECINFO_CSR_CSRRS_LSB 
      `define E203_DECINFO_CSR_CSRRC_LSB   (`E203_DECINFO_CSR_CSRRS_MSB+1)
      `define E203_DECINFO_CSR_CSRRC_MSB   (`E203_DECINFO_CSR_CSRRC_LSB+1-1)    
  `define E203_DECINFO_CSR_CSRRC   `E203_DECINFO_CSR_CSRRC_MSB:`E203_DECINFO_CSR_CSRRC_LSB 
      `define E203_DECINFO_CSR_RS1IMM_LSB  (`E203_DECINFO_CSR_CSRRC_MSB+1)
      `define E203_DECINFO_CSR_RS1IMM_MSB   (`E203_DECINFO_CSR_RS1IMM_LSB+1-1)    
  `define E203_DECINFO_CSR_RS1IMM  `E203_DECINFO_CSR_RS1IMM_MSB:`E203_DECINFO_CSR_RS1IMM_LSB
      `define E203_DECINFO_CSR_ZIMMM_LSB   (`E203_DECINFO_CSR_RS1IMM_MSB+1)
      `define E203_DECINFO_CSR_ZIMMM_MSB   (`E203_DECINFO_CSR_ZIMMM_LSB+5-1)    
  `define E203_DECINFO_CSR_ZIMMM   `E203_DECINFO_CSR_ZIMMM_MSB:`E203_DECINFO_CSR_ZIMMM_LSB 
      `define E203_DECINFO_CSR_RS1IS0_LSB  (`E203_DECINFO_CSR_ZIMMM_MSB+1)
      `define E203_DECINFO_CSR_RS1IS0_MSB  (`E203_DECINFO_CSR_RS1IS0_LSB+1-1)    
  `define E203_DECINFO_CSR_RS1IS0  `E203_DECINFO_CSR_RS1IS0_MSB:`E203_DECINFO_CSR_RS1IS0_LSB
      `define E203_DECINFO_CSR_CSRIDX_LSB  (`E203_DECINFO_CSR_RS1IS0_MSB+1)
      `define E203_DECINFO_CSR_CSRIDX_MSB  (`E203_DECINFO_CSR_CSRIDX_LSB+12-1)    
  `define E203_DECINFO_CSR_CSRIDX  `E203_DECINFO_CSR_CSRIDX_MSB:`E203_DECINFO_CSR_CSRIDX_LSB

`define E203_DECINFO_CSR_WIDTH  (`E203_DECINFO_CSR_CSRIDX_MSB+1)

  // NICE group
      `define E203_DECINFO_NICE_INSTR_LSB   `E203_DECINFO_SUBDECINFO_LSB
      `define E203_DECINFO_NICE_INSTR_MSB   (`E203_DECINFO_NICE_INSTR_LSB+27-1)    
  `define E203_DECINFO_NICE_INSTR   `E203_DECINFO_NICE_INSTR_MSB:`E203_DECINFO_NICE_INSTR_LSB    

`define E203_DECINFO_NICE_WIDTH  (`E203_DECINFO_NICE_INSTR_MSB+1)

      `define E203_DECINFO_FPU_GRP_LSB   `E203_DECINFO_SUBDECINFO_LSB
      `define E203_DECINFO_FPU_GRP_MSB   (`E203_DECINFO_FPU_GRP_LSB+`E203_DECINFO_GRP_FPU_WIDTH-1)    
  `define E203_DECINFO_FPU_GRP   `E203_DECINFO_FPU_GRP_MSB:`E203_DECINFO_FPU_GRP_LSB    
      `define E203_DECINFO_FPU_RM_LSB   (`E203_DECINFO_FPU_GRP_MSB+1)
      `define E203_DECINFO_FPU_RM_MSB   (`E203_DECINFO_FPU_RM_LSB+3-1)    
  `define E203_DECINFO_FPU_RM   `E203_DECINFO_FPU_RM_MSB:`E203_DECINFO_FPU_RM_LSB    
      `define E203_DECINFO_FPU_USERM_LSB   (`E203_DECINFO_FPU_RM_MSB+1)
      `define E203_DECINFO_FPU_USERM_MSB   (`E203_DECINFO_FPU_USERM_LSB+1-1)    
  `define E203_DECINFO_FPU_USERM   `E203_DECINFO_FPU_USERM_MSB:`E203_DECINFO_FPU_USERM_LSB    

  // FLSU group
      `define E203_DECINFO_FLSU_LOAD_LSB   (`E203_DECINFO_FPU_USERM_MSB+1)
      `define E203_DECINFO_FLSU_LOAD_MSB   (`E203_DECINFO_FLSU_LOAD_LSB+1-1)    
  `define E203_DECINFO_FLSU_LOAD   `E203_DECINFO_FLSU_LOAD_MSB:`E203_DECINFO_FLSU_LOAD_LSB 
      `define E203_DECINFO_FLSU_STORE_LSB   (`E203_DECINFO_FLSU_LOAD_MSB+1)
      `define E203_DECINFO_FLSU_STORE_MSB   (`E203_DECINFO_FLSU_STORE_LSB+1-1)    
  `define E203_DECINFO_FLSU_STORE   `E203_DECINFO_FLSU_STORE_MSB:`E203_DECINFO_FLSU_STORE_LSB 
      `define E203_DECINFO_FLSU_DOUBLE_LSB  (`E203_DECINFO_FLSU_STORE_MSB+1)
      `define E203_DECINFO_FLSU_DOUBLE_MSB   (`E203_DECINFO_FLSU_DOUBLE_LSB+1-1)    
  `define E203_DECINFO_FLSU_DOUBLE  `E203_DECINFO_FLSU_DOUBLE_MSB:`E203_DECINFO_FLSU_DOUBLE_LSB
      `define E203_DECINFO_FLSU_OP2IMM_LSB   (`E203_DECINFO_FLSU_DOUBLE_MSB+1)
      `define E203_DECINFO_FLSU_OP2IMM_MSB   (`E203_DECINFO_FLSU_OP2IMM_LSB+1-1)    
  `define E203_DECINFO_FLSU_OP2IMM   `E203_DECINFO_FLSU_OP2IMM_MSB:`E203_DECINFO_FLSU_OP2IMM_LSB 

`define E203_DECINFO_FLSU_WIDTH  (`E203_DECINFO_FLSU_OP2IMM_MSB+1)

  // FDIV group
      `define E203_DECINFO_FDIV_DIV_LSB   (`E203_DECINFO_FPU_USERM_MSB+1)
      `define E203_DECINFO_FDIV_DIV_MSB   (`E203_DECINFO_FDIV_DIV_LSB+1-1)    
  `define E203_DECINFO_FDIV_DIV   `E203_DECINFO_FDIV_DIV_MSB:`E203_DECINFO_FDIV_DIV_LSB 
      `define E203_DECINFO_FDIV_SQRT_LSB   (`E203_DECINFO_FDIV_DIV_MSB+1)
      `define E203_DECINFO_FDIV_SQRT_MSB   (`E203_DECINFO_FDIV_SQRT_LSB+1-1)    
  `define E203_DECINFO_FDIV_SQRT   `E203_DECINFO_FDIV_SQRT_MSB:`E203_DECINFO_FDIV_SQRT_LSB 
      `define E203_DECINFO_FDIV_DOUBLE_LSB  (`E203_DECINFO_FDIV_SQRT_MSB+1)
      `define E203_DECINFO_FDIV_DOUBLE_MSB   (`E203_DECINFO_FDIV_DOUBLE_LSB+1-1)    
  `define E203_DECINFO_FDIV_DOUBLE  `E203_DECINFO_FDIV_DOUBLE_MSB:`E203_DECINFO_FDIV_DOUBLE_LSB

`define E203_DECINFO_FDIV_WIDTH  (`E203_DECINFO_FDIV_DOUBLE_MSB+1)

  // FMIS group
      `define E203_DECINFO_FMIS_FSGNJ_LSB   (`E203_DECINFO_FPU_USERM_MSB+1)
      `define E203_DECINFO_FMIS_FSGNJ_MSB   (`E203_DECINFO_FMIS_FSGNJ_LSB+1-1)    
  `define E203_DECINFO_FMIS_FSGNJ   `E203_DECINFO_FMIS_FSGNJ_MSB:`E203_DECINFO_FMIS_FSGNJ_LSB 
      `define E203_DECINFO_FMIS_FSGNJN_LSB   (`E203_DECINFO_FMIS_FSGNJ_MSB+1)
      `define E203_DECINFO_FMIS_FSGNJN_MSB   (`E203_DECINFO_FMIS_FSGNJN_LSB+1-1)    
  `define E203_DECINFO_FMIS_FSGNJN   `E203_DECINFO_FMIS_FSGNJN_MSB:`E203_DECINFO_FMIS_FSGNJN_LSB 
      `define E203_DECINFO_FMIS_FSGNJX_LSB  (`E203_DECINFO_FMIS_FSGNJN_MSB+1)
      `define E203_DECINFO_FMIS_FSGNJX_MSB   (`E203_DECINFO_FMIS_FSGNJX_LSB+1-1)    
  `define E203_DECINFO_FMIS_FSGNJX  `E203_DECINFO_FMIS_FSGNJX_MSB:`E203_DECINFO_FMIS_FSGNJX_LSB
      `define E203_DECINFO_FMIS_FMVXW_LSB  (`E203_DECINFO_FMIS_FSGNJX_MSB+1)
      `define E203_DECINFO_FMIS_FMVXW_MSB   (`E203_DECINFO_FMIS_FMVXW_LSB+1-1)    
  `define E203_DECINFO_FMIS_FMVXW  `E203_DECINFO_FMIS_FMVXW_MSB:`E203_DECINFO_FMIS_FMVXW_LSB
      `define E203_DECINFO_FMIS_FCLASS_LSB  (`E203_DECINFO_FMIS_FMVXW_MSB+1)
      `define E203_DECINFO_FMIS_FCLASS_MSB   (`E203_DECINFO_FMIS_FCLASS_LSB+1-1)    
  `define E203_DECINFO_FMIS_FCLASS  `E203_DECINFO_FMIS_FCLASS_MSB:`E203_DECINFO_FMIS_FCLASS_LSB
      `define E203_DECINFO_FMIS_FMVWX_LSB  (`E203_DECINFO_FMIS_FCLASS_MSB+1)
      `define E203_DECINFO_FMIS_FMVWX_MSB   (`E203_DECINFO_FMIS_FMVWX_LSB+1-1)    
  `define E203_DECINFO_FMIS_FMVWX  `E203_DECINFO_FMIS_FMVWX_MSB:`E203_DECINFO_FMIS_FMVWX_LSB
      `define E203_DECINFO_FMIS_CVTWS_LSB  (`E203_DECINFO_FMIS_FMVWX_MSB+1)
      `define E203_DECINFO_FMIS_CVTWS_MSB   (`E203_DECINFO_FMIS_CVTWS_LSB+1-1)    
  `define E203_DECINFO_FMIS_CVTWS  `E203_DECINFO_FMIS_CVTWS_MSB:`E203_DECINFO_FMIS_CVTWS_LSB
      `define E203_DECINFO_FMIS_CVTWUS_LSB  (`E203_DECINFO_FMIS_CVTWS_MSB+1)
      `define E203_DECINFO_FMIS_CVTWUS_MSB   (`E203_DECINFO_FMIS_CVTWUS_LSB+1-1)    
  `define E203_DECINFO_FMIS_CVTWUS  `E203_DECINFO_FMIS_CVTWUS_MSB:`E203_DECINFO_FMIS_CVTWUS_LSB
      `define E203_DECINFO_FMIS_CVTSW_LSB  (`E203_DECINFO_FMIS_CVTWUS_MSB+1)
      `define E203_DECINFO_FMIS_CVTSW_MSB   (`E203_DECINFO_FMIS_CVTSW_LSB+1-1)    
  `define E203_DECINFO_FMIS_CVTSW  `E203_DECINFO_FMIS_CVTSW_MSB:`E203_DECINFO_FMIS_CVTSW_LSB
      `define E203_DECINFO_FMIS_CVTSWU_LSB  (`E203_DECINFO_FMIS_CVTSW_MSB+1)
      `define E203_DECINFO_FMIS_CVTSWU_MSB   (`E203_DECINFO_FMIS_CVTSWU_LSB+1-1)    
  `define E203_DECINFO_FMIS_CVTSWU  `E203_DECINFO_FMIS_CVTSWU_MSB:`E203_DECINFO_FMIS_CVTSWU_LSB
      `define E203_DECINFO_FMIS_CVTSD_LSB  (`E203_DECINFO_FMIS_CVTSWU_MSB+1)
      `define E203_DECINFO_FMIS_CVTSD_MSB   (`E203_DECINFO_FMIS_CVTSD_LSB+1-1)    
  `define E203_DECINFO_FMIS_CVTSD  `E203_DECINFO_FMIS_CVTSD_MSB:`E203_DECINFO_FMIS_CVTSD_LSB
      `define E203_DECINFO_FMIS_CVTDS_LSB  (`E203_DECINFO_FMIS_CVTSD_MSB+1)
      `define E203_DECINFO_FMIS_CVTDS_MSB   (`E203_DECINFO_FMIS_CVTDS_LSB+1-1)    
  `define E203_DECINFO_FMIS_CVTDS  `E203_DECINFO_FMIS_CVTDS_MSB:`E203_DECINFO_FMIS_CVTDS_LSB
      `define E203_DECINFO_FMIS_CVTWD_LSB  (`E203_DECINFO_FMIS_CVTDS_MSB+1)
      `define E203_DECINFO_FMIS_CVTWD_MSB   (`E203_DECINFO_FMIS_CVTWD_LSB+1-1)    
  `define E203_DECINFO_FMIS_CVTWD  `E203_DECINFO_FMIS_CVTWD_MSB:`E203_DECINFO_FMIS_CVTWD_LSB
      `define E203_DECINFO_FMIS_CVTWUD_LSB  (`E203_DECINFO_FMIS_CVTWD_MSB+1)
      `define E203_DECINFO_FMIS_CVTWUD_MSB   (`E203_DECINFO_FMIS_CVTWUD_LSB+1-1)    
  `define E203_DECINFO_FMIS_CVTWUD  `E203_DECINFO_FMIS_CVTWUD_MSB:`E203_DECINFO_FMIS_CVTWUD_LSB
      `define E203_DECINFO_FMIS_CVTDW_LSB  (`E203_DECINFO_FMIS_CVTWUD_MSB+1)
      `define E203_DECINFO_FMIS_CVTDW_MSB   (`E203_DECINFO_FMIS_CVTDW_LSB+1-1)    
  `define E203_DECINFO_FMIS_CVTDW  `E203_DECINFO_FMIS_CVTDW_MSB:`E203_DECINFO_FMIS_CVTDW_LSB
      `define E203_DECINFO_FMIS_CVTDWU_LSB  (`E203_DECINFO_FMIS_CVTDW_MSB+1)
      `define E203_DECINFO_FMIS_CVTDWU_MSB   (`E203_DECINFO_FMIS_CVTDWU_LSB+1-1)    
  `define E203_DECINFO_FMIS_CVTDWU  `E203_DECINFO_FMIS_CVTDWU_MSB:`E203_DECINFO_FMIS_CVTDWU_LSB
      `define E203_DECINFO_FMIS_DOUBLE_LSB  (`E203_DECINFO_FMIS_CVTDWU_MSB+1)
      `define E203_DECINFO_FMIS_DOUBLE_MSB   (`E203_DECINFO_FMIS_DOUBLE_LSB+1-1)    
  `define E203_DECINFO_FMIS_DOUBLE  `E203_DECINFO_FMIS_DOUBLE_MSB:`E203_DECINFO_FMIS_DOUBLE_LSB

`define E203_DECINFO_FMIS_WIDTH  (`E203_DECINFO_FMIS_DOUBLE_MSB+1)



  // FMAC group
      `define E203_DECINFO_FMAC_FMADD_LSB   (`E203_DECINFO_FPU_USERM_MSB+1)
      `define E203_DECINFO_FMAC_FMADD_MSB   (`E203_DECINFO_FMAC_FMADD_LSB+1-1)    
  `define E203_DECINFO_FMAC_FMADD   `E203_DECINFO_FMAC_FMADD_MSB:`E203_DECINFO_FMAC_FMADD_LSB 
      `define E203_DECINFO_FMAC_FMSUB_LSB   (`E203_DECINFO_FMAC_FMADD_MSB+1)
      `define E203_DECINFO_FMAC_FMSUB_MSB   (`E203_DECINFO_FMAC_FMSUB_LSB+1-1)    
  `define E203_DECINFO_FMAC_FMSUB   `E203_DECINFO_FMAC_FMSUB_MSB:`E203_DECINFO_FMAC_FMSUB_LSB 
      `define E203_DECINFO_FMAC_FNMSUB_LSB  (`E203_DECINFO_FMAC_FMSUB_MSB+1)
      `define E203_DECINFO_FMAC_FNMSUB_MSB   (`E203_DECINFO_FMAC_FNMSUB_LSB+1-1)    
  `define E203_DECINFO_FMAC_FNMSUB  `E203_DECINFO_FMAC_FNMSUB_MSB:`E203_DECINFO_FMAC_FNMSUB_LSB
      `define E203_DECINFO_FMAC_FNMADD_LSB  (`E203_DECINFO_FMAC_FNMSUB_MSB+1)
      `define E203_DECINFO_FMAC_FNMADD_MSB   (`E203_DECINFO_FMAC_FNMADD_LSB+1-1)    
  `define E203_DECINFO_FMAC_FNMADD  `E203_DECINFO_FMAC_FNMADD_MSB:`E203_DECINFO_FMAC_FNMADD_LSB
      `define E203_DECINFO_FMAC_FADD_LSB  (`E203_DECINFO_FMAC_FNMADD_MSB+1)
      `define E203_DECINFO_FMAC_FADD_MSB   (`E203_DECINFO_FMAC_FADD_LSB+1-1)    
  `define E203_DECINFO_FMAC_FADD  `E203_DECINFO_FMAC_FADD_MSB:`E203_DECINFO_FMAC_FADD_LSB
      `define E203_DECINFO_FMAC_FSUB_LSB  (`E203_DECINFO_FMAC_FADD_MSB+1)
      `define E203_DECINFO_FMAC_FSUB_MSB   (`E203_DECINFO_FMAC_FSUB_LSB+1-1)    
  `define E203_DECINFO_FMAC_FSUB  `E203_DECINFO_FMAC_FSUB_MSB:`E203_DECINFO_FMAC_FSUB_LSB
      `define E203_DECINFO_FMAC_FMUL_LSB  (`E203_DECINFO_FMAC_FSUB_MSB+1)
      `define E203_DECINFO_FMAC_FMUL_MSB   (`E203_DECINFO_FMAC_FMUL_LSB+1-1)    
  `define E203_DECINFO_FMAC_FMUL  `E203_DECINFO_FMAC_FMUL_MSB:`E203_DECINFO_FMAC_FMUL_LSB
      `define E203_DECINFO_FMAC_FMIN_LSB  (`E203_DECINFO_FMAC_FMUL_MSB+1)
      `define E203_DECINFO_FMAC_FMIN_MSB   (`E203_DECINFO_FMAC_FMIN_LSB+1-1)    
  `define E203_DECINFO_FMAC_FMIN  `E203_DECINFO_FMAC_FMIN_MSB:`E203_DECINFO_FMAC_FMIN_LSB
      `define E203_DECINFO_FMAC_FMAX_LSB  (`E203_DECINFO_FMAC_FMIN_MSB+1)
      `define E203_DECINFO_FMAC_FMAX_MSB   (`E203_DECINFO_FMAC_FMAX_LSB+1-1)    
  `define E203_DECINFO_FMAC_FMAX  `E203_DECINFO_FMAC_FMAX_MSB:`E203_DECINFO_FMAC_FMAX_LSB
      `define E203_DECINFO_FMAC_FEQ_LSB  (`E203_DECINFO_FMAC_FMAX_MSB+1)
      `define E203_DECINFO_FMAC_FEQ_MSB   (`E203_DECINFO_FMAC_FEQ_LSB+1-1)    
  `define E203_DECINFO_FMAC_FEQ  `E203_DECINFO_FMAC_FEQ_MSB:`E203_DECINFO_FMAC_FEQ_LSB
      `define E203_DECINFO_FMAC_FLT_LSB  (`E203_DECINFO_FMAC_FEQ_MSB+1)
      `define E203_DECINFO_FMAC_FLT_MSB   (`E203_DECINFO_FMAC_FLT_LSB+1-1)    
  `define E203_DECINFO_FMAC_FLT  `E203_DECINFO_FMAC_FLT_MSB:`E203_DECINFO_FMAC_FLT_LSB
      `define E203_DECINFO_FMAC_FLE_LSB  (`E203_DECINFO_FMAC_FLT_MSB+1)
      `define E203_DECINFO_FMAC_FLE_MSB   (`E203_DECINFO_FMAC_FLE_LSB+1-1)    
  `define E203_DECINFO_FMAC_FLE  `E203_DECINFO_FMAC_FLE_MSB:`E203_DECINFO_FMAC_FLE_LSB
      `define E203_DECINFO_FMAC_DOUBLE_LSB  (`E203_DECINFO_FMAC_FLE_MSB+1)
      `define E203_DECINFO_FMAC_DOUBLE_MSB   (`E203_DECINFO_FMAC_DOUBLE_LSB+1-1)    
  `define E203_DECINFO_FMAC_DOUBLE  `E203_DECINFO_FMAC_DOUBLE_MSB:`E203_DECINFO_FMAC_DOUBLE_LSB

`define E203_DECINFO_FMAC_WIDTH  (`E203_DECINFO_FMAC_DOUBLE_MSB+1)

  // MULDIV group
      `define E203_DECINFO_MULDIV_MUL_LSB   `E203_DECINFO_SUBDECINFO_LSB
      `define E203_DECINFO_MULDIV_MUL_MSB   (`E203_DECINFO_MULDIV_MUL_LSB+1-1)    
  `define E203_DECINFO_MULDIV_MUL   `E203_DECINFO_MULDIV_MUL_MSB:`E203_DECINFO_MULDIV_MUL_LSB    
      `define E203_DECINFO_MULDIV_MULH_LSB   (`E203_DECINFO_MULDIV_MUL_MSB+1)
      `define E203_DECINFO_MULDIV_MULH_MSB   (`E203_DECINFO_MULDIV_MULH_LSB+1-1)    
  `define E203_DECINFO_MULDIV_MULH   `E203_DECINFO_MULDIV_MULH_MSB:`E203_DECINFO_MULDIV_MULH_LSB 
      `define E203_DECINFO_MULDIV_MULHSU_LSB   (`E203_DECINFO_MULDIV_MULH_MSB+1)
      `define E203_DECINFO_MULDIV_MULHSU_MSB   (`E203_DECINFO_MULDIV_MULHSU_LSB+1-1)    
  `define E203_DECINFO_MULDIV_MULHSU   `E203_DECINFO_MULDIV_MULHSU_MSB:`E203_DECINFO_MULDIV_MULHSU_LSB 
      `define E203_DECINFO_MULDIV_MULHU_LSB  (`E203_DECINFO_MULDIV_MULHSU_MSB+1)
      `define E203_DECINFO_MULDIV_MULHU_MSB   (`E203_DECINFO_MULDIV_MULHU_LSB+1-1)    
  `define E203_DECINFO_MULDIV_MULHU  `E203_DECINFO_MULDIV_MULHU_MSB:`E203_DECINFO_MULDIV_MULHU_LSB
      `define E203_DECINFO_MULDIV_DIV_LSB   (`E203_DECINFO_MULDIV_MULHU_MSB+1)
      `define E203_DECINFO_MULDIV_DIV_MSB   (`E203_DECINFO_MULDIV_DIV_LSB+1-1)    
  `define E203_DECINFO_MULDIV_DIV   `E203_DECINFO_MULDIV_DIV_MSB:`E203_DECINFO_MULDIV_DIV_LSB 
      `define E203_DECINFO_MULDIV_DIVU_LSB  (`E203_DECINFO_MULDIV_DIV_MSB+1)
      `define E203_DECINFO_MULDIV_DIVU_MSB  (`E203_DECINFO_MULDIV_DIVU_LSB+1-1)    
  `define E203_DECINFO_MULDIV_DIVU  `E203_DECINFO_MULDIV_DIVU_MSB:`E203_DECINFO_MULDIV_DIVU_LSB
      `define E203_DECINFO_MULDIV_REM_LSB   (`E203_DECINFO_MULDIV_DIVU_MSB+1)
      `define E203_DECINFO_MULDIV_REM_MSB   (`E203_DECINFO_MULDIV_REM_LSB+1-1)    
  `define E203_DECINFO_MULDIV_REM   `E203_DECINFO_MULDIV_REM_MSB:`E203_DECINFO_MULDIV_REM_LSB    
      `define E203_DECINFO_MULDIV_REMU_LSB   (`E203_DECINFO_MULDIV_REM_MSB+1)
      `define E203_DECINFO_MULDIV_REMU_MSB   (`E203_DECINFO_MULDIV_REMU_LSB+1-1)    
  `define E203_DECINFO_MULDIV_REMU   `E203_DECINFO_MULDIV_REMU_MSB:`E203_DECINFO_MULDIV_REMU_LSB 
      `define E203_DECINFO_MULDIV_B2B_LSB   (`E203_DECINFO_MULDIV_REMU_MSB+1)
      `define E203_DECINFO_MULDIV_B2B_MSB   (`E203_DECINFO_MULDIV_B2B_LSB+1-1)    
  `define E203_DECINFO_MULDIV_B2B   `E203_DECINFO_MULDIV_B2B_MSB:`E203_DECINFO_MULDIV_B2B_LSB 

`define E203_DECINFO_MULDIV_WIDTH  (`E203_DECINFO_MULDIV_B2B_MSB+1)

// Choose the longest group as the final DEC info width
`define E203_DECINFO_WIDTH  (`E203_DECINFO_NICE_WIDTH+1)






/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////// LSU relevant macro
//
    // Currently is OITF_DEPTH, In the future, if the ROCC
    // support multiple oustanding
    // we can enlarge this number to 2 or 4
    //
    //
  //`ifdef E203_CFG_HAS_NICE //{
  //  //`define E203_LSU_OUTS_NUM 2 
  //`else//}{
    //`define E203_LSU_OUTS_NUM `E203_OITF_DEPTH 
    //`ifdef E203_OITF_DEPTH_IS_1
    //  `define E203_LSU_OUTS_NUM_IS_1
    //`endif
    // Although we defined the OITF depth as 2, but for LSU, we still only allow 1 oustanding for LSU
    `define E203_LSU_OUTS_NUM    1
    `define E203_LSU_OUTS_NUM_IS_1
  //`endif//}

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000034 file=e203_hbirdv2/e203_defines/e203_defines.v lines=724-726
  `ifdef E203_CFG_SUPPORT_AMO//{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000034 file=e203_hbirdv2/e203_defines/e203_defines.v lines=724-726
     `define E203_SUPPORT_AMO
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000034 file=e203_hbirdv2/e203_defines/e203_defines.v lines=724-726
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000034 file=e203_hbirdv2/e203_defines/e203_defines.v lines=724-726
  // No unalign
  //`ifdef E203_CFG_SUPPORT_UNALGNLDST//{
  //   `define E203_SUPPORT_UNALGNLDST
  //`endif//}
 
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////// BIU relevant macro
//
    // Currently is 1, In the future, if the DCache
    // support hit-under-miss (out of order return), then
    // we can enlarge this number to 2 or 4
    //
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000036 file=e203_hbirdv2/e203_defines/e203_defines.v lines=741-749
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000036:br:000001 file=e203_hbirdv2/e203_defines/e203_defines.v lines=741-742
  `ifdef E203_HAS_DCACHE //{
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000036 file=e203_hbirdv2/e203_defines/e203_defines.v lines=741-749
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000036:br:000001 file=e203_hbirdv2/e203_defines/e203_defines.v lines=741-742
    //`define E203_BIU_OUTS_NUM 2 
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000036:br:000001 file=e203_hbirdv2/e203_defines/e203_defines.v lines=741-742
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000036:br:000001 file=e203_hbirdv2/e203_defines/e203_defines.v lines=741-742
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000036:br:000002 file=e203_hbirdv2/e203_defines/e203_defines.v lines=743-748
  `else//}{
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000036:br:000002 file=e203_hbirdv2/e203_defines/e203_defines.v lines=743-748
    `define E203_BIU_OUTS_NUM `E203_LSU_OUTS_NUM 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000035 file=e203_hbirdv2/e203_defines/e203_defines.v lines=745-748
    `ifdef E203_LSU_OUTS_NUM_IS_1
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000035 file=e203_hbirdv2/e203_defines/e203_defines.v lines=745-748
      `define E203_BIU_OUTS_NUM_IS_1
      `define E203_BIU_OUTS_CNT_W  1
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000035 file=e203_hbirdv2/e203_defines/e203_defines.v lines=745-748
    `endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000035 file=e203_hbirdv2/e203_defines/e203_defines.v lines=745-748
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000036:br:000002 file=e203_hbirdv2/e203_defines/e203_defines.v lines=743-748
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000036:br:000002 file=e203_hbirdv2/e203_defines/e203_defines.v lines=743-748
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000036 file=e203_hbirdv2/e203_defines/e203_defines.v lines=741-749
  `endif//}
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000036 file=e203_hbirdv2/e203_defines/e203_defines.v lines=741-749



  // To cut the potential comb loop and critical path between LSU and IFU
  //   and also core and external system, we always cut the ready by BIU Stage
  //   You may argue: Always cut ready may potentially hurt throughput when the DP is just 1
  //   but it is actually a Pseudo proposition because:
  //     * If the BIU oustanding is just 1 in low end core, then we set DP as 1, and there is no 
  //         throughput issue becuase just only 1 oustanding. Even for the PPI or FIO port ideally
  //         if it is 0 cycle response and throughput can be bck-to-back ideally, but we just
  //         sacrafy sacrifice this performance lost, since this is a low end core
  //     * If the BIU oustanding is more than 1 in middle or high end core, then we
  //         set DP as 2 as ping-pong buffer, and then throughput is back-to-back
  //
  `define E203_BIU_CMD_CUT_READY 1
  `define E203_BIU_RSP_CUT_READY 1

  // If oustanding is just 1, then we just need 1 entry
  // If oustanding is more than 1, then we need ping-pong buffer to enhance throughput
  //   You may argue: why not allow 0 depth to save areas, well this is to cut the potential
  //   comb loop and critical path between LSU and IFU and external bus
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000037 file=e203_hbirdv2/e203_defines/e203_defines.v lines=771-777
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000037:br:000001 file=e203_hbirdv2/e203_defines/e203_defines.v lines=771-773
    `ifdef E203_BIU_OUTS_NUM_IS_1
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000037 file=e203_hbirdv2/e203_defines/e203_defines.v lines=771-777
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000037:br:000001 file=e203_hbirdv2/e203_defines/e203_defines.v lines=771-773
  `define E203_BIU_CMD_DP 1
  `define E203_BIU_RSP_DP_RAW 1
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000037:br:000001 file=e203_hbirdv2/e203_defines/e203_defines.v lines=771-773
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000037:br:000001 file=e203_hbirdv2/e203_defines/e203_defines.v lines=771-773
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000037:br:000002 file=e203_hbirdv2/e203_defines/e203_defines.v lines=774-776
    `else
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000037:br:000002 file=e203_hbirdv2/e203_defines/e203_defines.v lines=774-776
  `define E203_BIU_CMD_DP 2
  `define E203_BIU_RSP_DP_RAW 2
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000037:br:000002 file=e203_hbirdv2/e203_defines/e203_defines.v lines=774-776
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000037:br:000002 file=e203_hbirdv2/e203_defines/e203_defines.v lines=774-776
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000037 file=e203_hbirdv2/e203_defines/e203_defines.v lines=771-777
    `endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000037 file=e203_hbirdv2/e203_defines/e203_defines.v lines=771-777
  //  // We allow such configurability to cut timing path of not to save areas
  `define E203_TIMING_BOOST
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000038 file=e203_hbirdv2/e203_defines/e203_defines.v lines=780-784
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000038:br:000001 file=e203_hbirdv2/e203_defines/e203_defines.v lines=780-781
  `ifdef E203_TIMING_BOOST
//__RB_CUT_BODY__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000038 file=e203_hbirdv2/e203_defines/e203_defines.v lines=780-784
//__RB_CUT_BODY__ type=pp_ifdef_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000038:br:000001 file=e203_hbirdv2/e203_defines/e203_defines.v lines=780-781
    `define E203_BIU_RSP_DP        `E203_BIU_RSP_DP_RAW       
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000038:br:000001 file=e203_hbirdv2/e203_defines/e203_defines.v lines=780-781
//__RB_CUT_END__ type=pp_ifdef_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000038:br:000001 file=e203_hbirdv2/e203_defines/e203_defines.v lines=780-781
//__RB_CUT_BEGIN__ type=pp_else_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000038:br:000002 file=e203_hbirdv2/e203_defines/e203_defines.v lines=782-783
  `else
//__RB_CUT_BODY__ type=pp_else_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000038:br:000002 file=e203_hbirdv2/e203_defines/e203_defines.v lines=782-783
    `define E203_BIU_RSP_DP        0
//__RB_CUT_TAIL__ type=pp_else_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000038:br:000002 file=e203_hbirdv2/e203_defines/e203_defines.v lines=782-783
//__RB_CUT_END__ type=pp_else_branch id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000038:br:000002 file=e203_hbirdv2/e203_defines/e203_defines.v lines=782-783
//__RB_CUT_TAIL__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000038 file=e203_hbirdv2/e203_defines/e203_defines.v lines=780-784
  `endif
//__RB_CUT_END__ type=pp_ifdef_block id=e203_hbirdv2/e203_defines/e203_defines.v:pp_blk:000038 file=e203_hbirdv2/e203_defines/e203_defines.v lines=780-784

