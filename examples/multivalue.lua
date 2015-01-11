function three_times (a, b, c)
   return a * 3, b * 3, c * 3
end

local x, y, z = three_times(1, 2, 3)

function sum (a, b, c)
   return a + b + c
end

local x = sum(three_times(1, 2, 3))

function three_times2 (...)
   local vals = {...}

   for i, v in ipairs(vals) do
      vals[i] = 3 * v
   end
   
   -- 計算結果を返す……
end

function three_times2 (...)
   local vals = {...}

   for i, v in ipairs(vals) do
      vals[i] = 3 * v
   end
   
   return table.unpack(vals)
end

local numbers = {1, 2, 3, 4}
local a, b, c, d = three_times2(table.unpack(numbers))
