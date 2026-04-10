# Verilated -*- Makefile -*-
# DESCRIPTION: Verilator output: Make include file with class lists
#
# This file lists generated Verilated files, for including in higher level makefiles.
# See Vtb.mk for the caller.

### Switches...
# C11 constructs required?  0/1 (always on now)
VM_C11 = 1
# Timing enabled?  0/1
VM_TIMING = 1
# Coverage output mode?  0/1 (from --coverage)
VM_COVERAGE = 1
# Parallel builds?  0/1 (from --output-split)
VM_PARALLEL_BUILDS = 1
# Tracing output mode?  0/1 (from --trace/--trace-fst)
VM_TRACE = 1
# Tracing output mode in VCD format?  0/1 (from --trace)
VM_TRACE_VCD = 1
# Tracing output mode in FST format?  0/1 (from --trace-fst)
VM_TRACE_FST = 0

### Object file lists...
# Generated module classes, fast-path, compile with highest optimization
VM_CLASSES_FAST += \
	Vtb \
	Vtb___024root__DepSet_hfe20aad3__0 \
	Vtb___024root__DepSet_ha183790c__0 \
	Vtb_aes_inv_sbox__DepSet_hed62ef43__0 \
	Vtb_aes_inv_sbox__DepSet_hed62ef43__1 \
	Vtb_aes_inv_sbox__DepSet_hed62ef43__2 \
	Vtb_aes_inv_sbox__DepSet_hed62ef43__3 \
	Vtb_aes_inv_sbox__DepSet_hed62ef43__4 \
	Vtb_aes_inv_sbox__DepSet_hed62ef43__5 \
	Vtb_aes_inv_sbox__DepSet_hed62ef43__6 \
	Vtb_aes_sbox__DepSet_h37e03f20__0 \
	Vtb_aes_sbox__DepSet_h37e03f20__1 \
	Vtb__main \

# Generated module classes, non-fast-path, compile with low/medium optimization
VM_CLASSES_SLOW += \
	Vtb___024root__Slow \
	Vtb___024root__DepSet_hfe20aad3__0__Slow \
	Vtb___024root__DepSet_ha183790c__0__Slow \
	Vtb_aes_inv_sbox__Slow \
	Vtb_aes_inv_sbox__DepSet_hed62ef43__0__Slow \
	Vtb_aes_inv_sbox__DepSet_hb041bc7c__0__Slow \
	Vtb_aes_sbox__Slow \
	Vtb_aes_sbox__DepSet_h37e03f20__0__Slow \
	Vtb_aes_sbox__DepSet_hdac3ec1d__0__Slow \

# Generated support classes, fast-path, compile with highest optimization
VM_SUPPORT_FAST += \
	Vtb__Trace__0 \

# Generated support classes, non-fast-path, compile with low/medium optimization
VM_SUPPORT_SLOW += \
	Vtb__Syms \
	Vtb__Trace__0__Slow \
	Vtb__TraceDecls__0__Slow \

# Global classes, need linked once per executable, fast-path, compile with highest optimization
VM_GLOBAL_FAST += \
	verilated \
	verilated_cov \
	verilated_vcd_c \
	verilated_timing \
	verilated_threads \

# Global classes, need linked once per executable, non-fast-path, compile with low/medium optimization
VM_GLOBAL_SLOW += \


# Verilated -*- Makefile -*-
