// Own bounded one-level capture ownership plan. Caller gates eligible shapes.
#[derive(Debug,Clone,PartialEq)]
pub enum Atom { Literal(String), Identifier(usize), Restricted(usize,Vec<Vec<String>>), Expression(usize) }
#[derive(Debug,Clone,PartialEq)]
pub enum Node { Atom(Atom), Optional{ id:usize, atoms:Vec<Atom> } }
#[derive(Debug)]
pub struct Plan { pub nodes:Vec<Node>, pub markers:Vec<(String,Option<usize>)> }
#[derive(Debug,Clone,PartialEq)]
pub struct Iteration { pub group_id:usize, pub ordinal:usize, pub tokens:(usize,usize), pub captures:Vec<(usize,(usize,usize))> }
#[derive(Debug,Clone,PartialEq)]
pub struct Matched { pub roots:Vec<(usize,(usize,usize))>,pub iterations:Vec<Iteration>,pub consumed:usize }
fn identifier(s:&str)->bool { let b=s.as_bytes();!b.is_empty()&&(b[0].is_ascii_alphabetic()||b[0]==b'_')&&b[1..].iter().all(|b|b.is_ascii_alphanumeric()||*b==b'_') }
fn atom(t:&str,owner:Option<usize>,markers:&mut Vec<(String,Option<usize>)>)->Option<Atom>{
    if t.starts_with('<')&&t.ends_with('>'){
        let inner=&t[1..t.len()-1];
        let name=if inner.starts_with('!')&&inner.ends_with('!'){&inner[1..inner.len()-1]}else{inner.split(':').next()?};
        if !identifier(name)||markers.iter().any(|(n,_)|n.eq_ignore_ascii_case(name)){return None;}
        let id=markers.len();markers.push((name.into(),owner));
        if inner.starts_with('!'){Some(Atom::Identifier(id))}
        else if let Some((_,choices))=inner.split_once(':'){
            let choices:Vec<Vec<String>>=choices.split(',').map(|s|s.split_whitespace().map(String::from).collect()).collect();
            if choices.iter().any(|seq|seq.is_empty()||seq.iter().any(|s|!identifier(s))){return None;}
            Some(Atom::Restricted(id,choices))
        }else{Some(Atom::Expression(id))}
    }else if t=="["||t=="]"{None}else{Some(Atom::Literal(t.into()))}
}
impl Plan {
    pub fn parse(tokens:&[String])->Option<Self>{
        let mut nodes=Vec::new();let mut markers=Vec::new();let mut i=0;
        while i<tokens.len(){
            if tokens[i]=="["{
                let id=i;let mut atoms=Vec::new();i+=1;
                while i<tokens.len()&&tokens[i]!="]"{atoms.push(atom(&tokens[i],Some(id),&mut markers)?);i+=1;}
                if i==tokens.len()||atoms.is_empty(){return None;}
                nodes.push(Node::Optional{id,atoms});i+=1;
            }else{nodes.push(Node::Atom(atom(&tokens[i],None,&mut markers)?));i+=1;}
        }
        Some(Self{nodes,markers})
    }
    fn expression_in_scope(tokens:&[String])->bool{
        fn expr(t:&[String],at:&mut usize,depth:usize)->bool{
            if depth>64||!primary(t,at,depth+1){return false;}
            while t.get(*at).map(|s|matches!(s.as_str(),"+"|"-"|"*"|"/"|"%"|"^")).unwrap_or(false){*at+=1;if !primary(t,at,depth+1){return false;}}
            true
        }
        fn primary(t:&[String],at:&mut usize,depth:usize)->bool{
            if depth>64{return false;}let s=match t.get(*at){Some(s)=>s,None=>return false};
            if s=="+"||s=="-"{*at+=1;return primary(t,at,depth+1);}
            if s=="("{*at+=1;if !expr(t,at,depth+1)||t.get(*at).map(String::as_str)!=Some(")"){return false;}*at+=1;return true;}
            let name=identifier(s);
            if !name&&!s.bytes().all(|b|b.is_ascii_digit())&&!(s.len()>=2&&((s.starts_with('"')&&s.ends_with('"'))||(s.starts_with('\'')&&s.ends_with('\'')))){return false;}
            *at+=1;
            if name&&t.get(*at).map(String::as_str)==Some("("){
                *at+=1;if t.get(*at).map(String::as_str)!=Some(")"){loop{if !expr(t,at,depth+1){return false;}if t.get(*at).map(String::as_str)!=Some(","){break;}*at+=1;}}
                if t.get(*at).map(String::as_str)!=Some(")"){return false;}*at+=1;
            }
            true
        }
        let mut at=0;expr(tokens,&mut at,0)&&at==tokens.len()
    }
    pub fn expression_root(&self)->bool{
        if self.nodes.len()<3 || self.nodes.len()>8 || !matches!(self.nodes.first(),Some(Node::Atom(Atom::Literal(t)))if identifier(t)) || !matches!(self.nodes.get(1),Some(Node::Atom(Atom::Expression(_)))){return false;}
        let mut anchors=Vec::new();
        for node in &self.nodes[2..]{
            let atoms=match node{Node::Optional{atoms,..}=>atoms,_=>return false};
            match atoms.as_slice(){[Atom::Literal(t)]|[Atom::Literal(t),Atom::Expression(_)] if identifier(t)=>{
                if anchors.iter().any(|a:&String|a.eq_ignore_ascii_case(t)){return false;}anchors.push(t.clone());
            },_=>return false}
        }true
    }
    fn expression_root_matches(&self,source:&[String],exact:bool,adjacent:&[bool])->Result<Option<Matched>,&'static str>{
        fn prefix(t:&[String],adjacent:&[bool])->Option<usize>{
            let mut at=0;let mut stack=Vec::new();let mut previous=false;
            while at<t.len(){let word=t[at].as_str();
                if word.as_bytes().first().map(u8::is_ascii_digit).unwrap_or(false)&&!word.bytes().all(|b|b.is_ascii_digit())&&!word.strip_prefix("0x").or_else(||word.strip_prefix("0X")).map(|n|!n.is_empty()&&n.bytes().all(|b|b.is_ascii_hexdigit())).unwrap_or(false)&&!word.strip_prefix("0d").or_else(||word.strip_prefix("0D")).map(|n|!n.is_empty()&&n.bytes().all(|b|b.is_ascii_digit())).unwrap_or(false){return None;}
                if stack.is_empty()&&word=="."&&at>=2&&t[at-2]=="&"&&identifier(&t[at-1])&&adjacent[at]&&adjacent[at-1]{previous=true;at+=1;
                    if at<t.len()&&adjacent[at]&&identifier(&t[at]){at+=1;}
                    continue;}
                if stack.is_empty()&&at>0&&t[at-1].eq_ignore_ascii_case("d")&&adjacent[at]&&(word.starts_with('"')||word.starts_with('\'')){previous=true;at+=1;continue;}
                let operator=["+","-","*","/","%","^","**","=","==","!=","<>","<",">","<=",">=",":=",":","::",".",".AND.",".OR.",".NOT.","!","$","&","++","--","@","~","|","\\","?","=>","->"].iter().any(|o|word.eq_ignore_ascii_case(o));
                if stack.is_empty(){
                    if previous&&word=="&"&&t.get(at+1).map(|s|identifier(s)).unwrap_or(false)&&!adjacent[at]{break;}
                    if previous&&!operator&&!matches!(word,"("|"["|"{"|")"|"]"|"}"){break;}
                    if operator{if word!="++"&&word!="--"{previous=false;}}else{previous=true;}
                }
                match word{"("=>stack.push(")"),"["=>stack.push("]"),"{"=>stack.push("}"),")"|"]"|"}"=>if stack.pop()!=Some(word){return None},_=>{}}
                at+=1;
            }
            if at==0||!stack.is_empty(){None}else{Some(at)}
        }
        let lit=|s:&str,p:&str|s.eq_ignore_ascii_case(p)||(!exact&&s.is_ascii()&&p.is_ascii()&&s.len()>=4&&p.len()>s.len()&&p[..s.len()].eq_ignore_ascii_case(s));
        if source.is_empty()||!matches!(&self.nodes[0],Node::Atom(Atom::Literal(t))if lit(&source[0],t)){return Ok(None);}
        let root=match self.nodes[1]{Node::Atom(Atom::Expression(id))=>id,_=>return Ok(None)};
        let n=match prefix(&source[1..],&adjacent[1..]){Some(n)=>n,None=>return Ok(None)};let mut at=1+n;
        let mut out=Matched{roots:vec![(root,(1,at))],iterations:Vec::new(),consumed:0};
        let mut budget=1024;
        while at<source.len(){
            let mut next=None;
            for node in &self.nodes[2..]{if let Node::Optional{id,atoms}=node{
                let word=match &atoms[0]{Atom::Literal(t)=>t,_=>return Ok(None)};
                if !lit(&source[at],word){continue;}let start=at;let mut end=at+1;let mut captures=Vec::new();
                if let Some(Atom::Expression(marker))=atoms.get(1){let n=match prefix(&source[end..],&adjacent[end..]){Some(n)=>n,None=>return Ok(None)};captures.push((*marker,(end,end+n)));end+=n;}
                next=Some((*id,start,end,captures));break;
            }}
            match next{None=>return Ok(None),Some((id,start,end,captures))=>{
                if budget==0{return Err("expression root optional iteration limit exceeded");}budget-=1;
                let ordinal=out.iterations.iter().filter(|i|i.group_id==id).count();out.iterations.push(Iteration{group_id:id,ordinal,tokens:(start,end),captures});at=end;
            }}
        }
        out.consumed=at;Ok(Some(out))
    }
    pub fn reduced_var(&self)->bool{
        if self.nodes.len()<5||self.nodes.len()>11{return false;}
        if !matches!(&self.nodes[0],Node::Atom(Atom::Literal(t)) if identifier(t))||!matches!(&self.nodes[1],Node::Atom(Atom::Identifier(_))){return false;}
        let expected=[0,1,2];let mut names=Vec::new();
        for (node,kind) in self.nodes[2..5].iter().zip(expected){
            let atoms=match node{Node::Optional{atoms,..}=>atoms,_=>return false};
            if atoms.len()!=2{return false;}
            match (&atoms[0],&atoms[1],kind){
                (Atom::Literal(t),Atom::Identifier(_),0)if t==","=>{},
                (Atom::Restricted(_,choices),Atom::Identifier(_),1)|(Atom::Restricted(_,choices),Atom::Expression(_),1)|(Atom::Restricted(_,choices),Atom::Expression(_),2)=>{
                    for seq in choices{if seq.len()!=1||seq[0].len()<4&&seq[0].len()!=2{return false;}let word=seq[0].to_ascii_uppercase();if names.iter().any(|n:&String|n==&word||(n.len()>=4&&word.len()>=4&&n[..4]==word[..4])){return false;}names.push(word);}
                },_=>return false,
            }
        }
        for node in &self.nodes[5..]{
            let choices=match node{Node::Optional{atoms,..}if atoms.len()==1=>match &atoms[0]{Atom::Restricted(_,choices)=>choices,_=>return false},_=>return false};
            for seq in choices{if seq.len()!=1{return false;}let word=seq[0].to_ascii_uppercase();if names.iter().any(|n:&String|n==&word||(n.len()>=4&&word.len()>=4&&n[..4]==word[..4])){return false;}names.push(word);}
        }
        true
    }
    pub fn var_variant(&self)->bool{
        if !matches!(self.nodes.first(),Some(Node::Atom(Atom::Literal(t)))if identifier(t))||!matches!(self.nodes.get(1),Some(Node::Atom(Atom::Identifier(_)))){return false;}
        if !matches!(self.nodes.get(2),Some(Node::Optional{atoms,..})if matches!(atoms.as_slice(),[Atom::Literal(t),Atom::Expression(_)]if t.eq_ignore_ascii_case("AS"))){return false;}
        let tail=&self.nodes[3..];let mut keys=Vec::new();
        for pair in tail.chunks(2){if pair.len()!=2{return false;}match (&pair[0],&pair[1]){(Node::Atom(Atom::Literal(t)),Node::Atom(Atom::Identifier(_)))=>keys.push(t.to_ascii_uppercase()),_=>return false}}
        matches!(keys.iter().map(String::as_str).collect::<Vec<_>>().as_slice(),["IN"]|["IS"]|["IS","IN"]|["IS","TO"])
    }
    fn variant_matches(&self,source:&[String],exact:bool)->Result<Option<Matched>,&'static str>{
        let lit=|s:&str,p:&str|s.eq_ignore_ascii_case(p)||(!exact&&s.len()>=4&&s.is_ascii()&&p.is_ascii()&&p.len()>s.len()&&p[..s.len()].eq_ignore_ascii_case(s));
        if source.len()<2||!matches!(&self.nodes[0],Node::Atom(Atom::Literal(t))if lit(&source[0],t))||!identifier(&source[1]){return Ok(None);}
        let root=match self.nodes[1]{Node::Atom(Atom::Identifier(id))=>id,_=>return Ok(None)};
        let mut out=Matched{roots:vec![(root,(1,2))],iterations:Vec::new(),consumed:0};let mut at=2;
        if source.get(at).map(|s|lit(s,"AS")).unwrap_or(false){
            let begin=at+1;at=begin;let mut depth=0;
            let anchor=match &self.nodes[3]{Node::Atom(Atom::Literal(t))=>t,_=>return Ok(None)};
            while at<source.len(){if depth==0&&at>begin&&lit(&source[at],anchor)&&Self::expression_in_scope(&source[begin..at]){break;}if source[at]=="("{depth+=1;}if source[at]==")"{depth-=1;}at+=1;}
            if !Self::expression_in_scope(&source[begin..at]){return Ok(None);}
            if let Node::Optional{id,atoms}=&self.nodes[2]{if let Atom::Expression(marker)=atoms[1]{out.iterations.push(Iteration{group_id:*id,ordinal:0,tokens:(2,at),captures:vec![(marker,(begin,at))]});}}
        }
        for pair in self.nodes[3..].chunks(2){let (word,id)=match(&pair[0],&pair[1]){(Node::Atom(Atom::Literal(t)),Node::Atom(Atom::Identifier(id)))=>(t,*id),_=>return Ok(None)};
            if at+1>=source.len()||!lit(&source[at],word)||!identifier(&source[at+1]){return Ok(None);}out.roots.push((id,(at+1,at+2)));at+=2;
        }
        if at!=source.len(){return Ok(None);}out.consumed=at;Ok(Some(out))
    }
    fn identifier_matches(&self,source:&[String],exact:bool,prefix:bool)->Result<Option<Matched>,&'static str>{
        fn lit(s:&str,p:&str,exact:bool)->bool{s.eq_ignore_ascii_case(p)||(!exact&&s.is_ascii()&&p.is_ascii()&&s.len()>=4&&p.len()>s.len()&&p[..s.len()].eq_ignore_ascii_case(s))}
        fn atoms(atoms:&[Atom],source:&[String],start:usize,exact:bool)->Option<(usize,Vec<(usize,(usize,usize))>)>{
            let mut at=start;let mut caps=Vec::new();
            for a in atoms{let t=source.get(at)?;match a{Atom::Literal(l)=>if !lit(t,l,exact){return None;},Atom::Identifier(id)=>{if !identifier(t){return None;}caps.push((*id,(at,at+1)));},_=>return None}at+=1;}
            Some((at,caps))
        }
        fn seq(nodes:&[Node],source:&[String],at:usize,exact:bool,prefix:bool,state:Matched,budget:&mut usize)->Result<Option<Matched>,&'static str>{
            if *budget==0{return Err("identifier group match budget exhausted");}*budget-=1;
            if nodes.is_empty(){return Ok(if prefix||at==source.len(){Some(Matched{consumed:at,..state})}else{None});}
            match &nodes[0]{
                Node::Atom(a)=>{
                    if let Some((end,caps))=atoms(std::slice::from_ref(a),source,at,exact){let mut next=state;next.roots.extend(caps);seq(&nodes[1..],source,end,exact,prefix,next,budget)}else{Ok(None)}
                }
                Node::Optional{id,atoms:group}=>{
                    let mut choices=vec![(at,state)];let mut pos=at;
                    while let Some((end,caps))=atoms(group,source,pos,exact){
                        if end==pos{break;}let mut next=choices.last().unwrap().1.clone();let ordinal=choices.len()-1;
                        next.iterations.push(Iteration{group_id:*id,ordinal,tokens:(pos,end),captures:caps});choices.push((end,next));pos=end;
                        if choices.len()>1024{return Err("identifier group iteration limit exceeded");}
                    }
                    let (end,next)=choices.pop().unwrap();
                    seq(&nodes[1..],source,end,exact,prefix,next,budget)
                }
            }
        }
        seq(&self.nodes,source,0,exact,prefix,Matched{roots:Vec::new(),iterations:Vec::new(),consumed:0},&mut 10000)
    }
    pub fn matches_source(&self,source:&[String],exact:bool,prefix:bool,adjacent:&[bool])->Result<Option<Matched>,&'static str>{
        if adjacent.len()!=source.len(){return Err("invalid expression adjacency spans");}
        if self.expression_root(){return self.expression_root_matches(source,exact,adjacent);}
        self.matches(source,exact,prefix)
    }
    pub fn matches(&self,source:&[String],exact:bool,prefix:bool)->Result<Option<Matched>,&'static str>{
        if self.expression_root(){return self.expression_root_matches(source,exact,&vec![true;source.len()]);}
        if self.var_variant(){return self.variant_matches(source,exact);}
        if !self.reduced_var(){return self.identifier_matches(source,exact,prefix);}
        if prefix{return Err("reduced VAR prefix translation outside bounded contract");}
        for token in source{
            if identifier(token)||token.bytes().all(|b|b.is_ascii_digit())||token.starts_with('"')||token.starts_with('\'')||matches!(token.as_str(),"("|")"|","|"+"|"-"|"*"|"/"|"%"|"^"|"**"){continue;}
            return Err("reduced VAR expression atom outside bounded contract");
        }
        fn lit(s:&str,p:&str,exact:bool)->bool{s.eq_ignore_ascii_case(p)||(!exact&&s.is_ascii()&&p.is_ascii()&&s.len()>=4&&p.len()>s.len()&&p[..s.len()].eq_ignore_ascii_case(s))}
        fn anchor(a:&Atom,source:&[String],at:usize,exact:bool)->bool{
            match a{Atom::Literal(t)=>source.get(at).map(|s|lit(s,t,exact)).unwrap_or(false),Atom::Restricted(_,choices)=>choices.iter().any(|seq|at+seq.len()<=source.len()&&seq.iter().zip(&source[at..]).all(|(p,s)|lit(s,p,exact))),_=>false}
        }
        fn atoms(group:&[Atom],source:&[String],start:usize,exact:bool,anchors:&[&Atom])->Option<(usize,Vec<(usize,(usize,usize))>)>{
            let mut at=start;let mut caps=Vec::new();
            for (ai,a) in group.iter().enumerate(){
                let t=source.get(at)?;
                match a{
                    Atom::Literal(l)=>{if !lit(t,l,exact){return None;}at+=1;}
                    Atom::Identifier(id)=>{if !identifier(t){return None;}caps.push((*id,(at,at+1)));at+=1;}
                    Atom::Restricted(id,choices)=>{let choice=choices.iter().find(|seq|at+seq.len()<=source.len()&&seq.iter().zip(&source[at..]).all(|(p,s)|lit(s,p,exact)))?;caps.push((*id,(at,at+choice.len())));at+=choice.len();}
                    Atom::Expression(id)=>{
                        if ai+1!=group.len(){return None;}let begin=at;let mut depth=Vec::new();let mut previous_atom=false;
                        while at<source.len(){let t=source[at].as_str();
                            if at>begin&&previous_atom&&depth.is_empty()&&anchors.iter().any(|a|anchor(a,source,at,exact)){break;}
                            let operator=["+","-","*","/","%","^","**","=","==","!=","<>","<",">","<=",">=",":=",":","::",".",".AND.",".OR.",".NOT.","!","$","&","++","--","@","~","|","\\","?","=>"].iter().any(|op|t.eq_ignore_ascii_case(op));
                            if depth.is_empty(){
                                if t=="."&&at>begin&&source[begin]=="&"{previous_atom=at+1>=source.len()||anchors.iter().any(|a|anchor(a,source,at+1,exact));at+=1;continue;}
                                if at>begin&&source[at-1].eq_ignore_ascii_case("d")&&(t.starts_with('"')||t.starts_with('\'')){previous_atom=true;at+=1;continue;}
                                if previous_atom&&!operator&&t!="("&&t!="["&&t!="{"&&t!=")"&&t!="]"&&t!="}"{break;}
                                if operator{if t!="++"&&t!="--"{previous_atom=false;}}else{previous_atom=true;}
                            }
                            if t=="("{depth.push(")");}else if t=="["{depth.push("]");}else if t=="{"{depth.push("}");}
                            else if t==")"||t=="]"||t=="}"{if depth.pop()!=Some(t){return None;}}
                            at+=1;
                        }
                        if at==begin{return None;}
                        if source[begin..at].iter().any(|t|t.as_bytes().first().map(u8::is_ascii_digit).unwrap_or(false)&&!t.bytes().all(|b|b.is_ascii_digit())&&!t.strip_prefix("0x").or_else(||t.strip_prefix("0X")).map(|n|!n.is_empty()&&n.bytes().all(|b|b.is_ascii_hexdigit())).unwrap_or(false)&&!t.strip_prefix("0d").or_else(||t.strip_prefix("0D")).map(|n|!n.is_empty()&&n.bytes().all(|b|b.is_ascii_digit())).unwrap_or(false)){return None;}
                        caps.push((*id,(begin,at)));
                    }
                }
            }
            Some((at,caps))
        }
        let mut out=Matched{roots:Vec::new(),iterations:Vec::new(),consumed:0};let mut at=0;let mut first_group=self.nodes.len();
        for (i,node) in self.nodes.iter().enumerate(){match node{
            Node::Atom(a)=>{let(end,caps)=match atoms(std::slice::from_ref(a),source,at,exact,&[]){Some(v)=>v,None=>return Ok(None)};out.roots.extend(caps);at=end;}
            Node::Optional{..}=>{first_group=i;break;}
        }}
        let groups=&self.nodes[first_group..];
        if groups.iter().any(|n|matches!(n,Node::Atom(_))){return Err("required suffix after optional cluster outside reduced VAR plan");}
        let anchors:Vec<&Atom>=groups.iter().filter_map(|n|match n{Node::Optional{atoms,..}=>atoms.first(),_=>None}).collect();
        let mut budget=1024;
        loop{
            let mut found=None;
            for n in groups{if let Node::Optional{id,atoms:group}=n{if let Some((end,caps))=atoms(group,source,at,exact,&anchors){if end>at{found=Some((*id,end,caps));break;}}}}
            if let Some((id,end,caps))=found{if budget==0{return Err("reduced VAR group iteration limit exceeded");}budget-=1;let ordinal=out.iterations.iter().filter(|it|it.group_id==id).count();out.iterations.push(Iteration{group_id:id,ordinal,tokens:(at,end),captures:caps});at=end;}else{break;}
        }
        if !prefix&&at!=source.len(){return Ok(None);}
        for it in &out.iterations{for (id,(start,end)) in &it.captures{
            if self.nodes.iter().any(|node|matches!(node,Node::Optional{atoms,..} if atoms.iter().any(|a|matches!(a,Atom::Expression(m) if m==id))))&&!Self::expression_in_scope(&source[*start..*end]){return Err("reduced VAR expression shape outside bounded contract");}
        }}
        out.consumed=at;Ok(Some(out))
    }

}
#[cfg(test)]
mod tests{
use super::*;
fn words(t:&[&str])->Vec<String>{t.iter().map(|s|s.to_string()).collect()}
#[test]fn comma_and_tail_are_independent(){
 let p=Plan::parse(&words(&["SHOW","<!a!>","[",",","<!b!>","]","[","AS","<!t!>","]"])).unwrap();
 let m=p.matches(&words(&["SHOW","alpha",",","beta",",","gamma","AS","number"]),true,false).unwrap().unwrap();
 assert_eq!(m.roots,vec![(0,(1,2))]);assert_eq!(m.iterations.iter().map(|it|(it.group_id,it.ordinal,it.tokens)).collect::<Vec<_>>(),vec![(2,0,(2,4)),(2,1,(4,6)),(6,0,(6,8))]);assert_eq!(m.consumed,8);
}
#[test]fn identifier_group_does_not_backtrack_for_required_tail(){
 let p=Plan::parse(&words(&["SHOW","[","<!x!>","]","END","<!tail!>"])).unwrap();
 assert!(p.matches(&words(&["SHOW","alpha","beta","END","done"]),true,false).unwrap().is_none());
}
#[test]fn malformed_comma_not_accepted(){let p=Plan::parse(&words(&["SHOW","<!a!>","[",",","<!b!>","]"])).unwrap();assert!(p.matches(&words(&["SHOW","alpha",",",",","beta"]),true,false).unwrap().is_none());}
#[test]fn prefix_keeps_unconsumed_source(){let p=Plan::parse(&words(&["SHOW","<!a!>","[",",","<!b!>","]"])).unwrap();let m=p.matches(&words(&["SHOW","alpha",",","123"]),true,true).unwrap().unwrap();assert_eq!(m.consumed,2);assert!(m.iterations.is_empty());}
#[test]fn nested_and_duplicate_markers_stay_out(){assert!(Plan::parse(&words(&["SHOW","[","[","<!a!>","]","]"])).is_none());assert!(Plan::parse(&words(&["SHOW","<!a!>","[",",","<!a!>","]"])).is_none());}
}
// Result pieces name marker IDs. A single repeated owner may drive expansion;
// root captures and singleton sibling owners broadcast. No Cartesian products.
#[derive(Debug,PartialEq)]
pub struct ResultIteration { pub driver:Option<(usize,usize)>,pub captures:Vec<(usize,(usize,usize))> }
impl Plan{
 pub fn result_iterations(&self,matched:&Matched,markers:&[usize],grouped:bool)->Result<Vec<ResultIteration>,&'static str>{
  let mut owners=Vec::new();
  for id in markers{let owner=self.markers.get(*id).ok_or("unknown result marker")?.1;if let Some(owner)=owner{if !owners.contains(&owner){owners.push(owner);}}}
  let mut repeated=Vec::new();
  for owner in &owners{let n=matched.iterations.iter().filter(|it|it.group_id==*owner).count();if n>1{repeated.push(*owner);}}
  if repeated.len()>1{return Err("multiple repeated result owners outside bounded plan");}
  if !grouped&&!repeated.is_empty(){return Err("repeated result marker outside associated group");}
  let driver=repeated.first().copied();
  let any_bound=markers.iter().any(|id|matched.roots.iter().any(|(m,_)|m==id)||matched.iterations.iter().any(|it|it.captures.iter().any(|(m,_)|m==id)));
  if grouped&&!any_bound{return Ok(Vec::new());}
  let count=driver.map(|d|matched.iterations.iter().filter(|it|it.group_id==d).count()).unwrap_or(1);let mut out=Vec::new();
  for ordinal in 0..count{
   let mut captures=Vec::new();
   for id in markers{
    if let Some(value)=matched.roots.iter().find(|(m,_)|m==id){captures.push(*value);continue;}
    if let Some(owner)=self.markers[*id].1{
     let target=if Some(owner)==driver{ordinal}else{0};
     if let Some(value)=matched.iterations.iter().find(|it|it.group_id==owner&&it.ordinal==target).and_then(|it|it.captures.iter().find(|(m,_)|m==id)){captures.push(*value);}
    }
   }
   out.push(ResultIteration{driver:driver.map(|d|(d,ordinal)),captures});
  }
  Ok(out)
 }
}
#[cfg(test)]mod result_tests{
use super::*;fn w(t:&[&str])->Vec<String>{t.iter().map(|s|s.to_string()).collect()}
#[test]fn root_and_singleton_broadcast_with_comma_group(){let p=Plan::parse(&w(&["SHOW","<!a!>","[",",","<!b!>","]","[","AS","<!t!>","]"])).unwrap();let m=p.matches(&w(&["SHOW","alpha",",","beta",",","gamma","AS","number"]),true,false).unwrap().unwrap();let r=p.result_iterations(&m,&[0,1,2],true).unwrap();assert_eq!(r.len(),2);assert_eq!(r[0].captures,vec![(0,(1,2)),(1,(3,4)),(2,(7,8))]);assert_eq!(r[1].captures,vec![(0,(1,2)),(1,(5,6)),(2,(7,8))]);assert!(p.result_iterations(&m,&[1],false).is_err());}
#[test]fn missing_sibling_does_not_drop_bound_root_group(){let p=Plan::parse(&w(&["SHOW","<!a!>","[",",","<!b!>","]"])).unwrap();let m=p.matches(&w(&["SHOW","alpha"]),true,false).unwrap().unwrap();assert_eq!(p.result_iterations(&m,&[0,1],true).unwrap().len(),1);assert!(p.result_iterations(&m,&[1],true).unwrap().is_empty());}
#[test]fn multiple_repeated_owners_not_silently_crossed(){let p=Plan::parse(&w(&["SHOW","[","X","<!x!>","]","[","Y","<!y!>","]"])).unwrap();let m=p.matches(&w(&["SHOW","X","a","X","b","Y","c","Y","d"]),true,false).unwrap().unwrap();assert!(p.result_iterations(&m,&[0,1],true).is_err());}
}

#[cfg(test)]mod reduced_tests{
 use super::*;
 fn w(s:&[&str])->Vec<String>{s.iter().map(|s|s.to_string()).collect()}
 fn p()->Plan{Plan::parse(&w(&["PROBE","<!a!>","[",",","<!b!>","]","[","<tp:TYPE,AS>","<!t!>","]","[","<ini:INIT,ASSIGN>","<v>","]"])).unwrap()}
 #[test]fn reduced_topology_is_explicit(){assert!(p().reduced_var());assert!(!Plan::parse(&w(&["PROBE","[","<x:alpha,beta>","]"])).unwrap().reduced_var());}
 #[test]fn reduced_dispatch_reorders(){let p=p();let m=p.matches(&w(&["PROBE","alpha","INIT","1","AS","number"]),true,false).unwrap().unwrap();assert_eq!(m.iterations.iter().map(|i|i.group_id).collect::<Vec<_>>(),vec![10,6]);}
 #[test]fn reduced_anchor_is_operand_after_operator(){let p=p();assert!(p.matches(&w(&["PROBE","alpha","INIT","a","+","AS"]),true,false).unwrap().is_some());assert!(p.matches(&w(&["PROBE","alpha","INIT","a","+","AS","number"]),true,false).unwrap().is_none());}
 #[test]fn reduced_unsupported_atoms_fail_closed(){let p=p();for e in [w(&["1e2"]),w(&["a",".","1"]),w(&["&","name","."]),w(&["a","**","2"])]{let mut t=w(&["PROBE","alpha","INIT"]);t.extend(e);assert!(p.matches(&t,true,false).is_err());}}
 #[test]fn reduced_expression_admission_is_not_a_general_parser(){assert!(Plan::expression_in_scope(&w(&["f","(","1",",","2",")","+","3"])));assert!(!Plan::expression_in_scope(&w(&["1","+"])));assert!(!Plan::expression_in_scope(&w(&[","])));}
 #[test]fn reduced_prefix_stays_out(){assert!(p().matches(&w(&["PROBE","alpha"]),true,true).is_err());}
 #[test]fn reduced_iteration_cap(){let mut t=w(&["PROBE","alpha"]);for _ in 0..1025{t.extend(w(&[",","beta"]));}assert!(p().matches(&t,true,false).is_err());}
}

#[cfg(test)]mod plain_type_tests{
 use super::*;
 #[test]fn plain_type_uses_its_own_owner(){
 let tokens=["PROBE","<!a!>","[",",","<!b!>","]","[","<tp:TYPE,AS>","<t>","]","[","<ini:INIT,ASSIGN>","<v>","]"].iter().map(|s|s.to_string()).collect::<Vec<_>>();let p=Plan::parse(&tokens).unwrap();assert!(p.reduced_var());
 let source=["PROBE","alpha","INIT","1","AS","f","(","2",",","3",")"].iter().map(|s|s.to_string()).collect::<Vec<_>>();let m=p.matches(&source,true,false).unwrap().unwrap();assert_eq!(m.iterations.iter().map(|i|i.group_id).collect::<Vec<_>>(),vec![10,6]);assert_eq!(m.iterations[1].captures.last(),Some(&(3,(5,11))));
 }
}

#[cfg(test)]mod flag_tests{
 use super::*;
 #[test]fn flag_anchors_are_disjoint(){let mut t=["PROBE","<!a!>","[",",","<!b!>","]","[","<tp:TYPE,AS>","<t>","]","[","<ini:INIT,ASSIGN>","<v>","]","[","<ex:EXPORTED,VISIBLE>","]"].iter().map(|s|s.to_string()).collect::<Vec<_>>();assert!(Plan::parse(&t).unwrap().reduced_var());t[15]="<ex:ASSIGNED>".into();assert!(!Plan::parse(&t).unwrap().reduced_var());}
}

#[cfg(test)] mod expression_root_tests {
 use super::*;
 fn w(s:&[&str])->Vec<String>{s.iter().map(|s|s.to_string()).collect()}
 fn plan()->Plan{Plan::parse(&w(&["SHOW","<x>","[","AS","<t>","]","[","DECL","]"])).unwrap()}
 #[test] fn root_clause_order_and_owner(){let p=plan();assert!(p.expression_root());let s=w(&["SHOW","f","(","1",",","2",")","DECL","AS","T","DECL"]);let m=p.matches_source(&s,true,false,&vec![false;s.len()]).unwrap().unwrap();assert_eq!(m.roots,vec![(0,(1,7))]);assert_eq!(m.iterations.iter().map(|i|i.group_id).collect::<Vec<_>>(),vec![6,2,6]);}
 #[test] fn source_adjacency_is_not_optional(){let p=plan();let s=w(&["SHOW","d","\"date\"","DECL"]);assert!(p.matches_source(&s,true,false,&[false,false,false,false]).unwrap().is_none());assert!(p.matches_source(&s,true,false,&[false,false,true,false]).unwrap().is_some());assert!(p.matches_source(&s,true,false,&[]).is_err());}
 #[test] fn invalid_numeric_atom_does_not_match(){let p=plan();for n in ["1e2","1abc","0xFG"]{let s=w(&["SHOW",n,"DECL"]);assert!(p.matches_source(&s,true,false,&vec![false;s.len()]).unwrap().is_none());}}
 #[test] fn iteration_limit_is_bounded(){let p=plan();let mut s=w(&["SHOW","7"]);s.extend(std::iter::repeat("DECL".to_string()).take(1025));assert!(p.matches_source(&s,true,false,&vec![false;s.len()]).is_err());}
 #[test] fn anchors_are_distinct(){assert!(!Plan::parse(&w(&["SHOW","<x>","[","AS","<t>","]","[","as","]"])).unwrap().expression_root());}
}
