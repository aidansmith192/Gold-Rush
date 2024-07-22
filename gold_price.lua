local Players = game:GetService("Players")

-- starting price:
local goldPrice = math.abs(3 + math.sqrt(-2*math.log(1 - math.random()))*math.cos(2*math.pi*math.random()))
if goldPrice < 2 then
	goldPrice = 2
end

local open = script.Parent

open:SetAttribute("price", goldPrice)

local soundUp = workspace.zoom
local soundDown = workspace.crumble

local lostTime = 0

local randInt = 0 -- first event not random
while(true) do
	--print("randint: ",randInt)
	local add = 0
	if randInt == 4 then -- random event every ~5 cycles (randomized after first cycle)
		--print("entered")
		randInt = math.random(0,3)
		-- 0 & 1 down, 2 & 3 up
		if open:GetAttribute("price") < 1.5 then -- only allow positive market event if low price of gold (stop game stalling)
			randInt = math.random(2,3)
		end
		if randInt == 0 then -- large influx of gold into market from Australia => price down hard
			for _, p in pairs(Players:GetChildren()) do
				p.PlayerGui.event.crash.Visible = true
			end
			soundDown:Play()
			local price = math.floor(open:GetAttribute("price") - 0.5)
			if price < 0.5 then
				price = 0.5
			end
			local newPrice = open:GetAttribute("price")
			local i = 0
			while newPrice > price do
				i += 1
				open:SetAttribute("price", open:GetAttribute("price") - .2)
				newPrice -= .2
				wait(5)
			end
			lostTime = i * 5
		elseif randInt == 1 then -- stock market reaches new highs! => price down
			for _, p in pairs(Players:GetChildren()) do
				p.PlayerGui.event.drop.Visible = true
			end
			soundDown:Play()
			local count = 0
			while open:GetAttribute("price") > 1 and count <= 5 do
				open:SetAttribute("price", open:GetAttribute("price") - .1)
				count += 1
				wait(5)
			end
			lostTime = 25
		elseif randInt == 2 then -- consumers demand more gold as competing mines dry up => price high hard
			for _, p in pairs(Players:GetChildren()) do
				p.PlayerGui.event.soar.Visible = true
			end
			soundUp:Play()
			local price = math.ceil(open:GetAttribute("price") + 1)
			local newPrice = open:GetAttribute("price")
			local i = 0
			while newPrice < price do
				i += 1
				open:SetAttribute("price", open:GetAttribute("price") + .2)
				newPrice += .2
				wait(5)
			end
			lostTime = i * 5
		else -- stock market recession => price up 
			for _, p in pairs(Players:GetChildren()) do
				p.PlayerGui.event.rise.Visible = true
			end
			soundUp:Play()
			local count = 0
			while count <= 5 do
				open:SetAttribute("price", open:GetAttribute("price") + .1)
				wait(5)
				count += 1
			end
			lostTime = 25
		end
	else
		if open:GetAttribute("price") < 1 then
			add = math.abs(math.sqrt(-2*math.log(1 - math.random()))*math.cos(2*math.pi*math.random())) / 5
		elseif open:GetAttribute("price") < 2 then
			add = math.abs(math.sqrt(-2*math.log(1 - math.random()))*math.cos(2*math.pi*math.random())) / 10
		elseif open:GetAttribute("price") > 3.5 then
			add = -1 * math.abs(math.sqrt(-2*math.log(1 - math.random()))*math.cos(2*math.pi*math.random())) / 10
		else
			add = math.abs(math.sqrt(-2*math.log(1 - math.random()))*math.cos(2*math.pi*math.random())) / 20
		end
	end
	open:SetAttribute("price", open:GetAttribute("price") + add)
	
	-- now calculates lost time from waiting for events. wait x time or 0 if x is negative
	local waitAmount = math.max(50 * (.9 ^ #Players:GetPlayers()) - lostTime, 0)
	lostTime = 0
	wait(waitAmount)
	--wait(3)
	
	if randInt ~= 4 then -- cant happen twice in a row
		randInt = math.random(1,4) -- 25% chance of random event
	else
		randInt = 0
	end
end

