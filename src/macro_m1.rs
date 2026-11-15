// M1 admission boundary for precompiled macro literals. No runtime evaluator.
// The producer's literal concatenation is separate from the expanded text.
use super::{Expr, Tok, CmpOp, parse_expr_tokens, tokenize};

pub(super) fn limit(n: usize, detail: &str) -> String {
    format!("line {}: macro M1 capacity limit: {}; only closed, well-typed scalar literal expressions are precompiled; dynamic evaluation and deferred Harbour errors require the later evaluator (not a Harbour error)", n, detail)
}

// Parse only string literals, parentheses and +. No caller expression is
// evaluated, propagated, or resolved while obtaining macro text.
pub(super) fn literal_text(tokens: &[Tok], n: usize) -> Result<String, String> {
    fn part(ts: &[Tok], at: &mut usize, depth: usize) -> Option<String> {
        if depth > 64 { return None; }
        let s = match ts.get(*at)? {
            Tok::Str(s) => { *at += 1; s.clone() },
            Tok::LParen => {
                *at += 1;
                let s = sum(ts, at, depth + 1)?;
                if ts.get(*at) != Some(&Tok::RParen) { return None; }
                *at += 1;
                s
            },
            _ => return None,
        };
        Some(s)
    }
    fn sum(ts: &[Tok], at: &mut usize, depth: usize) -> Option<String> {
        let mut s = part(ts, at, depth)?;
        while ts.get(*at) == Some(&Tok::Plus) {
            *at += 1;
            s.push_str(&part(ts, at, depth)?);
        }
        Some(s)
    }
    let mut at = 0;
    let s = sum(tokens, &mut at, 0).filter(|_| at == tokens.len())
        .ok_or_else(|| limit(n, "macro text must be a string literal or literal-only concatenation"))?;
    Ok(s)
}

#[derive(Clone, Copy, PartialEq)]
enum Scalar { Int, Str, Bool, Nil }

// Refuse names before normal type inference can resolve a caller LOCAL.
// Refuse calls, lvalues and untyped/error-producing combinations, including
// unreachable ones. These are capability rejections, not Harbour errors.
fn closed(e: &Expr) -> Option<Scalar> {
    match e {
        Expr::Int(v) if v.parse::<i64>().is_ok() => Some(Scalar::Int),
        Expr::Float(_, _) | Expr::FloatV(_, _) => None, // numerical provenance needs a separate oracle gate
        Expr::Str(_) => Some(Scalar::Str),
        Expr::Log(_) => Some(Scalar::Bool),
        Expr::Nil => Some(Scalar::Nil),
        Expr::Bin('+', a, b) if closed(a) == Some(Scalar::Str) && closed(b) == Some(Scalar::Str) => Some(Scalar::Str),
        Expr::LNot(a) if closed(a) == Some(Scalar::Bool) => Some(Scalar::Bool),
        Expr::LAnd(a,b) | Expr::LOr(a,b) if closed(a) == Some(Scalar::Bool) && closed(b) == Some(Scalar::Bool) => Some(Scalar::Bool),
        Expr::Cmp(op,a,b) => {
            let k = closed(a)?;
            if Some(k) != closed(b) { return None; }
            if (k == Scalar::Int && !matches!(op,CmpOp::Contains)) || (k == Scalar::Bool && matches!(op,CmpOp::Eq|CmpOp::EqEq|CmpOp::Ne)) ||
                (k == Scalar::Str && matches!(op,CmpOp::EqEq|CmpOp::Contains)) { Some(Scalar::Bool) } else { None }
        },
        _ => None,
    }
}

pub(super) fn precompile(text: &str, n: usize) -> Result<Expr, String> {
    // No macrotext interpolation, comments, multi-line syntax or recursive
    // macro parsing. Reject rather than silently truncate at a comment.
    if text.len() > 65536 { return Err(limit(n,"expanded text exceeds the M1 byte budget (65536)")); }
    if text.chars().any(|c| c == '&' || c.is_control()) || text.contains("//") || text.contains("/*") || text.contains("*/") {
        return Err(limit(n, "nested macros, macrotext, controls and comments are not admitted"));
    }
    let toks = tokenize(text,n).map_err(|_| limit(n,"expanded text is outside the admitted literal grammar"))?;
    if toks.len() > 256 { return Err(limit(n,"expanded text exceeds the M1 token budget (256)")); }
    let mut depth = 0usize;
    for t in &toks {
        match t {
            Tok::LParen => { depth += 1; if depth > 64 { return Err(limit(n,"expanded text nesting exceeds 64")); } },
            Tok::RParen => { depth = depth.saturating_sub(1); },
            Tok::Int(_) | Tok::Str(_) | Tok::LogT | Tok::LogF | Tok::KwNil |
            Tok::Plus | Tok::Minus | Tok::Star | Tok::Slash | Tok::Pct |
            Tok::Eq | Tok::EqEq | Tok::Ne | Tok::Lt | Tok::Le | Tok::Gt | Tok::Ge |
            Tok::Dollar | Tok::LogNot | Tok::LogAnd | Tok::LogOr => {},
            _ => return Err(limit(n,"names, calls, floats, lvalues and other dynamic contexts are not admitted")),
        }
    }
    let e = parse_expr_tokens(toks,n).map_err(|_| limit(n,"expanded text requires unsupported grammar or deferred Harbour errors"))?;
    closed(&e).ok_or_else(|| limit(n,"expanded expression is not a proven closed, well-typed scalar (or may require a deferred Harbour error)"))?;
    Ok(e)
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test] fn producer_is_literal_only() {
        assert_eq!(literal_text(&[Tok::Str("1".into()),Tok::Plus,Tok::LParen,Tok::Str("+2".into()),Tok::RParen],1).unwrap(),"1+2");
        assert!(literal_text(&[Tok::Ident("caller".into())],1).is_err());
    }
    #[test] fn closed_only() {
        assert!(precompile("1+2*3",1).is_ok());
        assert!(precompile("'a'+'b'",1).is_ok());
        for s in ["hidden","F()","1$2","1/0","1+","'x'+1",".F. .AND. missing","1 // ignored","&('1')","{1}","1,2"] {
            assert!(precompile(s,1).unwrap_err().contains("macro M1 capacity limit"),"{}",s);
        }
    }
}
