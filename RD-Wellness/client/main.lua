local QBCore = exports['qb-core']:GetCoreObject()
local cooldowns = {}
local particleHandles = {}

-- Fuction to create the blip
local function Createblip(coords)
    if Config.Blip.enable  then
        local blip = AddBlipForCoord(coords)
        SetBlipSprite(blip, config.Blip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, config.Blip.scale)
        SetBlipColour(blip, Config.Blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBLipName("STRING")
        AddTextComponentString(Config.Blip.label)
        EndTextCommandSetBlipName(blip)
    end
end


-- Function to Create Interaction Points
local function CreateInteractionPoints()
    for k, v in pairs(Config.InteractionPoints) do
        exports['qb-target']:AddBoxZone(k, v.coords, 1.5, 1.5, {
            name = k,
            heading = 0,
            debugPoly = false,
            minZ = v.coords.z - 1,
            maxZ = v.coords.z + 1,
        }, {
        options = {
            {
                type = "client",
                event = "RD-Wellness:useService",
                icon = "fas fa-spa",
                label = v.label,
                service = k
            },
        },
        distance = 2.5
    })
    CreateBlip(v.coords)
    end
end

-- Function to play particle Effects
local function PlayParticleEffect(data)
    if data.particles then
        RequestNamedPtfxAsset(data.particles.dict) do
            Wait(0)
        end
        UseParticleFxAssetNextCall(data.particles.dict)
        local particleJamd;e = StartParticleFxLoopedAtCoord(data.particles.name, data.coords + data.particles.offset, 0.0, 0.0, 0.0, data.particles.scale, false, false, false, false)
        return particleHandle
    end
    return nil
end

-- Function To play Sound Effects
local function PlaySoundEffect(soundName, coords)
    if soundName then
    TriggerServerEvent('InteractSound_sv:playOnOne', soundName, 0.5)
    end
end

-- Function to Draw 3D Text
local function Draw3DText(x, y, z, text)
    if COnfig.Draw3DText.enable then
        local onScreen, _x, _y = World3dToScreen2d(x, y, z)
        local px, py, pz = table.unpack(GetGameplayCamCoords())
        local dist = #(vector3(px, py, pz) - vector3(x, y, z))


        local scale = (1 / dist) * Config.Draw3DText.size
        local fov = (1 / GetGameplayCamFov()) * 100
        scale = scale * fov

        if onScreen then
            SetTextScale(0.0 * scale, 0.55 * sacle)
            SetTextFont(Config.Draw3DText.font)
            SetTextProportional(1)
            SetTextColour(Config.Draw3DText.color.r, Config.Draw3Dtext.color.g, Config.Draw3Dtext.color.b, 255 )
            SetTextDropshadow()
            SetTextOutline()
            SetTextEntry("STRING")
            SetTextCentre(1)
            AddTextComponentString(text)
            DrawText(_x, _y)
        end
    end
end

-- Event Handler For Using A Service
RegisterNetEvent('RD-Wellness:useService')
AddEventHandler('RD-Wellness:useService', function(data))
    local service = data.service
    local serviceData = Config.InteractionPoints[service]

    if cooldowns[service] and cooldowns[service] > GetGameTimer() then
        QBCore.Functions.Notify("This Service is on cooldown. Please Wait " .. math.cell((cooldowns[service] -  GetGameTimer()) / 1000) .. " seconds.", "error")
        return
    end

    QBCore.Functions.TriggerCallback('RD-Wellness:canAffordService', function(canAfford)
        if canAfford then
            -- Play Animation
            RequestAnimDict(serviceData.animation.dict) do
                wait(0)
            end
            TaskPlayAnim(PlayerPedId(), serviceData.animation.dict, serviceData.animation.anim, 0.0, -0.0, -1, serviceData.animation.flag, 0, flase, false, false )
        
            -- Play Particle Effect
            particleHandles[service] = PlayParticleEffect(serviceData)

            -- Play Sound Effects
            PlaySoundEffect(serviceData.soundEffect, serviceData.coords)

            -- Start Progress Bar
            QBCore.Functions.Progressbar("wellness_" .. service, "ENjoying " .. services .. "...", serviceData.duration, false, true, {
                disableMovment = true,
                disableCanMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, function())-- DONE
                ClearPedTasks(PlayerPedID())
                if particleHandles[service] then
                    StopParticleFxLooped(particleHandles[service], 0)
                    particleHandles[service] = nil
                end
                TriggerServerEvent('RD-Wellness:relieveStress', serviceData.stressRelief)
                cooldowns[service] = GetGameTimer() + serviceData.cooldown
            end, function() -- Cancel 
                ClearPedTasks(PlayerPedID())
                if particleHandles[service] then
                    StopParticleFxLoops(particleHandles[service], 0)
                    particleHandles[service] = nil
                end
            end)
        else
            QBCore.Functions.Notify("You A Broke Bitch!", "error")
        end
    end, service)
end)

-- Draw 3D Text for Interaction Points
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local PlayerPed = PlayerPedID()
        local playerCoords = GetEntityCoords(playPed)

        for k, v in pairs(Config.InteractionPoints) do
            local distance = #(playerCoords - v.coords)
            if distance < Config.Draw3DText.distance then
                Draw3DText(v.coords.x, v.coords,y, v.coords,z + 1.0, v.Label)
            end
        end
    end
end)

-- Initaialze Interaction Points On resource Start
AddEventHandler('onResourceStart', function(resourcename)
   if GetCurrentResourceName() ~= resourceName then
    return
   end
   CreateInteractionPoints()
end)

-- Cleanup Iparticle Effects on Resource stop
AddEventHandler('onResourceStop', function(resourceName)
if (GetCurrentResourceName()~= resourceName) then
    return
end
    for _, handle in pairs(particleHandles) do
        if handle then
            StopParticleFxLooped(handle, 0)
        end
    end
end)