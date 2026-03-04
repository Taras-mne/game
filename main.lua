function love.load()
    require("drawing_board")
    require("click_UI_system")
    require("rendering_system")
    require("tiling_system")

    load_tilesets()

    tilemap = read_tilemap("demo_map.txt")
    
    window_setup()
    
    love.window.setMode(1300, 800, {resizable=true, fullscreen=false, vsync=true})
end

function love.update(dt)
end

function love.draw()
    draw_all()
    -- draw_zones()
end

function love.mousepressed(x, y, button, istouch)
    check_zones(x, y, button)
end
