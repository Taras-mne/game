DRAWING_STATE = {
    tile= "Water",
    tool= "Pen",
}

TOOLS = { --TODO: repopulate with tiles when loading
    "Pen",
    "Line",
    "Rect",
    "Bucket",
}

function drawing_board_setup()
    nuke_zones()
    nuke_draw_queue()
    local screen_width, screen_height = love.window.getMode()
    palette_i(10, 10)
    tilemap_i(round(screen_width/3), round(screen_height/4))
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

function do_pen(i,j,tilemap)
    tilemap.tiles[i][j] = DRAWING_STATE.tile
end

function do_line(i,j,tilemap,hard)
    if DRAWING_STATE.memo == nil then
        if hard then 
            DRAWING_STATE.memo = {i,j}
        end
    else
        local current_pos = {i,j}
        tilemap.tiles[current_pos[1]][current_pos[2]] = DRAWING_STATE.tile
        tilemap.tiles[DRAWING_STATE.memo[1]][DRAWING_STATE.memo[2]] = DRAWING_STATE.tile
        
        local current_pos_r = {i,j}
        local vec = normalize(sum(neg(current_pos), DRAWING_STATE.memo))
        while current_pos_r[1] ~= DRAWING_STATE.memo[1] 
        or current_pos_r[2] ~= DRAWING_STATE.memo[2] do
            current_pos = sum(current_pos, vec)
            current_pos_r = {round(current_pos[1]), round(current_pos[2])}
            tilemap.tiles[current_pos_r[1]][current_pos_r[2]] = DRAWING_STATE.tile
        end

        if hard then 
            DRAWING_STATE.memo = nil
        end
    end
end

function do_rect(i,j,tilemap,hard)
    if DRAWING_STATE.memo == nil then
        if hard then 
            DRAWING_STATE.memo = {i,j}
        end
    else
        for ii=math.min(i,DRAWING_STATE.memo[1]), math.max(i,DRAWING_STATE.memo[1]) do
            for jj=math.min(j,DRAWING_STATE.memo[2]), math.max(j,DRAWING_STATE.memo[2]) do
                tilemap.tiles[ii][jj] = DRAWING_STATE.tile
            end
        end
        if hard then 
            DRAWING_STATE.memo = nil
        end
    end
end

function update_bucket()
    if DRAWING_STATE.tool ~= "Bucket" or DRAWING_STATE.memo == nil then
        return
    end
    
    local memo = DRAWING_STATE.memo
    local seeds = memo.seeds
    if not seeds or #seeds == 0 then
        DRAWING_STATE.memo = nil
        return
    end
    
    local new_seeds = {}
    local memo_tile = memo.tile

    function try_add(nx, ny)
        local key = tostring(nx) .. "," .. tostring(ny)
        if nx > 0 and nx <= TILEMAP.w 
        and ny > 0 and ny <= TILEMAP.h
        and TILEMAP.tiles[nx][ny] == memo_tile then
            table.insert(new_seeds, {nx, ny})
        end
    end
    
    for i = 1, #seeds do
        local seed = seeds[i]
        if seed and seed[1] and seed[2] then
            local x, y = seed[1], seed[2]
            if TILEMAP.tiles[x][y] == DRAWING_STATE.tile then
                goto continue
            end
            TILEMAP.tiles[x][y] = DRAWING_STATE.tile

            try_add(x + 1, y)
            try_add(x - 1, y)
            try_add(x, y - 1)
            try_add(x, y + 1)
            ::continue::
        end
    end

    if #new_seeds == 0 then
        DRAWING_STATE.memo = nil
        return
    end

    DRAWING_STATE.memo.seeds = new_seeds
end

function do_bucket(i,j,tilemap)
    if tilemap.tiles[i][j] == DRAWING_STATE.tile then 
        return 
    end
    DRAWING_STATE.memo = {
        tile= tilemap.tiles[i][j],
        seeds = {{i,j},},
    }
end

function get_cell_click_and_hover(i,j)
    if DRAWING_STATE.tool == "Pen" then
        return --returns two functions
        function()
            do_pen(i,j,TILEMAP)
        end,
        function(isDown)
            PROJECTED_TILEMAP = clone_tilemap(TILEMAP)
            if isDown then
                do_pen(i,j,TILEMAP)
            else
                do_pen(i,j,PROJECTED_TILEMAP)
            end
        end
    elseif DRAWING_STATE.tool == "Line" then
        return
        function()
            do_line(i,j,TILEMAP,true)
        end,
        function(isDown)
            PROJECTED_TILEMAP = clone_tilemap(TILEMAP)
            do_line(i,j,PROJECTED_TILEMAP)
            do_pen(i,j,PROJECTED_TILEMAP)
        end
    elseif DRAWING_STATE.tool == "Rect" then
        return
        function()
            do_rect(i,j,TILEMAP,true)
        end,
        function(isDown)
            PROJECTED_TILEMAP = clone_tilemap(TILEMAP)
            do_pen(i,j,PROJECTED_TILEMAP)
            do_rect(i,j,PROJECTED_TILEMAP)
        end
    elseif DRAWING_STATE.tool == "Bucket" then
        return
        function()
            do_bucket(i,j,TILEMAP)
        end,
        function(isDown)
            PROJECTED_TILEMAP = clone_tilemap(TILEMAP)
            do_pen(i,j,PROJECTED_TILEMAP)
        end
    end
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
                get_cell_click_and_hover(i,j)
            )

            h_sh = h_sh + TILE_SIZE.w
        end
        v_sh = v_sh + TILE_SIZE.h
    end
    draw_call_add(function() 
        draw_tilemap(PROJECTED_TILEMAP, x, y)
    end)
end

function palette_i(x, y)
    local padding = 5
    local margin = 10
    local where = {x = x + padding, y = y + padding}
    local count = 0
    local tiles_todraw = {}

    for key,tile in pairs(TILESET) do
        if isInTable(RESERVED_TILES, key) then
            goto continue
        end
        create_zone(
            where.x, where.y, 
            TILE_SIZE.w, TILE_SIZE.h, 
            function() 
                DRAWING_STATE.tile = key 
            end
        )
        table.insert(tiles_todraw, key)
        where.y = where.y + TILE_SIZE.h + margin
        count = count + 1
        ::continue::
    end

    local where = {x = x + padding + TILE_SIZE.w + margin, y = y + padding}
    for key,tool in pairs(TOOLS) do
        where.y = where.y + TILE_SIZE.h + margin
        create_zone(
            where.x, where.y, 
            TILE_SIZE.w, TILE_SIZE.h, 
            function() 
                DRAWING_STATE.tool = tool
                DRAWING_STATE.memo = nil
                drawing_board_setup() 
            end
        )
    end

    local rects = {
        {
            x = x,
            y = y,
            w = TILE_SIZE.w + padding * 2,
            h = TILE_SIZE.w * count + margin * (count-1) + padding * 2,
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

    draw_call_add(function() 
        for i,rect in ipairs(rects) do
            love.graphics.setColor(unpack(rect.color))
            love.graphics.rectangle("fill", 
                rect.x, rect.y, 
                rect.w, rect.h
            )
        end
        love.graphics.setColor(1, 1, 1, 1)
        local where = {x = x + padding, y = y + padding}
        for _,key in pairs(tiles_todraw) do
            draw_tile(TILESET[key], where.x, where.y)
            where.y = where.y + TILE_SIZE.h + margin
        end
        local where = {x = x + padding + TILE_SIZE.w + margin, y = y + padding}
        draw_tile(TILESET[DRAWING_STATE.tile], where.x, where.y)
        for key,tool in pairs(TOOLS) do
            where.y = where.y + TILE_SIZE.h + margin
            if DRAWING_STATE.tool == tool then
                love.graphics.rectangle("fill", 
                    where.x - 2, where.y - 2, 
                    TILE_SIZE.w + 4, TILE_SIZE.h + 4
                ) 
            end
            tile = TILESET[tool]
            draw_tile(tile, where.x, where.y)
        end
    end)
end