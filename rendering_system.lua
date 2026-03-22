DRAW_QUEUE = {}

function nuke_draw_queue()
    DRAW_QUEUE = {}
end

function draw_all()
    for i,call in ipairs(DRAW_QUEUE) do
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
    local no_tile = TILESET.NoTile
    for _, column in ipairs(tiles) do
        local v_sh = 0
        for _, value in ipairs(column) do
            local tile = TILESET[value]
            if tile then
                draw_tile(tile, h_sh + x, v_sh + y)
            else
                draw_tile(no_tile, h_sh + x, v_sh + y)
            end

            v_sh = v_sh + TILE_SIZE.h
        end
        h_sh = h_sh + TILE_SIZE.w
    end

    local shifts = {
        L= {-50, 0, diff= {0,1}, len= tilemap.h},
        R= {50 + (tilemap.w-1) * TILE_SIZE.w, 0, diff= {0,1}, len= tilemap.h},
        U= {0, -50, diff= {1,0}, len= tilemap.w},
        D= {0, 50 + (tilemap.h-1) * TILE_SIZE.h, diff= {1,0}, len= tilemap.w}
    }
    
    for direction, link in pairs(tilemap.links) do
        local block_tile = TILESET["BLOCK"]
        local shift = shifts[direction]
        local other_tilemap = {}
        if link.name == tilemap.name then
            if tilemap.rotation_deg == 0 then
                other_tilemap = tilemap
            else 
                local deg = normalize_deg(-tilemap.rotation_deg)
                other_tilemap = rotate_tilemap(
                    tilemap, 
                    ROTATION_MATRICES[DEG_TO_NAMES[deg]]
                )
            end
        else
            other_tilemap = TILEMAPS[link.name]
        end

        if link.name == "BLOCK" then
            for i=0,shift.len-1 do 
                draw_tile(
                    block_tile, 
                    x + shift.diff[1] * i * TILE_SIZE.w + shift[1], 
                    y + shift.diff[2] * i * TILE_SIZE.h + shift[2])
            end
            goto continue
        end
        local side = get_side(
            other_tilemap, link.side, 
            flipped_check(direction, link.side))
        local i = 0
        for _,tile_name in pairs(side) do
            local tile = TILESET[tile_name] 
            draw_tile(
                tile, 
                x + shift.diff[1] * i * TILE_SIZE.w + shift[1], 
                y + shift.diff[2] * i * TILE_SIZE.h + shift[2])
            i = i + 1
        end
        ::continue::
    end
end

function draw_palette(x, y, padding, margin, tiles_count) 
    local rects = {
        {
            x = x,
            y = y,
            w = TILE_SIZE.w + padding * 2,
            h = TILE_SIZE.w * tiles_count + margin * (tiles_count-1) + padding * 2,
            color = {0.15, 0.15, 0.75, 1}
        },
        {
            x = x + TILE_SIZE.w + padding * 2,
            y = y,
            w = TILE_SIZE.w + padding * 2,
            h = TILE_SIZE.h + padding * 2,
            color = {1, 0.5, 0.5, 1}
        },
        {
            x = x + TILE_SIZE.w + padding * 2,
            y = y + TILE_SIZE.h + padding * 2,
            w = TILE_SIZE.w + padding * 2,
            h = TILE_SIZE.w * 4 + margin * 3 + padding * 2,
            color = {0.1, 0.4, 0.2, 1}
        },
    }

    for i,rect in ipairs(rects) do
        love.graphics.setColor(unpack(rect.color))
        love.graphics.rectangle("fill", 
            rect.x, rect.y, 
            rect.w, rect.h
        )
    end
    love.graphics.setColor(1, 1, 1, 1)
    
    local where = {x = x + padding + TILE_SIZE.w + margin, y = y + padding}
    draw_tile(TILESET[DRAWING_STATE.tile], where.x, where.y)
end