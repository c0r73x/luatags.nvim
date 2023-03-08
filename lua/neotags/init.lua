local f=nil;local a=vim.api;local b=vim.loop;local c=require('neotags/utils')local d;do local e;local g={setup=function(h,i)if i then h.opts=vim.tbl_deep_extend('force',h.opts,i)end;if not h.opts.enable then return end;local j=vim.api.nvim_create_augroup('NeotagsLua',{clear=true})vim.api.nvim_create_autocmd(h.opts.autocmd.highlight,{group=j,callback=function()return require('neotags').highlight()end})return vim.api.nvim_create_autocmd(h.opts.autocmd.update,{group=j,callback=function()return require('neotags').update()end})end,restart=function(h,i)h:setup()return h:run('highlight',i)end,currentTagfile=function(h)if vim.b.neotags_current_tagfile and#vim.b.neotags_current_tagfile>0 then return vim.b.neotags_current_tagfile end;local i=vim.fn.getcwd()i=i:gsub('[%.%/]','__')local j=h.opts.ctags.directory;if type(j)=='function'then j=j()end;os.execute("[ ! -d '"..tostring(j).."' ] && mkdir -p '"..tostring(j).."' &> /dev/null")vim.b.neotags_current_tagfile=tostring(j).."/"..tostring(i)..".tags"return vim.b.neotags_current_tagfile end,runCtags=function(h,i)if h.ctags_handle then return end;local j=h:currentTagfile()local k={}if h.opts.ctags.ptags then for n,o in ipairs(h.opts.ctags.args)do if string.match(o,'^%-%-')then table.insert(k,"-c")end;table.insert(k,o)end;k=c.concat(k,{'-f',j})table.insert(k,vim.fn.getcwd())else k=h.opts.ctags.args;k=c.concat(k,{'-f',j})k=c.concat(k,i)end;local l;if h.opts.ctags.verbose then l=b.new_pipe(false)end;local m;if h.opts.ctags.verbose then m=b.new_pipe(false)end;h.ctags_handle=b.spawn(h.opts.ctags.binary,{args=k,cwd=vim.fn.getcwd(),stdio={nil,l,m}},vim.schedule_wrap(function()if h.opts.ctags.verbose then l:read_stop()l:close()m:read_stop()m:close()end;h.ctags_handle:close()h.ctags_handle=nil;vim.bo.tags=j;return h:run('highlight')end))if h.opts.ctags.verbose then b.read_start(l,function(n,o)if o then return print(o)end end)return b.read_start(m,function(n,o)if o then return print(o)end end)end end,update=function(h)if not h.opts.enable then return end;local i=vim.bo.filetype;if#i==0 or c.contains(h.opts.ignore,i)then return end;if h.opts.ctags.ptags then return h:runCtags(nil)else return h:findFiles(function(j)return h:runCtags(j)end)end end,findFiles=function(h,i)local j=vim.fn.getcwd()if not h.opts.tools.find then return i({'-R',j})end;if h.find_handle then return end;local k=b.new_pipe(false)local l;if h.opts.ctags.verbose then l=b.new_pipe(false)end;local m={}local n=c.concat(h.opts.tools.find.args,{j})h.find_handle=b.spawn(h.opts.tools.find.binary,{args=n,cwd=j,stdio={nil,k,l}},vim.schedule_wrap(function()k:read_stop()k:close()if h.opts.ctags.verbose then l:read_stop()l:close()end;h.find_handle:close()h.find_handle=nil;return i(m)end))b.read_start(k,function(o,p)if not p then return end;for q,r in ipairs(c.explode('\n',p))do table.insert(m,r)end end)if h.opts.ctags.verbose then return b.read_start(l,function(o,p)if p then return print(p)end end)end end,run=function(h,i,j)local k=vim.bo.filetype;if#k==0 or c.contains(h.opts.ignore,k)then return end;local l=nil;if'highlight'==i then local m=h:currentTagfile()if vim.fn.filereadable(m)==0 then h:update()elseif vim.bo.tags~=m then vim.bo.tags=m end;l=coroutine.create(function()return h:highlight()end)elseif'clear'==i then l=coroutine.create(function()return h:clearsyntax()end)else return end;if not l then return end;while true do local m,n=coroutine.resume(l)if n then vim.defer_fn(function()return vim.cmd(n)end,10)end;if coroutine.status(l)=='dead'then break end end;if j then return j()end end,toggle=function(h)h.opts.enable=not h.opts.enable;if(h.opts.enable)then return h:restart(function()return print("Neotags enabled")end)else return h:run('clear',function()return print("Neotags disabled")end)end end,language=function(h,i,j)h.languages[i]=j end,clearsyntax=function(h)vim.api.nvim_create_augroup('NeotagsLua',{clear=true})local i=a.nvim_get_current_buf()h.highlighting[i]=false;for j,k in pairs(h.syntax_groups[i])do coroutine.yield("silent! syntax clear "..tostring(k))end;h.syntax_groups[i]={}end,makesyntax=function(h,i,j,k,l,m,n,o)local p="_Neotags_"..tostring(i).."_"..tostring(j).."_"..tostring(l.group)local q={}local r={}local s=l.prefix or h.opts.hl.prefix;local t=l.suffix or h.opts.hl.suffix;local u=l.minlen or h.opts.hl.minlen;local v={'*'}for y=1,#k do local z=k[y]if#z.name<u then goto _continue_0 end;if c.contains(o,z.name:lower())then goto _continue_0 end;if c.contains(v,z.name)then goto _continue_0 end;print(vim.inspect(o))if(s==h.opts.hl.prefix and t==h.opts.hl.suffix and l.allow_keyword~=false and not z.name:find('.',1,true)and z.name~='contains')then if not c.contains(r,z.name)then table.insert(r,z.name)end elseif not z.name:find('.',1,true)then if not c.contains(q,z.name)then table.insert(q,z.name)end end;table.insert(o,z.name:lower())::_continue_0::end;if#o==0 then return end;vim.api.nvim_set_hl(0,p,{link=l.group})table.sort(q,function(y,z)return y<z end)local w={}local x=''if not n then if l.extend_notin~=nil and l.extend_notin==false then w=l.notin or h.opts.notin or{}else local y=h.opts.notin or{}local z=l.notin or{}local A=(#y>#z)and#y or#z;for B=1,A do if y[B]then w[#w+1]=y[B]end;if z[B]then w[#w+1]=z[B]end end end;if#w>0 then x="contained containedin=ALLBUT,"..tostring(table.concat(w,','))end else x="contained containedin="..tostring(table.concat(n,','))end;coroutine.yield("syntax clear "..tostring(p))for y=1,#q,h.opts.hl.patternlength do local z={unpack(q,y,y+h.opts.hl.patternlength)}local A=table.concat(z,'\\|')coroutine.yield("syntax match "..tostring(p).." /"..tostring(s).."\\%("..tostring(A).."\\)"..tostring(t).."/ "..tostring(x).." display")end;if#w>0 and not n then x="contained=ALLBUT,"..tostring(table.concat(w,','))end;table.sort(r,function(y,z)return y<z end)for y=1,#r,h.opts.hl.patternlength do local z={unpack(r,y,y+h.opts.hl.patternlength)}local A=table.concat(z,' ')coroutine.yield("syntax keyword "..tostring(p).." "..tostring(A).." "..tostring(x).." display")end;if not h.syntax_groups[m]then h.syntax_groups[m]={}end;return table.insert(h.syntax_groups[m],p)end,highlight=function(h)local i=a.nvim_get_current_buf()if h.highlighting[i]then return end;local j=vim.bo.filetype;if#j==0 or c.contains(h.opts.ignore,j)then return end;h.highlighting[i]=true;local k=table.concat(a.nvim_buf_get_lines(i,0,-1,false),'\n')local l=vim.fn.taglist('^[a-zA-Z$_].*$')local m={}for o=1,#l do local p=l[o]if not p.language then goto _continue_0 end;p.language=p.language:lower()if h.opts.ft_conv[p.language]then p.language=h.opts.ft_conv[p.language]end;if not h.languages[p.language]then goto _continue_0 end;if not h.languages[p.language].order then goto _continue_0 end;if not h.languages[p.language].order:find(p.kind)then goto _continue_0 end;if#p.name<h.opts.hl.minlen then goto _continue_0 end;if p.name:match('^[a-zA-Z]{,2}$')then goto _continue_0 end;if p.name:match('^_?_?anon')then goto _continue_0 end;if h.opts.ft_map[j]~=nil and c.contains(h.opts.ft_map[j],p.language)==false then goto _continue_0 end;if h.opts.ft_map[j]==nil and j~=p.language then goto _continue_0 end;if not k:find(p.name)then goto _continue_0 end;if not k:find("%W"..tostring(p.name).."%W")and not k:find("^"..tostring(p.name).."%W")then goto _continue_0 end;if not m[p.language]then m[p.language]={}end;if not m[p.language][p.kind]then m[p.language][p.kind]={}end;table.insert(m[p.language][p.kind],p)::_continue_0::end;local n=h.opts.ft_map[j]or{j}for o,p in pairs(n)do local q;if type(o)~="string"then q=p end;local r=nil;if type(o)=="string"then q=o;r=p end;if not h.languages[q]or not h.languages[q].order then goto _continue_1 end;local s=h.languages[q]local t=s.order;local u=m[q]if not u then goto _continue_1 end;local v={}for w=1,#t do local x=t:sub(w,w)if not u[x]then goto _continue_2 end;if not s.kinds or not s.kinds[x]then goto _continue_2 end;h:makesyntax(q,x,u[x],s.kinds[x],i,r,v)::_continue_2::end::_continue_1::end;h.highlighting[i]=false end}if g.__index==nil then g.__index=g end;e=setmetatable({__init=function(h,i)h.opts={enable=true,autocmd={highlight={'Syntax'},update={'BufWritePost'}},ft_conv={['c++']='cpp',['moonscript']='moon',['c#']='cs'},ft_map={cpp={'cpp','c'},c={'c','cpp'}},hl={minlen=3,patternlength=2048,prefix=[[\C\<]],suffix=[[\>]]},tools={find=nil},ctags={run=true,directory=vim.fn.expand('~/.vim_tags'),verbose=false,ptags=false,binary='ctags',args={'--fields=+l','--c-kinds=+p','--c++-kinds=+p','--sort=no'}},ignore={'cfg','conf','help','mail','markdown','nerdtree','nofile','readdir','qf','text','plaintext'},notin={'.*String.*','.*Comment.*','cIncluded','cCppOut2','cCppInElse2','cCppOutIf2','pythonDocTest','pythonDocTest2'}}h.languages={}h.syntax_groups={}h.highlighting={}h.ctags_handle=nil;h.find_handle=nil end,__base=g,__name="Neotags"},{__index=g,__call=function(h,...)local i=setmetatable({},g)h.__init(i,...)return i end})g.__class=e;d=e end;if not neotags then neotags=d()end;f={setup=function(e)local g=debug.getinfo(1).source:match('@?(.*/)')for h in io.popen("ls "..tostring(g).."/languages"):lines()do local i=h:gsub('%.lua$','')neotags.language(neotags,i,require("neotags/languages/"..tostring(i)))end;return neotags.setup(neotags,e)end,highlight=function()return neotags.run(neotags,'highlight')end,update=function()return neotags.update(neotags)end,toggle=function()return neotags.toggle(neotags)end,language=function(e,g)return neotags.language(neotags,e,g)end}return f