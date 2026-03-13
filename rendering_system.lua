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
    local h_sh = 0
    for _, column in ipairs(tiles) do
        local v_sh = 0
        for _, value in ipairs(column) do
            local tile = TILESET[value]
            if tile then
                draw_tile(tile, h_sh + x, v_sh + y)
            end

            v_sh = v_sh + TILE_SIZE.h
        end
        h_sh = h_sh + TILE_SIZE.w
    end

    local link_y = y + #tiles[1] * TILE_SIZE.h + 10

    for direction, link in pairs(tilemap.links) do
        local block_tile = TILESET["BLOCK"]
        local diff = {}
        local shifts = {
            L= {-50, 0},
            R= {50 + (tilemap.w-1) * TILE_SIZE.w, 0},
            U= {0, -50},
            D= {0, 50 + (tilemap.h-1) * TILE_SIZE.h}
        }
        local shift = shifts[direction]

        if direction == "L" or  direction == "R" then
            diff = {0,1}
            len = tilemap.h
        else
            diff = {1,0}
            len = tilemap.w
        end

        if link.name == "BLOCK" then
            for i=0,len-1 do 
                draw_tile(
                    block_tile, 
                    x + diff[1] * i * TILE_SIZE.w + shift[1], 
                    y + diff[2] * i * TILE_SIZE.h + shift[2])
            end
        else
            side = get_side(TILEMAPS[link.name], link.side)
            i = 0
            for _,tile_name in pairs(side) do
                local tile = TILESET[tile_name] 
                draw_tile(
                    tile, 
                    x + diff[1] * i * TILE_SIZE.w + shift[1], 
                    y + diff[2] * i * TILE_SIZE.h + shift[2])
                i = i + 1
            end
        end
    end
end