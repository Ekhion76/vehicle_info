local enable, tempClosestVehicles
local closestVehicles = {}
local next = next

local function round(num)
    return math.floor(num * 10 + 0.5) / 10
end

local function DrawText3D(coords, text)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z + 2.5)
    local dist = #(GetGameplayCamCoords() - coords)

    local scale = (1 / dist) * 15
    local fov = (1 / GetGameplayCamFov()) * 10
    scale = scale * fov

    if onScreen then
        SetTextScale(1.5 * scale, 1.5 * scale)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

function start()
    CreateThread(function()
        local pos, model, info
        local pattern = '%s: %s~n~'
        while enable do
            Wait(500)

            pos = GetEntityCoords(PlayerPedId())
            tempClosestVehicles = {}

            for _, vehicle in pairs(GetGamePool('CVehicle')) do
                if #(GetEntityCoords(vehicle) - pos) <= 80 then
                    model = GetEntityModel(vehicle)
                    info = ''
                    tempClosestVehicles[vehicle] = info
                            .. pattern:format('speed', round(GetEntitySpeed(vehicle), 1))
                            .. pattern:format('plate', GetVehicleNumberPlateText(vehicle))
                            .. pattern:format('owner', NetworkPlayerGetName(NetworkGetEntityOwner(vehicle)))
                            .. pattern:format('engine', round(GetVehicleEngineHealth(vehicle)))
                            .. pattern:format('body', round(GetVehicleBodyHealth(vehicle)))
                    --..pattern:format('fMass', GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fMass'))
                    --..pattern:format('massRatio', GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fPosConstraintMassRatio'))
                    --..pattern:format('fSteering', GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fSteeringLock'))
                    --..pattern:format('tankHealth', round(GetVehiclePetrolTankHealth(vehicle)))
                    --..pattern:format('oilLevel', round(GetVehicleOilLevel(vehicle)))
                    --..pattern:format('class', GetVehicleClass(vehicle))
                    --..pattern:format('model', model)
                    --..pattern:format('numOfSeats', GetVehicleModelNumberOfSeats(model))
                    --..pattern:format('displayName', GetDisplayNameFromVehicleModel(model))
                end
            end
            closestVehicles = tempClosestVehicles
        end
    end)

    -- VEHICLE OVERHEAD
    CreateThread(function()
        while enable do
            Wait(0)
            if (next(closestVehicles)) then
                for vehicle, info in pairs(closestVehicles) do
                    DrawText3D(GetEntityCoords(vehicle), info)
                end
            else
                Wait(1000)
            end
        end
    end)
end

RegisterCommand('vehinfo', function()
    enable = not enable
    if enable then
        start()
    end
end)