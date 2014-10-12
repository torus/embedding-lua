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

function random_position(stage_size)
   return {x = math.random(stage_size.width) - 1,
           y = math.random(stage_size.height) - 1}
end

function put_string(win, pos, str)
   nc.mvwaddstr(win, pos.y, pos.x, str)
end

function show_title_screen(stat, win, stage_size)
   local finished = false

   nc.werase(win)
   nc.touchwin(win)
   nc.wrefresh(win)
   local childwin = nc.subwin(win, 3, 30,
                              math.floor(stage_size.height / 2) - 1,
                              math.floor(stage_size.width / 2) - 15)
   nc.box(childwin, 0, 0)

   nc.mvwaddstr(childwin, 1, 4, "Press ENTER to start");
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

function main_coro(stat, elapsed)
   local root_win = init_curses()

   stat:next_frame()

   local width, height = nc.getmaxx(nc.stdscr), nc.getmaxy(nc.stdscr)
   nc.mvaddstr(0, 1, string.format("size: % 3d, % 3d     press ESC to quit",
                                   width, height))

   local stage_size = {width = width, height = height - 1}

   local head_pos
   local direction
   local length
   local pos_in_trajectory
   local trajectory
   local food_pos

   local finished = false
   local alive

   local stage_win = nc.subwin(root_win, height - 1, width, 1, 0)

   while not finished do
      log("start: ", stat, " ", stage_win)
      finished = show_title_screen(stat, stage_win, stage_size)

      alive = true
      head_pos = random_position(stage_size)
      direction = math.random(0, 3)
      length = 4
      pos_in_trajectory = 1
      trajectory = {}
      food_pos = random_position(stage_size)
      put_string(stage_win, food_pos, "#")

      while not finished and alive do
         stat:update_key()

         finished, direction = stat:check_key_and_game_finished(direction)
         if finished then break end

         head_pos = next_position(head_pos, direction, stage_size)

         if head_pos.x == food_pos.x and head_pos.y == food_pos.y then
            food_pos = random_position(stage_size)
            length = length + 2

            put_string(stage_win, food_pos, "#")
         end

         put_string(stage_win, head_pos, "@")

         for i, v in ipairs(trajectory) do
            if v.x == head_pos.x and v.y == head_pos.y then
               alive = false
               put_string(stage_win, head_pos, "*")
               nc.wrefresh(stage_win)
               sleep(1)
               break
            end
         end

         local tail = trajectory[pos_in_trajectory]
         if tail then
            put_string(stage_win, tail, " ")
         end
         trajectory[pos_in_trajectory] = {x = head_pos.x, y = head_pos.y}
         pos_in_trajectory = (pos_in_trajectory + 1) % length

         nc.wrefresh(stage_win)
         nc.refresh()
         stat:next_frame()
      end
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
