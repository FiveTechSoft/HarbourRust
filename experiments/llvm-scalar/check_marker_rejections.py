"""Same fail-closed preprocessor boundary under both backends/target profiles."""
import pathlib,subprocess
root=pathlib.Path(__file__).resolve().parents[2]
for case in ['t1117_pp_logical_unknown_neg.hb', 't1118_pp_logical_case_neg.hb', 't1119_pp_logical_malformed_neg.hb', 't1120_pp_logical_nonmatch_neg.hb'] + ['t1105_pp_restricted_exact_neg.hb', 't1106_pp_restricted_unknown_neg.hb', 't1107_pp_restricted_prefix_neg.hb', 't1108_pp_restricted_quote_neg.hb', 't1109_pp_restricted_empty_neg.hb', 't1110_pp_restricted_macro_neg.hb'] + ['t1091_pp_identifier_literal_neg.hb','t1092_pp_identifier_expr_neg.hb','t1093_pp_wildcard_follow_neg.hb','t1094_pp_marker_remove.hb','t1096_pp_marker_malformed_neg.hb','t1097_pp_identifier_optional.hb']:
 for target in ['linux','windows']:
  errors=[]
  for flag in [[],['--experimental-llvm']]:
   r=subprocess.run([str(root/'experiments/llvm-scalar/run/hbc'),str(root/'tests'/case),str(root/'experiments/llvm-scalar/run/marker-negative.tmp'),'--target='+target]+flag,capture_output=True,text=True,timeout=10)
   assert r.returncode==1,(case,target,r.stderr);errors.append(r.stderr)
  assert errors[0]==errors[1],(case,target,errors)
  print('PASS marker shared rejection',case,target)
