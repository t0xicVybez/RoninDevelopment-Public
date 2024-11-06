local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local markers = {}
local blips = {}

-- Function to create a blip
local function CreateBlipForCoords(data)
    local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
    SetBlipSprite(blip, data.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, data.scale)
    SetBlipColour(blip, data.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(data.description)
    EndTextCommandSetBlipName(blip)
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
        RemoveBlip(blip.handle)
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

-- Command to create a marker
RegisterCommand('createmarker', function()
    if not PlayerData.job then return end
    local dialog = exports['qb-input']:ShowInput({
        header = Lang:t('input.marker.header'),
        submitText = "Create",
        inputs = {
            {
                text = Lang:t('input.marker.type'), 
                name = "type",
                type = "number",
                isRequired = true
            },
            {
                text = Lang:t('input.marker.scale'), 
                name = "scale",
                type = "number",
                isRequired = true
            },
            {
                text = Lang:t('input.marker.description'),
                name = "description",
                type = "text",
                isRequired = true
            },
            {
                text = Lang:t('input.marker.red'),
                name = "red",
                type = "number",
                isRequired = true
            },
            {
                text = Lang:t('input.marker.green'),
                name = "green",
                type = "number",
                isRequired = true
            },
            {
                text = Lang:t('input.marker.blue'),
                name = "blue",
                type = "number",
                isRequired = true
            },
            {
                text = Lang:t('input.marker.alpha'),
                name = "alpha",
                type = "number",
                isRequired = true
            }
        }
    })

    if dialog then
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
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

-- Command to remove closest marker
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
            QBCore.Functions.Notify(Lang:t('info.distance_too_far', {value = "marker"}), 'error')
        end
    end
end)

-- Command to create a blip
RegisterCommand('createblip', function()
    if not PlayerData.job then return end
    local dialog = exports['qb-input']:ShowInput({
        header = Lang:t('input.blip.header'),
        submitText = "Create",
        inputs = {
            {
                text = Lang:t('input.blip.sprite'),
                name = "sprite",
                type = "number",
                isRequired = true
            },
            {
                text = Lang:t('input.blip.scale'),
                name = "scale",
                type = "number",
                isRequired = true
            },
            {
                text = Lang:t('input.blip.color'),
                name = "color",
                type = "number",
                isRequired = true
            },
            {
                text = Lang:t('input.blip.description'),
                name = "description",
                type = "text",
                isRequired = true
            },
            {
                text = Lang:t('input.blip.job'),
                name = "job",
                type = "text",
                isRequired = false
            }
        }
    })

    if dialog then
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local blipData = {
            coords = coords,
            sprite = tonumber(dialog.sprite),
            scale = tonumber(dialog.scale),
            color = tonumber(dialog.color),
            description = dialog.description,
            job = dialog.job ~= "" and dialog.job or "all"
        }
        TriggerServerEvent('rd-blips:server:createBlip', blipData)
    end
end)

-- Command to remove blip
RegisterCommand('removeblip', function(source, args)
    local description = args[1]
    if description then
        for i, blip in ipairs(blips) do
            if blip.data.description == description then
                RemoveBlip(blip.handle)
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
            RemoveBlip(closestBlip.handle)
            TriggerServerEvent('rd-blips:server:removeBlip', closestBlip.data.id)
            table.remove(blips, closestIndex)
        else
            QBCore.Functions.Notify(Lang:t('info.distance_too_far', {value = "blip"}), 'error')
        end
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
    QBCore.Functions.Notify(Lang:t('info.marker_created'), 'success')
end)

RegisterNetEvent('rd-blips:client:blipCreated', function(blipData)
    if blipData.job == 'all' or blipData.job == PlayerData.job.name then
        local blip = CreateBlipForCoords(blipData)
        blips[#blips + 1] = {handle = blip, data = blipData}
        QBCore.Functions.Notify(Lang:t('info.blip_created'), 'success')
    end
end)