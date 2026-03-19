--used in many places, 100% needed
function round(x)
    if x >= 0 then
        return math.floor(x + 0.5)
    else
        return math.ceil(x - 0.5)
    end
end

--only used in line function, prob to be removed later in favor of only 45 deg lines
function sum(t1,t2)
    return({t1[1] + t2[1],t1[2] + t2[2]})
end

function neg(t)
    return({t[1] * -1,t[2] * -1})
end

function normalize(t)
    local l = (t[1]^2 + t[2]^2)^0.5
    return({t[1]/l,t[2]/l})
end

--used in tiling system once, feels like it will be used again somewhere
function compare_points(p1, p2)
    return p1.x == p2.x and p1.y == p2.y
end

function transform_point(point, rot_m)
    n_point = {}

    n_point.x = point.x * rot_m[1][1] + point.y * rot_m[1][2]
    n_point.y = point.x * rot_m[2][1] + point.y * rot_m[2][2]
    
    return n_point 
end

function sizeful_transform_point(point, size, n_size, rot_m)
    local t_x = point.x - (1 + size.w)/2
    local t_y = point.y - (1 + size.h)/2
    
    n_point = transform_point({x= t_x, y= t_y}, rot_m)

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
    n_array = {}
    for i=#array,1,-1 do
        table.insert(n_array, array[i])
    end
    return n_array
end

function normilize_deg(deg)
    return deg % 360
end

function extract_size(obj)
    return {w= obj.w, h= obj.h}
end

DEG_TO_NAMES = {
    [90 * 0] = "ZERO",
    [90 * 1] = "QUARTER",
    [90 * 2] = "HALF",
    [90 * 3] = "THREE_QUARTERS",
}