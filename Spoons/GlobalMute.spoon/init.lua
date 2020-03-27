--- === GlobalMute ===
---
--- 
local obj = {}
obj.__index = obj

-- Metadata
obj.name = "GlobalMute"
obj.version = "0.1"
obj.author = ""
obj.homepage = ""
obj.license = ""

obj.logger = hs.logger.new("GlobalMute")

obj.show_in_menubar = true
obj.menubar_title_muted = "muted ⚪"
obj.menubar_title_live = "live 🔴"
obj.isMuted = false

function obj:init() 
    local selfWatchdog = function () self:watchdog() end

    self.timer = hs.timer.new(1, selfWatchdog) 
end

function obj:start()

    local selfToggle = function () self:toggle() end

    self.menuIcon = hs.menubar.new(show_in_menubar)

    self.menuIcon:setClickCallback(selfToggle)
    hs.audiodevice.watcher.setCallback(selfToggle)

    hs.audiodevice.watcher.start()
    self.timer:start()

    self:updateMenuIcon()
end

function obj:stop()

    hs.audiodevice.watcher.setCallback(nil)
    hs.audiodevice.watcher.stop()

    self.timer:stop()

    self.menuIcon:delete()
end

function obj:toggle()
    self.isMuted = not self.isMuted
    self:setMute(self.isMuted)
end

function obj:setMute(state)

    for _, device in pairs(hs.audiodevice.allInputDevices()) do
        device:setInputMuted(state)
    end

    self:updateMenuIcon()
end

function obj:updateMenuIcon()

    self.menuIcon:setTitle(self.isMuted and self.menubar_title_muted or self.menubar_title_live)
end

function obj:bindHotkeys(mapping)

    local def = {toggle = function() self:toggle() end}
    hs.spoons.bindHotkeysToSpec(def, mapping)
end

function obj:watchdog()

    for _, device in pairs(hs.audiodevice.allInputDevices()) do
        if device:inputMuted() ~= self.isMuted then
            hs.alert.show("O: SOMEONE IS LISTENING :O")
            self.isMuted = true
            self:setMute(true)

            break
        end
    end
end

return obj
