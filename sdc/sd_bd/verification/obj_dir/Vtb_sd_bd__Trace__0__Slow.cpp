// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vtb_sd_bd__Syms.h"


VL_ATTR_COLD void Vtb_sd_bd___024root__trace_init_sub__TOP__0(Vtb_sd_bd___024root* vlSelf, VerilatedVcd* tracep) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root__trace_init_sub__TOP__0\n"); );
    // Init
    const int c = vlSymsp->__Vm_baseCode;
    // Body
    tracep->pushPrefix("tb_sd_bd", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declArray(c+26,0,"stats1",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::BIT, false,-1, 287,0);
    tracep->declBit(c+122,0,"clk",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+1,0,"rst",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+2,0,"we_m",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+3,0,"dat_in_m",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 15,0);
    tracep->declBus(c+36,0,"free_bd_ref",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+37,0,"free_bd_dut",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBit(c+4,0,"re_s",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+38,0,"ack_o_s_ref",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+39,0,"ack_o_s_dut",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+5,0,"a_cmp",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+40,0,"dat_out_s_ref",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 15,0);
    tracep->declBus(c+41,0,"dat_out_s_dut",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 15,0);
    tracep->declBit(c+42,0,"tb_match",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+43,0,"tb_mismatch",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declArray(c+6,0,"wavedrom_title",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 511,0);
    tracep->declBit(c+22,0,"wavedrom_enable",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->pushPrefix("good1", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBit(c+122,0,"clk",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+1,0,"rst",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+2,0,"we_m",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+3,0,"dat_in_m",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 15,0);
    tracep->declBus(c+36,0,"free_bd",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBit(c+4,0,"re_s",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+38,0,"ack_o_s",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+5,0,"a_cmp",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+40,0,"dat_out_s",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 15,0);
    tracep->declBit(c+44,0,"new_bw",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+45,0,"last_a_cmp",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->pushPrefix("bd_mem", VerilatedTracePrefixType::ARRAY_UNPACKED);
    for (int i = 0; i < 32; ++i) {
        tracep->declBus(c+46+i*1,0,"",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, true,(i+0), 15,0);
    }
    tracep->popPrefix();
    tracep->declBus(c+78,0,"write_cnt",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBus(c+79,0,"read_s_cnt",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBit(c+80,0,"read_cnt",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+81,0,"m_wr_pnt",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+82,0,"s_rd_pnt",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->popPrefix();
    tracep->pushPrefix("stim1", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBit(c+122,0,"clk",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+42,0,"tb_match",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+1,0,"rst",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+2,0,"we_m",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+3,0,"dat_in_m",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 15,0);
    tracep->declBit(c+4,0,"re_s",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+5,0,"a_cmp",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declArray(c+6,0,"wavedrom_title",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 511,0);
    tracep->declBit(c+22,0,"wavedrom_enable",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+23,0,"reset_test__Vstatic__arfail",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::BIT, false,-1);
    tracep->declBit(c+24,0,"reset_test__Vstatic__srfail",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::BIT, false,-1);
    tracep->declBit(c+25,0,"reset_test__Vstatic__datafail",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::BIT, false,-1);
    tracep->popPrefix();
    tracep->pushPrefix("top_module1", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBit(c+122,0,"clk",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+1,0,"rst",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+2,0,"we_m",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+3,0,"dat_in_m",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 15,0);
    tracep->declBus(c+37,0,"free_bd",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBit(c+4,0,"re_s",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+39,0,"ack_o_s",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+5,0,"a_cmp",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+41,0,"dat_out_s",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 15,0);
    tracep->declBit(c+83,0,"new_bw",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+84,0,"last_a_cmp",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->pushPrefix("bd_mem", VerilatedTracePrefixType::ARRAY_UNPACKED);
    for (int i = 0; i < 32; ++i) {
        tracep->declBus(c+85+i*1,0,"",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, true,(i+0), 15,0);
    }
    tracep->popPrefix();
    tracep->declBus(c+117,0,"write_cnt",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBus(c+118,0,"read_s_cnt",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBit(c+119,0,"read_cnt",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+120,0,"m_wr_pnt",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+121,0,"s_rd_pnt",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBit(c+35,0,"delay_re_s",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->popPrefix();
    tracep->popPrefix();
}

VL_ATTR_COLD void Vtb_sd_bd___024root__trace_init_top(Vtb_sd_bd___024root* vlSelf, VerilatedVcd* tracep) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root__trace_init_top\n"); );
    // Body
    Vtb_sd_bd___024root__trace_init_sub__TOP__0(vlSelf, tracep);
}

VL_ATTR_COLD void Vtb_sd_bd___024root__trace_const_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
VL_ATTR_COLD void Vtb_sd_bd___024root__trace_full_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void Vtb_sd_bd___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void Vtb_sd_bd___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/);

VL_ATTR_COLD void Vtb_sd_bd___024root__trace_register(Vtb_sd_bd___024root* vlSelf, VerilatedVcd* tracep) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root__trace_register\n"); );
    // Body
    tracep->addConstCb(&Vtb_sd_bd___024root__trace_const_0, 0U, vlSelf);
    tracep->addFullCb(&Vtb_sd_bd___024root__trace_full_0, 0U, vlSelf);
    tracep->addChgCb(&Vtb_sd_bd___024root__trace_chg_0, 0U, vlSelf);
    tracep->addCleanupCb(&Vtb_sd_bd___024root__trace_cleanup, vlSelf);
}

VL_ATTR_COLD void Vtb_sd_bd___024root__trace_const_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root__trace_const_0\n"); );
    // Init
    Vtb_sd_bd___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtb_sd_bd___024root*>(voidSelf);
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
}

VL_ATTR_COLD void Vtb_sd_bd___024root__trace_full_0_sub_0(Vtb_sd_bd___024root* vlSelf, VerilatedVcd::Buffer* bufp);

VL_ATTR_COLD void Vtb_sd_bd___024root__trace_full_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root__trace_full_0\n"); );
    // Init
    Vtb_sd_bd___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtb_sd_bd___024root*>(voidSelf);
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    Vtb_sd_bd___024root__trace_full_0_sub_0((&vlSymsp->TOP), bufp);
}

VL_ATTR_COLD void Vtb_sd_bd___024root__trace_full_0_sub_0(Vtb_sd_bd___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root__trace_full_0_sub_0\n"); );
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode);
    // Body
    bufp->fullBit(oldp+1,(vlSelf->tb_sd_bd__DOT__rst));
    bufp->fullBit(oldp+2,(vlSelf->tb_sd_bd__DOT__we_m));
    bufp->fullSData(oldp+3,(vlSelf->tb_sd_bd__DOT__dat_in_m),16);
    bufp->fullBit(oldp+4,(vlSelf->tb_sd_bd__DOT__re_s));
    bufp->fullBit(oldp+5,(vlSelf->tb_sd_bd__DOT__a_cmp));
    bufp->fullWData(oldp+6,(vlSelf->tb_sd_bd__DOT__wavedrom_title),512);
    bufp->fullBit(oldp+22,(vlSelf->tb_sd_bd__DOT__wavedrom_enable));
    bufp->fullBit(oldp+23,(vlSelf->tb_sd_bd__DOT__stim1__DOT__reset_test__Vstatic__arfail));
    bufp->fullBit(oldp+24,(vlSelf->tb_sd_bd__DOT__stim1__DOT__reset_test__Vstatic__srfail));
    bufp->fullBit(oldp+25,(vlSelf->tb_sd_bd__DOT__stim1__DOT__reset_test__Vstatic__datafail));
    bufp->fullWData(oldp+26,(vlSelf->tb_sd_bd__DOT__stats1),288);
    bufp->fullBit(oldp+35,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__delay_re_s));
    bufp->fullCData(oldp+36,(vlSelf->tb_sd_bd__DOT__free_bd_ref),5);
    bufp->fullCData(oldp+37,(vlSelf->tb_sd_bd__DOT__free_bd_dut),5);
    bufp->fullBit(oldp+38,(vlSelf->tb_sd_bd__DOT__ack_o_s_ref));
    bufp->fullBit(oldp+39,(vlSelf->tb_sd_bd__DOT__ack_o_s_dut));
    bufp->fullSData(oldp+40,(vlSelf->tb_sd_bd__DOT__dat_out_s_ref),16);
    bufp->fullSData(oldp+41,(vlSelf->tb_sd_bd__DOT__dat_out_s_dut),16);
    bufp->fullBit(oldp+42,((vlSelf->tb_sd_bd__DOT____VdfgRegularize_h4e4634a2_0_0 
                            == (vlSelf->tb_sd_bd__DOT____VdfgRegularize_h4e4634a2_0_0 
                                ^ ((((IData)(vlSelf->tb_sd_bd__DOT__free_bd_dut) 
                                     << 0x11U) | (((IData)(vlSelf->tb_sd_bd__DOT__ack_o_s_dut) 
                                                   << 0x10U) 
                                                  | (IData)(vlSelf->tb_sd_bd__DOT__dat_out_s_dut))) 
                                   ^ vlSelf->tb_sd_bd__DOT____VdfgRegularize_h4e4634a2_0_0)))));
    bufp->fullBit(oldp+43,((vlSelf->tb_sd_bd__DOT____VdfgRegularize_h4e4634a2_0_0 
                            != (vlSelf->tb_sd_bd__DOT____VdfgRegularize_h4e4634a2_0_0 
                                ^ ((((IData)(vlSelf->tb_sd_bd__DOT__free_bd_dut) 
                                     << 0x11U) | (((IData)(vlSelf->tb_sd_bd__DOT__ack_o_s_dut) 
                                                   << 0x10U) 
                                                  | (IData)(vlSelf->tb_sd_bd__DOT__dat_out_s_dut))) 
                                   ^ vlSelf->tb_sd_bd__DOT____VdfgRegularize_h4e4634a2_0_0)))));
    bufp->fullBit(oldp+44,(vlSelf->tb_sd_bd__DOT__good1__DOT__new_bw));
    bufp->fullBit(oldp+45,(vlSelf->tb_sd_bd__DOT__good1__DOT__last_a_cmp));
    bufp->fullSData(oldp+46,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[0]),16);
    bufp->fullSData(oldp+47,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[1]),16);
    bufp->fullSData(oldp+48,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[2]),16);
    bufp->fullSData(oldp+49,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[3]),16);
    bufp->fullSData(oldp+50,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[4]),16);
    bufp->fullSData(oldp+51,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[5]),16);
    bufp->fullSData(oldp+52,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[6]),16);
    bufp->fullSData(oldp+53,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[7]),16);
    bufp->fullSData(oldp+54,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[8]),16);
    bufp->fullSData(oldp+55,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[9]),16);
    bufp->fullSData(oldp+56,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[10]),16);
    bufp->fullSData(oldp+57,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[11]),16);
    bufp->fullSData(oldp+58,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[12]),16);
    bufp->fullSData(oldp+59,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[13]),16);
    bufp->fullSData(oldp+60,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[14]),16);
    bufp->fullSData(oldp+61,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[15]),16);
    bufp->fullSData(oldp+62,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[16]),16);
    bufp->fullSData(oldp+63,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[17]),16);
    bufp->fullSData(oldp+64,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[18]),16);
    bufp->fullSData(oldp+65,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[19]),16);
    bufp->fullSData(oldp+66,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[20]),16);
    bufp->fullSData(oldp+67,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[21]),16);
    bufp->fullSData(oldp+68,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[22]),16);
    bufp->fullSData(oldp+69,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[23]),16);
    bufp->fullSData(oldp+70,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[24]),16);
    bufp->fullSData(oldp+71,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[25]),16);
    bufp->fullSData(oldp+72,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[26]),16);
    bufp->fullSData(oldp+73,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[27]),16);
    bufp->fullSData(oldp+74,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[28]),16);
    bufp->fullSData(oldp+75,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[29]),16);
    bufp->fullSData(oldp+76,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[30]),16);
    bufp->fullSData(oldp+77,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[31]),16);
    bufp->fullCData(oldp+78,(vlSelf->tb_sd_bd__DOT__good1__DOT__write_cnt),2);
    bufp->fullCData(oldp+79,(vlSelf->tb_sd_bd__DOT__good1__DOT__read_s_cnt),2);
    bufp->fullBit(oldp+80,(vlSelf->tb_sd_bd__DOT__good1__DOT__read_cnt));
    bufp->fullCData(oldp+81,(vlSelf->tb_sd_bd__DOT__good1__DOT__m_wr_pnt),5);
    bufp->fullCData(oldp+82,(vlSelf->tb_sd_bd__DOT__good1__DOT__s_rd_pnt),5);
    bufp->fullBit(oldp+83,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__new_bw));
    bufp->fullBit(oldp+84,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__last_a_cmp));
    bufp->fullSData(oldp+85,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[0]),16);
    bufp->fullSData(oldp+86,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[1]),16);
    bufp->fullSData(oldp+87,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[2]),16);
    bufp->fullSData(oldp+88,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[3]),16);
    bufp->fullSData(oldp+89,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[4]),16);
    bufp->fullSData(oldp+90,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[5]),16);
    bufp->fullSData(oldp+91,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[6]),16);
    bufp->fullSData(oldp+92,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[7]),16);
    bufp->fullSData(oldp+93,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[8]),16);
    bufp->fullSData(oldp+94,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[9]),16);
    bufp->fullSData(oldp+95,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[10]),16);
    bufp->fullSData(oldp+96,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[11]),16);
    bufp->fullSData(oldp+97,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[12]),16);
    bufp->fullSData(oldp+98,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[13]),16);
    bufp->fullSData(oldp+99,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[14]),16);
    bufp->fullSData(oldp+100,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[15]),16);
    bufp->fullSData(oldp+101,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[16]),16);
    bufp->fullSData(oldp+102,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[17]),16);
    bufp->fullSData(oldp+103,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[18]),16);
    bufp->fullSData(oldp+104,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[19]),16);
    bufp->fullSData(oldp+105,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[20]),16);
    bufp->fullSData(oldp+106,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[21]),16);
    bufp->fullSData(oldp+107,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[22]),16);
    bufp->fullSData(oldp+108,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[23]),16);
    bufp->fullSData(oldp+109,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[24]),16);
    bufp->fullSData(oldp+110,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[25]),16);
    bufp->fullSData(oldp+111,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[26]),16);
    bufp->fullSData(oldp+112,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[27]),16);
    bufp->fullSData(oldp+113,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[28]),16);
    bufp->fullSData(oldp+114,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[29]),16);
    bufp->fullSData(oldp+115,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[30]),16);
    bufp->fullSData(oldp+116,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[31]),16);
    bufp->fullCData(oldp+117,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__write_cnt),2);
    bufp->fullCData(oldp+118,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__read_s_cnt),2);
    bufp->fullBit(oldp+119,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__read_cnt));
    bufp->fullCData(oldp+120,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__m_wr_pnt),5);
    bufp->fullCData(oldp+121,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__s_rd_pnt),5);
    bufp->fullBit(oldp+122,(vlSelf->tb_sd_bd__DOT__clk));
}
