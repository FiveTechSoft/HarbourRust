# PE fixed-ImageBase declaration

BASE6f3927face747afc0e55ed60f1a9c52bc6e3fc8b. Fix-forward only.

The PE writer emits no base relocation directory. B2's generated macro helper
contains absolute addresses, including function pointers. The writer nonetheless
set DllCharacteristics0x0160: HIGH_ENTROPY_VA0x20, DYNAMIC_BASE0x40, NX_COMPAT0x100.
A loader that rebased the image left those addresses at nominal0x140000000.
Indirect call then faulted on EXECUTE at an unmapped0x140... address.

The exact same failing PE contexts image from the second executor
SHA256fab4ce0f08023fbebb3f4f8eb7854d3834d907fc416c04dc9dd3a847e380a918
passes rc0/empty stderr in local Wine11.0, where it loads at nominal ImageBase.
The second executor's Wine11.22 rebases the image to0x7ff6..., explaining why
local captures missed the failure. Changing ONLY the ImageBase header of a
passing local PE to0x180000000 reproduces rc5 and execute access at0x1400094a0;
module loads0x180000000. This mutation is a diagnostic experiment, not the fix.

Fix: DllCharacteristics becomes0x0100. Clear only DYNAMIC_BASE and
HIGH_ENTROPY_VA. Keep NX_COMPAT. This truthfully declares a fixed-base image;
adding actual .reloc support and retaining ASLR is a separate future unit.
No runtime/compiler/generator/assembly changes. No QOut edits. M2 remains paused.

Evidence covers direct autonomous output, not external-GAS substitution.
Four original macro cases pass local Wine11.0 with the final compiler. Parent
reports independent Wine11.22 gate8/8: same four, three terminal diagnostics,
hello; compiler hash6d2a84ae verified, DllCharacteristics0x0100 checked. Those
second-executor captures are retained by parent; they are not local execution.
Complete autonomous1741 ELF+1741 PE BASE-vs-fix run is recorded separately in
summary.json. Raw stdout/stderr/exit comparisons are primary; compile-blocked
cases are explicitly not execution PASS. No native-Windows claim.

Local Wine11.0 executable SHA256
0fa5abe77c0d27991801983bd878fedd360b61fc26cca4777fd705a8a54ae6b9;
final compiler SHA2566d2a84ae892f8c74972c4f43cbf83518f82c769b730d67b0105ac4da74812408.
Prior local PE captures alone are no longer a publication gate. A second
executor reruns probes from the final compiler before PE-sensitive publication.

Limits: fixed-ImageBase output has no ASLR and cannot be loaded at another base
without implementing relocations. NX stays enabled. If ImageBase is unavailable,
loading may fail; no silent rebase support is claimed. Prior QOut whole-fixture
failures remain separate, unchanged, and are not greened by this fix.
