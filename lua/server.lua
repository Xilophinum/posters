RegisteredSprays = {}


ESX = exports["es_extended"]:getSharedObject()


ESX.RegisterUsableItem('poster', function(source)
    TriggerClientEvent("posters:placeImage", source)
end)

-- Add new image event
RegisterNetEvent("posters:addNewImage")
AddEventHandler("posters:addNewImage", function(data)
    local xPlayer = ESX.GetPlayerFromId(source)
    RegisteredSprays[#RegisteredSprays+1] = data
    TriggerClientEvent("posters:sendAddedImage", -1, data)
    xPlayer.removeInventoryItem('poster', 1)
end)

-- Get images callback
ESX.RegisterServerCallback('posters:getImages', function(source, cb)
    cb(RegisteredSprays)
end)

-- Delete image event
RegisterNetEvent("posters:deleteImage")
AddEventHandler("posters:deleteImage", function(id, isOwner)
    for k,v in pairs(RegisteredSprays) do
        if v.id == id then
            table.remove(RegisteredSprays, k)
            TriggerClientEvent("posters:deleteClientImage", -1, id)
        end
    end
    if isOwner then
        local xPlayer = ESX.GetPlayerFromId(source)
        xPlayer.addInventoryItem('poster', 1)
    end
end)

-- Register a command to remove a poster
RegisterCommand("removeposter", function(source, args, rawCommand)
    TriggerClientEvent("posters:removePoster", source)
end)
