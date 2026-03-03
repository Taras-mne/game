function love.load()
    require("drawing_board")
    require("click_UI_system")
    require("rendering_system")
    require("tiling_system")

    load_tilesets()

    tilemap = read_tilemap("demo_map.txt") 
    -- r_tilemap = rotate_tilemap(tilemap, ROTATION_MATRICES.QUARTER)
    -- upload_tilemap(tilemap)
    -- upload_tilemap(r_tilemap)
    
    create_palette_i(10, 10)
    create_tilemap_i(150, 10)
    
    love.window.setMode(1300, 800, {resizable=false, fullscreen=false, vsync=true})
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
