Config = {}

-- Framework Configuration
Config.Framework = 'auto'  -- 'auto', 'qb', or 'qbx'

-- Command Permissions
Config.Commands = {
    ['createblip'] = 'admin',     -- Only admins can create blips
    ['removeblip'] = 'admin',     -- Only admins can remove blips
    ['createmarker'] = 'admin',   -- Only admins can create markers
    ['removemarker'] = 'admin'    -- Only admins can remove markers
}

-- Feature Flags
Config.UseGsBlips = true         -- Enable gs_blips integration when available (true/false)

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

-- Job and JobType Configuration
Config.UseJobTypes = true              -- Enable jobtype-based blip filtering
Config.DefaultJobType = 'all'          -- Default jobtype if none specified

Config.JobTypeCategories = {           -- Group jobs by type
    ['leo'] = {'police', 'sheriff', 'statepolice'},
    ['medical'] = {'ambulance', 'doctor'},
    ['mechanic'] = {'mechanic', 'tuner'},
    ['business'] = {'taxi', 'realtor', 'restaurant'},
    ['all'] = {'all'}
}

-- gs_blips Configuration
Config.GsBlips = {
    DefaultCategory = 'General',           -- Default category for uncategorized blips
    EnableDynamicDisplay = true,           -- Enable dynamic display updates (distance, etc.)
    DisplayRefreshRate = 1000,             -- How often to refresh dynamic displays (ms)
    ManagementThreadRate = 5000,           -- How often to run the management thread (ms)
    UseJobCategories = true,               -- Group blips by job categories
    EnableDescriptions = true,             -- Enable detailed descriptions in gs_blips info boxes
    UseJobTypeCategories = true            -- Group blips by job type categories
}

-- Job-specific Configuration
Config.JobEmojis = {
    -- Law Enforcement
    ['police'] = '👮',
    ['sheriff'] = '👮',
    ['statepolice'] = '👮',
    -- Medical
    ['ambulance'] = '🚑',
    ['doctor'] = '⚕️',
    -- Service
    ['mechanic'] = '🔧',
    ['taxi'] = '🚕',
    ['realtor'] = '🏠',
    -- JobTypes
    ['leo'] = '🚔',
    ['medical'] = '🏥',
    ['mechanic'] = '🔧',
    ['business'] = '💼',
    -- Default
    ['all'] = '📍'
}

Config.JobColors = {
    -- Law Enforcement
    ['police'] = 3,      -- Blue
    ['sheriff'] = 3,     -- Blue
    ['statepolice'] = 3, -- Blue
    -- Medical
    ['ambulance'] = 1,   -- Red
    ['doctor'] = 1,      -- Red
    -- Service
    ['mechanic'] = 5,    -- Yellow
    ['taxi'] = 5,        -- Yellow
    ['realtor'] = 2,     -- Green
    -- JobTypes
    ['leo'] = 3,         -- Blue
    ['medical'] = 1,     -- Red
    ['mechanic'] = 5,    -- Yellow
    ['business'] = 2,    -- Green
    -- Default
    ['all'] = 0         -- White
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
    ['orange'] = 17
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

-- Default Marker Configuration
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

-- Helper function to get jobtype from job
Config.GetJobType = function(job)
    for jobType, jobs in pairs(Config.JobTypeCategories) do
        for _, jobName in ipairs(jobs) do
            if jobName == job then
                return jobType
            end
        end
    end
    return Config.DefaultJobType
end
