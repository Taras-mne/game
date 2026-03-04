MEMO = "A"

function window_setup()
    ZONES_OF_INTEREST = {}
    DRAW_QUEUE = {}
    create_palette_i(10, 10)
    create_tilemap_i(150, 10)
    buttons_bar_i(550, 10)
end

function buttons_bar_i(x, y)
    local padding = 5
    local margin = 10
    
    local rot_R = {
        x = x + padding,
        y = y + padding,
        w = TILE_SIZE.w,
        h = TILE_SIZE.h,
        tile = TILESET.Rot90cw
    }
    local rot_L = {
        x = x + rot_R.w + margin + padding,
        y = y + padding,
        w = TILE_SIZE.w,
        h = TILE_SIZE.h,
        tile = TILESET.Rot90ccw
    }
    local rect = {
        x = x,
        y = y,
        w = TILE_SIZE.w * 2 + margin + padding * 2,
        h = TILE_SIZE.h + padding * 2,
    }

    create_zone(
        rot_R.x, rot_R.y, 
        rot_R.w, rot_R.h, 
        function()
            tilemap = rotate_tilemap(tilemap, ROTATION_MATRICES.THREE_QUARTERS)
            window_setup()
        end,
        "rot_R"
    )
    create_zone(
        rot_L.x, rot_L.y, 
        rot_L.w, rot_L.h,
        function()
            tilemap = rotate_tilemap(tilemap, ROTATION_MATRICES.QUARTER)
            window_setup()
        end,
        "rot_L"
    )

    draw_call_add(function()
        love.graphics.setColor(1, 0.5, 0, 1)
        love.graphics.rectangle("fill", 
            rect.x, rect.y, 
            rect.w, rect.h
        )
        love.graphics.setColor(1, 1, 1, 1)
        draw_tile(rot_R.tile, rot_R.x, rot_R.y)
        draw_tile(rot_L.tile, rot_L.x, rot_L.y)
    end)
end

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