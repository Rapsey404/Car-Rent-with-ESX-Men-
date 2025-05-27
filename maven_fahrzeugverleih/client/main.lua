-- Rapsey exklusiv: Optimiert, Ausparkpunkt, Marker angepasst
local ESX = exports['es_extended']:getSharedObject()
local Rapsey = Rapsey or {}

-- Blips werden nur einmal gesetzt
CreateThread(function()
    for _, loc in pairs(Rapsey.Locations) do
        local blip = AddBlipForCoord(loc.coords)
        SetBlipSprite(blip, 225)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 3)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(loc.label)
        EndTextCommandSetBlipName(blip)
    end
end)

local function DrawMarkerAtLocation(loc)
    -- Marker etwas höher setzen
    DrawMarker(Rapsey.Marker.type, loc.coords.x, loc.coords.y, loc.coords.z + 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Rapsey.Marker.scale.x, Rapsey.Marker.scale.y, Rapsey.Marker.scale.z, Rapsey.Marker.color.r, Rapsey.Marker.color.g, Rapsey.Marker.color.b, Rapsey.Marker.color.a, false, true, 2, false, nil, nil, false)
end

-- Performanter: Nur alle 250ms prüfen, und nur wenn Spieler in der Nähe
CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local found = false
        for _, loc in pairs(Rapsey.Locations) do
            local dist = #(playerCoords - loc.coords)
            if dist < Rapsey.DrawDistance then
                found = true
                DrawMarkerAtLocation(loc)
                if dist < 2.0 then
                    ESX.ShowHelpNotification('Drücke ~INPUT_CONTEXT~ um ein Fahrzeug zu mieten')
                    if IsControlJustReleased(0, 38) then
                        TriggerEvent('Rapsey:openRentalMenu', loc)
                    end
                end
            end
        end
        Wait(found and 0 or 250)
    end
end)

RegisterNetEvent('Rapsey:openRentalMenu', function(loc)
    local elements = {}
    for _, v in pairs(loc.vehicles) do
        table.insert(elements, {label = v.label .. ' - $' .. v.price, value = v.model, price = v.price})
    end
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'rental_menu', {
        title = Rapsey.ESXMenuTitle,
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        -- Ausparkpunkt: Wenn vorhanden, sonst Standard
        local spawnCoords = loc.spawn or loc.coords
        local heading = loc.spawnHeading or loc.heading or 0.0
        TriggerServerEvent('Rapsey:rentVehicle', data.current.value, data.current.price, spawnCoords, heading)
        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end)

RegisterNetEvent('Rapsey:spawnRentedVehicle', function(model, coords, heading)
    ESX.Game.SpawnVehicle(model, coords, heading, function(vehicle)
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
        ESX.ShowNotification('Viel Spaß mit deinem Fahrzeug!')
    end)
end)


