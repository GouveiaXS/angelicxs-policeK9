 ESX = nil
QBcore = nil

if Config.UseESX then
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
elseif Config.UseQBCore then
    QBCore = exports['qb-core']:GetCoreObject()
end

if Config.UseESX then
    ESX.RegisterServerCallback('angelicxs-k9script:server:search:ESX', function(source, cb, target)
        local src = target
        local xPlayer = ESX.GetPlayerFromId(src)
        for i = 1, #Config.SearchableItems, 1 do
            if xPlayer.getInventoryItem(Config.SearchableItems[i]).count >= 0 then
                cb(true)
                break
            end
        end
    end)
    -- The below commented out field was my attempt to get the ESX framework to search player's vehicles. Unfortunately I was unable to do so.
--[[     ESX.RegisterServerCallback('angelicxs-k9script:server:searchcar:ESX', function(source, cb, plate)
        print('Vehicle '..plate..' is being searched by a dog.')
        MySQL.Async.fetchAll('SELECT trunk FROM owned_vehicles WHERE plate = @plate', {
            ['@plate'] = plate,
            }, function (result)
            if result then
                local trunkItems = json.decode(result)
                if trunkItems then
                    for k, item in pairs(trunkItems) do
                        if item == Config.SearchableItems[i] then
                            cb(true)
                            break
                        end
                    end
                end
            end
        end)
        MySQL.Async.fetchAll('SELECT glovebox FROM owned_vehicles WHERE plate = @plate', {
            ['@plate'] = plate,
            }, function (result)
            if result then
                local trunkItems = json.decode(result)
                if trunkItems then
                    for k, item in pairs(trunkItems) do
                        if item == Config.SearchableItems[i] then
                            cb(true)
                            break
                        end
                    end
                end
            end
        end)
    end) ]]
elseif Config.UseQBCore then
    QBCore.Functions.CreateCallback('angelicxs-k9script:server:search:QBCore', function(source, cb, target)
        local src = target
        local Player = QBCore.Functions.GetPlayer(src)
        print(Player.PlayerData.citizenid..' was searched by a dog')
        for i = 1, #Config.SearchableItems, 1 do
			for slot, item in pairs(Player.PlayerData.items) do
				if Player.PlayerData.items[slot] then
					if item.name == Config.SearchableItems[i] then
                        cb(true)
						break
					end
				end
			end
		end
    end)
    QBCore.Functions.CreateCallback('angelicxs-k9script:server:searchcar:QBCore', function(source, cb, plate)
        print('Vehicle '..plate..' is being searched by a dog.')
        local trunk = GetOwnedVehicleGloveboxItems(plate)
        local glovebox = GetOwnedVehicleItems(plate)
        cb(trunk or glovebox)
    end)
    function GetOwnedVehicleGloveboxItems(plate)
        local items = {}
        local result = MySQL.Sync.fetchScalar('SELECT items FROM gloveboxitems WHERE plate = ?', {plate})
        if result then
            local gloveboxItems = json.decode(result)
            if gloveboxItems then
                for k, item in pairs(gloveboxItems) do
                    local itemInfo = QBCore.Shared.Items[item.name:lower()]
                    if itemInfo then
                        items[item.slot] = {
                            name = itemInfo["name"],
                        }
                        for i = 1, #Config.SearchableItems, 1 do
                            if items[item.slot].name == Config.SearchableItems[i] then
                                return true
                            end
                        end
                    end
                end
            end
        end
        return false
    end
    function GetOwnedVehicleItems(plate)
        local items = {}
        local result = MySQL.Sync.fetchScalar('SELECT items FROM trunkitems WHERE plate = ?', {plate})
        if result then
            local trunkItems = json.decode(result)
            if trunkItems then
                for k, item in pairs(trunkItems) do
                    local itemInfo = QBCore.Shared.Items[item.name:lower()]
                    if itemInfo then
                        items[item.slot] = {
                            name = itemInfo["name"],
                        }
                        for i = 1, #Config.SearchableItems, 1 do
                            if items[item.slot].name == Config.SearchableItems[i] then
                                return true
                            end
                        end
                    end
                end
            end
        end
        return false
    end
end