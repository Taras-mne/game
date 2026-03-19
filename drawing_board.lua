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
    tilemap_i(200, 75)
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

function do_pen(i,j,tilemap,hard)
    tilemap.tiles[i][j] = DRAWING_STATE.tile
    if hard and tilemap.is_clone then
        local original = TILEMAPS[tilemap.name] 
        assert(not original.is_clone, "original is a clone 4 some reson")
        local rot_deg = normilize_deg(-tilemap.rotation_deg)
        local rot_m = ROTATION_MATRICES[DEG_TO_NAMES[rot_deg]]
        point = sizeful_transform_point(
            {x=i, y=j}, 
            extract_size(tilemap), 
            extract_size(original), 
            rot_m
        )
        do_pen(point.x, point.y, original, hard)
    end
end

function plot_line(p1, p2, tilemap)
    local p_diff = sum_points(p1, neg_point(p2))
    local diff = {} 
    if (math.abs(p_diff.x) < 2) and (math.abs(p_diff.y) < 2) then
        tilemap.tiles[p1.x][p1.y] = DRAWING_STATE.tile
        tilemap.tiles[p2.x][p2.y] = DRAWING_STATE.tile
        return
    elseif math.abs(p_diff.x) < 2 then
        diff = {x= 0, y= -1}
        limit = math.abs(p_diff.y)
    elseif math.abs(p_diff.y) < 2 then
        diff = {x= -1, y= 0}
        limit = math.abs(p_diff.x)
    else 
        diff = {x= -1, y= -1}
        limit = math.min(math.abs(p_diff.x), math.abs(p_diff.y))
    end
    diff.x = diff.x * sign(p_diff.x)
    diff.y = diff.y * sign(p_diff.y)
    
    tilemap.tiles[p1.x][p1.y] = DRAWING_STATE.tile
    for i=1,limit do
        p1 = sum_points(p1, diff)
        tilemap.tiles[p1.x][p1.y] = DRAWING_STATE.tile
    end
end

function do_line(i, j, tilemap, hard)
    if DRAWING_STATE.memo == nil then
        if hard then 
            DRAWING_STATE.memo = {x= i, y= j}
        end
        return
    end

    local click_point = {x= i, y= j}
    local memo_point = DRAWING_STATE.memo

    plot_line(memo_point, click_point, tilemap)

    if hard then 
        local original = TILEMAPS[tilemap.name] 
        assert(not original.is_clone, "original is a clone 4 some reson")
        local rot_deg = normilize_deg(-tilemap.rotation_deg)
        local rot_m = ROTATION_MATRICES[DEG_TO_NAMES[rot_deg]]

        click_point = sizeful_transform_point(
            click_point, 
            extract_size(tilemap), 
            extract_size(original), 
            rot_m
        )
        memo_point = sizeful_transform_point(
            memo_point, 
            extract_size(tilemap), 
            extract_size(original), 
            rot_m
        )

        plot_line(memo_point, click_point, original)

        DRAWING_STATE.memo = nil
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

function get_cell_click_and_hover(dx,dy)
    function get_ij(x,y)
        local i = math.floor((x-dx)/TILE_SIZE.w) + 1
        local j = math.floor((y-dy)/TILE_SIZE.h) + 1
        return i,j
    end

    if DRAWING_STATE.tool == "Pen" then
        return --returns two functions
        function(x,y)
            local i,j = get_ij(x,y)
            do_pen(i,j,TILEMAP,true)
        end,
        function(x,y,is_down)
            local i,j = get_ij(x,y)
            PROJECTED_TILEMAP = clone_tilemap(TILEMAP)
            if is_down then
                do_pen(i,j,TILEMAP,true)
            else
                do_pen(i,j,PROJECTED_TILEMAP)
            end
        end
    elseif DRAWING_STATE.tool == "Line" then
        return
        function(x,y)
            local i,j = get_ij(x,y)
            do_line(i,j,TILEMAP,true)
        end,
        function(x,y,is_down)
            local i,j = get_ij(x,y)
            PROJECTED_TILEMAP = clone_tilemap(TILEMAP)
            do_line(i,j,PROJECTED_TILEMAP)
            do_pen(i,j,PROJECTED_TILEMAP)
        end
    elseif DRAWING_STATE.tool == "Rect" then
        return
        function(x,y)
            local i,j = get_ij(x,y)
            do_rect(i,j,TILEMAP,true)
        end,
        function(x,y,is_down)
            local i,j = get_ij(x,y)
            PROJECTED_TILEMAP = clone_tilemap(TILEMAP)
            do_pen(i,j,PROJECTED_TILEMAP)
            do_rect(i,j,PROJECTED_TILEMAP)
        end
    elseif DRAWING_STATE.tool == "Bucket" then
        return
        function(x,y)
            local i,j = get_ij(x,y)
            do_bucket(i,j,TILEMAP)
        end,
        function(x,y,is_down)
            local i,j = get_ij(x,y)
            PROJECTED_TILEMAP = clone_tilemap(TILEMAP)
            do_pen(i,j,PROJECTED_TILEMAP)
        end
    end
end

function tilemap_i(x, y)
    local tiles = TILEMAP.tiles
    local h_sh = 0

    create_zone(
        x, y, 
        (TILE_SIZE.w * TILEMAP.w)-1, (TILE_SIZE.h * TILEMAP.h)-1, 
        get_cell_click_and_hover(x, y)
    )
    
    draw_call_add(function() 
        draw_tilemap(PROJECTED_TILEMAP, x, y)
    end)
end

function palette_i(x, y)
    local padding = 5
    local margin = 10
    local where = {x = x + padding, y = y + padding}
    local tiles_todraw = {}

    for key,tile in pairs(TILESET) do
        if is_in_table(RESERVED_TILES, key) then
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

    draw_call_add(function() 
        draw_palette(x, y, padding, margin, tiles_todraw)
    end)
end