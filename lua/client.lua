
editing = false
deleting = false
Point1 = false
Point2 = false
ActivePosters = {}
CurrentPoster = {}
GLOBAL_COORDS = nil
TXD = nil 
PlayerData = {}
local Framework

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    loadData()
end)

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
    loadData()
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        loadData()
    end
end)

RegisterNetEvent("QBCore:Client:OnPlayerUnload", function()
    PlayerData = {}
end)

local function GetPlayerData()
    if Config.Framework == 'qb-core' then
        return Framework.Functions.GetPlayerData()
    elseif Config.Framework == 'ESX' then
        return Framework.GetPlayerData()
    end
end

function loadData()
    if Config.Framework == "qb-core" then
        Framework = exports['qb-core']:GetCoreObject()
    elseif Config.Framework == "ESX" then
        Framework = exports["es_extended"]:getSharedObject()
    end
    PlayerData = GetPlayerData()
	local images = lib.callback.await("posters:getImages", false)
    for k,v in pairs(images) do
        DUILoaded = false
        v.duiObj = CreateDui(string.format("https://cfx-nui-%s/web/dist/index.html", GetCurrentResourceName()), v.width, v.height)
        v.duiHandle = GetDuiHandle(v.duiObj)
        v.txd = CreateRuntimeTxd(v.textureid)
        v.texture = CreateRuntimeTextureFromDuiHandle(v.txd, v.txn, v.duiHandle)
        while not DUILoaded do Wait(0) end
        SendDuiMessage(v.duiObj, json.encode({
            action = "setDUIVariables",
            imageSrc = v.url,
            width = v.width,
            height = v.height,
        }))
        Wait(1000)
    end
end

RegisterNetEvent("posters:deleteClientImage", function(id)
    for k,v in pairs(ActivePosters) do
        if v.id == id then
            DestroyDui(v.duiObj)
            table.remove(ActivePosters, k)
            break
        end
    end
end)

RegisterNetEvent("posters:sendAddedImage", function(newImage)
    DUILoaded = false
    newImage.duiObj = CreateDui(string.format("https://cfx-nui-%s/web/dist/index.html", GetCurrentResourceName()), newImage.width, newImage.height)
    newImage.duiHandle = GetDuiHandle(newImage.duiObj)
    newImage.txd = CreateRuntimeTxd(newImage.textureid)
    newImage.texture = CreateRuntimeTextureFromDuiHandle(newImage.txd, newImage.txn, newImage.duiHandle)
    while not DUILoaded do Wait(0) end
    SendDuiMessage(newImage.duiObj, json.encode({
        action = "setDUIVariables",
        imageSrc = newImage.url,
        width = newImage.width,
        height = newImage.height,
    }))
    ActivePosters[#ActivePosters+1] = newImage
end)

function PlaceImage()
    editing = true
    Point1 = false
    Point2 = false
    CurrentPoster = {}
    lib.showTextUI("[E] Select Start Point", {
        icon = 'fas fa-hand-pointer',
        position = 'left-center', 
    })
    while editing do
        DisableControlAction(0, 38, true)
        local start,fin = GetCoordsInFrontOfCam(0, 5000)
        local ray = StartShapeTestRay(start.x, start.y, start.z, fin.x, fin.y, fin.z, 4294967295, cache.ped, 5000)
        local _ray,hit,pos,norm,ent = GetShapeTestResult(ray)
        if hit then
            DrawSphere(pos, 0.06, 0, 255, 0, 0.5)
            if not Point1 then
                if IsDisabledControlJustReleased(0, 38) then
                    lib.hideTextUI()
                    Point1 = pos
                    Point2 = pos
                    Wait(100)
                    lib.showTextUI("[E] Select End Point ", {
                        icon = 'fas fa-hand-pointer',
                        position = 'left-center',
                    })
                end
            end
            if Point2 then
                Point2 = pos
                if IsDisabledControlJustReleased(0, 38) then
                    editing = false
                end
            end
        end
        if Point1 then
            DrawSelectedArea(Point1, Point2, Point2.z, Point1.z, 0, 155, 0, 80)
        end
        Wait(0)
    end
    lib.hideTextUI()
    if #(Point1 - Point2) < 50.0 then
        CurrentPoster.pointA = Point1
        CurrentPoster.pointB = Point2
        SendNUIMessage({ action = "openEditor" })
        SetNuiFocus(true, true)
    else
        lib.notify({
            title = 'Posters',
            description = 'Poster size is too large!',
            type = 'error'
        })
    end
end

function DeleteImage()
    deleting = true
    lib.showTextUI("[E] Select Image Area", {
        icon = 'fas fa-hand-pointer',
        position = 'left-center', 
    })
    while deleting do
        DisableControlAction(0, 38, true)
        local start,fin = GetCoordsInFrontOfCam(0, 5000)
        local ray = StartShapeTestRay(start.x, start.y, start.z, fin.x, fin.y, fin.z, 4294967295, cache.ped, 5000)
        local _ray,hit,pos,norm,ent = GetShapeTestResult(ray)
        if hit then
            DrawSphere(pos, 0.06, 0, 255, 0, 0.5)
            if IsDisabledControlJustReleased(0, 38) then
                deleting = false
                lib.hideTextUI()
                local closestDist, currentKey = 999.9, 1
                local currentPoster = nil
                for k,v in pairs(ActivePosters) do
                    if #(pos - v.pointA) < closestDist then
                        closestDist = #(pos - v.pointA)
                        currentKey = v.id
                        currentPoster = v
                    end
                    if #(pos - v.pointB) < closestDist then
                        closestDist = #(pos - v.pointB)
                        currentKey = v.id
                        currentPoster = v
                    end
                end
                if closestDist < 10 then
                    if lib.progressCircle({
                        label = 'Removing Poster...',
                        duration = 10000,
                        position = "bottom",
                        useWhileDead = false,
                        canCancel = true,
                        disable = {car = true, move = true, combat = true},
                        anim = { dict = 'mini@repair', clip = 'fixing_a_ped' },
                    }) then
                        if Config.Framework == "qb-core" then
                            TriggerServerEvent("posters:deleteImage", currentKey, PlayerData.citizenid == currentPoster.cid)
                        elseif Config.Framework == "ESX" then
                            TriggerServerEvent("posters:deleteImage", currentKey, PlayerData.identifier == currentPoster.cid)
                        end
                        lib.notify({
                            title = 'Posters',
                            description = "Poster sent for deletion!",
                            type = "inform",
                        })
                    else
                        lib.notify({
                            title = 'Posters',
                            description = "Menu deletion canceled.",
                            type = "error",
                        })
                    end
                else
                    lib.notify({
                        title = 'Posters',
                        description = "Could not find an poster close enough to delete. Please try again",
                        type = "error",
                    })
                end
            end
        end
        Wait(0)
    end
end

RegisterNUICallback("exit", function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNuiCallback('loaded', function(_, cb)
    DUILoaded = true
    cb({resName = GetCurrentResourceName()})
end)

RegisterNUICallback("savePoster", function(data, cb)
    SetNuiFocus(false, false)
    CurrentPoster.url = data.url
    CurrentPoster.width = data.width
    CurrentPoster.height = data.height
    CurrentPoster.id = math.random(999999, 999999999)
    if Config.Framework == "qb-core" then
        CurrentPoster.cid = PlayerData.citizenid
    elseif Config.Framework == "ESX" then
        CurrentPoster.cid = PlayerData.identifier
    end
    CurrentPoster.textureid = "newtexture"..tostring(math.random(1, 100000))
    CurrentPoster.txn = "newtexture"..tostring(math.random(1, 100000))
    TriggerServerEvent("posters:addNewImage", CurrentPoster)
    cb('ok')
end)

CreateThread(function()
    while true do
        GLOBAL_COORDS = GetEntityCoords(cache.ped)
        Wait(1500)
    end
end)

CreateThread(function()
    while true do
        local sleep = 1500
        for k,v in pairs(ActivePosters) do
            if #(GLOBAL_COORDS - v.pointA) < Config.RenderDistance or #(GLOBAL_COORDS - v.pointB) < Config.RenderDistance then
                sleep = 0
                DrawImageOnArea(v.pointA, v.pointB, v.pointB.z, v.pointA.z, 255, 255, 255, 255, v.textureid, v.txn)
            end
        end
        Wait(sleep)
    end
end)

RegisterNetEvent("posters:placeImage", function()
    PlaceImage()
end)

RegisterNetEvent("posters:removePoster", function()
	DeleteImage()
end)