WHITE = {1, 1, 1, 1}
BUTTONS = {}

function click_buttons(c_x, c_y, c_button)
    for _, button in pairs(BUTTONS) do
        if c_x < button.x 
        or c_y < button.y
        or c_x > button.x + button.w  
        or c_y > button.y + button.h 
        then 
            goto continue
        end

        button:callback(x, y, c_button)
        goto the_end --return breaks here 4 some reason

        ::continue::
    end
    ::the_end::
end

function hover_buttons(h_x, h_y, is_down)
    for _, button in pairs(BUTTONS) do
        if h_x < button.x 
        or h_y < button.y
        or h_x > button.x + button.w  
        or h_y > button.y + button.h 
        then 
            goto continue
        end

        button.is_hovered = true
        goto the_end --return breaks here 4 some reason

        ::continue::
    end
    ::the_end::
end

function menu_setup()
    local screen_width, screen_height = love.window.getMode()
    local button = button_setup(
        100,100,
        400,100,
        {1,0,1,0.5},"Testing_button",
        function(self,x,y)
            self.w = self.w + 50
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
        function(x, y, c_button)
        end,
        function(x, y)
            button.is_hovered = true
        end
    )

    return button
end