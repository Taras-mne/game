MOVEMENT_OPTIONS = {
    U = {x= 0, y= -1},
    D = {x= 0, y= 1},
    L = {x= -1, y= 0},
    R = {x= 1, y= 0},
}

function move_thing(thing, vector)
    n_pos = sum_points(thing, vector)
    if not point_within_bounds(n_pos, TILEMAP) then
        return
    end
    if TILEMAP.tiles[n_pos.x][n_pos.y] == "Spikes" then
        return
    end
    thing.x = n_pos.x
    thing.y = n_pos.y
end

function player_init(x,y)
    return {
        x= x,
        y= y,
        tile= TILESET.Player,
        type= "PLAYER"
    }
end

function gameplay_setup(map, player)
    TILEMAP = map
    PLAYER = player

    draw_call_add(function()
        gameplay_draw(100, 100)
    end)

    add_keys_callback({"w","up"}, function()
        move_thing(PLAYER, MOVEMENT_OPTIONS.U)
    end)
    add_keys_callback({"a","left"}, function()
        move_thing(PLAYER, MOVEMENT_OPTIONS.L)
    end)
    add_keys_callback({"s","down"}, function()
        move_thing(PLAYER, MOVEMENT_OPTIONS.D)
    end)
    add_keys_callback({"d","right"}, function()
        move_thing(PLAYER, MOVEMENT_OPTIONS.R)
    end)
end

function gameplay_update(dt)
end

function gameplay_draw(x,y)
    draw_tilemap(TILEMAP, x, y)
    draw_tile(
        PLAYER.tile,
        x + (PLAYER.x-1) * TILE_SIZE.w,
        y + (PLAYER.y-1) * TILE_SIZE.h
    )
end