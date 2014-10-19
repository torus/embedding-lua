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

function GameState:check_key_and_game_finished(direction)
   local finished = false

   if self.key_state_down[27] then
      finished = true
   elseif self.key_state_down[nc.KEY_RIGHT] then
      direction = 0
   elseif self.key_state_down[nc.KEY_DOWN] then
      direction = 1
   elseif self.key_state_down[nc.KEY_LEFT] then
      direction = 2
   elseif self.key_state_down[nc.KEY_UP] then
      direction = 3
   end

   return finished, direction
end

function GameState:next_frame()
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
   return {x = offset + math.random(stage_size.width - offset) - 1,
           y = offset + math.random(stage_size.height - offset) - 1}
end

function put_string(win, pos, str)
   nc.mvwaddstr(win, pos.y, pos.x, str)
end

function show_title_screen(stat)
   local finished = false
   local win, stage_size = stat.stage_win, stat.stage_size

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
      stat:update_key()
      if stat.key_state_down[27] then -- ESCAPE
         finished = true
      elseif stat.key_state_down[10] then -- ENTER
         break
      end
      stat:next_frame()
   end

   nc.delwin(childwin)
   nc.werase(win)

   return finished
end

function show_result(stat, foods)
   local finished = false

   local win, stage_size = stat.stage_win, stat.stage_size

   nc.touchwin(win)
   nc.wrefresh(win)
   local childwin = nc.subwin(win, 5, 30,
                              math.floor(stage_size.height / 2) - 1,
                              math.floor(stage_size.width / 2) - 15)
   nc.box(childwin, 0, 0)

   nc.mvwaddstr(childwin, 1, 4, "GAME OVER");
   nc.mvwaddstr(childwin, 2, 4, string.format("Foods: %d", foods));
   nc.mvwaddstr(childwin, 3, 4, "Press ENTER to Continue");
   nc.wrefresh(childwin)
   while not finished do
      stat:update_key()
      if stat.key_state_down[27] then -- ESCAPE
         finished = true
      elseif stat.key_state_down[10] then -- ENTER
         break
      end
      stat:next_frame()
   end

   nc.delwin(childwin)
   nc.werase(win)

   return finished
end

function check_got_food(stat, gstat)
   if gstat.head_pos.x == gstat.food_pos.x and gstat.head_pos.y == gstat.food_pos.y then
      gstat.food_pos = random_position(stat.stage_size, 5)
      gstat.length = gstat.length * 1.3
      gstat.foods = gstat.foods + 1

      put_string(stat.stage_win, gstat.food_pos, "#")
   end
end

function check_died(stat, gstat)
   local stage_win, stage_size = stat.stage_win, stat.stage_size
   for i, v in ipairs(gstat.trajectory) do
      if v.x == gstat.head_pos.x and v.y == gstat.head_pos.y then
         gstat.alive = false
         put_string(stage_win, gstat.head_pos, "*")
         nc.wrefresh(stage_win)
         break
      end
   end
end

function ingame_main(stat, gstat)
   local finished = false
   local stage_win, stage_size = stat.stage_win, stat.stage_size

   put_string(stage_win, gstat.food_pos, "#")

   while not finished and gstat.alive do
      stat:update_key()

      finished, gstat.direction = stat:check_key_and_game_finished(gstat.direction)
      if finished then break end

      gstat.head_pos = next_position(gstat.head_pos, gstat.direction, stage_size)

      check_got_food(stat, gstat)

      put_string(stage_win, gstat.head_pos, "@")

      check_died(stat, gstat)
      -- for i, v in ipairs(gstat.trajectory) do
      --    if v.x == gstat.head_pos.x and v.y == gstat.head_pos.y then
      --       gstat.alive = false
      --       put_string(stage_win, gstat.head_pos, "*")
      --       nc.wrefresh(stage_win)
      --       break
      --    end
      -- end

      local tail = gstat.trajectory[gstat.pos_in_trajectory]
      if tail then
         put_string(stage_win, tail, " ")
      end
      gstat.trajectory[gstat.pos_in_trajectory] = {x = gstat.head_pos.x, y = gstat.head_pos.y}
      gstat.pos_in_trajectory = (gstat.pos_in_trajectory + 1) % math.floor(gstat.length)

      nc.wrefresh(stage_win)
      nc.refresh()
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
      log("start: ", stat, " ", stat.stage_win)
      game_state = {
         alive = true,
         head_pos = random_position(stat.stage_size, 10),
         direction = math.random(0, 3),
         length = 10,
         pos_in_trajectory = 1,
         trajectory = {},
         food_pos = random_position(stat.stage_size, 5),
         foods = 0,
      }

      finished = show_title_screen(stat)
         or ingame_main(stat, game_state)
         or show_result(stat, game_state.foods)
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
