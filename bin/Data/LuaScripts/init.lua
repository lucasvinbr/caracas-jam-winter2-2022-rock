GameDebug = require "LuaScripts/Debug"
local uiManager = require "LuaScripts/ui/UI_Manager"
local uiDefs = require "LuaScripts/ui/UI_Definitions"
local mouseConfig = require "LuaScripts/Mouse"
local world = require "LuaScripts/World"
local gameAudio = require "LuaScripts/Audio"
require "LuaScripts/Player"
require "LuaScripts/Watcher"


COLMASK_WORLD = 1
COLMASK_PLAYER = 2
COLMASK_OBJS = 4

SPRITELAYER_WORLD = 0
SPRITELAYER_PLAYER = 4

TAG_PLAYER = "player"
TAG_ENEMY = "enemy"
TAG_WIN_OBJ = "winnerobj"

GAMESTATE_ENDED = 1
GAMESTATE_STARTING = 2
GAMESTATE_PLAYING = 4
GAMESTATE_ENDING = 8

CurGameState = GAMESTATE_ENDED

ProjectFolderName = "rock"



---@type Scene
Scene_ = nil -- Scene

---@type Node
GameCameraNode = nil -- Camera scene node

---@type Camera
GameCamera = nil

function Start()
  SetRandomSeed(os.time() % 1000)
  -- Set custom window Title & Icon
  SetWindowTitleAndIcon()

  -- Execute debug stuff startup
  GameDebug.DebugSetup()

-- Create the scene content
  CreateScene()

-- Hook up to relevant events
  SubscribeToEvents()

  gameAudio.SetupSound()

  SetupUI()

  mouseConfig.SetupMouseEvents()
  mouseConfig.SetMouseMode(MM_FREE)

end


function SetupUI()
  -- Set up global UI style into the root UI element
  local style = cache:GetResource("XMLFile", "UI/DefaultStyle.xml")
  ui.root.defaultStyle = style

  uiManager.AddUiDefinitions(uiDefs)
  uiManager.ShowUI("MainMenu")
end

function SetWindowTitleAndIcon()
    local icon = cache:GetResource("Image", "Urho2D/duality/gameIcon.png")
    graphics:SetWindowIcon(icon)
    graphics.windowTitle = "Rock"
end

function CreateScene()
    ---@type Scene
    Scene_ = Scene()

    -- load base scene (already contains physics world, etc)
    -- local sceneXml = cache:GetResource("XMLFile", "Scenes/rock/game.xml")
    -- Scene_:LoadXML(sceneXml:GetRoot())

    Scene_:CreateComponent("Octree")
    Scene_:CreateComponent("DebugRenderer")
    Scene_:CreateComponent("PhysicsWorld2D")

    local scenarioNode = Scene_:CreateChild("scenario")
    local scenarioSprite = scenarioNode:CreateComponent("StaticSprite2D")
    scenarioSprite:SetSprite(cache:GetResource("Sprite2D", "Urho2D/rock/tela_05_palco.png"))
    scenarioSprite:SetLayer(SPRITELAYER_WORLD)
    scenarioNode:SetScale2D(world.WORLD_SCALE)

    world.CreateBoundaries()

    -- Create camera
    GameCameraNode = Node()
    GameCameraNode:SetPosition(Vector3(0.0, 0.0, -1.0))

    GameCamera = GameCameraNode:CreateComponent("Camera")
    GameCamera.orthographic = true

    log:Write(LOG_DEBUG, "got here?")
    -- Setup the viewport for displaying the scene
    renderer:SetViewport(0, Viewport:new(Scene_, GameCamera))
    --renderer.defaultZone.fogColor = Color(0.2, 0.2, 0.2) -- Set background color for the scene

end

function SetupGameMatch()

  world.Cleanup()

  world.CreateDynamicContent()

  -- Check when scene is rendered; we pause until the player presses "play"
  SubscribeToEvent("EndRendering", HandleSceneReady)

end


function SetupViewport()
  -- Set up a viewport to the Renderer subsystem so that the 3D scene can be seen
  local viewport = Viewport:new(Scene_, GameCameraNode:GetComponent("Camera"))
  renderer:SetViewport(0, viewport)
end

function SubscribeToEvents()

  -- Subscribe HandlePostRenderUpdate() function for processing the post-render update event, during which we request
  -- debug geometry
  SubscribeToEvent("PostRenderUpdate", HandlePostRenderUpdate)

end


function HandlePostRenderUpdate(eventType, eventData)
  -- If draw debug mode is enabled, draw physics debug geometry. Use depth test to make the result easier to interpret
  if GameDebug.drawDebug  then
    Scene_:GetComponent("PhysicsWorld2D"):DrawDebugGeometry(true)
  end
end

function HandleSceneReady()
  UnsubscribeFromEvent("EndRendering")
  if not world.DoneSettingUp then
    Scene_.updateEnabled = false -- Pause the scene if it's still being loaded
  end
end