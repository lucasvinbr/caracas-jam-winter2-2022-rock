local uiManager = require "LuaScripts/ui/UI_Manager"
local gameAudio = require "LuaScripts/Audio"

local world = {}

---@type StaticSprite2D
world.fadeSprite = nil

world.DoneSettingUp = false

---@type Player[]
world.PlayerScripts = {}

---@type Node
world.DynamicContentParent = nil

---@type Vector2
world.BOUNDS_CENTER = Vector2(0.0, -2.5)

--- assuming world is a square
world.BOUNDS_UNSCALED = Vector2(13.5, 5.8)

world.WORLD_SCALE = Vector2(3.5, 4.0)


function world.CreateDynamicContent()

    CurGameState = GAMESTATE_STARTING

    world.DynamicContentParent = Scene_:CreateChild("DynamicContent")

    -- Create player character and the input handler
    local playerChar = world.CreateCharacter(Vector2.ZERO)
    playerChar.node:CreateScriptObject("PlayerController")
    playerChar:SetupColor(PLAYER_COLORS[1])

    -- create more chars!
    for i = 2, 4, 1 do
        local aiChar = world.CreateCharacter(Vector2.ONE)
        aiChar:SetupColor(PLAYER_COLORS[i])
        aiChar.node:CreateScriptObject("PlayerAI")
    end

end

function world.CreateBoundaries()
    local boundariesParent = Scene_:CreateChild("boundaries")

    -- create level boundaries based on world bounds constants and scale
    local boundaryThickness = 8
    local rightBoundary = Scene_:CreateChild("bRight")
    local boundaryRigid = rightBoundary:CreateComponent("RigidBody2D")
    boundaryRigid.bodyType = BT_STATIC

    local boundaryShape = rightBoundary:CreateComponent("CollisionBox2D")
    boundaryShape:SetCategoryBits(COLMASK_WORLD)
    boundaryShape:SetSize(2.0, 2.0)

    rightBoundary.position2D = world.BOUNDS_CENTER + Vector2(world.BOUNDS_UNSCALED.x + boundaryThickness, 0)
    rightBoundary:SetScale2D(Vector2(boundaryThickness, world.BOUNDS_UNSCALED.y * 2))

    local leftBoundary = rightBoundary:Clone()
    leftBoundary.position2D = world.BOUNDS_CENTER + Vector2(-world.BOUNDS_UNSCALED.x - boundaryThickness, 0)
    leftBoundary:SetScale2D(Vector2(boundaryThickness, world.BOUNDS_UNSCALED.y * 2))

    local topBoundary = rightBoundary:Clone()
    topBoundary.position2D = world.BOUNDS_CENTER + Vector2(0, world.BOUNDS_UNSCALED.y + boundaryThickness)
    topBoundary:SetScale2D(Vector2(world.BOUNDS_UNSCALED.x * 2, boundaryThickness))

    local bottomBoundary = rightBoundary:Clone()
    bottomBoundary.position2D = world.BOUNDS_CENTER + Vector2(0, -world.BOUNDS_UNSCALED.y - boundaryThickness)
    bottomBoundary:SetScale2D(Vector2(world.BOUNDS_UNSCALED.x * 2, boundaryThickness))

    -- slight rotation of side boundaries to account for perspective
    rightBoundary:Rotate2D(30.0)
    leftBoundary:Rotate2D(-30.0)
    rightBoundary:Translate2D(Vector2(boundaryThickness / 3 , boundaryThickness / 2))
    leftBoundary:Translate2D(Vector2(-boundaryThickness / 3 , boundaryThickness / 2))
end


---@return Player @ the created player script
function world.CreateCharacter(position)

    local charNode = world.DynamicContentParent:CreateChild("PlayerNode")
    charNode:SetParent(world.DynamicContentParent)

    ---@type Player
    local playerScript = charNode:CreateScriptObject("Player")
    table.insert(world.PlayerScripts, playerScript)  -- Create a ScriptObject to handle character behavior


    return playerScript
end


---@param spawnPos Vector2
---@param isInFlippedWorld boolean
function world.CreateEnemy(spawnPos, isInFlippedWorld)

    local node = world.DynamicContentParent:CreateChild("Enemy")
    node.position2D = spawnPos

    return node
end


---@param winningPlayer Player
function world.EndGame(winningPlayer)
    if CurGameState ~= GAMESTATE_ENDED then
        CurGameState = GAMESTATE_ENDED

        uiManager.HideUI("Game")

        ---@type EndGameScreenData
        local gameEndData = {
            winningPlayer = winningPlayer
        }

        uiManager.ShowUI("Endgame", gameEndData)

    end
end

function world.Cleanup()
    if world.DynamicContentParent ~= nil then
        world.DynamicContentParent:Remove()
        world.DynamicContentParent = nil

        world.fadeSprite:SetColor(Color.TRANSPARENT_BLACK)
        world.PlayerScripts = {}
        
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

---@param point Vector2
function world.IsPointInsideWalkableArea(point)
    if point.x > world.BOUNDS_CENTER.x - world.BOUNDS_UNSCALED.x and point.x < world.BOUNDS_CENTER.x + world.BOUNDS_UNSCALED.x then
        if point.y > world.BOUNDS_CENTER.y - world.BOUNDS_UNSCALED.y and point.y < world.BOUNDS_CENTER.y + world.BOUNDS_UNSCALED.y then
            return true
        end
    end

    return false
end

function world.SaveScene(initial)
    local filename = ProjectFolderName
    if not initial then
        filename = ProjectFolderName .. "InGame"
    end

    Scene_:SaveXML(fileSystem:GetProgramDir() .. "Data/Scenes/" .. filename .. ".xml")
end

return world