---@class PlayerCharacterData
---@field attackDuration number
---@field attackTimeBeforeHit number
---@field attackReach number
---@field attackPushForce number
---@field attackDamage number
---@field attackStunTime number
---@field timeBeforeRocking number
---@field moveSpeed number
---@field animSpritePath string
---@field portraitSpritePath string
---@field name string
---@field voicePitch number
---@field themeSongPath string


---@type PlayerCharacterData[]
local charOptions = {
    {
        name = "Johnny",
        animSpritePath = "Urho2D/rock/johnny.scml",
        portraitSpritePath = "Urho2D/rock/portrait_johnny.png",
        moveSpeed = 40.0,
        attackDuration = 0.3,
        attackTimeBeforeHit = 0.15,
        attackReach = 4.5,
        attackDamage = 1.5,
        attackStunTime = 0.35,
        attackPushForce = 40,
        timeBeforeRocking = 2.0,
        voicePitch = 1.0
    }
}

return charOptions