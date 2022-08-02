local uiManager = require("LuaScripts/ui/UI_Manager")
local world = require("LuaScripts/World")

---@class UiGame: UiScreen
local Ui = {}

Ui.screenName = "Game"


---@type ProgressBar
local timeBar = nil


--- links actions to buttons and etc. Usually, should be run only once
---@param instanceRoot UIElement
Ui.Setup = function (instanceRoot)
    timeBar = instanceRoot:GetChild("BottomBar", true)
end

---@param instanceRoot UIElement
---@param dataPassed table
Ui.Show = function (instanceRoot, dataPassed)
    instanceRoot:SetVisible(true)
    world.PlayerScript.timeBar = timeBar
end

return Ui