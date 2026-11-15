include!("../../src/hbc.rs");
#[cfg(test)] mod date_emission_gate {
    use super::*;
    #[test] fn each_entry_emits_date_port_helpers_without_ctod() {
        for target in [Target::Linux,Target::Windows] {
            for entry in ["stod","dtos","year","date_add","date_diff","date_days","date_from_days"] {
                // Date range-error paths reference existing stderr helpers.
                // Supply their expected context, not an isolated invalid runtime.
                let mut input=format!("    call hbc_{}\n",entry);
                input.push_str("\nhbc_write_bytes:\nret\n");
                for n in ["sep","i64","i64c","dyn","dyncell","num_f64","f64"] {
                    input.push_str(&format!("\nhbc_print_{}:\nret\n",n));
                }
                input.push_str("\nhbc_end_stub:\nret\n");
                let out=finalize_trace(input,target);
                for label in ["hbc_stod:","hbc_dtos:","hbc_year:","hbc_date_add:","hbc_date_diff:","hbc_date_days:","hbc_date_from_days:"] {
                    assert!(out.contains(label),"{} did not emit {}",entry,label);
                }
            }
        }
    }
    #[test] fn no_date_calls_leave_date_helpers_absent() {
        let out=finalize_trace("    nop\n".into(),Target::Linux);
        assert!(!out.contains("hbc_stod:"));
        assert!(!out.contains("hbc_dtos:"));
    }
}
