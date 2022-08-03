local uiManager = require "LuaScripts/ui/UI_Manager"
local world = require "LuaScripts/World"
local gameAudio = require "LuaScripts/Audio"

---@class Player : LuaScriptObject
---@field timeBar ProgressBar

local JUMP_FORCE = 7.0
local MOVE_FORCE = 0.8
local INAIR_MOVE_FORCE = 0.02
local BRAKE_FORCE = 0.2
local MOVE_SPEED = 7.0
local VERTICAL_MOVESPEED_FACTOR = 0.8
local ATTACK_DURATION = 0.3
local ATTACK_TIME_BEFORE_HIT = 0.15


local TIME_BEFORE_ROCKING = 2.0

local PLAYERSTATE_IDLE = 0
local PLAYERSTATE_MOVING = 1
local PLAYERSTATE_ROCKING = 2
local PLAYERSTATE_ATTACKING = 3


-- Character script object class
---@type Player
Player = ScriptObject()

Player.__index = Player

function Player:Start()
    self.canCountTime = false
    self.canMove = true

    self.timeBar = nil

    self.curPlayerState = PLAYERSTATE_IDLE
    self.wantsToAttack = false
    self.actionTimeElapsed = 0.0

    self.timeSinceLastAttack = 1.0

    ---@type RigidBody2D
    self.body = self.node:CreateComponent("RigidBody2D")
    self.body:SetGravityScale(0.0)
    self.body.bodyType = BT_DYNAMIC
    self.body.allowSleep = false

    ---@type CollisionCircle2D
    self.colshape = self.node:CreateComponent("CollisionCircle2D")
    self.colshape.radius = 0.22 -- Set shape size
    self.colshape.friction = 0.0 -- Set friction
    self.colshape.restitution = 0.1 -- Slight bounce
    self.colshape:SetCategoryBits(COLMASK_PLAYER)

    self.spriteNode = self.node:CreateChild("playerSpriteNode")

    self.spriteNode:SetPosition2D(0, 0.4)

    self.animatedSprite = self.spriteNode:CreateComponent("AnimatedSprite2D")
    self.animatedSprite.animationSet = cache:GetResource("AnimationSet2D", "Urho2D/rock/player.scml")
    self.animatedSprite.animation = "idle"
    self.animatedSprite:SetLayer(SPRITELAYER_PLAYER)

    self.node:SetScale(4.5)
end

function Player:Update(timeStep)

    if CurGameState ~= GAMESTATE_PLAYING then
        return
    end

    self.actionTimeElapsed = self.actionTimeElapsed + timeStep
    self.timeSinceLastAttack = self.timeSinceLastAttack + timeStep

    local node = self.node

    -- Set direction
    ---@type Vector3
    local moveDir = Vector3.ZERO -- Reset
    local speedX = Clamp(MOVE_SPEED, 0.4, MOVE_SPEED)
    local speedY = speedX

    if input:GetKeyDown(KEY_LEFT) or input:GetKeyDown(KEY_A) then
        moveDir = moveDir + Vector3.LEFT * speedX
        self.animatedSprite.flipX = true -- Flip sprite (reset to default play on the X axis)
    end
    if input:GetKeyDown(KEY_RIGHT) or input:GetKeyDown(KEY_D) then
        moveDir = moveDir + Vector3.RIGHT * speedX
        self.animatedSprite.flipX = false -- Flip sprite (flip animation on the X axis)
    end

    if not moveDir:Equals(Vector3.ZERO) then
        speedY = speedX * VERTICAL_MOVESPEED_FACTOR
    end

    if input:GetKeyDown(KEY_UP) or input:GetKeyDown(KEY_W) then
        moveDir = moveDir + Vector3.UP * speedY
    end
    if input:GetKeyDown(KEY_DOWN) or input:GetKeyDown(KEY_S) then
        moveDir = moveDir + Vector3.DOWN * speedY
    end


    self.wantsToAttack = false
    if input:GetKeyPress(KEY_SPACE) then
        self.wantsToAttack = true
    end

    -- if not attacking, we can move
    if self.wantsToAttack and self:CanAttack() then
        self.actionTimeElapsed = 0.0
        self.timeSinceLastAttack = 0.0
        self.curPlayerState = PLAYERSTATE_ATTACKING
    end

    if self.curPlayerState ~= PLAYERSTATE_ATTACKING then
        if not moveDir:Equals(Vector3.ZERO) and self.canMove then
            node:Translate(moveDir * timeStep)
            self.actionTimeElapsed = 0.0
            self.curPlayerState = PLAYERSTATE_MOVING
        else
            self.curPlayerState = PLAYERSTATE_IDLE
            if self.actionTimeElapsed >= TIME_BEFORE_ROCKING then
                self.curPlayerState = PLAYERSTATE_ROCKING
            end
        end
    end


    if self.curPlayerState == PLAYERSTATE_ATTACKING then
        if self.actionTimeElapsed >= ATTACK_DURATION then
            self.curPlayerState = PLAYERSTATE_IDLE
        end
    end

    -- animation...
    if self.curPlayerState == PLAYERSTATE_ROCKING then
        self.animatedSprite:SetAnimation("rock")
    elseif self.curPlayerState == PLAYERSTATE_ATTACKING then
        self.animatedSprite:SetAnimation("attack")
    elseif self.curPlayerState == PLAYERSTATE_MOVING then
        self.animatedSprite:SetAnimation("idle")
    else
        self.animatedSprite:SetAnimation("idle")
    end

end

function Player:CanAttack()
    return self.timeSinceLastAttack >= ATTACK_DURATION
end

function Player:HandleCollisionStart(eventType, eventData)

    if CurGameState ~= GAMESTATE_PLAYING then return end

    local velocity = self.body.linearVelocity:Length()

    gameAudio.PlayOneShotSoundWithFrequency(hitSounds[RandomInt(#hitSounds) + 1],
     1.0,
      20050 + Lerp(0, 20000, velocity / 20.0),
       true,
        self.node)
end
