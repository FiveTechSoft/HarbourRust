# Original datetime.prg

Own MIT incremental on6e005cd3fdf8970d3e5eb433ba5ab867b82017f5.
No workflows, push or publication. Original upstream tests/datetime.prg
is executed intact with its include path, as a specification only.

hb_DateTime admits zero arguments for current local time, or1..7 literal
i32/NIL components. Missing/NIL components are zero. Valid date and time
halves validate independently: an invalid date leaves valid time intact;
any invalid time component clears the whole time. Leap dates use the
existing measured date validation. Floats, runtime components and extra
arguments are named limits, although Harbour supports wider inputs.

Current time uses one CLOCK_REALTIME sample, the existing Linux timezone
lookup and existing civil-day conversion. It does not combine separately
sampled Date and Seconds. Timestamp remains non-owning Dyn tag17 with
JDN high32/milliseconds low32. Direct producer arguments to Year/Month/Day,
DoW/CDoW/CMonth/DToC lower through existing hb_TToD. Generic Dyn variables
are not newly accepted by those consumers; source-owned conversion names
exclude the rewrite. Dependencies enter before helper closure.

Gate41: original plus own constructor fixture each5exact Harbour runs,
2strict final balance0,6profile rejections,3component limits,20current-clock
checks. Current-clock checks require parsed complete local timestamps
inside host-clock brackets in UTC,Europe/Madrid,America/New_York and
Pacific/Kiritimati. They are live-clock tests, not exact timestamp strings
from independently sampled Harbour. Original prints only the current
calendar date, so its exact comparison is same-local-day evidence.

Census54/1041 is compile admissions, not54differential programs. Only new
admission and diagnostic change is datetime.prg. ASort1..21,timestamp1..9,
B1/B2,A1/A2,cycle59,nested51 PASS. Stringcopy19,omitted20,dates1=22,
dates2=19,dates3=19,ctodgolden6,runtime12,mask58,century22,epoch41,
inlineDate17,Rust104 PASS. Linux1177/1177exact. Historical negatives622
retain same14, including the earlier intentional Linux longstr2 admission.
PE1912PASS22known0FAIL is emission only, not execution. No performance
or Windows/Mac execution claim.

Julio Ponce's MIT programs/outputs remain ASort regression specifications
with attribution retained. No supplied implementation or cambio.diff.

    python tests/datetime-original/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/datetime
