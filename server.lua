ESX = nil
QBcore = nil

if Config.UseESX then
    ESX = exports["es_extended"]:getSharedObject()
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
	ESX.RegisterServerCallback('angelicxs-k9script:server:searchcar:ESX', function(source, cb, plate)
	    local xPlayer = ESX.GetPlayerFromId(source)
	    local search = true
	    local found = false
	    print('Vehicle ' .. plate .. ' is being searched by a dog.')
	    MySQL.Async.fetchAll('SELECT glovebox FROM owned_vehicles WHERE plate = ?', {plate},
	        function(result)
	        if result and #result > 0 then
	            local trunkItems = json.decode(result[1].glovebox)
	            if trunkItems then
	                for k, item in pairs(trunkItems) do
	                    for i = 1, #Config.SearchableItems, 1 do
	                        if item.name == Config.SearchableItems[i] then
	                            found = true
	                            break
	                        end
	                    end
	                end
	            end
	            trunkItems = json.decode(result[1].trunk)
	            if trunkItems and not found then
	                for k, item in pairs(trunkItems) do
	                    for i = 1, #Config.SearchableItems, 1 do
	                        if item.name == Config.SearchableItems[i] then
	                            found = true
	                            break
	                        end
	                    end
	                end
	            end
	        end
	        cb(found)
	    end)
	end)
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
        local found, glovebox, trunk = false, false, false
        glovebox = GetOwnedVehicleGloveboxItems(plate)
        if not glovebox then
            trunk = GetOwnedVehicleItems(plate)
        end
        cb(trunk or glovebox)
    end)
    function GetOwnedVehicleGloveboxItems(plate)
        local items = {}
        local result = exports["qb-inventory"]:getGloveboxItems(plate)
        if result then
            local gloveboxItems = result['items']
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
        local result = exports["qb-inventory"]:getTrunkItems(plate)
        if result then
            local trunkItems = result['items']
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
