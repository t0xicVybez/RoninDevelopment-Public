-- Framework Detection and Initialization
local QBCore = nil
local function InitializeFramework()
    if GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
        Config.Framework = 'qb'
        return true
    elseif GetResourceState('qbx-core') == 'started' then
        QBCore = exports['qbx-core']:GetCoreObject()
        Config.Framework = 'qbx'
        return true
    end
    return false
end

-- Initialize core variables
local PlayerData = {}
local markers = {}
local blips = {}
local gsBlips = {} -- Track gs_blips handles
local activeJobType = 'all'

-- Initialize Lang
Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})

-- Forward declare functions
local LoadBlips, LoadMarkers, UpdateBlipsForJob, CreateBlipForCoords, CreateMarkerAt
local GetBlipByHandle, DeleteBlip, UpdateBlipsForJobType, RefreshBlipDisplayHandlers

-- Framework-specific notification function
local function NotifyPlayer(message, type, duration)
    if Config.Framework == 'qbx' then
        QBCore.Functions.Notify({
            text = message,
            type = type,
            duration = duration or 3000
        })
    else
        QBCore.Functions.Notify(message, type, duration or 3000)
    end
end

-- Function to get player's current jobtype
local function GetPlayerJobType()
    if not PlayerData.job then return 'all' end
    return Config.GetJobType(PlayerData.job.name)
end

-- Function to check if player has access to blip
local function HasBlipAccess(blipData)
    if not PlayerData.job then return false end
    
    -- Check direct job match
    if blipData.job == 'all' or blipData.job == PlayerData.job.name then
        return true
    end
    
    -- Check jobtype match if enabled
    if Config.UseJobTypes and blipData.jobtype then
        local playerJobType = GetPlayerJobType()
        return blipData.jobtype == 'all' or blipData.jobtype == playerJobType
    end
    
    return false
end

-- Function to create structured blip metadata
local function CreateBlipMetadata(data)
    local locationName = data.description
    local locationDetails = data.details or "No additional information available"
    local jobType = data.jobtype or Config.GetJobType(data.job)
    
    -- Create emoji prefix based on job/jobtype
    local emojiPrefix = Config.JobEmojis[jobType] or Config.JobEmojis[data.job] or "📍"
    
    return {
        title = emojiPrefix .. " " .. locationName,
        description = locationDetails,
        category = data.category or (jobType ~= 'all' and jobType or Config.GsBlips.DefaultCategory),
        jobType = jobType,
        lastUpdate = os.date("%Y-%m-%d %H:%M:%S"),
        dynamic = data.dynamic == nil and true or data.dynamic
    }
end

-- Function to create dynamic display handler
local function CreateDisplayHandler(blipHandle, data)
    return function()
        -- Get current player distance to blip
        local playerCoords = GetEntityCoords(PlayerPedId())
        local blipCoords = vector3(data.coords.x, data.coords.y, data.coords.z)
        local distance = #(playerCoords - blipCoords)
        
        -- Update description with distance and job-specific info
        local jobInfo = ""
        if data.job ~= 'all' then
            jobInfo = string.format("\nRequired Job: %s", data.job:gsub("^%l", string.upper))
        end
        if Config.UseJobTypes and data.jobtype and data.jobtype ~= 'all' then
            jobInfo = jobInfo .. string.format("\nJob Type: %s", data.jobtype:gsub("^%l", string.upper))
        end
        
        local updatedDescription = string.format("%s%s\nDistance: %.1f meters", 
            data.details or data.description,
            jobInfo,
            distance
        )
        
        -- Update the blip's description
        if GetResourceState('gs_blips') == 'started' then
            local gsBlip = exports.gs_blips:GetBlip(blipHandle)
            if gsBlip then
                gsBlip.setDescription(updatedDescription)
            end
        end
    end
end

-- Enhanced function to create a blip with gs_blips support
CreateBlipForCoords = function(data)
    if not HasBlipAccess(data) then return nil end
    
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
        if gsBlip and Config.GsBlips.EnableDynamicDisplay and data.dynamic ~= false then
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
        
        -- Add job/jobtype info to blip name if applicable
        local blipName = data.description
        if data.job ~= 'all' then
            blipName = string.format("%s (%s)", blipName, data.job:upper())
        end
        
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(blipName)
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
        local gsBlip = GetBlipByHandle(handle)
        if gsBlip then
            if gsBlip.setDisplayHandler then
                gsBlip.setDisplayHandler(nil)
            end
            return exports.gs_blips:DeleteBlip(handle)
        end
    else
        if DoesBlipExist(handle) then
            RemoveBlip(handle)
            return true
        end
    end
    return false
end

-- Enhanced marker creation with metadata support
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
        id = data.id,
        created_by = data.created_by,
        created_at = data.created_at,
        updated_at = data.updated_at
    }
    
    markers[#markers + 1] = marker
    return marker
end

-- Enhanced function to load markers from database
LoadMarkers = function()
    QBCore.Functions.TriggerCallback('rd-blips:server:getMarkers', function(dbMarkers)
        -- Clear existing markers
        markers = {}
        
        if not dbMarkers then return end
        
        for _, data in ipairs(dbMarkers) do
            local markerData = {
                coords = json.decode(data.coords),
                type = data.type,
                scale = data.scale,
                color = json.decode(data.color),
                description = data.description,
                id = data.id,
                created_by = data.created_by,
                created_at = data.created_at,
                updated_at = data.updated_at
            }
            CreateMarkerAt(markerData)
        end
    end)
end

-- Function to get nearest marker
local function GetNearestMarker(coords, maxDistance)
    local nearestDist = maxDistance or Config.DefaultMarkerDistance
    local nearestMarker = nil
    local nearestIndex = nil

    for i, marker in ipairs(markers) do
        local dist = #(coords - vector3(marker.coords.x, marker.coords.y, marker.coords.z))
        if dist < nearestDist then
            nearestDist = dist
            nearestMarker = marker
            nearestIndex = i
        end
    end

    return nearestMarker, nearestIndex, nearestDist
end

-- Function to validate marker position
local function ValidateMarkerPosition(coords)
    -- Check if marker is too close to existing markers
    local minDistance = 2.0 -- Minimum distance between markers
    for _, marker in ipairs(markers) do
        local dist = #(coords - vector3(marker.coords.x, marker.coords.y, marker.coords.z))
        if dist < minDistance then
            return false, "Marker is too close to an existing marker"
        end
    end
    return true, nil
end

-- Enhanced marker creation dialog
local function OpenMarkerCreator()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    -- Validate position first
    local isValid, errorMessage = ValidateMarkerPosition(coords)
    if not isValid then
        NotifyPlayer(errorMessage, 'error', 3000)
        return
    end
    
    local ground = 0
    local groundFound, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, true)
    if groundFound then
        ground = groundZ
    end
    
    local dialog = exports['qb-input']:ShowInput({
        header = Lang:t('input.marker.header'),
        submitText = "Create",
        inputs = {
            {
                type = 'number',
                name = 'type',
                text = Lang:t('input.marker.type'),
                isRequired = true,
                default = 1,
            },
            {
                type = 'number',
                name = 'scale',
                text = Lang:t('input.marker.scale'),
                isRequired = true,
                default = Config.DefaultMarkerScale,
            },
            {
                type = 'number',
                name = 'red',
                text = Lang:t('input.marker.red'),
                isRequired = true,
                default = Config.DefaultMarkerColor.r,
            },
            {
                type = 'number',
                name = 'green',
                text = Lang:t('input.marker.green'),
                isRequired = true,
                default = Config.DefaultMarkerColor.g,
            },
            {
                type = 'number',
                name = 'blue',
                text = Lang:t('input.marker.blue'),
                isRequired = true,
                default = Config.DefaultMarkerColor.b,
            },
            {
                type = 'number',
                name = 'alpha',
                text = Lang:t('input.marker.alpha'),
                isRequired = true,
                default = Config.DefaultMarkerColor.a,
            },
            {
                type = 'text',
                name = 'description',
                text = Lang:t('input.marker.description'),
                isRequired = true,
            }
        }
    })

    if dialog then
        local scale = tonumber(dialog.scale) or Config.DefaultMarkerScale
        if scale < 0.5 or scale > 5.0 then
            NotifyPlayer('Scale must be between 0.5 and 5.0', 'error', 3000)
            return
        end

        local markerData = {
            coords = vector3(coords.x, coords.y, ground),
            type = tonumber(dialog.type) or 1,
            scale = scale,
            color = {
                r = tonumber(dialog.red) or Config.DefaultMarkerColor.r,
                g = tonumber(dialog.green) or Config.DefaultMarkerColor.g,
                b = tonumber(dialog.blue) or Config.DefaultMarkerColor.b,
                a = tonumber(dialog.alpha) or Config.DefaultMarkerColor.a
            },
            description = dialog.description
        }
        TriggerServerEvent('rd-blips:server:createMarker', markerData)
    end
end

-- Enhanced function to load blips from database with jobtype support
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
        
        -- Get player's current jobtype
        local playerJobType = GetPlayerJobType()
        
        -- Group blips by category/jobtype for batch processing
        local blipsByCategory = {}
        for _, data in ipairs(dbBlips) do
            if HasBlipAccess(data) then
                local category
                if Config.UseJobTypes and Config.GsBlips.UseJobTypeCategories then
                    category = data.jobtype or Config.GetJobType(data.job)
                else
                    category = data.job ~= 'all' and data.job or Config.GsBlips.DefaultCategory
                end
                
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
                    details = data.details,
                    id = data.id,
                    job = data.job,
                    jobtype = data.jobtype or Config.GetJobType(data.job),
                    dynamic = data.dynamic,
                    category = category,
                    created_by = data.created_by,
                    created_at = data.created_at,
                    updated_at = data.updated_at
                }
                
                local blip = CreateBlipForCoords(blipData)
                if blip then
                    if GetResourceState('gs_blips') == 'started' and Config.UseGsBlips then
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

-- Enhanced function to update blips based on job/jobtype
UpdateBlipsForJob = function(jobName)
    local playerJobType = Config.GetJobType(jobName)
    activeJobType = playerJobType
    
    -- Clear existing blips with proper cleanup
    if GetResourceState('gs_blips') == 'started' and Config.UseGsBlips then
        for _, blip in ipairs(gsBlips) do
            if blip.handle then
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

-- Function to update blips based on jobtype
UpdateBlipsForJobType = function(jobtype)
    if not Config.UseJobTypes then return end
    
    activeJobType = jobtype
    LoadBlips() -- This will now filter based on the new activeJobType
end

-- Function to refresh blip display handlers
RefreshBlipDisplayHandlers = function()
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

-- Enhanced blip creator dialog with jobtype support
local function OpenBlipCreator()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    local dialog = exports['qb-input']:ShowInput({
        header = Lang:t('input.blip.header'),
        submitText = "Create",
        inputs = {
            {
                type = 'number',
                name = 'sprite',
                text = Lang:t('input.blip.sprite'),
                isRequired = true,
                default = 1,
            },
            {
                type = 'number',
                name = 'scale',
                text = Lang:t('input.blip.scale'),
                isRequired = true,
                default = Config.DefaultBlipScale,
            },
            {
                type = 'number',
                name = 'color',
                text = Lang:t('input.blip.color'),
                isRequired = true,
                default = 1,
            },
            {
                type = 'text',
                name = 'description',
                text = Lang:t('input.blip.description'),
                isRequired = true,
            },
            {
                type = 'text',
                name = 'details',
                text = Lang:t('input.blip.details'),
                isRequired = false,
            },
            {
                type = 'text',
                name = 'job',
                text = Lang:t('input.blip.job'),
                isRequired = false,
                default = 'all',
            },
            {
                type = 'checkbox',
                name = 'dynamic',
                text = Lang:t('input.blip.dynamic'),
                isRequired = false,
                default = true,
            }
        }
    })

    if dialog then
        local blipData = {
            coords = coords,
            sprite = tonumber(dialog.sprite) or 1,
            scale = tonumber(dialog.scale) or Config.DefaultBlipScale,
            color = tonumber(dialog.color) or 1,
            description = dialog.description,
            details = dialog.details ~= "" and dialog.details or dialog.description,
            job = (dialog.job ~= "" and dialog.job) or "all",
            dynamic = dialog.dynamic
        }

        -- Automatically set jobtype based on job
        blipData.jobtype = Config.GetJobType(blipData.job)

        TriggerServerEvent('rd-blips:server:createBlip', blipData)
    end
end

-- Enhanced Events with Framework Support
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    Wait(1000) -- Wait for everything to initialize
    
    -- Initialize gs_blips categories if available
    if GetResourceState('gs_blips') == 'started' and Config.UseGsBlips then
        -- Set up job-based categories
        for job, emoji in pairs(Config.JobEmojis) do
            exports.gs_blips:SetupCategory(job, {
                label = emoji .. ' ' .. (job:gsub("^%l", string.upper)),
                color = Config.JobColors[job] or 0
            })
        end
        
        -- Set up jobtype-based categories if enabled
        if Config.UseJobTypes and Config.GsBlips.UseJobTypeCategories then
            for jobType, jobs in pairs(Config.JobTypeCategories) do
                if Config.JobEmojis[jobType] then
                    exports.gs_blips:SetupCategory(jobType, {
                        label = Config.JobEmojis[jobType] .. ' ' .. (jobType:gsub("^%l", string.upper)),
                        color = Config.JobColors[jobType] or 0
                    })
                end
            end
        end
    end
    
    LoadBlips()
    LoadMarkers()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
    -- Clear all blips and markers
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
    markers = {}
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
    Wait(100) -- Small delay to ensure job update is processed
    
    if Config.UseJobTypes then
        local newJobType = Config.GetJobType(JobInfo.name)
        if newJobType ~= activeJobType then
            UpdateBlipsForJobType(newJobType)
        end
    else
        UpdateBlipsForJob(JobInfo.name)
    end
end)

-- Specific support for IF-Multijob
RegisterNetEvent('IF-multijob:client:changeJob', function(job)
    if not job then return end
    PlayerData.job = job
    Wait(100) -- Small delay to ensure job update is processed
    
    if Config.UseJobTypes then
        UpdateBlipsForJobType(Config.GetJobType(job.name))
    else
        UpdateBlipsForJob(job.name)
    end
end)

-- Support for multi-job systems
RegisterNetEvent('qb-core:client:OnJobChange', function(JobInfo)
    PlayerData.job = JobInfo
    Wait(100)
    if Config.UseJobTypes then
        UpdateBlipsForJobType(Config.GetJobType(JobInfo.name))
    else
        UpdateBlipsForJob(JobInfo.name)
    end
end)

RegisterNetEvent('rd-blips:client:markerCreated', function(markerData)
    local marker = CreateMarkerAt(markerData)
    if marker then
        NotifyPlayer('Marker created successfully', 'success', 3000)
    else
        NotifyPlayer('Failed to create marker', 'error', 3000)
    end
end)

RegisterNetEvent('rd-blips:client:markerRemoved', function(markerId)
    for i = #markers, 1, -1 do
        if markers[i].id == markerId then
            table.remove(markers, i)
            break
        end
    end
end)

RegisterNetEvent('rd-blips:client:blipCreated', function(blipData)
    if not PlayerData.job then return end
    
    if HasBlipAccess(blipData) then
        local blip = CreateBlipForCoords(blipData)
        if blip then
            if GetResourceState('gs_blips') == 'started' and Config.UseGsBlips then
                gsBlips[#gsBlips + 1] = {
                    handle = blip,
                    data = blipData,
                    category = blipData.jobtype or blipData.job,
                    lastUpdate = os.time()
                }
            else
                blips[#blips + 1] = {handle = blip, data = blipData}
            end
            NotifyPlayer('Blip created successfully', 'success', 3000)
        end
    end
end)

RegisterNetEvent('rd-blips:client:blipRemoved', function(blipId)
    local blipList = GetResourceState('gs_blips') == 'started' and Config.UseGsBlips and gsBlips or blips
    for i = #blipList, 1, -1 do
        if blipList[i].data.id == blipId then
            DeleteBlip(blipList[i].handle)
            table.remove(blipList, i)
            break
        end
    end
end)

RegisterNetEvent('rd-blips:client:openBlipCreator', function()
    OpenBlipCreator()
end)

RegisterNetEvent('rd-blips:client:openMarkerCreator', function()
    OpenMarkerCreator()
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
            
            for i = #gsBlips, 1, -1 do
                local blip = gsBlips[i]
                if blip and blip.handle then
                    if currentTime - (blip.lastUpdate or 0) >= Config.GsBlips.DisplayRefreshRate then
                        local gsBlip = GetBlipByHandle(blip.handle)
                        if gsBlip then
                            if blip.data.dynamic then
                                gsBlip.setDisplayHandler(CreateDisplayHandler(blip.handle, blip.data))
                            end
                            blip.lastUpdate = currentTime
                        else
                            table.remove(gsBlips, i)
                        end
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
    if PlayerData and PlayerData.job then
        activeJobType = Config.GetJobType(PlayerData.job.name)
        LoadBlips()
        LoadMarkers()
    end
end)
