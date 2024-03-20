ESX = nil
QBcore = nil
PlayerData = nil
PlayerJob = nil
PlayerGrade = nil
local Dog
local Follow = true
local Sit = false
local Down = false
local inVehicle = false
Relationship = nil
garbage = nil

RegisterNetEvent('angelicxs-k9scipt:Notify', function(message, type)
	if Config.UseCustomNotify then
        TriggerEvent('angelicxs-k9scipt:CustomNotify',message, type)
	elseif Config.UseESX then
		ESX.ShowNotification(message)
	elseif Config.UseQBCore then
		QBCore.Functions.Notify(message, type)
	end
end)


CreateThread(function()

    if Config.UseESX then
        ESX = exports["es_extended"]:getSharedObject()
	while not ESX.IsPlayerLoaded() do
            Wait(100)
        end
        PlayerData = ESX.GetPlayerData()
        CreateThread(function()
            while true do
                if PlayerData ~= nil then
                    PlayerJob = PlayerData.job.name
                    PlayerGrade = PlayerData.job.grade
                    break
                end
                Wait(100)
            end
        end)
        RegisterNetEvent('esx:setJob', function(job)
            PlayerJob = job.name
            PlayerGrade = job.grade
        end)

    elseif Config.UseQBCore then

        QBCore = exports['qb-core']:GetCoreObject()
        
        CreateThread(function()
			while true do
                PlayerData = QBCore.Functions.GetPlayerData()
				if PlayerData.citizenid ~= nil then
					PlayerJob = PlayerData.job.name
					PlayerGrade = PlayerData.job.grade.level
					break
				end
				Wait(100)
			end
		end)

        RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
            PlayerJob = job.name
            PlayerGrade = job.grade.level
        end)
    end

	for i=1, #Config.K9Kennel, 1 do
		if Config.ThirdEyeName == 'ox_target' then
			exports.ox_target:addBoxZone({
				name = Config.K9Kennel[i]..'K9Kennel',
				coords = {x = Config.K9Kennel[i].x, y = Config.K9Kennel[i].y, z = Config.K9Kennel[i].z},
				dimensions = {width = 3.0, length = 3.0},
				heading = 151.91,
				minZ = Config.K9Kennel[i].z - 1.5,
				maxZ = Config.K9Kennel[i].z + 1.5,
				debugPoly = false,
				options = {
					{
						event = 'angelicxs-k9script:jobchecker',
						icon = 'fas fa-hand-point-up',
						label = Config.Lang['get_k9'],
						distance = 1.5,
					},
				},
			})
			exports.ox_target:addGlobalVehicle({
				{
					name = 'An:gelicXS:K9SearchCar',
					event = 'angelicxs-k9script:searchingcar',
					icon = 'fas fa-arrow-up',
					label = Config.Lang['search_car_k9'],
					canInteract = function(entity, distance, coords, name, bone)
						return DoesEntityExist(Dog)
					end
				}
			})
			exports.ox_target:addGlobalPlayer({
				{ 
					label = Config.Lang['search_person_k9'],
					onSelect = function(entity)
						StopAttack()
						TriggerEvent('angelicxs-k9script:searching', tonumber(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))), entity)
					end,
					canInteract = function(entity, distance, data)
						if DoesEntityExist(Dog) then return true end
						return false
					end,
				}
			})
		else
			exports[Config.ThirdEyeName]:AddBoxZone(Config.K9Kennel[i]..'K9Kennel', Config.K9Kennel[i], 3, 3, {
				name = Config.K9Kennel[i]..'K9Kennel',
				heading = 151.91,
				debugPoly = false,
				minZ = Config.K9Kennel[i].z - 1.5,
				maxZ = Config.K9Kennel[i].z + 1.5,
			},
			{
				options = {
					{
						icon = "fas fa-hand-point-up",
						label = Config.Lang['get_k9'],
						action = function(entity)
							TriggerEvent('angelicxs-k9script:jobchecker')
						end,
					},
				},
				distance = 1.5 
			})
			exports[Config.ThirdEyeName]:AddGlobalVehicle({
				options = {
					{
						event = "angelicxs-k9script:searchingcar",
						icon = "fas fa-arrow-up",
						label = Config.Lang['search_car_k9'],
						distance = 2,
						canInteract = function(entity, distance, data) -- This will check if you can interact with it, this won't show up if it returns false, this is OPTIONAL
							if DoesEntityExist(Dog) then return true end -- This will return false if the entity interacted with is a player and otherwise returns true
							return false
						end,
					},
				},
			})
			exports[Config.ThirdEyeName]:AddGlobalPlayer({
				options = {
				  { 
					label = Config.Lang['search_person_k9'],
					action = function(entity)
						StopAttack()
						TriggerEvent('angelicxs-k9script:searching', tonumber(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))), entity)
					end,
					canInteract = function(entity, distance, data)
					  if DoesEntityExist(Dog) then return true end
					  return false
					end,
				  }
				},
				distance = 2.5,
			})
		end
	end
end)

RegisterNetEvent('angelicxs-k9script:jobchecker', function()
	if Config.JobRestriction or Config.ItemRestriction then
		local hasItem = false
		local hasJob = false
		local hasRank = false
		local allow = false
		if Config.ItemRestriction then
			hasItem = Search()
		end
		if Config.JobRestriction then
			hasJob = JobCheck()
			hasRank = RankCheck()
		end
		if Config.ItemRestriction and Config.JobRestriction then
			if hasItem and hasJob and hasRank then
				allow = true
			else
				TriggerEvent('angelicxs-k9scipt:Notify', Config.Lang['miss_reqs'], Config.LangType['error'])
			end
		elseif Config.ItemRestriction then
			if hasItem then
				allow = true
			else
				TriggerEvent('angelicxs-k9scipt:Notify', Config.Lang['no_item'], Config.LangType['error'])
			end
		elseif Config.JobRestriction then
			if hasJob and hasRank then
				allow = true
			elseif hasJob and not hasRank then
				TriggerEvent('angelicxs-k9scipt:Notify', Config.Lang['low_rank'], Config.LangType['error'])
			else
				TriggerEvent('angelicxs-k9scipt:Notify', Config.Lang['no_cop'], Config.LangType['error'])
			end
		end
		if allow then
			TriggerEvent("angelicxs-k9script:dogspawn")
		end
	else
		TriggerEvent('angelicxs-k9script:dogspawn')
	end
end)

RegisterNetEvent('angelicxs-k9script:dogspawn', function()
	if not Relationship then
		garbage, Relationship = AddRelationshipGroup('doggroup')
		SetRelationshipBetweenGroups(0, Relationship, Relationship)
	end
	if not DoesEntityExist(Dog) then
		local hash = HashGrabber('a_c_shepherd')
		local Player = PlayerPedId()
		local PlayerCoords = GetEntityCoords(Player)
		local PlayerHeading = GetEntityHeading(Player)
		local plyCoords = GetOffsetFromEntityInWorldCoords(Player, 0.0, 1.0, 0.0)
		Dog = CreatePed(3, hash, PlayerCoords.x, (PlayerCoords.y+2), (PlayerCoords.z-1), PlayerHeading, true, true)
		TaskSetBlockingOfNonTemporaryEvents(Dog, true)
		SetEntityMaxHealth(Dog, Config.DogMaxHp)
		SetEntityHealth(Dog, Config.DogMaxHp)
		SetEntityAsMissionEntity(Dog)
		SetPedCombatRange(Dog, 2)
		SetPedFleeAttributes(Dog, 0, 0)
		SetPedCombatMovement(Dog, 3)
		GiveWeaponToPed(Dog, GetHashKey("WEAPON_ANIMAL"), 1, true, true)
		SetPedCombatAttributes(Dog, 3, true)
		SetPedCombatAttributes(Dog, 5, true)
        SetPedCombatAttributes(Dog, 46, true)
		TriggerEvent('angelicxs-k9script:dogactions')
		SetPedRelationshipGroupHash(PlayerPedId(), Relationship)
		SetPedRelationshipGroupHash(Dog, Relationship)
	else
		DeleteEntity(Dog)
		RemoveRelationshipGroup(Relationship)
	end
end)

RegisterNetEvent('angelicxs-k9script:searchingcar', function()
	if DoesEntityExist(Dog) then
		StopAttack()
		local Player = PlayerPedId()
		local VehicleData = {}
		local hasItem = false
		local data = nil
		if Config.UseESX then
			VehicleData = ESX.Game.GetClosestVehicle()
			data = ESX.Game.GetVehicleProperties(VehicleData)
			ESX.TriggerServerCallback('angelicxs-k9script:server:searchcar:ESX', function(cb)
				hasItem = cb
			end,data.plate)
		elseif Config.UseQBCore then
			VehicleData = QBCore.Functions.GetClosestVehicle()
			local plate = QBCore.Functions.GetPlate(VehicleData)
			QBCore.Functions.TriggerCallback('angelicxs-k9script:server:searchcar:QBCore', function(cb)
				hasItem = cb
			end,plate)
		end
		local PlayerCoord = GetEntityCoords(VehicleData)
		local DogCoord = GetEntityCoords(Dog)
		TaskGoStraightToCoord(Dog, PlayerCoord, 2.0, -1, 0.0, 0.0)
		Wait(3000)
		ClearPedTasks(Dog)
		if hasItem then
			TaskTurnPedToFaceEntity(Dog,VehicleData,-1)
			AnimationSitDog()
		end
	else
		TriggerEvent('angelicxs-k9scipt:Notify', Config.Lang['no_dog'], Config.LangType['error'])
	end
end)

RegisterNetEvent('angelicxs-k9script:dogactions', function()
	CreateThread(function()
		while DoesEntityExist(Dog) do
			local DogCoord = GetEntityCoords(Dog)
			local Sleep = 0
			if IsControlJustReleased(0,Config.FollowCommand) then
				ClearPedTasks(Dog)
				Sleep = 2000
				Follow = true
			end
			Wait(Sleep)
		end
	end)
	
	CreateThread(function()
		local Near1 = 0
		while DoesEntityExist(Dog) do
			local Sleep = 1000
			if Follow then
				local Player = PlayerPedId()
				local PlayerCoord = GetEntityCoords(Player)
				local DogCoord = GetEntityCoords(Dog)
				local Dist = #(PlayerCoord - DogCoord)
				if not inVehicle then
					local DogMove = IsPedWalking(Dog) or IsPedRunning(Dog) or IsPedSprinting(Dog)
					if not DogMove then
						ClearPedTasks(Dog)
						TaskGoToEntity(Dog, Player, -1, 0.8, 8.0, 1073741824, 0)
					elseif Near1 == Dist then
						ClearPedTasks(Dog)
					end
				end
				Near1 = Dist
			end
			Wait(Sleep)
		end
	end)
	
	CreateThread(function()
		while DoesEntityExist(Dog) do
			local Player = PlayerPedId()
			local Sleep = 1000
			if IsPedInAnyVehicle(Player, false) and Follow then
				local Vehicle = GetVehiclePedIsIn(Player, false)
				if IsVehicleSeatAccessible(Dog, Vehicle, 1, true, true) then
					inVehicle = true
					TaskEnterVehicle(Dog, Vehicle, 2000, 1, 2, 1, 0)
					Wait(4000)
					TaskWarpPedIntoVehicle(Dog, Vehicle, 1)
				elseif IsVehicleSeatAccessible(Dog, Vehicle, 2, true, true) then
					inVehicle = true
					TaskEnterVehicle(Dog, Vehicle, 2000, 1, 2, 1, 0)
					Wait(4000)
					TaskWarpPedIntoVehicle(Dog, Vehicle, 2)
				else
					Follow = false
					AnimationSitDog()
				end
				while inVehicle do
					if not IsPedInAnyVehicle(Player, false) and Follow then
						Wait(500)
						inVehicle = false
						local DogCoords = GetEntityCoords(Player)
						local DogHP = GetEntityMaxHealth(Dog)
						--TaskLeaveVehicle(Dog, Vehicle,256)
                       	SetEntityCoords(Dog,DogCoords.x, DogCoords.y+1.5, DogCoords.z-0.8)
						Wait(100)
						PlaceObjectOnGroundProperly(Dog)
						SetEntityHealth(Dog, DogHP)
					end
					Wait(750)
				end
			end
			Wait(Sleep)
		end
	end)
	
	CreateThread(function()
		while DoesEntityExist(Dog) do
			local Sleep = 0
			if IsControlJustReleased(0,Config.StayCommand) then
				Sleep = 1000
				Follow = false
				local spot = math.random(1,2)
				if spot == 1 then
					AnimationSitDog()
				else
					AnimationLayDog()
				end
				while not Follow do
					Wait(100)
				end
			else
				Sleep = 0
			end
			Wait(Sleep)
		end
	end)
	
	CreateThread(function()
        while DoesEntityExist(Dog) do
            local Player = PlayerPedId()
            local _, targetentity = GetEntityPlayerIsFreeAimingAt(PlayerId())
            local Sleep = 500
            if IsEntityAPed(targetentity) then
				TaskCombatPed(Dog, targetentity, 0, 16)
                local target = tonumber(GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetentity)))
                Sleep = 0
                if IsControlJustReleased(0,Config.SearchCommand) then
                    StopAttack()
                    TriggerEvent('angelicxs-k9script:searching', target,targetentity)
                elseif IsControlJustReleased(0,Config.AttackCommand) then
                    StopAttack()
                    TriggerEvent('angelicxs-k9scipt:client:attacking', targetentity)
                end
            end
            Wait(Sleep)
        end
    end)
end)

RegisterNetEvent('angelicxs-k9scipt:client:attacking', function(target)
	Follow = false
	TaskCombatPed(Dog, target, 0, 16)
end)

RegisterNetEvent('angelicxs-k9script:searching', function(target,entity)
    local hasItem = false
    local DogCoord = GetEntityCoords(Dog)
    local PlayerCoord = GetEntityCoords(entity)
    if Config.UseESX then
		ESX.TriggerServerCallback('angelicxs-k9script:server:search:ESX', function(cb)
			hasItem = cb
		end,target) 
    elseif Config.UseQBCore then
		QBCore.Functions.TriggerCallback('angelicxs-k9script:server:search:QBCore', function(cb)
			hasItem = cb
		end,target)
    end
    while #(PlayerCoord - DogCoord) >= 1.5 do 
		PlayerCoord = GetEntityCoords(entity)
        DogCoord = GetEntityCoords(Dog)
        if #(PlayerCoord - DogCoord) >= 5 then
            TaskGoStraightToCoord(Dog, PlayerCoord, 2.0, -1, 0.0, 0.0)
        else
            TaskGoStraightToCoord(Dog, PlayerCoord, 1.0, -1, 0.0, 0.0)
            if #(PlayerCoord - DogCoord) <= 1.5 then
                ClearPedTasks(Dog)
                break
            end
        end
        Wait(0)
    end 
    Wait(1000)
    if hasItem then
        TaskTurnPedToFaceEntity(Dog,entity,-1)
        AnimationSitDog()
    end
end)

function StopAttack()
	ClearPedTasks(Dog)
	Follow = false
end

function HashGrabber(model)
    local hash = GetHashKey(model)
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        Wait(10)
    end
    while not HasModelLoaded(hash) do
      Wait(10)
    end
    return hash
end

function AnimationSitDog()
    RequestAnimDict('creatures@rottweiler@amb@world_dog_sitting@base')
    while not HasAnimDictLoaded('creatures@rottweiler@amb@world_dog_sitting@base') do
        Wait(10)
    end
    TaskPlayAnim(Dog,'creatures@rottweiler@amb@world_dog_sitting@base','base', 8.0, 8.0, -1, 1, 0, 0, 0, 0)
end

function AnimationLayDog()
    RequestAnimDict('creatures@rottweiler@amb@sleep_in_kennel@')
    while not HasAnimDictLoaded('creatures@rottweiler@amb@sleep_in_kennel@') do
        Wait(10)
    end
    TaskPlayAnim(Dog,'creatures@rottweiler@amb@sleep_in_kennel@','sleep_in_kennel', 8.0, 8.0, -1, 1, 0, 0, 0, 0)
end

function Search()
	local hasItem = false
	if Config.UseESX then
		PlayerData = ESX.GetPlayerData()
		for i = 1, #Config.AllowedItemList, 1 do
			for k, v in ipairs(PlayerData.inventory) do
				if v.name == Config.AllowedItemList[i] and v.count > 0 then
					hasItem = true
					break
				end
			end
		end
	elseif Config.UseQBCore then
		PlayerData = QBCore.Functions.GetPlayerData()
		for i = 1, #Config.AllowedItemList, 1 do
			for slot, item in pairs(PlayerData.items) do
				if PlayerData.items[slot] then
					if item.name == Config.AllowedItemList[i] then
						hasItem = true
						break
					end
				end
			end
		end
	end
	return hasItem
end

function JobCheck()
	for i = 1, #Config.LEOJobName do
		if PlayerJob == Config.LEOJobName[i] then
			return true
		end
	end
	return false
end

function RankCheck()
	if PlayerGrade >= Config.JobRank then
		return true
	else
		return false
	end 
end

AddEventHandler('onResourceStop', function(resource)
	if GetCurrentResourceName() == resource then
		if DoesEntityExist(Dog) then
			DeleteEntity(Dog)
		end
	end
end)
