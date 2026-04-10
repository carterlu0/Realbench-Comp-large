// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_sd_bd.h for the primary calling header

#include "Vtb_sd_bd__pch.h"
#include "Vtb_sd_bd___024root.h"

VL_ATTR_COLD void Vtb_sd_bd___024root___eval_initial__TOP(Vtb_sd_bd___024root* vlSelf);
VlCoroutine Vtb_sd_bd___024root___eval_initial__TOP__Vtiming__0(Vtb_sd_bd___024root* vlSelf);
VlCoroutine Vtb_sd_bd___024root___eval_initial__TOP__Vtiming__1(Vtb_sd_bd___024root* vlSelf);
VlCoroutine Vtb_sd_bd___024root___eval_initial__TOP__Vtiming__2(Vtb_sd_bd___024root* vlSelf);

void Vtb_sd_bd___024root___eval_initial(Vtb_sd_bd___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root___eval_initial\n"); );
    // Body
    Vtb_sd_bd___024root___eval_initial__TOP(vlSelf);
    Vtb_sd_bd___024root___eval_initial__TOP__Vtiming__0(vlSelf);
    Vtb_sd_bd___024root___eval_initial__TOP__Vtiming__1(vlSelf);
    Vtb_sd_bd___024root___eval_initial__TOP__Vtiming__2(vlSelf);
    vlSelf->__Vtrigprevexpr___TOP__tb_sd_bd__DOT__clk__0 
        = vlSelf->tb_sd_bd__DOT__clk;
    vlSelf->__Vtrigprevexpr___TOP__tb_sd_bd__DOT__rst__0 
        = vlSelf->tb_sd_bd__DOT__rst;
}

VlCoroutine Vtb_sd_bd___024root___eval_initial__TOP__Vtiming__2__0(Vtb_sd_bd___024root* vlSelf);
VlCoroutine Vtb_sd_bd___024root___eval_initial__TOP__Vtiming__2__1(Vtb_sd_bd___024root* vlSelf);

VL_INLINE_OPT VlCoroutine Vtb_sd_bd___024root___eval_initial__TOP__Vtiming__2(Vtb_sd_bd___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root___eval_initial__TOP__Vtiming__2\n"); );
    // Body
    co_await Vtb_sd_bd___024root___eval_initial__TOP__Vtiming__2__0(vlSelf);
    co_await Vtb_sd_bd___024root___eval_initial__TOP__Vtiming__2__1(vlSelf);
}

void Vtb_sd_bd___024root___eval_act(Vtb_sd_bd___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root___eval_act\n"); );
}

void Vtb_sd_bd___024root___nba_sequent__TOP__0(Vtb_sd_bd___024root* vlSelf);
void Vtb_sd_bd___024root___nba_sequent__TOP__1(Vtb_sd_bd___024root* vlSelf);

void Vtb_sd_bd___024root___eval_nba(Vtb_sd_bd___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root___eval_nba\n"); );
    // Body
    if ((1ULL & vlSelf->__VnbaTriggered.word(0U))) {
        Vtb_sd_bd___024root___nba_sequent__TOP__0(vlSelf);
        vlSelf->__Vm_traceActivity[3U] = 1U;
    }
    if ((2ULL & vlSelf->__VnbaTriggered.word(0U))) {
        Vtb_sd_bd___024root___nba_sequent__TOP__1(vlSelf);
        vlSelf->__Vm_traceActivity[4U] = 1U;
    }
}

void Vtb_sd_bd___024root___timing_resume(Vtb_sd_bd___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root___timing_resume\n"); );
    // Body
    if ((1ULL & vlSelf->__VactTriggered.word(0U))) {
        vlSelf->__VtrigSched_h06a4b496__0.resume("@(posedge tb_sd_bd.clk)");
    }
    if ((8ULL & vlSelf->__VactTriggered.word(0U))) {
        vlSelf->__VtrigSched_h06a4b557__0.resume("@(negedge tb_sd_bd.clk)");
    }
    if ((4ULL & vlSelf->__VactTriggered.word(0U))) {
        vlSelf->__VdlySched.resume();
    }
}

void Vtb_sd_bd___024root___timing_commit(Vtb_sd_bd___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root___timing_commit\n"); );
    // Body
    if ((! (1ULL & vlSelf->__VactTriggered.word(0U)))) {
        vlSelf->__VtrigSched_h06a4b496__0.commit("@(posedge tb_sd_bd.clk)");
    }
    if ((! (8ULL & vlSelf->__VactTriggered.word(0U)))) {
        vlSelf->__VtrigSched_h06a4b557__0.commit("@(negedge tb_sd_bd.clk)");
    }
}

void Vtb_sd_bd___024root___eval_triggers__act(Vtb_sd_bd___024root* vlSelf);

bool Vtb_sd_bd___024root___eval_phase__act(Vtb_sd_bd___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root___eval_phase__act\n"); );
    // Init
    VlTriggerVec<4> __VpreTriggered;
    CData/*0:0*/ __VactExecute;
    // Body
    Vtb_sd_bd___024root___eval_triggers__act(vlSelf);
    Vtb_sd_bd___024root___timing_commit(vlSelf);
    __VactExecute = vlSelf->__VactTriggered.any();
    if (__VactExecute) {
        __VpreTriggered.andNot(vlSelf->__VactTriggered, vlSelf->__VnbaTriggered);
        vlSelf->__VnbaTriggered.thisOr(vlSelf->__VactTriggered);
        Vtb_sd_bd___024root___timing_resume(vlSelf);
        Vtb_sd_bd___024root___eval_act(vlSelf);
    }
    return (__VactExecute);
}

bool Vtb_sd_bd___024root___eval_phase__nba(Vtb_sd_bd___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root___eval_phase__nba\n"); );
    // Init
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = vlSelf->__VnbaTriggered.any();
    if (__VnbaExecute) {
        Vtb_sd_bd___024root___eval_nba(vlSelf);
        vlSelf->__VnbaTriggered.clear();
    }
    return (__VnbaExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_sd_bd___024root___dump_triggers__nba(Vtb_sd_bd___024root* vlSelf);
#endif  // VL_DEBUG
#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_sd_bd___024root___dump_triggers__act(Vtb_sd_bd___024root* vlSelf);
#endif  // VL_DEBUG

void Vtb_sd_bd___024root___eval(Vtb_sd_bd___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root___eval\n"); );
    // Init
    IData/*31:0*/ __VnbaIterCount;
    CData/*0:0*/ __VnbaContinue;
    // Body
    __VnbaIterCount = 0U;
    __VnbaContinue = 1U;
    while (__VnbaContinue) {
        if (VL_UNLIKELY((0x64U < __VnbaIterCount))) {
#ifdef VL_DEBUG
            Vtb_sd_bd___024root___dump_triggers__nba(vlSelf);
#endif
            VL_FATAL_MT("sd_bd_testbench.sv", 3, "", "NBA region did not converge.");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        __VnbaContinue = 0U;
        vlSelf->__VactIterCount = 0U;
        vlSelf->__VactContinue = 1U;
        while (vlSelf->__VactContinue) {
            if (VL_UNLIKELY((0x64U < vlSelf->__VactIterCount))) {
#ifdef VL_DEBUG
                Vtb_sd_bd___024root___dump_triggers__act(vlSelf);
#endif
                VL_FATAL_MT("sd_bd_testbench.sv", 3, "", "Active region did not converge.");
            }
            vlSelf->__VactIterCount = ((IData)(1U) 
                                       + vlSelf->__VactIterCount);
            vlSelf->__VactContinue = 0U;
            if (Vtb_sd_bd___024root___eval_phase__act(vlSelf)) {
                vlSelf->__VactContinue = 1U;
            }
        }
        if (Vtb_sd_bd___024root___eval_phase__nba(vlSelf)) {
            __VnbaContinue = 1U;
        }
    }
}

#ifdef VL_DEBUG
void Vtb_sd_bd___024root___eval_debug_assertions(Vtb_sd_bd___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root___eval_debug_assertions\n"); );
}
#endif  // VL_DEBUG
