local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local markers = {}
local blips = {}

-- Initialize Lang
Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})

-- Function to create a blip
local function CreateBlipForCoords(data)
    print("^2Creating blip with data^7")
    print("Coords:", data.coords.x, data.coords.y, data.coords.z)
    print("Sprite:", data.sprite)
    print("Scale:", data.scale)
    print("Color:", data.color)
    print("Description:", data.description)

    -- Create the blip at coordinates
    local x = tonumber(data.coords.x)
    local y = tonumber(data.coords.y)
    local z = tonumber(data.coords.z)
    
    local blip = AddBlipForCoord(x, y, z)
    
    if not DoesBlipExist(blip) then
        print("^1Failed to create blip^7")
        return nil
    end
    
    -- Set blip properties with error checking
    local sprite = tonumber(data.sprite)
    if sprite >= 1 and sprite <= 826 then
        SetBlipSprite(blip, sprite)
    else
        SetBlipSprite(blip, 1) -- Default to standard blip if invalid sprite
    end

    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, tonumber(data.scale))
    SetBlipColour(blip, tonumber(data.color))
    SetBlipAsShortRange(blip, false)
    
    -- Set blip name
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(data.description)
    EndTextCommandSetBlipName(blip)
    
    print("^2Successfully created blip^7:", blip)
    return blip
end

-- Function to create a marker
local function CreateMarkerAt(data)
    local marker = {
        coords = data.coords,
        type = data.type,
        scale = data.scale,
        color = data.color,
        description = data.description,
        id = data.id
    }
    markers[#markers + 1] = marker
    return marker
end

-- Function to update blips based on job
local function UpdateBlipsForJob(jobName)
    -- Remove existing blips
    for _, blip in ipairs(blips) do
        if DoesBlipExist(blip.handle) then
            RemoveBlip(blip.handle)
        end
    end
    blips = {}
    
    -- Reload blips for new job
    QBCore.Functions.TriggerCallback('rd-blips:server:getBlips', function(dbBlips)
        for _, data in ipairs(dbBlips) do
            if data.job == 'all' or data.job == jobName then
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
                blips[#blips + 1] = {handle = blip, data = blipData}
            end
        end
    end)
end

-- Function to load blips from database
local function LoadBlips()
    QBCore.Functions.TriggerCallback('rd-blips:server:getBlips', function(dbBlips)
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
                blips[#blips + 1] = {handle = blip, data = blipData}
            end
        end
    end)
end

-- Function to load markers from database
local function LoadMarkers()
    QBCore.Functions.TriggerCallback('rd-blips:server:getMarkers', function(dbMarkers)
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

-- Register Commands
RegisterCommand('createblip', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    local dialog = exports['qb-input']:ShowInput({
        header = "Create Blip",
        submitText = "Create",
        inputs = {
            {
                text = "Sprite (0-826)",
                name = "sprite",
                type = "number",
                isRequired = true
            },
            {
                text = "Scale (0.0-10.0)",
                name = "scale",
                type = "number",
                isRequired = true
            },
            {
                text = "Color (0-85)",
                name = "color",
                type = "number",
                isRequired = true
            },
            {
                text = "Description",
                name = "description",
                type = "text",
                isRequired = true
            },
            {
                text = "Job (leave empty for all)",
                name = "job",
                type = "text",
                isRequired = false
            }
        }
    })

    if dialog then
        local blipData = {
            coords = coords,
            sprite = tonumber(dialog.sprite),
            scale = tonumber(dialog.scale),
            color = tonumber(dialog.color),
            description = dialog.description,
            job = dialog.job ~= "" and dialog.job or "all"
        }
        print("Creating blip with data:", json.encode(blipData))
        TriggerServerEvent('rd-blips:server:createBlip', blipData)
    end
end)

RegisterCommand('createmarker', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    local dialog = exports['qb-input']:ShowInput({
        header = "Create Marker",
        submitText = "Create",
        inputs = {
            {
                text = "Type (0-43)",
                name = "type",
                type = "number",
                isRequired = true
            },
            {
                text = "Scale (0.0-10.0)",
                name = "scale",
                type = "number",
                isRequired = true
            },
            {
                text = "Description",
                name = "description",
                type = "text",
                isRequired = true
            },
            {
                text = "Red (0-255)",
                name = "red",
                type = "number",
                isRequired = true
            },
            {
                text = "Green (0-255)",
                name = "green",
                type = "number",
                isRequired = true
            },
            {
                text = "Blue (0-255)",
                name = "blue",
                type = "number",
                isRequired = true
            },
            {
                text = "Alpha (0-255)",
                name = "alpha",
                type = "number",
                isRequired = true
            }
        }
    })

    if dialog then
        local markerData = {
            coords = coords,
            type = tonumber(dialog.type),
            scale = tonumber(dialog.scale),
            color = {
                r = tonumber(dialog.red),
                g = tonumber(dialog.green),
                b = tonumber(dialog.blue),
                a = tonumber(dialog.alpha)
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
    LoadBlips()
    LoadMarkers()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
    UpdateBlipsForJob(JobInfo.name)
end)

-- IF-Multijob support
RegisterNetEvent('IF-multijob:client:changeJob', function(job)
    PlayerData.job = job
    UpdateBlipsForJob(job.name)
end)

RegisterNetEvent('rd-blips:client:markerCreated', function(markerData)
    CreateMarkerAt(markerData)
    QBCore.Functions.Notify('Marker created successfully', 'success')
end)

RegisterNetEvent('rd-blips:client:blipCreated', function(blipData)
    if blipData.job == 'all' or blipData.job == PlayerData.job.name then
        local blip = CreateBlipForCoords(blipData)
        blips[#blips + 1] = {handle = blip, data = blipData}
        QBCore.Functions.Notify('Blip created successfully', 'success')
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
                    false, false, 2, nil, nil, false
                )
            end
        end
        Wait(sleep)
    end
end)