# Checked standard runtime date masks

Own MIT incremental on3e3a08570d8cb0bb45e4b10c9940147f2955e53b.
No workflows,push or publication. Fresh Harbour behavior is specification.

A plain string variable may supply a standard mask to Set(4,value).
Runtime validation checks length before bytes and matches only14standard
layouts case-insensitively. The mask is copied to bounded global state;
input is borrowed,old mask is an independent owned result. No caller
string is consumed. Getter is called only after validation succeeds.

Other runtime masks stop with an explicit Limit diagnostic and exit1,
not a Harbour-compatible error. Empty,unusual and1000byte masks exercise
the pre-copy check. Literal restrictions and other type limits remain.
Computed effectful expressions are not admitted. DATEFORMAT macro and
arbitrary formats are still outside this increment,so no upstream
example is claimed closed. Invalid-mask recovery is not implemented.

Gate12:5fresh Harbour exact modes,1strict balance0,3profile rejections,
3runtime limits. The previously rejected standard runtime fixture moves
to the dateformat exact gate,now50. Its promotion is explicit. A151loop
changes both owned prior-mask outputs and borrowed source variables.

ASort1..21,timestamp1..9,B1/B2,A1/A2,cycle59,nested51,mask50,century22,
epoch41,inlineDate17,Rust104 PASS. Linux1176exact+1inherited ctod,
neg622/13same,PE1912PASS22known0FAIL,census48/1041unchanged admissions.
No speed or new non-Linux runtime claim. Renderer assembly regenerated
from our C code with the checked external whitelist.
