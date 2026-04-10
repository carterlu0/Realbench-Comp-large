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
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Body
    while (1U) {
        co_await vlSelfRef.__VdlySched.delay(5ULL, 
                                             nullptr, 
                                             "aes_inv_sbox_testbench.sv", 
                                             17);
        vlSelfRef.tb__DOT__clk = (1U & (~ (IData)(vlSelfRef.tb__DOT__clk)));
        ++(vlSymsp->__Vcoverage[1]);
    }
    ++(vlSymsp->__Vcoverage[2]);
}

VL_INLINE_OPT VlCoroutine Vtb___024root___eval_initial__TOP__Vtiming__1(Vtb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb___024root___eval_initial__TOP__Vtiming__1\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Body
    co_await vlSelfRef.__VdlySched.delay(0xf4240ULL, 
                                         nullptr, "aes_inv_sbox_testbench.sv", 
                                         84);
    VL_WRITEF_NX("TIMEOUT\n",0);
    VL_FINISH_MT("aes_inv_sbox_testbench.sv", 86, "");
    ++(vlSymsp->__Vcoverage[16]);
}

VL_INLINE_OPT VlCoroutine Vtb___024root___eval_initial__TOP__Vtiming__2(Vtb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb___024root___eval_initial__TOP__Vtiming__2\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.tb__DOT__a = 0U;
    vlSelfRef.tb__DOT__stim1__DOT__unnamedblk1__DOT__i = 0U;
    while (VL_GTS_III(32, 0x100U, vlSelfRef.tb__DOT__stim1__DOT__unnamedblk1__DOT__i)) {
        co_await vlSelfRef.__VtrigSched_h8aad79f9__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb.clk)", 
                                                             "aes_inv_sbox_stimulus_gen.sv", 
                                                             10);
        vlSelfRef.tb__DOT__a = (0xffU & vlSelfRef.tb__DOT__stim1__DOT__unnamedblk1__DOT__i);
        ++(vlSymsp->__Vcoverage[17]);
        vlSelfRef.tb__DOT__stim1__DOT__unnamedblk1__DOT__i 
            = ((IData)(1U) + vlSelfRef.tb__DOT__stim1__DOT__unnamedblk1__DOT__i);
    }
    vlSelfRef.tb__DOT__stim1__DOT__unnamedblk2__DOT__i = 0U;
    while (VL_GTS_III(32, 0x100U, vlSelfRef.tb__DOT__stim1__DOT__unnamedblk2__DOT__i)) {
        co_await vlSelfRef.__VtrigSched_h8aad79ba__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb.clk)", 
                                                             "aes_inv_sbox_stimulus_gen.sv", 
                                                             16);
        vlSelfRef.tb__DOT__a = (0xffU & vlSelfRef.tb__DOT__stim1__DOT__unnamedblk2__DOT__i);
        ++(vlSymsp->__Vcoverage[18]);
        vlSelfRef.tb__DOT__stim1__DOT__unnamedblk2__DOT__i 
            = ((IData)(1U) + vlSelfRef.tb__DOT__stim1__DOT__unnamedblk2__DOT__i);
    }
    vlSelfRef.tb__DOT__stim1__DOT__unnamedblk3__DOT__i = 0xffU;
    while (VL_LTES_III(32, 0U, vlSelfRef.tb__DOT__stim1__DOT__unnamedblk3__DOT__i)) {
        co_await vlSelfRef.__VtrigSched_h8aad79f9__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb.clk)", 
                                                             "aes_inv_sbox_stimulus_gen.sv", 
                                                             22);
        vlSelfRef.tb__DOT__a = (0xffU & vlSelfRef.tb__DOT__stim1__DOT__unnamedblk3__DOT__i);
        ++(vlSymsp->__Vcoverage[19]);
        vlSelfRef.tb__DOT__stim1__DOT__unnamedblk3__DOT__i 
            = (vlSelfRef.tb__DOT__stim1__DOT__unnamedblk3__DOT__i 
               - (IData)(1U));
    }
    co_await vlSelfRef.__VtrigSched_h8aad79f9__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb.clk)", 
                                                         "aes_inv_sbox_stimulus_gen.sv", 
                                                         27);
    VL_FINISH_MT("aes_inv_sbox_stimulus_gen.sv", 28, "");
    ++(vlSymsp->__Vcoverage[20]);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb___024root___dump_triggers__act(Vtb___024root* vlSelf);
#endif  // VL_DEBUG

void Vtb___024root___eval_triggers__act(Vtb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb___024root___eval_triggers__act\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VactTriggered.set(0U, ((IData)(vlSelfRef.tb__DOT__clk) 
                                       ^ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb__DOT__clk__0)));
    vlSelfRef.__VactTriggered.set(1U, ((IData)(vlSelfRef.tb__DOT__a) 
                                       != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb__DOT__a__0)));
    vlSelfRef.__VactTriggered.set(2U, vlSelfRef.__VdlySched.awaitingCurrentTime());
    vlSelfRef.__VactTriggered.set(3U, ((IData)(vlSelfRef.tb__DOT__clk) 
                                       & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb__DOT__clk__0))));
    vlSelfRef.__VactTriggered.set(4U, ((~ (IData)(vlSelfRef.tb__DOT__clk)) 
                                       & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb__DOT__clk__0)));
    vlSelfRef.__Vtrigprevexpr___TOP__tb__DOT__clk__0 
        = vlSelfRef.tb__DOT__clk;
    vlSelfRef.__Vtrigprevexpr___TOP__tb__DOT__a__0 
        = vlSelfRef.tb__DOT__a;
    if (VL_UNLIKELY((1U & (~ (IData)(vlSelfRef.__VactDidInit))))) {
        vlSelfRef.__VactDidInit = 1U;
        vlSelfRef.__VactTriggered.set(1U, 1U);
    }
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb___024root___dump_triggers__act(vlSelf);
    }
#endif
}

VL_INLINE_OPT void Vtb___024root___nba_sequent__TOP__0(Vtb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb___024root___nba_sequent__TOP__0\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((0x80U & (IData)(vlSelfRef.tb__DOT__a))) {
        if ((0x40U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((0x20U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((0x10U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((8U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                            if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                                if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                                    vlSelfRef.tb__DOT__b_ref = 0x7dU;
                                    ++(vlSymsp->__Vcoverage[276]);
                                } else {
                                    ++(vlSymsp->__Vcoverage[275]);
                                    vlSelfRef.tb__DOT__b_ref = 0xcU;
                                }
                            } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                                ++(vlSymsp->__Vcoverage[274]);
                                vlSelfRef.tb__DOT__b_ref = 0x21U;
                            } else {
                                ++(vlSymsp->__Vcoverage[273]);
                                vlSelfRef.tb__DOT__b_ref = 0x55U;
                            }
                        } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                            if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                                ++(vlSymsp->__Vcoverage[272]);
                                vlSelfRef.tb__DOT__b_ref = 0x63U;
                            } else {
                                ++(vlSymsp->__Vcoverage[271]);
                                vlSelfRef.tb__DOT__b_ref = 0x14U;
                            }
                        } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[270]);
                            vlSelfRef.tb__DOT__b_ref = 0x69U;
                        } else {
                            ++(vlSymsp->__Vcoverage[269]);
                            vlSelfRef.tb__DOT__b_ref = 0xe1U;
                        }
                    } else if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                            if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                                ++(vlSymsp->__Vcoverage[268]);
                                vlSelfRef.tb__DOT__b_ref = 0x26U;
                            } else {
                                ++(vlSymsp->__Vcoverage[267]);
                                vlSelfRef.tb__DOT__b_ref = 0xd6U;
                            }
                        } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[266]);
                            vlSelfRef.tb__DOT__b_ref = 0x77U;
                        } else {
                            ++(vlSymsp->__Vcoverage[265]);
                            vlSelfRef.tb__DOT__b_ref = 0xbaU;
                        }
                    } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[264]);
                            vlSelfRef.tb__DOT__b_ref = 0x7eU;
                        } else {
                            ++(vlSymsp->__Vcoverage[263]);
                            vlSelfRef.tb__DOT__b_ref = 4U;
                        }
                    } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[262]);
                        vlSelfRef.tb__DOT__b_ref = 0x2bU;
                    } else {
                        ++(vlSymsp->__Vcoverage[261]);
                        vlSelfRef.tb__DOT__b_ref = 0x17U;
                    }
                } else if ((8U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                            if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                                ++(vlSymsp->__Vcoverage[260]);
                                vlSelfRef.tb__DOT__b_ref = 0x61U;
                            } else {
                                ++(vlSymsp->__Vcoverage[259]);
                                vlSelfRef.tb__DOT__b_ref = 0x99U;
                            }
                        } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[258]);
                            vlSelfRef.tb__DOT__b_ref = 0x53U;
                        } else {
                            ++(vlSymsp->__Vcoverage[257]);
                            vlSelfRef.tb__DOT__b_ref = 0x83U;
                        }
                    } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[256]);
                            vlSelfRef.tb__DOT__b_ref = 0x3cU;
                        } else {
                            ++(vlSymsp->__Vcoverage[255]);
                            vlSelfRef.tb__DOT__b_ref = 0xbbU;
                        }
                    } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[254]);
                        vlSelfRef.tb__DOT__b_ref = 0xebU;
                    } else {
                        ++(vlSymsp->__Vcoverage[253]);
                        vlSelfRef.tb__DOT__b_ref = 0xc8U;
                    }
                } else if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[252]);
                            vlSelfRef.tb__DOT__b_ref = 0xb0U;
                        } else {
                            ++(vlSymsp->__Vcoverage[251]);
                            vlSelfRef.tb__DOT__b_ref = 0xf5U;
                        }
                    } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[250]);
                        vlSelfRef.tb__DOT__b_ref = 0x2aU;
                    } else {
                        ++(vlSymsp->__Vcoverage[249]);
                        vlSelfRef.tb__DOT__b_ref = 0xaeU;
                    }
                } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[248]);
                        vlSelfRef.tb__DOT__b_ref = 0x4dU;
                    } else {
                        ++(vlSymsp->__Vcoverage[247]);
                        vlSelfRef.tb__DOT__b_ref = 0x3bU;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[246]);
                    vlSelfRef.tb__DOT__b_ref = 0xe0U;
                } else {
                    ++(vlSymsp->__Vcoverage[245]);
                    vlSelfRef.tb__DOT__b_ref = 0xa0U;
                }
            } else if ((0x10U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((8U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                            if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                                ++(vlSymsp->__Vcoverage[244]);
                                vlSelfRef.tb__DOT__b_ref = 0xefU;
                            } else {
                                ++(vlSymsp->__Vcoverage[243]);
                                vlSelfRef.tb__DOT__b_ref = 0x9cU;
                            }
                        } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[242]);
                            vlSelfRef.tb__DOT__b_ref = 0xc9U;
                        } else {
                            ++(vlSymsp->__Vcoverage[241]);
                            vlSelfRef.tb__DOT__b_ref = 0x93U;
                        }
                    } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[240]);
                            vlSelfRef.tb__DOT__b_ref = 0x9fU;
                        } else {
                            ++(vlSymsp->__Vcoverage[239]);
                            vlSelfRef.tb__DOT__b_ref = 0x7aU;
                        }
                    } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[238]);
                        vlSelfRef.tb__DOT__b_ref = 0xe5U;
                    } else {
                        ++(vlSymsp->__Vcoverage[237]);
                        vlSelfRef.tb__DOT__b_ref = 0x2dU;
                    }
                } else if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[236]);
                            vlSelfRef.tb__DOT__b_ref = 0xdU;
                        } else {
                            ++(vlSymsp->__Vcoverage[235]);
                            vlSelfRef.tb__DOT__b_ref = 0x4aU;
                        }
                    } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[234]);
                        vlSelfRef.tb__DOT__b_ref = 0xb5U;
                    } else {
                        ++(vlSymsp->__Vcoverage[233]);
                        vlSelfRef.tb__DOT__b_ref = 0x19U;
                    }
                } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[232]);
                        vlSelfRef.tb__DOT__b_ref = 0xa9U;
                    } else {
                        ++(vlSymsp->__Vcoverage[231]);
                        vlSelfRef.tb__DOT__b_ref = 0x7fU;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[230]);
                    vlSelfRef.tb__DOT__b_ref = 0x51U;
                } else {
                    ++(vlSymsp->__Vcoverage[229]);
                    vlSelfRef.tb__DOT__b_ref = 0x60U;
                }
            } else if ((8U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[228]);
                            vlSelfRef.tb__DOT__b_ref = 0x5fU;
                        } else {
                            ++(vlSymsp->__Vcoverage[227]);
                            vlSelfRef.tb__DOT__b_ref = 0xecU;
                        }
                    } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[226]);
                        vlSelfRef.tb__DOT__b_ref = 0x80U;
                    } else {
                        ++(vlSymsp->__Vcoverage[225]);
                        vlSelfRef.tb__DOT__b_ref = 0x27U;
                    }
                } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[224]);
                        vlSelfRef.tb__DOT__b_ref = 0x59U;
                    } else {
                        ++(vlSymsp->__Vcoverage[223]);
                        vlSelfRef.tb__DOT__b_ref = 0x10U;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[222]);
                    vlSelfRef.tb__DOT__b_ref = 0x12U;
                } else {
                    ++(vlSymsp->__Vcoverage[221]);
                    vlSelfRef.tb__DOT__b_ref = 0xb1U;
                }
            } else if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[220]);
                        vlSelfRef.tb__DOT__b_ref = 0x31U;
                    } else {
                        ++(vlSymsp->__Vcoverage[219]);
                        vlSelfRef.tb__DOT__b_ref = 0xc7U;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[218]);
                    vlSelfRef.tb__DOT__b_ref = 7U;
                } else {
                    ++(vlSymsp->__Vcoverage[217]);
                    vlSelfRef.tb__DOT__b_ref = 0x88U;
                }
            } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[216]);
                    vlSelfRef.tb__DOT__b_ref = 0x33U;
                } else {
                    ++(vlSymsp->__Vcoverage[215]);
                    vlSelfRef.tb__DOT__b_ref = 0xa8U;
                }
            } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[214]);
                vlSelfRef.tb__DOT__b_ref = 0xddU;
            } else {
                ++(vlSymsp->__Vcoverage[213]);
                vlSelfRef.tb__DOT__b_ref = 0x1fU;
            }
        } else if ((0x20U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((0x10U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((8U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                            if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                                ++(vlSymsp->__Vcoverage[212]);
                                vlSelfRef.tb__DOT__b_ref = 0xf4U;
                            } else {
                                ++(vlSymsp->__Vcoverage[211]);
                                vlSelfRef.tb__DOT__b_ref = 0x5aU;
                            }
                        } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[210]);
                            vlSelfRef.tb__DOT__b_ref = 0xcdU;
                        } else {
                            ++(vlSymsp->__Vcoverage[209]);
                            vlSelfRef.tb__DOT__b_ref = 0x78U;
                        }
                    } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[208]);
                            vlSelfRef.tb__DOT__b_ref = 0xfeU;
                        } else {
                            ++(vlSymsp->__Vcoverage[207]);
                            vlSelfRef.tb__DOT__b_ref = 0xc0U;
                        }
                    } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[206]);
                        vlSelfRef.tb__DOT__b_ref = 0xdbU;
                    } else {
                        ++(vlSymsp->__Vcoverage[205]);
                        vlSelfRef.tb__DOT__b_ref = 0x9aU;
                    }
                } else if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[204]);
                            vlSelfRef.tb__DOT__b_ref = 0x20U;
                        } else {
                            ++(vlSymsp->__Vcoverage[203]);
                            vlSelfRef.tb__DOT__b_ref = 0x79U;
                        }
                    } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[202]);
                        vlSelfRef.tb__DOT__b_ref = 0xd2U;
                    } else {
                        ++(vlSymsp->__Vcoverage[201]);
                        vlSelfRef.tb__DOT__b_ref = 0xc6U;
                    }
                } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[200]);
                        vlSelfRef.tb__DOT__b_ref = 0x4bU;
                    } else {
                        ++(vlSymsp->__Vcoverage[199]);
                        vlSelfRef.tb__DOT__b_ref = 0x3eU;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[198]);
                    vlSelfRef.tb__DOT__b_ref = 0x56U;
                } else {
                    ++(vlSymsp->__Vcoverage[197]);
                    vlSelfRef.tb__DOT__b_ref = 0xfcU;
                }
            } else if ((8U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[196]);
                            vlSelfRef.tb__DOT__b_ref = 0x1bU;
                        } else {
                            ++(vlSymsp->__Vcoverage[195]);
                            vlSelfRef.tb__DOT__b_ref = 0xbeU;
                        }
                    } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[194]);
                        vlSelfRef.tb__DOT__b_ref = 0x18U;
                    } else {
                        ++(vlSymsp->__Vcoverage[193]);
                        vlSelfRef.tb__DOT__b_ref = 0xaaU;
                    }
                } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[192]);
                        vlSelfRef.tb__DOT__b_ref = 0xeU;
                    } else {
                        ++(vlSymsp->__Vcoverage[191]);
                        vlSelfRef.tb__DOT__b_ref = 0x62U;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[190]);
                    vlSelfRef.tb__DOT__b_ref = 0xb7U;
                } else {
                    ++(vlSymsp->__Vcoverage[189]);
                    vlSelfRef.tb__DOT__b_ref = 0x6fU;
                }
            } else if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[188]);
                        vlSelfRef.tb__DOT__b_ref = 0x89U;
                    } else {
                        ++(vlSymsp->__Vcoverage[187]);
                        vlSelfRef.tb__DOT__b_ref = 0xc5U;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[186]);
                    vlSelfRef.tb__DOT__b_ref = 0x29U;
                } else {
                    ++(vlSymsp->__Vcoverage[185]);
                    vlSelfRef.tb__DOT__b_ref = 0x1dU;
                }
            } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[184]);
                    vlSelfRef.tb__DOT__b_ref = 0x71U;
                } else {
                    ++(vlSymsp->__Vcoverage[183]);
                    vlSelfRef.tb__DOT__b_ref = 0x1aU;
                }
            } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[182]);
                vlSelfRef.tb__DOT__b_ref = 0xf1U;
            } else {
                ++(vlSymsp->__Vcoverage[181]);
                vlSelfRef.tb__DOT__b_ref = 0x47U;
            }
        } else if ((0x10U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((8U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[180]);
                            vlSelfRef.tb__DOT__b_ref = 0x6eU;
                        } else {
                            ++(vlSymsp->__Vcoverage[179]);
                            vlSelfRef.tb__DOT__b_ref = 0xdfU;
                        }
                    } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[178]);
                        vlSelfRef.tb__DOT__b_ref = 0x75U;
                    } else {
                        ++(vlSymsp->__Vcoverage[177]);
                        vlSelfRef.tb__DOT__b_ref = 0x1cU;
                    }
                } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[176]);
                        vlSelfRef.tb__DOT__b_ref = 0xe8U;
                    } else {
                        ++(vlSymsp->__Vcoverage[175]);
                        vlSelfRef.tb__DOT__b_ref = 0x37U;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[174]);
                    vlSelfRef.tb__DOT__b_ref = 0xf9U;
                } else {
                    ++(vlSymsp->__Vcoverage[173]);
                    vlSelfRef.tb__DOT__b_ref = 0xe2U;
                }
            } else if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[172]);
                        vlSelfRef.tb__DOT__b_ref = 0x85U;
                    } else {
                        ++(vlSymsp->__Vcoverage[171]);
                        vlSelfRef.tb__DOT__b_ref = 0x35U;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[170]);
                    vlSelfRef.tb__DOT__b_ref = 0xadU;
                } else {
                    ++(vlSymsp->__Vcoverage[169]);
                    vlSelfRef.tb__DOT__b_ref = 0xe7U;
                }
            } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[168]);
                    vlSelfRef.tb__DOT__b_ref = 0x22U;
                } else {
                    ++(vlSymsp->__Vcoverage[167]);
                    vlSelfRef.tb__DOT__b_ref = 0x74U;
                }
            } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[166]);
                vlSelfRef.tb__DOT__b_ref = 0xacU;
            } else {
                ++(vlSymsp->__Vcoverage[165]);
                vlSelfRef.tb__DOT__b_ref = 0x96U;
            }
        } else if ((8U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[164]);
                        vlSelfRef.tb__DOT__b_ref = 0x73U;
                    } else {
                        ++(vlSymsp->__Vcoverage[163]);
                        vlSelfRef.tb__DOT__b_ref = 0xe6U;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[162]);
                    vlSelfRef.tb__DOT__b_ref = 0xb4U;
                } else {
                    ++(vlSymsp->__Vcoverage[161]);
                    vlSelfRef.tb__DOT__b_ref = 0xf0U;
                }
            } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[160]);
                    vlSelfRef.tb__DOT__b_ref = 0xceU;
                } else {
                    ++(vlSymsp->__Vcoverage[159]);
                    vlSelfRef.tb__DOT__b_ref = 0xcfU;
                }
            } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[158]);
                vlSelfRef.tb__DOT__b_ref = 0xf2U;
            } else {
                ++(vlSymsp->__Vcoverage[157]);
                vlSelfRef.tb__DOT__b_ref = 0x97U;
            }
        } else if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[156]);
                    vlSelfRef.tb__DOT__b_ref = 0xeaU;
                } else {
                    ++(vlSymsp->__Vcoverage[155]);
                    vlSelfRef.tb__DOT__b_ref = 0xdcU;
                }
            } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[154]);
                vlSelfRef.tb__DOT__b_ref = 0x67U;
            } else {
                ++(vlSymsp->__Vcoverage[153]);
                vlSelfRef.tb__DOT__b_ref = 0x4fU;
            }
        } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[152]);
                vlSelfRef.tb__DOT__b_ref = 0x41U;
            } else {
                ++(vlSymsp->__Vcoverage[151]);
                vlSelfRef.tb__DOT__b_ref = 0x11U;
            }
        } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
            ++(vlSymsp->__Vcoverage[150]);
            vlSelfRef.tb__DOT__b_ref = 0x91U;
        } else {
            ++(vlSymsp->__Vcoverage[149]);
            vlSelfRef.tb__DOT__b_ref = 0x3aU;
        }
    } else if ((0x40U & (IData)(vlSelfRef.tb__DOT__a))) {
        if ((0x20U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((0x10U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((8U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                            if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                                ++(vlSymsp->__Vcoverage[148]);
                                vlSelfRef.tb__DOT__b_ref = 0x6bU;
                            } else {
                                ++(vlSymsp->__Vcoverage[147]);
                                vlSelfRef.tb__DOT__b_ref = 0x8aU;
                            }
                        } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[146]);
                            vlSelfRef.tb__DOT__b_ref = 0x13U;
                        } else {
                            ++(vlSymsp->__Vcoverage[145]);
                            vlSelfRef.tb__DOT__b_ref = 1U;
                        }
                    } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[144]);
                            vlSelfRef.tb__DOT__b_ref = 3U;
                        } else {
                            ++(vlSymsp->__Vcoverage[143]);
                            vlSelfRef.tb__DOT__b_ref = 0xbdU;
                        }
                    } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[142]);
                        vlSelfRef.tb__DOT__b_ref = 0xafU;
                    } else {
                        ++(vlSymsp->__Vcoverage[141]);
                        vlSelfRef.tb__DOT__b_ref = 0xc1U;
                    }
                } else if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[140]);
                            vlSelfRef.tb__DOT__b_ref = 2U;
                        } else {
                            ++(vlSymsp->__Vcoverage[139]);
                            vlSelfRef.tb__DOT__b_ref = 0xfU;
                        }
                    } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[138]);
                        vlSelfRef.tb__DOT__b_ref = 0x3fU;
                    } else {
                        ++(vlSymsp->__Vcoverage[137]);
                        vlSelfRef.tb__DOT__b_ref = 0xcaU;
                    }
                } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[136]);
                        vlSelfRef.tb__DOT__b_ref = 0x8fU;
                    } else {
                        ++(vlSymsp->__Vcoverage[135]);
                        vlSelfRef.tb__DOT__b_ref = 0x1eU;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[134]);
                    vlSelfRef.tb__DOT__b_ref = 0x2cU;
                } else {
                    ++(vlSymsp->__Vcoverage[133]);
                    vlSelfRef.tb__DOT__b_ref = 0xd0U;
                }
            } else if ((8U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[132]);
                            vlSelfRef.tb__DOT__b_ref = 6U;
                        } else {
                            ++(vlSymsp->__Vcoverage[131]);
                            vlSelfRef.tb__DOT__b_ref = 0x45U;
                        }
                    } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[130]);
                        vlSelfRef.tb__DOT__b_ref = 0xb3U;
                    } else {
                        ++(vlSymsp->__Vcoverage[129]);
                        vlSelfRef.tb__DOT__b_ref = 0xb8U;
                    }
                } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[128]);
                        vlSelfRef.tb__DOT__b_ref = 5U;
                    } else {
                        ++(vlSymsp->__Vcoverage[127]);
                        vlSelfRef.tb__DOT__b_ref = 0x58U;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[126]);
                    vlSelfRef.tb__DOT__b_ref = 0xe4U;
                } else {
                    ++(vlSymsp->__Vcoverage[125]);
                    vlSelfRef.tb__DOT__b_ref = 0xf7U;
                }
            } else if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[124]);
                        vlSelfRef.tb__DOT__b_ref = 0xaU;
                    } else {
                        ++(vlSymsp->__Vcoverage[123]);
                        vlSelfRef.tb__DOT__b_ref = 0xd3U;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[122]);
                    vlSelfRef.tb__DOT__b_ref = 0xbcU;
                } else {
                    ++(vlSymsp->__Vcoverage[121]);
                    vlSelfRef.tb__DOT__b_ref = 0x8cU;
                }
            } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[120]);
                    vlSelfRef.tb__DOT__b_ref = 0U;
                } else {
                    ++(vlSymsp->__Vcoverage[119]);
                    vlSelfRef.tb__DOT__b_ref = 0xabU;
                }
            } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[118]);
                vlSelfRef.tb__DOT__b_ref = 0xd8U;
            } else {
                ++(vlSymsp->__Vcoverage[117]);
                vlSelfRef.tb__DOT__b_ref = 0x90U;
            }
        } else if ((0x10U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((8U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[116]);
                            vlSelfRef.tb__DOT__b_ref = 0x84U;
                        } else {
                            ++(vlSymsp->__Vcoverage[115]);
                            vlSelfRef.tb__DOT__b_ref = 0x9dU;
                        }
                    } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[114]);
                        vlSelfRef.tb__DOT__b_ref = 0x8dU;
                    } else {
                        ++(vlSymsp->__Vcoverage[113]);
                        vlSelfRef.tb__DOT__b_ref = 0xa7U;
                    }
                } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[112]);
                        vlSelfRef.tb__DOT__b_ref = 0x57U;
                    } else {
                        ++(vlSymsp->__Vcoverage[111]);
                        vlSelfRef.tb__DOT__b_ref = 0x46U;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[110]);
                    vlSelfRef.tb__DOT__b_ref = 0x15U;
                } else {
                    ++(vlSymsp->__Vcoverage[109]);
                    vlSelfRef.tb__DOT__b_ref = 0x5eU;
                }
            } else if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[108]);
                        vlSelfRef.tb__DOT__b_ref = 0xdaU;
                    } else {
                        ++(vlSymsp->__Vcoverage[107]);
                        vlSelfRef.tb__DOT__b_ref = 0xb9U;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[106]);
                    vlSelfRef.tb__DOT__b_ref = 0xedU;
                } else {
                    ++(vlSymsp->__Vcoverage[105]);
                    vlSelfRef.tb__DOT__b_ref = 0xfdU;
                }
            } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[104]);
                    vlSelfRef.tb__DOT__b_ref = 0x50U;
                } else {
                    ++(vlSymsp->__Vcoverage[103]);
                    vlSelfRef.tb__DOT__b_ref = 0x48U;
                }
            } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[102]);
                vlSelfRef.tb__DOT__b_ref = 0x70U;
            } else {
                ++(vlSymsp->__Vcoverage[101]);
                vlSelfRef.tb__DOT__b_ref = 0x6cU;
            }
        } else if ((8U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[100]);
                        vlSelfRef.tb__DOT__b_ref = 0x92U;
                    } else {
                        ++(vlSymsp->__Vcoverage[99]);
                        vlSelfRef.tb__DOT__b_ref = 0xb6U;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[98]);
                    vlSelfRef.tb__DOT__b_ref = 0x65U;
                } else {
                    ++(vlSymsp->__Vcoverage[97]);
                    vlSelfRef.tb__DOT__b_ref = 0x5dU;
                }
            } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[96]);
                    vlSelfRef.tb__DOT__b_ref = 0xccU;
                } else {
                    ++(vlSymsp->__Vcoverage[95]);
                    vlSelfRef.tb__DOT__b_ref = 0x5cU;
                }
            } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[94]);
                vlSelfRef.tb__DOT__b_ref = 0xa4U;
            } else {
                ++(vlSymsp->__Vcoverage[93]);
                vlSelfRef.tb__DOT__b_ref = 0xd4U;
            }
        } else if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[92]);
                    vlSelfRef.tb__DOT__b_ref = 0x16U;
                } else {
                    ++(vlSymsp->__Vcoverage[91]);
                    vlSelfRef.tb__DOT__b_ref = 0x98U;
                }
            } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[90]);
                vlSelfRef.tb__DOT__b_ref = 0x68U;
            } else {
                ++(vlSymsp->__Vcoverage[89]);
                vlSelfRef.tb__DOT__b_ref = 0x86U;
            }
        } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[88]);
                vlSelfRef.tb__DOT__b_ref = 0x64U;
            } else {
                ++(vlSymsp->__Vcoverage[87]);
                vlSelfRef.tb__DOT__b_ref = 0xf6U;
            }
        } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
            ++(vlSymsp->__Vcoverage[86]);
            vlSelfRef.tb__DOT__b_ref = 0xf8U;
        } else {
            ++(vlSymsp->__Vcoverage[85]);
            vlSelfRef.tb__DOT__b_ref = 0x72U;
        }
    } else if ((0x20U & (IData)(vlSelfRef.tb__DOT__a))) {
        if ((0x10U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((8U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[84]);
                            vlSelfRef.tb__DOT__b_ref = 0x25U;
                        } else {
                            ++(vlSymsp->__Vcoverage[83]);
                            vlSelfRef.tb__DOT__b_ref = 0xd1U;
                        }
                    } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[82]);
                        vlSelfRef.tb__DOT__b_ref = 0x8bU;
                    } else {
                        ++(vlSymsp->__Vcoverage[81]);
                        vlSelfRef.tb__DOT__b_ref = 0x6dU;
                    }
                } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[80]);
                        vlSelfRef.tb__DOT__b_ref = 0x49U;
                    } else {
                        ++(vlSymsp->__Vcoverage[79]);
                        vlSelfRef.tb__DOT__b_ref = 0xa2U;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[78]);
                    vlSelfRef.tb__DOT__b_ref = 0x5bU;
                } else {
                    ++(vlSymsp->__Vcoverage[77]);
                    vlSelfRef.tb__DOT__b_ref = 0x76U;
                }
            } else if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[76]);
                        vlSelfRef.tb__DOT__b_ref = 0xb2U;
                    } else {
                        ++(vlSymsp->__Vcoverage[75]);
                        vlSelfRef.tb__DOT__b_ref = 0x24U;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[74]);
                    vlSelfRef.tb__DOT__b_ref = 0xd9U;
                } else {
                    ++(vlSymsp->__Vcoverage[73]);
                    vlSelfRef.tb__DOT__b_ref = 0x28U;
                }
            } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[72]);
                    vlSelfRef.tb__DOT__b_ref = 0x66U;
                } else {
                    ++(vlSymsp->__Vcoverage[71]);
                    vlSelfRef.tb__DOT__b_ref = 0xa1U;
                }
            } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[70]);
                vlSelfRef.tb__DOT__b_ref = 0x2eU;
            } else {
                ++(vlSymsp->__Vcoverage[69]);
                vlSelfRef.tb__DOT__b_ref = 8U;
            }
        } else if ((8U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[68]);
                        vlSelfRef.tb__DOT__b_ref = 0x4eU;
                    } else {
                        ++(vlSymsp->__Vcoverage[67]);
                        vlSelfRef.tb__DOT__b_ref = 0xc3U;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[66]);
                    vlSelfRef.tb__DOT__b_ref = 0xfaU;
                } else {
                    ++(vlSymsp->__Vcoverage[65]);
                    vlSelfRef.tb__DOT__b_ref = 0x42U;
                }
            } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[64]);
                    vlSelfRef.tb__DOT__b_ref = 0xbU;
                } else {
                    ++(vlSymsp->__Vcoverage[63]);
                    vlSelfRef.tb__DOT__b_ref = 0x95U;
                }
            } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[62]);
                vlSelfRef.tb__DOT__b_ref = 0x4cU;
            } else {
                ++(vlSymsp->__Vcoverage[61]);
                vlSelfRef.tb__DOT__b_ref = 0xeeU;
            }
        } else if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[60]);
                    vlSelfRef.tb__DOT__b_ref = 0x3dU;
                } else {
                    ++(vlSymsp->__Vcoverage[59]);
                    vlSelfRef.tb__DOT__b_ref = 0x23U;
                }
            } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[58]);
                vlSelfRef.tb__DOT__b_ref = 0xc2U;
            } else {
                ++(vlSymsp->__Vcoverage[57]);
                vlSelfRef.tb__DOT__b_ref = 0xa6U;
            }
        } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[56]);
                vlSelfRef.tb__DOT__b_ref = 0x32U;
            } else {
                ++(vlSymsp->__Vcoverage[55]);
                vlSelfRef.tb__DOT__b_ref = 0x94U;
            }
        } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
            ++(vlSymsp->__Vcoverage[54]);
            vlSelfRef.tb__DOT__b_ref = 0x7bU;
        } else {
            ++(vlSymsp->__Vcoverage[53]);
            vlSelfRef.tb__DOT__b_ref = 0x54U;
        }
    } else if ((0x10U & (IData)(vlSelfRef.tb__DOT__a))) {
        if ((8U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[52]);
                        vlSelfRef.tb__DOT__b_ref = 0xcbU;
                    } else {
                        ++(vlSymsp->__Vcoverage[51]);
                        vlSelfRef.tb__DOT__b_ref = 0xe9U;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[50]);
                    vlSelfRef.tb__DOT__b_ref = 0xdeU;
                } else {
                    ++(vlSymsp->__Vcoverage[49]);
                    vlSelfRef.tb__DOT__b_ref = 0xc4U;
                }
            } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[48]);
                    vlSelfRef.tb__DOT__b_ref = 0x44U;
                } else {
                    ++(vlSymsp->__Vcoverage[47]);
                    vlSelfRef.tb__DOT__b_ref = 0x43U;
                }
            } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[46]);
                vlSelfRef.tb__DOT__b_ref = 0x8eU;
            } else {
                ++(vlSymsp->__Vcoverage[45]);
                vlSelfRef.tb__DOT__b_ref = 0x34U;
            }
        } else if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[44]);
                    vlSelfRef.tb__DOT__b_ref = 0x87U;
                } else {
                    ++(vlSymsp->__Vcoverage[43]);
                    vlSelfRef.tb__DOT__b_ref = 0xffU;
                }
            } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[42]);
                vlSelfRef.tb__DOT__b_ref = 0x2fU;
            } else {
                ++(vlSymsp->__Vcoverage[41]);
                vlSelfRef.tb__DOT__b_ref = 0x9bU;
            }
        } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[40]);
                vlSelfRef.tb__DOT__b_ref = 0x82U;
            } else {
                ++(vlSymsp->__Vcoverage[39]);
                vlSelfRef.tb__DOT__b_ref = 0x39U;
            }
        } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
            ++(vlSymsp->__Vcoverage[38]);
            vlSelfRef.tb__DOT__b_ref = 0xe3U;
        } else {
            ++(vlSymsp->__Vcoverage[37]);
            vlSelfRef.tb__DOT__b_ref = 0x7cU;
        }
    } else if ((8U & (IData)(vlSelfRef.tb__DOT__a))) {
        if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[36]);
                    vlSelfRef.tb__DOT__b_ref = 0xfbU;
                } else {
                    ++(vlSymsp->__Vcoverage[35]);
                    vlSelfRef.tb__DOT__b_ref = 0xd7U;
                }
            } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[34]);
                vlSelfRef.tb__DOT__b_ref = 0xf3U;
            } else {
                ++(vlSymsp->__Vcoverage[33]);
                vlSelfRef.tb__DOT__b_ref = 0x81U;
            }
        } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[32]);
                vlSelfRef.tb__DOT__b_ref = 0x9eU;
            } else {
                ++(vlSymsp->__Vcoverage[31]);
                vlSelfRef.tb__DOT__b_ref = 0xa3U;
            }
        } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
            ++(vlSymsp->__Vcoverage[30]);
            vlSelfRef.tb__DOT__b_ref = 0x40U;
        } else {
            ++(vlSymsp->__Vcoverage[29]);
            vlSelfRef.tb__DOT__b_ref = 0xbfU;
        }
    } else if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
        if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[28]);
                vlSelfRef.tb__DOT__b_ref = 0x38U;
            } else {
                ++(vlSymsp->__Vcoverage[27]);
                vlSelfRef.tb__DOT__b_ref = 0xa5U;
            }
        } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
            ++(vlSymsp->__Vcoverage[26]);
            vlSelfRef.tb__DOT__b_ref = 0x36U;
        } else {
            ++(vlSymsp->__Vcoverage[25]);
            vlSelfRef.tb__DOT__b_ref = 0x30U;
        }
    } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
        if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
            ++(vlSymsp->__Vcoverage[24]);
            vlSelfRef.tb__DOT__b_ref = 0xd5U;
        } else {
            ++(vlSymsp->__Vcoverage[23]);
            vlSelfRef.tb__DOT__b_ref = 0x6aU;
        }
    } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
        ++(vlSymsp->__Vcoverage[22]);
        vlSelfRef.tb__DOT__b_ref = 9U;
    } else {
        ++(vlSymsp->__Vcoverage[21]);
        vlSelfRef.tb__DOT__b_ref = 0x52U;
    }
    ++(vlSymsp->__Vcoverage[277]);
    if ((0x80U & (IData)(vlSelfRef.tb__DOT__a))) {
        if ((0x40U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((0x20U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((0x10U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((8U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                            if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                                if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                                    vlSelfRef.tb__DOT__b_dut = 0x7dU;
                                    ++(vlSymsp->__Vcoverage[533]);
                                } else {
                                    ++(vlSymsp->__Vcoverage[532]);
                                    vlSelfRef.tb__DOT__b_dut = 0xcU;
                                }
                            } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                                ++(vlSymsp->__Vcoverage[531]);
                                vlSelfRef.tb__DOT__b_dut = 0x21U;
                            } else {
                                ++(vlSymsp->__Vcoverage[530]);
                                vlSelfRef.tb__DOT__b_dut = 0x55U;
                            }
                        } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                            if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                                ++(vlSymsp->__Vcoverage[529]);
                                vlSelfRef.tb__DOT__b_dut = 0x63U;
                            } else {
                                ++(vlSymsp->__Vcoverage[528]);
                                vlSelfRef.tb__DOT__b_dut = 0x14U;
                            }
                        } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[527]);
                            vlSelfRef.tb__DOT__b_dut = 0x69U;
                        } else {
                            ++(vlSymsp->__Vcoverage[526]);
                            vlSelfRef.tb__DOT__b_dut = 0xe1U;
                        }
                    } else if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                            if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                                ++(vlSymsp->__Vcoverage[525]);
                                vlSelfRef.tb__DOT__b_dut = 0x26U;
                            } else {
                                ++(vlSymsp->__Vcoverage[524]);
                                vlSelfRef.tb__DOT__b_dut = 0xd6U;
                            }
                        } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[523]);
                            vlSelfRef.tb__DOT__b_dut = 0x77U;
                        } else {
                            ++(vlSymsp->__Vcoverage[522]);
                            vlSelfRef.tb__DOT__b_dut = 0xbaU;
                        }
                    } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[521]);
                            vlSelfRef.tb__DOT__b_dut = 0x7eU;
                        } else {
                            ++(vlSymsp->__Vcoverage[520]);
                            vlSelfRef.tb__DOT__b_dut = 4U;
                        }
                    } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[519]);
                        vlSelfRef.tb__DOT__b_dut = 0x2bU;
                    } else {
                        ++(vlSymsp->__Vcoverage[518]);
                        vlSelfRef.tb__DOT__b_dut = 0x17U;
                    }
                } else if ((8U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                            if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                                ++(vlSymsp->__Vcoverage[517]);
                                vlSelfRef.tb__DOT__b_dut = 0x61U;
                            } else {
                                ++(vlSymsp->__Vcoverage[516]);
                                vlSelfRef.tb__DOT__b_dut = 0x99U;
                            }
                        } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[515]);
                            vlSelfRef.tb__DOT__b_dut = 0x53U;
                        } else {
                            ++(vlSymsp->__Vcoverage[514]);
                            vlSelfRef.tb__DOT__b_dut = 0x83U;
                        }
                    } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[513]);
                            vlSelfRef.tb__DOT__b_dut = 0x3cU;
                        } else {
                            ++(vlSymsp->__Vcoverage[512]);
                            vlSelfRef.tb__DOT__b_dut = 0xbbU;
                        }
                    } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[511]);
                        vlSelfRef.tb__DOT__b_dut = 0xebU;
                    } else {
                        ++(vlSymsp->__Vcoverage[510]);
                        vlSelfRef.tb__DOT__b_dut = 0xc8U;
                    }
                } else if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[509]);
                            vlSelfRef.tb__DOT__b_dut = 0xb0U;
                        } else {
                            ++(vlSymsp->__Vcoverage[508]);
                            vlSelfRef.tb__DOT__b_dut = 0xf5U;
                        }
                    } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[507]);
                        vlSelfRef.tb__DOT__b_dut = 0x2aU;
                    } else {
                        ++(vlSymsp->__Vcoverage[506]);
                        vlSelfRef.tb__DOT__b_dut = 0xaeU;
                    }
                } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[505]);
                        vlSelfRef.tb__DOT__b_dut = 0x4dU;
                    } else {
                        ++(vlSymsp->__Vcoverage[504]);
                        vlSelfRef.tb__DOT__b_dut = 0x3bU;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[503]);
                    vlSelfRef.tb__DOT__b_dut = 0xe0U;
                } else {
                    ++(vlSymsp->__Vcoverage[502]);
                    vlSelfRef.tb__DOT__b_dut = 0xa0U;
                }
            } else if ((0x10U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((8U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                            if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                                ++(vlSymsp->__Vcoverage[501]);
                                vlSelfRef.tb__DOT__b_dut = 0xefU;
                            } else {
                                ++(vlSymsp->__Vcoverage[500]);
                                vlSelfRef.tb__DOT__b_dut = 0x9cU;
                            }
                        } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[499]);
                            vlSelfRef.tb__DOT__b_dut = 0xc9U;
                        } else {
                            ++(vlSymsp->__Vcoverage[498]);
                            vlSelfRef.tb__DOT__b_dut = 0x93U;
                        }
                    } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[497]);
                            vlSelfRef.tb__DOT__b_dut = 0x9fU;
                        } else {
                            ++(vlSymsp->__Vcoverage[496]);
                            vlSelfRef.tb__DOT__b_dut = 0x7aU;
                        }
                    } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[495]);
                        vlSelfRef.tb__DOT__b_dut = 0xe5U;
                    } else {
                        ++(vlSymsp->__Vcoverage[494]);
                        vlSelfRef.tb__DOT__b_dut = 0x2dU;
                    }
                } else if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[493]);
                            vlSelfRef.tb__DOT__b_dut = 0xdU;
                        } else {
                            ++(vlSymsp->__Vcoverage[492]);
                            vlSelfRef.tb__DOT__b_dut = 0x4aU;
                        }
                    } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[491]);
                        vlSelfRef.tb__DOT__b_dut = 0xb5U;
                    } else {
                        ++(vlSymsp->__Vcoverage[490]);
                        vlSelfRef.tb__DOT__b_dut = 0x19U;
                    }
                } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[489]);
                        vlSelfRef.tb__DOT__b_dut = 0xa9U;
                    } else {
                        ++(vlSymsp->__Vcoverage[488]);
                        vlSelfRef.tb__DOT__b_dut = 0x7fU;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[487]);
                    vlSelfRef.tb__DOT__b_dut = 0x51U;
                } else {
                    ++(vlSymsp->__Vcoverage[486]);
                    vlSelfRef.tb__DOT__b_dut = 0x60U;
                }
            } else if ((8U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[485]);
                            vlSelfRef.tb__DOT__b_dut = 0x5fU;
                        } else {
                            ++(vlSymsp->__Vcoverage[484]);
                            vlSelfRef.tb__DOT__b_dut = 0xecU;
                        }
                    } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[483]);
                        vlSelfRef.tb__DOT__b_dut = 0x80U;
                    } else {
                        ++(vlSymsp->__Vcoverage[482]);
                        vlSelfRef.tb__DOT__b_dut = 0x27U;
                    }
                } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[481]);
                        vlSelfRef.tb__DOT__b_dut = 0x59U;
                    } else {
                        ++(vlSymsp->__Vcoverage[480]);
                        vlSelfRef.tb__DOT__b_dut = 0x10U;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[479]);
                    vlSelfRef.tb__DOT__b_dut = 0x12U;
                } else {
                    ++(vlSymsp->__Vcoverage[478]);
                    vlSelfRef.tb__DOT__b_dut = 0xb1U;
                }
            } else if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[477]);
                        vlSelfRef.tb__DOT__b_dut = 0x31U;
                    } else {
                        ++(vlSymsp->__Vcoverage[476]);
                        vlSelfRef.tb__DOT__b_dut = 0xc7U;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[475]);
                    vlSelfRef.tb__DOT__b_dut = 7U;
                } else {
                    ++(vlSymsp->__Vcoverage[474]);
                    vlSelfRef.tb__DOT__b_dut = 0x88U;
                }
            } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[473]);
                    vlSelfRef.tb__DOT__b_dut = 0x33U;
                } else {
                    ++(vlSymsp->__Vcoverage[472]);
                    vlSelfRef.tb__DOT__b_dut = 0xa8U;
                }
            } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[471]);
                vlSelfRef.tb__DOT__b_dut = 0xddU;
            } else {
                ++(vlSymsp->__Vcoverage[470]);
                vlSelfRef.tb__DOT__b_dut = 0x1fU;
            }
        } else if ((0x20U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((0x10U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((8U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                            if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                                ++(vlSymsp->__Vcoverage[469]);
                                vlSelfRef.tb__DOT__b_dut = 0xf4U;
                            } else {
                                ++(vlSymsp->__Vcoverage[468]);
                                vlSelfRef.tb__DOT__b_dut = 0x5aU;
                            }
                        } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[467]);
                            vlSelfRef.tb__DOT__b_dut = 0xcdU;
                        } else {
                            ++(vlSymsp->__Vcoverage[466]);
                            vlSelfRef.tb__DOT__b_dut = 0x78U;
                        }
                    } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[465]);
                            vlSelfRef.tb__DOT__b_dut = 0xfeU;
                        } else {
                            ++(vlSymsp->__Vcoverage[464]);
                            vlSelfRef.tb__DOT__b_dut = 0xc0U;
                        }
                    } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[463]);
                        vlSelfRef.tb__DOT__b_dut = 0xdbU;
                    } else {
                        ++(vlSymsp->__Vcoverage[462]);
                        vlSelfRef.tb__DOT__b_dut = 0x9aU;
                    }
                } else if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[461]);
                            vlSelfRef.tb__DOT__b_dut = 0x20U;
                        } else {
                            ++(vlSymsp->__Vcoverage[460]);
                            vlSelfRef.tb__DOT__b_dut = 0x79U;
                        }
                    } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[459]);
                        vlSelfRef.tb__DOT__b_dut = 0xd2U;
                    } else {
                        ++(vlSymsp->__Vcoverage[458]);
                        vlSelfRef.tb__DOT__b_dut = 0xc6U;
                    }
                } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[457]);
                        vlSelfRef.tb__DOT__b_dut = 0x4bU;
                    } else {
                        ++(vlSymsp->__Vcoverage[456]);
                        vlSelfRef.tb__DOT__b_dut = 0x3eU;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[455]);
                    vlSelfRef.tb__DOT__b_dut = 0x56U;
                } else {
                    ++(vlSymsp->__Vcoverage[454]);
                    vlSelfRef.tb__DOT__b_dut = 0xfcU;
                }
            } else if ((8U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[453]);
                            vlSelfRef.tb__DOT__b_dut = 0x1bU;
                        } else {
                            ++(vlSymsp->__Vcoverage[452]);
                            vlSelfRef.tb__DOT__b_dut = 0xbeU;
                        }
                    } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[451]);
                        vlSelfRef.tb__DOT__b_dut = 0x18U;
                    } else {
                        ++(vlSymsp->__Vcoverage[450]);
                        vlSelfRef.tb__DOT__b_dut = 0xaaU;
                    }
                } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[449]);
                        vlSelfRef.tb__DOT__b_dut = 0xeU;
                    } else {
                        ++(vlSymsp->__Vcoverage[448]);
                        vlSelfRef.tb__DOT__b_dut = 0x62U;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[447]);
                    vlSelfRef.tb__DOT__b_dut = 0xb7U;
                } else {
                    ++(vlSymsp->__Vcoverage[446]);
                    vlSelfRef.tb__DOT__b_dut = 0x6fU;
                }
            } else if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[445]);
                        vlSelfRef.tb__DOT__b_dut = 0x89U;
                    } else {
                        ++(vlSymsp->__Vcoverage[444]);
                        vlSelfRef.tb__DOT__b_dut = 0xc5U;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[443]);
                    vlSelfRef.tb__DOT__b_dut = 0x29U;
                } else {
                    ++(vlSymsp->__Vcoverage[442]);
                    vlSelfRef.tb__DOT__b_dut = 0x1dU;
                }
            } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[441]);
                    vlSelfRef.tb__DOT__b_dut = 0x71U;
                } else {
                    ++(vlSymsp->__Vcoverage[440]);
                    vlSelfRef.tb__DOT__b_dut = 0x1aU;
                }
            } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[439]);
                vlSelfRef.tb__DOT__b_dut = 0xf1U;
            } else {
                ++(vlSymsp->__Vcoverage[438]);
                vlSelfRef.tb__DOT__b_dut = 0x47U;
            }
        } else if ((0x10U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((8U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[437]);
                            vlSelfRef.tb__DOT__b_dut = 0x6eU;
                        } else {
                            ++(vlSymsp->__Vcoverage[436]);
                            vlSelfRef.tb__DOT__b_dut = 0xdfU;
                        }
                    } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[435]);
                        vlSelfRef.tb__DOT__b_dut = 0x75U;
                    } else {
                        ++(vlSymsp->__Vcoverage[434]);
                        vlSelfRef.tb__DOT__b_dut = 0x1cU;
                    }
                } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[433]);
                        vlSelfRef.tb__DOT__b_dut = 0xe8U;
                    } else {
                        ++(vlSymsp->__Vcoverage[432]);
                        vlSelfRef.tb__DOT__b_dut = 0x37U;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[431]);
                    vlSelfRef.tb__DOT__b_dut = 0xf9U;
                } else {
                    ++(vlSymsp->__Vcoverage[430]);
                    vlSelfRef.tb__DOT__b_dut = 0xe2U;
                }
            } else if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[429]);
                        vlSelfRef.tb__DOT__b_dut = 0x85U;
                    } else {
                        ++(vlSymsp->__Vcoverage[428]);
                        vlSelfRef.tb__DOT__b_dut = 0x35U;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[427]);
                    vlSelfRef.tb__DOT__b_dut = 0xadU;
                } else {
                    ++(vlSymsp->__Vcoverage[426]);
                    vlSelfRef.tb__DOT__b_dut = 0xe7U;
                }
            } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[425]);
                    vlSelfRef.tb__DOT__b_dut = 0x22U;
                } else {
                    ++(vlSymsp->__Vcoverage[424]);
                    vlSelfRef.tb__DOT__b_dut = 0x74U;
                }
            } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[423]);
                vlSelfRef.tb__DOT__b_dut = 0xacU;
            } else {
                ++(vlSymsp->__Vcoverage[422]);
                vlSelfRef.tb__DOT__b_dut = 0x96U;
            }
        } else if ((8U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[421]);
                        vlSelfRef.tb__DOT__b_dut = 0x73U;
                    } else {
                        ++(vlSymsp->__Vcoverage[420]);
                        vlSelfRef.tb__DOT__b_dut = 0xe6U;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[419]);
                    vlSelfRef.tb__DOT__b_dut = 0xb4U;
                } else {
                    ++(vlSymsp->__Vcoverage[418]);
                    vlSelfRef.tb__DOT__b_dut = 0xf0U;
                }
            } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[417]);
                    vlSelfRef.tb__DOT__b_dut = 0xceU;
                } else {
                    ++(vlSymsp->__Vcoverage[416]);
                    vlSelfRef.tb__DOT__b_dut = 0xcfU;
                }
            } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[415]);
                vlSelfRef.tb__DOT__b_dut = 0xf2U;
            } else {
                ++(vlSymsp->__Vcoverage[414]);
                vlSelfRef.tb__DOT__b_dut = 0x97U;
            }
        } else if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[413]);
                    vlSelfRef.tb__DOT__b_dut = 0xeaU;
                } else {
                    ++(vlSymsp->__Vcoverage[412]);
                    vlSelfRef.tb__DOT__b_dut = 0xdcU;
                }
            } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[411]);
                vlSelfRef.tb__DOT__b_dut = 0x67U;
            } else {
                ++(vlSymsp->__Vcoverage[410]);
                vlSelfRef.tb__DOT__b_dut = 0x4fU;
            }
        } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[409]);
                vlSelfRef.tb__DOT__b_dut = 0x41U;
            } else {
                ++(vlSymsp->__Vcoverage[408]);
                vlSelfRef.tb__DOT__b_dut = 0x11U;
            }
        } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
            ++(vlSymsp->__Vcoverage[407]);
            vlSelfRef.tb__DOT__b_dut = 0x91U;
        } else {
            ++(vlSymsp->__Vcoverage[406]);
            vlSelfRef.tb__DOT__b_dut = 0x3aU;
        }
    } else if ((0x40U & (IData)(vlSelfRef.tb__DOT__a))) {
        if ((0x20U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((0x10U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((8U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                            if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                                ++(vlSymsp->__Vcoverage[405]);
                                vlSelfRef.tb__DOT__b_dut = 0x6bU;
                            } else {
                                ++(vlSymsp->__Vcoverage[404]);
                                vlSelfRef.tb__DOT__b_dut = 0x8aU;
                            }
                        } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[403]);
                            vlSelfRef.tb__DOT__b_dut = 0x13U;
                        } else {
                            ++(vlSymsp->__Vcoverage[402]);
                            vlSelfRef.tb__DOT__b_dut = 1U;
                        }
                    } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[401]);
                            vlSelfRef.tb__DOT__b_dut = 3U;
                        } else {
                            ++(vlSymsp->__Vcoverage[400]);
                            vlSelfRef.tb__DOT__b_dut = 0xbdU;
                        }
                    } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[399]);
                        vlSelfRef.tb__DOT__b_dut = 0xafU;
                    } else {
                        ++(vlSymsp->__Vcoverage[398]);
                        vlSelfRef.tb__DOT__b_dut = 0xc1U;
                    }
                } else if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[397]);
                            vlSelfRef.tb__DOT__b_dut = 2U;
                        } else {
                            ++(vlSymsp->__Vcoverage[396]);
                            vlSelfRef.tb__DOT__b_dut = 0xfU;
                        }
                    } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[395]);
                        vlSelfRef.tb__DOT__b_dut = 0x3fU;
                    } else {
                        ++(vlSymsp->__Vcoverage[394]);
                        vlSelfRef.tb__DOT__b_dut = 0xcaU;
                    }
                } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[393]);
                        vlSelfRef.tb__DOT__b_dut = 0x8fU;
                    } else {
                        ++(vlSymsp->__Vcoverage[392]);
                        vlSelfRef.tb__DOT__b_dut = 0x1eU;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[391]);
                    vlSelfRef.tb__DOT__b_dut = 0x2cU;
                } else {
                    ++(vlSymsp->__Vcoverage[390]);
                    vlSelfRef.tb__DOT__b_dut = 0xd0U;
                }
            } else if ((8U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[389]);
                            vlSelfRef.tb__DOT__b_dut = 6U;
                        } else {
                            ++(vlSymsp->__Vcoverage[388]);
                            vlSelfRef.tb__DOT__b_dut = 0x45U;
                        }
                    } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[387]);
                        vlSelfRef.tb__DOT__b_dut = 0xb3U;
                    } else {
                        ++(vlSymsp->__Vcoverage[386]);
                        vlSelfRef.tb__DOT__b_dut = 0xb8U;
                    }
                } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[385]);
                        vlSelfRef.tb__DOT__b_dut = 5U;
                    } else {
                        ++(vlSymsp->__Vcoverage[384]);
                        vlSelfRef.tb__DOT__b_dut = 0x58U;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[383]);
                    vlSelfRef.tb__DOT__b_dut = 0xe4U;
                } else {
                    ++(vlSymsp->__Vcoverage[382]);
                    vlSelfRef.tb__DOT__b_dut = 0xf7U;
                }
            } else if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[381]);
                        vlSelfRef.tb__DOT__b_dut = 0xaU;
                    } else {
                        ++(vlSymsp->__Vcoverage[380]);
                        vlSelfRef.tb__DOT__b_dut = 0xd3U;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[379]);
                    vlSelfRef.tb__DOT__b_dut = 0xbcU;
                } else {
                    ++(vlSymsp->__Vcoverage[378]);
                    vlSelfRef.tb__DOT__b_dut = 0x8cU;
                }
            } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[377]);
                    vlSelfRef.tb__DOT__b_dut = 0U;
                } else {
                    ++(vlSymsp->__Vcoverage[376]);
                    vlSelfRef.tb__DOT__b_dut = 0xabU;
                }
            } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[375]);
                vlSelfRef.tb__DOT__b_dut = 0xd8U;
            } else {
                ++(vlSymsp->__Vcoverage[374]);
                vlSelfRef.tb__DOT__b_dut = 0x90U;
            }
        } else if ((0x10U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((8U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[373]);
                            vlSelfRef.tb__DOT__b_dut = 0x84U;
                        } else {
                            ++(vlSymsp->__Vcoverage[372]);
                            vlSelfRef.tb__DOT__b_dut = 0x9dU;
                        }
                    } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[371]);
                        vlSelfRef.tb__DOT__b_dut = 0x8dU;
                    } else {
                        ++(vlSymsp->__Vcoverage[370]);
                        vlSelfRef.tb__DOT__b_dut = 0xa7U;
                    }
                } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[369]);
                        vlSelfRef.tb__DOT__b_dut = 0x57U;
                    } else {
                        ++(vlSymsp->__Vcoverage[368]);
                        vlSelfRef.tb__DOT__b_dut = 0x46U;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[367]);
                    vlSelfRef.tb__DOT__b_dut = 0x15U;
                } else {
                    ++(vlSymsp->__Vcoverage[366]);
                    vlSelfRef.tb__DOT__b_dut = 0x5eU;
                }
            } else if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[365]);
                        vlSelfRef.tb__DOT__b_dut = 0xdaU;
                    } else {
                        ++(vlSymsp->__Vcoverage[364]);
                        vlSelfRef.tb__DOT__b_dut = 0xb9U;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[363]);
                    vlSelfRef.tb__DOT__b_dut = 0xedU;
                } else {
                    ++(vlSymsp->__Vcoverage[362]);
                    vlSelfRef.tb__DOT__b_dut = 0xfdU;
                }
            } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[361]);
                    vlSelfRef.tb__DOT__b_dut = 0x50U;
                } else {
                    ++(vlSymsp->__Vcoverage[360]);
                    vlSelfRef.tb__DOT__b_dut = 0x48U;
                }
            } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[359]);
                vlSelfRef.tb__DOT__b_dut = 0x70U;
            } else {
                ++(vlSymsp->__Vcoverage[358]);
                vlSelfRef.tb__DOT__b_dut = 0x6cU;
            }
        } else if ((8U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[357]);
                        vlSelfRef.tb__DOT__b_dut = 0x92U;
                    } else {
                        ++(vlSymsp->__Vcoverage[356]);
                        vlSelfRef.tb__DOT__b_dut = 0xb6U;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[355]);
                    vlSelfRef.tb__DOT__b_dut = 0x65U;
                } else {
                    ++(vlSymsp->__Vcoverage[354]);
                    vlSelfRef.tb__DOT__b_dut = 0x5dU;
                }
            } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[353]);
                    vlSelfRef.tb__DOT__b_dut = 0xccU;
                } else {
                    ++(vlSymsp->__Vcoverage[352]);
                    vlSelfRef.tb__DOT__b_dut = 0x5cU;
                }
            } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[351]);
                vlSelfRef.tb__DOT__b_dut = 0xa4U;
            } else {
                ++(vlSymsp->__Vcoverage[350]);
                vlSelfRef.tb__DOT__b_dut = 0xd4U;
            }
        } else if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[349]);
                    vlSelfRef.tb__DOT__b_dut = 0x16U;
                } else {
                    ++(vlSymsp->__Vcoverage[348]);
                    vlSelfRef.tb__DOT__b_dut = 0x98U;
                }
            } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[347]);
                vlSelfRef.tb__DOT__b_dut = 0x68U;
            } else {
                ++(vlSymsp->__Vcoverage[346]);
                vlSelfRef.tb__DOT__b_dut = 0x86U;
            }
        } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[345]);
                vlSelfRef.tb__DOT__b_dut = 0x64U;
            } else {
                ++(vlSymsp->__Vcoverage[344]);
                vlSelfRef.tb__DOT__b_dut = 0xf6U;
            }
        } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
            ++(vlSymsp->__Vcoverage[343]);
            vlSelfRef.tb__DOT__b_dut = 0xf8U;
        } else {
            ++(vlSymsp->__Vcoverage[342]);
            vlSelfRef.tb__DOT__b_dut = 0x72U;
        }
    } else if ((0x20U & (IData)(vlSelfRef.tb__DOT__a))) {
        if ((0x10U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((8U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                        if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                            ++(vlSymsp->__Vcoverage[341]);
                            vlSelfRef.tb__DOT__b_dut = 0x25U;
                        } else {
                            ++(vlSymsp->__Vcoverage[340]);
                            vlSelfRef.tb__DOT__b_dut = 0xd1U;
                        }
                    } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[339]);
                        vlSelfRef.tb__DOT__b_dut = 0x8bU;
                    } else {
                        ++(vlSymsp->__Vcoverage[338]);
                        vlSelfRef.tb__DOT__b_dut = 0x6dU;
                    }
                } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[337]);
                        vlSelfRef.tb__DOT__b_dut = 0x49U;
                    } else {
                        ++(vlSymsp->__Vcoverage[336]);
                        vlSelfRef.tb__DOT__b_dut = 0xa2U;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[335]);
                    vlSelfRef.tb__DOT__b_dut = 0x5bU;
                } else {
                    ++(vlSymsp->__Vcoverage[334]);
                    vlSelfRef.tb__DOT__b_dut = 0x76U;
                }
            } else if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[333]);
                        vlSelfRef.tb__DOT__b_dut = 0xb2U;
                    } else {
                        ++(vlSymsp->__Vcoverage[332]);
                        vlSelfRef.tb__DOT__b_dut = 0x24U;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[331]);
                    vlSelfRef.tb__DOT__b_dut = 0xd9U;
                } else {
                    ++(vlSymsp->__Vcoverage[330]);
                    vlSelfRef.tb__DOT__b_dut = 0x28U;
                }
            } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[329]);
                    vlSelfRef.tb__DOT__b_dut = 0x66U;
                } else {
                    ++(vlSymsp->__Vcoverage[328]);
                    vlSelfRef.tb__DOT__b_dut = 0xa1U;
                }
            } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[327]);
                vlSelfRef.tb__DOT__b_dut = 0x2eU;
            } else {
                ++(vlSymsp->__Vcoverage[326]);
                vlSelfRef.tb__DOT__b_dut = 8U;
            }
        } else if ((8U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[325]);
                        vlSelfRef.tb__DOT__b_dut = 0x4eU;
                    } else {
                        ++(vlSymsp->__Vcoverage[324]);
                        vlSelfRef.tb__DOT__b_dut = 0xc3U;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[323]);
                    vlSelfRef.tb__DOT__b_dut = 0xfaU;
                } else {
                    ++(vlSymsp->__Vcoverage[322]);
                    vlSelfRef.tb__DOT__b_dut = 0x42U;
                }
            } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[321]);
                    vlSelfRef.tb__DOT__b_dut = 0xbU;
                } else {
                    ++(vlSymsp->__Vcoverage[320]);
                    vlSelfRef.tb__DOT__b_dut = 0x95U;
                }
            } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[319]);
                vlSelfRef.tb__DOT__b_dut = 0x4cU;
            } else {
                ++(vlSymsp->__Vcoverage[318]);
                vlSelfRef.tb__DOT__b_dut = 0xeeU;
            }
        } else if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[317]);
                    vlSelfRef.tb__DOT__b_dut = 0x3dU;
                } else {
                    ++(vlSymsp->__Vcoverage[316]);
                    vlSelfRef.tb__DOT__b_dut = 0x23U;
                }
            } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[315]);
                vlSelfRef.tb__DOT__b_dut = 0xc2U;
            } else {
                ++(vlSymsp->__Vcoverage[314]);
                vlSelfRef.tb__DOT__b_dut = 0xa6U;
            }
        } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[313]);
                vlSelfRef.tb__DOT__b_dut = 0x32U;
            } else {
                ++(vlSymsp->__Vcoverage[312]);
                vlSelfRef.tb__DOT__b_dut = 0x94U;
            }
        } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
            ++(vlSymsp->__Vcoverage[311]);
            vlSelfRef.tb__DOT__b_dut = 0x7bU;
        } else {
            ++(vlSymsp->__Vcoverage[310]);
            vlSelfRef.tb__DOT__b_dut = 0x54U;
        }
    } else if ((0x10U & (IData)(vlSelfRef.tb__DOT__a))) {
        if ((8U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                    if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                        ++(vlSymsp->__Vcoverage[309]);
                        vlSelfRef.tb__DOT__b_dut = 0xcbU;
                    } else {
                        ++(vlSymsp->__Vcoverage[308]);
                        vlSelfRef.tb__DOT__b_dut = 0xe9U;
                    }
                } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[307]);
                    vlSelfRef.tb__DOT__b_dut = 0xdeU;
                } else {
                    ++(vlSymsp->__Vcoverage[306]);
                    vlSelfRef.tb__DOT__b_dut = 0xc4U;
                }
            } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[305]);
                    vlSelfRef.tb__DOT__b_dut = 0x44U;
                } else {
                    ++(vlSymsp->__Vcoverage[304]);
                    vlSelfRef.tb__DOT__b_dut = 0x43U;
                }
            } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[303]);
                vlSelfRef.tb__DOT__b_dut = 0x8eU;
            } else {
                ++(vlSymsp->__Vcoverage[302]);
                vlSelfRef.tb__DOT__b_dut = 0x34U;
            }
        } else if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[301]);
                    vlSelfRef.tb__DOT__b_dut = 0x87U;
                } else {
                    ++(vlSymsp->__Vcoverage[300]);
                    vlSelfRef.tb__DOT__b_dut = 0xffU;
                }
            } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[299]);
                vlSelfRef.tb__DOT__b_dut = 0x2fU;
            } else {
                ++(vlSymsp->__Vcoverage[298]);
                vlSelfRef.tb__DOT__b_dut = 0x9bU;
            }
        } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[297]);
                vlSelfRef.tb__DOT__b_dut = 0x82U;
            } else {
                ++(vlSymsp->__Vcoverage[296]);
                vlSelfRef.tb__DOT__b_dut = 0x39U;
            }
        } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
            ++(vlSymsp->__Vcoverage[295]);
            vlSelfRef.tb__DOT__b_dut = 0xe3U;
        } else {
            ++(vlSymsp->__Vcoverage[294]);
            vlSelfRef.tb__DOT__b_dut = 0x7cU;
        }
    } else if ((8U & (IData)(vlSelfRef.tb__DOT__a))) {
        if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
                if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                    ++(vlSymsp->__Vcoverage[293]);
                    vlSelfRef.tb__DOT__b_dut = 0xfbU;
                } else {
                    ++(vlSymsp->__Vcoverage[292]);
                    vlSelfRef.tb__DOT__b_dut = 0xd7U;
                }
            } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[291]);
                vlSelfRef.tb__DOT__b_dut = 0xf3U;
            } else {
                ++(vlSymsp->__Vcoverage[290]);
                vlSelfRef.tb__DOT__b_dut = 0x81U;
            }
        } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[289]);
                vlSelfRef.tb__DOT__b_dut = 0x9eU;
            } else {
                ++(vlSymsp->__Vcoverage[288]);
                vlSelfRef.tb__DOT__b_dut = 0xa3U;
            }
        } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
            ++(vlSymsp->__Vcoverage[287]);
            vlSelfRef.tb__DOT__b_dut = 0x40U;
        } else {
            ++(vlSymsp->__Vcoverage[286]);
            vlSelfRef.tb__DOT__b_dut = 0xbfU;
        }
    } else if ((4U & (IData)(vlSelfRef.tb__DOT__a))) {
        if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
            if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
                ++(vlSymsp->__Vcoverage[285]);
                vlSelfRef.tb__DOT__b_dut = 0x38U;
            } else {
                ++(vlSymsp->__Vcoverage[284]);
                vlSelfRef.tb__DOT__b_dut = 0xa5U;
            }
        } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
            ++(vlSymsp->__Vcoverage[283]);
            vlSelfRef.tb__DOT__b_dut = 0x36U;
        } else {
            ++(vlSymsp->__Vcoverage[282]);
            vlSelfRef.tb__DOT__b_dut = 0x30U;
        }
    } else if ((2U & (IData)(vlSelfRef.tb__DOT__a))) {
        if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
            ++(vlSymsp->__Vcoverage[281]);
            vlSelfRef.tb__DOT__b_dut = 0xd5U;
        } else {
            ++(vlSymsp->__Vcoverage[280]);
            vlSelfRef.tb__DOT__b_dut = 0x6aU;
        }
    } else if ((1U & (IData)(vlSelfRef.tb__DOT__a))) {
        ++(vlSymsp->__Vcoverage[279]);
        vlSelfRef.tb__DOT__b_dut = 9U;
    } else {
        ++(vlSymsp->__Vcoverage[278]);
        vlSelfRef.tb__DOT__b_dut = 0x52U;
    }
    ++(vlSymsp->__Vcoverage[534]);
}

VL_INLINE_OPT void Vtb___024root___nba_sequent__TOP__1(Vtb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb___024root___nba_sequent__TOP__1\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.tb__DOT__stats1[0U] = ((IData)(1U) + 
                                     vlSelfRef.tb__DOT__stats1[0U]);
    if (((IData)(vlSelfRef.tb__DOT__b_ref) == ((IData)(vlSelfRef.tb__DOT__b_ref) 
                                               ^ ((IData)(vlSelfRef.tb__DOT__b_dut) 
                                                  ^ (IData)(vlSelfRef.tb__DOT__b_ref))))) {
        ++(vlSymsp->__Vcoverage[10]);
    } else {
        if ((0U == vlSelfRef.tb__DOT__stats1[4U])) {
            ++(vlSymsp->__Vcoverage[7]);
            vlSelfRef.tb__DOT__stats1[3U] = (IData)(VL_TIME_UNITED_Q(1));
        } else {
            ++(vlSymsp->__Vcoverage[8]);
        }
        vlSelfRef.tb__DOT__stats1[4U] = ((IData)(1U) 
                                         + vlSelfRef.tb__DOT__stats1[4U]);
        ++(vlSymsp->__Vcoverage[9]);
    }
    if (((IData)(vlSelfRef.tb__DOT__b_ref) != (((IData)(vlSelfRef.tb__DOT__b_ref) 
                                                ^ (IData)(vlSelfRef.tb__DOT__b_dut)) 
                                               ^ (IData)(vlSelfRef.tb__DOT__b_ref)))) {
        if ((0U == vlSelfRef.tb__DOT__stats1[2U])) {
            ++(vlSymsp->__Vcoverage[11]);
            vlSelfRef.tb__DOT__stats1[1U] = (IData)(VL_TIME_UNITED_Q(1));
        } else {
            ++(vlSymsp->__Vcoverage[12]);
        }
        vlSelfRef.tb__DOT__stats1[2U] = ((IData)(1U) 
                                         + vlSelfRef.tb__DOT__stats1[2U]);
        ++(vlSymsp->__Vcoverage[13]);
    } else {
        ++(vlSymsp->__Vcoverage[14]);
    }
    ++(vlSymsp->__Vcoverage[15]);
}
