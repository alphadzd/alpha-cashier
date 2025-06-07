local QBCore = exports['qb-core']:GetCoreObject()
local RegistersRobbed = {}

local function GetLocaleText(text, ...)
    local lang = Config.Language
    if not Config.Locales[lang] then lang = 'en' end
    if not Config.Locales[lang][text] then return 'Missing locale: ' .. text end
    
    return string.format(Config.Locales[lang][text], ...)
end

local function HasEnoughPolice()
    local cops = 0
    local players = QBCore.Functions.GetQBPlayers()
    
    for _, v in pairs(players) do
        if v.PlayerData.job.name == "police" and v.PlayerData.job.onduty then
            cops = cops + 1
        end
    end
    
    return cops >= Config.MinPoliceOnline
end

local function IsRegisterRobbed(registerId, coords)
    local uniqueKey = registerId .. "_" .. tostring(coords.x) .. "_" .. tostring(coords.y)
    
    if RegistersRobbed[uniqueKey] then
        local timeElapsed = os.time() - RegistersRobbed[uniqueKey]
        if timeElapsed < (Config.RobberyTimeout * 60) then
            return true
        end
    end
    return false
end

local function MarkRegisterRobbed(registerId, coords)
    local uniqueKey = registerId .. "_" .. tostring(coords.x) .. "_" .. tostring(coords.y)
    RegistersRobbed[uniqueKey] = os.time()
end

local function GenerateRewards()
    local cash = math.random(Config.MinReward, Config.MaxReward)
    local items = {}
    
    for _, itemData in pairs(Config.RewardItems) do
        if math.random(1, 100) <= itemData.chance then
            local amount = math.random(itemData.min, itemData.max)
            table.insert(items, {
                name = itemData.item,
                amount = amount
            })
        end
    end
    
    return {
        cash = cash,
        items = items
    }
end

QBCore.Functions.CreateCallback('alpha-cashier:server:CanRobRegister', function(source, cb, registerId, coords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return cb(false, 'Invalid player') end
    
    if not HasEnoughPolice() then
        return cb(false, GetLocaleText('no_police'))
    end
    
    if IsRegisterRobbed(registerId, coords) then
        return cb(false, GetLocaleText('register_empty'))
    end
    
    if Config.RobberyItem ~= 'none' then
        local hasItem = Player.Functions.GetItemByName(Config.RobberyItem)
        if not hasItem then
            return cb(false, GetLocaleText('need_item', Config.RobberyItem))
        end
    end
    
    cb(true)
end)

RegisterNetEvent('alpha-cashier:server:StartRobbery', function(registerId, coords, zoneName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    MarkRegisterRobbed(registerId, coords)
    
    local alertMessage = GetLocaleText('robbery_police_notify', zoneName)
    for _, v in pairs(QBCore.Functions.GetQBPlayers()) do
        if v.PlayerData.job.name == "police" and v.PlayerData.job.onduty then
            TriggerClientEvent('alpha-cashier:client:PoliceAlert', v.PlayerData.source, coords, alertMessage)
        end
    end
    
    if Config.RobberyItemRemove then
        local item = Player.Functions.GetItemByName(Config.RobberyItem)
        if item then
            if item.amount <= Config.RobberyItemUses then
                Player.Functions.RemoveItem(Config.RobberyItem, item.amount)
            else
                Player.Functions.RemoveItem(Config.RobberyItem, Config.RobberyItemUses)
            end
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.RobberyItem], "remove")
        end
    end
    
    TriggerClientEvent('QBCore:Notify', src, GetLocaleText('robbery_started'), 'primary')
end)

RegisterNetEvent('alpha-cashier:server:RobberySuccess', function(registerId, score)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local finalCash = score
    
    local rewards = GenerateRewards()
    
    Player.Functions.AddMoney('cash', finalCash)
    
    for _, item in pairs(rewards.items) do
        Player.Functions.AddItem(item.name, item.amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.name], "add")
    end
    
    TriggerClientEvent('QBCore:Notify', src, GetLocaleText('robbery_successful', finalCash), 'success')
end)

RegisterNetEvent('alpha-cashier:server:RobberyFailed', function()
    local src = source
    TriggerClientEvent('QBCore:Notify', src, GetLocaleText('robbery_failed'), 'error')
end)

RegisterNetEvent('alpha-cashier:server:RobberyCancelled', function()
    local src = source
    TriggerClientEvent('QBCore:Notify', src, GetLocaleText('robbery_cancelled'), 'error')
end)


-- If you want to get more resources, please contact me on discord.
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    Citizen.SetTimeout(1000, function()
        local p1 = "\27[95m"  
        local p2 = "\27[35m"  
        local p3 = "\27[91m"  
        local p4 = "\27[31m"  
        local white = "\27[97m"
        local reset = "\27[0m"
        print(p1 .. " __        __  ____                 _                                  _   " .. reset)
        print(p1 .. " \\ \\      / / |  _ \\  _____   _____| | ___  _ __  _ __ ___   ___ _ __ | |_ " .. reset)
        print(p2 .. "  \\ \\ /\\ / /  | | | |/ _ \\ \\ / / _ \\ |/ _ \\| '_ \\| '_ ` _ \\ / _ \\ '_ \\| __|" .. reset)
        print(p2 .. "   \\ V  V /   | |_| |  __/\\ V /  __/ | (_) | |_) | | | | | |  __/ | | | |_ " .. reset)
        print(p3 .. "    \\_/\\_/    |____/ \\___| \\_/ \\___|_|\\___/| .__/|_| |_| |_|\\___|_| |_|\\__|" .. reset)
        print(p4 .. "                                           |_|                              " .. reset)
        print(white .. "                 Created by: Alpha" .. reset)
        print(white .. "                 Discord: https://discord.gg/w4dev" .. reset)
        print(white .. "                 If you want to get more resources, please contact me on discord." .. reset)
    end)
end)
