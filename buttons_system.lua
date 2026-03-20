WHITE = {1, 1, 1, 1}
BUTTONS = {}

-- needs a button system instead of current one

function menu_setup()
    local screen_width, screen_height = love.window.getMode()
    button = button_setup(
        100,100,
        400,100,
        {1,0,1,0.5},"Testing_button",
        function()
        end
    )
end

function button_setup(
    x, y, 
    w, h, 
    color, text, 
    callback
)
    local button = {
        x= x,
        y= y,
        w= w,
        h= h,
        text= text,
        color= color,
        color_hovered= {1-color[1], 1-color[2], 1-color[3], 1-color[4]},
        is_hovered= false,
        callback= callback,
    }
    table.insert(BUTTONS, button)

    draw_call_add(function()
        if button.is_hovered then
            love.graphics.setColor(button.color_hovered)
            love.graphics.rectangle("fill", button.x, button.y, button.w, button.h)
            love.graphics.setColor(WHITE)
            love.graphics.print(button.text, button.x, button.y)
        else
            love.graphics.setColor(button.color)
            love.graphics.rectangle("fill", button.x, button.y, button.w, button.h)
            love.graphics.setColor(WHITE)
            love.graphics.print(button.text, button.x, button.y)
        end
        --calming the hover will b there 4 now
        button.is_hovered = false
    end)

    create_zone(
        x, y, 
        w, h,
        function(x, y)
            button.callback(x, y)
        end,
        function()
            button.is_hovered = true
        end
    )

    return button
end