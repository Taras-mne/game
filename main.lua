function love.load()
    require("click_UI_system")
    require("rendering_system")
    require("tiling_system")

    load_tilesets()

    tilemap = read_tilemap("demo_map.txt") 
    r_tilemap = rotate_tilemap(tilemap, ROTATION_MATRICES.QUARTER)
    -- upload_tilemap(tilemap)
    -- upload_tilemap(r_tilemap)
    
    create_zone(
        10, 10, 
        70, 70, 
        function() 
            love.graphics.setColor(1, 0, 0, 1) 
        end
    )

    create_zone(
        100, 10, 
        70, 70, 
        function() 
            love.graphics.setColor(0, 1, 0, 1) 
        end
    )

    create_zone(
        200, 10, 
        70, 70, 
        function() 
            love.graphics.setColor(0, 0, 1, 1) 
        end
    )

    create_zone(
        300, 10, 
        70, 70, 
        function() 
            love.graphics.setColor(1, 1, 1, 1) 
        end
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
