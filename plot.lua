local part = script.Parent
local Players = game:GetService("Players")

local debounce = false
local stop = false
local resetTime = 1
local price = 50
local counter = 0
part:SetAttribute("cost", price)

part:SetAttribute("owner", nil)

local plotNum = string.gsub(part.Name, "%D", "")

-- Guassian distribution source: https://devforum.roblox.com/t/how-to-generate-a-random-rotation-and-much-more/1549051
-- distribution: (-inf, inf), Centered at 0 with Standard Deviation 1
local oreValue = math.abs(3 + math.sqrt(-2*math.log(1 - math.random()))*math.cos(2*math.pi*math.random()))

part:SetAttribute("prospect", oreValue) -- for prospecting

local function onPartTouched(otherPart)
	stop = false
	local partParent = otherPart.Parent
	local humanoid = partParent:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		if part:GetAttribute("cost") ~= price then -- to allow for changing values in another script
			price = part:GetAttribute("cost")
		end
		if part:GetAttribute("prospect") ~= oreValue then  -- to allow for changing values in another script
			oreValue = part:GetAttribute("prospect")
		end
		local player = Players:GetPlayerFromCharacter(partParent)
		player:SetAttribute("plot", plotNum)
		if not part:GetAttribute("owner") then -- if unowned, can prospect or buy
			player.PlayerGui.Plot.ImageLabel.purchase.Text = "Purchase - $" .. price
			player.PlayerGui.Plot.ImageLabel.Visible = true
			player.PlayerGui.Plot.prospected.Visible = false
			if player:GetAttribute("prospected" .. plotNum) then
				player.PlayerGui.Plot.prospected.TextLabel.Text = "Prospected: " .. math.floor(player:GetAttribute("prospected" .. plotNum)*100)/100 .. "mg"
				player.PlayerGui.Plot.prospected.Visible = true
				player.PlayerGui.Plot.ImageLabel.prospect.Visible = false
			else
				player.PlayerGui.Plot.ImageLabel.prospect.Visible = true
			end
		elseif partParent.Name == part:GetAttribute("owner") then -- otherwise owned, is player owner? then can mine
			local character = otherPart.Parent
			local owner = Players:GetPlayerFromCharacter(character)
			if owner:GetAttribute("prospected" .. plotNum) then
				owner.PlayerGui.Plot.prospected.TextLabel.Text = "Prospected: " .. math.floor(owner:GetAttribute("prospected" .. plotNum)*100)/100 .. "mg"
				owner.PlayerGui.Plot.prospected.Visible = true
			end
			owner.PlayerGui.Plot.abandon.Visible = true
			if not debounce then
				debounce = true

				stop = false
				while not stop do
					-- first wait, hit ground then get ore!
					-- play animation then wait
					if owner:GetAttribute("trait") == "Bodybuilder" then
						wait(resetTime*.9)
					else
						wait(resetTime)
					end
					if character.Name ~= part:GetAttribute("owner") or not part.CanTouch then
						stop = true
						break
					end
					local noise = math.sqrt(-2*math.log(1 - math.random()))*math.cos(2*math.pi*math.random())
					noise = noise / 1.1 ^ counter
					local mined = oreValue + noise
					oreValue = oreValue / 1.1
					if mined < 0.01 then
						mined = 0.010001
					end
					local amount = owner:GetAttribute("ore") + mined
					owner:SetAttribute("ore", amount)
					counter += 1
					part:SetAttribute("prospect", oreValue)
				end
				debounce = false
			end
		else -- not owner: may steal
			player.PlayerGui.Plot.steal.steal.Text = "Steal - $" .. price * 3
			player.PlayerGui.Plot.steal.Visible = true
			player.PlayerGui.Plot.ImageLabel.Visible = false
			player:SetAttribute("plot", plotNum)
			if player:GetAttribute("prospected" .. plotNum) then
				player.PlayerGui.Plot.prospected.TextLabel.Text = "Prospected: " .. math.floor(player:GetAttribute("prospected" .. plotNum)*100)/100 .. "mg"
				player.PlayerGui.Plot.prospected.Visible = true
			end
		end
	end
end

local function onTouchEnded(endingPart)
	--print(endingPart.Parent.Name)
	if endingPart.Parent.Name == part:GetAttribute("owner") then
		stop = true
	end
	local endingHumanoid = endingPart.Parent:FindFirstChildWhichIsA("Humanoid")
	if endingHumanoid then
		local playa = Players:GetPlayerFromCharacter(endingPart.Parent)
		playa.PlayerGui.Plot.ImageLabel.Visible = false
		playa.PlayerGui.Plot.prospected.Visible = false
		playa.PlayerGui.Plot.steal.Visible = false
		playa.PlayerGui.Plot.abandon.Visible = false
	end
end

part.Touched:Connect(onPartTouched)
part.TouchEnded:Connect(onTouchEnded)

