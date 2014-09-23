-- Game 0 - Snake game

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
   nc.initscr()

   nc.keypad(nc.stdscr, true)
   nc.nodelay(nc.stdscr, true)
   nc.noecho()
   nc.cbreak()
   nc.curs_set(0)
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

function main_coro(stat, elapsed)
   init_curses()

   stat, elapsed = coroutine.yield()

   math.randomseed(elapsed * 1000000)

   local width, height = nc.getmaxx(nc.stdscr), nc.getmaxy(nc.stdscr)
   nc.mvaddstr(0, 1, string.format("size: % 3d, % 3d, seed: %f     press ESC to quit",
                                   width, height, elapsed))

   local stage_size = {width = width, height = height - 1}
   local stage_pos = {x = 0, y = 1}

   local head_pos = {x = math.random(stage_size.width) - 1,
                     y = math.random(stage_size.height) - 1}
   local direction = math.random(0, 3)
   local length = 4
   local pos_in_trajectory = 1
   local trajectory = {}
   local food_pos = {x = math.random(stage_size.width) - 1,
                     y = math.random(stage_size.height) - 1}

   local finished = false

   nc.mvaddstr(math.floor(stage_size.height / 2) + stage_pos.y - 1,
               math.floor(stage_size.width / 2) + stage_pos.x - 10,
               "Press ENTER to start")

   while not finished do
      stat:update_key()
      if stat.key_state_down[27] then -- ESCAPE
         finished = true
      elseif stat.key_state_down[10] then -- ENTER
         break
      end
      sleep(0.033)
      stat, elapsed = coroutine.yield()
   end

   nc.mvaddstr(math.floor(stage_size.height / 2) + stage_pos.y - 1,
               math.floor(stage_size.width / 2) + stage_pos.x - 10,
               "                    ")

   nc.mvaddstr(food_pos.y + stage_pos.y,
               food_pos.x + stage_pos.x, "#")

   while not finished do
      stat:update_key()

      finished, direction = stat:check_key_and_game_finished(direction)
      if finished then break end

      head_pos = next_position(head_pos, direction, stage_size)

      if head_pos.x == food_pos.x and head_pos.y == food_pos.y then
         food_pos = {x = math.random(stage_size.width) - 1,
                     y = math.random(stage_size.height) - 1}
         length = length + 2
         -- えさが体に埋まらないようにする
         nc.mvaddstr(food_pos.y + stage_pos.y,
                     food_pos.x + stage_pos.x, "#")
      end

      nc.mvaddstr(head_pos.y + stage_pos.y,
                  head_pos.x + stage_pos.x, "@")

      for i, v in ipairs(trajectory) do
         if v.x == head_pos.x and v.y == head_pos.y then
            finished = true
            nc.mvaddstr(head_pos.y + stage_pos.y,
                        head_pos.x + stage_pos.x, "*")
            nc.refresh()
            sleep(1)
            break
         end
      end

      local tail = trajectory[pos_in_trajectory]
      if tail then
         nc.mvaddstr(tail.y + stage_pos.y, tail.x + stage_pos.x, " ")
      end
      trajectory[pos_in_trajectory] = {x = head_pos.x, y = head_pos.y}
      pos_in_trajectory = (pos_in_trajectory + 1) % length

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
