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
    ['STANDARD'] = 1,
    ['WAYPOINT'] = 8,
    ['STORE'] = 52,
    ['CLOTHING'] = 73,
    ['BARBER'] = 71,
    ['GARAGE'] = 357,
    ['GAS_STATION'] = 361,
    ['HOSPITAL'] = 61,
    ['BANK'] = 108,
    ['HOUSE'] = 40,
    ['YELLOW_HOUSE'] = 417,
    ['OFFICE'] = 475,
    ['WAREHOUSE'] = 473,
    ['POLICE'] = 60,
    ['REPAIR'] = 446,
    ['AMMUNITION'] = 110,
    ['BAR'] = 93,
    ['BEAUTY_SALON'] = 71,
    ['BOAT_DOCK'] = 427,
    ['TENNIS'] = 122,
    ['STRIP_CLUB'] = 121,
    ['RACE_TRACK'] = 147,
    ['CAR_DEALER'] = 225,
    ['GYM'] = 311,
    ['HELICOPTER'] = 43,
    ['AIRPORT'] = 90,
    ['AMUSEMENT_PARK'] = 266,
    ['MECHANIC'] = 446,
    ['RESTAURANT'] = 93,
    ['CLOTHES'] = 366,
    ['STORE_MASK'] = 362,
    ['ARMORY'] = 110,
    ['RADAR'] = 399,
    ['SURVIVAL'] = 361
}