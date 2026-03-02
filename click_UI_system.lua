ZONES_OF_INTEREST = {}

function check_zones(x, y, button)
    for i,foo in ipairs(ZONES_OF_INTEREST) do
        foo(x, y)
    end
end

function draw_zones()
    for i,foo in ipairs(ZONES_OF_INTEREST) do
        foo(0, 0, true)
    end
end

function create_zone(x, y, w, h, callback)
    local foo = function(c_x, c_y, show)
        if show then
            love.graphics.rectangle("fill", x, y, w, h)
            return
        end

        if c_x < x 
        or c_y < y
        or c_x > x+w  
        or c_y > y+h 
        then 
            return 
        end
        callback()
    end
    table.insert(ZONES_OF_INTEREST, foo)
end 