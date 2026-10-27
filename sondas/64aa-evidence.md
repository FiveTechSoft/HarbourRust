# 64aa parenthesized expression statements

hk426 uses complete std.ch: Harbour succeeds, HarbourRust still rejects
unsupported wildcard preprocessor markers in that header. hk427 uses only
the EXACT HB_SYMBOL_UNUSED macro from std.ch; it is a distinct successful
byte-exact probe, not proof that the full header works. hk428, hk430 and
hk431 are also successful byte-exact probes. hk429 is a documented FOR EACH
borrowed-variable restriction: accepted by Harbour, rejected by HarbourRust.

The first hk428 candidate exposed a float-channel compiler panic. Fixed by
using cg_f64_load for discarded float expressions; exact Harbour outputs
and Linux/Wine battery then pass. Unused non-Copy variables stay borrowed;
computed owned temporaries use existing free helpers. No new storage model.
