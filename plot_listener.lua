local Players = game:GetService("Players")

local function DFS(playa, plotNumber, searched) -- need to track previous moves to not get an infinite loop!!!
	table.insert(searched, plotNumber)
	local mine = workspace.Open.Purchases:FindFirstChild("Mining" .. playa:GetAttribute("plot"))
	if ((plotNumber-1) % 21) ~= 0 then -- (no right)
		local pass = false
		for _, v in ipairs(searched) do
			if v == plotNumber - 1 then
				pass = true
				break
			end
		end
		if not pass then
			local plotOther = mine.Parent:FindFirstChild("Mining" .. tostring(plotNumber - 1))
			if plotOther:GetAttribute("owner") == playa.Name then
				searched = DFS(playa, plotNumber - 1, searched)
			end
		end
	end
	if ((plotNumber) % 21) ~= 0 then -- (no left)
		local pass = false
		for _, v in ipairs(searched) do
			if v == plotNumber + 1 then
				pass = true
				break
			end
		end
		if not pass then
			local plotOther = mine.Parent:FindFirstChild("Mining" .. tostring(plotNumber + 1))
			if plotOther:GetAttribute("owner") == playa.Name then
				searched = DFS(playa, plotNumber + 1, searched)
			end
		end
	end
	if plotNumber > 21 then -- (no under)
		local pass = false
		for _, v in ipairs(searched) do
			if v == plotNumber - 21 then
				pass = true
				break
			end
		end
		if not pass then
			local plotOther = mine.Parent:FindFirstChild("Mining" .. tostring(plotNumber - 21))
			if plotOther:GetAttribute("owner") == playa.Name then
				searched = DFS(playa, plotNumber - 21, searched)
			end
		end
	end
	if plotNumber < 421 then -- (no above)
		local pass = false
		for _, v in ipairs(searched) do
			if v == plotNumber + 21 then
				pass = true
				break
			end
		end
		if not pass then
			local plotOther = mine.Parent:FindFirstChild("Mining" .. tostring(plotNumber + 21))
			if plotOther:GetAttribute("owner") == playa.Name then
				searched = DFS(playa, plotNumber + 21, searched)
			end
		end
	end
	return searched
end

game.ReplicatedStorage.PlotEvent.OnServerEvent:Connect(function(player, event, abandon)
	local plotNum = tonumber(player:GetAttribute("plot"))
	local mine = workspace.Open.Purchases:FindFirstChild("Mining" .. plotNum) -- need to make work for all mines
	if event == "prospect" then
		local value = mine:GetAttribute("prospect") + math.sqrt(-2*math.log(1 - math.random()))*math.cos(2*math.pi*math.random())
		if value < 0.01 then
			value = 0.01
		end
		--player:SetAttribute("ore", player:GetAttribute("ore") + value) -- disabled as money gain was too significant
		player:SetAttribute("prospected" .. player:GetAttribute("plot"), value)
		player.PlayerGui.Plot.ImageLabel.prospect.Visible = false
		mine.CanTouch = false
		mine.CanTouch = true
		
	elseif event == "purchase" or event == "steal" or event == "win" then -- is purchased
		if event == "steal" and player:GetAttribute("first") then -- cant steal first plot
			player.PlayerGui.getStarted.steal.Visible = true
			return
		end
		local adjacent = false
		if not player:GetAttribute("first") then -- only if it isnt the players first property
			if ((plotNum-1) % 21) ~= 0 then -- (no right)
				--print("working")
				local plotOther = mine.Parent:FindFirstChild("Mining" .. tostring(plotNum - 1))
				if plotOther:GetAttribute("owner") == player.Name then
					adjacent = true
				end
			end
			if not adjacent and ((plotNum) % 21) ~= 0 then -- (no left)
				--print("working")
				local plotOther = mine.Parent:FindFirstChild("Mining" .. tostring(plotNum + 1))
				if plotOther:GetAttribute("owner") == player.Name then
					adjacent = true
				end
			end
			if not adjacent and plotNum > 21 then -- (no under)
				--print("working")
				local plotOther = mine.Parent:FindFirstChild("Mining" .. tostring(plotNum - 21)) -- need to make jump correct
				if plotOther:GetAttribute("owner") == player.Name then
					adjacent = true
				end
			end
			if not adjacent and plotNum < 421 then -- (no above)
				--print("working")
				local plotOther = mine.Parent:FindFirstChild("Mining" .. tostring(plotNum + 21)) -- need to make jump correct
				if plotOther:GetAttribute("owner") == player.Name then
					adjacent = true
				end
			end
		else -- first plot (add if statement so it must be outter plot)
			-- if outter then
			if (plotNum < 22) or (plotNum > 420) or ((plotNum-1) % 21) == 0 or (plotNum % 21) == 0 then 
				--print("plotnum = ", plotNum)
				adjacent = true
			else
				player.PlayerGui.getStarted.outer.Visible = true
				return
			end
		end
		if adjacent then
			-- add DFS search to make sure player owns a plot that is 1st rank
			local search = DFS(player, plotNum, {})
			local loc = false
			for _, v in ipairs(search) do
				if (v < 22) or (v > 420) or ((v-1) % 21) == 0 or (v % 21) == 0 then 
					loc = true
					break
				end
			end
			if not loc then -- this plot does not connect to outer tiles 
				if player:GetAttribute("outerPlots") == 0 then -- player has no outer tiles, must make tiles go back to start or just start over
					--for i, v in ipairs(search) do -- ***doesnt really work***
					--	if v == plotNum then
					--		table.remove(search, i) -- remove purchase location because doesnt want to get added to allowed ranks to buy
					--	end
					--end
					local rank = 0
					if plotNum < 22 or plotNum > 420 or (plotNum-1) % 21 == 0 or plotNum % 21 == 0 then -- rank 1
						rank = 1
					elseif (plotNum > 22 and plotNum < 42) or (plotNum < 420 and plotNum > 400) or (plotNum-2) % 21 == 0 or (plotNum+1) % 21 == 0 then    -- 2nd  rank
						rank = 2
					elseif (plotNum > 44 and plotNum < 62) or (plotNum < 398 and plotNum > 380) or (plotNum-3) % 21 == 0 or (plotNum+2) % 21 == 0 then    -- 3rd  rank
						rank = 3
					elseif (plotNum > 66 and plotNum < 82) or (plotNum < 376 and plotNum > 360) or (plotNum-4) % 21 == 0 or (plotNum+3) % 21 == 0 then    -- 4th  rank
						rank = 4
					elseif (plotNum > 88 and plotNum < 102) or (plotNum < 354 and plotNum > 340) or (plotNum-5) % 21 == 0 or (plotNum+4) % 21 == 0 then   -- 5th  rank
						rank = 5
					elseif (plotNum > 110 and plotNum < 122) or (plotNum < 332 and plotNum > 320) or (plotNum-6) % 21 == 0 or (plotNum+5) % 21 == 0 then  -- 6th  rank
						rank = 6
					elseif (plotNum > 132 and plotNum < 142) or (plotNum < 310 and plotNum > 300) or (plotNum-7) % 21 == 0 or (plotNum+6) % 21 == 0 then  -- 7th  rank
						rank = 7
					elseif (plotNum > 154 and plotNum < 162) or (plotNum < 288 and plotNum > 280) or (plotNum-8) % 21 == 0 or (plotNum+7) % 21 == 0 then  -- 8th  rank
						rank = 8
					elseif (plotNum > 176 and plotNum < 182) or (plotNum < 266 and plotNum > 260) or (plotNum-9) % 21 == 0 or (plotNum+8) % 21 == 0 then  -- 9th  rank
						rank = 9
					elseif (plotNum > 198 and plotNum < 202) or (plotNum < 244 and plotNum > 240) or (plotNum-10) % 21 == 0 or (plotNum+9) % 21 == 0 then -- rank 10
						rank = 10
					else -- winning rank
						rank = 11
					end	
					local lowest = 10
					for _, v in ipairs(search) do
						if (v > 22 and v < 42) or (v < 420 and v > 400) or (v-2) % 21 == 0 or (v+1) % 21 == 0 then    -- 2nd  rank
							lowest = 2
							break
						elseif (v > 44 and v < 62) or (v < 398 and v > 380) or (v-3) % 21 == 0 or (v+2) % 21 == 0 then    -- 3rd  rank
							lowest = 3
						elseif (v > 66 and v < 82) or (v < 376 and v > 360) or (v-4) % 21 == 0 or (v+3) % 21 == 0 then    -- 4th  rank
							if lowest > 4 then
								lowest = 4
							end
						elseif (v > 88 and v < 102) or (v < 354 and v > 340) or (v-5) % 21 == 0 or (v+4) % 21 == 0 then   -- 5th  rank
							if lowest > 5 then
								lowest = 5
							end
						elseif (v > 110 and v < 122) or (v < 332 and v > 320) or (v-6) % 21 == 0 or (v+5) % 21 == 0 then  -- 6th  rank
							if lowest > 6 then
								lowest = 6
							end
						elseif (v > 132 and v < 142) or (v < 310 and v > 300) or (v-7) % 21 == 0 or (v+6) % 21 == 0 then  -- 7th  rank
							if lowest > 7 then
								lowest = 7
							end
						elseif (v > 154 and v < 162) or (v < 288 and v > 280) or (v-8) % 21 == 0 or (v+7) % 21 == 0 then  -- 8th  rank
							if lowest > 8 then
								lowest = 8
							end
						elseif (v > 176 and v < 182) or (v < 266 and v > 260) or (v-9) % 21 == 0 or (v+8) % 21 == 0 then  -- 9th  rank
							if lowest > 9 then
								lowest = 9
							end
						end		
					end
					if not (rank <= lowest) then -- since cutoff, must go outwards. whatever player picked is not outwards
						player.PlayerGui.getStarted.outwards.Visible = true 
						return
					end
				else
					player.PlayerGui.getStarted.connect.Visible = true
					return
				end
			end
			if player:GetAttribute("owner") then
				local cost = mine:GetAttribute("cost")
				if event == "steal" then
					cost *= 3
				end
				if player:GetAttribute("money") >= cost then
					player.PlayerGui.Plot.ImageLabel.Visible = false
					player.PlayerGui.Plot.steal.Visible = false
					player:SetAttribute("money", player:GetAttribute("money") - cost)
					player:SetAttribute("plotsOwned", player:GetAttribute("plotsOwned") + 1)
					local outer = false
					if (plotNum < 22) or (plotNum > 420) or ((plotNum-1) % 21) == 0 or (plotNum % 21) == 0 then 
						outer = true
						player:SetAttribute("outerPlots", player:GetAttribute("outerPlots") + 1)
					end
					if event == "steal" then
						local opponent = Players:FindFirstChild(mine:GetAttribute("owner"))
						--print(opponent.Name)
						if opponent then -- if opponent hasnt quit
							local diff = opponent:GetAttribute("plotsOwned") - 1
							opponent:SetAttribute("plotsOwned", diff)
							if diff == 0 then
								opponent:SetAttribute("first", true)
							end
							if outer then
								opponent:SetAttribute("outerPlots", opponent:GetAttribute("outerPlots") - 1)
							end
						end
					end
					--print("made it!")
					mine:SetAttribute("owner", player.Name)
					--local R = tonumber(player:GetAttribute("colorR"))
					--local G = tonumber(player:GetAttribute("colorG"))
					--local B = tonumber(player:GetAttribute("colorB"))
					for _, child in pairs(mine.plot:GetChildren()) do
						for _, rope in pairs(child.rope:GetChildren()) do
							--rope.Color = Color3.new(R,G,B)
							rope.BrickColor = BrickColor.new(player:GetAttribute("color"))
						end
					end
					mine.CanTouch = false
					--wait(.1) 
					mine.CanTouch = true
					if player:GetAttribute("first") then
						player:SetAttribute("first", false)
					elseif plotNum == 221 then -- VICTORY
						for _, v in pairs(Players:GetChildren()) do
							if player.Name == v.Name then
								player.PlayerGui.event.win.Visible = true
								player.PlayerGui.Plot.wincon.Visible = false
							else
								v.PlayerGui.event.loss.header.Text = player.Name .. " Wins!"
								v.PlayerGui.event.loss.Visible = true
							end
						end
						for _, v in pairs(workspace.Open.Purchases:GetChildren()) do
							v.Script.Disabled = true -- stop game from working
						end
						local leaderstats = player.leaderstats
						local win = leaderstats and leaderstats:FindFirstChild("Wins")
						win.Value = tostring(tonumber(win.Value) + 1)
						script.Disabled = true
					end
				else -- not enough money
					player.PlayerGui.getStarted.poor.Visible = true
				end
			else -- not owner
				player.PlayerGui.getStarted.start.Visible = true
			end
		else -- not adjacent
			player.PlayerGui.getStarted.adjacent.Visible = true
		end
	elseif event == "abandon" then
		local drop = workspace.Open.Purchases:FindFirstChild("Mining" .. abandon)
		for _, child in pairs(drop.plot:GetChildren()) do
			for _, rope in pairs(child.rope:GetChildren()) do
				rope.Color = Color3.new(1, 1, 1)
			end
		end
		drop:SetAttribute("owner", nil)
		local diff = player:GetAttribute("plotsOwned") - 1
		player:SetAttribute("plotsOwned", diff)
		if (plotNum < 22) or (plotNum > 420) or ((plotNum-1) % 21) == 0 or (plotNum % 21) == 0 then 
			player:SetAttribute("outerPlots", player:GetAttribute("outerPlots") - 1)
		end
		if diff == 0 then
			player:SetAttribute("first", true)
		end
		player.PlayerGui.Plot.abandon.Visible = false
		drop.CanTouch = false
		--wait(.1)
		drop.CanTouch = true
	end
end)
