require "nc"

function main()
   nc.keypad(nc.stdscr, true)
   nc.nodelay(nc.stdscr, true)
   nc.noecho()

   local ch = nc.getch()
   local count = 0
   while ch ~= 27 do		-- ESCAPE
      count = count + 1
      if ch > 0 then
	 nc.mvaddstr(10, 20, tostring(ch) .. "     ")
	 count = 0
      end
      nc.mvaddstr(10, 30, count .. "     ")
      nc.refresh()
      ch = nc.getch()
   end
end


nc.initscr()

local stat, err = pcall(main)

nc.endwin()

print(stat, err)
