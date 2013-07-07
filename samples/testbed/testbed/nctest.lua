require "nc"

function main()
   nc.keypad(nc.stdscr, true)
   nc.mvaddstr(10, 10, "hoge" .. tostring(nc.KEY_ENTER))
   local ch = nc.getch()
   while ch ~= 27 do		-- ESCAPE
      nc.mvaddstr(10, 20, tostring(ch))
      nc.refresh()
      ch = nc.getch()
   end
end


nc.initscr()

local stat, err = pcall(main)

nc.endwin()

print(stat, err)
