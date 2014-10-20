-- Game 0 - Snake game

local logfile = io.open("snake.log", "a")
local function log(...)
   local num = select("#", ...)
   local args = {}
   for i = 1, num do
      table.insert(args, tostring(select(i, ...)))
   end

   logfile:write(os.date("%Y-%m-%d %H:%M:%S"), ": ", table.concat(args), "\n")
   logfile:flush()
end

-------------

ModState = {}

function ModState:update_key()
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

function ModState:next_frame()
   local prev_time = self.frame_start_time
   local cur_time = elapsed_time()

   if prev_time and prev_time > 0 then
      local dur = 0.033 - (cur_time - prev_time)
      if dur > 0 then
         sleep(dur)
      end
   end
   self.frame_start_time = elapsed_time()
   local stat, elapsed = coroutine.yield()
end

-------------

InGameState = {}

function InGameState:new(mod_state)
   local o = {
      mod_state = mod_state,
      alive = true,
      head_pos = random_position(mod_state.stage_size, 10),
      direction = math.random(0, 3),
      length = 10,
      pos_in_trajectory = 1,
      trajectory = {},
      food_pos = random_position(mod_state.stage_size, 5),
      foods = 0,
   }

   setmetatable(o, {__index = InGameState})
   return o
end

function init_curses()
   local win = nc.initscr()

   nc.keypad(nc.stdscr, true)
   nc.nodelay(nc.stdscr, true)
   nc.noecho()
   nc.cbreak()
   nc.curs_set(0)
   nc.set_escdelay(0)
   nc.touchwin(win)

   return win
end

function clean_curses()
   nc.endwin()
end

function InGameState:check_key_and_game_finished()
   local stat = self.mod_state
   local finished = false

   if stat.key_state_down[27] then
      finished = true
   elseif stat.key_state_down[nc.KEY_RIGHT] then
      self.direction = 0
   elseif stat.key_state_down[nc.KEY_DOWN] then
      self.direction = 1
   elseif stat.key_state_down[nc.KEY_LEFT] then
      self.direction = 2
   elseif stat.key_state_down[nc.KEY_UP] then
      self.direction = 3
   end

   return finished
end

function next_position(pos, dir, stage_size)
   local x, y = pos.x, pos.y
   if dir == 0 then
      x = pos.x + 1
   elseif dir == 1 then
      y = pos.y + 1
   elseif dir == 2 then
      x = pos.x - 1
   elseif dir == 3 then
      y = pos.y - 1
   end

   x = x % stage_size.width
   y = y % stage_size.height

   return {x = x, y = y}
end

function random_position(stage_size, offset)
   offset = offset or 0
   return {x = offset + math.random(stage_size.width - 2 * offset) - 1,
           y = offset + math.random(stage_size.height - 2 * offset) - 1}
end

function put_string(win, pos, str)
   nc.mvwaddstr(win, pos.y, pos.x, str)
end

function ModState:show_title_screen()
   local finished = false
   local win, stage_size = self.stage_win, self.stage_size

   nc.werase(win)
   nc.touchwin(win)
   nc.wrefresh(win)
   local childwin = nc.subwin(win, 4, 30,
                              math.floor(stage_size.height / 2) - 1,
                              math.floor(stage_size.width / 2) - 15)
   nc.box(childwin, 0, 0)

   nc.mvwaddstr(childwin, 1, 4, "NCURSES SNAKE GAME");
   nc.mvwaddstr(childwin, 2, 4, "Press ENTER to start");
   nc.wrefresh(childwin)
   while not finished do
      self:update_key()
      if self.key_state_down[27] then -- ESCAPE
         finished = true
      elseif self.key_state_down[10] then -- ENTER
         break
      end
      self:next_frame()
   end

   nc.werase(childwin)
   nc.delwin(childwin)

   return finished
end

function ModState:show_result(foods)
   local finished = false

   local win, stage_size = self.stage_win, self.stage_size

   nc.touchwin(win)
   nc.wrefresh(win)
   local childwin = nc.subwin(win, 5, 30,
                              math.floor(stage_size.height / 2) - 1,
                              math.floor(stage_size.width / 2) - 15)
   nc.werase(childwin)
   nc.box(childwin, 0, 0)

   nc.mvwaddstr(childwin, 1, 4, "GAME OVER");
   nc.mvwaddstr(childwin, 2, 4, string.format("Foods: %d", foods));
   nc.mvwaddstr(childwin, 3, 4, "Press ENTER to Continue");
   nc.wrefresh(childwin)
   while not finished do
      self:update_key()
      if self.key_state_down[27] then -- ESCAPE
         finished = true
      elseif self.key_state_down[10] then -- ENTER
         break
      end
      self:next_frame()
   end

   nc.werase(childwin)
   nc.delwin(childwin)

   return finished
end

function InGameState:check_got_food()
   local stat = self.mod_state
   if self.head_pos.x == self.food_pos.x and self.head_pos.y == self.food_pos.y then
      self.food_pos = random_position(stat.stage_size, 5)
      self.length = self.length * 1.3
      self.foods = self.foods + 1

      put_string(stat.stage_win, self.food_pos, "#")
   end
end

function InGameState:check_died()
   local stat = self.mod_state
   local stage_win, stage_size = stat.stage_win, stat.stage_size
   for i, v in ipairs(self.trajectory) do
      if i ~= self.pos_in_trajectory and v.x == self.head_pos.x and v.y == self.head_pos.y then
         self.alive = false
         break
      end
   end
end

function InGameState:move_snake()
   local stat = self.mod_state
   self.trajectory[self.pos_in_trajectory] = {x = self.head_pos.x, y = self.head_pos.y}
   self.pos_in_trajectory = self.pos_in_trajectory % math.floor(self.length) + 1
   self.head_pos = next_position(self.head_pos, self.direction, stat.stage_size)
end

function InGameState:draw_snake()
   local stat = self.mod_state
   local stage_win, stage_size = stat.stage_win, stat.stage_size

   local tail = self.trajectory[self.pos_in_trajectory]
   if tail then
      put_string(stage_win, tail, " ")
   end

   if self.alive then
      put_string(stage_win, self.head_pos, "@")
   else
      for i, v in ipairs(self.trajectory) do
         put_string(stage_win, v, "o")
      end
      put_string(stage_win, self.head_pos, "*")
   end
end

function InGameState:main()
   local stat = self.mod_state
   local finished = false

   put_string(stat.stage_win, self.food_pos, "#")

   while not finished and self.alive do
      stat:update_key()

      finished = self:check_key_and_game_finished()

      self:move_snake()
      self:check_got_food()
      self:check_died()
      self:draw_snake()

      nc.wrefresh(stat.stage_win)
      stat:next_frame()
   end

   return finished
end

function main_coro(stat, elapsed)
   local root_win = init_curses()

   stat:next_frame()

   local width, height = nc.getmaxx(nc.stdscr), nc.getmaxy(nc.stdscr)
   nc.mvaddstr(0, 1, string.format("size: % 3d, % 3d     press ESC to quit",
                                   width, height))

   stat.stage_size = {width = width, height = height - 1}
   stat.stage_win = nc.subwin(root_win, height - 1, width, 1, 0)

   local finished = false
   local game_state

   while not finished do
      game_state = InGameState:new(stat)

      finished = stat:show_title_screen()
         or game_state:main()
         or stat:show_result(game_state.foods)
   end

   clean_curses()
end

function init()
   local o = {
      name = "game-0",
      coro = coroutine.create(main_coro),
      key_state = {},
   }
   setmetatable(o, {__index = ModState})
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
