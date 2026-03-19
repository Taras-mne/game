ZONES_OF_INTEREST = {}

function nuke_zones()
    ZONES_OF_INTEREST = {}
end

function check_zones(x, y, button)
    for i,foo in pairs(ZONES_OF_INTEREST) do
        foo(x, y)
    end
end

function check_hover(x, y, is_down)
    for i,foo in pairs(ZONES_OF_INTEREST) do
        foo(x, y, false, true, is_down)
    end
end

function draw_zones()
    love.graphics.setColor(1, 0, 0, 0.5) 
    for i,foo in pairs(ZONES_OF_INTEREST) do
        foo(0, 0, true)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function create_zone(x, y, w, h, callback, hover_callback)
    local foo = function(c_x, c_y, show, hover, is_down)
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

        if hover and hover_callback then 
            hover_callback(c_x, c_y, is_down)
        elseif not hover then
            callback(c_x, c_y)
        end
    end

    table.insert(ZONES_OF_INTEREST, foo)
end 