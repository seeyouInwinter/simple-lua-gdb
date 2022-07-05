function getvarvalue(...)
    co =...
    local found=false
    local thread_flag=false
    if type(co) == "thread" then
        thread_flag=true
    end
    local name
    local level
    local isenv
    if thread_flag then
        name,level,isenv=select(2, ...)
        level=level or 1
    else
        name,level,isenv=...
        level=(level or 1) + 1
    end
    for i = 1, math.huge do
        local n,v
        if thread_flag then
            n,v=debug.getlocal( co,level ,i)
        else
            n,v=debug.getlocal( level,i)
        end
        
        if not n then break end
        
        if n== name then
            value=v
            found=true
        end
        
    end
    if found then return "local",value end

    local func
    if thread_flag then
        func=debug.getinfo( co,level,"f" ).func
    else
        func=debug.getinfo( level,"f" ).func
    end
    for i= 1,math.huge do
        local n,v=debug.getupvalue( func, i )
        if not n then break end
        
        if n == name then 
            return "upvalue", v end
    end

    if isenv then return "noenv" end

    local env
    if thread_flag then
        _,env=getvarvalue(co,"_ENV",level,true)
        
    else 
        _,env=getvarvalue("_ENV",level,true)
    end
    if env then
        if env[name] then
            return "global",env[name]
        else
            return "noenv"
        end
    else
        return "noenv"
    end 
    

end


function getfilename(level)
    src=debug.getinfo( level ).short_src
    if string.find( src,"./") == nil then
        return src
    else
        return string.sub( src, 3 )
    end
end

function getAllLocals(level)
    local locals={}
    for i = 1, math.huge do
        local n,v
        n,v=debug.getlocal( level,i)
        
        if not n then break end
        if n=="(*temporary)" then 
            goto continue1
        end
        local val={}
        val["name"]=n
        val["val"]=v
        table.insert(locals,val)
        ::continue1::
    end
    return locals
end

function getArgs(level,nums)
    local locals={}
    for i = 1, nums do
        local n,v
        n,v=debug.getlocal( level,i)
        
        if not n then break end
        if n=="(*temporary)" then 
            goto continue1
        end
        local val={}
        val["name"]=n
        val["val"]=v
        table.insert(locals,val)
        ::continue1::
    end
    return locals
end