"""Same fail-closed preprocessor boundary under both backends/target profiles."""
import pathlib,subprocess
root=pathlib.Path(__file__).resolve().parents[2]
for case in ['t1202_pp_list_escape_neg.hb'] + ['t1195_pp_normal_stringify_quotes_neg.hb','t1196_pp_normal_stringify_list_neg.hb'] + ['t1189_pp_fixed_translate_recursive_neg.hb'] + ['t1177_pp_stringify_mixed_quotes_neg.hb', 't1178_pp_stringify_escape_neg.hb', 't1179_pp_stringify_list_neg.hb', 't1180_pp_stringify_other_form_neg.hb'] + ['t1167_pp_atoms_spaced_assign_neg.hb', 't1168_pp_atoms_spaced_logical_neg.hb'] + ['t1156_pp_call_unknown_neg.hb', 't1157_pp_call_case_neg.hb', 't1158_pp_call_recursive_neg.hb', 't1159_pp_call_removed_neg.hb'] + ['t1139_pp_generated_unknown_neg.hb', 't1140_pp_generated_case_neg.hb', 't1141_pp_generated_exact_neg.hb', 't1142_pp_generated_recursive_neg.hb', 't1143_pp_generated_unsupported_neg.hb', 't1144_pp_generated_unescaped_neg.hb'] + ['t1127_pp_null_unknown_neg.hb', 't1128_pp_null_case_neg.hb', 't1129_pp_null_malformed_neg.hb', 't1130_pp_null_nonmatch_neg.hb'] + ['t1117_pp_logical_unknown_neg.hb', 't1118_pp_logical_case_neg.hb', 't1119_pp_logical_malformed_neg.hb', 't1120_pp_logical_nonmatch_neg.hb'] + ['t1105_pp_restricted_exact_neg.hb', 't1106_pp_restricted_unknown_neg.hb', 't1107_pp_restricted_prefix_neg.hb', 't1108_pp_restricted_quote_neg.hb', 't1109_pp_restricted_empty_neg.hb', 't1110_pp_restricted_macro_neg.hb'] + ['t1091_pp_identifier_literal_neg.hb','t1092_pp_identifier_expr_neg.hb','t1093_pp_wildcard_follow_neg.hb','t1094_pp_marker_remove.hb','t1096_pp_marker_malformed_neg.hb','t1097_pp_identifier_optional.hb']:
 for target in ['linux','windows']:
  errors=[]
  for flag in [[],['--experimental-llvm']]:
   r=subprocess.run([str(root/'experiments/llvm-scalar/run/hbc'),str(root/'tests'/case),str(root/'experiments/llvm-scalar/run/marker-negative.tmp'),'--target='+target]+flag,capture_output=True,text=True,timeout=10)
   assert r.returncode==1,(case,target,r.stderr);errors.append(r.stderr)
  assert errors[0]==errors[1],(case,target,errors)
  print('PASS marker shared rejection',case,target)
