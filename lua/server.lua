RegisteredSprays = {}
local Framework
if Config.Framework == "qb-core" then
    Framework = exports['qb-core']:GetCoreObject()
    Framework.Functions.CreateUseableItem('poster', function(source, item)
        TriggerClientEvent("posters:placeImage", source)
    end)
elseif Config.Framework == "ESX" then
    Framework = exports["es_extended"]:getSharedObject()
    Framework.RegisterUsableItem('poster', function(source)
        TriggerClientEvent("posters:placeImage", source)
    end)
end

RegisterNetEvent("posters:addNewImage", function(data)
    local _source = source
    RegisteredSprays[#RegisteredSprays+1] = data
    TriggerClientEvent("posters:sendAddedImage", -1, data)
    if Config.Inventory == "ox_inventory" then
        exports.ox_inventory:RemoveItem(_source, "poster", 1)
    end
    if Config.Inventory == "qb-inventory" then
        local Player = Framework.Functions.GetPlayer(_source)
        Player.Functions.RemoveItem("poster", 1)
    end
end)

lib.callback.register('posters:getImages', function(source)
    return RegisteredSprays
end)

RegisterNetEvent("posters:deleteImage", function(id, isOwner)
    for k,v in pairs(RegisteredSprays) do
        if v.id == id then
            table.remove(RegisteredSprays, k)
            TriggerClientEvent("posters:deleteClientImage", -1, id)
        end
    end
    if isOwner then
        if Config.Inventory == "ox_inventory" then
            exports.ox_inventory:AddItem(source, "poster", 1)
        end
        if Config.Inventory == "qb-inventory" then
            local Player = Framework.Functions.GetPlayer(source)
            Player.Functions.AddItem("poster", 1)
        end
    end
end)

RegisterCommand("removeposter", function(source, args, raw)
    TriggerClientEvent("posters:removePoster", source)
end)
