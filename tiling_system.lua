ROTATION_MATRICES = {
    QUARTER = {
        { 0, 1},
        {-1, 0},
    },
    HALF = {
        {-1, 0},
        { 0,-1},
    },
    THREE_QUARTERS = {
        { 0,-1},
        { 1, 0},
    },
}

TILE_SIZE = {
    w= 32,
    h= 32
}

TILE_NAMES = {
    A= {x=1, y=1, atlas="smol_atlas"},
    B= {x=2, y=1, atlas="smol_atlas"},
    C= {x=1, y=2, atlas="smol_atlas"},
    D= {x=2, y=2, atlas="smol_atlas"},
    Grass=    {y=1, x=3, atlas="big_atlas"},
    Water=    {y=1, x=4, atlas="big_atlas"},
    Lava=     {y=2, x=3, atlas="big_atlas"},
    Spikes=   {y=2, x=4, atlas="big_atlas"},
    Rot90cw=  {y=5, x=4, atlas="big_atlas"},
    Rot90ccw= {y=5, x=5, atlas="big_atlas"}
}

TILE_ATLASES = {
    big_atlas= "pics/5by5.png",
    smol_atlas= "pics/2by2.png"
}

TILESET = {}

function load_tilesets()
    for key, path in pairs(TILE_ATLASES) do
        TILE_ATLASES[key] = love.graphics.newImage(path)
    end
    for name, coords in pairs(TILE_NAMES) do
        local src_x = (coords.x - 1) * TILE_SIZE.w
        local src_y = (coords.y - 1) * TILE_SIZE.h

        local tile_quad = love.graphics.newQuad(src_x, src_y, TILE_SIZE.w, TILE_SIZE.h, TILE_ATLASES[coords.atlas]:getDimensions())

        TILESET[name] = {
            name= name,
            quad= tile_quad,
            atlas= coords.atlas
        } 
    end
    TILE_NAMES = nil
end

function make_tilemap(w,h,bg_t,name)
    local tiles = {}
    for i=1,w do
        tiles[i] = {}
        for j=1,h do
            tiles[i][j] = bg_t
        end
    end
    return {
        tiles= tiles, 
        w= w, 
        h= h, 
        name= name, 
        bg_t= bg_t,
        links = { --for future use
            U = "BLOCK",
            D = "BLOCK",
            L = "BLOCK",
            R = "BLOCK",
        }
    }
end

function upload_tilemap(tilemap)
    local file_s = "NAME " .. tilemap.name .. "\n"
    file_s = file_s .. tilemap.w .. "x" .. tilemap.h .. "\n"
    file_s = file_s .. "BG " .. tilemap.bg_t .. "\n"
    file_s = file_s .. "===\n"

    local tile_coords = {}

    for x, column in pairs(tilemap.tiles) do
        for y, value in pairs(column) do
            if value == tilemap.bg_t then
                goto continue
            end
            if tile_coords[value] == nil then
                tile_coords[value] = {} 
            end

            table.insert(tile_coords[value], {x,y})
            
            ::continue::
        end
    end

    for key, array in pairs(tile_coords) do
        file_s = file_s .. key .. " "
        for i, point in pairs(array) do
            file_s = file_s .. "(" .. point[1] .. " " .. point[2] .. ") "
        end
        file_s = file_s .. "\n"
    end

    local file = io.open("o_maps/".. tilemap.name .. ".txt", "w")
    if file then
        file:write(file_s)
        file:close()
    end
end 

function tokenize(file_str)
    function try_put(tokens, token)
        if token == "" then return end
        table.insert(tokens, token)
    end

    local tokens = {}
    local token = ""
    
    for i = 1, #file_str do
        local ch = string.sub(file_str, i, i)
        if ch == '\n'
        or ch == '\t'
        or ch == '\r'
        or ch == ' '  
        then
            try_put(tokens, token)
            token = ""
        elseif ch == '(' 
            or ch == 'x' 
            or ch == ')'then
            try_put(tokens, token)
            try_put(tokens, ch)
            token = ""
        else
            token = token .. ch
        end
    end
    try_put(tokens, token)

    return tokens
end 

function read_tilemap(filename)
    local file = assert(io.open("maps/".. filename, "rb"))
    local content = file:read("*all")
    file:close()
    local tokens = tokenize(content)
    local tilemap = make_tilemap(
        tonumber(tokens[3]),
        tonumber(tokens[5]),
        tokens[7],
        tokens[2]
    )
    local i = 0
    for key,token in ipairs(tokens) do
        if token == "===" then
            i = key + 1
            break
        end
    end
    local tile = tilemap.bg_t
    repeat
        if tokens[i] == "(" then
            assert(tokens[i+3] == ")", "closing bracket expected")
            local x = tonumber(tokens[i+1])
            local y = tonumber(tokens[i+2])
            tilemap.tiles[x][y] = tile
            i = i + 4
        elseif tonumber(tokens[i]) == nil then
            tile = tokens[i]
            i = i + 1
        else
            assert(false, "unexpected token recieved: " .. tokens[i])
        end
    until i >= #tokens
    return tilemap
end

function rotate_tilemap(tilemap, rot_m)
    local n_w = math.abs(tilemap.w * rot_m[1][1]) + math.abs(tilemap.h * rot_m[1][2])
    local n_h = math.abs(tilemap.w * rot_m[2][1]) + math.abs(tilemap.h * rot_m[2][2])
    local tiles = tilemap.tiles
    local n_tilemap = make_tilemap(n_w, n_h, tilemap.bg_t, tilemap.name .. "_r")
    for x, column in pairs(tiles) do
        for y, value in pairs(column) do
            if value == tilemap.bg_t then
                goto continue
            end
            local t_x = x - (1 + tilemap.w)/2
            local t_y = y - (1 + tilemap.h)/2
            
            local n_x = t_x * rot_m[1][1] + t_y * rot_m[1][2]
            local n_y = t_x * rot_m[2][1] + t_y * rot_m[2][2]

            n_x = n_x + (1 + n_w)/2
            n_y = n_y + (1 + n_h)/2

            n_tilemap.tiles[n_x][n_y] = value
            ::continue::
        end
    end
    return n_tilemap
end