local x = 0
local z = 0
local y = 0

local mx = nil
local my = nil
local mz = nil

function clearConsole()
	term.clear()
	term.setCursorPos(1,1)
end

function home()
	bk(x)
	lft(z)
	local d = math.abs(y)
	up(d)
end

function refuel()
	if turtle.getFuelLevel() ~= unlimited and turtle.getFuelLevel() <= 1 then
		while turtle.refuel() == false do
			print('Out of Fuel. To continue, please load fuel and press enter.')
			read ()
		end
	end
end

function recharge()
	absY = math.abs(y)
	if turtle.getFuelLevel() ~= unlimited and turtle.getFuelLevel() <= 1 then
		while turtle.refuel() == false do
			print('Out of Fuel. To continue, please load fuel and press enter.')
			read ()
		end
	end
	if turtle.getFuelLevel() <= x+ absY +z+1 then
		print ('Fuel low... returning home')
		mx = x
		my = y
		mz = z
		home()
		print('Out of Fuel. To continue, please load fuel and press enter.')
		read ()
		fwd(mx)
		rgt(mz)
		dwn(math.abs(my))
	end
end

function fwd(n)
	if n == nil then
		n = 1
	end
	for i=1, n-1 do
		refuel()
		
		while turtle.forward() == false do
			turtle.dig()
			turtle.attack()
		end
		x = x + 1
	end
end

function bk(n)
	if n == nil then
		n = 1
	end
	for i=1, n-1 do
		refuel()
		
		while turtle.back() == false do
			turtle.turnRight(2)
			turtle.dig()
			turtle.attack()
			turtle.turnLeft(2)
		end
		x = x - 1
	end
end

function up(n)
	if n == nil then
		n = 1
	end
	for i=1, n do
		refuel()
		
		while turtle.up() == false do
			turtle.digUp()
			turtle.attackUp()
		end
		y = y + 1
	end
end

function dwn(n)
	if n == nil then
		n = 1
	end
	for i=1, n do
		refuel()
		
		while turtle.down() == false do
			turtle.digDown()
			turtle.attackDown()
		end
		y = y - 1
	end
end 

function lft(n)
	if n == nil then
		n = 1
	end
	for i=1, n do
		refuel()
		
		turtle.turnLeft()
		while turtle.forward() == false do
				turtle.dig()
				turtle.attack()
		end
		turtle.turnRight()
		z = z - 1
	end
end 

function rgt(n)
	if n == nil then
		n = 1
	end
	for i=1, n do
		refuel()
		
		turtle.turnRight()
		while turtle.forward() == false do
				turtle.dig()
				turtle.attack()
		end
		turtle.turnLeft()
		z = z + 1
	end	
end

function invdump()
	home()
	for i = 1, 16 do
		turtle.select(i)
		turtle.drop()
	end
end

function quarry (l,w,d)
	for i=1, d do
		print ('Digging Layer '..i)
		dwn()
		for i=1, w do
			fwd(l)
			bk(l)
			if i < w then
				rgt()
			end
		end		
		lft(w-1)
	end
end

quarry (8,8,57)
home()