RegisteredSprays = {}
local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateUseableItem('poster', function(source, item)
    TriggerClientEvent("posters:placeImage", source)
end)

RegisterNetEvent("posters:addNewImage", function(data)
    local Player = QBCore.Functions.GetPlayer(source)
    RegisteredSprays[#RegisteredSprays+1] = data
    TriggerClientEvent("posters:sendAddedImage", -1, data)
    --exports.ox_inventory:RemoveItem(source, "poster", 1)
    if not Player then return end
    Player.Functions.RemoveItem("poster", 1)
end)

lib.callback.register('posters:getImages', function(source)
    return RegisteredSprays
end)

RegisterNetEvent("posters:deleteImage", function(id, isOwner)
    local Player = QBCore.Functions.GetPlayer(source)
    for k,v in pairs(RegisteredSprays) do
        if v.id == id then
            table.remove(RegisteredSprays, k)
            TriggerClientEvent("posters:deleteClientImage", -1, id)
        end
    end
    if isOwner then
        --exports.ox_inventory:AddItem(source, "poster", 1)
        if not Player then return end
        Player.Functions.AddItem("poster", 1)
    end
end)


RegisterCommand("removeposter", function(source, args, raw)
    TriggerClientEvent("posters:removePoster", source)
end)
