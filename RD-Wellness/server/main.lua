local QBcore = exports['qb-core']:GetCoreObject()

-- callback to check if Player Can afford the service
QBCore.Functions.CreateCallback(RD-Wellness, function(source, cb, service)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local price = Config.InteractionPoints[service].price

    if Player.PlayerData.Money.cash >= price then
        Player.Functions.RemoveMoney('cash', price)
        if Config.UseSociety then
            exports['qb-mangement']:AddMoney(config.BusinessName, price)
        end
        TriggerClientEvent('QBCore:Notify', src, "You Paid $" .. price .. "for" .. service, "success")
        cb(true)
    elseif Player.PlayerData.money.bank >= price then
            Player.Functions.RemoveMoney('bank', price)
            if Config.UseSociety then
                exports['qb-management']:AddMoney(Config.BusinessName, price)
            end
            TriggerClientEvent('QBCore:Notify', src, "You Paid $" .. price .. "for" .. service, "success")
            cb(true)
        else
            cb(false)
            end
        end)

 -- event to relieveStress
 RegisterNetEvent('RD-Wellness:relieveStress')
 AddEventHandler('RD-Wellness:relieveStress', fuction(amount)
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        
        if Player.PlayerData.metadata['stress'] then
            local currentStress = Player.PlayerData.metadata['stress']
            local newStress = math.max(0, currentStress - amount)
            Player.Functions.SetMetaData('stress', newStress)
            TriggerClientEvent('hud:client:UpdateStress', src, newStress) -- Updates Stress on Client Side HUD

            local stressReduced = currentStress - newStress
            TriggerClientEvent('QBCore:Notify', src " Your Feeling More Relaxed! Stress Reduced by " .. stressReduced .. "points", "sucess")
        end
    end)

    -- Event To Sync Particle Effects Across Clients
    RegisterNetEvent('RD-Wellness:syncParticles')
    AddEventHandler('RD-Wellness:synchParticles', function(services, coords)
    local src = source
    TriggerClientEvent('RD-Wellness:syncParticles', -1, service, coords, src)
    end)

    -- Event To stop synced Particle Effects
    RegisterNetEvent('RD-Wellness:stopSyncedParticles')
    AddEventHandler('RD-Wellness:stopSyncedParticles', function(service)
    TriggerClientEvent('RD-Wellness:stopSyncedParticles', -1, service)
    end)

    -- Server-Side Cooldown check For Additional Security
    QBCore.Functions.CreateCallback('RD-Wellness:checkCooldown', function(source, cd, service)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenid = Player.Playerdata.citizenid

    if not Player.PlayerData.metadata['wellness_cooldonws'] then
        Player.PlayerData.metadata['wellness_cooldowns'] = {}
    end

    local cooldowns = Player.PlayerData.metadata['wellness_cooldowns']
    local currentTime = os.time()
    
    if cooldowns[service] and  currentTime < cooldowns[service] then
        local remainingTime = cooldowns[service] - currentTime
        cb(false, remainingTime)
    else
        cooldown[service] = currentTime + (Config.InteractionPoints[service].cooldown / 1000)
        Player.Functions.SetMetaData('wellness_cooldonws', cooldowns)
        cb(true, 0)
    end
end)

-- Event to Log Wellness Center Usage ( Optional)
RegisterNetEvent('RD-wellness:logUsage')
AddEventHandler('RD-wellness:logUsage', function(service)
local src = source
local Player = QBCore.functions.GetPlayer(src)
local citizenid = Player.PlayerData.citizenid
local name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
print(string.format("[RD-Wellness] Player %s (CitizenID: %s used %s", name, citizenid, service ))
-- Add any Additional Logging Logic you might want to use here
end)

-- Command to reset cooldowns (For Admin Use Only)
QBcore.Commands.Add('resetwellnesscooldowns', 'Reset Wellness Center Cooldown', {{name = 'id', help = 'Player ID (Optional)'}}, true, function(source, args)
local src = source
local Player

if args[1] then
    Player = QBCore.Functions.GetPlayer(tonumber(args[1]))
else
    Player = QBCore.Functions.GetPlayer(src)
end

if Player then
    Player.PlayerData.metadata['wellness_cooldonws'] = {}
    Player.Functions.SetMetaData('wellness_cooldonws',{})
    TriggerClientEvent('QBCore:Notify', src, "Wellness cooldowns reset for" .. Player.PlayerData.charinfo.firstname, "success")
else
    TriggerClientEvent('QBCore:Notify', src, "Player Not Found", "error")
end
end, ('admin'))