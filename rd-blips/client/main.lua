local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local markers = {}
local blips = {}
local gsBlips = {} -- Track gs_blips handles

-- Initialize Lang
Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})

-- Forward declare functions
local LoadBlips, LoadMarkers, UpdateBlipsForJob, CreateBlipForCoords, CreateMarkerAt, GetBlipByHandle, DeleteBlip

-- Function to create structured blip data
local function CreateBlipMetadata(data, category)
    local locationName = data.description
    local locationDetails = data.details or "No additional information available"
    
    -- Create emoji prefix based on job/category
    local emojiPrefix = Config.JobEmojis[data.job] or "📍"
    
    return {
        title = emojiPrefix .. " " .. locationName,
        description = locationDetails,
        category = category or (data.job ~= 'all' and data.job or Config.GsBlips.DefaultCategory),
        lastUpdate = os.date("%Y-%m-%d %H:%M:%S")
    }
end

-- Function to create dynamic display handler
local function CreateDisplayHandler(blipHandle, data)
    return function()
        -- Get current player distance to blip
        local playerCoords = GetEntityCoords(PlayerPedId())
        local blipCoords = vector3(data.coords.x, data.coords.y, data.coords.z)
        local distance = #(playerCoords - blipCoords)
        
        -- Update description with distance
        local updatedDescription = string.format("%s\nDistance: %.1f meters", 
            data.details or data.description,
            distance
        )
        
        -- Update the blip's description
        if GetResourceState('gs_blips') == 'started' then
            exports.gs_blips:GetBlip(blipHandle).setDescription(updatedDescription)
        end
    end
end

-- Enhanced function to create a blip with gs_blips support
CreateBlipForCoords = function(data)
    local x = tonumber(data.coords.x)
    local y = tonumber(data.coords.y)
    local z = tonumber(data.coords.z)
    
    -- Check if gs_blips is available and enabled
    if GetResourceState('gs_blips') == 'started' and Config.UseGsBlips then
        local blipMetadata = CreateBlipMetadata(data)
        local gsBlip = exports.gs_blips:CreateBlip({
            coords = vector3(x, y, z),
            sprite = tonumber(data.sprite),
            scale = tonumber(data.scale),
            color = tonumber(data.color),
            label = data.description,
            category = blipMetadata.category,
            data = blipMetadata
        })
        
        -- Set up dynamic display handler
        if gsBlip and Config.GsBlips.EnableDynamicDisplay then
            gsBlip.setDisplayHandler(CreateDisplayHandler(gsBlip, data))
        end
        
        return gsBlip
    else

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
end

-- Function to get a blip by its handle
GetBlipByHandle = function(handle)
    if GetResourceState('gs_blips') == 'started' and Config.UseGsBlips then
        return exports.gs_blips:GetBlip(handle)
    end
    return nil
end

-- Function to delete a blip
DeleteBlip = function(handle)
    if GetResourceState('gs_blips') == 'started' and Config.UseGsBlips then
        return exports.gs_blips:DeleteBlip(handle)
    else
        if DoesBlipExist(handle) then
            RemoveBlip(handle)
            return true
        end
    end
    return false
end

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

-- Enhanced function to load blips from database
LoadBlips = function()
    if not PlayerData.job then return end
    
    QBCore.Functions.TriggerCallback('rd-blips:server:getBlips', function(dbBlips)
        if not dbBlips then return end
        
        -- Clear existing blips first
        if GetResourceState('gs_blips') == 'started' and Config.UseGsBlips then
            for _, blip in ipairs(gsBlips) do
                if blip.handle then
                    DeleteBlip(blip.handle)
                end
            end
            gsBlips = {}
        else
            for _, blip in ipairs(blips) do
                if blip.handle then
                    DeleteBlip(blip.handle)
                end
            end
            blips = {}
        end
        
        -- Group blips by category for batch processing
        local blipsByCategory = {}
        for _, data in ipairs(dbBlips) do
            if data.job == 'all' or data.job == PlayerData.job.name then
                local category = data.job ~= 'all' and data.job or Config.GsBlips.DefaultCategory
                blipsByCategory[category] = blipsByCategory[category] or {}
                table.insert(blipsByCategory[category], data)
            end
        end
        
        -- Process blips by category
        for category, categoryBlips in pairs(blipsByCategory) do
            for _, data in ipairs(categoryBlips) do
                local blipData = {
                    coords = json.decode(data.coords),
                    sprite = data.sprite,
                    scale = data.scale,
                    color = data.color,
                    description = data.description,
                    details = data.details, -- Additional field for rich descriptions
                    id = data.id,
                    job = data.job
                }
                
                local blip = CreateBlipForCoords(blipData)
                if blip then
                    if GetResourceState('gs_blips') == 'started' and Config.UseGsBlips then
                        -- Store additional metadata for gs_blips
                        gsBlips[#gsBlips + 1] = {
                            handle = blip,
                            data = blipData,
                            category = category,
                            lastUpdate = os.time()
                        }
                    else
                        blips[#blips + 1] = {handle = blip, data = blipData}
                    end
                end
            end
        end
    end)
end

-- Function to load markers from database (unchanged)
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

-- Enhanced function to update blips based on job
UpdateBlipsForJob = function(jobName)
    -- Clear existing blips with proper cleanup
    if GetResourceState('gs_blips') == 'started' and Config.UseGsBlips then
        for _, blip in ipairs(gsBlips) do
            if blip.handle then
                -- Properly clean up any display handlers
                local gsBlip = GetBlipByHandle(blip.handle)
                if gsBlip and gsBlip.setDisplayHandler then
                    gsBlip.setDisplayHandler(nil)
                end
                DeleteBlip(blip.handle)
            end
        end
        gsBlips = {}
    else
        for _, blip in ipairs(blips) do
            if blip.handle then
                DeleteBlip(blip.handle)
            end
        end
        blips = {}
    end
    
    -- Reload blips with the new job filter
    LoadBlips()
end

-- Function to refresh blip display handlers
local function RefreshBlipDisplayHandlers()
    if not GetResourceState('gs_blips') == 'started' or not Config.UseGsBlips then return end
    
    for _, blip in ipairs(gsBlips) do
        if blip.handle then
            local gsBlip = GetBlipByHandle(blip.handle)
            if gsBlip and gsBlip.setDisplayHandler then
                gsBlip.setDisplayHandler(CreateDisplayHandler(blip.handle, blip.data))
            end
        end
    end
end

-- Create a thread to periodically refresh display handlers
CreateThread(function()
    while true do
        if Config.GsBlips.EnableDynamicDisplay then
            RefreshBlipDisplayHandlers()
        end
        Wait(Config.GsBlips.DisplayRefreshRate or 1000)
    end
end)

-- Enhanced createblip command with expanded options
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
                text = 'Title/Name',
                isRequired = true,
            },
            {
                type = 'text',
                name = 'details',
                text = 'Detailed Description',
                isRequired = false,
            },
            {
                type = 'text',
                name = 'job',
                text = 'Job/Category (leave empty for all)',
                isRequired = false,
                default = 'all',
            },
            {
                type = 'checkbox',
                name = 'dynamic',
                text = 'Enable Dynamic Updates',
                isRequired = false,
                default = true,
            }
        }
    })

    if dialog then
        local blipData = {
            coords = coords,
            sprite = tonumber(dialog.sprite) or 1,
            scale = tonumber(dialog.scale) or 0.8,
            color = tonumber(dialog.color) or 1,
            description = dialog.description,
            details = dialog.details ~= "" and dialog.details or dialog.description,
            job = (dialog.job ~= "" and dialog.job) or "all",
            dynamic = dialog.dynamic
        }

        if GetResourceState('gs_blips') == 'started' and Config.UseGsBlips then
            -- Create blip using gs_blips with enhanced features
            local gsBlip = exports.gs_blips:CreateBlip({
                coords = vector3(coords.x, coords.y, coords.z),
                sprite = blipData.sprite,
                scale = blipData.scale,
                color = blipData.color,
                label = blipData.description,
                category = blipData.job ~= 'all' and blipData.job or Config.GsBlips.DefaultCategory,
                data = {
                    title = (Config.JobEmojis[blipData.job] or "📍") .. " " .. blipData.description,
                    description = blipData.details,
                }
            })

            if gsBlip and blipData.dynamic then
                gsBlip.setDisplayHandler(CreateDisplayHandler(gsBlip, blipData))
            end

            -- Store the blip data
            gsBlips[#gsBlips + 1] = {
                handle = gsBlip,
                data = blipData,
                category = blipData.job,
                lastUpdate = os.time()
            }
        end

        TriggerServerEvent('rd-blips:server:createBlip', blipData)
    end
end)

-- Enhanced removeblip command with expanded functionality
RegisterCommand('removeblip', function(source, args)
    local description = args[1]
    if description then
        local blipList = GetResourceState('gs_blips') == 'started' and Config.UseGsBlips and gsBlips or blips
        for i, blip in ipairs(blipList) do
            if blip.data.description == description then
                -- Proper cleanup of gs_blips features
                if GetResourceState('gs_blips') == 'started' and Config.UseGsBlips then
                    local gsBlip = GetBlipByHandle(blip.handle)
                    if gsBlip then
                        if gsBlip.setDisplayHandler then
                            gsBlip.setDisplayHandler(nil)
                        end
                        DeleteBlip(blip.handle)
                    end
                else
                    DeleteBlip(blip.handle)
                end
                
                TriggerServerEvent('rd-blips:server:removeBlip', blip.data.id)
                table.remove(blipList, i)
                QBCore.Functions.Notify('Blip removed successfully', 'success')
                break
            end
        end
    else
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local closestDist = math.huge
        local closestBlip = nil
        local closestIndex = nil
        local blipList = GetResourceState('gs_blips') == 'started' and Config.UseGsBlips and gsBlips or blips

        for i, blip in ipairs(blipList) do
            local dist = #(coords - vector3(blip.data.coords.x, blip.data.coords.y, blip.data.coords.z))
            if dist < closestDist then
                closestDist = dist
                closestBlip = blip
                closestIndex = i
            end
        end

        if closestBlip and closestDist < Config.DefaultMarkerDistance then
            -- Proper cleanup of gs_blips features
            if GetResourceState('gs_blips') == 'started' and Config.UseGsBlips then
                local gsBlip = GetBlipByHandle(closestBlip.handle)
                if gsBlip then
                    if gsBlip.setDisplayHandler then
                        gsBlip.setDisplayHandler(nil)
                    end
                    DeleteBlip(closestBlip.handle)
                end
            else
                DeleteBlip(closestBlip.handle)
            end

            TriggerServerEvent('rd-blips:server:removeBlip', closestBlip.data.id)
            table.remove(blipList, closestIndex)
            QBCore.Functions.Notify('Closest blip removed successfully', 'success')
        else
            QBCore.Functions.Notify('You are too far from any blip', 'error')
        end
    end
end)

-- Keep original marker commands unchanged
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

-- Enhanced Events
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    Wait(1000) -- Wait a second for everything to initialize
    
    -- Initialize gs_blips categories if available
    if GetResourceState('gs_blips') == 'started' and Config.UseGsBlips then
        -- Set up job-based categories
        for job, emoji in pairs(Config.JobEmojis) do
            exports.gs_blips:SetupCategory(job, {
                label = emoji .. ' ' .. (job:gsub("^%l", string.upper)),
                color = Config.JobColors[job] or 0
            })
        end
    end
    
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
            -- Enhanced blip storage with proper metadata
            if GetResourceState('gs_blips') == 'started' and Config.UseGsBlips then
                local gsBlip = GetBlipByHandle(blip)
                if gsBlip then
                    -- Set up dynamic display if enabled
                    if Config.GsBlips.EnableDynamicDisplay and blipData.dynamic then
                        gsBlip.setDisplayHandler(CreateDisplayHandler(blip, blipData))
                    end
                    
                    -- Store with enhanced metadata
                    gsBlips[#gsBlips + 1] = {
                        handle = blip,
                        data = blipData,
                        category = blipData.job,
                        lastUpdate = os.time()
                    }
                end
            else
                blips[#blips + 1] = {handle = blip, data = blipData}
            end
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

-- Enhanced marker drawing thread with optimization
CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local hasNearbyMarker = false

        for _, marker in ipairs(markers) do
            local distance = #(coords - vector3(marker.coords.x, marker.coords.y, marker.coords.z))
            if distance < Config.DefaultMarkerDistance then
                hasNearbyMarker = true
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

        -- Optimize sleep based on marker proximity
        if hasNearbyMarker then
            sleep = 0
        end
        
        Wait(sleep)
    end
end)

-- Enhanced gs_blips management thread
CreateThread(function()
    while true do
        if GetResourceState('gs_blips') == 'started' and Config.UseGsBlips and Config.GsBlips.EnableDynamicDisplay then
            local currentTime = os.time()
            
            -- Update dynamic displays and cleanup stale blips
            for i = #gsBlips, 1, -1 do
                local blip = gsBlips[i]
                if blip and blip.handle then
                    local gsBlip = GetBlipByHandle(blip.handle)
                    if gsBlip then
                        -- Check if display handler needs refresh
                        if currentTime - (blip.lastUpdate or 0) >= Config.GsBlips.DisplayRefreshRate then
                            if blip.data.dynamic then
                                gsBlip.setDisplayHandler(CreateDisplayHandler(blip.handle, blip.data))
                            end
                            blip.lastUpdate = currentTime
                        end
                    else
                        -- Clean up invalid blips
                        table.remove(gsBlips, i)
                    end
                end
            end
        end
        
        Wait(Config.GsBlips.ManagementThreadRate or 5000)
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
