
--[[
    break_table={Point}
    Point={line=nums,filename=path,status=boolean}
]]
--[[
    函数名:isIntable
    参数：
        point 判断对象
        itable 判断表
    返回值：
        boolean
    作用：判断point是否在表中
]]
function isIntable(point,itable)
    for i,val in ipairs(itable) do            
        if val["line"]==point["line"] and val["filename"]==point["filename"] then
            if val["status"]==false then
                return false
            else
                return true
            end
        end
    end
    return false
end
--[[
    函数名:deltable
    返回值：boolean
    作用：将point从itable中删除
]]

function deltable( point,itable )
    for i,val in ipairs(itable) do
        if val["line"]== point["line"] and val["filename"]==point["filename"] then
            table.remove( itable,i)
            return true
        end
    end
    return false
end
--[[
    函数名：addtable
    返回值：无
    作用：向表中加入数据
]]
function addtable(point,itable)
    for i,v in ipairs(itable) do
        if v["line"]==point["line"] and v["filename"]==point["filename"] then
            return nil
        end
    end
    table.insert( itable,point )
end


--[[
    函数名：showtable
    返回值：无
    作用：查看全部断点
]]
function showtable(itable)
    print("序号","断点位置","所在文件","开启状态")
    for i,v in ipairs(itable) do
        print(i,v["line"]," ",v["filename"],v["status"])
    end
end

--[[
    函数名：getIndex
    返回值：元素下标
    作用：获取下标
]]
function getIndex(point,itable)
    for i,v in ipairs(itable) do
        if  v["line"] ==point["line"] and v["filename"]==point["filename"] then
            return i
        end
    end
    return nil
end

--[[
    函数名：getTable
    返回值：下标对应的值
    作用：获取下标对应的值
]]
function getTable(index,itable)
    for i,v in ipairs(itable) do
        if  i==tonumber(index) then
            return v
        end
    end
    return nil
end

--[[
    函数名：split
    返回值：table
    作用：将字符串划分
    example: "print a"->"print","a"
]]
function split(str,reps)
    local resultStrList = {}
    string.gsub(str,'[^'..reps..']+',function (w)
        table.insert(resultStrList,w)
    end)
    return resultStrList
end

--[[
    函数名：delTableByline
    返回值：boolean
    作用：通过断点所在行数删除元素
]]
function delTableByline(line,itable,filename)
    for i,val in ipairs(itable) do
        if val["line"]== line and val["filename"]==filename then
            table.remove( itable,i)
            return true
        end
    end
    return false
end
--[[
    函数名：delTableByIndex
    返回值：boolean
    作用：通过编号删除元素
]]
function delTableByIndex(index,itable)
    local i=string.byte( index )-48
    if itable[i]== nil then
        return false
    else
        table.remove( itable, i)
        return true
    end
end

--[[
    函数名：SetBreakPointStatus
    返回值：boolean
    作用：修改断点状态
]]

function SetBreakPointStatus(index,status,itable)
    if getTable(index,break_table)==nil then
        print("No such BreakPoint!")
        return false
    end
    itable[index]["status"]=status
    return true
end


--[[
    函数名：funcStkPush
    返回值：
    作用：将func_env加入stk中
]]
function funcStkPush(func_env,func_stack)
    local len=#func_stack
    if len == 0 then
        table.insert(func_stack,func_env)
    elseif len==1 and func_stack[1]~=func_env then
        table.insert(func_stack,func_env)
    elseif len>=2 and func_stack[len]~=func_env and func_stack[len-1]~=func_env then
        table.insert(func_stack,func_env)
    end

end

--[[
    函数名：funcStkPop
    返回值：
    作用：将func_env移除stk
]]
function funcStkPop(func_env,func_stack)
    local len=#func_stack
    if len>=2 and func_stack[len-1]==func_env then
        table.remove(func_stack,len)
    end
end

--[[
    函数名：checknBreak
    返回值：boolean
    作用：检查n断点是否执行
]]

function checknBreak(cur_env,break_env,func_stack)
    local ans=false
    if cur_env==break_env then
        ans=true
    end
    if #func_stack>=2 and cur_env==func_stack[#func_stack-1] then
        ans=true
    end
    return ans

end