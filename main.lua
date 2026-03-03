function love.load()
    require("click_UI_system")
    require("rendering_system")
    require("tiling_system")

    load_tilesets()

    tilemap = read_tilemap("demo_map.txt") 
    -- r_tilemap = rotate_tilemap(tilemap, ROTATION_MATRICES.QUARTER)
    -- upload_tilemap(tilemap)
    -- upload_tilemap(r_tilemap)
    
    create_zone(
        10, 10, 
        70, 70, 
        function() 
            tilemap = rotate_tilemap(tilemap, ROTATION_MATRICES.THREE_QUARTERS)
        end, "turn_left"
    )

    create_zone(
        110, 10, 
        70, 70, 
        function() 
            tilemap = rotate_tilemap(tilemap, ROTATION_MATRICES.QUARTER)
        end, "turn_right"
    )
    
    love.window.setMode(1300, 800, {resizable=false, fullscreen=false, vsync=true})
end

function love.update(dt)
end

function love.draw()
    draw_tilemap(tilemap, 60, 100)
    -- draw_tilemap(r_tilemap, 10, 10)
    draw_zones()
end

function love.mousepressed(x, y, button, istouch)
    check_zones(x, y, button)
end
