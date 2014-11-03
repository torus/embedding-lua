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

function include_code (filename, segment)
   local infile = io.open(filename)
   local switch = not segment
   -- print("switch", switch, segment)
   for line in infile:lines() do
      -- print("line", line)
      if segment and switch and line:match("~~>>") then
         -- print("switch off")
         switch = false
      end
      if switch and not line:match("~~") then
         spin("    " .. line)
      end
      if segment and not switch and line:match("~~<<%s*" .. segment .. "%s*$") then
         -- print("switch on")
         switch = true
      end
   end
   infile:close()
end
