local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local markers = {}
local blips = {}

-- Initialize Lang
Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})

-- Forward declare functions
local LoadBlips, LoadMarkers, UpdateBlipsForJob, CreateBlipForCoords, CreateMarkerAt

-- Function to create a blip
CreateBlipForCoords = function(data)
    local x = tonumber(data.coords.x)
    local y = tonumber(data.coords.y)
    local z = tonumber(data.coords.z)
    
    local blip = AddBlipForCoord(x, y, z)
    
    if not DoesBlipExist(blip) then
        return nil
    end
    
    local sprite = tonumber(data.sprite)
    if sprite >= 1 and sprite <= 826 then
        SetBlipSprite(blip, sprite)
    else
        SetBlipSprite(blip, 1)
    end

    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, tonumber(data.scale))
    SetBlipColour(blip, tonumber(data.color))
    SetBlipAsShortRange(blip, false)
    
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(data.description)
    EndTextCommandSetBlipName(blip)
    
    return blip
end

-- Function to create a marker
CreateMarkerAt = function(data)
    local marker = {
        coords = data.coords,
        type = tonumber(data.type),
        scale = tonumber(data.scale),
        color = {
            r = tonumber(data.color.r),
            g = tonumber(data.color.g),
            b = tonumber(data.color.b),
            a = tonumber(data.color.a)
        },
        description = data.description,
        id = data.id
    }
    
    markers[#markers + 1] = marker
    return marker
end

-- Function to load blips from database
LoadBlips = function()
    if not PlayerData.job then return end
    
    QBCore.Functions.TriggerCallback('rd-blips:server:getBlips', function(dbBlips)
        if not dbBlips then return end
        
        for _, data in ipairs(dbBlips) do
            if data.job == 'all' or data.job == PlayerData.job.name then
                local blipData = {
                    coords = json.decode(data.coords),
                    sprite = data.sprite,
                    scale = data.scale,
                    color = data.color,
                    description = data.description,
                    id = data.id,
                    job = data.job
                }
                local blip = CreateBlipForCoords(blipData)
                if blip then
                    blips[#blips + 1] = {handle = blip, data = blipData}
                end
            end
        end
    end)
end

-- Function to load markers from database
LoadMarkers = function()
    QBCore.Functions.TriggerCallback('rd-blips:server:getMarkers', function(dbMarkers)
        if not dbMarkers then return end
        
        for _, data in ipairs(dbMarkers) do
            local markerData = {
                coords = json.decode(data.coords),
                type = data.type,
                scale = data.scale,
                color = json.decode(data.color),
                description = data.description,
                id = data.id
            }
            CreateMarkerAt(markerData)
        end
    end)
end

-- Function to update blips based on job
UpdateBlipsForJob = function(jobName)
    -- Clear existing blips first
    for _, blip in ipairs(blips) do
        if DoesBlipExist(blip.handle) then
            RemoveBlip(blip.handle)
        end
    end
    blips = {} -- Reset blips table
    
-- Load all blips and filter by job
QBCore.Functions.TriggerCallback('rd-blips:server:getBlips', function(dbBlips)
    if not dbBlips then return end
    
    for _, data in ipairs(dbBlips) do
        -- Check if blip is for all jobs or matches current job
        if data.job == 'all' or data.job == jobName then
            local blipData = {
                coords = type(data.coords) == 'string' and json.decode(data.coords) or data.coords,
                sprite = data.sprite,
                scale = data.scale,
                color = data.color,
                description = data.description,
                id = data.id,
                job = data.job
            }
            local blip = CreateBlipForCoords(blipData)
            if blip then
                blips[#blips + 1] = {handle = blip, data = blipData}
            end
        end
    end
end)
end

-- Register Commands
RegisterCommand('createblip', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    local dialog = exports['qb-input']:ShowInput({
        header = "Create Blip",
        submitText = "Create",
        inputs = {
            {
                type = 'number',
                name = 'sprite',
                text = 'Sprite (0-826)',
                isRequired = true,
                default = 1,
            },
            {
                type = 'number',
                name = 'scale',
                text = 'Scale (0.0-10.0)',
                isRequired = true,
                default = 0.8,
            },
            {
                type = 'number',
                name = 'color',
                text = 'Color (0-85)',
                isRequired = true,
                default = 1,
            },
            {
                type = 'text',
                name = 'description',
                text = 'Description',
                isRequired = true,
            },
            {
                type = 'text',
                name = 'job',
                text = 'Job (leave empty for all)',
                isRequired = false,
                default = 'all',
            }
        }
    })

    if dialog ~= nil then
        local blipData = {
            coords = coords,
            sprite = tonumber(dialog.sprite) or 1,
            scale = tonumber(dialog.scale) or 0.8,
            color = tonumber(dialog.color) or 1,
            description = dialog.description,
            job = (dialog.job ~= "" and dialog.job) or "all"
        }
        TriggerServerEvent('rd-blips:server:createBlip', blipData)
    end
end)

RegisterCommand('createmarker', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    local ground = 0
    local groundFound, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, true)
    if groundFound then
        ground = groundZ
    end
    
    local dialog = exports['qb-input']:ShowInput({
        header = "Create Marker",
        submitText = "Create",
        inputs = {
            {
                type = 'number',
                name = 'type',
                text = 'Type (1-43)',
                isRequired = true,
                default = 1,
            },
            {
                type = 'number',
                name = 'scale',
                text = 'Scale (0.5-5.0)',
                isRequired = true,
                default = 1.0,
            },
            {
                type = 'number',
                name = 'red',
                text = 'Red (0-255)',
                isRequired = true,
                default = 255,
            },
            {
                type = 'number',
                name = 'green',
                text = 'Green (0-255)',
                isRequired = true,
                default = 0,
            },
            {
                type = 'number',
                name = 'blue',
                text = 'Blue (0-255)',
                isRequired = true,
                default = 0,
            },
            {
                type = 'number',
                name = 'alpha',
                text = 'Alpha (0-255)',
                isRequired = true,
                default = 200,
            },
            {
                type = 'text',
                name = 'description',
                text = 'Description',
                isRequired = true,
            }
        }
    })

    if dialog ~= nil then
        local scale = tonumber(dialog.scale) or 1.0
        if scale < 0.5 or scale > 5.0 then
            QBCore.Functions.Notify('Scale must be between 0.5 and 5.0', 'error')
            return
        end

        local markerData = {
            coords = vector3(coords.x, coords.y, ground),
            type = tonumber(dialog.type) or 1,
            scale = scale,
            color = {
                r = tonumber(dialog.red) or 255,
                g = tonumber(dialog.green) or 0,
                b = tonumber(dialog.blue) or 0,
                a = tonumber(dialog.alpha) or 200
            },
            description = dialog.description
        }
        TriggerServerEvent('rd-blips:server:createMarker', markerData)
    end
end)

RegisterCommand('removeblip', function(source, args)
    local description = args[1]
    if description then
        for i, blip in ipairs(blips) do
            if blip.data.description == description then
                if DoesBlipExist(blip.handle) then
                    RemoveBlip(blip.handle)
                end
                TriggerServerEvent('rd-blips:server:removeBlip', blip.data.id)
                table.remove(blips, i)
                break
            end
        end
    else
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local closestDist = math.huge
        local closestBlip = nil
        local closestIndex = nil

        for i, blip in ipairs(blips) do
            local dist = #(coords - vector3(blip.data.coords.x, blip.data.coords.y, blip.data.coords.z))
            if dist < closestDist then
                closestDist = dist
                closestBlip = blip
                closestIndex = i
            end
        end

        if closestBlip and closestDist < Config.DefaultMarkerDistance then
            if DoesBlipExist(closestBlip.handle) then
                RemoveBlip(closestBlip.handle)
            end
            TriggerServerEvent('rd-blips:server:removeBlip', closestBlip.data.id)
            table.remove(blips, closestIndex)
        else
            QBCore.Functions.Notify('You are too far from any blip', 'error')
        end
    end
end)

RegisterCommand('removemarker', function(source, args)
    local description = args[1]
    if description then
        for i, marker in ipairs(markers) do
            if marker.description == description then
                TriggerServerEvent('rd-blips:server:removeMarker', marker.id)
                table.remove(markers, i)
                break
            end
        end
    else
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local closestDist = math.huge
        local closestMarker = nil
        local closestIndex = nil

        for i, marker in ipairs(markers) do
            local dist = #(coords - vector3(marker.coords.x, marker.coords.y, marker.coords.z))
            if dist < closestDist then
                closestDist = dist
                closestMarker = marker
                closestIndex = i
            end
        end

        if closestMarker and closestDist < Config.DefaultMarkerDistance then
            TriggerServerEvent('rd-blips:server:removeMarker', closestMarker.id)
            table.remove(markers, closestIndex)
        else
            QBCore.Functions.Notify('You are too far from any marker', 'error')
        end
    end
end)

-- Events
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    Wait(1000) -- Wait a second for everything to initialize
    LoadBlips()
    LoadMarkers()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
    Wait(100) -- Small delay to ensure job update is processed
    UpdateBlipsForJob(JobInfo.name)
end)

RegisterNetEvent('IF-multijob:client:changeJob', function(job)
    if not job then return end
    PlayerData.job = job
    Wait(100) -- Small delay to ensure job update is processed
    UpdateBlipsForJob(job.name)
end)

RegisterNetEvent('rd-blips:client:markerCreated', function(markerData)
    local marker = CreateMarkerAt(markerData)
    if marker then
        QBCore.Functions.Notify('Marker created successfully', 'success')
    else
        QBCore.Functions.Notify('Failed to create marker', 'error')
    end
end)

RegisterNetEvent('rd-blips:client:blipCreated', function(blipData)
    if not PlayerData.job then return end
    
    if blipData.job == 'all' or blipData.job == PlayerData.job.name then
        local blip = CreateBlipForCoords(blipData)
        if blip then
            blips[#blips + 1] = {handle = blip, data = blipData}
            QBCore.Functions.Notify('Blip created successfully', 'success')
        end
    end
end)

RegisterNetEvent('QBCore:Client:SetPlayerData', function(val)
    PlayerData = val
    if PlayerData.job then
        Wait(100) -- Small delay to ensure job update is processed
        UpdateBlipsForJob(PlayerData.job.name)
    end
end)

-- Draw markers
CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        for _, marker in ipairs(markers) do
            local distance = #(coords - vector3(marker.coords.x, marker.coords.y, marker.coords.z))
            if distance < Config.DefaultMarkerDistance then
                sleep = 0
                DrawMarker(
                    marker.type,
                    marker.coords.x,
                    marker.coords.y,
                    marker.coords.z,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    marker.scale, marker.scale, marker.scale,
                    marker.color.r,
                    marker.color.g,
                    marker.color.b,
                    marker.color.a,
                    false,
                    false,
                    2,
                    false,
                    nil,
                    nil,
                    false
                )
            end
        end
        Wait(sleep)
    end
end)

-- Initialize script
CreateThread(function()
    while not QBCore do
        Wait(100)
    end
    
    PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData then
        LoadBlips()
        LoadMarkers()
    end
end)