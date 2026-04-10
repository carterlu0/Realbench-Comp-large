// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vtb__Syms.h"


void Vtb___024root__trace_chg_0_sub_0(Vtb___024root* vlSelf, VerilatedVcd::Buffer* bufp);

void Vtb___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb___024root__trace_chg_0\n"); );
    // Init
    Vtb___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtb___024root*>(voidSelf);
    Vtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    Vtb___024root__trace_chg_0_sub_0((&vlSymsp->TOP), bufp);
}

void Vtb___024root__trace_chg_0_sub_0(Vtb___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb___024root__trace_chg_0_sub_0\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode + 1);
    // Body
    if (VL_UNLIKELY(vlSelfRef.__Vm_traceActivity[1U])) {
        bufp->chgCData(oldp+0,(vlSelfRef.tb__DOT__b_ref),8);
        bufp->chgCData(oldp+1,(vlSelfRef.tb__DOT__b_dut),8);
        bufp->chgBit(oldp+2,(((IData)(vlSelfRef.tb__DOT__b_ref) 
                              == ((IData)(vlSelfRef.tb__DOT__b_ref) 
                                  ^ ((IData)(vlSelfRef.tb__DOT__b_dut) 
                                     ^ (IData)(vlSelfRef.tb__DOT__b_ref))))));
        bufp->chgBit(oldp+3,(((IData)(vlSelfRef.tb__DOT__b_ref) 
                              != ((IData)(vlSelfRef.tb__DOT__b_ref) 
                                  ^ ((IData)(vlSelfRef.tb__DOT__b_dut) 
                                     ^ (IData)(vlSelfRef.tb__DOT__b_ref))))));
    }
    if (VL_UNLIKELY(vlSelfRef.__Vm_traceActivity[2U])) {
        bufp->chgWData(oldp+4,(vlSelfRef.tb__DOT__stats1),160);
    }
    bufp->chgBit(oldp+9,(vlSelfRef.tb__DOT__clk));
    bufp->chgCData(oldp+10,(vlSelfRef.tb__DOT__a),8);
    bufp->chgIData(oldp+11,(vlSelfRef.tb__DOT__stim1__DOT__unnamedblk1__DOT__i),32);
    bufp->chgIData(oldp+12,(vlSelfRef.tb__DOT__stim1__DOT__unnamedblk2__DOT__i),32);
    bufp->chgIData(oldp+13,(vlSelfRef.tb__DOT__stim1__DOT__unnamedblk3__DOT__i),32);
}

void Vtb___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb___024root__trace_cleanup\n"); );
    // Init
    Vtb___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtb___024root*>(voidSelf);
    Vtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    vlSymsp->__Vm_activity = false;
    vlSymsp->TOP.__Vm_traceActivity[0U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[1U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[2U] = 0U;
}
