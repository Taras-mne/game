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
    ZERO = {
        { 1, 0},
        { 0, 1},
    },
}

TILE_SIZE = {
    w= 32,
    h= 32
}

TILE_NAMES = {
    Line=     {x=1, y=1, atlas="smol_atlas"},
    Rect=     {x=2, y=1, atlas="smol_atlas"},
    Bucket=   {x=1, y=2, atlas="smol_atlas"},
    Pen=      {x=2, y=2, atlas="smol_atlas"},
    Wug=      {x=1, y=1, atlas="big_atlas"},
    Birb=     {x=2, y=1, atlas="big_atlas"},
    Grass=    {y=1, x=3, atlas="big_atlas"},
    Water=    {y=1, x=4, atlas="big_atlas"},
    Lava=     {y=2, x=3, atlas="big_atlas"},
    Spikes=   {y=2, x=4, atlas="big_atlas"},
    Rot90cw=  {y=5, x=4, atlas="big_atlas"},
    Rot90ccw= {y=5, x=5, atlas="big_atlas"},
    Save=     {y=5, x=1, atlas="big_atlas"},

    UpArrow=     {y=2, x=2, atlas="big_atlas"},
    DownArrow=   {y=4, x=2, atlas="big_atlas"},
    LeftArrow=   {y=3, x=1, atlas="big_atlas"},
    RightArrow=  {y=3, x=3, atlas="big_atlas"},

    BLOCK=  {y=4, x=1, atlas="big_atlas"},
    NoTile=  {y=4, x=3, atlas="big_atlas"},
}

RESERVED_TILES = {
    "Pen",
    "Line",
    "Rect",
    "Bucket",

    "BLOCK",
    "NoTile",

    "UpArrow",
    "DownArrow",
    "LeftArrow",
    "RightArrow",

    "Save",
    "Rot90ccw",
    "Rot90cw",
}

TILE_ATLASES = {
    big_atlas= "pics/5by5.png",
    smol_atlas= "pics/2by2.png"
}

TILESET = {}

TILEMAPS = {}

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
    local tilemap =  {
        tiles= tiles, 
        w= w, 
        h= h, 
        name= name, 
        bg_t= bg_t,
        links = {
            U = {name = "BLOCK"},
            D = {name = "BLOCK"},
            L = {name = "BLOCK"},
            R = {name = "BLOCK"},
        }
    }
    TILEMAPS[name] = tilemap
    return tilemap
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
        elseif ch == '(' or ch == ')'
            or ch == '[' or ch == ']'
            or ch == 'x' 
            or ch == '.'then
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
    while i < #tokens do
        if tokens[i] == "(" then
            assert(tokens[i+3] == ")", "closing bracket expected")
            local x = tonumber(tokens[i+1])
            local y = tonumber(tokens[i+2])
            tilemap.tiles[x][y] = tile
            i = i + 4
        elseif tokens[i] == "===" then
            i = i + 1
            break
        elseif tonumber(tokens[i]) == nil then
            tile = tokens[i]
            i = i + 1
        else
            assert(false, "unexpected token recieved: " .. tokens[i])
        end
    end 
    local self_side = ""
    local dest_side = ""
    local destanation = {}
    while i < #tokens do
        if tokens[i] == "->" then
            self_side = tokens[i-1]
            i = i + 1
        elseif tokens[i] == "[" then
            assert(tokens[i+2] == "]", "closing bracket expected")
            destanation = TILEMAPS[tokens[i+1]]
            i = i + 3
        elseif tokens[i] == "BLOCK" then
            -- block is default, no behaviour needed
            self_side = ""
            dest_side = ""
            destanation = {}
            i = i + 1
        elseif tokens[i] == "." then
            dest_side = tokens[i+1]
            assert(self_side ~= "", "missing self side")
            assert(dest_side ~= "", "missing destanation side")
            assert(destanation.name ~= nil, "missing destanation")
            tilemap.links[self_side] = {name = destanation.name, side = dest_side}
            i = i + 1
        elseif tokens[i] == "U" 
            or tokens[i] == "D"
            or tokens[i] == "L"
            or tokens[i] == "R" 
        then
            i = i + 1
        else
            assert(false, "unexpected token recieved: " .. tokens[i])
        end
    end
    return tilemap
end

function rotate_tilemap(tilemap, rot_m)
    local n_w = math.abs(tilemap.w * rot_m[1][1]) + math.abs(tilemap.h * rot_m[1][2])
    local n_h = math.abs(tilemap.w * rot_m[2][1]) + math.abs(tilemap.h * rot_m[2][2])
    local size = {w= tilemap.w, h=tilemap.h}
    local n_size = {w= n_w, h=n_h}
    local tiles = tilemap.tiles
    local n_tilemap = make_tilemap(n_w, n_h, tilemap.bg_t, tilemap.name)

    for x, column in pairs(tiles) do
        for y, value in pairs(column) do
            if value == tilemap.bg_t then
                goto continue
            end

            local point = sizeful_transform_point({x= x, y= y}, size, n_size, rot_m)
            n_tilemap.tiles[point.x][point.y] = value

            ::continue::
        end
    end

    local points = {
        D= {x= 0, y= -1}, 
        U= {x= 0, y= 1},
        L= {x= -1, y= 0},
        R= {x= 1, y= 0},
    }

    for key,point in pairs(points) do
        n_point = transform_point(point, rot_m)
        for n_key,point in pairs(points) do
            if compare_points(n_point, point) then 
                n_tilemap.links[n_key] = tilemap.links[key] 
            end
        end
    end
    return n_tilemap
end

function clone_tilemap(tilemap)
    return rotate_tilemap(tilemap, ROTATION_MATRICES.ZERO)
end