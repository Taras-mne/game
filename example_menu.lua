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

    local button2 = button_setup(
        200, 420,
        400, 100,
        {1,1,0,0.5},
        function(self,x,y)
            if self.c_key ~= nil then
                delete_update(self.c_key)
                self.c_key = nil
            else
                self.c_key = sleep_then_do(0.25, function()
                    drawing_board_setup("beeg") 
                end)
            end
        end
    )
    icon_setup(button2, 20, 20, TILESET.NoTile)
    setup_button_color_hover(button2)

    debug_output(1,1)
end