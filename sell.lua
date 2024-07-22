local open = workspace.Open
local Players = game:GetService("Players")

game.ReplicatedStorage.SellEvent.OnServerEvent:Connect(function(player, amount)
	local ore = 0
	if amount == "all" then
		ore = player:GetAttribute("ore")
		player:SetAttribute("ore", 0)
	else
		ore = tonumber(amount)
		player:SetAttribute("ore", player:GetAttribute("ore") - ore)
	end
	
	local price = open:GetAttribute("price")
	local money = player:GetAttribute("money")
	
	while ore >= 10 do
		local value = price * 10
		money =  money + value
		-- lower value of price of gold
		local reduction = 10 * math.abs(math.sqrt(-2*math.log(1 - math.random()))*math.cos(2*math.pi*math.random())) / (200 * #Players:GetPlayers())
		price = price - reduction
		if price < .5 then
			price = .5
		end
		ore -= 10
	end
	local value = price * ore
	player:SetAttribute("money", money + value)
	-- lower value of price of gold
	local reduction = ore * math.abs(math.sqrt(-2*math.log(1 - math.random()))*math.cos(2*math.pi*math.random())) / (200 * #Players:GetPlayers())
	open:SetAttribute("price", price - reduction)
	if open:GetAttribute("price") < .5 then
		open:SetAttribute("price", .5)
	end
end)

