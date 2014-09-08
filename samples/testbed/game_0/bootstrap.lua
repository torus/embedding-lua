-- Game 0

GameState = {}

function GameState:update_key()
   self.key_state_up = {}
   self.key_state_down = {}

   local ch = nc.getch()
   for k, v in pairs(self.key_state) do
      if k ~= ch then
         self.key_state_up[k] = true
         self.key_state[k] = nil
      end
   end
   if ch ~= nc.ERR and not self.key_state[ch] then
      self.key_state_down[ch] = true
      self.key_state[ch] = true
   end
end

Entity = {}

function Entity:addEventListener(el)
   table.insert(self.event_listeners, el)
   return self
end

function init_curses()
   nc.initscr()

   nc.keypad(nc.stdscr, true)
   nc.nodelay(nc.stdscr, true)
   nc.noecho()
   nc.cbreak()
end

function clean_curses()
   nc.endwin()
end

function main_coro(stat, elapsed)
   init_curses()

   local width, height = nc.getmaxx(nc.stdscr), nc.getmaxy(nc.stdscr)
   nc.mvaddstr(0, 1, string.format("size: % 3d, % 3d   press ESC to quit", width, height))

   while true do
      stat:update_key()
      if stat.key_state_down[27] then
         break
      end

      nc.mvaddstr(1, 1, string.format("FPS: %6.4f     ", 1 / elapsed))
      local text = os.date()
      nc.mvaddstr(math.floor(height / 2), math.floor((width - #text) / 2), text)
      nc.refresh()

      sleep(0.033)
      stat, elapsed = coroutine.yield()
   end

   clean_curses()
end

function init()
   local o = {
      name = "game-0",
      coro = coroutine.create(main_coro),
      key_state = {},
   }
   setmetatable(o, {__index = GameState})
   return o
end

function update(stat, elapsed)
   local success, err = coroutine.resume(stat.coro, stat, elapsed)
   if not success then
      clean_curses()
      error(err)
   end
end

function running(stat)
   return coroutine.status(stat.coro) ~= "dead"
end
