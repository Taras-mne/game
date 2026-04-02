function love.load()
    require("utils")
    require("rendering_system")
    require("tiling_system")
    require("buttons_system")
    require("sceduled_updates_system")
    require("key_mapping_system")
    require("gameplay_system")
    require("example_menu")
    require("drawing_board")

    load_tilesets()

    -- read_tilemap("shmol_sphere.txt")
    -- read_tilemap("shmol_tor.txt")
    read_tilemap("beeg.txt")
    read_tilemap("weird.txt")
    
    read_tilemap("gemini_1.txt")
    read_tilemap("gemini_2.txt")

    local myFont = love.graphics.newFont("fonts/JacquardaBastarda9-Regular.ttf", 40) -- 24 - размер шрифта
    love.graphics.setFont(myFont)
    
    love.window.setMode(1300, 800, {resizable=true, fullscreen=false, vsync=true})

    add_key_callback("escape", function()
        love.event.quit()
    end)
    
    gameplay_setup(TILEMAPS.beeg, player_init(3,3))
end

SECONDS = 0

function love.update(dt)
    SECONDS = SECONDS + dt
    trigger_updates(dt)
    -- update_bucket()
    local x, y = love.mouse.getPosition()
    hover_buttons(x, y, love.mouse.isDown(1))
end

function love.draw()
    draw_all()
    PROJECTED_TILEMAP = TILEMAP
end

function love.mousepressed(x, y, button, is_touch)
    click_buttons(x, y, button)
end

function love.resize(width, height)
    -- drawing_board_setup()
end