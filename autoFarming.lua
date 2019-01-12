component = require("component")
sides = require("sides")

robot = component.robot
inventory = component.inventory_controller
scanner = component.geolyzer

function canGrow()
   local info = scanner.analyze(sides.bottom)

   if (info) then
      return info.growth == 1
   else
      return false
   end
end

function grow()
   return robot.swing(sides.bottom)
end

function goStraightWith(length, f)
   for i = 1, length do
      local suc

      repeat
	 suc = robot.move(sides.front)
      until (suc)

      f()
   end
end

function onlyGoStraight(len)
   goStraightWith(len, function() end)
end

function goStraightWithGrow(len)
   goStraightWith(len,
		  function()
		     if (canGrow()) then
			grow()
			robot.place(sides.bottom)
		     end
		  end
   )
end

function search(turn, from, to)
   local function block(i)
      goStraightWithGrow(i)
      robot.turn(turn)
   end
   
   local step

   if (from > to) then
      step = -1
   else
      step = 1
   end

   for i = from, to, step do
      if (not (i == from or i == to)) then
	 block()
      end

      block()
   end
end

while (true) do
   search(false, 9, 1)

   robot.turn(true)
   robot.turn(true)
   onlyGoStraight(3)
   robot.turn(false)
   onlyGoStraight(4)
   robot.turn(true)
   onlyGoStraight(1)

   robot.turn(false)
   inventory.dropIntoSlot(sides.front, 1)
   robot.turn(false)
end

		  
