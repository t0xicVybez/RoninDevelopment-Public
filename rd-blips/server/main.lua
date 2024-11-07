local QBCore = exports['qb-core']:GetCoreObject()
local Lang = Lang or Locale:new({
    phrases = {},
    warnOnMissing = true,
    fallbackLang = 'en'
})

-- Function to check if player is admin
local function IsPlayerAdmin(Player)
    -- Check multiple ways
    if Player.PlayerData.group == "admin" or 
       Player.PlayerData.group == "god" or
       QBCore.Functions.HasPermission(Player.PlayerData.source, "admin") or 
       QBCore.Functions.HasPermission(Player.PlayerData.source, "god") or
       IsPlayerAceAllowed(Player.PlayerData.source, "command") then
        return true
    end
    return false
end

-- Function to validate marker data
local function ValidateMarkerData(data)
    if not data.type or data.type < 0 or data.type > 43 then
        return false, "Invalid marker type"
    end
    if not data.scale or data.scale < 0.0 or data.scale > 10.0 then
        return false, "Invalid scale"
    end
    if not data.description or data.description == "" then
        return false, "Description required"
    end
    if not data.color or 
       not data.color.r or data.color.r < 0 or data.color.r > 255 or
       not data.color.g or data.color.g < 0 or data.color.g > 255 or
       not data.color.b or data.color.b < 0 or data.color.b > 255 or
       not data.color.a or data.color.a < 0 or data.color.a > 255 then
        return false, "Invalid color values"
    end
    return true, nil
end

-- Function to validate blip data
local function ValidateBlipData(data)
    if not data.sprite or data.sprite < 0 or data.sprite > 826 then
        return false, "Invalid blip sprite"
    end
    if not data.scale or data.scale < 0.0 or data.scale > 10.0 then
        return false, "Invalid scale"
    end
    if not data.color or data.color < 0 or data.color > 85 then
        return false, "Invalid color"
    end
    if not data.description or data.description == "" then
        return false, "Description required"
    end
    return true, nil
end

-- Callback to get all blips
QBCore.Functions.CreateCallback('rd-blips:server:getBlips', function(source, cb)
    local result = MySQL.query.await('SELECT * FROM rd_blips')
    cb(result)
end)

-- Callback to get all markers
QBCore.Functions.CreateCallback('rd-blips:server:getMarkers', function(source, cb)
    local result = MySQL.query.await('SELECT * FROM rd_markers')
    cb(result)
end)

-- Create new blip
RegisterNetEvent('rd-blips:server:createBlip', function(blipData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then 
        print("No player found")
        return 
    end
    

    -- Check if player is admin
    if not IsPlayerAdmin(Player) then
        print("Permission denied for player:", Player.PlayerData.citizenid)
        TriggerClientEvent('QBCore:Notify', src, 'You do not have permission', 'error', 3000)
        return
    end

    print("Permission granted for player:", Player.PlayerData.citizenid)

    -- Validate blip data
    local isValid, errorMessage = ValidateBlipData(blipData)
    if not isValid then
        TriggerClientEvent('QBCore:Notify', src, errorMessage, 'error', 3000)
        return
    end

    local id = MySQL.insert.await('INSERT INTO rd_blips (coords, sprite, scale, color, description, job) VALUES (?, ?, ?, ?, ?, ?)', {
        json.encode(blipData.coords),
        blipData.sprite,
        blipData.scale,
        blipData.color,
        blipData.description,
        blipData.job
    })

    if id then
        blipData.id = id
        TriggerClientEvent('rd-blips:client:blipCreated', -1, blipData)
        TriggerClientEvent('QBCore:Notify', src, 'Blip created successfully', 'success', 3000)
    else
        TriggerClientEvent('QBCore:Notify', src, 'Failed to create blip', 'error', 3000)
    end
end)

-- Create new marker
RegisterNetEvent('rd-blips:server:createMarker', function(markerData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Check if player is admin
    if not IsPlayerAdmin(Player) then
        TriggerClientEvent('QBCore:Notify', src, 'You do not have permission', 'error', 3000)
        return
    end

    -- Validate marker data
    local isValid, errorMessage = ValidateMarkerData(markerData)
    if not isValid then
        TriggerClientEvent('QBCore:Notify', src, errorMessage, 'error', 3000)
        return
    end

    local id = MySQL.insert.await('INSERT INTO rd_markers (coords, type, scale, color, description) VALUES (?, ?, ?, ?, ?)', {
        json.encode(markerData.coords),
        markerData.type,
        markerData.scale,
        json.encode(markerData.color),
        markerData.description
    })

    if id then
        markerData.id = id
        TriggerClientEvent('rd-blips:client:markerCreated', -1, markerData)
        TriggerClientEvent('QBCore:Notify', src, 'Marker created successfully', 'success', 3000)
    else
        TriggerClientEvent('QBCore:Notify', src, 'Failed to create marker', 'error', 3000)
    end
end)

-- Remove blip
RegisterNetEvent('rd-blips:server:removeBlip', function(blipId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Check if player is admin
    if not IsPlayerAdmin(Player) then
        TriggerClientEvent('QBCore:Notify', src, 'You do not have permission', 'error', 3000)
        return
    end

    local success = MySQL.query.await('DELETE FROM rd_blips WHERE id = ?', {blipId})
    
    if success then
        TriggerClientEvent('QBCore:Notify', src, 'Blip removed successfully', 'success', 3000)
    else
        TriggerClientEvent('QBCore:Notify', src, 'Failed to remove blip', 'error', 3000)
    end
end)

-- Remove marker
RegisterNetEvent('rd-blips:server:removeMarker', function(markerId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Check if player is admin
    if not IsPlayerAdmin(Player) then
        TriggerClientEvent('QBCore:Notify', src, 'You do not have permission', 'error', 3000)
        return
    end

    local success = MySQL.query.await('DELETE FROM rd_markers WHERE id = ?', {markerId})
    
    if success then
        TriggerClientEvent('QBCore:Notify', src, 'Marker removed successfully', 'success', 3000)
    else
        TriggerClientEvent('QBCore:Notify', src, 'Failed to remove marker', 'error', 3000)
    end
end)

-- Register commands
RegisterCommand('createblip', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    if not IsPlayerAdmin(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have permission', 'error', 3000)
        return
    end
    
    TriggerClientEvent('rd-blips:client:openBlipCreator', source)
end)

RegisterCommand('removeblip', function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    if not IsPlayerAdmin(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have permission', 'error', 3000)
        return
    end

    local description = args[1]
    TriggerClientEvent('rd-blips:client:removeBlip', source, description)
end)

RegisterCommand('createmarker', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    if not IsPlayerAdmin(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have permission', 'error', 3000)
        return
    end
    
    TriggerClientEvent('rd-blips:client:openMarkerCreator', source)
end)

RegisterCommand('removemarker', function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    if not IsPlayerAdmin(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have permission', 'error', 3000)
        return
    end

    local description = args[1]
    TriggerClientEvent('rd-blips:client:removeMarker', source, description)
end)