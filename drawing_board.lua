MEMO = "A"

function create_tilemap_i(x, y)
    local tiles = tilemap.tiles --!tilemap is a global name!
    local v_sh = 0
    for i, column in ipairs(tiles) do
        local h_sh = 0
        for j, value in ipairs(column) do
            create_zone(
                x + h_sh + 1, y + v_sh + 1, 
                TILE_SIZE.w-2, TILE_SIZE.h-2, 
                function()
                    tilemap.tiles[i][j] = MEMO
                end,
                tilemap.name .. "_" .. i .. "_" .. j
            )

            h_sh = h_sh + TILE_SIZE.w
        end
        v_sh = v_sh + TILE_SIZE.h
    end
    draw_call_add(function() 
        draw_tilemap(tilemap, x, y) --!tilemap is a global name! 
    end)
end

function create_palette_i(x, y)
    local where = {x = x, y = y}

    for key,tile in pairs(TILESET) do
        create_zone(
            where.x, where.y, 
            TILE_SIZE.w, TILE_SIZE.h, 
            function() MEMO = key end, 
            name
        )
        where.y = where.y + 40
    end

    draw_call_add(function() draw_palette(x, y) end)
end

function draw_palette(x, y)
    local where = {x = x, y = y}
    draw_tile(TILESET[MEMO], where.x + 40, where.y)
    for key,tile in pairs(TILESET) do
        draw_tile(tile, where.x, where.y)
        where.y = where.y + 40
    end
end