MEMVAR v
function Probe(label,text)
local result, err, saved:=ErrorBlock({|e| Break(e)})
begin sequence
result:=&(text)
OutStd(label+"=OK:"+ValType(result)+":"+hb_ValToStr(result)+Chr(10))
recover using err
OutStd(label+"=ERR:"+hb_ntos(err:subCode)+":"+err:operation+Chr(10))
end sequence
ErrorBlock(saved)
return nil
function Main()
private v:=10
Probe("lit.exact","10/2")
Probe("var.exact","v/2")
Probe("lit.zero","10/0")
Probe("var.zero","v/0")
Probe("missing.then.syntax","missing +")
Probe("const.false.missing",".F. .AND. missing")
Probe("missing.const.false","missing .AND. .F.")
v:=.F.
Probe("var.false.missing","v .AND. missing")
Probe("var.false.badtype","v .AND. 123")
Probe("badtype.var.false","123 .AND. v")
Probe("const.true.missing",".T. .OR. missing")
v:=.T.
Probe("var.true.missing","v .OR. missing")
return nil
