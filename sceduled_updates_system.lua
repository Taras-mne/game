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
        call = function(self)
            if self:dead() then
                UPDATES[self.key] = nil
                return
            end
            self:_call()
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

function trigger_updates()
    for key, update in pairs(UPDATES) do
        update:call()
    end 
end