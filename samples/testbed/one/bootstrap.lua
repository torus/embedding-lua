function init()
   return {
      name = "one",
      running = true
   }
end

local count = 10
function update(stat, elapsed)
   count = count - 1
   print(count, "elapsed time:", string.format("%2.7f", elapsed))

   if count < 0 then
      stat.running = false
   end
end

function running(stat)
   return stat.running
end
