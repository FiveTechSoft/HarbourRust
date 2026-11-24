# Original upstream dates3

Own MIT incremental onf06a0a5df78c57631c9c462387b6becd20289ce0.
No workflows,push or publication. Upstream program is specification only.

Intact tests/dates3.prg now compiles and runs byte-exact against freshly
built Harbour in5Linux modes. No source edits or substitute Main. It
includes Date() output,so oracle and candidate run on the same local day;
this is execution evidence,not a timeless golden-output file. Strict
final balance0 includes exact stdout,rc0,empty stderr and measured marker.

Missing pieces: public _SET_DATEFORMAT macro4;hb_SToD recognized as Date
producer when narrowing first bare-local stores;direct date-consumer
parameter evidence collected before enclosing arithmetic (d-DoW(d)+2);
Date +/- offset pinning preserves that evidence;no-argument SToD/hb_SToD
normalizes to the empty-date constructor before existing checks/codegen.
Source-owned constructors are not rewritten. Conflicting date multiply
remains a named rejection. No arbitrary dateformat admission.

Gate19:original and own fixture each5exact runs,2balances0,6profile
rejections,1conflicting-parameter limit. Censo49/1041,only new admission
is tests/dates3.prg. Census counts compile admissions,not49exact programs.
Other rejection diagnostics may change with the new public selector.
Original dates.prg and dates2.prg remain open,not silently adapted.

ASort1..21,timestamp1..9,B1/B2,A1/A2,cycle59,nested51,runtime-mask12,
mask50,century22,epoch41,inlineDate17,Rust104 PASS. Linux1176exact plus
same inherited ctod failure,neg622/13same,PE1912PASS22known0FAIL. No new
non-Linux runtime support or speed claim.

    python tests/date-original3/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/original-dates3
