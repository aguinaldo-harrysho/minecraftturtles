local x = 0
local z = 0
local y = 0

local facing = 3 --assumes turtle is facing forward at initialization.


local needsFuel = false

function clearConsole()
	term.clear()
	term.setCursorPos(1,1)
end

function face(a) --from any initial facing turns turtle to new facing direction in optimal turn direction
    if a then
        local turnValue = {-2,-1,0,1,2} --assigns number value to each facing (1-5) for turning math
        local initial = facing
        local terminal = a
        local turn = turnValue[terminal]-turnValue[initial]
        print(tostring(turn))
        if turn > 2 then
            turn = turn-4
        elseif turn < -2 then
            turn = turn+4
        end
        if turn <= 0 then
            for i=1, turn do
                turtle.turnLeft()
            end
            print('Turned Left '..turn..' times')
        elseif turn>0 then
            for i=1, turn do
                turtle.turnRight()
            end
            print('Turned Right '..turn..' times')
        end
        facing = terminal	
        print('Facing '..facing)
    end
end
face(5)
face(2)
print(tostring(facing))

function updatePos()
    if facing == 1 then
        x = x-1
    elseif facing == 3 then
        x = x+1
    elseif facing == 2 then 
        z = z-1
    elseif facing == 4 then
        z = z+1
    elseif facing == 5 then
        x = x-1
    end
    print(tostring(x)..tostring(y)..tostring(z))
end

function home() --Returns turtle to initial starting point (0,0,0)
	if x>0 then
		bk(x,1)
	elseif x<0 then
		fwd(math.abs(x),3)
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

function fwd(n,m) --Checks for fuel then moves n amount of times
    m = m or nil
    face(m)
	n = n or 1
	for i=1, n do
		refuel()
		homeForFuel()
		while turtle.forward() == false do
			turtle.dig()
			turtle.attack()
        end
		updatePos()
		print('Moved forward ('..i..')')
	end
end

function bk(n,m) --turns around, Checks for fuel then moves n amount of times
    m = m or nil
    face(m)
	n = n or 1
	for i=1, n do
		refuel()
        homeForFuel()
        if i == 1 then
            turtle.turnLeft()
            turtle.turnLeft()
        end
        while turtle.forward() == false do
			turtle.dig()
			turtle.attack()
        end
        if i == n then
            turtle.turnRight()
            turtle.turnRight()
        end
		updatePos()
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
		y = y+1
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
		y = y-1
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
		updatePos()
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
		updatePos()
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
			fwd(l-1,3)
			fwd(l-1,1)
			if i < w then
				rgt()
			end
		end		
		lft(w-1)
	end
    print('Quarry Complete. Unloading Cargo.')
    print('Position: '..x,y,z)
	invDump()
end

function detectOres()
    local cycle = 1
    for i=cycle, 4 do
        face(i)
        local success, data = turtle.inspect()
        local blockname = data.name
        if success and string.find(data.name, "ore") then
            
        end
    end
end

function focusedMine(l,w)

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