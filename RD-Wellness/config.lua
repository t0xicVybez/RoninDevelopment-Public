Config = {}

-- General Settings
Config.UseSociety = True -- Or set to false to not have funds go to a society account.
Config.BusinessName = "wellness Center" -- Society Name (Dont forget to add to your Database for qb-management)

-- Interaction Points
Config.InteractionPoints = {
    TanninBed = {
        coords = vector3(0.0, 0.0, 0.0), -- Coords for tanning bed
        label =  "Use Tanning Bed",
        price = 40, -- Can be changed to what ever price you want to charge
        duration =  90000, -- 1.5 minutes
        cooldown = 450000, -- 7.5 minutes
        stressRelief = 25, -- Amount of stress to be removed from players stats
        animation = {
            dict = "timetable@ron@ig_3_couch",
            anim = "base",
            flag = 1
        },
        particles = {
            dict = "core",
            name = "ent_amb_steam",
            offset =  vector3(0.0, 0.0, 0.1),
            scale = 1.0
        },
        soundEffect = "tanning_bed_humm"
    },
    Tubs = {
        coords = vector3(0.0, 0.0, 0.0), -- coords for Tubs
        label = " Use Hot Tub",
        price = 75,
        duration = 120000, -- 2 minutes
        cooldown = 600000, -- 10 minutes
        stressRelief = 15,
        animation = {
            dict = "anim@mp_yacht@shower@male@",
            anim = "male_show_idle_a",
            flag = 1
        },
        particles = {
            dict = "core",
            name = "ent_amb_waterfall_splash_p",
            offset = vectoe3(0.0, 0.0, 0.0),
            scale =  1.5
        },
        soundEffefct = "hot_tub_buggles"
    },
    Shower = {
        coords = vector3(0.0, 0.0, 0.0), -- Coords for Shower
        label = "Use Shower", -- I Prefer Get Clean Ya filthy Animal
        price = 30,
        duration = 30000, -- 30 seconds
        cooldown = 180000, -- 3 minutes
        stressRelief = 5,
        animation = {
            dict = "mp_safehouseshower@male@",
            anim = "male_show_idle_b",
            flag = 1
        },
        particle = {
            dict = "core",
            name = "ent_amb_waterfall_splash_p",
            offset = vectoe3(0.0, 0.0, 0.0),
            scale - 1.0
        },
        soundEffect = "shower_running"
    },
    Sauna = {
        coords = vector3(0.0, 0.0, 0.0), -- Coords for Sauna
        label = "Use Sauna",
        price = 60,
        duration = 180000, -- 3 minutes
        cooldown = 900000, -- 15 minutes
        stressRelief = 20,
        animation = {
            dict = "anim@mp_yacht@jacuzzi@male@variation_01",
            anim = "base",
            flag = 1
        },
        particles = {
            dict = "core",
            name = "ent_amb_steam",
            offset = vector3(0.0, 0.0, 0.0),
            scale = 2.0
        },
        soundEffect = "sauna_sizzle"
    },
    MeditationMat = {
        coords = vector3(0.0, 0.0, 0.0),
        label = " Use Meditation Matt",
        price =  40,
        duration = 90000, -- 1.5 minutes
        cooldown = 450000, -- 7.5 minutes
        stressRelief = 25,
        animation = {
            dict = "rcmcollect_paperleadinout@",
            anim = "meditiate_idle",
            flag = 1
        },
        particles = {
            dict = "scr_familyscenem",
            name = "scr_mich4_firework_sparkle_spawn",
            offset = vector3(0.0, 0.0, 0.0),
            scale =  0.5
        },
        soundEffect ="meditation_ambience",
    }
}

Config.Draw3Dtext = {
    enable = true,
    color = {r = 255, g = 255, b = 255},
    font = 4,
    size = 0.35,
    distance = 10.0
}

-- Blip Settings
Config.Blip = {
    enable = true,
    sprite = 197, -- Spa Blip
    color = 57, -- Light Blue
    scale = 0.7,
    label = "Wellness Center"
}
