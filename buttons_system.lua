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
            if button.unhovered_callback and button.is_hovered then
                button:unhovered_callback(h_x, h_y, is_down)
                button.is_hovered = false
            end 
            goto continue
        end

        if button.hovered_callback and not button.is_hovered then
            button:hovered_callback(h_x, h_y, is_down)
            button.is_hovered = true
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
            if self.c_upd_key ~= nil then
                delete_update(self.c_upd_key)
            end
            upd_key = animate_numeric_attribute(self, "w", self.w + 100, 1)
            self.c_upd_key = upd_key
        end
    )
    button1.hovered_callback = function(self, x, y)
        self.h_upd_key = animate_color(self, "display_color", clone_color(self.color_hovered), 0.01)
        if self.uh_upd_key ~= nil then
            delete_update(self.uh_upd_key)
        end
    end
    button1.unhovered_callback = function(self, x, y)
        self.uh_upd_key = animate_color(self, "display_color", clone_color(self.color_default), 0.01)
        if self.h_upd_key ~= nil then
            delete_update(self.h_upd_key)
        end
    end

    local button2 = button_setup(
        100, 210,
        400, 100,
        {1,0,1,0.5},
        function(self,x,y)
            if self.upd_key ~= nil then
                delete_update(self.upd_key)
            end
            upd_key = animate_numeric_attribute(self, "h", self.h + 100, 1)
            self.upd_key = upd_key
        end
    )
    icon_setup(button2, 20, 20, TILESET.NoTile)
    button2.hovered_callback = function(self, x, y)
        self.h_upd_key = animate_color(self, "display_color", clone_color(self.color_hovered), 0.01)
        if self.uh_upd_key ~= nil then
            delete_update(self.uh_upd_key)
        end
    end
    button2.unhovered_callback = function(self, x, y)
        self.uh_upd_key = animate_color(self, "display_color", clone_color(self.color_default), 0.01)
        if self.h_upd_key ~= nil then
            delete_update(self.h_upd_key)
        end
    end
end

function animate_numeric_attribute(table, key, target, epsilon)
    return create_update(
        function(_self, dt)
            table[key] = table[key] + ((_self.target[key] - table[key])/5) * (dt*30) 
            --30 fps is the reference point 4 a single frame. in reality 4 me it's 144 fps
        end, 
        function(_self)
            _self.target = {}
            _self.target[key] = target
        end, 
        function(_self)
            if math.abs(_self.target[key] - table[key]) > epsilon then
                return false
            end 
            table[key] = _self.target[key]
            return true
        end
    )
end

function animate_color(table, key, target, epsilon)
    return create_update(
        function(_self, dt)
            --30 fps is the reference point 4 a single frame. in reality 4 me it's 144 fps
            for i=1,4 do
                table[key][i] = table[key][i] + ((_self.target[key][i] - table[key][i])/5) * (dt*30) 
            end
        end, 
        function(_self)
            _self.target = {}
            _self.target[key] = target
        end, 
        function(_self)
            for i=1,4 do
                if math.abs(_self.target[key][i] - table[key][i]) > epsilon then
                    return false
                end 
            end
            table[key] = _self.target[key]
            return true
        end
    )
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
        display_color= clone_color(color),
        color_default= clone_color(color),
        color_hovered= {1-color[1], 1-color[2], 1-color[3], 1-color[4]},
        is_hovered= false,
        callback= callback,
    }
    table.insert(BUTTONS, button)

    draw_call_add(function()
        love.graphics.setColor(button.display_color)
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