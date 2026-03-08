function love.load()
    require("drawing_board")
    require("click_UI_system")
    require("rendering_system")
    require("tiling_system")

    load_tilesets()

    TILEMAP = read_tilemap("beeg.txt")
    --needed projecting without destroying TILEMAP
    --is cloned when needed
    PROJECTED_TILEMAP = TILEMAP
    
    love.window.setMode(1300, 800, {resizable=true, fullscreen=false, vsync=true})

    drawing_board_setup()
end

function love.update(dt)
    local x, y = love.mouse.getPosition()
    check_hover(x, y, love.mouse.isDown(1))
end

function love.draw()
    draw_all()
    -- draw_zones()
    PROJECTED_TILEMAP = TILEMAP
end

function love.mousepressed(x, y, button, istouch)
    check_zones(x, y, button)
end

function love.resize(width, height)
    drawing_board_setup()
end