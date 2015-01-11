function f()
   g()
   print("ここには来ない。")
end
function g()
   h()
end
function h()
   error("exit from h()")
end
local stat, obj = pcall(f)
print ("message:", obj)
