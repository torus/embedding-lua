function spin (line)
   print(line)
end

function code_aux (filename, proc)
   local out = io.open(filename, "w")
   local function local_spin (line)
      out:write(line, "\n")
      out:flush()
      spin(line)
   end
   proc(local_spin)
   out:close()

   local f, err = loadfile(filename)
   if not f then
      io.stderr:write("SYNTAX ERROR: ", err, "\n")
      os.exit(false)
   end
end

function code (filename, proc)
   code_aux("eg/" .. filename, proc)
end

function codetmp (proc)
   local filename = os.tmpname()
   code_aux(filename, proc)
   os.remove(filename)
end
