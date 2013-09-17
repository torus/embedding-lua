function spin (line)
   print(line)
end

function write_code_to_file (filename, proc)
   local out = io.open(filename, "w")
   local function local_spin (line)
      out:write(line:sub(5), "\n")
      out:flush()
      spin(line)
   end
   proc(local_spin)
   out:close()
end

function code_aux (filename, proc)
   write_code_to_file(filename, proc)

   local f, err = loadfile(filename)
   if not f then
      io.stderr:write("SYNTAX ERROR: ", err, "\n")
      os.exit(false)
   end
end

function code (filename, proc)
   code_aux("eg/" .. filename, proc)
end

function code_any (filename, proc)
   write_code_to_file("eg/" .. filename, proc)
end

function codetmp (proc)
   local filename = os.tmpname()
   code_aux(filename, proc)
   os.remove(filename)
end

function include_code (filename)
   local infile = io.open(filename)
   for line in infile:lines() do
      spin("    " .. line)
   end
   infile:close()
end
