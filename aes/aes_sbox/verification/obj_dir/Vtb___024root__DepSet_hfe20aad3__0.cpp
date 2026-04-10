// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb.h for the primary calling header

#include "Vtb__pch.h"
#include "Vtb__Syms.h"
#include "Vtb___024root.h"

VL_INLINE_OPT VlCoroutine Vtb___024root___eval_initial__TOP__Vtiming__0(Vtb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb___024root___eval_initial__TOP__Vtiming__0\n"); );
    // Body
    while (1U) {
        co_await vlSelf->__VdlySched.delay(5ULL, nullptr, 
                                           "aes_sbox_testbench.sv", 
                                           17);
        vlSelf->tb__DOT__clk = (1U & (~ (IData)(vlSelf->tb__DOT__clk)));
        ++(vlSymsp->__Vcoverage[1]);
    }
    ++(vlSymsp->__Vcoverage[2]);
}

VL_INLINE_OPT VlCoroutine Vtb___024root___eval_initial__TOP__Vtiming__1(Vtb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb___024root___eval_initial__TOP__Vtiming__1\n"); );
    // Body
    co_await vlSelf->__VdlySched.delay(0xf4240ULL, 
                                       nullptr, "aes_sbox_testbench.sv", 
                                       87);
    VL_WRITEF_NX("TIMEOUT\n",0);
    VL_FINISH_MT("aes_sbox_testbench.sv", 89, "");
    ++(vlSymsp->__Vcoverage[16]);
}

VL_INLINE_OPT VlCoroutine Vtb___024root___eval_initial__TOP__Vtiming__2(Vtb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb___024root___eval_initial__TOP__Vtiming__2\n"); );
    // Body
    vlSelf->tb__DOT__a = 0U;
    vlSelf->tb__DOT__stim1__DOT__unnamedblk1__DOT__i = 0U;
    while (VL_GTS_III(32, 0x100U, vlSelf->tb__DOT__stim1__DOT__unnamedblk1__DOT__i)) {
        co_await vlSelf->__VtrigSched_h95c06bd6__0.trigger(0U, 
                                                           nullptr, 
                                                           "@(posedge tb.clk)", 
                                                           "aes_sbox_stimulus_gen.sv", 
                                                           11);
        vlSelf->tb__DOT__a = (0xffU & vlSelf->tb__DOT__stim1__DOT__unnamedblk1__DOT__i);
        ++(vlSymsp->__Vcoverage[17]);
        vlSelf->tb__DOT__stim1__DOT__unnamedblk1__DOT__i 
            = ((IData)(1U) + vlSelf->tb__DOT__stim1__DOT__unnamedblk1__DOT__i);
    }
    vlSelf->tb__DOT__stim1__DOT__unnamedblk2__DOT__i = 0U;
    while (VL_GTS_III(32, 0x100U, vlSelf->tb__DOT__stim1__DOT__unnamedblk2__DOT__i)) {
        co_await vlSelf->__VtrigSched_h95c06b97__0.trigger(0U, 
                                                           nullptr, 
                                                           "@(negedge tb.clk)", 
                                                           "aes_sbox_stimulus_gen.sv", 
                                                           17);
        vlSelf->tb__DOT__a = (0xffU & vlSelf->tb__DOT__stim1__DOT__unnamedblk2__DOT__i);
        ++(vlSymsp->__Vcoverage[18]);
        vlSelf->tb__DOT__stim1__DOT__unnamedblk2__DOT__i 
            = ((IData)(1U) + vlSelf->tb__DOT__stim1__DOT__unnamedblk2__DOT__i);
    }
    vlSelf->tb__DOT__stim1__DOT__unnamedblk3__DOT__i = 0xffU;
    while (VL_LTES_III(32, 0U, vlSelf->tb__DOT__stim1__DOT__unnamedblk3__DOT__i)) {
        co_await vlSelf->__VtrigSched_h95c06bd6__0.trigger(0U, 
                                                           nullptr, 
                                                           "@(posedge tb.clk)", 
                                                           "aes_sbox_stimulus_gen.sv", 
                                                           23);
        vlSelf->tb__DOT__a = (0xffU & vlSelf->tb__DOT__stim1__DOT__unnamedblk3__DOT__i);
        ++(vlSymsp->__Vcoverage[19]);
        vlSelf->tb__DOT__stim1__DOT__unnamedblk3__DOT__i 
            = (vlSelf->tb__DOT__stim1__DOT__unnamedblk3__DOT__i 
               - (IData)(1U));
    }
    co_await vlSelf->__VtrigSched_h95c06bd6__0.trigger(0U, 
                                                       nullptr, 
                                                       "@(posedge tb.clk)", 
                                                       "aes_sbox_stimulus_gen.sv", 
                                                       29);
    VL_FINISH_MT("aes_sbox_stimulus_gen.sv", 30, "");
    ++(vlSymsp->__Vcoverage[20]);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb___024root___dump_triggers__act(Vtb___024root* vlSelf);
#endif  // VL_DEBUG

void Vtb___024root___eval_triggers__act(Vtb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb___024root___eval_triggers__act\n"); );
    // Body
    vlSelf->__VactTriggered.set(0U, ((IData)(vlSelf->tb__DOT__clk) 
                                     ^ (IData)(vlSelf->__Vtrigprevexpr___TOP__tb__DOT__clk__0)));
    vlSelf->__VactTriggered.set(1U, vlSelf->__VdlySched.awaitingCurrentTime());
    vlSelf->__VactTriggered.set(2U, ((IData)(vlSelf->tb__DOT__clk) 
                                     & (~ (IData)(vlSelf->__Vtrigprevexpr___TOP__tb__DOT__clk__0))));
    vlSelf->__VactTriggered.set(3U, ((~ (IData)(vlSelf->tb__DOT__clk)) 
                                     & (IData)(vlSelf->__Vtrigprevexpr___TOP__tb__DOT__clk__0)));
    vlSelf->__Vtrigprevexpr___TOP__tb__DOT__clk__0 
        = vlSelf->tb__DOT__clk;
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb___024root___dump_triggers__act(vlSelf);
    }
#endif
}

VL_INLINE_OPT void Vtb___024root___act_comb__TOP__0(Vtb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb___024root___act_comb__TOP__0\n"); );
    // Body
    if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) >> 7U)))) {
        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) >> 6U)))) {
            if ((0x20U & (IData)(vlSelf->tb__DOT__a))) {
                if ((0x10U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                  >> 3U)))) {
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[75]);
                                    ++(vlSymsp->__Vcoverage[332]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[76]);
                                    ++(vlSymsp->__Vcoverage[333]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[74]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[73]);
                                }
                            }
                        }
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[72]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[71]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[70]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[69]);
                                }
                            }
                        }
                    }
                    if ((8U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[84]);
                                    ++(vlSymsp->__Vcoverage[341]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[83]);
                                    ++(vlSymsp->__Vcoverage[340]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[82]);
                                    ++(vlSymsp->__Vcoverage[339]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[81]);
                                    ++(vlSymsp->__Vcoverage[338]);
                                }
                            }
                        }
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[80]);
                                    ++(vlSymsp->__Vcoverage[337]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[79]);
                                    ++(vlSymsp->__Vcoverage[336]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[78]);
                                    ++(vlSymsp->__Vcoverage[335]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[77]);
                                    ++(vlSymsp->__Vcoverage[334]);
                                }
                            }
                        }
                    }
                }
                if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                              >> 4U)))) {
                    if ((8U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[68]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[67]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[66]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[65]);
                                }
                            }
                        }
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[64]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[63]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[62]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[61]);
                                }
                            }
                        }
                    }
                    if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                  >> 3U)))) {
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[60]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[59]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[58]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[57]);
                                }
                            }
                        }
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[56]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[55]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[54]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[53]);
                                }
                            }
                        }
                    }
                }
            }
            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                          >> 5U)))) {
                if ((0x10U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((8U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[52]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[51]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[50]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[49]);
                                }
                            }
                        }
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[48]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[47]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[46]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[45]);
                                }
                            }
                        }
                    }
                    if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                  >> 3U)))) {
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[44]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[43]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[42]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[41]);
                                }
                            }
                        }
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[40]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[39]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[38]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[37]);
                                }
                            }
                        }
                    }
                }
                if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                              >> 4U)))) {
                    if ((8U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[36]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[35]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[34]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[33]);
                                }
                            }
                        }
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[32]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[31]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[30]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[29]);
                                }
                            }
                        }
                    }
                    if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                  >> 3U)))) {
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[28]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[27]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[26]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[25]);
                                }
                            }
                        }
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[24]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[23]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[22]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[21]);
                                }
                            }
                        }
                    }
                }
            }
        }
        if ((0x40U & (IData)(vlSelf->tb__DOT__a))) {
            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                          >> 5U)))) {
                if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                              >> 4U)))) {
                    if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                  >> 3U)))) {
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[85]);
                                    ++(vlSymsp->__Vcoverage[342]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[86]);
                                    ++(vlSymsp->__Vcoverage[343]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[87]);
                                    ++(vlSymsp->__Vcoverage[344]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[88]);
                                    ++(vlSymsp->__Vcoverage[345]);
                                }
                            }
                        }
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[89]);
                                    ++(vlSymsp->__Vcoverage[346]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[90]);
                                    ++(vlSymsp->__Vcoverage[347]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[91]);
                                    ++(vlSymsp->__Vcoverage[348]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[92]);
                                    ++(vlSymsp->__Vcoverage[349]);
                                }
                            }
                        }
                    }
                    if ((8U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[94]);
                                    ++(vlSymsp->__Vcoverage[351]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[93]);
                                    ++(vlSymsp->__Vcoverage[350]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[96]);
                                    ++(vlSymsp->__Vcoverage[353]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[95]);
                                    ++(vlSymsp->__Vcoverage[352]);
                                }
                            }
                        }
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[98]);
                                    ++(vlSymsp->__Vcoverage[355]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[97]);
                                    ++(vlSymsp->__Vcoverage[354]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[100]);
                                    ++(vlSymsp->__Vcoverage[357]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[99]);
                                    ++(vlSymsp->__Vcoverage[356]);
                                }
                            }
                        }
                    }
                }
                if ((0x10U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                  >> 3U)))) {
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[101]);
                                    ++(vlSymsp->__Vcoverage[358]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[102]);
                                    ++(vlSymsp->__Vcoverage[359]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[103]);
                                    ++(vlSymsp->__Vcoverage[360]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[104]);
                                    ++(vlSymsp->__Vcoverage[361]);
                                }
                            }
                        }
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[105]);
                                    ++(vlSymsp->__Vcoverage[362]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[106]);
                                    ++(vlSymsp->__Vcoverage[363]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[107]);
                                    ++(vlSymsp->__Vcoverage[364]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[108]);
                                    ++(vlSymsp->__Vcoverage[365]);
                                }
                            }
                        }
                    }
                    if ((8U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[109]);
                                    ++(vlSymsp->__Vcoverage[366]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[110]);
                                    ++(vlSymsp->__Vcoverage[367]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[111]);
                                    ++(vlSymsp->__Vcoverage[368]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[112]);
                                    ++(vlSymsp->__Vcoverage[369]);
                                }
                            }
                        }
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[113]);
                                    ++(vlSymsp->__Vcoverage[370]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[114]);
                                    ++(vlSymsp->__Vcoverage[371]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[115]);
                                    ++(vlSymsp->__Vcoverage[372]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[116]);
                                    ++(vlSymsp->__Vcoverage[373]);
                                }
                            }
                        }
                    }
                }
            }
            if ((0x20U & (IData)(vlSelf->tb__DOT__a))) {
                if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                              >> 4U)))) {
                    if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                  >> 3U)))) {
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[117]);
                                    ++(vlSymsp->__Vcoverage[374]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[118]);
                                    ++(vlSymsp->__Vcoverage[375]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[119]);
                                    ++(vlSymsp->__Vcoverage[376]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[120]);
                                    ++(vlSymsp->__Vcoverage[377]);
                                }
                            }
                        }
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[121]);
                                    ++(vlSymsp->__Vcoverage[378]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[122]);
                                    ++(vlSymsp->__Vcoverage[379]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[123]);
                                    ++(vlSymsp->__Vcoverage[380]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[124]);
                                    ++(vlSymsp->__Vcoverage[381]);
                                }
                            }
                        }
                    }
                    if ((8U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[125]);
                                    ++(vlSymsp->__Vcoverage[382]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[126]);
                                    ++(vlSymsp->__Vcoverage[383]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[128]);
                                    ++(vlSymsp->__Vcoverage[385]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[127]);
                                    ++(vlSymsp->__Vcoverage[384]);
                                }
                            }
                        }
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[132]);
                                    ++(vlSymsp->__Vcoverage[389]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[131]);
                                    ++(vlSymsp->__Vcoverage[388]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[130]);
                                    ++(vlSymsp->__Vcoverage[387]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[129]);
                                    ++(vlSymsp->__Vcoverage[386]);
                                }
                            }
                        }
                    }
                }
                if ((0x10U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                  >> 3U)))) {
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[133]);
                                    ++(vlSymsp->__Vcoverage[390]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[134]);
                                    ++(vlSymsp->__Vcoverage[391]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[135]);
                                    ++(vlSymsp->__Vcoverage[392]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[136]);
                                    ++(vlSymsp->__Vcoverage[393]);
                                }
                            }
                        }
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[137]);
                                    ++(vlSymsp->__Vcoverage[394]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[138]);
                                    ++(vlSymsp->__Vcoverage[395]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[139]);
                                    ++(vlSymsp->__Vcoverage[396]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[140]);
                                    ++(vlSymsp->__Vcoverage[397]);
                                }
                            }
                        }
                    }
                    if ((8U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[142]);
                                    ++(vlSymsp->__Vcoverage[399]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[141]);
                                    ++(vlSymsp->__Vcoverage[398]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[143]);
                                    ++(vlSymsp->__Vcoverage[400]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[144]);
                                    ++(vlSymsp->__Vcoverage[401]);
                                }
                            }
                        }
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[145]);
                                    ++(vlSymsp->__Vcoverage[402]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[146]);
                                    ++(vlSymsp->__Vcoverage[403]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[147]);
                                    ++(vlSymsp->__Vcoverage[404]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[148]);
                                    ++(vlSymsp->__Vcoverage[405]);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    if ((0x80U & (IData)(vlSelf->tb__DOT__a))) {
        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) >> 6U)))) {
            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                          >> 5U)))) {
                if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                              >> 4U)))) {
                    if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                  >> 3U)))) {
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[149]);
                                    ++(vlSymsp->__Vcoverage[406]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[150]);
                                    ++(vlSymsp->__Vcoverage[407]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[151]);
                                    ++(vlSymsp->__Vcoverage[408]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[152]);
                                    ++(vlSymsp->__Vcoverage[409]);
                                }
                            }
                        }
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[153]);
                                    ++(vlSymsp->__Vcoverage[410]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[154]);
                                    ++(vlSymsp->__Vcoverage[411]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[155]);
                                    ++(vlSymsp->__Vcoverage[412]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[156]);
                                    ++(vlSymsp->__Vcoverage[413]);
                                }
                            }
                        }
                    }
                    if ((8U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[157]);
                                    ++(vlSymsp->__Vcoverage[414]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[158]);
                                    ++(vlSymsp->__Vcoverage[415]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[159]);
                                    ++(vlSymsp->__Vcoverage[416]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[160]);
                                    ++(vlSymsp->__Vcoverage[417]);
                                }
                            }
                        }
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[161]);
                                    ++(vlSymsp->__Vcoverage[418]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[162]);
                                    ++(vlSymsp->__Vcoverage[419]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[163]);
                                    ++(vlSymsp->__Vcoverage[420]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[164]);
                                    ++(vlSymsp->__Vcoverage[421]);
                                }
                            }
                        }
                    }
                }
                if ((0x10U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                  >> 3U)))) {
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[165]);
                                    ++(vlSymsp->__Vcoverage[422]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[166]);
                                    ++(vlSymsp->__Vcoverage[423]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[167]);
                                    ++(vlSymsp->__Vcoverage[424]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[168]);
                                    ++(vlSymsp->__Vcoverage[425]);
                                }
                            }
                        }
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[169]);
                                    ++(vlSymsp->__Vcoverage[426]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[170]);
                                    ++(vlSymsp->__Vcoverage[427]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[171]);
                                    ++(vlSymsp->__Vcoverage[428]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[172]);
                                    ++(vlSymsp->__Vcoverage[429]);
                                }
                            }
                        }
                    }
                    if ((8U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[173]);
                                    ++(vlSymsp->__Vcoverage[430]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[174]);
                                    ++(vlSymsp->__Vcoverage[431]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[175]);
                                    ++(vlSymsp->__Vcoverage[432]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[176]);
                                    ++(vlSymsp->__Vcoverage[433]);
                                }
                            }
                        }
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[177]);
                                    ++(vlSymsp->__Vcoverage[434]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[178]);
                                    ++(vlSymsp->__Vcoverage[435]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[179]);
                                    ++(vlSymsp->__Vcoverage[436]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[180]);
                                    ++(vlSymsp->__Vcoverage[437]);
                                }
                            }
                        }
                    }
                }
            }
            if ((0x20U & (IData)(vlSelf->tb__DOT__a))) {
                if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                              >> 4U)))) {
                    if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                  >> 3U)))) {
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[182]);
                                    ++(vlSymsp->__Vcoverage[439]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[181]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[183]);
                                    ++(vlSymsp->__Vcoverage[440]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[184]);
                                    ++(vlSymsp->__Vcoverage[441]);
                                }
                            }
                        }
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[186]);
                                    ++(vlSymsp->__Vcoverage[443]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[185]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[188]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[187]);
                                }
                            }
                        }
                    }
                    if ((8U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[190]);
                                    ++(vlSymsp->__Vcoverage[447]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[189]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[191]);
                                    ++(vlSymsp->__Vcoverage[448]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[192]);
                                    ++(vlSymsp->__Vcoverage[449]);
                                }
                            }
                        }
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[196]);
                                    ++(vlSymsp->__Vcoverage[453]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[195]);
                                    ++(vlSymsp->__Vcoverage[452]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[194]);
                                    ++(vlSymsp->__Vcoverage[451]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[193]);
                                }
                            }
                        }
                    }
                }
                if ((0x10U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((8U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[206]);
                                    ++(vlSymsp->__Vcoverage[463]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[205]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[207]);
                                    ++(vlSymsp->__Vcoverage[464]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[208]);
                                    ++(vlSymsp->__Vcoverage[465]);
                                }
                            }
                        }
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[212]);
                                    ++(vlSymsp->__Vcoverage[469]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[211]);
                                    ++(vlSymsp->__Vcoverage[468]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[210]);
                                    ++(vlSymsp->__Vcoverage[467]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[209]);
                                }
                            }
                        }
                    }
                    if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                  >> 3U)))) {
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[202]);
                                    ++(vlSymsp->__Vcoverage[459]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[201]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[204]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[203]);
                                }
                            }
                        }
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[200]);
                                    ++(vlSymsp->__Vcoverage[457]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[199]);
                                    ++(vlSymsp->__Vcoverage[456]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[198]);
                                    ++(vlSymsp->__Vcoverage[455]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[197]);
                                }
                            }
                        }
                    }
                }
            }
        }
        if ((0x40U & (IData)(vlSelf->tb__DOT__a))) {
            if ((0x20U & (IData)(vlSelf->tb__DOT__a))) {
                if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                              >> 4U)))) {
                    if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                  >> 3U)))) {
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[247]);
                                    ++(vlSymsp->__Vcoverage[504]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[248]);
                                    ++(vlSymsp->__Vcoverage[505]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[246]);
                                    ++(vlSymsp->__Vcoverage[503]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[245]);
                                    ++(vlSymsp->__Vcoverage[502]);
                                }
                            }
                        }
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[249]);
                                    ++(vlSymsp->__Vcoverage[506]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[250]);
                                    ++(vlSymsp->__Vcoverage[507]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[251]);
                                    ++(vlSymsp->__Vcoverage[508]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[252]);
                                    ++(vlSymsp->__Vcoverage[509]);
                                }
                            }
                        }
                    }
                    if ((8U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[253]);
                                    ++(vlSymsp->__Vcoverage[510]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[254]);
                                    ++(vlSymsp->__Vcoverage[511]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[255]);
                                    ++(vlSymsp->__Vcoverage[512]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[256]);
                                    ++(vlSymsp->__Vcoverage[513]);
                                }
                            }
                        }
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[257]);
                                    ++(vlSymsp->__Vcoverage[514]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[258]);
                                    ++(vlSymsp->__Vcoverage[515]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[260]);
                                    ++(vlSymsp->__Vcoverage[517]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[259]);
                                    ++(vlSymsp->__Vcoverage[516]);
                                }
                            }
                        }
                    }
                }
                if ((0x10U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((8U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[271]);
                                    ++(vlSymsp->__Vcoverage[528]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[272]);
                                    ++(vlSymsp->__Vcoverage[529]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[270]);
                                    ++(vlSymsp->__Vcoverage[527]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[269]);
                                    ++(vlSymsp->__Vcoverage[526]);
                                }
                            }
                        }
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[273]);
                                    ++(vlSymsp->__Vcoverage[530]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[274]);
                                    ++(vlSymsp->__Vcoverage[531]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[276]);
                                    ++(vlSymsp->__Vcoverage[533]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[275]);
                                    ++(vlSymsp->__Vcoverage[532]);
                                }
                            }
                        }
                    }
                    if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                  >> 3U)))) {
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[262]);
                                    ++(vlSymsp->__Vcoverage[519]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[261]);
                                    ++(vlSymsp->__Vcoverage[518]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[263]);
                                    ++(vlSymsp->__Vcoverage[520]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[264]);
                                    ++(vlSymsp->__Vcoverage[521]);
                                }
                            }
                        }
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[268]);
                                    ++(vlSymsp->__Vcoverage[525]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[267]);
                                    ++(vlSymsp->__Vcoverage[524]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[266]);
                                    ++(vlSymsp->__Vcoverage[523]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[265]);
                                    ++(vlSymsp->__Vcoverage[522]);
                                }
                            }
                        }
                    }
                }
            }
            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                          >> 5U)))) {
                if ((0x10U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((8U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[239]);
                                    ++(vlSymsp->__Vcoverage[496]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[240]);
                                    ++(vlSymsp->__Vcoverage[497]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[237]);
                                    ++(vlSymsp->__Vcoverage[494]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[238]);
                                    ++(vlSymsp->__Vcoverage[495]);
                                }
                            }
                        }
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[241]);
                                    ++(vlSymsp->__Vcoverage[498]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[242]);
                                    ++(vlSymsp->__Vcoverage[499]);
                                }
                            }
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[243]);
                                    ++(vlSymsp->__Vcoverage[500]);
                                }
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[244]);
                                    ++(vlSymsp->__Vcoverage[501]);
                                }
                            }
                        }
                    }
                    if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                  >> 3U)))) {
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[236]);
                                    ++(vlSymsp->__Vcoverage[493]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[235]);
                                    ++(vlSymsp->__Vcoverage[492]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[234]);
                                    ++(vlSymsp->__Vcoverage[491]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[233]);
                                    ++(vlSymsp->__Vcoverage[490]);
                                }
                            }
                        }
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[232]);
                                    ++(vlSymsp->__Vcoverage[489]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[231]);
                                    ++(vlSymsp->__Vcoverage[488]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[230]);
                                    ++(vlSymsp->__Vcoverage[487]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[229]);
                                    ++(vlSymsp->__Vcoverage[486]);
                                }
                            }
                        }
                    }
                }
                if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                              >> 4U)))) {
                    if ((8U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[228]);
                                    ++(vlSymsp->__Vcoverage[485]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[227]);
                                    ++(vlSymsp->__Vcoverage[484]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[226]);
                                    ++(vlSymsp->__Vcoverage[483]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[225]);
                                    ++(vlSymsp->__Vcoverage[482]);
                                }
                            }
                        }
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[224]);
                                    ++(vlSymsp->__Vcoverage[481]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[223]);
                                    ++(vlSymsp->__Vcoverage[480]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[222]);
                                    ++(vlSymsp->__Vcoverage[479]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[221]);
                                    ++(vlSymsp->__Vcoverage[478]);
                                }
                            }
                        }
                    }
                    if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                  >> 3U)))) {
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[220]);
                                    ++(vlSymsp->__Vcoverage[477]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[219]);
                                    ++(vlSymsp->__Vcoverage[476]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[218]);
                                    ++(vlSymsp->__Vcoverage[475]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[217]);
                                    ++(vlSymsp->__Vcoverage[474]);
                                }
                            }
                        }
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[216]);
                                    ++(vlSymsp->__Vcoverage[473]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[215]);
                                    ++(vlSymsp->__Vcoverage[472]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[214]);
                                    ++(vlSymsp->__Vcoverage[471]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[213]);
                                    ++(vlSymsp->__Vcoverage[470]);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

VL_INLINE_OPT void Vtb___024root___act_comb__TOP__1(Vtb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb___024root___act_comb__TOP__1\n"); );
    // Body
    if ((0x80U & (IData)(vlSelf->tb__DOT__a))) {
        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) >> 6U)))) {
            if ((0x20U & (IData)(vlSelf->tb__DOT__a))) {
                if ((0x10U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((8U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[466]);
                                }
                            }
                        }
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[462]);
                                }
                            }
                        }
                    }
                    if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                  >> 3U)))) {
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[461]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[460]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[458]);
                                }
                            }
                        }
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[454]);
                                }
                            }
                        }
                    }
                }
                if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                              >> 4U)))) {
                    if ((8U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[450]);
                                }
                            }
                        }
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[446]);
                                }
                            }
                        }
                    }
                    if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                  >> 3U)))) {
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[445]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[444]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[442]);
                                }
                            }
                        }
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[438]);
                                }
                            }
                        }
                    }
                }
            }
        }
        if ((0x40U & (IData)(vlSelf->tb__DOT__a))) {
            if ((0x20U & (IData)(vlSelf->tb__DOT__a))) {
                if ((0x10U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((8U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    vlSelf->tb__DOT__b_ref = 0x16U;
                                    vlSelf->tb__DOT__b_dut = 0x16U;
                                } else {
                                    vlSelf->tb__DOT__b_ref = 0xbbU;
                                    vlSelf->tb__DOT__b_dut = 0xbbU;
                                }
                            } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                vlSelf->tb__DOT__b_ref = 0x54U;
                                vlSelf->tb__DOT__b_dut = 0x54U;
                            } else {
                                vlSelf->tb__DOT__b_ref = 0xb0U;
                                vlSelf->tb__DOT__b_dut = 0xb0U;
                            }
                        } else if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                vlSelf->tb__DOT__b_ref = 0xfU;
                                vlSelf->tb__DOT__b_dut = 0xfU;
                            } else {
                                vlSelf->tb__DOT__b_ref = 0x2dU;
                                vlSelf->tb__DOT__b_dut = 0x2dU;
                            }
                        } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                            vlSelf->tb__DOT__b_ref = 0x99U;
                            vlSelf->tb__DOT__b_dut = 0x99U;
                        } else {
                            vlSelf->tb__DOT__b_ref = 0x41U;
                            vlSelf->tb__DOT__b_dut = 0x41U;
                        }
                    } else if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                vlSelf->tb__DOT__b_ref = 0x68U;
                                vlSelf->tb__DOT__b_dut = 0x68U;
                            } else {
                                vlSelf->tb__DOT__b_ref = 0x42U;
                                vlSelf->tb__DOT__b_dut = 0x42U;
                            }
                        } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                            vlSelf->tb__DOT__b_ref = 0xe6U;
                            vlSelf->tb__DOT__b_dut = 0xe6U;
                        } else {
                            vlSelf->tb__DOT__b_ref = 0xbfU;
                            vlSelf->tb__DOT__b_dut = 0xbfU;
                        }
                    } else if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                            vlSelf->tb__DOT__b_ref = 0xdU;
                            vlSelf->tb__DOT__b_dut = 0xdU;
                        } else {
                            vlSelf->tb__DOT__b_ref = 0x89U;
                            vlSelf->tb__DOT__b_dut = 0x89U;
                        }
                    } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0xa1U;
                        vlSelf->tb__DOT__b_dut = 0xa1U;
                    } else {
                        vlSelf->tb__DOT__b_ref = 0x8cU;
                        vlSelf->tb__DOT__b_dut = 0x8cU;
                    }
                } else if ((8U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                vlSelf->tb__DOT__b_ref = 0xdfU;
                                vlSelf->tb__DOT__b_dut = 0xdfU;
                            } else {
                                vlSelf->tb__DOT__b_ref = 0x28U;
                                vlSelf->tb__DOT__b_dut = 0x28U;
                            }
                        } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                            vlSelf->tb__DOT__b_ref = 0x55U;
                            vlSelf->tb__DOT__b_dut = 0x55U;
                        } else {
                            vlSelf->tb__DOT__b_ref = 0xceU;
                            vlSelf->tb__DOT__b_dut = 0xceU;
                        }
                    } else if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                            vlSelf->tb__DOT__b_ref = 0xe9U;
                            vlSelf->tb__DOT__b_dut = 0xe9U;
                        } else {
                            vlSelf->tb__DOT__b_ref = 0x87U;
                            vlSelf->tb__DOT__b_dut = 0x87U;
                        }
                    } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0x1eU;
                        vlSelf->tb__DOT__b_dut = 0x1eU;
                    } else {
                        vlSelf->tb__DOT__b_ref = 0x9bU;
                        vlSelf->tb__DOT__b_dut = 0x9bU;
                    }
                } else if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                            vlSelf->tb__DOT__b_ref = 0x94U;
                            vlSelf->tb__DOT__b_dut = 0x94U;
                        } else {
                            vlSelf->tb__DOT__b_ref = 0x8eU;
                            vlSelf->tb__DOT__b_dut = 0x8eU;
                        }
                    } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0xd9U;
                        vlSelf->tb__DOT__b_dut = 0xd9U;
                    } else {
                        vlSelf->tb__DOT__b_ref = 0x69U;
                        vlSelf->tb__DOT__b_dut = 0x69U;
                    }
                } else if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0x11U;
                        vlSelf->tb__DOT__b_dut = 0x11U;
                    } else {
                        vlSelf->tb__DOT__b_ref = 0x98U;
                        vlSelf->tb__DOT__b_dut = 0x98U;
                    }
                } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0xf8U;
                    vlSelf->tb__DOT__b_dut = 0xf8U;
                } else {
                    vlSelf->tb__DOT__b_ref = 0xe1U;
                    vlSelf->tb__DOT__b_dut = 0xe1U;
                }
            } else if ((0x10U & (IData)(vlSelf->tb__DOT__a))) {
                if ((8U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                vlSelf->tb__DOT__b_ref = 0x9eU;
                                vlSelf->tb__DOT__b_dut = 0x9eU;
                            } else {
                                vlSelf->tb__DOT__b_ref = 0x1dU;
                                vlSelf->tb__DOT__b_dut = 0x1dU;
                            }
                        } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                            vlSelf->tb__DOT__b_ref = 0xc1U;
                            vlSelf->tb__DOT__b_dut = 0xc1U;
                        } else {
                            vlSelf->tb__DOT__b_ref = 0x86U;
                            vlSelf->tb__DOT__b_dut = 0x86U;
                        }
                    } else if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                            vlSelf->tb__DOT__b_ref = 0xb9U;
                            vlSelf->tb__DOT__b_dut = 0xb9U;
                        } else {
                            vlSelf->tb__DOT__b_ref = 0x57U;
                            vlSelf->tb__DOT__b_dut = 0x57U;
                        }
                    } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0x35U;
                        vlSelf->tb__DOT__b_dut = 0x35U;
                    } else {
                        vlSelf->tb__DOT__b_ref = 0x61U;
                        vlSelf->tb__DOT__b_dut = 0x61U;
                    }
                } else if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                            vlSelf->tb__DOT__b_ref = 0xeU;
                            vlSelf->tb__DOT__b_dut = 0xeU;
                        } else {
                            vlSelf->tb__DOT__b_ref = 0xf6U;
                            vlSelf->tb__DOT__b_dut = 0xf6U;
                        }
                    } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 3U;
                        vlSelf->tb__DOT__b_dut = 3U;
                    } else {
                        vlSelf->tb__DOT__b_ref = 0x48U;
                        vlSelf->tb__DOT__b_dut = 0x48U;
                    }
                } else if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0x66U;
                        vlSelf->tb__DOT__b_dut = 0x66U;
                    } else {
                        vlSelf->tb__DOT__b_ref = 0xb5U;
                        vlSelf->tb__DOT__b_dut = 0xb5U;
                    }
                } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0x3eU;
                    vlSelf->tb__DOT__b_dut = 0x3eU;
                } else {
                    vlSelf->tb__DOT__b_ref = 0x70U;
                    vlSelf->tb__DOT__b_dut = 0x70U;
                }
            } else if ((8U & (IData)(vlSelf->tb__DOT__a))) {
                if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                            vlSelf->tb__DOT__b_ref = 0x8aU;
                            vlSelf->tb__DOT__b_dut = 0x8aU;
                        } else {
                            vlSelf->tb__DOT__b_ref = 0x8bU;
                            vlSelf->tb__DOT__b_dut = 0x8bU;
                        }
                    } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0xbdU;
                        vlSelf->tb__DOT__b_dut = 0xbdU;
                    } else {
                        vlSelf->tb__DOT__b_ref = 0x4bU;
                        vlSelf->tb__DOT__b_dut = 0x4bU;
                    }
                } else if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0x1fU;
                        vlSelf->tb__DOT__b_dut = 0x1fU;
                    } else {
                        vlSelf->tb__DOT__b_ref = 0x74U;
                        vlSelf->tb__DOT__b_dut = 0x74U;
                    }
                } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0xddU;
                    vlSelf->tb__DOT__b_dut = 0xddU;
                } else {
                    vlSelf->tb__DOT__b_ref = 0xe8U;
                    vlSelf->tb__DOT__b_dut = 0xe8U;
                }
            } else if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0xc6U;
                        vlSelf->tb__DOT__b_dut = 0xc6U;
                    } else {
                        vlSelf->tb__DOT__b_ref = 0xb4U;
                        vlSelf->tb__DOT__b_dut = 0xb4U;
                    }
                } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0xa6U;
                    vlSelf->tb__DOT__b_dut = 0xa6U;
                } else {
                    vlSelf->tb__DOT__b_ref = 0x1cU;
                    vlSelf->tb__DOT__b_dut = 0x1cU;
                }
            } else if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0x2eU;
                    vlSelf->tb__DOT__b_dut = 0x2eU;
                } else {
                    vlSelf->tb__DOT__b_ref = 0x25U;
                    vlSelf->tb__DOT__b_dut = 0x25U;
                }
            } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                vlSelf->tb__DOT__b_ref = 0x78U;
                vlSelf->tb__DOT__b_dut = 0x78U;
            } else {
                vlSelf->tb__DOT__b_ref = 0xbaU;
                vlSelf->tb__DOT__b_dut = 0xbaU;
            }
        } else if ((0x20U & (IData)(vlSelf->tb__DOT__a))) {
            if ((0x10U & (IData)(vlSelf->tb__DOT__a))) {
                if ((8U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                vlSelf->tb__DOT__b_ref = 8U;
                                vlSelf->tb__DOT__b_dut = 8U;
                            } else {
                                vlSelf->tb__DOT__b_ref = 0xaeU;
                                vlSelf->tb__DOT__b_dut = 0xaeU;
                            }
                        } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                            vlSelf->tb__DOT__b_ref = 0x7aU;
                            vlSelf->tb__DOT__b_dut = 0x7aU;
                        } else {
                            vlSelf->tb__DOT__b_ref = 0x65U;
                            vlSelf->tb__DOT__b_dut = 0x65U;
                        }
                    } else if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                            vlSelf->tb__DOT__b_ref = 0xeaU;
                            vlSelf->tb__DOT__b_dut = 0xeaU;
                        } else {
                            vlSelf->tb__DOT__b_ref = 0xf4U;
                            vlSelf->tb__DOT__b_dut = 0xf4U;
                        }
                    } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0x56U;
                        vlSelf->tb__DOT__b_dut = 0x56U;
                    } else {
                        vlSelf->tb__DOT__b_ref = 0x6cU;
                        vlSelf->tb__DOT__b_dut = 0x6cU;
                    }
                } else if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                            vlSelf->tb__DOT__b_ref = 0xa9U;
                            vlSelf->tb__DOT__b_dut = 0xa9U;
                        } else {
                            vlSelf->tb__DOT__b_ref = 0x4eU;
                            vlSelf->tb__DOT__b_dut = 0x4eU;
                        }
                    } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0xd5U;
                        vlSelf->tb__DOT__b_dut = 0xd5U;
                    } else {
                        vlSelf->tb__DOT__b_ref = 0x8dU;
                        vlSelf->tb__DOT__b_dut = 0x8dU;
                    }
                } else if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0x6dU;
                        vlSelf->tb__DOT__b_dut = 0x6dU;
                    } else {
                        vlSelf->tb__DOT__b_ref = 0x37U;
                        vlSelf->tb__DOT__b_dut = 0x37U;
                    }
                } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0xc8U;
                    vlSelf->tb__DOT__b_dut = 0xc8U;
                } else {
                    vlSelf->tb__DOT__b_ref = 0xe7U;
                    vlSelf->tb__DOT__b_dut = 0xe7U;
                }
            } else if ((8U & (IData)(vlSelf->tb__DOT__a))) {
                if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                            vlSelf->tb__DOT__b_ref = 0x79U;
                            vlSelf->tb__DOT__b_dut = 0x79U;
                        } else {
                            vlSelf->tb__DOT__b_ref = 0xe4U;
                            vlSelf->tb__DOT__b_dut = 0xe4U;
                        }
                    } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0x95U;
                        vlSelf->tb__DOT__b_dut = 0x95U;
                    } else {
                        vlSelf->tb__DOT__b_ref = 0x91U;
                        vlSelf->tb__DOT__b_dut = 0x91U;
                    }
                } else if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0x62U;
                        vlSelf->tb__DOT__b_dut = 0x62U;
                    } else {
                        vlSelf->tb__DOT__b_ref = 0xacU;
                        vlSelf->tb__DOT__b_dut = 0xacU;
                    }
                } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0xd3U;
                    vlSelf->tb__DOT__b_dut = 0xd3U;
                } else {
                    vlSelf->tb__DOT__b_ref = 0xc2U;
                    vlSelf->tb__DOT__b_dut = 0xc2U;
                }
            } else if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0x5cU;
                        vlSelf->tb__DOT__b_dut = 0x5cU;
                    } else {
                        vlSelf->tb__DOT__b_ref = 0x24U;
                        vlSelf->tb__DOT__b_dut = 0x24U;
                    }
                } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 6U;
                    vlSelf->tb__DOT__b_dut = 6U;
                } else {
                    vlSelf->tb__DOT__b_ref = 0x49U;
                    vlSelf->tb__DOT__b_dut = 0x49U;
                }
            } else if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0xaU;
                    vlSelf->tb__DOT__b_dut = 0xaU;
                } else {
                    vlSelf->tb__DOT__b_ref = 0x3aU;
                    vlSelf->tb__DOT__b_dut = 0x3aU;
                }
            } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                vlSelf->tb__DOT__b_ref = 0x32U;
                vlSelf->tb__DOT__b_dut = 0x32U;
            } else {
                vlSelf->tb__DOT__b_ref = 0xe0U;
                vlSelf->tb__DOT__b_dut = 0xe0U;
            }
        } else if ((0x10U & (IData)(vlSelf->tb__DOT__a))) {
            if ((8U & (IData)(vlSelf->tb__DOT__a))) {
                if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                            vlSelf->tb__DOT__b_ref = 0xdbU;
                            vlSelf->tb__DOT__b_dut = 0xdbU;
                        } else {
                            vlSelf->tb__DOT__b_ref = 0xbU;
                            vlSelf->tb__DOT__b_dut = 0xbU;
                        }
                    } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0x5eU;
                        vlSelf->tb__DOT__b_dut = 0x5eU;
                    } else {
                        vlSelf->tb__DOT__b_ref = 0xdeU;
                        vlSelf->tb__DOT__b_dut = 0xdeU;
                    }
                } else if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0x14U;
                        vlSelf->tb__DOT__b_dut = 0x14U;
                    } else {
                        vlSelf->tb__DOT__b_ref = 0xb8U;
                        vlSelf->tb__DOT__b_dut = 0xb8U;
                    }
                } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0xeeU;
                    vlSelf->tb__DOT__b_dut = 0xeeU;
                } else {
                    vlSelf->tb__DOT__b_ref = 0x46U;
                    vlSelf->tb__DOT__b_dut = 0x46U;
                }
            } else if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0x88U;
                        vlSelf->tb__DOT__b_dut = 0x88U;
                    } else {
                        vlSelf->tb__DOT__b_ref = 0x90U;
                        vlSelf->tb__DOT__b_dut = 0x90U;
                    }
                } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0x2aU;
                    vlSelf->tb__DOT__b_dut = 0x2aU;
                } else {
                    vlSelf->tb__DOT__b_ref = 0x22U;
                    vlSelf->tb__DOT__b_dut = 0x22U;
                }
            } else if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0xdcU;
                    vlSelf->tb__DOT__b_dut = 0xdcU;
                } else {
                    vlSelf->tb__DOT__b_ref = 0x4fU;
                    vlSelf->tb__DOT__b_dut = 0x4fU;
                }
            } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                vlSelf->tb__DOT__b_ref = 0x81U;
                vlSelf->tb__DOT__b_dut = 0x81U;
            } else {
                vlSelf->tb__DOT__b_ref = 0x60U;
                vlSelf->tb__DOT__b_dut = 0x60U;
            }
        } else if ((8U & (IData)(vlSelf->tb__DOT__a))) {
            if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0x73U;
                        vlSelf->tb__DOT__b_dut = 0x73U;
                    } else {
                        vlSelf->tb__DOT__b_ref = 0x19U;
                        vlSelf->tb__DOT__b_dut = 0x19U;
                    }
                } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0x5dU;
                    vlSelf->tb__DOT__b_dut = 0x5dU;
                } else {
                    vlSelf->tb__DOT__b_ref = 0x64U;
                    vlSelf->tb__DOT__b_dut = 0x64U;
                }
            } else if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0x3dU;
                    vlSelf->tb__DOT__b_dut = 0x3dU;
                } else {
                    vlSelf->tb__DOT__b_ref = 0x7eU;
                    vlSelf->tb__DOT__b_dut = 0x7eU;
                }
            } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                vlSelf->tb__DOT__b_ref = 0xa7U;
                vlSelf->tb__DOT__b_dut = 0xa7U;
            } else {
                vlSelf->tb__DOT__b_ref = 0xc4U;
                vlSelf->tb__DOT__b_dut = 0xc4U;
            }
        } else if ((4U & (IData)(vlSelf->tb__DOT__a))) {
            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0x17U;
                    vlSelf->tb__DOT__b_dut = 0x17U;
                } else {
                    vlSelf->tb__DOT__b_ref = 0x44U;
                    vlSelf->tb__DOT__b_dut = 0x44U;
                }
            } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                vlSelf->tb__DOT__b_ref = 0x97U;
                vlSelf->tb__DOT__b_dut = 0x97U;
            } else {
                vlSelf->tb__DOT__b_ref = 0x5fU;
                vlSelf->tb__DOT__b_dut = 0x5fU;
            }
        } else if ((2U & (IData)(vlSelf->tb__DOT__a))) {
            if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                vlSelf->tb__DOT__b_ref = 0xecU;
                vlSelf->tb__DOT__b_dut = 0xecU;
            } else {
                vlSelf->tb__DOT__b_ref = 0x13U;
                vlSelf->tb__DOT__b_dut = 0x13U;
            }
        } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
            vlSelf->tb__DOT__b_ref = 0xcU;
            vlSelf->tb__DOT__b_dut = 0xcU;
        } else {
            vlSelf->tb__DOT__b_ref = 0xcdU;
            vlSelf->tb__DOT__b_dut = 0xcdU;
        }
    } else if ((0x40U & (IData)(vlSelf->tb__DOT__a))) {
        if ((0x20U & (IData)(vlSelf->tb__DOT__a))) {
            if ((0x10U & (IData)(vlSelf->tb__DOT__a))) {
                if ((8U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                vlSelf->tb__DOT__b_ref = 0xd2U;
                                vlSelf->tb__DOT__b_dut = 0xd2U;
                            } else {
                                vlSelf->tb__DOT__b_ref = 0xf3U;
                                vlSelf->tb__DOT__b_dut = 0xf3U;
                            }
                        } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                            vlSelf->tb__DOT__b_ref = 0xffU;
                            vlSelf->tb__DOT__b_dut = 0xffU;
                        } else {
                            vlSelf->tb__DOT__b_ref = 0x10U;
                            vlSelf->tb__DOT__b_dut = 0x10U;
                        }
                    } else if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                            vlSelf->tb__DOT__b_ref = 0x21U;
                            vlSelf->tb__DOT__b_dut = 0x21U;
                        } else {
                            vlSelf->tb__DOT__b_ref = 0xdaU;
                            vlSelf->tb__DOT__b_dut = 0xdaU;
                        }
                    } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0xb6U;
                        vlSelf->tb__DOT__b_dut = 0xb6U;
                    } else {
                        vlSelf->tb__DOT__b_ref = 0xbcU;
                        vlSelf->tb__DOT__b_dut = 0xbcU;
                    }
                } else if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                            vlSelf->tb__DOT__b_ref = 0xf5U;
                            vlSelf->tb__DOT__b_dut = 0xf5U;
                        } else {
                            vlSelf->tb__DOT__b_ref = 0x38U;
                            vlSelf->tb__DOT__b_dut = 0x38U;
                        }
                    } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0x9dU;
                        vlSelf->tb__DOT__b_dut = 0x9dU;
                    } else {
                        vlSelf->tb__DOT__b_ref = 0x92U;
                        vlSelf->tb__DOT__b_dut = 0x92U;
                    }
                } else if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0x8fU;
                        vlSelf->tb__DOT__b_dut = 0x8fU;
                    } else {
                        vlSelf->tb__DOT__b_ref = 0x40U;
                        vlSelf->tb__DOT__b_dut = 0x40U;
                    }
                } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0xa3U;
                    vlSelf->tb__DOT__b_dut = 0xa3U;
                } else {
                    vlSelf->tb__DOT__b_ref = 0x51U;
                    vlSelf->tb__DOT__b_dut = 0x51U;
                }
            } else if ((8U & (IData)(vlSelf->tb__DOT__a))) {
                if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                            vlSelf->tb__DOT__b_ref = 0xa8U;
                            vlSelf->tb__DOT__b_dut = 0xa8U;
                        } else {
                            vlSelf->tb__DOT__b_ref = 0x9fU;
                            vlSelf->tb__DOT__b_dut = 0x9fU;
                        }
                    } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0x3cU;
                        vlSelf->tb__DOT__b_dut = 0x3cU;
                    } else {
                        vlSelf->tb__DOT__b_ref = 0x50U;
                        vlSelf->tb__DOT__b_dut = 0x50U;
                    }
                } else if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0x7fU;
                        vlSelf->tb__DOT__b_dut = 0x7fU;
                    } else {
                        vlSelf->tb__DOT__b_ref = 2U;
                        vlSelf->tb__DOT__b_dut = 2U;
                    }
                } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0xf9U;
                    vlSelf->tb__DOT__b_dut = 0xf9U;
                } else {
                    vlSelf->tb__DOT__b_ref = 0x45U;
                    vlSelf->tb__DOT__b_dut = 0x45U;
                }
            } else if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0x85U;
                        vlSelf->tb__DOT__b_dut = 0x85U;
                    } else {
                        vlSelf->tb__DOT__b_ref = 0x33U;
                        vlSelf->tb__DOT__b_dut = 0x33U;
                    }
                } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0x4dU;
                    vlSelf->tb__DOT__b_dut = 0x4dU;
                } else {
                    vlSelf->tb__DOT__b_ref = 0x43U;
                    vlSelf->tb__DOT__b_dut = 0x43U;
                }
            } else if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0xfbU;
                    vlSelf->tb__DOT__b_dut = 0xfbU;
                } else {
                    vlSelf->tb__DOT__b_ref = 0xaaU;
                    vlSelf->tb__DOT__b_dut = 0xaaU;
                }
            } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                vlSelf->tb__DOT__b_ref = 0xefU;
                vlSelf->tb__DOT__b_dut = 0xefU;
            } else {
                vlSelf->tb__DOT__b_ref = 0xd0U;
                vlSelf->tb__DOT__b_dut = 0xd0U;
            }
        } else if ((0x10U & (IData)(vlSelf->tb__DOT__a))) {
            if ((8U & (IData)(vlSelf->tb__DOT__a))) {
                if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                            vlSelf->tb__DOT__b_ref = 0xcfU;
                            vlSelf->tb__DOT__b_dut = 0xcfU;
                        } else {
                            vlSelf->tb__DOT__b_ref = 0x58U;
                            vlSelf->tb__DOT__b_dut = 0x58U;
                        }
                    } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0x4cU;
                        vlSelf->tb__DOT__b_dut = 0x4cU;
                    } else {
                        vlSelf->tb__DOT__b_ref = 0x4aU;
                        vlSelf->tb__DOT__b_dut = 0x4aU;
                    }
                } else if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0x39U;
                        vlSelf->tb__DOT__b_dut = 0x39U;
                    } else {
                        vlSelf->tb__DOT__b_ref = 0xbeU;
                        vlSelf->tb__DOT__b_dut = 0xbeU;
                    }
                } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0xcbU;
                    vlSelf->tb__DOT__b_dut = 0xcbU;
                } else {
                    vlSelf->tb__DOT__b_ref = 0x6aU;
                    vlSelf->tb__DOT__b_dut = 0x6aU;
                }
            } else if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0x5bU;
                        vlSelf->tb__DOT__b_dut = 0x5bU;
                    } else {
                        vlSelf->tb__DOT__b_ref = 0xb1U;
                        vlSelf->tb__DOT__b_dut = 0xb1U;
                    }
                } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0xfcU;
                    vlSelf->tb__DOT__b_dut = 0xfcU;
                } else {
                    vlSelf->tb__DOT__b_ref = 0x20U;
                    vlSelf->tb__DOT__b_dut = 0x20U;
                }
            } else if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0xedU;
                    vlSelf->tb__DOT__b_dut = 0xedU;
                } else {
                    vlSelf->tb__DOT__b_ref = 0U;
                    vlSelf->tb__DOT__b_dut = 0U;
                }
            } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                vlSelf->tb__DOT__b_ref = 0xd1U;
                vlSelf->tb__DOT__b_dut = 0xd1U;
            } else {
                vlSelf->tb__DOT__b_ref = 0x53U;
                vlSelf->tb__DOT__b_dut = 0x53U;
            }
        } else if ((8U & (IData)(vlSelf->tb__DOT__a))) {
            if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0x84U;
                        vlSelf->tb__DOT__b_dut = 0x84U;
                    } else {
                        vlSelf->tb__DOT__b_ref = 0x2fU;
                        vlSelf->tb__DOT__b_dut = 0x2fU;
                    }
                } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0xe3U;
                    vlSelf->tb__DOT__b_dut = 0xe3U;
                } else {
                    vlSelf->tb__DOT__b_ref = 0x29U;
                    vlSelf->tb__DOT__b_dut = 0x29U;
                }
            } else if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0xb3U;
                    vlSelf->tb__DOT__b_dut = 0xb3U;
                } else {
                    vlSelf->tb__DOT__b_ref = 0xd6U;
                    vlSelf->tb__DOT__b_dut = 0xd6U;
                }
            } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                vlSelf->tb__DOT__b_ref = 0x3bU;
                vlSelf->tb__DOT__b_dut = 0x3bU;
            } else {
                vlSelf->tb__DOT__b_ref = 0x52U;
                vlSelf->tb__DOT__b_dut = 0x52U;
            }
        } else if ((4U & (IData)(vlSelf->tb__DOT__a))) {
            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0xa0U;
                    vlSelf->tb__DOT__b_dut = 0xa0U;
                } else {
                    vlSelf->tb__DOT__b_ref = 0x5aU;
                    vlSelf->tb__DOT__b_dut = 0x5aU;
                }
            } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                vlSelf->tb__DOT__b_ref = 0x6eU;
                vlSelf->tb__DOT__b_dut = 0x6eU;
            } else {
                vlSelf->tb__DOT__b_ref = 0x1bU;
                vlSelf->tb__DOT__b_dut = 0x1bU;
            }
        } else if ((2U & (IData)(vlSelf->tb__DOT__a))) {
            if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                vlSelf->tb__DOT__b_ref = 0x1aU;
                vlSelf->tb__DOT__b_dut = 0x1aU;
            } else {
                vlSelf->tb__DOT__b_ref = 0x2cU;
                vlSelf->tb__DOT__b_dut = 0x2cU;
            }
        } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
            vlSelf->tb__DOT__b_ref = 0x83U;
            vlSelf->tb__DOT__b_dut = 0x83U;
        } else {
            vlSelf->tb__DOT__b_ref = 9U;
            vlSelf->tb__DOT__b_dut = 9U;
        }
    } else if ((0x20U & (IData)(vlSelf->tb__DOT__a))) {
        if ((0x10U & (IData)(vlSelf->tb__DOT__a))) {
            if ((8U & (IData)(vlSelf->tb__DOT__a))) {
                if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                            vlSelf->tb__DOT__b_ref = 0x75U;
                            vlSelf->tb__DOT__b_dut = 0x75U;
                        } else {
                            vlSelf->tb__DOT__b_ref = 0xb2U;
                            vlSelf->tb__DOT__b_dut = 0xb2U;
                        }
                    } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0x27U;
                        vlSelf->tb__DOT__b_dut = 0x27U;
                    } else {
                        vlSelf->tb__DOT__b_ref = 0xebU;
                        vlSelf->tb__DOT__b_dut = 0xebU;
                    }
                } else if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0xe2U;
                        vlSelf->tb__DOT__b_dut = 0xe2U;
                    } else {
                        vlSelf->tb__DOT__b_ref = 0x80U;
                        vlSelf->tb__DOT__b_dut = 0x80U;
                    }
                } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0x12U;
                    vlSelf->tb__DOT__b_dut = 0x12U;
                } else {
                    vlSelf->tb__DOT__b_ref = 7U;
                    vlSelf->tb__DOT__b_dut = 7U;
                }
            } else if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0x9aU;
                        vlSelf->tb__DOT__b_dut = 0x9aU;
                    } else {
                        vlSelf->tb__DOT__b_ref = 5U;
                        vlSelf->tb__DOT__b_dut = 5U;
                    }
                } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0x96U;
                    vlSelf->tb__DOT__b_dut = 0x96U;
                } else {
                    vlSelf->tb__DOT__b_ref = 0x18U;
                    vlSelf->tb__DOT__b_dut = 0x18U;
                }
            } else if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0xc3U;
                    vlSelf->tb__DOT__b_dut = 0xc3U;
                } else {
                    vlSelf->tb__DOT__b_ref = 0x23U;
                    vlSelf->tb__DOT__b_dut = 0x23U;
                }
            } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                vlSelf->tb__DOT__b_ref = 0xc7U;
                vlSelf->tb__DOT__b_dut = 0xc7U;
            } else {
                vlSelf->tb__DOT__b_ref = 4U;
                vlSelf->tb__DOT__b_dut = 4U;
            }
        } else if ((8U & (IData)(vlSelf->tb__DOT__a))) {
            if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0x15U;
                        vlSelf->tb__DOT__b_dut = 0x15U;
                    } else {
                        vlSelf->tb__DOT__b_ref = 0x31U;
                        vlSelf->tb__DOT__b_dut = 0x31U;
                    }
                } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0xd8U;
                    vlSelf->tb__DOT__b_dut = 0xd8U;
                } else {
                    vlSelf->tb__DOT__b_ref = 0x71U;
                    vlSelf->tb__DOT__b_dut = 0x71U;
                }
            } else if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0xf1U;
                    vlSelf->tb__DOT__b_dut = 0xf1U;
                } else {
                    vlSelf->tb__DOT__b_ref = 0xe5U;
                    vlSelf->tb__DOT__b_dut = 0xe5U;
                }
            } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                vlSelf->tb__DOT__b_ref = 0xa5U;
                vlSelf->tb__DOT__b_dut = 0xa5U;
            } else {
                vlSelf->tb__DOT__b_ref = 0x34U;
                vlSelf->tb__DOT__b_dut = 0x34U;
            }
        } else if ((4U & (IData)(vlSelf->tb__DOT__a))) {
            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0xccU;
                    vlSelf->tb__DOT__b_dut = 0xccU;
                } else {
                    vlSelf->tb__DOT__b_ref = 0xf7U;
                    vlSelf->tb__DOT__b_dut = 0xf7U;
                }
            } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                vlSelf->tb__DOT__b_ref = 0x3fU;
                vlSelf->tb__DOT__b_dut = 0x3fU;
            } else {
                vlSelf->tb__DOT__b_ref = 0x36U;
                vlSelf->tb__DOT__b_dut = 0x36U;
            }
        } else if ((2U & (IData)(vlSelf->tb__DOT__a))) {
            if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                vlSelf->tb__DOT__b_ref = 0x26U;
                vlSelf->tb__DOT__b_dut = 0x26U;
            } else {
                vlSelf->tb__DOT__b_ref = 0x93U;
                vlSelf->tb__DOT__b_dut = 0x93U;
            }
        } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
            vlSelf->tb__DOT__b_ref = 0xfdU;
            vlSelf->tb__DOT__b_dut = 0xfdU;
        } else {
            vlSelf->tb__DOT__b_ref = 0xb7U;
            vlSelf->tb__DOT__b_dut = 0xb7U;
        }
    } else if ((0x10U & (IData)(vlSelf->tb__DOT__a))) {
        if ((8U & (IData)(vlSelf->tb__DOT__a))) {
            if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                        vlSelf->tb__DOT__b_ref = 0xc0U;
                        vlSelf->tb__DOT__b_dut = 0xc0U;
                    } else {
                        vlSelf->tb__DOT__b_ref = 0x72U;
                        vlSelf->tb__DOT__b_dut = 0x72U;
                    }
                } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0xa4U;
                    vlSelf->tb__DOT__b_dut = 0xa4U;
                } else {
                    vlSelf->tb__DOT__b_ref = 0x9cU;
                    vlSelf->tb__DOT__b_dut = 0x9cU;
                }
            } else if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0xafU;
                    vlSelf->tb__DOT__b_dut = 0xafU;
                } else {
                    vlSelf->tb__DOT__b_ref = 0xa2U;
                    vlSelf->tb__DOT__b_dut = 0xa2U;
                }
            } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                vlSelf->tb__DOT__b_ref = 0xd4U;
                vlSelf->tb__DOT__b_dut = 0xd4U;
            } else {
                vlSelf->tb__DOT__b_ref = 0xadU;
                vlSelf->tb__DOT__b_dut = 0xadU;
            }
        } else if ((4U & (IData)(vlSelf->tb__DOT__a))) {
            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0xf0U;
                    vlSelf->tb__DOT__b_dut = 0xf0U;
                } else {
                    vlSelf->tb__DOT__b_ref = 0x47U;
                    vlSelf->tb__DOT__b_dut = 0x47U;
                }
            } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                vlSelf->tb__DOT__b_ref = 0x59U;
                vlSelf->tb__DOT__b_dut = 0x59U;
            } else {
                vlSelf->tb__DOT__b_ref = 0xfaU;
                vlSelf->tb__DOT__b_dut = 0xfaU;
            }
        } else if ((2U & (IData)(vlSelf->tb__DOT__a))) {
            if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                vlSelf->tb__DOT__b_ref = 0x7dU;
                vlSelf->tb__DOT__b_dut = 0x7dU;
            } else {
                vlSelf->tb__DOT__b_ref = 0xc9U;
                vlSelf->tb__DOT__b_dut = 0xc9U;
            }
        } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
            vlSelf->tb__DOT__b_ref = 0x82U;
            vlSelf->tb__DOT__b_dut = 0x82U;
        } else {
            vlSelf->tb__DOT__b_ref = 0xcaU;
            vlSelf->tb__DOT__b_dut = 0xcaU;
        }
    } else if ((8U & (IData)(vlSelf->tb__DOT__a))) {
        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                    vlSelf->tb__DOT__b_ref = 0x76U;
                    vlSelf->tb__DOT__b_dut = 0x76U;
                } else {
                    vlSelf->tb__DOT__b_ref = 0xabU;
                    vlSelf->tb__DOT__b_dut = 0xabU;
                }
            } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                vlSelf->tb__DOT__b_ref = 0xd7U;
                vlSelf->tb__DOT__b_dut = 0xd7U;
            } else {
                vlSelf->tb__DOT__b_ref = 0xfeU;
                vlSelf->tb__DOT__b_dut = 0xfeU;
            }
        } else if ((2U & (IData)(vlSelf->tb__DOT__a))) {
            if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                vlSelf->tb__DOT__b_ref = 0x2bU;
                vlSelf->tb__DOT__b_dut = 0x2bU;
            } else {
                vlSelf->tb__DOT__b_ref = 0x67U;
                vlSelf->tb__DOT__b_dut = 0x67U;
            }
        } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
            vlSelf->tb__DOT__b_ref = 1U;
            vlSelf->tb__DOT__b_dut = 1U;
        } else {
            vlSelf->tb__DOT__b_ref = 0x30U;
            vlSelf->tb__DOT__b_dut = 0x30U;
        }
    } else if ((4U & (IData)(vlSelf->tb__DOT__a))) {
        if ((2U & (IData)(vlSelf->tb__DOT__a))) {
            if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                vlSelf->tb__DOT__b_ref = 0xc5U;
                vlSelf->tb__DOT__b_dut = 0xc5U;
            } else {
                vlSelf->tb__DOT__b_ref = 0x6fU;
                vlSelf->tb__DOT__b_dut = 0x6fU;
            }
        } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
            vlSelf->tb__DOT__b_ref = 0x6bU;
            vlSelf->tb__DOT__b_dut = 0x6bU;
        } else {
            vlSelf->tb__DOT__b_ref = 0xf2U;
            vlSelf->tb__DOT__b_dut = 0xf2U;
        }
    } else if ((2U & (IData)(vlSelf->tb__DOT__a))) {
        if ((1U & (IData)(vlSelf->tb__DOT__a))) {
            vlSelf->tb__DOT__b_ref = 0x7bU;
            vlSelf->tb__DOT__b_dut = 0x7bU;
        } else {
            vlSelf->tb__DOT__b_ref = 0x77U;
            vlSelf->tb__DOT__b_dut = 0x77U;
        }
    } else if ((1U & (IData)(vlSelf->tb__DOT__a))) {
        vlSelf->tb__DOT__b_ref = 0x7cU;
        vlSelf->tb__DOT__b_dut = 0x7cU;
    } else {
        vlSelf->tb__DOT__b_ref = 0x63U;
        vlSelf->tb__DOT__b_dut = 0x63U;
    }
    if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) >> 7U)))) {
        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) >> 6U)))) {
            if ((0x20U & (IData)(vlSelf->tb__DOT__a))) {
                if ((0x10U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                  >> 3U)))) {
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[331]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[330]);
                                }
                            }
                        }
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[329]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[328]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[327]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[326]);
                                }
                            }
                        }
                    }
                }
                if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                              >> 4U)))) {
                    if ((8U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[325]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[324]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[323]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[322]);
                                }
                            }
                        }
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[321]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[320]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[319]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[318]);
                                }
                            }
                        }
                    }
                    if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                  >> 3U)))) {
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[317]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[316]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[315]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[314]);
                                }
                            }
                        }
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[313]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[312]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[311]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[310]);
                                }
                            }
                        }
                    }
                }
            }
            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                          >> 5U)))) {
                if ((0x10U & (IData)(vlSelf->tb__DOT__a))) {
                    if ((8U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[309]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[308]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[307]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[306]);
                                }
                            }
                        }
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[305]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[304]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[303]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[302]);
                                }
                            }
                        }
                    }
                    if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                  >> 3U)))) {
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[301]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[300]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[299]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[298]);
                                }
                            }
                        }
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[297]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[296]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[295]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[294]);
                                }
                            }
                        }
                    }
                }
                if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                              >> 4U)))) {
                    if ((8U & (IData)(vlSelf->tb__DOT__a))) {
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[293]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[292]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[291]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[290]);
                                }
                            }
                        }
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[289]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[288]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[287]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[286]);
                                }
                            }
                        }
                    }
                    if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                  >> 3U)))) {
                        if ((4U & (IData)(vlSelf->tb__DOT__a))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[285]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[284]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[283]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[282]);
                                }
                            }
                        }
                        if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                      >> 2U)))) {
                            if ((2U & (IData)(vlSelf->tb__DOT__a))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[281]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[280]);
                                }
                            }
                            if ((1U & (~ ((IData)(vlSelf->tb__DOT__a) 
                                          >> 1U)))) {
                                if ((1U & (IData)(vlSelf->tb__DOT__a))) {
                                    ++(vlSymsp->__Vcoverage[279]);
                                }
                                if ((1U & (~ (IData)(vlSelf->tb__DOT__a)))) {
                                    ++(vlSymsp->__Vcoverage[278]);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

VL_INLINE_OPT void Vtb___024root___nba_sequent__TOP__0(Vtb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb___024root___nba_sequent__TOP__0\n"); );
    // Body
    ++(vlSymsp->__Vcoverage[15]);
    if (((IData)(vlSelf->tb__DOT__b_ref) == (((IData)(vlSelf->tb__DOT__b_ref) 
                                              ^ (IData)(vlSelf->tb__DOT__b_dut)) 
                                             ^ (IData)(vlSelf->tb__DOT__b_ref)))) {
        ++(vlSymsp->__Vcoverage[14]);
    }
    if (((IData)(vlSelf->tb__DOT__b_ref) == ((IData)(vlSelf->tb__DOT__b_ref) 
                                             ^ ((IData)(vlSelf->tb__DOT__b_dut) 
                                                ^ (IData)(vlSelf->tb__DOT__b_ref))))) {
        ++(vlSymsp->__Vcoverage[10]);
    }
    if (((IData)(vlSelf->tb__DOT__b_ref) != ((IData)(vlSelf->tb__DOT__b_ref) 
                                             ^ ((IData)(vlSelf->tb__DOT__b_dut) 
                                                ^ (IData)(vlSelf->tb__DOT__b_ref))))) {
        ++(vlSymsp->__Vcoverage[9]);
        if ((0U == vlSelf->tb__DOT__stats1[4U])) {
            ++(vlSymsp->__Vcoverage[7]);
        }
        if ((0U != vlSelf->tb__DOT__stats1[4U])) {
            ++(vlSymsp->__Vcoverage[8]);
        }
    }
    if (((IData)(vlSelf->tb__DOT__b_ref) != (((IData)(vlSelf->tb__DOT__b_ref) 
                                              ^ (IData)(vlSelf->tb__DOT__b_dut)) 
                                             ^ (IData)(vlSelf->tb__DOT__b_ref)))) {
        ++(vlSymsp->__Vcoverage[13]);
        if ((0U != vlSelf->tb__DOT__stats1[2U])) {
            ++(vlSymsp->__Vcoverage[12]);
        }
        if ((0U == vlSelf->tb__DOT__stats1[2U])) {
            ++(vlSymsp->__Vcoverage[11]);
        }
    }
    vlSelf->tb__DOT__stats1[0U] = ((IData)(1U) + vlSelf->tb__DOT__stats1[0U]);
    if (((IData)(vlSelf->tb__DOT__b_ref) != ((IData)(vlSelf->tb__DOT__b_ref) 
                                             ^ ((IData)(vlSelf->tb__DOT__b_dut) 
                                                ^ (IData)(vlSelf->tb__DOT__b_ref))))) {
        if ((0U == vlSelf->tb__DOT__stats1[4U])) {
            vlSelf->tb__DOT__stats1[3U] = (IData)(VL_TIME_UNITED_Q(1));
        }
        vlSelf->tb__DOT__stats1[4U] = ((IData)(1U) 
                                       + vlSelf->tb__DOT__stats1[4U]);
    }
    if (((IData)(vlSelf->tb__DOT__b_ref) != (((IData)(vlSelf->tb__DOT__b_ref) 
                                              ^ (IData)(vlSelf->tb__DOT__b_dut)) 
                                             ^ (IData)(vlSelf->tb__DOT__b_ref)))) {
        if ((0U == vlSelf->tb__DOT__stats1[2U])) {
            vlSelf->tb__DOT__stats1[1U] = (IData)(VL_TIME_UNITED_Q(1));
        }
        vlSelf->tb__DOT__stats1[2U] = ((IData)(1U) 
                                       + vlSelf->tb__DOT__stats1[2U]);
    }
}
