function main_coro(stat, elapsed)
   nc.initscr()

   nc.keypad(nc.stdscr, true)
   nc.nodelay(nc.stdscr, true)
   nc.noecho()

   local width, height = nc.getmaxx(nc.stdscr), nc.getmaxy(nc.stdscr)

   nc.mvaddstr(0, 1, string.format("size: % 3d, % 3d   press ESC to quit", width, height))

   local ch = nc.getch()
   while ch ~= 27 do		-- ESCAPE
      nc.mvaddstr(1, 1, string.format("FPS: %6.4f     ", 1 / elapsed))
      local text = os.date()
      nc.mvaddstr(math.floor(height / 2), math.floor((width - #text) / 2), text)
      nc.refresh()
      ch = nc.getch()
      sleep(0.033)
      stat, elapsed = coroutine.yield()
   end

   nc.endwin()
end

function init()
   return {
      name = "clock",
      coro = coroutine.create(main_coro)
   }
end

function update(stat, elapsed)
   coroutine.resume(stat.coro, stat, elapsed)
end

function running(stat)
   return coroutine.status(stat.coro) ~= "dead"
end
