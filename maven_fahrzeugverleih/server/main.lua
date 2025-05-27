local ESX = exports['es_extended']:getSharedObject()
local Rapsey = Rapsey or {}

RegisterServerEvent('Rapsey:rentVehicle')
AddEventHandler('Rapsey:rentVehicle', function(model, price, coords, heading)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
        TriggerClientEvent('Rapsey:spawnRentedVehicle', source, model, coords, heading)
        xPlayer.showNotification('Du hast das Fahrzeug gemietet!')
    else
        xPlayer.showNotification('Nicht genug Geld!')
    end
end)

