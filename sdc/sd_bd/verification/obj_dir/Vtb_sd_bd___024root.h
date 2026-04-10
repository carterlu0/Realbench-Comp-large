// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vtb_sd_bd.h for the primary calling header

#ifndef VERILATED_VTB_SD_BD___024ROOT_H_
#define VERILATED_VTB_SD_BD___024ROOT_H_  // guard

#include "verilated.h"
#include "verilated_cov.h"
#include "verilated_timing.h"


class Vtb_sd_bd__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vtb_sd_bd___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    CData/*0:0*/ tb_sd_bd__DOT__clk;
    CData/*0:0*/ tb_sd_bd__DOT__rst;
    CData/*0:0*/ tb_sd_bd__DOT__we_m;
    CData/*4:0*/ tb_sd_bd__DOT__free_bd_ref;
    CData/*4:0*/ tb_sd_bd__DOT__free_bd_dut;
    CData/*0:0*/ tb_sd_bd__DOT__re_s;
    CData/*0:0*/ tb_sd_bd__DOT__ack_o_s_ref;
    CData/*0:0*/ tb_sd_bd__DOT__ack_o_s_dut;
    CData/*0:0*/ tb_sd_bd__DOT__a_cmp;
    CData/*0:0*/ tb_sd_bd__DOT__wavedrom_enable;
    CData/*0:0*/ tb_sd_bd__DOT__stim1__DOT__reset_test__Vstatic__arfail;
    CData/*0:0*/ tb_sd_bd__DOT__stim1__DOT__reset_test__Vstatic__srfail;
    CData/*0:0*/ tb_sd_bd__DOT__stim1__DOT__reset_test__Vstatic__datafail;
    CData/*0:0*/ tb_sd_bd__DOT__good1__DOT__new_bw;
    CData/*0:0*/ tb_sd_bd__DOT__good1__DOT__last_a_cmp;
    CData/*1:0*/ tb_sd_bd__DOT__good1__DOT__write_cnt;
    CData/*1:0*/ tb_sd_bd__DOT__good1__DOT__read_s_cnt;
    CData/*0:0*/ tb_sd_bd__DOT__good1__DOT__read_cnt;
    CData/*4:0*/ tb_sd_bd__DOT__good1__DOT__m_wr_pnt;
    CData/*4:0*/ tb_sd_bd__DOT__good1__DOT__s_rd_pnt;
    CData/*0:0*/ tb_sd_bd__DOT__top_module1__DOT__new_bw;
    CData/*0:0*/ tb_sd_bd__DOT__top_module1__DOT__last_a_cmp;
    CData/*1:0*/ tb_sd_bd__DOT__top_module1__DOT__write_cnt;
    CData/*1:0*/ tb_sd_bd__DOT__top_module1__DOT__read_s_cnt;
    CData/*0:0*/ tb_sd_bd__DOT__top_module1__DOT__read_cnt;
    CData/*4:0*/ tb_sd_bd__DOT__top_module1__DOT__m_wr_pnt;
    CData/*4:0*/ tb_sd_bd__DOT__top_module1__DOT__s_rd_pnt;
    CData/*0:0*/ tb_sd_bd__DOT__top_module1__DOT__delay_re_s;
    CData/*0:0*/ __VstlFirstIteration;
    CData/*0:0*/ __Vtrigprevexpr___TOP__tb_sd_bd__DOT__clk__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__tb_sd_bd__DOT__rst__0;
    CData/*0:0*/ __VactContinue;
    SData/*15:0*/ tb_sd_bd__DOT__dat_in_m;
    SData/*15:0*/ tb_sd_bd__DOT__dat_out_s_ref;
    SData/*15:0*/ tb_sd_bd__DOT__dat_out_s_dut;
    VlWide<16>/*511:0*/ tb_sd_bd__DOT__wavedrom_title;
    IData/*21:0*/ tb_sd_bd__DOT____VdfgRegularize_h4e4634a2_0_0;
    IData/*31:0*/ __VactIterCount;
    VlWide<9>/*287:0*/ tb_sd_bd__DOT__stats1;
    VlUnpacked<SData/*15:0*/, 32> tb_sd_bd__DOT__good1__DOT__bd_mem;
    VlUnpacked<SData/*15:0*/, 32> tb_sd_bd__DOT__top_module1__DOT__bd_mem;
    VlUnpacked<CData/*0:0*/, 5> __Vm_traceActivity;
    VlDelayScheduler __VdlySched;
    VlTriggerScheduler __VtrigSched_h06a4b496__0;
    VlTriggerScheduler __VtrigSched_h06a4b557__0;
    VlTriggerVec<1> __VstlTriggered;
    VlTriggerVec<4> __VactTriggered;
    VlTriggerVec<4> __VnbaTriggered;

    // INTERNAL VARIABLES
    Vtb_sd_bd__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vtb_sd_bd___024root(Vtb_sd_bd__Syms* symsp, const char* v__name);
    ~Vtb_sd_bd___024root();
    VL_UNCOPYABLE(Vtb_sd_bd___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
    void __vlCoverInsert(uint32_t* countp, bool enable, const char* filenamep, int lineno, int column,
        const char* hierp, const char* pagep, const char* commentp, const char* linescovp);
};


#endif  // guard
