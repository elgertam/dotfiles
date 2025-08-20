-- LayoutRestorer.spoon
-- Saves/restores window layouts per display arrangement.
-- Author: You + ChatGPT
-- License: MIT

local obj = {}
obj.__index = obj

obj.name = "LayoutRestorer"
obj.version = "1.0.0"
obj.author = "You"
obj.homepage = "https://github.com/yourname/LayoutRestorer.spoon" -- optional
obj.license = "MIT"

-- ============ User options ============
obj.storagePath = hs.configdir .. "/layouts.json"
obj.debounceSeconds = 1.0
obj.autoRestoreOnScreenChange = true
obj.autoSaveOnUndock = true       -- when screens decrease in count
obj.ignoreFullScreenWindows = true
obj.ignoreNonStandardWindows = true
obj.log = hs.logger.new("LayoutRestorer", "info")

-- Keys to save/restore
-- Provide via :bindHotkeys(...)
obj.hotkeys = nil

-- ============ Internals ===============
local screenWatcher = nil
local caffeinateWatcher = nil
local debounceTimer = nil
local lastSignature = nil
local lastScreenCount = nil

-- Utility: read/write JSON
local function readJSON(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local raw = f:read("*a")
  f:close()
  local ok, data = pcall(hs.json.decode, raw)
  if ok then return data else return nil end
end

local function writeJSON(path, tbl)
  local f, err = io.open(path, "w")
  if not f then
    obj.log.e("Error opening layout file for write: " .. tostring(err))
    return false
  end
  f:write(hs.json.encode(tbl, true))
  f:close()
  return true
end

-- Normalize window rect to unit coords within its screen
local function toUnitRect(win)
  local wf = win:frame()
  local sf = win:screen():frame()
  return {
    x = (wf.x - sf.x) / sf.w,
    y = (wf.y - sf.y) / sf.h,
    w = wf.w / sf.w,
    h = wf.h / sf.h,
  }
end

local function fromUnitRect(unit, screen)
  local sf = screen:frame()
  return {
    x = sf.x + unit.x * sf.w,
    y = sf.y + unit.y * sf.h,
    w = unit.w * sf.w,
    h = unit.h * sf.h,
  }
end

-- A stable signature of the current display arrangement.
-- Uses screen UUIDs plus their frames (so arrangement/positions matter).
local function screenSignature()
  local screens = hs.screen.allScreens()
  local parts = {}
  for _, s in ipairs(screens) do
    local uuid = s:getUUID() or s:id() or s:name()
    local f = s:frame()
    table.insert(parts, string.format("%s:%d,%d,%d,%d", uuid, f.x, f.y, f.w, f.h))
  end
  table.sort(parts) -- order independent
  return table.concat(parts, "|"), #screens
end

-- Safe window filter
local function shouldIncludeWindow(win)
  if not win or not win:application() then return false end
  if obj.ignoreNonStandardWindows and not win:isStandard() then return false end
  if obj.ignoreFullScreenWindows and win:isFullScreen() then return false end
  if win:isMinimized() then return false end
  -- ignore hidden apps windows
  local app = win:application()
  if app and app:isHidden() then return false end
  return true
end

-- Key to identify a window reliably enough between sessions.
local function winKey(win)
  local app = win:application()
  local bundle = app and app:bundleID() or (app and app:name()) or "UnknownApp"
  local title = win:title() or ""
  -- Using role/subrole can make it a bit more robust across title changes
  local role = win:role() or ""
  local sub = win:subrole() or ""
  return table.concat({bundle, role, sub, title}, "::")
end

-- Load the full layout database (per signature)
local function loadDB()
  return readJSON(obj.storagePath) or {}
end

local function saveDB(db)
  writeJSON(obj.storagePath, db)
end

-- ============ Public API ==============

-- Capture the layout for the current signature.
function obj:saveLayout()
  local sig, count = screenSignature()
  local db = loadDB()
  db[sig] = db[sig] or { windows = {}, ts = os.time() }

  local wins = hs.window.allWindows()
  local byKey = {}

  for _, w in ipairs(wins) do
    if shouldIncludeWindow(w) then
      local key = winKey(w)
      byKey[key] = {
        app = w:application() and (w:application():bundleID() or w:application():name()) or "UnknownApp",
        title = w:title() or "",
        screenUUID = (w:screen() and (w:screen():getUUID() or w:screen():id() or w:screen():name())) or "UnknownScreen",
        unit = toUnitRect(w),
      }
    end
  end

  db[sig].windows = byKey
  db[sig].ts = os.time()

  saveDB(db)
  hs.alert.show("Layout saved (" .. tostring(count) .. " screen(s))")
  obj.log.i("Saved layout for signature: " .. sig)
end

-- Restore the layout for the current signature.
function obj:restoreLayout()
  local sig = select(1, screenSignature())
  local db = loadDB()
  local layout = db[sig]
  if not layout or not layout.windows then
    hs.alert.show("No saved layout for this display setup")
    obj.log.w("No layout for signature: " .. sig)
    return
  end

  -- Map available screens by uuid/id/name
  local screens = hs.screen.allScreens()
  local screenMap = {}
  for _, s in ipairs(screens) do
    screenMap[s:getUUID()] = s
    screenMap[s:id()] = s
    screenMap[s:name()] = s
  end

  local countRestored = 0
  for _, w in ipairs(hs.window.allWindows()) do
    if shouldIncludeWindow(w) then
      local key = winKey(w)
      local entry = layout.windows[key]
      if entry then
        local targetScreen = screenMap[entry.screenUUID] or w:screen()
        local frame = fromUnitRect(entry.unit, targetScreen)
        w:setFrame(frame, 0) -- no animation for speed/precision
        countRestored = countRestored + 1
      end
    end
  end

  hs.alert.show("Layout restored (" .. tostring(countRestored) .. " windows)")
  obj.log.i(string.format("Restored %d windows for signature %s", countRestored, sig))
end

-- Fixed “recipe” application for predictable setups (optional helper).
-- layout = { {app="Safari", screen="DELL U2720Q", unit={x=0,y=0,w=1,h=1}}, ... }
function obj:applyFixedLayout(layout)
  local screens = hs.screen.allScreens()
  local byName = {}
  for _, s in ipairs(screens) do byName[s:name()] = s end

  for _, rule in ipairs(layout) do
    local appname = rule.app
    local app = hs.appfinder.appFromName(appname)
    if app then
      local wins = app:allWindows()
      for _, w in ipairs(wins) do
        if shouldIncludeWindow(w) then
          local target = byName[rule.screen] or w:screen()
          local frame = fromUnitRect(rule.unit, target)
          w:setFrame(frame, 0)
        end
      end
    end
  end
end

-- Hotkey binder
function obj:bindHotkeys(mapping)
  self.hotkeys = {
    save    = mapping.save    and hs.hotkey.bind(table.unpack({mapping.save[1], mapping.save[2], self.saveLayout, self})) or nil,
    restore = mapping.restore and hs.hotkey.bind(table.unpack({mapping.restore[1], mapping.restore[2], self.restoreLayout, self})) or nil,
  }
end

-- Start watchers
function obj:start()
  if screenWatcher then return self end

  local function handleChange()
    if debounceTimer then debounceTimer:stop() end
    debounceTimer = hs.timer.doAfter(self.debounceSeconds, function()
      local sig, count = screenSignature()
      local previousCount = lastScreenCount
      lastSignature = sig
      lastScreenCount = count

      self.log.i(string.format("Screen change detected. Sig=%s (count=%d)", sig, count))

      if self.autoSaveOnUndock and previousCount and (count < previousCount) then
        -- Before we lost a display, we *had* a layout. Save the last known layout
        -- (this runs *after* the change, so just save current single screen state).
        self:saveLayout()
      end

      if self.autoRestoreOnScreenChange then
        self:restoreLayout()
      end
    end)
  end

  screenWatcher = hs.screen.watcher.new(handleChange)
  screenWatcher:start()

  caffeinateWatcher = hs.caffeinate.watcher.new(function(event)
    -- Restore after wake/unlock as windows often jumble then.
    if event == hs.caffeinate.watcher.systemDidWake
       or event == hs.caffeinate.watcher.screensDidUnlock
       or event == hs.caffeinate.watcher.screensDidWake then
      if debounceTimer then debounceTimer:stop() end
      debounceTimer = hs.timer.doAfter(self.debounceSeconds, function()
        self:restoreLayout()
      end)
    end
  end)
  caffeinateWatcher:start()

  -- Capture initial state
  lastSignature, lastScreenCount = screenSignature()
  self.log.i("LayoutRestorer started. Current signature: " .. lastSignature)
  return self
end

function obj:stop()
  if screenWatcher then screenWatcher:stop(); screenWatcher = nil end
  if caffeinateWatcher then caffeinateWatcher:stop(); caffeinateWatcher = nil end
  if debounceTimer then debounceTimer:stop(); debounceTimer = nil end
  return self
end

return obj
