NEW_ID = 0
UPDATES = {}

function create_update(
    update_call, 
    update_setup,
    destruction_check
)
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
    if update_struct:dead() then 
        return
    end
    UPDATES[key] = update_struct
end

function trigger_updates()
    for key,update in pairs(UPDATES) do
        update:call()
    end 
end