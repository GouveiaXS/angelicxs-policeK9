# policeK9

Lite PoliceK9 script for FiveM Please check out other scripts by me on CFX (https://forum.cfx.re/u/angelicxs/activity/topics) or my paid stuff on Tebex (https://angelicxs.tebex.io/)

OX_Target compatability added by OfficialWoodyUK
Original Fork (https://github.com/OfficialWoodyUK/angelicxs-policeK9)

For ESX or QBCore.

This is a lite Police K9 Script that provides enough functionality to get a solid K9 unit rolling.
Main functionality:
* Enter/Exit Vehicles
* Search/Attack Players
* Stay
* Follow
* Job & Rank Lock
* Third-Eye Spawn/Despawn
* Search player owned vehicles

Buttons for commands can easily be swapped in the config.

# FOR QB-CORE Add following code in qb-inventory or ps-inventory /server.lua at bottom

```Lua
-- required for k9
function getTrunkItems(plate)
	if Trunks[plate] then
		return Trunks[plate]
	else
		local result = MySQL.scalar.await('SELECT items FROM trunkitems WHERE plate = ?', {plate})
		if not result then return false end
		local data = {
			items = json.decode(result)
		}
		return data
	end
end
function getGloveboxItems(plate)
	if Gloveboxes[plate] then
		return Gloveboxes[plate]
	else
		local result = MySQL.scalar.await('SELECT items FROM gloveboxitems WHERE plate = ?', {plate})
		if not result then return false end
		local data = {
			items = json.decode(result)
		}
		return data
	end
end
exports("getGloveboxItems", getGloveboxItems)
exports("getTrunkItems", getTrunkItems)
-- required for k9
```
