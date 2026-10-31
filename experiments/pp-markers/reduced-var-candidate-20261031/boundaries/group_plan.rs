// Own bounded one-level identifier capture plan. Not a production pp path.
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
                if i==tokens.len()||atoms.is_empty()||!atoms.iter().any(|a|matches!(a,Atom::Identifier(_)|Atom::Restricted(_,_)|Atom::Expression(_))){return None;}
                nodes.push(Node::Optional{id,atoms});i+=1;
            }else{nodes.push(Node::Atom(atom(&tokens[i],None,&mut markers)?));i+=1;}
        }
        Some(Self{nodes,markers})
    }
    pub fn matches(&self,source:&[String],exact:bool,prefix:bool)->Result<Option<Matched>,&'static str>{
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
                            if at>begin&&depth.is_empty()&&anchors.iter().any(|a|anchor(a,source,at,exact)){break;}
                            let operator=["+","-","*","/","%","^","**","=","==","!=","<>","<",">","<=",">=",":=",":","::",".",".AND.",".OR.",".NOT.","!","$","&","++","--","@","~","|","\\"].iter().any(|op|t.eq_ignore_ascii_case(op));
                            if depth.is_empty(){
                                if previous_atom&&!operator&&t!="("&&t!="["&&t!="{"&&t!=")"&&t!="]"&&t!="}"{break;}
                                if operator{if t!="++"&&t!="--"{previous_atom=false;}}else{previous_atom=true;}
                            }
                            if t=="("{depth.push(")");}else if t=="["{depth.push("]");}else if t=="{"{depth.push("}");}
                            else if t==")"||t=="]"||t=="}"{if depth.pop()!=Some(t){return None;}}
                            at+=1;
                        }
                        if at==begin{return None;}caps.push((*id,(begin,at)));
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
        if !prefix&&at!=source.len(){return Ok(None);}out.consumed=at;Ok(Some(out))
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
