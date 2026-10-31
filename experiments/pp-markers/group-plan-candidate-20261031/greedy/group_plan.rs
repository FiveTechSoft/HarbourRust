// Own bounded one-level identifier capture plan. Not a production pp path.
#[derive(Debug,Clone,PartialEq)]
pub enum Atom { Literal(String), Identifier(usize) }
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
    if t.starts_with("<!")&&t.ends_with("!>"){
        let name=&t[2..t.len()-2];if !identifier(name)||markers.iter().any(|(n,_)|n.eq_ignore_ascii_case(name)){return None;}
        let i=markers.len();markers.push((name.into(),owner));Some(Atom::Identifier(i))
    }else if t.starts_with('<')||t=="["||t=="]"{None}else{Some(Atom::Literal(t.into()))}
}
impl Plan {
    pub fn parse(tokens:&[String])->Option<Self>{
        let mut nodes=Vec::new();let mut markers=Vec::new();let mut i=0;
        while i<tokens.len(){
            if tokens[i]=="["{
                let id=i;let mut atoms=Vec::new();i+=1;
                while i<tokens.len()&&tokens[i]!="]"{atoms.push(atom(&tokens[i],Some(id),&mut markers)?);i+=1;}
                if i==tokens.len()||atoms.is_empty()||!atoms.iter().any(|a|matches!(a,Atom::Identifier(_))){return None;}
                nodes.push(Node::Optional{id,atoms});i+=1;
            }else{nodes.push(Node::Atom(atom(&tokens[i],None,&mut markers)?));i+=1;}
        }
        Some(Self{nodes,markers})
    }
    pub fn matches(&self,source:&[String],exact:bool,prefix:bool)->Result<Option<Matched>,&'static str>{
        fn lit(s:&str,p:&str,exact:bool)->bool{s.eq_ignore_ascii_case(p)||(!exact&&s.is_ascii()&&p.is_ascii()&&s.len()>=4&&p.len()>s.len()&&p[..s.len()].eq_ignore_ascii_case(s))}
        fn atoms(atoms:&[Atom],source:&[String],start:usize,exact:bool)->Option<(usize,Vec<(usize,(usize,usize))>)>{
            let mut at=start;let mut caps=Vec::new();
            for a in atoms{let t=source.get(at)?;match a{Atom::Literal(l)=>if !lit(t,l,exact){return None;},Atom::Identifier(id)=>{if !identifier(t){return None;}caps.push((*id,(at,at+1)));}}at+=1;}
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
