DEG_TO_NAMES = {
    [90 * 0] = "ZERO",
    [90 * 1] = "QUARTER",
    [90 * 2] = "HALF",
    [90 * 3] = "THREE_QUARTERS",
}

ROTATION_MATRICES = {
    QUARTER = {
        rotation_deg= 90,
        flips= {w= 0, h= 0},
        { 0,-1},
        { 1, 0},
    },
    HALF = {
        rotation_deg= 90 * 2,
        flips= {w= 1, h= 1},
        {-1, 0},
        { 0,-1},
    },
    THREE_QUARTERS = {
        rotation_deg= 90 * 3,
        flips= {w= 0, h= 0},
        { 0, 1},
        {-1, 0},
    },
    ZERO = {
        rotation_deg= 0,
        flips= {w= 0, h= 0},
        { 1, 0},
        { 0, 1},
    },
    W_FLIPPED = {
        rotation_deg= 0,
        flips= {w= 1, h= 0},
        { -1, 0},
        { 0, 1},
    },
    H_FLIPPED = {
        rotation_deg= 0,
        flips= {w= 0, h= 1},
        { 1, 0},
        { 0, -1},
    },
}

function round(x)
    if x >= 0 then
        return math.floor(x + 0.5)
    else
        return math.ceil(x - 0.5)
    end
end

function compare_points(p1, p2)
    return p1.x == p2.x and p1.y == p2.y
end

function sum_points(p1, p2)
    return {x=p1.x + p2.x , y=p1.y + p2.y}
end

function neg_point(p)
    return {x=-p.x , y=-p.y}
end

function abs_point(p)
    return {x=math.abs(p.x) , y=math.abs(p.y)}
end

function sign(number)
    return number > 0 and 1 or (number == 0 and 0 or -1)
end

function transform_point(point, rot_m)
    local n_point = {}

    n_point.x = point.x * rot_m[1][1] + point.y * rot_m[1][2]
    n_point.y = point.x * rot_m[2][1] + point.y * rot_m[2][2]
    
    return n_point 
end

function sizeful_transform_point(point, size, n_size, rot_m)
    local t_x = point.x - (1 + size.w)/2
    local t_y = point.y - (1 + size.h)/2
    
    local n_point = transform_point({x= t_x, y= t_y}, rot_m)

    n_point.x = n_point.x + (1 + n_size.w)/2
    n_point.y = n_point.y + (1 + n_size.h)/2
    
    return n_point 
end

function is_in_table(table, value)
    for _, v in ipairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

function array_flip(array)
    local n_array = {}
    for i=#array,1,-1 do
        table.insert(n_array, array[i])
    end
    return n_array
end

function normalize_deg(deg)
    return deg % 360
end

function deg_to_matrix(deg)
    return ROTATION_MATRICES[DEG_TO_NAMES[normalize_deg(deg)]]
end

function extract_size(obj)
    return {w= obj.w, h= obj.h}
end

function is_function(obj)
    return type(obj) == "function"
end

function clone_color(color)
    return {color[1], color[2], color[3], color[4]}
end