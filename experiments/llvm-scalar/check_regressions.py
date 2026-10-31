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
selected = ['t1265_pp_plain_type_name.hb', 't1266_pp_plain_type_expression.hb', 't1267_pp_plain_type_call.hb', 't1268_pp_plain_type_reorder.hb', 't1269_pp_plain_type_repeats.hb', 't1270_pp_plain_type_operand.hb'] + ['t1253_pp_reduced_var_root.hb', 't1254_pp_reduced_var_comma.hb', 't1255_pp_reduced_var_type.hb', 't1256_pp_reduced_var_init.hb', 't1257_pp_reduced_var_reorder.hb', 't1258_pp_reduced_var_duplicates.hb', 't1259_pp_reduced_var_smart.hb', 't1260_pp_reduced_var_operand.hb'] + ['t1247_pp_iter_identifier_smart.hb','t1248_pp_iter_identifier_dumb.hb','t1249_pp_iter_identifier_normal.hb','t1250_pp_iter_identifier_plain.hb','t1251_pp_iter_identifier_logical.hb','t1252_pp_iter_identifier_empty.hb'] + ['t1244_pp_smart_escape_list.hb','t1245_pp_smart_escape_quote.hb','t1246_pp_smart_escape_marker.hb'] + ['t1233_pp_smart_bare.hb', 't1234_pp_smart_parentheses.hb', 't1235_pp_smart_quotes.hb', 't1236_pp_smart_list.hb', 't1237_pp_smart_optional.hb', 't1238_pp_smart_identifier.hb'] + ['t1228_pp_identifier_stringify.hb', 't1229_pp_restricted_stringify.hb', 't1230_pp_wildcard_stringify.hb', 't1231_pp_wildcard_normal.hb', 't1232_pp_optional_marker_stringify.hb'] + ['t1227_pp_template_continuation.hb'] + ['t1224_pp_list_index.hb','t1225_pp_list_index_whole.hb','t1226_pp_list_index_literal.hb'] + ['t1220_escape_protection.hb','t1221_escape_stringify.hb','t1222_escape_call_macro.hb'] + ['t1210_bracket_literals.hb','t1211_bracket_index_context.hb','t1212_bracket_macro.hb','t1213_bracket_semicolon.hb','t1215_bracket_translate.hb'] + ['t1203_pp_macro_nested_array.hb','t1204_pp_macro_nested_pair.hb','t1205_pp_macro_simultaneous.hb','t1206_pp_macro_strings.hb','t1207_pp_macro_nested_calls.hb'] + ['t1197_pp_list_stringify.hb','t1198_pp_list_normal.hb','t1199_pp_list_quotes.hb','t1200_pp_list_absent.hb','t1201_pp_list_empty.hb'] + ['t1190_pp_normal_stringify.hb','t1191_pp_normal_stringify_absent.hb','t1192_pp_normal_stringify_mix.hb','t1193_pp_normal_stringify_marker.hb','t1194_pp_normal_stringify_call.hb'] + ['t1182_pp_fixed_translate_inline.hb','t1183_pp_fixed_translate_order.hb','t1184_pp_fixed_translate_specific.hb','t1185_pp_fixed_translate_remove.hb','t1186_pp_fixed_translate_temporal.hb','t1187_pp_fixed_translate_command.hb','t1188_pp_fixed_xtranslate.hb'] + ['t1181_pp_stringify_quoted_result.hb'] + ['t1169_pp_stringify_spaces.hb', 't1170_pp_stringify_quotes.hb', 't1171_pp_stringify_absent.hb', 't1172_pp_stringify_optional.hb', 't1173_pp_stringify_repeat_text.hb', 't1174_pp_stringify_call.hb', 't1175_pp_stringify_dotted.hb', 't1176_pp_stringify_literal_marker.hb'] + ['t1160_pp_atoms_logical.hb', 't1161_pp_atoms_compare.hb', 't1162_pp_atoms_assign.hb', 't1163_pp_atoms_increment.hb', 't1165_pp_atoms_call.hb', 't1166_pp_atoms_quoted.hb'] + ['t1148_pp_call_optional.hb', 't1149_pp_call_overload.hb', 't1150_pp_call_order.hb', 't1151_pp_call_case.hb', 't1152_pp_call_remove.hb', 't1153_pp_call_quoted.hb', 't1154_pp_call_chain.hb', 't1155_pp_call_nested.hb'] + ['t1145_pp_nonmatch_procedure.hb','t1146_pp_nonmatch_assignment.hb','t1147_pp_nonmatch_call.hb'] + ['t1131_pp_generated_factory.hb', 't1132_pp_generated_collision.hb', 't1133_pp_generated_optional.hb', 't1134_pp_generated_ordinary.hb', 't1135_pp_generated_ordered.hb', 't1136_pp_generated_unused.hb', 't1137_pp_generated_multi.hb', 't1138_pp_generated_local_scope.hb'] + ['t1121_pp_null_erase.hb', 't1122_pp_null_group.hb', 't1123_pp_null_payload.hb', 't1124_pp_null_mixed.hb', 't1125_pp_null_translate.hb', 't1126_pp_null_name.hb'] + ['t1111_pp_logical_presence.hb', 't1112_pp_logical_false_payload.hb', 't1113_pp_logical_group.hb', 't1114_pp_logical_mixed.hb', 't1115_pp_logical_translate.hb', 't1116_pp_logical_required.hb'] + ['t1099_pp_restricted_choice.hb', 't1100_pp_restricted_case.hb', 't1101_pp_restricted_phrase.hb', 't1102_pp_restricted_abbrev.hb', 't1103_pp_restricted_optional.hb', 't1104_pp_restricted_translate.hb'] + ['t1087_pp_identifier_marker.hb','t1088_pp_identifier_pair.hb','t1089_pp_wildcard_marker.hb','t1090_pp_wildcard_optional.hb','t1095_pp_identifier_translate.hb','t1098_pp_identifier_result_optional.hb','t28_exit_loop.hb', 't42_for_exit_loop.hb', 't48_nested_exit.hb',
            't49_nested_loop.hb', 't129_arr_loop.hb',
            't980_inline_if_qout.hb','t982_original_ifinline.hb','t792_barelocal_for.hb','t601_shortcircuit.hb','t602_log_fn.hb','t606_dotted_forms.hb','t722_qq_logical.hb', 't907_original_while.hb', 't997_original_recursiv.hb']
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
