local QBCore = exports['qb-core']:GetCoreObject()

-- Function to check if player is admin
local function IsPlayerAdmin(Player)
    if Player.PlayerData.permission == "admin" or Player.PlayerData.permission == "god" then
        return true
    end
    return false
end

-- Function to validate marker data
local function ValidateMarkerData(data)
    if not data.type or data.type < 0 or data.type > 43 then
        return false, Lang:t('error.invalid_type', {value = "marker"})
    end
    if not data.scale or data.scale < 0.0 or data.scale > 10.0 then
        return false, Lang:t('error.invalid_scale')
    end
    if not data.description or data.description == "" then
        return false, Lang:t('error.invalid_description')
    end
    if not data.color or 
       not data.color.r or data.color.r < 0 or data.color.r > 255 or
       not data.color.g or data.color.g < 0 or data.color.g > 255 or
       not data.color.b or data.color.b < 0 or data.color.b > 255 or
       not data.color.a or data.color.a < 0 or data.color.a > 255 then
        return false, Lang:t('error.invalid_color')
    end
    return true, nil
end

-- Function to validate blip data
local function ValidateBlipData(data)
    if not data.sprite or data.sprite < 0 or data.sprite > 826 then
        return false, Lang:t('error.invalid_type', {value = "blip"})
    end
    if not data.scale or data.scale < 0.0 or data.scale > 10.0 then
        return false, Lang:t('error.invalid_scale')
    end
    if not data.color or data.color < 0 or data.color > 85 then
        return false, Lang:t('error.invalid_color')
    end
    if not data.description or data.description == "" then
        return false, Lang:t('error.invalid_description')
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
    
    if not Player then return end
    
    -- Check if player is admin
    if not IsPlayerAdmin(Player) then
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.no_permission'), 'error')
        return
    end

    -- Validate blip data
    local isValid, errorMessage = ValidateBlipData(blipData)
    if not isValid then
        TriggerClientEvent('QBCore:Notify', src, errorMessage, 'error')
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
        TriggerClientEvent('QBCore:Notify', src, Lang:t('info.blip_created'), 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.failed_to_create', {value = "blip"}), 'error')
    end
end)

-- Create new marker
RegisterNetEvent('rd-blips:server:createMarker', function(markerData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Check if player is admin
    if not IsPlayerAdmin(Player) then
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.no_permission'), 'error')
        return
    end

    -- Validate marker data
    local isValid, errorMessage = ValidateMarkerData(markerData)
    if not isValid then
        TriggerClientEvent('QBCore:Notify', src, errorMessage, 'error')
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
        TriggerClientEvent('QBCore:Notify', src, Lang:t('info.marker_created'), 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.failed_to_create', {value = "marker"}), 'error')
    end
end)

-- Remove blip
RegisterNetEvent('rd-blips:server:removeBlip', function(blipId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Check if player is admin
    if not IsPlayerAdmin(Player) then
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.no_permission'), 'error')
        return
    end

    local success = MySQL.query.await('DELETE FROM rd_blips WHERE id = ?', {blipId})
    
    if success then
        TriggerClientEvent('QBCore:Notify', src, Lang:t('info.blip_removed'), 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.failed_to_remove', {value = "blip"}), 'error')
    end
end)

-- Remove marker
RegisterNetEvent('rd-blips:server:removeMarker', function(markerId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Check if player is admin
    if not IsPlayerAdmin(Player) then
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.no_permission'), 'error')
        return
    end

    local success = MySQL.query.await('DELETE FROM rd_markers WHERE id = ?', {markerId})
    
    if success then
        TriggerClientEvent('QBCore:Notify', src, Lang:t('info.marker_removed'), 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.failed_to_remove', {value = "marker"}), 'error')
    end
end)

-- Register commands
QBCore.Commands.Add('createblip', Lang:t('commands.create_blip'), {}, false, function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not IsPlayerAdmin(Player) then
        TriggerClientEvent('QBCore:Notify', source, Lang:t('error.no_permission'), 'error')
        return
    end
    TriggerClientEvent('rd-blips:client:openBlipCreator', source)
end, 'admin')

QBCore.Commands.Add('removeblip', Lang:t('commands.remove_blip'), {{name = 'description', help = 'Blip description (optional)'}}, false, function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not IsPlayerAdmin(Player) then
        TriggerClientEvent('QBCore:Notify', source, Lang:t('error.no_permission'), 'error')
        return
    end
end, 'admin')

QBCore.Commands.Add('createmarker', Lang:t('commands.create_marker'), {}, false, function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not IsPlayerAdmin(Player) then
        TriggerClientEvent('QBCore:Notify', source, Lang:t('error.no_permission'), 'error')
        return
    end
    TriggerClientEvent('rd-blips:client:openMarkerCreator', source)
end, 'admin')

QBCore.Commands.Add('removemarker', Lang:t('commands.remove_marker'), {{name = 'description', help = 'Marker description (optional)'}}, false, function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not IsPlayerAdmin(Player) then
        TriggerClientEvent('QBCore:Notify', source, Lang:t('error.no_permission'), 'error')
        return
    end
end, 'admin')