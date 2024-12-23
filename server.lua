ESX = exports["es_extended"]:getSharedObject()

lib.callback.register('checkSnowballCount', function(source)
    local snowballs = exports.ox_inventory:GetItemCount(source, 'weapon_snowball')
    return snowballs < 10
end)

RegisterNetEvent('qbx_smallresources:server:addSnowballToInv', function()
    exports.ox_inventory:AddItem(source, 'weapon_snowball', 1)
end)

RegisterNetEvent('qbx_smallresources:server:removeSnowballToInv', function()
    exports.ox_inventory:RemoveItem(source, 'weapon_snowball', 1)
end)

RegisterNetEvent('qbx_smallresources:server:removeSnowballAndCarrotFromInv', function()
    exports.ox_inventory:RemoveItem(source, 'weapon_snowball', 10)
    exports.ox_inventory:RemoveItem(source, 'carrot', 1)
end)

lib.callback.register('checkSnowballAndCarrotCount', function(source)
    local snowballs = exports.ox_inventory:GetItemCount(source, 'weapon_snowball')
    local carrot = exports.ox_inventory:GetItemCount(source, 'carrot')
    return snowballs < 10 or carrot < 1
end)

lib.callback.register('snow:GetBucket', function(source)
    return GetPlayerRoutingBucket(source)
end)

ESX.RegisterUsableItem('weapon_snowball', function(source)
    TriggerClientEvent('qbx_smallresources:client:snowmanProgress', source)
end)

ESX.RegisterUsableItem('carrot', function(source)
    TriggerClientEvent('qbx_smallresources:client:snowmanProgress', source)
end)
