function Main()
local saved:=ErrorBlock({|e| Break(e)}), e, text:="10/0", answer
begin sequence
answer:= &("10/0")
OutStd("constant.zero=OK:"+hb_ValToStr(answer)+Chr(10))
recover using e
OutStd("constant.zero=ERR:"+hb_ntos(e:subCode)+Chr(10))
end sequence
begin sequence
answer:= &(text)
OutStd("dynamic.zero=OK:"+hb_ValToStr(answer)+Chr(10))
recover using e
OutStd("dynamic.zero=ERR:"+hb_ntos(e:subCode)+Chr(10))
end sequence
ErrorBlock(saved)
return nil
