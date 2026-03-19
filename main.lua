function love.load()
    require("utils")
    require("drawing_board")
    require("click_UI_system")
    require("rendering_system")
    require("tiling_system")
    require("menu")

    load_tilesets()

    read_tilemap("shmol_sphere.txt")
    read_tilemap("shmol_tor.txt")
    read_tilemap("beeg.txt")

    local myFont = love.graphics.newFont("fonts/JacquardaBastarda9-Regular.ttf", 40) -- 24 - размер шрифта
    love.graphics.setFont(myFont)
    
    love.window.setMode(1300, 800, {resizable=true, fullscreen=false, vsync=true})

    -- drawing_board_setup()
    menu_setup()
end

function love.update(dt)
    -- in future there will b a global update name that will be changing as needed
    -- update_bucket()
    local x, y = love.mouse.getPosition()
    check_hover(x, y, love.mouse.isDown(1))
end

function love.draw()
    draw_all()
    -- draw_zones()
    -- PROJECTED_TILEMAP = TILEMAP
end

function love.mousepressed(x, y, button, is_touch)
    check_zones(x, y, button)
end

function love.resize(width, height)
    -- drawing_board_setup()
end