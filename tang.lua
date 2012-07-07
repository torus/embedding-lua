local file = arg[1]
local fh = io.open(file)

print [[
require "spinner"
]]

for line in fh:lines() do
   local exp = line:match("^%s*~~%s*(.*)$")
   if exp then
      print(exp)
   else
      print(string.format("spin %q", line))
   end
end
