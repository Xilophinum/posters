local Framework
if Config.Framework == 'QBCore' then
    Framework = exports['qb-core']:GetCoreObject()
elseif Config.Framework == 'ESX' then
    ESX = exports["es_extended"]:getSharedObject()
end

if Config.Framework == 'QBCore' then
    QBCore.Functions.CreateUseableItem('poster', function(source)
        TriggerClientEvent("posters:placeImage", source)
    end)
elseif Config.Framework == 'ESX' then
    ESX.RegisterUsableItem('poster', function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        xPlayer.removeInventoryItem('poster', 1)
        TriggerClientEvent("posters:placeImage", source)
    end)
end

local RegisteredSprays = {}

if Config.Framework == 'QBCore' then
    lib.callback.register('posters:getImages', function(source)
        return RegisteredSprays
    end)
elseif Config.Framework == 'ESX' then
    ESX.RegisterServerCallback('posters:getImages', function(source, cb)
        cb(RegisteredSprays)
    end)
end

RegisterNetEvent("posters:addNewImage", function(data)
    RegisteredSprays[#RegisteredSprays+1] = data
    if Config.Framework == 'QBCore' then
        TriggerClientEvent("posters:sendAddedImage", -1, data)
    elseif Config.Framework == 'ESX' then
        TriggerClientEvent("posters:sendAddedImage", -1, data)
    end
end)

RegisterNetEvent("posters:deleteImage", function(id, isOwner)
    for k,v in pairs(RegisteredSprays) do
        if v.id == id then
            table.remove(RegisteredSprays, k)
            TriggerClientEvent("posters:deleteClientImage", -1, id)
        end
    end
    if isOwner then
        if Config.Framework == 'QBCore' then
            -- Specific QBCore handling for giving item back
        elseif Config.Framework == 'ESX' then
            local xPlayer = ESX.GetPlayerFromId(source)
            xPlayer.addInventoryItem('poster', 1)
        end
    end
end)

RegisterCommand("removeposter", function(source, args, raw)
    TriggerClientEvent("posters:removePoster", source)
end)
