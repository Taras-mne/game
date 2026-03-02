function draw_tile(tile, x, y)
    love.graphics.draw(TILE_ATLASES[tile.atlas], tile.quad, x, y)
end