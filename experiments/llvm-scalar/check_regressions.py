"""Run existing repository regressions unchanged through both backends/targets."""
import os
import sys
import pathlib
import subprocess

root = pathlib.Path(__file__).resolve().parents[2]
os.chdir(root)
work = pathlib.Path('experiments/llvm-scalar/run')
base = pathlib.Path('experiments/llvm-scalar')
hbc = str(work / 'hbc')
env = os.environ
selected = ['t1346_pp_root_expression.prg', 't1347_pp_root_reorder.prg', 't1348_pp_root_iterations.prg', 't1349_pp_root_index.prg', 't1350_pp_root_macro_normal.prg', 't1351_pp_root_macro_expr.prg', 't1352_pp_root_comparisons.prg', 't1353_pp_root_overlap.prg'] + ['t1342_pp_independent_ident.prg', 't1343_pp_independent_plain.prg', 't1344_pp_independent_temporal.prg', 't1345_pp_independent_call.prg'] + ['t1339_pp_readmit_alias.prg', 't1340_pp_readmit_call.prg', 't1341_pp_readmit_fixed.prg'] + ['t1333_pp_concat_bare.prg', 't1334_pp_concat_call.prg', 't1335_pp_concat_math.prg', 't1336_pp_concat_nested.prg'] + ['t1326_pp_inline_ident_one.prg', 't1328_pp_inline_ident_join.prg', 't1329_pp_inline_ident_call.prg', 't1330_pp_inline_ident_suffix.prg', 't1331_pp_inline_ident_quote.prg'] + ['t1319_pp_call_source.prg', 't1320_pp_call_head.prg', 't1321_pp_call_rescan.prg', 't1322_pp_call_factory.prg', 't1323_pp_call_stringify.prg', 't1324_pp_call_temporal.prg'] + ['t1315_pp_factory_separator.prg', 't1316_pp_factory_separator.prg', 't1317_pp_factory_separator.prg', 't1318_pp_factory_separator.prg'] + ['t1309_pp_continuation_separator.prg', 't1310_pp_continuation_separator.prg', 't1311_pp_continuation_separator.prg', 't1312_pp_continuation_separator.prg', 't1313_pp_continuation_separator.prg', 't1314_pp_continuation_separator.prg'] + ['t1301_pp_alias_source.prg', 't1302_pp_alias_rescan.prg', 't1303_pp_alias_mode.prg', 't1304_pp_alias_temporal.prg', 't1305_pp_alias_generated_define.prg', 't1306_pp_alias_chain.prg'] + ['t1293_pp_var_family_comma.prg', 't1294_pp_var_family_reorder.prg', 't1295_pp_var_family_in.prg', 't1296_pp_var_family_is.prg', 't1297_pp_var_family_isin.prg', 't1298_pp_var_family_isto.prg'] + ['t1282_pp_queue_siblings.prg', 't1283_pp_queue_nested.prg', 't1284_pp_queue_quoted.prg', 't1285_pp_queue_factory.prg', 't1286_pp_queue_define.prg', 't1287_pp_queue_define_order.prg', 't1288_pp_queue_function_define.prg', 't1289_pp_queue_undef.prg'] + ['t1273_pp_var_flags_absent.prg', 't1274_pp_var_flags_all.prg', 't1275_pp_var_flags_aliases.prg', 't1276_pp_var_flags_reorder.prg', 't1278_pp_var_flags_operand.prg', 't1279_pp_var_flags_capture.prg'] + ['t1265_pp_plain_type_name.prg', 't1266_pp_plain_type_expression.prg', 't1267_pp_plain_type_call.prg', 't1268_pp_plain_type_reorder.prg', 't1269_pp_plain_type_repeats.prg', 't1270_pp_plain_type_operand.prg'] + ['t1253_pp_reduced_var_root.prg', 't1254_pp_reduced_var_comma.prg', 't1255_pp_reduced_var_type.prg', 't1256_pp_reduced_var_init.prg', 't1257_pp_reduced_var_reorder.prg', 't1258_pp_reduced_var_duplicates.prg', 't1259_pp_reduced_var_smart.prg', 't1260_pp_reduced_var_operand.prg'] + ['t1247_pp_iter_identifier_smart.prg','t1248_pp_iter_identifier_dumb.prg','t1249_pp_iter_identifier_normal.prg','t1250_pp_iter_identifier_plain.prg','t1251_pp_iter_identifier_logical.prg','t1252_pp_iter_identifier_empty.prg'] + ['t1244_pp_smart_escape_list.prg','t1245_pp_smart_escape_quote.prg','t1246_pp_smart_escape_marker.prg'] + ['t1233_pp_smart_bare.prg', 't1234_pp_smart_parentheses.prg', 't1235_pp_smart_quotes.prg', 't1236_pp_smart_list.prg', 't1237_pp_smart_optional.prg', 't1238_pp_smart_identifier.prg'] + ['t1228_pp_identifier_stringify.prg', 't1229_pp_restricted_stringify.prg', 't1230_pp_wildcard_stringify.prg', 't1231_pp_wildcard_normal.prg', 't1232_pp_optional_marker_stringify.prg'] + ['t1227_pp_template_continuation.prg'] + ['t1224_pp_list_index.prg','t1225_pp_list_index_whole.prg','t1226_pp_list_index_literal.prg'] + ['t1220_escape_protection.prg','t1221_escape_stringify.prg','t1222_escape_call_macro.prg'] + ['t1210_bracket_literals.prg','t1211_bracket_index_context.prg','t1212_bracket_macro.prg','t1213_bracket_semicolon.prg','t1215_bracket_translate.prg'] + ['t1203_pp_macro_nested_array.prg','t1204_pp_macro_nested_pair.prg','t1205_pp_macro_simultaneous.prg','t1206_pp_macro_strings.prg','t1207_pp_macro_nested_calls.prg'] + ['t1197_pp_list_stringify.prg','t1198_pp_list_normal.prg','t1199_pp_list_quotes.prg','t1200_pp_list_absent.prg','t1201_pp_list_empty.prg'] + ['t1190_pp_normal_stringify.prg','t1191_pp_normal_stringify_absent.prg','t1192_pp_normal_stringify_mix.prg','t1193_pp_normal_stringify_marker.prg','t1194_pp_normal_stringify_call.prg'] + ['t1182_pp_fixed_translate_inline.prg','t1183_pp_fixed_translate_order.prg','t1184_pp_fixed_translate_specific.prg','t1185_pp_fixed_translate_remove.prg','t1186_pp_fixed_translate_temporal.prg','t1187_pp_fixed_translate_command.prg','t1188_pp_fixed_xtranslate.prg'] + ['t1181_pp_stringify_quoted_result.prg'] + ['t1169_pp_stringify_spaces.prg', 't1170_pp_stringify_quotes.prg', 't1171_pp_stringify_absent.prg', 't1172_pp_stringify_optional.prg', 't1173_pp_stringify_repeat_text.prg', 't1174_pp_stringify_call.prg', 't1175_pp_stringify_dotted.prg', 't1176_pp_stringify_literal_marker.prg'] + ['t1160_pp_atoms_logical.prg', 't1161_pp_atoms_compare.prg', 't1162_pp_atoms_assign.prg', 't1163_pp_atoms_increment.prg', 't1165_pp_atoms_call.prg', 't1166_pp_atoms_quoted.prg'] + ['t1148_pp_call_optional.prg', 't1149_pp_call_overload.prg', 't1150_pp_call_order.prg', 't1151_pp_call_case.prg', 't1152_pp_call_remove.prg', 't1153_pp_call_quoted.prg', 't1154_pp_call_chain.prg', 't1155_pp_call_nested.prg'] + ['t1145_pp_nonmatch_procedure.prg','t1146_pp_nonmatch_assignment.prg','t1147_pp_nonmatch_call.prg'] + ['t1131_pp_generated_factory.prg', 't1132_pp_generated_collision.prg', 't1133_pp_generated_optional.prg', 't1134_pp_generated_ordinary.prg', 't1135_pp_generated_ordered.prg', 't1136_pp_generated_unused.prg', 't1137_pp_generated_multi.prg', 't1138_pp_generated_local_scope.prg'] + ['t1121_pp_null_erase.prg', 't1122_pp_null_group.prg', 't1123_pp_null_payload.prg', 't1124_pp_null_mixed.prg', 't1125_pp_null_translate.prg', 't1126_pp_null_name.prg'] + ['t1111_pp_logical_presence.prg', 't1112_pp_logical_false_payload.prg', 't1113_pp_logical_group.prg', 't1114_pp_logical_mixed.prg', 't1115_pp_logical_translate.prg', 't1116_pp_logical_required.prg'] + ['t1099_pp_restricted_choice.prg', 't1100_pp_restricted_case.prg', 't1101_pp_restricted_phrase.prg', 't1102_pp_restricted_abbrev.prg', 't1103_pp_restricted_optional.prg', 't1104_pp_restricted_translate.prg'] + ['t1087_pp_identifier_marker.prg','t1088_pp_identifier_pair.prg','t1089_pp_wildcard_marker.prg','t1090_pp_wildcard_optional.prg','t1095_pp_identifier_translate.prg','t1098_pp_identifier_result_optional.prg','t28_exit_loop.prg', 't42_for_exit_loop.prg', 't48_nested_exit.prg',
            't49_nested_loop.prg', 't129_arr_loop.prg',
            't980_inline_if_qout.prg','t982_original_ifinline.prg','t792_barelocal_for.prg','t601_shortcircuit.prg','t602_log_fn.prg','t606_dotted_forms.prg','t722_qq_logical.prg', 't907_original_while.prg', 't997_original_recursiv.prg']
manifest = {}
for line in pathlib.Path('tests/manifest.txt').read_text().splitlines():
    if line.startswith(('pos ','posx ')):
        parts = line.split(' ', 2)
        _, path = parts[:2]
        expected = parts[2] if len(parts) == 3 else ''
        manifest[path] = (parts[0],expected)

def run(cmd):
    return subprocess.run(list(map(str, cmd)), check=True, capture_output=True)

# Optional answer-only compatibility audit: run each existing successful-output
# manifest case the LLVM emitter admits. Rejections are not language support.
scan_errors = '--scan-errors-linux' in sys.argv
scan = '--scan-supported-linux' in sys.argv or scan_errors
if scan:
    selected = []
    for source,(kind,_) in manifest.items():
        if kind != ('posx' if scan_errors else 'pos'):
            continue
        if not source.startswith('tests/'):
            continue  # generated inputs are not part of the source audit
        trial = subprocess.run([hbc,source,str(work/'scan.ll'),'--experimental-llvm','-I','tests'],capture_output=True)
        if trial.returncode == 0:
            selected.append(source.removeprefix('tests/'))
    print('AUDIT admitted', 'failure-mode sources' if scan_errors else 'successful-output sources',len(selected),flush=True)
for case in selected:
    source = 'tests/' + case
    kind,escaped = manifest[source]
    want_rc = 0
    if kind == 'posx':
        rc,escaped = escaped.split(' ',1)
        want_rc = int(rc)
    expected = subprocess.run(['printf','%b',escaped], capture_output=True, check=True).stdout
    for target in ['linux'] + (['windows'] if not scan and env.get('M') and env.get('WINE') else []):
        current_bytes = None
        for backend in ['current', 'llvm']:
            p = str(work / ('reg-' + pathlib.Path(case).stem + '-' + target + '-' + backend))
            asm = p + '.s'
            args = [hbc, source, p + '.ll' if backend == 'llvm' else asm, '--target=' + target, '-I', 'tests']
            if backend == 'llvm':
                args += ['--experimental-llvm']
            run(args)
            objects = [p + '.o']
            if backend == 'llvm':
                run(['python3', base / 'llvm_aot.py', p + '.ll', p + '.o'] + (['windows'] if target == 'windows' else []))
                asm = p + '.ll.runtime.s'
                run(['python3', base / 'link_runtime.py', asm] + (['windows'] if target == 'windows' else []))
                objects += [p + '-rt.o']
            assembler = 'as' if target == 'linux' else env['M'] + '/x86_64-w64-mingw32-as'
            linker = 'ld' if target == 'linux' else env['M'] + '/x86_64-w64-mingw32-ld'
            run([assembler, '-o', objects[-1], asm])
            exe = p + ('.exe' if target == 'windows' else '')
            run([linker, '-o', exe] + objects + (['-e', '_start', '--subsystem', 'console', '-L' + env['MLIB'], '-lkernel32'] if target == 'windows' else []))
            result = subprocess.run(([env['WINE'], exe] if target == 'windows' else [exe]), capture_output=True, timeout=20)
            assert result.returncode == want_rc and result.stderr == b'', (case, target, backend, result)
            if kind == 'posx':
                # Existing shell runner strips trailing newlines; retain its
                # expectation semantics, then require exact backend parity.
                assert result.stdout.rstrip(b'\n') == expected.rstrip(b'\n'), (case,target,backend,result.stdout,expected)
                if current_bytes is None:
                    current_bytes = result.stdout
                else:
                    assert result.stdout == current_bytes, (case,target,result.stdout,current_bytes)
            else:
                assert result.stdout == expected, (case, target, backend, result.stdout, expected)
        print('PASS existing regression', case, target)
