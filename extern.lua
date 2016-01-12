function clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

--Create an class.
function class(classname, super)
    local superType = type(super)
    local cls

    if superType ~= "function" and superType ~= "table" then
        superType = nil
        super = nil
    end

    if superType == "function" or (super and super.__ctype == 1) then
        -- inherited from native C++ Object
        cls = {}

        if superType == "table" then
            -- copy fields from super
            for k,v in pairs(super) do cls[k] = v end
            cls.__create = super.__create
            cls.super    = super
        else
            cls.__create = super
        end
        
        cls.ctor    = function() end
        cls.__cname = classname
        cls.__ctype = 1

        function cls.new(...)
            local instance = cls.__create(...)
            -- copy fields from class to native object
            for k,v in pairs(cls) do instance[k] = v end
            instance.class = cls
            instance:ctor(...)
            return instance
        end

    else
        -- inherited from Lua Object
        if super then
            cls = clone(super)
            cls.super = super
        else
            cls = {ctor = function() end}
        end

        cls.__cname = classname
        cls.__ctype = 2 -- lua
        cls.__index = cls

        function cls.new(...)
            local instance = setmetatable({}, cls)
            instance.class = cls
            instance:ctor(...)
            return instance
        end
    end

    return cls
end

function schedule(node, callback, delay)
    local delay = CCDelayTime:create(delay)
    local callfunc = CCCallFunc:create(callback)
    local sequence = CCSequence:createWithTwoActions(delay, callfunc)
    local action = CCRepeatForever:create(sequence)
    node:runAction(action)
    return action
end

function performWithDelay(node, callback, delay)
    local delay = CCDelayTime:create(delay)
    return runActionWithCallback(node, delay, callback)
end

function runActionWithCallback( node, action, callback )
    local callfunc = CCCallFunc:create(callback)
    local sequence = CCSequence:createWithTwoActions(action, callfunc)
    node:runAction(sequence)
    return sequence 
end

function split( str, reps)
    local resultStrsList = {}
    string.gsub(str, '[^' .. reps ..']+', function(w)
        table.insert(resultStrsList, w)
        end
    )
    return resultStrsList
end

-- 获取基类的某个方法
-- table C++类或者lua table
-- methodName 函数名，也可以是成员变量名
-- return 基类的函数或成员变量值（如果methodName为变量名）
--          nil 表示找不到
function getSuperMethod(table, methodName)
    local mt = getmetatable(table)
    local method = nil
    while mt and not method do
        method = mt[methodName]
        if not method then
            local index = mt.__index
            if index and type(index) == "function" then
                method = index(mt, methodName)
            elseif index and type(index) == "table" then
                method = index[methodName]
            end
        end
        mt = getmetatable(mt)
    end
    return method
end