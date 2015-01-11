function main()
   local subco = coroutine.wrap(subroutine)
   local value = subco("arg")
end

function retvalue(value)
   coroutine.yield(value)
end

function subroutine(param)
   retvalue("hello " .. param)
end
