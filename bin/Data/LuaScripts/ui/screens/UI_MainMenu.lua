local uiManager = require("LuaScripts/ui/UI_Manager")
local gameAudio = require "LuaScripts/Audio"

---@class UiScreen
local Ui = {}

Ui.screenName = "MainMenu"

local randomMenuSounds = {
    "Sounds/rock/go_johnny.ogg",
    "Sounds/rock/i_am_complete.ogg",
    "Sounds/rock/crowd_cheer.ogg",
    "Sounds/rock/crowd.ogg",
}

--- links actions to buttons and etc. Usually, should be run only once
---@param instanceRoot UIElement
Ui.Setup = function (instanceRoot)

    local buttonPlay = instanceRoot:GetChild("ButtonPlay", true)

    SubscribeToEvent(buttonPlay, "Released", function ()
        instanceRoot:SetVisible(false)
        uiManager.ShowUI("Loading")
    end)

    local buttonCreds = instanceRoot:GetChild("ButtonCredits", true)
    SubscribeToEvent(buttonCreds, "Released", function ()
        instanceRoot:SetVisible(false)
        uiManager.ShowUI("Credits")
    end)

    local buttonHowTo = instanceRoot:GetChild("ButtonHowTo", true)
    SubscribeToEvent(buttonHowTo, "Released", function ()
        instanceRoot:SetVisible(false)
        uiManager.ShowUI("HowTo")
    end)

    local buttonQuit = instanceRoot:GetChild("ButtonExit", true)
    SubscribeToEvent(buttonQuit, "Released", function ()
        engine:Exit()
    end)

    if GetPlatform() == "Web" then
        buttonQuit:SetVisible(false)
    end

end

---@param instanceRoot UIElement
---@param dataPassed table
Ui.Show = function (instanceRoot, dataPassed)
    instanceRoot:SetVisible(true)

    gameAudio.StopMusic()

    gameAudio.PlayOneShotSoundWithFreqVariation(randomMenuSounds[RandomInt(1, #randomMenuSounds)], 1.0, 2000)
end

return Ui