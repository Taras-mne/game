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

function drawing_board_setup(tilemap_key)
    if tilemap_key ~= nil then
        DRAWING_STATE.tilemap_key = tilemap_key
        TILEMAP = clone_tilemap(TILEMAPS[DRAWING_STATE.tilemap_key])
        TILEMAP.is_clone = false
        TILEMAPS_CLONES[DRAWING_STATE.tilemap_key] = TILEMAP
    end
    PROJECTED_TILEMAP = TILEMAP
    nuke_buttons()
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
        y = y + TILE_SIZE.w + margin + padding,
        w = TILE_SIZE.w,
        h = TILE_SIZE.h,
        tile = TILESET.Rot90cw
    }
    local rot_L = {
        x = x + TILE_SIZE.w + margin + padding,
        y = y + TILE_SIZE.w + margin + padding,
        w = TILE_SIZE.w,
        h = TILE_SIZE.h,
        tile = TILESET.Rot90ccw
    }
    local save = {
        x = x + padding,
        y = y + padding,
        w = TILE_SIZE.w,
        h = TILE_SIZE.h,
        tile = TILESET.Save
    }
    local quit = {
        x = x + TILE_SIZE.w + margin + padding,
        y = y + padding,
        w = TILE_SIZE.w,
        h = TILE_SIZE.h,
        tile = TILESET.BLOCK
    }

    local rect = {
        x = x,
        y = y,
        w = TILE_SIZE.w * 2 + margin + padding * 2,
        h = TILE_SIZE.h * 2 + margin + padding * 2,
    }

    -- Queue the background first so buttons draw on top of it
    draw_call_add(function()
        love.graphics.setColor(1, 0.5, 0, 1)
        love.graphics.rectangle("fill", 
            rect.x, rect.y, 
            rect.w, rect.h
        )
        love.graphics.setColor(1, 1, 1, 1)
    end)

    local btn_rot_r = transparent_button_setup(
        rot_R.x, rot_R.y, 
        rot_R.w, rot_R.h, 
        function()
            TILEMAP = rotate_tilemap(TILEMAP, ROTATION_MATRICES.THREE_QUARTERS)
            drawing_board_setup()
        end
    )
    icon_setup(btn_rot_r, 0, 0, rot_R.tile)
    
    local btn_rot_l = transparent_button_setup(
        rot_L.x, rot_L.y, 
        rot_L.w, rot_L.h,
        function()
            TILEMAP = rotate_tilemap(TILEMAP, ROTATION_MATRICES.QUARTER)
            drawing_board_setup()
        end
    )
    icon_setup(btn_rot_l, 0, 0, rot_L.tile)
    
    local btn_save = transparent_button_setup(
        save.x, save.y, 
        save.w, save.h, 
        function()
            apply_tilemap_rotation(TILEMAP)
            TILEMAPS_CLONES[DRAWING_STATE.tilemap_key] = TILEMAP 
            upload_tilemap(TILEMAPS_CLONES[DRAWING_STATE.tilemap_key])
            TILEMAPS[DRAWING_STATE.tilemap_key] = TILEMAPS_CLONES[DRAWING_STATE.tilemap_key]
            --TODO - draw a popup 
        end
    )
    icon_setup(btn_save, 0, 0, save.tile)

    local btn_quit = transparent_button_setup(
        quit.x, quit.y, 
        quit.w, quit.h, 
        function()
            menu_setup() 
        end
    )
    icon_setup(btn_quit, 0, 0, quit.tile)
end

function do_pen(i,j,tilemap,hard)
    tilemap.tiles[i][j] = DRAWING_STATE.tile
    if hard and tilemap.is_clone then
        local original = TILEMAPS_CLONES[tilemap.name] 
        assert(not original.is_clone, "original is a clone 4 some reson")
        local rot_deg = normalize_deg(-tilemap.rotation_deg)
        local rot_m = ROTATION_MATRICES[DEG_TO_NAMES[rot_deg]]
        local point = sizeful_transform_point(
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
    local limit = 0 
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
        local original = TILEMAPS_CLONES[tilemap.name] 
        assert(not original.is_clone, "original is a clone 4 some reson")
        local rot_deg = normalize_deg(-tilemap.rotation_deg)
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

function plot_rect(p1, p2, tilemap)
    for i=math.min(p2.x,p1.x), math.max(p2.x,p1.x) do
        for j=math.min(p2.y,p1.y), math.max(p2.y,p1.y) do
            tilemap.tiles[i][j] = DRAWING_STATE.tile
        end
    end
end

function do_rect(i,j,tilemap,hard)
    if DRAWING_STATE.memo == nil then
        if hard then 
            DRAWING_STATE.memo = {x= i, y= j}
        end
        return
    end

    local click_point = {x= i, y= j}
    local memo_point = DRAWING_STATE.memo

    plot_rect(click_point, memo_point, tilemap)

    if hard then 
        local original = TILEMAPS_CLONES[tilemap.name] 
        assert(not original.is_clone, "original is a clone 4 some reson")
        local rot_deg = normalize_deg(-tilemap.rotation_deg)
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

        plot_rect(click_point, memo_point, original)

        DRAWING_STATE.memo = nil
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

    local original = TILEMAPS_CLONES[TILEMAP.name] 
    assert(not original.is_clone, "original is a clone 4 some reson")
    local rot_deg = normalize_deg(-TILEMAP.rotation_deg)
    local rot_m = ROTATION_MATRICES[DEG_TO_NAMES[rot_deg]]
    
    local new_seeds = {}
    local memo_tile = memo.tile

    function try_add(nx, ny)
        if nx > 0 and nx <= TILEMAP.w 
        and ny > 0 and ny <= TILEMAP.h
        and TILEMAP.tiles[nx][ny] == memo_tile then
            table.insert(new_seeds, {x= nx, y= ny})
        end
    end
    
    for _,seed in pairs(seeds) do
        if seed.x == nil or seed.y == nil then
            goto continue
        end
        if TILEMAP.tiles[seed.x][seed.y] == DRAWING_STATE.tile then
            goto continue
        end

        TILEMAP.tiles[seed.x][seed.y] = DRAWING_STATE.tile

        try_add(seed.x + 1, seed.y)
        try_add(seed.x - 1, seed.y)
        try_add(seed.x, seed.y - 1)
        try_add(seed.x, seed.y + 1)

        seed = sizeful_transform_point(
            seed, 
            extract_size(TILEMAP), 
            extract_size(original), 
            rot_m
        )
        original.tiles[seed.x][seed.y] = DRAWING_STATE.tile

        ::continue::
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
        seeds = {{x= i, y= j}}
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
        function(self,x,y)
            local i,j = get_ij(x,y)
            do_pen(i,j,TILEMAP,true)
        end,
        function(self,x,y,is_down)
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
        function(self,x,y)
            local i,j = get_ij(x,y)
            do_line(i,j,TILEMAP,true)
        end,
        function(self,x,y,is_down)
            local i,j = get_ij(x,y)
            PROJECTED_TILEMAP = clone_tilemap(TILEMAP)
            do_line(i,j,PROJECTED_TILEMAP)
            do_pen(i,j,PROJECTED_TILEMAP)
        end
    elseif DRAWING_STATE.tool == "Rect" then
        return
        function(self,x,y)
            local i,j = get_ij(x,y)
            do_rect(i,j,TILEMAP,true)
        end,
        function(self,x,y,is_down)
            local i,j = get_ij(x,y)
            PROJECTED_TILEMAP = clone_tilemap(TILEMAP)
            do_pen(i,j,PROJECTED_TILEMAP)
            do_rect(i,j,PROJECTED_TILEMAP)
        end
    elseif DRAWING_STATE.tool == "Bucket" then
        return
        function(self,x,y)
            local i,j = get_ij(x,y)
            do_bucket(i,j,TILEMAP)
        end,
        function(self,x,y,is_down)
            local i,j = get_ij(x,y)
            PROJECTED_TILEMAP = clone_tilemap(TILEMAP)
            do_pen(i,j,PROJECTED_TILEMAP)
        end
    end
end

function tilemap_i(x, y)
    local map_w = (TILE_SIZE.w * TILEMAP.w) - 1
    local map_h = (TILE_SIZE.h * TILEMAP.h) - 1

    local click_fn, hover_fn = get_cell_click_and_hover(x, y)
    
    local map_btn = transparent_button_setup(
        x, y, 
        map_w, map_h, 
        click_fn
    )

    map_btn.while_hovered_callback = hover_fn
    
    draw_call_add(function()
        draw_tilemap(PROJECTED_TILEMAP, x, y)
    end)
end

function palette_i(x, y)
    local padding = 5
    local margin = 10
    local where = {x = x + padding, y = y + padding}
    
    -- Pre-calculate to queue the background right away
    local tiles_todraw = {}
    for key,tile in pairs(TILESET) do
        if not is_in_table(RESERVED_TILES, key) then
            table.insert(tiles_todraw, key)
        end
    end

    draw_call_add(function() 
        draw_palette(x, y, padding, margin, #tiles_todraw)
    end)

    for _,key in ipairs(tiles_todraw) do
        local btn = transparent_button_setup(
            where.x, where.y, 
            TILE_SIZE.w, TILE_SIZE.h, 
            function() 
                DRAWING_STATE.tile = key 
            end
        )
        icon_setup(btn, 0, 0, TILESET[key])
        where.y = where.y + TILE_SIZE.h + margin
    end

    local where_tools = {x = x + padding + TILE_SIZE.w + margin, y = y + padding}
    for _,tool in ipairs(TOOLS) do
        where_tools.y = where_tools.y + TILE_SIZE.h + margin
        local btn = transparent_button_setup(
            where_tools.x, where_tools.y, 
            TILE_SIZE.w, TILE_SIZE.h, 
            function() 
                DRAWING_STATE.tool = tool
                DRAWING_STATE.memo = nil
                drawing_board_setup() 
            end
        )
        icon_setup(btn, 0, 0, TILESET[tool])
    end
end