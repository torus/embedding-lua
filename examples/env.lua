function g()
   print "global g"
end

function f()
   g()
end

_ENV = {print = print,
        f = f,
        g = function()
               print "local g!"
            end}
f()
