NEW_ID = 0
UPDATES = {}

function create_update(update_call, update_setup, destruction_check)
    assert(is_function(update_call), "update_call is not a function")
    assert(is_function(update_setup), "update_setup is not a function")
    assert(is_function(destruction_check), "destruction_check is not a function") 

    local key = "_" .. NEW_ID
    NEW_ID = NEW_ID + 1

    local update_struct = {
        key = key,
        dead = destruction_check,
        _call = update_call,
        call = function(self, dt)
            if self:dead() then
                UPDATES[self.key] = nil
                return
            end
            self:_call(dt)
        end,
    }

    update_setup(update_struct)
    if not update_struct:dead() then 
        UPDATES[key] = update_struct
    end
    return key
end

function delete_update(key)
    UPDATES[key] = nil
end

function trigger_updates(dt)
    for key, update in pairs(UPDATES) do
        update:call(dt)
    end 
end

function animate_numeric_attribute(table, key, target, epsilon)
    return create_update(
        function(_self, dt)
            table[key] = table[key] + ((_self.target[key] - table[key])/5) * (dt*30) 
            --30 fps is the reference point 4 a single frame. in reality 4 me it's 144 fps
        end, 
        function(_self)
            _self.target = target
        end, 
        function(_self)
            if math.abs(_self.target[key] - table[key]) > epsilon then
                return false
            end 
            table[key] = _self.target[key]
            return true
        end
    )
end

function animate_numeric_attributes(table, keys, target, epsilons)
    return create_update(
        function(_self, dt)
            for _,key in ipairs(keys) do
                table[key] = table[key] + ((_self.target[key] - table[key])/5) * (dt*30) 
            end
            --30 fps is the reference point 4 a single frame. in reality 4 me it's 144 fps
        end, 
        function(_self)
            _self.target = target
        end, 
        function(_self)
            for _,key in ipairs(keys) do
                if math.abs(_self.target[key] - table[key]) > epsilons[key] then
                    return false
                end 
                table[key] = _self.target[key]
            end
            return true
        end
    )
end

function animate_color(table, key, target, epsilon)
    return create_update(
        function(_self, dt)
            --30 fps is the reference point 4 a single frame. in reality 4 me it's 144 fps
            for i=1,4 do
                table[key][i] = table[key][i] + ((_self.target[key][i] - table[key][i])/5) * (dt*30) 
            end
        end, 
        function(_self)
            _self.target = {}
            _self.target[key] = target
        end, 
        function(_self)
            for i=1,4 do
                if math.abs(_self.target[key][i] - table[key][i]) > epsilon then
                    return false
                end 
            end
            table[key] = _self.target[key]
            return true
        end
    )
end

function sleep_then_do(time, callback)
    return create_update(
        function(_self, dt)
            _self.time = _self.time - dt
        end, 
        function(_self)
            _self.time = time
            _self.callback = callback
        end, 
        function(_self)
            if _self.time <= 0 then
                _self.callback()
                return true
            end 
            return false
        end
    )
end

function debug_output(x, y)
    draw_call_add(function()
        s = ""
        s = s .. SECONDS .. "\n"
        for key,_ in pairs(UPDATES) do
            s = s .. key .. "\n"
        end
        love.graphics.print(s,x,y)
    end)
end