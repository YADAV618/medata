local BRPlayerCharacterBase = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {},
  LuaEventContainer = {}
}
BRPlayerCharacterBase.ServerRPC.ServerRPC_NearDeathGiveupRescue = {
  Reliable = true,
  Params = {}
}
BRPlayerCharacterBase.ServerRPC.ServerRPC_CarryDeadBox = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Object
  }
}
BRPlayerCharacterBase.ServerRPC.RPC_Server_GmPlayAction = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
BRPlayerCharacterBase.MulticastRPC.MulticastRPC_GmPlayAction = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
BRPlayerCharacterBase.ClientRPC.RPC_Client_SetShouldCheckPassWall = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Bool
  }
}
local ENetRole = import("ENetRole")
local EPawnState = import("EPawnState")
local ESpecialMovementType = import("ESpecialMovementType")
local ESpiderSwingMoveState = import("ESpiderSwingMoveState")
local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
local EParachuteState = import("EParachuteState")
local EMovementMode = import("EMovementMode")
local EStateType = import("EStateType")
local ESTEPoseState = import("ESTEPoseState")
local EGameModeType = import("EGameModeType")
local STExtraGameStateBase = import("STExtraGameStateBase")
local UKismetSystemLibrary = import("KismetSystemLibrary")
local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local MatchModeIds = require("GameLua.Mod.BaseMod.GamePlay.Config.MatchModeIdsConfig")
-- MODIFIED BY BlackGamerOG
-- VIP MOD: ESP, CHAMS, WEAPON GLOW HDR, 165 FPS, IPAD VIEW, WHITE BODY, AIMBOT

-- Reset popup flags (before per-match guard so they always reset)
_G._SkinPopupShown = false
-- Don't reset _SkinPopupDone if already set (prevents re-show after match)
if not _G._SkinPopupSessionStarted then
    _G._SkinPopupDone = false
end

-- Per-match guard (prevents double-loading ESP/skin system)
do
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if _G._MOD_LOADED and _G._MOD_PC == pc then
        -- Script already loaded, but still allow popup to show
        -- Re-show popup via timer
        pcall(function()
            if pc and pc.AddGameTimer then
                pc:AddGameTimer(3, false, function()
                    pcall(function()
                        local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
                        local MainUI = InGameUITools.GetMainControlBaseUI()
                        if not MainUI or not Game:IsValid(MainUI) then return end
                        local canvas = nil
                        if MainUI.CanvasPanel_0 and Game:IsValid(MainUI.CanvasPanel_0) then canvas = MainUI.CanvasPanel_0
                        elseif MainUI.CanvasPanel_42 and Game:IsValid(MainUI.CanvasPanel_42) then canvas = MainUI.CanvasPanel_42 end
                        if not canvas then return end
                        if _G._SkinPopupShown or _G._SkinPopupDone then return end
                        _G._SkinPopupShown = true
                        _G._SkinPopupDone = true
                        _G._SkinPopupWidgets = {}
                        local pw, ph = 360, 200
                        local px, py = 960 - pw * 0.5, 540 - ph * 0.5
                        pcall(function()
                            if canvas and canvas.GetDesiredSize then
                                local sz = canvas:GetDesiredSize()
                                if sz and sz.X > 0 and sz.Y > 0 then
                                    px = sz.X * 0.5 - pw * 0.5
                                    py = sz.Y * 0.5 - ph * 0.5
                                end
                            end
                        end)
                        local function FL(x, y, w, h, color, z)
                            local b = CGame:NewObjectFromPath("/Script/UMG.Border", canvas)
                            if b and slua.isValid(b) then
                                pcall(function() b:SetBrushColor(color) end)
                                pcall(function() b:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
                                local slot = canvas:AddChildToCanvas(b)
                                if slot then slot:SetAutoSize(false) slot:SetPosition(FVector2D(x, y)) slot:SetSize(FVector2D(w, h)) slot:SetZOrder(z) end
                                table.insert(_G._SkinPopupWidgets, b)
                            end
                        end
                        local function FT(x, y, txt, size, color, z)
                            local t = CGame:NewObjectFromPath("/Script/UMG.TextBlock", canvas)
                            if t and slua.isValid(t) then
                                pcall(function() t:SetText(txt) end)
                                pcall(function() if FSlateColor then t:SetColorAndOpacity(FSlateColor(color)) else t:SetColorAndOpacity(color) end end)
                                pcall(function() if t.Font then local f = t.Font f.Size = size t.Font = f end end)
                                pcall(function() t:SetRenderTransformPivot(FVector2D(0.5, 0.5)) end)
                                pcall(function() t:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
                                local slot = canvas:AddChildToCanvas(t)
                                if slot then slot:SetAutoSize(true) slot:SetAlignment(FVector2D(0.5, 0.5)) slot:SetPosition(FVector2D(x, y)) slot:SetZOrder(z) end
                                table.insert(_G._SkinPopupWidgets, t)
                            end
                        end
                        local function FB(x, y, w, h, z, onClick)
                            local btn = CGame:NewObjectFromPath("/Script/UMG.Button", canvas)
                            if btn and slua.isValid(btn) then
                                pcall(function() btn:SetColorAndOpacity(FLinearColor(0,0,0,0)) end)
                                pcall(function() btn:SetBackgroundColor(FLinearColor(0,0,0,0)) end)
                                pcall(function() btn:SetWidgetVisibility(UEnums.ESlateVisibility.Visible) end)
                                local slot = canvas:AddChildToCanvas(btn)
                                if slot then slot:SetAutoSize(false) slot:SetPosition(FVector2D(x, y)) slot:SetSize(FVector2D(w, h)) slot:SetZOrder(z) end
                                if onClick and btn.OnClicked then
                                    btn.OnClicked:Add(function() pcall(onClick) end)
                                end
                                if onClick and btn.OnPressed then
                                    btn.OnPressed:Add(function() pcall(onClick) end)
                                end
                                table.insert(_G._SkinPopupWidgets, btn)
                            end
                        end
                        -- Build popup
                        FL(px-4, py-4, pw+8, ph+8, FLinearColor(0.25,0.19,0.0,1.0), 19998)
                        FL(px-2, py-2, pw+4, ph+4, FLinearColor(0.03,0.03,0.04,1.0), 19999)
                        FL(px, py, pw, ph, FLinearColor(0.04,0.035,0.05,0.98), 20000)
                        FL(px, py, pw, 50, FLinearColor(0.12,0.09,0.02,1.0), 20001)
                        FL(px+2, py+2, pw-4, 1, FLinearColor(0.85,0.68,0.0,1.0), 20002)
                        FL(px+2, py+ph-3, pw-4, 1, FLinearColor(0.85,0.68,0.0,1.0), 20002)
                        FT(px+pw*0.5, py+25, "VIP SKIN SYSTEM", 22, FLinearColor(1.0,0.84,0.08,1.0), 20010)
                        FT(px+pw*0.5, py+70, "Skin Enable Kar Na Hai Kya?", 18, FLinearColor(0.9,0.9,0.9,1.0), 20010)
                        FT(px+pw*0.5, py+95, "@YADAV524", 14, FLinearColor(0.85,0.68,0.0,0.8), 20010)
                        -- ON button
                        FL(px+30, py+120, 130, 50, FLinearColor(0.12,0.09,0.02,1.0), 20003)
                        FL(px+32, py+122, 126, 46, FLinearColor(0.85,0.68,0.0,0.15), 20004)
                        FT(px+95, py+145, "ON", 20, FLinearColor(1.0,0.84,0.08,1.0), 20005)
                        FB(px+30, py+120, 130, 50, 20050, function()
                            _G.LexusConfig = _G.LexusConfig or {}
                            _G.LexusConfig.ModSkin = true
                            _G.LexusConfig.ModEmote = true
                            _G.LexusConfig.SkinDeadBox = true
                            _G.LexusConfig.SkinAttachment = true
                            _G.LexusConfig.KillMessage = true
                            _G.LexusConfig.KillCountUI = true
                            _G.LexusConfig.SkinOptionOpen = true
                            _G.LexusConfig.SkinOpenLink = true
                            _G.LexusConfig.SkinEnable_Suit = true
                            _G.LexusConfig.SkinEnable_Top = true
                            _G.LexusConfig.SkinEnable_Gloves = true
                            _G.LexusConfig.SkinEnable_Bottom = true
                            _G.LexusConfig.SkinEnable_Shoes = true
                            _G.LexusConfig.SkinEnable_Bag = true
                            _G.LexusConfig.SkinEnable_Helmet = true
                            _G.LexusConfig.SkinEnable_Parachute = true
                            _G.LexusConfig.SkinEnable_M416 = true
                            _G.LexusConfig.SkinEnable_AKM = true
                            _G.LexusConfig.SkinEnable_SCAR = true
                            _G.LexusConfig.SkinEnable_M762 = true
                            _G.LexusConfig.SkinEnable_AUG = true
                            _G.LexusConfig.SkinEnable_UMP = true
                            _G.LexusConfig.SkinEnable_UZI = true
                            _G.LexusConfig.SkinEnable_Groza = true
                            _G.LexusConfig.SkinEnable_S12K = true
                            _G.LexusConfig.SkinEnable_DBS = true
                            _G.LexusConfig.SkinEnable_Dacia = true
                            _G.LexusConfig.SkinEnable_UAZ = true
                            _G.LexusConfig.SkinEnable_Coupe = true
                            _G.LexusConfig.SkinEnable_Buggy = true
                            _G.LexusConfig.SkinEnable_Mirado = true
                            _G.VIPConfig = _G.VIPConfig or {}
                            _G.VIPConfig.SKIN_ModSkin = true
                            _G.VIPConfig.SKIN_ModEmote = true
                            _G.VIPConfig.SKIN_DeadBox = true
                            _G.VIPConfig.SKIN_Attachment = true
                            _G.VIPConfig.SKIN_KillMsg = true
                            _G.VIPConfig.SKIN_KillCount = true
                            _G.AddOutfitLobbyRestored = false
                            _G._SkinPopupShown = false
                            _G._SkinPopupDone = true
                            if _G._SkinPopupWidgets then
                                for _, w in ipairs(_G._SkinPopupWidgets) do
                                    if w and slua.isValid(w) then pcall(function() w:RemoveFromParent() end) end
                                end
                            end
                            _G._SkinPopupWidgets = nil
                        end)
                        -- OFF button
                        FL(px+200, py+120, 130, 50, FLinearColor(0.06,0.02,0.02,1.0), 20003)
                        FL(px+202, py+122, 126, 46, FLinearColor(0.90,0.16,0.16,0.15), 20004)
                        FT(px+265, py+145, "OFF", 20, FLinearColor(0.90,0.16,0.16,1.0), 20005)
                        FB(px+200, py+120, 130, 50, 20050, function()
                            _G.LexusConfig = _G.LexusConfig or {}
                            _G.LexusConfig.ModSkin = false
                            _G.LexusConfig.ModEmote = false
                            _G.LexusConfig.SkinDeadBox = false
                            _G.LexusConfig.SkinAttachment = false
                            _G.LexusConfig.KillMessage = false
                            _G.LexusConfig.KillCountUI = false
                            _G.LexusConfig.SkinOptionOpen = false
                            _G.LexusConfig.SkinOpenLink = false
                            _G.LexusConfig.SkinEnable_Suit = false
                            _G.LexusConfig.SkinEnable_Top = false
                            _G.LexusConfig.SkinEnable_Gloves = false
                            _G.LexusConfig.SkinEnable_Bottom = false
                            _G.LexusConfig.SkinEnable_Shoes = false
                            _G.LexusConfig.SkinEnable_Bag = false
                            _G.LexusConfig.SkinEnable_Helmet = false
                            _G.LexusConfig.SkinEnable_Parachute = false
                            _G.LexusConfig.SkinEnable_M416 = false
                            _G.LexusConfig.SkinEnable_AKM = false
                            _G.LexusConfig.SkinEnable_SCAR = false
                            _G.LexusConfig.SkinEnable_M762 = false
                            _G.LexusConfig.SkinEnable_AUG = false
                            _G.LexusConfig.SkinEnable_UMP = false
                            _G.LexusConfig.SkinEnable_UZI = false
                            _G.LexusConfig.SkinEnable_Groza = false
                            _G.LexusConfig.SkinEnable_S12K = false
                            _G.LexusConfig.SkinEnable_DBS = false
                            _G.LexusConfig.SkinEnable_Dacia = false
                            _G.LexusConfig.SkinEnable_UAZ = false
                            _G.LexusConfig.SkinEnable_Coupe = false
                            _G.LexusConfig.SkinEnable_Buggy = false
                            _G.LexusConfig.SkinEnable_Mirado = false
                            _G.VIPConfig = _G.VIPConfig or {}
                            _G.VIPConfig.SKIN_ModSkin = false
                            _G.VIPConfig.SKIN_ModEmote = false
                            _G.VIPConfig.SKIN_DeadBox = false
                            _G.VIPConfig.SKIN_Attachment = false
                            _G.VIPConfig.SKIN_KillMsg = false
                            _G.VIPConfig.SKIN_KillCount = false
                            _G._SkinPopupShown = false
                            _G._SkinPopupDone = true
                            if _G._SkinPopupWidgets then
                                for _, w in ipairs(_G._SkinPopupWidgets) do
                                    if w and slua.isValid(w) then pcall(function() w:RemoveFromParent() end) end
                                end
                            end
                            _G._SkinPopupWidgets = nil
                        end)
                    end)
                end)
            end
        end)
        return
    end
    _G._MOD_LOADED = true
    _G._MOD_PC = pc
end

-- Initialize feature toggles with defaults
if not _G.Mod_ESP_Enabled then _G.Mod_ESP_Enabled = false end
if not _G.Mod_Chams_Enabled then _G.Mod_Chams_Enabled = false end
if not _G.Mod_WeaponGlow_Enabled then _G.Mod_WeaponGlow_Enabled = false end
_G.WeaponGlowColor = _G.WeaponGlowColor or 5
_G.WeaponGlowThickness = _G.WeaponGlowThickness or 3
if not _G.Mod_UnlockFPS_Enabled then _G.Mod_UnlockFPS_Enabled = false end
if not _G.Mod_IpadView_Enabled then _G.Mod_IpadView_Enabled = false end
if not _G.Mod_WhiteBody_Enabled then _G.Mod_WhiteBody_Enabled = false end
_G.IpadViewFOV = _G.IpadViewFOV or 120
_G.GraphicsUnlocked = false
_G.PrevWhiteBody = false
if not _G.Mod_CircleArrow_Enabled then _G.Mod_CircleArrow_Enabled = false end

-- ESP V2 sub-feature toggles
if not _G.Mod_ESP_ShowPlayerCount then _G.Mod_ESP_ShowPlayerCount = true end
if not _G.Mod_ESP_ShowName then _G.Mod_ESP_ShowName = true end
if not _G.Mod_ESP_ShowDistance then _G.Mod_ESP_ShowDistance = true end
if not _G.Mod_ESP_ShowHealthBar then _G.Mod_ESP_ShowHealthBar = true end
if not _G.Mod_ESP_ShowTeamColor then _G.Mod_ESP_ShowTeamColor = true end
if not _G.Mod_ESP_ShowWeaponIcon then _G.Mod_ESP_ShowWeaponIcon = true end
if not _G.Mod_ESP_ShowSnapline then _G.Mod_ESP_ShowSnapline = true end





-- Slider values for fine-tuning

local require = require
local import  = import
local isValid = slua.isValid
local pcall = pcall
local type = type
local pairs = pairs
local ipairs = ipairs
local tostring = tostring
local math = math
local string = string

local function nop() return true end
local function retFalse() return false end
local function retZero() return 0 end
local function retEmpty() return {} end
_G.CheatsEnabled = true

local function safe_require(path)
    local ok, mod = pcall(require, path)
    return ok and mod or nil
end

local ok_gd, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData")
if not ok_gd then GameplayData = nil end

local SecurityCommonUtils = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils")
local ASTExtraPlayerController = import("/Script/ShadowTrackerExtra.STExtraPlayerController")

-- ============================================================
-- CHAMS & AIMBOT VARIABLES
-- ============================================================
local FLinearColor = import("LinearColor")
local chamsTimer = nil
local processedPawns = {}
local tickCount = 0
local chamsReady = false
local colors = nil
local lastWeapon = nil

if FLinearColor then
    colors = {
        vis = FLinearColor(0, 500, 500, 1),       -- Ultra Bright Cyan
        occ = FLinearColor(500, 0, 500, 1),       -- Ultra Bright Purple
        bVis = FLinearColor(500, 500, 0, 1),      -- Ultra Bright Gold
        bOcc = FLinearColor(0, 250, 500, 1)       -- Ultra Bright Blue
    }
end

-- ============================================================
-- CHAMS FUNCTIONS
-- ============================================================
local function EnableChamsConsole()
    if chamsReady then return end
    pcall(function()
        local KSL = import("KismetSystemLibrary")
        local world = slua.getWorld()
        if not KSL or not world then return end
        
        KSL.ExecuteConsoleCommand(world, "r.EnableDrawDyeingColor 1")
        KSL.ExecuteConsoleCommand(world, "r.CustomDepth 3")
        KSL.ExecuteConsoleCommand(world, "r.IdeaOutline.Enable 1")
        KSL.ExecuteConsoleCommand(world, "r.Highlight.Enable 1")
        KSL.ExecuteConsoleCommand(world, "r.BloomQuality 5")
        KSL.ExecuteConsoleCommand(world, "r.DefaultFeature.Bloom 1")
        KSL.ExecuteConsoleCommand(world, "r.Bloom.Intensity 2.0")
        
        chamsReady = true
    end)
end

-- Disable chams: reset all processed meshes to normal
local function DisableChamsToMesh(mesh)
    if not mesh or not slua.isValid(mesh) then return end
    pcall(function()
        if mesh.SetDrawDyeing then mesh:SetDrawDyeing(false) end
        if mesh.SetDrawHighlight then mesh:SetDrawHighlight(false) end
        if mesh.SetDrawIdeaOutline then mesh:SetDrawIdeaOutline(false) end
        if mesh.SetIdeaOutlineNew then mesh:SetIdeaOutlineNew(false) end
        if mesh.SetIdeaOutlineOcclusionHighlight then mesh:SetIdeaOutlineOcclusionHighlight(false) end
        if mesh.SetIdeaOverrideOutlineAndOcclusion then mesh:SetIdeaOverrideOutlineAndOcclusion(false) end
        if mesh.SetRenderCustomDepth then mesh:SetRenderCustomDepth(false) end
    end)
end

local function DisableChams()
    pcall(function()
        -- Disable console commands
        local KSL = import("KismetSystemLibrary")
        local world = slua.getWorld()
        if KSL and world then
            KSL.ExecuteConsoleCommand(world, "r.EnableDrawDyeingColor 0")
            KSL.ExecuteConsoleCommand(world, "r.IdeaOutline.Enable 0")
            KSL.ExecuteConsoleCommand(world, "r.Highlight.Enable 0")
        end
        -- Reset all processed pawns
        local allChars = Game:GetAllPlayerPawns() or {}
        for _, pawn in pairs(allChars) do
            if slua.isValid(pawn) then
                if pawn.Mesh and slua.isValid(pawn.Mesh) then DisableChamsToMesh(pawn.Mesh) end
                local avatarComp = pawn.CharacterAvatarComp2_BP or (pawn.getAvatarComponent2 and pawn:getAvatarComponent2())
                if avatarComp and slua.isValid(avatarComp) and avatarComp.GetMeshCompBySlot then
                    for _, slot in ipairs({0,1,2,3,4,5,6,7}) do
                        local meshComp = avatarComp:GetMeshCompBySlot(slot)
                        if meshComp and slua.isValid(meshComp) then DisableChamsToMesh(meshComp) end
                    end
                end
                local weapon = pawn.GetCurrentWeapon and pawn:GetCurrentWeapon()
                if weapon and slua.isValid(weapon) and weapon.Mesh then DisableChamsToMesh(weapon.Mesh) end
            end
        end
        processedPawns = {}
        chamsReady = false
    end)
end

local function ApplyChamsToMesh(mesh, visColor, occColor)
    if not mesh or not slua.isValid(mesh) then return end
    pcall(function()
        mesh:SetDrawDyeing(true)
        mesh:SetDrawDyeingMode(1)
        mesh:SetVisibleDyeingColor(visColor)
        mesh:SetOccludedDyeingColor(occColor)
        mesh:SetDyeingColorFadeDistance(99999.0)
        mesh:SetDyeingColorMinMaxDistance(0.0, 99999.0)
        
        mesh:SetDrawHighlight(true)
        mesh:OverrideHighlightColor(visColor)
        mesh:SetHighlightCanBeOccluded(false)
        
        mesh:SetDrawIdeaOutline(true)
        mesh:SetIdeaOutlineNew(true)
        mesh:SetIdeaOutlineOcclusionHighlight(true)
        mesh:OverrideIdeaOutlineColor(visColor)
        mesh:SetIdeaOutlineOcclusionColor(occColor)
        mesh:OverrideIdeaOutlineThickness(8.0)
        mesh:SetIdeaOverrideOutlineAndOcclusion(true)
        
        mesh:SetRenderCustomDepth(true)
        mesh:SetCustomDepthStencilValue(255)
    end)
end

local function IsAlive_Chams(pawn) -- Renamed to avoid conflict with ESP's IsPawnAlive
    if not slua.isValid(pawn) then return false end
    local hp = pawn.Health
    if hp and hp > 0 then return true end
    local status = pawn.HealthStatus
    if status then return SecurityCommonUtils.IsHealthStatusAlive(status) end
    return false
end

local function ProcessEnemy_Chams(pawn, myTeamID)
    if not slua.isValid(pawn) or not IsAlive_Chams(pawn) then return false end
    local teamID = pawn.TeamID
    if not teamID or teamID <= 0 or teamID == myTeamID then return false end
    
    local isBot = false
    pcall(function() isBot = Game:IsAI(pawn) end)
    local visColor = isBot and colors.bVis or colors.vis
    local occColor = isBot and colors.bOcc or colors.occ
    
    if pawn.Mesh and slua.isValid(pawn.Mesh) then ApplyChamsToMesh(pawn.Mesh, visColor, occColor) end
    
    local avatarComp = pawn.CharacterAvatarComp2_BP or pawn:getAvatarComponent2()
    if avatarComp and slua.isValid(avatarComp) and avatarComp.GetMeshCompBySlot then
        for _, slot in ipairs({0, 1, 2, 3, 4, 5, 6, 7}) do
            local meshComp = avatarComp:GetMeshCompBySlot(slot)
            if meshComp and slua.isValid(meshComp) then ApplyChamsToMesh(meshComp, visColor, occColor) end
        end
    end
    
    local weapon = pawn:GetCurrentWeapon()
    if weapon and slua.isValid(weapon) and weapon.Mesh then ApplyChamsToMesh(weapon.Mesh, visColor, occColor) end
    
    local playerKey = pawn.PlayerKey
    if playerKey then processedPawns[playerKey] = true end
    return true
end

-- ========================================================================
-- âš¡ ESP V2 SYSTEM (RedBoxOverlay + PlayerMapMarker) - FIXED
-- ========================================================================
local PlayerMapMarker = {}
local RedBoxOverlay = {
    bActive = false,
    MainContainer = nil,
    WidgetSlot = nil,
    TextBlock = nil,
    Width = 340,
    Height = 54,
    OffsetY = 46,
    PlayerCount = 0,
    BotCount = 0,
    NearestDistance = 0,
    Layers = {},
    FontSize = 20,
    TextScaleValue = 1.15,
    _CachedText = "",
    _CachedPosVec = nil
}

function RedBoxOverlay.Create()
    if RedBoxOverlay.MainContainer and slua.isValid(RedBoxOverlay.MainContainer) then return true end

    local ParentCanvas = PlayerMapMarker.ESPCanvas
    if not ParentCanvas or not slua.isValid(ParentCanvas) then 
        if not PlayerMapMarker.InitESPCanvas() then return false end
        ParentCanvas = PlayerMapMarker.ESPCanvas
    end

    if not ParentCanvas or not slua.isValid(ParentCanvas) then return false end

    local Container = nil
    pcall(function() Container = CGame:NewObjectFromPath("/Script/UMG.CanvasPanel", ParentCanvas) end)
    if not Container or not slua.isValid(Container) then return false end

    local FLinearColor = import("LinearColor") or FLinearColor
    local FVector2D = import("Vector2D") or FVector2D
    
    -- Premium luxury bar - deep black glass with gold bevel, glow & shadow
    local CounterLayers = {
        -- Layer 0: Outer glow shadow (soft, large spread)
        {width = 348, height = 60, r = 0.0, g = 0.0, b = 0.0, a = 0.35, z = -2},
        -- Layer 1: Soft gold outer glow halo
        {width = 340, height = 54, r = 0.4, g = 0.3, b = 0.05, a = 0.3, z = -1},
        -- Layer 2: Bright gold bevel edge (thick premium border)
        {width = 334, height = 50, r = 0.85, g = 0.65, b = 0.1, a = 0.85, z = 0},
        -- Layer 3: Dark gold inner bevel (depth ring)
        {width = 330, height = 48, r = 0.45, g = 0.32, b = 0.02, a = 0.75, z = 1},
        -- Layer 4: Deep charcoal glass background
        {width = 324, height = 44, r = 0.03, g = 0.02, b = 0.01, a = 0.97, z = 2},
        -- Layer 5: Dark gold glass tint (warm subtle)
        {width = 318, height = 40, r = 0.08, g = 0.05, b = 0.01, a = 0.6, z = 3},
        -- Layer 6: Deep black center (pure dark glass)
        {width = 312, height = 36, r = 0.01, g = 0.01, b = 0.0, a = 0.9, z = 4},
        -- Layer 7: Inner warm glow border
        {width = 306, height = 32, r = 0.12, g = 0.08, b = 0.0, a = 0.4, z = 5},
        -- Layer 8: Gold top accent line (bright, sharp premium)
        {width = 290, height = 2, r = 1.0, g = 0.85, b = 0.2, a = 0.9, z = 6},
        -- Layer 9: Gold bottom accent line (dimmer, depth)
        {width = 290, height = 1.5, r = 0.75, g = 0.6, b = 0.12, a = 0.6, z = 7}
    }
    RedBoxOverlay.Layers = {}
    for _, layerConfig in ipairs(CounterLayers) do
        local border = nil
        pcall(function() border = CGame:NewObjectFromPath("/Script/UMG.Border", Container) end)
        if border and slua.isValid(border) then
            pcall(function()
                border:SetBrushColor(FLinearColor(layerConfig.r, layerConfig.g, layerConfig.b, layerConfig.a))
                border:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            end)
            local slot = Container:AddChildToCanvas(border)
            if slot then
                pcall(function()
                    slot:SetPosition(FVector2D((RedBoxOverlay.Width - layerConfig.width) * 0.5, (RedBoxOverlay.Height - layerConfig.height) * 0.5))
                    slot:SetSize(FVector2D(layerConfig.width, layerConfig.height))
                    slot:SetZOrder(layerConfig.z)
                end)
                table.insert(RedBoxOverlay.Layers, {Widget = border, Slot = slot})
            end
        end
    end

    local FSlateColor = import("SlateColor") or import("/Script/SlateCore.SlateColor")
    
    -- Text: Enemy: X | Bot: Y
    local txtBlock = nil
    pcall(function() txtBlock = CGame:NewObjectFromPath("/Script/UMG.TextBlock", Container) end)
    if txtBlock and slua.isValid(txtBlock) then
        pcall(function()
            local strText = string.format("Player: %d   Bot: %d", RedBoxOverlay.PlayerCount, RedBoxOverlay.BotCount)
            txtBlock:SetText(strText)
            RedBoxOverlay._CachedText = strText

            -- Premium luxury gold text on dark glass (high contrast, pops)
            local premiumTextColor = FLinearColor(1.0, 0.92, 0.4, 1.0)
            if FSlateColor then txtBlock:SetColorAndOpacity(FSlateColor(premiumTextColor)) else txtBlock:SetColorAndOpacity(premiumTextColor) end
            -- Full opacity for sharp premium text
            pcall(function() txtBlock:SetRenderOpacity(1.0) end)

            if txtBlock.Font then
                local font = txtBlock.Font
                font.Size = RedBoxOverlay.FontSize
                txtBlock.Font = font
            end
            txtBlock:SetRenderScale(FVector2D(RedBoxOverlay.TextScaleValue, RedBoxOverlay.TextScaleValue))
            txtBlock:SetRenderTransformPivot(FVector2D(0.5, 0.5))
            txtBlock:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        end)
        local txtSlot = Container:AddChildToCanvas(txtBlock)
        if txtSlot then
            pcall(function()
                txtSlot:SetAutoSize(true)
                txtSlot:SetAlignment(FVector2D(0.5, 0.5))
                txtSlot:SetPosition(FVector2D(RedBoxOverlay.Width * 0.5, RedBoxOverlay.Height * 0.5))
                txtSlot:SetZOrder(1000)
            end)
        end
        RedBoxOverlay.TextBlock = txtBlock
    end

    local MainSlot = nil
    pcall(function() MainSlot = ParentCanvas:AddChildToCanvas(Container) end)
    if not MainSlot then return false end

    RedBoxOverlay.MainContainer = Container
    RedBoxOverlay.WidgetSlot = MainSlot
    
    pcall(function()
        MainSlot:SetAutoSize(false)
        MainSlot:SetZOrder(999)
        MainSlot:SetAlignment(FVector2D(0.5, 0.0))
        MainSlot:SetSize(FVector2D(RedBoxOverlay.Width, RedBoxOverlay.Height))
    end)

    RedBoxOverlay.UpdatePosition()
    return true
end

function RedBoxOverlay.SetCounts(players, bots)
    local nearestMeters = 0
    pcall(function()
        local nearest = nil
        for _, data in pairs(PlayerMapMarker.ESPWidgets or {}) do
            local dist = tonumber(data and data.LastDistance)
            if dist and dist >= 0 then
                local meters = math.floor(dist / 100)
                if nearest == nil or meters < nearest then nearest = meters end
            end
        end
        nearestMeters = nearest or 0
    end)
    if RedBoxOverlay.PlayerCount == players and RedBoxOverlay.BotCount == bots and RedBoxOverlay.NearestDistance == nearestMeters then return end
    RedBoxOverlay.PlayerCount = players or 0
    RedBoxOverlay.BotCount = bots or 0
    RedBoxOverlay.NearestDistance = nearestMeters
    
    if RedBoxOverlay.TextBlock and slua.isValid(RedBoxOverlay.TextBlock) then
        pcall(function()
            local str = string.format("Player: %d   Bot: %d   Dist: %dm", RedBoxOverlay.PlayerCount, RedBoxOverlay.BotCount, RedBoxOverlay.NearestDistance)
            if RedBoxOverlay._CachedText ~= str then
                RedBoxOverlay.TextBlock:SetText(str)
                RedBoxOverlay._CachedText = str
            end
        end)
    end
end

function RedBoxOverlay.UpdatePosition()
    local Slot = RedBoxOverlay.WidgetSlot
    if not Slot or not slua.isValid(Slot) then return end
    local PC = PlayerMapMarker.GetMyPlayerController()
    if not slua.isValid(PC) then return end

    local fromX, fromY = PlayerMapMarker.GetSnapLineStartPos(PC)
    local FVector2D = import("Vector2D") or FVector2D
    pcall(function()
        if not RedBoxOverlay._CachedPosVec then
            RedBoxOverlay._CachedPosVec = FVector2D(fromX, fromY)
        else
            RedBoxOverlay._CachedPosVec.X = fromX
            RedBoxOverlay._CachedPosVec.Y = fromY
        end
        local counterPos = FVector2D(fromX, fromY - 30)
        if RedBoxOverlay._CachedPosVec then
            RedBoxOverlay._CachedPosVec.X = counterPos.X
            RedBoxOverlay._CachedPosVec.Y = counterPos.Y
        else
            RedBoxOverlay._CachedPosVec = counterPos
        end
        Slot:SetPosition(RedBoxOverlay._CachedPosVec)
        pcall(function()
            Slot:SetAlignment(FVector2D(0.5, 0.0))
            Slot:SetSize(FVector2D(RedBoxOverlay.Width, RedBoxOverlay.Height))
        end)
    end)
end

function RedBoxOverlay.Start()
    if RedBoxOverlay.bActive and RedBoxOverlay.MainContainer and slua.isValid(RedBoxOverlay.MainContainer) then return end
    if RedBoxOverlay.Create() then
        RedBoxOverlay.bActive = true
        pcall(function() RedBoxOverlay.MainContainer:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
    end
end

function RedBoxOverlay.Stop()
    RedBoxOverlay.bActive = false
    if RedBoxOverlay.MainContainer and slua.isValid(RedBoxOverlay.MainContainer) then
        pcall(function()
            RedBoxOverlay.MainContainer:RemoveFromParent()
            RedBoxOverlay.MainContainer:ConditionalBeginDestroy()
        end)
    end
    RedBoxOverlay.MainContainer = nil
    RedBoxOverlay.WidgetSlot = nil
    RedBoxOverlay.TextBlock = nil
    RedBoxOverlay.Layers = {}
    RedBoxOverlay.NearestDistance = 0
    RedBoxOverlay._CachedPosVec = nil
end

_G.RedBoxOverlay = RedBoxOverlay

-- ========================================================================
-- âš¡ ESP V2 SYSTEM (Continued) - FIXED
-- ========================================================================
local SlateBlueprintLibrary = nil
local WidgetLayoutLibrary = nil
local KismetMathLibrary_ESP9 = nil
local KismetSystemLibrary_ESP9 = nil

pcall(function() SlateBlueprintLibrary = import("SlateBlueprintLibrary") or import("/Script/UMG.SlateBlueprintLibrary") end)
pcall(function() WidgetLayoutLibrary = import("WidgetLayoutLibrary") or import("/Script/UMG.WidgetLayoutLibrary") end)
pcall(function() KismetMathLibrary_ESP9 = import("KismetMathLibrary") end)
pcall(function() KismetSystemLibrary_ESP9 = import("KismetSystemLibrary") end)

local FVector2D_ESP9 = _G.FVector2D or import("Vector2D")
local FLinearColor_ESP9 = _G.FLinearColor or import("LinearColor")
local FVector_ESP9 = _G.FVector or import("Vector")

PlayerMapMarker.MarkTypeID = 1007
PlayerMapMarker.bUseScreenESP = true
PlayerMapMarker.bUseScreenMark = false
PlayerMapMarker.bUseQuickSign = false
PlayerMapMarker.bUseNavigator = false
PlayerMapMarker.bUseWidgetComponent = false
PlayerMapMarker.ESPBoneName = "head"
PlayerMapMarker.ESPWorldOffsetZ = 0
PlayerMapMarker.ESPAnchorOffsetX = 35
PlayerMapMarker.ESPAnchorOffsetY = 0
PlayerMapMarker.ESPTextOffsetX = 0
PlayerMapMarker.ESPTextOffsetY = 0
PlayerMapMarker.ESPWidgetAlignment = FVector2D_ESP9 and FVector2D_ESP9(0.5, 1.0) or {X=0.5, Y=1.0}
PlayerMapMarker.ESPWidgetSize = FVector2D_ESP9 and FVector2D_ESP9(70, 21) or {X=70, Y=21}
PlayerMapMarker.ESPWidgetAutoSize = true
PlayerMapMarker.ESPWidgetZOrder = 2
PlayerMapMarker.bShowDistance = true
PlayerMapMarker.DistanceUnit = "m"
PlayerMapMarker.WeaponIconBrushW = 96
PlayerMapMarker.WeaponIconBrushH = 48
PlayerMapMarker.HPWidgetSwitcherTypeIndex = 0
PlayerMapMarker.HPWidgetSwitcherType2Index = 0
PlayerMapMarker.bForceSwitcherIndexEveryUpdate = true
PlayerMapMarker.bUseSnapLines = true
PlayerMapMarker.SnapLineThickness = 3.0
PlayerMapMarker.SnapLineOriginY = 50
PlayerMapMarker.SnapLineOriginOffsetX = 0
PlayerMapMarker.SnapLineHeadOffsetX = 0
PlayerMapMarker.SnapLineHeadOffsetY = -14
PlayerMapMarker.SnapLineColor = FLinearColor_ESP9 and FLinearColor_ESP9(1.0, 0.85, 0.0, 1.0) or {R=255, G=217, B=0, A=255}
PlayerMapMarker.SnapLineOpacity = 0.9

PlayerMapMarker.SkeletonThickness = 0.8
PlayerMapMarker.SkeletonColor = nil
PlayerMapMarker.SkeletonOpacity = 0.8
PlayerMapMarker.SkeletonMaxDistance = 100000
PlayerMapMarker.bUseVisibilityColor = true
PlayerMapMarker.SkeletonVisibleColor = FLinearColor_ESP9 and FLinearColor_ESP9(1.0, 0.85, 0.0, 0.8) or {R=255,G=217,B=0,A=200}
PlayerMapMarker.SkeletonCoverColor = FLinearColor_ESP9 and FLinearColor_ESP9(0.9, 0.0, 0.0, 0.6) or {R=230,G=0,B=0,A=150}
PlayerMapMarker.SkeletonWidgets = {}
PlayerMapMarker._StaticBoneLocCache = {}
PlayerMapMarker.SkeletonChains = {
    {"neck_01", "lowerarm_r", "hand_r"},
    {"neck_01", "lowerarm_l", "hand_l"},
    {"head", "neck_01", "pelvis"},
    {"pelvis", "calf_r", "foot_r"},
    {"pelvis", "calf_l", "foot_l"}
}
PlayerMapMarker.BoneNameFallbacks = {
    ["head"] = {"head", "Head", "head_socket"},
    ["neck_01"] = {"neck_01", "Neck_01", "neck", "Neck"},
    ["clavicle_r"] = {"clavicle_r", "Clavicle_R", "clavicle_R"},
    ["upperarm_r"] = {"upperarm_r", "UpperArm_R", "arm_r", "arm_r_01"},
    ["lowerarm_r"] = {"lowerarm_r", "LowerArm_R", "forearm_r"},
    ["hand_r"] = {"hand_r", "Hand_R", "hand_r_socket"},
    ["clavicle_l"] = {"clavicle_l", "Clavicle_L", "clavicle_L"},
    ["upperarm_l"] = {"upperarm_l", "UpperArm_L", "arm_l", "arm_l_01"},
    ["lowerarm_l"] = {"lowerarm_l", "LowerArm_L", "forearm_l"},
    ["hand_l"] = {"hand_l", "Hand_L", "hand_l_socket"},
    ["spine_03"] = {"spine_03", "Spine_03", "spine_02", "spine"},
    ["spine_02"] = {"spine_02", "Spine_02", "spine_01"},
    ["pelvis"] = {"pelvis", "Pelvis", "hip"},
    ["thigh_r"] = {"thigh_r", "Thigh_R", "leg_r"},
    ["calf_r"] = {"calf_r", "Calf_R", "shin_r"},
    ["foot_r"] = {"foot_r", "Foot_R", "foot_r_socket"},
    ["thigh_l"] = {"thigh_l", "Thigh_L", "leg_l"},
    ["calf_l"] = {"calf_l", "Calf_L", "shin_l"},
    ["foot_l"] = {"foot_l", "Foot_L", "foot_l_socket"},
}

PlayerMapMarker.MapAddedFlag = 4
PlayerMapMarker.nUpdateInterval = 0.5
PlayerMapMarker.bUseFrameTick = false
PlayerMapMarker.nHeavyScanFrameInterval = 15
PlayerMapMarker.nDistanceUpdateFrameInterval = 5
PlayerMapMarker.bIncludeMe = false
PlayerMapMarker.bIncludeAI = true
PlayerMapMarker.bUseServerMarks = false
PlayerMapMarker.bActive = false
PlayerMapMarker.MarkMap = {}
PlayerMapMarker.PlayerInfo = {}
PlayerMapMarker.ESPCanvas = nil
PlayerMapMarker.ESPWidgets = {}
PlayerMapMarker.ESPWidgetPtrs = {}
PlayerMapMarker.SnapLineWidgets = {}
PlayerMapMarker._cachedViewportW = 1920
PlayerMapMarker._cachedViewportH = 1080
PlayerMapMarker._FrameCount = 0
PlayerMapMarker._bTickRegistered = false
PlayerMapMarker._CachedAllChars = nil
PlayerMapMarker._CachedMyLoc = nil
PlayerMapMarker._CachedMyKey = nil
PlayerMapMarker.WidgetComps = {}
PlayerMapMarker._bAllPathsFailed = false
PlayerMapMarker._bLightUpdateScheduled = false
PlayerMapMarker._LightUpdateInterval = 0.02
PlayerMapMarker._bDistanceUpdateScheduled = false
PlayerMapMarker._DistanceUpdateInterval = 0.1
PlayerMapMarker._bScreenMarkConfigSetup = false

local function IsValid_ESP9(obj)
    if obj == nil then return false end
    if slua and slua.isValid then return slua.isValid(obj) end
    return obj ~= nil
end

function PlayerMapMarker.GetGameplayData()
    if PlayerMapMarker._CachedGameplayData then return PlayerMapMarker._CachedGameplayData end
    local ok, GDP = pcall(function() return require("GameLua.GameCore.Data.GameplayData") end)
    if ok and GDP then PlayerMapMarker._CachedGameplayData = GDP return GDP end
    return nil
end

function PlayerMapMarker.GetMyPlayerController()
    local PC = PlayerMapMarker._CachedPC
    if PC and IsValid_ESP9(PC) then return PC end
    local GDP = PlayerMapMarker.GetGameplayData()
    if not GDP then return nil end
    pcall(function() PC = GDP.GetPlayerController and GDP.GetPlayerController() end)
    if PC and IsValid_ESP9(PC) then PlayerMapMarker._CachedPC = PC return PC end
    return nil
end

function PlayerMapMarker.GetCGameState()
    if CGameState and IsValid_ESP9(CGameState) then return CGameState end
    if PlayerMapMarker._CachedCGameState and IsValid_ESP9(PlayerMapMarker._CachedCGameState) then return PlayerMapMarker._CachedCGameState end
    local ok, GS = pcall(function() return require("GameLua.GameCore.Data.CGameState") end)
    if ok and GS then PlayerMapMarker._CachedCGameState = GS return GS end
    return nil
end

function PlayerMapMarker.GetAllCharacters()
    local AllChars = {}
    pcall(function()
        local Pawns = Game:GetAllPlayerPawns()
        if Pawns then
            for _, Pawn in pairs(Pawns) do
                if Pawn and slua.isValid(Pawn) then
                    local pKey = nil
                    if Pawn.GetPlayerKey then pKey = Pawn:GetPlayerKey() end
                    if not pKey and Pawn.PlayerKey then pKey = Pawn.PlayerKey end
                    if not pKey and Pawn.PlayerState and Pawn.PlayerState.PlayerKey then pKey = Pawn.PlayerState.PlayerKey end
                    if pKey then AllChars[pKey] = Pawn end
                end
            end
        end
    end)
    if not next(AllChars) then
        local GS = PlayerMapMarker.GetCGameState()
        if GS and GS.GetAllCharacters then pcall(function() AllChars = GS:GetAllCharacters() end) end
    end
    return AllChars
end

function PlayerMapMarker.GetMyPlayerKey()
    local PC = PlayerMapMarker.GetMyPlayerController()
    if not IsValid_ESP9(PC) then return nil end
    local MyKey = nil
    pcall(function()
        if PC.GetPlayerKey then MyKey = PC:GetPlayerKey()
        elseif PC.PlayerState and PC.PlayerState.PlayerKey then MyKey = PC.PlayerState.PlayerKey end
    end)
    return MyKey
end

function PlayerMapMarker.IsMe(Character, PlayerKey, MyKey)
    local bIsMe = false
    pcall(function()
        local GDP = PlayerMapMarker.GetGameplayData()
        if GDP and GDP.GetLocalCharacter then
            local MyChar = GDP.GetLocalCharacter()
            if MyChar and Character == MyChar then bIsMe = true return end
        end
        local PC = PlayerMapMarker.GetMyPlayerController()
        if PC and PC.GetPawn then
            local Pawn = PC:GetPawn()
            if Pawn and Character == Pawn then bIsMe = true return end
        end
    end)
    if not bIsMe and MyKey ~= nil and PlayerKey ~= nil then bIsMe = (tostring(PlayerKey) == tostring(MyKey)) end
    return bIsMe
end

function PlayerMapMarker.GetCharacterLocation(Character)
    if not IsValid_ESP9(Character) then return nil end
    local Loc = nil
    pcall(function() if Character.K2_GetActorLocation then Loc = Character:K2_GetActorLocation() end end)
    if not Loc then pcall(function() if Game and Game.GetActorLocation then Loc = Game:GetActorLocation(Character) end end) end
    return Loc
end

function PlayerMapMarker.CalcDistance(Loc1, Loc2)
    if not Loc1 or not Loc2 then return nil end
    local Dist = nil
    pcall(function() if FVector_ESP9 and FVector_ESP9.Dist2D then Dist = FVector_ESP9.Dist2D(Loc1, Loc2) end end)
    if not Dist then
        pcall(function()
            local DX = (Loc1.X or 0) - (Loc2.X or 0)
            local DY = (Loc1.Y or 0) - (Loc2.Y or 0)
            Dist = math.sqrt(DX * DX + DY * DY)
        end)
    end
    return Dist
end

function PlayerMapMarker.GetDistanceString(MyLoc, TargetLoc)
    if not PlayerMapMarker.bShowDistance then return "" end
    if not MyLoc or not TargetLoc then return "" end
    local Dist = PlayerMapMarker.CalcDistance(MyLoc, TargetLoc)
    if not Dist then return "" end
    local Meters = Dist / 100
    if Meters < 1000 then return string.format("%dm", math.floor(Meters))
    else return string.format("%.1fkm", Meters / 1000) end
end

function PlayerMapMarker.GetMyLocation()
    local GDP = PlayerMapMarker.GetGameplayData()
    if not GDP then return nil end
    local MyChar = nil
    pcall(function() MyChar = GDP.GetLocalCharacter and GDP.GetLocalCharacter() end)
    if not IsValid_ESP9(MyChar) then return nil end
    return PlayerMapMarker.GetCharacterLocation(MyChar)
end

function PlayerMapMarker.GetPlayerName(Character)
    if not IsValid_ESP9(Character) then return "Unknown" end
    local Name = nil
    pcall(function() if Character.GetPlayerNameSafety then Name = Character:GetPlayerNameSafety() end end)
    if not Name then
        pcall(function()
            local PS = nil
            if Character.GetPlayerStateSafety then PS = Character:GetPlayerStateSafety()
            elseif Character.GetPlayerState then PS = Character:GetPlayerState() end
            if IsValid_ESP9(PS) and PS.GetPlayerName then Name = PS:GetPlayerName() end
        end)
    end
    return Name or "Unknown"
end

function PlayerMapMarker.IsAI(Character)
    local bAI = false
    pcall(function() if Game and Game.IsAI then bAI = Game:IsAI(Character) end end)
    return bAI
end

function PlayerMapMarker.IsAlive(Character)
    local bAlive = true
    pcall(function() if Character.IsAlive then bAlive = Character:IsAlive() end end)
    return bAlive
end

function PlayerMapMarker.GetTeamID(Character)
    if not IsValid_ESP9(Character) then return nil end
    local TeamID = nil
    pcall(function() if Character.GetTeamID then TeamID = Character:GetTeamID() end end)
    if not TeamID then
        pcall(function()
            local PS = nil
            if Character.GetPlayerStateSafety then PS = Character:GetPlayerStateSafety()
            elseif Character.GetPlayerState then PS = Character:GetPlayerState() end
            if IsValid_ESP9(PS) and PS.GetTeamID then TeamID = PS:GetTeamID()
            elseif IsValid_ESP9(PS) and PS.TeamID then TeamID = PS.TeamID end
        end)
    end
    if not TeamID then pcall(function() if Character.TeamID then TeamID = Character.TeamID end end) end
    return TeamID
end

function PlayerMapMarker.GetTeamColor(TeamID)
    if TeamID == nil or TeamID == 0 then
        return FLinearColor_ESP9 and FLinearColor_ESP9(0.2, 0.4, 1.0, 1.0) or {R=50,G=100,B=255,A=255}
    end
    local TeamColors = {
        [1]={R=255,G=50,B=50,A=255,fR=1.0,fG=0.2,fB=0.2},
        [2]={R=50,G=255,B=50,A=255,fR=0.2,fG=1.0,fB=0.2},
        [3]={R=50,G=100,B=255,A=255,fR=0.2,fG=0.4,fB=1.0},
        [4]={R=255,G=255,B=50,A=255,fR=1.0,fG=1.0,fB=0.2},
        [5]={R=255,G=50,B=255,A=255,fR=1.0,fG=0.2,fB=1.0},
        [6]={R=50,G=255,B=255,A=255,fR=0.2,fG=1.0,fB=1.0},
        [7]={R=255,G=150,B=50,A=255,fR=1.0,fG=0.6,fB=0.2},
        [8]={R=150,G=50,B=255,A=255,fR=0.6,fG=0.2,fB=1.0},
        [9]={R=200,G=255,B=50,A=255,fR=0.8,fG=1.0,fB=0.2},
        [10]={R=50,G=150,B=255,A=255,fR=0.2,fG=0.6,fB=1.0},
        [11]={R=255,G=100,B=150,A=255,fR=1.0,fG=0.4,fB=0.6},
        [12]={R=100,G=255,B=150,A=255,fR=0.4,fG=1.0,fB=0.6},
        [13]={R=150,G=150,B=50,A=255,fR=0.6,fG=0.6,fB=0.2},
        [14]={R=50,G=200,B=150,A=255,fR=0.2,fG=0.8,fB=0.6},
        [15]={R=255,G=200,B=50,A=255,fR=1.0,fG=0.8,fB=0.2}
    }
    local colorIndex = (TeamID % 15)
    if colorIndex == 0 then colorIndex = 15 end
    local c = TeamColors[colorIndex]
    return FLinearColor_ESP9 and FLinearColor_ESP9(c.fR, c.fG, c.fB, 1.0) or {R=c.R, G=c.G, B=c.B, A=c.A}
end

function PlayerMapMarker.InitESPCanvas()
    if PlayerMapMarker.ESPCanvas and Game:IsValid(PlayerMapMarker.ESPCanvas) then return true end
    local InGameUITools = nil
    pcall(function() InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools") end)
    if not InGameUITools then return false end
    local MainControlBaseUI = nil
    pcall(function() MainControlBaseUI = InGameUITools.GetMainControlBaseUI() end)
    if not MainControlBaseUI or not Game:IsValid(MainControlBaseUI) then return false end
    local ParentCanvas = nil
    pcall(function()
        if MainControlBaseUI.CanvasPanel_0 and Game:IsValid(MainControlBaseUI.CanvasPanel_0) then ParentCanvas = MainControlBaseUI.CanvasPanel_0
        elseif MainControlBaseUI.CanvasPanel_42 and Game:IsValid(MainControlBaseUI.CanvasPanel_42) then ParentCanvas = MainControlBaseUI.CanvasPanel_42 end
    end)
    if not ParentCanvas then return false end
    PlayerMapMarker.ESPCanvas = ParentCanvas
    return true
end

function PlayerMapMarker.GetESPLocation(Character)
    if not IsValid_ESP9(Character) then return nil end
    local BoneLoc = PlayerMapMarker.GetCharacterLocation(Character)
    if BoneLoc then
        local heightOffset = 85
        pcall(function()
            if Character.bIsCrouched then heightOffset = 60 end
            if Character.IsProne and Character:IsProne() then heightOffset = 30 end
        end)
        pcall(function() BoneLoc.Z = BoneLoc.Z + heightOffset + (PlayerMapMarker.ESPWorldOffsetZ or 0) end)
    end
    return BoneLoc
end

function PlayerMapMarker.GetCharacterWeaponInfo(Character)
    if not IsValid_ESP9(Character) then return nil end
    local WeaponID, WeaponName, WeaponIconPath, WeaponIconTexture, CurrentWeapon = nil, nil, nil, nil, nil
    pcall(function() if Character.GetCurrentWeapon then CurrentWeapon = Character:GetCurrentWeapon() end end)
    if not CurrentWeapon then pcall(function() CurrentWeapon = Character.CurrentWeapon end) end
    if not CurrentWeapon then pcall(function() if Character.GetWeaponManager then local WM = Character:GetWeaponManager() if WM and WM.GetCurrentWeapon then CurrentWeapon = WM:GetCurrentWeapon() end end end) end
    if CurrentWeapon and IsValid_ESP9(CurrentWeapon) then
        pcall(function() if CurrentWeapon.GetWeaponID then WeaponID = CurrentWeapon:GetWeaponID() end end)
        if not WeaponID then pcall(function() WeaponID = CurrentWeapon.WeaponID end) end
        if not WeaponID then pcall(function() if CurrentWeapon.GetItemID then WeaponID = CurrentWeapon:GetItemID() end end) end
        pcall(function() if CurrentWeapon.GetWeaponName then WeaponName = CurrentWeapon:GetWeaponName() end end)
        pcall(function() if CurrentWeapon.GetWeaponIconPath then WeaponIconPath = CurrentWeapon:GetWeaponIconPath() end end)
        pcall(function() if CurrentWeapon.GetWeaponIcon then WeaponIconTexture = CurrentWeapon:GetWeaponIcon() end end)
    end
    if not WeaponID then
        pcall(function()
            local PS = nil
            if Character.GetPlayerStateSafety then PS = Character:GetPlayerStateSafety() elseif Character.GetPlayerState then PS = Character:GetPlayerState() end
            if PS and IsValid_ESP9(PS) then
                if PS.GetCurrentWeaponID then WeaponID = PS:GetCurrentWeaponID() end
                if not WeaponID and PS.CurWeaponID then WeaponID = PS.CurWeaponID end
            end
        end)
    end
    return { WeaponID = WeaponID, WeaponName = WeaponName, WeaponIconPath = WeaponIconPath, WeaponIconTexture = WeaponIconTexture, CurrentWeapon = CurrentWeapon }
end

PlayerMapMarker._OBHeadWidgetClass = nil
PlayerMapMarker._OBHeadWidgetLoadFailed = false

function PlayerMapMarker.CreateESPWidget()
    if not PlayerMapMarker.ESPCanvas or not Game:IsValid(PlayerMapMarker.ESPCanvas) then return nil end
    if PlayerMapMarker._OBHeadWidgetLoadFailed then return nil end

    if not PlayerMapMarker._OBHeadWidgetClass then
        pcall(function()
            local Path = "/Game/BluePrints/UI/OBUI/Item/OB_PlayerHeadHPItem_UIBP.OB_PlayerHeadHPItem_UIBP"
            local uClass = slua.loadClass(Path)
            if uClass then PlayerMapMarker._OBHeadWidgetClass = uClass end
        end)
        if not PlayerMapMarker._OBHeadWidgetClass then
            PlayerMapMarker._OBHeadWidgetLoadFailed = true
            return nil
        end
    end

    local Widget = nil
    pcall(function()
        local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
        local PC = PlayerMapMarker.GetMyPlayerController()
        local OuterObj = IsValid_ESP9(PC) and PC.Object or PlayerMapMarker.ESPCanvas
        Widget = STExtraBlueprintFunctionLibrary.CreateWidgetByClass(PlayerMapMarker._OBHeadWidgetClass, OuterObj)
    end)
    if not Widget then return nil end

    pcall(function() Widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
    pcall(function() Widget:SetRenderOpacity(1.0) end)

    -- Premium styling: apply yellow & red theme to the ESP widget
    local FSlateColor = import("SlateColor") or import("/Script/SlateCore.SlateColor")
    local premiumYellow = FLinearColor_ESP9 and FLinearColor_ESP9(1.0, 0.85, 0.0, 1.0) or {R=1,G=0.85,B=0,A=1}
    local premiumRedGlow = FLinearColor_ESP9 and FLinearColor_ESP9(0.9, 0.05, 0.0, 0.3) or {R=0.9,G=0.05,B=0,A=0.3}

    -- Try to style the widget background and border with premium red glow
    pcall(function()
        if Widget.SetBrushColor then Widget:SetBrushColor(FLinearColor_ESP9 and FLinearColor_ESP9(0.05, 0.02, 0.0, 0.85) or {R=0.05,G=0.02,B=0,A=0.85}) end
        if Widget.SetBrushColor then Widget:SetBrushColor(premiumRedGlow) end
    end)

    -- Try to apply render opacity and render scale for a premium look
    pcall(function() Widget:SetRenderOpacity(1.0) end)

    local NameText = nil
    local HealthFill = nil
    pcall(function()
        NameText = Widget.TextBlock_TeamName
        if NameText and slua.isValid(NameText) then pcall(function() NameText:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end) end
        if Widget.TextBlock_PlayerName and slua.isValid(Widget.TextBlock_PlayerName) then pcall(function() Widget.TextBlock_PlayerName:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end) end
        local SizeBox_HP = Widget.SizeBox_HP
        if SizeBox_HP and slua.isValid(SizeBox_HP) then
            pcall(function() SizeBox_HP:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
            local ExistingChild = nil
            pcall(function() if SizeBox_HP.GetContent then ExistingChild = SizeBox_HP:GetContent() end end)
            if ExistingChild and slua.isValid(ExistingChild) then
                local FoundPB = PlayerMapMarker.FindProgressBarInWidget(ExistingChild, 0, 5)
                if FoundPB and slua.isValid(FoundPB) then HealthFill = FoundPB end
            end
        end
    end)

    local WidgetData = {
        Container = Widget,
        NameText = NameText,
        HealthFill = HealthFill,
        IsGameWidget = true,
        HasChildren = (NameText ~= nil)
    }
    return WidgetData
end

function PlayerMapMarker.FindProgressBarInWidget(WidgetObj, Depth, MaxDepth)
    if not WidgetObj or not slua.isValid(WidgetObj) then return nil end
    Depth = Depth or 0
    MaxDepth = MaxDepth or 5
    if Depth > MaxDepth then return nil end

    local bIsPB = false
    pcall(function() if WidgetObj.SetPercent and WidgetObj.SetFillColorAndOpacity then bIsPB = true end end)
    if bIsPB then return WidgetObj end

    local nChildren = 0
    pcall(function() if WidgetObj.GetChildrenCount then nChildren = WidgetObj:GetChildrenCount() end end)
    for i = 0, math.max(nChildren - 1, 0) do
        local child = nil
        pcall(function() child = WidgetObj:GetChildAt(i) end)
        if child and slua.isValid(child) then
            local result = PlayerMapMarker.FindProgressBarInWidget(child, Depth + 1, MaxDepth)
            if result then return result end
        end
    end
    return nil
end

function PlayerMapMarker.ApplyTeamColor(Widget, TeamID)
    if not Widget or not Widget.Container then return end
    if not _G.Mod_ESP_ShowTeamColor then return end
    local color = PlayerMapMarker.GetTeamColor(TeamID)
    if not color then return end
    pcall(function()
        local W = Widget.Container
        if not W or not slua.isValid(W) then return end
        if W.SetTeamColor then pcall(function() W:SetTeamColor(TeamID) end) end
    end)
end

function PlayerMapMarker.UpdateESPText(Widget, Text)
    if not Widget then return end
    if Widget._LastESPText == Text then return end
    Widget._LastESPText = Text

    -- Premium yellow text color for ESP names
    local FSlateColor = import("SlateColor") or import("/Script/SlateCore.SlateColor")
    local premiumYellow = FLinearColor_ESP9 and FLinearColor_ESP9(1.0, 0.85, 0.0, 1.0) or {R=1,G=0.85,B=0,A=1}

    local function applyText(w, txt)
        if not w or not slua.isValid(w) then return end
        if txt == "" then
            pcall(function() w:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
            return
        else
            pcall(function() w:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
        end
        pcall(function() w:SetText(txt) end)
        -- Apply premium yellow text color
        pcall(function()
            if FSlateColor then w:SetColorAndOpacity(FSlateColor(premiumYellow))
            else w:SetColorAndOpacity(premiumYellow) end
        end)
    end

    if Widget.NameText and slua.isValid(Widget.NameText) then applyText(Widget.NameText, Text) end
    if Widget.IsGameWidget and Widget.Container then
        pcall(function()
            local W = Widget.Container
            if W and slua.isValid(W) then
                applyText(W.TextBlock_TeamName, Text)
                applyText(W.TextBlock_PlayerName, Text)
            end
        end)
    end
end

function PlayerMapMarker.UpdateESPHealth(Widget, pct)
    if not Widget then return end
    Widget.LastPct = pct
    local bShowHP = _G.Mod_ESP_ShowHealthBar
    if not bShowHP then return end

    if PlayerMapMarker.bForceSwitcherIndexEveryUpdate and Widget.Container then
        pcall(function()
            local W = Widget.Container
            if W and slua.isValid(W) then
                if W.WidgetSwitcher_Type and slua.isValid(W.WidgetSwitcher_Type) then pcall(function() if W.WidgetSwitcher_Type.SetActiveWidgetIndex then W.WidgetSwitcher_Type:SetActiveWidgetIndex(PlayerMapMarker.HPWidgetSwitcherTypeIndex) end end) end
                if W.WidgetSwitcher_Type2 and slua.isValid(W.WidgetSwitcher_Type2) then pcall(function() if W.WidgetSwitcher_Type2.SetActiveWidgetIndex then W.WidgetSwitcher_Type2:SetActiveWidgetIndex(PlayerMapMarker.HPWidgetSwitcherType2Index) end end) end
            end
        end)
    end

    if Widget.HealthFill then
        local bValid = false
        pcall(function() bValid = slua.isValid(Widget.HealthFill) end)
        if bValid then
            pcall(function()
                if Widget.HealthFill.SetPercent then
                    Widget.HealthFill:SetPercent(pct)
                    local color
                    if pct > 0.5 then color = FLinearColor_ESP9 and FLinearColor_ESP9(1.0, 0.85, 0.0, 1.0) or {R=255,G=217,B=0,A=255}
                    elseif pct > 0.25 then color = FLinearColor_ESP9 and FLinearColor_ESP9(1.0, 0.4, 0.0, 1.0) or {R=255,G=102,B=0,A=255}
                    else color = FLinearColor_ESP9 and FLinearColor_ESP9(0.9, 0.0, 0.0, 1.0) or {R=230,G=0,B=0,A=255} end
                    if Widget.HealthFill.SetFillColorAndOpacity then Widget.HealthFill:SetFillColorAndOpacity(color) end
                end
            end)
        end
    end
end

function PlayerMapMarker.UpdateESPPositionWithPC(Widget, WorldLoc, PC, CanvasPos)
    if not Widget or not IsValid_ESP9(PC) then return false end

    local Container = Widget.Container or Widget
    local bOnScreen = true

    if not CanvasPos then
        if not WorldLoc then return false end
        bOnScreen, CanvasPos = PlayerMapMarker.ProjectWorldToCanvasLocal(PC, WorldLoc)
    end

    if not bOnScreen then pcall(function() Container:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end) return false end

    pcall(function()
        local bShowAnyUI = _G.Mod_ESP_ShowName or _G.Mod_ESP_ShowDistance or _G.Mod_ESP_ShowHealthBar or _G.Mod_ESP_ShowTeamColor or _G.Mod_ESP_ShowWeaponIcon
        if bShowAnyUI then Container:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        else Container:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end

        if PlayerMapMarker.ESPCanvas and Game:IsValid(PlayerMapMarker.ESPCanvas) then
            local ptr = tostring(Container)
            local Slot = PlayerMapMarker.ESPWidgetPtrs[ptr]
            if not Slot or not slua.isValid(Slot) then
                local addedSlot = PlayerMapMarker.ESPCanvas:AddChildToCanvas(Container)
                if addedSlot and slua.isValid(addedSlot) then
                    Slot = addedSlot
                    PlayerMapMarker.ESPWidgetPtrs[ptr] = addedSlot
                    pcall(function() Slot:SetAutoSize(true) end)
                    pcall(function() Slot:SetAlignment(FVector2D_ESP9 and FVector2D_ESP9(0.5, 1.0) or {X=0.5, Y=1.0}) end)
                    pcall(function() Slot:SetZOrder(PlayerMapMarker.ESPWidgetZOrder or 20) end)
                end
            end
            if Slot and slua.isValid(Slot) then
                local finalX = CanvasPos.X + (PlayerMapMarker.ESPAnchorOffsetX or 0)
                local finalY = CanvasPos.Y + (PlayerMapMarker.ESPAnchorOffsetY or 0)
                if not Widget._CachedPosVec then Widget._CachedPosVec = FVector2D_ESP9 and FVector2D_ESP9(finalX, finalY) or {X=finalX, Y=finalY}
                else Widget._CachedPosVec.X = finalX; Widget._CachedPosVec.Y = finalY end
                pcall(function() Slot:SetPosition(Widget._CachedPosVec) end)
            end
        end
    end)
    return true
end

PlayerMapMarker._CanvasScaleX = 1.0
PlayerMapMarker._CanvasScaleY = 1.0
PlayerMapMarker._CanvasOffsetX = 0.0
PlayerMapMarker._CanvasOffsetY = 0.0

function PlayerMapMarker.UpdateCanvasTransform(PC)
    if not PlayerMapMarker.ESPCanvas or not Game:IsValid(PlayerMapMarker.ESPCanvas) then return end

    local success = false
    pcall(function()
        local SBL = SlateBlueprintLibrary
        if SBL and SBL.AbsoluteToLocal then
            local cg = PlayerMapMarker.ESPCanvas:GetCachedGeometry()
            if cg then
                local pt0 = SBL.AbsoluteToLocal(cg, FVector2D_ESP9 and FVector2D_ESP9(0, 0) or {X=0, Y=0})
                local pt1 = SBL.AbsoluteToLocal(cg, FVector2D_ESP9 and FVector2D_ESP9(100, 100) or {X=100, Y=100})
                if pt0 and pt1 then
                    PlayerMapMarker._CanvasScaleX = (pt1.X - pt0.X) / 100
                    PlayerMapMarker._CanvasScaleY = (pt1.Y - pt0.Y) / 100
                    PlayerMapMarker._CanvasOffsetX = pt0.X
                    PlayerMapMarker._CanvasOffsetY = pt0.Y
                    success = true
                end
            end
        end
    end)

    if not success then
        local scale = 1.0
        if WidgetLayoutLibrary and WidgetLayoutLibrary.GetViewportScale then scale = WidgetLayoutLibrary.GetViewportScale(PC) or 1.0 end
        PlayerMapMarker._CanvasScaleX = 1.0 / scale
        PlayerMapMarker._CanvasScaleY = 1.0 / scale
        PlayerMapMarker._CanvasOffsetX = 0
        PlayerMapMarker._CanvasOffsetY = 0
    end
end

function PlayerMapMarker.ScreenPixelToCanvasLocal(PC, ScreenPixelPos)
    if not ScreenPixelPos then return FVector2D_ESP9 and FVector2D_ESP9(0, 0) or {X=0, Y=0} end
    local scaleX = PlayerMapMarker._CanvasScaleX or 1.0
    local scaleY = PlayerMapMarker._CanvasScaleY or 1.0
    local offsetX = PlayerMapMarker._CanvasOffsetX or 0
    local offsetY = PlayerMapMarker._CanvasOffsetY or 0
    return (FVector2D_ESP9 and FVector2D_ESP9(ScreenPixelPos.X * scaleX + offsetX, ScreenPixelPos.Y * scaleY + offsetY)) or {X = ScreenPixelPos.X * scaleX + offsetX, Y = ScreenPixelPos.Y * scaleY + offsetY}
end

function PlayerMapMarker.ProjectWorldToCanvasLocal(PC, WorldLoc)
    if not IsValid_ESP9(PC) or not WorldLoc then return false, (FVector2D_ESP9 and FVector2D_ESP9(0, 0) or {X=0, Y=0}) end

    local ScreenPixelPos = FVector2D_ESP9 and FVector2D_ESP9(0, 0) or {X=0, Y=0}
    local bOK = false
    pcall(function()
        local res = PC:ProjectWorldLocationToScreen(WorldLoc, ScreenPixelPos, true)
        if res == true or res == 1 or (ScreenPixelPos and (ScreenPixelPos.X ~= 0 or ScreenPixelPos.Y ~= 0)) then bOK = true end
    end)

    if not bOK or not ScreenPixelPos or (ScreenPixelPos.X == 0 and ScreenPixelPos.Y == 0) then return false, (FVector2D_ESP9 and FVector2D_ESP9(0, 0) or {X=0, Y=0}) end

    local CanvasLocalPos = PlayerMapMarker.ScreenPixelToCanvasLocal(PC, ScreenPixelPos)
    return true, CanvasLocalPos
end

function PlayerMapMarker.GetSnapLineStartPos(PC)
    local screenPixelW, screenPixelH = 0, 0
    local scale = 1.0

    pcall(function()
        if PC and PC.GetViewportSize then
            local vs = FVector2D_ESP9 and FVector2D_ESP9(0, 0) or {X=0,Y=0}
            PC:GetViewportSize(vs)
            if vs and vs.X and vs.X > 200 then screenPixelW = vs.X screenPixelH = vs.Y end
        end
    end)

    if screenPixelW <= 200 then
        pcall(function()
            local WLL = WidgetLayoutLibrary
            if WLL and WLL.GetViewportSize then
                local vs = WLL.GetViewportSize(PC)
                if vs and vs.X and vs.X > 200 then screenPixelW = vs.X screenPixelH = vs.Y end
            end
        end)
    end

    pcall(function()
        local WLL = WidgetLayoutLibrary
        if WLL and WLL.GetViewportScale then
            local s = WLL.GetViewportScale(PC)
            if s and type(s) == "number" and s > 0 then scale = s end
        end
    end)

    if screenPixelW <= 200 then
        screenPixelW = (PlayerMapMarker._cachedViewportW or 1920) * scale
        screenPixelH = (PlayerMapMarker._cachedViewportH or 1080) * scale
    end

    if not PlayerMapMarker._CachedTopCenterPixel then PlayerMapMarker._CachedTopCenterPixel = FVector2D_ESP9 and FVector2D_ESP9(0, 0) or {X=0,Y=0} end
    PlayerMapMarker._CachedTopCenterPixel.X = screenPixelW / 2.0
    PlayerMapMarker._CachedTopCenterPixel.Y = (PlayerMapMarker.SnapLineOriginY or 50) * scale

    local fromCanvasPos = PlayerMapMarker.ScreenPixelToCanvasLocal(PC, PlayerMapMarker._CachedTopCenterPixel)
    return fromCanvasPos.X + (PlayerMapMarker.SnapLineOriginOffsetX or 0), fromCanvasPos.Y
end

function PlayerMapMarker.CreateSnapLine()
    if not PlayerMapMarker.ESPCanvas or not Game:IsValid(PlayerMapMarker.ESPCanvas) then return nil end

    -- Premium 2-layer snapline: red glow + yellow core
    local layerDefs = {
        -- Layer 1: Red glow (wider, behind)
        {r = 0.9, g = 0.05, b = 0.0, a = 0.35, thick = 2.5, z = 0},
        -- Layer 2: Bright yellow core (sharp, front)
        {r = 1.0, g = 0.85, b = 0.0, a = 0.9, thick = 1.0, z = 1},
    }

    local Layers = {}
    for _, ld in ipairs(layerDefs) do
        local Border = nil
        pcall(function() Border = CGame:NewObjectFromPath("/Script/UMG.Border", PlayerMapMarker.ESPCanvas) end)
        if Border and slua.isValid(Border) then
            local lc = FLinearColor_ESP9 and FLinearColor_ESP9(ld.r, ld.g, ld.b, ld.a) or {R=ld.r,G=ld.g,B=ld.b,A=ld.a}
            pcall(function() Border:SetBrushColor(lc) end)
            pcall(function() Border:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
            pcall(function() Border.RenderTransformPivot = FVector2D_ESP9 and FVector2D_ESP9(0.0, 0.5) or {X=0,Y=0.5} end)
            pcall(function() Border:SetRenderTransformPivot(FVector2D_ESP9 and FVector2D_ESP9(0.0, 0.5) or {X=0,Y=0.5}) end)

            local Slot = nil
            pcall(function()
                Slot = PlayerMapMarker.ESPCanvas:AddChildToCanvas(Border)
                if Slot then Slot:SetAutoSize(false) Slot:SetZOrder(ld.z) end
            end)
            if Slot then
                table.insert(Layers, { Widget = Border, Slot = Slot, Thick = ld.thick })
            end
        end
    end

    if #Layers == 0 then return nil end

    -- Return composite structure; .Widget and .Slot point to the core (yellow) layer for compatibility
    local coreLayer = Layers[2] or Layers[1]
    return {
        Widget = coreLayer.Widget,
        Slot = coreLayer.Slot,
        Layers = Layers,
        _CachedPosVec = nil,
        _CachedSizeVec = nil,
    }
end

function PlayerMapMarker.UpdateSnapLine(KeyStr, CanvasPos, bOnScreen, fromX, fromY)
    if not PlayerMapMarker.bUseSnapLines then return end
    if not PlayerMapMarker.ESPCanvas or not Game:IsValid(PlayerMapMarker.ESPCanvas) then return end

    local LineData = PlayerMapMarker.SnapLineWidgets[KeyStr]
    -- Validate: if multi-layer, check all layers; if single, check the one
    local function IsLineDataValid(ld)
        if not ld or not ld.Widget or not slua.isValid(ld.Widget) or not ld.Slot then return false end
        if ld.Layers then
            for _, layer in ipairs(ld.Layers) do
                if not layer.Widget or not slua.isValid(layer.Widget) or not layer.Slot then return false end
            end
        end
        return true
    end
    if LineData and not IsLineDataValid(LineData) then
        PlayerMapMarker.RemoveSnapLine(KeyStr)
        LineData = nil
    end
    if not bOnScreen or not CanvasPos then
        if LineData then
            if LineData.Layers then
                for _, layer in ipairs(LineData.Layers) do
                    if layer.Widget and slua.isValid(layer.Widget) then
                        pcall(function() layer.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
                    end
                end
            elseif LineData.Widget and slua.isValid(LineData.Widget) then
                pcall(function() LineData.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
            end
        end
        return
    end

    if not LineData then
        LineData = PlayerMapMarker.CreateSnapLine()
        if not LineData or not LineData.Widget or not LineData.Slot then return end
        PlayerMapMarker.SnapLineWidgets[KeyStr] = LineData
    end

    local toX = CanvasPos.X + (PlayerMapMarker.SnapLineHeadOffsetX or 0)
    local toY = CanvasPos.Y + (PlayerMapMarker.SnapLineHeadOffsetY or 0)

    local dx = toX - fromX
    local dy = toY - fromY
    local length = math.sqrt(dx * dx + dy * dy)
    local baseThick = PlayerMapMarker.SnapLineThickness or 3.0
    local angle_rad = 0
    if math.atan2 then angle_rad = math.atan2(dy, dx) else angle_rad = math.atan(dy, dx) end
    local angle = angle_rad * (180.0 / math.pi)

    -- Update all layers with their respective thickness multipliers
    if LineData.Layers then
        for _, layer in ipairs(LineData.Layers) do
            local lt = baseThick * (layer.Thick or 1.0)
            local lY = fromY - lt / 2.0
            pcall(function() layer.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
            if not layer._posVec then
                layer._posVec = FVector2D_ESP9 and FVector2D_ESP9(fromX, lY) or {X=fromX, Y=lY}
                layer._sizeVec = FVector2D_ESP9 and FVector2D_ESP9(length, lt) or {X=length, Y=lt}
            else
                layer._posVec.X = fromX; layer._posVec.Y = lY
                layer._sizeVec.X = length; layer._sizeVec.Y = lt
            end
            pcall(function()
                layer.Slot:SetPosition(layer._posVec)
                layer.Slot:SetSize(layer._sizeVec)
            end)
            pcall(function() layer.Widget:SetRenderAngle(angle) end)
        end
    else
        -- Fallback: single-layer (legacy path)
        local Widget = LineData.Widget
        local Slot = LineData.Slot
        pcall(function() Widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
        if not LineData._CachedPosVec then
            LineData._CachedPosVec = FVector2D_ESP9 and FVector2D_ESP9(fromX, fromY - baseThick / 2.0) or {X=fromX, Y=fromY - baseThick / 2.0}
            LineData._CachedSizeVec = FVector2D_ESP9 and FVector2D_ESP9(length, baseThick) or {X=length, Y=baseThick}
        else
            LineData._CachedPosVec.X = fromX; LineData._CachedPosVec.Y = fromY - baseThick / 2.0
            LineData._CachedSizeVec.X = length; LineData._CachedSizeVec.Y = baseThick
        end
        pcall(function()
            Slot:SetPosition(LineData._CachedPosVec)
            Slot:SetSize(LineData._CachedSizeVec)
        end)
        pcall(function() Widget:SetRenderAngle(angle) end)
    end
end

function PlayerMapMarker.RemoveSnapLine(KeyStr)
    local LineData = PlayerMapMarker.SnapLineWidgets[KeyStr]
    if LineData then
        -- Multi-layer: destroy all layer widgets
        if LineData.Layers then
            for _, layer in ipairs(LineData.Layers) do
                if layer.Widget and slua.isValid(layer.Widget) then
                    pcall(function() layer.Widget:RemoveFromParent() layer.Widget:ConditionalBeginDestroy() end)
                end
            end
        elseif LineData.Widget and slua.isValid(LineData.Widget) then
            pcall(function() LineData.Widget:RemoveFromParent() LineData.Widget:ConditionalBeginDestroy() end)
        end
    end
    -- Always clear the record, including invalid/stale widget handles.
    PlayerMapMarker.SnapLineWidgets[KeyStr] = nil
end

function PlayerMapMarker.RemoveESPWidget(Widget, KeyStr)
    if not Widget then return end
    local Container = Widget.Container or Widget
    pcall(function()
        local ptr = tostring(Container)
        PlayerMapMarker.ESPWidgetPtrs[ptr] = nil
        Container:RemoveFromParent()
        Container:ConditionalBeginDestroy()
    end)
    if KeyStr then
        PlayerMapMarker.RemoveSnapLine(KeyStr)
        if PlayerMapMarker.RemoveSkeletonLines then
            PlayerMapMarker.RemoveSkeletonLines(KeyStr)
        end
    end
end

function PlayerMapMarker.ClearAllSnapLines()
    for KeyStr, LineData in pairs(PlayerMapMarker.SnapLineWidgets) do
        if LineData then
            if LineData.Layers then
                for _, layer in ipairs(LineData.Layers) do
                    if layer.Widget and slua.isValid(layer.Widget) then
                        pcall(function() layer.Widget:RemoveFromParent() layer.Widget:ConditionalBeginDestroy() end)
                    end
                end
            elseif LineData.Widget and slua.isValid(LineData.Widget) then
                pcall(function() LineData.Widget:RemoveFromParent() LineData.Widget:ConditionalBeginDestroy() end)
            end
        end
    end
    PlayerMapMarker.SnapLineWidgets = {}
end

-- ============================================================
function PlayerMapMarker.ScreenPixelToCanvasLocalRaw(PC, screenX, screenY)
    local scaleX = PlayerMapMarker._CanvasScaleX or 1.0
    local scaleY = PlayerMapMarker._CanvasScaleY or 1.0
    local offsetX = PlayerMapMarker._CanvasOffsetX or 0
    local offsetY = PlayerMapMarker._CanvasOffsetY or 0
    return screenX * scaleX + offsetX, screenY * scaleY + offsetY
end

function PlayerMapMarker.ProjectWorldToCanvasLocalRaw(PC, WorldLoc)
    if not IsValid_ESP9(PC) or not WorldLoc then return false, 0, 0 end

    if not PlayerMapMarker._tempScreenPixelPos then
        PlayerMapMarker._tempScreenPixelPos = FVector2D_ESP9 and FVector2D_ESP9(0, 0) or {X=0, Y=0}
    end
    local tempPos = PlayerMapMarker._tempScreenPixelPos

    local bOK = false
    pcall(function()
        local res = PC:ProjectWorldLocationToScreen(WorldLoc, tempPos, true)
        if res == true or res == 1 then bOK = true end
    end)

    if not bOK or (tempPos.X == 0 and tempPos.Y == 0) then return false, 0, 0 end

    local canvasX, canvasY = PlayerMapMarker.ScreenPixelToCanvasLocalRaw(PC, tempPos.X, tempPos.Y)
    return true, canvasX, canvasY
end

function PlayerMapMarker.GetBoneLocationWithFallback(Character, PrimaryBoneName)
    if not IsValid_ESP9(Character) or not PrimaryBoneName then return nil end

    if Character._cachedBoneNames and Character._cachedBoneNames[PrimaryBoneName] then
        local cachedName = Character._cachedBoneNames[PrimaryBoneName]
        local loc = nil
        pcall(function()
            local Mesh = PlayerMapMarker.GetCharacterMesh(Character)
            if Mesh and Game:IsValid(Mesh) then
                if Mesh.GetSocketLocation then loc = Mesh:GetSocketLocation(cachedName)
                elseif Mesh.GetBoneLocation then loc = Mesh:GetBoneLocation(cachedName) end
            end
        end)
        if loc then return loc end
    end

    local fallbacks = PlayerMapMarker.BoneNameFallbacks[PrimaryBoneName] or {PrimaryBoneName}
    for _, bname in ipairs(fallbacks) do
        local loc = nil
        pcall(function()
            local Mesh = PlayerMapMarker.GetCharacterMesh(Character)
            if Mesh and Game:IsValid(Mesh) then
                if Mesh.GetSocketLocation then loc = Mesh:GetSocketLocation(bname)
                elseif Mesh.GetBoneLocation then loc = Mesh:GetBoneLocation(bname) end
            end
        end)
        if loc then
            if not Character._cachedBoneNames then Character._cachedBoneNames = {} end
            Character._cachedBoneNames[PrimaryBoneName] = bname
            return loc
        end
    end
    return nil
end

function PlayerMapMarker.GetCharacterMesh(Character)
    if not IsValid_ESP9(Character) then return nil end
    local Mesh = nil
    pcall(function() if Character.Mesh and Game:IsValid(Character.Mesh) then Mesh = Character.Mesh end end)
    if not Mesh then pcall(function() local SkeletalMeshCompClass = import("/Script/Engine.SkeletalMeshComponent") Mesh = Character:GetComponentByClass(SkeletalMeshCompClass) end) end
    return Mesh
end

function PlayerMapMarker.IsPlayerVisible(PC, Character)
    if not IsValid_ESP9(PC) or not IsValid_ESP9(Character) then return false end
    local now = os.clock()
    if Character._lastVisTime and (now - Character._lastVisTime) < 0.15 then
        return Character._cachedIsVisible or false
    end
    Character._lastVisTime = now

    local bVis = false
    pcall(function()
        if PC.LineOfSightTo then
            if not PlayerMapMarker._ZeroVector then
                local VT = FVector_ESP9 or import("/Script/CoreUObject.Vector")
                if VT then PlayerMapMarker._ZeroVector = VT(0, 0, 0) end
            end
            bVis = PC:LineOfSightTo(Character, PlayerMapMarker._ZeroVector, false)
        end
    end)
    Character._cachedIsVisible = bVis
    return bVis
end

function PlayerMapMarker.CreateSkeletonLineWidget()
    if not PlayerMapMarker.ESPCanvas or not Game:IsValid(PlayerMapMarker.ESPCanvas) then return nil end

    local Border = nil
    pcall(function() Border = CGame:NewObjectFromPath("/Script/UMG.Border", PlayerMapMarker.ESPCanvas) end)
    if not Border or not slua.isValid(Border) then return nil end

    pcall(function() Border.RenderTransformPivot = FVector2D_ESP9 and FVector2D_ESP9(0.0, 0.5) or {X=0, Y=0.5} end)
    pcall(function() Border:SetRenderTransformPivot(FVector2D_ESP9 and FVector2D_ESP9(0.0, 0.5) or {X=0, Y=0.5}) end)

    local Slot = nil
    pcall(function()
        Slot = PlayerMapMarker.ESPCanvas:AddChildToCanvas(Border)
        if Slot then Slot:SetAutoSize(false) Slot:SetZOrder(5) end
    end)

    return {
        Widget = Border, Slot = Slot,
        posVec = FVector2D_ESP9 and FVector2D_ESP9(0, 0) or {X=0, Y=0},
        sizeVec = FVector2D_ESP9 and FVector2D_ESP9(0, 0) or {X=0, Y=0},
        lastFromX = -99999, lastFromY = -99999,
        lastToX = -99999, lastToY = -99999
    }
end

function PlayerMapMarker.UpdateSkeletonLines(KeyStr, Character, PC, bVisible, TeamColor, bPlayerOnScreen, charLoc)
    if not PlayerMapMarker.bUseSkeleton then return end
    if not PlayerMapMarker.ESPCanvas or not Game:IsValid(PlayerMapMarker.ESPCanvas) then return end

    local PlayerBones = PlayerMapMarker.SkeletonWidgets[KeyStr]

    if not bVisible or not IsValid_ESP9(Character) or not IsValid_ESP9(PC) then
        if PlayerBones then
            for _, LineData in ipairs(PlayerBones) do
                if LineData and LineData.Widget and slua.isValid(LineData.Widget) then
                    LineData.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
                    LineData.Widget._isSelfHitTestVisible = false
                end
            end
        end
        return
    end

    if not charLoc then charLoc = PlayerMapMarker.GetESPLocation(Character) end
    if not charLoc then return end

    if bPlayerOnScreen == nil then
        local bOnScreen, _, _ = PlayerMapMarker.ProjectWorldToCanvasLocalRaw(PC, charLoc)
        bPlayerOnScreen = bOnScreen
    end

    if not bPlayerOnScreen then
        if PlayerBones then
            for _, LineData in ipairs(PlayerBones) do
                if LineData and LineData.Widget and slua.isValid(LineData.Widget) then
                    LineData.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
                    LineData.Widget._isSelfHitTestVisible = false
                end
            end
        end
        return
    end

    local dist = 0
    local myLoc = PlayerMapMarker._CachedMyLoc or PlayerMapMarker.GetMyLocation()
    if myLoc and charLoc then
        local dx = (charLoc.X or 0) - (myLoc.X or 0)
        local dy = (charLoc.Y or 0) - (myLoc.Y or 0)
        local dz = (charLoc.Z or 0) - (myLoc.Z or 0)
        dist = math.sqrt(dx * dx + dy * dy + dz * dz)
    end

    if PlayerMapMarker.SkeletonMaxDistance and PlayerMapMarker.SkeletonMaxDistance > 0 then
        if dist > PlayerMapMarker.SkeletonMaxDistance then
            if PlayerBones then
                for _, LineData in ipairs(PlayerBones) do
                    if LineData and LineData.Widget and slua.isValid(LineData.Widget) then
                        LineData.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
                        LineData.Widget._isSelfHitTestVisible = false
                    end
                end
            end
            return
        end
    end

    if not PlayerBones then
        PlayerBones = {}
        PlayerMapMarker.SkeletonWidgets[KeyStr] = PlayerBones
    end

    local lineColor = nil
    if PlayerMapMarker.bUseVisibilityColor then
        local bTargetVisible = PlayerMapMarker.IsPlayerVisible(PC, Character)
        if bTargetVisible then lineColor = PlayerMapMarker.SkeletonVisibleColor or FLinearColor_ESP9(1.0, 0.85, 0.0, 0.8)
        else lineColor = PlayerMapMarker.SkeletonCoverColor or FLinearColor_ESP9(0.9, 0.0, 0.0, 0.6) end
    else
        lineColor = PlayerMapMarker.SkeletonColor or TeamColor or FLinearColor_ESP9(1.0, 1.0, 1.0, PlayerMapMarker.SkeletonOpacity or 0.8)
    end

    local cache = PlayerMapMarker._StaticBoneLocCache
    for k in pairs(cache) do cache[k] = nil end

    local lineIndex = 0
    local thickness = PlayerMapMarker.SkeletonThickness or 1.2

    for _, chain in ipairs(PlayerMapMarker.SkeletonChains) do
        local lastCanvasX, lastCanvasY = nil, nil
        for _, boneName in ipairs(chain) do
            local boneWorldLoc = cache[boneName]
            if boneWorldLoc == nil then
                boneWorldLoc = PlayerMapMarker.GetBoneLocationWithFallback(Character, boneName) or false
                cache[boneName] = boneWorldLoc
            end
            if boneWorldLoc == false then boneWorldLoc = nil end

            local currentCanvasX, currentCanvasY = nil, nil
            if boneWorldLoc then
                local bOnScreen, cX, cY = PlayerMapMarker.ProjectWorldToCanvasLocalRaw(PC, boneWorldLoc)
                if bOnScreen then
                    currentCanvasX = cX
                    currentCanvasY = cY
                end
            end

            if lastCanvasX and currentCanvasX then
                lineIndex = lineIndex + 1
                local LineData = PlayerBones[lineIndex]
                if not LineData or not LineData.Widget or not slua.isValid(LineData.Widget) then
                    LineData = PlayerMapMarker.CreateSkeletonLineWidget()
                    if LineData then PlayerBones[lineIndex] = LineData end
                end

                if LineData and LineData.Widget and LineData.Slot then
                    local Widget = LineData.Widget
                    local Slot = LineData.Slot

                    if Widget._cachedColor ~= lineColor then
                        Widget:SetBrushColor(lineColor)
                        Widget._cachedColor = lineColor
                    end

                    if not Widget._isSelfHitTestVisible then
                        Widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                        Widget._isSelfHitTestVisible = true
                    end

                    local fromX = lastCanvasX
                    local fromY = lastCanvasY
                    local toX = currentCanvasX
                    local toY = currentCanvasY

                    local threshold = 0.15
                    if dist > 8000 then threshold = 0.8 elseif dist > 4000 then threshold = 0.4 end

                    if math.abs(fromX - LineData.lastFromX) > threshold or
                       math.abs(fromY - LineData.lastFromY) > threshold or
                       math.abs(toX - LineData.lastToX) > threshold or
                       math.abs(toY - LineData.lastToY) > threshold then

                        LineData.lastFromX = fromX
                        LineData.lastFromY = fromY
                        LineData.lastToX = toX
                        LineData.lastToY = toY

                        local dx = toX - fromX
                        local dy = toY - fromY
                        local length = math.sqrt(dx * dx + dy * dy)
                        local angle_rad = (math.atan2 and math.atan2(dy, dx)) or math.atan(dy, dx)
                        local angle = angle_rad * 57.29577951308232

                        local pVec = LineData.posVec
                        pVec.X = fromX; pVec.Y = fromY - thickness / 2.0
                        Slot:SetPosition(pVec)

                        local sVec = LineData.sizeVec
                        sVec.X = length; sVec.Y = thickness
                        Slot:SetSize(sVec)

                        Widget:SetRenderAngle(angle)
                    end
                end
            end
            lastCanvasX = currentCanvasX
            lastCanvasY = currentCanvasY
        end
    end

    for i = lineIndex + 1, #PlayerBones do
        local LineData = PlayerBones[i]
        if LineData and LineData.Widget and slua.isValid(LineData.Widget) then
            LineData.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
            LineData.Widget._isSelfHitTestVisible = false
        end
    end
end

function PlayerMapMarker.RemoveSkeletonLines(KeyStr)
    local PlayerBones = PlayerMapMarker.SkeletonWidgets[KeyStr]
    if PlayerBones then
        for _, LineData in ipairs(PlayerBones) do
            if LineData and LineData.Widget and slua.isValid(LineData.Widget) then
                pcall(function()
                    LineData.Widget:RemoveFromParent()
                    LineData.Widget:ConditionalBeginDestroy()
                end)
            end
        end
        PlayerMapMarker.SkeletonWidgets[KeyStr] = nil
    end
end

function PlayerMapMarker.ClearAllSkeletonLines()
    for KeyStr, PlayerBones in pairs(PlayerMapMarker.SkeletonWidgets) do
        for _, LineData in ipairs(PlayerBones) do
            if LineData and LineData.Widget and slua.isValid(LineData.Widget) then
                pcall(function()
                    LineData.Widget:RemoveFromParent()
                    LineData.Widget:ConditionalBeginDestroy()
                end)
            end
        end
    end
    PlayerMapMarker.SkeletonWidgets = {}
end

function PlayerMapMarker.ClearAllESP()
    RedBoxOverlay.Stop()
    for KeyStr, Data in pairs(PlayerMapMarker.ESPWidgets) do
        PlayerMapMarker.RemoveESPWidget(Data.Widget, KeyStr)
    end
    PlayerMapMarker.ESPWidgets = {}
    PlayerMapMarker.ESPWidgetPtrs = {}
    PlayerMapMarker.ClearAllSnapLines()
    PlayerMapMarker.ClearAllSkeletonLines()
    PlayerMapMarker.ESPCanvas = nil
    PlayerMapMarker._OBHeadWidgetClass = nil
    PlayerMapMarker._OBHeadWidgetLoadFailed = false
    PlayerMapMarker._cachedViewportW = 1920
    PlayerMapMarker._cachedViewportH = 1080
end

function PlayerMapMarker.UpdateESP(AllPlayers, MyLoc)
    if not PlayerMapMarker.bUseScreenESP then return end

    PlayerMapMarker.bUseSnapLines = _G.Mod_ESP_ShowSnapline
    PlayerMapMarker.bUseSkeleton = false

    if not PlayerMapMarker.InitESPCanvas() then return end
    if PlayerMapMarker._OBHeadWidgetLoadFailed then return end

    local PC = PlayerMapMarker.GetMyPlayerController()
    if IsValid_ESP9(PC) then PlayerMapMarker.UpdateCanvasTransform(PC) end

    local fromX, fromY = 0, 0
    if PlayerMapMarker.bUseSnapLines and IsValid_ESP9(PC) then
        fromX, fromY = PlayerMapMarker.GetSnapLineStartPos(PC)
    end

    local MyKey = PlayerMapMarker.GetMyPlayerKey()
    local SeenKeys = {}
    local MyChar = nil
    pcall(function()
        local GDP = PlayerMapMarker.GetGameplayData()
        if GDP and GDP.GetLocalCharacter then MyChar = GDP.GetLocalCharacter()
        else if PC and PC.GetPawn then MyChar = PC:GetPawn() end end
    end)

    local MyTeamID = PlayerMapMarker.GetTeamID(MyChar)

    for PlayerKey, Character in pairs(AllPlayers) do
        if IsValid_ESP9(Character) then
            local bIsMe = PlayerMapMarker.IsMe(Character, PlayerKey, MyKey)
            local bIsAI = PlayerMapMarker.IsAI(Character)
            local KeyStr = tostring(PlayerKey)
            local Name = PlayerMapMarker.GetPlayerName(Character)
            local Loc = PlayerMapMarker.GetESPLocation(Character)
            local DistStr = ""
            if MyLoc and Loc then DistStr = PlayerMapMarker.GetDistanceString(MyLoc, Loc) end

            local bSkip = false
            if bIsMe and not PlayerMapMarker.bIncludeMe then bSkip = true end
            if bIsAI and not PlayerMapMarker.bIncludeAI then bSkip = true end

            local TeamID = PlayerMapMarker.GetTeamID(Character)
            if MyTeamID ~= nil and TeamID == MyTeamID and not bIsMe then bSkip = true end

            local bIsAlive = PlayerMapMarker.IsAlive(Character)

            if not bSkip and Loc then
                SeenKeys[KeyStr] = true
                local ESPData = PlayerMapMarker.ESPWidgets[KeyStr]

                local Text = ""
                if _G.Mod_ESP_ShowName then Text = Name end
                if _G.Mod_ESP_ShowDistance and DistStr ~= "" then
                    if Text ~= "" then Text = string.format("%s [%s]", Text, DistStr) else Text = string.format("[%s]", DistStr) end
                end

                local bOnScreen, CanvasPos = PlayerMapMarker.ProjectWorldToCanvasLocal(PC, Loc)

                if not ESPData then
                    local Widget = PlayerMapMarker.CreateESPWidget()
                    if Widget then
                        PlayerMapMarker.ESPWidgets[KeyStr] = { Widget = Widget, Character = Character, Name = Name, LastDistStr = DistStr, TeamID = TeamID }
                        PlayerMapMarker.UpdateESPText(Widget, Text)
                        if bIsAlive then
                            PlayerMapMarker.UpdateESPPositionWithPC(Widget, Loc, PC, CanvasPos)
                            PlayerMapMarker.ApplyTeamColor(Widget, TeamID)
                            local HP = Character.Health or 0
                            local MaxHP = Character.MaxHealth or 120
                            local pct = 0
                            if HP > 0 and MaxHP > 0 then pct = HP / MaxHP; if pct > 1 then pct = 1 end; if pct < 0 then pct = 0 end end
                            PlayerMapMarker.UpdateESPHealth(Widget, pct)
                            PlayerMapMarker.AddWeaponIconToESP(Widget, Character)
                            if PlayerMapMarker.bUseSnapLines then
                                PlayerMapMarker.UpdateSnapLine(KeyStr, CanvasPos, bOnScreen, fromX, fromY)
                            else
                                PlayerMapMarker.RemoveSnapLine(KeyStr)
                            end
                            if PlayerMapMarker.bUseSkeleton then
                                PlayerMapMarker.UpdateSkeletonLines(KeyStr, Character, PC, true, PlayerMapMarker.GetTeamColor(TeamID), bOnScreen, Loc)
                            else
                                PlayerMapMarker.RemoveSkeletonLines(KeyStr)
                            end

                        else
                            local Container = Widget.Container or Widget
                            pcall(function() Container:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
                            PlayerMapMarker.UpdateESPHealth(Widget, 0)
                            PlayerMapMarker.RemoveSnapLine(KeyStr)
                            PlayerMapMarker.RemoveSkeletonLines(KeyStr)
                                            end
                    end
                else
                    ESPData.Character = Character
                    ESPData.Name = Name
                    ESPData.LastDistStr = DistStr
                    ESPData.TeamID = TeamID
                    PlayerMapMarker.ApplyTeamColor(ESPData.Widget, TeamID)
                    ESPData.Widget._LastESPText = nil
                    PlayerMapMarker.UpdateESPText(ESPData.Widget, Text)
                    PlayerMapMarker.UpdateESPPositionWithPC(ESPData.Widget, Loc, PC, CanvasPos)

                    local HP = Character.Health or 0
                    local MaxHP = Character.MaxHealth or 120
                    local pct = 0
                    if HP > 0 and MaxHP > 0 then pct = HP / MaxHP; if pct > 1 then pct = 1 end; if pct < 0 then pct = 0 end end
                    PlayerMapMarker.UpdateESPHealth(ESPData.Widget, pct)
                    PlayerMapMarker.AddWeaponIconToESP(ESPData.Widget, Character)

                    if PlayerMapMarker.bUseSnapLines then
                        PlayerMapMarker.UpdateSnapLine(KeyStr, CanvasPos, bOnScreen, fromX, fromY)
                    else
                        PlayerMapMarker.RemoveSnapLine(KeyStr)
                    end
                    if PlayerMapMarker.bUseSkeleton then
                        PlayerMapMarker.UpdateSkeletonLines(KeyStr, Character, PC, true, PlayerMapMarker.GetTeamColor(TeamID), bOnScreen, Loc)
                    else
                        PlayerMapMarker.RemoveSkeletonLines(KeyStr)
                    end

                end
            end
        end
    end

    for KeyStr, Data in pairs(PlayerMapMarker.ESPWidgets) do
        if not SeenKeys[KeyStr] then
            PlayerMapMarker.RemoveESPWidget(Data.Widget, KeyStr)
            PlayerMapMarker.ESPWidgets[KeyStr] = nil
        end
    end
    -- Remove any line whose target record no longer exists; this prevents stale left-side flicker.
    for KeyStr in pairs(PlayerMapMarker.SnapLineWidgets) do
        if not PlayerMapMarker.ESPWidgets[KeyStr] then PlayerMapMarker.RemoveSnapLine(KeyStr) end
    end
end

function PlayerMapMarker.UpdateESPLight()
    if RedBoxOverlay and RedBoxOverlay.bActive then RedBoxOverlay.UpdatePosition() end
    if not PlayerMapMarker.bUseScreenESP then return end

    PlayerMapMarker.bUseSnapLines = _G.Mod_ESP_ShowSnapline
    PlayerMapMarker.bUseSkeleton = false

    if not PlayerMapMarker.ESPCanvas or not Game:IsValid(PlayerMapMarker.ESPCanvas) then return end

    local PC = PlayerMapMarker.GetMyPlayerController()
    if not IsValid_ESP9(PC) then return end

    PlayerMapMarker.UpdateCanvasTransform(PC)

    local fromX, fromY = 0, 0
    if PlayerMapMarker.bUseSnapLines then fromX, fromY = PlayerMapMarker.GetSnapLineStartPos(PC) end

    for KeyStr, ESPData in pairs(PlayerMapMarker.ESPWidgets) do
        local Widget = ESPData.Widget
        local Character = ESPData.Character
        local Container = Widget and (Widget.Container or Widget)
        local bWidgetValid = false
        pcall(function() bWidgetValid = Container and slua.isValid(Container) end)

        if Widget and bWidgetValid and Character and IsValid_ESP9(Character) then
            local bIsAlive = PlayerMapMarker.IsAlive(Character)
            if not bIsAlive then
                pcall(function() Container:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
                PlayerMapMarker.RemoveSnapLine(KeyStr)
                PlayerMapMarker.RemoveSkeletonLines(KeyStr)
                    else
                local bShowAnyUI = _G.Mod_ESP_ShowName or _G.Mod_ESP_ShowDistance or _G.Mod_ESP_ShowHealthBar or _G.Mod_ESP_ShowTeamColor or _G.Mod_ESP_ShowWeaponIcon
                if bShowAnyUI then
                    pcall(function() Container:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
                else
                    pcall(function() Container:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
                end

                local Loc = PlayerMapMarker.GetESPLocation(Character)
                if Loc then
                    local bOnScreen, CanvasPos = PlayerMapMarker.ProjectWorldToCanvasLocal(PC, Loc)
                    PlayerMapMarker.UpdateESPPositionWithPC(Widget, Loc, PC, CanvasPos)

                    if PlayerMapMarker.bUseSnapLines then PlayerMapMarker.UpdateSnapLine(KeyStr, CanvasPos, bOnScreen, fromX, fromY)
                    else PlayerMapMarker.RemoveSnapLine(KeyStr) end

                    if PlayerMapMarker.bUseSkeleton then
                        PlayerMapMarker.UpdateSkeletonLines(KeyStr, Character, PC, true, PlayerMapMarker.GetTeamColor(ESPData.TeamID), bOnScreen, Loc)
                    else
                        PlayerMapMarker.RemoveSkeletonLines(KeyStr)
                    end

                else
                    PlayerMapMarker.RemoveSnapLine(KeyStr)
                    PlayerMapMarker.RemoveSkeletonLines(KeyStr)
                            end
            end
        end
    end
end

function PlayerMapMarker.UpdateESPDistances()
    if not PlayerMapMarker.bUseScreenESP then return end

    local MyLoc = PlayerMapMarker.GetMyLocation()
    if not MyLoc then return end

    local PC = PlayerMapMarker.GetMyPlayerController()
    if not IsValid_ESP9(PC) then return end

    PlayerMapMarker.UpdateCanvasTransform(PC)

    for KeyStr, ESPData in pairs(PlayerMapMarker.ESPWidgets) do
        local Character = ESPData.Character
        local Widget = ESPData.Widget
        local Container = Widget and (Widget.Container or Widget)
        local bWidgetValid = false
        pcall(function() bWidgetValid = Container and slua.isValid(Container) end)

        if Character and IsValid_ESP9(Character) and Widget and bWidgetValid then
            local Loc = PlayerMapMarker.GetESPLocation(Character)
            if Loc then
                local Dist = PlayerMapMarker.CalcDistance(MyLoc, Loc)
                ESPData.LastDistance = Dist

                if PlayerMapMarker.bShowDistance then
                    local DistStr = ""
                    local Meters = 0
                    if Dist then
                        Meters = Dist / 100
                        if Meters < 1000 then DistStr = string.format("%dm", math.floor(Meters))
                        else DistStr = string.format("%.1fkm", Meters / 1000) end
                    end

                    local Name = ESPData.Name or "Unknown"
                    local Text = ""
                    if _G.Mod_ESP_ShowName then Text = Name end
                    if _G.Mod_ESP_ShowDistance and DistStr ~= "" then
                        if Text ~= "" then Text = string.format("%s [%s]", Text, DistStr) else Text = string.format("[%s]", DistStr) end
                    end

                    ESPData.LastDistStr = DistStr
                    Widget._LastESPText = nil
                    PlayerMapMarker.UpdateESPText(Widget, Text)
                end
            end
        end
    end
end

function PlayerMapMarker.AddWeaponIconToESP(WidgetData, Character)
    if not WidgetData or not WidgetData.Container then return end
    if not _G.Mod_ESP_ShowWeaponIcon then return end

    pcall(function()
        local Container = WidgetData.Container
        if not Container or not slua.isValid(Container) then return end

        local winfo = Character and PlayerMapMarker.GetCharacterWeaponInfo(Character) or nil
        if not winfo or not winfo.WeaponID or winfo.WeaponID == 0 then return end

        if WidgetData._LastWeaponID == winfo.WeaponID and WidgetData._WeaponIconApplied then return end
        WidgetData._LastWeaponID = winfo.WeaponID
        WidgetData._WeaponIconApplied = true
    end)
end

function PlayerMapMarker.ScanAndUpdate()
    local AllChars = PlayerMapMarker.GetAllCharacters()
    if not AllChars then RedBoxOverlay.SetCounts(0, 0) return 0 end

    local MyKey = PlayerMapMarker.GetMyPlayerKey()
    local MyLoc = PlayerMapMarker.GetMyLocation()
    local MyChar = nil
    pcall(function()
        local GDP = PlayerMapMarker.GetGameplayData()
        if GDP and GDP.GetLocalCharacter then MyChar = GDP.GetLocalCharacter()
        else local PC = PlayerMapMarker.GetMyPlayerController() if PC and PC.GetPawn then MyChar = PC:GetPawn() end end
    end)

    local MyTeamID = PlayerMapMarker.GetTeamID(MyChar)
    local realPlayers = 0
    local botPlayers = 0

    for PlayerKey, Character in pairs(AllChars) do
        if IsValid_ESP9(Character) then
            local bIsMe = PlayerMapMarker.IsMe(Character, PlayerKey, MyKey)
            local bIsAI = PlayerMapMarker.IsAI(Character)
            local bIsAlive = PlayerMapMarker.IsAlive(Character)

            if bIsAlive and not bIsMe then
                local bIsMyTeam = false
                if MyTeamID ~= nil then
                    local targetTeamID = PlayerMapMarker.GetTeamID(Character)
                    if targetTeamID == MyTeamID then bIsMyTeam = true end
                end
                if not bIsMyTeam then
                    if bIsAI then botPlayers = botPlayers + 1
                    else realPlayers = realPlayers + 1 end
                end
            end
        end
    end

    if _G.Mod_ESP_ShowPlayerCount then
        if RedBoxOverlay.bActive then RedBoxOverlay.SetCounts(realPlayers, botPlayers)
        else RedBoxOverlay.Start() end
    else
        if RedBoxOverlay.bActive then RedBoxOverlay.Stop() end
    end

    if PlayerMapMarker.bUseScreenESP then
        PlayerMapMarker.UpdateESP(AllChars, MyLoc)
    end

    return 0
end

function PlayerMapMarker.AttachTimers()
    pcall(function()
        local pc = PlayerMapMarker.GetMyPlayerController()
        if not slua.isValid(pc) or not pc.AddGameTimer then return end

        pcall(function() pc:AddGameTimer(PlayerMapMarker.nUpdateInterval or 0.5, true, function() if PlayerMapMarker.bActive then pcall(function() PlayerMapMarker.ScanAndUpdate() end) end end) end)
        pcall(function() pc:AddGameTimer(PlayerMapMarker._LightUpdateInterval or 0.02, true, function() if PlayerMapMarker.bActive then pcall(function() PlayerMapMarker.UpdateESPLight() end) end end) end)
        pcall(function() pc:AddGameTimer(PlayerMapMarker._DistanceUpdateInterval or 0.1, true, function() if PlayerMapMarker.bActive and PlayerMapMarker.bUseScreenESP and PlayerMapMarker.bShowDistance then pcall(function() PlayerMapMarker.UpdateESPDistances() end) end end) end)
    end)
end

function PlayerMapMarker.Start()
    if PlayerMapMarker.bActive then return end
    PlayerMapMarker.bActive = true
    PlayerMapMarker._FrameCount = 0
    PlayerMapMarker.ScanAndUpdate()
    PlayerMapMarker.AttachTimers()
end

function PlayerMapMarker.Stop()
    PlayerMapMarker.bActive = false
    PlayerMapMarker._FrameCount = 0
    PlayerMapMarker.ClearAllESP()
end

_G.PlayerMapMarker = PlayerMapMarker

-- ========================================================================
-- NewFreshRuntimeTick - applies ESP toggle settings and start/stop
-- ========================================================================
function _G.NewFreshRuntimeTick()
    -- Aim features, iPad view, credit (from BRPlayerCharacterBase.lua)
    -- These functions may not exist in this context, so pcall them safely
    pcall(function() if _G.NewFreshApplyV1AimFeatures then _G.NewFreshApplyV1AimFeatures() end end)
    pcall(function() if _G.NewFreshApplyIpadView then _G.NewFreshApplyIpadView() end end)
    pcall(function() if _G.NewFreshCredit then _G.NewFreshCredit() end end)

    -- Weapon Glow
    if _G.Mod_WeaponGlow_Enabled and _G.ApplyWeaponGlow then
        pcall(function() _G.ApplyWeaponGlow(GameplayData.GetPlayerCharacter()) end)
    end

    -- ESP V2 toggle settings and start/stop
    if _G.PlayerMapMarker then
        _G.PlayerMapMarker.bUseSnapLines = _G.Mod_ESP_ShowSnapline or false
        _G.PlayerMapMarker.bShowDistance = _G.Mod_ESP_ShowDistance or false
        if _G.Mod_ESP_Enabled then
            if not _G.PlayerMapMarker.bActive then pcall(_G.PlayerMapMarker.Start) end
        elseif _G.PlayerMapMarker.bActive then
            pcall(_G.PlayerMapMarker.Stop)
        end
    end

    -- RedBoxOverlay (player count) start/stop
    if _G.RedBoxOverlay then
        if _G.Mod_ESP_Enabled and _G.Mod_ESP_ShowPlayerCount then
            if not _G.RedBoxOverlay.bActive then pcall(_G.RedBoxOverlay.Start) end
        else
            if _G.RedBoxOverlay.bActive then pcall(_G.RedBoxOverlay.Stop) end
        end
    end
end


-- ============================================================
-- WEAPON GLOW (HDR) FUNCTION
-- ============================================================
_G.ApplyWeaponGlow = function(PlayerCharacter)
    pcall(function()
        if not _G.Mod_WeaponGlow_Enabled then return end
        if not slua.isValid(PlayerCharacter) then return end

        local WeaponManager = PlayerCharacter.WeaponManagerComponent
        if not slua.isValid(WeaponManager) then return end

        local LinearColorClass = import("LinearColor") or FLinearColor
        local glowIntensity = 80.0
        local thickness = _G.WeaponGlowThickness or 3
        local colorMode = _G.WeaponGlowColor or 5

        local r, g, b = 1.0, 1.0, 0.0
        if colorMode == 1 then r, g, b = 1.0, 0.0, 0.0
        elseif colorMode == 2 then r, g, b = 1.0, 0.85, 0.0
        elseif colorMode == 3 then r, g, b = 0.0, 0.0, 1.0
        elseif colorMode == 4 then r, g, b = 1.0, 1.0, 0.0
        elseif colorMode == 5 then
            local time = os.clock() * 2.0
            r = (math.sin(time) + 1) / 2
            g = (math.sin(time + 2) + 1) / 2
            b = (math.sin(time + 4) + 1) / 2
        end

        local finalColor = LinearColorClass and LinearColorClass(r * glowIntensity, g * glowIntensity, b * glowIntensity, 1.0) or { R = r * 255 * glowIntensity, G = g * 255 * glowIntensity, B = b * 255 * glowIntensity, A = 255 }

        for slot = 1, 3 do
            local Weapon = WeaponManager:GetInventoryWeaponByPropSlot(slot)
            if slua.isValid(Weapon) then
                local ok, meshComponent = pcall(function() return import("/Script/Engine.MeshComponent") end)
                if ok then
                    local ok2, components = pcall(function() return Weapon:GetComponentsByClass(meshComponent) end)
                    if ok2 and components then
                        local count = type(components.Num) == "function" and components:Num() or #components
                        for i = 1, count do
                            local comp = type(components.Get) == "function" and components:Get(i-1) or components[i]
                            if slua.isValid(comp) then
                                pcall(function()
                                    comp.UseScopeDistanceCulling = false
                                    comp.PrimitiveShadingStrategy = 1
                                    comp.ShadingRate = 6
                                    if comp.SetDrawIdeaOutline then
                                        comp:SetDrawIdeaOutline(true)
                                        if comp.OverrideIdeaOutlineColor then comp:OverrideIdeaOutlineColor(true, finalColor) end
                                        if comp.OverrideIdeaOutlineThickness then comp:OverrideIdeaOutlineThickness(true, thickness) end
                                    elseif comp.SetRenderCustomDepth then
                                        comp:SetRenderCustomDepth(true)
                                    end
                                end)
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- Disable Weapon Glow: reset weapon outlines to normal
_G.DisableWeaponGlow = function(PlayerCharacter)
    pcall(function()
        if not slua.isValid(PlayerCharacter) then return end
        local WeaponManager = PlayerCharacter.WeaponManagerComponent
        if not slua.isValid(WeaponManager) then return end
        for slot = 1, 3 do
            local Weapon = WeaponManager:GetInventoryWeaponByPropSlot(slot)
            if slua.isValid(Weapon) then
                local ok, meshComponent = pcall(function() return import("/Script/Engine.MeshComponent") end)
                if ok then
                    local ok2, components = pcall(function() return Weapon:GetComponentsByClass(meshComponent) end)
                    if ok2 and components then
                        local count = type(components.Num) == "function" and components:Num() or #components
                        for i = 1, count do
                            local comp = type(components.Get) == "function" and components:Get(i-1) or components[i]
                            if slua.isValid(comp) then
                                pcall(function()
                                    if comp.SetDrawIdeaOutline then comp:SetDrawIdeaOutline(false) end
                                    if comp.SetRenderCustomDepth then comp:SetRenderCustomDepth(false) end
                                end)
                            end
                        end
                    end
                end
            end
        end
    end)
end


-- ============================================================
-- UNLOCK 165 FPS FUNCTION (Full hook version)
-- ============================================================
local function InitializeGraphicsUnlock()
    if _G.GraphicsUnlocked then return end

    pcall(function()
        local SettingCfg = safe_require("client.logic.setting.setting_config")
        local GraphicSettingDB = safe_require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
        if SettingCfg then
            if SettingCfg.TpViewValue then SettingCfg.TpViewValue.max = 160 end
            if SettingCfg.FpViewValue then SettingCfg.FpViewValue.max = 160 end
        end
        if GraphicSettingDB then
            if GraphicSettingDB.TpViewValue then GraphicSettingDB.TpViewValue.max = 160 end
        end
    end)

    pcall(function()
        local logic_setting_graphics = safe_require("client.slua.logic.setting.logic_setting_graphics")
        local GSC_FPS = safe_require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_FPS")
        local GSC_FPSFT = safe_require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_FPSFT")
        local GraphicSettingDB = safe_require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")

        local KismetMathLibrary = import("KismetMathLibrary") or _G.KismetMathLibrary
        local FLinearColor2 = import("LinearColor") or FLinearColor

        -- Hook SetFPS to force 165 when level 8
        if logic_setting_graphics then
            local old_SetFPS = logic_setting_graphics.SetFPS
            function logic_setting_graphics.SetFPS(gameInstance, FPSLevel)
                if old_SetFPS then old_SetFPS(gameInstance, FPSLevel) end
                if FPSLevel == 8 then
                    gameInstance:ExecuteCMD("t.MaxFPS", "165")
                    gameInstance:ExecuteCMD("r.FrameRateLimit", "165")
                end
            end
        end

        -- Hook GSC_FPS to unlock all FPS levels
        if GSC_FPS and GSC_FPS.__inner_impl then
            local fps_impl = GSC_FPS.__inner_impl
            function fps_impl:GetMaxFPSLevel() return 8, 8 end
            function fps_impl:InitRealSupportFPS()
                local RealSupportFPS = {}
                for i = 1, 8 do RealSupportFPS[i] = {true, true} end
                if GraphicSettingDB then GraphicSettingDB:UpdateUIData(GraphicSettingDB.RealSupportFPS, RealSupportFPS, false) end
                return RealSupportFPS
            end
            function fps_impl:UpdateSelectedFPSState(selectedLevel)
                if not slua.isValid(self.UIRoot) then return end
                for level = 2, 8 do
                    local name = "NodeFps" .. (({[2]=20,[3]=25,[4]=30,[5]=40,[6]=60,[7]=90,[8]=120})[level] or 120)
                    local widget = self.UIRoot[name]
                    if slua.isValid(widget) then
                        widget:SetIsEnabled(true)
                        pcall(function() widget:SetRenderOpacity(1.0) end)
                        local switcher = self.UIRoot["WidgetSwitcher_" .. level]
                        if slua.isValid(switcher) then
                            switcher:SetActiveWidgetIndex(level == selectedLevel and 0 or 1)
                        end
                    end
                end
            end
        end

        -- Hook GSC_FPSFT to allow 90-165 fine tune slider
        if GSC_FPSFT and GSC_FPSFT.__inner_impl then
            local ft_impl = GSC_FPSFT.__inner_impl
            local NMinFPS, NStep = 90, 5
            local function clamp(value, min, max)
                if value < min then return min end
                if max < value then return max end
                return value
            end
            local function lerp(a, b, t) return a + (b - a) * t end
            local function _getColorByPercent(start, finish, percent)
                if not FLinearColor2 then return nil end
                return FLinearColor2(lerp(start.R, finish.R, percent), lerp(start.G, finish.G, percent), lerp(start.B, finish.B, percent), lerp(start.A, finish.A, percent))
            end

            ft_impl.ShowOrHide = function(self)
                self:SelfHitTestInvisible()
                if self.InitFPSFTSwitch then self:InitFPSFTSwitch() end
            end

            ft_impl.InitFPSFTSwitch = function(self)
                local FPSFineTuneSwitch = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch)
                if self.UIRoot.Setting_Switch then self.UIRoot.Setting_Switch:SetSwitcherEnable2(FPSFineTuneSwitch, true) end
                if self.UIRoot.CanvasPanel_8 then self:SetWidgetVisible(self.UIRoot.CanvasPanel_8, FPSFineTuneSwitch) end
                if self.UIRoot.WidgetSwitcher_0 then self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(2) end
                if self.InitFPSFTValue165 then self:InitFPSFTValue165() end
            end

            ft_impl.InitFPSFTValue165 = function(self)
                local itemRoot = self.UIRoot
                local FPSFineTuneSwitch = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch)
                local FPSFineTuneNum = 165
                if FPSFineTuneSwitch then
                    FPSFineTuneNum = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneNum) or 165
                    itemRoot.Slider_screen3:SetLocked(false)
                    if FLinearColor2 then
                        itemRoot.ProgressBar_screen3:SetFillColorAndOpacity(FLinearColor2(1.0, 1.0, 1.0, 1.0))
                        itemRoot.Slider_screen3:SetSliderHandleColor(FLinearColor2(1.0, 1.0, 1.0, 1.0))
                    end
                else
                    itemRoot.Slider_screen3:SetLocked(true)
                    if FLinearColor2 then
                        itemRoot.ProgressBar_screen3:SetFillColorAndOpacity(FLinearColor2(1.0, 0.625, 0.6, 1))
                        itemRoot.Slider_screen3:SetSliderHandleColor(FLinearColor2(1.0, 0.625, 0.6, 1.0))
                    end
                end
                local FPSFineTunePer = (FPSFineTuneNum - NMinFPS) / (165 - NMinFPS)

                itemRoot.Veihclescreen3:SetText(tostring(FPSFineTuneNum))
                itemRoot.Slider_screen3:SetValue(FPSFineTunePer)
                itemRoot.ProgressBar_screen3:SetPercent(FPSFineTunePer)

                if FLinearColor2 then
                    local startColor = FLinearColor2(1.0, 1.0, 1.0, 1.0)
                    local midColor = FLinearColor2(1.0, 0.54, 0.11, 1.0)
                    local endColor = FLinearColor2(1.0, 0.23, 0.15, 1.0)
                    local sliderColor = FPSFineTunePer < 0.4 and startColor or _getColorByPercent(midColor, endColor, (FPSFineTunePer - 0.4) / 0.6)
                    itemRoot.Slider_screen3:SetSliderHandleColor(sliderColor)
                end
            end

            ft_impl.OnFPSFTValueChange3 = function(self, FPSFineTuneNum)
                GraphicSettingDB:UpdateUIData(GraphicSettingDB.FPSFineTuneNum, FPSFineTuneNum)
                if self.InitFPSFTValue165 then self:InitFPSFTValue165() end
                if self:GetParentUI() then self:GetParentUI():SetDirty(true) end
                local gameInstance = GraphicSettingDB.GetGameInstance and GraphicSettingDB.GetGameInstance()
                if gameInstance then
                    gameInstance:ExecuteCMD("t.MaxFPS", tostring(FPSFineTuneNum))
                    gameInstance:ExecuteCMD("r.FrameRateLimit", tostring(FPSFineTuneNum))
                end
            end

            ft_impl.OnFPSFTSliderValueChange3 = function(self, value)
                if GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch) and KismetMathLibrary then
                    local FPSFineTuneNum = KismetMathLibrary.FCeil(value * (165 - NMinFPS) / NStep) * NStep + NMinFPS
                    self:OnFPSFTValueChange3(clamp(FPSFineTuneNum, NMinFPS, 165))
                end
            end

            ft_impl.OnFPSFTAdd = ft_impl.OnFPSFTAdd3
            ft_impl.OnFPSFTMinus = ft_impl.OnFPSFTMinus3
            ft_impl.OnFPSFTAdd2 = ft_impl.OnFPSFTAdd3
            ft_impl.OnFPSFTMinus2 = ft_impl.OnFPSFTMinus3
            ft_impl.OnFPSFTSliderValueChange = ft_impl.OnFPSFTSliderValueChange3
            ft_impl.OnFPSFTSliderValueChange2 = ft_impl.OnFPSFTSliderValueChange3
        end
    end)

    -- Also run console commands directly
    pcall(function()
        local KSL = import("KismetSystemLibrary")
        local world = slua.getWorld()
        if KSL and world then
            KSL.ExecuteConsoleCommand(world, "t.MaxFPS 165")
            KSL.ExecuteConsoleCommand(world, "r.FrameRateLimit 165")
        end
    end)

    _G.GraphicsUnlocked = true
end

-- ============================================================
-- IPAD VIEW FUNCTION
-- ============================================================
local function UpdateIpadView(localPlayer, pc)
    pcall(function()
        if not isValid(localPlayer) then return end
        
        local currentVehicle = localPlayer.CurrentVehicle or (type(localPlayer.GetVehicle) == "function" and localPlayer:GetVehicle())
        local isInVehicle = isValid(currentVehicle) or localPlayer.bIsInVehicle
        local uTPPCam = localPlayer.ThirdPersonCameraComponent
        local uVehCam = localPlayer.VehicleCameraComponent
        local camMgr = pc.PlayerCameraManager
        
        -- Not aiming (walking or driving)
        if type(pc.FOV) == "function" then pc:FOV(0) end
        if isValid(camMgr) and type(camMgr.UnlockFOV) == "function" then camMgr:UnlockFOV() end
        
        -- Walk
        if not isInVehicle then
            if _G.Mod_IpadView_Enabled then
                local targetTPP = _G.IpadViewFOV or 120
                if isValid(uTPPCam) and uTPPCam.FieldOfView ~= targetTPP then
                    uTPPCam.FieldOfView = targetTPP
                end
            else
                if isValid(uTPPCam) and uTPPCam.FieldOfView ~= 90 then
                    uTPPCam.FieldOfView = 90
                end
            end
        end
        
        -- Drive (reset vehicle cam to default)
        if isInVehicle then
            if isValid(uVehCam) and uVehCam.FieldOfView ~= 90 then
                uVehCam.FieldOfView = 90
            end
        end
    end)
end

-- ============================================================
-- WHITE BODY FUNCTION
-- ============================================================
local function UpdateWhiteBody()
    pcall(function()
        local KSL = import("KismetSystemLibrary")
        local world = slua.getWorld()
        if not KSL or not world then return end
        
        if _G.Mod_WhiteBody_Enabled and not _G.PrevWhiteBody then
            KSL.ExecuteConsoleCommand(world, "r.CharacterDiffuseOffset 2")
            KSL.ExecuteConsoleCommand(world, "r.CharacterDiffusePower 5")
            KSL.ExecuteConsoleCommand(world, "r.CharacterMinShadowFactor 100")
            _G.PrevWhiteBody = true
        elseif not _G.Mod_WhiteBody_Enabled and _G.PrevWhiteBody then
            KSL.ExecuteConsoleCommand(world, "r.CharacterDiffuseOffset 0")
            KSL.ExecuteConsoleCommand(world, "r.CharacterDiffusePower 1")
            KSL.ExecuteConsoleCommand(world, "r.CharacterMinShadowFactor 1")
            _G.PrevWhiteBody = false
        end
    end)
end

-- ============================================================
-- CIRCLE & ARROW ESP FUNCTION
-- ============================================================
local function InitCircleArrowESP()
    if _G.CircleArrowESP then return end
    local CAIsValid = function(obj) return obj ~= nil and slua ~= nil and slua.isValid ~= nil and slua.isValid(obj) end
    local CAFVector2D = _G.FVector2D or import("Vector2D")
    local CAFLinearColor = _G.FLinearColor or import("LinearColor")
    local CASlateBlueprintLibrary = nil
    local CAWidgetLayoutLibrary = nil
    pcall(function() CASlateBlueprintLibrary = import("SlateBlueprintLibrary") end)
    pcall(function() CAWidgetLayoutLibrary = import("WidgetLayoutLibrary") end)

    local ESP = {}
    ESP.ArrowWidgets = {}
    ESP.FOVCircleLines = {}
    ESP.ESPCanvas = nil
    ESP.bActive = false
    ESP._cachedViewportW = 1920
    ESP._cachedViewportH = 1080
    ESP._CanvasScaleX = 1.0
    ESP._CanvasScaleY = 1.0
    ESP._CanvasOffsetX = 0.0
    ESP._CanvasOffsetY = 0.0
    ESP._EnemyCache = {}
    ESP.FOVCircleRadius = 250.0
    ESP.FOVCircleSegments = 72
    ESP.FOVCircleThickness = 4.0
    ESP.FOVCircleColor = CAFLinearColor and CAFLinearColor(1.0, 0.85, 0.0, 0.7) or {R=1,G=0.85,B=0,A=0.7}
    -- Extra glow circle for premium feel (red glow)
    ESP.FOVCircleGlowColor = CAFLinearColor and CAFLinearColor(1.0, 0.2, 0.0, 0.2) or {R=1,G=0.2,B=0,A=0.2}
    ESP.FOVCircleGlowRadius = 260.0
    ESP.FOVCircleGlowSegments = 72
    ESP.FOVCircleGlowThickness = 8.0
    -- Inner ring for depth
    ESP.FOVCircleInnerColor = CAFLinearColor and CAFLinearColor(0.8, 0.15, 0.0, 0.5) or {R=0.8,G=0.15,B=0,A=0.5}
    ESP.FOVCircleInnerRadius = 240.0
    ESP.FOVCircleInnerSegments = 72
    ESP.FOVCircleInnerThickness = 2.0
    -- Layer 4: Outer yellow accent ring (bright, sharp)
    ESP.FOVCircleOuterColor = CAFLinearColor and CAFLinearColor(1.0, 0.85, 0.0, 0.9) or {R=1,G=0.85,B=0,A=0.9}
    ESP.FOVCircleOuterRadius = 275.0
    ESP.FOVCircleOuterSegments = 72
    ESP.FOVCircleOuterThickness = 3.0
    ESP.ArrowLength = 40.0
    ESP.ArrowThickness = 40.0
    ESP.ArrowColor = CAFLinearColor and CAFLinearColor(1.0, 1.0, 0.9, 0.95) or {R=1,G=1,B=0.9,A=0.95}
    ESP.nUpdateInterval = 0.5
    ESP._LightUpdateInterval = 0.05

    function ESP.GetGameplayData()
        if ESP._CachedGameplayData then return ESP._CachedGameplayData end
        local ok, GDP = pcall(function() return require("GameLua.GameCore.Data.GameplayData") end)
        if ok and GDP then ESP._CachedGameplayData = GDP; return GDP end
        return nil
    end

    function ESP.GetMyPlayerController()
        local PC = ESP._CachedPC
        if PC and CAIsValid(PC) then return PC end
        local GDP = ESP.GetGameplayData()
        if GDP then pcall(function() PC = GDP.GetPlayerController and GDP.GetPlayerController() end) end
        if not (PC and CAIsValid(PC)) then pcall(function() if slua_GameFrontendHUD then PC = slua_GameFrontendHUD:GetPlayerController() end end) end
        if PC and CAIsValid(PC) then ESP._CachedPC = PC end
        return PC
    end

    function ESP.GetCGameState()
        if ESP._CachedCGameState and CAIsValid(ESP._CachedCGameState) then return ESP._CachedCGameState end
        local ok, GS = pcall(function() return require("GameLua.GameCore.Data.CGameState") end)
        if ok and GS then ESP._CachedCGameState = GS; return GS end
        return nil
    end

    function ESP.GetAllCharacters()
        local AllChars = {}
        pcall(function()
            local Pawns = Game:GetAllPlayerPawns()
            if Pawns then
                for _, Pawn in pairs(Pawns) do
                    if Pawn and slua.isValid(Pawn) then
                        local pKey = nil
                        if Pawn.GetPlayerKey then pKey = Pawn:GetPlayerKey() end
                        if not pKey and Pawn.PlayerKey then pKey = Pawn.PlayerKey end
                        if not pKey and Pawn.PlayerState and Pawn.PlayerState.PlayerKey then pKey = Pawn.PlayerState.PlayerKey end
                        if pKey then AllChars[pKey] = Pawn end
                    end
                end
            end
        end)
        if not next(AllChars) then
            local GS = ESP.GetCGameState()
            if GS and GS.GetAllCharacters then pcall(function() AllChars = GS:GetAllCharacters() end) end
        end
        return AllChars
    end

    function ESP.GetMyPlayerKey()
        local PC = ESP.GetMyPlayerController()
        if not CAIsValid(PC) then return nil end
        local MyKey = nil
        pcall(function()
            if PC.GetPlayerKey then MyKey = PC:GetPlayerKey()
            elseif PC.PlayerState and PC.PlayerState.PlayerKey then MyKey = PC.PlayerState.PlayerKey end
        end)
        return MyKey
    end

    function ESP.IsMe(Character, PlayerKey, MyKey)
        local bIsMe = false
        pcall(function()
            local GDP = ESP.GetGameplayData()
            if GDP and GDP.GetLocalCharacter then
                local MyChar = GDP.GetLocalCharacter()
                if MyChar and Character == MyChar then bIsMe = true; return end
            end
            local PC = ESP.GetMyPlayerController()
            if PC and PC.GetPawn then
                local Pawn = PC:GetPawn()
                if Pawn and Character == Pawn then bIsMe = true; return end
            end
        end)
        if not bIsMe and MyKey ~= nil and PlayerKey ~= nil then bIsMe = (tostring(PlayerKey) == tostring(MyKey)) end
        return bIsMe
    end

    function ESP.IsAlive(Character)
        local bAlive = true
        pcall(function()
            if Character.HealthStatus then bAlive = SecurityCommonUtils.IsHealthStatusAlive(Character.HealthStatus)
            elseif Character.IsAlive then bAlive = Character:IsAlive()
            elseif Character.Health ~= nil then bAlive = Character.Health > 0
            elseif Character.HP ~= nil then bAlive = Character.HP > 0 end
        end)
        return bAlive
    end

    function ESP.GetTeamID(Character)
        if not CAIsValid(Character) then return nil end
        local TeamID = nil
        pcall(function() if Character.GetTeamID then TeamID = Character:GetTeamID() end end)
        if not TeamID then
            pcall(function()
                local PS = nil
                if Character.GetPlayerStateSafety then PS = Character:GetPlayerStateSafety()
                elseif Character.GetPlayerState then PS = Character:GetPlayerState() end
                if CAIsValid(PS) then
                    if PS.GetTeamID then TeamID = PS:GetTeamID()
                    elseif PS.TeamID then TeamID = PS.TeamID end
                end
            end)
        end
        if not TeamID then pcall(function() if Character.TeamID then TeamID = Character.TeamID end end) end
        return TeamID
    end

    function ESP.GetCharacterLocation(Character)
        if not CAIsValid(Character) then return nil end
        local Loc = nil
        pcall(function() if Character.K2_GetActorLocation then Loc = Character:K2_GetActorLocation() end end)
        if not Loc then pcall(function() if Game and Game.GetActorLocation then Loc = Game:GetActorLocation(Character) end end) end
        return Loc
    end

    function ESP.InitESPCanvas()
        if ESP.ESPCanvas and Game:IsValid(ESP.ESPCanvas) then return true end
        local InGameUITools = nil
        pcall(function() InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools") end)
        if not InGameUITools then return false end
        local MainControlBaseUI = nil
        pcall(function() MainControlBaseUI = InGameUITools.GetMainControlBaseUI() end)
        if not MainControlBaseUI or not Game:IsValid(MainControlBaseUI) then return false end
        local ParentCanvas = nil
        pcall(function()
            if MainControlBaseUI.CanvasPanel_0 and Game:IsValid(MainControlBaseUI.CanvasPanel_0) then ParentCanvas = MainControlBaseUI.CanvasPanel_0
            elseif MainControlBaseUI.CanvasPanel_42 and Game:IsValid(MainControlBaseUI.CanvasPanel_42) then ParentCanvas = MainControlBaseUI.CanvasPanel_42 end
        end)
        if not ParentCanvas then return false end
        ESP.ESPCanvas = ParentCanvas
        return true
    end

    function ESP.UpdateCanvasTransform(PC)
        if not ESP.ESPCanvas or not Game:IsValid(ESP.ESPCanvas) then return end
        local success = false
        pcall(function()
            local SBL = CASlateBlueprintLibrary
            if SBL and SBL.AbsoluteToLocal then
                local cg = ESP.ESPCanvas:GetCachedGeometry()
                if cg then
                    local pt0 = SBL.AbsoluteToLocal(cg, CAFVector2D and CAFVector2D(0,0) or {X=0,Y=0})
                    local pt1 = SBL.AbsoluteToLocal(cg, CAFVector2D and CAFVector2D(100,100) or {X=100,Y=100})
                    if pt0 and pt1 then
                        ESP._CanvasScaleX = (pt1.X - pt0.X) / 100
                        ESP._CanvasScaleY = (pt1.Y - pt0.Y) / 100
                        ESP._CanvasOffsetX = pt0.X
                        ESP._CanvasOffsetY = pt0.Y
                        success = true
                    end
                end
            end
        end)
        if not success then
            local scale = 1.0
            local WLL = CAWidgetLayoutLibrary
            if WLL and WLL.GetViewportScale then scale = WLL.GetViewportScale(PC) or 1.0 end
            ESP._CanvasScaleX = 1.0 / scale
            ESP._CanvasScaleY = 1.0 / scale
            ESP._CanvasOffsetX = 0
            ESP._CanvasOffsetY = 0
        end
    end

    function ESP.ScreenPixelToCanvasLocal(PC, ScreenPixelPos)
        if not ScreenPixelPos then return CAFVector2D and CAFVector2D(0,0) or {X=0,Y=0} end
        local scaleX = ESP._CanvasScaleX or 1.0
        local scaleY = ESP._CanvasScaleY or 1.0
        local offsetX = ESP._CanvasOffsetX or 0
        local offsetY = ESP._CanvasOffsetY or 0
        return (CAFVector2D and CAFVector2D(ScreenPixelPos.X * scaleX + offsetX, ScreenPixelPos.Y * scaleY + offsetY)) or {X = ScreenPixelPos.X * scaleX + offsetX, Y = ScreenPixelPos.Y * scaleY + offsetY}
    end

    function ESP.GetScreenCenter(PC)
        local screenPixelW, screenPixelH = 0, 0
        local scale = 1.0
        pcall(function()
            if PC and PC.GetViewportSize then
                local vs = CAFVector2D and CAFVector2D(0,0) or {X=0,Y=0}
                PC:GetViewportSize(vs)
                if vs and vs.X and vs.X > 200 then screenPixelW, screenPixelH = vs.X, vs.Y end
            end
        end)
        if screenPixelW <= 200 then
            pcall(function()
                local WLL = CAWidgetLayoutLibrary
                if WLL and WLL.GetViewportSize then
                    local vs = WLL.GetViewportSize(PC)
                    if vs and vs.X and vs.X > 200 then screenPixelW, screenPixelH = vs.X, vs.Y end
                end
            end)
        end
        if screenPixelW <= 200 then
            screenPixelW = (ESP._cachedViewportW or 1920) * scale
            screenPixelH = (ESP._cachedViewportH or 1080) * scale
        end
        local centerPixel = CAFVector2D and CAFVector2D(screenPixelW / 2.0, screenPixelH / 2.0) or {X = screenPixelW / 2.0, Y = screenPixelH / 2.0}
        return ESP.ScreenPixelToCanvasLocal(PC, centerPixel)
    end

    function ESP.GetArrowAngleRad(PC, WorldLoc, CenterCanvas)
        local angle_rad = 0
        local ScreenPos = CAFVector2D and CAFVector2D(0,0) or {X=0,Y=0}
        local bProjectOK = false
        pcall(function()
            local res = PC:ProjectWorldLocationToScreen(WorldLoc, ScreenPos, true)
            bProjectOK = (res == true or res == 1)
        end)
        if bProjectOK then
            local canvasPos = ESP.ScreenPixelToCanvasLocal(PC, ScreenPos)
            local dx = canvasPos.X - CenterCanvas.X
            local dy = canvasPos.Y - CenterCanvas.Y
            if math.abs(dx) > 0.1 or math.abs(dy) > 0.1 then
                angle_rad = math.atan2 and math.atan2(dy, dx) or math.atan(dy, dx)
            end
        else
            pcall(function()
                local CamMgr = PC:GetPlayerCameraManager()
                if not CAIsValid(CamMgr) then return end
                local CamLoc = CamMgr:GetCameraLocation()
                local CamRot = CamMgr:GetCameraRotation()
                local dx3 = WorldLoc.X - CamLoc.X
                local dy3 = WorldLoc.Y - CamLoc.Y
                local enemyYaw = math.atan2 and math.atan2(dy3, dx3) or math.atan(dy3, dx3)
                local camYaw = math.rad(CamRot.Yaw)
                local delta = enemyYaw - camYaw
                while delta > math.pi do delta = delta - 2*math.pi end
                while delta < -math.pi do delta = delta + 2*math.pi end
                angle_rad = delta + math.pi
                while angle_rad > math.pi do angle_rad = angle_rad - 2*math.pi end
                while angle_rad < -math.pi do angle_rad = angle_rad + 2*math.pi end
            end)
        end
        return angle_rad
    end

    function ESP.UpdateCenterCircle(CenterCanvas)
        if not ESP.ESPCanvas or not Game:IsValid(ESP.ESPCanvas) then ESP.RemoveCenterCircle() return end
        local cx = CenterCanvas.X
        local cy = CenterCanvas.Y
        if not ESP.FOVCircleLines then ESP.FOVCircleLines = {} end
        if not ESP.FOVCircleGlowLines then ESP.FOVCircleGlowLines = {} end
        if not ESP.FOVCircleInnerLines then ESP.FOVCircleInnerLines = {} end
        if not ESP.FOVCircleOuterLines then ESP.FOVCircleOuterLines = {} end

        -- Helper to draw a circle ring
        local function DrawRing(linesTable, radius, segments, thickness, color, zorder)
            for i = 1, segments do
                local angle1 = ((i-1) / segments) * (2 * math.pi)
                local angle2 = (i / segments) * (2 * math.pi)
                local x1 = cx + math.cos(angle1) * radius
                local y1 = cy + math.sin(angle1) * radius
                local x2 = cx + math.cos(angle2) * radius
                local y2 = cy + math.sin(angle2) * radius
                local dx = x2 - x1
                local dy = y2 - y1
                local len = math.sqrt(dx*dx + dy*dy)
                local ang = (math.atan2 and math.atan2(dy,dx) or math.atan(dy,dx)) * (180.0 / math.pi)
                local lineData = linesTable[i]
                if not lineData then
                    local Border = nil
                    pcall(function() Border = CGame:NewObjectFromPath("/Script/UMG.Border", ESP.ESPCanvas) end)
                    if Border and slua.isValid(Border) then
                        pcall(function() Border:SetBrushColor(color) end)
                        pcall(function() Border:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
                        pcall(function() Border:SetRenderTransformPivot(CAFVector2D and CAFVector2D(0.0, 0.5) or {X=0,Y=0.5}) end)
                        local Slot = ESP.ESPCanvas:AddChildToCanvas(Border)
                        if Slot then Slot:SetAutoSize(false); Slot:SetZOrder(zorder) end
                        lineData = { Widget = Border, Slot = Slot }
                        linesTable[i] = lineData
                    end
                end
                if lineData and lineData.Slot then
                    pcall(function()
                        lineData.Slot:SetPosition(CAFVector2D and CAFVector2D(x1, y1 - thickness/2.0) or {X=x1, Y=y1 - thickness/2.0})
                        lineData.Slot:SetSize(CAFVector2D and CAFVector2D(len + 0.5, thickness) or {X=len+0.5, Y=thickness})
                        lineData.Widget:SetRenderAngle(ang)
                        lineData.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                    end)
                end
            end
        end

        -- Only 1 main circle (bright yellow, sharp)
        DrawRing(ESP.FOVCircleLines, ESP.FOVCircleRadius or 300.0, ESP.FOVCircleSegments or 72, ESP.FOVCircleThickness or 4.0, ESP.FOVCircleColor, 1)
    end

    function ESP.RemoveCenterCircle()
        if ESP.FOVCircleLines then
            for _, lineData in pairs(ESP.FOVCircleLines) do
                if lineData and lineData.Widget and slua.isValid(lineData.Widget) then
                    pcall(function() lineData.Widget:RemoveFromParent() lineData.Widget:ConditionalBeginDestroy() end)
                end
            end
        end
        if ESP.FOVCircleGlowLines then
            for _, lineData in pairs(ESP.FOVCircleGlowLines) do
                if lineData and lineData.Widget and slua.isValid(lineData.Widget) then
                    pcall(function() lineData.Widget:RemoveFromParent() lineData.Widget:ConditionalBeginDestroy() end)
                end
            end
        end
        if ESP.FOVCircleInnerLines then
            for _, lineData in pairs(ESP.FOVCircleInnerLines) do
                if lineData and lineData.Widget and slua.isValid(lineData.Widget) then
                    pcall(function() lineData.Widget:RemoveFromParent() lineData.Widget:ConditionalBeginDestroy() end)
                end
            end
        end
        if ESP.FOVCircleOuterLines then
            for _, lineData in pairs(ESP.FOVCircleOuterLines) do
                if lineData and lineData.Widget and slua.isValid(lineData.Widget) then
                    pcall(function() lineData.Widget:RemoveFromParent() lineData.Widget:ConditionalBeginDestroy() end)
                end
            end
        end
        ESP.FOVCircleLines = {}
        ESP.FOVCircleGlowLines = {}
        ESP.FOVCircleInnerLines = {}
        ESP.FOVCircleOuterLines = {}
    end

    function ESP.CreateArrowWidget()
        if not ESP.ESPCanvas or not Game:IsValid(ESP.ESPCanvas) then return nil end

        -- Layer 1: Outer glow halo (largest, very transparent)
        local GlowBorder = nil
        pcall(function() GlowBorder = CGame:NewObjectFromPath("/Script/UMG.Border", ESP.ESPCanvas) end)
        if GlowBorder and slua.isValid(GlowBorder) then
            pcall(function() GlowBorder:SetBrushColor(CAFLinearColor and CAFLinearColor(1.0, 0.5, 0.0, 0.1) or {R=1,G=0.5,B=0,A=0.1}) end)
            pcall(function() GlowBorder:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
            pcall(function() GlowBorder:SetRenderTransformPivot(CAFVector2D and CAFVector2D(0.5, 0.5) or {X=0.5,Y=0.5}) end)
        end
        local GlowSlot = nil
        pcall(function()
            GlowSlot = ESP.ESPCanvas:AddChildToCanvas(GlowBorder)
            if GlowSlot then GlowSlot:SetAutoSize(false); GlowSlot:SetZOrder(0) end
        end)

        -- Layer 2: Mid glow (orange aura)
        local MidGlowBorder = nil
        pcall(function() MidGlowBorder = CGame:NewObjectFromPath("/Script/UMG.Border", ESP.ESPCanvas) end)
        if MidGlowBorder and slua.isValid(MidGlowBorder) then
            pcall(function() MidGlowBorder:SetBrushColor(CAFLinearColor and CAFLinearColor(1.0, 0.65, 0.0, 0.2) or {R=1,G=0.65,B=0,A=0.2}) end)
            pcall(function() MidGlowBorder:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
            pcall(function() MidGlowBorder:SetRenderTransformPivot(CAFVector2D and CAFVector2D(0.5, 0.5) or {X=0.5,Y=0.5}) end)
        end
        local MidGlowSlot = nil
        pcall(function()
            MidGlowSlot = ESP.ESPCanvas:AddChildToCanvas(MidGlowBorder)
            if MidGlowSlot then MidGlowSlot:SetAutoSize(false); MidGlowSlot:SetZOrder(1) end
        end)

        -- Layer 3: Golden ring (medium, semi-transparent)
        local RingBorder = nil
        pcall(function() RingBorder = CGame:NewObjectFromPath("/Script/UMG.Border", ESP.ESPCanvas) end)
        if RingBorder and slua.isValid(RingBorder) then
            pcall(function() RingBorder:SetBrushColor(CAFLinearColor and CAFLinearColor(0.85, 0.45, 0.0, 0.5) or {R=0.85,G=0.45,B=0,A=0.5}) end)
            pcall(function() RingBorder:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
            pcall(function() RingBorder:SetRenderTransformPivot(CAFVector2D and CAFVector2D(0.5, 0.5) or {X=0.5,Y=0.5}) end)
        end
        local RingSlot = nil
        pcall(function()
            RingSlot = ESP.ESPCanvas:AddChildToCanvas(RingBorder)
            if RingSlot then RingSlot:SetAutoSize(false); RingSlot:SetZOrder(2) end
        end)

        -- Layer 4: Main bright diamond (core)
        local Border = nil
        pcall(function() Border = CGame:NewObjectFromPath("/Script/UMG.Border", ESP.ESPCanvas) end)
        if not Border or not slua.isValid(Border) then return nil end
        pcall(function() Border:SetBrushColor(ESP.ArrowColor) end)
        pcall(function() Border:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
        pcall(function() Border:SetRenderTransformPivot(CAFVector2D and CAFVector2D(0.5, 0.5) or {X=0.5,Y=0.5}) end)
        local Slot = nil
        pcall(function()
            Slot = ESP.ESPCanvas:AddChildToCanvas(Border)
            if Slot then Slot:SetAutoSize(false); Slot:SetZOrder(4) end
        end)

        -- Layer 5: Inner gold core (medium)
        local InnerGoldBorder = nil
        pcall(function() InnerGoldBorder = CGame:NewObjectFromPath("/Script/UMG.Border", ESP.ESPCanvas) end)
        if InnerGoldBorder and slua.isValid(InnerGoldBorder) then
            pcall(function() InnerGoldBorder:SetBrushColor(CAFLinearColor and CAFLinearColor(1.0, 0.9, 0.3, 0.9) or {R=1,G=0.9,B=0.3,A=0.9}) end)
            pcall(function() InnerGoldBorder:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
            pcall(function() InnerGoldBorder:SetRenderTransformPivot(CAFVector2D and CAFVector2D(0.5, 0.5) or {X=0.5,Y=0.5}) end)
        end
        local InnerGoldSlot = nil
        pcall(function()
            InnerGoldSlot = ESP.ESPCanvas:AddChildToCanvas(InnerGoldBorder)
            if InnerGoldSlot then InnerGoldSlot:SetAutoSize(false); InnerGoldSlot:SetZOrder(5) end
        end)

        -- Layer 6: Bright white-yellow center (tiny, sharp)
        local CoreBorder = nil
        pcall(function() CoreBorder = CGame:NewObjectFromPath("/Script/UMG.Border", ESP.ESPCanvas) end)
        if CoreBorder and slua.isValid(CoreBorder) then
            pcall(function() CoreBorder:SetBrushColor(CAFLinearColor and CAFLinearColor(1.0, 1.0, 0.9, 1.0) or {R=1,G=1,B=0.9,A=1}) end)
            pcall(function() CoreBorder:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
            pcall(function() CoreBorder:SetRenderTransformPivot(CAFVector2D and CAFVector2D(0.5, 0.5) or {X=0.5,Y=0.5}) end)
        end
        local CoreSlot = nil
        pcall(function()
            CoreSlot = ESP.ESPCanvas:AddChildToCanvas(CoreBorder)
            if CoreSlot then CoreSlot:SetAutoSize(false); CoreSlot:SetZOrder(6) end
        end)

        return { Widget = Border, Slot = Slot, GlowWidget = GlowBorder, GlowSlot = GlowSlot, RingWidget = RingBorder, RingSlot = RingSlot, CoreWidget = CoreBorder, CoreSlot = CoreSlot, MidGlowWidget = MidGlowBorder, MidGlowSlot = MidGlowSlot, InnerGoldWidget = InnerGoldBorder, InnerGoldSlot = InnerGoldSlot }
    end

    function ESP.UpdateDirectionalArrow(KeyStr, WorldLoc, PC, CenterCanvas)
        if not ESP.ESPCanvas or not Game:IsValid(ESP.ESPCanvas) then return end
        if not WorldLoc then
            local ld = ESP.ArrowWidgets[KeyStr]
            if ld and ld.Widget and slua.isValid(ld.Widget) then
                pcall(function() ld.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
            end
            return
        end
        local angle_rad = ESP.GetArrowAngleRad(PC, WorldLoc, CenterCanvas)
        local angle_deg = angle_rad * (180.0 / math.pi)
        local radius = ESP.FOVCircleRadius or 150.0
        local markSize = ESP.ArrowLength or 30.0
        local startX = CenterCanvas.X + math.cos(angle_rad) * radius
        local startY = CenterCanvas.Y + math.sin(angle_rad) * radius
        local LineData = ESP.ArrowWidgets[KeyStr]
        if not LineData then
            LineData = ESP.CreateArrowWidget()
            if not LineData or not LineData.Widget or not LineData.Slot then return end
            ESP.ArrowWidgets[KeyStr] = LineData
        end
        pcall(function()
            local halfSize = markSize / 2.0
            local ringSize = markSize * 1.3
            local halfRing = ringSize / 2.0
            local glowSize = markSize * 2.0
            local halfGlow = glowSize / 2.0
            local midGlowSize = markSize * 1.5
            local halfMidGlow = midGlowSize / 2.0
            local innerGoldSize = markSize * 0.55
            local halfInnerGold = innerGoldSize / 2.0
            local coreSize = markSize * 0.25
            local halfCore = coreSize / 2.0
            local diamondRot = angle_deg + 45.0

            -- Layer 4: Main diamond
            LineData.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            LineData.Slot:SetPosition(CAFVector2D and CAFVector2D(startX - halfSize, startY - halfSize) or {X=startX - halfSize, Y=startY - halfSize})
            LineData.Slot:SetSize(CAFVector2D and CAFVector2D(markSize, markSize) or {X=markSize, Y=markSize})
            LineData.Widget:SetRenderAngle(diamondRot)

            -- Layer 1: Outer glow halo
            if LineData.GlowWidget and LineData.GlowSlot then
                pcall(function()
                    LineData.GlowWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                    LineData.GlowSlot:SetPosition(CAFVector2D and CAFVector2D(startX - halfGlow, startY - halfGlow) or {X=startX - halfGlow, Y=startY - halfGlow})
                    LineData.GlowSlot:SetSize(CAFVector2D and CAFVector2D(glowSize, glowSize) or {X=glowSize, Y=glowSize})
                    LineData.GlowWidget:SetRenderAngle(diamondRot)
                end)
            end

            -- Layer 2: Mid glow aura
            if LineData.MidGlowWidget and LineData.MidGlowSlot then
                pcall(function()
                    LineData.MidGlowWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                    LineData.MidGlowSlot:SetPosition(CAFVector2D and CAFVector2D(startX - halfMidGlow, startY - halfMidGlow) or {X=startX - halfMidGlow, Y=startY - halfMidGlow})
                    LineData.MidGlowSlot:SetSize(CAFVector2D and CAFVector2D(midGlowSize, midGlowSize) or {X=midGlowSize, Y=midGlowSize})
                    LineData.MidGlowWidget:SetRenderAngle(diamondRot)
                end)
            end

            -- Layer 3: Golden ring
            if LineData.RingWidget and LineData.RingSlot then
                pcall(function()
                    LineData.RingWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                    LineData.RingSlot:SetPosition(CAFVector2D and CAFVector2D(startX - halfRing, startY - halfRing) or {X=startX - halfRing, Y=startY - halfRing})
                    LineData.RingSlot:SetSize(CAFVector2D and CAFVector2D(ringSize, ringSize) or {X=ringSize, Y=ringSize})
                    LineData.RingWidget:SetRenderAngle(diamondRot)
                end)
            end

            -- Layer 5: Inner gold core
            if LineData.InnerGoldWidget and LineData.InnerGoldSlot then
                pcall(function()
                    LineData.InnerGoldWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                    LineData.InnerGoldSlot:SetPosition(CAFVector2D and CAFVector2D(startX - halfInnerGold, startY - halfInnerGold) or {X=startX - halfInnerGold, Y=startY - halfInnerGold})
                    LineData.InnerGoldSlot:SetSize(CAFVector2D and CAFVector2D(innerGoldSize, innerGoldSize) or {X=innerGoldSize, Y=innerGoldSize})
                    LineData.InnerGoldWidget:SetRenderAngle(diamondRot)
                end)
            end

            -- Layer 6: Bright white-yellow center
            if LineData.CoreWidget and LineData.CoreSlot then
                pcall(function()
                    LineData.CoreWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                    LineData.CoreSlot:SetPosition(CAFVector2D and CAFVector2D(startX - halfCore, startY - halfCore) or {X=startX - halfCore, Y=startY - halfCore})
                    LineData.CoreSlot:SetSize(CAFVector2D and CAFVector2D(coreSize, coreSize) or {X=coreSize, Y=coreSize})
                    LineData.CoreWidget:SetRenderAngle(diamondRot)
                end)
            end
        end)
    end

    function ESP.RemoveArrow(KeyStr)
        local LineData = ESP.ArrowWidgets[KeyStr]
        if LineData then
            if LineData.Widget and slua.isValid(LineData.Widget) then
                pcall(function() LineData.Widget:RemoveFromParent() LineData.Widget:ConditionalBeginDestroy() end)
            end
            if LineData.GlowWidget and slua.isValid(LineData.GlowWidget) then
                pcall(function() LineData.GlowWidget:RemoveFromParent() LineData.GlowWidget:ConditionalBeginDestroy() end)
            end
            if LineData.MidGlowWidget and slua.isValid(LineData.MidGlowWidget) then
                pcall(function() LineData.MidGlowWidget:RemoveFromParent() LineData.MidGlowWidget:ConditionalBeginDestroy() end)
            end
            if LineData.RingWidget and slua.isValid(LineData.RingWidget) then
                pcall(function() LineData.RingWidget:RemoveFromParent() LineData.RingWidget:ConditionalBeginDestroy() end)
            end
            if LineData.InnerGoldWidget and slua.isValid(LineData.InnerGoldWidget) then
                pcall(function() LineData.InnerGoldWidget:RemoveFromParent() LineData.InnerGoldWidget:ConditionalBeginDestroy() end)
            end
            if LineData.CoreWidget and slua.isValid(LineData.CoreWidget) then
                pcall(function() LineData.CoreWidget:RemoveFromParent() LineData.CoreWidget:ConditionalBeginDestroy() end)
            end
        end
        ESP.ArrowWidgets[KeyStr] = nil
    end

    function ESP.ClearAllArrows()
        for KeyStr, LineData in pairs(ESP.ArrowWidgets) do
            if LineData then
                if LineData.Widget and slua.isValid(LineData.Widget) then
                    pcall(function() LineData.Widget:RemoveFromParent() LineData.Widget:ConditionalBeginDestroy() end)
                end
                if LineData.GlowWidget and slua.isValid(LineData.GlowWidget) then
                    pcall(function() LineData.GlowWidget:RemoveFromParent() LineData.GlowWidget:ConditionalBeginDestroy() end)
                end
                if LineData.MidGlowWidget and slua.isValid(LineData.MidGlowWidget) then
                    pcall(function() LineData.MidGlowWidget:RemoveFromParent() LineData.MidGlowWidget:ConditionalBeginDestroy() end)
                end
                if LineData.RingWidget and slua.isValid(LineData.RingWidget) then
                    pcall(function() LineData.RingWidget:RemoveFromParent() LineData.RingWidget:ConditionalBeginDestroy() end)
                end
                if LineData.InnerGoldWidget and slua.isValid(LineData.InnerGoldWidget) then
                    pcall(function() LineData.InnerGoldWidget:RemoveFromParent() LineData.InnerGoldWidget:ConditionalBeginDestroy() end)
                end
                if LineData.CoreWidget and slua.isValid(LineData.CoreWidget) then
                    pcall(function() LineData.CoreWidget:RemoveFromParent() LineData.CoreWidget:ConditionalBeginDestroy() end)
                end
            end
        end
        ESP.ArrowWidgets = {}
    end

    function ESP.ScanAndUpdate()
        if not ESP.InitESPCanvas() then return end
        local PC = ESP.GetMyPlayerController()
        if not CAIsValid(PC) then return end
        ESP.UpdateCanvasTransform(PC)
        local centerCanvas = ESP.GetScreenCenter(PC)
        ESP.UpdateCenterCircle(centerCanvas)
        local AllChars = ESP.GetAllCharacters()
        if not AllChars then return end
        local MyKey = ESP.GetMyPlayerKey()
        local MyChar = nil
        pcall(function()
            local GDP = ESP.GetGameplayData()
            if GDP and GDP.GetLocalCharacter then MyChar = GDP.GetLocalCharacter()
            elseif PC and PC.GetPawn then MyChar = PC:GetPawn() end
        end)
        local MyTeamID = ESP.GetTeamID(MyChar)
        local SeenKeys = {}
        for PlayerKey, Character in pairs(AllChars) do
            if CAIsValid(Character) then
                local bIsMe = ESP.IsMe(Character, PlayerKey, MyKey)
                local KeyStr = tostring(PlayerKey)
                local bAlive = ESP.IsAlive(Character)
                local TeamID = ESP.GetTeamID(Character)
                local bSkip = bIsMe
                if MyTeamID ~= nil and TeamID == MyTeamID and not bIsMe then bSkip = true end
                if not bAlive then bSkip = true end
                if not bSkip then
                    SeenKeys[KeyStr] = true
                    ESP._EnemyCache[KeyStr] = Character
                    local Loc = ESP.GetCharacterLocation(Character)
                    ESP.UpdateDirectionalArrow(KeyStr, Loc, PC, centerCanvas)
                end
            end
        end
        for KeyStr in pairs(ESP.ArrowWidgets) do
            if not SeenKeys[KeyStr] then ESP.RemoveArrow(KeyStr); ESP._EnemyCache[KeyStr] = nil end
        end
    end

    function ESP.UpdateLight()
        if not ESP.ESPCanvas or not Game:IsValid(ESP.ESPCanvas) then return end
        local PC = ESP.GetMyPlayerController()
        if not CAIsValid(PC) then return end
        ESP.UpdateCanvasTransform(PC)
        local centerCanvas = ESP.GetScreenCenter(PC)
        for KeyStr, Character in pairs(ESP._EnemyCache) do
            if CAIsValid(Character) and ESP.IsAlive(Character) then
                local Loc = ESP.GetCharacterLocation(Character)
                ESP.UpdateDirectionalArrow(KeyStr, Loc, PC, centerCanvas)
            else
                ESP.RemoveArrow(KeyStr)
                ESP._EnemyCache[KeyStr] = nil
            end
        end
    end

    function ESP.AttachTimers()
        pcall(function()
            local pc = ESP.GetMyPlayerController()
            if not slua.isValid(pc) or not pc.AddGameTimer then return end
            local now = os.time()
            local lastPC = ESP._ActiveTimerPC
            if lastPC and slua.isValid(lastPC) and lastPC == pc then
                if ESP._ActiveTimerTick and (now - ESP._ActiveTimerTick) < 5 then return end
            end
            ESP._ActiveTimerPC = pc
            ESP._ActiveTimerTick = now
            pcall(function()
                pc:AddGameTimer(ESP.nUpdateInterval or 0.5, true, function()
                    ESP._ActiveTimerTick = os.time()
                    if ESP.bActive then pcall(function() ESP.ScanAndUpdate() end) end
                end)
            end)
            pcall(function()
                pc:AddGameTimer(ESP._LightUpdateInterval or 0.05, true, function()
                    ESP._ActiveTimerTick = os.time()
                    if ESP.bActive then pcall(function() ESP.UpdateLight() end) end
                end)
            end)
        end)
    end

    function ESP.Start()
        if ESP.bActive then return end
        ESP.bActive = true
        ESP.ScanAndUpdate()
        ESP.AttachTimers()
    end

    function ESP.Stop()
        ESP.bActive = false
        ESP.ClearAllArrows()
        ESP.RemoveCenterCircle()
        ESP._EnemyCache = {}
        ESP.ESPCanvas = nil
    end

    _G.CircleArrowESP = ESP
end

-- ============================================================
-- MAIN UPDATE LOOP (CHAMS + ESP V2 + WEAPON GLOW + IPAD + WHITE BODY + FPS + CIRCLE ARROW)
-- ============================================================
local function MainUpdate()
    pcall(function()
        local localPlayer = GameplayData and GameplayData.GetPlayerCharacter()
        if not slua.isValid(localPlayer) then return end

        -- Update Chams
        if _G.Mod_Chams_Enabled then
            EnableChamsConsole()
            if colors then
                tickCount = tickCount + 1
                if tickCount % 6 == 0 then processedPawns = {} end
                local myTeamID = localPlayer.TeamID
                local allChars = Game:GetAllPlayerPawns() or {}
                local count = 0
                for _, target in pairs(allChars) do
                    if count >= 20 then break end
                    local playerKey = target.PlayerKey
                    if not (playerKey and processedPawns[playerKey]) then
                        if ProcessEnemy_Chams(target, myTeamID) then count = count + 1 end
                    end
                end
            end
        else
            -- Chams turned OFF: disable and reset meshes
            if chamsReady then
                DisableChams()
            end
        end

        -- Update ESP V2 (PlayerMapMarker + RedBoxOverlay)
        if _G.Mod_ESP_Enabled then
            if _G.PlayerMapMarker then
                _G.PlayerMapMarker.bUseSnapLines = _G.Mod_ESP_ShowSnapline or false
                _G.PlayerMapMarker.bShowDistance = _G.Mod_ESP_ShowDistance or false
                if not _G.PlayerMapMarker.bActive then
                    pcall(_G.PlayerMapMarker.Start)
                end
            end
            if _G.RedBoxOverlay then
                if _G.Mod_ESP_ShowPlayerCount then
                    if not _G.RedBoxOverlay.bActive then pcall(_G.RedBoxOverlay.Start) end
                else
                    if _G.RedBoxOverlay.bActive then pcall(_G.RedBoxOverlay.Stop) end
                end
            end
        else
            if _G.PlayerMapMarker and _G.PlayerMapMarker.bActive then
                pcall(_G.PlayerMapMarker.Stop)
            end
            if _G.RedBoxOverlay and _G.RedBoxOverlay.bActive then
                pcall(_G.RedBoxOverlay.Stop)
            end
        end

        -- Call NewFreshRuntimeTick for aim features, iPad view, ESP toggles, etc.
        pcall(_G.NewFreshRuntimeTick)

        -- Update Weapon Glow (HDR)
        if not _G.LastGlowTime or (os.clock() - _G.LastGlowTime) > 0.5 then
            _G.LastGlowTime = os.clock()
            if _G.Mod_WeaponGlow_Enabled then
                if _G.ApplyWeaponGlow then _G.ApplyWeaponGlow(localPlayer) end
            else
                -- Weapon Glow turned OFF: reset weapon outlines
                if _G.DisableWeaponGlow then _G.DisableWeaponGlow(localPlayer) end
            end
        end

        -- Update Unlock 165 FPS
        if _G.Mod_UnlockFPS_Enabled and not _G.GraphicsUnlocked then
            InitializeGraphicsUnlock()
        end

        -- Update iPad View
        local uCon = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if isValid(uCon) then
            UpdateIpadView(localPlayer, uCon)
        end

        -- Update White Body
        UpdateWhiteBody()

        -- Update Circle & Arrow ESP
        if _G.Mod_CircleArrow_Enabled then
            if not _G.CircleArrowESP then InitCircleArrowESP() end
            if _G.CircleArrowESP and not _G.CircleArrowESP.bActive then
                pcall(_G.CircleArrowESP.Start)
            end
        else
            if _G.CircleArrowESP and _G.CircleArrowESP.bActive then
                pcall(_G.CircleArrowESP.Stop)
            end
        end

    end)
end


-- ============================================================
-- START MODULES
-- ============================================================
pcall(function()
    if _G._ESPWatchdogHandle then pcall(function() Game:ClearTimer(_G._ESPWatchdogHandle) end); _G._ESPWatchdogHandle = nil end

    local function StartESP_Watchdog(targetActor)
        if not isValid(targetActor) then return end
        _G._ESPTimerChar = targetActor
        _G._ESPTimerHandle = targetActor:AddGameTimer(0.2, true, function()
            pcall(MainUpdate)
        end)
    end

    local function Watchdog()
        pcall(function()
            local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
            local curPawn = pc and pc:GetCurPawn()
            if isValid(curPawn) and _G._ESPTimerChar ~= curPawn then
                if _G._ESPTimerHandle and isValid(_G._ESPTimerChar) then
                    pcall(function() _G._ESPTimerChar:RemoveGameTimer(_G._ESPTimerHandle) end)
                end
                _G._ESPTimerHandle = nil
                StartESP_Watchdog(curPawn)
            elseif not _G._ESPTimerHandle then
                StartESP_Watchdog(curPawn)
            end
        end)
    end

    _G._ESPWatchdogHandle = Game:SetTimer(1.0, true, Watchdog)
    Watchdog()
end)



-- ============================================================
-- LUXURY MENU UI - FROM 1.lua (old game menu removed)
-- ============================================================
do

-- ============================================================
-- VIP MENU UI - LUXURY EDITION v15
-- MOD DEVELOPER @GRW_XD
-- Luxury: deep glass gradients, dual gold+red accent system,
-- premium toggle switches, rich depth shadows, refined spacing
-- ============================================================

local IsValid = function(obj) return obj and slua and slua.isValid and slua.isValid(obj) end
local FLinearColor = import("LinearColor")
local FVector2D = import("Vector2D")
local FSlateColor = import("SlateColor") or import("/Script/SlateCore.SlateColor")

-- ===== LUXURY COLOR PALETTE v15 =====
local C = {
    -- Neon glass / black base
    bg_glass1 = FLinearColor(0.005, 0.008, 0.018, 0.98),
    bg_glass2 = FLinearColor(0.010, 0.015, 0.030, 0.98),
    bg_glass3 = FLinearColor(0.020, 0.025, 0.045, 0.98),
    bg_main   = FLinearColor(0.006, 0.008, 0.018, 1.0),
    bg_header = FLinearColor(0.008, 0.010, 0.022, 1.0),
    bg_header2= FLinearColor(0.012, 0.018, 0.035, 1.0),
    bg_header3= FLinearColor(0.025, 0.030, 0.055, 1.0),
    bg_dark   = FLinearColor(0.005, 0.007, 0.015, 1.0),
    bg_light  = FLinearColor(0.025, 0.030, 0.055, 1.0),
    bg_row    = FLinearColor(0.012, 0.018, 0.034, 0.98),
    bg_row_alt= FLinearColor(0.018, 0.024, 0.045, 0.98),
    bg_tab   = FLinearColor(0.008, 0.014, 0.028, 1.0),
    bg_tab_active = FLinearColor(0.055, 0.015, 0.055, 1.0),

    -- Gold / yellow
    gold = FLinearColor(1.0, 0.72, 0.04, 1.0),
    gold_bright = FLinearColor(1.0, 0.88, 0.16, 1.0),
    gold_dark = FLinearColor(0.45, 0.26, 0.02, 1.0),
    gold_deep = FLinearColor(0.20, 0.10, 0.01, 1.0),
    gold_glow = FLinearColor(1.0, 0.72, 0.04, 0.10),
    gold_glow_strong = FLinearColor(1.0, 0.72, 0.04, 0.18),
    yellow = FLinearColor(1.0, 0.78, 0.06, 1.0),

    -- Neon accents
    red = FLinearColor(1.0, 0.08, 0.12, 1.0),
    red_bright = FLinearColor(1.0, 0.12, 0.22, 1.0),
    red_dark = FLinearColor(0.55, 0.015, 0.05, 1.0),
    red_deep = FLinearColor(0.28, 0.008, 0.025, 1.0),
    red_glow = FLinearColor(1.0, 0.08, 0.12, 0.10),
    cyan = FLinearColor(0.05, 0.88, 1.0, 1.0),
    blue = FLinearColor(0.08, 0.35, 1.0, 1.0),
    violet = FLinearColor(0.72, 0.18, 1.0, 1.0),
    magenta = FLinearColor(1.0, 0.08, 0.72, 1.0),
    green = FLinearColor(0.08, 1.0, 0.36, 1.0),

    white = FLinearColor(0.96, 0.98, 1.0, 1.0),
    text_bright = FLinearColor(1.0, 1.0, 1.0, 1.0),
    text_dim = FLinearColor(0.55, 0.62, 0.72, 1.0),
    text_label = FLinearColor(0.90, 0.94, 1.0, 1.0),
    text_grey = FLinearColor(0.52, 0.58, 0.68, 1.0),

    divider = FLinearColor(0.08, 0.13, 0.22, 1.0),
    divider_gold = FLinearColor(0.32, 0.20, 0.02, 1.0),
    divider_red = FLinearColor(0.38, 0.025, 0.08, 1.0),
    border_gold = FLinearColor(0.80, 0.46, 0.02, 1.0),
    border_dark = FLinearColor(0.015, 0.020, 0.040, 1.0),

    close_bg = FLinearColor(0.60, 0.015, 0.06, 1.0),
    shadow1 = FLinearColor(0.0, 0.0, 0.0, 0.86),
    shadow2 = FLinearColor(0.0, 0.0, 0.0, 0.64),
    shadow3 = FLinearColor(0.0, 0.0, 0.0, 0.44),
    shadow4 = FLinearColor(0.0, 0.0, 0.0, 0.25),
    shadow5 = FLinearColor(0.0, 0.0, 0.0, 0.14),
    glow_yellow = FLinearColor(1.0, 0.72, 0.04, 0.10),
    glow_red = FLinearColor(1.0, 0.08, 0.12, 0.08),
    transparent = FLinearColor(0, 0, 0, 0.01),
    black = FLinearColor(0.0, 0.0, 0.0, 1.0),
}

-- ===== MULTI-COLOR VIP ACCENT PALETTE =====
local ACCENTS = {
    { c = C.red_bright, bg = FLinearColor(0.28, 0.015, 0.035, 1.0) },
    { c = C.cyan,       bg = FLinearColor(0.015, 0.12, 0.18, 1.0) },
    { c = C.violet,     bg = FLinearColor(0.15, 0.025, 0.22, 1.0) },
    { c = C.magenta,    bg = FLinearColor(0.24, 0.015, 0.14, 1.0) },
    { c = C.gold_bright,bg = FLinearColor(0.20, 0.13, 0.015, 1.0) },
}

local M_W = 700
local M_H = 920
local ROW_H = 54
local HEADER_H = 150
local TAB_H = 58

-- ===== VIP EXPIRY / LICENSE SYSTEM =====
-- Change only this date when you need to renew the VIP access.
local VIP_EXPIRE_DATE = "2026-10-17 23:59:59"
local VIP_EXPIRE_LABEL = "17 OCT 2026"

local function GetVipExpireTime()
    local y, mo, d, h, mi, sec = VIP_EXPIRE_DATE:match("^(%d%d%d%d)%-(%d%d)%-(%d%d) (%d%d):(%d%d):(%d%d)$")
    if not y then return nil end
    return os.time({year=tonumber(y), month=tonumber(mo), day=tonumber(d), hour=tonumber(h), min=tonumber(mi), sec=tonumber(sec)})
end

local function GetVipExpiryInfo()
    local expireAt = GetVipExpireTime()
    if not expireAt then
        return false, "EXPIRY CONFIG ERROR", 0
    end
    local now = os.time()
    local remaining = expireAt - now
    if remaining <= 0 then
        return true, "EXPIRED", 0
    end
    local days = math.floor(remaining / 86400)
    local hours = math.floor((remaining % 86400) / 3600)
    return false, string.format("%dd %02dh", days, hours), remaining
end

local function IsVipExpired()
    local expired = GetVipExpiryInfo()
    return expired == true
end

_G.HUSSNAIN_VIP_EXPIRE_DATE = VIP_EXPIRE_DATE
_G.HUSSNAIN_VIP_EXPIRE_LABEL = VIP_EXPIRE_LABEL

_G.VIPConfig = _G.VIPConfig or {
    ESP_Enabled = true, ESP_HealthBar = true, ESP_Distance = true,      ESP_WeaponIcon = false, ESP_Name = false,
    ESP_Line = false, ESP_Vehicle = false, ESP_Item = false,
    ESP_Airdrop = false, ESP_Enemy = false, ESP_Team = false,
    ESP_Skeleton = false, ESP_Radar = false, ESP_TotalCount = false,
    AIM_Enabled = false, AIM_Bot = false, AIM_Silent = false,
    AIM_FOV = false, AIM_Smooth = false, AIM_Visible = false,
    AIM_Distance = false, AIM_Bone = false,
    SKIN_M416 = false, SKIN_AKM = false, SKIN_AWM = false,
    SKIN_KAR98 = false, SKIN_UMP45 = false, SKIN_SCARL = false,
    SKIN_DP28 = false, SKIN_GROZA = false,
    MEM_AntiBan = false, MEM_Wallhack = false, MEM_Speed = false,
    MEM_NoRecoil = false, MEM_NoShake = false, MEM_NoFog = false,
    MEM_NoGrass = false, MEM_BlackSky = false,
    SKIN_ModSkin = false, SKIN_ModEmote = false, SKIN_DeadBox = false,
    SKIN_Attachment = false, SKIN_KillMsg = false, SKIN_KillCount = false,
    AIMBOT_Enabled = false,
}


-- ==============================================================================
-- LEXUS CONFIG (Skin System Config from 1.lua)
-- ==============================================================================
pcall(function()
    _G.LexusConfig = _G.LexusConfig or {}
    
    -- Config Mod Skin VIP -- [FIX] Preserve existing values, only set default if nil
    _G.LexusConfig.ModEmote = _G.LexusConfig.ModEmote or false
    _G.LexusConfig.ModSkin = _G.LexusConfig.ModSkin or false
    _G.LexusConfig.SkinDeadBox = _G.LexusConfig.SkinDeadBox or false
    _G.LexusConfig.SkinAttachment = _G.LexusConfig.SkinAttachment or false
    _G.LexusConfig.SkinOptionOpen = _G.LexusConfig.SkinOptionOpen or false
    _G.LexusConfig.SkinOpenLink = _G.LexusConfig.SkinOpenLink or false
    _G.LexusConfig.KillMessage = _G.LexusConfig.KillMessage or false
    _G.LexusConfig.KillCountUI = _G.LexusConfig.KillCountUI or false
    
    -- Toggles for each item
    _G.LexusConfig.SkinEnable_Suit = _G.LexusConfig.SkinEnable_Suit or false
    _G.LexusConfig.SkinEnable_Top = _G.LexusConfig.SkinEnable_Top or false
    _G.LexusConfig.SkinEnable_Gloves = _G.LexusConfig.SkinEnable_Gloves or false
    _G.LexusConfig.SkinEnable_Bottom = _G.LexusConfig.SkinEnable_Bottom or false
    _G.LexusConfig.SkinEnable_Shoes = _G.LexusConfig.SkinEnable_Shoes or false
    _G.LexusConfig.SkinEnable_Bag = _G.LexusConfig.SkinEnable_Bag or false
    _G.LexusConfig.SkinEnable_Helmet = _G.LexusConfig.SkinEnable_Helmet or false
    _G.LexusConfig.SkinEnable_Parachute = _G.LexusConfig.SkinEnable_Parachute or false
    _G.LexusConfig.SkinEnable_M416 = _G.LexusConfig.SkinEnable_M416 or false
    _G.LexusConfig.SkinEnable_AKM = _G.LexusConfig.SkinEnable_AKM or false
    _G.LexusConfig.SkinEnable_SCAR = _G.LexusConfig.SkinEnable_SCAR or false
    _G.LexusConfig.SkinEnable_M762 = _G.LexusConfig.SkinEnable_M762 or false
    _G.LexusConfig.SkinEnable_AUG = _G.LexusConfig.SkinEnable_AUG or false
    _G.LexusConfig.SkinEnable_UMP = _G.LexusConfig.SkinEnable_UMP or false
    _G.LexusConfig.SkinEnable_UZI = _G.LexusConfig.SkinEnable_UZI or false
    _G.LexusConfig.SkinEnable_Groza = _G.LexusConfig.SkinEnable_Groza or false
    _G.LexusConfig.SkinEnable_S12K = _G.LexusConfig.SkinEnable_S12K or false
    _G.LexusConfig.SkinEnable_DBS = _G.LexusConfig.SkinEnable_DBS or false
    _G.LexusConfig.SkinEnable_Dacia = _G.LexusConfig.SkinEnable_Dacia or false
    _G.LexusConfig.SkinEnable_UAZ = _G.LexusConfig.SkinEnable_UAZ or false
    _G.LexusConfig.SkinEnable_Coupe = _G.LexusConfig.SkinEnable_Coupe or false
    _G.LexusConfig.SkinEnable_Buggy = _G.LexusConfig.SkinEnable_Buggy or false
    _G.LexusConfig.SkinEnable_Mirado = _G.LexusConfig.SkinEnable_Mirado or false
end)



-- ===== FEATURE SYNC: VIPConfig <-> _G.Mod_* =====
local FeatureMap = {
    ESP_Enabled = "_G.Mod_ESP_Enabled",
    ESP_Line = "_G.Mod_ESP_ShowSnapline",ESP_Distance = "_G.Mod_ESP_ShowDistance",
    ESP_Name = "_G.Mod_ESP_ShowName",
    ESP_HealthBar = "_G.Mod_ESP_ShowHealthBar",
    ESP_TotalCount = "_G.Mod_ESP_ShowPlayerCount",
    ESP_Radar = "_G.Mod_ESP_ShowTeamColor",
    ESP_WeaponIcon = "_G.Mod_ESP_ShowWeaponIcon",
    AIM_Enabled = "_G.Mod_Chams_Enabled",
    AIM_Bot = "_G.Mod_WeaponGlow_Enabled",
    AIM_Silent = "_G.Mod_UnlockFPS_Enabled",
    AIM_FOV = "_G.Mod_IpadView_Enabled",
    AIM_Smooth = "_G.Mod_WhiteBody_Enabled",
    AIM_Visible = "_G.Mod_CircleArrow_Enabled",
    -- Skin system bridge: SKIN_ keys -> LexusConfig
    SKIN_ModSkin = "_G.LexusConfig.ModSkin",
    SKIN_ModEmote = "_G.LexusConfig.ModEmote",
    SKIN_DeadBox = "_G.LexusConfig.SkinDeadBox",
    SKIN_Attachment = "_G.LexusConfig.SkinAttachment",
    SKIN_KillMsg = "_G.LexusConfig.KillMessage",
    SKIN_KillCount = "_G.LexusConfig.KillCountUI",
}

local function SyncFeature(key, value)
    local gVar = FeatureMap[key]
    if gVar then
        pcall(function() load(gVar .. " = " .. tostring(value))() end)
    end
end

local function GetFeatureState(key)
    local gVar = FeatureMap[key]
    if not gVar then return _G.VIPConfig[key] or false end
    local val = false
    pcall(function() val = load("return " .. gVar)() end)
    return val
end

for cfgKey, gVar in pairs(FeatureMap) do
    local val = false
    pcall(function() val = load("return " .. gVar)() end)
    _G.VIPConfig[cfgKey] = val
end

local parentCanvas = nil
local bgPanel = nil
local allWidgets = {}
local toggleRows = {}
local floatItem = nil
local isMenuOpen = false
local menuBuilt = false

local function GetCanvas()
    if parentCanvas and Game:IsValid(parentCanvas) then return parentCanvas end
    parentCanvas = nil
    pcall(function()
        local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
        local MainUI = InGameUITools.GetMainControlBaseUI()
        if not MainUI or not Game:IsValid(MainUI) then return end
        if MainUI.CanvasPanel_0 and Game:IsValid(MainUI.CanvasPanel_0) then parentCanvas = MainUI.CanvasPanel_0
        elseif MainUI.CanvasPanel_42 and Game:IsValid(MainUI.CanvasPanel_42) then parentCanvas = MainUI.CanvasPanel_42 end
    end)
    return parentCanvas
end

local function MakeBtn(parent, x, y, w, h, z, onClick)
    local btn = nil
    pcall(function()
        btn = CGame:NewObjectFromPath("/Script/UMG.Button", parent)
        if btn and slua.isValid(btn) then
            pcall(function() btn:SetColorAndOpacity(C.transparent) end)
            pcall(function() btn:SetBackgroundColor(C.transparent) end)
            pcall(function() btn:SetWidgetVisibility(UEnums.ESlateVisibility.Visible) end)
            local slot = parent:AddChildToCanvas(btn)
            if slot then
                slot:SetAutoSize(false)
                slot:SetPosition(FVector2D(x, y))
                slot:SetSize(FVector2D(w, h))
                slot:SetZOrder(z or 900)
            end
            if onClick then
                pcall(function() if btn.OnClicked then btn.OnClicked:Add(function() if not IsVipExpired() then pcall(onClick) end end) end end)
                pcall(function() if btn.OnPressed then btn.OnPressed:Add(function() if not IsVipExpired() then pcall(onClick) end end) end end)
                pcall(function() if btn.OnReleased then btn.OnReleased:Add(function() if not IsVipExpired() then pcall(onClick) end end) end end)
            end
        end
    end)
    table.insert(allWidgets, btn)
    return btn
end

local function Layer(parent, x, y, w, h, color, z)
    local b = nil
    pcall(function()
        b = CGame:NewObjectFromPath("/Script/UMG.Border", parent)
        if b and slua.isValid(b) then
            b:SetBrushColor(color)
            b:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            local slot = parent:AddChildToCanvas(b)
            if slot then
                slot:SetAutoSize(false)
                slot:SetPosition(FVector2D(x, y))
                slot:SetSize(FVector2D(w, h))
                slot:SetZOrder(z or 0)
            end
        end
    end)
    table.insert(allWidgets, b)
    return b
end

local function FloatLayer(parent, x, y, w, h, color, z)
    local b = nil
    pcall(function()
        b = CGame:NewObjectFromPath("/Script/UMG.Border", parent)
        if b and slua.isValid(b) then
            b:SetBrushColor(color)
            b:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            local slot = parent:AddChildToCanvas(b)
            if slot then
                slot:SetAutoSize(false)
                slot:SetPosition(FVector2D(x, y))
                slot:SetSize(FVector2D(w, h))
                slot:SetZOrder(z or 0)
            end
        end
    end)
    return b
end

local function Text(parent, txt, x, y, size, color, z, alignX, alignY)
    local t = nil
    pcall(function()
        t = CGame:NewObjectFromPath("/Script/UMG.TextBlock", parent)
        if t and slua.isValid(t) then
            t:SetText(txt)
            if FSlateColor then t:SetColorAndOpacity(FSlateColor(color))
            else t:SetColorAndOpacity(color) end
            if t.Font then local f = t.Font f.Size = size t.Font = f end
            t:SetRenderTransformPivot(FVector2D(alignX or 0.5, alignY or 0.5))
            t:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            local slot = parent:AddChildToCanvas(t)
            if slot then
                slot:SetAutoSize(true)
                slot:SetAlignment(FVector2D(alignX or 0.5, alignY or 0.5))
                slot:SetPosition(FVector2D(x, y))
                slot:SetZOrder(z or 100)
            end
        end
    end)
    table.insert(allWidgets, t)
    return t
end

local function ShowMenu()
    if IsVipExpired() then
        if bgPanel and IsValid(bgPanel) then
            pcall(function() bgPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
        end
        return
    end
    if bgPanel and IsValid(bgPanel) then
        pcall(function() bgPanel:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
    end
end

local function HideMenu()
    if bgPanel and IsValid(bgPanel) then
        pcall(function() bgPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
    end
end

-- ===== PREMIUM TOGGLE ROW UPDATE =====
local function UpdateToggleRow(rowData)
    if not rowData then return end
    local state = GetFeatureState(rowData.key)
    _G.VIPConfig[rowData.key] = state
    local stateText = state and "ON" or "OFF"
    local stateColor = state and (rowData.accentColor or C.cyan) or C.text_dim

    if rowData.stateText and IsValid(rowData.stateText) then
        pcall(function()
            rowData.stateText:SetText(stateText)
            if FSlateColor then rowData.stateText:SetColorAndOpacity(FSlateColor(stateColor))
            else rowData.stateText:SetColorAndOpacity(stateColor) end
        end)
    end

    -- Toggle switch knob position
    if rowData.knob and IsValid(rowData.knob) then
        pcall(function()
            local knobX = state and (rowData.toggleX + rowData.toggleW - rowData.knobSize - 3) or (rowData.toggleX + 3)
            rowData.knobSlot:SetPosition(FVector2D(knobX, rowData.toggleY + 3))
        end)
    end

    -- Toggle track color
    if rowData.track and IsValid(rowData.track) then
        pcall(function()
            rowData.track:SetBrushColor(state and (rowData.accentColor or C.cyan) or FLinearColor(0.035,0.045,0.075,1.0))
        end)
    end

    -- Toggle glow
    if rowData.toggleGlow and IsValid(rowData.toggleGlow) then
        pcall(function()
            if state then
                rowData.toggleGlow:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            else
                rowData.toggleGlow:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
            end
        end)
    end

    -- Row glow when ON
    if rowData.rowGlow and IsValid(rowData.rowGlow) then
        pcall(function()
            if state then
                rowData.rowGlow:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            else
                rowData.rowGlow:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
            end
        end)
    end

    -- Left accent bar color
    if rowData.accent2 and IsValid(rowData.accent2) then
        pcall(function()
            rowData.accent2:SetBrushColor(state and (rowData.accentColor or C.cyan) or C.red_dark)
        end)
    end
end

-- ===== NEON TOGGLE ROW =====
local function MakeToggleRow(parent, label, x, y, w, h, toggleKey, isZebra, accentColor)
    local state = GetFeatureState(toggleKey)
    _G.VIPConfig[toggleKey] = state
    local rowBg = isZebra and C.bg_row_alt or C.bg_row
    local ac = accentColor or C.cyan
    local rowData = { key = toggleKey }

    rowData.rowGlow = Layer(parent, x, y, w, h, FLinearColor(ac.R or 0.1, ac.G or 0.3, ac.B or 0.8, 0.055), 199)
    if not state then
        pcall(function() rowData.rowGlow:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
    end

    -- Rounded-looking stacked border effect
    rowData.outer = Layer(parent, x, y, w, h, FLinearColor(0.10,0.16,0.26,1.0), 200)
    rowData.bg = Layer(parent, x + 2, y + 2, w - 4, h - 4, rowBg, 201)
    rowData.accent1 = Layer(parent, x + 2, y + 2, 3, h - 4, ac, 202)
    rowData.accent2 = Layer(parent, x + 5, y + 4, 1, h - 8, FLinearColor(ac.R or 0.1, ac.G or 0.3, ac.B or 0.8, 0.45), 203)
    rowData.topHighlight = Layer(parent, x + 8, y + 2, w - 16, 1, FLinearColor(0.30,0.60,1.0,0.22), 204)
    rowData.bottom = Layer(parent, x + 8, y + h - 2, w - 16, 1, FLinearColor(0.12,0.25,0.45,0.35), 204)

    rowData.label = Text(parent, label, x + 26, y + h * 0.5, 17, C.text_label, 300, 0, 0.5)

    local toggleW, toggleH = 58, 30
    local toggleX = x + w - toggleW - 18
    local toggleY = y + h * 0.5 - toggleH * 0.5
    local knobSize = toggleH - 8
    rowData.toggleX, rowData.toggleY, rowData.toggleW, rowData.toggleH, rowData.knobSize =
        toggleX, toggleY, toggleW, toggleH, knobSize

    rowData.toggleGlow = Layer(parent, toggleX - 6, toggleY - 6, toggleW + 12, toggleH + 12,
        FLinearColor(ac.R or 0.1, ac.G or 0.3, ac.B or 0.8, 0.14), 298)
    if not state then
        pcall(function() rowData.toggleGlow:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
    end

    rowData.trackBorder = Layer(parent, toggleX - 2, toggleY - 2, toggleW + 4, toggleH + 4, ac, 299)
    rowData.track = Layer(parent, toggleX, toggleY, toggleW, toggleH,
        state and ac or FLinearColor(0.035,0.045,0.075,1.0), 300)
    rowData.trackInner = Layer(parent, toggleX + 2, toggleY + 2, toggleW - 4, toggleH - 4,
        FLinearColor(0.0,0.0,0.0,0.22), 301)

    local knobX = state and (toggleX + toggleW - knobSize - 4) or (toggleX + 4)
    local knobY = toggleY + 4
    rowData.knobSlot = nil
    pcall(function()
        local k = CGame:NewObjectFromPath("/Script/UMG.Border", parent)
        if k and slua.isValid(k) then
            k:SetBrushColor(C.white)
            k:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            local slot = parent:AddChildToCanvas(k)
            if slot then
                slot:SetAutoSize(false)
                slot:SetPosition(FVector2D(knobX, knobY))
                slot:SetSize(FVector2D(knobSize, knobSize))
                slot:SetZOrder(303)
            end
            rowData.knob, rowData.knobSlot = k, slot
        end
    end)

    local stateColor = state and ac or C.text_dim
    rowData.stateText = Text(parent, state and "ON" or "OFF", toggleX - 10, y + h * 0.5,
        12, stateColor, 304, 1, 0.5)

    rowData.btn = MakeBtn(parent, x, y, w, h, 900, function()
        _G.VIPConfig[toggleKey] = not _G.VIPConfig[toggleKey]
        SyncFeature(toggleKey, _G.VIPConfig[toggleKey])
        UpdateToggleRow(rowData)
    end)

    rowData.accentColor = ac
    table.insert(toggleRows, rowData)
    return rowData
end

-- ===== NEON SLIDER ROW =====
local function MakeSliderRow(parent, label, x, y, w, h, getText, onClick, isZebra)
    local rowBg = isZebra and C.bg_row_alt or C.bg_row
    local rowData = { key = label, isSlider = true }
    rowData.bg = Layer(parent, x, y, w, h, rowBg, 200)
    rowData.outer = Layer(parent, x, y, w, h, FLinearColor(0.10,0.16,0.26,1.0), 199)
    rowData.bg2 = Layer(parent, x + 2, y + 2, w - 4, h - 4, rowBg, 200)
    rowData.accent1 = Layer(parent, x + 2, y + 2, 3, h - 4, C.violet, 201)
    rowData.label = Text(parent, label, x + 26, y + h * 0.5, 16, C.text_label, 300, 0, 0.5)
    local valText = getText()
    rowData.valText = Text(parent, valText, x + w - 88, y + h * 0.5, 14, C.cyan, 300, 1, 0.5)

    local btnW, btnH = 30, 30
    local btnY = y + h * 0.5 - btnH * 0.5
    local minusX, plusX = x + w - 64, x + w - 32

    Layer(parent, minusX - 2, btnY - 2, btnW + 4, btnH + 4, C.red_bright, 298)
    Layer(parent, minusX, btnY, btnW, btnH, C.bg_tab, 299)
    Text(parent, "-", minusX + btnW*0.5, btnY + btnH*0.5, 19, C.red_bright, 400, 0.5, 0.5)
    MakeBtn(parent, minusX, btnY, btnW, btnH, 900, function()
        onClick(-1)
        if rowData.valText and IsValid(rowData.valText) then pcall(function() rowData.valText:SetText(getText()) end) end
    end)

    Layer(parent, plusX - 2, btnY - 2, btnW + 4, btnH + 4, C.cyan, 298)
    Layer(parent, plusX, btnY, btnW, btnH, C.bg_tab, 299)
    Text(parent, "+", plusX + btnW*0.5, btnY + btnH*0.5, 19, C.cyan, 400, 0.5, 0.5)
    MakeBtn(parent, plusX, btnY, btnW, btnH, 900, function()
        onClick(1)
        if rowData.valText and IsValid(rowData.valText) then pcall(function() rowData.valText:SetText(getText()) end) end
    end)

    table.insert(toggleRows, rowData)
    return rowData
end


-- ===== BUILD MENU : NEON VIP EDITION =====
local function BuildMenu()
    if IsVipExpired() then
        if bgPanel and IsValid(bgPanel) then HideMenu() end
        return
    end
    if menuBuilt and bgPanel and IsValid(bgPanel) then
        ShowMenu()
        return
    end

    local canvas = GetCanvas()
    if not canvas then return end

    pcall(function()
        bgPanel = CGame:NewObjectFromPath("/Script/UMG.CanvasPanel", canvas)
        if bgPanel and slua.isValid(bgPanel) then
            local slot = canvas:AddChildToCanvas(bgPanel)
            if slot then
                slot:SetAutoSize(false)
                slot:SetZOrder(10000)
                slot:SetAnchors(FAnchors(1, 0, 1, 0))
                slot:SetAlignment(FVector2D(1, 0))
                slot:SetPosition(FVector2D(-12, 18))
                slot:SetSize(FVector2D(M_W, M_H))
                -- Compact display scale: preserves the exact neon VIP theme/layout
                -- while reducing the whole menu proportionally.
                pcall(function()
                    bgPanel:SetRenderTransformPivot(FVector2D(1.0, 0.0))
                    bgPanel:SetRenderScale(FVector2D(0.86, 0.86))
                end)
            end
        end
    end)
    if not bgPanel or not slua.isValid(bgPanel) then return end

    -- Deep neon shadow
    Layer(bgPanel, -24, -24, M_W + 48, M_H + 48, C.shadow5, -7)
    Layer(bgPanel, -16, -16, M_W + 32, M_H + 32, C.shadow4, -6)
    Layer(bgPanel, -9, -9, M_W + 18, M_H + 18, C.shadow3, -5)
    Layer(bgPanel, -5, -5, M_W + 10, M_H + 10, C.shadow2, -4)
    Layer(bgPanel, -2, -2, M_W + 4, M_H + 4, C.shadow1, -3)

    -- Rainbow/neon outer frame
    Layer(bgPanel, -4, -4, M_W + 8, M_H + 8, C.red_bright, -2)
    Layer(bgPanel, -3, -3, M_W + 6, M_H + 6, C.violet, -1)
    Layer(bgPanel, -2, -2, M_W + 4, M_H + 4, C.cyan, 0)
    Layer(bgPanel, 0, 0, M_W, M_H, C.bg_main, 1)

    -- Side neon rails
    Layer(bgPanel, 0, 14, 3, M_H - 28, C.red_bright, 3)
    Layer(bgPanel, 1, 18, 1, M_H - 36, C.magenta, 4)
    Layer(bgPanel, M_W - 3, 14, 3, M_H - 28, C.cyan, 3)
    Layer(bgPanel, M_W - 2, 18, 1, M_H - 36, C.violet, 4)

    -- ===== HERO HEADER =====
    Layer(bgPanel, 0, 0, M_W, HEADER_H, C.bg_header, 2)
    Layer(bgPanel, 0, 35, M_W, 55, C.bg_header2, 2)
    Layer(bgPanel, 0, 90, M_W, 60, C.bg_header3, 2)

    -- Rainbow header accents
    Layer(bgPanel, 12, 8, 170, 2, C.red_bright, 5)
    Layer(bgPanel, 180, 8, 170, 2, C.gold_bright, 5)
    Layer(bgPanel, 348, 8, 170, 2, C.cyan, 5)
    Layer(bgPanel, 516, 8, 172, 2, C.violet, 5)
    Layer(bgPanel, 14, HEADER_H - 5, M_W - 28, 2, C.magenta, 5)
    Layer(bgPanel, 14, HEADER_H - 3, M_W - 28, 2, C.cyan, 5)

    -- Crown / premium mark
    Text(bgPanel, "♛", M_W * 0.5, 21, 28, C.gold_bright, 500, 0.5, 0.5)

    -- Main title
    Text(bgPanel, "SAMEER", M_W * 0.5, 63, 31, C.red_bright, 500, 0.5, 0.5)
    Text(bgPanel, "SAMEER", M_W * 0.5 + 2, 63, 31, C.cyan, 499, 0.5, 0.5)

    -- Cover the cyan offset with a dark/red title pass for a two-tone effect
    Text(bgPanel, "SAMEER", M_W * 0.5 - 2, 63, 31, C.red_bright, 501, 0.5, 0.5)
    Text(bgPanel, "SAMEER", M_W * 0.5 + 2, 63, 31, C.cyan, 502, 0.5, 0.5)

    -- Subtitle
    Layer(bgPanel, 120, 91, 120, 1, C.red_bright, 5)
    Layer(bgPanel, 460, 91, 120, 1, C.cyan, 5)
    Text(bgPanel, "MODDED BY @YADAV524", M_W * 0.5, 98, 17, C.gold_bright, 500, 0.5, 0.5)
    Text(bgPanel, "PREMIUM EDITION", M_W * 0.5, 124, 10, C.gold, 500, 0.5, 0.5)

    -- VIP active badge
    local vipExpired = GetVipExpiryInfo()
    local statusColor = vipExpired and C.red_bright or C.cyan
    local statusW, statusH = 122, 28
    local statusX, statusY = M_W - statusW - 52, 15
    Layer(bgPanel, statusX - 2, statusY - 2, statusW + 4, statusH + 4, statusColor, 5)
    Layer(bgPanel, statusX, statusY, statusW, statusH, C.bg_tab, 6)
    Text(bgPanel, vipExpired and "VIP EXPIRED" or "VIP ACTIVE", statusX + statusW*0.5, statusY + statusH*0.5,
        9, statusColor, 500, 0.5, 0.5)

    -- Close button
    local closeX, closeY = M_W - 38, 54
    Layer(bgPanel, closeX - 3, closeY - 3, 32, 32, C.red_bright, 5)
    Layer(bgPanel, closeX, closeY, 26, 26, C.bg_header2, 6)
    Text(bgPanel, "X", closeX + 13, closeY + 13, 15, C.white, 500, 0.5, 0.5)
    MakeBtn(bgPanel, closeX, closeY, 26, 26, 900, function()
        isMenuOpen = false
        HideMenu()
    end)

    -- ===== TABS =====
    local tabY = HEADER_H
    local tabNames = {"ESP", "MODS", "SKINS", "AIMBOT", "MISC"}
    local tabW = M_W / #tabNames
    local tabWidgets, contentPanels = {}, {}

    local function SwitchTab(tabIndex)
        for i = 1, #tabWidgets do
            local tw = tabWidgets[i]
            if tw then
                local ac = (ACCENTS[i] and ACCENTS[i].c) or C.cyan
                local acBg = (ACCENTS[i] and ACCENTS[i].bg) or C.bg_tab_active
                if i == tabIndex then
                    if tw.bg and IsValid(tw.bg) then tw.bg:SetBrushColor(acBg) end
                    if tw.glow and IsValid(tw.glow) then
                        tw.glow:SetBrushColor(FLinearColor(ac.R or 0.2, ac.G or 0.2, ac.B or 0.8, 0.13))
                        tw.glow:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                    end
                    if tw.accent and IsValid(tw.accent) then
                        tw.accent:SetBrushColor(ac)
                        tw.accent:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                    end
                    if tw.txt and IsValid(tw.txt) then
                        if FSlateColor then tw.txt:SetColorAndOpacity(FSlateColor(ac)) else tw.txt:SetColorAndOpacity(ac) end
                    end
                else
                    if tw.bg and IsValid(tw.bg) then tw.bg:SetBrushColor(C.bg_tab) end
                    if tw.glow and IsValid(tw.glow) then tw.glow:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end
                    if tw.accent and IsValid(tw.accent) then tw.accent:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end
                    if tw.txt and IsValid(tw.txt) then
                        if FSlateColor then tw.txt:SetColorAndOpacity(FSlateColor(C.text_dim)) else tw.txt:SetColorAndOpacity(C.text_dim) end
                    end
                end
            end
        end
        for i = 1, #contentPanels do
            if contentPanels[i] and IsValid(contentPanels[i]) then
                contentPanels[i]:SetWidgetVisibility(i == tabIndex and
                    UEnums.ESlateVisibility.SelfHitTestInvisible or UEnums.ESlateVisibility.Collapsed)
            end
        end
    end

    for i, tabName in ipairs(tabNames) do
        local tx = (i - 1) * tabW
        local ac = (ACCENTS[i] and ACCENTS[i].c) or C.cyan
        local tabGlow = Layer(bgPanel, tx + 3, tabY + 4, tabW - 6, TAB_H - 8,
            FLinearColor(ac.R or 0.2, ac.G or 0.2, ac.B or 0.8, 0.10), 2)
        if i ~= 1 then pcall(function() tabGlow:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end) end
        local tabBg = Layer(bgPanel, tx + 3, tabY + 4, tabW - 6, TAB_H - 8, i == 1 and ACCENTS[i].bg or C.bg_tab, 3)
        local tabAccent = Layer(bgPanel, tx + 3, tabY + TAB_H - 5, tabW - 6, 3, ac, 4)
        if i ~= 1 then pcall(function() tabAccent:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end) end
        local tabTxt = Text(bgPanel, tabName, tx + tabW*0.5, tabY + TAB_H*0.5, 13,
            i == 1 and ac or C.text_dim, 500, 0.5, 0.5)
        if i < #tabNames then Layer(bgPanel, tx + tabW - 1, tabY + 13, 1, TAB_H - 26, C.divider, 5) end
        local tabIdx = i
        MakeBtn(bgPanel, tx, tabY, tabW, TAB_H, 900, function() SwitchTab(tabIdx) end)
        tabWidgets[i] = {bg=tabBg, txt=tabTxt, glow=tabGlow, accent=tabAccent}
    end
    Layer(bgPanel, 10, tabY + TAB_H - 1, M_W - 20, 2, C.gold_bright, 6)

    -- ===== CONTENT =====
    local contentStartY = tabY + TAB_H + 12
    local contentX, contentW = 16, M_W - 32

    local tabContents = {
        { title = "SAMEER ESP SYSTEM", options = {
            {label="WALL ESP", key="ESP_Enabled"},
            {label="ESP Player Count", key="ESP_TotalCount"},
            {label="ESP Name", key="ESP_Name"},
            {label="ESP Distance", key="ESP_Distance"},
            {label="ESP Health Bar", key="ESP_HealthBar"},
            {label="ESP Team Color", key="ESP_Radar"},
            {label="ESP Snapline", key="ESP_Line"},
        }},
        { title = "MODS SYSTEM", options = {
            {label="CHAMS (COLOR HACK)", key="AIM_Enabled"},
            {label="WEAPON GLOW (HDR)", key="AIM_Bot"},
            {slider=true, label="Glow Color", getText=function()
                local c=_G.WeaponGlowColor or 5
                local names={[1]="Red",[2]="Green",[3]="Blue",[4]="Yellow",[5]="Rainbow"}
                return names[c] or "Rainbow"
            end, onClick=function(dir)
                local c=(_G.WeaponGlowColor or 5)+dir
                if c<1 then c=5 end if c>5 then c=1 end
                _G.WeaponGlowColor=c
            end},
            {slider=true, label="Glow Thickness", getText=function() return tostring(_G.WeaponGlowThickness or 3) end,
                onClick=function(dir)
                    local v=(_G.WeaponGlowThickness or 3)+dir
                    if v<1 then v=1 end if v>15 then v=15 end
                    _G.WeaponGlowThickness=v
                end},
            {label="UNLOCK 165 FPS", key="AIM_Silent"},
            {label="IPAD VIEW", key="AIM_FOV"},
            {slider=true, label="FOV Value", getText=function() return tostring(_G.IpadViewFOV or 120) end,
                onClick=function(dir)
                    local v=(_G.IpadViewFOV or 120)+dir
                    if v<91 then v=91 end if v>190 then v=190 end
                    _G.IpadViewFOV=v
                    pcall(function() if _G.NewFreshApplyIpadView then _G.NewFreshApplyIpadView() end end)
                end},
            {label="WHITE BODY", key="AIM_Smooth"},
            {label="CIRCLE & ARROW ESP", key="AIM_Visible"},
        }},
        { title = "SKINS SYSTEM", options = {
            {label="VIP MOD SKIN", key="SKIN_ModSkin"},
            {label="VIP EMOTES", key="SKIN_ModEmote"},
            {label="DEADBOX SKIN", key="SKIN_DeadBox"},
            {label="ATTACHMENT SKIN", key="SKIN_Attachment"},
            {label="KILL MESSENGER", key="SKIN_KillMsg"},
            {label="KILL COUNTER UI", key="SKIN_KillCount"},
        }},
        { title = "AIMBOT SYSTEM", options = {
            {label="AIMBOT ENABLE", key="AIMBOT_Enabled"},
        }},
        { title = "MISC / VIP STATUS", options = {
            {isLabel=true, label="PREMIUM EDITION"},
            {isLabel=true, label="SAMEER VIP ACCESS"},
        }},
    }

    for tabIdx, tabData in ipairs(tabContents) do
        local panel = CGame:NewObjectFromPath("/Script/UMG.CanvasPanel", bgPanel)
        if panel and slua.isValid(panel) then
            local slot = bgPanel:AddChildToCanvas(panel)
            if slot then
                slot:SetAutoSize(false)
                slot:SetPosition(FVector2D(0, contentStartY))
                slot:SetSize(FVector2D(M_W, M_H - contentStartY - 72))
                slot:SetZOrder(10)
            end
            panel:SetWidgetVisibility(tabIdx == 1 and UEnums.ESlateVisibility.SelfHitTestInvisible or UEnums.ESlateVisibility.Collapsed)
        end
        contentPanels[tabIdx] = panel
        if not panel or not slua.isValid(panel) then panel = bgPanel end

        local cY = 4
        local ac = (ACCENTS[tabIdx] and ACCENTS[tabIdx].c) or C.cyan

        -- Section title frame
        Layer(panel, contentX, cY + 2, 52, 2, ac, 200)
        Layer(panel, contentX + contentW - 52, cY + 2, 52, 2, ac, 200)
        Text(panel, tabData.title, contentX + contentW*0.5, cY + 11, 16, C.gold_bright, 500, 0.5, 0.5)
        Layer(panel, contentX, cY + 24, contentW, 1, C.divider, 200)
        Layer(panel, contentX + 18, cY + 24, contentW - 36, 1, ac, 201)
        cY = cY + 34

        for i, opt in ipairs(tabData.options) do
            if opt.isLabel then
                Layer(panel, contentX, cY + ROW_H*0.5, contentW, 1, ac, 200)
                Text(panel, opt.label, contentX + contentW*0.5, cY + ROW_H*0.5, 13, ac, 400, 0.5, 0.5)
                cY = cY + ROW_H
            elseif opt.slider then
                MakeSliderRow(panel, opt.label, contentX, cY, contentW, ROW_H, opt.getText, opt.onClick, i % 2 == 0)
                cY = cY + ROW_H
            else
                if _G.VIPConfig[opt.key] == nil then _G.VIPConfig[opt.key] = false end
                local acRow = (ACCENTS[((i-1) % #ACCENTS) + 1] and ACCENTS[((i-1) % #ACCENTS) + 1].c) or ac
                MakeToggleRow(panel, opt.label, contentX, cY, contentW, ROW_H, opt.key, i % 2 == 0, acRow)
                cY = cY + ROW_H
            end
        end
    end

    -- ===== VIP FOOTER =====
    local footY = M_H - 72
    Layer(bgPanel, 12, footY - 3, M_W - 24, 3, C.magenta, 5)
    Layer(bgPanel, 12, footY, M_W - 24, 66, C.bg_header, 1)
    Layer(bgPanel, 12, footY + 2, M_W - 24, 2, C.gold_bright, 5)

    local vipExpired, vipRemaining = GetVipExpiryInfo()
    local expColor = vipExpired and C.red_bright or C.cyan
    Text(bgPanel, "♛  SAMEER  ♛", M_W*0.5, footY + 16, 15, C.magenta, 500, 0.5, 0.5)
    Text(bgPanel, vipExpired and "VIP EXPIRED" or "VIP ACCESS", M_W*0.5, footY + 34, 10, expColor, 500, 0.5, 0.5)
    Text(bgPanel, VIP_EXPIRE_LABEL .. "  •  " .. vipRemaining, M_W*0.5, footY + 51, 9, C.gold_bright, 400, 0.5, 0.5)
    Layer(bgPanel, 22, M_H - 5, M_W - 44, 2, C.cyan, 5)
    Layer(bgPanel, 22, M_H - 3, (M_W - 44) * 0.5, 2, C.red_bright, 5)

    menuBuilt = true
    isMenuOpen = true
end

-- ===== LUXURY FLOAT BUTTON =====
local function CreateFloat()
    if IsVipExpired() then return end
    if floatItem and floatItem.btn and IsValid(floatItem.btn) then return end
    floatItem = nil
    pcall(function()
        local canvas = GetCanvas()
        if not canvas then return end

        floatItem = {}
        local fX = 20
        local fY = 15
        local fW = 120
        local fH = 50

        -- Deep shadow layers (5-layer luxury)
        floatItem.s0 = FloatLayer(canvas, fX - 18, fY - 18, fW + 36, fH + 36, C.shadow5, 11895)
        floatItem.s1 = FloatLayer(canvas, fX - 12, fY - 12, fW + 24, fH + 24, C.shadow4, 11896)
        floatItem.s2 = FloatLayer(canvas, fX - 6, fY - 6, fW + 12, fH + 12, C.shadow3, 11897)
        floatItem.s3 = FloatLayer(canvas, fX - 3, fY - 3, fW + 6, fH + 6, C.shadow2, 11898)
        floatItem.s4 = FloatLayer(canvas, fX - 2, fY - 2, fW + 4, fH + 4, C.shadow1, 11898)

        -- Gold + red border system
        floatItem.s5 = FloatLayer(canvas, fX - 3, fY - 3, fW + 6, fH + 6, C.gold_deep, 11899)
        floatItem.s6 = FloatLayer(canvas, fX - 2, fY - 2, fW + 4, fH + 4, C.border_dark, 11900)
        floatItem.s7 = FloatLayer(canvas, fX - 1, fY - 1, fW + 2, fH + 2, C.border_gold, 11901)

        -- Main bg (dark glass)
        floatItem.s8 = FloatLayer(canvas, fX, fY, fW, fH, C.bg_main, 11902)
        floatItem.s9 = FloatLayer(canvas, fX, fY, fW, fH / 2, C.bg_header3, 11903)
        floatItem.s10 = FloatLayer(canvas, fX, fY + fH / 2, fW, fH / 2, C.bg_header, 11903)

        -- Red side accents
        floatItem.s11 = FloatLayer(canvas, fX, fY + 4, 2, fH - 8, C.red_dark, 11904)
        floatItem.s12 = FloatLayer(canvas, fX + fW - 2, fY + 4, 2, fH - 8, C.red_dark, 11904)

        -- Gold accent lines (top + bottom)
        floatItem.s13 = FloatLayer(canvas, fX + 2, fY + 2, fW - 4, 1, C.gold, 11905)
        floatItem.s14 = FloatLayer(canvas, fX + 2, fY + fH - 3, fW - 4, 1, C.gold, 11905)
        floatItem.s15 = FloatLayer(canvas, fX + 2, fY + fH - 2, fW - 4, 1, C.gold_bright, 11905)

        -- Gold glow
        floatItem.s16 = FloatLayer(canvas, fX + 2, fY + 4, fW - 4, fH - 8, C.gold_glow, 11906)

        -- Text
        pcall(function()
            floatItem.text = CGame:NewObjectFromPath("/Script/UMG.TextBlock", canvas)
            if floatItem.text and slua.isValid(floatItem.text) then
                floatItem.text:SetText("SAMEER")
                if FSlateColor then floatItem.text:SetColorAndOpacity(FSlateColor(C.gold_bright))
                else floatItem.text:SetColorAndOpacity(C.gold_bright) end
                if floatItem.text.Font then local f = floatItem.text.Font f.Size = 17 floatItem.text.Font = f end
                floatItem.text:SetRenderScale(FVector2D(1.15, 1.15))
                floatItem.text:SetRenderTransformPivot(FVector2D(0.5, 0.5))
                floatItem.text:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                local slot = canvas:AddChildToCanvas(floatItem.text)
                if slot then
                    slot:SetAutoSize(true)
                    slot:SetAlignment(FVector2D(0.5, 0.5))
                    slot:SetPosition(FVector2D(fX + fW * 0.5, fY + fH * 0.5))
                    slot:SetZOrder(12001)
                end
            end
        end)

        -- Red dot indicator
        floatItem.s17 = FloatLayer(canvas, fX + fW - 10, fY + 4, 5, 5, C.red, 12000)

        -- Click button
        pcall(function()
            floatItem.btn = CGame:NewObjectFromPath("/Script/UMG.Button", canvas)
            if floatItem.btn and slua.isValid(floatItem.btn) then
                pcall(function() floatItem.btn:SetColorAndOpacity(C.transparent) end)
                pcall(function() floatItem.btn:SetBackgroundColor(C.transparent) end)
                pcall(function() floatItem.btn:SetWidgetVisibility(UEnums.ESlateVisibility.Visible) end)
                local slot = canvas:AddChildToCanvas(floatItem.btn)
                if slot then
                    slot:SetAutoSize(false)
                    slot:SetPosition(FVector2D(fX, fY))
                    slot:SetSize(FVector2D(fW, fH))
                    slot:SetZOrder(12002)
                end
                pcall(function()
                    if floatItem.btn.OnClicked then
                        floatItem.btn.OnClicked:Add(function()
                            pcall(function()
                                isMenuOpen = not isMenuOpen
                                if isMenuOpen then
                                    if menuBuilt and bgPanel and IsValid(bgPanel) then
                                        ShowMenu()
                                    else
                                        BuildMenu()
                                    end
                                else
                                    HideMenu()
                                end
                            end)
                        end)
                    end
                end)
            end
        end)
    end)
end


-- ===== AIMBOT SYSTEM (from 2.lua) =====


pcall(function()
    print("[Aimbot] Loading module...")
    
    local aimbotTimer = nil
    local lastWeapon = nil
    local origAccuracy = nil
    local origFactor = nil
    local origRecoil = nil
    local origSaved = false
    
    local function ApplyAimbot(weapon)
        if not slua.isValid(weapon) then return end
        
        -- Only apply if Aimbot toggle is ON
        local enabled = _G.VIPConfig and _G.VIPConfig.AIMBOT_Enabled or false
        if not enabled then
            -- Restore SAVED original values when OFF (not hardcoded 1.0)
            if lastWeapon then
                local oldEntity = lastWeapon.ShootWeaponEntityComp
                if not slua.isValid(oldEntity) then
                    oldEntity = lastWeapon.STExtraShootWeaponComponent
                end
                if slua.isValid(oldEntity) then
                    pcall(function()
                        oldEntity.GameDeviationAccuracy = origAccuracy or 1.0
                        oldEntity.GameDeviationFactor = origFactor or 1.0
                        oldEntity.RecoilKickADS = origRecoil or 1.0
                    end)
                end
            end
            lastWeapon = nil
            return
        end
        
        if weapon == lastWeapon then return end
        
        local entity = weapon.ShootWeaponEntityComp
        if not slua.isValid(entity) then
            entity = weapon.STExtraShootWeaponComponent
        end
        if not slua.isValid(entity) then return end
        
        -- Save ORIGINAL values BEFORE modifying (only first time)
        if not origSaved then
            pcall(function()
                origAccuracy = entity.GameDeviationAccuracy
                origFactor = entity.GameDeviationFactor
                origRecoil = entity.RecoilKickADS
                origSaved = true
            end)
        end
        
        pcall(function()
            entity.GameDeviationAccuracy = 0.0003
            entity.GameDeviationFactor = 0.0003
            entity.RecoilKickADS = 0.0003
            
            if entity.AutoAimingConfig then
                for _, range in ipairs({"OuterRange", "InnerRange"}) do
                    local cfg = entity.AutoAimingConfig[range]
                    if cfg then
                        cfg.Speed = 10.55
                        cfg.RangeRate = 5.88
                        cfg.SpeedRate = 5.88
                        cfg.RangeRateSight = 3.55
                        cfg.SpeedRateSight = 3.55
                        cfg.CrouchRate = 3
                        cfg.ProneRate = 3
                        cfg.DyingRate = 0
                    end
                end
            end
        end)
        
        lastWeapon = weapon
        print("[Aimbot] Applied to weapon")
    end
    
    function _aimbot_Init(self)
        if aimbotTimer then return end
        
        aimbotTimer = self:AddGameTimer(0.3, true, function()
            if not slua.isValid(self.Object) then return end
            
            local wm = self.Object.WeaponManagerComponent
            if slua.isValid(wm) then
                local currWeapon = wm.CurrentWeaponReplicated
                if slua.isValid(currWeapon) then
                    ApplyAimbot(currWeapon)
                end
            end
        end)
    end
    
    function _aimbot_Cleanup(self)
        if aimbotTimer then 
            self:RemoveGameTimer(aimbotTimer)
            aimbotTimer = nil
        end
        -- Restore original values on cleanup
        if lastWeapon then
            local entity = lastWeapon.ShootWeaponEntityComp
            if not slua.isValid(entity) then
                entity = lastWeapon.STExtraShootWeaponComponent
            end
            if slua.isValid(entity) and origSaved then
                pcall(function()
                    entity.GameDeviationAccuracy = origAccuracy or 1.0
                    entity.GameDeviationFactor = origFactor or 1.0
                    entity.RecoilKickADS = origRecoil or 1.0
                end)
            end
        end
        lastWeapon = nil
        origSaved = false
        origAccuracy = nil
        origFactor = nil
        origRecoil = nil
    end
    
    local function StartAimbot()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then
            local pawn = pc:GetPlayerCharacterSafety()
            if slua.isValid(pawn) then
                _aimbot_Init(pawn)
                return true
            end
        end
        return false
    end
    
    local retryCount = 0
    local function RetryAimbot()
        if retryCount >= 20 then return end
        retryCount = retryCount + 1
        if StartAimbot() then
            print("[Aimbot] Active! Zero recoil + auto-aim")
        else
            if _G.Game and _G.Game.AddGameTimer then
                _G.Game.AddGameTimer(1.0, false, RetryAimbot)
            end
        end
    end
    
    RetryAimbot()
    
    print("[Aimbot] Module ready")
end)
-- ===== END AIMBOT SYSTEM =====

-- ===== SKIN POPUP (inside do block - uses proven GetCanvas/FloatLayer pattern) =====
_G._SkinPopupShown = false
_G._SkinPopupReset = false
-- Only reset _SkinPopupDone if this is a fresh game session (not match reload)
if not _G._SkinPopupSessionStarted then
    _G._SkinPopupDone = false
end
_G._SkinPopupSessionStarted = true
_G._SkinPopupWidgets = nil

local function HideSkinPopup()
    pcall(function()
        if _G._SkinPopupWidgets then
            for _, w in ipairs(_G._SkinPopupWidgets) do
                if w and slua.isValid(w) then pcall(function() w:RemoveFromParent() end) end
            end
        end
    end)
    _G._SkinPopupWidgets = nil
end

local function ShowSkinPopup()
    if _G._SkinPopupShown then return end
    if _G._SkinPopupDone then return end
    local canvas = GetCanvas()
    if not canvas then return end
    _G._SkinPopupShown = true
    _G._SkinPopupDone = true
    _G._SkinPopupWidgets = {}

    local pw, ph = 360, 200
    local px, py = 960 - pw * 0.5, 540 - ph * 0.5
                        pcall(function()
                            if canvas and canvas.GetDesiredSize then
                                local sz = canvas:GetDesiredSize()
                                if sz and sz.X > 0 and sz.Y > 0 then
                                    px = sz.X * 0.5 - pw * 0.5
                                    py = sz.Y * 0.5 - ph * 0.5
                                end
                            end
                        end)

    -- Popup bg (using FloatLayer - same as floating button)
    table.insert(_G._SkinPopupWidgets, FloatLayer(canvas, px-4, py-4, pw+8, ph+8, FLinearColor(0.25,0.19,0.0,1.0), 19998))
    table.insert(_G._SkinPopupWidgets, FloatLayer(canvas, px-2, py-2, pw+4, ph+4, FLinearColor(0.03,0.03,0.04,1.0), 19999))
    table.insert(_G._SkinPopupWidgets, FloatLayer(canvas, px, py, pw, ph, FLinearColor(0.04,0.035,0.05,0.98), 20000))
    table.insert(_G._SkinPopupWidgets, FloatLayer(canvas, px, py, pw, 50, FLinearColor(0.12,0.09,0.02,1.0), 20001))
    table.insert(_G._SkinPopupWidgets, FloatLayer(canvas, px+2, py+2, pw-4, 1, FLinearColor(0.85,0.68,0.0,1.0), 20002))
    table.insert(_G._SkinPopupWidgets, FloatLayer(canvas, px+2, py+ph-3, pw-4, 1, FLinearColor(0.85,0.68,0.0,1.0), 20002))

    -- Title text (manual creation - same as floating button text)
    pcall(function()
        local t = CGame:NewObjectFromPath("/Script/UMG.TextBlock", canvas)
        if t and slua.isValid(t) then
            t:SetText("VIP SKIN SYSTEM")
            if FSlateColor then t:SetColorAndOpacity(FSlateColor(FLinearColor(1.0,0.84,0.08,1.0)))
            else t:SetColorAndOpacity(FLinearColor(1.0,0.84,0.08,1.0)) end
            if t.Font then local f = t.Font f.Size = 22 t.Font = f end
            t:SetRenderTransformPivot(FVector2D(0.5, 0.5))
            t:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            local slot = canvas:AddChildToCanvas(t)
            if slot then slot:SetAutoSize(true) slot:SetAlignment(FVector2D(0.5, 0.5)) slot:SetPosition(FVector2D(px+pw*0.5, py+25)) slot:SetZOrder(20010) end
            table.insert(_G._SkinPopupWidgets, t)
        end
    end)

    -- Subtitle text
    pcall(function()
        local t = CGame:NewObjectFromPath("/Script/UMG.TextBlock", canvas)
        if t and slua.isValid(t) then
            t:SetText("Skin Enable Kar Na Hai Kya?")
            if FSlateColor then t:SetColorAndOpacity(FSlateColor(FLinearColor(0.9,0.9,0.9,1.0)))
            else t:SetColorAndOpacity(FLinearColor(0.9,0.9,0.9,1.0)) end
            if t.Font then local f = t.Font f.Size = 18 t.Font = f end
            t:SetRenderTransformPivot(FVector2D(0.5, 0.5))
            t:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            local slot = canvas:AddChildToCanvas(t)
            if slot then slot:SetAutoSize(true) slot:SetAlignment(FVector2D(0.5, 0.5)) slot:SetPosition(FVector2D(px+pw*0.5, py+70)) slot:SetZOrder(20010) end
            table.insert(_G._SkinPopupWidgets, t)
        end
    end)

    -- Credit text
    pcall(function()
        local t = CGame:NewObjectFromPath("/Script/UMG.TextBlock", canvas)
        if t and slua.isValid(t) then
            t:SetText("@YADAV524")
            if FSlateColor then t:SetColorAndOpacity(FSlateColor(FLinearColor(0.85,0.68,0.0,0.8)))
            else t:SetColorAndOpacity(FLinearColor(0.85,0.68,0.0,0.8)) end
            if t.Font then local f = t.Font f.Size = 14 t.Font = f end
            t:SetRenderTransformPivot(FVector2D(0.5, 0.5))
            t:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            local slot = canvas:AddChildToCanvas(t)
            if slot then slot:SetAutoSize(true) slot:SetAlignment(FVector2D(0.5, 0.5)) slot:SetPosition(FVector2D(px+pw*0.5, py+95)) slot:SetZOrder(20010) end
            table.insert(_G._SkinPopupWidgets, t)
        end
    end)

    -- ON button bg
    table.insert(_G._SkinPopupWidgets, FloatLayer(canvas, px+30, py+120, 130, 50, FLinearColor(0.12,0.09,0.02,1.0), 20003))
    table.insert(_G._SkinPopupWidgets, FloatLayer(canvas, px+32, py+122, 126, 46, FLinearColor(0.85,0.68,0.0,0.15), 20004))

    -- ON text
    pcall(function()
        local t = CGame:NewObjectFromPath("/Script/UMG.TextBlock", canvas)
        if t and slua.isValid(t) then
            t:SetText("ON")
            if FSlateColor then t:SetColorAndOpacity(FSlateColor(FLinearColor(1.0,0.84,0.08,1.0)))
            else t:SetColorAndOpacity(FLinearColor(1.0,0.84,0.08,1.0)) end
            if t.Font then local f = t.Font f.Size = 20 t.Font = f end
            t:SetRenderTransformPivot(FVector2D(0.5, 0.5))
            t:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            local slot = canvas:AddChildToCanvas(t)
            if slot then slot:SetAutoSize(true) slot:SetAlignment(FVector2D(0.5, 0.5)) slot:SetPosition(FVector2D(px+95, py+145)) slot:SetZOrder(20005) end
            table.insert(_G._SkinPopupWidgets, t)
        end
    end)

    -- ON click button (manual - same as floating button)
    pcall(function()
        local btn = CGame:NewObjectFromPath("/Script/UMG.Button", canvas)
        if btn and slua.isValid(btn) then
            btn:SetColorAndOpacity(FLinearColor(0,0,0,0))
            btn:SetBackgroundColor(FLinearColor(0,0,0,0))
            btn:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
            local slot = canvas:AddChildToCanvas(btn)
            if slot then slot:SetAutoSize(false) slot:SetPosition(FVector2D(px+30, py+120)) slot:SetSize(FVector2D(130, 50)) slot:SetZOrder(20050) end
            if btn.OnClicked then
                btn.OnClicked:Add(function()
                    pcall(function()
                        _G.LexusConfig = _G.LexusConfig or {}
                        _G.LexusConfig.ModSkin = true
                        _G.LexusConfig.ModEmote = true
                        _G.LexusConfig.SkinDeadBox = true
                        _G.LexusConfig.SkinAttachment = true
                        _G.LexusConfig.KillMessage = true
                        _G.LexusConfig.KillCountUI = true
                        _G.LexusConfig.SkinOptionOpen = true
                        _G.LexusConfig.SkinOpenLink = true
                        -- All dress/outfit items ON
                        _G.LexusConfig.SkinEnable_Suit = true
                        _G.LexusConfig.SkinEnable_Top = true
                        _G.LexusConfig.SkinEnable_Gloves = true
                        _G.LexusConfig.SkinEnable_Bottom = true
                        _G.LexusConfig.SkinEnable_Shoes = true
                        _G.LexusConfig.SkinEnable_Bag = true
                        _G.LexusConfig.SkinEnable_Helmet = true
                        _G.LexusConfig.SkinEnable_Parachute = true
                        -- All weapon skins ON
                        _G.LexusConfig.SkinEnable_M416 = true
                        _G.LexusConfig.SkinEnable_AKM = true
                        _G.LexusConfig.SkinEnable_SCAR = true
                        _G.LexusConfig.SkinEnable_M762 = true
                        _G.LexusConfig.SkinEnable_AUG = true
                        _G.LexusConfig.SkinEnable_UMP = true
                        _G.LexusConfig.SkinEnable_UZI = true
                        _G.LexusConfig.SkinEnable_Groza = true
                        _G.LexusConfig.SkinEnable_S12K = true
                        _G.LexusConfig.SkinEnable_DBS = true
                        -- All vehicle skins ON
                        _G.LexusConfig.SkinEnable_Dacia = true
                        _G.LexusConfig.SkinEnable_UAZ = true
                        _G.LexusConfig.SkinEnable_Coupe = true
                        _G.LexusConfig.SkinEnable_Buggy = true
                        _G.LexusConfig.SkinEnable_Mirado = true
                        _G.VIPConfig = _G.VIPConfig or {}
                        _G.VIPConfig.SKIN_ModSkin = true
                        _G.VIPConfig.SKIN_ModEmote = true
                        _G.VIPConfig.SKIN_DeadBox = true
                        _G.VIPConfig.SKIN_Attachment = true
                        _G.VIPConfig.SKIN_KillMsg = true
                        _G.VIPConfig.SKIN_KillCount = true
                        _G.AddOutfitLobbyRestored = false
                        _G._SkinPopupShown = false
                        _G._SkinPopupDone = true
                        HideSkinPopup()
                        -- Update menu toggle rows
                        pcall(function()
                            for _, row in ipairs(toggleRows) do
                                if row and row.key and row.key:match("^SKIN_") then
                                    UpdateToggleRow(row)
                                end
                            end
                        end)
                    end)
                end)
            end
            if btn.OnPressed then
                btn.OnPressed:Add(function()
                    pcall(function()
                        _G.LexusConfig = _G.LexusConfig or {}
                        _G.LexusConfig.ModSkin = true
                        _G.LexusConfig.ModEmote = true
                        _G.LexusConfig.SkinDeadBox = true
                        _G.LexusConfig.SkinAttachment = true
                        _G.LexusConfig.KillMessage = true
                        _G.LexusConfig.KillCountUI = true
                        _G.LexusConfig.SkinOptionOpen = true
                        _G.LexusConfig.SkinOpenLink = true
                        -- All dress/outfit items ON
                        _G.LexusConfig.SkinEnable_Suit = true
                        _G.LexusConfig.SkinEnable_Top = true
                        _G.LexusConfig.SkinEnable_Gloves = true
                        _G.LexusConfig.SkinEnable_Bottom = true
                        _G.LexusConfig.SkinEnable_Shoes = true
                        _G.LexusConfig.SkinEnable_Bag = true
                        _G.LexusConfig.SkinEnable_Helmet = true
                        _G.LexusConfig.SkinEnable_Parachute = true
                        -- All weapon skins ON
                        _G.LexusConfig.SkinEnable_M416 = true
                        _G.LexusConfig.SkinEnable_AKM = true
                        _G.LexusConfig.SkinEnable_SCAR = true
                        _G.LexusConfig.SkinEnable_M762 = true
                        _G.LexusConfig.SkinEnable_AUG = true
                        _G.LexusConfig.SkinEnable_UMP = true
                        _G.LexusConfig.SkinEnable_UZI = true
                        _G.LexusConfig.SkinEnable_Groza = true
                        _G.LexusConfig.SkinEnable_S12K = true
                        _G.LexusConfig.SkinEnable_DBS = true
                        -- All vehicle skins ON
                        _G.LexusConfig.SkinEnable_Dacia = true
                        _G.LexusConfig.SkinEnable_UAZ = true
                        _G.LexusConfig.SkinEnable_Coupe = true
                        _G.LexusConfig.SkinEnable_Buggy = true
                        _G.LexusConfig.SkinEnable_Mirado = true
                        _G.VIPConfig = _G.VIPConfig or {}
                        _G.VIPConfig.SKIN_ModSkin = true
                        _G.VIPConfig.SKIN_ModEmote = true
                        _G.VIPConfig.SKIN_DeadBox = true
                        _G.VIPConfig.SKIN_Attachment = true
                        _G.VIPConfig.SKIN_KillMsg = true
                        _G.VIPConfig.SKIN_KillCount = true
                        _G.AddOutfitLobbyRestored = false
                        _G._SkinPopupShown = false
                        _G._SkinPopupDone = true
                        HideSkinPopup()
                        -- Update menu toggle rows
                        pcall(function()
                            for _, row in ipairs(toggleRows) do
                                if row and row.key and row.key:match("^SKIN_") then
                                    UpdateToggleRow(row)
                                end
                            end
                        end)
                    end)
                end)
            end
            table.insert(_G._SkinPopupWidgets, btn)
        end
    end)

    -- OFF button bg
    table.insert(_G._SkinPopupWidgets, FloatLayer(canvas, px+200, py+120, 130, 50, FLinearColor(0.06,0.02,0.02,1.0), 20003))
    table.insert(_G._SkinPopupWidgets, FloatLayer(canvas, px+202, py+122, 126, 46, FLinearColor(0.90,0.16,0.16,0.15), 20004))

    -- OFF text
    pcall(function()
        local t = CGame:NewObjectFromPath("/Script/UMG.TextBlock", canvas)
        if t and slua.isValid(t) then
            t:SetText("OFF")
            if FSlateColor then t:SetColorAndOpacity(FSlateColor(FLinearColor(0.90,0.16,0.16,1.0)))
            else t:SetColorAndOpacity(FLinearColor(0.90,0.16,0.16,1.0)) end
            if t.Font then local f = t.Font f.Size = 20 t.Font = f end
            t:SetRenderTransformPivot(FVector2D(0.5, 0.5))
            t:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            local slot = canvas:AddChildToCanvas(t)
            if slot then slot:SetAutoSize(true) slot:SetAlignment(FVector2D(0.5, 0.5)) slot:SetPosition(FVector2D(px+265, py+145)) slot:SetZOrder(20005) end
            table.insert(_G._SkinPopupWidgets, t)
        end
    end)

    -- OFF click button (manual - same as floating button)
    pcall(function()
        local btn = CGame:NewObjectFromPath("/Script/UMG.Button", canvas)
        if btn and slua.isValid(btn) then
            btn:SetColorAndOpacity(FLinearColor(0,0,0,0))
            btn:SetBackgroundColor(FLinearColor(0,0,0,0))
            btn:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
            local slot = canvas:AddChildToCanvas(btn)
            if slot then slot:SetAutoSize(false) slot:SetPosition(FVector2D(px+200, py+120)) slot:SetSize(FVector2D(130, 50)) slot:SetZOrder(20050) end
            if btn.OnClicked then
                btn.OnClicked:Add(function()
                    pcall(function()
                        _G.LexusConfig = _G.LexusConfig or {}
                        _G.LexusConfig.ModSkin = false
                        _G.LexusConfig.ModEmote = false
                        _G.LexusConfig.SkinDeadBox = false
                        _G.LexusConfig.SkinAttachment = false
                        _G.LexusConfig.KillMessage = false
                        _G.LexusConfig.KillCountUI = false
                        _G.LexusConfig.SkinOptionOpen = false
                        _G.LexusConfig.SkinOpenLink = false
                        -- All dress/outfit items OFF
                        _G.LexusConfig.SkinEnable_Suit = false
                        _G.LexusConfig.SkinEnable_Top = false
                        _G.LexusConfig.SkinEnable_Gloves = false
                        _G.LexusConfig.SkinEnable_Bottom = false
                        _G.LexusConfig.SkinEnable_Shoes = false
                        _G.LexusConfig.SkinEnable_Bag = false
                        _G.LexusConfig.SkinEnable_Helmet = false
                        _G.LexusConfig.SkinEnable_Parachute = false
                        -- All weapon skins OFF
                        _G.LexusConfig.SkinEnable_M416 = false
                        _G.LexusConfig.SkinEnable_AKM = false
                        _G.LexusConfig.SkinEnable_SCAR = false
                        _G.LexusConfig.SkinEnable_M762 = false
                        _G.LexusConfig.SkinEnable_AUG = false
                        _G.LexusConfig.SkinEnable_UMP = false
                        _G.LexusConfig.SkinEnable_UZI = false
                        _G.LexusConfig.SkinEnable_Groza = false
                        _G.LexusConfig.SkinEnable_S12K = false
                        _G.LexusConfig.SkinEnable_DBS = false
                        -- All vehicle skins OFF
                        _G.LexusConfig.SkinEnable_Dacia = false
                        _G.LexusConfig.SkinEnable_UAZ = false
                        _G.LexusConfig.SkinEnable_Coupe = false
                        _G.LexusConfig.SkinEnable_Buggy = false
                        _G.LexusConfig.SkinEnable_Mirado = false
                        _G.VIPConfig = _G.VIPConfig or {}
                        _G.VIPConfig.SKIN_ModSkin = false
                        _G.VIPConfig.SKIN_ModEmote = false
                        _G.VIPConfig.SKIN_DeadBox = false
                        _G.VIPConfig.SKIN_Attachment = false
                        _G.VIPConfig.SKIN_KillMsg = false
                        _G.VIPConfig.SKIN_KillCount = false
                        _G._SkinPopupShown = false
                        _G._SkinPopupDone = true
                        HideSkinPopup()
                        -- Update menu toggle rows
                        pcall(function()
                            for _, row in ipairs(toggleRows) do
                                if row and row.key and row.key:match("^SKIN_") then
                                    UpdateToggleRow(row)
                                end
                            end
                        end)
                    end)
                end)
            end
            if btn.OnPressed then
                btn.OnPressed:Add(function()
                    pcall(function()
                        _G.LexusConfig = _G.LexusConfig or {}
                        _G.LexusConfig.ModSkin = false
                        _G.LexusConfig.ModEmote = false
                        _G.LexusConfig.SkinDeadBox = false
                        _G.LexusConfig.SkinAttachment = false
                        _G.LexusConfig.KillMessage = false
                        _G.LexusConfig.KillCountUI = false
                        _G.LexusConfig.SkinOptionOpen = false
                        _G.LexusConfig.SkinOpenLink = false
                        -- All dress/outfit items OFF
                        _G.LexusConfig.SkinEnable_Suit = false
                        _G.LexusConfig.SkinEnable_Top = false
                        _G.LexusConfig.SkinEnable_Gloves = false
                        _G.LexusConfig.SkinEnable_Bottom = false
                        _G.LexusConfig.SkinEnable_Shoes = false
                        _G.LexusConfig.SkinEnable_Bag = false
                        _G.LexusConfig.SkinEnable_Helmet = false
                        _G.LexusConfig.SkinEnable_Parachute = false
                        -- All weapon skins OFF
                        _G.LexusConfig.SkinEnable_M416 = false
                        _G.LexusConfig.SkinEnable_AKM = false
                        _G.LexusConfig.SkinEnable_SCAR = false
                        _G.LexusConfig.SkinEnable_M762 = false
                        _G.LexusConfig.SkinEnable_AUG = false
                        _G.LexusConfig.SkinEnable_UMP = false
                        _G.LexusConfig.SkinEnable_UZI = false
                        _G.LexusConfig.SkinEnable_Groza = false
                        _G.LexusConfig.SkinEnable_S12K = false
                        _G.LexusConfig.SkinEnable_DBS = false
                        -- All vehicle skins OFF
                        _G.LexusConfig.SkinEnable_Dacia = false
                        _G.LexusConfig.SkinEnable_UAZ = false
                        _G.LexusConfig.SkinEnable_Coupe = false
                        _G.LexusConfig.SkinEnable_Buggy = false
                        _G.LexusConfig.SkinEnable_Mirado = false
                        _G.VIPConfig = _G.VIPConfig or {}
                        _G.VIPConfig.SKIN_ModSkin = false
                        _G.VIPConfig.SKIN_ModEmote = false
                        _G.VIPConfig.SKIN_DeadBox = false
                        _G.VIPConfig.SKIN_Attachment = false
                        _G.VIPConfig.SKIN_KillMsg = false
                        _G.VIPConfig.SKIN_KillCount = false
                        _G._SkinPopupShown = false
                        _G._SkinPopupDone = true
                        HideSkinPopup()
                        -- Update menu toggle rows
                        pcall(function()
                            for _, row in ipairs(toggleRows) do
                                if row and row.key and row.key:match("^SKIN_") then
                                    UpdateToggleRow(row)
                                end
                            end
                        end)
                    end)
                end)
            end
            table.insert(_G._SkinPopupWidgets, btn)
        end
    end)
end
-- ===== END SKIN POPUP FUNCTIONS =====

-- ===== INIT =====
pcall(function()
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if pc and IsValid(pc) then
        CreateFloat()
        pc:AddGameTimer(3, true, function()
            if not floatItem or not floatItem.btn or not IsValid(floatItem.btn) then
                floatItem = nil
                CreateFloat()
            end
            -- Re-show popup ONLY after match reset (returning to lobby)
            -- Popup only shows once, no re-show after matches
        end)

        -- Show popup once on initial load
        if not _G._SkinPopupShown and not _G._SkinPopupDone then
            ShowSkinPopup()
        end

    end
end)

end


-- ============================ SKIN MOD SYSTEM ============================
-- ============================ FULL SKIN MOD SYSTEM ===========================
-- ============================ (pcall injected for safety) ====================
-- ==============================================================================
pcall(function()
-- ================= Báº®T Äáº¦U CORE ADD-OUTFIT V7.5 (Há»† THá»NG SKIN) =================
-- ==============================================================================
-- Báº£ng map ID phá»¥ kiá»‡n gá»‘c ra index máº£ng
_G.BaseAttachToIndex = {
    [201010]=1, [201005]=1, [201004]=1, [201009]=2, [201003]=2, [201002]=2, 
    [201011]=3, [201007]=3, [201006]=3, [204012]=4, [204005]=4, [204008]=4, 
    [204011]=5, [204004]=5, [204007]=5, [204013]=6, [204006]=6, [204009]=6, 
    [203001]=7, [203002]=8, [203003]=9, [203014]=10, [203004]=11, [203015]=12, [203005]=13, 
    [202002]=14, [202001]=15, [202004]=16, [202005]=17, [202007]=18, [202006]=19, 
    [205002]=20, [205003]=20, [205001]=20, [203018]=21, [204014]=22 
}

-- DÃN ID PHá»¤ KIá»†N Cá»¦A Báº N VÃ€O BÃŠN TRONG NGOáº¶C NHá»ŒN DÆ¯á»šI ÄÃ‚Y â†“â†“â†“
_G.VIP_Attachments = {
    
    [1101004236]={1010042307,1010042306,1010042308,1010042304,1010042300,1010042305,1010042299,1010042298,1010042297,1010042296,1010042295,1010042294,0,1010042314,1010042309,1010042316,1010042317,1010042318,1010042310,1010042315,1010042319,0},
    [1101001116]={1010011106,1010011107,1010011108,0,1010011109,1010011112,1010011105,1010011104,1010011103,0,1010011102,0,0,0,0,0,0,0,0,0,0,0},
    [1101001128]={1010011232,1010011233,1010011234,1010011228,1010011227,1010011229,1010011226,1010011225,1010011224,1010011223,1010011222,0,0,0,0,0,0,0,0,0,0,0},
    [1101001154]={1010011487,1010011488,1010011489,1010011493,1010011490,1010011494,1010011486,1010011485,1010011484,1010011483,1010011482,1010011497,0,0,0,0,0,0,0,0,1010011498,0},
    [1101001174]={1010011667,1010011668,1010011669,1010011673,1010011670,1010011674,1010011666,1010011665,1010011664,1010011663,1010011662,0,0,0,0,0,0,0,0,0,0,0},
    [1101001213]={1010012067,1010012068,1010012069,1010012072,1010012070,1010012073,1010012066,1010012065,1010012064,1010012063,1010012062,0,0,0,0,0,0,0,0,0,1010012074,0},
    [1101001231]={1010012267,1010012268,1010012269,1010012273,1010012272,1010012274,1010012266,1010012265,1010012264,1010012263,1010012262,1010012075,0,0,0,0,0,0,0,0,1010012275,0},
    [1101001242]={1010012357,1010012358,1010012359,1010012363,1010012362,1010012364,1010012356,1010012355,1010012354,1010012353,1010012352,1010012276,0,0,0,0,0,0,0,0,1010012365,0},
    [1101001249]={1010012437,1010012438,1010012439,1010012443,1010012442,1010012444,1010012436,1010012435,1010012434,1010012433,1010012432,1010012366,0,0,0,0,0,0,0,0,1010012445,0},
    [1101001256]={1010012588,1010012589,1010012590,1010012593,1010012592,1010012594,1010012587,1010012586,1010012585,1010012584,1010012583,1010012582,0,0,0,0,0,0,0,0,1010012595,0},
    [1101001265]={1010012698,1010012699,1010012700,1010012703,1010012702,1010012704,1010012697,1010012696,1010012695,1010012694,1010012693,1010012692,0,0,0,0,0,0,0,0,1010012705,0},
    [1101001276]={1010012698,1010012699,1010012700,1010012703,1010012702,1010012704,1010012697,1010012696,1010012695,1010012694,1010012693,1010012692,0,0,0,0,0,0,0,0,1010012705,0},
    [1101002029]={1010020249,1010020250,1010020255,1010020247,1010020246,1010020248,1010020240,1010020239,1010020238,1010020237,1010020236,1010020235,0,0,0,0,0,0,0,1010020257,1010020256,1010020258},
    [1101002056]={1010020519,0,0,1010020517,1010020516,1010020518,1010020500,1010020509,1010020508,1010020507,1010020506,1010020505,0,0,0,0,0,0,0,0,0,0},
    [1101002081]={1010020768,1010020769,1010020770,1010020766,1010020760,1010020767,1010020759,1010020758,1010020757,1010020756,1010020755,1010020776,0,0,0,0,0,0,0,1010020775,1010020777,1010020778},
    [1101003070]={1010030654,1010030653,1010030655,1010030649,1010030648,1010030650,1010030647,1010030646,1010030645,1010030644,1010030643,1010030642,0,1010030658,1010030656,1010030660,1010030662,1010030659,1010030657,0,1010030663,0},
    [1101003080]={1010030754,1010030753,1010030755,1010030749,1010030748,1010030750,1010030747,1010030746,1010030745,1010030744,1010030743,1010030742,0,1010030758,1010030756,1010030760,1010030762,1010030759,1010030757,0,1010030763,0},
    [1101003099]={1010030943,1010030944,1010030945,1010030939,1010030938,1010030942,1010030937,1010030936,1010030935,1010030934,1010030933,1010030932,0,1010030947,1010030946,1010030948,1010030949,1010030953,1010030952,0,1010030955,0},
    [1101003119]={1010031139,1010031140,1010031142,1010031138,1010031137,1010031146,1010031136,1010031135,1010031134,1010031133,1010031132,0,0,1010031144,1010031143,0,0,0,1010031145,0,0,0},
    [1101003146]={1010031229,1010031230,1010031237,1010031228,1010031227,1010031242,1010031226,1010031225,1010031224,1010031223,1010031222,0,0,1010031239,1010031238,0,0,0,1010031240,0,0,0},
    [1101003167]={1010031609,1010031610,1010031613,1010031608,1010031607,1010031617,1010031606,1010031605,1010031604,1010031603,1010031602,1010031618,0,1010031615,1010031614,1010031620,1010031622,1010031619,1010031616,0,1010031623,0},
    [1101003181]={1010031765,1010031764,1010031766,1010031759,1010031758,1010031763,1010031757,1010031756,1010031755,1010031754,1010031753,1010031752,0,1010031769,1010031767,1010031773,1010031774,1010031772,1010031768,0,1010031775,0},
    [1101003195]={1010031912,1010031911,1010031913,1010031908,1010031907,1010031909,1010031906,1010031905,1010031904,1010031903,1010031902,1010031901,0,1010031916,1010031914,1010031918,1010031919,1010031917,1010031915,0,1010031921,0},
    [1101003208]={1010032034,1010032033,1010032045,1010032029,1010032028,1010032032,1010032027,1010032026,1010032025,1010032024,1010032023,1010032022,0,1010032038,1010032036,1010032042,1010032043,1010032039,1010032037,0,1010032044,0},
    [1101004046]={1010040474,1010040475,1010040476,1010040472,1010040471,1010040473,1010040470,1010040469,1010040468,1010040467,1010040466,1010040481,0,1010040479,1010040477,1010040482,1010040483,1010040484,1010040478,1010040480,1010040485,0},
    [1101004062]={1010040578,1010040577,1010040579,1010040575,1010040570,1010040576,1010040569,1010040568,1010040567,1010040566,1010040565,1010040564,0,1010040585,1010040580,1010040587,1010040588,1010040589,1010040584,1010040586,1010040590,1010040594},
    [1101004098]={1010040924,1010040926,1010040925,0,1010040937,1010040938,1010040935,1010040934,1010040929,1010040928,1010040927,0,0,1010040939,1010040945,0,0,0,1010040944,1010040936,0,0},
    [1101004138]={1010041136,1010041137,1010041138,1010041134,1010041129,1010041135,1010041128,1010041127,1010041126,1010041125,1010041124,0,0,1010041145,1010041139,0,0,0,1010041144,1010041146,0,0},
    [1101004163]={1010041570,1010041574,1010041575,1010041568,1010041567,1010041569,1010041566,1010041565,1010041564,1010041560,1010041554,0,0,1010041578,1010041576,0,0,0,1010041577,1010041579,0,0},
    [1101004201]={1010041956,1010041957,1010041958,1010041950,1010041949,1010041955,1010041948,1010041947,1010041946,1010041945,1010041944,1010041967,0,1010041965,1010041959,0,0,0,1010041960,1010041966,0,0},
    [1101004209]={1010042038,1010042037,1010042039,1010042035,1010042034,1010042036,1010042029,1010042028,1010042027,1010042026,1010042025,1010042024,0,1010042046,1010042044,1010042048,1010042049,1010042054,1010042045,1010042047,1010042055,0},
    [1101004218]={1010042128,1010042127,1010042129,1010042125,1010042124,1010042126,1010042119,1010042118,1010042117,1010042116,1010042115,1010042114,0,1010042136,1010042134,1010042138,1010042139,1010042144,1010042135,1010042137,1010042145,0},
    [1101004226]={1010042238,1010042237,1010042239,1010042235,1010042234,1010042236,1010042233,1010042232,1010042231,1010042219,1010042218,1010042217,0,1010042243,1010042241,1010042245,1010042246,1010042247,1010042242,1010042244,1010042248,0},
    [1101004246]={1010042406,1010042407,1010042408,1010042404,1010042400,1010042405,1010042399,1010042398,1010042397,1010042396,1010042395,1010042394,0,1010042414,1010042409,1010042416,1010042417,1010042418,1010042410,1010042415,1010042419,1010042420},
    [1101005038]={0,0,1010050327,1010050329,1010050328,1010050330,1010050326,1010050325,1010050324,1010050323,1010050322,1010050334,0,0,0,0,0,0,0,0,0,0},
    [1101005052]={0,0,1010050467,1010050469,1010050468,1010050470,1010050466,1010050465,1010050464,1010050463,1010050462,1010050473,0,0,0,0,0,0,0,0,0,0},
    [1101005098]={0,0,1010050928,1010050930,1010050929,1010050932,1010050927,1010050926,1010050925,1010050924,1010050923,1010050922,0,0,0,0,0,0,0,0,0,0},
    [1101006062]={1010060573,1010060572,1010060574,1010060564,1010060563,1010060571,1010060562,1010060561,1010060554,1010060553,1010060552,1010060551,0,1010060583,1010060581,1010060591,1010060592,1010060584,1010060582,0,1010060593,0},
    [1101006075]={1010060702,1010060701,1010060703,1010060698,1010060697,1010060699,1010060696,1010060695,1010060694,1010060693,1010060692,1010060691,0,1010060706,1010060704,1010060708,1010060709,1010060707,1010060705,0,1010060711,0},
    [1101006085]={1010060796,1010060795,1010060797,1010060793,1010060789,1010060794,1010060788,1010060787,1010060786,1010060785,1010060784,1010060783,0,1010060800,1010060798,1010060804,1010060805,1010060803,1010060799,0,1010060806,0},
    [1101007046]={1010070410,1010070413,1010070414,1010070408,1010070407,1010070409,1010070406,1010070405,1010070404,1010070403,1010070402,1010070418,0,1010070417,1010070415,1010070420,1010070422,1010070419,1010070416,0,1010070423,0},
    [1101007062]={1010070579,1010070578,1010070581,1010070576,1010070575,1010070577,1010070574,1010070573,1010070572,1010070571,1010070569,1010070568,0,1010070584,1010070582,1010070585,1010070586,1010070587,1010070583,0,1010070588,0},
    [1101007071]={1010070663,1010070662,1010070664,1010070659,1010070658,1010070660,1010070657,1010070656,1010070655,1010070654,1010070653,1010070652,0,1010070667,1010070665,1010070668,1010070669,1010070670,1010070666,0,1010070672,0},
    [1101008051]={1010080463,1010080464,1010080465,1010080459,1010080458,1010080462,1010080457,1010080456,1010080455,1010080454,1010080453,1010080452,0,1010080467,1010080466,1010080468,1010080469,1010080473,1010080472,0,1010080475,0},
    [1101008061]={1010080563,1010080564,1010080565,1010080559,1010080558,1010080562,1010080557,1010080556,1010080555,1010080554,1010080553,0,0,1010080567,1010080566,0,0,0,1010080572,0,0,0},
    [1101008070]={1010080609,1010080612,1010080613,1010080608,1010080607,1010080617,1010080606,1010080605,1010080604,1010080603,1010080602,0,0,1010080615,1010080614,0,0,0,1010080616,0,0,0},
    [1101008081]={1010080740,1010080743,1010080745,1010080738,1010080737,1010080739,1010080736,1010080735,1010080734,1010080733,1010080732,1010080748,0,1010080747,1010080746,1010080750,1010080752,1010080749,1010080744,0,1010080753,0},
    [1101008104]={1010080980,1010080982,1010080984,1010080978,1010080977,1010080979,1010080976,1010080975,1010080974,1010080973,1010080972,1010080992,0,1010080986,1010080985,1010080989,1010080987,1010080993,1010080983,0,1010080988,0},
    [1101008116]={1010081110,1010081112,1010081114,1010081108,1010081107,1010081109,1010081106,1010081105,1010081104,1010081103,1010081102,0,0,1010081116,1010081115,0,0,0,1010081113,0,0,0},
    [1101008126]={1010081210,1010081225,1010081226,1010081208,1010081207,1010081209,1010081206,1010081205,1010081204,1010081203,1010081202,1010081218,0,1010081217,1010081216,1010081219,1010081220,1010081222,1010081214,1010081228,1010081227,1010081229},
    [1101008136]={1010081314,1010081315,1010081316,1010081312,1010081308,1010081313,1010081307,1010081306,1010081305,1010081304,1010081303,1010081302,0,1010081318,1010081317,1010081322,1010081323,1010081325,1010081324,0,1010081326,0},
    [1101008146]={1010081401,1010081402,1010081403,1010081398,1010081397,1010081399,1010081396,1010081395,1010081394,1010081393,1010081392,1010081391,0,1010081405,1010081404,1010081406,1010081407,1010081409,1010081408,0,1010081411,0},
    [1101008154]={1010081531,1010081532,1010081533,1010081528,1010081527,1010081529,1010081526,1010081525,1010081524,1010081523,1010081522,1010081521,0,1010081541,1010081534,1010081542,1010081543,1010081545,1010081544,0,1010081546,0},
    [1101008163]={1010081582,1010081583,1010081584,1010081579,1010081578,1010081580,1010081577,1010081576,1010081575,1010081574,1010081573,1010081572,0,1010081586,1010081585,1010081587,1010081588,1010081590,1010081589,0,1010081592,0},
    [1101012033]={1010120284,1010120285,1010120286,1010120280,1010120279,1010120283,1010120278,1010120277,1010120276,1010120275,1010120274,1010120273,0,0,0,0,0,0,0,0,1010120287,0},
    [1101100012]={1011000066,1011000067,1011000068,0,0,0,1011000058,1011000057,1011000056,1011000055,1011000054,1011000053,0,0,0,0,0,0,0,0,1011000073,0},
    [1101102007]={1011010025,1011010024,1011010026,1011010020,1011010019,1011010023,1011010018,1011010017,1011010016,1011010015,1011010014,1011010013,0,0,0,0,0,0,0,0,1011010027,0},
    [1101102017]={1011020027,1011020028,1011020029,1011020025,1011020024,1011020026,1011020019,1011020018,1011020017,1011020016,1011020015,1011020014,0,1011020036,1011020034,1011020038,1011020039,1011020044,1011020035,1011020037,1011020045,1011020047},
    [1101102025]={1011020127,1011020128,1011020129,1011020125,1011020124,1011020126,1011020119,1011020118,1011020117,1011020116,1011020115,1011020114,0,1011020136,1011020134,1011020138,1011020139,1011020144,1011020135,1011020137,1011020145,0},
    [1101102041]={1011020214,1011020215,1011020216,1011020212,1011020211,1011020213,1011020209,1011020208,1011020207,1011020206,1011020205,1011020204,0,1011020219,1011020217,1011020222,1011020223,1011020224,1011020218,1011020221,1011020225,1011020229},
    [1101102049]={1011020356,1011020357,1011020358,1011020354,1011020350,1011020355,1011020349,1011020348,1011020347,1011020346,1011020345,1011020344,0,1011020364,1011020359,1011020366,1011020367,1011020368,1011020360,1011020365,1011020369,1011020370},
    [1101101007]={1011020436,1011020437,1011020438,1011020434,1011020430,1011020435,1011020429,1011020428,1011020427,1011020426,1011020425,1011020424,0,1011020444,1011020439,1011020446,1011020447,1011020448,1011020440,1011020445,1011020449,1011020450},
    [1102001120]={1020011137,1020011138,1020011139,1020011135,1020011134,1020011136,1020011133,1020011132,0,0,0,0,0,0,0,0,0,0,0,1020011142,0,0},
    [1102001130]={1020011247,1020011248,1020011249,1020011245,1020011244,1020011246,1020011243,1020011242,0,0,0,0,0,0,0,0,0,0,0,1020011250,0,0},
    [1102002043]={1020020372,1020020374,1020020373,1020020383,1020020380,1020020384,1020020379,1020020378,1020020377,1020020376,1020020375,1020020388,0,1020020385,1020020387,0,0,0,1020020386,0,0,0},
    [1102002061]={1020020552,1020020554,1020020553,1020020563,1020020562,1020020564,1020020559,1020020558,1020020557,1020020556,1020020555,1020020578,0,1020020565,1020020567,1020020573,1020020574,1020020572,1020020566,0,1020020569,0},
    [1102002136]={1020021314,1020021313,1020021315,1020021309,1020021308,1020021312,1020021307,1020021306,1020021305,1020021304,1020021303,1020021302,0,1020021318,1020021316,1020021323,1020021324,1020021322,1020021317,0,1020021325,0},
    [1102002424]={1020024193,1020024192,1020024194,1020024189,1020024188,1020024190,1020024187,1020024186,1020024185,1020024184,1020024183,1020024182,0,1020024197,1020024195,1020024199,1020024200,1020024198,1020024196,0,1020024202,0},
    [1102003080]={1020030755,1020030756,1020030758,0,1020030749,1020030754,1020030748,1020030747,1020030746,1020030745,1020030744,1020030764,0,1020030760,0,1020030759,1020030757,0,0,1020030765,0,0},
    [1102003100]={1020030956,1020030957,1020030958,1020030954,1020030950,1020030955,1020030949,1020030948,1020030947,1020030946,1020030945,1020030944,0,1020030964,0,1020030960,1020030959,1020030965,0,1020030967,1020030966,1020030968},
    [1102005064]={1020050588,1020050589,1020050590,0,0,0,1020050587,1020050586,1020050585,1020050584,1020050583,1020050582,0,0,0,0,0,0,0,0,1020050592,0},
    [1103001101]={1030010954,1030010955,1030010956,0,0,0,0,0,0,0,1030010953,1030010952,1030010951,0,0,0,0,0,0,1030010957,0,1030010958},
    [1103001146]={1030011344,1030011345,1030011346,0,0,0,0,0,0,0,1030011343,1030011342,1030011341,0,0,0,0,0,0,1030011347,0,1030011348},
    [1103001154]={1030011484,1030011485,1030011486,0,0,0,0,0,0,0,1030011483,1030011482,1030011481,0,0,0,0,0,0,1030011487,0,1030011488},
    [1103001179]={1030011738,1030011739,1030011741,0,0,0,1030011737,1030011736,1030011735,1030011734,1030011733,1030011732,1030011731,0,0,0,0,0,0,1030011742,1030011743,1030011744},
    [1103001191]={1030011858,1030011859,1030011861,0,0,0,1030011857,1030011856,1030011855,1030011854,1030011853,1030011852,1030011851,0,0,0,0,0,0,1030011862,1030011863,1030011864},
    [1103001202]={1030011948,1030011949,1030011950,0,0,0,1030011947,1030011946,1030011945,1030011944,1030011943,1030011942,1030011941,0,0,0,0,0,0,1030011951,1030011952,1030011953},
    [1103002030]={1030020245,1030020246,1030020247,1030020252,1030020249,1030020253,1030020258,1030020257,1030020256,1030020255,1030020244,1030020243,1030020242,0,0,0,0,0,0,1030020248,0,0},
    [1103002059]={1030020544,1030020545,1030020546,1030020542,1030020539,1030020543,1030020538,1030020537,1030020536,1030020535,1030020534,1030020533,1030020532,0,0,0,0,0,0,1030020547,1030020548,0},
    [1103002087]={1030020824,1030020825,1030020826,0,0,0,1030020818,1030020817,1030020816,1030020815,1030020814,1030020813,1030020812,0,0,0,0,0,0,1030020827,1030020828,0},
    [1103002106]={1030021009,1030021010,1030021012,1030021015,1030021014,1030021016,1030021008,1030021007,1030021006,1030021005,1030021004,1030021003,1030021002,0,0,0,0,0,0,1030021013,1030021017,0},
    [1103002113]={1030021079,1030021080,1030021082,1030021085,1030021084,1030021086,1030021078,1030021077,1030021076,1030021075,1030021074,1030021073,1030021072,0,0,0,0,0,0,1030021083,1030021087,0},
    [1103003022]={1030030165,1030030166,1030030167,1030030172,1030030169,1030030173,0,0,0,0,1030030164,1030030163,1030030162,0,0,0,0,0,0,0,0,0},
    [1103003030]={1030030256,1030030257,1030030258,1030030254,1030030253,1030030255,1030030248,1030030247,1030030246,1030030245,1030030244,1030030243,1030030242,0,0,0,0,0,0,1030030259,1030030249,0},
    [1103003042]={1030030374,1030030375,1030030376,1030030372,1030030369,1030030373,0,0,0,0,1030030364,1030030363,1030030362,0,0,0,0,0,0,1030030377,0,0},
    [1103003051]={1030030458,1030030459,1030030460,1030030456,1030030455,1030030457,0,0,0,0,1030030454,1030030453,1030030452,0,0,0,0,0,0,1030030463,0,0},
    [1103003062]={1030030568,1030030569,1030030570,1030030566,1030030565,1030030567,0,0,0,0,1030030564,1030030563,1030030562,0,0,0,0,0,0,1030030572,0,0},
    [1103003079]={1030030744,1030030745,1030030746,1030030742,1030030740,1030030743,1030030738,1030030737,1030030736,1030030735,1030030734,1030030733,1030030732,0,0,0,0,0,0,1030030747,1030030739,0},
    [1103003087]={1030030825,1030030826,1030030827,1030030823,1030030824,1030030824,1030030818,1030030817,1030030816,1030030815,1030030814,1030030813,1030030812,0,0,0,0,0,0,1030030828,1030030819,0},
    [1103004037]={1030040315,1030040316,1030040317,1030040325,1030040324,1030040323,0,0,0,0,1030040314,1030040313,1030040312,1030040327,1030040326,0,0,0,1030040328,1030040329,0,0},
    [1103006030]={1030060245,1030060246,1030060247,0,1030060253,1030060252,0,0,0,0,1030060244,1030060243,1030060242,0,0,0,0,0,0,0,0,0},
    [1103007028]={1030070233,1030070234,1030070235,1030070226,1030070225,1030070227,1030070218,1030070217,1030070216,1030070215,1030070214,1030070213,1030070212,0,0,0,0,0,0,1030070236,1030070219,0},
    [1103012010]={0,0,0,0,0,0,1030120038,1030120037,1030120036,1030120035,1030120034,1030120033,1030120032,0,0,0,0,0,0,0,0,0},
    [1103012019]={0,0,0,0,0,0,1030120138,1030120137,1030120136,1030120135,1030120134,1030120133,1030120132,0,0,0,0,0,0,0,0,0},
    [1103012031]={0,0,0,0,0,0,1030120258,1030120257,1030120256,1030120255,1030120254,1030120253,1030120252,0,0,0,0,0,0,0,0,0},
    [1103012039]={0,0,0,0,0,0,1030120339,1030120338,1030120337,1030120336,1030120335,1030120334,1030120333,0,0,0,0,0,0,0,0,0},
    [1103102007]={1031020026,1031020027,1031020028,1031020024,1031020023,1031020025,1031020019,1031020018,1031020017,1031020016,1031020015,1031020014,1031020013,0,0,0,0,0,0,1031020029,0,0},
    [1105001034]={0,0,0,0,1050010287,1050010289,1050010286,1050010285,1050010284,1050010283,1050010282,0,0,0,0,0,0,0,0,1050010292,0,0},
    [1105001048]={0,0,0,1050010429,1050010428,1050010434,1050010427,1050010426,1050010425,1050010424,1050010423,0,0,0,0,0,0,0,0,1050010435,0,1050010436},
    [1105001069]={0,0,0,1050010639,1050010638,1050010640,1050010637,1050010636,1050010635,1050010634,1050010633,1050010645,0,0,0,0,0,0,0,1050010643,1050010646,1050010644},
    [1105002091]={0,0,0,0,0,0,1050020847,1050020846,1050020845,1050020844,1050020843,1050020842,0,0,0,0,0,0,0,0,0,1050020848},
    [1105010019]={0,0,0,0,0,0,1050100144,1050100143,1050100142,1050100141,1050100139,1050100138,0,0,0,0,0,0,0,0,0,0},
    -- [ AUG Cá»­u VÄ© Cuá»“ng Ná»™ - Dáº¡ng CÆ¡ Báº£n (MÃ u Äá») ]
    [1101006098] = {1010060925,1010060926,1010060927,1010060919,0,1010060924,1010060918,1010060917,1010060916,1010060915,1010060914,1010060913,0,1010060930,1010060928,1010060929,1010060935,1010060934,1010060933,0,1010060936,0},

    -- [ AUG Cá»­u VÄ© Cuá»“ng Ná»™ - Dáº¡ng Tá»‘i ThÆ°á»£ng (MÃ u VÃ ng) ]
    [1101006106] = {1010061004,1010061005,1010061006,1010060999,1010061000,1010061003,1010060998,1010060997,1010060996,1010060995,1010060994,1010060993,0,1010061009,1010061007,1010061008,1010061014,1010061013,1010061010,0,1010061015,0},
}
-- DÃN ID PHá»¤ KIá»†N Cá»¦A Báº N VÃ€O TRÃŠN ÄÃ‚Y â†‘â†‘â†‘

local cached_GameplayStatics = nil
local cached_PlayerTombBox = nil
local cached_ActorClass = nil
_G.NeedCheckDeadBoxTimer = 0

_G.DeadBox_TemperRequest = function(PlayerController)
    if not _G.LexusConfig.SkinDeadBox or _G.NeedCheckDeadBoxTimer <= 0 then return end
    
    local curTime = os.clock()
    if _G.LastCheckDeadBoxTime and (curTime - _G.LastCheckDeadBoxTime) < 2.0 then return end
    _G.LastCheckDeadBoxTime = curTime
    _G.NeedCheckDeadBoxTimer = _G.NeedCheckDeadBoxTimer - 1

    local PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
    if not slua.isValid(PlayerCharacter) then return end
    
    if not cached_GameplayStatics then
        cached_GameplayStatics = import("GameplayStatics")
        cached_ActorClass = import("Actor")
        cached_PlayerTombBox = import("PlayerTombBox")
    end
    
    if not _G.CachedActorArray_DB then
        _G.CachedActorArray_DB = slua.Array(UEnums.EPropertyClass.Object, cached_ActorClass)
    end
    
    local UI_Util = require("client.common.ui_util")
    local GameInstance = UI_Util and UI_Util.GetGameInstance()
    if not GameInstance or not cached_GameplayStatics then return end

    -- Tá»‘i Æ°u: Láº¥y trÆ°á»›c ID ngÆ°á»i chÆ¡i vÃ  ID sÃºng/xe á»Ÿ ngoÃ i vÃ²ng láº·p Ä‘á»ƒ trÃ¡nh tÃ­nh toÃ¡n láº¡i
    local myPlayerKey = PlayerController.PlayerKey
    local currentBoxSkinId = 0
    pcall(function()
        local curVeh = PlayerCharacter.CurrentVehicle or (type(PlayerCharacter.GetCurrentVehicle) == "function" and PlayerCharacter:GetCurrentVehicle())
        if slua.isValid(curVeh) and _G.CurrentEquipVehicleID and _G.CurrentEquipVehicleID ~= 0 then
            currentBoxSkinId = tonumber(tostring(_G.CurrentEquipVehicleID) .. "1") or 0
        else
            -- [FIX CHUáº¨N VIP]: Láº¥y ID cá»§a vÅ© khÃ­ Ä‘ang cáº§m trÃªn tay Ä‘á»ƒ xuáº¥t Ä‘Ãºng hÃ²m xÃ¡c, Bá» vÃ²ng láº·p Ä‘á»ƒ chá»‘ng Drop FPS
            local curWeapon = PlayerCharacter.GetCurrentWeapon and PlayerCharacter:GetCurrentWeapon() or PlayerCharacter.CurrentWeapon
            if slua.isValid(curWeapon) then
                local defineIDObj = curWeapon.GetItemDefineID and curWeapon:GetItemDefineID()
                local curWeaponID = (defineIDObj and slua.isValid(defineIDObj)) and defineIDObj.TypeSpecificID or 0
                
                -- Äá»‘i chiáº¿u vá»›i kho Skin Ä‘Ã£ lÆ°u Ä‘á»ƒ láº¥y Ä‘Ãºng ID Skin hiá»‡n táº¡i
                if curWeaponID > 0 and _G.AddOutfitLastAppliedSkin and _G.AddOutfitLastAppliedSkin[curWeaponID] then
                    local skinID = _G.AddOutfitLastAppliedSkin[curWeaponID]
                    if skinID and skinID > 1000000 then 
                        currentBoxSkinId = skinID 
                    end
                end
            end
        end
    end)

    if currentBoxSkinId == 0 then return end

    local deadBoxes = cached_GameplayStatics.GetAllActorsOfClass(GameInstance, cached_PlayerTombBox, _G.CachedActorArray_DB)
    if not deadBoxes then return end
    
    local count = type(deadBoxes.Num) == "function" and deadBoxes:Num() or #deadBoxes
    for i = 1, count do
        local deadBoxActor = type(deadBoxes.Get) == "function" and deadBoxes:Get(i-1) or deadBoxes[i]
        if slua.isValid(deadBoxActor) and not deadBoxActor.bIsTDSkinApplied then
            local damageCauser = deadBoxActor.DamageCauser
            -- So sÃ¡nh cá»±c nhanh báº±ng MyPlayerKey Ä‘Ã£ cache
            if slua.isValid(damageCauser) and damageCauser.PlayerKey == myPlayerKey then
                local DeadBoxAvatarComponent = deadBoxActor.DeadBoxAvatarComponent_BP
                if slua.isValid(DeadBoxAvatarComponent) then
                    pcall(function()
                        DeadBoxAvatarComponent:ResetItemAvatar()
                        DeadBoxAvatarComponent:PreChangeItemAvatar(currentBoxSkinId)
                        DeadBoxAvatarComponent:SyncChangeItemAvatar(currentBoxSkinId)
                    end)
                    deadBoxActor.bIsTDSkinApplied = true
                end
            end
        end
    end
end

--[[ AddOutfit v7.5 â€” TÃ­ch há»£p há»‡ thá»‘ng chá»n Skin qua tá»§ Ä‘á»“ (Wardrobe) ]]
local F = {}
local DEBUG = false  
function F.log(...)
    if DEBUG then print("[AddOutfit]", ...) end
end

local MATCH_CONFIG = {
    outfitRes = 0,        
    hatRes    = 0,        
    maskRes   = 0,
    glassRes  = 0,
    tshirtRes = 0,        
    pantsRes  = 0,        
    shoesRes  = 0,        
    bagRes    = 0,        
    helmetRes = 0,        
    weaponSkins = {},
}

-- Báº£ng ID cÃ¡c siÃªu xe (ThÃªm tá»± do náº¿u cÃ³ ID má»›i)
local ITEMS = {
    -- ==============================================================================
    -- Há»† THá»NG Gá»C Cá»¦A V7.5 (KHÃ”NG ÄÆ¯á»¢C XÃ“A DÃ’NG NÃ€Y)
    -- ==============================================================================
    703029, 703044, 703046, 703048, 1400010, 1400062, 1400070, 1400083, 1400100, 1400106, 1400112, 1400117, 1400134, 1407917, 1400170, 
    1400172, 1400173, 1400174, 1400175, 1400177, 1400179, 1400180, 1400228, 1400231, 1400233, 1400236, 1400237, 1400238, 1400242, 1400244,
    202408070, 202408071, 202408072, 202408073, 202408074, 202408075,
    1407905, 1407906, 1407907, 1407908, 1407909, 1407910, 1407911, 1407912, 1407913, 1407914, 1407915, 1407916, 1410585,
    -- ==============================================================================
    -- 1. SÃšNG NÃ‚NG Cáº¤P (CHá»ˆ Láº¤Y Cáº¤P Äá»˜ CAO NHáº¤T Cá»¦A Tá»ªNG KHáº¨U SÃšNG)
    -- ==============================================================================
    -- [ M416 ]
    1101004163, -- HoÃ ng Gia Lá»™ng Láº«y - M416 (Cáº¥p 8)
    1101004201, -- Báº¡ch LÃ¢n Nháº£ Ngá»c - M416 (Cáº¥p 8)
    1101004209, -- Thá»§y Triá»u Dáº­y SÃ³ng - M416 (Cáº¥p 8)
    1101004218, -- Ma áº¢nh - M416 (Cáº¥p 8)
    1101004226, -- Phong áº¤n U Minh - M416 (Cáº¥p 8)
    1101004236, -- Lam SÆ° Äoáº¡t Má»‡nh - M416 (Cáº¥p 8)
    1101004246, -- Há»a LiÃªn - M416 (Cáº¥p 8)
    1101004046, -- BÄƒng giÃ¡ - M416 (Cáº¥p 7)
    1101004062, -- ChÃº há» - M416 (Cáº¥p 7)
    1101004078, -- Káº» lang thang - M416 (Cáº¥p 7)
    1101004086, -- BÃ² SÃ¡t Gáº§m Gá»« - M416 (Cáº¥p 7)
    1101004098, -- Tiáº¿ng Gá»i Hoang DÃ£ - M416 (Cáº¥p 7)
    1101004138, -- LÃµi CÃ´ng Nghá»‡ - M416 (Cáº¥p 7)

    -- [ AKM ]
    1101001174, -- Báº¡o ChÃºa Bá»™ Láº¡c - AKM (Cáº¥p 8)
    1101001213, -- ÄÃ´ Äá»‘c Háº£i Long Tinh - AKM (Cáº¥p 8)
    1101001242, -- NgÃ y PhÃ¡n Quyáº¿t - AKM (Cáº¥p 8)
    1101001265, -- Thá»i Quang Kháº£ Biáº¿n - AKM (Cáº¥p 8)
    1101001276, -- Huyá»…n Tháº§n - AKM (Cáº¥p 8)
    1101001063, -- Huyá»n thoáº¡i Seven Seas - AKM (Cáº¥p 7)
    1101001089, -- BÄƒng giÃ¡ - AKM (Cáº¥p 7)
    1101001103, -- HÃ³a Tháº¡ch - AKM (Cáº¥p 7)
    1101001116, -- BÃ­ NgÃ´ Kinh Dá»‹ - AKM (Cáº¥p 7)
    1101001128, -- Long VÆ°Æ¡ng - AKM (Cáº¥p 7)
    1101001143, -- Háº£i Táº·c VÃ ng - AKM (Cáº¥p 7)
    1101001154, -- NgÆ°á»i Giáº£i MÃ£ - AKM (Cáº¥p 7)
    1101001231, -- Thá» Tinh Nghá»‹ch - AKM (Cáº¥p 7)
    1101001249, -- ThÃ¡nh Quang (TrÄƒng Tháº§n) - AKM (Cáº¥p 7)
    1101001256, -- ThÃ¡nh Quang (LÃ´ng VÅ© HoÃ ng Kim) - AKM (Cáº¥p 7)
    1101001042, -- Ãnh kim - AKM (Cáº¥p 6)
    1101001068, -- Há»• gáº§m gá»« - AKM (Cáº¥p 5)

    -- [ SCAR-L ]
    1101003146, -- Gai TÃ  Ãc - SCAR-L (Cáº¥p 8)
    1101003167, -- Ma VÆ°Æ¡ng Huyáº¿t Há»“n - SCAR-L (Cáº¥p 8)
    1101003227, -- ThiÃªn Äiá»ƒu - SCAR-L (Cáº¥p 8)
    1101003057, -- SÃºng nÆ°á»›c - SCAR-L (Cáº¥p 7)
    1101003070, -- BÃ­ NgÃ´ Ma QuÃ¡i - SCAR-L (Cáº¥p 7)
    1101003080, -- Chiáº¿n Dá»‹ch VÃ¬ NgÃ y Mai - SCAR-L (Cáº¥p 7)
    1101003099, -- Drop Da Bass - SCAR-L (Cáº¥p 7)
    1101003119, -- Tinh thá»ƒ Hextech SCAR-L (Cáº¥p 7)
    1101003188, -- CÃ¡i Ã”m Cá»§a ChÃº Há» - SCAR-L (Cáº¥p 7)
    1101003195, -- ThÃ¡nh Ná»¯ Huyá»n áº¢o - SCAR-L (Cáº¥p 7)
    1101003208, -- VÆ°Æ¡ng Quá»‘c Huyá»n áº¢o - SCAR-L (Cáº¥p 7)
    1101003219, -- KÃ­nh Pha LÃª - SCAR-L (Cáº¥p 7)
    1101003173, -- Ãnh SÃ¡ng HoÃ ng Tá»™c - SCAR-L (Cáº¥p 5)
    1101003212, -- MÃ¨o Ä‚n Váº·t - SCAR-L (Cáº¥p 3)

    -- [ M762 ]
    1101008081, -- Vá»‹ KhÃ¡ch Ná»•i Loáº¡n - M762 (Cáº¥p 8)
    1101008104, -- LÃµi Sao Huyá»n áº¢o - M762 (Cáº¥p 8)
    1101008146, -- Báº¡ch Cá»‘t U Minh - M762 (Cáº¥p 8)
    1101008154, -- Khung XÆ°Æ¡ng - M762 (Cáº¥p 8)
    1101008051, -- Báº£n Nháº¡c TÃ¬nh YÃªu - M762 (Cáº¥p 7)
    1101008061, -- PhÃ¡t Báº¯n ChÃ­ Máº¡ng - M762 (Cáº¥p 7)
    1101008070, -- GACKT MOONSAGA - M762 (Cáº¥p 7)
    1101008116, -- Biá»ƒu TÆ°á»£ng BÃ³ng ÄÃ¡ Messi - M762 (Cáº¥p 7)
    1101008126, -- Huyáº¿t Rá»“ng - M762 (Cáº¥p 7)
    1101008136, -- TiÃªn Linh LÆ°u Ly - M762 (Cáº¥p 7)
    1101008163, -- Cá»• Váº­t Háº¯c Ãm - M762 (Cáº¥p 7)
    1101008026, -- Pony BÃ© Nhá» - M762 (Cáº¥p 5)
    1101008036, -- ÄÃ³a Sen Pháº«n Ná»™ - M762 (Cáº¥p 5)

    -- [ AUG ]
    1101006062, -- Tinh Linh BÄƒng GiÃ¡ - AUG (Cáº¥p 8)
    1101006085, -- Hoa Há»“ng Ma Má»‹ - AUG (Cáº¥p 8)
    1101006075, -- Há»a Ca - AUG (Cáº¥p 7)
    1101006033, -- GÃ¡nh Xiáº¿c Rong - AUG (Cáº¥p 5)
    1101006044, -- Evangelion Angel Thá»© 4 - AUG (Cáº¥p 5)
    1101006067, -- Ãc Má»™ng Biá»ƒn SÃ¢u - AUG (Cáº¥p 5)

    -- [ GROZA ]
    1101005038, -- Ryomen Sukuna - Groza (Cáº¥p 7)
    1101005052, -- Lá»­a U Minh - Groza (Cáº¥p 7)
    1101005098, -- Godzilla Bá»‘c Lá»­a - Groza (Cáº¥p 7)
    1101005019, -- Ká»µ Binh Rá»«ng SÃ¢u - GROZA (Cáº¥p 5)
    1101005025, -- ÄÃªm Huyá»n áº¢o - GROZA (Cáº¥p 5)
    1101005043, -- Tráº­n Chiáº¿n Sáº¯c MÃ u - Groza (Cáº¥p 5)
    1101005082, -- Lá»“ng ÄÃ¨n BÃ­ NgÃ´ - Groza (Cáº¥p 5)
    1101005090, -- Di TÃ­ch ThÆ°á»£ng Cá»• - Groza (Cáº¥p 5)
    1101005105, -- Singam Roar - Groza (Cáº¥p 5)

    -- [ QBZ & Mk47 & G36C & Honey Badger & FAMAS & ASM Abakan & ACE32 ]
    1101007046, -- CÃ´ng ChÃºa Háº¯c Ãm - QBZ (Cáº¥p 7)
    1101007062, -- Hoa Kiáº¿m ChÃ­ Máº¡ng - QBZ (Cáº¥p 7)
    1101007071, -- ThiÃªn Má»‡nh - QBZ (Cáº¥p 7)
    1101007025, -- Ãnh DÆ°Æ¡ng - QBZ (Cáº¥p 5)
    1101007036, -- CÃ n QuÃ©t - QBZ (Cáº¥p 5)
    1101007079, -- BÄƒng Quyá»n - QBZ (Cáº¥p 5)
    1101009019, -- Thá» Tinh QuÃ¡i - Mk47 (Cáº¥p 3)
    1101010029, -- Xung Nhá»‹p SÃ¢n Cá» - G36C (Cáº¥p 5)
    1101012033, -- Cá»• Má»™c Chiáº¿n KhÃ­ - Honey Badger (Cáº¥p 7)
    1101012009, -- Sáº¯c MÃ u Huyá»n áº¢o - Honey Badger (Cáº¥p 5)
    1101012018, -- Thanh Ã‚m Du DÆ°Æ¡ng - Honey Badger (Cáº¥p 5)
    1101012024, -- Honey Badger Mikey (Cáº¥p 5)
    1101100012, -- Äáº¿ VÆ°Æ¡ng Tháº§n Vá»±c - FAMAS (Cáº¥p 8)
    1101100018, -- áº¢o áº¢nh Äiá»‡n Tá»­ - FAMAS (Cáº¥p 5)
    1101101007, -- Uy VÅ© Háº¯c Äiá»ƒu - ASM Abakan (Cáº¥p 7)
    1101102025, -- Thá»§y QuÃ¡i - ACE32 (Cáº¥p 8)
    1101102041, -- TiÃªn Tri Äiá»m LÃ nh - ACE32 (Cáº¥p 8)
    1101102049, -- ThÃ¬ Tháº§m CÃ¡nh BÆ°á»›m - ACE32 (Cáº¥p 8)
    1101102007, -- Kamehameha - ACE32 (Cáº¥p 7)
    1101102017, -- Ngá»c BÃ­ch - ACE32 (Cáº¥p 7)
    1101102032, -- CÃ¡o Tinh Nghá»‹ch - ACE32 (Cáº¥p 5)

    -- [ SMG (UZI, UMP45, Vector, Thompson, Bizon, MP5K, P90) ]
    1102001120, -- BÄƒng GiÃ¡ - UZI (Cáº¥p 8)
    1102001130, -- Xiá»ng XÃ­ch Há»a Ngá»¥c - UZI (Cáº¥p 7)
    1102001024, -- Savagery - UZI (Cáº¥p 6)
    1102001036, -- Váº­t Tá»• Tháº§n BÃ­ - UZI (Cáº¥p 5)
    1102001058, -- Khoáº£nh Kháº¯c Báº¥t Ngá» - UZI (Cáº¥p 5)
    1102001069, -- UZI Quang HÃ³a (Cáº¥p 5)
    1102001089, -- Ma PhÃ¡p - UZI (Cáº¥p 5)
    1102001103, -- Cam TÆ°Æ¡i MÃ¡t - UZI (Cáº¥p 5)
    1102001102, -- MÃ¡y Ã‰p TrÃ¡i CÃ¢y - UZI (Cáº¥p 5)
    1102002438, -- Song Tá»­ Chiáº¿n - UMP45 (Cáº¥p 8)
    1102002446, -- Song Tá»­ Äá» Tháº«m - UMP45 (Cáº¥p 8)
    1102002043, -- Há»a long - UMP45 (Cáº¥p 7)
    1102002061, -- áº¢o Má»™ng Cháº¿t ChÃ³c - UMP45 (Cáº¥p 7)
    1102002136, -- BÄƒng GiÃ¡ - UMP45 (Cáº¥p 7)
    1102002424, -- Tháº§n KhÃ­ Anukhra - UMP45 (Cáº¥p 7)
    1102002053, -- EMP - UMP45 (Cáº¥p 5)
    1102002070, -- Äá»“ Tá»ƒ Báº¡ch Kim - UMP45 (Cáº¥p 5)
    1102002090, -- Cuá»™c Chiáº¿n 8-Bit - UMP45 (Cáº¥p 5)
    1102002112, -- NgÃ y GiÃ¡ng Sinh - UMP45 (Cáº¥p 5)
    1102002117, -- Ong Báº¯p CÃ y - UMP45 (Cáº¥p 5)
    1102002129, -- Con SÃ³ng Lá»… Há»™i - UMP45 (Cáº¥p 5)
    1102002143, -- PUBGM X NewJeans - UMP45 (Cáº¥p 5)
    1102003080, -- CÃ¡nh Rá»“ng - Vector (Cáº¥p 7)
    1102003100, -- Tuyáº¿t Diá»‡t áº¢nh - Vector (Cáº¥p 7)
    1102003020, -- Nanh DÆ¡i Huyáº¿t Tá»™c - Vector (Cáº¥p 5)
    1102003031, -- Hoa Há»“ng ÄÃªm - Vector (Cáº¥p 5)
    1102003039, -- Gáº¥u Tinh Nghá»‹ch - Vector (Cáº¥p 5)
    1102003052, -- BÃ¡ TÆ°á»›c VÃ ng - Vector (Cáº¥p 5)
    1102003065, -- LÆ°á»¡i Liá»m VÃ ng - Vector (Cáº¥p 5)
    1102003072, -- SÃ¡t Thá»§ Tá»‘i ThÆ°á»£ng - Vector (Cáº¥p 5)
    1102003090, -- KMF Lancelot - Vector (Cáº¥p 5)
    1102004018, -- Káº¹o ngá»t - Thompson (Cáº¥p 5)
    1102004034, -- MÃ¡y Cháº¡y HÆ¡i NÆ°á»›c - Thompson (Cáº¥p 5)
    1102004048, -- Tá»­ Äáº±ng - Thompson SMG (Cáº¥p 3)
    1102005064, -- Quang áº¢o Äiá»‡n Tá»­ - PP-19 Bizon (Cáº¥p 7)
    1102005007, -- Táº¯c KÃ¨ - PP-19 Bizon (Cáº¥p 5)
    1102005020, -- Skullcrusher - PP-19 Bizon (Cáº¥p 5)
    1102005041, -- Tháº§n Binh VÃµ Thuáº­t - PP-19 Bizon (Cáº¥p 5)
    1102005052, -- DP Quantum Quake - Bizon (Cáº¥p 5)
    1102005057, -- LÃ¢n SÆ° - PP-19 Bizon (Cáº¥p 5)
    1102005072, -- Huyáº¿t Táº¿ - PP-19 Bizon (Cáº¥p 5)
    1102005078, -- SAKAMOTO SHOP - PP-19 (Cáº¥p 5)
    1102007019, -- PUBGM X QWER - MP5K (Cáº¥p 5)
    1102007022, -- Pixel Cá»• Äiá»ƒn - MP5K (Cáº¥p 3)
    1102105012, -- MiÃªu Ná»¯ CÃ´ng Nghá»‡ - P90 (Cáº¥p 7)
    1102105028, -- ThiÃªn MÃ£ - P90 (Cáº¥p 7)
    1102105018, -- MÃ³ng Vuá»‘t HoÃ ng Kim - P90 (Cáº¥p 5)

    -- [ SNIPER & MARKSMAN RIFLE (Kar98, M24, AWM, SKS, SLR, Mk14, etc.) ]
    1103001202, -- BÄƒng YÃªu - Kar98K (Cáº¥p 8)
    1103001060, -- Dáº¥u nanh Pháº«n ná»™ - Kar98K (Cáº¥p 7)
    1103001079, -- Kukulkan Cuá»“ng Ná»™ - Kar98K (Cáº¥p 7)
    1103001101, -- Ãnh TrÄƒng - Kar98K (Cáº¥p 7)
    1103001129, -- Gackt Moon - Kar98K (Cáº¥p 7)
    1103001146, -- CÃ¡ Máº­p Titan - Kar98K (Cáº¥p 7)
    1103001154, -- Máº­t MÃ£ Cháº¿t ChÃ³c - Kar98K (Cáº¥p 7)
    1103001179, -- Äiá»‡n Cá»±c TÃ­m - Kar98K (Cáº¥p 7)
    1103001191, -- Há»“ng Há»a Diá»‡m - Kar98K (Cáº¥p 7)
    1103001085, -- ÄÃªm Nháº¡c Rock - Kar98K (Cáº¥p 5)
    1103001160, -- Thá»£ SÄƒn Tinh VÃ¢n - Kar98K (Cáº¥p 5)
    1103001183, -- Nhá»‹p Äiá»‡u MÃ¨o Con - Kar98K (Cáº¥p 3)
    1103002030, -- Quyá»n TrÆ°á»£ng Pharaoh - M24 (Cáº¥p 7)
    1103002059, -- Tuáº§n HoÃ n Sá»± Sá»‘ng - M24 (Cáº¥p 7)
    1103002087, -- Nhá»‹p Äiá»‡u HoÃ n Má»¹ - M24 (Cáº¥p 7)
    1103002106, -- Minh Nguyá»‡t Cáº¥m Vá»±c - M24 (Cáº¥p 7)
    1103002156, -- BÃ¬nh Minh BÃ³ng Tá»‘i - M24 (Cáº¥p 7)
    1103002049, -- Há»“ Äiá»‡p Phu NhÃ¢n - M24 (Cáº¥p 5)
    1103002047, -- Giai Äiá»‡u ChÃ­ Máº¡ng - M24 (Cáº¥p 5)
    1103002094, -- CÃ´ng Nghá»‡ Cao - M24 (Cáº¥p 5)
    1103003022, -- Neon - AWM (Cáº¥p 7)
    1103003030, -- Chá»‰ Huy Chiáº¿n TrÆ°á»ng - AWM (Cáº¥p 7)
    1103003042, -- Godzilla - AWM (Cáº¥p 7)
    1103003051, -- Äáº¡i Long Cáº§u Vá»“ng - AWM (Cáº¥p 7)
    1103003062, -- Há»a PhÆ°á»£ng HoÃ ng - AWM (Cáº¥p 7)
    1103003079, -- Huyáº¿t Háº£i ThiÃªn Long - AWM (Cáº¥p 7)
    1103003087, -- Thanh Hoa XÃ  - AWM (Cáº¥p 7)
    1103003099, -- Háº¯c KhÃ­ - AWM (Cáº¥p 7)
    1103003092, -- Há»“ng Hoang - AWM (Cáº¥p 5)
    1103004037, -- QuÃ½ BÃ  Äá» - SKS (Cáº¥p 7)
    1103004046, -- Rá»«ng ThÃ©p - SKS (Cáº¥p 5)
    1103004058, -- NÄƒng LÆ°á»£ng BÄƒng Tuyáº¿t - SKS (Cáº¥p 5)
    1103004080, -- Khiáº¿t Hoa Ná»Ÿ Rá»™ - SKS (Cáº¥p 5)
    1103004087, -- Giai Äiá»‡u Tá»­ Tháº§n - SKS (Cáº¥p 5)
    1103005024, -- Quáº¡ Äen - VSS (Cáº¥p 5)
    1103005048, -- Trinh SÃ¡t Tuyáº¿t Tráº¯ng - VSS (Cáº¥p 3)
    1103009022, -- MÃ¹a Hoa ÄÃ o - SLR (Cáº¥p 5)
    1103009037, -- Ngá»n Lá»­a Ma Thuáº­t - SLR (Cáº¥p 5)
    1103009051, -- Ma Má»™ng - SLR (Cáº¥p 5)
    1103009042, -- Thanh Ã‚m Háº£i Huyá»n - SLR (Cáº¥p 3)
    1103006030, -- SÃ´ng BÄƒng - Mini14 (Cáº¥p 7)
    1103006046, -- NÃ©t Äáº¹p Thuáº§n Khiáº¿t - Mini14 (Cáº¥p 5)
    1103006058, -- MÃ¨o ChiÃªu TÃ i - Mini14 (Cáº¥p 5)
    1103006063, -- Tay Äua Gan Dáº¡ - Mini14 (Cáº¥p 5)
    1103006075, -- Nhá»‹p Chiáº¿n Nhanh - Mini14 (Cáº¥p 5)
    1103007028, -- VÆ°Æ¡ng Quá»‘c Rá»“ng - Mk14 (Cáº¥p 8)
    1103007020, -- Sá»©c Máº¡nh NgÃ¢n HÃ  - Mk14 (Cáº¥p 5)
    1103007038, -- Rá»“ng Sá»¯a Má»m Máº¡i - Mk14 (Cáº¥p 5)
    1103007043, -- Há»™p QuÃ  May Máº¯n - Mk14 (Cáº¥p 5)
    1103012010, -- Khá»§ng Long Ephialtes - AMR (Cáº¥p 8)
    1103012019, -- Há»a Tháº§n - AMR (Cáº¥p 7)
    1103012031, -- VÃ´ Ã‚m Ly Biá»‡t - AMR (Cáº¥p 7)
    1103012039, -- Äáº¡i Chiáº¿n Huyá»…n Sáº¯c - AMR (Cáº¥p 7)
    1103012024, -- Tinh Thá»ƒ Onyx - AMR (Cáº¥p 5)
    1103100007, -- ThÃº SÄƒn Má»“i - Mk12 (Cáº¥p 5)
    1103102007, -- Chiáº¿n Háº¡m VÅ© Trá»¥ - DSR (Cáº¥p 7)
    1103103007, -- Vinh Quang Chiáº¿n Binh - M1 Garand (Cáº¥p 7)

    -- [ SHOTGUN & MACHINE GUN (S12K, DBS, M249, DP-28, MG3...) ]
    1104001035, -- Äá»™c Há»“n - S686 (Cáº¥p 5)
    1104002022, -- Cháº¡ng Váº¡ng - S1897 (Cáº¥p 5)
    1104002049, -- Xung KÃ­ch Sáº¯c MÃ u - S1897 (Cáº¥p 3)
    1104003026, -- S12K GACKT (Cáº¥p 7)
    1104003037, -- KÃ­ch Hoáº¡t NguyÃªn Tá»­ - S12K (Cáº¥p 5)
    1104003046, -- TrÃ¡i Tim Cyber - S12K (Cáº¥p 5)
    1104004035, -- Chiáº¿n GiÃ¡p QuÃ¡i ThÃº - DBS (Cáº¥p 5)
    1104004041, -- Sandsinger - DBS (Cáº¥p 5)
    1104004051, -- Okarun - DBS (Cáº¥p 5)
    1104004024, -- BÃ¡o Sáº¯c MÃ u - DBS (Cáº¥p 3)
    1104102004, -- TÃ n TÃ­ch HoÃ ng Kim - NS2000 (Cáº¥p 3)
    1105001034, -- PhÃ¡o GiÃ¡ng Sinh - M249 (Cáº¥p 7)
    1105001048, -- Ná»¯ Äáº¿ Ãnh SÃ¡ng - M249 (Cáº¥p 7)
    1105001069, -- VÆ°Æ¡ng Quyá»n Háº¯c Ãm - M249 (Cáº¥p 7)
    1105001020, -- Ná»¯ HoÃ ng BÄƒng GiÃ¡ M249 V (Cáº¥p 5)
    1105001054, -- Stargaze Fury - M249 (Cáº¥p 5)
    1105001062, -- Graffiti ÄÆ°á»ng Phá»‘ - M249 (Cáº¥p 5)
    1105001075, -- CÃ¡ Máº­p ThÃ©p - M249 (Cáº¥p 4)
    1105002091, -- Huyáº¿t Há»a - DP28 (Cáº¥p 8)
    1105002018, -- SÃ¡t Thá»§ BÃ­ áº¨n - DP-28 (Cáº¥p 5)
    1105002035, -- Ngá»c Long - DP-28 (Cáº¥p 5)
    1105002058, -- Chiáº¿n Binh HÃ ng Háº£i - DP28 (Cáº¥p 5)
    1105002063, -- Rá»“ng Tháº§n Shenron - DP-28 (Cáº¥p 5)
    1105002071, -- Chiáº¿n SÄ© Tháº§n GiÃ¡p - DP-28 (Cáº¥p 5)
    1105002076, -- MÃ¨o Sá»‘ HÃ³a - DP-28 (Cáº¥p 5)
    1105002083, -- DP-28 Frieren's Staff (Cáº¥p 5)
    1105002096, -- Há»“ Tá»™c - DP-28 (Cáº¥p 3)
    1105010019, -- Chiáº¿n Tháº§n Báº§u Trá»i - MG3 (Cáº¥p 7)
    1105010008, -- ThiÃªn Khung - MG3 (Cáº¥p 5)
    1105010026, -- Mina Ashiro - MG3 (Cáº¥p 5)

    -- [ Cáº¬N CHIáº¾N & VÅ¨ KHÃ KHÃC (Skorpion, Ná», Cháº£o, Dao...) ]
    1106008013, -- Máº­t MÃ£ VÃ ng - Skorpion (Cáº¥p 5)
    1106008022, -- BÃ­ áº¨n Tinh TÃº - Skorpion (Cáº¥p 3)
    1106011008, -- Rá»“ng Ráº¯n LÃªn MÃ¢y - MP7 KÃ©p (Cáº¥p 5)
    1106011003, -- Thá»£ SÄƒn Káº¹o - MP7 (Cáº¥p 3)
    1107001018, -- ChÃºa Há» Thá»‹nh Ná»™ - Ná» (Cáº¥p 3)
    1107098003, -- Rung Cháº¥n CÃ´ng Nghá»‡ - MGL (Cáº¥p 3)
    1108001057, -- SÄƒn Rá»“ng - Dao (Cáº¥p 3)
    1108001064, -- Äoáº£n Kiáº¿m Yor SPYÃ—FAMILY (Cáº¥p 3)
    1108001069, -- Ki Sword (Cáº¥p 3)
    1108001081, -- RÃ¬u Godzilla Bá»‘c Lá»­a (Cáº¥p 3)
    1108001085, -- Kiáº¿m Trung ÄoÃ n Trinh SÃ¡t Cáº¥p 3
    1108001098, -- ThÆ°Æ¡ng Äáº£o NgÆ°á»£c ThiÃªn ÄÆ°á»ng - Dao (Cáº¥p 3)
    1108001104, -- XÃ­ch Tay - Dao (Cáº¥p 3)
    1108002059, -- Äinh Ba Thá»§y Triá»u Thá»‹nh Ná»™ (Cáº¥p 5)
    1108004125, -- HÅ© Máº­t Ong - Cháº£o (Cáº¥p 5)
    1108004160, -- CÃ¡ Sáº¥u - Cháº£o (Cáº¥p 5)
    1108004145, -- ÄÃªm Nháº¡c Rock - Cháº£o (Cáº¥p 5)
    1108004283, -- Vinh Quang - Cháº£o (Cáº¥p 6)
    1108004337, -- Cháº£o Äiá»‡n NguyÃªn Tá»­ (Cáº¥p 6)
    1108004356, -- GÃ  RÃ¡n - Cháº£o (Cáº¥p 3)
    1108004365, -- Yokai Huyá»n BÃ­ - Cháº£o (Cáº¥p 3)
    1108004377, -- Cháº£o CÃ¡nh Cá»¥t Vui Váº» (Cáº¥p 5)
    1108004416, -- Quáº¡t VÅ© Äiá»‡u NÃ³ng Bá»ng - Cháº£o (Cáº¥p 3)
    1108005050, -- Rá»“ng BÄƒng GiÃ¡ - Dao GÄƒm (Cáº¥p 3)

    -- ==============================================================================
    -- 2. FULL SIÃŠU XE (VIP VEHICLES)
    -- ==============================================================================
    -- [ McLaren ]
    1961007, -- McLaren 570S (Äen)
    1961010, -- McLaren 570S (Tráº¯ng)
    1961012, -- McLaren 570S (Há»“ng)
    1961013, -- McLaren 570S (VÃ ng Tráº¯ng)
    1961014, -- McLaren 570S (VÃ ng Äen)
    1961015, -- McLaren 570S (Ãnh Kim)
    1961147, -- McLaren P1 (Trá»i Sao)
    1961148, -- McLaren P1 (Há»“ng Rá»±c Rá»¡)
    1961149, -- McLaren P1 (VÃ ng NÃºi Lá»­a)
    1907054, -- Xe Äua Äá»™i McLaren F1 (Äiá»‡n Tá»­)
    1907058, -- Xe Äua Äá»™i McLaren F1
    1907059, -- Xe Äua Äá»™i McLaren F1 (Chiáº¿n Tháº¯ng)

    -- [ Koenigsegg ]
    1961016, -- Koenigsegg Jesko (XÃ¡m Báº¡c)
    1961017, -- Koenigsegg Jesko (Cáº§u Vá»“ng)
    1961018, -- Koenigsegg Jesko (BÃ¬nh Minh)
    1961029, -- Koenigsegg One:1 Gilt
    1961030, -- Koenigsegg One:1 Cyber Nebula
    1961031, -- Koenigsegg One:1 Jade
    1961032, -- Koenigsegg One:1 Phoenix
    1903074, -- Koenigsegg Gemera (XÃ¡m Báº¡c)
    1903075, -- Koenigsegg Gemera (Cáº§u Vá»“ng)
    1903076, -- Koenigsegg Gemera (BÃ¬nh Minh)

    -- [ Lamborghini ]
    1961020, -- Lamborghini Aventador SVJ Verde Alceo
    1961021, -- Lamborghini Centenario Galassia
    1961024, -- Lamborghini Aventador SVJ Blue
    1961025, -- Lamborghini Centenario Carbon Fiber
    1961144, -- Lamborghini Invencible Rosso Efesto
    1961145, -- Lamborghini Invencible Nebula Drift
    1903079, -- Lamborghini Estoque Oro
    1903080, -- Lamborghini Estoque Metal Grey
    1908066, -- Lamborghini Urus Pink
    1908067, -- Lamborghini Urus Giallo Inti

    -- [ Bugatti ]
    1961041, -- Bugatti Veyron 16.4 (Sáº¯c MÃ u)
    1961042, -- Bugatti Veyron 16.4 (VÃ ng)
    1961043, -- Bugatti Veyron 16.4
    1961044, -- Bugatti La Voiture Noire
    1961045, -- Bugatti La Voiture Noire (Há»£p Kim)
    1961046, -- Bugatti La Voiture Noire (Chiáº¿n Binh)
    1961047, -- Bugatti La Voiture Noire (Tinh VÃ¢n)
    1961151, -- Bugatti Bolide (LÆ°á»¡i GÆ°Æ¡ng)
    1961152, -- Bugatti Bolide (Bá»‰ Ngáº¡n)
    1961153, -- Bugatti Bolide (áº¢o áº¢nh Há»“ BÄƒng)

    -- [ Aston Martin ]
    1961048, -- Aston Martin Valkyrie (Luminous Diamond)
    1961049, -- Aston Martin Valkyrie (Racing Green)
    1915005, -- Aston Martin DBS Volante (Deep Cosmos)
    1915006, -- Aston Martin DBS Volante (Celestial Pink)
    1915007, -- Aston Martin DBS Volante (Black-Bronze Satin)
    1908084, -- Aston Martin DBX707 (Neon Purple)
    1908085, -- Aston Martin DBX707 (Quasar Blue)

    -- [ Pagani ]
    1961051, -- Pagani Zonda R (Tricolore Carbon)
    1961052, -- Pagani Zonda R (Bianco Benny)
    1961053, -- Pagani Zonda R (Melodic Midnight)
    1961054, -- Pagani Imola (Grigio Montecarlo)
    1961055, -- Pagani Imola (Crystal Clear Carbon)
    1961056, -- Pagani Imola (Nebula Dream)
    1961057, -- Pagani Imola (Arctic Aegis)

    -- [ Bentley ]
    1961137, -- Bentley Batur (Kim CÆ°Æ¡ng Láº¥p LÃ¡nh)
    1961138, -- Bentley Batur (Táº­n CÃ¹ng Thá»i Gian)
    1961139, -- Bentley Betayga Azure (VÆ°Æ¡ng Quá»‘c Huyá»n áº¢o)
    1903200, -- Bentley Flying Spur Mulliner (Tinh VÃ¢n Xanh)
    1903201, -- Bentley Flying Spur Mulliner (DÃ²ng Cháº£y Vá»‹nh Háº¹p)
    1908094, -- Bentley Betayga Azure (MÆ°a Hoa)
    1908095, -- Bentley Betayga Azure (ÄÃªm YÃªn TÄ©nh)
    1915008, -- Bentley Continental GTC Mulliner (Má»™ng Cáº£nh Lung Linh)
    1915009, -- Bentley Continental GTC Mulliner (QuÃ½ Tá»™c Ão TÃ­m)

    -- [ Maserati ]
    1961038, -- Maserati MC20 Bianco Audace
    1961039, -- Maserati MC20 Rosso Vincente
    1961040, -- Maserati MC20 Sogni
    1908075, -- Maserati Levante Blu Emozione
    1908076, -- Maserati Luce Arancione
    1908077, -- Maserati Levante Neon Urbano
    1908078, -- Maserati Levante Firmamento

    -- [ Dodge / SRT ]
    1961036, -- Dodge Challenger SRT Hellcat - Blaze
    1961037, -- Dodge Challenger SRT Hellcat - Lime
    1961050, -- Dodge Challenger SRT Hellcat Jailbreak - Hellfire
    1961136, -- Dodge Challenger SRT Hellcat - Blaze
    1961150, -- Dodge Challenger SRT Hellcat Jailbreak - Hellfire
    1903088, -- Dodge Charger SRT Hellcat - Fuchsia
    1903089, -- Dodge Charger SRT Hellcat - Tuscan Torque
    1903090, -- Dodge Charger SRT Hellcat Jailbreak - Violet Venom
    1903189, -- Dodge Charger SRT Hellcat - Tuscan Torque
    1903190, -- Dodge Charger SRT Hellcat Jailbreak - Violet Venom
    1908086, -- Dodge Hornet - Scarlet Sting
    1908088, -- Dodge Hornet GLH Concept - Redline
    1908089, -- Dodge Hornet - Sunburst
    1908188, -- Dodge Hornet GLH Concept - Redline
    1908189, -- Dodge Hornet - Sunburst

    -- [ Porsche ]
    1961062, -- Porsche 918 Spyder (DÃ²ng NÆ°á»›c)
    1961063, -- Porsche 918 Spyder (964 Báº¡c Ãnh Kim)
    1961064, -- Porsche 918 Spyder (Há»“ng)
    1903218, -- Porsche Panamera Turbo S (Lam Ngá»c)
    1903219, -- Porsche Panamera Turbo S (Xanh Viper)
    1908108, -- Porsche Cayenne Turbo GT (ÄÆ°á»ng Äua Rá»±c Lá»­a)
    1908109, -- Porsche Cayenne Turbo GT (Cam SAMEER Nham)
    1915021, -- Porsche 911 Carrera 4 GTS Cabriolet (NgÃ n Sao)
    1915022, -- Porsche 911 Carrera 4 GTS Cabriolet (Äá» Ruby)

    -- [ Shelby / Ford ]
    1961058, -- Shelby 427 Cobra (Xanh & Tráº¯ng)
    1961059, -- Shelby 427 Cobra (Graffiti Phá»¥c Cá»•)
    1903210, -- Shelby GT500 (Äen & Äá»)
    1903211, -- Shelby GT500 (NgÆ°á»i NgoÃ i HÃ nh Tinh Cyber)
    1961068, -- Ford Mustang GTD (Huyá»n Thoáº¡i Xanh TÆ°Æ¡i)
    1961069, -- Ford Mustang GTD (Tinh Tháº§n NÆ°á»›c Má»¹)

    -- [ Lotus ]
    1961060, -- Lotus Emira (Rá»«ng SÃ¢u Tháº«m)
    1961061, -- Lotus Emira (LÆ°á»›t Sáº¯c Xanh)

    -- [ Apollo ]
    1961065, -- Apollo EVO (VÃ ng Rá»±c Rá»¡)
    1961066, -- Apollo EVO (HoÃ ng HÃ´n)
    1961067, -- Apollo EVO (BÄƒng GiÃ¡)
    1903220, -- Apollo Intensa Emozione (Há»a Ngá»¥c NÃ³ng Cháº£y)
    1903221, -- Apollo Intensa Emozione (BÃ³ng Ma TÃ­m)
    1903222, -- Apollo Intensa Emozione (Quyáº¿t Äáº¥u)
    1903223, -- Apollo Intensa Emozione (BÃ£o Tá»‘)

    -- [ SSC Tuatara ]
    1961140, -- áº¢o áº¢nh Hoa Há»“ng SSC Tuatara
    1961141, -- Háº¡c Trá»i SSC Tuatara
    1961142, -- Äao BÃ¬nh Minh SSC Tuatara Striker
    1961143, -- MÃ n ÄÃªm Xanh SSC Tuatara Striker

    -- [ Tesla ]
    1903071, -- Tesla Roadster (Kim CÆ°Æ¡ng)
    1903072, -- Tesla Roadster (Pha LÃª TÃ­m)
    1903073, -- Tesla Roadster (Xanh Biá»ƒn Cáº£)

    -- [ Ducati / Motor VIP ]
    1901073, -- DUCATI Panigale V4S
    1901074, -- Ducati Panigale V4S Black Phantom
    1901075, -- Ducati Panigale V4S Crimson Storm
    1901076, -- Ducati Panigale V4S Swift Mirage

    -- ==============================================================================
    -- 3. FULL BAY DÃ™ (DÃ™ RÆ I, TÃ€U LÆ¯á»¢N, VÃN TRÆ¯á»¢T BAY)
    -- ==============================================================================
    -- [ DÃ™ (Parachutes) ]
    1401000, -- New Years Blessing Parachute
    1401001, -- Happy New Year Parachute
    1401002, -- DÃ¹ XÆ°Æ¡ng Äá»
    1401003, -- DÃ¹ tiá»ƒu quá»· tinh nghá»‹ch
    1401005, -- DÃ¹ nhá»‡n biáº¿n hÃ¬nh
    1401006, -- DÃ¹ MÃ¹a 5
    1401007, -- DÃ¹ sinh nháº­t
    1401008, -- DÃ¹ Sáº¿u VÃ ng
    1401009, -- DÃ¹ Quá»· Äá»
    1401010, -- DÃ¹ hoa bÃ¡ch tháº£o
    1401011, -- DÃ¹ anh Ä‘Ã o
    1401012, -- DÃ¹ Campus Tournament
    1401013, -- DÃ¹ Joker
    1401014, -- DÃ¹ chÃº há»
    1401015, -- Carabao Parachute
    1401016, -- Orange Life Parachute
    1401017, -- DÃ¹ Æ°ng vÃ ng
    1401018, -- DÃ¹ QuÃ¡n quÃ¢n MÃ¹a 8
    1401019, -- DÃ¹ Äá»™i trÆ°á»Ÿng Ryan
    1401020, -- DÃ¹ káº» lang thang
    1401021, -- DÃ¹ cung trÄƒng
    1401022, -- OPPO F11 PRO SURVIVOURS PARACHUTE
    1401023, -- DÃ¹ lÃ£nh chÃºa Sekigahara (VuÃ´ng)
    1401024, -- DÃ¹ Äá»“ng Minh Loot ThÃ­nh
    1401025, -- DÃ¹ ÄÃªm MÃª Hoáº·c (VuÃ´ng)
    1401026, -- DÃ¹ cÃ¡t tÆ°á»ng
    1401027, -- DÃ¹ PMCO
    1401028, -- DÃ¹ QuÃ¡n quÃ¢n MÃ¹a 7
    1401029, -- DÃ¹ sinh nháº­t rá»±c rá»¡
    1401031, -- DÃ¹ QuÃ¡n quÃ¢n MÃ¹a 6
    1401032, -- DÃ¹ Dao GÄƒm Äá»
    1401033, -- DÃ¹ WALKER
    1401034, -- DÃ¹ PhÃ¹ Thá»§y BÄƒng GiÃ¡
    1401035, -- DÃ¹ ngÆ°á»i thÃ¡ch Ä‘áº¥u
    1401036, -- DÃ¹ BAPE X PUBGM CAMO
    1401037, -- DÃ¹ Godzilla (Tráº¯ng)
    1401038, -- DÃ¹ Godzilla (VÃ ng)
    1401039, -- DÃ¹ Godzilla (Xanh)
    1401040, -- DÃ¹ Monarch
    1401041, -- DÃ¹ CÃ  Ri
    1401043, -- DÃ¹ NgÆ°á»i GÃ¡c ÄÃªm
    1401044, -- DÃ¹ hoa há»“ng Ä‘en
    1401045, -- DÃ¹ MÃ¨o May Máº¯n
    1401046, -- DÃ¹ ÄÃªm u Ã¡m
    1401047, -- DÃ¹ CÃ¡ Voi SÃ¡t Thá»§
    1401048, -- DÃ¹ thá»§y quÃ¡i Kraken
    1401050, -- DÃ¹ giai Ä‘iá»‡u Ã¢m nháº¡c
    1401051, -- DÃ¹ OPPO Reno
    1401052, -- DÃ¹ OPPO VOOC
    1401053, -- DÃ¹ ÄÃªm MÃª Hoáº·c
    1401054, -- DÃ¹ ChÃº Heo Tinh Nghá»‹ch
    1401055, -- DÃ¹ Red (DÃ i)
    1401056, -- PMJC Parachute
    1401057, -- PMSC Parachute
    1401059, -- DÃ¹ QuÃ¡n quÃ¢n Draconian
    1401060, -- DÃ¹ lÃ£nh chÃºa Sekigahara
    1401061, -- DÃ¹ Tiá»ƒu Quá»·
    1401062, -- DÃ¹ QuÃ¡n quÃ¢n MÃ¹a 9
    1401063, -- DÃ¹ QuÃ¡n quÃ¢n MÃ¹a 10
    1401064, -- DÃ¹ MÃ¨o Äen
    1401065, -- DÃ¹ GÃ  trá»‘ng
    1401066, -- DÃ¹ Má»t SÃ¡ch BÄƒng GiÃ¡
    1401067, -- DÃ¹ NgÆ°á»i Giáº£m Äau #11
    1401068, -- Super Power Parachute
    1401071, -- DÃ¹ LuÃ¢n Há»“i VÃ´ Táº­n
    1401072, -- DÃ¹ ChÃºa Tá»ƒ MuÃ´n LoÃ i
    1401074, -- DÃ¹ BÃ­ NgÃ´ Kinh Dá»‹
    1401085, -- DÃ¹ GÃ  ThÆ¡m Ngon
    1401086, -- DÃ¹ QuÃ¡n quÃ¢n MÃ¹a 11
    1401087, -- DÃ¹ Hoa Sen MÃ¡u
    1401088, -- DÃ¹ HÃ nh Tinh TrÃ´i Dáº¡t
    1401089, -- DÃ¹ QuÃ¡n QuÃ¢n MÃ¹a 12
    1401090, -- DÃ¹ Ninja SÃ¡t Thá»§
    1401091, -- DÃ¹ Neko Sakura
    1401092, -- DÃ¹ NgÆ°á»i TiÃªn Phong
    1401094, -- DÃ¹ Fantasy Girl
    1401095, -- DÃ¹ Tranh Váº½ Chiáº¿n TrÆ°á»ng
    1401096, -- DÃ¹ NgÆ°á»i PhÃ¡n Quyáº¿t
    1401097, -- DÃ¹ Africa Pride
    1401098, -- DÃ¹ Africa Unite
    1401100, -- DÃ¹ Cáº­u VÃ ng
    1401102, -- DÃ¹ Ä‘áº·c vá»¥ PMSC World Cup
    1401103, -- DÃ¹ QuÃ¢n ÄoÃ n Tháº¥t Láº¡c
    1401104, -- DÃ¹ Giáº£i Äáº¥u PMCO
    1401106, -- DÃ¹ Trung Ãšy VÅ© Trá»¥
    1401107, -- DÃ¹ Äáº§y Tá»› Huyáº¿t Nha
    1401108, -- DÃ¹ Street Dancer 3
    1401109, -- DÃ¹ Unique KingCard
    1401111, -- DÃ¹ BÃ¡nh Ãš
    1401112, -- DÃ¹ GÃ o ThÃ©t
    1401113, -- DÃ¹ Thá»§ Vá»‡ Tá»± Do
    1401115, -- DÃ¹ Káº¹o Ngá»t
    1401117, -- DÃ¹ Cao Bá»“i Viá»…n TÃ¢y
    1401119, -- DÃ¹ GiÃ¡p Samurai
    1401122, -- Incredible Parachute
    1401124, -- DÃ¹ Warrior
    1401125, -- DÃ¹ QuÃ½ CÃ´ Gothic
    1401127, -- DÃ¹ Tháº§n Thoáº¡i áº¢ Ráº­p
    1401128, -- DÃ¹ NhÃ  VÃ´ Äá»‹ch Arena
    1401129, -- DÃ¹ QuÃ¡n QuÃ¢n MÃ¹a 13
    1401130, -- DÃ¹ Gorilla
    1401131, -- DÃ¹ PMGC
    1401133, -- DÃ¹ MÃ¹a 15
    1401134, -- DÃ¹ Tulip
    1401135, -- DÃ¹ Ãc Ma Cuá»“ng Ná»™
    1401137, -- DÃ¹ MÃ¹a 14
    1401138, -- DÃ¹ Pro League (VÃ ng)
    1401139, -- DÃ¹ Pro League (Báº¡c)
    1401140, -- DÃ¹ Láº¡c ÄÃ  Báº£nh Bao
    1401141, -- DÃ¹ GÃ  RÃ¡n
    1401142, -- DÃ¹ CLB HoÃ ng Gia
    1401145, -- DÃ¹ Báº£y Sáº¯c
    1401146, -- DÃ¹ Mountain Dew
    1401147, -- DÃ¹ TÆ° Táº¿ Tá»‘i Cao
    1401148, -- DÃ¹ Idol
    1401149, -- DÃ¹ Dang Rá»™ng ÄÃ´i CÃ¡nh
    1401150, -- DÃ¹ Chiáº¿n Binh ThÃ©p
    1401151, -- DÃ¹ QuÃ¡n QuÃ¢n MÃ¹a 16
    1401152, -- DÃ¹ Liá»m Tá»­ Tháº§n
    1401153, -- DÃ¹ emoji Thá»a MÃ£n
    1401154, -- DÃ¹ emoji
    1401155, -- DÃ¹ emoji Vui Nhá»™n
    1401156, -- DÃ¹ Qualcomm
    1401157, -- DÃ¹ Äiá»ƒm SÆ¡ TÃ¡n
    1401159, -- DÃ¹ LÃ£nh ChÃºa Äá»™c TÃ i
    1401160, -- DÃ¹ Káº¹p Háº¡t Dáº» Vui Váº»
    1401161, -- DÃ¹ Long VÆ°Æ¡ng
    1401163, -- DÃ¹ GiÃ¡p Chiáº¿n Tháº§n
    1401164, -- DÃ¹ Giai Äiá»‡u YÃªu ThÆ°Æ¡ng
    1401165, -- DÃ¹ QuÃ¡n QuÃ¢n MÃ¹a 17
    1401167, -- DÃ¹ Ãnh TrÄƒng Huyá»n BÃ­
    1401168, -- DÃ¹ Tiá»‡c Disco
    1401169, -- DÃ¹ QuÃ¡n QuÃ¢n MÃ¹a 18
    1401170, -- DÃ¹ Tuyáº¿t Anh ÄÃ o
    1401171, -- DÃ¹ Tá»• Ong
    1401174, -- DÃ¹ QuÃ¡n QuÃ¢n MÃ¹a 19
    1401177, -- DÃ¹ QuÃ¡n QuÃ¢n C1S1
    1401178, -- DÃ¹ BÄƒng CÃ¡t SÃ©t
    1401179, -- DÃ¹ El Diablo
    1401181, -- ChÃºa Tá»ƒ BÄƒng GiÃ¡ - DÃ¹
    1401182, -- DÃ¹ Káº» SÄƒn Má»“i Biá»ƒn Xanh
    1401183, -- DÃ¹ Má»™ng Äiá»‡p
    1401184, -- DÃ¹ Bá» CÃ¡nh Cá»©ng
    1401186, -- DÃ¹ RÃ¹a vÃ  Thá»
    1401187, -- DÃ¹ Nhá»‹p BÆ°á»›c Máº¡nh Máº½
    1401188, -- DÃ¹ PMPL MÃ¹a XuÃ¢n 2021
    1401189, -- DÃ¹ GodzillaVsKong
    1401190, -- DÃ¹ HÃ nh TrÃ¬nh Ká»³ Diá»‡u
    1401191, -- DÃ¹ Dáº¥u áº¤n VÅ© Trá»¥
    1401192, -- DÃ¹ Äáº§u Báº¿p GÃ 
    1401193, -- DÃ¹ Nghá»‡ Thuáº­t Sáº¯c MÃ u
    1401194, -- DÃ¹ Aerial Punk Rich Brian
    1401195, -- DÃ¹ OPPO
    1401196, -- DÃ¹ BUG
    1401197, -- DÃ¹ ChÃºa Tá»ƒ BÃ¡nh RÄƒng
    1401198, -- DÃ¹ Xiaomi
    1401200, -- DÃ¹ ÄÃ´i Máº¯t Biá»ƒn SÃ¢u
    1401201, -- DÃ¹ OnePlus
    1401204, -- DÃ¹ foodpanda
    1401205, -- DÃ¹ PMPL MÃ¹a Thu 2021
    1401208, -- DÃ¹ ThÃ nh Phá»‘ TrÃªn KhÃ´ng
    1401209, -- DÃ¹ BÃ³ng Ma TÆ°Æ¡ng Lai
    1401210, -- DÃ¹ Máº­t ThÃ¡m CÆ¡ KhÃ­
    1401212, -- DÃ¹ ThÃ nh Phá»‘ Sáº¯c MÃ u
    1401213, -- DÃ¹ SÃºng Hoa Há»“ng
    1401215, -- DÃ¹ BÄƒng GiÃ¡
    1401216, -- DÃ¹ Báº£n Äá»“ Kho BÃ¡u
    1401217, -- DÃ¹ CÆ¡n Sá»‘t GiÃ¡ng Sinh
    1401218, -- DÃ¹ Há»a Tiáº¿t VÃ ng
    1401219, -- DÃ¹ VÆ°Æ¡ng Quá»‘c VÃ ng
    1401220, -- DÃ¹ HoÃ ng HÃ´n Rá»±c Rá»¡
    1401221, -- DÃ¹ Bá»“ CÃ¢u Tráº¯ng
    1401222, -- DÃ¹ VÃ²ng Xoay Thá»i Gian
    1401223, -- DÃ¹ Zong
    1401224, -- DÃ¹ QuÃ¡n QuÃ¢n C1S2
    1401225, -- DÃ¹ QuÃ¡n QuÃ¢n C1S3
    1401227, -- DÃ¹ Äáº¡i Háº¡ GiÃ¡
    1401228, -- DÃ¹ LÃ£ng KhÃ¡ch Thá»i ThÆ°á»£ng
    1401231, -- DÃ¹ PMGC 2021
    1401232, -- DÃ¹ Liverpool FC
    1401233, -- DÃ¹ Äá»™t PhÃ¡
    1401234, -- DÃ¹ Voi Sáº¯c MÃ u
    1401235, -- DÃ¹ Há»£p TÃ¡c Egor Kreed
    1401236, -- Gackt Moon Parachute
    1401237, -- DÃ¹ Dune
    1401238, -- DÃ¹ Guruh Gundala
    1401239, -- DÃ¹ C2S4
    1401240, -- DÃ¹ Baby Shark
    1401241, -- DÃ¹ JAPAN LEAGUE S2
    1401242, -- DÃ¹ Äáº§u Báº¿p QuÃ¡i ThÃº
    1401243, -- DÃ¹ BÃ¡ Chá»§ Äáº¡i DÆ°Æ¡ng
    1401244, -- DÃ¹ C2S5
    1401245, -- DÃ¹ Ná»¯ HoÃ ng Äiá»‡n Tá»­
    1401246, -- DÃ¹ NhÃ¢m Dáº§n
    1401247, -- DÃ¹ Sáº¯c XuÃ¢n
    1401248, -- DÃ¹ Jujutsu Kaisen
    1401249, -- DÃ¹ Shiba Inu
    1401250, -- DÃ¹ Motorola
    1401252, -- DÃ¹ Tráº­n Chiáº¿n Trendy
    1401254, -- DÃ¹ DJ CÃ¡ TÃ­nh
    1401255, -- DÃ¹ Chá»‹ Chá»‹ Em Em
    1401256, -- DÃ¹ Graffiti Neon
    1401257, -- DÃ¹ C2S6
    1401258, -- DÃ¹ NgÆ°á»i Nhá»‡n: KhÃ´ng CÃ²n NhÃ 
    1401259, -- DÃ¹ SÃ¡t Thá»§ Thá»i KhÃ´ng
    1401260, -- DÃ¹ VÃ¹ng Äáº¥t Hoang
    1401261, -- DÃ¹ Sáº¯c MÃ u
    1401262, -- DÃ¹ Lá»… Há»™i Sáº¯c MÃ u
    1401263, -- DÃ¹ Ráº¡p Xiáº¿c Tháº§n Ká»³
    1401264, -- DÃ¹ Thiáº¿u Ná»¯ TÃ³c Äá»
    1401265, -- DÃ¹ Bá»™ ÄÃ´i HoÃ n Háº£o
    1401266, -- DÃ¹ Thiáº¿u Ná»¯ Song Sinh
    1401267, -- DÃ¹ CÃ¡nh Cá»•ng Ká»³ Dá»‹
    1401268, -- DÃ¹ Thiáº¿u Ná»¯ Anime
    1401269, -- DÃ¹ GÃ  Chiáº¿n Äáº¥u
    1401270, -- DÃ¹ Náº¿n Xanh
    1401271, -- DÃ¹ Há»“n Ma Nghá»‹ch Ngá»£m
    1401272, -- DÃ¹ Thiáº¿u Ná»¯ Cáº§u Nguyá»‡n
    1401273, -- DÃ¹ Ma Ná»¯ ÄÃ¡ng YÃªu
    1401274, -- DÃ¹ Evangelion NERV
    1401275, -- DÃ¹ Chá»‹ Em Song Sinh
    1401276, -- DÃ¹ PMPL MÃ¹a XuÃ¢n 2022
    1401277, -- DÃ¹ Gáº¥u Teddy GB
    1401278, -- DÃ¹ SÆ° Tá»­ Thá»i Trang
    1401280, -- DÃ¹ Ká»· Niá»‡m Tuá»•i ThÆ¡
    1401281, -- DÃ¹ C3S7
    1401282, -- DÃ¹ MÃ¨o Khá»•ng Lá»“
    1401283, -- DÃ¹ Butterfinger
    1401284, -- SiÃªu DÃ¹ Nháº£y
    1401285, -- DÃ¹ Äá»“ng Minh MÃ¹a HÃ¨
    1401286, -- DÃ¹ SÃ³c Chuá»™t
    1401287, -- DÃ¹ Há»a Diá»‡m Ma GiÃ¡p
    1401289, -- DÃ¹ Heartrocker
    1401290, -- DÃ¹ SÆ° Tá»­ LÆ°á»¡ng HÃ 
    1401291, -- DÃ¹ realme
    1401292, -- DÃ¹ Lil Burger
    1401294, -- DÃ¹ DÃ²ng SÃ´ng Má»™ng MÆ¡
    1401295, -- DÃ¹ C3S8
    1401296, -- DÃ¹ ÄÃªm Cá»§a PhÃ©p MÃ u
    1401298, -- DÃ¹ Vinh Quang
    1401299, -- DÃ¹ Báº£n Äá»“ Sao
    1401300, -- DÃ¹ ChÃºa Tá»ƒ Gai Äá»™c
    1401301, -- DÃ¹ BÃ³ng Ma VÃ  NÃ ng
    1401302, -- DÃ¹ Gai BÃ© Bá»ng
    1401303, -- DÃ¹ Uqabi
    1401308, -- DÃ¹ PhÃ¹ Thá»§y BÄƒng GiÃ¡
    1401309, -- DÃ¹ Tá»‘c Äá»™ Cá»±c Háº¡n
    1401310, -- DÃ¹ PMWI 2022
    1401311, -- BGMI Esports Parachute
    1401312, -- PMJL SEASON3 Parachute
    1401313, -- PMPS 2022 Parachute
    1401314, -- DÃ¹ Chiáº¿n Binh NgÆ°u
    1401315, -- DÃ¹ Quyá»n Lá»±c Tá»‘i ThÆ°á»£ng
    1401316, -- DÃ¹ Äá»™i BÃ³ng áº¢ Ráº­p
    1401317, -- DÃ¹ NgÃ n Sao Rá»±c Rá»¡
    1401318, -- DÃ¹ PhÃ¡p SÆ° ThiÃªn VÄƒn
    1401319, -- DÃ¹ C3S9
    1401320, -- DÃ¹ BoBoiBoy
    1401323, -- DÃ¹ ÄÆ°á»ng Äua Hoang DÃ£
    1401324, -- DÃ¹ Tuáº§n Lá»™c Tráº¯ng
    1401325, -- DÃ¹ RÃ¬u HoÃ ng Kim
    1401326, -- DÃ¹ VÃ ng Huyá»n BÃ­
    1401330, -- DÃ¹ Du HÃ nh Tinh VÃ¢n
    1401332, -- DÃ¹ MÃ¨o Tuyáº¿t
    1401334, -- DÃ¹ KFC
    1401335, -- DÃ¹ Thá»§y SÆ° Cuá»“ng Ná»™
    1401336, -- DÃ¹ Sá» Nham Tháº¡ch
    1401337, -- DÃ¹ BÃ¡ Chá»§ Báº§u Trá»i
    1401338, -- DÃ¹ Grubhub
    1401339, -- DÃ¹ AFA
    1401340, -- DÃ¹ Huyá»n Thoáº¡i SiÃªu Sao Messi
    1401343, -- DÃ¹ PMGC 2022
    1401345, -- DÃ¹ Báº£n Äá»“ Kho BÃ¡u
    1401346, -- DÃ¹ Nobru
    1401347, -- DÃ¹ Sony
    1401349, -- DÃ¹ Äá»™t KÃ­ch TrÃªn KhÃ´ng
    1401351, -- DÃ¹ Ná»¯ Hiá»‡p
    1401353, -- DÃ¹ ChÃº Há» Quá»· Quyá»‡t
    1401355, -- DÃ¹ LÃ½ Tiá»ƒu Long
    1401356, -- DÃ¹ Cáº·p ÄÃ´i Diá»…n VÃµ
    1401357, -- DÃ¹ Donkey King
    1401360, -- DÃ¹ Pro League
    1401361, -- DÃ¹ Káº¿ Hoáº¡ch Äá» Tháº«m
    1401362, -- DÃ¹ C4S11
    1401363, -- DÃ¹ Báº£n Äá»“ VÅ© Trá»¥
    1401364, -- DÃ¹ BE@RBRICK
    1401365, -- DÃ¹ Nguá»“n SÃ¡ng Vinh Quang
    1401366, -- DÃ¹ KÃ½ á»¨c XÆ°a
    1401367, -- DÃ¹ Bugatti
    1401368, -- DÃ¹ HÃ³a Tháº¡ch Khá»§ng Long
    1401369, -- DÃ¹ Trá»‘n ThoÃ¡t T-Rex
    1401370, -- DÃ¹ Dragon Ball Super
    1401371, -- DÃ¹ C4S12
    1401372, -- DÃ¹ Huyáº¿t Rá»“ng
    1401373, -- UNIVER@GRW_XD BT21 Parachute
    1401374, -- DÃ¹ HUAWEI AppGallery
    1401375, -- DÃ¹ PMWI 2023
    1401376, -- DÃ¹ C5S13
    1401377, -- DÃ¹ Thá» Disco
    1401378, -- DÃ¹ Aston Martin
    1401379, -- DÃ¹ MÃ¹a HÃ¨ TrÃªn BÃ£i Biá»ƒn
    1401380, -- DÃ¹ C5S14
    1401381, -- DÃ¹ C5S15
    1401382, -- DÃ¹ PMGC 2023
    1401383, -- DÃ¹ KFC
    1401385, -- DÃ¹ Yeti Khá»•ng Lá»“
    1401386, -- DÃ¹ Pagani
    1401387, -- DÃ¹ BÃ¡o Sáº¯c MÃ u
    1401388, -- DÃ¹ BÃ© SÃ³c ÄÃ¡ng YÃªu
    1401389, -- DÃ¹ Ká»³ GiÃ´ng Há»“ng
    1401390, -- RS Swagster Parachute
    1401391, -- DÃ¹ Gáº¥u TrÃºc Ngá»t NgÃ o
    1401392, -- DÃ¹ Chiáº¿n Binh Hoa Há»“ng
    1401393, -- DÃ¹ Cuá»™c Chiáº¿n ChÃ­nh NghÄ©a
    1401394, -- DÃ¹ LINE FRIENDS
    1401395, -- DÃ¹ Há»“ Ly Tháº§n BÃ­
    1401396, -- DÃ¹ Zanmang Loopy
    1401397, -- Hardik Sky Parachute
    1401398, -- DÃ¹ C6S16
    1401399, -- DÃ¹ BÃ³ng Ma Quyáº¿n RÅ©
    1401400, -- DÃ¹ Báº£o Há»™ HoÃ ng Gia
    1401401, -- DÃ¹ Bentley
    1401402, -- SPYÃ—FAMILY DÃ¹
    1401403, -- DÃ¹ Nháº­t Thá»±c
    1401404, -- DÃ¹ Chiáº¿n SÄ© Tháº§n GiÃ¡p
    1401405, -- DÃ¹ C6S17
    1401406, -- DÃ¹ Giai Äiá»‡u MÃ¨o Con
    1401407, -- DÃ¹ ThÃ nh Phá»‘ Há»—n Loáº¡n
    1401408, -- DÃ¹ ÄÃ´i CÃ¡nh Cáº­n Vá»‡
    1401409, -- DÃ¹ Thiáº¿t MÃ£
    1401410, -- DÃ¹ Bay LÆ°á»›t VÅ© Trá»¥
    1401411, -- DÃ¹ C6 S18
    1401412, -- DÃ¹ Ná»¯ Äáº¿ Háº¯c Ãm
    1401413, -- DÃ¹ Há»£p TÃ¡c Lamborghini
    1401416, -- DÃ¹ TÆ°á»£ng ÄÃ¡ Cá»• XÆ°a
    1401417, -- DÃ¹ Äáº¡i DÆ°Æ¡ng Xanh
    1401418, -- KAKAO FRIENDS Parachute
    1401419, -- DÃ¹ Infinix GT
    1401420, -- DÃ¹ Esports World Cup 2024
    1401421, -- DÃ¹ C7S19
    1401422, -- DÃ¹ Thá» Tinh QuÃ¡i
    1401423, -- DÃ¹ Há»£p TÃ¡c VW
    1401424, -- DÃ¹ MiÃªu Linh Sáº¯c MÃ u
    1401425, -- DÃ¹ Háº¯c Long Ma NhÃ£n
    1401426, -- DÃ¹ Ã‚m DÆ°Æ¡ng
    1401427, -- NieR:Automata Parachute
    1401428, -- DÃ¹ Äam MÃª Esports
    1401429, -- DÃ¹ C7S20
    1401430, -- DÃ¹ Venom: KÃ¨o Cuá»‘i
    1401431, -- DÃ¹ Bá»™ Tá»™c NgÃ¢n HÃ 
    1401432, -- DÃ¹ Tuáº§n Lá»™c HoÃ ng Gia
    1401433, -- DÃ¹ McLaren
    1401434, -- DÃ¹ PMGC 2024
    1401435, -- DÃ¹ lÆ°á»£n SÃ³i Tuyáº¿t
    1401436, -- DÃ¹ lÆ°á»£n BÃ³ng NÆ°á»›c
    1401437, -- DÃ¹ lÆ°á»£n C7S21
    1401438, -- DÃ¹ CÃ¡ Koi XuÃ¢n Sáº¯c
    1401439, -- DÃ¹ Äáº¡i BÃ ng
    1401440, -- DÃ¹ Hoa Há»“ng BÃ³ng ÄÃªm
    1401441, -- Opanchu Parachute
    1401442, -- Neon Drop BE 6 Parachute
    1401443, -- DÃ¹ C8S22
    1401444, -- DÃ¹ LÆ°á»£n Háº¯c Cá»‘t
    1401445, -- DÃ¹ Cá»±c Quang Tinh TÃº
    1401446, -- Godzilla vs. DÃ¹ Destoroyah
    1401447, -- DÃ¹ Thá» Bá»“ng Bá»nh
    1401448, -- Parachute(Frieren&Fern)
    1401449, -- DÃ¹ C8S23
    1401450, -- DÃ¹ LÆ°á»£n MÃ£ Sá»‘ HÃ³a 
    1401451, -- DÃ¹ LÆ°á»£n Khuáº¿ch Äáº¡i Sáº¯c MÃ u
    1401452, -- DÃ¹ Há»£p TÃ¡c Shelby
    1401453, -- DÃ¹ RÃ¡ng Chiá»u Rá»±c ChÃ¡y
    1401454, -- DÃ¹ Attack on Titan
    1401455, -- DÃ¹ CÆ¡ KhÃ­ 
    1401456, -- Mountain Dew Neon Shard Parachute
    1401457, -- DÃ¹ C8S24
    1401458, -- DÃ¹ VÅ© Trá»¥
    1401459, -- DÃ¹ Transformers
    1401460, -- DÃ¹ Tháº§n Má»‡nh
    1401461, -- DÃ¹ CÃºn YÃªu
    1401462, -- Bbangbbang's diary Parachute
    1401463, -- Realme Parachute
    1401464, -- DÃ¹ Infinix GT
    1401465, -- DÃ¹ C9S25
    1401466, -- DÃ¹ Ãc Quá»·
    1401467, -- DÃ¹ Kaiju No. 8
    1401468, -- DÃ¹ TEAM SONIC
    1401469, -- DÃ¹ Há»“ Äiá»‡p Láº¥p LÃ¡nh
    1401470, -- DÃ¹ Lotus
    1401471, -- DÃ¹ BÃ´ng XÃ¹
    1401472, -- DÃ¹ Gen HoÃ n Háº£o
    1401473, -- Tokyo Revengers Parachute
    1401474, -- Sky Striker Parachute
    1401475, -- DÃ¹ C9S26
    1401476, -- DÃ¹ LÆ°á»£n Gáº¥u Ngá»t NgÃ o
    1401477, -- DÃ¹ Balenciaga
    1401478, -- DÃ¹ LÆ°á»£n Tuyáº¿t HÃ n
    1401479, -- DÃ¹ Porsche
    1401480, -- DÃ¹ Háº¯c Linh
    1401481, -- DÃ¹ Chá»“n Chill
    1401482, -- TV Anime DAN DA DAN Parachute
    1401483, -- DÃ¹ C9S27
    1401484, -- DÃ¹ LÆ°á»£n Shuriken
    1401485, -- DÃ¹ BÃ³ng Ma Anh Quá»‘c
    1401486, -- DÃ¹ The King of Fighters
    1401487, -- DÃ¹ LÆ°á»£n VÅ© KhÃºc
    1401488, -- DÃ¹ Báº£o Tháº¡ch
    1401489, -- DÃ¹ Chuá»—i MÃ¹a Giáº£i (2026H1)
    1401490, -- DÃ¹ S28
    1401491, -- DÃ¹ TrÃ² ChÆ¡i ChÃºa Há» LÃ©m LÄ©nh
    1401492, -- DÃ¹ Apollo
    1401493, -- DÃ¹ Hacker Láº¡nh LÃ¹ng
    1401494, -- DÃ¹ Há»™i Tá»¥ Äa Chiá»u
    1401495, -- Catch! Teenieping Parachute
    1401496, -- SAKAMOTO TARO Parachute
    1401497, -- Nakiri Ayame Parachute
    1401498, -- DÃ¹ S29
    1401499, -- Toxic Parachute
    1401500, -- DÃ¹ Red (TrÃ²n)
    1401511, -- DÃ¹ MÃ¨o Tinh Nghá»‹ch
    1401513, -- DÃ¹ San Martin FC
    1401515, -- DÃ¹ Máº¯t Quá»·
    1401516, -- DÃ¹ SÃ³ng ÄÃªm
    1401517, -- DÃ¹ Quáº£ QuÃ½t
    1401519, -- DÃ¹ Gáº¥u NgÃ¡y Ngá»§
    1401520, -- DÃ¹ Háº­u Duá»‡ Äáº¿ VÆ°Æ¡ng
    1401521, -- DÃ¹ MÃ¢y Cuá»™n
    1401526, -- DÃ¹ Hoa VÄƒn TrÃ¡ng Lá»‡
    1401527, -- DÃ¹ TrÃ¡i Tim Biá»ƒn Cáº£
    1401528, -- DÃ¹ HÃ nh Tinh Máº¹
    1401529, -- DÃ¹ HoÃ ng Tá»­ Ãnh Kim
    1401530, -- DÃ¹ GiÃ¡p Gai
    1401531, -- DÃ¹ VÃ¹ng Nguy Hiá»ƒm
    1401532, -- DÃ¹ á»c Biá»ƒn
    1401534, -- DÃ¹ Vá»‹t VÃ ng B.Duck
    1401538, -- DÃ¹ Thá» Dá»‹u DÃ ng
    1401540, -- DÃ¹ Yeti
    1401541, -- DÃ¹ Pixel Sáº¯c MÃ u
    1401542, -- DÃ¹ Má»¹ Vá»‹
    1401543, -- DÃ¹ I Love Tao Kae Noi
    1401544, -- DÃ¹ Váº¹t Baby
    1401545, -- DÃ¹ U.F.O
    1401546, -- DÃ¹ Baby Shark
    1401547, -- DÃ¹ Gáº¥u Nhá»“i BÃ´ng
    1401548, -- DÃ¹ MÃ¨o NghiÃªm TÃºc
    1401549, -- DÃ¹ Vinh Quang TrÆ°á»ng Tá»“n
    1401551, -- DÃ¹ Ná»¯ VÆ°Æ¡ng KhÃ´i GiÃ¡p
    1401554, -- DÃ¹ Khá»§ng Long Pixel
    1401555, -- DÃ¹ CÃ¡nh BÆ°á»›m HoÃ ng Gia
    1401556, -- DÃ¹ HÃ nh TrÃ¬nh Ngá»t NgÃ o
    1401610, -- DÃ¹ ChÃºc Má»«ng Sinh Nháº­t
    1401611, -- DÃ¹ SÃ¢n Kháº¥u Láº¥p LÃ¡nh
    1401613, -- DÃ¹ Tháº©m PhÃ¡n Anubis
    1401615, -- DÃ¹ Tháº§n Horus
    1401616, -- DÃ¹ One Plus
    1401617, -- DÃ¹ SÆ° Tá»­ Há»‘ng
    1401618, -- DÃ¹ Facebook
    1401619, -- DÃ¹ BÃ¹a Há»™ Má»‡nh Pharaoh
    1401620, -- DÃ¹ Pharaoh (Xanh)
    1401621, -- DÃ¹ Huyáº¿t Nha
    1401622, -- DÃ¹ LINE FRIENDS
    1401623, -- DÃ¹ PMNC 2021
    1401624, -- DÃ¹ Poseidon
    1401625, -- DÃ¹ CÃ´ng ChÃºa Bá»™ Láº¡c
    1401628, -- DÃ¹ PhÆ°á»£ng HoÃ ng Adarna áº¢o Diá»‡u
    1401629, -- DÃ¹ Thiáº¿u Ná»¯ SÃ¡ng Tháº¿
    1401811, -- Giannis Parachute
    1401813, -- DÃ¹ HÃ nh TrÃ¬nh Anh HÃ¹ng
    1401814, -- DÃ¹ Rock 'n' Roll
    1401815, -- DÃ¹ Chá»‰ Huy Chiáº¿n TrÆ°á»ng
    1401816, -- DÃ¹ BURGER KING
    1401817, -- DÃ¹ Chiáº¿n Binh Huyáº¿t Æ¯ng
    1401820, -- DÃ¹ CÃ¡ Chuá»“n
    1401822, -- DÃ¹ QuÃ¡i ThÃº Äáº§m Láº§y
    1401823, -- DÃ¹ LÃ£nh ChÃºa Phong
    1401824, -- DÃ¹ Há»™p QuÃ 
    1401826, -- DÃ¹ - Má»‘i TÃ¬nh Äáº§u
    1401827, -- DÃ¹ Ná»¯ HoÃ ng CÃ  PhÃª
    1401828, -- DÃ¹ Vá»‡ Binh Cá»• Äáº¡i
    1401829, -- DÃ¹ CÆ¡n Giáº­n Cá»§a Tháº§n
    1401832, -- DÃ¹ C4S10
    1401833, -- DÃ¹ QuÃ¡i ThÃº MÃª Cung
    1401835, -- DÃ¹ Poker Äá»‘i KhÃ¡ng
    1401836, -- DÃ¹ TrÃ² ChÆ¡i ChÃº Há»
    1401837, -- DÃ¹ Huyá»…n áº¢nh
    1401838, -- DÃ¹ BLUE LOCK
    1401839, -- DÃ¹ Ford
    1401840, -- DÃ¹ Harley-DavidsonÂ®
    1401841, -- DÃ¹ Hoa Há»“ng Cá»‘t
    1401842, -- DÃ¹ Song Tá»­
    1401843, -- DÃ¹ LÆ°á»£n VÃ²ng Nguyá»‡t Quáº¿
    1401844, -- Parachute(Pubniku)
    1401845, -- DÃ¹ S30
    1401846, -- DÃ¹ Sá»± Kiá»‡n Trial of Fire

    -- [ TÃ€U LÆ¯á»¢N / VÃN TRÆ¯á»¢T / THIáº¾T Bá»Š BAY (Gliders/Hoverboards) ]
    4151001, -- DÃ¹ (Xanh)
    4151002, -- Hiá»‡u á»©ng nháº£y dÃ¹ (VÃ ng)
    4151003, -- KhÃ³i LÆ°á»£n DÃ¹ (Há»“ng)
    4151004, -- KhÃ³i lÆ°á»£n xanh
    4151006, -- KhÃ³i lÆ°á»£n cáº§u vá»“ng
    4151010, -- Thiáº¿t bá»‹ bay Báº±ng ChÃ­u
    4151012, -- VÃ¡n TrÆ°á»£t Chu Ká»³
    4151013, -- VÃ¡n TrÆ°á»£t Tuyáº¿t
    4151014, -- VÃ¡n trÆ°á»£t CHU Ká»² 2
    4151015, -- KhÃ³i LÆ°á»£n DÃ¹ ChÃºc Má»«ng (3 mÃ u)
    4151017, -- VÃ¡n trÆ°á»£t TrÃ¡i Tim Rá»«ng Xanh
    4151018, -- VÃ¡n trÆ°á»£t Sinh Nháº­t
    4151019, -- TÃ u LÆ°á»£n Chiáº¿n Tháº§n TÃ¬nh YÃªu
    4151020, -- VÃ¡n TrÆ°á»£t Cáº£nh Vá»‡ C3
    4151021, -- TÃ u LÆ°á»£n Sá»© Giáº£ Cá»§a Tháº§n
    4151022, -- TÃ u LÆ°á»£n CÃ¡nh VÃ ng
    4151023, -- VÃ¡n TrÆ°á»£t Há»£p TÃ¡c Messi
    4151024, -- TÃ u LÆ°á»£n GiÃ¡o SÄ© Äá» Tháº«m
    4151025, -- TÃ u LÆ°á»£n Diá»u Giáº¥y
    4151026, -- VÃ¡n TrÆ°á»£t Äáº¡i SÆ° VÃµ Há»“n
    4151027, -- VÃ¡n TrÆ°á»£t Cycle 4
    4151028, -- VÃ¡n TrÆ°á»£t Giá»t Lá»‡ Huyáº¿t
    4151029, -- TÃ u LÆ°á»£n Ná»¯ Äáº¿ Ãnh SÃ¡ng
    4151030, -- TÃ u LÆ°á»£n Ma VÆ°Æ¡ng Huyáº¿t Há»“n
    4151031, -- TÃ u LÆ°á»£n Khá»§ng Long TÃºi Tiá»n
    4151032, -- TÃ u LÆ°á»£n CÃ¡nh Rá»“ng Äá» Tháº«m
    4151034, -- CÃ¢n Äáº©u VÃ¢n
    4151035, -- TÃ u LÆ°á»£n Giao HÆ°á»Ÿng GiÃ³
    4151036, -- VÃ¡n TrÆ°á»£t MÃ¡y Dáº­p SÃ³ng
    4151037, -- VÃ¡n TrÆ°á»£t CYCLE 5
    4151038, -- DÃ¹ LÆ°á»£n Ngá»c Trai Tuyá»‡t Háº£o
    4151040, -- VÃ¡n trÆ°á»£t Thá»£ SÄƒn Äiá»‡n Quang
    4151041, -- DÃ¹ LÆ°á»£n XÆ°Æ¡ng Xanh
    4151042, -- TÃ u LÆ°á»£n CÃ´ng ChÃºa CÃ´ng Nghá»‡
    4151043, -- TÃ u LÆ°á»£n CÃ´ng ChÃºa CÃ´ng Nghá»‡
    4151044, -- VÃ¡n TrÆ°á»£t CÃ¡ Máº­p
    4151045, -- DÃ¹ LÆ°á»£n MÃ¹a ÄÃ´ng HoÃ ng Gia
    4151046, -- VÃ¡n TrÆ°á»£t LÆ°á»¡i Dao Trá»i Xanh
    4151056, -- DÃ¹ LÆ°á»£n MÃ¹a ÄÃ´ng HoÃ ng Gia
    4151057, -- VÃ¡n TrÆ°á»£t Há»a Há»“ Ly
    4151058, -- DÃ¹ LÆ°á»£n LINE FRIENDS
    4151059, -- VÃ¡n TrÆ°á»£t XuyÃªn MÃ¢y
    4151060, -- DÃ¹ LÆ°á»£n XÃ  Kim
    4151061, -- VÃ¡n TrÆ°á»£t CYCLE 6
    4151062, -- KhÃ³i LÆ°á»£n DÃ¹ Zanmang Loopy
    4151063, -- SPYÃ—FAMILY TÃ u LÆ°á»£n Bond
    4151064, -- DÃ¹ LÆ°á»£n ThiÃªn Sá»©
    4151065, -- DÃ¹ LÆ°á»£n ThiÃªn Sá»©
    4151066, -- DÃ¹ LÆ°á»£n Äáº¿ VÆ°Æ¡ng Tháº§n Vá»±c
    4151067, -- DÃ¹ LÆ°á»£n KÃ­nh Váº¡n Hoa
    4151068, -- TÃ u LÆ°á»£n ChÃºa Tá»ƒ Gai Äá»™c
    4151069, -- TÃ u LÆ°á»£n Tinh VÃ¢n Sáº¥m SÃ©t
    4151070, -- TÃ u LÆ°á»£n Ká»µ Binh Tháº§n GiÃ¡p
    4151071, -- DÃ¹ LÆ°á»£n Vá»‡ Tháº§n TÃ¬nh Ãi
    4151072, -- DÃ¹ LÆ°á»£n Ngao Du VÅ© Trá»¥
    4151073, -- DÃ¹ LÆ°á»£n Neon Huyá»n BÃ­
    4151074, -- PUBGM X NewJeans Glider
    4151075, -- DÃ¹ LÆ°á»£n Vá»‡ Tháº§n TÃ¬nh Ãi
    4151076, -- TÃ u LÆ°á»£n Cá»­u Phong ThiÃªn TÃ´n
    4151077, -- MÃ¡y Bay
    4151078, -- TÃ u LÆ°á»£n Háº£i MÃ£ Sáº¯t
    4151079, -- TÃ u LÆ°á»£n ÄÃ´i CÃ¡nh Tháº¿ Giá»›i Ngáº§m
    4151080, -- VÃ¡n TrÆ°á»£t Cycle 7
    4151083, -- DÃ¹ LÆ°á»£n Long Cá»‘t
    4151084, -- Há»“ng Há»a Diá»‡m - Kar98 (Cáº¥p 8)
    4151085, -- DÃ¹ LÆ°á»£n CÃ¡nh ThÃ©p XuyÃªn KhÃ´ng
    4151086, -- DP Drift Parachute
    4151087, -- DÃ¹ LÆ°á»£n Long Cá»‘t
    4151089, -- DÃ¹ LÆ°á»£n Háº¯c Äiá»ƒu 
    4151090, -- DÃ¹ LÆ°á»£n Giáº¥c Má»™ng Ngá»t NgÃ o
    4151091, -- TÃ u LÆ°á»£n NhÃ  KhÃ¡m PhÃ¡ VÅ© Trá»¥
    4151092, -- DÃ¹ LÆ°á»£n Lam SÆ° Tinh HÃ 
    4151093, -- DÃ¹ LÆ°á»£n Ngá»c Lang ThiÃªn Giá»›i
    4151094, -- VÃ¡n TrÆ°á»£t CYCLE 8
    4151095, -- DÃ¹ LÆ°á»£n ÄÃ´i CÃ¡nh Anukhra
    4151096, -- DÃ¹ LÆ°á»£n ÄÃ´i CÃ¡nh Pharaoh
    4151097, -- TÃ u LÆ°á»£n SiÃªu ThÃº Ghidorah
    4151098, -- DÃ¹ LÆ°á»£n Thá»i Quang Kháº£ Biáº¿n
    4151099, -- DÃ¹ LÆ°á»£n VÆ°Æ¡ng Quyá»n Háº¯c Ãm
    4151103, -- DÃ¹ LÆ°á»£n Chiáº¿n Xa Tinh TÃº
    4151104, -- TÃ u LÆ°á»£n Thiáº¿t Bá»‹ ODM
    4151105, -- DÃ¹ LÆ°á»£n Äá»‹nh Má»‡nh Huyáº¿t ChÃº
    4151106, -- DÃ¹ LÆ°á»£n Quang áº¢o Äiá»‡n Tá»« 
    4151107, -- DÃ¹ LÆ°á»£n Chiáº¿n Xa Tinh TÃº
    4151108, -- TÃ u LÆ°á»£n Laserbreak
    4151109, -- TÃ u LÆ°á»£n BÄƒng Tháº§n
    4151110, -- TÃ u LÆ°á»£n Long ThÃ¡nh
    4151111, -- TÃ u LÆ°á»£n Thá»£ SÄƒn Pháº£n Lá»±c
    4151112, -- TÃ u LÆ°á»£n TÃ  Tháº§n Má»¹ Quang
    4151113, -- VÃ¡n TrÆ°á»£t CYCLE 9
    4151114, -- TÃ u LÆ°á»£n Long ThÃ¡nh
    4151115, -- TÃ u LÆ°á»£n BÄƒng Tháº§n
    4151117, -- TÃ u LÆ°á»£n Preondactyl
    4151118, -- DÃ¹ LÆ°á»£n Há»“ Äiá»‡p Láº¥p LÃ¡nh
    4151119, -- DÃ¹ LÆ°á»£n Chá»•i PhÃ©p Thuáº­t
    4151120, -- DÃ¹ LÆ°á»£n Long KÃ­nh
    4151121, -- Mikey Glider
    4151122, -- DÃ¹ LÆ°á»£n Há»“ Äiá»‡p Láº¥p LÃ¡nh
    4151123, -- TÃ u LÆ°á»£n BÄƒng Linh LÆ°u Ly
    4151124, -- TÃ u LÆ°á»£n Huyáº¿t Dá»±c Tá»­ Tháº§n
    4151125, -- TÃ u LÆ°á»£n Vá»‡ Binh NgÃ¢n HÃ 
    4151126, -- TÃ u LÆ°á»£n Giáº£i TrÃ­
    4151127, -- TÃ u LÆ°á»£n Linh Má»™c VÄ©nh Cá»­u
    4151128, -- TÃ u LÆ°á»£n Tháº§n Quang
    4151129, -- VÃ¡n TrÆ°á»£t Chuá»—i MÃ¹a Giáº£i (2026H1)
    4151130, -- TÃ u LÆ°á»£n Nue
    4151131, -- TÃ u LÆ°á»£n PhÆ°á»£ng HoÃ ng Äáº¿ VÆ°Æ¡ng
    4151132, -- TÃ u LÆ°á»£n Huyáº¿t Dá»±c Háº¯c Äiá»ƒu
    4151133, -- TÃ u LÆ°á»£n Dá»‹ch Chuyá»ƒn KhÃ´ng Gian
    4151134, -- DÃ¹ LÆ°á»£n Äa VÅ© Trá»¥
    4151135, -- SAKAMOTO TARO Glider
    4151138, -- TÃ u LÆ°á»£n Sáº¥m SÃ©t Äá»
    4151139, -- TÃ u LÆ°á»£n HÆ° KhÃ´ng
    4151140, -- TÃ u LÆ°á»£n Song Tá»­
    4151141, -- TÃ u LÆ°á»£n Cerberus
    4151142, -- TÃ u LÆ°á»£n Ngá»c Trai
    4151143, -- TÃ u LÆ°á»£n Song Tá»­
    202408087,
    202408061,
    1102001001,
    4152031, -- TÃ u LÆ°á»£n Ma VÆ°Æ¡ng Huyáº¿t Há»“n
    4152035, -- CÃ¢n Äáº©u VÃ¢n
    4152036, -- Windborne Euphony Glider
    4152037, -- VÃ¡n TrÆ°á»£t MÃ¡y Dáº­p SÃ³ng
    4152038, -- VÃ¡n TrÆ°á»£t CYCLE 5
    4152039, -- TÃ u LÆ°á»£n Ngá»c Trai Tuyá»‡t Háº£o
    4152041, -- Boxerbolt Hoverboard (Shop)
    4152042, -- Blueyonder Glider
    4152043, -- Agile Charmer Glider
    4152044, -- Agile Charmer Glider
    4152045, -- Chilly Perch Glider
    4152046, -- Foxy Flare Hoverboard
    4152058, -- LINE FRIENDS Glider (Shop)
    4152059, -- Cloud Piercer Hoverboard (Shop)
    4152060, -- Golden Wings Glider (Shop)
    4152061, -- CYCLE 6 Skateboard (Shop)
    4152063, -- TÃ u LÆ°á»£n Bond SPYÃ—FAMILY (Cá»­a HÃ ng)
    4152066, -- DÃ¹ LÆ°á»£n Äáº¿ VÆ°Æ¡ng Tháº§n Vá»±c (Cá»­a HÃ ng)
    4152067, -- TÃ u LÆ°á»£n KÃ­nh Váº¡n Hoa (Cá»­a HÃ ng)
    4152068, -- TÃ u LÆ°á»£n ChÃºa Tá»ƒ Gai Äá»™c (Cá»­a HÃ ng)
    4152069, -- TÃ u LÆ°á»£n Tinh VÃ¢n Sáº¥m SÃ©t (Cá»­a HÃ ng)
    4152070, -- TÃ u LÆ°á»£n Ká»µ Binh Tháº§n GiÃ¡p (Cá»­a HÃ ng)
    4152076, -- TÃ u LÆ°á»£n Cá»­u Phong ThiÃªn TÃ´n (Cá»­a HÃ ng)
    4152077, -- TÃ u LÆ°á»£n (Cá»­a HÃ ng)
    4152078, -- TÃ u LÆ°á»£n Háº£i MÃ£ Sáº¯t (Cá»­a HÃ ng)
    4152079, -- TÃ u LÆ°á»£n ÄÃ´i CÃ¡nh Tháº¿ Giá»›i Ngáº§m (Cá»­a HÃ ng)
    4152080, -- VÃ¡n TrÆ°á»£t CYCLE 7 (Cá»­a HÃ ng)
    4152092, -- TÃ u LÆ°á»£n Lam SÆ° Tinh HÃ  (Cá»­a HÃ ng)
    4152093, -- TÃ u LÆ°á»£n Ngá»c Lang ThiÃªn Giá»›i (Cá»­a HÃ ng)
    4152094, -- VÃ¡n TrÆ°á»£t CYCLE 8 (Cá»­a HÃ ng)
    4152095, -- DÃ¹ LÆ°á»£n ÄÃ´i CÃ¡nh Anukhra
    4152096, -- DÃ¹ LÆ°á»£n ÄÃ´i CÃ¡nh Pharaoh
    4152097, -- TÃ u LÆ°á»£n SiÃªu ThÃº Ghidorah
    4152098, -- DÃ¹ LÆ°á»£n Thá»i Quang Kháº£ Biáº¿n
    4152099, -- DÃ¹ LÆ°á»£n VÆ°Æ¡ng Quyá»n Háº¯c Ãm
    4152116, -- TÃ u LÆ°á»£n Long ThÃ¡nh (Sáº£nh Má»™t NgÆ°á»i)

    -- ==============================================================================
    -- 3. TRANG PHá»¤C (OUTFITS), X-SUIT & PHá»¤ KIá»†N
    -- ==============================================================================
    -- [ X-SUIT ]
    1407895, -- X-Suit Quáº¡ Huyáº¿t (7 Sao)
    1407856, -- X-Suit PhÆ°á»£ng HoÃ ng (7 Sao)
    1405628, -- X-Suit Pharaoh VÃ ng (6 Sao)
    1406469, -- X-Suit Pharaoh VÃ ng (7 Sao)
    1405870, -- X-Suit Quáº¡ Huyáº¿t (6 Sao)
    1407140, -- X-Suit Poseidon (7 Sao)
    1407142, -- X-Suit Silvanus (7 Sao)
    1407141, -- X-Suit BÃ£o Tuyáº¿t (7 Sao)
    1407550, -- X-Suit Ãnh SÃ¡ng Cáº§u Vá»“ng (7 Sao)
    1406638, -- X-Suit Há» BÃ­ áº¨n (6 Sao) [Äen]
    1406641, -- X-Suit Há» BÃ­ áº¨n (6 Sao) [Tráº¯ng]
    1406872, -- X-Suit ChÃºa Tá»ƒ Ã‚m Ty (7 Sao)
    1406971, -- X-Suit Marmoris (7 Sao)
    1407103, -- X-Suit Fiore (7 Sao)
    1407219, -- X-Suit Ignis (7 Sao)
    1407366, -- X-Suit Galadria (7 Sao)
    1407512, -- X-Suit Anukhra (7 Sao)
    1407625, -- X-Suit Dravion (7 Sao) [Nam]
    1407667, -- X-Suit Dravion (7 Sao) [Ná»¯]

    -- [ OUTFITS ]
    1407870, -- Bá»™ Ná»¯ Tháº§n KhÃ´ng Gian
    1407871, -- Bá»™ ThÃ¡m Tá»­ Äa VÅ© Trá»¥
    1407812, -- Bá»™ Vá»‡ Binh Hoang DÃ£
    1407758, -- Bá»™ TiÃªn Ná»¯ MÃ¹a ÄÃ´ng
    1407286, -- Bá»™ MÃ¨o Cyber Tinh Nghá»‹ch
    1407329, -- Bá»™ Ãnh SÃ¡ng TÄ©nh Láº·ng
    1407391, -- Bá»™ Ná»¯ BÃ¡ TÆ°á»›c Ma CÃ  Rá»“ng
    1407392, -- Bá»™ Káº» PhÃ¡ Hoáº¡i Man Rá»£
    1407387, -- Bá»™ Tá»­ Tháº§n Táº­n Tháº¿
    1407440, -- Bá»™ Káº» Chinh Phá»¥c Báº¯c Cá»±c
    1406985, -- Bá»™ NgÆ°á»i TÃ¬nh BÃ£i Biá»ƒn
    1407470, -- Bá»™ ThiÃªn Tháº§n Ná»•i Loáº¡n
    1407471, -- Bá»™ Cá»±c Quang Nanh Ngá»c
    1407522, -- Bá»™ Háº­u Duá»‡ TiÃªn CÃ¡t
    1407330, -- Bá»™ ÄÃ´ Äá»‘c BÃ³ng Ma
    1407523, -- Bá»™ Uy Quyá»n TÃ  Ãc
    1407558, -- Bá»™ ThÃ¡i DÆ°Æ¡ng ThÄƒng Hoa
    1407559, -- Bá»™ Ãnh SÃ¡ng Nguyá»‡t Cung
    1407572, -- Bá»™ Huyáº¿t Dáº¡ HoÃ ng HÃ´n
    1407682, -- Bá»™ KÃ©n áº¨n SÄ©
    1407695, -- Bá»™ Lá»… TÃ¬nh NhÃ¢n RÃ¹ng Rá»£n
    1407696, -- Bá»™ LÄƒng KÃ­nh ThÄƒng Hoa
    1407632, -- Bá»™ Háº¯c Dáº¡ TÃ  Ãc
    1407573, -- Bá»™ BÃ³ng Ma Äiá»‡n Tá»­
    1406398, -- Bá»™ BÃ³ng Ma Rá»±c Lá»­a
    1406399, -- Bá»™ Ká»µ Binh Oai Vá»‡
    1406482, -- Bá»™ ChÃºa Tá»ƒ Gai GÃ³c
    1406483, -- Bá»™ Tinh VÃ¢n Sáº¥m SÃ©t
    1406555, -- Bá»™ KhuÃ´n Máº·t Äá»‹a Ngá»¥c
    1406573, -- Bá»™ ThiÃªn Nga BÃ³ng Ma
    1406574, -- Bá»™ Quan TÃ²a VÅ© Trá»¥
    1406656, -- Bá»™ TrÆ°a Äáº«m MÃ¡u
    1406657, -- Bá»™ ÄÃ´ Äá»‘c Biá»ƒn Sao
    1406742, -- Bá»™ Äáº¡o SÆ° Báº¡c
    1406744, -- Bá»™ Hiá»‡p SÄ© ThÃ¡i DÆ°Æ¡ng
    1406789, -- Bá»™ BÃ³ng Ma Äá»‹a Ngá»¥c
    1406823, -- Bá»™ Giá»t Nguyá»‡t Báº¥t Diá»‡t
    1406824, -- Bá»™ Káº» ThÃ¹ Nhuá»‘m MÃ¡u
    1406897, -- Bá»™ Ãc Má»™ng Äá» Tháº«m
    1407277, -- Trang Phá»¥c Há»a Tháº§n Cá»• Ngá»¯
    1406891, -- Trang Phá»¥c Linh Há»“n XÃ¡c Æ¯á»›p
    1405623, -- Bá»™ XÃ¡c Æ¯á»›p VÃ ng
    1400687, -- Bá»™ XÃ¡c Æ¯á»›p Tráº¯ng
    1407618, -- Bá»™ Thá»±c Há»“n Báº¯c Cá»±c (Polar Spectrophage)

    -- [ Dragon Ball Super Collab ]
    1406937, -- Trang Phá»¥c NhÃ¢n Váº­t Super Saiyan Son Goku
    1406938, -- Trang Phá»¥c NhÃ¢n Váº­t Frieza
    1406939, -- Trang Phá»¥c NhÃ¢n Váº­t Son Goku
    1406947, -- Trang Phá»¥c NhÃ¢n Váº­t Vegeta
    1406948, -- Trang Phá»¥c NhÃ¢n Váº­t Super Saiyan Vegeta
    1406950, -- Trang Phá»¥c Beerus
    1406951, -- Trang Phá»¥c Ma BÆ°
    1406952, -- Trang Phá»¥c Quy LÃ£o Kame
    1406953, -- Trang Phá»¥c NhÃ¢n Váº­t Gohan SiÃªu Cáº¥p
    1406954, -- Trang Phá»¥c NhÃ¢n Váº­t Piccolo
    1407264, -- Trang Phá»¥c NhÃ¢n Váº­t Vegito
    1407265, -- Trang Phá»¥c NhÃ¢n Váº­t Vegito SiÃªu Saiyan
    1407266, -- Trang Phá»¥c NhÃ¢n Váº­t Vegito SiÃªu Saiyan Xanh
    1407267, -- Trang Phá»¥c NhÃ¢n Váº­t Son Goku SiÃªu Saiyan Xanh
    1407268, -- Trang Phá»¥c NhÃ¢n Váº­t Son Goku SiÃªu Saiyan Xanh (Bá»‹ ThÆ°Æ¡ng)
    1407269, -- Trang Phá»¥c NhÃ¢n Váº­t Vegeta Super Saiyan Xanh
    1407270, -- Trang Phá»¥c NhÃ¢n Váº­t Vegeta SiÃªu Saiyan Xanh (Bá»‹ ThÆ°Æ¡ng)
    1407271, -- Trang Phá»¥c NhÃ¢n Váº­t Bulma

    -- [ Evangelion Collab ]
    1406385, -- Plugsuit Evangelion Shinji
    1406386, -- Plugsuit Evangelion Rei
    1406387, -- Plugsuit Evangelion Asuka
    1406388, -- Plugsuit Evangelion Mari
    1406389, -- Plugsuit Evangelion Kaworu

    -- [ Attack on Titan Collab ]
    1407563, -- Trang Phá»¥c NhÃ¢n Váº­t Eren Jaeger
    1407565, -- Trang Phá»¥c NhÃ¢n Váº­t Mikasa Ackermann
    1407566, -- Trang Phá»¥c NhÃ¢n Váº­t Armin Arlelt
    1407567, -- Trang Phá»¥c Titan Khá»•ng Lá»“ (Armin)
    1407568, -- Trang Phá»¥c NhÃ¢n Váº­t Levi
    1407569, -- Trang Phá»¥c Titan Bá»c ThÃ©p

    -- [ Kaiju No. 8 Collab ]
    1407672, -- Trang Phá»¥c NhÃ¢n Váº­t Kafka Hibino
    1407673, -- Trang Phá»¥c Kaiju No. 8
    1407674, -- Trang Phá»¥c NhÃ¢n Váº­t Kikoru Shinomiya
    1407675, -- Trang Phá»¥c Kaiju No. 9
    1407676, -- Trang Phá»¥c Kaiju No. 10
    1407677, -- Trang Phá»¥c NhÃ¢n Váº­t Mina Ashiro
    1407678, -- Trang Phá»¥c NhÃ¢n Váº­t Reno Ichikawa
    1407679, -- Trang Phá»¥c NhÃ¢n Váº­t Soshiro Hoshina

    -- [ BlackPink & Kpop Collabs ]
    1406132, -- Trang phá»¥c DDU-DU DDU-DU ROSÃ‰
    1406133, -- Trang phá»¥c DDU-DU DDU-DU JENNIE
    1406134, -- Trang phá»¥c DDU-DU DDU-DU JISOO
    1406135, -- Trang phá»¥c DDU-DU DDU-DU LISA
    1406161, -- Trang phá»¥c How You Like That ROSÃ‰
    1406162, -- Trang phá»¥c How You Like That JENNIE
    1406163, -- Trang phá»¥c How You Like That JISOO 
    1406164, -- Trang phá»¥c How You Like That LISA
    1406178, -- Trang phá»¥c Lovesick Girls ROSÃ‰
    1406179, -- Trang phá»¥c Lovesick Girls JENNIE
    1406180, -- Trang phá»¥c Lovesick Girls JISOO
    1406181, -- Trang phá»¥c Lovesick Girls LISA
    1407346, -- PUBGM X NewJeans MINJI Set
    1407347, -- PUBGM X NewJeans HANNI Set
    1407348, -- PUBGM X NewJeans HAERIN Set
    1407349, -- PUBGM X NewJeans DANIELLE Set
    1407350, -- PUBGM X NewJeans HYEIN Set
    1407745, -- Trang Phá»¥c RAMI (Babymonster)
    1407746, -- Trang Phá»¥c ASA (Babymonster)
    1407747, -- Trang Phá»¥c AHYEON (Babymonster)
    1407748, -- Trang Phá»¥c RORA (Babymonster)
    1407749, -- Trang Phá»¥c CHIQUITA (Babymonster)
    1407750, -- Trang Phá»¥c PHARITA (Babymonster)
    1407751, -- Trang Phá»¥c RUKA (Babymonster)
    1407826, -- Trang Phá»¥c PUBG MOBILE Ã— aespa KARINA
    1407827, -- Trang Phá»¥c PUBG MOBILE Ã— aespa GISELLE
    1407828, -- Trang Phá»¥c PUBG MOBILE Ã— aespa WINTER
    1407829, -- Trang Phá»¥c PUBG MOBILE Ã— aespa NINGNING
    1407687, -- Trang Phá»¥c G-DRAGON PEACEMINUSONE
    1407688, -- Trang Phá»¥c SÃ¢n Kháº¥u cá»§a G-DRAGON

    -- [ CÃC COLLAB Ná»”I Báº¬T KHÃC (Messi, LÃ½ Tiá»ƒu Long, SPYxFAMILY...) ]
    1406648, -- Trang Phá»¥c Biá»ƒu TÆ°á»£ng BÃ³ng ÄÃ¡ Messi
    1406649, -- Trang Phá»¥c Huyá»n Thoáº¡i SiÃªu Sao Messi
    1406728, -- Trang Phá»¥c Kung Fu LÃ½ Tiá»ƒu Long
    1406729, -- Trang Phá»¥c ChuyÃªn Gia Cáº­n Chiáº¿n LÃ½ Tiá»ƒu Long
    1406730, -- Trang Phá»¥c Rá»“ng Gáº§m LÃ½ Tiá»ƒu Long
    1406731, -- Trang Phá»¥c VÃµ SÄ© LÃ½ Tiá»ƒu Long
    1407206, -- SPYÃ—FAMILY Trang Phá»¥c HoÃ ng HÃ´n
    1407401, -- C.C. Set
    1407402, -- Kallen Kozuki Set
    1407404, -- Suzaku Kururugi Set
    1407405, -- ZERO Set
    1407408, -- Emperor Lelouch Set
    1407769, -- Okarun(transformed) Set
    1407770, -- Okarun Set
    1407771, -- Momo Set
    1407772, -- Jiji(transformed) Set
    1407773, -- Aira Set
    1407794, -- Trang Phá»¥c NhÃ¢n Váº­t John Shelby
    1407795, -- Trang Phá»¥c NhÃ¢n Váº­t Arthur Shelby
    1407796, -- Trang phá»¥c Thomas Shelby
    1407798, -- Trang Phá»¥c NhÃ¢n Váº­t Iori Yagami
    1407800, -- Trang Phá»¥c NhÃ¢n Váº­t Mai Shiranui
    1407801, -- Trang Phá»¥c NhÃ¢n Váº­t Nakoruru
    1407846, -- Trang Phá»¥c NhÃ¢n Váº­t Kimono Ryomen Sukuna
    1407848, -- Trang Phá»¥c NhÃ¢n Váº­t Suguru Geto
    1407901, -- Trang Phá»¥c NhÃ¢n Váº­t Isagi Yoichi
    1407902, -- Trang Phá»¥c NhÃ¢n Váº­t Bachira Meguru

    -- [ Set Äá»“ Äá» Tá»± NhiÃªn & SiÃªu VIP cá»§a Game ]
    1405160, -- Huyá»n Thoáº¡i Godzilla
    1405161, -- SiÃªu ThÃº Ghidorah
    1405186, -- Bá»™ Äá»“ Godzilla
    1405662, -- Trang phá»¥c GiÃ¡p Samurai
    1405663, -- Trang phá»¥c SÃ¡t Thá»§ BÃ³ng ÄÃªm
    1406020, -- Trang phá»¥c QuÃ¡i ThÃº
    1406398, -- Trang phá»¥c Há»a Diá»‡m Ma GiÃ¡p
    1406399, -- Trang phá»¥c Ká»µ Binh Tháº§n GiÃ¡p
    1406456, -- Trang Phá»¥c Anh HÃ¹ng Truyá»n Thuyáº¿t
    1406568, -- Trang Phá»¥c Ná»¯ HoÃ ng BÃ³ng ÄÃªm
    1406569, -- Trang Phá»¥c Minh VÆ°Æ¡ng HÃ nh Quyáº¿t
    1406732, -- Trang Phá»¥c Ná»¯ Äáº¿ HoÃ ng Kim
    1406733, -- Trang Phá»¥c HoÃ ng Äáº¿ HoÃ ng Kim
    1406764, -- Trang Phá»¥c Thiáº¿u Ná»¯ Äá» Rá»±c

    -- ==============================================================================
    -- 4. ÃO, QUáº¦N, GIÃ€Y Äáº¸P & TDM (PHONG CÃCH Cá»°C CHáº¤T)
    -- ==============================================================================
    -- [ BAPE & ALAN WALKER ]
    1400569, -- BAPE MIX CAMO HOODIE
    1400650, -- BAPE MIX CAMO SHORTS
    1400651, -- BAPE STA MID
    1404000, -- BAPE City Camo Hoodie
    1404002, -- BAPE City Camo Pants
    1404003, -- BAPE Sta Mid
    1404048, -- Ão BAPE X PUBGM CAMO
    1404049, -- Ão Hoodie cÃ¡ máº­p BAPE X PUBGM CAMO
    1404050, -- Quáº§n BAPE X PUBGM CAMO
    1404051, -- GiÃ y BAPE X PUBGM CAMO
    1404016, -- Alan Walker T-shirt
    1404017, -- Alan Walker Hoodie
    1404042, -- Trang phá»¥c Alan Walker
    1404043, -- Ão Alan Walker
    1404044, -- Quáº§n Alan Walker
    1404045, -- GiÃ y Alan Walker
    1404340, -- Trang phá»¥c Alan Walker 2021
    1403038, -- Alan Walker Mask
    1403064, -- Kháº©u trang Alan Walker

    -- [ Äá»“ TDM Phá»• Biáº¿n (KhÄƒn bá»‹t máº·t, Ão LÃ­nh, Ão KhoÃ¡c Äen...) ]
    402001, -- KhÄƒn ráº±n sinh tá»“n
    402037, -- KhÄƒn quÃ ng cao bá»“i
    402043, -- KhÄƒn quÃ ng PUBG (Äá»-Äen)
    402045, -- KhÄƒn quÃ ng PUBG (Chiáº¿n thuáº­t)
    1400158, -- Máº·t Náº¡ Hockey
    1402005, -- Mysterious Leather Mask
    1403100, -- Máº·t náº¡ ngÆ°á»i leo nÃºi
    403010, -- Ão Ba Lá»— Báº©n (Tráº¯ng)
    403028, -- Ão Trench coat (MÃ u Ä‘en)
    403181, -- Ão lÃ­nh sa máº¡c
    403182, -- Ão Hoodie sÄƒn má»“i (Äen)
    403183, -- Ão Hoodie biá»‡t kÃ­ch (Tráº¯ng)
    403192, -- Ão khoÃ¡c bomber
    404006, -- Quáº§n Jeans (NÃ¢u)
    404008, -- Quáº§n lÃ­nh (Ka-ki)
    404013, -- Quáº§n lÃ­nh (Ráº±n ri)
    404015, -- Quáº§n Jeans BÃ³ (MÃ u Lam)
    404026, -- Quáº§n tÃºi há»™p (MÃ u be)
    404028, -- Quáº§n tÃºi há»™p (MÃ u Ä‘en)
    404084, -- Quáº§n thá»ƒ thao ngáº¯n (Äen)
    404100, -- Quáº§n ngÆ°á»i áº©n náº¥p (Äen)
    405001, -- GiÃ y Ä‘áº¿ má»m (MÃ u tráº¯ng)
    405002, -- GiÃ y thá»ƒ thao cá»• cao
    405019, -- GiÃ y lÃ­nh chim Æ°ng (Äen)
    405044, -- GiÃ y Ä‘áº¿ má»m (Äen)
    1400013, -- Quáº§n Jeans Má»¹

    -- [ CÃC ÃO Láºº VIP (Collab, SiÃªu Xe) ]
    1404142, -- Ão thun THE WALKING DEAD (Tráº¯ng)
    1404143, -- Ão thun THE WALKING DEAD (Äen)
    1404218, -- Ão Hoodie COVERNAT (Tráº¯ng)
    1404219, -- Ão Hoodie COVERNAT (Äen)
    1404326, -- Ão thun Xiaomi
    1404327, -- Ão thun OnePlus
    1404405, -- Ão Äáº¥u Há»£p TÃ¡c Messi Ã— PUBG MOBILE
    1404406, -- Ão Thun LÃ½ Tiá»ƒu Long
    1404411, -- Hoodie Ducati
    1404412, -- GiÃ y Ducati Corse City C2
    1404413, -- Quáº§n Ducati Sport C2
    1404414, -- Ão KhoÃ¡c Ducati Speed Evo C2
    1404426, -- Ão PMGC 2023
    1404427, -- Quáº§n NgÆ°á»i Chinh Phá»¥c Pagani
    1404428, -- GiÃ y NgÆ°á»i Chinh Phá»¥c Pagani
    1404508, -- Ão Hoodie Mr.Beast
    1400324, -- Ã¡o b
    1400325, -- Ã¡o a
    452001, 452002, 452003, -- GÄƒng Tay (Gloves)
    
        -- [ HÃ€NH Äá»˜NG ]
    12201301, -- HÃ nh Ä‘á»™ng SÃ¡t thá»§ Gothic
    12216101, -- HÃ nh Ä‘á»™ng VÃµ sÄ© Huyáº¿t Æ¯ng
    12212201, -- HÃ nh Ä‘á»™ng SÃ¡t thá»§ Cá»±c Ãm
    12219207, -- HÃ nh Ä‘á»™ng Äáº¡i tÆ°á»›ng ThiÃªn NgÆ°u
    12209001, -- HÃ nh Ä‘á»™ng VÃµ sÄ© (Samurai)
    12219561, -- HÃ nh Ä‘á»™ng Ão choÃ ng Äá» tháº«m
    12210001, -- HÃ nh Ä‘á»™ng CÃ¡i cháº¡m cá»§a Tá»­ tháº§n
    12219022, -- HÃ nh Ä‘á»™ng Thiáº¿t vá»‡ Gai gÃ³c
    12208801, -- HÃ nh Ä‘á»™ng @GRW_XD sÄ© BÃ¡n tháº§n
    12210801, -- HÃ nh Ä‘á»™ng Thá»£ sÄƒn Vá» báº¡c
    12200701, -- HÃ nh Ä‘á»™ng Du hÃ nh KhÃ´ng thá»i gian
    12219242, -- HÃ nh Ä‘á»™ng Dáº¡o bÆ°á»›c Báº§u trá»i
    12206001, -- HÃ nh Ä‘á»™ng Hoa linh Äá»“ng xanh
    12205401, -- HÃ nh Ä‘á»™ng Vua cá»§a muÃ´n thÃº
    12205201, -- HÃ nh Ä‘á»™ng TrÃ¡i tim Cá»± thÃº
    12212601, -- HÃ nh Ä‘á»™ng SÃ¡t lá»¥c Tháº§n bÃ­
    12205601, -- HÃ nh Ä‘á»™ng Linh há»“n Cá»± thÃº
    12219208, -- HÃ nh Ä‘á»™ng Háº§u vÆ°Æ¡ng Cyber
    12212001, -- HÃ nh Ä‘á»™ng VÃµ thÃ¡nh
    12206801, -- HÃ nh Ä‘á»™ng Háº£i long Tháº§n bÃ­
    12209801, -- HÃ nh Ä‘á»™ng Ngá»± linh sÆ°
    12211401, -- HÃ nh Ä‘á»™ng Ná»¯ phÃ¹ thá»§y BÄƒng tuyáº¿t
    12207001, -- HÃ nh Ä‘á»™ng Du hÃ nh Biá»ƒn sao
    12211801, -- HÃ nh Ä‘á»™ng ChÃºa tá»ƒ Tráº­t tá»±
    12207901, -- HÃ nh Ä‘á»™ng Háº£i vÆ°Æ¡ng Quyáº¿n rÅ©
    12203401, -- HÃ nh Ä‘á»™ng Ká»· niá»‡m áº¢o áº£nh
    12204001, -- HÃ nh Ä‘á»™ng ChÃº há» (NgÃ y CÃ¡ thÃ¡ng TÆ°)
    12201801, -- HÃ nh Ä‘á»™ng NgÆ°á»i báº£o vá»‡ VÃ¹ng tuyáº¿t
    12215601, -- HÃ nh Ä‘á»™ng SiÃªu nhÃ¢n Háº±ng tinh
    12215532, -- HÃ nh Ä‘á»™ng LÃ£nh chÃºa Ngá»n lá»­a
    12213201, -- HÃ nh Ä‘á»™ng Káº¿ hoáº¡ch NgÃ y mai
    12215529, -- HÃ nh Ä‘á»™ng Ká»µ sÄ© Äua xe
    12219053, -- HÃ nh Ä‘á»™ng Ná»¯ hoÃ ng TrÃ¢n báº£o
    12204601, -- HÃ nh Ä‘á»™ng ThiÃªn háº¡ Bá»‘ vÃµ
    12215701, -- HÃ nh Ä‘á»™ng HÃ nh tinh VÆ°á»£n ngÆ°á»i
    12219003, -- HÃ nh Ä‘á»™ng BÃ³ng tá»‘i Tháº§n linh
    12219004, -- HÃ nh Ä‘á»™ng NgÃ¢n há»“n Rá»±c lá»­a
    12219009, -- HÃ nh Ä‘á»™ng MÃª hoáº·c Rá»±c lá»­a
    12219216, -- HÃ nh Ä‘á»™ng Táº¿ tÆ° HÃ©o Ãºa
    
    
    -- tÃ³c máº·t tÃ¹m lum
    1404198, 1410085, 1404366, 1403137, 1410480, 1403028, 1400158, 40605011, 1404323, 1406001, 1403002,

-- ==============================================================================
    -- MÅ¨ GIÃP VIP (CHá»ˆ Láº¤Y Cáº¤P 1 - Gá»ŒN GÃ€NG, Dá»„ áº¨N Náº¤P)
    -- ==============================================================================
    1502001183, -- Godzilla Helmet (Lv. 1)
    1502001194, -- MÅ© MECHAGODZILLA (Cáº¥p 1)
    1502001093, -- MÅ© Tháº©m PhÃ¡n Anubis (Cáº¥p 1) - Pharaoh
    1502001305, -- MÅ© GiÃ¡p SiÃªu NhÃ¢n ThÃ©p (Cáº¥p 1)
    1502001320, -- MÅ© GiÃ¡p Biá»ƒu TÆ°á»£ng BÃ³ng ÄÃ¡ Messi (Cáº¥p 1)
    1502001105, -- MÅ© TÃ ng HÃ¬nh (Cáº¥p 1)
    1502001364, -- MÅ© GiÃ¡p PMGC 2023 (Cáº¥p 1)
    1502001373, -- MÅ© GiÃ¡p LINE FRIENDS BROWN (Cáº¥p 1)
    1502001402, -- APEACH Helmet (LV.1)
    1502001403, -- Bellygom Helmet (LV.1)
    1502001427, -- Opanchu Helmet (Lv.1)
    1502001443, -- MÅ© GiÃ¡p SÃ³ng Ã‚m Cuá»“ng Loáº¡n (Cáº¥p 1)
    1502001450, -- MÅ© GiÃ¡p CÃºn Tinh Nghá»‹ch (Cáº¥p 1)
    1502001471, -- Turbo Granny (Beckoning cat) Helmet (Lv. 1)
    1502001480, -- MÅ© GiÃ¡p PUBG MOBILE Ã— aespa (Cáº¥p 1)
    1502001490, -- Nakiri Ayame Helmet (Lv.1)
    1502001495, -- MÅ© BLUE LOCK (Cáº¥p 1)
    1502001001, -- MÅ© pizza nÃ³ng (Cáº¥p 1)
    1502001004, -- MÅ© Cyberpunk (TÃ­m) (Cáº¥p 1)
    1502001005, -- MÅ© há»™p sá» (Cáº¥p 1)
    1502001046, -- MÅ© Samurai - danh dá»± (Cáº¥p 1)
    1502001058, -- MÅ© báº£o hiá»ƒm Monarch (Cáº¥p 1)
    1502001064, -- MÅ© báº£o hiá»ƒm ThiÃªn Sá»© (Cáº¥p 1)
    1502001073, -- MÅ© Vá»‡ Binh Robot (Cáº¥p 1)
    1502001078, -- MÅ© Ninja SÃ¡t Thá»§ (Cáº¥p 1)
    1502001086, -- MÅ© Chuá»™t Tinh Nghá»‹ch (Cáº¥p 1)
    1502001099, -- MÅ© Corgi (Cáº¥p 1)
    1502001115, -- MÅ© Bá» RÃ¹a (Cáº¥p 1)
    1502001133, -- MÅ© BÃ­ NgÃ´ Kinh Dá»‹ (Cáº¥p 1)
    1502001145, -- MÅ© ChÃº LÃ­nh ChÃ¬ (Cáº¥p 1)
    1502001154, -- MÅ© GiÃ¡p Äáº¡i BÃ ng Tá»a SÃ¡ng (Cáº¥p 1)
    1502001175, -- MÅ© Vá»‹t VÃ ng B.Duck (Cáº¥p 1)
    1502001230, -- MÅ© Rá»“ng CÃ´ng Nghá»‡ (Cáº¥p 1)
    1502001248, -- MÅ© NgÆ°á»i Má»Ÿ ÄÆ°á»ng (Cáº¥p 1)
    1502001264, -- MÅ© Ã‰t Ã” Ã‰t (Cáº¥p 1)
    1502001276, -- MÅ© VÅ© CÃ´ng BÃ­ áº¨n (Cáº¥p 1)
    1502001294, -- MÅ© GiÃ¡p Ma PhÃ¡p SÆ° (Cáº¥p 1)
    1502001301, -- MÅ© GiÃ¡p Archon Lá»«ng Láº«y (Cáº¥p 1)
    1502001357, -- MÅ© GiÃ¡p Son Goku (Cáº¥p 1)
    1502001381, -- MÅ© GiÃ¡p Há»a Linh ChÃ­ TÃ´n (Cáº¥p 1)
    1502001416, -- MÅ© GiÃ¡p PMGC 2024 (Cáº¥p 1)
    1502001453, -- 2025 Esports Helmet (Lv. 1)

    -- ==============================================================================
    -- BA LÃ” VIP (CHá»ˆ Láº¤Y Cáº¤P 1 - Gá»ŒN GÃ€NG, Dá»„ áº¨N Náº¤P)
    -- ==============================================================================
    1501001174, -- Ba lÃ´ Pharaoh (Cáº¥p 1)
    1501001220, -- Ba lÃ´ Huyáº¿t Nha (Cáº¥p 1)
    1501001265, -- Ba lÃ´ Poseidon (Cáº¥p 1)
    1501001548, -- Balo Tháº§n Thoáº¡i Viá»…n Cá»• (Cáº¥p 1)
    1501001559, -- Balo Thanh Hoa XÃ  (Cáº¥p 1)
    1501001567, -- Ba LÃ´ Há»a Linh ChÃ­ TÃ´n (Cáº¥p 1)
    1501001577, -- Balo ÄÃ´i CÃ¡nh Vá»‡ Tháº§n (Cáº¥p 1)
    1501001607, -- Balo DÆ¡i BÃ³ng ÄÃªm (Cáº¥p 1)
    1501001061, -- Ba lÃ´ Godzilla (Cáº¥p 1)
    1501001062, -- Ba LÃ´ SiÃªu ThÃº Ghidorah (Cáº¥p 1)
    1501001082, -- Ba lÃ´ Genbu (Cáº¥p 1)
    1501001112, -- Ba lÃ´ Pig Ngá»‘c Ngháº¿ch (Cáº¥p 1)
    1501001133, -- Ba lÃ´ Joker KhÃ¡t MÃ¡u (Cáº¥p 1)
    1501001243, -- Ba LÃ´ Vá»‹t VÃ ng B.Duck (Cáº¥p 1)
    1501001273, -- Ba lÃ´ MECHAGODZILLA (Cáº¥p 1)
    1501001304, -- Ba lÃ´ Ma VÆ°Æ¡ng (Cáº¥p 1)
    1501001331, -- Ba lÃ´ cá»§a Jinx (Cáº¥p 1)
    1501001340, -- Ba LÃ´ Háº£i Cáº©u Tuyáº¿t (Cáº¥p 1)
    1501001376, -- Ba lÃ´ MÃ¡y HÃ¡t Cá»• Äiá»ƒn (Cáº¥p 1)
    1501001400, -- Ba lÃ´ Baby Shark (Cáº¥p 1)
    1501001463, -- Ba LÃ´ BoBoiBoy (Cáº¥p 1)
    1501001476, -- Ba LÃ´ Biá»ƒu TÆ°á»£ng BÃ³ng ÄÃ¡ Messi (Cáº¥p 1)
    1501001480, -- Ba LÃ´ MÃ¬ Indomie (Cáº¥p 1)
    1501001487, -- Ba LÃ´ Con Máº¯t Cháº¿t ChÃ³c (Cáº¥p 1)
    1501001521, -- Ba LÃ´ Quy LÃ£o Kame (Cáº¥p 1)
    1501001539, -- Ba LÃ´ PMGC 2023 (Cáº¥p 1)
    1501001540, -- Ba LÃ´ GÃ  RÃ¡n KFC (Cáº¥p 1)
    1501001554, -- Ba LÃ´ LINE FRIENDS SALLY (Cáº¥p 1)
    1501001587, -- Ba LÃ´ Äáº¡i Ãšy Loáº¡n Tháº¿ (Cáº¥p 1)
    1501001597, -- Bellygom Backpack (LV.1)
    1501001632, -- Opanchu Backpack (Lv.1)
    1501001643, -- Frieren&Mimic Backbag (Lv.1)
    1501001650, -- Ba LÃ´ Titan Khá»•ng Lá»“ Cáº¥p 1
    1501001683, -- Ba LÃ´ Balenciaga (Cáº¥p 1)
    1501001715, -- SAKAMOTO TARO Backpack (Lv.1)
    1501001720, -- Ba LÃ´ BLUE LOCK (Cáº¥p 1)
    
        -- [ BALO, MÅ¨ & DÃ™ LÆ¯á»¢N ]
    1501001024, -- Balo BÃ¡ TÆ°á»›c
    1502001014, -- MÅ© Äinh
    1502001439, -- mÅ© vÆ°Æ¡ng miá»‡n
    1502001069, -- mÅ© cÆ°Æ¡ng thi
    1502001023, -- mÅ© bÄƒng
    

    
    -- id bá»• xung
    1400092, 1400101, 1400122, --tÆ° lá»‡nh
    1404191, -- quáº§n bá»™ hÃ nh
    1405128, 1405129, 140224445, 140224445, -- crew
    1407961, 1407962, 1407963, 1407964, 1407965, 1407966, 1407967, 1407968, 1407969, 1407970, 1407971, 1502001508, 1502002508, 1502003508, 1411134, 1411133, 1411135, 1403771, 1403770, 1407994, 1407993, 1101006106, 1101006098, 4151145, 1903230, 1903231, 1903232, 1908117, 1908118, 1908119, 19116002, 19116003, 19116004, 1961070, 1961071, 1961072, 1961073, 1408045, 1408038, 1407990,1407922, -- Trang Phá»¥c Ná»¯ Tháº§n Ãi TÃ¬nh
    1407704, -- Trang Phá»¥c CÃ´ DÃ¢u Tinh QuÃ¡i
    1400782, -- Trang phá»¥c bÄƒng tuyáº¿t
    1407614, -- Trang Phá»¥c Optimus Prime Transformers
    1407276, -- Trang Phá»¥c Vá»‡ Tháº§n TÃ¬nh Ãi
    1410356, -- Máº·t Náº¡ Ma VÆ°Æ¡ng Huyáº¿t Há»“n
    40605012, -- TÃ³c Hai ChÃ¹m
    401035, -- MÅ© cao bá»“i (Tráº¯ng)
}

local INS_BASE = 2000000000
local PKG_SLOT = 3
local MELEE_ID = 108
local HAT_SUB = 401
local MASK_SUB = 402
local OUTFIT_SUB = 403
local PANTS_SUB = 404
local SHOES_SUB = 405
local GLASS_SUB = 407
local GLIDER_SUB = 415      
local GLOVES_SUB = 452
local GLIDER_SUBS = { [413] = true, [414] = true, [415] = true }

F.CUST_SLOT = {
    NONE = 0,
    HeadEquipemtSlot = 1,
    HairEquipemtSlot = 2,
    HatEquipemtSlot = 3,
    FaceEquipemtSlot = 4,
    ClothesEquipemtSlot = 5,
    PantsEquipemtSlot = 6,
    ShoesEquipemtSlot = 7,
    BackpackEquipemtSlot = 8,
    HelmetEquipemtSlot = 9,
    ArmorEquipemtSlot = 10,
    ParachuteEquipemtSlot = 11,
    GlassEquipemtSlot = 12,
    NightVisionEquipemtSlot = 13,
    BeardEquipemtSlot = 14,
    GlideEquipemtSlot = 15,
    HandEffectEquipemtSlot = 16,
    BackPack_PendantSlot = 17,
}
_G.CustSlotType = F.CUST_SLOT

local CHASSIS_LIGHT_SUB = 7302
local CHASSIS_LIGHT_IDS = { [7302001] = true, [7302002] = true }
local DEFAULT_CHASSIS_LIGHT = 7302002
local PARACHUTE_SUB = 701   
local DEFAULT_PARACHUTE_RES = 703001  
local TAB_SUIT = 10
local TAB_CLOTHES = 3
local PAGE_AVATAR = 1
local PAGE_VEHICLE = 6
local PAGE_PARACHUTE = 5
local HALL_THEME_TYPE = 202
local SUBTYPE_DEFAULT_TAB = {
    [401] = 1, [402] = 2, [403] = 10, [404] = 4, [405] = 5, [407] = 14,
    [501] = 15, [504] = 15, [502] = 16, [505] = 16,
}
local HAT_SUBS = { [401] = true }
local HELMET_SUBS = { [502] = true, [505] = true }
local HEAD_SUBS = { [401] = true } -- [FIX VIP] ÄÃ£ xÃ³a 502 vÃ  505 Ä‘á»ƒ tÃ¡ch biá»‡t hoÃ n toÃ n MÅ© Báº£o Hiá»ƒm khá»i TÃ³c/MÅ© Thá»i Trang
local BAG_SUBS = { [501] = true, [504] = true }
local FACE_SUBS = { [402] = true, [407] = true }
local BODY_SUBS = { [404] = true, [405] = true, [501] = true, [504] = true, [502] = true, [505] = true }
local GUN_SUB = { [101]=true, [102]=true, [103]=true, [104]=true, [105]=true, [106]=true, [107]=true }
local NET_OK = NetErrorCode_NONE or "ok"

local R = { insToRes = {}, resToIns = {}, byWeapon = {} }
local _matchApplied = false

_G.AddOutfitPersist = _G.AddOutfitPersist or { path = nil, dirty = false, scheduled = false, loaded = nil, lastWritten = nil, configVehicleSlots = nil, configWeapons = nil, configSlots = nil, lobbyVehicleSubType = nil, lobbyVehicleIns = nil, lobbyVehicleResID = nil, hallThemeResID = nil, hallThemeIns = nil, configChassisLight = nil, configChassisLightMap = nil }
local PERSIST = _G.AddOutfitPersist

F.persistMarkDirty = function() end

local PERF = {
    lobbySynced     = false,
    mappingsDirty   = true,
    desiredSkins    = nil,
    skinTarget      = {},
    matchActive     = false,
    lastBootstrapAt = 0,
    wearDoneThisMatch = false,  
}
local MATCH_TICK_SEC    = 3.0
local MATCH_MAX_SEC     = 45.0
local BOOTSTRAP_COOLDOWN = 2.0
local INJECT_RETRY_MAX  = 5
local INJECT_RETRY_SEC  = 3.0

function F.lobbyState()
    _G.AddOutfitLobbyState = _G.AddOutfitLobbyState or {
        wardrobeRefreshed = false,
        reapplyScheduled  = false,
        reapplyDone       = false,
        outfitResolved    = false,
        skinResolved      = false,
        cachedOutfit      = nil,
        cachedSkin        = nil,
        injectRefreshGen  = 0,
        lobbySynced       = false,
    }
    return _G.AddOutfitLobbyState
end

local LOBBY = setmetatable({}, {
    __index = function(_, k) return F.lobbyState()[k] end,
    __newindex = function(_, k, v) F.lobbyState()[k] = v end,
})

function F.invalidateLobbyResolved()
    LOBBY.outfitResolved = false
    LOBBY.skinResolved   = false
    LOBBY.cachedOutfit   = nil
    LOBBY.cachedSkin     = nil
end

function F.perfInvalidateLobby()
    LOBBY.lobbySynced   = false
    PERF.mappingsDirty = true
    PERF.desiredSkins  = nil
    for k in pairs(PERF.skinTarget) do PERF.skinTarget[k] = nil end
    F.invalidateLobbyResolved()
end

function F.cache()
    _G.AddOutfitEquippedCache = _G.AddOutfitEquippedCache or {
        outfitRes = nil, outfitIns = nil,
        hatRes = nil, hatIns = nil,
        maskRes = nil, maskIns = nil,
        glassRes = nil, glassIns = nil,
        tshirtRes = nil, tshirtIns = nil,
        pantsRes = nil, pantsIns = nil,
        shoesRes = nil, shoesIns = nil,
        bagRes = nil, bagIns = nil,
        helmetRes = nil, helmetIns = nil,
        weapons = {},
        vehicleSlots = {},  
        hallThemeRes = nil, hallThemeIns = nil,
        parachuteRes = nil, parachuteIns = nil,
        gliderRes = nil, gliderIns = nil,
        glovesRes = nil, glovesIns = nil,
    }
    return _G.AddOutfitEquippedCache
end

function F.cfg(resID)
    if not resID or not CDataTable or not CDataTable.GetTableData then return nil end
    return CDataTable.GetTableData("Item", resID)
end

function F.subType(c)
    return c and (c.ItemSubType or c.itemSubType) or nil
end

function F.wardrobeTab(resID)
    local c = F.cfg(resID)
    return c and tonumber(c.WardrobeTab) or 0
end

function F.depotResID(v)
    return v and tonumber(v.resID or v.res_id) or nil
end

function F.resToCustSlot(resID, st)
    resID, st = tonumber(resID), tonumber(st)
    if not resID or resID <= 0 then return nil end
    st = st or F.subType(F.cfg(resID))
    if st == HAT_SUB or HAT_SUBS[st] then return F.CUST_SLOT.HatEquipemtSlot end
    if st == OUTFIT_SUB then return F.CUST_SLOT.ClothesEquipemtSlot end
    if st == PANTS_SUB then return F.CUST_SLOT.PantsEquipemtSlot end
    if st == SHOES_SUB then return F.CUST_SLOT.ShoesEquipemtSlot end
    if st == MASK_SUB then return F.CUST_SLOT.FaceEquipemtSlot end
    if st == GLASS_SUB then return F.CUST_SLOT.GlassEquipemtSlot end
    if st == GLOVES_SUB then return F.CUST_SLOT.HandEffectEquipemtSlot end
    if BAG_SUBS[st] then return F.CUST_SLOT.BackpackEquipemtSlot end
    if HELMET_SUBS[st] then return F.CUST_SLOT.HelmetEquipemtSlot end
    if F.isParachuteRes(resID) or st == PARACHUTE_SUB then return F.CUST_SLOT.ParachuteEquipemtSlot end
    if F.isGlideRes(resID) or GLIDER_SUBS[st] then return F.CUST_SLOT.GlideEquipemtSlot end
    return nil
end

function F.isSuitRes(resID)
    if F.subType(F.cfg(resID)) ~= OUTFIT_SUB then return false end
    return F.wardrobeTab(resID) ~= TAB_CLOTHES
end

function F.isTshirtRes(resID)
    return F.subType(F.cfg(resID)) == OUTFIT_SUB and F.wardrobeTab(resID) == TAB_CLOTHES
end

function F.weaponIdFromSkin(resID)
    local m = CDataTable and CDataTable.GetTableData and CDataTable.GetTableData("WeaponSkinMapping", resID)
    if not m then return nil end
    return m.WeaponID or m.WeaponId
end

function F.isValidWeaponId(weaponID)
    weaponID = tonumber(weaponID)
    if not weaponID or weaponID <= 0 then return false end
    if weaponID == MELEE_ID then return true end
    return weaponID >= 101000 and weaponID < 108000
end

function F.isValidWeaponPersistEntry(weaponID, resID)
    weaponID, resID = tonumber(weaponID), tonumber(resID)
    if not F.isValidWeaponId(weaponID) or not resID or resID <= 0 then return false end
    if weaponID == resID then return false end
    if resID >= 1800000 and resID < 1810000 then return false end
    if resID >= 1900000 and resID < 2000000 then return false end
    if F.isInjectedRes(resID) then
        local wid = tonumber(F.weaponIdFromSkin(resID))
        return wid and wid == weaponID
    end
    local wid = tonumber(F.weaponIdFromSkin(resID))
    return wid and wid == weaponID
end

function F.sanitizeConfigWeapons(wmap)
    if type(wmap) ~= "table" then return {} end
    local clean = {}
    for wid, res in pairs(wmap) do
        wid, res = tonumber(wid), tonumber(res)
        if F.isValidWeaponPersistEntry(wid, res) then clean[wid] = res end
    end
    return clean
end

function F.indexWeaponSkin(resID, insID)
    resID, insID = tonumber(resID), tonumber(insID)
    if not resID or not insID then return end
    local c = F.cfg(resID)
    local st = F.subType(c)
    if not (GUN_SUB[st] or st == MELEE_ID) then return end
    local wid = F.weaponIdFromSkin(resID)
    wid = tonumber(wid)
    if not wid or wid <= 0 then return end
    R.byWeapon[wid] = R.byWeapon[wid] or {}
    R.byWeapon[wid][resID] = insID
end

function F.isInjectedIns(ins)
    return ins and R.insToRes[tonumber(ins)] ~= nil
end

function F.isInjectedRes(res)
    return res and R.resToIns[tonumber(res)] ~= nil
end

function F.isWeaponSkinRes(resID)
    resID = tonumber(resID)
    if not resID then return false end
    local st = F.subType(F.cfg(resID))
    return GUN_SUB[st] or st == MELEE_ID
end

function F.isWeaponSkinIns(insID)
    insID = tonumber(insID)
    if not insID then return false end
    local res = R.insToRes[insID]
    return res and F.isWeaponSkinRes(res)
end

function F.cleanArmoryPollution()
    pcall(function()
        local Arm = require("client.logic.armory.logic_armory")
        if not Arm.rsp_list then return end
        if Arm.rsp_list.install_list then
            for wid, entry in pairs(Arm.rsp_list.install_list) do
                local ins = tonumber(entry and entry.skin_id)
                if ins and not F.isWeaponSkinIns(ins) then
                    Arm.rsp_list.install_list[wid] = nil
                end
            end
        end
        if Arm.rsp_list.skin_list then
            for wid, skins in pairs(Arm.rsp_list.skin_list) do
                if type(skins) == "table" then
                    for resID in pairs(skins) do
                        if not F.isWeaponSkinRes(tonumber(resID)) then
                            skins[resID] = nil
                        end
                    end
                end
            end
        end
    end)
end

function F.depotSubType(insID, resID)
    resID = tonumber(resID) or tonumber(R.insToRes[insID])
    local st = F.subType(F.cfg(resID))
    if st then return st end
    local wd = require("client.slua.logic.wardrobe.wardrobe_data")
    local d = wd:GetHallDepotItemDataByInsID(insID)
    return d and tonumber(d.itemSubType)
end

function F.tryLocalWearByIns(insID)
    insID = tonumber(insID)
    if not insID then return false end
    if _G.LexusConfig and _G.LexusConfig.ModSkin == false then return false end -- Bá» qua náº¿u táº¯t Mod Skin
    local resID = R.insToRes[insID]
    local wd = require("client.slua.logic.wardrobe.wardrobe_data")
    local d = wd:GetHallDepotItemDataByInsID(insID)
    if not resID and d then resID = tonumber(d.resID or d.res_id) end
    if not resID or resID <= 0 then return false end
    local st = F.depotSubType(insID, resID)

    local function mapLocal()
        if not R.insToRes[insID] then
            R.insToRes[insID] = resID
            R.resToIns[resID] = insID
        end
    end

    if st == GLOVES_SUB then mapLocal(); F.putOnGloves(insID) return true end
    F.clearItemExpire(d, insID, resID)
    F.ensureDepotItemValid(insID, resID)
    if F.isParachuteRes(resID) then mapLocal(); return F.putOnParachute(insID) end
    if F.isGlideRes(resID) or GLIDER_SUBS[st] then mapLocal(); return F.putOnGlider(insID) end

    if st == OUTFIT_SUB then
        mapLocal()
        if F.isSuitRes(resID) or F.wardrobeTab(resID) == TAB_SUIT then
            F.putOnOutfit(insID)
        else
            F.putOnRoleWear(insID)
        end
        return true
    end
    if st == HAT_SUB or HEAD_SUBS[st] then mapLocal(); F.putOnHat(insID) return true end
    if FACE_SUBS[st] then mapLocal(); F.putOnFaceAccessory(insID) return true end
    if BODY_SUBS[st] or HELMET_SUBS[st] then mapLocal(); F.putOnRoleWear(insID) return true end

    if not F.isInjectedIns(insID) then return false end
    if GUN_SUB[st] then
        local wid = F.weaponIdFromSkin(resID)
        if wid then F.equipWeaponSkin(wid, insID) end
        return true
    end
    if st == MELEE_ID then F.equipWeaponSkin(MELEE_ID, insID) return true end
    if F.isHallThemeRes(resID) and (F.isInjectedIns(insID) or F.isInjectedRes(resID)) then
        mapLocal()
        return F.putOnHallTheme(insID)
    end
    if F.isVehicleRes(resID) and (F.isInjectedIns(insID) or F.isInjectedRes(resID)) then
        mapLocal()
        return F.putOnVehicle(insID)
    end
    return false
end

function F.isHallThemeRes(resID)
    local c = F.cfg(tonumber(resID))
    if not c then return false end
    local t = c.ItemType or c.itemType
    return t == HALL_THEME_TYPE
end

function F.isResourcesReady(resID)
    resID = tonumber(resID)
    if not resID or resID <= 0 then return false end
    if not F.isInjectedRes(resID) then return true end
    local ready = false
    pcall(function()
        local PufferConst = require("client.slua.logic.download.puffer_const")
        local mgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
        if mgr and mgr.GetStateByItemID then
            local st = mgr:GetStateByItemID(resID)
            ready = st == PufferConst.ENUM_DownloadState.Done
        end
    end)
    return ready
end

function F.requestResourceDownload(resID)
    resID = tonumber(resID)
    if not resID or resID <= 0 or not F.isInjectedRes(resID) then return end
    if F.isResourcesReady(resID) then return end
    _G.AddOutfitDownloadQueued = _G.AddOutfitDownloadQueued or {}
    if _G.AddOutfitDownloadQueued[resID] then return end
    _G.AddOutfitDownloadQueued[resID] = true
    pcall(function()
        local PM = require("client.slua.logic.download.puffer.puffer_manager")
        local PufferConst = require("client.slua.logic.download.puffer_const")
        PM.Download(PufferConst.ENUM_DownloadType.ODPAK, { resID }, "AddOutfit", function()
            _G.AddOutfitDownloadQueued[resID] = nil
        end)
    end)
end

function F.ensureInjectedResources()
    for res in pairs(R.resToIns) do
        F.requestResourceDownload(tonumber(res))
    end
end

function F.restorePufferHooks()
    pcall(function()
        local mgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
        if mgr and _G.AddOutfitPufferOrig then
            mgr.GetStateByItemID = _G.AddOutfitPufferOrig
        end
    end)
    pcall(function()
        local PM = require("client.slua.logic.download.puffer.puffer_manager")
        if PM and _G.AddOutfitPufferGetStateOrig then
            PM.GetState = _G.AddOutfitPufferGetStateOrig
        end
    end)
    pcall(function()
        local VAC = require("GameLua.GameCore.Module.Vehicle.Component.VehicleAvatarComponent")
        local vacImpl = VAC and VAC.__inner_impl
        if vacImpl and _G.AddOutfitVehOrigAssets then
            vacImpl.LuaIsAssetsAlreadyAvailable = _G.AddOutfitVehOrigAssets
        end
    end)
end

function F.invalidateSocialWearCache()
    local s = _G.AddOutfitSocialState
    if s then
        s.wearPatchKey, s.snapshotKey, s.fullSnapshot, s.lastHandSkin = nil, nil, nil, nil
    end
end

function F.clearWeaponEquippedMark(weaponID)
    _G.AddOutfitWeaponEquipped = _G.AddOutfitWeaponEquipped or {}
    if weaponID then
        _G.AddOutfitWeaponEquipped[tonumber(weaponID)] = nil
    else
        for k in pairs(_G.AddOutfitWeaponEquipped) do _G.AddOutfitWeaponEquipped[k] = nil end
    end
end

function F.isWeaponVisuallyEquipped(weaponID, insID)
    weaponID, insID = tonumber(weaponID), tonumber(insID)
    if not weaponID or not insID then return false end
    return _G.AddOutfitWeaponEquipped and _G.AddOutfitWeaponEquipped[weaponID] == insID
end

function F.saveWeaponToCache(weaponID, resID, insID)
    F.clearWeaponEquippedMark(weaponID)
    weaponID, resID, insID = tonumber(weaponID), tonumber(resID), tonumber(insID)
    if not F.isValidWeaponPersistEntry(weaponID, resID) then return end
    local cch = F.cache()
    cch.weapons[weaponID] = { resID = resID, insID = insID or 0 }
    PERSIST.configWeapons = PERSIST.configWeapons or {}
    PERSIST.configWeapons[weaponID] = resID
    _G.AddOutfitLastAppliedSkin = {}
    _matchApplied = false
    F.perfInvalidateLobby()
    F.invalidateSocialWearCache()
    F.persistMarkDirty()
    F.log("Ø°Ø§ÙƒØ±Ø© Ø³ÙƒÙ†", weaponID, "â†’", resID)
end

function F.cacheWeaponSkinFromIns(weaponID, insID)
    weaponID, insID = tonumber(weaponID), tonumber(insID)
    if not weaponID or not insID or insID <= 0 then return end
    if F.isInjectedIns(insID) then
        F.saveWeaponToCache(weaponID, R.insToRes[insID], insID)
        return
    end
    pcall(function()
        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
        local d = wd:GetValidHallDepotItemDataByInsID(insID) or wd:GetHallDepotItemDataByInsID(insID)
        if d and d.resID and tonumber(d.resID) > 0 then
            F.saveWeaponToCache(weaponID, tonumber(d.resID), insID)
        end
    end)
end

function F.saveEquip(resID, insID)
    resID, insID = tonumber(resID), tonumber(insID)
    if not resID or not insID then return end
    local c = F.cfg(resID)
    local st = F.subType(c)
    local cch = F.cache()
    if st == OUTFIT_SUB then
        if F.wardrobeTab(resID) == TAB_CLOTHES then
            cch.tshirtRes, cch.tshirtIns = resID, insID
            _G.AddOutfitLastLobbyTshirtRes = resID
            F.persistRememberSlot("tshirt", resID)
        else
            cch.outfitRes, cch.outfitIns = resID, insID
            _G.AddOutfitLastLobbyOutfitRes = resID
            F.persistRememberSlot("outfit", resID)
            F.invalidateSocialWearCache()
        end
    elseif st == HAT_SUB then
        cch.hatRes, cch.hatIns = resID, insID
        _G.AddOutfitLastLobbyHatRes = resID
        F.persistRememberSlot("hat", resID)
    elseif st == MASK_SUB then
        cch.maskRes, cch.maskIns = resID, insID
        _G.AddOutfitLastLobbyMaskRes = resID
        F.persistRememberSlot("mask", resID)
    elseif st == GLASS_SUB then
        cch.glassRes, cch.glassIns = resID, insID
        _G.AddOutfitLastLobbyGlassRes = resID
        F.persistRememberSlot("glass", resID)
    elseif st == PANTS_SUB then
        cch.pantsRes, cch.pantsIns = resID, insID
        _G.AddOutfitLastLobbyPantsRes = resID
        F.persistRememberSlot("pants", resID)
    elseif st == SHOES_SUB then
        cch.shoesRes, cch.shoesIns = resID, insID
        _G.AddOutfitLastLobbyShoesRes = resID
        F.persistRememberSlot("shoes", resID)
    elseif BAG_SUBS[st] then
        cch.bagRes, cch.bagIns = resID, insID
        _G.AddOutfitLastLobbyBagRes = resID
        F.persistRememberSlot("bag", resID)
    elseif HELMET_SUBS[st] then
        cch.helmetRes, cch.helmetIns = resID, insID
        _G.AddOutfitLastLobbyHelmetRes = resID
        F.persistRememberSlot("helmet", resID)
    elseif st == PARACHUTE_SUB then
        cch.parachuteRes, cch.parachuteIns = resID, insID
        _G.AddOutfitLastLobbyParachuteRes = resID
        F.persistRememberSlot("parachute", resID)
    elseif F.isGlideRes(resID) then
        cch.gliderRes, cch.gliderIns = resID, insID
        _G.AddOutfitLastLobbyGliderRes = resID
        F.persistRememberSlot("glider", resID)
    elseif st == GLOVES_SUB then
        cch.glovesRes, cch.glovesIns = resID, insID
        _G.AddOutfitLastLobbyGlovesRes = resID
        F.persistRememberSlot("gloves", resID)
    elseif GUN_SUB[st] then
        local wid = F.weaponIdFromSkin(resID)
        if wid then F.saveWeaponToCache(wid, resID, insID) end
    elseif st == MELEE_ID then
        F.saveWeaponToCache(MELEE_ID, resID, insID)
    end
    _matchApplied = false
    F.perfInvalidateLobby()
    F.persistMarkDirty()
end

function F.findWornInsBySubType(st, filterFn)
    st = tonumber(st)
    if not st then return nil end
    local wd = require("client.slua.logic.wardrobe.wardrobe_data")
    local AvatarData = require("client.logic.data.AvatarData")
    for _, ins in pairs(AvatarData.GetRoleWear()) do
        ins = tonumber(ins)
        if ins and ins > 0 then
            local d = wd:GetHallDepotItemDataByInsID(ins)
            if d and tonumber(d.itemSubType) == st then
                local res = tonumber(d.resID)
                if not filterFn or filterFn(res, d) then
                    return ins, res
                end
            end
        end
    end
    return nil
end

function F.syncHatCacheFromLobby()
    local cch = F.cache()
    pcall(function()
        local ins, res = F.findWornInsBySubType(HAT_SUB)
        if ins and res and tonumber(res) > 0 then
            cch.hatRes, cch.hatIns = tonumber(res), ins
            return
        end
        local fbd = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
        local bag = fbd.GetCurrentFashionBag and fbd:GetCurrentFashionBag()
        local headIns = tonumber(bag and bag.head_show) or 0
        if headIns <= 0 then return end
        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
        local d = wd:GetValidHallDepotItemDataByInsID(headIns) or wd:GetHallDepotItemDataByInsID(headIns)
        if not d or not d.resID or tonumber(d.resID) <= 0 then return end
        local st = tonumber(d.itemSubType or F.subType(F.cfg(d.resID)))
        if HEAD_SUBS[st] then
            cch.hatRes, cch.hatIns = tonumber(d.resID), headIns
        end
    end)
end

function F.syncFaceCacheFromLobby()
    local cch = F.cache()
    pcall(function()
        local ins, res = F.findWornInsBySubType(MASK_SUB)
        if ins and res and tonumber(res) > 0 then
            cch.maskRes, cch.maskIns = tonumber(res), ins
            _G.AddOutfitLastLobbyMaskRes = tonumber(res)
        end
    end)
    pcall(function()
        local ins, res = F.findWornInsBySubType(GLASS_SUB)
        if ins and res and tonumber(res) > 0 then
            cch.glassRes, cch.glassIns = tonumber(res), ins
            _G.AddOutfitLastLobbyGlassRes = tonumber(res)
        end
    end)
end

function F.syncBodyCacheFromLobby()
    local cch = F.cache()
    pcall(function()
        local ins, res = F.findWornInsBySubType(OUTFIT_SUB, function(r) return F.wardrobeTab(r) == TAB_CLOTHES end)
        if ins and res and tonumber(res) > 0 then
            cch.tshirtRes, cch.tshirtIns = tonumber(res), ins
            _G.AddOutfitLastLobbyTshirtRes = tonumber(res)
        end
    end)
    pcall(function()
        local ins, res = F.findWornInsBySubType(PANTS_SUB)
        if ins and res and tonumber(res) > 0 then
            cch.pantsRes, cch.pantsIns = tonumber(res), ins
            _G.AddOutfitLastLobbyPantsRes = tonumber(res)
        end
    end)
    pcall(function()
        local ins, res = F.findWornInsBySubType(SHOES_SUB)
        if ins and res and tonumber(res) > 0 then
            cch.shoesRes, cch.shoesIns = tonumber(res), ins
            _G.AddOutfitLastLobbyShoesRes = tonumber(res)
        end
    end)
    pcall(function()
        local ins, res = F.findWornInsBySubType(GLOVES_SUB)
        if ins and res and tonumber(res) > 0 then
            cch.glovesRes, cch.glovesIns = tonumber(res), ins
            _G.AddOutfitLastLobbyGlovesRes = tonumber(res)
        end
    end)
    pcall(function()
        for st in pairs(BAG_SUBS) do
            local ins, res = F.findWornInsBySubType(st)
            if ins and res and tonumber(res) > 0 then
                cch.bagRes, cch.bagIns = tonumber(res), ins
                _G.AddOutfitLastLobbyBagRes = tonumber(res)
                break
            end
        end
    end)
    pcall(function()
        for st in pairs(HELMET_SUBS) do
            local ins, res = F.findWornInsBySubType(st)
            if ins and res and tonumber(res) > 0 then
                cch.helmetRes, cch.helmetIns = tonumber(res), ins
                _G.AddOutfitLastLobbyHelmetRes = tonumber(res)
                break
            end
        end
    end)
    pcall(function()
        local ins, res = F.findWornInsBySubType(OUTFIT_SUB, function(r) return F.isSuitRes(r) end)
        if ins and res and tonumber(res) > 0 then
            cch.outfitRes, cch.outfitIns = tonumber(res), ins
            _G.AddOutfitLastLobbyOutfitRes = tonumber(res)
        end
    end)
end

function F.syncAirborneCacheFromLobby(saveToConfig)
    local cch = F.cache()
    local cfgPara = tonumber(PERSIST.configSlots and PERSIST.configSlots.parachute)
    local cfgGlide = tonumber(PERSIST.configSlots and PERSIST.configSlots.glider)
    local changed = false

    local function maybeSave(slotName, res)
        if not saveToConfig or not res or res <= 0 then return end
        if slotName == "parachute" and res == DEFAULT_PARACHUTE_RES
            and cfgPara and cfgPara > 0 and cfgPara ~= DEFAULT_PARACHUTE_RES then
            return
        end
        F.persistRememberSlot(slotName, res)
        changed = true
    end

    local function applyPara(res, ins)
        res, ins = tonumber(res), tonumber(ins)
        if not res or not ins or not F.isParachuteRes(res) then return end
        if cfgPara and cfgPara > 0 and not saveToConfig then
            if res == cfgPara then cch.parachuteIns = ins end
            return
        end
        if res == DEFAULT_PARACHUTE_RES and not saveToConfig then return end
        if cch.parachuteRes ~= res or cch.parachuteIns ~= ins then
            cch.parachuteRes, cch.parachuteIns = res, ins
            _G.AddOutfitLastLobbyParachuteRes = res
            maybeSave("parachute", res)
        end
    end

    local function applyGlide(res, ins)
        res, ins = tonumber(res), tonumber(ins)
        if not res or not ins or not F.isGlideRes(res) then return end
        if cfgGlide and cfgGlide > 0 and not saveToConfig then
            if res == cfgGlide then cch.gliderIns = ins end
            return
        end
        if cch.gliderRes ~= res or cch.gliderIns ~= ins then
            cch.gliderRes, cch.gliderIns = res, ins
            _G.AddOutfitLastLobbyGliderRes = res
            maybeSave("glider", res)
        end
    end

    pcall(function()
        local fbd = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
        local paraIns = tonumber(fbd.GetParachute and fbd:GetParachute()) or 0
        if paraIns > 0 then
            local d = wd:GetValidHallDepotItemDataByInsID(paraIns) or wd:GetHallDepotItemDataByInsID(paraIns)
            applyPara(d and tonumber(d.resID), paraIns)
        end
        local glideIns = tonumber(fbd.GetAircraftOrGliding and fbd:GetAircraftOrGliding()) or 0
        if glideIns > 0 then
            local d = wd:GetValidHallDepotItemDataByInsID(glideIns) or wd:GetHallDepotItemDataByInsID(glideIns)
            applyGlide(d and tonumber(d.resID), glideIns)
        end
    end)
    pcall(function()
        for st in pairs(GLIDER_SUBS) do
            local ins, res = F.findWornInsBySubType(st)
            if ins and res then applyGlide(res, ins) break end
        end
        local ins, res = F.findWornInsBySubType(PARACHUTE_SUB)
        if ins and res then applyPara(res, ins) end
    end)
    if changed then F.persistMarkDirty() end
end

function F.syncWeaponCacheFromLobby(force)
    if LOBBY.lobbySynced and not force then return end
    LOBBY.lobbySynced = true
    PERF.mappingsDirty = true
    PERF.desiredSkins = nil
    for k in pairs(PERF.skinTarget) do PERF.skinTarget[k] = nil end
    local cch = F.cache()
    pcall(function()
        local fbd = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
        local bag = fbd.GetCurrentFashionBag and fbd:GetCurrentFashionBag()
        if bag and bag.weapon_skin_list then
            for weaponID, entry in pairs(bag.weapon_skin_list) do
                weaponID = tonumber(weaponID)
                local insID = tonumber(entry and (entry.skin_id or entry.skinId)) or 0
                if weaponID and weaponID > 0 and insID > 0 then
                    local res
                    if F.isInjectedIns(insID) then
                        res = tonumber(R.insToRes[insID])
                    else
                        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
                        local d = wd:GetValidHallDepotItemDataByInsID(insID)
                            or wd:GetHallDepotItemDataByInsID(insID)
                        res = d and tonumber(d.resID)
                    end
                    if res and res > 0 and F.isValidWeaponPersistEntry(weaponID, res) then
                        cch.weapons[weaponID] = { resID = res, insID = insID }
                    end
                end
            end
        end
    end)
    pcall(function()
        local Arm = require("client.logic.armory.logic_armory")
        if Arm.rsp_list and Arm.rsp_list.install_list then
            for weaponID, entry in pairs(Arm.rsp_list.install_list) do
                weaponID = tonumber(weaponID)
                local insID = tonumber(entry and entry.skin_id) or 0
                if weaponID and weaponID > 0 and insID > 0 then
                    local res
                    if F.isInjectedIns(insID) then
                        res = tonumber(R.insToRes[insID])
                    else
                        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
                        local d = wd:GetValidHallDepotItemDataByInsID(insID)
                            or wd:GetHallDepotItemDataByInsID(insID)
                        res = d and tonumber(d.resID)
                    end
                    if res and res > 0 and F.isValidWeaponPersistEntry(weaponID, res) then
                        cch.weapons[weaponID] = { resID = res, insID = insID }
                    end
                end
            end
        end
    end)
    F.syncHatCacheFromLobby()
    F.syncFaceCacheFromLobby()
    F.syncBodyCacheFromLobby()
end

function F.getCachedWeaponSkin(weaponID)
    weaponID = tonumber(weaponID) or 0
    if weaponID <= 0 then return nil end
    F.syncWeaponCacheFromLobby()
    local w = F.cache().weapons[weaponID]
    if w and w.resID and w.resID > 0 then return w.resID end
    return nil
end

function F.getMatchWeaponSkin(weaponID)
    weaponID = tonumber(weaponID) or 0
    local fromCache = F.getCachedWeaponSkin(weaponID)
    if fromCache then return fromCache end
    if MATCH_CONFIG.weaponSkins then
        local fixed = tonumber(MATCH_CONFIG.weaponSkins[weaponID])
        if fixed and fixed > 0 then return fixed end
    end
    return nil
end

function F.removeRoleWearBySubType(st, filterFn)
    st = tonumber(st)
    if not st then return end
    local wd = require("client.slua.logic.wardrobe.wardrobe_data")
    local AvatarData = require("client.logic.data.AvatarData")
    for _, ins in pairs(AvatarData.GetRoleWear()) do
        ins = tonumber(ins)
        if ins and ins > 0 then
            local d = wd:GetHallDepotItemDataByInsID(ins)
            if d and tonumber(d.itemSubType) == st then
                local res = tonumber(d.resID)
                if not filterFn or filterFn(res, d) then
                    AvatarData.RemoveRoleWearDataByValue(ins)
                end
            end
        end
    end
end

function F.syncFashionBagRolewear()
    pcall(function()
        local fbd = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
        fbd:SaveRolewearToFashionBag(fbd:GetFashionBagUseIndex())
    end)
end

local _ticker
pcall(function() _ticker = require("common.time_ticker") end)
function F.later(sec, fn)
    if _G.SetTimer then pcall(_G.SetTimer, sec, fn) return end
    if _ticker and _ticker.AddTimer then pcall(_ticker.AddTimer, sec, fn) end
end

function F.getPC()
    if slua_GameFrontendHUD then
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then return pc end
    end
    local ok, gd = pcall(require, "GameLua.GameCore.Data.GameplayData")
    if ok and gd then
        local pc = gd.GetPlayerController()
        if slua.isValid(pc) then return pc end
    end
    return nil
end

function F.syncVehicleSlotsToDataMgr()
    local cch = F.cache()
    DataMgr.VehicleSlotList = DataMgr.VehicleSlotList or {}
    for subType, slots in pairs(cch.vehicleSlots or {}) do
        local arr = DataMgr.VehicleSlotList[subType]
        if not arr then arr = {}; DataMgr.VehicleSlotList[subType] = arr end
        for k in pairs(arr) do arr[k] = nil end
        for idx, e in pairs(slots or {}) do
            if e and tonumber(e.insID) and tonumber(e.insID) > 0 then
                arr[tonumber(idx)] = tonumber(e.insID)
            end
        end
    end
end

function F.mergeInjectedIntoVehicleSlotList(serverList)
    serverList = serverList or {}
    local cch = F.cache()
    for subType, slots in pairs(cch.vehicleSlots or {}) do
        subType = tonumber(subType)
        if subType and type(slots) == "table" then
            local arr = serverList[subType]
            if not arr then arr = {}; serverList[subType] = arr end
            for idx, e in pairs(slots) do
                idx = tonumber(idx)
                local insID = e and tonumber(e.insID)
                if idx and insID and insID > 0 and F.isInjectedIns(insID) then
                    arr[idx] = insID
                end
            end
        end
    end
    local cfg = PERSIST.configVehicleSlots
    if cfg then
        for subType, slotMap in pairs(cfg) do
            subType = tonumber(subType)
            if subType and type(slotMap) == "table" then
                local arr = serverList[subType]
                if not arr then arr = {}; serverList[subType] = arr end
                for idx, res in pairs(slotMap) do
                    idx, res = tonumber(idx), tonumber(res)
                    local ins = res and R.resToIns[res]
                    if idx and ins and F.isInjectedIns(ins) then
                        arr[idx] = ins
                    end
                end
            end
        end
    end
    return serverList
end

function F.applyVehicleSlotsFromConfigMap(slotMap)
    if not slotMap or not next(slotMap) then return false end
    local cch = F.cache()
    cch.vehicleSlots = cch.vehicleSlots or {}
    local any = false
    for subType, slots in pairs(slotMap) do
        subType = tonumber(subType)
        if subType then
            cch.vehicleSlots[subType] = cch.vehicleSlots[subType] or {}
            for idx, res in pairs(slots) do
                idx, res = tonumber(idx), tonumber(res)
                local ins = res and R.resToIns[res]
                if idx and ins then
                    cch.vehicleSlots[subType][idx] = { resID = res, insID = ins }
                    any = true
                end
            end
        end
    end
    return any
end

function F.notifyVehicleSlotUI()
    pcall(function()
        local WRH = require("client.network.Protocol.WardrobeNewHandler")
        WRH.on_depot_modify_combat_vehicle_rsp(0, DataMgr.VehicleSlotList or {})
    end)
end

function F.mergeInjectedVehicleSkinTable(serverTable)
    serverTable = serverTable or {}
    local cfg = PERSIST.configVehicleSlots
    if not cfg then return serverTable end
    for subType, slotMap in pairs(cfg) do
        subType = tonumber(subType)
        if subType and type(slotMap) == "table" then
            local res = tonumber(slotMap[1] or slotMap["1"])
            local ins = res and R.resToIns[res]
            if ins and F.isInjectedIns(ins) then
                serverTable[subType] = ins
            end
        end
    end
    local cch = F.cache()
    for subType, slots in pairs(cch.vehicleSlots or {}) do
        subType = tonumber(subType)
        local e = slots and (slots[1] or slots["1"])
        local insID = e and tonumber(e.insID)
        if subType and insID and insID > 0 and F.isInjectedIns(insID) then
            serverTable[subType] = insID
        end
    end
    return serverTable
end

function F.equipVehicleTypesFromConfig(slotMap)
    slotMap = slotMap or PERSIST.configVehicleSlots
    if not slotMap or not next(slotMap) then return false end
    DataMgr.vehicleSkinInsIDTable = DataMgr.vehicleSkinInsIDTable or {}
    local subTypes = {}
    for st in pairs(slotMap) do
        local n = tonumber(st)
        if n then subTypes[#subTypes + 1] = n end
    end
    table.sort(subTypes)
    local any, lobbyRes, lobbyIns = false, nil, nil
    for _, subType in ipairs(subTypes) do
        local slots = slotMap[subType] or slotMap[tostring(subType)]
        if type(slots) == "table" then
            local res = tonumber(slots[1] or slots["1"])
            local ins = res and R.resToIns[res]
            if ins and F.isInjectedIns(ins) then
                DataMgr.vehicleSkinInsIDTable[subType] = ins
                any = true
                if not lobbyIns then
                    lobbyRes, lobbyIns = res, ins
                end
            end
        end
    end
    if any then
        pcall(function()
            local TabSurveillance = require("client.slua.logic.wardrobe.tab_surveillance")
            TabSurveillance.VehicleChange()
        end)
    end
    return any, lobbyRes, lobbyIns
end

function F.applyLobbyVehicleDisplay(resID, insID, showVehicle)
    insID = tonumber(insID)
    resID = tonumber(resID)
    if not insID or insID <= 0 then return end
    _G.AddOutfitApplyingConfig = true
    pcall(function() DataMgr.vst_skin = insID end)
    pcall(function()
        local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
        HallThemeUtils.ProcPutOnVehicle({ res_id = resID, instid = insID }, showVehicle ~= false)
    end)
    pcall(F.applyVehicleSkinsToPC)
    _G.AddOutfitApplyingConfig = false
end

function F.setLobbyVehicleManual(subType, resID, insID)
    insID = tonumber(insID)
    resID = tonumber(resID)
    subType = tonumber(subType)
    if not insID then return end
    if F.isChassisLightId(resID) or subType == CHASSIS_LIGHT_SUB then return end
    if resID and not F.isVehicleRes(resID) then return end
    if not F.isInjectedIns(insID) and not F.isVehicleRes(resID) then return end
    if not resID then resID = R.insToRes[insID] end
    if not subType and resID then subType = tonumber(F.vehicleSubType(resID)) end
    _G.AddOutfitLobbyVeh = _G.AddOutfitLobbyVeh or {}
    _G.AddOutfitLobbyVeh.manual = true
    _G.AddOutfitLobbyVeh.subType = subType
    _G.AddOutfitLobbyVeh.resID = resID
    _G.AddOutfitLobbyVeh.insID = insID
    PERSIST.lobbyVehicleSubType = subType
    PERSIST.lobbyVehicleIns = insID
    PERSIST.lobbyVehicleResID = resID
    F.persistMarkDirty()
end

function F.resolveLobbyVehicle(slotMap)
    slotMap = slotMap or PERSIST.configVehicleSlots
    local L = _G.AddOutfitLobbyVeh or {}
    local st = tonumber(PERSIST.lobbyVehicleSubType) or tonumber(L.subType)
    local res = tonumber(PERSIST.lobbyVehicleResID) or tonumber(L.resID)
    if res and res > 0 then
        local ins = R.resToIns[res]
        if ins then
            if not st then st = tonumber(F.vehicleSubType(res)) end
            return res, ins, st
        end
    end
    local ins = tonumber(PERSIST.lobbyVehicleIns) or tonumber(L.insID)
    if ins and F.isInjectedIns(ins) then
        res = R.insToRes[ins] or res
        if not st and res then st = tonumber(F.vehicleSubType(res)) end
        return res, ins, st
    end
    if st and slotMap then
        local slots = slotMap[st] or slotMap[tostring(st)]
        local res = slots and tonumber(slots[1] or slots["1"])
        ins = res and R.resToIns[res]
        if ins then return res, ins, st end
    end
    local subTypes = {}
    for s in pairs(slotMap or {}) do
        local n = tonumber(s)
        if n then subTypes[#subTypes + 1] = n end
    end
    table.sort(subTypes)
    if subTypes[1] then
        st = subTypes[1]
        local slots = slotMap[st] or slotMap[tostring(st)]
        local res = slots and tonumber(slots[1] or slots["1"])
        ins = res and R.resToIns[res]
        if ins then return res, ins, st end
    end
    return nil, nil, nil
end

function F.syncLobbyVehicleResFromIns()
    if PERSIST.lobbyVehicleResID and PERSIST.lobbyVehicleResID > 0 then return end
    local ins = tonumber(PERSIST.lobbyVehicleIns)
    if ins and R.insToRes[ins] then
        PERSIST.lobbyVehicleResID = R.insToRes[ins]
        F.persistMarkDirty()
    end
end

function F.hasExplicitLobbyVehicle()
    local res = tonumber(PERSIST.lobbyVehicleResID)
    local st = tonumber(PERSIST.lobbyVehicleSubType)
    if F.isChassisLightId(res) or st == CHASSIS_LIGHT_SUB then return false end
    if res and res > 0 and not F.isVehicleRes(res) then return false end
    if res and res > 0 then return true end
    if (tonumber(PERSIST.lobbyVehicleIns) or 0) > 0 then return true end
    local L = _G.AddOutfitLobbyVeh
    if L and L.manual and ((tonumber(L.resID) or 0) > 0 or (tonumber(L.insID) or 0) > 0) then return true end
    return false
end

function F.shouldApplyLobbyFromConfig(silent)
    if not F.hasExplicitLobbyVehicle() then return false end
    local _, lobbyIns = F.resolveLobbyVehicle(PERSIST.configVehicleSlots)
    if not lobbyIns then return false end
    local cur = tonumber(DataMgr.vst_skin)
    if cur == lobbyIns then return false end
    return true
end

function F.reapplyVehicleSlotsFromConfig(silent)
    local slotMap = PERSIST.configVehicleSlots
    if not slotMap or not next(slotMap) then return false end
    if not F.applyVehicleSlotsFromConfigMap(slotMap) then return false end
    F.syncVehicleSlotsToDataMgr()
    F.notifyVehicleSlotUI()
    F.equipVehicleTypesFromConfig(slotMap)
    if F.shouldApplyLobbyFromConfig(silent) then
        local lobbyRes, lobbyIns = F.resolveLobbyVehicle(slotMap)
        if lobbyIns then
            F.applyLobbyVehicleDisplay(lobbyRes, lobbyIns, not silent)
        elseif not silent then
            pcall(F.applyVehicleSkinsToPC)
            F.perfInvalidateLobby()
        end
    end
    return true
end

function F.applyHallThemeDisplay(resID, insID)
    insID = tonumber(insID)
    resID = tonumber(resID)
    if not insID or not resID then return false end
    if not F.isInjectedIns(insID) then return false end
    if not F.isResourcesReady(resID) then
        F.requestResourceDownload(resID)
        return false
    end
    _G.AddOutfitApplyingTheme = true
    pcall(function()
        local HT = require("client.logic.lobby.hall_theme_utils")
        HT.ProcPutOnHallTheme({ res_id = resID, instid = insID }, nil)
    end)
    _G.AddOutfitApplyingTheme = false
    local cch = F.cache()
    cch.hallThemeRes, cch.hallThemeIns = resID, insID
    return true
end

function F.setHallThemeManual(resID, insID)
    insID = tonumber(insID)
    resID = tonumber(resID)
    if not insID or not F.isInjectedIns(insID) then return end
    if not resID then resID = R.insToRes[insID] end
    _G.AddOutfitLobbyTheme = _G.AddOutfitLobbyTheme or {}
    _G.AddOutfitLobbyTheme.manual = true
    _G.AddOutfitLobbyTheme.resID = resID
    _G.AddOutfitLobbyTheme.insID = insID
    PERSIST.hallThemeResID = resID
    PERSIST.hallThemeIns = insID
    local cch = F.cache()
    cch.hallThemeRes, cch.hallThemeIns = resID, insID
    F.persistMarkDirty()
end

function F.resolveHallTheme()
    local L = _G.AddOutfitLobbyTheme or {}
    local res = tonumber(PERSIST.hallThemeResID) or tonumber(L.resID)
    if res and R.resToIns[res] then return res, R.resToIns[res] end
    local ins = tonumber(PERSIST.hallThemeIns) or tonumber(L.insID)
    if ins and F.isInjectedIns(ins) then return R.insToRes[ins], ins end
    return nil, nil
end

function F.shouldApplyHallThemeFromConfig(silent)
    local _, ins = F.resolveHallTheme()
    if not ins then return false end
    local cur = nil
    pcall(function()
        local HT = require("client.logic.lobby.hall_theme_utils")
        cur = tonumber(HT.GetThemeInstId())
    end)
    if cur == ins then return false end
    if _G.AddOutfitLobbyTheme and _G.AddOutfitLobbyTheme.manual then return true end
    if silent and cur and cur > 0 and F.isInjectedIns(cur) then return false end
    return true
end

function F.putOnHallTheme(insID)
    insID = tonumber(insID)
    if not insID or not F.isInjectedIns(insID) then return false end
    local resID = R.insToRes[insID]
    if F.applyHallThemeDisplay(resID, insID) then
        F.setHallThemeManual(resID, insID)
        return true
    end
    return false
end

function F.reapplyHallThemeFromConfig(silent)
    if not F.shouldApplyHallThemeFromConfig(silent) then return false end
    local res, ins = F.resolveHallTheme()
    if not res or not ins then return false end
    return F.applyHallThemeDisplay(res, ins)
end

function F.syncVehicleCacheFromDataMgr()
    local cch = F.cache()
    cch.vehicleSlots = cch.vehicleSlots or {}
    local wd = require("client.slua.logic.wardrobe.wardrobe_data")
    for subType, slots in pairs(DataMgr.VehicleSlotList or {}) do
        subType = tonumber(subType)
        if subType and type(slots) == "table" then
            cch.vehicleSlots[subType] = cch.vehicleSlots[subType] or {}
            for idx, insID in pairs(slots) do
                idx, insID = tonumber(idx), tonumber(insID)
                if idx and insID and insID > 0 then
                    local res = R.insToRes[insID]
                    if not res then
                        pcall(function()
                            local d = wd:GetHallDepotItemDataByInsID(insID)
                            res = d and tonumber(d.resID)
                        end)
                    end
                    if res and res > 0 then
                        cch.vehicleSlots[subType][idx] = { resID = res, insID = insID }
                    end
                end
            end
        end
    end
end

function F.vehicleSubType(resID)
    local c = F.cfg(resID)
    return c and (c.ItemSubType or c.itemSubType)
end

function F.modifyInjectedVehicleSlot(insID, slotIndex, equip)
    insID = tonumber(insID)
    slotIndex = tonumber(slotIndex)
    if not insID or not slotIndex then return false end
    local resID = R.insToRes[insID]
    if not resID and insID >= INS_BASE then
        pcall(function()
            local wd = require("client.slua.logic.wardrobe.wardrobe_data")
            local d = wd:GetHallDepotItemDataByInsID(insID)
            resID = d and tonumber(d.resID or d.res_id)
        end)
    end
    if not resID then return false end
    local st = F.vehicleSubType(resID)
    if not st or tonumber(st) < 900 then return false end
    local cch = F.cache()
    cch.vehicleSlots = cch.vehicleSlots or {}
    cch.vehicleSlots[st] = cch.vehicleSlots[st] or {}
    if equip then
        for _, slots in pairs(cch.vehicleSlots) do
            for i, e in pairs(slots) do
                if e and tonumber(e.insID) == insID then slots[i] = nil end
            end
        end
        cch.vehicleSlots[st][slotIndex] = { resID = resID, insID = insID }
        PERSIST.configVehicleSlots = PERSIST.configVehicleSlots or {}
        PERSIST.configVehicleSlots[st] = PERSIST.configVehicleSlots[st] or {}
        PERSIST.configVehicleSlots[st][slotIndex] = resID
    else
        local e = cch.vehicleSlots[st][slotIndex]
        if e and tonumber(e.insID) == insID then
            cch.vehicleSlots[st][slotIndex] = nil
            if PERSIST.configVehicleSlots and PERSIST.configVehicleSlots[st] then
                PERSIST.configVehicleSlots[st][slotIndex] = nil
            end
        end
    end
    F.syncVehicleSlotsToDataMgr()
    if equip and slotIndex == 1 then
        DataMgr.vehicleSkinInsIDTable = DataMgr.vehicleSkinInsIDTable or {}
        DataMgr.vehicleSkinInsIDTable[st] = insID
        pcall(function()
            local TabSurveillance = require("client.slua.logic.wardrobe.tab_surveillance")
            TabSurveillance.VehicleChange()
        end)
    end
    F.persistMarkDirty()
    F.notifyVehicleSlotUI()
    return true
end

function F.buildVstInBattleFromSlots()
    local vst = {}
    local function insToRes(insID)
        insID = tonumber(insID)
        if not insID or insID <= 0 then return nil end
        local res = R.insToRes[insID]
        if res and res > 0 then return res end
        pcall(function()
            local wd = require("client.slua.logic.wardrobe.wardrobe_data")
            local d = wd:GetHallDepotItemDataByInsID(insID)
            res = d and tonumber(d.resID)
        end)
        if res and res > 0 then return res end
        if insID >= 1000000 and F.cfg(insID) then return insID end
        return nil
    end
    local function fillFromSlots(subType, slots)
        subType = tonumber(subType)
        if not subType or type(slots) ~= "table" then return end
        local resList = {}
        for idx = 1, 8 do
            local val = slots[idx] or slots[tostring(idx)]
            local res = insToRes(val)
            if not res and type(val) == "table" then
                res = tonumber(val.resID or val.res_id)
            end
            if res and res > 0 then resList[#resList + 1] = res end
        end
        if #resList > 0 then vst[subType] = resList end
    end
    for subType, slots in pairs(DataMgr.VehicleSlotList or {}) do
        fillFromSlots(subType, slots)
    end
    if not next(vst) then
        local cch = F.cache()
        for subType, slots in pairs(cch.vehicleSlots or {}) do
            local resList = {}
            for idx = 1, 8 do
                local e = slots[idx]
                local res = e and tonumber(e.resID)
                if res and res > 0 then resList[#resList + 1] = res end
            end
            if #resList > 0 then vst[tonumber(subType)] = resList end
        end
    end
    if not next(vst) then
        local bySub = {}
        for res, _ in pairs(R.resToIns) do
            res = tonumber(res)
            local c = F.cfg(res)
            local st = c and tonumber(F.subType(c))
            if res and st and st >= 900 then
                bySub[st] = bySub[st] or {}
                bySub[st][#bySub[st] + 1] = res
            end
        end
        for st, list in pairs(bySub) do
            table.sort(list)
            vst[st] = list
        end
    end
    return vst
end

function F.isVehicleSkinAllowed(skinId)
    skinId = tonumber(skinId)
    if not skinId or skinId <= 0 then return false end
    if F.isInjectedRes(skinId) then return true end
    for _, list in pairs(F.buildVstInBattleFromSlots()) do
        for _, res in ipairs(list) do
            if tonumber(res) == skinId then return true end
        end
    end
    if R.resToIns[skinId] then
        local c = F.cfg(skinId)
        local st = F.subType(c)
        if st and tonumber(st) >= 900 then return true end
    end
    return false
end

function F.isSkinInVehiclePCList(skinId)
    skinId = tonumber(skinId)
    if not skinId or skinId <= 0 then return false end
    local pc = F.getPC()
    if not slua.isValid(pc) or not pc.VehicleAvatarSkinList then return false end
    local UAvatarUtils = import("AvatarUtils")
    local shape = UAvatarUtils.GetVehicleShapeBySkinID(skinId)
    if shape and shape >= 0 then
        local entry = pc.VehicleAvatarSkinList:Get(shape)
        if entry and entry.SkinList then
            for _, id in pairs(entry.SkinList) do
                if tonumber(id) == skinId then return true end
            end
        end
    end
    return false
end

function F.shouldHandleVehicleSkinClick(resID)
    resID = tonumber(resID)
    if not resID or resID <= 0 then return false end
    return F.isVehicleSkinAllowed(resID) or F.isSkinInVehiclePCList(resID)
end

function F.getMatchVehicle()
    local found = nil
    pcall(function()
        local subs = SubsystemMgr:Get("VehicleControlUISubSystem")
        if subs and subs.GetVehicleUserComponent then
            local uuc = subs:GetVehicleUserComponent()
            if slua.isValid(uuc) and slua.isValid(uuc.Vehicle) then found = uuc.Vehicle end
        end
    end)
    if slua.isValid(found) then return found end
    local pc = F.getPC()
    if slua.isValid(pc) and pc.GetPlayerCharacterSafety then
        local char = pc:GetPlayerCharacterSafety()
        if slua.isValid(char) then
            if char.GetCurrentVehicle then
                local v = char:GetCurrentVehicle()
                if slua.isValid(v) then return v end
            end
            if char.CurrentVehicle and slua.isValid(char.CurrentVehicle) then
                return char.CurrentVehicle
            end
        end
    end
    return nil
end

function F.applyClientVehicleSkin(skinId, vehicle, pc)
    skinId = tonumber(skinId)
    if not skinId or skinId <= 0 then return false end
    pc = pc or F.getPC()
    vehicle = vehicle or F.getMatchVehicle()
    if not slua.isValid(vehicle) then return false end

    local UAvatarUtils = import("AvatarUtils")
    pcall(function()
        if slua.isValid(pc) then
            pc.ShowVehicleSkin = skinId
            local shapeType = UAvatarUtils.GetVehicleShapeBySkinID(skinId)
            if shapeType and shapeType >= 0 and pc.VehicleAvatarList then
                pc.VehicleAvatarList:Add(shapeType, skinId)
            end
        end
    end)

    local applied = false
    local av = nil
    pcall(function()
        if vehicle.GetAvatarComponent then av = vehicle:GetAvatarComponent() end
        if not slua.isValid(av) then av = vehicle.VehicleAvatarComponent_BP end
    end)

    if slua.isValid(av) then
        pcall(function() if av.bIsLobbyAvatar ~= nil then av.bIsLobbyAvatar = false end end)
        pcall(function() if av.CanChangeAvatar ~= nil then av.CanChangeAvatar = true end end)
        pcall(function()
            if slua.isValid(pc) and av.SetVehicleNetAvatarData then
                av:SetVehicleNetAvatarData(pc)
            end
        end)
        pcall(function()
            if av.ChangeItemAvatar then
                av:ChangeItemAvatar(skinId, false)
                applied = true
            elseif av.PreChangeVehicleAvatar then
                av:PreChangeVehicleAvatar(skinId)
                applied = true
            end
        end)
        pcall(function()
            if av.PostChangeItemAvatar then av:PostChangeItemAvatar(false) end
        end)
    end

    pcall(function()
        local battleCls = import("VehicleAvatarComponentBattleBase")
        local battleAv = vehicle:GetComponentByClass(battleCls)
        if slua.isValid(battleAv) then
            if battleAv.ChangeVehicleAvatar then
                battleAv:ChangeVehicleAvatar(skinId, false)
                applied = true
            end
            pcall(function()
                local VehiclePlateLicenseUtil = require("GameLua.Activity.Commercialize.GamePlay.Vehicle.VehiclePlateLicenseUtil")
                local uid = pc and pc.PlayerUID or 0
                local bTire = VehiclePlateLicenseUtil.NeedOpenHighTire(tonumber(uid), skinId)
                if battleAv.PreChangeHighTireLight then
                    battleAv:PreChangeHighTireLight(skinId, bTire)
                end
            end)
        end
    end)

    pcall(function()
        if vehicle.ChangeVehicleAvatar and slua.isValid(pc) then
            vehicle:ChangeVehicleAvatar(pc)
            applied = true
        end
    end)

    pcall(function() if vehicle.ForceNetUpdate then vehicle:ForceNetUpdate() end end)
    pcall(function() if slua.isValid(pc) and pc.ForceNetUpdate then pc:ForceNetUpdate() end end)
    return applied
end

function F.getVehicleSkinIds()
    local out, seen = {}, {}
    local function add(res)
        res = tonumber(res)
        if res and res > 0 and not seen[res] then
            seen[res] = true
            out[#out + 1] = res
        end
    end
    for _, list in pairs(F.buildVstInBattleFromSlots()) do
        for _, res in ipairs(list) do add(res) end
    end
    for res in pairs(R.resToIns) do
        local c = F.cfg(tonumber(res))
        local st = c and tonumber(F.subType(c))
        if st and st >= 900 then add(res) end
    end
    return out
end

function F.buildVehVst(skinIds)
    local bySub = {}
    for _, skinId in ipairs(skinIds or {}) do
        local subType = 961
        local ok, c = pcall(function() return CDataTable.GetTableData("Item", skinId) end)
        if ok and c and c.ItemSubType then subType = c.ItemSubType end
        bySub[subType] = bySub[subType] or {}
        bySub[subType][#bySub[subType] + 1] = skinId
    end
    return bySub
end

function F.directInjectVehicleSkinList(pc, skinIds)
    if not slua.isValid(pc) or not pc.VehicleAvatarSkinList then return end
    local UAvatarUtils = import("AvatarUtils")
    for _, skinId in ipairs(skinIds or {}) do
        local shapeType = nil
        pcall(function() shapeType = UAvatarUtils.GetVehicleShapeBySkinID(skinId) end)
        if shapeType and shapeType >= 0 then
            pcall(function() pc.VehicleAvatarList:Add(shapeType, skinId) end)
            local entry = pc.VehicleAvatarSkinList:Get(shapeType)
            if entry and entry.SkinList then
                pcall(function() entry.SkinList:Add(skinId) end)
            end
        end
    end
end

function F.mergeVstIntoPlayerInfo(playerInfo)
    if not playerInfo then return end
    F.syncVehicleCacheFromDataMgr()
    local vst = F.buildVehVst(F.getVehicleSkinIds())
    if not next(vst) then return end
    playerInfo.vst_in_battle = playerInfo.vst_in_battle or {}
    for subType, list in pairs(vst) do
        playerInfo.vst_in_battle[subType] = list
    end
    local first
    for _, list in pairs(vst) do first = list[1]; break end
    if first and first > 0 then playerInfo.vst_skin = first end
end

function F.applyVehicleSkinsToPC(pc)
    pc = pc or F.getPC()
    if not slua.isValid(pc) then return false end
    local skinIds = F.getVehicleSkinIds()
    if #skinIds == 0 then return false end
    local vst = F.buildVehVst(skinIds)
    local avatarList, avatarSkinList = {}, {}
    for _, skinList in pairs(vst) do
        local itemArray = {}
        for _, resid in ipairs(skinList) do
            if resid and resid > 0 then
                itemArray[#itemArray + 1] = { ItemTableID = resid, Count = 1 }
                avatarList[#avatarList + 1] = { ItemTableID = resid, Count = 1 }
            end
        end
        if #itemArray > 0 then
            avatarSkinList[#avatarSkinList + 1] = { Items = itemArray }
        end
    end
    pcall(function() pc.bEnableFuzzyAvatarOnClient = false end)
    pcall(function() pc.ShowVehicleSkin = skinIds[1] end)
    if #avatarList > 0 then
        pcall(function()
            pc.InitialVehicleAvatarList = avatarList
            pc:InitVehicleAvatarList()
        end)
    end
    if #avatarSkinList > 0 then
        pcall(function()
            pc.InitialVehicleAvatarSkinList = avatarSkinList
            pc:InitVehicleAvatarSkinList()
        end)
    end
    F.directInjectVehicleSkinList(pc, skinIds)
    return true
end

function F.serverChangeVehicleAvatar(skinId, pc)
    skinId = tonumber(skinId)
    if not skinId or skinId <= 0 then return false end
    pc = pc or F.getPC()
    if not slua.isValid(pc) then return false end

    F.applyVehicleSkinsToPC(pc)

    pcall(function()
        pc.ShowVehicleSkin = skinId
        local UAvatarUtils = import("AvatarUtils")
        local shapeType = UAvatarUtils.GetVehicleShapeBySkinID(skinId)
        if shapeType and shapeType >= 0 and pc.VehicleAvatarList then
            pc.VehicleAvatarList:Add(shapeType, skinId)
        end
        F.directInjectVehicleSkinList(pc, { skinId })
    end)

    local ok = false
    pcall(function()
        if pc.ServerChangeVehicleAvatar then
            pc:ServerChangeVehicleAvatar(skinId)
            ok = true
        end
    end)

    pcall(function()
        if pc.PlayerState and slua.isValid(pc.PlayerState) then
            pc.PlayerState.nVst_skin = skinId
        end
    end)

    pcall(function() pc:ForceNetUpdate() end)
    return ok
end

_G.AddOutfitVehSel = _G.AddOutfitVehSel or { override = nil, overrideVehicle = nil, byShape = {} }
local VEHSEL = _G.AddOutfitVehSel
_G.AddOutfitLobbyVeh = _G.AddOutfitLobbyVeh or { manual = false, subType = nil, resID = nil, insID = nil }
local _vehTickLastApply = 0
local VEH_SWITCH_EFFECT_ID = 7303001

function F.prepVehicleSwitchEffect(av, vehicle)
    if not slua.isValid(av) then return end
    if not F.isInRealMatch() then
        pcall(function() av.curSwitchEffectId = 0 end)
        return
    end
    pcall(function()
        av.curSwitchEffectId = VEH_SWITCH_EFFECT_ID
        local defaultId = 0
        pcall(function() defaultId = tonumber(av:GetDefaultAvatarID()) or 0 end)
        local curId = 0
        if slua.isValid(vehicle) then
            pcall(function() curId = tonumber(vehicle.GetAvatarId and vehicle:GetAvatarId()) or 0 end)
            if curId <= 0 then
                pcall(function() curId = tonumber(vehicle.ClientUsedAvatarID) or 0 end)
            end
        end
        if curId <= 0 then curId = defaultId end
        if not av.lastEquipedAvatarId or av.lastEquipedAvatarId <= 0 then
            av.lastEquipedAvatarId = curId > 0 and curId or defaultId
        end
    end)
end

function F.isParachuteRes(resID)
    return F.subType(F.cfg(tonumber(resID))) == PARACHUTE_SUB
end

function F.isGlideRes(resID)
    resID = tonumber(resID)
    if not resID then return false end
    local st = F.subType(F.cfg(resID))
    if GLIDER_SUBS[st] then return true end
    local ok, r = pcall(function()
        local MDH = require("client.logic.avatar.ModelDisplayTypeHelper")
        if MDH.IsGlideByItemID and MDH.IsGlideByItemID(resID) then return true end
        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
        return wd.IsGlideType(st)
    end)
    return ok and r == true
end

function F.isVehicleRes(resID)
    resID = tonumber(resID)
    if not resID or F.isChassisLightId(resID) then return false end
    local st = tonumber(F.subType(F.cfg(resID)))
    return st and st >= 900 and st < 7000 and st ~= CHASSIS_LIGHT_SUB
end

function F.ensureInjectedItemAlive(entity, resID, insID)
    entity = entity or F.getEntity()
    insID = tonumber(insID) or (resID and R.resToIns[tonumber(resID)])
    resID = tonumber(resID) or (insID and R.insToRes[insID])
    if not entity or not insID then return end
    pcall(function()
        local d = entity:GetDataByInsID(insID)
        if d then
            d.expire_ts = 0
            d.expireTS = 0
            d.valid_hours = 0
        end
    end)
end

function F.sanitizeAllInjectedExpire()
    local entity = F.getEntity()
    if not entity then return end
    for res, ins in pairs(R.resToIns) do
        F.ensureInjectedItemAlive(entity, res, ins)
    end
end

function F.putOnVehicle(insID)
    insID = tonumber(insID)
    if not insID then return false end
    local resID = R.insToRes[insID]
    if not resID or not F.isVehicleRes(resID) then return false end
    F.ensureInjectedItemAlive(nil, resID, insID)
    if not F.isResourcesReady(resID) then
        F.requestResourceDownload(resID)
        return false
    end
    local item = {
        res_id = resID, resID = resID,
        instid = insID, ins_id = insID, insID = insID,
        expire_ts = 0, expireTS = 0, count = 1,
    }
    local WRH = require("client.network.Protocol.WardRobeHandler")
    WRH.on_depot_put_on_rsp(NET_OK, item, nil, 1, insID, 0)
    F.setLobbyVehicleManual(F.vehicleSubType(resID), resID, insID)
    pcall(function()
        local TabSurveillance = require("client.slua.logic.wardrobe.tab_surveillance")
        TabSurveillance.VehicleChange()
    end)
    pcall(function()
        if EventSystem and EVENTTYPE_WARDROBE and EVENTID_WARDROBE_UPDATE_ITEM_LIST then
            EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_ITEM_LIST)
        end
    end)
    return true
end

function F.isChassisLightId(id)
    return CHASSIS_LIGHT_IDS[tonumber(id)] == true
end

function F.getDesiredChassisLight(vehicleSkinId)
    vehicleSkinId = tonumber(vehicleSkinId)
    local map = PERSIST.configChassisLightMap
    if vehicleSkinId and map and map[vehicleSkinId] then
        local v = tonumber(map[vehicleSkinId])
        if F.isChassisLightId(v) then return v end
    end
    local def = tonumber(PERSIST.configChassisLight) or DEFAULT_CHASSIS_LIGHT
    return F.isChassisLightId(def) and def or DEFAULT_CHASSIS_LIGHT
end

function F.saveChassisLight(vehicleSkinId, lightId)
    vehicleSkinId = tonumber(vehicleSkinId)
    lightId = tonumber(lightId)
    if not F.isChassisLightId(lightId) then return end
    PERSIST.configChassisLightMap = PERSIST.configChassisLightMap or {}
    if vehicleSkinId and vehicleSkinId > 0 then
        PERSIST.configChassisLightMap[vehicleSkinId] = lightId
    else
        PERSIST.configChassisLight = lightId
    end
    F.requestResourceDownload(lightId)
    F.persistMarkDirty()
end

function F.getVehicleLicenseComp(vehicle)
    if not slua.isValid(vehicle) then return nil end
    local lic = nil
    pcall(function()
        if vehicle.GetLicenseComponent then lic = vehicle:GetLicenseComponent() end
    end)
    if slua.isValid(lic) then return lic end
    pcall(function() lic = vehicle.BP_Lobby_VehicleLicenseComponent end)
    if slua.isValid(lic) then return lic end
    pcall(function()
        local cls = import("VehicleLicenseNumberComponent")
        lic = vehicle:GetComponentByClass(cls)
    end)
    return slua.isValid(lic) and lic or nil
end

function F.applyVehicleChassisLight(vehicle, skinId, lightId)
    -- [FIX VIP] Náº¿u táº¯t Mod Skin thÃ¬ bá» qua khÃ´ng load Ä‘Ã¨n gáº§m
    if _G.LexusConfig and _G.LexusConfig.ModSkin == false then return false end 
    
    skinId = tonumber(skinId)
    lightId = tonumber(lightId) or F.getDesiredChassisLight(skinId)
    if not F.isChassisLightId(lightId) then return false end
    if not slua.isValid(vehicle) then return false end
    if skinId and skinId > 0 then
        F.requestResourceDownload(skinId)
    end
    F.requestResourceDownload(lightId)
    local applied = false
    pcall(function()
        if vehicle.SetChassisLightShowData then
            vehicle:SetChassisLightShowData(lightId)
            applied = true
        end
    end)
    local lic = F.getVehicleLicenseComp(vehicle)
    if not slua.isValid(lic) then return applied end
    pcall(function()
        local vid = skinId
        if not vid or vid <= 0 then
            pcall(function()
                if vehicle.GetAvatarId then vid = tonumber(vehicle:GetAvatarId()) end
            end)
        end
        if not vid or vid <= 0 then
            pcall(function() vid = tonumber(lic.LicensePlate and lic.LicensePlate.ItemID) end)
        end
        if vid and vid > 0 then
            lic.curVehicleAvatarId = vid
            if lic.ChangeNetData_ItemID then
                lic:ChangeNetData_ItemID(vid)
            elseif lic.LicensePlate then
                lic.LicensePlate.ItemID = vid
            end
        end
        if lic.LicensePlate then
            lic.LicensePlate.ChassisLightId = lightId
        end
        if lic.SetChassisLightData and vid and vid > 0 then
            lic:SetChassisLightData(vid, lightId)
        elseif lic.PreChangeChassisLight then
            lic:PreChangeChassisLight()
        end
        applied = true
    end)
    return applied
end

function F.scheduleChassisLightApply(vehicle, skinId)
    skinId = tonumber(skinId)
    local vref = slua.isValid(vehicle) and vehicle or nil
    local function try()
        local v = slua.isValid(vref) and vref or F.getCurrentVehicleForSkin()
        if slua.isValid(v) then
            F.applyVehicleChassisLight(v, skinId)
        end
    end
    F.later(0.4, try)
    F.later(1.1, try)
end

function F.getVehicleShape(vehicle)
    if not slua.isValid(vehicle) then return nil end
    local shape = vehicle.VehicleShapeType
    if shape and tonumber(shape) >= 0 then return tonumber(shape) end
    pcall(function()
        local UAvatarUtils = import("AvatarUtils")
        local defId = vehicle.AvatarDefaultCfg and vehicle.AvatarDefaultCfg.TypeSpecificID
        if defId and tonumber(defId) > 0 then
            shape = UAvatarUtils.GetVehicleShapeBySkinID(tonumber(defId))
        end
    end)
    return shape and tonumber(shape) >= 0 and tonumber(shape) or nil
end

function F.getDesiredVehicleSkinForShape(shape)
    shape = tonumber(shape)
    if not shape or shape < 0 then return nil end
    F.syncVehicleCacheFromDataMgr()
    local UAvatarUtils = import("AvatarUtils")
    local vst = F.buildVstInBattleFromSlots()
    for _, list in pairs(vst) do
        local skin = list and tonumber(list[1])
        if skin and skin > 0 then
            local s = UAvatarUtils.GetVehicleShapeBySkinID(skin)
            if s == shape then return skin end
        end
    end
    local pc = F.getPC()
    if slua.isValid(pc) and pc.VehicleAvatarList then
        local skin = tonumber(pc.VehicleAvatarList:Get(shape))
        if skin and skin > 0 then return skin end
    end
    return nil
end

function F.getVehicleAvatarComp(vehicle)
    if not slua.isValid(vehicle) then return nil end
    local av = nil
    pcall(function() av = vehicle.VehicleAvatar end)
    if slua.isValid(av) then return av end
    pcall(function() if vehicle.GetAvatarComponent then av = vehicle:GetAvatarComponent() end end)
    if slua.isValid(av) then return av end
    pcall(function() av = vehicle.VehicleAvatarComponent_BP end)
    if slua.isValid(av) then return av end
    return nil
end

function F.getCurrentVehicleForSkin()
    local char = F.getLocalChar()
    if char and slua.isValid(char) then
        local v = nil
        pcall(function() v = char.CurrentVehicle end)
        if slua.isValid(v) then return v end
    end
    return F.getMatchVehicle()
end

function F.forceVehicleAvatar(skinId, vehicle)
    skinId = tonumber(skinId)
    if not skinId or skinId <= 0 then return false end
    if not F.isResourcesReady(skinId) then
        F.requestResourceDownload(skinId)
        return false
    end
    vehicle = slua.isValid(vehicle) and vehicle or F.getCurrentVehicleForSkin()
    if not slua.isValid(vehicle) then return false end
    local av = F.getVehicleAvatarComp(vehicle)
    if not slua.isValid(av) then return false end
    local applied = false
    F.prepVehicleSwitchEffect(av, vehicle)
    pcall(function() if av.CanChangeAvatar ~= nil then av.CanChangeAvatar = true end end)
    pcall(function()
        av:ChangeItemAvatar(skinId, true)
        applied = true
        _G.CurrentEquipVehicleID = skinId
    end)
    if applied then F.scheduleChassisLightApply(vehicle, skinId) end
    return applied
end

function F.vehicleAvatarTemper()
    local vehicle = F.getCurrentVehicleForSkin()
    if not slua.isValid(vehicle) then return end
    local av = F.getVehicleAvatarComp(vehicle)
    if not slua.isValid(av) then return end

    local defaultId = 0
    pcall(function() defaultId = tonumber(av:GetDefaultAvatarID()) or 0 end)
    if defaultId <= 0 then return end

    local shape = nil
    pcall(function() shape = tonumber(import("AvatarUtils").GetVehicleShapeBySkinID(defaultId)) end)

    local skinId = nil
    if VEHSEL.override and slua.isValid(VEHSEL.overrideVehicle) and VEHSEL.overrideVehicle == vehicle then
        skinId = VEHSEL.override
    end
    if not skinId and shape then skinId = VEHSEL.byShape[shape] end
    if not skinId then skinId = F.getDesiredVehicleSkinForShape(shape) end
    skinId = tonumber(skinId)
    if not skinId or skinId <= 0 or skinId == defaultId then return end

    local cur = 0
    pcall(function() cur = tonumber(vehicle.GetAvatarId and vehicle:GetAvatarId()) or 0 end)
    if cur <= 0 then
        pcall(function() cur = tonumber(vehicle.GetVehicleSkinItemID and vehicle:GetVehicleSkinItemID()) or 0 end)
    end
    if cur == skinId then return end

    F.forceVehicleAvatar(skinId, vehicle)
end

function F.vehicleSkinTick()
    F.vehicleAvatarTemper()
    
    -- [FIX VIP] Ã‰p hiá»ƒn thá»‹ KÃ­nh & Máº·t Náº¡ liÃªn tá»¥c má»—i 1 giÃ¢y (Báº¥t cháº¥p viá»‡c nháº·t mÅ© báº£o hiá»ƒm)
    pcall(function()
        local char = F.getLocalChar()
        if char then F.matchApplyFaceWear(char) end
    end)

    local now = os.clock()
    if now - _vehTickLastApply < 5.0 then return end
    _vehTickLastApply = now
    F.applyVehicleSkinsToPC()
end

function F.startVehicleSkinTicker()
    pcall(function()
        if not _ticker then return end
        if _G.AddOutfitVehTickerId then return end
        if _ticker.AddTimerLoop then
            _G.AddOutfitVehTickerId = _ticker.AddTimerLoop(1.0, function()
                local fn = _G.AddOutfit and _G.AddOutfit.vehicleSkinTick
                if fn then pcall(fn) end
            end, -1, 1.0)
        end
    end)
end

function F.matchApplyVehicleSkin(skinId)
    skinId = tonumber(skinId)
    if not skinId or skinId <= 0 then return false end

    local vehicle = F.getCurrentVehicleForSkin()

    VEHSEL.override = skinId
    VEHSEL.overrideVehicle = slua.isValid(vehicle) and vehicle or nil

    pcall(function()
        local UAvatarUtils = import("AvatarUtils")
        local shape = tonumber(UAvatarUtils.GetVehicleShapeBySkinID(skinId))
        if shape and shape >= 0 then VEHSEL.byShape[shape] = skinId end
        local av = F.getVehicleAvatarComp(vehicle)
        if slua.isValid(av) then
            local defaultId = tonumber(av:GetDefaultAvatarID()) or 0
            if defaultId > 0 then
                local defShape = tonumber(UAvatarUtils.GetVehicleShapeBySkinID(defaultId))
                if defShape and defShape >= 0 then VEHSEL.byShape[defShape] = skinId end
            end
        end
    end)

    F.applyVehicleSkinsToPC(F.getPC())
    local ok = F.forceVehicleAvatar(skinId, vehicle)
    F.startVehicleSkinTicker()
    return ok
end

function F.autoApplyVehicleSkinOnEnter(vehicle)
    if not slua.isValid(vehicle) then return end
    F.syncVehicleCacheFromDataMgr()
    F.applyVehicleSkinsToPC(F.getPC())
    F.startVehicleSkinTicker()
    F.later(0.35, function() pcall(F.vehicleAvatarTemper) end)
    F.later(0.9, function() pcall(F.vehicleAvatarTemper) end)
    F.later(0.5, function()
        local skinId = nil
        pcall(function() skinId = tonumber(vehicle.GetAvatarId and vehicle:GetAvatarId()) end)
        F.scheduleChassisLightApply(vehicle, skinId)
    end)
end

local function GetOutfitConfigPaths(fileName)
    local paths = {
        "//storage/emulated/0/Android/data/com.tencent.ig/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "//storage/emulated/0/Android/data/com.vng.pubgmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "//storage/emulated/0/Android/data/com.pubg.krmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "//storage/emulated/0/Android/data/com.rekoo.pubgm/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "//storage/emulated/0/Android/data/com.pubg.imobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "/Documents/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "/Documents/ShadowTrackerExtra/Saved/Paks/puffer_temp/" .. fileName,
        "ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "../../ShadowTrackerExtra/Saved/Paks/" .. fileName
    }
    pcall(function()
        if os and os.getenv then
            local homeDir = os.getenv("HOME")
            if homeDir and homeDir ~= "" then
                table.insert(paths, 1, homeDir .. "/Documents/ShadowTrackerExtra/Saved/Paks/" .. fileName)
            end
        end
    end)
    return paths
end

local CONFIG_PATHS = GetOutfitConfigPaths("star_outfit.json")

local PERSIST_SLOTS = {
    { "outfit", "outfitRes", "outfitIns", "AddOutfitLastLobbyOutfitRes" },
    { "tshirt", "tshirtRes", "tshirtIns", "AddOutfitLastLobbyTshirtRes" },
    { "pants",  "pantsRes",  "pantsIns",  "AddOutfitLastLobbyPantsRes"  },
    { "shoes",  "shoesRes",  "shoesIns",  "AddOutfitLastLobbyShoesRes"  },
    { "hat",    "hatRes",    "hatIns",    "AddOutfitLastLobbyHatRes"    },
    { "mask",   "maskRes",   "maskIns",   "AddOutfitLastLobbyMaskRes"   },
    { "glass",  "glassRes",  "glassIns",  "AddOutfitLastLobbyGlassRes"  },
    { "bag",    "bagRes",    "bagIns",    "AddOutfitLastLobbyBagRes"    },
    { "helmet", "helmetRes", "helmetIns", "AddOutfitLastLobbyHelmetRes" },
    { "parachute", "parachuteRes", "parachuteIns", "AddOutfitLastLobbyParachuteRes" },
    { "glider", "gliderRes", "gliderIns", "AddOutfitLastLobbyGliderRes" },
    { "gloves", "glovesRes", "glovesIns", "AddOutfitLastLobbyGlovesRes" },
}

function F.isPersistableWearRes(resID)
    resID = tonumber(resID)
    if not resID or resID <= 0 then return false end
    if F.isInjectedRes(resID) then return true end
    if F.isParachuteRes(resID) or F.isGlideRes(resID) then return true end
    if PERSIST.configSlots then
        for _, v in pairs(PERSIST.configSlots) do
            if tonumber(v) == resID then return true end
        end
    end
    return false
end

function F.persistRememberSlot(slotName, resID)
    slotName = slotName and tostring(slotName)
    resID = tonumber(resID)
    if not slotName or not resID or resID <= 0 then return end
    PERSIST.configSlots = PERSIST.configSlots or {}
    PERSIST.configSlots[slotName] = resID
end

function F.persistForgetSlot(slotName)
    if PERSIST.configSlots and slotName then
        PERSIST.configSlots[tostring(slotName)] = nil
    end
end

function F.persistLoadSlotsFromSaved(saved)
    if type(saved) ~= "table" then return end
    PERSIST.configSlots = PERSIST.configSlots or {}
    for _, s in ipairs(PERSIST_SLOTS) do
        local res = tonumber(saved[s[1]])
        if res and res > 0 then PERSIST.configSlots[s[1]] = res end
    end
    F.applyPersistSlotsToCache()
end

function F.resolveInsForRes(resID)
    resID = tonumber(resID)
    if not resID or resID <= 0 then return nil end
    if R.resToIns[resID] then return R.resToIns[resID] end
    local ins
    pcall(function()
        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
        local list = wd.GetHallDepotItemListByResID and wd:GetHallDepotItemListByResID(resID)
        if list then
            for _, v in pairs(list) do
                local id = tonumber(v.insID or v.instid or v.ins_id)
                if id and id > 0 then ins = id break end
            end
        end
        if not ins then
            local d = wd.GetValidHallDepotItemDataByInsID and wd:GetValidHallDepotItemDataByInsID(resID)
            if not d and wd.GetHallDepotItemDataByResID then
                d = wd:GetHallDepotItemDataByResID(resID)
            end
            if d then ins = tonumber(d.insID or d.instid or d.ins_id) end
        end
    end)
    return ins
end

function F.applyPersistSlotsToCache()
    if not PERSIST.configSlots then return end
    local cch = F.cache()
    for _, s in ipairs(PERSIST_SLOTS) do
        local slotName, cacheResKey, cacheInsKey, globalKey = s[1], s[2], s[3], s[4]
        local res = tonumber(PERSIST.configSlots[slotName])
        if res and res > 0 then
            cch[cacheResKey] = res
            _G[globalKey] = res
            local ins = F.resolveInsForRes(res)
            if ins and ins > 0 then cch[cacheInsKey] = ins end
        end
    end
end

function F.getDesiredGliderRes()
    F.applyPersistSlotsToCache()
    local r = tonumber(PERSIST.configSlots and PERSIST.configSlots.glider)
    if r and r > 0 then return r end
    F.syncAirborneCacheFromLobby()
    return F.getDesiredWear("gliderRes", "gliderRes", "AddOutfitLastLobbyGliderRes")
end

function F.getDesiredParachuteRes()
    F.applyPersistSlotsToCache()
    local r = tonumber(PERSIST.configSlots and PERSIST.configSlots.parachute)
    if r and r > 0 then return r end
    F.syncAirborneCacheFromLobby()
    return F.getDesiredWear("parachuteRes", "parachuteRes", "AddOutfitLastLobbyParachuteRes")
end

function F.getAvatarComp2(char)
    if not char or not slua.isValid(char) then return nil end
    local comp
    pcall(function()
        if char.getAvatarComponent2 then
            comp = char:getAvatarComponent2()
        end
        if (not comp or not slua.isValid(comp)) and char.AvatarComponent2 then
            comp = char.AvatarComponent2
        end
        if (not comp or not slua.isValid(comp)) and char.CharacterAvatarComp2_BP then
            comp = char.CharacterAvatarComp2_BP
        end
    end)
    return comp
end

function F.isCharacterAirborne(char)
    if not char or not slua.isValid(char) then return false end
    local ok, r = pcall(function()
        local EParachuteState = import("EParachuteState")
        local st = char.ParachuteState
        return st and st ~= EParachuteState.PS_None
    end)
    return ok and r == true
end

function F.reapplyWeaponsFromConfig()
    local wmap = F.sanitizeConfigWeapons(PERSIST.configWeapons)
    local dropped = false
    for k in pairs(PERSIST.configWeapons or {}) do
        if not wmap[tonumber(k) or k] then dropped = true break end
    end
    PERSIST.configWeapons = wmap
    if dropped then F.persistMarkDirty() end
    if not next(wmap) then return false end
    local cch = F.cache()
    local any = false
    for wid, res in pairs(wmap) do
        wid, res = tonumber(wid), tonumber(res)
        local ins = res and R.resToIns[res]
        if wid and ins and F.isInjectedIns(ins) then
            cch.weapons[wid] = { resID = res, insID = ins }
            if F.equipWeaponSkin(wid, ins) then
                any = true
            else
                F.syncWeaponArmorySilent(wid, ins)
            end
        end
    end
    return any
end

function F.persistEncode()
    local cch = F.cache()
    local parts = {}
    for _, s in ipairs(PERSIST_SLOTS) do
        local res = tonumber(PERSIST.configSlots and PERSIST.configSlots[s[1]])
            or tonumber(cch[s[2]])
        if res and res > 0 and F.isPersistableWearRes(res) then
            parts[#parts + 1] = string.format('  "%s": %d', s[1], res)
        end
    end
    local wparts = {}
    local wmap = {}
    for wid, res in pairs(F.sanitizeConfigWeapons(PERSIST.configWeapons)) do
        wmap[wid] = res
    end
    for wid, w in pairs(cch.weapons or {}) do
        local res = w and tonumber(w.resID)
        wid = tonumber(wid)
        if F.isValidWeaponPersistEntry(wid, res) then wmap[wid] = res end
    end
    for wid, res in pairs(wmap) do
        wparts[#wparts + 1] = string.format('    "%d": %d', wid, res)
    end
    table.sort(wparts)
    parts[#parts + 1] = '  "weapons": {\n' .. table.concat(wparts, ",\n") .. "\n  }"
    local vparts = {}
    local function appendVehicleSlots(SAMEER)
        for subType, slots in pairs(SAMEER or {}) do
            local sparts = {}
            if type(slots) == "table" then
                for idx, val in pairs(slots) do
                    local res = type(val) == "table" and tonumber(val.resID) or tonumber(val)
                    if res and res > 0 then
                        sparts[#sparts + 1] = string.format('      "%d": %d', tonumber(idx), res)
                    end
                end
            end
            table.sort(sparts)
            if #sparts > 0 then
                vparts[#vparts + 1] = string.format('    "%d": {\n%s\n    }', tonumber(subType), table.concat(sparts, ",\n"))
            end
        end
    end
    local hasCacheSlots = false
    for _ in pairs(cch.vehicleSlots or {}) do hasCacheSlots = true; break end
    if hasCacheSlots then
        appendVehicleSlots(cch.vehicleSlots)
    elseif PERSIST.configVehicleSlots then
        appendVehicleSlots(PERSIST.configVehicleSlots)
    end
    table.sort(vparts)
    parts[#parts + 1] = '  "vehicleSlots": {\n' .. table.concat(vparts, ",\n") .. "\n  }"
    if PERSIST.lobbyVehicleSubType and PERSIST.lobbyVehicleSubType > 0
        and PERSIST.lobbyVehicleSubType ~= CHASSIS_LIGHT_SUB
        and not F.isChassisLightId(PERSIST.lobbyVehicleResID)
        and F.isVehicleRes(PERSIST.lobbyVehicleResID) then
        parts[#parts + 1] = string.format('  "lobbyVehicleSubType": %d', PERSIST.lobbyVehicleSubType)
    end
    if PERSIST.lobbyVehicleResID and PERSIST.lobbyVehicleResID > 0
        and F.isVehicleRes(PERSIST.lobbyVehicleResID) then
        parts[#parts + 1] = string.format('  "lobbyVehicleResID": %d', PERSIST.lobbyVehicleResID)
    end
    if PERSIST.lobbyVehicleIns and PERSIST.lobbyVehicleIns > 0
        and F.isVehicleRes(PERSIST.lobbyVehicleResID or R.insToRes[PERSIST.lobbyVehicleIns]) then
        parts[#parts + 1] = string.format('  "lobbyVehicleIns": %d', PERSIST.lobbyVehicleIns)
    end
    local hres = tonumber(cch.hallThemeRes) or tonumber(PERSIST.hallThemeResID)
    if hres and hres > 0 and F.isInjectedRes(hres) then
        parts[#parts + 1] = string.format('  "hallTheme": %d', hres)
    end
    local cl = tonumber(PERSIST.configChassisLight)
    if F.isChassisLightId(cl) then
        parts[#parts + 1] = string.format('  "chassisLight": %d', cl)
    end
    local cmap = PERSIST.configChassisLightMap
    if cmap and next(cmap) then
        local cparts = {}
        for vid, lid in pairs(cmap) do
            vid, lid = tonumber(vid), tonumber(lid)
            if vid and vid > 0 and F.isChassisLightId(lid) then
                cparts[#cparts + 1] = string.format('    "%d": %d', vid, lid)
            end
        end
        table.sort(cparts)
        if #cparts > 0 then
            parts[#parts + 1] = '  "chassisLightMap": {\n' .. table.concat(cparts, ",\n") .. "\n  }"
        end
    end
    return "{\n" .. table.concat(parts, ",\n") .. "\n}\n"
end

function F.persistWrite(txt)
    if not (io and io.open) then return false end
    if PERSIST.path then
        local f
        pcall(function() f = io.open(PERSIST.path, "w") end)
        if f then f:write(txt) f:close() return true end
        PERSIST.path = nil
    end
    for _, p in ipairs(CONFIG_PATHS) do
        local f
        pcall(function() f = io.open(p, "w") end)
        if not f then
            pcall(function()
                local dir = p:match("^(.*)/[^/]+$")
                if dir and os and os.execute then os.execute('mkdir -p "' .. dir .. '"') end
            end)
            pcall(function() f = io.open(p, "w") end)
        end
        if f then
            f:write(txt) f:close()
            PERSIST.path = p
            return true
        end
    end
    return false
end

function F.persistFlush()
    if not PERSIST.dirty then return end
    PERSIST.dirty = false
    pcall(function()
        local txt = F.persistEncode()
        if txt == PERSIST.lastWritten then return end
        if F.persistWrite(txt) then
            PERSIST.lastWritten = txt
        end
    end)
end

F.persistMarkDirty = function()
    PERSIST.dirty = true
    if PERSIST.scheduled then return end
    PERSIST.scheduled = true
    F.later(2.0, function()
        PERSIST.scheduled = false
        F.persistFlush()
    end)
end

function F.persistParse(txt)
    if not txt or #txt == 0 then return nil end
    local out = { weapons = {}, vehicleSlots = {} }
    local parsed = false
    pcall(function()
        local t = json and json.decode and json.decode(txt)
        if type(t) == "table" then
            for k, v in pairs(t) do
                if k == "weapons" and type(v) == "table" then
                    for wk, wv in pairs(v) do
                        local wid, res = tonumber(wk), tonumber(wv)
                        if F.isValidWeaponPersistEntry(wid, res) then out.weapons[wid] = res end
                    end
                elseif k == "vehicleSlots" and type(v) == "table" then
                    for stk, slotMap in pairs(v) do
                        local st = tonumber(stk)
                        if st then
                            out.vehicleSlots[st] = out.vehicleSlots[st] or {}
                            for idxStr, res in pairs(slotMap) do
                                local idx, r = tonumber(idxStr), tonumber(res)
                                if idx and r and r > 0 then out.vehicleSlots[st][idx] = r end
                            end
                        end
                    end
                elseif k == "chassisLightMap" and type(v) == "table" then
                    out.chassisLightMap = {}
                    for vk, lv in pairs(v) do
                        local vid, lid = tonumber(vk), tonumber(lv)
                        if vid and lid and F.isChassisLightId(lid) then
                            out.chassisLightMap[vid] = lid
                        end
                    end
                else
                    local n = tonumber(v)
                    if n and n > 0 then out[k] = n end
                end
            end
            parsed = true
        end
    end)
    if not parsed then
        for k, v in txt:gmatch('"([%w_]+)"%s*:%s*(%d+)') do
            local n = tonumber(v)
            if n and n > 0 then
                local wid = tonumber(k)
                if wid and F.isValidWeaponPersistEntry(wid, n) then
                    out.weapons[wid] = n
                elseif not wid then
                    out[k] = n
                end
            end
        end
    end
    return out
end

function F.persistLoadFromDisk()
    if not (io and io.open) then return end
    pcall(function()
        for _, p in ipairs(CONFIG_PATHS) do
            local f
            pcall(function() f = io.open(p, "r") end)
            if f then
                local txt = f:read("*a")
                f:close()
                PERSIST.path = p
                PERSIST.lastWritten = txt
                PERSIST.loaded = F.persistParse(txt)
                F.persistLoadSlotsFromSaved(PERSIST.loaded)
                if PERSIST.loaded and PERSIST.loaded.vehicleSlots then
                    PERSIST.configVehicleSlots = PERSIST.loaded.vehicleSlots
                end
                if PERSIST.loaded and PERSIST.loaded.weapons then
                    local raw = PERSIST.loaded.weapons
                    PERSIST.configWeapons = F.sanitizeConfigWeapons(raw)
                    if next(raw) and not next(PERSIST.configWeapons) then
                        F.persistMarkDirty()
                    elseif next(raw) then
                        for wid, res in pairs(raw) do
                            if not F.isValidWeaponPersistEntry(tonumber(wid), tonumber(res)) then
                                F.persistMarkDirty()
                                break
                            end
                        end
                    end
                end
                PERSIST.lobbyVehicleSubType = tonumber(PERSIST.loaded and PERSIST.loaded.lobbyVehicleSubType)
                PERSIST.lobbyVehicleResID = tonumber(PERSIST.loaded and PERSIST.loaded.lobbyVehicleResID)
                PERSIST.lobbyVehicleIns = tonumber(PERSIST.loaded and PERSIST.loaded.lobbyVehicleIns)
                if PERSIST.lobbyVehicleSubType or PERSIST.lobbyVehicleIns or PERSIST.lobbyVehicleResID then
                    if F.isChassisLightId(PERSIST.lobbyVehicleResID)
                        or PERSIST.lobbyVehicleSubType == CHASSIS_LIGHT_SUB
                        or not F.isVehicleRes(PERSIST.lobbyVehicleResID) then
                        PERSIST.lobbyVehicleSubType = nil
                        PERSIST.lobbyVehicleResID = nil
                        PERSIST.lobbyVehicleIns = nil
                    else
                        _G.AddOutfitLobbyVeh = _G.AddOutfitLobbyVeh or {}
                        _G.AddOutfitLobbyVeh.manual = true
                        _G.AddOutfitLobbyVeh.subType = PERSIST.lobbyVehicleSubType
                        _G.AddOutfitLobbyVeh.resID = PERSIST.lobbyVehicleResID
                        _G.AddOutfitLobbyVeh.insID = PERSIST.lobbyVehicleIns
                    end
                end
                PERSIST.hallThemeResID = tonumber(PERSIST.loaded and PERSIST.loaded.hallTheme)
                PERSIST.hallThemeIns = nil
                if PERSIST.hallThemeResID then
                    _G.AddOutfitLobbyTheme = _G.AddOutfitLobbyTheme or {}
                    _G.AddOutfitLobbyTheme.manual = true
                    _G.AddOutfitLobbyTheme.resID = PERSIST.hallThemeResID
                end
                PERSIST.configChassisLight = tonumber(PERSIST.loaded and PERSIST.loaded.chassisLight)
                if PERSIST.loaded and PERSIST.loaded.chassisLightMap then
                    PERSIST.configChassisLightMap = PERSIST.loaded.chassisLightMap
                end
                return
            end
        end
    end)
end

function F.persistApplyLoaded()
    local saved = PERSIST.loaded
    if not saved then return end
    PERSIST.loaded = nil
    local cch = F.cache()
    local any = false
    for _, s in ipairs(PERSIST_SLOTS) do
        local res = tonumber(saved[s[1]]) or tonumber(PERSIST.configSlots and PERSIST.configSlots[s[1]])
        if res and res > 0 and not cch[s[2]] then
            local ins = R.resToIns[res]
            if ins then
                cch[s[2]], cch[s[3]] = res, ins
                _G[s[4]] = res
                any = true
            end
        end
    end
    PERSIST.configWeapons = F.sanitizeConfigWeapons(saved.weapons or PERSIST.configWeapons)
    if saved.weapons and F.reapplyWeaponsFromConfig() then
        any = true
    end
    if saved.vehicleSlots then
        PERSIST.configVehicleSlots = saved.vehicleSlots
        if F.reapplyVehicleSlotsFromConfig(true) then
            any = true
        end
    end
    if saved.hallTheme then
        PERSIST.hallThemeResID = tonumber(saved.hallTheme)
        if PERSIST.hallThemeResID and F.reapplyHallThemeFromConfig(true) then
            any = true
        end
    end
    if saved.chassisLight then
        PERSIST.configChassisLight = tonumber(saved.chassisLight)
    end
    if saved.chassisLightMap then
        PERSIST.configChassisLightMap = saved.chassisLightMap
    end
    if any then
        _matchApplied = false
        F.perfInvalidateLobby()
    end
end

function F.getEntity()
    local ok, dc = pcall(require, "client.slua.logic.wardrobe.logic_wardrobe_data_center")
    if not ok or not dc then return nil end
    local ok2, e = pcall(dc.GetWardrobeData)
    return ok2 and e or nil
end

function F.firstInsForRes(entity, resID)
    local arr = entity.ResIDToIndexArrayMap and entity.ResIDToIndexArrayMap[resID]
    if not arr then return nil end
    for _, idx in pairs(arr) do
        local d = entity._data[idx]
        if d and d.count and d.count > 0 then return d.insID end
    end
    return nil
end

function F.injectOne(entity, resID, insID)
    local ownedIns = F.firstInsForRes(entity, resID)
    if ownedIns then
        F.ensureInjectedItemAlive(entity, resID, ownedIns)
        R.resToIns[resID] = ownedIns
        R.insToRes[ownedIns] = resID
        F.indexWeaponSkin(resID, ownedIns)
        return true
    end
    local row = {
        instid = insID,
        res_id = resID,
        count = 1,
        lock_cnt = 0,
        isnew = 0,
        valid_hours = 0,
        expire_ts = 0,
    }
    entity:AddData(row)
    pcall(function()
        if entity.LoadConfigForData and CDataTable and CDataTable.GetTableData then
            local idx = entity._DataCount
            if idx and entity._data[idx] then
                entity:LoadConfigForData(entity._data[idx], CDataTable.GetTableData)
            end
        end
    end)
    R.insToRes[insID] = resID
    R.resToIns[resID] = insID
    F.indexWeaponSkin(resID, insID)
    return true
end

function F.reviveExpiredOwned(entity)
    entity = entity or F.getEntity()
    if not entity or not entity.bInit or not entity._data then return end
    local now = 0
    pcall(function()
        local TimeUtil = require("client.common.time_util")
        now = tonumber(TimeUtil.GetServerTimeInSec()) or 0
    end)
    if now <= 0 then return end
    _G.AddOutfitRevived = _G.AddOutfitRevived or {}
    local n = 0
    for i = 1, (entity._DataCount or #entity._data) do
        local d = entity._data[i]
        if d then
            local exp = tonumber(d.expire_ts or d.expireTS) or 0
            local res = tonumber(d.res_id or d.resID)
            local ins = tonumber(d.instid or d.insID)
            if exp > 0 and exp <= now and res and ins and (tonumber(d.count) or 0) > 0 then
                d.expire_ts = 0
                if d.expireTS ~= nil then d.expireTS = 0 end
                if d.valid_hours ~= nil then d.valid_hours = 0 end
                _G.AddOutfitRevived[res] = ins
                n = n + 1
            end
        end
    end
end

function F.mergeRevivedIntoMaps()
    for res, ins in pairs(_G.AddOutfitRevived or {}) do
        if not R.resToIns[res] then
            R.resToIns[res] = ins
            R.insToRes[ins] = res
            F.indexWeaponSkin(res, ins)
        end
    end
end

function F.injectArmory(resID, insID)
    local wid = F.weaponIdFromSkin(resID)
    if not wid then return end
    local Arm = require("client.logic.armory.logic_armory")
    Arm.rsp_list = Arm.rsp_list or { skin_list = {}, install_list = {} }
    Arm.rsp_list.skin_list = Arm.rsp_list.skin_list or {}
    Arm.rsp_list.install_list = Arm.rsp_list.install_list or {}
    if not Arm.rsp_list.skin_list[wid] then Arm.rsp_list.skin_list[wid] = {} end
    Arm.rsp_list.skin_list[wid][resID] = { is_open = 1 }
    Arm.WardrobeInsList = Arm.WardrobeInsList or {}
    Arm.WardrobeInsList[resID] = insID
end

function F.mergeInjectedArmorySkins()
    for _, skins in pairs(R.byWeapon) do
        for resID, insID in pairs(skins) do
            F.injectArmory(resID, insID)
        end
    end
end

function F.injectAll(entity)
    if _G.LexusConfig and _G.LexusConfig.ModSkin == false then return false end -- Bá» qua náº¿u táº¯t Mod Skin
    entity = entity or F.getEntity()
    if not entity or not entity.bInit then return false end
    local n, nNew = 0, 0
    for i, resID in ipairs(ITEMS) do
        local insID = INS_BASE + i
        local had = R.resToIns[resID] ~= nil
        if F.injectOne(entity, resID, insID) then
            n = n + 1
            if not had then nNew = nNew + 1 end
            local c = F.cfg(resID)
            if GUN_SUB[F.subType(c)] or F.subType(c) == MELEE_ID then
                F.injectArmory(resID, insID)
            end
        end
    end
    if not _G.AddOutfitUnexpireDone then
        _G.AddOutfitUnexpireDone = true
        pcall(F.reviveExpiredOwned, entity)
    end
    F.mergeRevivedIntoMaps()
    F.sanitizeAllInjectedExpire()
    F.ensureInjectedResources()
    return n > 0
end

function F.refreshWardrobe()
    pcall(function()
        if EventSystem and EVENTTYPE_WARDROBE then
            if EVENTID_WARDROBE_UPDATE_ITEM_LIST then
                EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_ITEM_LIST)
            end
            if EVENTID_WARDROBE_UPDATE_AVATAR_LIST then
                EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_AVATAR_LIST)
            end
            if EVENTID_WARDROBE_UPDATE_GUN_LIST then
                EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_GUN_LIST, -1)
            end
        end
    end)
end

function F.refreshWardrobeOnce()
    if LOBBY.wardrobeRefreshed then return end
    LOBBY.wardrobeRefreshed = true
    F.refreshWardrobe()
end

function F.scheduleInjectRefresh()
    LOBBY.injectRefreshGen = (LOBBY.injectRefreshGen or 0) + 1
    local gen = LOBBY.injectRefreshGen
    F.later(0.4, function()
        if gen ~= LOBBY.injectRefreshGen then return end
        F.refreshWardrobe()
    end)
end

function F.putOnOutfit(insID)
    insID = tonumber(insID)
    local resID = R.insToRes[insID]
    if not resID then
        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
        local d0 = wd:GetValidHallDepotItemDataByInsID(insID) or wd:GetHallDepotItemDataByInsID(insID)
        resID = d0 and tonumber(d0.resID or d0.res_id)
    end
    if not resID or resID <= 0 then return end
    if not R.insToRes[insID] then R.insToRes[insID] = resID; R.resToIns[resID] = insID end
    F.ensureDepotItemValid(insID, resID)
    if not F.isResourcesReady(resID) then
        F.requestResourceDownload(resID)
        return
    end
    if not F.isSuitRes(resID) then
        if F.isTshirtRes(resID) then return F.putOnRoleWear(insID) end
        return
    end
    local wd = require("client.slua.logic.wardrobe.wardrobe_data")
    local d = wd:GetHallDepotItemDataByInsID(insID)
    if not d then return end

    local suitFilter = function(r) return F.isSuitRes(r) end
    local oldIns, oldRes = F.findWornInsBySubType(OUTFIT_SUB, suitFilter)
    F.removeRoleWearBySubType(OUTFIT_SUB, suitFilter)
    F.saveEquip(resID, insID)

    local slot = PKG_SLOT
    pcall(function()
        local wfu = require("client.slua.logic.wardrobe.fashionbag.wardrobe_fashion_utils")
        local idx = wfu.GetRoleWearIndexBySubType and wfu:GetRoleWearIndexBySubType(OUTFIT_SUB)
        if idx then slot = idx end
    end)

    local olditem
    if oldIns and oldIns ~= insID then
        olditem = { res_id = oldRes or R.insToRes[oldIns], count = 1, instid = oldIns }
    end

    local WRH = require("client.network.Protocol.WardRobeHandler")
    local item = { res_id = resID, count = 1, instid = insID }
    WRH.on_depot_put_on_rsp(NET_OK, item, olditem, slot, insID, oldIns or 0)

    pcall(function()
        local av = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
        av:AddToWearInfo(OUTFIT_SUB, insID, resID, 0, 0)
        F.syncFashionBagRolewear()
    end)
end

function F.putOnHat(insID)
    insID = tonumber(insID)
    local resID = R.insToRes[insID]
    if not resID then
        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
        local d0 = wd:GetValidHallDepotItemDataByInsID(insID) or wd:GetHallDepotItemDataByInsID(insID)
        resID = d0 and tonumber(d0.resID or d0.res_id)
    end
    if not resID or resID <= 0 then return end
    if not R.insToRes[insID] then R.insToRes[insID] = resID; R.resToIns[resID] = insID end
    F.ensureDepotItemValid(insID, resID)
    if not F.isResourcesReady(resID) then
        F.requestResourceDownload(resID)
        return
    end
    local wd = require("client.slua.logic.wardrobe.wardrobe_data")
    local d = wd:GetHallDepotItemDataByInsID(insID)
    if not d then return end
    local st = F.subType(F.cfg(resID)) or HAT_SUB

    local oldIns, oldRes = F.findWornInsBySubType(st)
    if not oldIns and st ~= HAT_SUB then
        oldIns, oldRes = F.findWornInsBySubType(HAT_SUB)
    end
    F.removeRoleWearBySubType(st)
    if st ~= HAT_SUB then F.removeRoleWearBySubType(HAT_SUB) end
    F.saveEquip(resID, insID)

    local slot = 1
    pcall(function()
        local wfu = require("client.slua.logic.wardrobe.fashionbag.wardrobe_fashion_utils")
        local idx = wfu.GetRoleWearIndexBySubType and wfu:GetRoleWearIndexBySubType(st)
        if idx then slot = idx end
    end)

    local olditem
    if oldIns and oldIns ~= insID then
        olditem = { res_id = oldRes or R.insToRes[oldIns], count = 1, instid = oldIns }
    end

    local WRH = require("client.network.Protocol.WardRobeHandler")
    local item = { res_id = resID, count = 1, instid = insID, color = d.color, pattern = d.pattern }
    WRH.on_depot_put_on_rsp(NET_OK, item, olditem, slot, insID, oldIns or 0)

    pcall(function()
        local fbd = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
        fbd:SetHeadShow(insID)
        F.syncFashionBagRolewear()
    end)
    F.invalidateSocialWearCache()
end

function F.putOnFaceAccessory(insID)
    insID = tonumber(insID)
    local resID = R.insToRes[insID]
    if not resID then
        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
        local d0 = wd:GetValidHallDepotItemDataByInsID(insID) or wd:GetHallDepotItemDataByInsID(insID)
        resID = d0 and tonumber(d0.resID or d0.res_id)
    end
    if not resID or resID <= 0 then return end
    if not R.insToRes[insID] then R.insToRes[insID] = resID; R.resToIns[resID] = insID end
    F.ensureDepotItemValid(insID, resID)
    if not F.isResourcesReady(resID) then
        F.requestResourceDownload(resID)
        return
    end
    local wd = require("client.slua.logic.wardrobe.wardrobe_data")
    local d = wd:GetHallDepotItemDataByInsID(insID)
    if not d then return end
    local st = F.subType(F.cfg(resID)) or tonumber(d.itemSubType)
    if not FACE_SUBS[st] then return end

    local oldIns, oldRes = F.findWornInsBySubType(st)
    F.removeRoleWearBySubType(st)
    F.saveEquip(resID, insID)

    local slot = (st == MASK_SUB) and 2 or 6
    pcall(function()
        local wfu = require("client.slua.logic.wardrobe.fashionbag.wardrobe_fashion_utils")
        local idx = wfu.GetRoleWearIndexBySubType and wfu:GetRoleWearIndexBySubType(st)
        if idx then slot = idx end
    end)

    local olditem
    if oldIns and oldIns ~= insID then
        olditem = { res_id = oldRes or R.insToRes[oldIns], count = 1, instid = oldIns }
    end

    local WRH = require("client.network.Protocol.WardRobeHandler")
    local item = { res_id = resID, count = 1, instid = insID, color = d.color, pattern = d.pattern }
    WRH.on_depot_put_on_rsp(NET_OK, item, olditem, slot, insID, oldIns or 0)

    pcall(function() F.syncFashionBagRolewear() end)
    F.invalidateSocialWearCache()
end

function F.canRoleWear(resID, st)
    st = st or F.subType(F.cfg(resID))
    if FACE_SUBS[st] or BODY_SUBS[st] then return true end
    if st == GLOVES_SUB then return true end
    if st == OUTFIT_SUB and F.wardrobeTab(resID) == TAB_CLOTHES then return true end
    return false
end

F.putOnRoleWear = function(insID)
    insID = tonumber(insID)
    local resID = R.insToRes[insID]
    if not resID then
        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
        local d0 = wd:GetValidHallDepotItemDataByInsID(insID) or wd:GetHallDepotItemDataByInsID(insID)
        resID = d0 and tonumber(d0.resID or d0.res_id)
    end
    if not resID or resID <= 0 then return end
    if not R.insToRes[insID] then R.insToRes[insID] = resID; R.resToIns[resID] = insID end
    F.ensureDepotItemValid(insID, resID)
    if not F.isResourcesReady(resID) then
        F.requestResourceDownload(resID)
        return
    end
    local wd = require("client.slua.logic.wardrobe.wardrobe_data")
    local d = wd:GetHallDepotItemDataByInsID(insID)
    if not d then return end
    local st = F.subType(F.cfg(resID)) or tonumber(d.itemSubType)
    if not F.canRoleWear(resID, st) then return end

    local filterFn
    if st == OUTFIT_SUB then
        filterFn = function(r) return F.wardrobeTab(r) == TAB_CLOTHES end
    end
    local oldIns, oldRes = F.findWornInsBySubType(st, filterFn)
    F.removeRoleWearBySubType(st, filterFn)
    F.saveEquip(resID, insID)

    local slot = PKG_SLOT
    pcall(function()
        local wfu = require("client.slua.logic.wardrobe.fashionbag.wardrobe_fashion_utils")
        local idx = wfu.GetRoleWearIndexBySubType and wfu:GetRoleWearIndexBySubType(st)
        if idx then slot = idx end
    end)

    local olditem
    if oldIns and oldIns ~= insID then
        olditem = { res_id = oldRes or R.insToRes[oldIns], count = 1, instid = oldIns }
    end

    local WRH = require("client.network.Protocol.WardRobeHandler")
    local item = { res_id = resID, count = 1, instid = insID, color = d.color, pattern = d.pattern }
    WRH.on_depot_put_on_rsp(NET_OK, item, olditem, slot, insID, oldIns or 0)

    if BAG_SUBS[st] or HELMET_SUBS[st] then
        pcall(function()
            DataMgr.equipmentSkinInsIDTable = DataMgr.equipmentSkinInsIDTable or {}
            DataMgr.equipmentSkinInsIDTable[st] = insID
            local fbd = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
            local bag = fbd.GetCurrentFashionBag and fbd:GetCurrentFashionBag()
            if bag then
                if st == 504 or st == 501 then
                    DataMgr.equipmentSkinInsIDTable[504] = insID
                    bag.bag_skin = insID
                elseif st == 505 or st == 502 then
                    DataMgr.equipmentSkinInsIDTable[505] = insID
                    bag.helmet_skin = insID
                end
            end
        end)
    end

    pcall(function() F.syncFashionBagRolewear() end)
    F.invalidateSocialWearCache()
end

function F.putOnGloves(insID)
    insID = tonumber(insID)
    local resID = R.insToRes[insID]
    if not resID then
        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
        local d0 = wd:GetValidHallDepotItemDataByInsID(insID) or wd:GetHallDepotItemDataByInsID(insID)
        resID = d0 and tonumber(d0.resID or d0.res_id)
    end
    if not resID or resID <= 0 then return end
    if not R.insToRes[insID] then R.insToRes[insID] = resID; R.resToIns[resID] = insID end
    F.ensureDepotItemValid(insID, resID)
    if not F.isResourcesReady(resID) then
        F.requestResourceDownload(resID)
        return
    end
    local wd = require("client.slua.logic.wardrobe.wardrobe_data")
    local d = wd:GetHallDepotItemDataByInsID(insID)
    if not d then return end

    local oldIns, oldRes = F.findWornInsBySubType(GLOVES_SUB)
    F.removeRoleWearBySubType(GLOVES_SUB)
    F.saveEquip(resID, insID)

    local slot = 8
    pcall(function()
        local wfu = require("client.slua.logic.wardrobe.fashionbag.wardrobe_fashion_utils")
        local idx = wfu.GetRoleWearIndexBySubType and wfu:GetRoleWearIndexBySubType(GLOVES_SUB)
        if idx then slot = idx end
    end)

    local olditem
    if oldIns and oldIns ~= insID then
        olditem = { res_id = oldRes or R.insToRes[oldIns], count = 1, instid = oldIns }
    end

    local WRH = require("client.network.Protocol.WardRobeHandler")
    local item = { res_id = resID, count = 1, instid = insID, color = d.color, pattern = d.pattern, expire_ts = 0 }
    WRH.on_depot_put_on_rsp(NET_OK, item, olditem, slot, insID, oldIns or 0)

    pcall(function()
        local logic_wardrobe_avatar = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
        logic_wardrobe_avatar:AddToWearInfo(GLOVES_SUB, insID, resID, d.color or 0, d.pattern or 0)
        DataMgr.UpdateRoleWearData(insID, oldIns or 0)
        logic_wardrobe_avatar:AvatarChange(resID, true, d.color, d.pattern)
    end)
    pcall(function()
        local wl = require("client.slua.logic.wardrobe.logic_wardrobe_new")
        if wl.SetClickItemInsId then wl:SetClickItemInsId(insID) end
    end)
    pcall(function()
        if EventSystem and EVENTTYPE_WARDROBE then
            if EVENTID_WARDROBE_UPDATE_ITEM_LIST then
                EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_ITEM_LIST)
            end
            if EVENTID_WARDROBE_UPDATE_AVATAR_LIST then
                EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_AVATAR_LIST)
            end
        end
    end)
    F.invalidateSocialWearCache()
end

function F.ensureDepotItemValid(insID, resID)
    insID = tonumber(insID)
    if not insID then return end
    pcall(function()
        local entity = F.getEntity()
        if entity and entity.GetDataByInsID then
            local d = entity:GetDataByInsID(insID)
            if d then
                d.expire_ts = 0
                if d.expireTS ~= nil then d.expireTS = 0 end
                if d.valid_hours ~= nil then d.valid_hours = 0 end
            end
        end
        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
        local hd = wd:GetHallDepotItemDataByInsID(insID)
        if hd then
            hd.expire_ts = 0
            if hd.expireTS ~= nil then hd.expireTS = 0 end
            if hd.valid_hours ~= nil then hd.valid_hours = 0 end
        end
    end)
end

function F.clearItemExpire(itemData, insID, resID)
    F.ensureDepotItemValid(insID, resID)
    if type(itemData) == "table" then
        itemData.expireTS = 0
        itemData.expire_ts = 0
        itemData.expireTs = 0
    end
end

function F.onGlideClick(self, itemData)
    if not itemData then return end
    local insID = tonumber(itemData.ins_id)
    local resID = tonumber(itemData.res_id)
    F.clearItemExpire(itemData, insID, resID)
    local isGlide = resID and F.isGlideRes(resID)
    if not isGlide and itemData.itemSubType then
        isGlide = GLIDER_SUBS[tonumber(itemData.itemSubType)] == true
    end
    if insID and resID and isGlide then
        F.saveEquip(resID, insID)
        if F.putOnGlider(insID) then
            pcall(function()
                if self.ShowGlide then self:ShowGlide(resID) end
                if self.ChangeItemStatus then self:ChangeItemStatus(insID, true) end
            end)
            return
        end
    end
    if _G.AddOutfitGlideClickOrig then
        F.clearItemExpire(itemData, insID, resID)
        return _G.AddOutfitGlideClickOrig(self, itemData)
    end
end

function F.onParachuteClick(self, itemData)
    if not itemData then return end
    local insID = tonumber(itemData.ins_id)
    local resID = tonumber(itemData.res_id)
    F.clearItemExpire(itemData, insID, resID)
    if insID and resID and F.isParachuteRes(resID) then
        F.saveEquip(resID, insID)
        if F.putOnParachute(insID) then
            pcall(function()
                if self.ChangeItemStatus then self:ChangeItemStatus(insID, true) end
            end)
            return
        end
    end
    if _G.AddOutfitParaClickOrig then
        return _G.AddOutfitParaClickOrig(self, itemData)
    end
end

function F.hookAirborneClick()
    pcall(function()
        local WG = require("client.slua.umg.Wardrobe.subtab_gliding")
        if WG then
            if not WG._AddOutfitGlideWrapped then
                WG._AddOutfitGlideWrapped = true
                _G.AddOutfitGlideClickOrig = WG.ClickItem
            end
            WG.ClickItem = function(self, itemData)
                return F.onGlideClick(self, itemData)
            end
        end
        local WP = require("client.slua.umg.Wardrobe.subtab_parachute")
        if WP then
            if not WP._AddOutfitParaWrapped then
                WP._AddOutfitParaWrapped = true
                _G.AddOutfitParaClickOrig = WP.ClickItem
            end
            WP.ClickItem = function(self, itemData)
                return F.onParachuteClick(self, itemData)
            end
        end
    end)
    pcall(function()
        local fbd = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
        if fbd and not fbd._AddOutfitAirborneFBHooked then
            fbd._AddOutfitAirborneFBHooked = true
            local oG = fbd.UpdateAircraftOrGliding
            fbd.UpdateAircraftOrGliding = function(self, putOnID, bAircraft)
                local r = oG(self, putOnID, bAircraft)
                local ins = tonumber(putOnID)
                if ins and ins > 0 then
                    local wd = require("client.slua.logic.wardrobe.wardrobe_data")
                    local d = wd:GetValidHallDepotItemDataByInsID(ins) or wd:GetHallDepotItemDataByInsID(ins)
                    local res = d and tonumber(d.resID)
                    if res and F.isGlideRes(res) then F.saveEquip(res, ins) end
                end
                return r
            end
            local oP = fbd.UpdateParachute
            if oP then
                fbd.UpdateParachute = function(self, insID)
                    local r = oP(self, insID)
                    local ins = tonumber(insID)
                    if ins and ins > 0 then
                        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
                        local d = wd:GetValidHallDepotItemDataByInsID(ins) or wd:GetHallDepotItemDataByInsID(ins)
                        local res = d and tonumber(d.resID)
                        if res and F.isParachuteRes(res) then F.saveEquip(res, ins) end
                    end
                    return r
                end
            end
        end
    end)
    pcall(function()
        if not ModuleManager or not ModuleManager.GetModule then return end
        local FB = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
        if FB and not FB._AddOutfitFBBagHooked then
            FB._AddOutfitFBBagHooked = true
            local o = FB.PutOnFashionBagItem
            FB.PutOnFashionBagItem = function(self, itemData)
                if itemData then
                    F.clearItemExpire(itemData, itemData.ins_id, itemData.res_id)
                end
                local r = o(self, itemData)
                if itemData then
                    local res = tonumber(itemData.res_id)
                    local ins = tonumber(itemData.ins_id)
                    if res and ins and (F.isGlideRes(res) or F.isParachuteRes(res)) then
                        F.saveEquip(res, ins)
                    end
                end
                return r
            end
        end
    end)
end

function F.putOnParachute(insID)
    insID = tonumber(insID)
    local resID = R.insToRes[insID]
    if not resID then
        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
        local d = wd:GetValidHallDepotItemDataByInsID(insID) or wd:GetHallDepotItemDataByInsID(insID)
        resID = d and tonumber(d.resID)
    end
    if not resID or not F.isParachuteRes(resID) then return false end
    if not R.insToRes[insID] then R.insToRes[insID] = resID end
    F.ensureDepotItemValid(insID, resID)
    F.saveEquip(resID, insID)
    F.ensureInjectedItemAlive(nil, resID, insID)
    local ready = F.isResourcesReady(resID)
    if not ready then F.requestResourceDownload(resID) end
    pcall(function()
        local fbd = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
        if fbd.SetParachute then fbd:SetParachute(insID) end
        if fbd.UpdateParachute then fbd:UpdateParachute(insID) end
    end)
    if ready then
        local item = {
            res_id = resID, resID = resID,
            instid = insID, ins_id = insID, insID = insID,
            expire_ts = 0, expireTS = 0, count = 1,
        }
        local WRH = require("client.network.Protocol.WardRobeHandler")
        WRH.on_depot_put_on_rsp(NET_OK, item, nil, 1, insID, 0)
    end
    return true
end

function F.putOnGlider(insID)
    insID = tonumber(insID)
    local resID = R.insToRes[insID]
    if not resID then
        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
        local d = wd:GetValidHallDepotItemDataByInsID(insID) or wd:GetHallDepotItemDataByInsID(insID)
        resID = d and tonumber(d.resID)
    end
    if not resID or resID <= 0 then return false end
    local st = F.depotSubType(insID, resID)
    if not F.isGlideRes(resID) and not GLIDER_SUBS[st] then return false end
    if not R.insToRes[insID] then R.insToRes[insID] = resID end
    F.ensureDepotItemValid(insID, resID)
    F.saveEquip(resID, insID)
    F.ensureInjectedItemAlive(nil, resID, insID)
    local ready = F.isResourcesReady(resID)
    if not ready then F.requestResourceDownload(resID) end
    local bAircraft = false
    pcall(function()
        local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
        local st = F.subType(F.cfg(resID))
        bAircraft = ModelDisplayTypeHelper.IsGlideSmoke(st)
    end)
    pcall(function()
        local fbd = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
        if fbd.UpdateAircraftOrGliding then
            fbd:UpdateAircraftOrGliding(insID, bAircraft)
        elseif fbd.SetGliding then
            fbd:SetGliding(insID)
            if DataMgr.UpdateEffect then DataMgr.UpdateEffect(insID) end
        end
    end)
    if ready then
        local item = {
            res_id = resID, resID = resID,
            instid = insID, ins_id = insID, insID = insID,
            expire_ts = 0, expireTS = 0, count = 1,
        }
        local WRH = require("client.network.Protocol.WardRobeHandler")
        WRH.on_depot_put_on_rsp(NET_OK, item, nil, 1, insID, 0)
    end
    return true
end

function F.syncAirborneToDataMgr()
    F.applyPersistSlotsToCache()
    local cch = F.cache()
    local paraRes = F.getDesiredParachuteRes()
    local gliderRes = F.getDesiredGliderRes()
    if paraRes and paraRes > 0 and not cch.parachuteIns then
        cch.parachuteIns = F.resolveInsForRes(paraRes)
        cch.parachuteRes = paraRes
    end
    if gliderRes and gliderRes > 0 and not cch.gliderIns then
        cch.gliderIns = F.resolveInsForRes(gliderRes)
        cch.gliderRes = gliderRes
    end
    pcall(function()
        local fbd = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
        if cch.parachuteIns and tonumber(cch.parachuteIns) > 0 then
            if fbd.SetParachute then fbd:SetParachute(cch.parachuteIns) end
            if DataMgr.roleData then DataMgr.roleData.parachute = tostring(cch.parachuteIns) end
        end
        if cch.gliderIns and tonumber(cch.gliderIns) > 0 then
            local bAircraft = false
            if cch.gliderRes then
                pcall(function()
                    local MDH = require("client.logic.avatar.ModelDisplayTypeHelper")
                    bAircraft = not MDH.IsGlideSmoke(F.subType(F.cfg(cch.gliderRes)))
                end)
            end
            if fbd.UpdateAircraftOrGliding then
                fbd:UpdateAircraftOrGliding(cch.gliderIns, bAircraft)
            elseif fbd.SetGliding then
                fbd:SetGliding(cch.gliderIns)
                if DataMgr.UpdateEffect then DataMgr.UpdateEffect(cch.gliderIns) end
            end
            if DataMgr.roleData then
                if bAircraft then
                    DataMgr.roleData.aircraft_put_id = tostring(cch.gliderIns)
                    DataMgr.gliding = cch.gliderIns
                else
                    DataMgr.roleData.gliding = tostring(cch.gliderIns)
                end
            end
        end
    end)
end

function F.putOnGenericInjected(insID)
    insID = tonumber(insID)
    local resID = R.insToRes[insID]
    if not resID then return end
    if not F.isResourcesReady(resID) then
        F.requestResourceDownload(resID)
        return
    end
    F.saveEquip(resID, insID)
    local WRH = require("client.network.Protocol.WardRobeHandler")
    WRH.on_depot_put_on_rsp(NET_OK, { res_id = resID, count = 1, instid = insID }, nil, 1, insID, 0)
end

function F.clearEquipCache(resID)
    local st = F.subType(F.cfg(resID))
    local cch = F.cache()
    if st == OUTFIT_SUB then
        if F.wardrobeTab(resID) == TAB_CLOTHES then
            cch.tshirtRes, cch.tshirtIns = nil, nil
            _G.AddOutfitLastLobbyTshirtRes = nil
            F.persistForgetSlot("tshirt")
        else
            cch.outfitRes, cch.outfitIns = nil, nil
            _G.AddOutfitLastLobbyOutfitRes = nil
            F.persistForgetSlot("outfit")
        end
    elseif st == HAT_SUB or HEAD_SUBS[st] then
        cch.hatRes, cch.hatIns = nil, nil
        _G.AddOutfitLastLobbyHatRes = nil
        F.persistForgetSlot("hat")
    elseif st == MASK_SUB then
        cch.maskRes, cch.maskIns = nil, nil
        _G.AddOutfitLastLobbyMaskRes = nil
        F.persistForgetSlot("mask")
    elseif st == GLASS_SUB then
        cch.glassRes, cch.glassIns = nil, nil
        _G.AddOutfitLastLobbyGlassRes = nil
        F.persistForgetSlot("glass")
    elseif st == PANTS_SUB then
        cch.pantsRes, cch.pantsIns = nil, nil
        _G.AddOutfitLastLobbyPantsRes = nil
        F.persistForgetSlot("pants")
    elseif st == SHOES_SUB then
        cch.shoesRes, cch.shoesIns = nil, nil
        _G.AddOutfitLastLobbyShoesRes = nil
        F.persistForgetSlot("shoes")
    elseif BAG_SUBS[st] then
        cch.bagRes, cch.bagIns = nil, nil
        _G.AddOutfitLastLobbyBagRes = nil
        F.persistForgetSlot("bag")
    elseif HELMET_SUBS[st] then
        cch.helmetRes, cch.helmetIns = nil, nil
        _G.AddOutfitLastLobbyHelmetRes = nil
        F.persistForgetSlot("helmet")
    elseif st == PARACHUTE_SUB then
        cch.parachuteRes, cch.parachuteIns = nil, nil
        _G.AddOutfitLastLobbyParachuteRes = nil
        F.persistForgetSlot("parachute")
    elseif F.isGlideRes(resID) then
        cch.gliderRes, cch.gliderIns = nil, nil
        _G.AddOutfitLastLobbyGliderRes = nil
        F.persistForgetSlot("glider")
    elseif st == GLOVES_SUB then
        cch.glovesRes, cch.glovesIns = nil, nil
        _G.AddOutfitLastLobbyGlovesRes = nil
        F.persistForgetSlot("gloves")
    end
    _matchApplied = false
    F.invalidateSocialWearCache()
    F.perfInvalidateLobby()
    F.persistMarkDirty()
end

function F.takeOffInjected(insID)
    insID = tonumber(insID)
    local resID = R.insToRes[insID]
    if not resID then return end
    local st = F.subType(F.cfg(resID))

    pcall(function()
        local WRH = require("client.network.Protocol.WardRobeHandler")
        WRH.on_depot_put_down_rsp(NET_OK, { res_id = resID, count = 1 }, insID)
    end)

    pcall(function()
        local AvatarData = require("client.logic.data.AvatarData")
        AvatarData.RemoveRoleWearDataByValue(insID)
    end)
    if st == HAT_SUB or HEAD_SUBS[st] then
        pcall(function()
            local fbd = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
            local bag = fbd.GetCurrentFashionBag and fbd:GetCurrentFashionBag()
            if bag and tonumber(bag.head_show) == insID then fbd:SetHeadShow(0) end
        end)
    end
    if BAG_SUBS[st] or HELMET_SUBS[st] then
        pcall(function()
            local t = DataMgr.equipmentSkinInsIDTable
            if t then
                for _, k in ipairs({ st, 504, 505 }) do
                    if tonumber(t[k]) == insID then t[k] = 0 end
                end
            end
            local fbd = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
            local bag = fbd.GetCurrentFashionBag and fbd:GetCurrentFashionBag()
            if bag then
                if tonumber(bag.bag_skin) == insID then bag.bag_skin = 0 end
                if tonumber(bag.helmet_skin) == insID then bag.helmet_skin = 0 end
            end
        end)
    end

    F.clearEquipCache(resID)
    pcall(function() F.syncFashionBagRolewear() end)
end

function F.syncWeaponArmorySilent(weaponID, insID)
    weaponID, insID = tonumber(weaponID), tonumber(insID)
    if not weaponID or not insID or not F.isInjectedIns(insID) then return end
    local resID = R.insToRes[insID]
    if not resID then return end
    local Arm = require("client.logic.armory.logic_armory")
    Arm.rsp_list = Arm.rsp_list or { skin_list = {}, install_list = {} }
    Arm.rsp_list.install_list = Arm.rsp_list.install_list or {}
    F.injectArmory(resID, insID)
    Arm.rsp_list.install_list[weaponID] = { skin_id = insID }
    pcall(function()
        local fbd = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
        if fbd.UpdateCurrentFashionBagWeaponSkin then
            fbd:UpdateCurrentFashionBagWeaponSkin(weaponID, insID)
        end
    end)
end

function F.equipWeaponSkin(weaponID, insID, forceVisual)
    weaponID, insID = tonumber(weaponID), tonumber(insID)
    if not weaponID or not insID or not F.isInjectedIns(insID) then return false end
    local resID = R.insToRes[insID]
    if not resID then return false end

    _G.AddOutfitWeaponEquipped = _G.AddOutfitWeaponEquipped or {}
    if not forceVisual and F.isWeaponVisuallyEquipped(weaponID, insID) then
        F.syncWeaponArmorySilent(weaponID, insID)
        return false
    end
    F.saveEquip(resID, insID)

    local Arm = require("client.logic.armory.logic_armory")
    local fbd = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
    local HT = require("client.logic.lobby.hall_theme_utils")
    local wgl = require("client.slua.logic.wardrobe.logic_wardrobe_gun")

    F.injectArmory(resID, insID)
    Arm.rsp_list.install_list[weaponID] = { skin_id = insID }
    if fbd.UpdateCurrentFashionBagWeaponSkin then
        fbd:UpdateCurrentFashionBagWeaponSkin(weaponID, insID)
    end

    local bagIdx = fbd:GetFashionBagUseIndex()
    HT.proc_skin_list_chg("weapon_skin", weaponID, insID, bagIdx, {})

    wgl:SetGunID(weaponID)
    wgl:UpdateCurrentGunAvatar(weaponID, insID)

    if EventSystem and EVENTTYPE_ARMORY and EVENTID_ARMORY_EQUIP_STAT_CHANGE then
        EventSystem:postEvent(EVENTTYPE_ARMORY, EVENTID_ARMORY_EQUIP_STAT_CHANGE, resID)
    end
    if EventSystem and EVENTTYPE_WARDROBE and EVENTID_WARDROBE_UPDATE_CURRENT_PUT_ON_GUN then
        EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_CURRENT_PUT_ON_GUN, resID)
    end
    _G.AddOutfitWeaponEquipped[weaponID] = insID
    return true
end

local SOCIAL = _G.AddOutfitSocialState or {}
_G.AddOutfitSocialState = SOCIAL
SOCIAL.debGen = SOCIAL.debGen or 0
SOCIAL.wearPatchKey = SOCIAL.wearPatchKey or nil
SOCIAL.snapshotKey = SOCIAL.snapshotKey or nil
SOCIAL.fullSnapshot = SOCIAL.fullSnapshot or nil

function F.socialDebounce(sec, fn)
    SOCIAL.debGen = (SOCIAL.debGen or 0) + 1
    local gen = SOCIAL.debGen
    F.later(sec, function()
        if gen ~= SOCIAL.debGen then return end
        pcall(fn)
    end)
end

function F.getLobbyCurPage()
    local p = nil
    pcall(function()
        local LMC = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
        if LMC.GetCurPage then p = LMC.GetCurPage() end
    end)
    return p
end

function F.isLobbyLeftPage()
    return ENUM_LobbyPageType and F.getLobbyCurPage() == ENUM_LobbyPageType.Left
end

function F.getWeaponSkinResFast()
    local cch = F.cache()
    local wid = tonumber(DataMgr.Weapon_ID) or 0
    local w = wid > 0 and cch.weapons[wid] or nil
    if w and w.resID and w.resID > 0 then return w.resID end
    for _, ww in pairs(cch.weapons) do
        if ww.resID and ww.resID > 0 then return ww.resID end
    end
    return nil
end

function F.resolveLobbyWeaponSkinRes()
    if LOBBY.skinResolved then return LOBBY.cachedSkin end
    local wid = tonumber(DataMgr.Weapon_ID) or 0
    local skin = F.getWeaponSkinResFast()
    if skin and skin > 0 then return skin end

    if wid > 0 then
        local fromMatch = F.getMatchWeaponSkin(wid)
        if fromMatch and fromMatch > 0 then return fromMatch end
    end
    if MATCH_CONFIG.weaponSkins then
        for _, s in pairs(MATCH_CONFIG.weaponSkins) do
            s = tonumber(s)
            if s and s > 0 then return s end
        end
    end

    pcall(function()
        local Arm = require("client.logic.armory.logic_armory")
        local entry = Arm.rsp_list and Arm.rsp_list.install_list
            and Arm.rsp_list.install_list[wid > 0 and wid or 101004]
        local insID = tonumber(entry and entry.skin_id) or 0
        if insID > 0 and F.isInjectedIns(insID) then
            skin = tonumber(R.insToRes[insID])
        elseif insID > 0 then
            local wd = require("client.slua.logic.wardrobe.wardrobe_data")
            local d = wd:GetHallDepotItemDataByInsID(insID)
            if d and d.resID then skin = tonumber(d.resID) end
        end
    end)
    if skin and skin > 0 then return skin end

    pcall(function()
        local wgl = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
        if wgl.GetSkinIdByWeaponID and wid > 0 then
            local insID = tonumber(wgl:GetSkinIdByWeaponID(wid)) or 0
            if insID > 0 and F.isInjectedIns(insID) then
                skin = tonumber(R.insToRes[insID])
            end
        end
    end)
    LOBBY.skinResolved = true
    LOBBY.cachedSkin = (skin and skin > 0) and skin or nil
    return LOBBY.cachedSkin
end

function F.resolveLobbyOutfitRes()
    if LOBBY.outfitResolved then return LOBBY.cachedOutfit end
    local cch = F.cache()
    local outfitRes = tonumber(cch.outfitRes) or 0
    if outfitRes > 0 then
        LOBBY.outfitResolved = true
        LOBBY.cachedOutfit = outfitRes
        return outfitRes
    end
    outfitRes = tonumber(_G.AddOutfitLastLobbyOutfitRes) or 0
    if outfitRes > 0 then
        LOBBY.outfitResolved = true
        LOBBY.cachedOutfit = outfitRes
        return outfitRes
    end
    if MATCH_CONFIG.outfitRes and tonumber(MATCH_CONFIG.outfitRes) > 0 then
        LOBBY.outfitResolved = true
        LOBBY.cachedOutfit = tonumber(MATCH_CONFIG.outfitRes)
        return LOBBY.cachedOutfit
    end

    local injectedRes, anyRes
    pcall(function()
        local AvatarData = require("client.logic.data.AvatarData")
        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
        local function resFromIns(ins)
            ins = tonumber(ins)
            if not ins or ins <= 0 then return nil end
            if F.isInjectedIns(ins) then return tonumber(R.insToRes[ins]) end
            local d = wd:GetHallDepotItemDataByInsID(ins)
            return d and tonumber(d.resID) or nil
        end
        for _, ins in pairs(AvatarData.GetRoleWear()) do
            local res = resFromIns(ins)
            if res and F.isSuitRes(res) then
                if F.isInjectedRes(res) then injectedRes = res end
                anyRes = anyRes or res
            end
        end
        local fbd = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
        local bag = fbd.GetCurrentFashionBag and fbd:GetCurrentFashionBag()
        if bag and bag.rolewear_list then
            for _, ins in pairs(bag.rolewear_list) do
                local res = resFromIns(ins)
                if res and F.isSuitRes(res) then
                    if F.isInjectedRes(res) then injectedRes = res end
                    anyRes = anyRes or res
                end
            end
        end
    end)
    if injectedRes and injectedRes > 0 then
        LOBBY.outfitResolved = true
        LOBBY.cachedOutfit = injectedRes
        return injectedRes
    end
    if anyRes and anyRes > 0 then
        LOBBY.outfitResolved = true
        LOBBY.cachedOutfit = anyRes
        return anyRes
    end
    LOBBY.outfitResolved = true
    LOBBY.cachedOutfit = nil
    return nil
end

function F.rememberLobbyOutfitRes(resID)
    resID = tonumber(resID)
    if not resID or resID <= 0 or not F.isSuitRes(resID) then return end
    _G.AddOutfitLastLobbyOutfitRes = resID
    F.invalidateLobbyResolved()
    local cch = F.cache()
    if not cch.outfitRes or cch.outfitRes <= 0 then
        cch.outfitRes = resID
        if F.isInjectedRes(resID) then cch.outfitIns = R.resToIns[resID] end
    end
end

function F.wearPatchKey()
    local outfit = F.resolveLobbyOutfitRes() or 0
    local skin = F.resolveLobbyWeaponSkinRes() or 0
    local openGun = 1
    pcall(function()
        local lds = require("client.slua.logic.wardrobe.logic_display_setting")
        if lds.data and lds.data.OpenGun ~= nil then openGun = lds.data.OpenGun and 1 or 0 end
    end)
    return outfit .. "_" .. skin .. "_" .. openGun
end

function F.syncDepotShowWeaponFlags(depot)
    depot = depot or {}
    pcall(function()
        local lds = require("client.slua.logic.wardrobe.logic_display_setting")
        if lds.data then
            if lds.data.OpenGun ~= nil then depot.weapon = lds.data.OpenGun end
            if lds.data.OpenSocialWeapon ~= nil then depot.social_weapon = lds.data.OpenSocialWeapon end
        end
    end)
    return depot
end

function F.applyInjectedPspace(roleData)
    if not roleData then return end
    roleData.bshow = true
    roleData.pspace_wear_ext = roleData.pspace_wear_ext or {}
    local outfitRes = F.resolveLobbyOutfitRes()
    if outfitRes and outfitRes > 0 then
        roleData.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH] = { outfitRes, 0, 0 }
    end
    local skinRes = F.resolveLobbyWeaponSkinRes()
    if skinRes and skinRes > 0 then
        roleData.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_WEAPON] = { 0, 0, 0 }
        roleData.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_WEAPONSKIN] = { skinRes, 0, 0 }
        roleData.depot_show_info = roleData.depot_show_info or {}
        if roleData.depot_show_info.weapon == nil then
            roleData.depot_show_info.weapon = true
        end
    end
    roleData.depot_show_info = F.syncDepotShowWeaponFlags(roleData.depot_show_info)
end

function F.patchSelfWearCache(force)
    local key = F.wearPatchKey()
    if not force and SOCIAL.wearPatchKey == key then return false end
    SOCIAL.wearPatchKey = key
    SOCIAL.snapshotKey = nil
    SOCIAL.fullSnapshot = nil

    local myUid = tonumber(DataMgr.roleData.uid)
    if not myUid then return false end

    local changed = false
    pcall(function()
        local BD = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
        local d = BD:GetCacheData(myUid)
        if not d then
            BD:OnHandleMsgDataAndCallback(myUid, F.buildLocalRoleDataForCoupleAvatar())
            return true
        end
        local oldCloth = d.pspace_wear_ext and d.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH]
        local oldSkin = d.pspace_wear_ext and d.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_WEAPONSKIN]
        F.applyInjectedPspace(d)
        local nc = d.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH]
        local ns = d.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_WEAPONSKIN]
        if oldCloth ~= nc or oldSkin ~= ns or not d.bshow then changed = true end
    end)
    return force or changed
end

function F.requestSocialAvatarRefresh()
    pcall(function()
        if EventSystem and EVENTTYPE_LOBBY_SOCIAL and EVENTID_SOCIAL_LOBBY_REFRESH_AVATAR then
            EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_SOCIAL_LOBBY_REFRESH_AVATAR)
        end
    end)
end

function F.onSocialWearDirty(forceRefresh)
    SOCIAL.lastHandSkin = nil
    if F.patchSelfWearCache(forceRefresh) then
        F.requestSocialAvatarRefresh()
    end
end

function F.buildLocalRoleDataForCoupleAvatar()
    local key = F.wearPatchKey()
    if SOCIAL.fullSnapshot and SOCIAL.snapshotKey == key then
        return SOCIAL.fullSnapshot
    end
    F.syncWeaponCacheFromLobby()
    local cch = F.cache()
    local ad = DataMgr.avatarData or {}
    local gender = tonumber(ad.gamegender) or 2
    if gender < 1 then gender = 2 end

    local data = {
        uid = DataMgr.roleData.uid,
        gender = gender,
        bshow = true,
        pspace_wear_ext = {
            [ENUM_AVATAR_SHOW_TYPE.SHOW_POS_HEAD] = { tonumber(ad.headid) or 401993, 0, 0 },
            [ENUM_AVATAR_SHOW_TYPE.SHOW_POS_HAIR] = { tonumber(ad.hairid) or 40601001, 0, 0 },
            [ENUM_AVATAR_SHOW_TYPE.SHOW_POS_WEAPON] = { 0, 0, 0 },
            [ENUM_AVATAR_SHOW_TYPE.SHOW_POS_WEAPONSKIN] = { 0, 0, 0 },
        },
        depot_show_info = {
            weapon = true, social_weapon = true, idle = true,
            helmet = true, bag = true, vehicle = true, hand = true,
        },
    }

    local outfitRes = F.resolveLobbyOutfitRes()
    if outfitRes and outfitRes > 0 then
        data.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH] = { outfitRes, 0, 0 }
    end

    local skinRes = F.resolveLobbyWeaponSkinRes()
    if skinRes and skinRes > 0 then
        data.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_WEAPON][1] = 0
        data.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_WEAPONSKIN][1] = skinRes
    end
    data.depot_show_info = F.syncDepotShowWeaponFlags(data.depot_show_info)
    SOCIAL.fullSnapshot = data
    SOCIAL.snapshotKey = F.wearPatchKey()
    return data
end

local _myUidCached
function F.isMyWearData(wearData)
    if not wearData then return false end
    if not _myUidCached then
        pcall(function() _myUidCached = tonumber(DataMgr.roleData.uid) end)
    end
    return _myUidCached and tonumber(wearData.uid) == _myUidCached
end

function F.mergeInjectedWeaponIntoWearData(wearData)
    if not F.isMyWearData(wearData) then return end
    local skinRes = F.resolveLobbyWeaponSkinRes()
    wearData.depot_show_info = F.syncDepotShowWeaponFlags(wearData.depot_show_info)
    if not skinRes or skinRes <= 0 then return end
    wearData.mainWeaponInfo = wearData.mainWeaponInfo or {
        weaponResId = 0, weaponSkinId = 0,
        diyInfo = { diyWeaponId = 0, diyDefaultScheme = false, diyScheme = nil },
    }
    if wearData.mainWeaponInfo.weaponSkinId == skinRes
        and (tonumber(wearData.mainWeaponInfo.weaponResId) or 0) == 0 then
        return
    end
    wearData.mainWeaponInfo.weaponSkinId = skinRes
    wearData.mainWeaponInfo.weaponResId = 0
end

function F.equipSocialHandWeapon(avatar, skinRes)
    if not avatar or not skinRes or skinRes <= 0 then return end
    if SOCIAL.lastHandSkin == skinRes then return end
    SOCIAL.lastHandSkin = skinRes
    pcall(function()
        avatar:PutonEquipment(skinRes, nil, { bIsUse = true })
    end)
end

function F.shouldShowHandWeapon()
    local show = true
    pcall(function()
        local lds = require("client.slua.logic.wardrobe.logic_display_setting")
        if lds.data and lds.data.OpenGun ~= nil then
            show = lds.data.OpenGun ~= false
        end
    end)
    return show
end

function F.mergeInjectedOutfitIntoWearData(wearData)
    if not F.isMyWearData(wearData) then return end
    local outfitRes = F.resolveLobbyOutfitRes()
    if not outfitRes or outfitRes <= 0 then return end
    F.rememberLobbyOutfitRes(outfitRes)
    local AvatarData = require("client.logic.data.AvatarData")
    local converted = AvatarData.ConvertToAvatarCustom({ outfitRes, 0, 0 })
    if not converted then return end
    wearData.WearInfoList = wearData.WearInfoList or {}
    local replaced = false
    for i, e in ipairs(wearData.WearInfoList) do
        if e and e.ItemID and F.isSuitRes(e.ItemID) then
            wearData.WearInfoList[i] = converted
            replaced = true
            break
        end
    end
    if not replaced then
        table.insert(wearData.WearInfoList, converted)
    end
end

function F.mergeInjectedIntoWearData(wearData)
    if not wearData then return end
    F.mergeInjectedWeaponIntoWearData(wearData)
    F.mergeInjectedOutfitIntoWearData(wearData)
end

function F.reapplyLobbyEquipped()
    if not GameStatus or not GameStatus.IsInLobbyOrMainCity or not GameStatus.IsInLobbyOrMainCity() then
        return
    end
    F.syncWeaponCacheFromLobby()
    F.applyPersistSlotsToCache()
    local curPage = F.getLobbyCurPage()

    if ENUM_LobbyPageType and curPage == ENUM_LobbyPageType.Left then
        F.onSocialWearDirty(true)
        return
    end

    local cch = F.cache()
    if cch.outfitIns and F.isInjectedIns(cch.outfitIns) then
        F.putOnOutfit(cch.outfitIns)
    end
    if cch.hatIns and F.isInjectedIns(cch.hatIns) then
        F.putOnHat(cch.hatIns)
    end
    if cch.maskIns and F.isInjectedIns(cch.maskIns) then
        F.putOnRoleWear(cch.maskIns)
    end
    if cch.glassIns and F.isInjectedIns(cch.glassIns) then
        F.putOnRoleWear(cch.glassIns)
    end
    if cch.tshirtIns and F.isInjectedIns(cch.tshirtIns) then
        F.putOnRoleWear(cch.tshirtIns)
    end
    if cch.pantsIns and F.isInjectedIns(cch.pantsIns) then
        F.putOnRoleWear(cch.pantsIns)
    end
    if cch.shoesIns and F.isInjectedIns(cch.shoesIns) then
        F.putOnRoleWear(cch.shoesIns)
    end
    if cch.bagIns and F.isInjectedIns(cch.bagIns) then
        F.putOnRoleWear(cch.bagIns)
    end
    if cch.helmetIns and F.isInjectedIns(cch.helmetIns) then
        F.putOnRoleWear(cch.helmetIns)
    end
    if cch.parachuteIns then
        F.putOnParachute(cch.parachuteIns)
    end
    if cch.gliderIns then
        F.putOnGlider(cch.gliderIns)
    end
    if cch.glovesIns and F.isInjectedIns(cch.glovesIns) then
        F.putOnGloves(cch.glovesIns)
    end

    local mainWid = tonumber(DataMgr.Weapon_ID) or 0
    local w = mainWid > 0 and cch.weapons[mainWid] or nil
    if w and w.resID and w.resID > 0 then
        if w.insID and F.isInjectedIns(w.insID) then
            F.equipWeaponSkin(mainWid, w.insID)
        else
            pcall(function() DataMgr.InitWeaponData(mainWid, w.resID, w.insID or 0) end)
        end
    end

    pcall(function()
        local uid = tostring(DataMgr.roleData.uid)
        local LAM = require("client.logic.avatar.LobbyAvatarManager")
        local TAM = require("client.logic.avatar.logic_team_avatar_manager")
        if w and w.resID and w.resID > 0 and TAM.GetAvatarByUid(uid) then
            LAM.EquipWeapon(uid, { weaponId = mainWid, skinId = w.resID }, nil, true)
        end
    end)

    F.reapplyVehicleSlotsFromConfig(true)
    F.reapplyHallThemeFromConfig(true)
    F.reapplyWeaponsFromConfig()
    pcall(F.applyVehicleSkinsToPC)
end

F.scheduleLobbyReapplyOnce = function()
    if LOBBY.reapplyDone or LOBBY.reapplyScheduled then return end
    LOBBY.reapplyScheduled = true
    F.later(2.0, function()
        LOBBY.reapplyScheduled = false
        if LOBBY.reapplyDone then return end
        LOBBY.reapplyDone = true
        F.reapplyLobbyEquipped()
    end)
end

function F.hookLobbySwipePersistence()
    if _G.AddOutfitLobbySwipeHooked then return end
    _G.AddOutfitLobbySwipeHooked = true
    pcall(function()
        local BD = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
        local oRsp = BD.on_get_avatar_show_rsp
        BD.on_get_avatar_show_rsp = function(self, res, target_uid, data)
            oRsp(self, res, target_uid, data)
                if tonumber(target_uid) == tonumber(DataMgr.roleData.uid) then
                F.patchSelfWearCache(true)
                SOCIAL.forceAvatarRedraw = true
                SOCIAL.lastHandSkin = nil
                if ENUM_LobbyPageType and F.getLobbyCurPage() == ENUM_LobbyPageType.Left then
                    F.requestSocialAvatarRefresh()
                end
            end
        end
    end)

    pcall(function()
        local AC = require("client.slua.logic.avatar.avatar_common")
        local oGetWear = AC.GetWearDataFromRoleData
        AC.GetWearDataFromRoleData = function(roleData)
            local wearData = oGetWear(roleData)
            if wearData and roleData and tonumber(roleData.uid) == tonumber(DataMgr.roleData.uid)
                and F.isLobbyLeftPage() then
                F.mergeInjectedIntoWearData(wearData)
            end
            return wearData
        end
        local oUp = AC.UpdateAvatar
        AC.UpdateAvatar = function(avatar, wearData, isShowWeapon, isShowHelmet, isShowBag)
            if F.isMyWearData(wearData) and F.isLobbyLeftPage() then
                F.mergeInjectedIntoWearData(wearData)
            end
            local showGun = isShowWeapon and F.shouldShowHandWeapon()
            if wearData and wearData.depot_show_info then
                showGun = showGun and wearData.depot_show_info.weapon ~= false
            end
            if F.isMyWearData(wearData) and F.isLobbyLeftPage() then
                for _, e in ipairs(wearData.WearInfoList or {}) do
                    if e and e.ItemID and F.isInjectedRes(e.ItemID) and F.isSuitRes(e.ItemID) then
                        F.rememberLobbyOutfitRes(e.ItemID)
                        break
                    end
                end
            end
            local ret = oUp(avatar, wearData, showGun, isShowHelmet, isShowBag)
            if showGun and F.isMyWearData(wearData) and avatar and F.isLobbyLeftPage() then
                local skin = tonumber(wearData.mainWeaponInfo and wearData.mainWeaponInfo.weaponSkinId) or 0
                if skin <= 0 then skin = F.resolveLobbyWeaponSkinRes() or 0 end
                if skin > 0 then F.equipSocialHandWeapon(avatar, skin) end
            end
            return ret
        end
    end)

    pcall(function()
        local CA = require("client.logic.avatar.CoupleAvatar")
        local Cfg = require("client.slua.logic.lobby.Left.CoupleAvatarConfig")
        local oMulti = CA._UpdateMultiAvatar
        if oMulti then
            CA._UpdateMultiAvatar = function(self, avatar, avatarType)
                local isSelf = avatarType == Cfg.AvatarType.Self
                    and self.SelfUID and tostring(self.SelfUID) == tostring(DataMgr.roleData.uid)
                if isSelf and F.isLobbyLeftPage() then
                    pcall(function()
                        local BD = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
                        local d = BD:GetCacheData(tonumber(self.SelfUID))
                        if d then F.applyInjectedPspace(d) end
                    end)
                    if SOCIAL.forceAvatarRedraw then
                        self.CompareDataCache[avatarType] = nil
                        SOCIAL.forceAvatarRedraw = nil
                    end
                end
                oMulti(self, avatar, avatarType)
                if isSelf and F.isLobbyLeftPage() and self.isShowWeapon ~= false and F.shouldShowHandWeapon() then
                    local skin = F.resolveLobbyWeaponSkinRes()
                    if skin and skin > 0 then F.equipSocialHandWeapon(avatar, skin) end
                end
            end
        end
        local oHideCheck = CA.CheckSelfIsHideAvatar
        CA.CheckSelfIsHideAvatar = function(self, nSelfUId, tRoleData)
            if F.isLobbyLeftPage() and tostring(nSelfUId) == tostring(DataMgr.roleData.uid) then
                return false
            end
            return oHideCheck(self, nSelfUId, tRoleData)
        end

        local oUpdate = CA.Update
        CA.Update = function(self)
            if not F.isLobbyLeftPage() then
                return oUpdate(self)
            end
            local isSelf = self.SelfUID and tostring(self.SelfUID) == tostring(DataMgr.roleData.uid)
            local oHide = CA.HideAvatars
            if isSelf then
                CA.HideAvatars = function() end
            end
            local ok, err = pcall(oUpdate, self)
            CA.HideAvatars = oHide
        end

        local oRecv = CA.OnReceiveData
        CA.OnReceiveData = function(self, uid, data)
            if F.isLobbyLeftPage() and uid == self.SelfUID and tostring(uid) == tostring(DataMgr.roleData.uid) then
                if data then
                    F.applyInjectedPspace(data)
                else
                    data = F.buildLocalRoleDataForCoupleAvatar()
                end
            end
            return oRecv(self, uid, data)
        end
    end)

    pcall(function()
        if not EventSystem or not EventSystem.registEvent then return end
        if EVENTTYPE_LOBBY and EVENTID_SWITCHTO_PAGE_SAMEERT then
            EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_SAMEERT, function(_, _, toPage)
                if ENUM_LobbyPageType and toPage == ENUM_LobbyPageType.Left then
                    F.syncWeaponCacheFromLobby()
                    SOCIAL.lastHandSkin = nil
                    local o = F.resolveLobbyOutfitRes()
                    if o then F.rememberLobbyOutfitRes(o) end
                    F.patchSelfWearCache(true)
                    SOCIAL.forceAvatarRedraw = true
                end
            end)
        end
        if EVENTTYPE_LOBBY and EVENTID_SWITCHTO_PAGE_END then
            EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_END, function(_, _, _, toPage)
                if ENUM_LobbyPageType and toPage == ENUM_LobbyPageType.Left then
                    F.syncWeaponCacheFromLobby()
                    SOCIAL.lastHandSkin = nil
                    F.socialDebounce(0.45, function()
                        F.onSocialWearDirty(true)
                    end)
                elseif ENUM_LobbyPageType and toPage == ENUM_LobbyPageType.Mid then
                    SOCIAL.wearPatchKey = nil
                    F.invalidateLobbyResolved()
                    if not LOBBY.reapplyDone then
                        F.socialDebounce(0.5, F.scheduleLobbyReapplyOnce)
                    end
                end
            end)
        end
        if EVENTTYPE_LOBBY_SOCIAL and EVENTID_GOT_SOCIAL_LOBBY_SHOW_DATA then
            EventSystem:registEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_GOT_SOCIAL_LOBBY_SHOW_DATA, function(_, _, nUId)
                if tonumber(nUId) == tonumber(DataMgr.roleData.uid) then
                    F.socialDebounce(0.2, function() F.patchSelfWearCache(false) end)
                end
            end)
        end
        if EVENTTYPE_WARDROBE and EVENTID_WARDROBE_UPDATE_CURRENT_PUT_ON_GUN then
            EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_CURRENT_PUT_ON_GUN, function()
                SOCIAL.wearPatchKey = nil
                SOCIAL.snapshotKey = nil
                F.syncWeaponCacheFromLobby()
                
                local curPage = ENUM_LobbyPageType and F.getLobbyCurPage()
                if curPage == ENUM_LobbyPageType.Left then
                    F.socialDebounce(0.25, function() F.onSocialWearDirty(true) end)
                end
                
                -- [FIX Lá»–I VIP] Tá»± Ä‘á»™ng Ä‘áº¯p láº¡i Skin Mod khi game cÃ³ dáº¥u hiá»‡u update sÃºng á»Ÿ sáº£nh
                F.socialDebounce(0.3, function()
                    if F.reapplyLobbyEquipped then F.reapplyLobbyEquipped() end
                end)
            end)
        end
    end)

    pcall(function()
        local lds = require("client.slua.logic.wardrobe.logic_display_setting")
        local oSwitch = lds.SwitchGun
        lds.SwitchGun = function(...)
            local r = oSwitch(...)
            SOCIAL.wearPatchKey = nil
            
            local curPage = ENUM_LobbyPageType and F.getLobbyCurPage()
            if curPage == ENUM_LobbyPageType.Left then
                F.socialDebounce(0.2, function() F.onSocialWearDirty(true) end)
            end
            
            -- [FIX Lá»–I VIP] Khi Click vÃ o Ã´ vÅ© khÃ­ á»Ÿ Sáº£nh, Ä‘á»£i game Ä‘á»•i sÃºng gá»‘c xong thÃ¬ 0.3s sau Ä‘áº¯p skin Mod lÃªn láº¡i
            F.socialDebounce(0.3, function()
                if F.reapplyLobbyEquipped then F.reapplyLobbyEquipped() end
            end)
            
            return r
        end
    end)
end

function F.hookDepotInit()
    pcall(function()
        local WDE = require("client.slua.logic.wardrobe.WardrobeDataEntity")
        if WDE._AddOutfitInitHooked then return end
        WDE._AddOutfitInitHooked = true
        local orig = WDE.InitData
        WDE.InitData = function(self, pkg)
            orig(self, pkg)
            _G.AddOutfitUnexpireDone = false
            pcall(function()
                if F.injectAll(self) then
                    F.scheduleInjectRefresh()
                    LOBBY.reapplyDone = false
                    LOBBY.reapplyScheduled = false
                    F.scheduleLobbyReapplyOnce()
                end
            end)
        end
    end)
end

function F.hookWardrobeData()
    pcall(function()
        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
        if wd._AddOutfitDataHooked then return end
        wd._AddOutfitDataHooked = true
        local function wrapGet(name)
            local o = wd[name]
            if not o then return end
            wd[name] = function(self, insID, ...)
                insID = tonumber(insID)
                local r
                if F.isInjectedIns(insID) then
                    local e = F.getEntity()
                    if e then r = e:GetDataByInsID(insID) end
                else
                    r = o(self, insID, ...)
                end
                if r and (F.isInjectedIns(insID) or F.isInjectedRes(r.resID or r.res_id)) then
                    r.expire_ts = 0
                    r.expireTS = 0
                    r.valid_hours = 0
                end
                return r
            end
        end
        wrapGet("GetHallDepotItemDataByInsID")
        wrapGet("GetValidHallDepotItemDataByInsID")
        local function wrapBool(name)
            local o = wd[name]
            if not o then return end
            wd[name] = function(self, id, ...)
                if F.isInjectedRes(tonumber(id)) or F.isInjectedIns(tonumber(id)) then return true end
                return o(self, id, ...)
            end
        end
        wrapBool("HasItem")
        wrapBool("HasValidItem")
        wrapBool("CheckHasPermanentItem")
    end)
end

function F.hookPageFilter()
    pcall(function()
        local wl = require("client.slua.logic.wardrobe.logic_wardrobe_new")
        if wl._AddOutfitPageFilterHooked then return end
        wl._AddOutfitPageFilterHooked = true
        local o1 = wl.IsValidCurrentPageItem
        wl.IsValidCurrentPageItem = function(self, mainTab, subTab, v, t)
            if v and F.isInjectedRes(v.resID) then
                local itemTab = tonumber(v.subTabType) or F.wardrobeTab(v.resID)
                if itemTab and itemTab == subTab then
                    if mainTab == PAGE_AVATAR or mainTab == PAGE_VEHICLE then return true end
                    if mainTab == PAGE_PARACHUTE and F.isHallThemeRes(v.resID) then return true end
                end
            end
            return o1(self, mainTab, subTab, v, t)
        end
        local o2 = wl.IsCanUse
        wl.IsCanUse = function(self, resId)
            if F.isInjectedRes(resId) then return true end
            return o2(self, resId)
        end
        local o3 = wl.IsCharacterUse
        wl.IsCharacterUse = function(self, resId)
            if F.isInjectedRes(resId) then return true end
            return o3(self, resId)
        end
        local o4 = wl.GetWardrobeInsIdByResId
        wl.GetWardrobeInsIdByResId = function(self, resid)
            resid = tonumber(resid)
            if F.isInjectedRes(resid) then return R.resToIns[resid] end
            return o4(self, resid)
        end
    end)
end

function F.hookArmory()
    pcall(function()
        local Arm = require("client.logic.armory.logic_armory")
        if Arm._AddOutfitArmoryHooked then return end
        Arm._AddOutfitArmoryHooked = true
        local oa = Arm.get_weapon_skin_list_rsp
        Arm.get_weapon_skin_list_rsp = function(a, b, c, d)
            oa(a, b, c, d)
            F.mergeInjectedArmorySkins()
        end
        local oi = Arm.install_weapon_skin
        Arm.install_weapon_skin = function(cd, wid, ins)
            ins = tonumber(ins)
            if F.isWeaponSkinIns(ins) then
                wid = tonumber(F.weaponIdFromSkin(R.insToRes[ins]) or wid)
                F.equipWeaponSkin(wid, ins)
                return
            end
            return oi(cd, wid, ins)
        end
    end)
    pcall(function()
        local AH = require("client.network.Protocol.ArmoryHandler")
        if AH._AddOutfitArmorySendHooked then return end
        AH._AddOutfitArmorySendHooked = true
        local o = AH.send_install_weapon_skin
        AH.send_install_weapon_skin = function(cd, wid, ins)
            ins = tonumber(ins)
            if F.isWeaponSkinIns(ins) then
                wid = tonumber(F.weaponIdFromSkin(R.insToRes[ins]) or wid)
                F.equipWeaponSkin(wid, ins)
                return
            end
            return o(cd, wid, ins)
        end
    end)
end

function F.hookGunSkinId()
    pcall(function()
        local wgl = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
        if wgl._AddOutfitGunSkinHooked then return end
        wgl._AddOutfitGunSkinHooked = true
        local o = wgl.GetSkinIdByWeaponID
        wgl.GetSkinIdByWeaponID = function(self, wid)
            local c = F.cache()
            local w = c.weapons[wid]
            if w and F.isWeaponSkinIns(w.insID) then return w.insID end
            local Arm = require("client.logic.armory.logic_armory")
            if Arm.rsp_list and Arm.rsp_list.install_list and Arm.rsp_list.install_list[wid] then
                local sid = Arm.rsp_list.install_list[wid].skin_id
                if sid and F.isWeaponSkinIns(sid) then return sid end
            end
            return o(self, wid)
        end
    end)
end

function F.hookPutOn()
    pcall(function()
        local WRH = require("client.network.Protocol.WardRobeHandler")
        if WRH._AddOutfitPutOnHooked then return end
        WRH._AddOutfitPutOnHooked = true
        local o = WRH.send_depot_put_on_req
        WRH.send_depot_put_on_req = function(insID, extra)
            insID = tonumber(insID)
            if F.tryLocalWearByIns(insID) then return end
            return o(insID, extra)
        end
    end)
end

function F.hookPutDown()
    pcall(function()
        local WRH = require("client.network.Protocol.WardRobeHandler")
        if WRH._AddOutfitPutDownHooked then return end
        WRH._AddOutfitPutDownHooked = true
        local o = WRH.send_depot_put_down_req
        WRH.send_depot_put_down_req = function(insID)
            if F.isInjectedIns(tonumber(insID)) then
                F.takeOffInjected(insID)
                return
            end
            return o(insID)
        end
        local ob = WRH.send_depot_batch_put_down_req
        WRH.send_depot_batch_put_down_req = function(instid_list)
            local rest = {}
            for _, id in ipairs(instid_list or {}) do
                if F.isInjectedIns(tonumber(id)) then
                    F.takeOffInjected(id)
                else
                    rest[#rest + 1] = id
                end
            end
            if #rest > 0 then return ob(rest) end
        end
    end)
end

function F.hookVehicleSwitchEffect()
    if _G.AddOutfitVehSwitchHooked then return end
    pcall(function()
        local VAC = require("GameLua.GameCore.Module.Vehicle.Component.VehicleAvatarComponent")
        local impl = VAC and VAC.__inner_impl
        if not impl or impl._AddOutfitVehSwitchHooked then return end
        impl._AddOutfitVehSwitchHooked = true

        if not _G.AddOutfitVehOrigCanSwitch then
            _G.AddOutfitVehOrigCanSwitch = impl.CheckCanPlaySkinSwitchEffect
        end
        impl.CheckCanPlaySkinSwitchEffect = function(self, curVehicleId, lastVehicleId)
            if self.IsLobbyActor and self:IsLobbyActor() then return false end
            if not F.isInRealMatch() then return false end
            return true
        end

        if not _G.AddOutfitVehOrigShowSwitch then
            _G.AddOutfitVehOrigShowSwitch = impl.ShowVehicleSwitchEffect
        end
        impl.ShowVehicleSwitchEffect = function(self)
            if self.IsLobbyActor and self:IsLobbyActor() then return false end
            if not F.isInRealMatch() then return false end
            if not self.curSwitchEffectId or self.curSwitchEffectId <= 0 then
                self.curSwitchEffectId = VEH_SWITCH_EFFECT_ID
            end
            local vehicleActor = self:GetOwner()
            if not slua.isValid(vehicleActor) then return false end
            if self.uSwitchEffectActor then
                self:StopSkinSwitchEffect()
                pcall(function() self.uSwitchEffectActor:K2_DestroyActor() end)
                self.uSwitchEffectActor = nil
            end
            if not self.lastEquipedAvatarId or self.lastEquipedAvatarId <= 0 then
                local defId = 0
                pcall(function() defId = self:GetDefaultAvatarID() or 0 end)
                self.lastEquipedAvatarId = vehicleActor.ClientUsedAvatarID or defId or 0
            end
            local currentAvatarID = vehicleActor.ClientUsedAvatarID or self.lastEquipedAvatarId or 0
            local bIsLobbyActor = self:IsLobbyActor()
            local world = slua_GameFrontendHUD:GetWorld()
            local VehiclePlateLicenseUtil = require("GameLua.Activity.Commercialize.GamePlay.Vehicle.VehiclePlateLicenseUtil")
            local SkinSwitchEffectActorPath = VehiclePlateLicenseUtil.GetSwitchEffectActorPath()
            local BP_DissolveVehicleClass = import(SkinSwitchEffectActorPath)
            self.uSwitchEffectActor = world:SpawnActor(BP_DissolveVehicleClass, nil, nil, nil)
            if not slua.isValid(self.uSwitchEffectActor) then
                self.uSwitchEffectActor = nil
                return false
            end
            self.uSwitchEffectActor:K2_AttachToActor(vehicleActor, "None", 1, 1, 1, false)
            self.uSwitchEffectActor:K2_SetActorRelativeLocation(FVector(0, 0, 0), false, nil, false)
            self.uSwitchEffectActor:K2_SetActorRelativeRotation(FRotator(0, 0, 0), false, nil, false)
            pcall(function() self:HideParticles() end)
            self:ChangeFakeSwitchVehicleAvatar(self.uSwitchEffectActor.Mesh, self.lastEquipedAvatarId)
            self.uSwitchEffectActor:SetAnimInsAndAnimState(self.uOldVehicleMeshAnimClass, vehicleActor)
            self.uSwitchEffectActor:StartVehicleSwitchEffect(
                vehicleActor, self.curSwitchEffectId, self.lastEquipedAvatarId, currentAvatarID, bIsLobbyActor)
            self.uOldVehicleMeshAnimClass = nil
            return true
        end

        if not _G.AddOutfitVehOrigBeginPlay then
            _G.AddOutfitVehOrigBeginPlay = impl.ReceiveBeginPlay
        end
        local oBegin = _G.AddOutfitVehOrigBeginPlay
        impl.ReceiveBeginPlay = function(self)
            oBegin(self)
            pcall(function()
                if self.uSwitchEffectActor then
                    self:StopSkinSwitchEffect()
                    pcall(function() self.uSwitchEffectActor:K2_DestroyActor() end)
                    self.uSwitchEffectActor = nil
                end
                self.lastEquipedAvatarId = 0
                if self.IsLobbyActor and self:IsLobbyActor() then
                    self.curSwitchEffectId = 0
                elseif F.isInRealMatch() then
                    self.curSwitchEffectId = VEH_SWITCH_EFFECT_ID
                else
                    self.curSwitchEffectId = 0
                end
            end)
        end

        if impl.LuaIsAssetsAlreadyAvailable and not _G.AddOutfitVehOrigAssets then
            _G.AddOutfitVehOrigAssets = impl.LuaIsAssetsAlreadyAvailable
            impl.LuaIsAssetsAlreadyAvailable = function(self, avatarId)
                if F.isVehicleSkinAllowed(tonumber(avatarId)) then return true end
                return _G.AddOutfitVehOrigAssets(self, avatarId)
            end
        end

        _G.AddOutfitVehSwitchHooked = true
    end)
end

function F.hookVehicleChassisLight()
    if _G.AddOutfitVehChassisHooked then return end
    pcall(function()
        local LIC = require("GameLua.Activity.Commercialize.Actor.ActorComponent.BP_VehicleLicenseComponentBase")
        if LIC and LIC.CheckHasVehicleDownloaded and not _G.AddOutfitVehOrigLicDownload then
            _G.AddOutfitVehOrigLicDownload = LIC.CheckHasVehicleDownloaded
            LIC.CheckHasVehicleDownloaded = function(self, itemID)
                local id = tonumber(itemID)
                if F.isVehicleSkinAllowed(id) or F.isChassisLightId(id) then return true end
                return _G.AddOutfitVehOrigLicDownload(self, itemID)
            end
        end
    end)
    pcall(function()
        local LVF = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicVehicleExtendedFeature)
        if not LVF or LVF._AddOutfitChassisHooked then return end
        LVF._AddOutfitChassisHooked = true

        if not _G.AddOutfitVehOrigGetFeature then
            _G.AddOutfitVehOrigGetFeature = LVF.CheckHasGetFeatureItem
        end
        LVF.CheckHasGetFeatureItem = function(self, featureId)
            if F.isChassisLightId(featureId) then return true end
            return _G.AddOutfitVehOrigGetFeature(self, featureId)
        end

        if not _G.AddOutfitVehOrigEquippedFeature then
            _G.AddOutfitVehOrigEquippedFeature = LVF.CheckHasEquippedItem
        end
        LVF.CheckHasEquippedItem = function(self, featureId, vehicleId)
            -- [FIX VIP] Bá»• sung check Ä‘iá»u kiá»‡n ModSkin
            if _G.LexusConfig and _G.LexusConfig.ModSkin ~= false then
                if F.isChassisLightId(featureId) then
                    return F.getDesiredChassisLight(vehicleId) == tonumber(featureId)
                end
            end
            return _G.AddOutfitVehOrigEquippedFeature(self, featureId, vehicleId)
        end

        if not _G.AddOutfitVehOrigEquipChassisData then
            _G.AddOutfitVehOrigEquipChassisData = LVF.GetEquipedChassisLightData
        end
        LVF.GetEquipedChassisLightData = function(self, vehicleId, source)
            -- [FIX VIP] Bá»• sung check Ä‘iá»u kiá»‡n ModSkin
            if _G.LexusConfig and _G.LexusConfig.ModSkin ~= false then
                local our = F.getDesiredChassisLight(vehicleId)
                if our then return our end
            end
            return _G.AddOutfitVehOrigEquipChassisData(self, vehicleId, source)
        end

        if not _G.AddOutfitVehOrigChassisLightData then
            _G.AddOutfitVehOrigChassisLightData = LVF.GetVehicleChassisLightData
        end
        LVF.GetVehicleChassisLightData = function(self, uid, vehicleId, position, source)
            -- [FIX VIP] Bá»• sung check Ä‘iá»u kiá»‡n ModSkin
            if _G.LexusConfig and _G.LexusConfig.ModSkin ~= false then
                if uid and DataMgr and DataMgr.roleData and tonumber(uid) == tonumber(DataMgr.roleData.uid) then
                    local our = F.getDesiredChassisLight(vehicleId)
                    if our then return our end
                end
            end
            return _G.AddOutfitVehOrigChassisLightData(self, uid, vehicleId, position, source)
        end

        if not _G.AddOutfitVehOrigPutOnFeature then
            _G.AddOutfitVehOrigPutOnFeature = LVF.PutOnVehicleFeature
        end
        LVF.PutOnVehicleFeature = function(self, featureId, vehicleId)
            featureId = tonumber(featureId)
            vehicleId = tonumber(vehicleId)
            if F.isChassisLightId(featureId) then
                F.saveChassisLight(vehicleId, featureId)
                self.equip_chassis_light = self.equip_chassis_light or {}
                if vehicleId and vehicleId > 0 then
                    self.equip_chassis_light[vehicleId] = featureId
                end
                return
            end
            return _G.AddOutfitVehOrigPutOnFeature(self, featureId, vehicleId)
        end

        if not _G.AddOutfitVehOrigPutOffFeature then
            _G.AddOutfitVehOrigPutOffFeature = LVF.PutOffVehicleFeature
        end
        LVF.PutOffVehicleFeature = function(self, featureId, vehicleId)
            featureId = tonumber(featureId)
            vehicleId = tonumber(vehicleId)
            if F.isChassisLightId(featureId) then
                PERSIST.configChassisLightMap = PERSIST.configChassisLightMap or {}
                if vehicleId and vehicleId > 0 then
                    PERSIST.configChassisLightMap[vehicleId] = nil
                end
                if self.equip_chassis_light and vehicleId then
                    self.equip_chassis_light[vehicleId] = nil
                end
                F.persistMarkDirty()
                return
            end
            return _G.AddOutfitVehOrigPutOffFeature(self, featureId, vehicleId)
        end
    end)
    _G.AddOutfitVehChassisHooked = true
end

function F.hookVehicles()
    F.hookVehicleSwitchEffect()
    F.hookVehicleChassisLight()
    pcall(function()
        local WV = require("client.slua.umg.Wardrobe.subtab_vehicles")
        if not WV or WV._AddOutfitVehClickHooked then return end
        WV._AddOutfitVehClickHooked = true
        local oClick = WV.ClickItem
        WV.ClickItem = function(self, vehicleSkin, bForceUsing)
            if vehicleSkin and F.isInjectedRes(vehicleSkin.res_id) then
                vehicleSkin.expireTS = 0
                vehicleSkin.expire_ts = 0
            end
            return oClick(self, vehicleSkin, bForceUsing)
        end
        local oDrop = WV.OnVehicleSlotDrop
        if oDrop then
            WV.OnVehicleSlotDrop = function(self, DragWidget, Index, DragDropData)
                pcall(function()
                    local ins = DragDropData and DragDropData.ins_id
                    if F.isInjectedIns(tonumber(ins)) then
                        F.ensureInjectedItemAlive(nil, nil, ins)
                    end
                end)
                return oDrop(self, DragWidget, Index, DragDropData)
            end
        end
    end)
    pcall(function()
        local WNH = require("client.network.Protocol.WardrobeNewHandler")
        if WNH._AddOutfitVehicleHooked then return end
        WNH._AddOutfitVehicleHooked = true
        local oMod = WNH.send_depot_modify_combat_vehicle_req
        WNH.send_depot_modify_combat_vehicle_req = function(instid, slot_index, ope_type)
            if F.modifyInjectedVehicleSlot(instid, slot_index, ope_type == true) then return end
            return oMod(instid, slot_index, ope_type)
        end
        local oRsp = WNH.on_depot_modify_combat_vehicle_rsp
        WNH.on_depot_modify_combat_vehicle_rsp = function(err_code, knapsack_vst)
            if err_code == 0 or err_code == NET_OK then
                knapsack_vst = F.mergeInjectedIntoVehicleSlotList(knapsack_vst)
            end
            oRsp(err_code, knapsack_vst)
            if err_code == 0 or err_code == NET_OK then
                F.syncVehicleSlotsToDataMgr()
                F.equipVehicleTypesFromConfig(PERSIST.configVehicleSlots)
                if not (_G.AddOutfitLobbyVeh and _G.AddOutfitLobbyVeh.manual) then
                    pcall(F.applyVehicleSkinsToPC)
                end
                F.persistMarkDirty()
            end
        end
    end)
    pcall(function()
        local gsm = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.golden_suit_module)
        if gsm and gsm.VehicleNeedClothes and not gsm._AddOutfitVehClothesHooked then
            gsm._AddOutfitVehClothesHooked = true
            local o = gsm.VehicleNeedClothes
            gsm.VehicleNeedClothes = function(self, vehicleId)
                vehicleId = tonumber(vehicleId)
                if vehicleId and F.isInjectedRes(vehicleId) then return 0 end
                return o(self, vehicleId)
            end
        end
    end)
    pcall(function()
        local mod = require("GameLua.Activity.Commercialize.GamePlay.CommerAvatarDataUtil")
        if mod._FillVehicleSkinList then
            if not _G.AddOutfitVehFillOrig then
                _G.AddOutfitVehFillOrig = mod._FillVehicleSkinList
            end
            local o = _G.AddOutfitVehFillOrig
            mod._FillVehicleSkinList = function(self, playerInfo, uPlayerController)
                F.mergeVstIntoPlayerInfo(playerInfo)
                return o(self, playerInfo, uPlayerController)
            end
            mod._AddOutfitFillVehHooked = true
        end
    end)
    pcall(function()
        local classMod = require("GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.VehicleSkinItem")
        if not classMod or not classMod.__inner_impl then return end
        local impl = classMod.__inner_impl
        if not _G.AddOutfitVehOrigClick then
            _G.AddOutfitVehOrigClick = impl.OnClickSkinButton
        end
        local oClick = _G.AddOutfitVehOrigClick
        impl.OnClickSkinButton = function(self)
            local resID = tonumber(self.resID)
            if resID and resID > 0 then
                if F.matchApplyVehicleSkin(resID) then
                    pcall(function()
                        if EVENTYPE_INGAME_VEHICLE_CONTROL_PANEL and EVENTID_CHANGE_VEHICLESKIN_BUTTON_CLICK then
                            EventSystem:postEvent(EVENTYPE_INGAME_VEHICLE_CONTROL_PANEL, EVENTID_CHANGE_VEHICLESKIN_BUTTON_CLICK)
                        end
                    end)
                end
                return
            end
            return oClick(self)
        end
        if not _G.AddOutfitVehOrigRefresh then
            _G.AddOutfitVehOrigRefresh = impl.OnRefresh
        end
        local oRefresh = _G.AddOutfitVehOrigRefresh
        impl.OnRefresh = function(self, resID, selectIndex)
            oRefresh(self, resID, selectIndex)
            if self.resID and tonumber(self.resID) and tonumber(self.resID) > 0 then
                if F.isResourcesReady(self.resID) then
                    pcall(function()
                        local PufferConst = require("client.slua.logic.download.puffer_const")
                        self.dowloadState = PufferConst.ENUM_DownloadState.Done
                        self.UIRoot.Image_Download:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
                        self:SetWidgetVisible(self.UIRoot.Image_Mask, false)
                    end)
                else
                    F.requestResourceDownload(self.resID)
                end
            end
        end
        classMod._AddOutfitSkinClickHooked = true
    end)
    pcall(function()
        local utilMod = require("GameLua.Activity.Commercialize.GamePlay.Vehicle.VehiclePlateLicenseUtil")
        if utilMod.CheckHasUnLockFeature and not utilMod._AddOutfitVehPlateHooked then
            utilMod._AddOutfitVehPlateHooked = true
            local orig = utilMod.CheckHasUnLockFeature
            utilMod.CheckHasUnLockFeature = function(ft, uid, itemId)
                local id = tonumber(itemId)
                if F.isVehicleSkinAllowed(id) or F.isChassisLightId(id) then return true end
                return orig(ft, uid, itemId)
            end
        end
    end)
    pcall(function()
        local panelMod = require("GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.VehicleSkinAndMusicPanel")
        if panelMod and panelMod.__inner_impl and not panelMod._AddOutfitInitSkinHooked then
            panelMod._AddOutfitInitSkinHooked = true
            local o = panelMod.__inner_impl.InitSkinList
            panelMod.__inner_impl.InitSkinList = function(self)
                F.applyVehicleSkinsToPC(F.getPC())
                return o(self)
            end
        end
    end)
    pcall(function()
        local VUC = require("GameLua.GameCore.Module.Vehicle.Component.VehicleUserComponent")
        if not VUC then return end
        if not _G.AddOutfitVehOrigEnter then
            _G.AddOutfitVehOrigEnter = VUC.SendUIMsgWhenEnterVehicleCompleted
        end
        local oEnter = _G.AddOutfitVehOrigEnter
        VUC.SendUIMsgWhenEnterVehicleCompleted = function(self)
            oEnter(self)
            pcall(function()
                if slua.isValid(self.Vehicle) then
                    F.autoApplyVehicleSkinOnEnter(self.Vehicle)
                end
            end)
        end
        VUC._AddOutfitEnterVehHooked = true
    end)
end

function F.hookWeaponWear()
    pcall(function()
        local HT = require("client.logic.lobby.hall_theme_utils")
        local o = HT.IsWeaponWear
        HT.IsWeaponWear = function(insId)
            insId = tonumber(insId)
            if F.isInjectedIns(insId) then
                local c = F.cache()
                local Arm = require("client.logic.armory.logic_armory")
                for wid, w in pairs(c.weapons) do
                    if tonumber(w.insID) == insId then
                        if Arm.rsp_list and Arm.rsp_list.install_list and Arm.rsp_list.install_list[wid] then
                            return tonumber(Arm.rsp_list.install_list[wid].skin_id) == insId
                        end
                        return true
                    end
                end
            end
            return o(insId)
        end
    end)
end

function F.hookNotice()
    pcall(function()
        if DataMgr and not DataMgr._AddOutfitExpireHooked then
            DataMgr._AddOutfitExpireHooked = true
            local oValid = DataMgr.IsValidTime
            DataMgr.IsValidTime = function(expireTS)
                if expireTS == nil or tonumber(expireTS) == 0 then return true end
                if oValid and oValid(expireTS) then return true end
                local inMatch = false
                pcall(function()
                    inMatch = GameStatus and GameStatus.IsInFightingStatus and GameStatus.IsInFightingStatus()
                end)
                if not inMatch then return true end
                return false
            end
        end
    end)
end

function F.wrapWardrobeClick(classMod, key)
    if not classMod or not classMod[key] or classMod["_AddOutfitWrap_" .. key] then return end
    classMod["_AddOutfitWrap_" .. key] = true
    local orig = classMod[key]
    classMod[key] = function(self, widget, index)
        local itemData = self.LoopScrollGrid_Normal and self.LoopScrollGrid_Normal:GetItemData(index)
        if itemData then
            F.clearItemExpire(itemData, itemData.ins_id, itemData.res_id)
            F.ensureDepotItemValid(itemData.ins_id, itemData.res_id)
        end
        return orig(self, widget, index)
    end
end

function F.hookWardrobeWearClicks()
    if _G.AddOutfitWearClickHooked then return end
    _G.AddOutfitWearClickHooked = true
    F.hookNotice()
    pcall(function()
        local avatarClass = require("client.slua.umg.Wardrobe.subtab_avatar")
        F.wrapWardrobeClick(avatarClass, "OnClickItem")
        F.wrapWardrobeClick(avatarClass, "ClickAvatarItem")
    end)
    pcall(function()
        local suitClass = require("client.slua.umg.Wardrobe.subtab_suit")
        F.wrapWardrobeClick(suitClass, "OnClickItem")
    end)
    pcall(function()
        local bagClass = require("client.slua.umg.Wardrobe.subtab_bag")
        F.wrapWardrobeClick(bagClass, "OnClickItem")
    end)
end

function F.hookAvatarValid()
    pcall(function()
        local path = "GameLua.Mod.Library.GamePlay.Avatar.Component.CharacterAvatarComponent"
        local comp = require(path)
        if comp and comp.CheckItemValid then
            local o = comp.CheckItemValid
            comp.CheckItemValid = function(self, resID)
                if F.isInjectedRes(resID) then return true end
                return o(self, resID)
            end
        end
    end)
end

function F.isInRealMatch()
    local ok, r = pcall(function()
        return GameStatus and GameStatus.IsInFightingStatus and GameStatus.IsInFightingStatus()
    end)
    return ok and r == true
end

function F.getLocalChar()
    local ok, GD = pcall(require, "GameLua.GameCore.Data.GameplayData")
    if not ok or not GD then return nil end
    local char = GD.GetPlayerCharacter()
    if char and slua.isValid(char) then return char end
    return nil
end

function F.getWAC(char)
    local w = char and char.GetCurrentWeapon and char:GetCurrentWeapon()
    if slua.isValid(w) and slua.isValid(w.WeaponAvatarComponent) then
        return w.WeaponAvatarComponent
    end
    return nil
end

function F.notify(msg)
    if not DEBUG then return end
    pcall(function() if ShowNotice then ShowNotice("[AddOutfit] " .. tostring(msg)) end end)
end

function F.getDesiredOutfit()
    if MATCH_CONFIG.outfitRes and MATCH_CONFIG.outfitRes > 0 then
        return MATCH_CONFIG.outfitRes
    end
    local wornSuitRes
    pcall(function()
        local _, res = F.findWornInsBySubType(OUTFIT_SUB, function(r) return F.isSuitRes(r) end)
        wornSuitRes = tonumber(res)
    end)
    if wornSuitRes and wornSuitRes > 0 then return wornSuitRes end
    local tshirtWorn = false
    pcall(function()
        local ins = F.findWornInsBySubType(OUTFIT_SUB, function(r) return F.isTshirtRes(r) end)
        tshirtWorn = ins ~= nil
    end)
    if tshirtWorn then return nil end
    F.syncBodyCacheFromLobby()
    local c = F.cache()
    return c.outfitRes
end

function F.matchApplyOutfit(char)
    local outfitRes = F.getDesiredOutfit()
    if not outfitRes then return true end
    if not F.isResourcesReady(outfitRes) then
        F.requestResourceDownload(outfitRes)
        return false
    end
    local comp = F.getAvatarComp2(char)
    if not comp then return false end
    local ok = F.setMakeSkin(comp, outfitRes, F.CUST_SLOT.ClothesEquipemtSlot, { allowPutOn = true })
    return ok
end

function F.getDesiredHat()
    if MATCH_CONFIG.hatRes and tonumber(MATCH_CONFIG.hatRes) > 0 then
        return tonumber(MATCH_CONFIG.hatRes)
    end
    F.syncHatCacheFromLobby()
    local h = F.cache().hatRes
    if h and tonumber(h) > 0 then return tonumber(h) end
    return tonumber(_G.AddOutfitLastLobbyHatRes) or nil
end

function F.ensureSkinDownload(resID)
    resID = tonumber(resID)
    if not resID or resID <= 0 then return end
    _G.skinIdCache = _G.skinIdCache or {}
    if not _G.skinIdCache[resID] then
        F.requestResourceDownload(resID)
        _G.skinIdCache[resID] = true
    end
end

function F.syncGlobalWearSkins()
    _G.CustSlotType = F.CUST_SLOT
    _G.skinIdCache = _G.skinIdCache or {}
    _G.HatSkin = tonumber(F.getDesiredHat()) or 0
    local outfit = F.getDesiredOutfit()
    _G.SuitSkin = tonumber(outfit)
        or tonumber(F.getDesiredWear("tshirtRes", "tshirtRes", "AddOutfitLastLobbyTshirtRes", F.syncBodyCacheFromLobby))
        or 0
    _G.PantsSkin = tonumber(F.getDesiredWear("pantsRes", "pantsRes", "AddOutfitLastLobbyPantsRes", F.syncBodyCacheFromLobby)) or 0
    _G.ShoesSkin = tonumber(F.getDesiredWear("shoesRes", "shoesRes", "AddOutfitLastLobbyShoesRes", F.syncBodyCacheFromLobby)) or 0
    _G.GlovesSkin = tonumber(F.getDesiredWear("glovesRes", "glovesRes", "AddOutfitLastLobbyGlovesRes", F.syncBodyCacheFromLobby)) or 0
    _G.MaskSkin = tonumber(F.getDesiredMask()) or 0
    _G.GlassSkin = tonumber(F.getDesiredGlass()) or 0
    _G.GliderSkin = tonumber(F.getDesiredGliderRes()) or 0
    _G.ParachuteSkin = tonumber(F.getDesiredParachuteRes()) or 0
end

function F.setMakeSkinAtIndex(comp, applyIdx, resID, slotID)
    resID = tonumber(resID)
    slotID = tonumber(slotID)
    applyIdx = tonumber(applyIdx)
    if not comp or not slua.isValid(comp) or not resID or resID <= 0 or not slotID or applyIdx == nil then
        return false
    end
    local changed = false
    pcall(function()
        local net = comp.NetAvatarData
        if not net then return end
        local applyData = net.SlotSyncData
        if not applyData or not slua.isValid(applyData) then return end
        local equipment = applyData:Get(applyIdx)
        if equipment and equipment.SlotID == slotID then
            local cur = tonumber(equipment.ItemId) or tonumber(equipment.ItemID) or 0
            if cur ~= resID then
                F.ensureSkinDownload(resID)
                equipment.ItemId = resID
                if equipment.ItemID ~= nil then equipment.ItemID = resID end
                applyData:Set(applyIdx, equipment)
                changed = true
            end
        end
    end)
    return changed
end

function F.applySlotSkinBatch(comp, entries, opts)
    opts = opts or {}
    if not comp or not slua.isValid(comp) or not entries then return false end
    local changed, anyOk = false, false
    pcall(function()
        local net = comp.NetAvatarData
        if not net then return end
        local applyData = net.SlotSyncData
        if not applyData or not slua.isValid(applyData) then return end
        local num = applyData:Num()
        for _, e in ipairs(entries) do
            local itemId, slotId = tonumber(e[1]), tonumber(e[2])
            if itemId and itemId > 0 and slotId then
                F.ensureSkinDownload(itemId)
                for i = 0, num - 1 do
                    local equipment = applyData:Get(i)
                    if equipment and equipment.SlotID == slotId then
                        local cur = tonumber(equipment.ItemId) or tonumber(equipment.ItemID) or 0
                        if cur == itemId then
                            anyOk = true
                        elseif cur ~= itemId then
                            equipment.ItemId = itemId
                            if equipment.ItemID ~= nil then equipment.ItemID = itemId end
                            applyData:Set(i, equipment)
                            changed = true
                            anyOk = true
                        end
                        break
                    end
                end
            end
        end
        if (changed or opts.forceRep) and comp.OnRep_BodySlotStateChanged then
            comp:OnRep_BodySlotStateChanged()
        end
    end)
    return anyOk or changed
end

function F.setMakeSkin(comp, resID, slotID, opts)
    opts = opts or {}
    slotID, resID = tonumber(slotID), tonumber(resID)
    if not comp or not slua.isValid(comp) or not slotID or not resID or resID <= 0 then return false end
    local changed = false
    local already = false
    pcall(function()
        local net = comp.NetAvatarData
        if not net then return end
        local applyData = net.SlotSyncData
        if not applyData or not slua.isValid(applyData) then return end
        local num = applyData:Num()
        for i = 0, num - 1 do
            local equipment = applyData:Get(i)
            if equipment and equipment.SlotID == slotID then
                local cur = tonumber(equipment.ItemId) or tonumber(equipment.ItemID) or 0
                if cur == resID then
                    already = true
                elseif cur ~= resID then
                    F.ensureSkinDownload(resID)
                    equipment.ItemId = resID
                    if equipment.ItemID ~= nil then equipment.ItemID = resID end
                    applyData:Set(i, equipment)
                    changed = true
                end
                break
            end
        end
        if changed and not opts.skipRep and comp.OnRep_BodySlotStateChanged then
            comp:OnRep_BodySlotStateChanged()
        end
        if opts.inAir and comp.PutOnCustomEquipmentByID then
            comp:PutOnCustomEquipmentByID(resID)
        end
    end)
    if already or changed then return true end
    if opts.allowPutOn and comp.PutOnCustomEquipmentByID then
        pcall(function() comp:PutOnCustomEquipmentByID(resID) end)
        return true
    end
    return false
end
F.setSlotSkin = F.setMakeSkin

_G.setMakeSkin = function(applyIdx, itemId, applyEquipSlot)
    local char = F.getLocalChar()
    if not char then return end
    local comp = F.getAvatarComp2(char)
    if not comp then return end
    if F.setMakeSkinAtIndex(comp, applyIdx, itemId, applyEquipSlot) then
        pcall(function()
            if comp.OnRep_BodySlotStateChanged then comp:OnRep_BodySlotStateChanged() end
        end)
    end
end

function F.patchWearNetAvatar(comp, resID, slotName, noForceShow)
    if not comp or not slua.isValid(comp) or not resID or resID <= 0 or not slotName then return false end
    local ok = false
    pcall(function()
        local EAvatarSlotType = import("EAvatarSlotType")
        local ESyncOperation = import("ESyncOperation")
        local slot = EAvatarSlotType[slotName]
        if not slot then return end
        local sync = comp.GetSlotSyncData and comp:GetSlotSyncData(slot)
        if sync then
            sync.ItemID = resID
            if sync.FakeItemID ~= nil then sync.FakeItemID = resID end
            sync.OperationType = ESyncOperation.PutOn
            if comp.ChangeSlotSyncData then
                comp:ChangeSlotSyncData(sync)
                ok = true
            end
        end
        if not noForceShow and comp.SetAvatarVisibility then
            comp:SetAvatarVisibility(slot, true, true)
        end
    end)
    return ok
end

function F.patchHatNetAvatar(comp, hatRes)
    return F.patchWearNetAvatar(comp, hatRes, "EAvatarSlotType_HatEquipemtSlot")
end

function F.matchApplyWearItem(char, resID, slotID, label, opts)
    if not resID or resID <= 0 then return true end
    slotID = slotID or F.resToCustSlot(resID)
    if not slotID then return false end
    local comp = F.getAvatarComp2(char)
    if not comp then return false end
    opts = opts or {}
    opts.allowPutOn = true
    local ok = F.setMakeSkin(comp, resID, slotID, opts)
    return ok
end

function F.getDesiredMask()
    if MATCH_CONFIG.maskRes and tonumber(MATCH_CONFIG.maskRes) > 0 then
        return tonumber(MATCH_CONFIG.maskRes)
    end
    F.syncFaceCacheFromLobby()
    local m = F.cache().maskRes
    if m and tonumber(m) > 0 then return tonumber(m) end
    return tonumber(_G.AddOutfitLastLobbyMaskRes) or nil
end

function F.getDesiredGlass()
    if MATCH_CONFIG.glassRes and tonumber(MATCH_CONFIG.glassRes) > 0 then
        return tonumber(MATCH_CONFIG.glassRes)
    end
    F.syncFaceCacheFromLobby()
    local g = F.cache().glassRes
    if g and tonumber(g) > 0 then return tonumber(g) end
    return tonumber(_G.AddOutfitLastLobbyGlassRes) or nil
end

function F.matchApplyFaceWear(char)
    local maskRes = F.getDesiredMask()
    local glassRes = F.getDesiredGlass()
    if (not maskRes or maskRes <= 0) and (not glassRes or glassRes <= 0) then
        return true
    end
    char = char or F.getLocalChar()
    if not char then return false end
    local comp = F.getAvatarComp2(char)
    if not comp then return false end

    local ok = false
    pcall(function()
        local EAvatarSlotType = import("EAvatarSlotType")
        local ESyncOperation = import("ESyncOperation")
        local net = comp.NetAvatarData
        local applyData = net and net.SlotSyncData

        local function forceApplySlot(resID, slotID, slotNameStr)
            if not resID or resID <= 0 then return end
            
            local slotEnum = EAvatarSlotType and EAvatarSlotType[slotNameStr]
            local needRep = false
            
            -- 1. GHI ÄÃˆ DATA Máº NG (Chá»‘ng lá»—i khÃ´ng Ä‘á»“ng bá»™)
            if applyData and slua.isValid(applyData) then
                local found = false
                for i = 0, applyData:Num() - 1 do
                    local equipment = applyData:Get(i)
                    if equipment and equipment.SlotID == slotID then
                        found = true
                        local cur = tonumber(equipment.ItemId) or tonumber(equipment.ItemID) or 0
                        if cur ~= resID then
                            F.ensureSkinDownload(resID)
                            equipment.ItemId = resID
                            if equipment.ItemID ~= nil then equipment.ItemID = resID end
                            if equipment.FakeItemID ~= nil then equipment.FakeItemID = resID end
                            applyData:Set(i, equipment)
                            needRep = true
                        end
                        break
                    end
                end
                
                if not found then
                    F.ensureSkinDownload(resID)
                    local entry = import("AvatarSyncData")()
                    entry.SlotID = slotID
                    entry.ItemId = resID
                    entry.ItemID = resID
                    entry.FakeItemID = resID
                    entry.OperationType = ESyncOperation.PutOn
                    applyData:Add(entry)
                    needRep = true
                end
            end

            -- [LOGIC NGá»¦ ÄÃ”NG] - Tá»I Æ¯U FPS TUYá»†T Äá»I
            _G.FaceWearStateCache = _G.FaceWearStateCache or {}
            -- Táº¡o ID Ä‘á»‹nh danh riÃªng biá»‡t cho nhÃ¢n váº­t hiá»‡n táº¡i trÃ¡nh trÃ¹ng láº·p
            local cacheKey = tostring(comp) .. "_" .. tostring(slotID)

            if needRep or _G.FaceWearStateCache[cacheKey] ~= resID then
                -- Láº§n Ä‘áº§u tiÃªn Ã©p hiá»ƒn thá»‹ / Hoáº·c ID Skin bá»‹ thay Ä‘á»•i -> Cháº¡y Full C++
                if slotEnum then
                    if comp.CancelHideAvatarBySlot then comp:CancelHideAvatarBySlot(slotEnum) end
                    if comp.SetAvatarVisibility then comp:SetAvatarVisibility(slotEnum, true, true) end
                end
                if comp.PutOnCustomEquipmentByID then
                    comp:PutOnCustomEquipmentByID(resID)
                end
                
                -- Cáº­p nháº­t Cache Ä‘á»ƒ vÃ²ng láº·p sau Ä‘i vÃ o Ngá»§ ÄÃ´ng
                _G.FaceWearStateCache[cacheKey] = resID
                ok = true -- Báº­t cá» Ä‘á»ƒ gá»i OnRep_BodySlotStateChanged (váº½ láº¡i Mesh)
            else
                -- TRáº NG THÃI NGá»¦ ÄÃ”NG: Data Ä‘Ã£ Ä‘Ãºng, Mesh 3D Ä‘Ã£ Ä‘Æ°á»£c render.
                -- Chá»‰ cháº¡y hÃ m cá»±c nháº¹ CancelHide Ä‘á»ƒ chá»‘ng Game tá»± áº©n khi nháº·t MÅ© báº£o hiá»ƒm (1,2,3).
                -- Bá»Ž QUA viá»‡c Render láº¡i Mesh Ä‘á»ƒ trÃ¡nh Drop FPS.
                if slotEnum and comp.CancelHideAvatarBySlot then 
                    comp:CancelHideAvatarBySlot(slotEnum) 
                end
            end
        end

        -- Gá»i lá»‡nh Ã©p cho Máº·t náº¡ (Mask)
        forceApplySlot(maskRes, F.CUST_SLOT.FaceEquipemtSlot, "EAvatarSlotType_FaceEquipemtSlot")
        -- Gá»i lá»‡nh Ã©p cho Máº¯t kÃ­nh (Glass)
        forceApplySlot(glassRes, F.CUST_SLOT.GlassEquipemtSlot, "EAvatarSlotType_GlassEquipemtSlot")
        
        -- Cáº­p nháº­t hÃ¬nh áº£nh 3D CHá»ˆ KHI THOÃT KHá»ŽI NGá»¦ ÄÃ”NG (Khi cáº§n thiáº¿t)
        if ok and comp.OnRep_BodySlotStateChanged then
            comp:OnRep_BodySlotStateChanged()
        end
    end)
    return ok
end

function F.getDesiredWear(configKey, cacheResKey, globalKey, syncFn)
    local fixed = MATCH_CONFIG[configKey] and tonumber(MATCH_CONFIG[configKey])
    if fixed and fixed > 0 then return fixed end
    local persistKey = cacheResKey and cacheResKey:gsub("Res$", "")
    if persistKey and PERSIST.configSlots then
        local pr = tonumber(PERSIST.configSlots[persistKey])
        if pr and pr > 0 then return pr end
    end
    if syncFn then syncFn() end
    local v = F.cache()[cacheResKey]
    if v and tonumber(v) > 0 then return tonumber(v) end
    return tonumber(_G[globalKey]) or nil
end

local EQUIP_APPLY = { lastBagWrite = 0, lastHelmetWrite = 0 }

function F.levelSkinID(baseSkin, level)
    level = tonumber(level) or 1
    if level < 1 then level = 1 end
    local mapped = 0
    pcall(function()
        local t = CDataTable.GetTableData("BackpackMapping", baseSkin)
        if t then
            if level <= 1 then mapped = tonumber(t.SkinItemIDLv1) or 0
            elseif level == 2 then mapped = tonumber(t.SkinItemIDLv2) or 0
            else mapped = tonumber(t.SkinItemIDLv3) or 0 end
        end
    end)
    if mapped > 0 then return mapped end
    return baseSkin + (level - 1) * 1000
end

function F.applyEquipSkinToComp(comp, bagRes, helmetRes)
    local applied, found = false, false
    pcall(function()
        local EAvatarSlotType = import("EAvatarSlotType")
        local BackpackUtils = import("BackpackUtils")
        local function doSlot(slotEnum, res, levelFn, lastKey)
            res = tonumber(res) or 0
            if res <= 0 or not slotEnum then return end
            local sync = comp.GetSlotSyncData and comp:GetSlotSyncData(slotEnum)
            if not sync then return end
            local cur = tonumber(sync.ItemID) or 0
            local addID = tonumber(sync.AdditionalItemID) or 0
            if cur <= 0 and addID <= 0 then return end
            found = true
            local lvl = 1
            pcall(function()
                if levelFn then lvl = levelFn(addID > 0 and addID or cur) or 1 end
            end)
            if lvl < 1 then lvl = 1 end
            local target = F.levelSkinID(res, lvl)
            if target > 0 and cur ~= target then
                sync.ItemID = target
                comp:ChangeSlotSyncData(sync)
                applied = true
                EQUIP_APPLY[lastKey] = target
            end
        end
        doSlot(EAvatarSlotType.EAvatarSlotType_BackpackEquipemtSlot, bagRes,
               BackpackUtils.GetEquipmentBagLevel, "lastBagWrite")
        doSlot(EAvatarSlotType.EAvatarSlotType_HelmetEquipemtSlot, helmetRes,
               BackpackUtils.GetEquipmentHelmetLevel, "lastHelmetWrite")
    end)
    return applied, found
end

function F.matchApplyEquipmentSkin(char, bagRes, helmetRes)
    bagRes = tonumber(bagRes) or 0
    helmetRes = tonumber(helmetRes) or 0
    if bagRes <= 0 and helmetRes <= 0 then return true end
    local comp = char.CharacterAvatarComp2_BP
    if not slua.isValid(comp) then return false end

    local applied, found = F.applyEquipSkinToComp(comp, bagRes, helmetRes)

    if applied then
        pcall(function()
            if comp.OnRep_BodySlotStateChanged then comp:OnRep_BodySlotStateChanged() end
        end)
        return true
    end
    return found
end

function F.hookEquipmentRectify()
    _G.AddOutfitEquipRectifyFn = function(self)
        pcall(function()
            if self.IsLobbyActor and self:IsLobbyActor() then return end
            if not (self.IsSelf and self:IsSelf()) then return end
            local bagRes = F.getDesiredWear("bagRes", "bagRes", "AddOutfitLastLobbyBagRes", F.syncBodyCacheFromLobby)
            local helmetRes = F.getDesiredWear("helmetRes", "helmetRes", "AddOutfitLastLobbyHelmetRes", F.syncBodyCacheFromLobby)
            if (tonumber(bagRes) or 0) <= 0 and (tonumber(helmetRes) or 0) <= 0 then return end
            F.applyEquipSkinToComp(self, bagRes, helmetRes)
        end)
    end
    pcall(function()
        local MCAC = require("GameLua.Mod.TPlan.Component.MetroCharacterAvatarComponent")
        if MCAC._AddOutfitRectifyHooked then return end
        MCAC._AddOutfitRectifyHooked = true
        local o = MCAC.ProcessClientAvatarRectify
        MCAC.ProcessClientAvatarRectify = function(self)
            o(self)
            if _G.AddOutfitEquipRectifyFn then _G.AddOutfitEquipRectifyFn(self) end
        end
    end)
end

function F.applyAirborneSlots(char, forceInAir)
    local comp = F.getAvatarComp2(char)
    if not comp or not slua.isValid(comp) then return false end
    pcall(function() F.syncAirborneToDataMgr() end)
    local inAir = forceInAir == true or F.isCharacterAirborne(char)
    local any = false
    local paraRes = F.getDesiredParachuteRes()
    if paraRes and paraRes > 0 then
        any = true
        if not F.isResourcesReady(paraRes) then F.requestResourceDownload(paraRes) end
        F.setMakeSkin(comp, paraRes, F.CUST_SLOT.ParachuteEquipemtSlot, { inAir = inAir })
    end
    local gliderRes = F.getDesiredGliderRes()
    if gliderRes and gliderRes > 0 then
        any = true
        if not F.isResourcesReady(gliderRes) then F.requestResourceDownload(gliderRes) end
        F.setMakeSkin(comp, gliderRes, F.CUST_SLOT.GlideEquipemtSlot, { inAir = inAir })
    end
    return any
end

function F.matchApplyBodyWear(char)
    local pieces = {}
    if not F.getDesiredOutfit() then
        pieces[#pieces + 1] = {
            F.getDesiredWear("tshirtRes", "tshirtRes", "AddOutfitLastLobbyTshirtRes", F.syncBodyCacheFromLobby),
            F.CUST_SLOT.ClothesEquipemtSlot, "ØªÙŠØ´Ø±Øª",
        }
    end
    pieces[#pieces + 1] = { F.getDesiredWear("pantsRes", "pantsRes", "AddOutfitLastLobbyPantsRes", F.syncBodyCacheFromLobby), F.CUST_SLOT.PantsEquipemtSlot, "Ø³Ø±ÙˆØ§Ù„" }
    pieces[#pieces + 1] = { F.getDesiredWear("shoesRes", "shoesRes", "AddOutfitLastLobbyShoesRes", F.syncBodyCacheFromLobby), F.CUST_SLOT.ShoesEquipemtSlot, "Ø­Ø°Ø§Ø¡" }
    pieces[#pieces + 1] = { F.getDesiredWear("glovesRes", "glovesRes", "AddOutfitLastLobbyGlovesRes", F.syncBodyCacheFromLobby), F.CUST_SLOT.HandEffectEquipemtSlot, "Ù‚ÙØ§Ø²Ø§Øª" }
    local any, okAll = false, true
    for _, p in ipairs(pieces) do
        local res, slot, label = p[1], p[2], p[3]
        if res and res > 0 then
            any = true
            okAll = F.matchApplyWearItem(char, res, slot, label) and okAll
        end
    end
    local anyAir = F.applyAirborneSlots(char, false)
    if anyAir then any = true end
    local bagRes = F.getDesiredWear("bagRes", "bagRes", "AddOutfitLastLobbyBagRes", F.syncBodyCacheFromLobby)
    local helmetRes = F.getDesiredWear("helmetRes", "helmetRes", "AddOutfitLastLobbyHelmetRes", F.syncBodyCacheFromLobby)
    if (tonumber(bagRes) or 0) > 0 or (tonumber(helmetRes) or 0) > 0 then
        any = true
        okAll = F.matchApplyEquipmentSkin(char, bagRes, helmetRes) and okAll
    end
    return not any or okAll
end

function F.matchApplyAllSlots(char)
    if not char then return false end
    F.syncGlobalWearSkins()
    local comp = F.getAvatarComp2(char)
    if not comp then return false end

    local entries = {}
    local function add(skin, slot)
        skin = tonumber(skin)
        if skin and skin > 0 and slot then entries[#entries + 1] = { skin, slot } end
    end
    add(_G.HatSkin, F.CUST_SLOT.HatEquipemtSlot)
    add(_G.SuitSkin, F.CUST_SLOT.ClothesEquipemtSlot)
    add(_G.PantsSkin, F.CUST_SLOT.PantsEquipemtSlot)
    add(_G.ShoesSkin, F.CUST_SLOT.ShoesEquipemtSlot)
    add(_G.GlovesSkin, F.CUST_SLOT.HandEffectEquipemtSlot)
    add(_G.MaskSkin, F.CUST_SLOT.FaceEquipemtSlot)
    add(_G.GlassSkin, F.CUST_SLOT.GlassEquipemtSlot)

    local ok = false
    if #entries > 0 then
        ok = F.applySlotSkinBatch(comp, entries, { forceRep = true })
        if not ok then
            for _, e in ipairs(entries) do
                if F.setMakeSkin(comp, e[1], e[2], { allowPutOn = true }) then ok = true end
            end
        end
    end

    F.applyAirborneSlots(char, false)

    local bagRes = F.getDesiredWear("bagRes", "bagRes", "AddOutfitLastLobbyBagRes", F.syncBodyCacheFromLobby)
    local helmetRes = F.getDesiredWear("helmetRes", "helmetRes", "AddOutfitLastLobbyHelmetRes", F.syncBodyCacheFromLobby)
    if (tonumber(bagRes) or 0) > 0 or (tonumber(helmetRes) or 0) > 0 then
        ok = F.matchApplyEquipmentSkin(char, bagRes, helmetRes) or ok
    end

    return ok or #entries == 0
end

function F.matchApplyHat(char)
    local hatRes = tonumber(F.getDesiredHat())
    if not hatRes or hatRes <= 0 then return true end
    char = char or F.getLocalChar()
    if not char then return false end
    local comp = F.getAvatarComp2(char)
    if not comp then return false end
    local slotID = F.CUST_SLOT.HatEquipemtSlot
    local ok = false
    pcall(function()
        local net = comp.NetAvatarData
        if not net then return end
        local applyData = net.SlotSyncData
        if not applyData or not slua.isValid(applyData) then return end
        local found = false
        for i = 0, applyData:Num() - 1 do
            local equipment = applyData:Get(i)
            if equipment and equipment.SlotID == slotID then
                found = true
                local cur = tonumber(equipment.ItemId) or tonumber(equipment.ItemID) or 0
                if cur ~= hatRes then
                    F.ensureSkinDownload(hatRes)
                    equipment.ItemId = hatRes
                    if equipment.ItemID ~= nil then equipment.ItemID = hatRes end
                    if equipment.FakeItemID ~= nil then equipment.FakeItemID = hatRes end
                    applyData:Set(i, equipment)
                end
                ok = true
                break
            end
        end
        if not found then
            F.ensureSkinDownload(hatRes)
            local ESyncOperation = import("ESyncOperation")
            local entry = import("AvatarSyncData")()
            entry.SlotID = slotID
            entry.ItemId = hatRes
            entry.ItemID = hatRes
            entry.FakeItemID = hatRes
            entry.OperationType = ESyncOperation.PutOn
            applyData:Add(entry)
            ok = true
        end
        
    end)
    return ok
end

local _avatarItemsRegistered = false

function F.getDesiredWeaponSkins()
    if PERF.desiredSkins then return PERF.desiredSkins end
    F.syncWeaponCacheFromLobby()
    local out, seen = {}, {}
    local function add(res)
        res = tonumber(res)
        if res and res > 0 and not seen[res] then seen[res] = true; out[#out+1] = res end
    end
    for wid, w in pairs(F.cache().weapons) do
        if wid ~= MELEE_ID and w.resID then add(w.resID) end
    end
    if MATCH_CONFIG.weaponSkins then
        for _, res in pairs(MATCH_CONFIG.weaponSkins) do add(res) end
    end
    PERF.desiredSkins = out
    return out
end

function F._cacheSkinTarget(weaponResID, skin)
    if skin and skin > 0 then PERF.skinTarget[weaponResID] = skin else PERF.skinTarget[weaponResID] = 0 end
    return skin
end

local GUN_MASTER_SYN_SLOT = 7

function F.findSkinSlotInSynData(weapon)
    if not slua.isValid(weapon) then return GUN_MASTER_SYN_SLOT, 0 end
    local arr = weapon.synData
    if not arr or not slua.isValid(arr) then return GUN_MASTER_SYN_SLOT, 0 end
    local count = 0
    pcall(function() count = arr:Num() end)
    for i = 0, math.min(count - 1, 15) do
        local ok2, att = pcall(function() return arr:Get(i) end)
        if ok2 and att then
            local ok3, defRef = pcall(slua.IndexReference, att, "defineID")
            if ok3 and defRef then
                local tid = 0
                pcall(function() tid = tonumber(defRef.TypeSpecificID) or 0 end)
                if tid >= 1000000 then
                    return i, tid
                end
            end
        end
    end
    return GUN_MASTER_SYN_SLOT, 0
end

function F.resolveWeaponTypeID(weaponResID)
    weaponResID = tonumber(weaponResID) or 0
    if weaponResID <= 0 then return 0 end
    local found = 0
    pcall(function()
        local wc = CDataTable.GetTableData("WeaponConfig", weaponResID)
        if wc then found = tonumber(wc.WeaponID or wc.WeaponId or wc.weaponID or 0) end
    end)
    if found > 0 then return found end
    pcall(function()
        local ic = CDataTable.GetTableData("Item", weaponResID)
        if ic then found = tonumber(ic.WeaponID or ic.weaponId or 0) end
    end)
    return found > 0 and found or weaponResID
end

function F.findTargetSkinForWeaponRes(weaponResID)
    weaponResID = tonumber(weaponResID) or 0
    if weaponResID <= 0 then return nil end
    local cached = PERF.skinTarget[weaponResID]
    if cached ~= nil then return cached == 0 and nil or cached end

    local memSkin = F.getMatchWeaponSkin(weaponResID)
    if memSkin then return F._cacheSkinTarget(weaponResID, memSkin) end
    local typeID = F.resolveWeaponTypeID(weaponResID)
    if typeID > 0 and typeID ~= weaponResID then
        memSkin = F.getMatchWeaponSkin(typeID)
        if memSkin then return F._cacheSkinTarget(weaponResID, memSkin) end
    end

    if MATCH_CONFIG.weaponSkins and MATCH_CONFIG.weaponSkins[weaponResID] then
        local fixed = tonumber(MATCH_CONFIG.weaponSkins[weaponResID])
        if fixed and fixed > 0 then return F._cacheSkinTarget(weaponResID, fixed) end
    end

    for _, skinRes in ipairs(F.getDesiredWeaponSkins()) do
        local wid = F.weaponIdFromSkin(skinRes)
        if wid and tonumber(wid) == weaponResID then return F._cacheSkinTarget(weaponResID, skinRes) end
    end

    local typeID = F.resolveWeaponTypeID(weaponResID)
    if typeID > 0 and typeID ~= weaponResID then
        if MATCH_CONFIG.weaponSkins and MATCH_CONFIG.weaponSkins[typeID] then
            local fixed = tonumber(MATCH_CONFIG.weaponSkins[typeID])
            if fixed and fixed > 0 then return F._cacheSkinTarget(weaponResID, fixed) end
        end
        for _, skinRes in ipairs(F.getDesiredWeaponSkins()) do
            local wid = F.weaponIdFromSkin(skinRes)
            if wid and tonumber(wid) == typeID then return F._cacheSkinTarget(weaponResID, skinRes) end
        end
    end

    local avatarMatch = nil
    pcall(function()
        local AU = import("AvatarUtils")
        local weaponBase = AU.GetWeaponAvatarParentID(AU.GetBPIDByResID(weaponResID), false)
        if not weaponBase or weaponBase <= 0 then return end
        for _, skinRes in ipairs(F.getDesiredWeaponSkins()) do
            local skinBase = AU.GetWeaponAvatarParentID(AU.GetBPIDByResID(skinRes), false)
            if skinBase and skinBase > 0 and skinBase == weaponBase then
                avatarMatch = skinRes
                return
            end
        end
    end)
    if avatarMatch then return F._cacheSkinTarget(weaponResID, avatarMatch) end

    local c = F.cfg(weaponResID)
    local st = F.subType(c)
    if st and GUN_SUB[st] and MATCH_CONFIG.weaponSkins then
        for _, skinRes in pairs(MATCH_CONFIG.weaponSkins) do
            local skinWid = F.weaponIdFromSkin(skinRes)
            if skinWid then
                local sc = F.cfg(tonumber(skinWid))
                if sc and F.subType(sc) == st then return F._cacheSkinTarget(weaponResID, skinRes) end
            end
            local sc = F.cfg(skinRes)
            if sc and GUN_SUB[F.subType(sc)] and F.subType(sc) == st then return F._cacheSkinTarget(weaponResID, skinRes) end
        end
    end

    PERF.skinTarget[weaponResID] = 0
    return nil
end

function F.getSynMasterSkinID(weapon)
    if not slua.isValid(weapon) then return 0 end
    local id = 0
    pcall(function()
        local slot, tid = F.findSkinSlotInSynData(weapon)
        id = tid
        if id == 0 then
            local arr = weapon.synData
            if not arr or not slua.isValid(arr) then return end
            local att = arr:Get(GUN_MASTER_SYN_SLOT)
            if not att then return end
            id = slua.IndexReference(att, "defineID").TypeSpecificID or 0
        end
    end)
    return id
end

_G.AddOutfitSkinIdMappings = _G.AddOutfitSkinIdMappings or {}
_G.AddOutfitLastAppliedSkin = _G.AddOutfitLastAppliedSkin or {}

function F.buildSkinMappings()
    if not PERF.mappingsDirty then return end
    F.syncWeaponCacheFromLobby()
    PERF.mappingsDirty = false
    local m = _G.AddOutfitSkinIdMappings
    for k in pairs(m) do m[k] = nil end
    for wid, w in pairs(F.cache().weapons) do
        wid = tonumber(wid)
        if wid and w.resID and w.resID > 0 then
            m[wid] = { tonumber(w.resID) }
        end
    end
    if MATCH_CONFIG.weaponSkins then
        for weaponKey, skinRes in pairs(MATCH_CONFIG.weaponSkins) do
            weaponKey = tonumber(weaponKey)
            skinRes = tonumber(skinRes)
            if weaponKey and skinRes and skinRes > 0 and not m[weaponKey] then
                m[weaponKey] = { skinRes }
            end
        end
    end
end

function F.get_skin_id(currentGunId, maxIt)
    currentGunId = tonumber(currentGunId) or 0
    maxIt = tonumber(maxIt) or 0
    if currentGunId <= 0 and maxIt <= 0 then return 0 end
    F.buildSkinMappings()
    if maxIt > 0 then
        local fromMem = F.getMatchWeaponSkin(maxIt)
        if fromMem then return fromMem end
    end
    local fromMem2 = F.getMatchWeaponSkin(F.resolveWeaponTypeID(currentGunId))
    if fromMem2 then return fromMem2 end
    local m = _G.AddOutfitSkinIdMappings
    if maxIt > 0 and m[maxIt] and m[maxIt][1] then return tonumber(m[maxIt][1]) end
    local list = m[currentGunId]
    if list and list[1] then return tonumber(list[1]) end
    local typeId = F.resolveWeaponTypeID(currentGunId)
    if typeId > 0 and m[typeId] and m[typeId][1] then return tonumber(m[typeId][1]) end
    local target = F.findTargetSkinForWeaponRes(maxIt > 0 and maxIt or currentGunId)
    if target then return target end
    return currentGunId
end

function F.applySkinToWeaponRef(CurWeapon)
    if not slua.isValid(CurWeapon) then return false end
    local AttachmentArray = CurWeapon.synData
    if not AttachmentArray or not slua.isValid(AttachmentArray) then return false end

    local AttachmentData = AttachmentArray:Get(GUN_MASTER_SYN_SLOT)
    if not AttachmentData then return false end

    local current_gunid = 0
    pcall(function() current_gunid = slua.IndexReference(AttachmentData, "defineID").TypeSpecificID or 0 end)
    if not current_gunid or current_gunid <= 0 then return false end

    local MaxIt = 0
    pcall(function()
        if CurWeapon.GetWeaponID then MaxIt = CurWeapon:GetWeaponID() end
        if MaxIt <= 0 then MaxIt = CurWeapon:GetItemDefineID().TypeSpecificID end
    end)
    MaxIt = tonumber(MaxIt) or 0
    local tmp_id = F.get_skin_id(current_gunid, MaxIt)
    tmp_id = tonumber(tmp_id) or 0
    if tmp_id <= 0 or MaxIt <= 0 then return false end
    
    local changedAny = false

    -- LOGIC 1: Láº¤Y ID HÃŒNH áº¢NH ÄANG HIá»‚N THá»Š THá»°C Táº¾
    local wac = CurWeapon.WeaponAvatarComponent
    local currentVisualID = 0
    if slua.isValid(wac) then currentVisualID = wac.CachedLoadedID or 0 end

    -- Náº¾U SÃšNG CHÃNH CHÆ¯A PHáº¢I LÃ€ SKIN VIP -> THAY Äá»”I DATA
    if currentVisualID ~= tmp_id then
        changedAny = true
        pcall(function()
            local defRef = slua.IndexReference(AttachmentData, "defineID")
            defRef.TypeSpecificID = tmp_id
            local c0 = F.cfg(tmp_id)
            if c0 and c0.ItemType and defRef.Type ~= nil then defRef.Type = c0.ItemType end
            AttachmentData.operationType = 0
            AttachmentArray:Set(GUN_MASTER_SYN_SLOT, AttachmentData)
        end)
    end

    -- LOGIC 2: Xá»¬ LÃ PHá»¤ KIá»†N (ATTACHMENTS)
    if _G.LexusConfig.SkinAttachment and tmp_id >= 1000000 and _G.VIP_Attachments and _G.VIP_Attachments[tmp_id] then
        local attachSkinConfig = _G.VIP_Attachments[tmp_id]
        local baseAttachMap = _G.BaseAttachToIndex
        
        if attachSkinConfig and baseAttachMap then
            for AttachIdx = 0, 5 do 
                pcall(function()
                    local attachData = AttachmentArray:Get(AttachIdx)
                    if attachData then
                        local defineIDRef = slua.IndexReference(attachData, "defineID")
                        if defineIDRef then
                            local attachmentId = defineIDRef.TypeSpecificID
                            if attachmentId and attachmentId > 0 then
                                local baseAttId = attachmentId
                                if baseAttId > 1000000 then
                                    local strId = tostring(baseAttId)
                                    if #strId >= 9 then baseAttId = tonumber(string.sub(strId, 2, 7)) or baseAttId end
                                end

                                local mapIndex = baseAttachMap[baseAttId]
                                if mapIndex then
                                    local targetAttachId = attachSkinConfig[mapIndex]
                                    if targetAttachId and targetAttachId > 0 and targetAttachId ~= attachmentId then
                                        defineIDRef.TypeSpecificID = targetAttachId
                                        attachData.defineID = defineIDRef
                                        AttachmentArray:Set(AttachIdx, attachData)
                                        changedAny = true
                                        
                                        -- XÃ³a cache Phá»¥ kiá»‡n cÅ© Ä‘á»ƒ game Load phá»¥ kiá»‡n VIP
                                        if slua.isValid(wac) then
                                            if wac.ClearMeshPathCacheBySlot then wac:ClearMeshPathCacheBySlot(AttachIdx) end
                                            if wac.ClearMeshBySlot then wac:ClearMeshBySlot(AttachIdx, true, true) end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end
    end

    -- LOGIC 3: Lá»†NH THáº¦N THÃNH Ã‰P GAME Váº¼ Láº I MESH NGAY TRÃŠN TAY
    if changedAny then
        pcall(function()
            if slua.isValid(wac) then
                -- Náº¿u lÃ  sÃºng má»›i nháº·t, xÃ³a cÃ¡i vá» sÃºng cÅ© kÄ© Ä‘i
                if currentVisualID ~= tmp_id then
                    if wac.ClearMeshPathCacheBySlot then wac:ClearMeshPathCacheBySlot(0) end
                    if wac.ClearMeshBySlot then wac:ClearMeshBySlot(0, true, true) end
                end
                
                if CurWeapon.DelayHandleAvatarMeshChanged then
                    CurWeapon:DelayHandleAvatarMeshChanged()
                end
                if wac.ReloadAllEquippedAvatar then
                    wac:ReloadAllEquippedAvatar(1) 
                end
            end
        end)
        _G.AddOutfitLastAppliedSkin[MaxIt] = tmp_id
        return true
    end
    
    return false
end

function _G.equip_weapon_avatar(uCharacter)
    if not uCharacter or not slua.isValid(uCharacter) then return false end
    F.buildSkinMappings()
    local WeaponManager = uCharacter:GetWeaponManager()
    if not WeaponManager or not slua.isValid(WeaponManager) then return false end
    local uWeaponList = WeaponManager:GetAllInventoryWeaponList(false)
    if not uWeaponList or not slua.isValid(uWeaponList) then return false end

    local appliedAny = false
    for i = 0, uWeaponList:Num() - 1 do
        local CurWeapon = uWeaponList:Get(i)
        if slua.isValid(CurWeapon) and F.applySkinToWeaponRef(CurWeapon) then
            appliedAny = true
        end
    end
    return appliedAny
end

function F.equipWeaponAvatarSynData(char)
    return _G.equip_weapon_avatar(char)
end

F.applySkinToWeapon = F.applySkinToWeaponRef

function F.registerWeaponAvatarItems(char)
    local pc = char.GetPlayerControllerSafety and char:GetPlayerControllerSafety()
    if not slua.isValid(pc) then return false end
    local AU = import("AvatarUtils")
    local BU = import("BackpackUtils")
    local addedCount = 0

    for _, resID in ipairs(F.getDesiredWeaponSkins()) do
        local doneDirect = false
        pcall(function()
            if pc.AddWeaponAvatarItem then
                pc:AddWeaponAvatarItem(tonumber(resID))
                doneDirect = true
                addedCount = addedCount + 1
            end
        end)
        if not doneDirect then
            pcall(function()
                local skinBPID = BU.GetBPIDByResID(tonumber(resID))
                local arr = slua.Array(UEnums.EPropertyClass.Int)
                local parents = AU.GetWeaponAvatarParentIDList(skinBPID, arr, false)
                if parents and parents.Num and parents:Num() > 0 and pc.WeaponAvatarItemList then
                    for _, parentID in pairs(parents) do
                        pc.WeaponAvatarItemList:Add(parentID, skinBPID)
                    end
                    addedCount = addedCount + 1
                end
            end)
        end
    end

    if addedCount == 0 then return false end

    pcall(function() if pc.InitWeaponAvatarItems then pc:InitWeaponAvatarItems() end end)
    pcall(function() if pc.OnWeaponAvatarUpdate then pc:OnWeaponAvatarUpdate() end end)
    return true
end

function F.reloadCurrentWeaponAvatar(char)
    pcall(function()
        local weapon = char.GetCurrentWeapon and char:GetCurrentWeapon()
        if not slua.isValid(weapon) then return end
        local wac = weapon.WeaponAvatarComponent
        if slua.isValid(wac) then
            local ES = import("EWeaponAttachmentSocketType")
            pcall(function() wac:ClearMeshPathCacheBySlot(ES.MasterGun) end)
            pcall(function() wac:ClearMeshBySlot(ES.MasterGun, true, true) end)
        end
        if weapon.DelayHandleAvatarMeshChanged then
            weapon:DelayHandleAvatarMeshChanged()
        elseif slua.isValid(wac) and wac.ReloadAllEquippedAvatar then
            local ESlotDescDiff = import("ESlotDescDiff")
            wac:ReloadAllEquippedAvatar(ESlotDescDiff.MeshDiff)
        end
    end)
end

local _weaponDiagDone = false
local _weaponApplied = false
local _lastWeaponResID = 0
local _weaponSpawnHooked = false

function F.onWeaponLuaInit(_, _, weapon)
    if not weapon or not slua.isValid(weapon) then return end
    local char = F.getLocalChar()
    if not char then return end
    local owner = nil
    pcall(function()
        if weapon.GetOwnerPawn then owner = weapon:GetOwnerPawn() end
    end)
    if not slua.isValid(owner) or owner ~= char then return end
    pcall(function()
        char:AddGameTimer(0.15, false, function()
            local c = F.getLocalChar()
            if c and slua.isValid(weapon) then
                -- [FIX SCOPE GLITCH] Skip náº¿u Ä‘ang ADS
                local ads = false
                pcall(function() ads = c.bIsGunADS end)
                if not ads then
                    F.applySkinToWeapon(weapon)
                    _weaponApplied = false
                end
            end
        end)
    end)
end

function F.hookWeaponSpawn()
    if _weaponSpawnHooked then return end
    pcall(function()
        if EventSystem and EventSystem.registEvent and EVENTTYPE_PLAYEREVENT_WEAPON and EVENTID_PLAYEREVENT_WEAPON_LUA_INIT then
            EventSystem:registEvent(EVENTTYPE_PLAYEREVENT_WEAPON, EVENTID_PLAYEREVENT_WEAPON_LUA_INIT, onWeaponLuaInit)
            _weaponSpawnHooked = true
        end
    end)
end

function F.matchApplyWeaponSkin(char)
    if not _avatarItemsRegistered then
        _avatarItemsRegistered = F.registerWeaponAvatarItems(char)
    end

    local curWeapon = char.GetCurrentWeapon and char:GetCurrentWeapon()
    if not slua.isValid(curWeapon) then return false end

    local currentVisualID = 0
    pcall(function()
        local wac = curWeapon.WeaponAvatarComponent
        if slua.isValid(wac) then currentVisualID = wac.CachedLoadedID or 0 end
    end)

    local curWeaponResID = 0
    pcall(function() curWeaponResID = curWeapon:GetItemDefineID().TypeSpecificID end)
    local targetSkin = F.findTargetSkinForWeaponRes(curWeaponResID) or curWeaponResID

    local isVisualMatched = false
    if currentVisualID > 0 and currentVisualID == targetSkin then
        isVisualMatched = true
    end

    -- [Há»† THá»NG SMART WATCHER V3] QuÃ©t toÃ n bá»™ SÃºng trÃªn tay & SÃºng trong Balo
    -- [FIX PHONE CALL] Allow re-init if watcher died (phone call/game pause)
    if not _G.SmartWeaponWatcherActive then
        _G.SmartWeaponWatcherActive = true
        pcall(function()
            local ticker = require("common.time_ticker")
            if ticker and ticker.AddTimerLoop then
                ticker.AddTimerLoop(0, function()
                    if not _G.LexusConfig.ModSkin then return end
                    
                    -- [Cá»œ NGá»¦ ÄÃ”NG IN-GAME]: Náº¿u Ä‘Ã£ ra Sáº£nh -> Ngá»§ luÃ´n, khÃ´ng cháº¡y gÃ¬ háº¿t!
                    if _G.AddOutfit and not _G.AddOutfit.isInRealMatch() then return end
                    
                    local pController = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
                    if not pController or not slua.isValid(pController) then return end
                    local pChar = pController:GetPlayerCharacterSafety()
                    if not pChar or not slua.isValid(pChar) then return end
                    
                    -- [FIX SCOPE GLITCH] KhÃ´ng Ä‘á»•i skin khi Ä‘ang ADS (ngáº¯m báº¯n) -> trÃ¡nh bá»‹ má»Ÿ scope liÃªn tá»¥c
                    if pChar.bIsGunADS then return end
                    
                    -- Thay vÃ¬ chá»‰ láº¥y sÃºng trÃªn tay, láº¥y luÃ´n KHO VÅ¨ KHÃ (Weapon Manager)
                    local WeaponManager = pChar:GetWeaponManager()
                    if not WeaponManager or not slua.isValid(WeaponManager) then return end
                    local uWeaponList = WeaponManager:GetAllInventoryWeaponList(false)
                    if not uWeaponList or not slua.isValid(uWeaponList) then return end
                    
                    local count = uWeaponList:Num()
                    -- Láº·p qua tá»«ng kháº©u sÃºng báº¡n Ä‘ang sá»Ÿ há»¯u (SÃºng 1, SÃºng 2, Lá»¥c, Dao)
                    for i = 0, count - 1 do
                        local wep = uWeaponList:Get(i)
                        if slua.isValid(wep) then
                            -- Kiá»ƒm tra data (synData) cá»§a sÃºng xem Ä‘Ã£ lÃ  Data VIP chÆ°a
                            local synSkinID = F.getSynMasterSkinID(wep)
                            local baseID = 0
                            pcall(function() baseID = wep:GetItemDefineID().TypeSpecificID end)
                            local tSkin = F.findTargetSkinForWeaponRes(baseID) or baseID
                            
                            -- Náº¾U DATA CHÆ¯A PHáº¢I LÃ€ VIP -> Vá»«a lá»¥m tháº³ng vÃ o Balo -> Báº¯n lá»‡nh Load ngáº§m!
                            -- HOáº¶C báº­t Skin Phá»¥ Kiá»‡n -> Kiá»ƒm tra phá»¥ kiá»‡n
                            if synSkinID ~= tSkin or _G.LexusConfig.SkinAttachment then
                                if _G.AddOutfit and _G.AddOutfit.applySkinToWeapon then
                                    _G.AddOutfit.applySkinToWeapon(wep)
                                end
                            end
                        end
                    end
                end, -1, 0.4) 
            end
        end)
    end

    -- BÃO CÃO HOÃ€N THÃ€NH: Náº¿u sÃºng cáº§m trÃªn tay Ä‘Ã£ xong xuÃ´i thÃ¬ khÃ³a luá»“ng gá»‘c cá»§a Engine
    if isVisualMatched and not _G.LexusConfig.SkinAttachment then
        _weaponApplied = true
        return true
    end

    F.buildSkinMappings()
    local okSyn = F.applySkinToWeapon(curWeapon)

    return okSyn
end

local _matchTimer = nil
local _matchWearDone = false

function F.startMatchWatcher(char)
    if _matchTimer or PERF.matchActive then return end
    PERF.matchActive = true
    local skipWear = PERF.wearDoneThisMatch
    _matchWearDone = skipWear
    _avatarItemsRegistered = false
    _weaponDiagDone = false
    _weaponApplied = false
    _lastWeaponResID = 0
    local elapsed = 0

    _matchTimer = char:AddGameTimer(MATCH_TICK_SEC, true, function()
        elapsed = elapsed + MATCH_TICK_SEC
        local cur = F.getLocalChar()
        if not cur or not slua.isValid(cur) then return end

        -- [FIX SCOPE GLITCH] Skip táº¥t cáº£ skin apply khi Ä‘ang ADS Ä‘á»ƒ trÃ¡nh bá»‹ scope má»Ÿ liÃªn tá»¥c
        local isADS = false
        pcall(function() isADS = cur.bIsGunADS end)
        if not isADS then
            if not _matchWearDone then
                _matchWearDone = F.matchApplyAllSlots(cur)
            end
            F.matchApplyHat(cur)
            F.matchApplyFaceWear(cur) -- [FIX VIP] Bá»• sung lá»‡nh gá»i Ã©p KÃ­nh & Máº·t Náº¡ cháº¡y liÃªn tá»¥c giá»‘ng MÅ©
            if not _weaponApplied then
                F.matchApplyWeaponSkin(cur)
            end
            if F.isCharacterAirborne(cur) then
                F.applyAirborneSlots(cur, true)
            end
        end

        if (_matchWearDone and _weaponApplied) or elapsed >= MATCH_MAX_SEC then
            if _matchWearDone then
                PERF.wearDoneThisMatch = true
            end
            if _matchTimer and cur.RemoveGameTimer then
                pcall(function() cur:RemoveGameTimer(_matchTimer) end)
            end
            _matchTimer = nil
            PERF.matchActive = false
        end
    end)
end

function F.stopMatchWatcher()
    if _matchTimer then
        pcall(function()
            local char = F.getLocalChar()
            if char and char.RemoveGameTimer then char:RemoveGameTimer(_matchTimer) end
        end)
        _matchTimer = nil
    end
    PERF.matchActive = false
    PERF.wearDoneThisMatch = false
    _matchWearDone = false
    _avatarItemsRegistered = false
    _weaponApplied = false
    _weaponDiagDone = false
    _lastWeaponResID = 0
    -- [FIX PHONE CALL] Reset watcher flag so it can restart after game pause/phone call
    _G.SmartWeaponWatcherActive = false
end

function F.hookAirborneCache()
    if _G.AddOutfitAirborneHooked then return end
    _G.AddOutfitAirborneHooked = true
    pcall(function()
        if not EventSystem or not EventSystem.registEvent then return end
        if EVENTTYPE_WARDROBE and EVENTID_WARDROBE_UPDATE_ITEM_LIST then
            EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_ITEM_LIST, function()
                F.syncAirborneCacheFromLobby()
            end)
        end
    end)
end

function F.hookPutOnRsp()
    pcall(function()
        local wl = require("client.slua.logic.wardrobe.logic_wardrobe_new")
        local o = wl.on_puton_rsp
        wl.on_puton_rsp = function(self, res, item, olditem, index, extra)
            o(self, res, item, olditem, index, extra)
            if not item or not item.instid then return end
            local resID = tonumber(item.res_id)
            local insID = tonumber(item.instid)
            if not resID or not insID then return end
            local c = F.cfg(resID)
            local st = F.subType(c)
            if st == OUTFIT_SUB then
                F.saveEquip(resID, insID)
            elseif st == HAT_SUB or FACE_SUBS[st] or BODY_SUBS[st] or HELMET_SUBS[st]
                or st == PARACHUTE_SUB or F.isGlideRes(resID) or st == GLOVES_SUB then
                F.saveEquip(resID, insID)
            elseif F.isParachuteRes(resID) or F.isGlideRes(resID) then
                F.saveEquip(resID, insID)
            elseif HEAD_SUBS[st] then
                F.saveEquip(resID, insID)
            elseif GUN_SUB[st] then
                local wid = F.weaponIdFromSkin(resID)
                if wid then F.cacheWeaponSkinFromIns(wid, insID) end
            elseif st == MELEE_ID then
                F.cacheWeaponSkinFromIns(MELEE_ID, insID)
            elseif F.isInjectedIns(insID) then
                F.saveEquip(resID, insID)
            end
        end
    end)
end

function F.hookLobbyWeaponCache()
    if _G.AddOutfitLobbyWeaponCacheHooked then return end
    _G.AddOutfitLobbyWeaponCacheHooked = true
    pcall(function()
        local Arm = require("client.logic.armory.logic_armory")
        local oRsp = Arm.install_weapon_skin_rsp
        Arm.install_weapon_skin_rsp = function(client_data, errorCode, weapon_id, instanceID)
            oRsp(client_data, errorCode, weapon_id, instanceID)
            if (errorCode == 0 or errorCode == NET_OK) and F.isWeaponSkinIns(instanceID) then
                F.cacheWeaponSkinFromIns(weapon_id, instanceID)
            end
        end
        local oH = Arm.HandleWeaponSkinChange
        Arm.HandleWeaponSkinChange = function(client_data, weapon_id, instanceID)
            oH(client_data, weapon_id, instanceID)
            if F.isWeaponSkinIns(instanceID) then
                F.cacheWeaponSkinFromIns(weapon_id, instanceID)
            end
        end
    end)
    pcall(function()
        local wgl = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
        local o = wgl.on_put_on_weapon_wear_rsp
        wgl.on_put_on_weapon_wear_rsp = function(self, client_data, res, weapon_id, new_skin_id, extra_weapon_list)
            o(self, client_data, res, weapon_id, new_skin_id, extra_weapon_list)
            if res == 0 or res == NET_OK then
                F.cacheWeaponSkinFromIns(weapon_id, new_skin_id)
            end
        end
    end)
    pcall(function()
        if not EventSystem or not EventSystem.registEvent then return end
        if EVENTTYPE_WARDROBE and EVENTID_WARDROBE_UPDATE_CURRENT_PUT_ON_GUN then
            EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_CURRENT_PUT_ON_GUN, function(_, _, resOrFlag, weapon_id)
                weapon_id = tonumber(weapon_id)
                if weapon_id and weapon_id > 0 then
                    pcall(function()
                        local wgl = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
                        local insID = tonumber(wgl:GetSkinIdByWeaponID(weapon_id)) or 0
                        if insID > 0 then F.cacheWeaponSkinFromIns(weapon_id, insID) end
                    end)
                elseif tonumber(resOrFlag) and tonumber(resOrFlag) > 100000 then
                    pcall(function()
                        local wid = F.weaponIdFromSkin(resOrFlag)
                        if wid then
                            local wd = require("client.slua.logic.wardrobe.wardrobe_data")
                            local ins = wd.GetWardrobeInsIdByResId and wd:GetWardrobeInsIdByResId(resOrFlag)
                            if ins and ins > 0 then F.cacheWeaponSkinFromIns(wid, ins) end
                        end
                    end)
                end
            end)
        end
    end)
    pcall(function()
        local WRH = require("client.network.Protocol.WardRobeHandler")
        local oHeadReq = WRH.send_depot_set_head_show_req
        WRH.send_depot_set_head_show_req = function(insID)
            insID = tonumber(insID) or 0
            if insID > 0 and F.isInjectedIns(insID) then
                local wd = require("client.slua.logic.wardrobe.wardrobe_data")
                local d = wd:GetHallDepotItemDataByInsID(insID)
                if d and d.resID then
                    F.saveEquip(tonumber(d.resID), insID)
                end
                local fbd = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
                fbd:SetHeadShow(insID)
                WRH.on_depot_set_head_show_rsp(NET_OK, insID)
                return
            end
            return oHeadReq(insID)
        end
        local oHead = WRH.on_depot_set_head_show_rsp
        WRH.on_depot_set_head_show_rsp = function(err_code, id)
            oHead(err_code, id)
            if err_code ~= 0 and err_code ~= NET_OK then return end
            id = tonumber(id) or 0
            if id <= 0 then return end
            local wd = require("client.slua.logic.wardrobe.wardrobe_data")
            local d = wd:GetHallDepotItemDataByInsID(id)
            if d and d.resID then
                local st = tonumber(d.itemSubType or F.subType(F.cfg(d.resID)))
                if st == HAT_SUB or HELMET_SUBS[st] then
                    F.saveEquip(tonumber(d.resID), id)
                end
            end
        end
    end)
end

function F.hookWardrobePutOnReq()
    pcall(function()
        local wl = require("client.slua.logic.wardrobe.logic_wardrobe_new")
        if wl._AddOutfitPutOnReqHooked then return end
        wl._AddOutfitPutOnReqHooked = true
        local oReq = wl.wardrobe_puton_req
        wl.wardrobe_puton_req = function(self, insID, extra)
            insID = tonumber(insID)
            F.ensureDepotItemValid(insID)
            if F.tryLocalWearByIns(insID) then return end
            return oReq(self, insID, extra)
        end
        if not wl._AddOutfitPutOnDataHooked then
            wl._AddOutfitPutOnDataHooked = true
            local oData = wl.wardrobe_puton_data_req
            wl.wardrobe_puton_data_req = function(self, itemData)
                if itemData then
                    local insID = tonumber(itemData.ins_id or itemData.insID)
                    local resID = tonumber(itemData.res_id or itemData.resID)
                    F.clearItemExpire(itemData, insID, resID)
                    F.ensureDepotItemValid(insID, resID)
                end
                return oData(self, itemData)
            end
        end
    end)
end

local _bootstrapNotified = false

function F.bootstrapMatch(char)
    char = char or F.getLocalChar()
    if not char or not slua.isValid(char) then return false end
    if PERF.matchActive then return true end
    local now = os.clock()
    if (now - PERF.lastBootstrapAt) < BOOTSTRAP_COOLDOWN then return false end
    PERF.lastBootstrapAt = now
    F.syncWeaponCacheFromLobby(true)
    F.applyPersistSlotsToCache()
    F.cleanArmoryPollution()
    F.syncGlobalWearSkins()
    F.syncAirborneToDataMgr()
    pcall(function() F.applyAirborneSlots(char, F.isCharacterAirborne(char)) end)
    F.syncVehicleCacheFromDataMgr()
    F.syncVehicleSlotsToDataMgr()
    pcall(function() F.applyVehicleSkinsToPC(F.getPC()) end)
    F.startVehicleSkinTicker()
    pcall(function()
        local v = F.getMatchVehicle()
        if slua.isValid(v) then F.autoApplyVehicleSkinOnEnter(v) end
    end)
    _weaponApplied = false
    _weaponDiagDone = false
    _matchApplied = false
    if not _bootstrapNotified then
        _bootstrapNotified = true
    end
    F.startMatchWatcher(char)
    return true
end

function F.hookMatchAvatar()
    pcall(function()
        local CAC = require("GameLua.Mod.Library.GamePlay.Avatar.Component.CharacterAvatarComponent")
        local o = CAC.OnAvatarAllMeshLoadedLua
        CAC.OnAvatarAllMeshLoadedLua = function(self)
            o(self)
            pcall(function()
                if self.IsLobbyActor and self:IsLobbyActor() then return end
                local isSelf = self.IsSelf and self:IsSelf()
                if not isSelf then return end
                if PERF.wearDoneThisMatch or PERF.matchActive then return end
                local char = F.getLocalChar()
                if char and char.AddGameTimer then
                    char:AddGameTimer(0.5, false, function() F.bootstrapMatch(char) end)
                end
            end)
        end
    end)
    pcall(function()
        local WAC = require("GameLua.Mod.Library.GamePlay.Avatar.Component.WeaponAvatarComponent")
        local oLoad = WAC.OnWeaponAvatarLoadedLua
        WAC.OnWeaponAvatarLoadedLua = function(self, slotID, definedID)
            oLoad(self, slotID, definedID)
            pcall(function()
                if self.IsLobbyActor and self:IsLobbyActor() then return end
                local isSelf = self.IsSelf and self:IsSelf()
                if not isSelf then return end
                local char = F.getLocalChar()
                if not char then return end
                _weaponApplied = false
                if not PERF.matchActive then F.bootstrapMatch(char)
                elseif char.AddGameTimer then
                    char:AddGameTimer(0.25, false, function()
                        local c = F.getLocalChar()
                        if c then F.matchApplyWeaponSkin(c) end
                    end)
                end
            end)
        end
    end)
end

function F.hookVehicleInfoInit()
    pcall(function()
        if DataMgr._AddOutfitVehInfoHooked then return end
        DataMgr._AddOutfitVehInfoHooked = true
        local orig = DataMgr.InitVehicleInfo
        DataMgr.InitVehicleInfo = function(vehicle_info, vst_skin)
            vehicle_info = F.mergeInjectedIntoVehicleSlotList(vehicle_info)
            orig(vehicle_info, vst_skin)
            F.later(0.15, function()
                F.reapplyVehicleSlotsFromConfig()
                F.reapplyHallThemeFromConfig()
                LOBBY.reapplyDone = false
                LOBBY.reapplyScheduled = false
                F.scheduleLobbyReapplyOnce()
            end)
        end
    end)
end

function F.hookVehicleSkinDataInit()
    pcall(function()
        if DataMgr._AddOutfitVehSkinDataHooked then return end
        DataMgr._AddOutfitVehSkinDataHooked = true
        local origInit = DataMgr.InitVehicleSkinData
        DataMgr.InitVehicleSkinData = function(data)
            data = F.mergeInjectedVehicleSkinTable(data)
            origInit(data)
            F.later(0.1, function()
                F.equipVehicleTypesFromConfig(PERSIST.configVehicleSlots)
            end)
        end
        local origUpd = DataMgr.UpdateVehicleSkin
        DataMgr.UpdateVehicleSkin = function(itemSubType, putOnId)
            origUpd(itemSubType, putOnId)
            if not _G.AddOutfitApplyingConfig and F.isInjectedIns(putOnId) then
                F.setLobbyVehicleManual(itemSubType, R.insToRes[putOnId], putOnId)
            end
        end
    end)
    pcall(function()
        local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
        if HallThemeUtils._AddOutfitLobbyVehHooked then return end
        HallThemeUtils._AddOutfitLobbyVehHooked = true
        local orig = HallThemeUtils.ProcPutOnVehicle
        HallThemeUtils.ProcPutOnVehicle = function(putOnItem, bShowVehicle)
            orig(putOnItem, bShowVehicle)
            if not _G.AddOutfitApplyingConfig and putOnItem then
                local ins = tonumber(putOnItem.instid)
                local res = tonumber(putOnItem.res_id)
                if ins and F.isInjectedIns(ins) then
                    F.setLobbyVehicleManual(F.vehicleSubType(res or R.insToRes[ins]), res or R.insToRes[ins], ins)
                end
            end
        end
    end)
end

function F.hookHallTheme()
    pcall(function()
        local HT = require("client.logic.lobby.hall_theme_utils")
        if HT._AddOutfitHallThemeHooked then return end
        HT._AddOutfitHallThemeHooked = true
        local orig = HT.ProcPutOnHallTheme
        HT.ProcPutOnHallTheme = function(putOnItem, putOffItem)
            orig(putOnItem, putOffItem)
            if not _G.AddOutfitApplyingTheme and putOnItem then
                local ins = tonumber(putOnItem.instid)
                local res = tonumber(putOnItem.res_id)
                if ins and F.isInjectedIns(ins) then
                    F.setHallThemeManual(res or R.insToRes[ins], ins)
                end
            end
        end
    end)
end

function F.hookGarageTheme()
    pcall(function()
        local TeamupHandler = require("client.network.Protocol.TeamupHandler")
        local ModuleManager = require("client.module_framework.ModuleManager")
        if not TeamupHandler then return end
        
        -- Hook: Update Tá»«ng Slot Xe á»Ÿ sáº£nh
        local o_send_update = TeamupHandler.send_update_car_main_page_slot_req
        if o_send_update and not TeamupHandler._AddOutfitGarageUpdateHooked then
            TeamupHandler._AddOutfitGarageUpdateHooked = true
            TeamupHandler.send_update_car_main_page_slot_req = function(slot_id, item_inst_id)
                
                -- [Tá»I Æ¯U FPS - NGá»¦ ÄÃ”NG] Náº¿u Ä‘ang trong tráº­n thá»±c sá»± -> Bá» qua toÃ n bá»™ logic Gara Sáº£nh, tráº£ vá» game gá»‘c ngay láº­p tá»©c!
                if F.isInRealMatch() then 
                    return o_send_update(slot_id, item_inst_id) 
                end

                if F.isInjectedIns(tonumber(item_inst_id)) then
                    local resID = R.insToRes[tonumber(item_inst_id)]
                    local GarageThemeSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.GarageThemeSystem)
                    if not GarageThemeSystem then return end

                    GarageThemeSystem.GarageVehicleInfo[slot_id] = {
                        inst_id = tonumber(item_inst_id),
                        res_id = resID
                    }

                    for k, v in pairs(GarageThemeSystem.GarageVehicleInfo) do
                        if k ~= slot_id and v.inst_id == tonumber(item_inst_id) then
                            GarageThemeSystem.GarageVehicleInfo[k] = nil
                        end
                    end

                    pcall(function() GarageThemeSystem:ReportSpecialEffectTlog() end)
                    if EventSystem and EVENTTYPE_LOBBY_THEME and EVENTID_GARAGE_VEHICLE_DATA_CHANGE then
                        EventSystem:postEvent(EVENTTYPE_LOBBY_THEME, EVENTID_GARAGE_VEHICLE_DATA_CHANGE)
                    end

                    local itemCfg = F.cfg(resID)
                    if itemCfg and DataMgr and DataMgr.UpdateVehicleSkin then
                        local subType = itemCfg.ItemSubType or itemCfg.itemSubType
                        DataMgr.UpdateVehicleSkin(subType, tonumber(item_inst_id))
                    end
                    if DataMgr then DataMgr.vst_skin = tonumber(item_inst_id) end
                    
                    pcall(function()
                        local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
                        if HallThemeUtils then
                            if HallThemeUtils.UpdateThemeVehicleShow then HallThemeUtils.UpdateThemeVehicleShow() end
                            if HallThemeUtils.ShowThemeVehicle then HallThemeUtils.ShowThemeVehicle() end
                        end
                    end)
                    return
                end
                return o_send_update(slot_id, item_inst_id)
            end
        end

        -- Hook: Update HÃ ng loáº¡t xe á»Ÿ sáº£nh
        local o_send_batch = TeamupHandler.send_batch_put_on_sportscar_req
        if o_send_batch and not TeamupHandler._AddOutfitGarageBatchHooked then
            TeamupHandler._AddOutfitGarageBatchHooked = true
            TeamupHandler.send_batch_put_on_sportscar_req = function(instid_list)
                
                -- [Tá»I Æ¯U FPS - NGá»¦ ÄÃ”NG] TÆ°Æ¡ng tá»±, cháº·n Ä‘á»©ng khi Ä‘ang trong tráº­n
                if F.isInRealMatch() then 
                    return o_send_batch(instid_list) 
                end

                if type(instid_list) ~= "table" then
                    return o_send_batch(instid_list)
                end

                local hasInjected = false
                for slot_id, item_inst_id in pairs(instid_list) do
                    if F.isInjectedIns(tonumber(item_inst_id)) then
                        hasInjected = true
                        break
                    end
                end

                if not hasInjected then
                    return o_send_batch(instid_list)
                end

                local GarageThemeSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.GarageThemeSystem)
                if not GarageThemeSystem then return end

                for slot_id, item_inst_id in pairs(instid_list) do
                    local insID = tonumber(item_inst_id)
                    if F.isInjectedIns(insID) then
                        local resID = R.insToRes[insID]
                        if insID ~= 0 and resID then
                            GarageThemeSystem.GarageVehicleInfo[slot_id] = {
                                inst_id = insID,
                                res_id = resID
                            }
                        else
                            GarageThemeSystem.GarageVehicleInfo[slot_id] = nil
                        end
                    end
                end

                pcall(function() GarageThemeSystem:ReportSpecialEffectTlog() end)
                if EventSystem and EVENTTYPE_LOBBY_THEME and EVENTID_GARAGE_VEHICLE_DATA_CHANGE then
                    EventSystem:postEvent(EVENTTYPE_LOBBY_THEME, EVENTID_GARAGE_VEHICLE_DATA_CHANGE)
                end

                local nonInjected = {}
                for slot_id, item_inst_id in pairs(instid_list) do
                    if not F.isInjectedIns(tonumber(item_inst_id)) then
                        nonInjected[slot_id] = item_inst_id
                    end
                end
                if next(nonInjected) then
                    return o_send_batch(nonInjected)
                end
            end
        end
    end)
end

function F.hookEnterGame()
    if _G.AddOutfitEnterGameHooked then return end
    _G.AddOutfitEnterGameHooked = true
    pcall(function()
        if EventSystem and EventSystem.registEvent and EVENTTYPE_LOBBY and EVENTID_ENTER_GAME_BEGIN then
            EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_ENTER_GAME_BEGIN, function()
                F.perfInvalidateLobby()
                F.syncWeaponCacheFromLobby(true)
                F.reapplyVehicleSlotsFromConfig(true)
                F.reapplyHallThemeFromConfig(true)
                pcall(F.applyVehicleSkinsToPC)
                F.stopMatchWatcher()
                _bootstrapNotified = false
            end)
        end
    end)
end

function F.afterInjectApply(firstTime)
    F.mergeInjectedArmorySkins()
    F.cleanArmoryPollution()
    if firstTime then
        F.refreshWardrobeOnce()
        F.persistApplyLoaded()
        F.hookGarageTheme()
        F.syncLobbyVehicleResFromIns()
        F.reapplyVehicleSlotsFromConfig(true)
        F.reapplyHallThemeFromConfig(true)
        F.reapplyWeaponsFromConfig()
        F.scheduleLobbyReapplyOnce()
    else
        F.reapplyWeaponsFromConfig()
    end
end



function F.start()
    F.restorePufferHooks()
    F.buildSkinMappings()
    if not _G.AddOutfitPersistLoaded then
        _G.AddOutfitPersistLoaded = true
        F.persistLoadFromDisk()
    end
    F.applyPersistSlotsToCache()
    F.syncGlobalWearSkins()
    
    _G.apply_vehicle_skin = F.matchApplyVehicleSkin
    _G.skinIdMappings = _G.AddOutfitSkinIdMappings
    
    F.hookDepotInit()
    F.hookWardrobeData()
    F.hookPageFilter()
    F.hookArmory()
    F.hookGunSkinId()
    F.hookPutOn()
    F.hookPutDown()
    F.hookVehicles()
    F.hookAirborneClick()
    F.hookVehicleInfoInit()
    F.hookVehicleSkinDataInit()
    F.hookHallTheme()
    F.hookWeaponWear()
    F.hookNotice()
    F.hookAvatarValid()
    F.hookPutOnRsp()
    F.hookAirborneCache()
    F.hookLobbyWeaponCache()
    F.hookLobbySwipePersistence()
    F.hookWardrobePutOnReq()
    F.hookWardrobeWearClicks()
    F.hookMatchAvatar()
    F.hookEquipmentRectify()
    F.hookWeaponSpawn()
    F.hookEnterGame()

-- ==============================================================================
-- [THÃŠM Má»šI] LOGIC KILL MESSENGER, DEADBOX, Bá»˜ Äáº¾M KILL & ICON Tá»ª CODE MáºªU
-- ==============================================================================
local function decodeExpand(expandContent)
    local ok, exp = pcall(function() return slua.LuaArchiverDecode(LuaStateWrapper, expandContent) or {} end)
    return ok and exp or {}
end

local function encodeExpand(exp)
    return slua.LuaArchiverEncode(LuaStateWrapper, exp or {})
end

local _cachedMyName = nil
local function isMyKill(data)
    if not data then return false end
    if data.bIamCauser then return true end
    -- Tá»‘i Æ°u: Chá»‰ láº¥y tÃªn 1 láº§n duy nháº¥t, trÃ¡nh gá»i C++ SLUA hÃ ng ngÃ n láº§n
    if not _cachedMyName then
        local hud = slua_GameFrontendHUD
        if hud then
            local pc = hud:GetPlayerController()
            if slua.isValid(pc) then
                local ch = pc:GetPlayerCharacterSafety()
                if slua.isValid(ch) then _cachedMyName = ch:GetPlayerNameSafety() end
            end
        end
    end
    if not _cachedMyName or _cachedMyName == "" then return false end
    return data.Causer == _cachedMyName or data.CauserRealPlayerName == _cachedMyName or data.CauserPlayerName == _cachedMyName
end

local function getCurrentWeaponSkinID()
    -- [ÄÃƒ FIX] Láº¥y chÃ­nh xÃ¡c Skin ID cá»§a cÃ¢y sÃºng ÄANG Cáº¦M TRÃŠN TAY Ä‘á»ƒ trÃ¡nh hiá»‡n nháº§m Kill Message
    local hud = slua_GameFrontendHUD
    if not hud then return 0 end
    local pc = hud:GetPlayerController()
    if not slua.isValid(pc) then return 0 end
    local ch = pc:GetPlayerCharacterSafety()
    if not slua.isValid(ch) then return 0 end
    
    local currWeapon = ch:GetCurrentWeapon()
    if slua.isValid(currWeapon) and currWeapon.synData then
        local currentSkinID = 0
        pcall(function()
            local synDataRef = slua.IndexReference(currWeapon.synData:Get(7), "defineID")
            local skinID = synDataRef and slua.isValid(synDataRef) and synDataRef.TypeSpecificID or 0
            
            -- Chá»‰ xuáº¥t Kill Message náº¿u sÃºng trÃªn tay thá»±c sá»± lÃ  sÃºng VIP (ID > 1000000)
            if skinID > 1000000 then 
                currentSkinID = skinID
            end
        end)
        return currentSkinID
    end
    return 0
end

local _downloadedAssetsCache = {}
local function downloadTeamAssets(skinID)
    if not skinID or skinID == 0 or skinID == 69 then return end
    -- Tá»‘i Æ°u: Chá»‰ táº£i 1 láº§n duy nháº¥t má»—i skin, trÃ¡nh spam bÄƒng thÃ´ng vÃ  CPU
    if _downloadedAssetsCache[skinID] then return end
    _downloadedAssetsCache[skinID] = true

    pcall(function()
        local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
        local PufferConst = require("client.slua.logic.download.puffer_const")
        PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {skinID})
        
        local cfg = CDataTable.GetTableData("TeamKillBroadcast", skinID)
        if cfg then
            if cfg.EffectPath and cfg.EffectPath ~= "" then
                PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {cfg.EffectPath})
            end
            if cfg.BgPath and cfg.BgPath ~= "" then
                PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {cfg.BgPath})
            end
        end
    end)
end

local function patchTeamKill(messageData)
    if not _G.LexusConfig.KillMessage then return messageData end -- [CHáº¶N Náº¾U Táº®T CÃ”NG Táº®C]
    if not messageData or not isMyKill(messageData) then return messageData end
    local currentSkinID = getCurrentWeaponSkinID()
    if not currentSkinID or currentSkinID == 0 or currentSkinID == 69 then return messageData end
    local broadcastCfg = CDataTable.GetTableData("TeamKillBroadcast", currentSkinID)
    if not broadcastCfg or (not broadcastCfg.BgPath and not broadcastCfg.EffectPath) then return messageData end
    pcall(function()
        local exp = decodeExpand(messageData.ExpandDataContent)
        exp.CauserWeaponAvatarID = currentSkinID
        messageData.ExpandDataContent = encodeExpand(exp)
        messageData.bShowBottomBothSidesKillInfo = true
        messageData.bIamCauser = true
        downloadTeamAssets(currentSkinID)
    end)
    return messageData
end

local function installTeamBroadcastHooks()
    local function wrapCopy(mod, tag)
        if not mod then return end
        local impl2 = mod.__inner_impl or mod
        if not impl2 or not impl2.CopyKillOrPutDownMessageDataUserDataToLuaTable then return end
        local key = "__teamKillCopy_" .. tag
        if not impl2[key] then impl2[key] = impl2.CopyKillOrPutDownMessageDataUserDataToLuaTable end
        local O_Copy = impl2[key]
        impl2.CopyKillOrPutDownMessageDataUserDataToLuaTable = function(self, messageData)
            local copied = O_Copy(self, messageData)
            
            -- [Tá»I Æ¯U TUYá»†T Äá»I] Náº¿u táº¯t Kill Message -> Bá» qua toÃ n bá»™ logic bÃªn dÆ°á»›i, tráº£ vá» nguyÃªn báº£n cá»§a game luÃ´n.
            if not _G.LexusConfig.KillMessage then return copied end
            
            local ok2, result = pcall(function() return patchTeamKill(copied) end)
            if ok2 then return result end
            return copied
        end
    end
    pcall(function() wrapCopy(require("GameLua.Mod.BaseMod.Client.BattleKillBroadcast.BattleKillBroadcastSubSystem"), "base") end)
    pcall(function() wrapCopy(require("GameLua.Mod.SingleTraining.Client.BattleKillBroadcast.BattleKillBroadcastSubSystem"), "training") end)
end

-- Khá»Ÿi táº¡o há»‡ thá»‘ng Kill Count
_G.killCountInfo = {
    [101001] = 0000, [101004] = 0000, [101003] = 0000, [103001] = 0000,
    [102001] = 0000, [105001] = 0000, [102002] = 0000, [103002] = 0000
}

function _G.saveKillCountToFile()
    -- ÄÃ£ lÃ m rá»—ng hÃ m lÆ°u file Ä‘á»ƒ chá»‘ng Drop FPS
end

function _G.loadKillCountFromFile()
    -- ÄÃ£ lÃ m rá»—ng hÃ m Ä‘á»c file Ä‘á»ƒ chá»‘ng Drop FPS
end

function _G.addKill(weaponID, count)
    if not weaponID or not count then return end
    _G.killCountInfo[weaponID] = (_G.killCountInfo[weaponID] or 0) + count
    _G.saveKillCountToFile()
end

function _G.getKills(weaponID) return weaponID and _G.killCountInfo[weaponID] or 0 end

-- Hook Deadbox (Táº¡o HÃ²m XÃ¡c) vÃ  KillInfo
pcall(function()
    local SKillInfo = require("GameLua.Mod.BaseMod.Client.KillInfoTips.KillInfo")
    local SKillInfoModuleManager = require("client.module_framework.ModuleManager")
    local UEnums = _ENV.UEnums
    local ECharacterHealthStatus = import("ECharacterHealthStatus")
    
    if SKillInfo and SKillInfo.__inner_impl and SKillInfo.__inner_impl.FileItem then
        local O_FileItem = SKillInfo.__inner_impl.FileItem
        SKillInfo.__inner_impl.FileItem = function(self, DamageRecordData)
            if not self or not DamageRecordData then return end

            -- [Tá»I Æ¯U TUYá»†T Äá»I] Táº¯t cáº£ 3 chá»©c nÄƒng -> Tráº£ vá» game gá»‘c ngay láº­p tá»©c, siÃªu nháº¹
            if not _G.LexusConfig.SkinDeadBox and not _G.LexusConfig.KillCountUI and not _G.LexusConfig.KillMessage then
                return O_FileItem(self, DamageRecordData)
            end

            local LogicKillCounter = SKillInfoModuleManager.GetModule(SKillInfoModuleManager.CommonModuleConfig.LogicKillCounter)
            if not LogicKillCounter then return O_FileItem(self, DamageRecordData) end

            local uCharacter = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController() and slua_GameFrontendHUD:GetPlayerController():GetPlayerCharacterSafety()
            if not uCharacter or not slua.isValid(uCharacter) then return O_FileItem(self, DamageRecordData) end

            local SelfName = uCharacter:GetPlayerNameSafety()
            local bIsCauser = DamageRecordData.Causer == SelfName

            if bIsCauser then
                if DamageRecordData.DamageType == UEnums.DamageType.VehicleDamage then
                    if _G.LexusConfig.SkinDeadBox or _G.LexusConfig.KillMessage then 
                        local carSkinID = _G.CurrentEquipVehicleID or 0
                        if carSkinID ~= 0 then
                            local ExpandData = slua.LuaArchiverDecode(LuaStateWrapper, DamageRecordData.ExpandDataContent) or {}
                            ExpandData.CauserVehicleSkinID = carSkinID
                            if _G.LexusConfig.KillMessage then -- CHá»ˆ Báº¬T Má»šI Ã‰P SKIN LÃŠN KILL FEED
                                self:ChangeInfoBgByWeaponAvatarIDLua(carSkinID)
                                DamageRecordData.CauserWeaponAvatarID = carSkinID
                                DamageRecordData.CauserClothAvatarID = _G.SuitSkin or 0
                            end
                            DamageRecordData.ExpandDataContent = slua.LuaArchiverEncode(LuaStateWrapper, ExpandData)
                        end
                    end
                elseif DamageRecordData.CauserWeaponAvatarID ~= 69 and DamageRecordData.CauserClothAvatarID ~= 69 then
                    local currWeapon = uCharacter:GetCurrentWeapon()
                    if currWeapon and slua.isValid(currWeapon) then
                        local defineID = currWeapon:GetItemDefineID()
                        local DefineID = defineID and slua.isValid(defineID) and defineID.TypeSpecificID or 0
                        if DefineID ~= 0 then
                            local ExpandData = slua.LuaArchiverDecode(LuaStateWrapper, DamageRecordData.ExpandDataContent) or {}
                            local hasChanged = false

                            local SupportKillCounter = LogicKillCounter:GetBaseKillCounterIdByWeaponId(DefineID)
                            if SupportKillCounter and DamageRecordData.ResultHealthStatus == ECharacterHealthStatus.FinishedLastBreath then
                                local synDataRef = slua.IndexReference(currWeapon.synData:Get(7), "defineID")
                                local SkinID = synDataRef and slua.isValid(synDataRef) and synDataRef.TypeSpecificID or 0
                                
                                -- [Tá»I Æ¯U FPS] SÃºng Mod luÃ´n cÃ³ ID lá»›n hÆ¡n 1.000.000 (VÃ­ dá»¥ M4 BÄƒng: 1101004046)
                                if SkinID > 1000000 then 
                                    if _G.LexusConfig.KillCountUI then 
                                        ExpandData.KillCounterItemId = DefineID
                                        ExpandData.KillCounterNum = (ExpandData.KillCounterNum or 0) + 1
                                        _G.addKill(DefineID, 1)
                                        hasChanged = true
                                    end
                                    if _G.LexusConfig.SkinDeadBox then 
                                        _G.NeedCheckDeadBoxTimer = 5 
                                        hasChanged = true
                                    end
                                end
                            end

                            if hasChanged or _G.LexusConfig.KillMessage then
                                _G.UpdateMyKillCounter = true
                                if _G.LexusConfig.KillMessage then -- CHá»ˆ Báº¬T Má»šI THAY Äá»”I GÃ“I TIN Äá»‚ HIá»†N TRÃŠN TOP
                                    local synData = currWeapon.synData
                                    if synData and slua.isValid(synData) then
                                        local weaponDefineID = slua.IndexReference(synData:Get(7), "defineID")
                                        if weaponDefineID and slua.isValid(weaponDefineID) then
                                            DamageRecordData.CauserWeaponAvatarID = weaponDefineID.TypeSpecificID
                                        end
                                    end
                                    DamageRecordData.CauserClothAvatarID = _G.SuitSkin or 0
                                end
                                DamageRecordData.ExpandDataContent = slua.LuaArchiverEncode(LuaStateWrapper, ExpandData)
                            end
                        end
                    end
                end
            end
            O_FileItem(self, DamageRecordData)
        end
    end
end)

-- Hook UI Kill Counter (Cáº­p nháº­t sá»‘ Ä‘áº¿m & Icon trÃªn mÃ n hÃ¬nh)
pcall(function()
    local MyMainKillCounter = require("GameLua.Mod.BaseMod.Client.KillCounter.MainKillCounter")
    local MyKillCountSubSystem = require("GameLua.Mod.BaseMod.Client.KillCounter.KillCounterUISubsystem")
    local MyMainWeaponInfoItemUI = require("GameLua.Mod.BaseMod.Client.Backpack.MainWeaponInfoItemUI")
    local MyMainWeaponKillCounter = require("GameLua.Mod.BaseMod.Client.KillCounter.MainWeaponKillCounter")
    local SlotBase = require("GameLua.Mod.BaseMod.Client.MainControlUI.SwitchWeaponSlotMode2")
    local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
    local UIManager = require("client.slua_ui_framework.manager")
    local ModuleManager = require("client.module_framework.ModuleManager")

    if MyKillCountSubSystem and MyKillCountSubSystem.__inner_impl then
        _G.OurkillCountSystem = MyKillCountSubSystem.__inner_impl
        
        local o_OnRefreshUI = MyMainKillCounter.__inner_impl.OnRefreshUI
        MyMainKillCounter.__inner_impl.OnRefreshUI = function(self, _, _, UID)
            if not _G.LexusConfig.KillCountUI then return end -- CHáº¶N KHI Táº®T
            local LogicKillCounter = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicKillCounter)
            local curEquipedKillCounter = LogicKillCounter:GetEquipedKillCounterId(6114302174, self.WeaponID)
            local uCharacter = slua_GameFrontendHUD:GetPlayerController():GetPlayerCharacterSafety()
            local currweapon = uCharacter:GetCurrentWeapon()
            if currweapon ~= nil then
                local defineID = currweapon:GetItemDefineID()
                local DefineID = defineID and slua.isValid(defineID) and defineID.TypeSpecificID or 0
                local synDataRef = slua.IndexReference(currweapon.synData:Get(7), "defineID")
                local SkinID = synDataRef and slua.isValid(synDataRef) and synDataRef.TypeSpecificID or 0
                self.KillCounterItem:SetKillCounterItemShowWithNum(curEquipedKillCounter, _G.getKills(DefineID), SkinID)
            end
        end

        MyKillCountSubSystem.__inner_impl.CheckSupportKCUI = function(self) return _G.LexusConfig.KillCountUI end

        local o_UpdateMainKillCounterUI = MyKillCountSubSystem.__inner_impl.UpdateMainKillCounterUI
        MyKillCountSubSystem.__inner_impl.UpdateMainKillCounterUI = function(self, bShow, WeaponID, AvatarID)
            -- [Tá»I Æ¯U TUYá»†T Äá»I] BÃ³p ngháº¹t ngay lá»‡nh gá»i UI cá»§a Game náº¿u Ä‘ang táº¯t, CHá»NG CHá»šP (FLASH)
            if not _G.LexusConfig.KillCountUI then
                o_UpdateMainKillCounterUI(self, false, WeaponID, AvatarID) -- Ã‰p tham sá»‘ False
                local MainKillCounter = UIManager.GetUI(UIManager.UI_Config_InGame.MainKillCounter)
                if MainKillCounter then UIManager.CloseUI(UIManager.UI_Config_InGame.MainKillCounter) end
                return
            end

            o_UpdateMainKillCounterUI(self, bShow, WeaponID, AvatarID)
            local MainKillCounter = UIManager.GetUI(UIManager.UI_Config_InGame.MainKillCounter)
            local uCharacter = slua_GameFrontendHUD:GetPlayerController():GetPlayerCharacterSafety()
            local currweapon = uCharacter:GetCurrentWeapon()
         
            if not bShow and MainKillCounter then
                UIManager.CloseUI(UIManager.UI_Config_InGame.MainKillCounter)
            elseif bShow and currweapon ~= nil then
                local DefineID = currweapon:GetItemDefineID().TypeSpecificID
                local currentEquipAvatrid = slua.IndexReference(currweapon.synData:Get(7), "defineID").TypeSpecificID
                local LogicKillCounter = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicKillCounter)
                local SupportKillCounter = LogicKillCounter:GetBaseKillCounterIdByWeaponId(DefineID)
                
                local curEquipedKillCounter = LogicKillCounter:GetEquipedKillCounterId(6114302174, currentEquipAvatrid)
                
                -- [Tá»I Æ¯U FPS] NHáº¬N DIá»†N SÃšNG MOD: SÃºng thÆ°á»ng ID < 1.000.000, SÃºng Mod ID > 1.000.000
                local isModdedSkin = (currentEquipAvatrid and currentEquipAvatrid > 1000000)
                
                -- ÄÃ³ng UI náº¿u lÃ  sÃºng lá»¥c, dao, CHáº¢O hoáº·c SÃšNG THÆ¯á»œNG KHÃ”NG CÃ“ SKIN
                if (SupportKillCounter == nil or not isModdedSkin) then
                    if MainKillCounter then
                        UIManager.CloseUI(UIManager.UI_Config_InGame.MainKillCounter)
                    end
                else
                    -- Hiá»‡n UI náº¿u lÃ  sÃºng Mod (DÃ¹ curEquipedKillCounter cÃ³ tráº£ vá» nil do server khÃ´ng nháº­n diá»‡n Ä‘Æ°á»£c)
                    if not MainKillCounter then
                        UIManager.ShowUI(UIManager.UI_Config_InGame.MainKillCounter, DefineID, currentEquipAvatrid)
                        MainKillCounter = UIManager.GetUI(UIManager.UI_Config_InGame.MainKillCounter)
                        if MainKillCounter then
                            MainKillCounter:SetKillCounterItemShowWithNum(curEquipedKillCounter, _G.getKills(DefineID), currentEquipAvatrid)
                        end
                    else
                        MainKillCounter:UpdateWeaponID(DefineID, currentEquipAvatrid)
                        MainKillCounter:SetKillCounterItemShowWithNum(curEquipedKillCounter, _G.getKills(DefineID), currentEquipAvatrid)
                    end
                end
            end
        end

        local o_CheckNeedMainKillCounterUI = MyKillCountSubSystem.__inner_impl.CheckNeedMainKillCounterUI
        MyKillCountSubSystem.__inner_impl.CheckNeedMainKillCounterUI = function(self, Weapon, PlayerID)
            if not _G.LexusConfig.KillCountUI then return end -- CHáº¶N KHI Táº®T
            local uCharacter = slua_GameFrontendHUD:GetPlayerController():GetPlayerCharacterSafety()
            local currweapon = uCharacter:GetCurrentWeapon()
            if currweapon ~= nil then
                local defineID = currweapon:GetItemDefineID()
                local DefineID = defineID and slua.isValid(defineID) and defineID.TypeSpecificID or 0
                local synDataRef = slua.IndexReference(currweapon.synData:Get(7), "defineID")
                local SkinID = synDataRef and slua.isValid(synDataRef) and synDataRef.TypeSpecificID or 0
                self:UpdateMainKillCounterUI(true, DefineID, SkinID)
            end
        end
    end
end)

-- VÃ²ng láº·p Updater (ÄÃ£ tá»‘i Æ°u Cache: Chá»‰ Update UI khi Ä‘á»•i sÃºng hoáº·c cÃ³ máº¡ng Kill)
local _lastKCWeaponID = 0
local _lastKCSkinID = 0

_G.GameAvatarHandlerkillcounter = function()
    local UIManager = require("client.slua_ui_framework.manager")
    
    if not _G.LexusConfig.KillCountUI then
        local MainKillCounter = UIManager.GetUI(UIManager.UI_Config_InGame.MainKillCounter)
        if MainKillCounter then UIManager.CloseUI(UIManager.UI_Config_InGame.MainKillCounter) end
        return 
    end

    local PlayerController = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if not PlayerController or not slua.isValid(PlayerController) then return end
    
    local uCharacter = PlayerController:GetPlayerCharacterSafety()
    if not uCharacter or not slua.isValid(uCharacter) then return end
    
    local currweapon = uCharacter:GetCurrentWeapon()
    if currweapon and slua.isValid(currweapon) then
        -- Láº¥y DefineID an toÃ n, khÃ´ng táº¡o rÃ¡c RAM
        local defineIDObj = currweapon:GetItemDefineID()
        local currentWeaponID = (defineIDObj and slua.isValid(defineIDObj)) and defineIDObj.TypeSpecificID or 0
        
        -- Láº¥y Skin ID tá»« Cache cá»§a há»‡ thá»‘ng Skin V7.5 (Cá»±c nháº¹, khÃ´ng gá»i SLUA)
        local currentSkinID = 0
        if _G.AddOutfitLastAppliedSkin and _G.AddOutfitLastAppliedSkin[currentWeaponID] then
            currentSkinID = _G.AddOutfitLastAppliedSkin[currentWeaponID]
        end

        -- Tá»I Æ¯U Cá»°C Äá»˜: Chá»‰ gá»­i lá»‡nh cáº­p nháº­t UI náº¿u Má»šI Äá»”I SÃšNG hoáº·c Má»šI GIáº¾T NGÆ¯á»œI
        if _G.UpdateMyKillCounter or currentWeaponID ~= _lastKCWeaponID or currentSkinID ~= _lastKCSkinID then
            _lastKCWeaponID = currentWeaponID
            _lastKCSkinID = currentSkinID
            _G.UpdateMyKillCounter = false
            
            if _G.OurkillCountSystem then
                _G.OurkillCountSystem:UpdateMainKillCounterUI(true, currentWeaponID, currentSkinID)
            end
        end
    else
        _lastKCWeaponID = 0
        _lastKCSkinID = 0
        local MainKillCounter = UIManager.GetUI(UIManager.UI_Config_InGame.MainKillCounter)
        if MainKillCounter then UIManager.CloseUI(UIManager.UI_Config_InGame.MainKillCounter) end
    end
end

local function LobbyTickSetup()
    if not _G.CounterUpdated then
        _G.CounterUpdated = true
        _G.loadKillCountFromFile()
    end
    -- ÄÃƒ XÃ“A LOGIC QUÃ‰T FILE translateec.conf LIÃŠN Tá»¤C GÃ‚Y LAG
end

-- KÃ­ch hoáº¡t Hooks vÃ  Loop
pcall(function()
    installTeamBroadcastHooks()
    LobbyTickSetup() -- Chá»‰ gá»i Ä‘á»c file 1 láº§n duy nháº¥t khi vÃ o game, khÃ´ng láº·p láº¡i ná»¯a
    
    local ticker = require("common.time_ticker")
    if ticker and ticker.AddTimerLoop then
        ticker.AddTimerLoop(0, _G.GameAvatarHandlerkillcounter, -1, 0.5)
        -- ÄÃƒ XÃ“A VÃ’NG Láº¶P Äá»ŒC FILE 0.4 GIÃ‚Y Äá»‚ TRÃNH DROP FPS
    end
end)
-- ==============================================================================

    F.startVehicleSkinTicker()
    if not _G.AddOutfitVehInitTimers then
        _G.AddOutfitVehInitTimers = true
        F.later(1.5, function() pcall(F.applyVehicleSkinsToPC) end)
        F.later(4.0, function() pcall(F.applyVehicleSkinsToPC) end)
    end

    pcall(function()
        if F.isInRealMatch() then
            local char = F.getLocalChar()
            if char then
                F.bootstrapMatch(char)
            end
        end
    end)

    local firstLobby = not _G.AddOutfitLobbyInitDone
    if F.injectAll() then
        if firstLobby then _G.AddOutfitLobbyInitDone = true end
        F.afterInjectApply(firstLobby)
        return
    end
    local tries = 0
    local function retry()
        tries = tries + 1
        if F.injectAll() then
            local ft = not _G.AddOutfitLobbyInitDone
            if ft then _G.AddOutfitLobbyInitDone = true end
            F.afterInjectApply(ft)
            return
        end
        if tries < INJECT_RETRY_MAX then F.later(INJECT_RETRY_SEC, retry) end
    end
    F.later(INJECT_RETRY_SEC, retry)
end

_G.AddOutfit = F
F.start()

-- [FIX VIP] Há»† THá»NG Tá»° Äá»˜NG KHÃ”I PHá»¤C SKIN á»ž Sáº¢NH KHI Vá»ªA Má»ž GAME + SAU Má»–I TRáº¬N
_G.AddOutfitLobbyRestored = false

local function AutoRestoreLobbySkin()
    -- [Cá»œ NGá»¦ ÄÃ”NG LOBBY]: Náº¿u Ä‘Ã£ leo lÃªn mÃ¡y bay vÃ o tráº­n -> Ngá»§ luÃ´n
    if _G.AddOutfit and _G.AddOutfit.isInRealMatch() then return end
    
    -- [FIX] Chá»‰ load skin khi VIP Mod Skin Ä‘ang ON
    if not (_G.LexusConfig and _G.LexusConfig.ModSkin) then return end
    
    pcall(function()
        if GameStatus and GameStatus.IsInLobbyOrMainCity and GameStatus.IsInLobbyOrMainCity() then
            -- Chá» DataMgr táº£i xong UID
            if DataMgr and DataMgr.roleData and DataMgr.roleData.uid then
                if _G.AddOutfit and _G.AddOutfit.reapplyLobbyEquipped then
                    -- Äá»c File -> GÃ¡n Data -> Váº½ lÃªn nhÃ¢n váº­t
                    _G.AddOutfit.persistLoadFromDisk() 
                    _G.AddOutfit.persistApplyLoaded() 
                    _G.AddOutfit.reapplyLobbyEquipped() 
                    
                    -- Chá»‘t cá» Ä‘Ã£ hoÃ n thÃ nh
                    _G.AddOutfitLobbyRestored = true
                end
            end
        end
    end)
end


-- Cháº¡y ngáº§m 1 giÃ¢y / láº§n, load xong tá»± ngÆ°ng. Reset khi vÃ o tráº­n má»›i.
pcall(function()
    local ticker = require("common.time_ticker")
    if ticker and ticker.AddTimerLoop then
        ticker.AddTimerLoop(0, AutoRestoreLobbySkin, -1, 1.0)
    end
end)

-- [FIX] Reset lobby restore flag khi báº¯t Ä‘áº§u vÃ o tráº­n -> sau khi ra Sáº£nh sáº½ tá»± load láº¡i skin
pcall(function()
    if EventSystem and EventSystem.registEvent and EVENTTYPE_LOBBY and EVENTID_ENTER_GAME_BEGIN then
        EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_ENTER_GAME_BEGIN, function()
            _G.AddOutfitLobbyRestored = false
            -- Popup flags NOT reset here - popup shows only once per game session
            if LOBBY then
                LOBBY.reapplyDone = false
                LOBBY.reapplyScheduled = false
            end
        end)
    end
end)
-- ==============================================================================
-- ================= Káº¾T THÃšC CORE ADD-OUTFIT V7.5 (Há»† THá»NG SKIN) ==============
-- ==============================================================================

-- ==============================================================================
-- ================= Káº¾T THÃšC CORE ADD-OUTFIT V7.5 (Há»† THá»NG SKIN) ==============
-- ==============================================================================

-- ==============================================================================
-- ================= Báº®T Äáº¦U LOGIC MOD EMOTE (CHá»ˆ INGAME - 0% DROP FPS) =========
-- ==============================================================================
pcall(function()
    local QuickExpressionUtils = require("GameLua.Mod.BaseMod.Client.Emote.QuickExpressionUtils")

    -- Danh sÃ¡ch ID HÃ nh Äá»™ng VIP
    local EXTRA_EMOTES = {
          -- [ HÃ€NH Äá»˜NG ]
    12201301, -- HÃ nh Ä‘á»™ng SÃ¡t thá»§ Gothic
    12216101, -- HÃ nh Ä‘á»™ng VÃµ sÄ© Huyáº¿t Æ¯ng
    12212201, -- HÃ nh Ä‘á»™ng SÃ¡t thá»§ Cá»±c Ãm
    12219207, -- HÃ nh Ä‘á»™ng Äáº¡i tÆ°á»›ng ThiÃªn NgÆ°u
    12209001, -- HÃ nh Ä‘á»™ng VÃµ sÄ© (Samurai)
    12219561, -- HÃ nh Ä‘á»™ng Ão choÃ ng Äá» tháº«m
    12210001, -- HÃ nh Ä‘á»™ng CÃ¡i cháº¡m cá»§a Tá»­ tháº§n
    12219022, -- HÃ nh Ä‘á»™ng Thiáº¿t vá»‡ Gai gÃ³c
    12208801, -- HÃ nh Ä‘á»™ng @GRW_XD sÄ© BÃ¡n tháº§n
    12210801, -- HÃ nh Ä‘á»™ng Thá»£ sÄƒn Vá» báº¡c
    12200701, -- HÃ nh Ä‘á»™ng Du hÃ nh KhÃ´ng thá»i gian
    12219242, -- HÃ nh Ä‘á»™ng Dáº¡o bÆ°á»›c Báº§u trá»i
    12206001, -- HÃ nh Ä‘á»™ng Hoa linh Äá»“ng xanh
    12205401, -- HÃ nh Ä‘á»™ng Vua cá»§a muÃ´n thÃº
    12205201, -- HÃ nh Ä‘á»™ng TrÃ¡i tim Cá»± thÃº
    12212601, -- HÃ nh Ä‘á»™ng SÃ¡t lá»¥c Tháº§n bÃ­
    12205601, -- HÃ nh Ä‘á»™ng Linh há»“n Cá»± thÃº
    12219208, -- HÃ nh Ä‘á»™ng Háº§u vÆ°Æ¡ng Cyber
    12212001, -- HÃ nh Ä‘á»™ng VÃµ thÃ¡nh
    12206801, -- HÃ nh Ä‘á»™ng Háº£i long Tháº§n bÃ­
    12209801, -- HÃ nh Ä‘á»™ng Ngá»± linh sÆ°
    12211401, -- HÃ nh Ä‘á»™ng Ná»¯ phÃ¹ thá»§y BÄƒng tuyáº¿t
    12207001, -- HÃ nh Ä‘á»™ng Du hÃ nh Biá»ƒn sao
    12211801, -- HÃ nh Ä‘á»™ng ChÃºa tá»ƒ Tráº­t tá»±
    12207901, -- HÃ nh Ä‘á»™ng Háº£i vÆ°Æ¡ng Quyáº¿n rÅ©
    12203401, -- HÃ nh Ä‘á»™ng Ká»· niá»‡m áº¢o áº£nh
    12204001, -- HÃ nh Ä‘á»™ng ChÃº há» (NgÃ y CÃ¡ thÃ¡ng TÆ°)
    12201801, -- HÃ nh Ä‘á»™ng NgÆ°á»i báº£o vá»‡ VÃ¹ng tuyáº¿t
    12215601, -- HÃ nh Ä‘á»™ng SiÃªu nhÃ¢n Háº±ng tinh
    12215532, -- HÃ nh Ä‘á»™ng LÃ£nh chÃºa Ngá»n lá»­a
    12213201, -- HÃ nh Ä‘á»™ng Káº¿ hoáº¡ch NgÃ y mai
    12215529, -- HÃ nh Ä‘á»™ng Ká»µ sÄ© Äua xe
    12219053, -- HÃ nh Ä‘á»™ng Ná»¯ hoÃ ng TrÃ¢n báº£o
    12204601, -- HÃ nh Ä‘á»™ng ThiÃªn háº¡ Bá»‘ vÃµ
    12215701, -- HÃ nh Ä‘á»™ng HÃ nh tinh VÆ°á»£n ngÆ°á»i
    12219003, -- HÃ nh Ä‘á»™ng BÃ³ng tá»‘i Tháº§n linh
    12219004, -- HÃ nh Ä‘á»™ng NgÃ¢n há»“n Rá»±c lá»­a
    12219009, -- HÃ nh Ä‘á»™ng MÃª hoáº·c Rá»±c lá»­a
    12219216, -- HÃ nh Ä‘á»™ng Táº¿ tÆ° HÃ©o Ãºa
    }

    -- Tá»I Æ¯U Cá»°C Äá»˜: Cache dá»¯ liá»‡u trÃªn RAM Ä‘á»ƒ game khÃ´ng pháº£i táº¡o báº£ng má»›i má»—i láº§n báº¥m nÃºt
    local CachedInGameEmotes = nil
    local LastBaseCount = -1
    local LastEmoteSwitchState = nil

    -- HÃ m trá»™n Emote 1 láº§n duy nháº¥t
    local function GetOptimizedEmoteList(baseList)
        local baseCount = baseList and #baseList or 0
        local isEmoteModEnabled = _G.LexusConfig.ModEmote == true

        -- Náº¿u Ä‘Ã£ trá»™n rá»“i, sá»‘ lÆ°á»£ng Emote gá»‘c khÃ´ng Ä‘á»•i, VÃ€ tráº¡ng thÃ¡i nÃºt Báº­t/Táº¯t khÃ´ng Ä‘á»•i -> Láº¥y luÃ´n tá»« Cache ra xÃ i
        if CachedInGameEmotes and LastBaseCount == baseCount and LastEmoteSwitchState == isEmoteModEnabled then
            return CachedInGameEmotes
        end

        local compact = {}
        local seen = {}
        
        -- 1. ThÃªm Emote máº·c Ä‘á»‹nh cá»§a ngÆ°á»i chÆ¡i
        if baseList then
            for _, data in pairs(baseList) do
                if data and data.DefineID and data.DefineID.TypeSpecificID then
                    table.insert(compact, data)
                    seen[data.DefineID.TypeSpecificID] = true
                end
            end
        end

        -- 2. CHá»ˆ ThÃªm Emote VIP Náº¾U ÄANG Báº¬T CÃ”NG Táº®C
        if isEmoteModEnabled then
            for _, nEmoteID in ipairs(EXTRA_EMOTES) do
                if not seen[nEmoteID] then
                    table.insert(compact, {
                        DefineID = {TypeSpecificID = nEmoteID},
                        Name = tostring(nEmoteID)
                    })
                    seen[nEmoteID] = true
                end
            end
        end

        CachedInGameEmotes = compact
        LastBaseCount = baseCount
        LastEmoteSwitchState = isEmoteModEnabled
        return CachedInGameEmotes
    end

    -- Hook vÃ o hÃ m Load danh sÃ¡ch cá»§a In-game
    if QuickExpressionUtils and not _G.__EMOTE_INGAME_HOOKED then
        _G.__EMOTE_INGAME_HOOKED = true
        _G.__EMOTE_ORIG_GET_LIST = QuickExpressionUtils.GetShowExpressionList
        
        QuickExpressionUtils.GetShowExpressionList = function()
            local baseList, nWeaponShowEmoteID = _G.__EMOTE_ORIG_GET_LIST()
            return GetOptimizedEmoteList(baseList), nWeaponShowEmoteID
        end
    end

    -- Hook vÃ o sá»± kiá»‡n báº¥m nÃºt Emote trong game Ä‘á»ƒ Ã©p UI váº½ ra
    if not _G.__EMOTE_MENU_EVENT_HOOKED and EventSystem and EventSystem.registEvent then
        _G.__EMOTE_MENU_EVENT_HOOKED = true
        EventSystem:registEvent(EVENTTYPE_INGAME, EVENTID_INGAME_QUICK_EXPRESSION_DECAL_CLICK, function()
            pcall(function()
                -- Náº¾U ÄANG Táº®T MOD EMOTE -> Tráº£ vá» giao diá»‡n máº·c Ä‘á»‹nh cá»§a Game Ä‘á»ƒ khá»i lá»—i UI
                if not _G.LexusConfig.ModEmote then return end 

                local UIManager = require("client.slua_ui_framework.manager")
                if not UIManager or not UIManager.UI_Config_InGame then return end
                local subPanel = UIManager.GetUI(UIManager.UI_Config_InGame.QuickExpressionDecalSubPanel)
                
                if subPanel and subPanel.GetQuickExpressionDecalItemByIndex and CachedInGameEmotes then
                    local showCount = 0
                    for _, data in ipairs(CachedInGameEmotes) do
                        local nEmoteID = data.DefineID and data.DefineID.TypeSpecificID
                        if nEmoteID and nEmoteID > 0 then
                            showCount = showCount + 1
                            local item = subPanel:GetQuickExpressionDecalItemByIndex(showCount)
                            if item then
                                -- Táº¯t cÃ¡c hiá»‡u á»©ng thá»«a lÃ m náº·ng mÃ¡y
                                if item.UIRoot.WidgetSwitcher_Effect then item.UIRoot.WidgetSwitcher_Effect:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end
                                if item.UIRoot.Image_Weapon then item.UIRoot.Image_Weapon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end
                                
                                item:Show()
                                item:RefreshData(nEmoteID, -1)
                            end
                        end
                    end
                    if subPanel.HideRestBlocks then subPanel:HideRestBlocks(showCount) end
                    if subPanel.UIRoot then
                        subPanel.UIRoot.WrapBox_List:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
                        subPanel.UIRoot.VerticalBox_Empty:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
                    end
                end
            end)
        end)
    end
end)
-- ==============================================================================
-- ================= Káº¾T THÃšC LOGIC MOD EMOTE ===================================
-- ==============================================================================


end) -- end of pcall skin system




-- ==============================================================================
-- ============================ END SKIN MOD SYSTEM ============================
-- ==============================================================================

-- ============================ END SKIN MOD SYSTEM ============================

function BRPlayerCharacterBase:ctor()
end

function BRPlayerCharacterBase:_PostConstruct()
  BRPlayerCharacterBase.__super._PostConstruct(self)
  self:InitAddSpecialMoveInfo()
  self.bCanNearDeathGiveup = true
  print(bWriteLog and "BRPlayerCharacterBase:_PostConstruct bCanNearDeathGiveup true")
end

function BRPlayerCharacterBase:ReceiveBeginPlay()
  BRPlayerCharacterBase.__super.ReceiveBeginPlay(self)
  self:AddControlEvent(self, "MovementModeChangedDelegate", self.HandleOnMovementModeChangedNew, self)
  if self:HasAuthority() and self:CheckAddCheckFallingDistanceComponent() then
    local CheckFallingDistanceComponent_C = import("CheckFallingDistanceComponent")
    if slua.isValid(CheckFallingDistanceComponent_C) and not slua.isValid(self:GetComponentByClass(CheckFallingDistanceComponent_C)) then
      print(bWriteLog and "BRPlayerCharacterBase:ReceiveBeginPlay Add CheckFallingDistanceComponent")
      Game:AddComponent(CheckFallingDistanceComponent_C, self, "CheckFallingDistanceComponent")
    end
  end
  if slua.isValid(self.STCharacterMovement) then
    self.STCharacterMovement.bPositiveBlowUp = true
  end
  if self.Role == ENetRole.ROLE_AutonomousProxy then
    self:AddControlEvent(self, "OnPawnStateDisabled", self.OnPawnStateChange, self)
    self:AddControlEvent(self, "OnPawnStateEnabled", self.OnPawnStateChange, self)
    self:AddControlEventConditionOnly(self, "OnAttrChangeEventDelegate", {
      AttrName = {
        "bCanSelfRescue"
      }
    }, self.CharacterAttrChangeEvent, self)
  end
  if Client then
    printf(bWriteLog and "BRPlayerCharacterBase:ReceiveBeginPlay, PlayerKey:%u ", self.PlayerKey)
    GameplayData.AddCharacter(self.Object)
  else
    self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
      [1] = "FinishedState"
    }, self.HandleFinishedState, self)
  end
end

function BRPlayerCharacterBase:CharacterAttrChangeEvent(uPawn, AttrName, AttrVal)
  BRPlayerCharacterBase.__super.CharacterAttrChangeEvent(self, uPawn, AttrName, AttrVal)
  if self.Object ~= uPawn then
    return
  end
  if self.Role == ENetRole.ROLE_AutonomousProxy and AttrName == "bCanSelfRescue" then
    local uPlayerController = self:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      uPlayerController:BroadcastUIMessage("UIMsg_CanSelfRescue", 0, "", "")
    end
  end
end

function BRPlayerCharacterBase:OnPawnStateChange(PawnState)
  print("BRPlayerCharacterBase:OnPawnStateChange:", PawnState)
  if PawnState == EPawnState.SwitchPP then
    local uPlayerController = self:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      uPlayerController:BroadcastUIMessage("UIMsg_FPPModeChange", 0, "", "")
    end
  end
end

function BRPlayerCharacterBase:HandleFinishedState()
  print(bWriteLog and "BRPlayerCharacterBase:HandleFinishedState", self.STCharacterMovement)
  if slua.isValid(self.STCharacterMovement) and self.STCharacterMovement.SetDynamicSimpleQueryConfigDisable then
    local EDynamicSimpleQueryConfigDisableMask = import("EDynamicSimpleQueryConfigDisableMask")
    self.STCharacterMovement:SetDynamicSimpleQueryConfigDisable(EDynamicSimpleQueryConfigDisableMask.Bit0, true)
  end
end

function BRPlayerCharacterBase:CheckAddCheckFallingDistanceComponent()
  if CGameMode and CGameMode.GameModeType and CGameState and CGameState.GameModeID then
    local GameModeType = CGameMode.GameModeType
    local GameModeID = tonumber(CGameState.GameModeID)
    local bModeTypeSatisfy = GameModeType == EGameModeType.ETypicalGameMode or GameModeType == EGameModeType.EFourInOneGameMode or GameModeType == EGameModeType.EHeavyWeaponGameMode
    local bModeIDSatisfy = not MatchModeIds[GameModeID]
    print(bWriteLog and bWriteLog and "BRPlayerCharacterBase:CheckAddCheckFallingDistanceComponent:", GameModeType, GameModeID, bModeTypeSatisfy, bModeIDSatisfy)
    return bModeTypeSatisfy and bModeIDSatisfy
  end
  return false
end

function BRPlayerCharacterBase:LuaHandleParachuteStateChanged(LastParachuteState, NewParachuteState)
  BRPlayerCharacterBase.__super.LuaHandleParachuteStateChanged(self, LastParachuteState, NewParachuteState)
  if not Client then
    local uCurrentPlayerControl = self:GetPlayerControllerSafety()
    if slua.isValid(uCurrentPlayerControl) and uCurrentPlayerControl.CheckParachuteOpenFeature then
      if NewParachuteState == EParachuteState.PS_Opening then
        if uCurrentPlayerControl.CheckParachuteOpenFeature.SatrtCheckShowParachuteCloseUI then
          uCurrentPlayerControl.CheckParachuteOpenFeature:SatrtCheckShowParachuteCloseUI()
        end
      elseif NewParachuteState == EParachuteState.PS_None then
        if uCurrentPlayerControl.CheckParachuteOpenFeature.RecoverParachuteOpenParam then
          uCurrentPlayerControl.CheckParachuteOpenFeature:RecoverParachuteOpenParam()
        end
        if uCurrentPlayerControl.CheckParachuteOpenFeature.ClearTimerAndState then
          uCurrentPlayerControl.CheckParachuteOpenFeature:ClearTimerAndState()
        end
      end
    end
  end
end

function BRPlayerCharacterBase:OnLanded()
  printf("BRPlayerCharacterBase:OnLanded PlayerKey:%d", self.PlayerKey)
  if self.HandleOnLanded then
    self:HandleOnLanded(-1)
  end
  if not Client then
    local uCurrentPlayerControl = self:GetPlayerControllerSafety()
    if slua.isValid(uCurrentPlayerControl) and uCurrentPlayerControl.CheckParachuteOpenFeature then
      if uCurrentPlayerControl.CheckParachuteOpenFeature.ClearTimerAndState then
        uCurrentPlayerControl.CheckParachuteOpenFeature:ClearTimerAndState()
      end
      if uCurrentPlayerControl.CheckParachuteOpenFeature.ResetCheckShowUI then
        uCurrentPlayerControl.CheckParachuteOpenFeature:ResetCheckShowUI()
      end
    end
  end
end

function BRPlayerCharacterBase:ReceiveEndPlay(EndPlayReason)
  BRPlayerCharacterBase.__super.ReceiveEndPlay(self, EndPlayReason)
  if Client then
    GameplayData.RemoveCharacter(self.Object)
  end
end

function BRPlayerCharacterBase:IsWarGameMode()
  local uGameState = GameplayData:GetGameState()
  if slua.isValid(uGameState) and Game:IsClassOf(uGameState, STExtraGameStateBase) then
    return uGameState.GameModeType == EGameModeType.EWarGameMode
  else
    return false
  end
end

function BRPlayerCharacterBase:BPOnRecycled()
  print(bWriteLog and string.format("%s BPOnRecycled()", Game:GetPlainName(self.Object)))
  if Client then
    self:ResetMeshRelativeLocationAndRotation()
  end
end

function BRPlayerCharacterBase:BPOnRespawned()
  print(bWriteLog and string.format("%s BPOnRespawned()", Game:GetPlainName(self.Object)))
  if Client then
    self:ResetMeshRelativeLocationAndRotation()
  end
end

function BRPlayerCharacterBase:ReceiveOnRecycle()
  print(bWriteLog and string.format("%s IReusable:ReceiveOnRecycle()", Game:GetPlainName(self.Object)))
  if Client then
    self:ResetMeshRelativeLocationAndRotation()
    GameplayData.RemoveCharacter(self.Object)
  end
end

function BRPlayerCharacterBase:ReceiveOnSpawn()
  print(bWriteLog and string.format("%s IReusable:ReceiveOnSpawn()", Game:GetPlainName(self.Object)))
  if Client then
    self:ResetMeshRelativeLocationAndRotation()
    GameplayData.AddCharacter(self.Object)
  end
end

function BRPlayerCharacterBase:ResetMeshRelativeLocationAndRotation()
  if Game:IsValid(self.Object) and Game:IsValid(self.Mesh) then
    local uDefaultMeshRot = FRotator(0, -90, 0)
    local uDefaultMeshRelativeLoc = FVector(0, 0, 0)
    if self.Mesh.K2_SetRelativeRotation then
      self.Mesh:K2_SetRelativeRotation(uDefaultMeshRot, false, nil, false)
    end
    self:CacheInitialMeshOffset(uDefaultMeshRelativeLoc, uDefaultMeshRot)
    local vRelativeRot = self.Mesh.RelativeRotation
    local vBaseRotationOffset = self.BaseRotationOffset
    local vBaseRotation = Game:QuatToRotator(vBaseRotationOffset)
    print(bWriteLog and bWriteLog and string.format("%s ResetMeshRelativeLocationAndRotation() Mesh.RelativeRotation: %s %s %s   Pawn.BaseRotationOffset:%s %s %s ", Game:GetPlainName(self.Object), tostring(vRelativeRot.Pitch), tostring(vRelativeRot.Yaw), tostring(vRelativeRot.Roll), tostring(vBaseRotation.Pitch), tostring(vBaseRotation.Yaw), tostring(vBaseRotation.Roll)))
  end
end

function BRPlayerCharacterBase:HandleOnMovementModeChangedNew()
  print(bWriteLog and "BRPlayerCharacterBase:HandleOnMovementModeChanged11")
  if Game:IsValid(self.STCharacterMovement) and self.STCharacterMovement.MovementMode == EMovementMode.MOVE_Swimming and self:CheckBaseIsMoveable() then
    print(bWriteLog and "BRPlayerCharacterBase:HandleOnMovementModeChanged22")
    self.CharacterMovement:SetBase(nil, "", true)
  end
  if self.Role == ENetRole.ROLE_AutonomousProxy and Game:IsValid(self.STCharacterMovement) and self.STCharacterMovement.MovementMode == EMovementMode.MOVE_Walking and UIManager.UI_Config_InGame.ParachuteOpenUI then
    print(bWriteLog and "BRPlayerCharacterBase:HandleOnMovementModeChangedNew CloseUI")
    UIManager.CloseUI(UIManager.UI_Config_InGame.ParachuteOpenUI)
  end
end

function BRPlayerCharacterBase:BPOnMissPlayerDamageRecord()
end

function BRPlayerCharacterBase:PreAttachedToVehicle()
  local IsDS = UKismetSystemLibrary.IsDedicatedServer(self)
  if not IsDS then
    return
  end
  local MainPlayerController = self:GetPlayerControllerSafety()
  if not slua.isValid(MainPlayerController) then
    return
  end
  local CharacterAvatarComp2_BP = self.CharacterAvatarComp2_BP
  if not slua.isValid(CharacterAvatarComp2_BP) then
    return
  end
  local CommerAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.CommerAvatarDataUtil")
  local changedVehicleId = CommerAvatarDataUtil:ChangeVehicleSkinByClothes(MainPlayerController, CharacterAvatarComp2_BP)
  local ESTExtraVehicleShapeType = import("ESTExtraVehicleShapeType")
  if changedVehicleId then
    local UAvatarUtils = import("AvatarUtils")
    if UAvatarUtils.GetVehicleShapeBySkinID(changedVehicleId) == ESTExtraVehicleShapeType.VST_Horse then
      local uCurPlayerState = self:GetPlayerStateSafety()
      if slua.isValid(uCurPlayerState) then
        print(bWriteLog and "  BRPlayerCharacterBase:PreAttachedToVehicle. changedVehicleId: " .. tostring(changedVehicleId))
        uCurPlayerState:AddGeneralCount(468, 1, false)
      end
    end
  end
end

function BRPlayerCharacterBase:ParachuteJump()
  local uPlayerController = self:GetControllerSafety()
  if slua.isValid(uPlayerController) then
    if not self:GetEnsure() then
      if uPlayerController:GetCurrentStateType() ~= EStateType.State_ParachuteJump and uPlayerController:GetCurrentStateType() ~= EStateType.State_ParachuteOpen then
        self:SwitchPoseState(ESTEPoseState.Stand, true, true, true, false)
        uPlayerController:ReInitParachuteItem()
        uPlayerController:ServerChangeStatePC(EStateType.State_ParachuteJump)
      end
      print(bWriteLog and "BRPlayerCharacterBase:ParachuteJump over")
    else
      EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_AI_CALL_PARACHUTE_JUMP, self.Object)
      print(bWriteLog and "BRPlayerCharacterBase:ParachuteJump AI JUMP over, Loc=", tostring(self:K2_GetActorLocation():ToString()))
    end
  end
end

function BRPlayerCharacterBase:OnMovementBaseChangedEvent(uCharacter, uNewMovementBase, uOldMovementBase)
  if uCharacter ~= self.Object then
    return
  end
  print(bWriteLog and string.format("BRPlayerCharacterBase:OnMovementBaseChangedEvent %s, Base: %s -> %s", uCharacter, uOldMovementBase, uNewMovementBase))
  local MedievalCrane = self:GetMedievalCraneFromBase(uNewMovementBase)
  if MedievalCrane and MedievalCrane.AddCharacter then
    MedievalCrane:AddCharacter(self.Object)
  else
    MedievalCrane = self:GetMedievalCraneFromBase(uOldMovementBase)
    if MedievalCrane and MedievalCrane.RemoveCharacter then
      MedievalCrane:RemoveCharacter(self.Object)
    end
  end
end

function BRPlayerCharacterBase:GetMedievalCraneFromBase(Base)
  if not slua.isValid(Base) or not Base.GetOwner then
    return
  end
  local Lifter = Base:GetOwner()
  if not slua.isValid(Lifter) then
    return
  end
  if not Lifter.AddCharacter then
    return
  end
  return Lifter
end

function BRPlayerCharacterBase:CheckForbidFlaregun()
  local uPlayerState = self:GetPlayerStateSafety()
  if not slua.isValid(uPlayerState) then
    return false
  end
  if uPlayerState.CanUseFlaregun == false and self:IsLocallyControlled() then
    local uPlayerController = self:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      uPlayerController:DisplayGameTipWithMsgID(48532)
    end
  end
  return not uPlayerState.CanUseFlaregun
end

function BRPlayerCharacterBase:ServerRPC_NearDeathGiveupRescue()
  self:HandleNearDeathGiveupRescue()
end

function BRPlayerCharacterBase:HandleNearDeathGiveupRescue()
  local uNearDeathComp = self.NearDeatchComponent
  if self:IsNearDeath() and slua.isValid(uNearDeathComp) and self.bCanNearDeathGiveup == true then
    local uPlayerState = self:GetPlayerStateSafety()
    if slua.isValid(uPlayerState) then
      uPlayerState:AddGeneralCount(1613, 1, false)
    end
    uNearDeathComp:TriggerGotoDieExplictly(self.Object)
  end
end

function BRPlayerCharacterBase:RPC_Server_GmPlayAction(actionId)
  log(bWriteLog and "  BRPlayerCharacterBase:RPC_Server_GmPlayAction.  actionId: " .. tostring(actionId))
  if USTExtraBlueprintFunctionLibrary.IsDevelopment() then
    log(bWriteLog and "  BRPlayerCharacterBase:RPC_Server_GmPlayAction. IsDevelopment actionId: " .. tostring(actionId))
    self:MulticastRPC_GmPlayAction(actionId)
  end
end

function BRPlayerCharacterBase:MulticastRPC_GmPlayAction(actionId)
  if not Client then
    return
  end
  log(bWriteLog and "  BRPlayerCharacterBase:MulticastRPC_GmPlayAction.  actionId: " .. tostring(actionId))
  local uPlayEmoteComp = self:GetPlayEmoteComponent()
  if not slua.isValid(uPlayEmoteComp) then
    return
  end
  local LogFilter = require("common.log_filter")
  LogFilter.SetLogTreeEnable(true)
  local animCfg = CDataTable.GetTableData("EmoteBPTable", actionId)
  if not animCfg then
    return
  end
  local handlePath = animCfg.Path
  local EmoteHandleAsset = slua.loadObject(handlePath)
  local assetsArray = slua.Array(UEnums.EPropertyClass.Struct, import("/Script/CoreUObject.SoftObjectPath"))
  local handle = EmoteHandleAsset()
  uPlayEmoteComp:OnLoadEmoteAssetBegin(handle, actionId, assetsArray, "")
  log(bWriteLog and "  BRPlayerCharacterBase:MulticastRPC_GmPlayAction. assetsArray:Num(): " .. tostring(assetsArray:Num()))
  local tb = FuncUtil.LuaArrayToTable(assetsArray)
  local asset_util = require("common.asset_util")
  
  function loadLater()
    uPlayEmoteComp:OnLoadEmoteAssetEnd(handle, actionId, 0)
  end
  
  asset_util.GetAssetsArrayAsyncParallel(tb, loadLater)
end

function BRPlayerCharacterBase:RPC_Client_SetShouldCheckPassWall(bServerSyncShouldCheckPassWall)
  print(bWriteLog and "BRPlayerCharacterBase:RPC_Client_SetShouldCheckPassWall " .. tostring(bServerSyncShouldCheckPassWall))
  if slua.isValid(self.ParachuteComponent) then
    self.ParachuteComponent.bServerSyncShouldCheckPassWall = bServerSyncShouldCheckPassWall
  end
end

function BRPlayerCharacterBase:OnPlayerEnterCarryBoxState()
  self.Super:OnPlayerEnterCarryBoxState()
  local CharName = self:GetPlayerNameSafety()
  print(bWriteLog and string.format("DeadBoxLog BRPlayerCharacterBase:OnPlayerEnterCarryBoxState Role:%s PlayerKey:%s Name:%s", tostring(self.Role), tostring(self.PlayerKey), tostring(CharName)))
  if self.CarryDeadBoxFeature then
    self.CarryDeadBoxFeature:OnPlayerEnterCarryBoxState()
  end
end

function BRPlayerCharacterBase:OnPlayerLeaveCarryBoxState(bInIsInterrupt)
  self.Super:OnPlayerLeaveCarryBoxState(bInIsInterrupt)
  local CharName = self:GetPlayerNameSafety()
  print(bWriteLog and string.format("DeadBoxLog BRPlayerCharacterBase:OnPlayerLeaveCarryBoxState Role:%s PlayerKey:%s Name:%s bInIsInterrupt:%s", tostring(self.Role), tostring(self.PlayerKey), tostring(CharName), tostring(bInIsInterrupt)))
  if self.CarryDeadBoxFeature then
    self.CarryDeadBoxFeature:OnPlayerLeaveCarryBoxState(bInIsInterrupt)
  end
end

function BRPlayerCharacterBase:ServerRPC_CarryDeadBox(uInDeadBox)
  if slua.isValid(uInDeadBox) and Game:IsClassOf(uInDeadBox, import("/Script/ShadowTrackerExtra.PlayerTombBox")) and self.CarryDeadBoxFeature then
    self.CarryDeadBoxFeature:CarryDeadBox(uInDeadBox)
  end
end

function BRPlayerCharacterBase:SetAreaID(AreaID)
  self:SetAttrValue("AreaID", AreaID, -1)
end

function BRPlayerCharacterBase:GetAreaID()
  return math.floor(self:GetAttrValue("AreaID") + 0.5)
end

function BRPlayerCharacterBase:CannotChangeIntoPetSpectator()
  print(bWriteLog and "BRPlayerCharacterBase:CannotChangeIntoPetSpectator")
  return self.bCannotChangeIntoPetSpectator
end

function BRPlayerCharacterBase:DoModChangeToBT()
  print(bWriteLog and string.format("BRPlayerCharacterBase:DoModChangeToBT, PlayerKey=%s", tostring(self.PlayerKey)))
  if self:HasState(EPawnState.SpecialSuit) then
    self:TriggerEntrySkillWithID(4301101, true)
    print(bWriteLog and string.format("BRPlayerCharacterBase:DoModChangeToBT, PlayerKey=%s, HasState(EPawnState.SpecialSuit)", tostring(self.PlayerKey)))
  end
end

function BRPlayerCharacterBase:SwitchCameraToParachuteOpening()
  print(bWriteLog and "BRPlayerCharacterBase:SwitchCameraToParachuteOpening")
  self.Super:SwitchCameraToParachuteOpening()
  if self.ParachuteFormation and self.ParachuteFormation.ShouldApplyFormationCamera and self.ParachuteFormation:ShouldApplyFormationCamera() then
    self.ParachuteFormation:OverlayFormationCameraParams()
    print(bWriteLog and "BRPlayerCharacterBase:SwitchCameraToParachuteOpening - Formation camera overlaid")
  end
end

function BRPlayerCharacterBase:SwitchCameraToParachuteFalling()
  print(bWriteLog and "BRPlayerCharacterBase:SwitchCameraToParachuteFalling")
  self.Super:SwitchCameraToParachuteFalling()
  if self.ParachuteFormation and self.ParachuteFormation.ShouldApplyFormationCamera and self.ParachuteFormation:ShouldApplyFormationCamera() then
    self.ParachuteFormation:OverlayFormationCameraParams()
    print(bWriteLog and "BRPlayerCharacterBase:SwitchCameraToParachuteFalling - Formation camera overlaid")
  end
end

function BRPlayerCharacterBase:SwitchCameraToNormal()
  print(bWriteLog and "BRPlayerCharacterBase:SwitchCameraToNormal")
  self.Super:SwitchCameraToNormal()
  if self.ParachuteFormation and self.ParachuteFormation.OnLandingClearFormationCamera then
    self.ParachuteFormation:OnLandingClearFormationCamera()
  end
end

function BRPlayerCharacterBase:SwitchWeaponCheck(Slot, IgnoreState)
  if self:HasState(EPawnState.AttachToOther) then
    local Weapon = self:GetWeaponBySlot(Slot)
    if slua.isValid(Weapon) then
      local WeaponID = Weapon:GetWeaponID()
      local AttachToOtherConfig = GamePlayTools.GetCurrentConfig("AttachToOtherConfig")
      if AttachToOtherConfig and AttachToOtherConfig.CheckIsWeaponInBlackList and AttachToOtherConfig.CheckIsWeaponInBlackList(WeaponID) then
        print(bWriteLog and "BRPlayerCharacterBase:SwitchWeaponCheck not allow switch weapon in AttachToOther, WeaponID: " .. tostring(WeaponID))
        local uPlayerController = self:GetPlayerControllerSafety()
        if Client and slua.isValid(uPlayerController) and uPlayerController.Role == ENetRole.ROLE_AutonomousProxy then
          uPlayerController:DisplayGameTipWithMsgID(47306)
        end
        return false
      end
    end
  end
  if self:HasState(EPawnState.WebSwing) and Slot ~= ESurviveWeaponPropSlot.SWPS_None and slua.isValid(self.STCharacterMovement) then
    local SpiderSwingObj = self.STCharacterMovement:GetSpecialMoveObjBySpecialMoveType(ESpecialMovementType.SPECIAL_MOVE_SpiderSwing)
    if slua.isValid(SpiderSwingObj) then
      local nCurState = SpiderSwingObj:GetCurMoveState()
      if nCurState == ESpiderSwingMoveState.Launching or nCurState == ESpiderSwingMoveState.Swinging then
        print(bWriteLog and "BRPlayerCharacterBase:SwitchWeaponCheck blocked by SpiderSwing state: " .. tostring(nCurState))
        return false
      end
    end
  end
  return self.Super:SwitchWeaponCheck(Slot, IgnoreState)
end

local class = require("class")
local CCharacterBase = require("GameLua.GameCore.Framework.CharacterBase")
local CBRPlayerCharacterBase = class(CCharacterBase, nil, BRPlayerCharacterBase)
return require("combine_class").DeclareFeature(CBRPlayerCharacterBase, {
  {
    SkyTransition = "GameLua.Mod.BaseMod.Gameplay.Feature.SkyControl.PlayerCharacterSkyTransitionFeature"
  },
  {
    CarryDeadBoxFeature = "GameLua.Mod.Library.GamePlay.Feature.CarryDeadBoxFeature"
  },
  {
    SpecialSuitFeature = "GameLua.Mod.Library.GamePlay.Feature.SpecialSuitFeature"
  },
  {
    TeleportPawnFeature = "GameLua.Mod.Library.GamePlay.Feature.TeleportPawnFeature"
  },
  {
    LifterControl = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.CharacterLifterControlFeature"
  },
  {
    FinalKillEffect = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.PlayerCharacterFinalKillEffectFeature"
  },
  {
    CampFeature = "GameLua.Mod.BaseMod.Gameplay.Feature.Camp.PlayerCharacterCampFeature"
  },
  {
    BuildSkateFeature = "GameLua.Mod.BaseMod.Gameplay.Feature.PlayerCharacterBuildVehicleFeature"
  },
  {
    CommonBornlandTransformFeature = "GameLua.Mod.BaseMod.Gameplay.Feature.HeroPropFeature.CommonBornlandTransformFeature"
  },
  {
    ParachuteFormation = "GameLua.Mod.BaseMod.Gameplay.Feature.ParachuteFormationFeature"
  },
  {
    SpiderSenseFootprintFeature = "GameLua.Mod.Library.GamePlay.Feature.SpiderSenseFootprintFeature"
  },
  {
    GeneralShowSpotFeature = "GameLua.Mod.BRMod.Gameplay.Feature.PlayerCharacterGeneralShowSpotFeature"
  }
}, "BRPlayerCharacterBase")