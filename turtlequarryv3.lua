local x = 0
local z = 0
local y = 0

local facing = 3 --assumes turtle is facing forward at initialization.
local turnValue = {-2,-1,0,1,2} --assigns number value to each facing (1-5) for turning math

local needsFuel = false

function clearConsole()
	term.clear()
	term.setCursorPos(1,1)
end

function face(a) --from any initial facing turns turtle to new facing direction in optimal turn direction
	local initial = facing
	local terminal = a
	local turnAmount = math.abs(math.abs(turnValue[terminal])-math.abs(turnValue[initial]))	
	print(tostring(turnAmount))
	local turnDirection = turnValue[terminal]-turnValue[initial]
    print(tostring(turnDirection))
	if  turnAmount<0 or turnAmount>2 then
		print('Turning math error!')
		read()
	end
	if turnDirection == 3 then --terrible solution for cases facing 5 -> 2 and facing 1 -> 4 but oh well
	    turnDirection = turnDirection*-1
    elseif turnDirection == -3 then
	    turnDirection = turnDirection*-1
	end
	if turnDirection <= 0 then
        for i=1, turnAmount do
            turtle.turnLeft()
		end
		print('Turned Left '..turnAmount..' times')
	elseif turnDirection>0 then
        for i=1, turnAmount do
            turtle.turnRight()
		end
		print('Turned Right '..turnAmount..' times')
	end
	facing = terminal	
	print('Facing '..facing)
end

function home() --Returns turtle to initial starting point (0,0,0)
	if x>0 then
		bk(x)
	elseif x<0 then
		fwd(math.abs(x))
	end
	if z>0 then
		lft(z)
	elseif z<0 then
		fwd(math.abs(z))
	end
	if y>0 then
		dwn(y)
	elseif y<0 then
		up(math.abs(y))
	end
end

function resume(mx, my, mz)
	if mx>0 then
		bk(mx)
	elseif mx<0 then
		fwd(math.abs(mx))
	end
	if mz>0 then
		lft(z)
	elseif mz<0 then
		fwd(math.abs(mz))
	end
	if my>0 then
		dwn(my)
	elseif my<0 then
		up(math.abs(my))
	end
end

function refuel() --Checks if current fuel level is below one and prompts player to insert fuel.
	if turtle.getFuelLevel() ~= unlimited and turtle.getFuelLevel() <= 1 then
		needsFuel = true
		while turtle.refuel() == false do
			print('Out of Fuel. To continue, please load fuel and press enter.')
			read ()
		end
		needsFuel = false
	end	
end

function homeForFuel() --Checks current fuel level if not already checked, for whether turtle will have enough to return home. Then, returns home to await refueling.
	if needsFuel ~= true and turtle.getFuelLevel() <= x + math.abs(y) + z + 2 then
		needsFuel = true
		print ('Fuel low... returning home')
		local mx = x
		local my = y
		local mz = z
		home()
		invDump()
		print('Out of Fuel. Awaiting refueling...')
		while turtle.getFuelLevel() <= 10000 do
			for i = 1, 16 do
				local initFuel = turtle.getFuelLevel()
				turtle.select(i)
				turtle.refuel()
				local fuelLevel = turtle.getFuelLevel()
				if turtle.getFuelLevel() ~= initFuel then
					print(tostring(fuelLevel)..'/10000')
				end
			end
		end
		print('Refueling Complete.')
		invDump()
		needsFuel = false
		print('Resuming mining')
		resume(mx,my,mz)
	end
end

function invDump() --Turns left to face chest then dumps entire inventory contents
	home()
	face(2)
	for i = 1, 16 do
		turtle.select(i)
		turtle.drop()
	end
	turtle.select(1)
end

function invCheck() --Checks inventory for an empty slot; if there are none, goes home, dumps, and then resumes mining
	local initSlot = turtle.getSelectedSlot()
	for i = 16, 1, -1 do
		turtle.select(i)
		if turtle.getItemCount() == 0 then
			print('Inventory has space. Resuming mining')
			break
		else
			local mx, my, mz = x, y, z
			print('Inventory full... Returning to unload')
			invDump()
			resume(mx, my, mz)
		end
	end
	turtle.select(initSlot)
end

function fwd(n) --Checks for fuel then moves n amount of times
	face(3)
	n = n or 1
	for i=1, n do
		refuel()
		homeForFuel()
		
		while turtle.forward() == false do
			turtle.dig()
			turtle.attack()
		end
		x = x + 1
		print('Moved forward ('..i..')')
	end
end

function bk(n) --Checks for fuel then moves n amount of times
	face(1)
	n = n or 1
	for i=1, n do
		refuel()
		homeForFuel()
		while turtle.forward() == false do
			turtle.dig()
			turtle.attack()
		end
		x = x - 1
		print('Moved backward ('..i..')')
	end
end

function up(n) --Checks for fuel then moves n amount of times
	n = n or 1
	for i=1, n do
		refuel()
		homeForFuel()
		while turtle.up() == false do
			turtle.digUp()
			turtle.attackUp()
		end
		y = y + 1
		print('Moved up ('..i..')')
	end
end

function dwn(n) --Checks for fuel then moves n amount of times
	n = n or 1
	for i=1, n do
		refuel()
		homeForFuel()
		while turtle.down() == false do
			turtle.digDown()
			turtle.attackDown()
		end
		y = y - 1
		print('Moved down ('..i..')')
	end
end 

function lft(n) --Checks for fuel then moves n amount of times
	n = n or 1
	face(2)
	for i=1, n do
		refuel()
		homeForFuel()
		while turtle.forward() == false do
				turtle.dig()
				turtle.attack()
		end
		z = z - 1
		print('Moved left ('..i..')')
	end
end 

function rgt(n) --Checks for fuel then moves n amount of times
	face(4)
	n = n or 1
	for i=1, n do
		refuel()
		homeForFuel()
		while turtle.forward() == false do
				turtle.dig()
				turtle.attack()
		end
		z = z + 1
		print('Moved right ('..i..')')
	end	
end

function quarry (l,w,d) --Digs quarry of length l, width w, and depth d, returning to refuel and empty inventory as needed; then, returns to starting location 
	for i=1, d do
		invCheck() print('Checking inventory...')
		print ('Digging Layer '..i)
		dwn()
		for i=1, w do
			print('Digging Row '..i)
			fwd(l-1)
			bk(l-1)
			if i < w then
				rgt()
			end
		end		
		lft(w-1)
	end
	print('Quarry Complete. Unloading Cargo.')
	invDump()
end

clearConsole()
print('Please enter quarry dimensions')
print('Length? (Forward)')
local l = tonumber(read())
print('Width? (Right)')
local w = tonumber(read())
print('Depth?')
local d = tonumber(read())
print('Mining quarry...')
quarry(l,w,d)
exit()