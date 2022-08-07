local uiManager = require "LuaScripts/ui/UI_Manager"
local world = require "LuaScripts/World"
local gameAudio = require "LuaScripts/Audio"

---@class PlayerAI : LuaScriptObject
---@field playerScript Player

-- if someone's rocking progress percent is ahead of us but is below this threshold, don't worry
local SHOULD_ATTACK_OTHER_THRESHOLD = 0.4

local NEARBY_DISTANCE = 2.0

-- Character script object class
---@type PlayerAI
PlayerAI = ScriptObject()

PlayerAI.__index = PlayerAI


-- ai base procedure:
-- if no one is close to winning or I'm the closest, just rock away.
-- if someone else is closer than me, go and hit them!
-- if someone is nearby but I just want to rock, hit them

function PlayerAI:Start()
    self.playerScript = self.node:GetScriptObject("Player") --[[@as Player]]

    self.iWannaRock = true -- ROCK
    self.wantsToAttack = false
    self.moveDir = Vector2.ZERO
    self.moveDest = Vector2.ZERO
    self.attackTarget = nil

    coroutine.start(function()
        while self.node ~= nil do
            coroutine.sleep(0.7 + Random(0.05, 0.15))
            self:UpdateTargets()
        end
    end)
end

function PlayerAI:Update(timeStep)

    if CurGameState ~= GAMESTATE_PLAYING then
        return
    end

    self.wantsToAttack = false
    self.moveDir = Vector2.ZERO
    local curPos = self.node.position2D

    if self.attackTarget ~= nil then
        local targetPos = self.attackTarget.node.position2D
        -- the distance check in this case shouldn't be too strict in the y axis,
        -- and in the x axis, as long as we're close enough, it's ok

        if math.abs(curPos.x - targetPos.x) <= self.playerScript.charData.attackReach and
         math.abs(curPos.y - targetPos.y) <= 0.2 then
            -- we're close enough to attack, but keep moving towards the target to make sure we're facing the right direction
            self.moveDest = targetPos
            self.wantsToAttack = true
        end
    end

    if world.DistanceBetween(curPos, self.moveDest) > 0.4 then
        -- move towards moveDest
        self.moveDir = self.moveDest - curPos
        self.moveDir:Normalize()
    end

    self.playerScript:UpdateControls(self.moveDir, self.wantsToAttack)

end

--- returns a position at the sides of the target (whichever side is closest),
--- just close enough for our attacks to hit
---@param targetPosition Vector2
---@return Vector2
function PlayerAI:GetAttackPosition(targetPosition)
    if targetPosition.x - self.node.position2D.x > 0.0 then
        -- target is to our right.
        -- their left side should be closer to us
        return targetPosition + Vector2.LEFT * self.playerScript.charData.attackReach
    else
        return targetPosition + Vector2.RIGHT * self.playerScript.charData.attackReach
    end
end

function PlayerAI:UpdateTargets()
    local winningPlyr = nil
    local closestPlyr = nil
    local topRockingValue = 0.0
    local smallestPlyrDist = 1000

    self.attackTarget = nil
    self.iWannaRock = true
    self.moveDest = self.node.position2D

    for _, plyr in ipairs(world.PlayerScripts) do
        if plyr.rockingTime > topRockingValue then
            winningPlyr = plyr
            topRockingValue = plyr.rockingTime
        end

        local plyrDist = world.DistanceBetween(self.node.position2D, plyr.node.position2D)
        if plyr ~= self.playerScript and plyrDist < smallestPlyrDist then
            closestPlyr = plyr
            smallestPlyrDist = plyrDist
        end
    end

    if winningPlyr and winningPlyr:GetRockingProgressPercent() > SHOULD_ATTACK_OTHER_THRESHOLD and
        winningPlyr ~= self.playerScript then
        -- we should go beat them up!
        self.iWannaRock = false
        self.attackTarget = winningPlyr
        self.moveDest = self:GetAttackPosition(winningPlyr.node.position2D)
    end

    -- if someone is too close for comfort, hit them!
    if closestPlyr and smallestPlyrDist < NEARBY_DISTANCE then
        self.iWannaRock = false
        self.attackTarget = closestPlyr
        self.moveDest = self:GetAttackPosition(closestPlyr.node.position2D)
    end
end