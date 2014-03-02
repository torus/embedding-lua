function init()
   return {
      name = "one",
      running = true
   }
end

local count = 20
function update(stat, elapsed)
   count = count - 1
   print(stat, elapsed, count)

   if count < 0 then
      stat.running = false
   end
end

function running(stat)
   print(stat.running)
   return stat.running
end
