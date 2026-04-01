function player_init(x,y)
    return {
        x= x,
        y= y
    }
end

function gameplay_setup(map, player)
    TILEMAP = map
    PLAYER = player

    draw_call_add(function()
        gameplay_draw(150, 150)
    end)
end

function gameplay_update(dt)
end

function gameplay_draw(x,y)
    draw_tilemap(TILEMAP, x, y)
    draw_tile(
        TILESET.Player,
        x + (PLAYER.x-1) * TILE_SIZE.w,
        y + (PLAYER.y-1) * TILE_SIZE.h
    )
end