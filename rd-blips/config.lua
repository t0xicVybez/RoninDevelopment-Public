Config = {}

-- Command Permissions
Config.Commands = {
    ['createblip'] = 'admin',     -- Only admins can create blips
    ['removeblip'] = 'admin',     -- Only admins can remove blips
    ['createmarker'] = 'admin',   -- Only admins can create markers
    ['removemarker'] = 'admin'    -- Only admins can remove markers
}

-- Defaults
Config.DefaultMarkerDistance = 50.0    -- Distance to start rendering markers
Config.DefaultBlipScale = 0.8          -- Default scale for new blips
Config.DefaultMarkerScale = 1.0        -- Default scale for new markers
Config.DefaultMarkerColor = {          -- Default color for new markers
    r = 255,
    g = 0,
    b = 0,
    a = 100
}

-- Marker Types Reference (for admins)
Config.MarkerTypes = {
    ['cylinder'] = 1,
    ['arrow'] = 2,
    ['ring'] = 25,
    ['chevron'] = 27,
    ['horizontal_circle'] = 28,
    ['plane'] = 33,
    ['car'] = 36,
    ['bike'] = 37,
    ['at_symbol'] = 38,
}

-- Blip Colors Reference (for admins)
Config.BlipColors = {
    ['white'] = 0,
    ['red'] = 1,
    ['green'] = 2,
    ['blue'] = 3,
    ['yellow'] = 5,
    ['light_red'] = 6,
    ['violet'] = 7,
    ['pink'] = 8,
    ['orange'] = 17,
}

-- Common Blip Sprites Reference (for admins)
Config.CommonBlipSprites = {
    ['store'] = 52,
    ['clothing'] = 73,
    ['barber'] = 71,
    ['garage'] = 357,
    ['gas_station'] = 361,
    ['hospital'] = 61,
    ['bank'] = 108,
    ['house'] = 40,
    ['office'] = 475,
    ['warehouse'] = 473,
    ['police'] = 60,
    ['repair'] = 446,
    ['ammunition'] = 110,
}