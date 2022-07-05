file_io={fp}
function file_io:new(o)
    o=o or {}
    self.__index=self
    setmetatable(o,self)
    return o 
end


function file_io:readRow(f,st,en)
    en=en or 10
    self.fp=io.open(f,"r")
    self.fp:seek("set",0)
    local reLine=0
    local src={}
    local nums=0
    for r in self.fp:lines() do
        reLine=reLine+1
        if reLine>=st then
            src[#src+1]=r
            nums=nums+1
            if nums>=en then
                break
            end
        end
    end
    io.close(self.fp)
    return src
end

return file_io