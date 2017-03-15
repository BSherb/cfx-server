local permission = {
	kick = 1,
	ban = 4
}

-- Loading MySQL Class
require "resources/essentialmode/lib/MySQL"

-- MySQL:open("IP", "databasname", "user", "password")
MySQL:open("192.168.0.13", "gta5_gamemode_essential", "root", "JFBS27NMGCXNVXLH")


-- Default commands
TriggerEvent('es:addCommand', 'admin', function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Your permission level is: ^2" .. user['permission_level'])
end)

-- Default commands
TriggerEvent('es:addCommand', 'report', function(source, args, user)
	table.remove(args, 1)
	TriggerClientEvent('chatMessage', source, "REPORT", {255, 0, 0}, " (^2" .. GetPlayerName(source) .." | "..source.."^0 ) " .. table.concat(args, " "))

	for k,v in ipairs(GetPlayers())do
		TriggerEvent("es:getPlayerFromId", k, function(user)
			if(tonumber(user.permission_level) > 0)then
				TriggerClientEvent('chatMessage', k, "REPORT", {255, 0, 0}, " (^2" .. GetPlayerName(source) .." | "..source.."^0 ) " .. table.concat(args, " "))
			end
		end)
	end
end)

-- Kicking
TriggerEvent('es:addAdminCommand', 'car', permission.ban, function(source, args, user)
	TriggerClientEvent('es_admin:spawnVehicle', source, args[2])
end, function(source, args, user)

end)

function appendNewPos(msg)
	local file = io.open('resources/[essential]/es_admin/positions.txt', "a")
	newFile = msg
	file:write(newFile)
	file:flush()
	file:close()
end


RegisterServerEvent('es_admin:givePos')
AddEventHandler('es_admin:givePos', function(str)
	appendNewPos(str)
end)

-- Kicking
TriggerEvent('es:addAdminCommand', 'kick', permission.kick, function(source, args, user)
		if(GetPlayerName(tonumber(args[2])))then
			local player = tonumber(args[2])

			-- User permission check
			TriggerEvent("es:getPlayerFromId", player, function(target)
				if(tonumber(target.permission_level) > tonumber(user.permission_level))then
					TriggerClientEvent("chatMessage", source, "SYSTEM", {255, 0, 0}, "You're not allowed to target this person!")
					return
				end

				local reason = args
				table.remove(reason, 1)
				table.remove(reason, 1)
				if(#reason == 0)then
					reason = "Kicked: You have been kicked from the server"
				else
					reason = "Kicked: " .. table.concat(reason, " ")
				end

				TriggerClientEvent('chatMessage', -1, "SYSTEM", {255, 0, 0}, "Player ^2" .. GetPlayerName(player) .. "^0 has been kicked(^2" .. reason .. "^0)")
				DropPlayer(player, reason)
			end)
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
		end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

-- Banning
TriggerEvent('es:addAdminCommand', 'ban', permission.ban, function(source, args, user)
		if(GetPlayerName(tonumber(args[2])) ~= nil)then
			-- User permission check
			local player = tonumber(args[2])
			TriggerEvent("es:getPlayerFromId", player, function(target)
					if(tonumber(target.permission_level) > tonumber(user.permission_level))then
						TriggerClientEvent("chatMessage", source, "SYSTEM", {255, 0, 0}, "You're not allowed to target this person!")
						return
					end
				local time = args[3]

				local message = ""

				if string.find(time, "m") then
					time = string.gsub(time, "m", "")
					time = os.time() + (tonumber(time) * 60)
					message = time .. " minute(s)"
				elseif string.find(time, "h") then
					time = string.gsub(time, "h", "")
					message = time .. " hour(s)"
					time = os.time() + (tonumber(time) * 60 * 60)
				else
					time = os.time() + tonumber(time)
					message = time .. " second(s)"
				end

				if not tonumber(time) > 0 then
					time = os.time() + 999999999999
					message = 'very long'
				end

				local reason = args
				table.remove(reason, 1)
				table.remove(reason, 1)
				table.remove(reason, 1)

				reason = "Banned: " .. table.concat(reason, " ")				

				if(reason == "Banned: ")then
					reason = reason .. "You have been banned for: ^1^*" .. message .. "^r^0."
					DropPlayer(player, "You have been banned for: " .. message)
				else
					DropPlayer(player, "Banned: " .. reason)
				end

				TriggerClientEvent('chatMessage', -1, "SYSTEM", {255, 0, 0}, "Player ^2" .. GetPlayerName(player) .. "^0 has been banned(^2" .. reason .. "^0)")

				local tstamp = os.date("*t", time)
				local tstamp2 = os.date("*t", os.time())

				MySQL:executeQuery("INSERT INTO bans (`banned`, `reason`, `expires`, `banner`, `timestamp`) VALUES ('@username', '@reason', '@expires', '@banner', '@now')",
				{['@username'] = target.identifier, ['@reason'] = reason, ['@expires'] = os.date(tstamp.year .. "-" .. tstamp.month .. "-" .. tstamp.day .. " " .. tstamp.hour .. ":" .. tstamp.min .. ":" .. tstamp.sec), ['@banner'] = user.identifier, ['@now'] = os.date(tstamp2.year .. "-" .. tstamp2.month .. "-" .. tstamp2.day .. " " .. tstamp2.hour .. ":" .. tstamp2.min .. ":" .. tstamp2.sec)})
			end)
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
		end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

function stringsplit(self, delimiter)
  local a = self:Split(delimiter)
  local t = {}

  for i = 0, #a - 1 do
     table.insert(t, a[i])
  end

  return t
end

-- Announcing
TriggerEvent('es:addAdminCommand', 'announce', permission.ban, function(source, args, user)
	table.remove(args, 1)
	TriggerClientEvent('chatMessage', -1, "ANNOUNCEMENT", {255, 0, 0}, "" .. table.concat(args, " "))
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

-- Freezing
local frozen = {}
TriggerEvent('es:addAdminCommand', 'freeze', permission.kick, function(source, args, user)
		if(GetPlayerName(tonumber(args[2])))then
			local player = tonumber(args[2])

			-- User permission check
			TriggerEvent("es:getPlayerFromId", player, function(target)
				if(tonumber(target.permission_level) > tonumber(user.permission_level))then
					TriggerClientEvent("chatMessage", source, "SYSTEM", {255, 0, 0}, "You're not allowed to target this person!")
					return
				end

				if(frozen[player])then
					frozen[player] = false
				else
					frozen[player] = true
				end

				TriggerClientEvent('es_admin:freezePlayer', player, frozen[player])

				local state = "unfrozen"
				if(frozen[player])then
					state = "frozen"
				end

				TriggerClientEvent('chatMessage', player, "SYSTEM", {255, 0, 0}, "You have been " .. state .. " by ^2" .. GetPlayerName(source))
				TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Player ^2" .. GetPlayerName(player) .. "^0 has been " .. state)
			end)
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
		end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

-- Bring
local frozen = {}
TriggerEvent('es:addAdminCommand', 'bring', permission.kick, function(source, args, user)
		if(GetPlayerName(tonumber(args[2])))then
			local player = tonumber(args[2])

			-- User permission check
			TriggerEvent("es:getPlayerFromId", player, function(target)
				if(tonumber(target.permission_level) > tonumber(user.permission_level))then
					TriggerClientEvent("chatMessage", source, "SYSTEM", {255, 0, 0}, "You're not allowed to target this person!")
					return
				end

				TriggerClientEvent('es_admin:teleportUser', player, source)

				TriggerClientEvent('chatMessage', player, "SYSTEM", {255, 0, 0}, "You have brought by ^2" .. GetPlayerName(source))
				TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Player ^2" .. GetPlayerName(player) .. "^0 has been brought")
			end)
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
		end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

-- Bring
local frozen = {}
TriggerEvent('es:addAdminCommand', 'slap', 4, function(source, args, user)
		if(GetPlayerName(tonumber(args[2])))then
			local player = tonumber(args[2])

			-- User permission check
			TriggerEvent("es:getPlayerFromId", player, function(target)
				if(tonumber(target.permission_level) > tonumber(user.permission_level))then
					TriggerClientEvent("chatMessage", source, "SYSTEM", {255, 0, 0}, "You're not allowed to target this person!")
					return
				end

				TriggerClientEvent('es_admin:slap', player)

				TriggerClientEvent('chatMessage', player, "SYSTEM", {255, 0, 0}, "You have slapped by ^2" .. GetPlayerName(source))
				TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Player ^2" .. GetPlayerName(player) .. "^0 has been slapped")
			end)
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
		end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

-- Freezing
local frozen = {}
TriggerEvent('es:addAdminCommand', 'goto', permission.kick, function(source, args, user)
		if(GetPlayerName(tonumber(args[2])))then
			local player = tonumber(args[2])

			-- User permission check
			TriggerEvent("es:getPlayerFromId", player, function(target)
				if(tonumber(target.permission_level) > tonumber(user.permission_level))then
					TriggerClientEvent("chatMessage", source, "SYSTEM", {255, 0, 0}, "You're not allowed to target this person!")
					return
				end

				TriggerClientEvent('es_admin:teleportUser', source, player)

				TriggerClientEvent('chatMessage', player, "SYSTEM", {255, 0, 0}, "You have been teleported to by ^2" .. GetPlayerName(source))
				TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Teleported to player ^2" .. GetPlayerName(player) .. "")
			end)
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
		end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

-- Kill yourself
TriggerEvent('es:addCommand', 'die', function(source, args, user)
	TriggerClientEvent('es_admin:kill', source)
	TriggerClientEvent('chatMessage', source, "", {0,0,0}, "^1^*You killed yourself.")
end)

-- Killing
TriggerEvent('es:addAdminCommand', 'slay', permission.kick, function(source, args, user)
		if(GetPlayerName(tonumber(args[2])))then
			local player = tonumber(args[2])

			-- User permission check
			TriggerEvent("es:getPlayerFromId", player, function(target)
				if(tonumber(target.permission_level) > tonumber(user.permission_level))then
					TriggerClientEvent("chatMessage", source, "SYSTEM", {255, 0, 0}, "You're not allowed to target this person!")
					return
				end

				TriggerClientEvent('es_admin:kill', player)

				TriggerClientEvent('chatMessage', player, "SYSTEM", {255, 0, 0}, "You have been killed by ^2" .. GetPlayerName(source))
				TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Player ^2" .. GetPlayerName(player) .. "^0 has been killed.")
			end)
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
		end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

-- Crashing
TriggerEvent('es:addAdminCommand', 'crash', 5, function(source, args, user)
		if(GetPlayerName(tonumber(args[2])))then
			local player = tonumber(args[2])

			-- User permission check
			TriggerEvent("es:getPlayerFromId", player, function(target)
				if(tonumber(target.permission_level) > tonumber(user.permission_level))then
					TriggerClientEvent("chatMessage", source, "SYSTEM", {255, 0, 0}, "You're not allowed to target this person!")
					return
				end

				TriggerClientEvent('es_admin:crash', player)

				TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Player ^2" .. GetPlayerName(player) .. "^0 has been crashed.")
			end)
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
		end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

-- Position
TriggerEvent('es:addAdminCommand', 'pos', permission.kick, function(source, args, user)
	TriggerClientEvent('es_admin:givePosition', source)
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)


-- Rcon commands
AddEventHandler('rconCommand', function(commandName, args)
	if commandName == 'setadmin' then
		if #args ~= 2 then
				RconPrint("Usage: setadmin [user-id] [permission-level]\n")
				CancelEvent()
				return
		end

		if(GetPlayerName(tonumber(args[1])) == nil)then
			RconPrint("Player not ingame\n")
			CancelEvent()
			return
		end

		TriggerEvent("es:setPlayerData", tonumber(args[1]), "permission_level", tonumber(args[2]), function(response, success)
			RconPrint(response)

			if(success)then
				TriggerClientEvent('chatMessage', -1, "CONSOLE", {0, 0, 0}, "Permission level of ^2" .. GetPlayerName(tonumber(args[1])) .. "^0 has been set to ^2" .. args[2])
			end
		end)

		CancelEvent()
	elseif commandName == 'setmoney' then
			if #args ~= 2 then
					RconPrint("Usage: setmoney [user-id] [money]\n")
					CancelEvent()
					return
			end

			if(GetPlayerName(tonumber(args[1])) == nil)then
				RconPrint("Player not ingame\n")
				CancelEvent()
				return
			end

			TriggerEvent("es:setPlayerData", tonumber(args[1]), "money", tonumber(args[2]), function(response, success)
				RconPrint(response)

				TriggerClientEvent('es:activateMoney', tonumber(args[1]), tonumber(args[2]))

				if(success)then
					TriggerClientEvent('chatMessage', tonumber(args[1]), "CONSOLE", {0, 0, 0}, "Your money has been set to: $" .. tonumber(args[2]))
				end
			end)

			CancelEvent()
		elseif commandName == 'unban' then
			if #args ~= 1 then
					RconPrint("Usage: unban [identifier]\n")
					CancelEvent()
					return
			end

			CancelEvent()
		elseif commandName == 'ban' then
			if #args ~= 1 then
					RconPrint("Usage: ban [user-id]\n")
					CancelEvent()
					return
			end

			if(GetPlayerName(tonumber(args[1])) == nil)then
				RconPrint("Player not ingame\n")
				CancelEvent()
				return
			end

			TriggerEvent("es:setPlayerData", tonumber(args[1]), "banned", 1, function(response, success)
				TriggerClientEvent('chatMessage', -1, "SYSTEM", {255, 0, 0}, "Player ^2" .. GetPlayerName(player) .. "^0 has been banned(^2Banned: You have been banned by console.^0)")
			end)

			CancelEvent()
		end
end)

-- Logging
AddEventHandler("es:adminCommandRan", function(source, command)

end)
