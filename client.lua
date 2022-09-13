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
        while ESX == nil do
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            Wait(0)
        end
    
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
	exports[Config.ThirdEyeName]:AddBoxZone('K9Kennel', Config.K9Kennel, 3, 3, {
		name = 'K9Kennel',
		heading = 151.91,
		debugPoly = false,
		minZ = Config.K9Kennel.z - 1.5,
		maxZ = Config.K9Kennel.z + 1.5,
	},
	{
		options = {
			{
				icon = "fas fa-hand-point-up",
				label = "Get/Return K9",
				action = function(entity)
					TriggerEvent('angelicxs-k9script:jobchecker')
				end,
			},
		},
		job = Config.LEOJobName,
		distance = 1.5 
	})

end)

RegisterNetEvent('angelicxs-k9script:jobchecker', function()
	if Config.JobRestriction then
		if PlayerJob == Config.LEOJobName and PlayerGrade >= Config.JobRank then
			TriggerEvent("angelicxs-k9script:dogspawn")
		elseif PlayerJob == Config.LEOJobName and PlayerGrade < Config.JobRank then
			TriggerEvent('angelicxs-k9scipt:Notify', Config.Lang['low_rank'], Config.LangType['error'])
		else
			TriggerEvent('angelicxs-k9scipt:Notify', Config.Lang['no_cop'], Config.LangType['error'])
		end
	else
		TriggerEvent('angelicxs-k9script:dogspawn')
	end
end)

RegisterNetEvent('angelicxs-k9script:dogspawn', function()
	if not DoesEntityExist(Dog) then
		local hash = HashGrabber('a_c_shepherd')
		local Player = PlayerPedId()
		local PlayerCoords = GetEntityCoords(Player)
		local PlayerHeading = GetEntityHeading(Player)
		local plyCoords = GetOffsetFromEntityInWorldCoords(Player, 0.0, 1.0, 0.0)
		Dog = CreatePed(3, hash, PlayerCoords.x, (PlayerCoords.y+2), (PlayerCoords.z-1), PlayerHeading, true, true)
		TaskSetBlockingOfNonTemporaryEvents(Dog, true)
		SetEntityAsMissionEntity(Dog)
		SetPedCombatRange(Dog, 2)
		SetPedFleeAttributes(Dog, 0, 0)
		SetPedCombatMovement(Dog, 3)
		GiveWeaponToPed(Dog, GetHashKey("WEAPON_ANIMAL"), 1, true, true)
		SetPedCombatAttributes(Dog, 3, true)
		SetPedCombatAttributes(Dog, 5, true)
        SetPedCombatAttributes(Dog, 46, true)
		TriggerEvent('angelicxs-k9script:dogactions')
		if Config.UseQBCore then -- If you manage to get the ESX server side to properly search vehicles (currently commented out) this export can be re added to ESX users.
			exports[Config.ThirdEyeName]:AddGlobalVehicle({
				options = {
					{
						event = "angelicxs-k9script:searchingcar",
						icon = "fas fa-arrow-up",
						label = "Search Vehicle with K9",
						distance = 2
					},
				},
			})
		end
	else
		DeleteEntity(Dog)
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
		while DoesEntityExist(Dog) do
			local Sleep = 0
			if Follow then
				local Player = PlayerPedId()
				local PlayerCoord = GetEntityCoords(Player)
				local DogCoord = GetEntityCoords(Dog)
				if not inVehicle then
                    if #(PlayerCoord - DogCoord) >= 5 then
                        TaskGoStraightToCoord(Dog, PlayerCoord, 30.0, -1, 0.0, 0.0)
                    else
                        if #(PlayerCoord - DogCoord) <= 1.5 then
                            ClearPedTasks(Dog)
						else
							TaskGoStraightToCoord(Dog, PlayerCoord, 1.5, -1, 0.0, 0.0)
                        end
                    end
                end
				Sleep = 100
			else
				Sleep = 1000
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
	print(hasItem)
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

AddEventHandler('onResourceStop', function(resource)
	if GetCurrentResourceName() == resource then
		if DoesEntityExist(Dog) then
			DeleteEntity(Dog)
		end
	end
end)
