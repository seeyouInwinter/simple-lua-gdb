require("table_op")
require("getval")
fp=require("file_io")
break_table={}  --断点表
n_break={}  --跳过函数调试
func_stack={}  --函数调用栈
START_FLAG=false --启动判断
STEP_ONE_FLAG=false --单步调试判断
start_file_name=arg[1]  --主调试文件
MAIN_FUNC=debug.getinfo(1).func
function getcmd(line)
    local SHOW_LINE=line    --保存上下文
    local FIRST_SHOW_FLAG=false
    local RuningFileName=getfilename(4)
    if START_FLAG==false then
        SHOW_LINE=1
        RuningFileName=start_file_name
    end
    while true do
        io.write("(gdb)")
        str=io.read()
        ans=split(str," ")  --划分
        local Point={}
        Point["status"]=true
        if ans[1]== "b" then        --break      
            if ans[3]==nil then
                Point["filename"]=start_file_name
            else
                Point["filename"]=ans[3]
            end
            if ans[2]==nil or tonumber(ans[2])==nil then
                print("error! b line [filename]")
                goto continue
            end
            Point["line"]=ans[2]
            addtable(Point,break_table)
            my_index=getIndex(Point,break_table)
            print(string.format( "Breakpoint %d at %s:%d.",my_index,Point["filename"],Point["line"]))
        elseif ans[1]=="clear" then     --clear
            if ans[3]==nil then
                Point["filename"]=start_file_name
            else 
                Point["filename"]=ans[3]
            end
            Point["line"]=ans[2]
            my_index=getIndex(Point,break_table)
            if my_index==nil then
                print("No such BreakPoint!")
            else
                deltable(Point,break_table)
                print("BreakPoint "..my_index.." have been delete!")
            end
        elseif ans[1]=="delete" then        --delete
            if delTableByIndex(ans[2],break_table) == false then
                print("No such BreakPoint!")
            else
                print("BreakPoint "..ans[2].." have been delete!")
            end
        elseif ans[1]=="disable" then       --disable
            local break_index=tonumber(ans[2])
            if break_table==nil then
                print("error! disable break_index(number)")
                goto continue
            end
            if SetBreakPointStatus(break_index,false,break_table) ==false then
                print("Set status fail!")
            else
                local s=string.format( "BreakPoint %d disable!",break_index)
                print(s)
            end   
        elseif ans[1]=="enable" then        --enable
            local break_index=tonumber(ans[2])
            if break_table==nil then
                print("error! enable break_index(number)")
                goto continue
            end
            if SetBreakPointStatus(break_index,true,break_table) ==false then
                print("Set status fail!")
            else
                local s=string.format( "BreakPoint %d enable!",break_index)
                print(s)
            end
        elseif ans[1]=="start" then     --start
            if START_FLAG==false then
                START_FLAG=true
            end
            break
        elseif ans[1]=="c" then         --c 
            if START_FLAG==false then
                print("you have not startd yet")
                goto continue
            else
                print("Continuing")
                break
            end
        elseif ans[1]=="s" then     --s
            if START_FLAG==false then
                print("you have not startd yet")
                goto continue
            end
            STEP_ONE_FLAG=true
            break
        elseif ans[1]=="n" then
            if START_FLAG==false then
                print("you have not startd yet")
                goto continue
            end
            local func_env=debug.getinfo(3).func
            n_break["status"]=true
            n_break["env"]=func_env

            break
        elseif ans[1]=="info" then      --info
            if ans[2]=="b" then             --info b
                if ans[3]==nil then
                    showtable(break_table)
                else
                    local pt=getTable(ans[3],break_table)
                    if pt ==nil then
                        showtable(break_table)
                    else
                        print("序号","断点位置","所在文件")
                        print(ans[3],pt["line"],pt["filename"])
                    end
                    
                end
            elseif ans[2]=="locals" then        --info locals
                local locals=getAllLocals(4)
                print("变量名","变量值")
                for i,v in ipairs(locals) do
                    print(v["name"],v["val"])
                end
            elseif ans[2]=="args" then          --info args
                local argsNum=debug.getinfo(3).nparams
                local args=getArgs(4,argsNum)
                for i,v in ipairs(args) do
                    print(v["name"],v["val"])
                end
            end
        elseif ans[1]=="p" then
            p,v=getvarvalue(ans[2],3)
            if(p~="noenv") then
                print(p,ans[2],"=",v)
            else 
                print(ans[2],"=","nil")
            end
        elseif ans[1]=="l" then
            local show_start=0
            local step=ans[2] or 10
            if FIRST_SHOW_FLAG==false then --第一次使用，显示上下文              
                show_start=SHOW_LINE-step//2
                if show_start<=0 then
                    show_start=1
                end
                SHOW_LINE=show_start+step
                FIRST_SHOW_FLAG=true
            else
                show_start=SHOW_LINE
            end
            src=fp:readRow(RuningFileName,show_start,ans[2])
            local j=show_start
            for i,val in ipairs(src) do
                print(j," ",val)
                j=j+1
            end
        elseif ans[1]=="quit" then
            os.exit()         
        else            
            src=string.format( "Undefined command:\"%s\". Try \"help\"",ans[1])
            print(src)
        end
        ::continue::
    end
end
function todo(event,line)
    -- 判断line 是否在break_table中 或者START_FLAG
    --print(line,isIntable(line,break_table))
    
    local Point={}
    local func_env=debug.getinfo(2).func
    if MAIN_FUNC==func_env and START_FLAG then
        print("end")
        return
    end
    
    if n_break["status"]==true and checknBreak(func_env,n_break["env"],func_stack) then
        STEP_ONE_FLAG=true
        n_break["status"]=false
    end
    funcStkPush(func_env,func_stack)
    funcStkPop(func_env,func_stack) 
    Point["line"]=tostring(line)
    Point["filename"]=getfilename(3)
    local isIntable_flag=isIntable(Point,break_table)   --进行断点判断
    if START_FLAG==false then
        getcmd(line)
    elseif isIntable_flag then
        STEP_ONE_FLAG=false
        s=string.format( "BreakPoint %d, %s at %s:%s",getIndex(Point,break_table),
        debug.getinfo(2).what,debug.getinfo(2).short_src,line)
        print(s)
        fileInfo=fp:readRow(getfilename(3),line,1)
        print(Point["filename"]..":"..line," ",fileInfo[1]) 
        getcmd(line)
        
    elseif STEP_ONE_FLAG==true then
        STEP_ONE_FLAG=false
        fileInfo=fp:readRow(getfilename(3),line,1)
        print(Point["filename"]..":"..line," ",fileInfo[1]) 
        getcmd(line)
    end

end

table.remove( arg,1 )

fp:new()
env1={}
while true do
    debug.sethook( todo, "l" )
    dofile(start_file_name)
    debug.sethook()
    START_FLAG=false
    
end
