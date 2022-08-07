local GlobalEvents = require "LuaScripts/GlobalEvents"

--    - Handle Esc key down to hide Console or exit application


local GameDebug = {}

GameDebug.drawDebug = false -- Draw debug geometry flag

local function GameDebugHandleKeyUp(eventType, eventData)
    local key = eventData["Key"]:GetInt()
    -- Close console (if open) or exit when ESC is pressed
    if key == KEY_ESCAPE then
        if console:IsVisible() then
            console:SetVisible(false)
        else
            if GetPlatform() ~= "Web" then
                engine:Exit()
            end
        end
    end
end

local function GameDebugHandleKeyDown(eventType, eventData)
    local key = eventData["Key"]:GetInt()

    local uiManager = require("LuaScripts/ui/UI_Manager")

    if key == KEY_F1 then
        console:Toggle()
        -- uiManager.ShowUI("Loading")
    elseif key == KEY_F2 then
        debugHud:ToggleAll()

        -- ---@type EndGameScreenData
        -- local endgameData = {}
        -- endgameData.hasWon = true

        -- uiManager.ShowUI("Endgame", endgameData)
    elseif key == KEY_F3 then
        GameDebug.drawDebug = not GameDebug.drawDebug
        -- uiManager.ShowUI("MainMenu")
    elseif key == KEY_F5 then
        Scene_:SaveXML(fileSystem:GetProgramDir().."Data/Scenes/".. ProjectFolderName .. "/debugSave.xml")
        ui.root:SaveXML(fileSystem:GetProgramDir().."Data/UI/" .. ProjectFolderName .. "/debugSaveUI.xml")
    end

end

function GameDebug.DebugSetup()

    -- Create console and debug HUD
    GameDebug.CreateConsoleAndDebugHud()

    -- Subscribe key down event
    GlobalEvents:SubscribeToEvent("KeyDown", GameDebugHandleKeyDown)

    -- Subscribe key up event
    GlobalEvents:SubscribeToEvent("KeyUp", GameDebugHandleKeyUp)
end

function GameDebug.CreateConsoleAndDebugHud()
    -- Get default style
    local uiStyle = cache:GetResource("XMLFile", "UI/DefaultStyle.xml")
    if uiStyle == nil then
        return
    end

    -- Create console
    engine:CreateConsole()
    console.defaultStyle = uiStyle
    console.background.opacity = 0.8

    -- Create debug HUD
    engine:CreateDebugHud()
    debugHud.defaultStyle = uiStyle
end



return GameDebug
