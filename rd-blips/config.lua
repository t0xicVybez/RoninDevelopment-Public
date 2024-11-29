Config = {}

-- Command Permissions
Config.Commands = {
    ['createblip'] = 'admin',     -- Only admins can create blips
    ['removeblip'] = 'admin',     -- Only admins can remove blips
    ['createmarker'] = 'admin',   -- Only admins can create markers
    ['removemarker'] = 'admin'    -- Only admins can remove markers
}

-- Feature Flags
Config.UseGsBlips = true         -- Enable gs_blips integration when available (true/False)

-- gs_blips specific configurations
Config.GsBlips = {
    DefaultCategory = 'Misc',     -- Default category for uncategorized blips
    UseJobCategories = true,      -- Group blips by job categories
    EnableDescriptions = true     -- Enable detailed descriptions in gs_blips info boxes
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
    ['CYLINDER'] = 1,
    ['ARROW'] = 2,
    ['RING'] = 25,
    ['CHEVRON'] = 27,
    ['HORIZONTAL_CIRCLE'] = 28,
    ['VERTICAL_CIRCLE'] = 29,
    ['PLANE'] = 33,
    ['CAR'] = 36,
    ['BIKE'] = 37,
    ['NUMBER'] = 42
}

Config.DefaultMarker = {
    Type = 1,           -- Cylinder
    Scale = 1.0,
    Color = {
        r = 255,        -- Red
        g = 0,          -- Green
        b = 0,          -- Blue
        a = 200         -- Alpha/Transparency
    }
}

Config.DefaultMarkerDistance = 50.0  -- Distance to start rendering markers

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
