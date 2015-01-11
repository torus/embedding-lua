function may_have_error(a)
   if a then
      error("something is wrong")
   end
   return "no error"
end
local result, mesg = pcall(may_have_error, true)
if not result then
   print("[ERROR]", mesg)
end
