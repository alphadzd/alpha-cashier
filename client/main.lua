local QBCore = exports['qb-core']:GetCoreObject()
local isRobbing = false
local currentRegister = nil
local cashierPeds = {}
local cashierObjects = {}
local blips = {}

local function GetLocaleText(text, ...)
    local lang = Config.Language
    if not Config.Locales[lang] then lang = 'en' end
    if not Config.Locales[lang][text] then return 'Missing locale: ' .. text end
    
    return string.format(Config.Locales[lang][text], ...)
end

local function FindAllCashiers()
    local existingCashiers = {}
    for _, cashier in ipairs(cashierObjects) do
        if cashier.object then
            existingCashiers[cashier.object] = true
        else
            local coordKey = tostring(cashier.coords.x) .. "_" .. tostring(cashier.coords.y) .. "_" .. tostring(cashier.coords.z)
            existingCashiers[coordKey] = true
        end
    end
    
    local cashierModels = {
        `prop_till_01`,
        `prop_till_02`,
        `v_ret_gc_cashreg`,
        `prop_till_03`,
        `v_ret_ta_till1`,
        `v_ret_ta_till2`,
        `prop_cs_till_01`,
        `v_corp_officedesk`,
        `v_ret_247_till1`,
        `v_ret_247_till2`,
        `v_ret_247_till3`,
        `v_ilev_gasdoor_r`,
        `v_ilev_gasdoor`,
        `v_ret_gc_drawer`,
        `prop_cash_register_01`,
        `prop_cash_register_02`,
        `p_till_01_s`,
        `prop_food_cb_till`,
        `prop_food_bs_tray_01`,
        `prop_food_bs_tray_02`,
        `prop_food_bs_tray_03`,
        `prop_food_bs_tray_06`,
        `prop_food_tray_01`,
        `prop_food_van_01`,
        `prop_food_van_02`,
        `prop_bar_till_01`,
        `prop_bar_till_02`,
        `prop_till_01_dam`,
        `prop_till_02_dam`,
        `prop_till_03_dam`,
    }
    
    local allObjects = GetGamePool('CObject')
    local foundCount = 0
    
    for _, model in ipairs(cashierModels) do
        for i = 1, #allObjects do
            local obj = allObjects[i]
            if GetEntityModel(obj) == model and not existingCashiers[obj] then
                local coords = GetEntityCoords(obj)
                
                table.insert(cashierObjects, {
                    object = obj,
                    coords = coords,
                    zone = "Store",
                    zoneType = "store",
                    id = #cashierObjects + 1
                })
                
                existingCashiers[obj] = true
                foundCount = foundCount + 1
            end
        end
    end
    
    for i = 1, #allObjects do
        local obj = allObjects[i]
        if not existingCashiers[obj] then
            local model = GetEntityModel(obj)
            local modelName = GetEntityArchetypeName(obj)
            
            if modelName then
                local lowerName = string.lower(modelName)
                if string.find(lowerName, "till") or 
                   string.find(lowerName, "register") or 
                   string.find(lowerName, "cash") or
                   string.find(lowerName, "drawer") then
                    
                    local coords = GetEntityCoords(obj)
                    table.insert(cashierObjects, {
                        object = obj,
                        coords = coords,
                        zone = "Store",
                        zoneType = "store",
                        id = #cashierObjects + 1
                    })
                    
                    exports['qb-target']:AddTargetModel(model, {
                        options = {
                            {
                                type = "client",
                                event = "alpha-cashier:client:RobCashier",
                                icon = "fas fa-money-bill",
                                label = "Rob Register",
                            },
                        },
                        distance = 2.0
                    })
                    
                    existingCashiers[obj] = true
                    foundCount = foundCount + 1
                end
            end
        end
    end
    
    local hardcodedLocations = {
        {x = -47.24, y = -1757.65, z = 29.53},
        {x = 24.50, y = -1345.63, z = 29.50},
        {x = 372.66, y = 328.77, z = 103.57},
        {x = -706.15, y = -913.46, z = 19.22},
        {x = 1164.94, y = -322.64, z = 69.21},
        {x = 1134.25, y = -982.47, z = 46.42},
        {x = -1222.78, y = -907.22, z = 12.33},
        {x = -1487.7, y = -378.53, z = 40.16},
        {x = -2967.79, y = 390.75, z = 15.04},
        {x = 1392.81, y = 3606.47, z = 34.98},
        {x = 1165.95, y = 2710.20, z = 38.16},
        {x = 549.04, y = 2669.36, z = 42.16},
        {x = 1959.96, y = 3741.98, z = 32.34},
        {x = 1697.87, y = 4923.60, z = 42.06},
        {x = 2678.02, y = 3279.40, z = 55.24},
        {x = -3242.23, y = 1000.01, z = 12.83},
        {x = -3038.95, y = 584.55, z = 7.91},
        {x = 2557.19, y = 380.83, z = 108.62},
        {x = -1820.38, y = 794.25, z = 138.09},
    }
    
    for i, loc in ipairs(hardcodedLocations) do
        local coordKey = tostring(loc.x) .. "_" .. tostring(loc.y) .. "_" .. tostring(loc.z)
        if not existingCashiers[coordKey] then
            table.insert(cashierObjects, {
                object = nil,
                coords = vector3(loc.x, loc.y, loc.z),
                zone = "Store",
                zoneType = "store",
                id = #cashierObjects + 1
            })
            existingCashiers[coordKey] = true
            foundCount = foundCount + 1
        end
    end
    
    return foundCount
end

local function SetupCashierTargets()
    local allCashierModels = {
        `prop_till_01`,
        `prop_till_02`,
        `v_ret_gc_cashreg`,
        `prop_till_03`,
        `v_ret_ta_till1`,
        `v_ret_ta_till2`,
        `prop_cs_till_01`,
        `v_corp_officedesk`,
        `v_ret_247_till1`,
        `v_ret_247_till2`,
        `v_ret_247_till3`,
        `v_ilev_gasdoor_r`,
        `v_ilev_gasdoor`,
        `v_ret_gc_drawer`,
        `prop_cash_register_01`,
        `prop_cash_register_02`,
        `p_till_01_s`,
        `prop_food_cb_till`,
        `prop_food_bs_tray_01`,
        `prop_food_bs_tray_02`,
        `prop_food_bs_tray_03`,
        `prop_food_bs_tray_06`,
        `prop_food_tray_01`,
        `prop_food_van_01`,
        `prop_food_van_02`,
        `prop_bar_till_01`,
        `prop_bar_till_02`,
        `prop_till_01_dam`,
        `prop_till_02_dam`,
        `prop_till_03_dam`,
    }
    
    pcall(function()
        for _, model in ipairs(allCashierModels) do
            exports['qb-target']:RemoveTargetModel(model, 'RobCashier')
        end
    end)
    
    exports['qb-target']:AddTargetModel(allCashierModels, {
        options = {
            {
                type = "client",
                event = "alpha-cashier:client:RobCashier",
                icon = "fas fa-money-bill",
                label = "Rob Register",
            },
        },
        distance = 2.0
    })
    
    local existingZones = {}
    
    for i, cashier in ipairs(cashierObjects) do
        if not cashier.object then
            local zoneName = "cashier_" .. math.floor(cashier.coords.x) .. "_" .. math.floor(cashier.coords.y)
            
            if not existingZones[zoneName] then
                pcall(function()
                    exports['qb-target']:RemoveZone(zoneName)
                end)
                
                exports['qb-target']:AddBoxZone(
                    zoneName,
                    cashier.coords,
                    0.6, 0.6,
                    {
                        name = zoneName,
                        heading = 0,
                        debugPoly = false,
                        minZ = cashier.coords.z - 0.3,
                        maxZ = cashier.coords.z + 0.3,
                    },
                    {
                        options = {
                            {
                                type = "client",
                                event = "alpha-cashier:client:RobCashier",
                                icon = "fas fa-money-bill",
                                label = "Rob Register",
                            },
                        },
                        distance = 2.0
                    }
                )
                
                existingZones[zoneName] = true
            end
        end
    end
end

local function CreatePoliceBlip(coords, text)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 161)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 1)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
    
    table.insert(blips, {
        blip = blip,
        time = GetGameTimer()
    })
    
    SetBlipFlashes(blip, true)
    
    return blip
end

local function CleanupBlips()
    local currentTime = GetGameTimer()
    local blipsToKeep = {}
    
    for i = 1, #blips do
        local blipData = blips[i]
        if currentTime - blipData.time < (Config.BlipDuration * 1000) then
            table.insert(blipsToKeep, blipData)
        else
            RemoveBlip(blipData.blip)
        end
    end
    
    blips = blipsToKeep
end

local function GetNearestCashier()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local nearestDist = 999999
    local nearest = nil
    
    for i = 1, #cashierObjects do
        local cashier = cashierObjects[i]
        local dist = #(playerCoords - cashier.coords)
        if dist < nearestDist then
            nearestDist = dist
            nearest = cashier
        end
    end
    
    if nearestDist <= 5.0 then
        return nearest
    end
    
    if nearestDist > 5.0 and nearestDist < 20.0 then
        local foundNewCashiers = FindAllCashiers()
        if foundNewCashiers > 0 then
            nearestDist = 999999
            nearest = nil
            
            for i = 1, #cashierObjects do
                local cashier = cashierObjects[i]
                local dist = #(playerCoords - cashier.coords)
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = cashier
                end
            end
            
            if nearestDist <= 5.0 then
                return nearest
            end
        end
    end
    
    return nil
end

local function StartRobberyMinigame(cashier)
    isRobbing = true
    currentRegister = cashier
    
    TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_ATM", 0, true)
    
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openGame'
    })
    
    QBCore.Functions.Notify(GetLocaleText('minigame_started'), 'primary')
end

local function HandleSuccessfulRobbery(amount)
    QBCore.Functions.Progressbar("collect_cash", GetLocaleText('collecting_cash'), 5000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "mp_common",
        anim = "givetake1_a",
        flags = 50,
    }, {}, {}, function()
        if currentRegister then
            TriggerServerEvent('alpha-cashier:server:RobberySuccess', currentRegister.id, amount)
            currentRegister = nil
        end
        ClearPedTasks(PlayerPedId())
        isRobbing = false
    end, function()
        ClearPedTasks(PlayerPedId())
        isRobbing = false
        TriggerServerEvent('alpha-cashier:server:RobberyCancelled')
    end)
end

Citizen.CreateThread(function()
    while not QBCore.Functions.GetPlayerData().job do
        Citizen.Wait(100)
    end
    
    Citizen.Wait(10000)
    
    local foundCount = FindAllCashiers()
    
    SetupCashierTargets()
    
    Citizen.SetTimeout(30000, function()
        local newFound = FindAllCashiers()
        if newFound > 0 then
            SetupCashierTargets()
        end
    end)
    
    Citizen.SetTimeout(120000, function()
        local newFound = FindAllCashiers()
        if newFound > 0 then
            SetupCashierTargets()
        end
    end)
end)

Citizen.CreateThread(function()
    while true do
        CleanupBlips()
        Citizen.Wait(10000)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000)
        
        local newCashiersFound = FindAllCashiers()
        
        if newCashiersFound > 0 then
            SetupCashierTargets()
        end
    end
end)

RegisterNetEvent('alpha-cashier:client:RobCashier', function()
    if isRobbing then 
        QBCore.Functions.Notify('You are already robbing a register', 'error')
        return 
    end
    
    local cashier = GetNearestCashier()
    if not cashier then 
        QBCore.Functions.Notify('No register found nearby', 'error')
        
        FindAllCashiers()
        SetupCashierTargets()
        return 
    end
    
    QBCore.Functions.TriggerCallback('alpha-cashier:server:CanRobRegister', function(canRob, message)
        if canRob then
            TriggerServerEvent('alpha-cashier:server:StartRobbery', cashier.id, cashier.coords, cashier.zone)
            
            StartRobberyMinigame(cashier)
        else
            QBCore.Functions.Notify(message, 'error')
        end
    end, cashier.id, cashier.coords)
end)

RegisterNetEvent('alpha-cashier:client:PoliceAlert', function(coords, message)
    local PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData.job.name ~= "police" or not PlayerData.job.onduty then return end
    
    CreatePoliceBlip(coords, "Register Robbery")
    
    QBCore.Functions.Notify(message, 'police')
end)

RegisterNUICallback('gameWon', function(data, cb)
    SetNuiFocus(false, false)
    HandleSuccessfulRobbery(data.score)
    cb('ok')
end)

RegisterNUICallback('gameFailed', function(data, cb)
    SetNuiFocus(false, false)
    ClearPedTasks(PlayerPedId())
    isRobbing = false
    
    QBCore.Functions.Notify(GetLocaleText('bomb_exploded'), 'error', 5000)
    
    TriggerServerEvent('alpha-cashier:server:RobberyFailed')
    currentRegister = nil
    
    cb('ok')
end)

RegisterNUICallback('withdrawCash', function(data, cb)
    SetNuiFocus(false, false)
    HandleSuccessfulRobbery(data.amount)
    cb('ok')
end)

RegisterNUICallback('closeGame', function(data, cb)
    SetNuiFocus(false, false)
    ClearPedTasks(PlayerPedId())
    
    if isRobbing then
        TriggerServerEvent('alpha-cashier:server:RobberyCancelled')
        isRobbing = false
        currentRegister = nil
    end
    
    cb('ok')
end)

RegisterCommand('refreshcashiers', function()
    cashierObjects = {}
    FindAllCashiers()
    SetupCashierTargets()
end)

RegisterCommand('testcashier', function()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local dummyCashier = {
        id = 999,
        coords = playerCoords,
        zone = "TestZone",
        zoneType = "store"
    }
    
    TriggerServerEvent('alpha-cashier:server:StartRobbery', dummyCashier.id, dummyCashier.coords, dummyCashier.zone)
    StartRobberyMinigame(dummyCashier)
    
    QBCore.Functions.Notify('Started test robbery minigame', 'success')
end)

RegisterCommand('addcashier', function()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local id = #cashierObjects + 1
    
    table.insert(cashierObjects, {
        object = nil,
        coords = playerCoords,
        zone = "CustomRegister",
        zoneType = "store",
        id = id
    })
    
    exports['qb-target']:AddBoxZone(
        "cashier_custom_" .. id,
        playerCoords,
        0.6, 0.6,
        {
            name = "cashier_custom_" .. id,
            heading = GetEntityHeading(PlayerPedId()),
            debugPoly = false,
            minZ = playerCoords.z - 0.3,
            maxZ = playerCoords.z + 0.3,
        },
        {
            options = {
                {
                    type = "client",
                    event = "alpha-cashier:client:RobCashier",
                    icon = "fas fa-money-bill",
                    label = "Rob Register",
                },
            },
            distance = 2.0
        }
    )
    
    QBCore.Functions.Notify('Added custom cash register at your position', 'success')
end)

RegisterCommand('spawncashier', function()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local heading = GetEntityHeading(PlayerPedId())
    
    local modelHash = `prop_till_01`
    
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(1)
    end
    
    local forward = GetEntityForwardVector(PlayerPedId())
    local pos = vector3(
        playerCoords.x + forward.x * 1.0,
        playerCoords.y + forward.y * 1.0,
        playerCoords.z - 1.0
    )
    
    local obj = CreateObject(modelHash, pos.x, pos.y, pos.z, true, false, false)
    SetEntityHeading(obj, heading)
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)
    
    local objCoords = GetEntityCoords(obj)
    table.insert(cashierObjects, {
        object = obj,
        coords = objCoords,
        zone = "SpawnedRegister",
        zoneType = "store",
        id = #cashierObjects + 1
    })
    
    exports['qb-target']:AddTargetEntity(obj, {
        options = {
            {
                type = "client",
                event = "alpha-cashier:client:RobCashier",
                icon = "fas fa-money-bill",
                label = "Rob Register",
            },
        },
        distance = 2.0
    })
    
    QBCore.Functions.Notify('Spawned a physical cash register', 'success')
    
    SetModelAsNoLongerNeeded(modelHash)
end)