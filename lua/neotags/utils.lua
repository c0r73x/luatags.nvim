local b;do local a;local c={contains=function(d,e)if not d then return false end;if not e then return false end;for f,g in pairs(d)do if g==e then return true end;if f==e then return true end end;return false end,concat=function(d,e)if not e then return d end;if not d then return e end;local f={unpack(d)}table.move(e,1,#e,#f+1,f)return f end,explode=function(d,e)if d==''then return false end;local f,g=0,{}local h=table.insert;local i=string.sub;for j,k in function()return string.find(e,d,f,true)end do h(g,i(e,f,j-1))f=k+1 end;return g end}if c.__index==nil then c.__index=c end;a=setmetatable({__init=function()end,__base=c,__name="Utils"},{__index=c,__call=function(d,...)local e=setmetatable({},c)d.__init(e,...)return e end})c.__class=a;b=a end;return b