// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb.h for the primary calling header

#include "Vtb__pch.h"
#include "Vtb__Syms.h"
#include "Vtb_aes_sbox.h"

void Vtb_aes_sbox___ctor_var_reset(Vtb_aes_sbox* vlSelf);

Vtb_aes_sbox::Vtb_aes_sbox(Vtb__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vtb_aes_sbox___ctor_var_reset(this);
}

void Vtb_aes_sbox___configure_coverage(Vtb_aes_sbox* vlSelf, bool first);

void Vtb_aes_sbox::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
    Vtb_aes_sbox___configure_coverage(this, first);
}

Vtb_aes_sbox::~Vtb_aes_sbox() {
}

// Coverage
void Vtb_aes_sbox::__vlCoverInsert(uint32_t* countp, bool enable, const char* filenamep, int lineno, int column,
    const char* hierp, const char* pagep, const char* commentp, const char* linescovp) {
    uint32_t* count32p = countp;
    static uint32_t fake_zero_count = 0;
    if (!enable) count32p = &fake_zero_count;
    *count32p = 0;
    VL_COVER_INSERT(vlSymsp->_vm_contextp__->coveragep(), VerilatedModule::name(), count32p,  "filename",filenamep,  "lineno",lineno,  "column",column,
        "hier",std::string{VerilatedModule::name()} + hierp,  "page",pagep,  "comment",commentp,  (linescovp[0] ? "linescov" : ""), linescovp);
}
