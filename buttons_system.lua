WHITE = {1, 1, 1, 1}
BUTTONS = {}

function click_buttons(c_x, c_y, c_button)
    for _, button in pairs(BUTTONS) do
        if c_x < button.display.x 
        or c_y < button.display.y
        or c_x > button.display.x + button.display.w  
        or c_y > button.display.y + button.display.h 
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
        if h_x < button.display.x 
        or h_y < button.display.y
        or h_x > button.display.x + button.display.w  
        or h_y > button.display.y + button.display.h 
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

        ::continue::
    end
    ::the_end::
end

function menu_setup()
    local screen_width, screen_height = love.window.getMode()
    local button1 = button_setup(
        200, 200,
        400, 100,
        {0,1,1,0.5},
        function(self,x,y)
            self.text = "picaboo"
            if self.c_upd_key ~= nil then
                delete_update(self.c_upd_key)
            end
            self.target.w = self.target.w + 50
            self.base.w = self.base.w + 50
            upd_key = animate_numeric_attribute(self.display, "w", self.target, 1)
            self.c_upd_key = upd_key
        end
    )
    setup_hover_bounce(button1, -20, -20, 40, 40)

    local button2 = button_setup(
        200, 310,
        400, 100,
        {1,0,1,0.5},
        function(self,x,y)
            if self.c_upd_key ~= nil then
                delete_update(self.c_upd_key)
            end
            self.target.h = self.target.h + 50
            self.base.h = self.base.h + 50
            upd_key = animate_numeric_attribute(self.display, "h", self.target, 1)
            self.c_upd_key = upd_key
        end
    )
    icon_setup(button2, 20, 20, TILESET.NoTile)
    setup_button_color_hover(button2)

    debug_output(1,1)
end

function icon_setup(button, l_x, l_y, tile)
    local icon = {
        x= l_x,
        y= l_y,
        tile= tile,
    }
    button.icon = icon
end

function setup_button_color_hover(button)
    button.hovered_callback = function(self, x, y)
        self.h_upd_key = animate_color(self.display, "color", clone_color(self.color_hovered), 0.01)
        if self.uh_upd_key ~= nil then
            delete_update(self.uh_upd_key)
            self.uh_upd_key = nil
        end
    end
    button.unhovered_callback = function(self, x, y)
        self.uh_upd_key = animate_color(self.display, "color", clone_color(self.color_default), 0.01)
        if self.h_upd_key ~= nil then
            delete_update(self.h_upd_key)
            self.h_upd_key = nil
        end
    end
end

function setup_hover_bounce(button, dx, dy, dw, dh)
    local starting_pos = {button.x, button.y, button.w, button.h} 
    button.hovered_callback = function(self, x, y)
        self.target.x = self.base.x + dx
        self.target.y = self.base.y + dy
        self.target.w = self.base.w + dw
        self.target.h = self.base.h + dh
        self.h_upd_key = animate_numeric_attributes(
            self.display, 
            {"x","y","w","h"}, 
            self.target, 
            {x=1, y=1, w=1, h=1}
        )
        if self.uh_upd_key ~= nil then
            delete_update(self.uh_upd_key)
            self.uh_upd_key = nil
        end
    end
    button.unhovered_callback = function(self, x, y)
        self.target.x = self.base.x
        self.target.y = self.base.y
        self.target.w = self.base.w
        self.target.h = self.base.h
        self.uh_upd_key = animate_numeric_attributes(
            self.display, 
            {"x","y","w","h"}, 
            self.target,
            {x=1, y=1, w=1, h=1}
        )
        if self.h_upd_key ~= nil then
            delete_update(self.h_upd_key)
            self.h_upd_key = nil
        end
    end
end

function button_setup(
    x, y, 
    w, h, 
    color, 
    callback
)
    local button = {
        display = {
            color= clone_color(color),
            x= x,
            y= y,
            w= w,
            h= h,
        },
        base = {
            color= clone_color(color),
            x= x,
            y= y,
            w= w,
            h= h,
        },
        target = {
            color= clone_color(color),
            x= x,
            y= y,
            w= w,
            h= h,
        },
        color_default= clone_color(color),
        color_hovered= {1-color[1], 1-color[2], 1-color[3], 1-color[4]},
        is_hovered= false,
        callback= callback,
    }
    table.insert(BUTTONS, button)

    draw_call_add(function()
        love.graphics.setColor(button.display.color)
        love.graphics.rectangle("fill", button.display.x, button.display.y, button.display.w, button.display.h)
        love.graphics.setColor(WHITE)
        if button.icon then
            draw_tile(
                button.icon.tile, 
                button.display.x + button.icon.x, 
                button.display.y + button.icon.y)
        end
        if button.text then
            love.graphics.print(button.text, button.display.x, button.display.y)
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