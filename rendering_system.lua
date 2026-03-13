DRAW_QUEUE = {}

function nuke_draw_queue()
    DRAW_QUEUE = {}
end

function draw_all()
    for key,call in pairs(DRAW_QUEUE) do
        call()
    end
end

function draw_call_add(call)
    table.insert(DRAW_QUEUE, call)
end

function draw_tile(tile, x, y)
    love.graphics.draw(TILE_ATLASES[tile.atlas], tile.quad, x, y)
end

function draw_tilemap(tilemap, x, y)
    local tiles = tilemap.tiles
    local v_sh = 0
    for _, column in ipairs(tiles) do
        local h_sh = 0
        for _, value in ipairs(column) do
            local tile = TILESET[value]
            if tile then
                draw_tile(tile, h_sh + x, v_sh + y)
            end

            h_sh = h_sh + TILE_SIZE.w
        end
        v_sh = v_sh + TILE_SIZE.h
    end

    local link_y = y + #tiles[1] * TILE_SIZE.h + 10

    for direction, link in pairs(tilemap.links) do
        local block_tile = TILESET["BLOCK"]
        if link.name == "BLOCK" then
            local line = {}
            local diff = {}
            local shifts = {
                L= {-50, 0},
                R= {50 + (tilemap.h-1) * TILE_SIZE.w, 0},
                U= {0, -50},
                D= {0, 50 + (tilemap.w-1) * TILE_SIZE.h}
            }
            if direction == "L" or  direction == "R" then
                diff = {0,1}
                len = tilemap.w
            else
                diff = {1,0}
                len = tilemap.h
            end
            for i=0,len-1 do 
                draw_tile(
                    block_tile, 
                    x + diff[1] * i * TILE_SIZE.w + shifts[direction][1], 
                    y + diff[2] * i * TILE_SIZE.h + shifts[direction][2])
            end
        end
    end
end