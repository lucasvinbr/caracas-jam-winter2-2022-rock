local world = require "LuaScripts/World"
local gameAudio = require "LuaScripts/Audio"
local gameUi = require "LuaScripts/ui/screens/UI_Game"
local playerCharOptions = require "LuaScripts/Player_characters"

---@class Player : LuaScriptObject
---@field rockingBar ProgressBar
---@field body RigidBody2D
---@field colshape CollisionCircle2D
---@field spriteNode Node
---@field animatedSprite AnimatedSprite2D
---@field charData PlayerCharacterData
---@field playerColor Color
---@field playerArrowNode Node
---@field playerArrowSprite StaticSprite2D
---@field rockingTime number
---@field stunTime number @the amount of time the player should remain stunned

local PLAYERSTATE_IDLE = 0
local PLAYERSTATE_MOVING = 1
local PLAYERSTATE_ROCKING = 2
local PLAYERSTATE_ATTACKING = 3
local PLAYERSTATE_STUNNED = 4

local VERTICAL_MOVESPEED_FACTOR = 0.6
-- note: all player sprites should, by default, be looking to the right!

local hitSounds = {
    "Sounds/rock/hit_00.ogg",
    "Sounds/rock/hit_01.ogg",
    "Sounds/rock/hit_02.ogg",
    "Sounds/rock/hit_03.ogg",
    "Sounds/rock/hit_04.ogg",
}

local cheerSound = "Sounds/rock/yeah.ogg"

-- Character script object class
---@type Player
Player = ScriptObject() --[[@as Player]]

Player.__index = Player

function Player:Start()
    self.canCountTime = false
    self.canMove = true

    self.wantsToAttack = false
    self.moveDir = Vector2.ZERO

    self.curPlayerState = PLAYERSTATE_IDLE
    self.attackIsComplete = false

    self.stunTime = 0.0
    -- counter for mutually exclusive actions, like idling and attacking
    self.actionTimeElapsed = 0.0

    self.timeSinceLastAttack = 1.0

    self.rockingTime = 0.0

    self.charData = playerCharOptions[RandomInt(1,#playerCharOptions + 1)]
    self.body = self.node:CreateComponent("RigidBody2D")
    self.body:SetGravityScale(0.0)
    self.body:SetLinearDamping(5.0)
    self.body.bodyType = BT_DYNAMIC
    self.body.allowSleep = false

    self.colshape = self.node:CreateComponent("CollisionCircle2D")
    self.colshape.radius = 0.22 -- Set shape size
    self.colshape.friction = 0.5 -- Set friction
    self.colshape.restitution = 0.1 -- Slight bounce
    self.colshape:SetCategoryBits(COLMASK_PLAYER)
    self.colshape:SetMaskBits(COLMASK_WORLD + COLMASK_PLAYER)

    self.spriteNode = self.node:CreateChild("playerSpriteNode")
    self.spriteNode:SetPosition2D(0, 0.4)

    self.animatedSprite = self.spriteNode:CreateComponent("AnimatedSprite2D")
    self.animatedSprite.animationSet = cache:GetResource("AnimationSet2D", self.charData.animSpritePath)
    self.animatedSprite.animation = "idle"
    self.animatedSprite:SetLayer(SPRITELAYER_PLAYER)

    self.spriteNode:SetScale(self.charData.spriteScaling)

    self.playerArrowNode = self.spriteNode:CreateChild("playerArrowNode")
    self.playerArrowNode:SetPosition2D(0, 0.7 / self.charData.spriteScaling)
    self.playerArrowSprite = self.playerArrowNode:CreateComponent("StaticSprite2D")
    self.playerArrowSprite:SetSprite(cache:GetResource("Sprite2D", "Urho2D/rock/playerTriangle.png"))
    self.playerArrowSprite:SetLayer(SPRITELAYER_PLAYER_ARROW)
    self.playerArrowNode:SetWorldScale2D(Vector2.ONE * 0.75)

    self.node:SetScale(4.0)

end

function Player:DelayedStart()
    self.rockingBar = gameUi.SetupPlayer(self.charData, self.playerColor)
    self.playerArrowSprite:SetColor(self.playerColor)
end

function Player:SetupColor(playerColor)
    self.playerColor = playerColor
end

function Player:UpdateControls(moveDir, wantsToAttack)
    self.moveDir = moveDir
    self.wantsToAttack = wantsToAttack
end


function Player:Update(timeStep)

    if CurGameState ~= GAMESTATE_PLAYING then
        return
    end

    self.actionTimeElapsed = self.actionTimeElapsed + timeStep
    self.timeSinceLastAttack = self.timeSinceLastAttack + timeStep

    local node = self.node

    -- Set direction
    local speedX = self.charData.moveSpeed

    if self.moveDir ~= Vector2.ZERO then
        self.animatedSprite.flipX = self.moveDir.x < 0.0
        self.moveDir = Vector2(self.moveDir.x * speedX, self.moveDir.y * speedX * VERTICAL_MOVESPEED_FACTOR)
    end

    if self.curPlayerState == PLAYERSTATE_STUNNED then
        if self.actionTimeElapsed >= self.stunTime then
            self.curPlayerState = PLAYERSTATE_IDLE
            self.actionTimeElapsed = 0.0
        end
    end

    -- if not attacking, we can move
    if self.wantsToAttack and self:CanAttack() then
        self.actionTimeElapsed = 0.0
        self.timeSinceLastAttack = 0.0
        self.curPlayerState = PLAYERSTATE_ATTACKING
    end

    if self:CanMove() then
        if not self.moveDir:Equals(Vector2.ZERO) then
            -- node:Translate2D(self.moveDir * timeStep)
            self.body:ApplyForceToCenter(self.moveDir, true)
            self.actionTimeElapsed = 0.0
            self.curPlayerState = PLAYERSTATE_MOVING
        else
            self.curPlayerState = PLAYERSTATE_IDLE
            if self.actionTimeElapsed >= self.charData.timeBeforeRocking then
                self.curPlayerState = PLAYERSTATE_ROCKING
                self.rockingTime = self.rockingTime + timeStep
                -- update rocking bar
                self.rockingBar:SetValue(self.rockingTime / ROCKING_TIME_TO_WIN)

                if self.rockingTime >= ROCKING_TIME_TO_WIN then
                    world.EndGame(self)
                    return
                end
            end
        end
    end

    if self.curPlayerState == PLAYERSTATE_ATTACKING then
        if self.actionTimeElapsed >= self.charData.attackDuration then
            self.curPlayerState = PLAYERSTATE_IDLE
            self.attackIsComplete = false
        elseif self.actionTimeElapsed >= self.charData.attackTimeBeforeHit and not self.attackIsComplete then
            self.attackIsComplete = true

            -- apply actual attack calculations/effects!
            -- log:Write(LOG_DEBUG, "attack goes here!")
            local attackDir = Vector2.RIGHT
            if self.animatedSprite.flipX then
               attackDir = Vector2.LEFT
            end

            for i, rayResult in ipairs(Scene_:GetComponent("PhysicsWorld2D"):
              Raycast(node.position2D, node.position2D + attackDir * self.charData.attackReach, COLMASK_PLAYER)) do
                if rayResult.body == self.body then
                    log:Write(LOG_DEBUG, "we've hit ourselves!")
                else
                    -- log:Write(LOG_DEBUG, "we've hit someone else!")
                    local enemyPlayerScript = rayResult.body:GetNode():GetScriptObject("Player") --[[@as Player]]
                    if enemyPlayerScript then
                        enemyPlayerScript:BeAttacked(attackDir * self.charData.attackPushForce, self.charData.attackDamage, self.charData.attackStunTime)
                    end
                end
            end
        end
    end

    self.animatedSprite:SetOrderInLayer(math.floor((world.BOUNDS_UNSCALED.y * 2) - self.node.position2D.y))

    -- animation...
    if self.curPlayerState == PLAYERSTATE_ROCKING then
        self.animatedSprite:SetAnimation("rock")
    elseif self.curPlayerState == PLAYERSTATE_ATTACKING then
        self.animatedSprite:SetAnimation("attack")
    elseif self.curPlayerState == PLAYERSTATE_MOVING then
        self.animatedSprite:SetAnimation("walk")
    elseif self.curPlayerState == PLAYERSTATE_STUNNED then
        self.animatedSprite:SetAnimation("stunned")
    else
        self.animatedSprite:SetAnimation("idle")
    end


    -- reset controls
    self.moveDir = Vector2.ZERO
    self.wantsToAttack = false
end

function Player:CanAttack()
    return self.curPlayerState ~= PLAYERSTATE_STUNNED and self.timeSinceLastAttack >= self.charData.attackDuration
end

function Player:CanMove()
    return self.curPlayerState ~= PLAYERSTATE_STUNNED and self.curPlayerState ~= PLAYERSTATE_ATTACKING
end

function Player:GetRockingProgressPercent()
    return self.rockingTime / ROCKING_TIME_TO_WIN
end

--- attacks push the attacked player around, makes them stop rocking and reduces their rock bar, preventing them from winning the game
---@param pushForce Vector2
---@param rockbarDamage number
---@param stunTime number
function Player:BeAttacked(pushForce, rockbarDamage, stunTime)
    if CurGameState ~= GAMESTATE_PLAYING then return end

    self.body:ApplyLinearImpulseToCenter(pushForce, true)
    self.rockingTime = math.max(0.0, self.rockingTime - rockbarDamage)
    self.curPlayerState = PLAYERSTATE_STUNNED
    self.stunTime = stunTime
    self.actionTimeElapsed = 0.0

    self.rockingBar:SetValue(self.rockingTime / ROCKING_TIME_TO_WIN)

    local voiceFrequency = 22050 * self.charData.voicePitch + Random(-1000, 1000)
    gameAudio.PlayOneShotSoundWithFrequency(hitSounds[RandomInt(1, #hitSounds + 1)], 0.7, voiceFrequency)
end

function Player:ForceAnim(animName)
    self.animatedSprite:SetAnimation(animName)
end

function Player:PlayVictorySound()
    local voiceFrequency = 22050 * self.charData.voicePitch + Random(-1000, 1000)
    gameAudio.PlayOneShotSoundWithFrequency(cheerSound, 1.0, voiceFrequency)

    gameAudio.StartMusic(self.charData.themeSongPath)
end