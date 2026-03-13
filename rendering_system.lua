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
        if link.name ~= "BLOCK" then
            love.graphics.print(direction .. ": " .. link.name .. "." .. link.side, x, link_y)
        else
            love.graphics.print(direction .. ": " .. link.name, x, link_y)
        end
        link_y = link_y + 20
    end
end