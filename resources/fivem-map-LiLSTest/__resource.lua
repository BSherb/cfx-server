resource_type 'map' { gameTypes = { fivem = true } }

map 'map.lua'

AddEventHandler('es:playerLoaded', function(source)
-- Get the current amount for the player
 TriggerEvent('es:getPlayerFromId', source, function(user)
 -- Activate the money for the current player
 TriggerClientEvent('es:activateMoney', source, tonumber(user.money))

 -- Send the player some information regarding the money
 TriggerClientEvent('chatMessage', source, "SYSTEM", {187, 235, 42}, "Your money amount is: $" .. tonumber(user.money))
  end)
end)