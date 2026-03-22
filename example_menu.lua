function menu_setup()
    nuke_buttons()
    nuke_draw_queue()

    local screen_width, screen_height = love.window.getMode()
    start = {x= 100, y= 25}
    size = {w= 300, h= 100}
    margin = 25


    for key,value in pairs(TILEMAPS) do
        local button = button_setup(
            start.x, start.y,
            size.w, size.h,
            {1, 0, 0, 0.5},
            function(self,x,y)
                if self.c_key ~= nil then
                    delete_update(self.c_key)
                    self.c_key = nil
                end
                self.c_key = sleep_then_do(0.25, function()
                    drawing_board_setup(key) 
                end)
            end
        )
        button.text = key
        start.y = start.y + margin + size.h 
        setup_hover_bounce(button, -15, -15, 30, 30)
        -- setup_button_color_hover(button)
    end

    debug_output(1,1)
end