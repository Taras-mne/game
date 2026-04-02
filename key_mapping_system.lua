KEYS_CALLBACKS = {}

function add_key_callback(key, call)
    KEYS_CALLBACKS[key] = call
end

function love.keypressed(key, scancode, isrepeat)
    if KEYS_CALLBACKS[key] then
        KEYS_CALLBACKS[key](key, scancode, isrepeat)
    end
end