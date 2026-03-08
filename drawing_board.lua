DRAWING_STATE = {
    tile= "Water"
}

function drawing_board_setup()
    nuke_zones()
    nuke_draw_queue()
    local screen_width, screen_height = love.window.getMode()
    palette_i(10, 10)
    tilemap_i(120, 10)
    buttons_bar_i(screen_width - 100, 10)
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
    local save = {
        x = x + (rot_R.w + margin)/2 + padding,
        y = y + rot_R.w + margin + padding,
        w = TILE_SIZE.w,
        h = TILE_SIZE.h,
        tile = TILESET.Save
    }
    local rect = {
        x = x,
        y = y,
        w = TILE_SIZE.w * 2 + margin + padding * 2,
        h = TILE_SIZE.w * 2 + margin + padding * 2,
    }

    create_zone(
        rot_R.x, rot_R.y, 
        rot_R.w, rot_R.h, 
        function()
            TILEMAP = rotate_tilemap(TILEMAP, ROTATION_MATRICES.THREE_QUARTERS)
            drawing_board_setup()
        end
    )
    create_zone(
        rot_L.x, rot_L.y, 
        rot_L.w, rot_L.h,
        function()
            TILEMAP = rotate_tilemap(TILEMAP, ROTATION_MATRICES.QUARTER)
            drawing_board_setup()
        end
    )
    create_zone(
        save.x, save.y, 
        save.w, save.h, 
        function()
            upload_tilemap(TILEMAP)
            --TODO - draw a popup 
        end
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
        draw_tile(save.tile, save.x, save.y)
    end)
end

function tilemap_i(x, y)
    local tiles = TILEMAP.tiles
    local v_sh = 0
    for i, column in ipairs(tiles) do
        local h_sh = 0
        for j, value in ipairs(column) do
            create_zone(
                x + h_sh + 1, y + v_sh + 1, 
                TILE_SIZE.w-2, TILE_SIZE.h-2, 
                function()
                    TILEMAP.tiles[i][j] = DRAWING_STATE.tile
                end,
                function(isDown)
                    if isDown then
                        TILEMAP.tiles[i][j] = DRAWING_STATE.tile
                    end
                end
            )

            h_sh = h_sh + TILE_SIZE.w
        end
        v_sh = v_sh + TILE_SIZE.h
    end
    draw_call_add(function() 
        draw_tilemap(TILEMAP, x, y)
    end)
end

function palette_i(x, y)
    local padding = 5
    local margin = 10
    local where = {x = x + padding, y = y + padding}
    local count = 0

    for key,tile in pairs(TILESET) do
        create_zone(
            where.x, where.y, 
            TILE_SIZE.w, TILE_SIZE.h, 
            function() DRAWING_STATE.tile = key end
        )
        where.y = where.y + TILE_SIZE.h + margin
        count = count + 1
    end

    local rect = {
        x = x,
        y = y,
        w = TILE_SIZE.w * 2 + margin + padding * 2,
        h = TILE_SIZE.w * count + margin * (count-1) + padding * 2,
    }

    draw_call_add(function() 
        local where = {x = x + padding, y = y + padding}
        love.graphics.setColor(0.33, 0.33, 0.33, 1)
        love.graphics.rectangle("fill", 
            rect.x, rect.y, 
            rect.w, rect.h
        )
        love.graphics.setColor(1, 1, 1, 1)
        draw_tile(TILESET[DRAWING_STATE.tile], where.x + TILE_SIZE.w + margin, where.y)
        for key,tile in pairs(TILESET) do
            draw_tile(tile, where.x, where.y)
            where.y = where.y + TILE_SIZE.h + margin
        end
    end)
end