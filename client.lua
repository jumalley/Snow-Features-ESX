local cooldown = false

local SnowmanEntity

local snowing = {
    'BLIZZARD',
    'SNOW',
    'SNOWLIGHT',
    'XMAS'
}

local snowmen = {
    'xm3_prop_xm3_snowman_01a',
    'xm3_prop_xm3_snowman_01b',
    'xm3_prop_xm3_snowman_01c',
}
local inSnowman = false

local keybind = lib.addKeybind({
    name = 'snowball',
    description = 'press G to make a snowball',
    defaultKey = 'G',
    onPressed = function(self)
        TriggerEvent('snowball')
    end,
})
RegisterNetEvent('snowball', function()

    local bucket = lib.callback.await('snow:GetBucket')

    if inSnowman then
        lib.notify({
            title = 'Action Denied',
            description = 'You can\'t do this while in a snowman!',
            type = 'error'
        })
        return
    end
    local weather = GlobalState.weather.weather

    if GetInteriorFromEntity(cache.ped) ~= 0 or bucket ~= 0 then
        lib.notify({
            title = 'Action Denied',
            description = 'You cannot make a snowball indoors!',
            type = 'error'
        })
        return
    end

    if cache.vehicle then
        return
    end
    local maxamount = lib.callback.await('checkSnowballCount')
    if not maxamount then
        lib.notify({
            title = 'Inventory Full',
            description = 'You can\'t carry more snowballs',
            type = 'error'
        })
        cooldown = false
        return
    end
    if lib.progressCircle({
            label = 'Making snowball',
            duration = 1500,
            position = 'bottom',
            useWhileDead = false,
            allowCuffed = false,
            allowSwimming = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = true,
            },
            anim = {
                dict = 'anim@mp_snowball',
                clip = 'pickup_snowball',
                flag = 0
            },
        }) then
        TriggerServerEvent('qbx_smallresources:server:addSnowballToInv')
        Wait(1500)
        cooldown = false
    else
        lib.notify({
            title = 'Action Cancelled',
            description = 'You have cancelled the action',
            type = 'error'
        })
    end
end)

RegisterNetEvent('qbx_smallresources:client:snowmanProgress', function()
    if lib.callback.await('checkSnowballAndCarrotCount') then
        lib.notify({
            title = 'Insufficient Materials',
            description = 'You do not have enough snowballs or carrots',
            type = 'error'
        })
        return
    end

    if lib.progressCircle({
            label = 'Making Snowman',
            duration = 15000,
            position = 'bottom',
            useWhileDead = false,
            allowCuffed = false,
            allowSwimming = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = true,
            },
            anim = {
                dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                clip = 'machinic_loop_mechandplayer',
                flag = 0
            },
        }) then
        local playerHeading = GetEntityHeading(cache.ped)
        local playerCoords = GetEntityCoords(cache.ped)

        local offsetX = math.sin(math.rad(playerHeading)) * 1.0
        local offsetY = math.cos(math.rad(playerHeading)) * 1.0
        local newCoords = vector4(playerCoords.x - offsetX, playerCoords.y + offsetY, playerCoords.z - 1.0, playerHeading)

        TriggerServerEvent('qbx_smallresources:server:removeSnowballAndCarrotFromInv')

        local randomIndex = math.random(1, #snowmen)
        local snowmanModel = snowmen[randomIndex]
        SnowmanEntity = CreateObject(snowmanModel, newCoords.x, newCoords.y, newCoords.z, true, true, true)
    else
        lib.notify({
            title = 'Action Cancelled',
            description = 'You have cancelled the action',
            type = 'error'
        })
    end
end)

local function snowmanCheck()
    inSnowman = true
    CreateThread(function()
        while inSnowman do
            Wait(0)
            if IsControlPressed(0, 32) or not DoesEntityExist(SnowmanEntity) then
                lib.hideTextUI()

                local coords = GetEntityCoords(cache.ped)

                lib.requestAnimDict('anim@sports@ballgame@handball@')
                lib.requestNamedPtfxAsset('core')
                UseParticleFxAssetNextCall('core')
                StartNetworkedParticleFxNonLoopedAtCoord('ent_dst_xt_snowman', coords.x, coords.y, coords.z, 0.0, 0.0, 0.0,
                    1, false, false, false)

                TaskPlayAnim(cache.ped, "anim@sports@ballgame@handball@", "ball_rstop_r", 8.0, -8.0, -1, 0, 0, false,
                    false, false)
                inSnowman = false
                SetEntityVisible(cache.ped, true, false)
                FreezeEntityPosition(cache.ped, false)

                local animDuration = GetAnimDuration('anim@sports@ballgame@handball@', 'ball_rstop_r')

                DeleteEntity(SnowmanEntity)
                Wait(animDuration * 1000)
                RemoveNamedPtfxAsset('core')
                RemoveAnimDict('anim@sports@ballgame@handball@')
            end
        end
    end)
end

local function hideInSnowman(snowmanCoords, snowmanEntity)
    local playerPed = cache.ped
    local distance = #(GetEntityCoords(playerPed) - vector3(snowmanCoords.x, snowmanCoords.y, snowmanCoords.z))
    if inSnowman then
        return
    end
    if distance > 2.0 then
        lib.notify({
            title = 'Too Far',
            description = 'You are too far away from the snowman',
            type = 'error'
        })
        return
    end
    SetEntityVisible(playerPed, false, false)
    SetEntityCoords(playerPed, snowmanCoords.x, snowmanCoords.y, snowmanCoords.z - 1, 0.0, 0.0, 0.0, false)
    FreezeEntityPosition(playerPed, true)

    lib.showTextUI('[w] - Exit', {
        position = "top-center",
        style = {
            borderRadius = 0,
            backgroundColor = '#48BB78',
            color = 'white'
        }
    })

    snowmanCheck()
end

for k, v in pairs(snowmen) do
    exports.ox_target:addModel(v, {
        {
            label = 'Hide in Snowman',
            onSelect = function(data)
                hideInSnowman(data.coords, data.entity)
            end
        }
    })
end
