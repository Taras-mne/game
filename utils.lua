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