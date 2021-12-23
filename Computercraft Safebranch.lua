--[[ 
This program is designed to create a branch mine with 3x3 hallways, with multiple turtles working in tandem. Each turtle is responsible for either a branch or the main trunk of the mine. It is recommended to use at least 3 turtles (one for the main trunk and one for a branch on each side of the trunk), but fewer can be used with some manual repositioning. How it works:

* The turtle will mine out a 3x3 area. As it does so, it will compare the blocks in the walls with whatever is placed in its first slot. If that block does not match slot 1, it will be replaced with whatever is in slot 2. For example, I use this with stone in slot 1 and cobblestone in slot 2. This means that anything in the walls that ISN'T stone will be replaced with cobblestone. If you were to place cobblestone in slots 1 and 2, the walls would end up being solid cobblestone. As it mines out these slices, a turtle will place torches so that the tunnel remains safe from mob spawns. For optimum torch utilization, users are recommended to make the length of their tunnels a multiple of 10.

* Before beginning each 3x3 slice of a tunnel, the turtle will check to make sure it has enough materials to adequately complete that slice. If it does not, it will return to the beginning of the branch mine to resupply. If the turtle's inventory gets full, it will also return to this position to unload. 

* As the main trunk is mined out, the turtle assigned to this task will leave redstone torches behind in addition to normal torches. These function as markers to let the turtles know which way to go to get to the drop-off chest.

* When the turtles are finished with mining out the branches, they will return to the main trunk and position themselves for the next branch. The user will need to specify the direction that the turtle will need to go (either right or left) to reach the next tunnel position.

* Lastly, more than 1 turtle can be assigned to work on each side of the main trunk (each working on their own tunnels). The number of turtles needs to be specified by the user.

For specifics of the setup, go to https://imgur.com/a/p9jCJT1

Inventory Layout:
1 - Stone
2 - Cobble
3 - Torches
4 - Redstone Torches (Optional)
16 - Fuel (Optional)
--]]
function usage()  --Displays usage tips when invalid inputs are entered
	usagetext = {
	'Usage: Safebranch <type> <length>','       <direction> <# of turtles>',' ',' ','<type> can be "side" or "main"',' ','<length> is the length of the tunnel','         you want mined',' ','<direction> is the direction the turtle','            should go when finished (l','            or r). This argument may be','            omitted for "main" tunnels',' ','<# of turtles> is the number of turtles','               on this side of the main','               tunnel. This argument','               may be omitted for','               "main" tunnels',' ','The arguments may be omitted for a text','prompt. For more help, type "Safebranch','help"',''}
	textutils.pagedTabulate(usagetext)
	return
end

function clc()    --Quick command to clear the terminal (I use matlab a lot, so clc is natural for me)
	term.clear()
	term.setCursorPos(1,1)
end

function stuck()	--Displays "I'm stuck" messages
	print('I think I might have gotten myself stuck...')
	print('Terminate program or press enter after obstacle is cleared.')
	read()
end

function searchinv()	--Searches turtle's inventory for items like currently selected item, and reloads slot if they are found
	local ini_slot = turtle.getSelectedSlot()
	if turtle.getFuelLevel() == 'unlimited' then
		endslot = 16
	else
		endslot = 15
	end
	for i = 4,endslot do
		restocktorches()	--If turtle is at the reloading station, this makes sure the turtle has at least 32 torches
		turtle.select(i)
		if turtle.compareTo(ini_slot) then
			turtle.transferTo(ini_slot)
			if ini_slot == cobble then
				if turtle.getItemCount(ini_slot) > 22 then		--At most, a turtle will need 22 pieces of cobble for a slice of branch mine. This makes sure he has it
					turtle.select(ini_slot)
					return true
				end
			else
				turtle.select(ini_slot)
				return true
			end
		end
	end
	turtle.select(ini_slot)
	return false
end

function addfuel()			--Checks if a turtle needs fuel, and refuels if it does.
	if turtle.getFuelLevel() == 'unlimited' then
	elseif turtle.getFuelLevel() == 0 then
		local ini_slot = turtle.getSelectedSlot()
		turtle.select(fuel)
		if turtle.getItemCount() > 1 then
			turtle.refuel(1)
		elseif turtle.getItemCount() == 1 then
			for i = 4,15 do
				turtle.select(i)
				if turtle.refuel(1) then
					break
				elseif i == 15 then
					turtle.select(fuel)
					print('I am out of fuel. Please load fuel into slot '..tostring(fuel))
					print('Press enter after fuel is loaded.')
					read()
					turtle.refuel(1)				
				end
			end
		else
			print('Slot '..tostring(fuel)..' must contain a fuel item!')
		end
		turtle.select(ini_slot)
	end
end

function tup()		--Guarantees that a turtle will move up when told (gravel, sand, water, lava, and mob proof)
	addfuel()
	local attempt = 0
	while turtle.up() == false do
		turtle.digUp()
		turtle.attackUp()
		attempt = attempt + 1
		if attempt >= 10 then
			stuck()
		end
	end
end

function tdn()		--Guarantees that a turtle will move down when told (gravel, sand, water, lava, and mob proof)
	addfuel()
	local attempt = 0
	while turtle.down() == false do
		turtle.digDown()
		turtle.attackDown()
		attempt = attempt + 1
		if attempt >= 10 then
			stuck()
		end
	end
end

function tfd()		--Guarantees that a turtle will move forward when told (gravel, sand, water, lava, and mob proof)
	addfuel()
	local attempt = 0
	while turtle.forward() == false do
		turtle.dig()
		turtle.attack()
		attempt = attempt + 1
		if attempt >= 10 then
			stuck()
		end
	end
end

function tbk()		--Guarantees that a turtle will move back when told (gravel, sand, water, lava, and mob proof)
	addfuel()
	if turtle.back() == false then
		turtle.turnRight()
		turtle.turnRight()
		tfd()
		turtle.turnRight()
		turtle.turnRight()
	end
end

function cup()		--Compares the block above turtle to slot 1 and replaces it with slot 2 if it doesnt match
	local ini_slot = turtle.getSelectedSlot()
	turtle.select(stone)
	if turtle.compareUp() == false then
		turtle.select(cobble)
		if turtle.getItemCount() <= 1 then
			if searchinv() == false then
				print('I need more of item '..tostring(cobble)..'.')
				print('Press enter after reloading...')
				read()
			end
		end
		local attempt = 0
		while turtle.placeUp() == false do
			turtle.digUp()
			turtle.attackUp()
			attempt = attempt + 1
			if attempt >= 10 then
				stuck()
			end
		end
	end
	turtle.select(ini_slot)
end

function cdn()		--Compares the block below turtle to slot 1 and replaces it with slot 2 if it doesnt match
	local ini_slot = turtle.getSelectedSlot()
	turtle.select(stone)
	if turtle.compareDown() == false then
		turtle.select(cobble)
		if turtle.getItemCount() <= 1 then
			if searchinv() == false then
				print('I need more of item '..tostring(cobble)..'.')
				print('Press enter after reloading...')
				read()
			end
		end
		local attempt = 0
		while turtle.placeDown() == false do
			turtle.digDown()
			turtle.attackDown()
			attempt = attempt + 1
			if attempt >= 10 then
				stuck()
			end
		end
	end
	turtle.select(ini_slot)
end

function cfd()			--Compares the block in front of turtle to slot 1 and replaces it with slot 2 if it doesnt match
	local ini_slot = turtle.getSelectedSlot()
	turtle.select(stone)
	if turtle.compare() == false then
		turtle.select(cobble)
		if turtle.getItemCount() <= 1 then
			if searchinv() == false then
				print('I need more of item '..tostring(cobble)..'.')
				print('Press enter after reloading...')
				read()
			end
		end
		local attempt = 0
		while turtle.place() == false do
			turtle.dig()
			turtle.attack()
			attempt = attempt + 1
			if attempt >= 10 then
				stuck()
			end
		end
	end
	turtle.select(ini_slot)
end

function placetorch(torchtype)		--Turns turtle around and places either a torch or a redstone torch
	local ini_slot = turtle.getSelectedSlot()
	torchtype = torchtype or 0
	turtle.turnLeft()
	turtle.turnLeft()
	local attempt = 0
	if string.lower(torchtype) == 'rs' then
		turtle.select(rstorch)
	else
		turtle.select(torch)
	end
	if turtle.getItemCount() <= 1 then
		print('I need more torches in slot '..tostring(turtle.getSelectedSlot())..'.')
		print('Press enter after reloading...')
		read()
	end
	tup()
	tfd()
	while turtle.placeDown() == false do
		turtle.attackDown()
		turtle.digDown()
		attempt = attempt + 1
		if attempt >= 10 then
			stuck()
		end
	end
	tbk()
	tdn()
	turtle.turnLeft()
	turtle.turnLeft()
	turtle.select(ini_slot)
end

function checkstock(position)		--Checks to make sure turtle has sufficient supplies for this slice of mining. Position is fed to this function so the turtle can get back to its tunnel if it needs to go restock
	position = position or 0
	local ini_slot = turtle.getSelectedSlot()
	if turtle.getItemCount(stone) < 1 then
		turtle.select(stone)
		if searchinv() == false then
			print('I need more of item '..tostring(stone)..'.')
			print('Press enter after reloading...')
			read()
		end
	elseif turtle.getItemCount(cobble) < 22 then
		turtle.select(cobble)
		if searchinv() == false then
			print('Restocking on item '..tostring(cobble)..'.')
			restock(position)
		end
	elseif turtle.getItemCount(torch) < math.ceil(length/5) then
		turtle.select(torch)
		if searchinv() == false then
			print('Restocking on torches.')
			restock(position)
		end
	elseif tunneltype == 'main' and turtle.getItemCount(rstorch) < math.ceil(length/5) then
		turtle.select(rstorch)
		if searchinv() == false then
			print('Restocking on rs torches.')
			restock(position)
		end
	elseif turtle.getFuelLevel() ~= 'unlimited' and turtle.getItemCount(fuel) < 4 then
		turtle.select(fuel)
		if searchinv() == false then
			print('Restocking on fuel.')
			restock(position)
		end
	else
		emptyslots = 0
		for i = 1,16 do
			if turtle.getItemCount(i) == 0 then
				emptyslots = emptyslots + 1
			end
		end
		if emptyslots == 0 then
			restock(position)
		else
			return true
		end		
	end
	turtle.select(ini_slot)
end

function restock(position)			--Sends the turtle back to the unload/reload chests to restock or deposit excess materials
	turtle.turnLeft()
	tfd()
	turtle.turnLeft()
	if tunneltype == 'side' then		--Determines if the turtle is a branch miner or trunk miner
		for j = 1,position do
			tfd()
		end
		if rs.getInput('front') then	--Determines which way the chests are and orients to begin travel
			turtle.turnRight()
			side = 'l'
		else
			while turtle.forward() == false do
				turtle.attack()
			end
			while turtle.forward() == false do
				turtle.attack()
			end
			turtle.turnLeft()
			while turtle.forward() == false do
				turtle.attack()
			end
			while turtle.forward() == false do
				turtle.attack()
			end
			side = 'r'
		end
	end
	distfromchest = 0						--This variable keeps up with how far the turtle travels to reach chest so it can get back to its tunnel
	while turtle.detect() == false do
		while turtle.forward() == false do
			addfuel()
			turtle.attack()
		end
		distfromchest = distfromchest + 1
		if turtle.detect() then
			local boolean, data = turtle.inspect()	
			if string.find(string.lower(data.name),'turtle') then
				print('Detected another turtle. Waiting in line...')
				while turtle.detect() do
					sleep(7)
				end
			elseif data.name == 'minecraft:chest' then
			else
				print('Unknown Obstacle. Wating for clearance.')
				print('Press enter to continue...')
				read()
			end
		end
	end
	local ini_slot = turtle.getSelectedSlot()
	if turtle.getItemCount(cobble) < 64 then		--Reloads cobble if needed
		for i = 4,15 do
			restocktorches()
			turtle.select(i)
			if turtle.compareTo(cobble) then
				turtle.transferTo(cobble)
			end
		end
		if turtle.getItemCount(cobble) < 64 then
			turtle.select(cobble)
			turtle.suckDown()
		end
	end
	if tunneltype == 'side' then
		startslot = 4
	else
		startslot = 5
	end
	if turtle.getFuelLimit() == 'unlimited' then
		endslot = 16
	else
		endslot = 15
	end
	
	for i = startslot,endslot do
		restocktorches()
		turtle.select(i)
		if turtle.compareTo(cobble) then			--Deposits excess materials
			turtle.dropDown()
		else
			turtle.drop()
		end
	end
	turtle.select(ini_slot)
	tup()
	turtle.turnLeft()
	tfd()
	tfd()
	tdn()
	turtle.turnLeft()
	for z = distfromchest,1,-1 do				--Returns to branch or main trunk end
		tfd()
	end
	if tunneltype == 'side' then
		if side == 'r' then 
			turtle.turnRight()
		else
			tfd()
			tfd()
			turtle.turnLeft()
			tfd()
			tfd()
		end
		for j = 1, position do
			tfd()
		end
	end
	turtle.turnLeft()
	tfd()
	turtle.turnRight()	
end

function restocktorches()					--Controls whether the hopper at the restock chests will load more torches into turtle
	if turtle.getItemCount(torch) > 31 then
		rs.setOutput('right',true)
	else
		rs.setOutput('right',false)
	end
end

function moveover()				--Once turtle is done with branch, this function makes it return to the trunk and position itself for the next branch
	tup()
	turtle.turnRight()
	turtle.turnRight()
	turtle.select(torch)
	remainder = (length/10-math.floor(length/10))*10
	for i = length,1,-1 do
		tfd()
		if i == length and remainder <4 and remainder ~= 0 then		--Removes excess torches that are not needed. Light level will stay above 7
			turtle.digDown()
		elseif i/5 == math.floor(i/5) and i/10 ~= math.floor(i/10) then
			turtle.digDown()
		end
	end
	if direction == 'l' then
		turtle.turnRight()
	else
		turtle.turnLeft()
	end
	for i = 1,5*turtles do
		turtle.forward()
	end
	turtle.down()
	if direction == 'l' then
		turtle.turnRight()
	else
		turtle.turnLeft()
	end
end

function progress(i)			--Function to display progress bar while mining
	percent = (i+1)/length
	clc()
	print('Mining in progress...')
	print()
	print()
	print('<                                   >')
	term.setCursorPos(2,4)
	bar = math.ceil(percent*35)
	for j = 1,bar do
		write('=')
	end
	term.setCursorPos(17,5)
	print(tostring(percent*100-percent*100%0.1)..'%')
end
---------------------------------------
-----------------CODE------------------
---------------------------------------

local args = {...}

stone = 1    --Slot index for materials
cobble = 2   
torch = 3    
rstorch = 4  
fuel = 16    		   

helptext = {
'Safebranch is designed to mine out a ','branch mine with 3x3 tunnels with ','multiple turtles mining their own ','branches simultaneously. As they mine, ','they will remove any ores from the ','walls, and fill in empty space to block ','off natural caverns, water, lava, etc. ','In addition, they will place down ','torches periodically to prevent mobs ','from spawning. To work as intended, it ','is recommended to have at least 3 ','turtles going at a time (1 on the main ','"trunk" of the mine, and 1 for each ','branch on either side, but you can use ','as few as 1 turtle with manual ','placement after each tunnel. Below is a','diagram of the intended usage. The Ds ','represent walls, with "dashed" lines ','representing the excavation path of the','turtles.',' ','            D   D',' sideshaft','            D   D',' ','            D   D','DDDDDDDDDDDDDDDDD D D D D D D D','              T D','               TD    mainshaft','              T D','DDDDDDDDDDDDDDDDD D D D D D D D','            D   D',' ','            D   D',' sideshaft','            D   D',' '}			 
			 
if #args == 0 then   --If no arguments, give a text prompt instead
	print('Is this a side branch or the main shaft? ')
	write('Type main or side: ')
	tunneltype = string.lower(read())
	print()
	print('How long do you want the tunnel to be?')
	write('Enter a number greater than 0: ')
	length = tonumber(read())
	if tunneltype == 'side' then
		print()
		print('Once the turtle is finished, should it move to the left or right to start the next one?')
		write('Type either L or R: ')
		direction = string.lower(read())
		print()
		print('How many turtles (including this one) are on this side of the branch mine?')
		write('Enter a number greater than 0: ')
		turtles = tonumber(read())
	end
elseif string.lower(args[1]) == 'help' then
	clc()
	textutils.pagedTabulate(helptext)
	return
elseif #args == 2 then
	if string.lower(args[1]) ~= 'main' then
		usage()
		return
	end
	tunneltype = string.lower(args[1])
	length = tonumber(args[2])
elseif string.lower(args[1]) == 'side' and tonumber(args[2]) > 0 and (string.lower(args[3]) == 'l' or string.lower(args[3]) == 'r') and tonumber(args[4]) >= 1 then
	tunneltype = string.lower(args[1])
	length = tonumber(args[2])
	direction = string.lower(args[3])
	turtles = tonumber(args[4])
else
	usage()
	return
end

clc()

for i = 0,length-1 do
	checkstock(i)		--Checks to make sure turtle has enough materials
	if i ~= 0 then		--Checks to see if turtle needs to place a torch behind itself
		if i/5 == math.floor(i/5) then
			placetorch()
		elseif tunneltype == 'main' and (i+1)/5 == math.floor((i+1)/5) then
			placetorch('rs')
		end
	end
	
--Middle column of slice	
	tfd()
	cfd()
	cdn()
	tup()
	cfd()
	tup()
	cfd()
	cup()
	turtle.turnLeft()
	
--Left column of slice
	tfd()
	cfd()
	cup()
	turtle.turnRight()
	cfd()
	tdn()
	cfd()
	turtle.turnLeft()
	cfd()
	tdn()
	cfd()
	cdn()
	turtle.turnRight()
	cfd()
	turtle.turnRight()
	
--Right column of slice
	tfd()
	tfd()
	cfd()
	cdn()
	turtle.turnLeft()
	cfd()
	tup()
	cfd()
	turtle.turnRight()
	cfd()
	tup()
	cfd()
	cup()
	turtle.turnLeft()
	cfd()
	turtle.turnLeft()
	tfd()
	turtle.turnRight()
	tdn()
	tdn()
	
	progress(i) 	--Update progress bar
	
	if i == length-1 then	--Place torch at end of tunnel
		placetorch()
		if tunneltype == 'side' then
			moveover()
		end
	end
end

turtle.select(1)