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
obj.menubar_title_muted = "muted 🤐"
obj.menubar_title_live = "live 🔴"
obj.notification_muted = "Muted the microphone"
obj.notification_live = "Enabled the microphone"
obj.isMuted = false

function obj:init()
    local selfWatchdog = function()
        self:watchdog()
    end

    self.timer = hs.timer.new(1, selfWatchdog)
end

function obj:start()

    self.menuIcon = hs.menubar.new(show_in_menubar)
    self.menuIcon:setClickCallback(function()
        self:toggle()
    end)

    hs.audiodevice.watcher.setCallback(function()
        self:setMute(self.isMuted, true)
    end)

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

function obj:setMute(state, silent)

    for _, device in pairs(hs.audiodevice.allInputDevices()) do
        device:setInputMuted(state)
    end

    self:updateMenuIcon()

    if silent ~= true then
        hs.notify.show("GlobalMute", "", self.isMuted and self.notification_muted or self.notification_live)
    end
end

function obj:updateMenuIcon()

    self.menuIcon:setTitle(self.isMuted and self.menubar_title_muted or self.menubar_title_live)
end

function obj:bindHotkeys(mapping)

    local def = {
        toggle = function()
            self:toggle()
        end
    }
    hs.spoons.bindHotkeysToSpec(def, mapping)
end

function obj:watchdog()

    if (self.isMuted) then
        for _, device in pairs(hs.audiodevice.allInputDevices()) do
            if not device:inputMuted() then
                hs.notify.show("GlobalMute", "", "Someone unmuted the input, resetting")
                self:setMute(true, true)

                break
            end
        end
    end
end

return obj
