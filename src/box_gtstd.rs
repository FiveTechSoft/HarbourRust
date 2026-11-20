// Original MIT: partial evaluation of isolated, ordered literal GTSTD boxes.
use super::{Expr,Func,Stmt,is_builtin};
thread_local! {static ROW:std::cell::Cell<usize>=const{std::cell::Cell::new(0)};}
pub fn reset(){ROW.with(|r|r.set(0));}
fn bytes(e:&Expr)->Result<Vec<u8>,String>{
    match e {
        Expr::Str(s)=>Ok(s.as_bytes().to_vec()),
        Expr::Bin('+',a,b)=>{let mut v=bytes(a)?;v.extend(bytes(b)?);Ok(v)},
        Expr::Call(f,a) if is_builtin(f,"chr")&&a.len()==1=>match &a[0]{Expr::Int(n)=>n.parse::<u8>().map(|v|vec![v]).map_err(|_|"DispBox Chr must be a literal byte".into()),_=>Err("DispBox Chr must be a literal byte".into())},
        Expr::Call(f,a) if is_builtin(f,"hb_utf8tostrbox")&&a.len()==1=>{
            let raw=bytes(&a[0])?;let s=std::str::from_utf8(&raw).map_err(|_|"DispBox UTF8 box text is invalid")?;
            s.chars().map(|c|match c {
                '┌'=>Ok(218),'─'=>Ok(196),'┐'=>Ok(191),'│'=>Ok(179),'┘'=>Ok(217),'└'=>Ok(192),
                '╔'=>Ok(201),'═'=>Ok(205),'╗'=>Ok(187),'║'=>Ok(186),'╝'=>Ok(188),'╚'=>Ok(200),
                '╓'=>Ok(214),'╖'=>Ok(183),'╜'=>Ok(189),'╙'=>Ok(211),
                '╒'=>Ok(213),'╕'=>Ok(184),'╛'=>Ok(190),'╘'=>Ok(212),
                c if c.is_ascii()=>Ok(c as u8),_=>Err("DispBox UTF8 box glyph outside measured CP437 set".into())
            }).collect()
        },
        _=>Err("DispBox border/color must be literal, concatenation, Chr or measured UTF8 box conversion".into())
    }
}
pub struct Shape {pub top:usize,pub left:usize,pub bottom:usize,pub right:usize,pub border:Vec<u8>}
pub fn shape(args:&[Expr])->Result<Shape,String>{
    if !(4..=6).contains(&args.len()){return Err("DispBox needs four literal coordinates and optional literal border/color".into());}
    let mut c=Vec::new();for a in &args[..4]{if let Expr::Int(v)=a {c.push(v.parse::<usize>().map_err(|_|"DispBox coordinates must be nonnegative integer literals")?);}else{return Err("DispBox coordinates must be nonnegative integer literals".into());}}
    if c[0]>=c[2]||c[1]>=c[3]||c[2]>23||c[3]>78{return Err("DispBox requires nondegenerate coordinates inside measured rows 0..23 and columns 0..78".into());}
    let border=match args.get(4){None|Some(Expr::Int(_))=>{
        match args.get(4){None=>vec![218,196,191,179,217,196,192,179],Some(Expr::Int(v)) if v=="1"=>vec![218,196,191,179,217,196,192,179],Some(Expr::Int(v)) if v=="2"=>vec![201,205,187,186,188,205,200,186],_=>return Err("DispBox numeric border must be literal 1 or 2".into())}
    },Some(v)=>bytes(v)?};
    if border.len()!=8&&border.len()!=9{return Err("DispBox literal border must contain eight or nine bytes".into());}
    if border.iter().any(|v|!(33..=126).contains(v)&&![218,196,191,179,217,192,201,205,187,186,188,200,214,183,189,211,213,184,190,212].contains(v)){return Err("DispBox explicit border bytes must be nonspace printable ASCII or measured CP437 box bytes; spaces/control/DEL/other bytes are outside this increment".into());}
    if let Some(color)=args.get(5){let _=bytes(color)?;}
    Ok(Shape{top:c[0],left:c[1],bottom:c[2],right:c[3],border})
}
pub fn validate(fs:&[Func])->Result<(),String>{
    let mut used=false;
    for f in fs {super::visit_stmts_ref(&f.stmts,&mut |_|{},&mut |e|if matches!(e,Expr::Call(id,_) if is_builtin(id,"dispbox")){used=true;});}
    if !used{return Ok(());}
    if fs.len()!=1||fs[0].name!="main"||!fs[0].params.is_empty(){return Err("DispBox is measured only in an isolated parameter-free Main of ordered literal boxes".into());}
    let mut prev=None;let mut returned=false;
    for s in &fs[0].stmts {
        if returned{return Err("DispBox does not admit statements after RETURN".into());}
        match s {
            Stmt::Ret(_,None)=>returned=true,
            Stmt::CallStmt(_,Expr::Call(id,args)) if is_builtin(id,"dispbox")=>{
                let b=shape(args)?;if prev.map_or(false,|p|b.top<=p){return Err("DispBox boxes must occupy strictly increasing disjoint rows".into());}prev=Some(b.bottom);
            },
            _=>return Err("DispBox isolated Main allows only ordered literal box calls and RETURN; mixed output/control/variables are outside this increment".into())
        }
    }Ok(())
}
pub fn render(args:&[Expr])->Vec<u8>{
    let b=shape(args).expect("validated box");let previous=ROW.with(|r|{let p=r.get();r.set(b.bottom);p});
    let mut out=vec![b'\n';b.top-previous];let fill=*b.border.get(8).unwrap_or(&b' ');
    for row in b.top..=b.bottom{
        if row>b.top{out.push(b'\n');}out.extend(std::iter::repeat(b' ').take(b.left));
        let (l,m,r)=if row==b.top{(b.border[0],b.border[1],b.border[2])}else if row==b.bottom{(b.border[6],b.border[5],b.border[4])}else{(b.border[7],fill,b.border[3])};
        out.push(l);out.extend(std::iter::repeat(m).take(b.right-b.left-1));out.push(r);
    }out
}
