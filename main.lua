function love.load()
    require("utils")
    require("drawing_board")
    require("rendering_system")
    require("tiling_system")
    require("buttons_system")
    require("sceduled_updates_system")

    load_tilesets()

    read_tilemap("shmol_sphere.txt")
    read_tilemap("shmol_tor.txt")
    TILEMAP = read_tilemap("beeg.txt")

    local myFont = love.graphics.newFont("fonts/JacquardaBastarda9-Regular.ttf", 40) -- 24 - размер шрифта
    love.graphics.setFont(myFont)
    
    love.window.setMode(1300, 800, {resizable=true, fullscreen=false, vsync=true})

    -- drawing_board_setup()
    menu_setup()
end

function love.update(dt)
    update_bucket()
    trigger_updates()
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
    drawing_board_setup()
end