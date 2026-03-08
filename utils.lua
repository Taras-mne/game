function round(x)
    if x >= 0 then
        return math.floor(x + 0.5)
    else
        return math.ceil(x - 0.5)
    end
end

function sum(t1,t2)
    return({t1[1] + t2[1],t1[2] + t2[2]})
end

function neg(t)
    return({t[1] * -1,t[2] * -1})
end

function normalize(t)
    l = (t[1]^2 + t[2]^2)^0.5
    return({t[1]/l,t[2]/l})
end