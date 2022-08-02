local uiManager = require "LuaScripts/ui/UI_Manager"
local gameAudio = require "LuaScripts/Audio"

local world = {}

world.DoneSettingUp = false

---@type Node
world.PlayerNode = nil

---@type Player
world.PlayerScript = nil

---@type Node
world.DynamicContentParent = nil

--- assuming world is a square
world.BOUNDS_UNSCALED = Vector2(5.0, 2.3)

world.WORLD_SCALE = Vector2(3.5, 4.0)


function world.CreateDynamicContent()

    CurGameState = GAMESTATE_STARTING

    world.DynamicContentParent = Scene_:CreateChild("DynamicContent")

    -- Create player character
    world.CreateCharacter(Vector2.ZERO)

end


function world.CreateCharacter(position)

    world.PlayerNode = world.DynamicContentParent:CreateChild("PlayerNode")
    world.PlayerNode:SetParent(world.DynamicContentParent)

    ---@type Player
    world.PlayerScript = world.PlayerNode:CreateScriptObject("Player") -- Create a ScriptObject to handle character behavior

end

function world.CreateWatcher(position)
    local watcherXml = cache:GetResource("XMLFile", "Objects/mballs/watcher.xml")
    local watcherNode = Scene_:InstantiateXML(watcherXml:GetRoot(), position, Quaternion.IDENTITY)
    watcherNode:SetParent(world.DynamicContentParent)

    watcherNode:CreateScriptObject("Watcher")
end


---@param spawnPos Vector2
---@param isInFlippedWorld boolean
function world.CreateEnemy(spawnPos, isInFlippedWorld)

    local node = world.DynamicContentParent:CreateChild("Enemy")
    node.position2D = spawnPos

    ---@type Enemy
    local enemyScript = node:CreateScriptObject("Enemy")

    enemyScript:SetupFlipDependentData(isInFlippedWorld)

    return node
end


---@param victory boolean
function world.EndGame(victory)
    if CurGameState ~= GAMESTATE_ENDED then
        CurGameState = GAMESTATE_ENDED

        world.PlayerScript.canCountTime = false
        world.PlayerScript.canMove = false

        uiManager.HideUI("Game")

        ---@type EndGameScreenData
        local gameEndData = {
            hasWon = victory
        }

        if victory then
            TimesWon = TimesWon + 1
        else
            gameAudio.PlayOneShotSoundWithFreqVariation("Music/duality/gameplaytransition.ogg", 0.65, 0)
        end

        uiManager.ShowUI("Endgame", gameEndData)
        
    end
end

function world.FreezeAllPlayers()
    -- TODO make this work in multiplayer
    world.PlayerScript.body:SetKinematic(true)
    world.PlayerScript.canMove = false
end

function world.Cleanup()
    if world.DynamicContentParent ~= nil then
        world.DynamicContentParent:Remove()
        world.DynamicContentParent = nil

        CurGameState = GAMESTATE_ENDED
    end
end

function world.SpawnOneShotParticleEffect(worldPosition, effectPath)
    local particleNode = Scene_:CreateChild("Emitter")
    particleNode:SetPosition(worldPosition)
    ---@type ParticleEmitter
    local particleEmitter = particleNode:CreateComponent("ParticleEmitter")
    particleEmitter:SetAutoRemoveMode(REMOVE_NODE)
    particleEmitter.effect = cache:GetResource("ParticleEffect", effectPath)
    particleEmitter.effect.updateInvisible = true
    coroutine.start(function()
        coroutine.sleep(particleEmitter.effect:GetMinTimeToLive())
        particleEmitter:SetEmitting(false)
    end)

    return particleEmitter
end


---@param from Vector2
---@param to Vector2
---@return number
function world.DistanceBetween(from, to)

    ---@type Vector2
    local subtractedVec = to - from

    return subtractedVec:Length()

end

function world.SaveScene(initial)
    local filename = ProjectFolderName
    if not initial then
        filename = ProjectFolderName .. "InGame"
    end

    Scene_:SaveXML(fileSystem:GetProgramDir() .. "Data/Scenes/" .. filename .. ".xml")
end

return world