function player_init(x,y)
    return {
        x= x,
        y= y,
        tile = TILESET.Player
    }
end

function gameplay_setup(map, player)
    TILEMAP = map
    PLAYER = player

    draw_call_add(function()
        gameplay_draw(150, 150)
    end)

    add_key_callback("w", function()
        PLAYER.y = PLAYER.y - 1
    end)
    add_key_callback("a", function()
        PLAYER.x = PLAYER.x - 1
    end)
    add_key_callback("s", function()
        PLAYER.y = PLAYER.y + 1
    end)
    add_key_callback("d", function()
        PLAYER.x = PLAYER.x + 1
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