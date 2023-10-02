Config = {}

Config.UseESX = true								-- Use ESX Framework
Config.UseQBCore = false							-- Use QBCore Framework (Ignored if Config.UseESX = true)

Config.UseCustomNotify = false				-- Use a custom notification script, must complete event below.
-- Only complete this event if Config.UseCustomNotify is true; mythic_notification provided as an example
RegisterNetEvent('angelicxs-k9scipt:CustomNotify')
AddEventHandler('angelicxs-k9scipt:CustomNotify', function(message, type)
    --exports.mythic_notify:SendAlert(type, message, 4000)
end)

-- https://docs.fivem.net/docs/game-references/controls/
Config.SearchCommand = 38 							-- E - When aiming at a person, press this button to have the dog search them
													-- To search a vehicle use your thirdeye on the vehicle
Config.AttackCommand = 47 							-- G - When aiming at a person, press this button to have the dog attack them
Config.FollowCommand = 23 							-- F - Press this button to have the dog follow you
Config.StayCommand = 29 							-- B - Press this button to have the dog stay

Config.ThirdEyeName = 'qb-target'					-- Name of the third eye system you use
Config.K9Kennel = {									-- Location of where police can pull out a K9
	vector3(453.94, -990.0, 30.69),
}
Config.DogMaxHp = 200								-- Sets Dog's max hp (MAX IS 200)
Config.LEOJobName = {'police'}						-- Name of police job that can pull out K9
Config.JobRestriction = true						-- If true, only allows police of a certain rank or higher to pull out a K9
Config.JobRank = 3									-- If Config.JobRestriction = true, then sets what minimum rank a police officer must be to pull out a K9
Config.ItemRestriction = false						-- If true, will only allow anyone with the item to spawn K9 (can be used with Config.JobRestriction to only let police with a certain item spawn K9)
Config.AllowedItemList = {'itemnamelisthere'}		-- If Config.ItemRestriction = true, the list of items that will allow a K9 to spawn

Config.SearchableItems = {
	'aluminumoxide',
	'ironoxide',
	'thermite',
	'cokebaggy',
	'joint',
	'crack_baggy',
	'xtcbaggy',
	'weed_brick',
	'coke_brick',
	'coke_small_brick',
	'oxy',
	'weed_white-widow',
	'weed_skunk',
	'weed_purple-haze',
	'weed_og-kush',
	'weed_amnesia',
	'weed_ak47',
	'weed_skunk_cbd',
	'weed_og-kush_cbd',
	'weed_white-widow_cbd',
	'weed_ak47_cbd',
	'weed_amnesia_cbd',
	'weed_purple-haze_cbd',
	'weed_gelato_cbd',
	'weed_zkittlez_cbd',
	'weed_skunk_cbd_joint',
	'weed_og-kush_cbd_joint',
	'weed_white-widow_cbd_joint',
	'weed_ak47_cbd_joint',
	'weed_amnesia_cbd_joint',
	'weed_purple-haze_cbd_joint',
	'weed_gelato_cbd_joint',
	'weed_zkittlez_cbd_joint',
	'gummy_skunk_cbd',
	'gummy_og-kush_cbd',
	'gummy_white-widow_cbd',
	'gummy_ak47_cbd',
	'gummy_amnesia_cbd',
	'gummy_purple-haze_cbd',
	'gummy_gelato_cbd',
	'gummy_zkittlez_cbd',
	


}

-- Language Configuration
Config.LangType = {
	['error'] = 'error',
	['success'] = 'success',
	['info'] = 'primary'
}

Config.Lang = {
	['no_dog'] = 'You need a K9 out to search with a dog.',
	['no_cop'] = 'You are not a law enforcement officer!',
	['low_rank'] = 'You need a to be a higher rank to request a police K9!',
	['no_item'] = 'You do not have the appropriate items to request a police K9!',
	['miss_reqs'] = 'You are missing the requirements to grab a police K9!',
	['get_k9'] = 'Get/Return K9',
	['search_car_k9'] = 'Search Vehicle with K9',


}
