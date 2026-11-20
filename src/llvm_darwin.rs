// Own MIT runtime for the existing bounded LLVM scalar ABI on Darwin ARM64 and Intel.
// No native-backend translation and no C/Harbour runtime dependencies.
pub fn arm64() -> String { include_str!("llvm_darwin_arm64.s").into() }
pub fn intel() -> String { include_str!("llvm_darwin_intel.s").into() }

#[cfg(test)] mod tests {
    #[test] fn complete_intel_scalar_abi() {
        let s=super::intel();
        for n in ["nl","sep","str","pstrt","pflush","pdrop","psep","int","computed","inc_error","bound_error"] {
            assert!(s.contains(&format!(".globl _rt_{}\n_rt_{}:",n,n)),"{}",n);
        }
        assert!(s.contains(".globl _hbc_trace_top"));
        assert!(s.contains("call _ll_main"));
    }
    #[test] fn complete_scalar_abi_and_no_reserved_platform_register() {
        let s=super::arm64();
        for n in ["nl","sep","str","pstrt","pflush","pdrop","psep","int","computed","inc_error","bound_error"] {
            assert!(s.contains(&format!(".globl _rt_{}\n_rt_{}:",n,n)),"{}",n);
        }
        assert!(s.contains(".globl _hbc_trace_top"));
        assert!(s.contains("bl _ll_main"));
        for l in s.lines().filter(|l|!l.trim_start().starts_with("//")) {
            assert!(!l.split(|c:char|!c.is_ascii_alphanumeric()).any(|v|v=="x18"||v=="w18"),"{}",l);
        }
    }
}
