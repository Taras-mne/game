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

        button:callback(c_x, c_y, c_button)
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
        if button.hovered_callback then
            button:hovered_callback(h_x, h_y, is_down)
        end
        goto the_end 

        ::continue::
    end
    ::the_end::
end

function menu_setup()
    local screen_width, screen_height = love.window.getMode()
    local button1 = button_setup(
        100, 100,
        400, 100,
        {0,1,1,0.5},
        function(self,x,y)
            self.text = "picaboo"
            if self.upd_key ~= nil then
                delete_update(self.upd_key)
            end
            upd_key = create_update(
                function(_self)
                    self.w = self.w + (_self.target.w - self.w) / 20
                end, 
                function(_self)
                    _self.target = {}
                    _self.target.w = self.w + 40
                end, 
                function(_self)
                    if (_self.target.w - self.w) > 1 then
                        return false
                    end 
                    self.w = _self.target.w
                    return true
                end
            )
            self.upd_key = upd_key
        end
    )
    button1.target = {
        w= nil
    }

    local button2 = button_setup(
        100, 210,
        400, 100,
        {1,0,1,0.5},
        function(self,x,y)
            self.w = self.w + 50
            self.icon.x = self.icon.x + 50
        end
    )
    icon_setup(button2, 20, 20, TILESET.NoTile)
end

function icon_setup(button, l_x, l_y, tile)
    local icon = {
        x= l_x,
        y= l_y,
        tile= tile,
    }
    button.icon = icon
end

function button_setup(
    x, y, 
    w, h, 
    color, 
    callback
)
    local button = {
        x= x,
        y= y,
        w= w,
        h= h,
        color= color,
        color_hovered= {1-color[1], 1-color[2], 1-color[3], 1-color[4]},
        is_hovered= false,
        callback= callback,
    }
    table.insert(BUTTONS, button)

    draw_call_add(function()
        if button.is_hovered then
            love.graphics.setColor(button.color_hovered)
        else
            love.graphics.setColor(button.color)
        end
        love.graphics.rectangle("fill", button.x, button.y, button.w, button.h)
        love.graphics.setColor(WHITE)
        if button.icon then
            draw_tile(
                button.icon.tile, 
                button.x + button.icon.x, 
                button.y + button.icon.y)
        end
        if button.text then
            love.graphics.print(button.text, button.x, button.y)
        end
        --calming the hover will b there 4 now
        button.is_hovered = false
    end)

    return button
end

function transparent_button_setup(
    x, y, 
    w, h, 
    callback
)
    local btn = button_setup(x, y, w, h, {0, 0, 0, 0}, callback)
    btn.color_hovered = {0, 0, 0, 0}
    return btn
end