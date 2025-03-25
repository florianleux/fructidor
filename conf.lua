function love.conf(t)
    -- Save file
    t.identity = 'data/saves'
    t.console = true

    -- Window settings
    t.window.width = 1920  -- The window width (number)
    t.window.height = 1080 -- The window height (number)
    t.window.fullscreen = true
    t.window.fullscreentype = "desktop"
    t.window.resizable = true

    t.window.title = "Fructidor"
end
