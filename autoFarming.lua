--[[ 
名称: 马铃薯农场自动收割 (用于全自动彼方兰产魔)
用于: 机器人
需要: 
物品栏升级
物品栏控制器升级
地质分析仪
]]--

component = require("component")
sides = require("sides")

robot = component.robot
inventory = component.inventory_controller
scanner = component.geolyzer

-- 存放作物
function store()
   for i = 1, 16 do
      robot.select(i)
      inventory.dropIntoSlot(sides.front, i)
   end

   robot.select(1)
end

-- 判断下方作物是否成熟
function canGrow()
   local info = scanner.analyze(sides.bottom)

   if (info) then
      return info.growth == 1
   else
      return false
   end
end

-- 采摘下方作物
function grow()
   return robot.swing(sides.bottom)
end

-- 直行, 每一格执行一次 f
function goStraightWith(length, f)
   for i = 1, length do
      local suc

      repeat
	 suc = robot.move(sides.front)
      until (suc)

      f()
   end
end

-- 仅 直行
function onlyGoStraight(len)
   goStraightWith(len, function() end)
end

-- 直行并采摘作物
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

-- 对农场进行遍历, 螺旋路线
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
	 block(i)
      end

      block(i)
   end
end

while (true) do
   search(false, 9, 1)

   -- 遍历结束, 返回起点 (这实在是太暴力了, 这是不行的
   robot.turn(true)
   robot.turn(true)
   onlyGoStraight(3)
   robot.turn(false)
   onlyGoStraight(4)
   robot.turn(true)
   onlyGoStraight(1)

   -- 此时应该背对农场, 接着转向箱子
   robot.turn(false)
   -- 放入农作物
   -- inventory.dropIntoSlot(sides.front, 1)
   store()
   robot.turn(false)
end

		  
