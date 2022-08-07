local uiManager = require("LuaScripts/ui/UI_Manager")
local world = require("LuaScripts/World")

---@class UiGame: UiScreen
local Ui = {}

Ui.screenName = "Game"


---@type UIElement
local playerEntriesParent = nil


--- links actions to buttons and etc. Usually, should be run only once
---@param instanceRoot UIElement
Ui.Setup = function (instanceRoot)
    playerEntriesParent = instanceRoot:GetChild("playerFields", true)
end

---@param instanceRoot UIElement
---@param dataPassed table
Ui.Show = function (instanceRoot, dataPassed)
    instanceRoot:SetVisible(true)

    -- remove existing player UI entries from previous games
    while playerEntriesParent:GetNumChildren() > 2 do
        playerEntriesParent:RemoveChildAtIndex(1)
    end
end

--- returns the player's rocking progress bar
---@param playerData PlayerCharacterData
---@param playerColor Color
---@return ProgressBar
Ui.SetupPlayer = function (playerData, playerColor)
    local playerEntriesCount = playerEntriesParent:GetNumChildren() - 2 -- there are 2 spacers as children
    local newEntry = ui:LoadLayout(cache:GetResource("XMLFile", "UI/rock/screen_game_player_entry.xml"))
    newEntry:SetParent(playerEntriesParent, playerEntriesCount + 1)
    local playerPicImg = newEntry:GetChild("playerEntryPic") --[[@as BorderImage]]
    local playerPicTexture = cache:GetResource("Texture2D", playerData.portraitSpritePath)
    -- this seems to work? no need to tolua_cast?
    playerPicImg:SetTexture(playerPicTexture)
    playerPicImg:SetFullImageRect()

    local playerColorIndicator = playerPicImg:GetChild("playerColorIndicator") --[[@as BorderImage]]
    playerColorIndicator:SetColor(playerColor)

    local playerProgBar = newEntry:GetChild("playerEntryProgBar") --[[@as ProgressBar]]
    playerProgBar:SetValue(0.0)
    playerProgBar:SetColor(playerColor)
    return playerProgBar
end

return Ui