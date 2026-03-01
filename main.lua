function love.load()
    require("tiling_system")
    love.graphics.setFont(love.graphics.newFont(20))

    load_tilesets()

    tilemap = read_tilemap("name.txt") 
    r_tilemap = rotate_tilemap(tilemap, ROTATION_MATRICES.QUARTER)
    -- upload_tilemap(tilemap)
    -- upload_tilemap(r_tilemap)
end

function love.update(dt)
end

function love.draw()
    draw_tilemap(tilemap, 10, 10)
    -- draw_tilemap(r_tilemap, 400, 50)
end
