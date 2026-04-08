-- Original remote hooking code (unchanged)
local originalRemotes = {}
local routerInit = debug.getupvalue(
    require(game.ReplicatedStorage.Fsys).load('RouterClient').init,
    7
)
for i, v in pairs(routerInit) do
    v.Name = i
    originalRemotes[i] = v
end
local Fsys = require(game:GetService('ReplicatedStorage'):WaitForChild('Fsys'))
local UIManager = Fsys.load('UIManager')
local toys = Fsys.load('ClientData').get('inventory').toys
local licenseUniqueId
for i, v in pairs(toys) do
    if v.id == 'trade_license' then
        licenseUniqueId = i
        break
    end
end
local function hookedEquip(player, uniqueId, ...)
    if uniqueId == licenseUniqueId then
        UIManager.set_app_visibility('TradeHistoryApp', true)
    end
    return originalRemotes['ToolAPI/Equip'](player, uniqueId, ...)
end
local function hookedUnequip(player, uniqueId)
    if uniqueId == licenseUniqueId then
        UIManager.set_app_visibility('TradeHistoryApp', false)
    end
    return originalRemotes['ToolAPI/Unequip'](player, uniqueId)
end
debug.setupvalue(
    require(game.ReplicatedStorage.Fsys).load('RouterClient').init,
    7,
    setmetatable({
        ['ToolAPI/Equip'] = hookedEquip,
        ['ToolAPI/Unequip'] = hookedUnequip,
    }, {
        __index = originalRemotes,
        __newindex = function(t, k, v)
            if k == 'ToolAPI/Equip' or k == 'ToolAPI/Unequip' then
                rawset(t, k, v)
            else
                originalRemotes[k] = v
            end
        end,
    })
)

-- Trade history hooking (unchanged)
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Fsys = require(ReplicatedStorage:WaitForChild('Fsys'))
local UIManager = Fsys.load('UIManager')
local TradeHistoryApp = UIManager.apps.TradeHistoryApp
local TradeApp = UIManager.apps.TradeApp
local LocalPlayer = Players.LocalPlayer
if TradeHistoryApp._ORIGINAL_create_trade_frame then
    TradeHistoryApp._create_trade_frame =
        TradeHistoryApp._ORIGINAL_create_trade_frame
end
if TradeApp._ORIGINAL_change_local_trade_state then
    TradeApp._change_local_trade_state =
        TradeApp._ORIGINAL_change_local_trade_state
end
if TradeApp._ORIGINAL_overwrite_local_trade_state then
    TradeApp._overwrite_local_trade_state =
        TradeApp._ORIGINAL_overwrite_local_trade_state
end
TradeHistoryApp._ORIGINAL_create_trade_frame =
    TradeHistoryApp._create_trade_frame
TradeApp._ORIGINAL_change_local_trade_state = TradeApp._change_local_trade_state
TradeApp._ORIGINAL_overwrite_local_trade_state =
    TradeApp._overwrite_local_trade_state
local tradeOffers = {}
TradeApp._change_local_trade_state = function(self, change, ...)
    local state = self:_get_local_trade_state()
    if state and state.trade_id then
        if state.sender == LocalPlayer and change.sender_offer then
            tradeOffers[state.trade_id] = {
                items = table.clone(change.sender_offer.items),
                isSender = true,
            }
        elseif state.recipient == LocalPlayer and change.recipient_offer then
            tradeOffers[state.trade_id] = {
                items = table.clone(change.recipient_offer.items),
                isSender = false,
            }
        end
    end
    return TradeApp._ORIGINAL_change_local_trade_state(self, change, ...)
end
TradeApp._overwrite_local_trade_state = function(self, trade, ...)
    if not trade and TradeApp._last_trade_id then
        tradeOffers[TradeApp._last_trade_id] = nil
    end
    return TradeApp._ORIGINAL_overwrite_local_trade_state(self, trade, ...)
end
TradeHistoryApp._create_trade_frame = function(self, tradeData, ...)
    if tradeData.trade_id and tradeOffers[tradeData.trade_id] then
        local offer = tradeOffers[tradeData.trade_id]
        local modified = table.clone(tradeData)

        if offer.isSender then
            modified.sender_items = table.clone(offer.items)
        else
            modified.recipient_items = table.clone(offer.items)
        end
        return self._ORIGINAL_create_trade_frame(self, modified, ...)
    end
    return self._ORIGINAL_create_trade_frame(self, tradeData, ...)
end

-- Visual pets trade hooking (unchanged)
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local Fsys = require(ReplicatedStorage:WaitForChild('Fsys'))
local UIManager = Fsys.load('UIManager')
local data
local _overwrite_local_trade_state =
    UIManager.apps.TradeApp._overwrite_local_trade_state
UIManager.apps.TradeApp._overwrite_local_trade_state = function(
    self,
    trade,
    ...
)
    if trade then
        local offer = trade.sender == Players.LocalPlayer and trade.sender_offer
            or trade.recipient == Players.LocalPlayer
                and trade.recipient_offer
        if offer then
            if data then
                offer.items = data
            end
        end
    else
        data = nil
    end
    return _overwrite_local_trade_state(self, trade, ...)
end
local _change_local_trade_state =
    UIManager.apps.TradeApp._change_local_trade_state
UIManager.apps.TradeApp._change_local_trade_state = function(self, change, ...)
    local trade = UIManager.apps.TradeApp.local_trade_state
    if trade then
        local team = trade.sender == Players.LocalPlayer and 'sender_offer'
            or trade.recipient == Players.LocalPlayer and 'recipient_offer'
        if team then
            local offer = change[team]
            if offer and offer.items then
                data = offer.items
            end
        end
    end
    return _change_local_trade_state(self, change, ...)
end

-- SPAWNER WITH PETNEONHELPER INTEGRATION
local TweenService = game:GetService('TweenService')
local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService('RunService')

-- Load required modules for neon functionality
local load = require(game.ReplicatedStorage:WaitForChild('Fsys')).load

-- INJECT THE DECOMPILED PETNEONHELPER FUNCTION
local PetNeonHelper = {}
do
    local load = require(game.ReplicatedStorage:WaitForChild("Fsys")).load
    local load_result1_upvr_2 = load("EffectsToggleHelper")
    local var1_result1_upvr = load("new:PetRigs")
    local tbl_2_upvr = {Color3.fromRGB(255, 72, 69), Color3.fromRGB(255, 96, 93), Color3.fromRGB(245, 255, 99), Color3.fromRGB(149, 255, 79), Color3.fromRGB(73, 255, 82), Color3.fromRGB(80, 255, 159), Color3.fromRGB(78, 47, 255), Color3.fromRGB(160, 97, 255), Color3.fromRGB(255, 97, 189), Color3.fromRGB(255, 101, 101)}
    
    PetNeonHelper = {
        get_mega_neon_defaults = function()
            return tbl_2_upvr
        end;
        apply_neon = function(arg1, arg2)
            for i, v in pairs(arg2) do
                local any_get_geo_part_result1_3 = var1_result1_upvr.get(arg1).get_geo_part(arg1, i)
                if any_get_geo_part_result1_3 then
                    if any_get_geo_part_result1_3:IsA("MeshPart") and any_get_geo_part_result1_3.TextureID ~= "" then
                        any_get_geo_part_result1_3.TextureID = ""
                    end
                    for i_2, v_2 in pairs(v) do
                        any_get_geo_part_result1_3[i_2] = v_2
                    end
                    any_get_geo_part_result1_3:SetAttribute("is_neon_transformed", true)
                end
            end
            if arg1:FindFirstChild("NeonEffects") then
                load_result1_upvr_2.toggle_effects(arg1.NeonEffects:GetDescendants(), true)
            end
            if arg1:FindFirstChild("NonNeonEffects") then
                load_result1_upvr_2.toggle_effects(arg1.NonNeonEffects:GetDescendants(), false)
            end
        end;
        disable_neon_effects = function(arg1)
            if arg1:FindFirstChild("NeonEffects") then
                load_result1_upvr_2.toggle_effects(arg1.NeonEffects:GetDescendants(), false)
            end
            if arg1:FindFirstChild("NonNeonEffects") then
                load_result1_upvr_2.toggle_effects(arg1.NonNeonEffects:GetDescendants(), true)
            end
        end;
    }
    
    local load_result1_upvr = load("PetColorHelper")
    local setmetatable_result1_upvr = setmetatable({}, {
        __mode = 'v';
    })
    local var1_result1_upvr_2 = load("LerpCIELUV")
    
    function PetNeonHelper.precache(arg1, arg2, arg3)
        local var59
        if arg3 then
        end
        local any_get_mega_neon_paint_entry_result1_2 = load_result1_upvr.get_mega_neon_paint_entry(arg3.Parent)
        if any_get_mega_neon_paint_entry_result1_2 then
            if not any_get_mega_neon_paint_entry_result1_2.gradient_to_apply then
            end
        else
        end
        var59 = nil
        if not var59 then
            if not arg2.mega_neon_colors then
            end
        end
        
        debug.setmemorycategory("PetEntities_NeonCache_Colors")
        if setmetatable_result1_upvr[tbl_2_upvr] then
            arg1.cached_colors = setmetatable_result1_upvr[tbl_2_upvr]
        else
            local tbl_7 = {}
            for i_3, v_3 in ipairs(tbl_2_upvr) do
                local tbl = {}
                local var18_result1 = var1_result1_upvr_2(v_3, tbl_2_upvr[i_3 % #tbl_2_upvr + 1])
                for i_4 = 0, 1, (1/60) do
                    table.insert(tbl, var18_result1(i_4))
                end
                table.insert(tbl_7, tbl)
            end
            setmetatable_result1_upvr[tbl_2_upvr] = tbl_7
            arg1.cached_colors = tbl_7
        end
        debug.resetmemorycategory()
        
        local tbl_6 = {}
        if arg2.neon_parts then
            for i_5 in pairs(arg2.mega_neon_parts) do
                local any_get_geo_part_result1 = var1_result1_upvr.get(arg3).get_geo_part(arg3, i_5)
                local var66
                if any_get_geo_part_result1 then
                    var18_result1 = any_get_geo_part_result1
                    var66 = table.insert
                    var66(tbl_6, var18_result1)
                    var18_result1 = "DisplayEyes"
                    var66 = any_get_geo_part_result1:FindFirstChild(var18_result1)
                    if not var66 then
                        var18_result1 = "DisplayPart"
                        var66 = any_get_geo_part_result1:FindFirstChild(var18_result1)
                    end
                    if var66 then
                        var18_result1 = tbl_6
                        table.insert(var18_result1, var66)
                    end
                end
            end
        end
        arg1.cached_parts = tbl_6
    end
    
    function PetNeonHelper.step_mega_neon(arg1, arg2, arg3)
        if not arg3.mega_neon_parts then
            return
        end
        if not arg1.cached_colors or not arg1.cached_parts then
            PetNeonHelper.precache(arg1, arg3, arg2)
        end
        
        debug.profilebegin("PetEntities_MegaNeon_CalculateFrame")
        local tick_result1 = tick()
        debug.profileend()
        
        if arg1.cached_colors[math.floor(tick_result1 / 1.5) % #arg1.cached_colors + 1][math.min(math.floor(tick_result1 % 1.5 * 60) + 1, 60)] then
            for _, v_4 in ipairs(arg1.cached_parts) do
                v_4.Color = arg1.cached_colors[math.floor(tick_result1 / 1.5) % #arg1.cached_colors + 1][math.min(math.floor(tick_result1 % 1.5 * 60) + 1, 60)]
            end
        end
    end
end

-- Store the original DoNeonFusion remote for fallback
local originalDoNeonFusion = nil

-- Track fusion in progress
local fusionInProgress = false
local pendingAutoEquip = nil

-- Store pet positions to prevent stacking
local spawnedPetPositions = {}
local positionOffset = Vector3.new(0, 0, 5) -- Offset to prevent stacking

-- Real Adopt Me Mega Neon color sequences
local REAL_MEGA_NEON_COLORS = {
    DEFAULT = {
        ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 127, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(75, 0, 130)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(148, 0, 211))
        })
    },
    CROW = {
        ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 40)),
            ColorSequenceKeypoint.new(0.25, Color3.fromRGB(100, 100, 100)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 180, 180)),
            ColorSequenceKeypoint.new(0.75, Color3.fromRGB(220, 220, 220)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 40))
        })
    },
    OWL = {
        ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 75, 0)),
            ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 215, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 150)),
            ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 215, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 75, 0))
        })
    },
    PARROT = {
        ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 165, 0)),
            ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(128, 0, 128))
        })
    },
    BAT_DRAGON = {
        ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(128, 0, 128)),
            ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(128, 0, 128)),
            ColorSequenceKeypoint.new(0.75, Color3.fromRGB(75, 0, 130)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(128, 0, 128))
        })
    },
    SHADOW_DRAGON = {
        ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 40)),
            ColorSequenceKeypoint.new(0.25, Color3.fromRGB(128, 0, 128)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(75, 0, 130)),
            ColorSequenceKeypoint.new(0.75, Color3.fromRGB(128, 0, 128)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 40))
        })
    },
    FROST_DRAGON = {
        ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 191, 255)),
            ColorSequenceKeypoint.new(0.25, Color3.fromRGB(135, 206, 235)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(176, 224, 230)),
            ColorSequenceKeypoint.new(0.75, Color3.fromRGB(135, 206, 235)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 191, 255))
        })
    },
    GIRAFFE = {
        ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(210, 180, 140)),
            ColorSequenceKeypoint.new(0.25, Color3.fromRGB(244, 164, 96)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 228, 196)),
            ColorSequenceKeypoint.new(0.75, Color3.fromRGB(244, 164, 96)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(210, 180, 140))
        })
    }
}

local function getRealMegaNeonColors(petName)
    local upperName = petName:upper()
    
    if upperName:find("CROW") then
        return REAL_MEGA_NEON_COLORS.CROW
    elseif upperName:find("OWL") then
        return REAL_MEGA_NEON_COLORS.OWL
    elseif upperName:find("PARROT") then
        return REAL_MEGA_NEON_COLORS.PARROT
    elseif upperName:find("BAT DRAGON") or upperName:find("BATDRAGON") then
        return REAL_MEGA_NEON_COLORS.BAT_DRAGON
    elseif upperName:find("SHADOW DRAGON") or upperName:find("SHADOWDRAGON") then
        return REAL_MEGA_NEON_COLORS.SHADOW_DRAGON
    elseif upperName:find("FROST DRAGON") or upperName:find("FROSTDRAGON") then
        return REAL_MEGA_NEON_COLORS.FROST_DRAGON
    elseif upperName:find("GIRAFFE") then
        return REAL_MEGA_NEON_COLORS.GIRAFFE
    end
    
    return REAL_MEGA_NEON_COLORS.DEFAULT
end

-- Function to get a non-stacked position for pets
local function getNonStackedPosition()
    local playerPos = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart and LocalPlayer.Character.PrimaryPart.Position
    local basePosition = playerPos or Vector3.new(0, 10, 0)
    
    -- Try different positions in a grid pattern
    for i = 1, 100 do  -- Try up to 100 different positions
        local row = math.floor((i - 1) / 10)  -- 10 pets per row
        local col = (i - 1) % 10
        
        local position = basePosition + Vector3.new(col * 4, 0, row * 4)  -- 4 studs spacing
        
        -- Check if position is occupied
        local isOccupied = false
        for _, pos in pairs(spawnedPetPositions) do
            if (pos - position).Magnitude < 3 then  -- 3 studs minimum distance
                isOccupied = true
                break
            end
        end
        
        if not isOccupied then
            spawnedPetPositions[#spawnedPetPositions + 1] = position
            return position
        end
    end
    
    -- If all positions are occupied, use a random one far away
    local randomPosition = basePosition + Vector3.new(
        math.random(-50, 50),
        0,
        math.random(-50, 50)
    )
    spawnedPetPositions[#spawnedPetPositions + 1] = randomPosition
    return randomPosition
end

-- Function to clear old positions periodically
local function cleanupPositions()
    while true do
        task.wait(10)  -- Clean up every 10 seconds
        if #spawnedPetPositions > 50 then  -- Keep only recent positions
            for i = 1, #spawnedPetPositions - 30 do
                spawnedPetPositions[i] = nil
            end
            -- Reindex the table
            local newPositions = {}
            for _, pos in pairs(spawnedPetPositions) do
                if pos then
                    table.insert(newPositions, pos)
                end
            end
            spawnedPetPositions = newPositions
        end
    end
end

-- Start position cleanup
task.spawn(cleanupPositions)

-- Pet spawning logic
task.spawn(function()
    local load = require(game.ReplicatedStorage:WaitForChild('Fsys')).load

    set_thread_identity(2)
    local clientData = load('ClientData')
    local items = load('KindDB')
    local router = load('RouterClient')
    local downloader = load('DownloadClient')
    local animationManager = load('AnimationManager')
    local petRigs = load('new:PetRigs')
    set_thread_identity(8)

    local petModels = {}
    local pets = {}
    local equippedPet = nil
    local mountedPet = nil
    local currentMountTrack = nil

    -- Store mega neon animators for each pet
    local megaNeonAnimators = {}

    local function updateData(key, action)
        local data = clientData.get(key)

        local clonedData = table.clone(data)
        clientData.predict(key, action(clonedData))
    end

    local function getUniqueId()
        local HttpService = game:GetService('HttpService')
        return HttpService:GenerateGUID(false)
    end

    local function getPetModel(kind)
        if petModels[kind] then
            return petModels[kind]
        end

        local streamed = downloader.promise_download_copy('Pets', kind):expect()
        petModels[kind] = streamed
        return streamed
    end

    local function createPet(id, properties, positionOverride)
        local uniqueId = getUniqueId()
        local item = items[id]
        if not item then
            warn('Pet ID not found: ' .. id)
            return nil
        end

        set_thread_identity(2)
        local new_pet = {
            unique = uniqueId,
            category = 'pets',
            id = id,
            kind = item.kind,
            newness_order = math.random(1, 900000),
            properties = properties or {},
            is_fusion_candidate = true,
            fusion_ready = true,
            can_fuse = true,
            fusion_properties = {
                is_neon = properties.neon or false,
                is_mega = properties.mega_neon or false,
                age = properties.age or 6,
                rarity = item.rarity or 'Common'
            }
        }
        
        local inventory = clientData.get('inventory')
        inventory.pets[uniqueId] = new_pet

        set_thread_identity(8)
        pets[uniqueId] = {
            data = new_pet,
            model = nil,
            fusion_data = {
                can_fuse = true,
                fusion_type = properties.mega_neon and 'mega' or (properties.neon and 'neon' or 'normal')
            },
            neon_cache = properties.mega_neon and {
                cached_colors = nil,
                cached_parts = nil
            } or nil,
            spawn_position = positionOverride or getNonStackedPosition()
        }
        return new_pet
    end

    local function removePetFromInventory(uniqueId)
        updateData('inventory', function(inventory)
            if inventory.pets[uniqueId] then
                inventory.pets[uniqueId] = nil
            end
            return inventory
        end)
    end

    -- Toy spawning function
    local function createToy(id)
        local uniqueId = getUniqueId()
        local item = items[id]
        if not item then
            warn('Toy ID not found: ' .. id)
            return nil
        end

        set_thread_identity(2)
        local new_toy = {
            unique = uniqueId,
            category = 'toys',
            id = id,
            kind = item.kind,
            newness_order = math.random(1, 900000),
            properties = {},
        }
        local inventory = clientData.get('inventory')
        inventory.toys[uniqueId] = new_toy

        set_thread_identity(8)
        return new_toy
    end

    -- Function to apply neon effects using PetNeonHelper
    local function applyNeonEffect(model, isNeon, isMegaNeon, petKind, petUniqueId, petId)
        if not model then return end
        
        local petModel = model:FindFirstChild('PetModel')
        if not petModel then return end
        
        PetNeonHelper.disable_neon_effects(petModel)
        
        petModel:SetAttribute("MegaNeon", false)
        petModel:SetAttribute("Neon", false)
        petModel:SetAttribute("NeonEnabled", false)
        
        if megaNeonAnimators[petUniqueId] then
            megaNeonAnimators[petUniqueId] = nil
        end
        
        if isMegaNeon then
            local neonConfig = items[petKind]
            if not neonConfig or not neonConfig.neon_parts then
                return
            end
            
            PetNeonHelper.apply_neon(petModel, neonConfig.neon_parts)
            
            petModel:SetAttribute("MegaNeon", true)
            petModel:SetAttribute("NeonEnabled", true)
            
            local petCache = pets[petUniqueId] and pets[petUniqueId].neon_cache
            if petCache then
                PetNeonHelper.precache(petCache, neonConfig, petModel)
            end
            
            task.spawn(function()
                while petModel and petModel:GetAttribute("MegaNeon") do
                    if petCache and petCache.cached_colors and petCache.cached_parts then
                        PetNeonHelper.step_mega_neon(petCache, petModel, neonConfig)
                    end
                    RunService.Heartbeat:Wait()
                end
            end)
            
        elseif isNeon then
            local neonConfig = items[petKind]
            if not neonConfig or not neonConfig.neon_parts then
                return
            end
            
            PetNeonHelper.apply_neon(petModel, neonConfig.neon_parts)
            
            petModel:SetAttribute("Neon", true)
            petModel:SetAttribute("NeonEnabled", true)
            
        else
            petModel:SetAttribute("MegaNeon", false)
            petModel:SetAttribute("Neon", false)
            petModel:SetAttribute("NeonEnabled", false)
            
            for _, part in pairs(petModel:GetDescendants()) do
                if part:IsA("BasePart") and part:GetAttribute("is_neon_transformed") then
                    part:SetAttribute("is_neon_transformed", nil)
                end
            end
        end
    end

    local function addPetWrapper(wrapper)
        updateData('pet_char_wrappers', function(petWrappers)
            wrapper.unique = #petWrappers + 1
            wrapper.index = #petWrappers + 1
            petWrappers[#petWrappers + 1] = wrapper
            return petWrappers
        end)
    end

    local function addPetState(state)
        updateData('pet_state_managers', function(petStates)
            petStates[#petStates + 1] = state
            return petStates
        end)
    end

    local function findIndex(array, finder)
        for index, value in pairs(array) do
            local isIt = finder(value, index)

            if isIt then
                return index
            end
        end

        return nil
    end

    local function removePetWrapper(uniqueId)
        updateData('pet_char_wrappers', function(petWrappers)
            local index = findIndex(petWrappers, function(wrapper)
                return wrapper.pet_unique == uniqueId
            end)

            if not index then
                return petWrappers
            end

            table.remove(petWrappers, index)

            for wrapperIndex, wrapper in pairs(petWrappers) do
                wrapper.unique = wrapperIndex
                wrapper.index = wrapperIndex
            end

            return petWrappers
        end)
    end

    local function clearPetState(uniqueId)
        local pet = pets[uniqueId]

        if not pet then
            return
        end

        if not pet.model then
            return
        end

        updateData('pet_state_managers', function(states)
            local index = findIndex(states, function(state)
                return state.char == pet.model
            end)

            if not index then
                return states
            end

            local clonedStates = table.clone(states)

            clonedStates[index] = table.clone(clonedStates[index])
            clonedStates[index].states = {}

            return clonedStates
        end)
    end

    local function setPetState(uniqueId, id)
        local pet = pets[uniqueId]

        if not pet then
            return
        end

        if not pet.model then
            return
        end

        updateData('pet_state_managers', function(states)
            local index = findIndex(states, function(state)
                return state.char == pet.model
            end)

            if not index then
                return states
            end

            local clonedStates = table.clone(states)

            clonedStates[index] = table.clone(clonedStates[index])
            clonedStates[index].states = {
                { id = id },
            }

            return clonedStates
        end)
    end

    local function attachPlayerToPet(pet)
        local character = game.Players.LocalPlayer.Character

        if not character then
            return false
        end

        if not character.PrimaryPart then
            return false
        end

        local ridePosition = pet:FindFirstChild('RidePosition', true)

        if not ridePosition then
            return false
        end

        local sourceAttachment = Instance.new('Attachment')

        sourceAttachment.Parent = ridePosition
        sourceAttachment.Position = Vector3.new(0, 1.237, 0)
        sourceAttachment.Name = 'SourceAttachment'

        local stateConnection = Instance.new('RigidConstraint')

        stateConnection.Name = 'StateConnection'
        stateConnection.Attachment0 = sourceAttachment
        stateConnection.Attachment1 = character.PrimaryPart.RootAttachment

        stateConnection.Parent = character

        return true
    end

    local function clearPlayerState()
        updateData('state_manager', function(state)
            local clonedState = table.clone(state)
            clonedState.states = {}
            clonedState.is_sitting = false
            return clonedState
        end)
    end

    local function setPlayerState(id)
        updateData('state_manager', function(state)
            local clonedState = table.clone(state)

            clonedState.states = {
                { id = id },
            }

            clonedState.is_sitting = true

            return clonedState
        end)
    end

    local function removePetState(uniqueId)
        local pet = pets[uniqueId]

        if not pet then
            return
        end

        if not pet.model then
            return
        end

        updateData('pet_state_managers', function(petStates)
            local index = findIndex(petStates, function(state)
                return state.char == pet.model
            end)

            if not index then
                return petStates
            end

            table.remove(petStates, index)
            return petStates
        end)
    end

    local function unmount(uniqueId)
        local pet = pets[uniqueId]

        if not pet then
            return
        end

        if not pet.model then
            return
        end

        if currentMountTrack then
            currentMountTrack:Stop()
            currentMountTrack:Destroy()
        end

        local sourceAttachment =
            pet.model:FindFirstChild('SourceAttachment', true)

        if sourceAttachment then
            sourceAttachment:Destroy()
        end

        if game.Players.LocalPlayer.Character then
            for _, descendant in
                pairs(game.Players.LocalPlayer.Character:GetDescendants())
            do
                if
                    descendant:IsA('BasePart')
                    and descendant:GetAttribute('HaveMass')
                then
                    descendant.Massless = false
                end
            end
        end

        clearPetState(uniqueId)
        clearPlayerState()

        pet.model:ScaleTo(1)

        mountedPet = nil
    end

    local function mount(uniqueId, playerState, petState)
        local pet = pets[uniqueId]

        if not pet then
            return
        end

        if not pet.model then
            return
        end

        local player = game.Players.LocalPlayer

        if not player.Character then
            return
        end

        if not player.Character.PrimaryPart then
            return
        end

        mountedPet = uniqueId

        setPetState(uniqueId, petState)
        setPlayerState(playerState)

        pet.model:ScaleTo(2)
        attachPlayerToPet(pet.model)

        currentMountTrack = player.Character.Humanoid.Animator:LoadAnimation(
            animationManager.get_track('PlayerRidingPet')
        )
        player.Character.Humanoid.Sit = true

        for _, descendant in pairs(player.Character:GetDescendants()) do
            if descendant:IsA('BasePart') and descendant.Massless == false then
                descendant.Massless = true
                descendant:SetAttribute('HaveMass', true)
            end
        end

        currentMountTrack:Play()
    end

    local function fly(uniqueId)
        mount(uniqueId, 'PlayerFlyingPet', 'PetBeingFlown')
    end

    local function ride(uniqueId)
        mount(uniqueId, 'PlayerRidingPet', 'PetBeingRidden')
    end

    local function unequip(item)
        local pet = pets[item.unique]

        if not pet then
            return
        end

        if not pet.model then
            return
        end

        unmount(item.unique)

        removePetWrapper(item.unique)
        removePetState(item.unique)

        PetNeonHelper.disable_neon_effects(pet.model)
        
        if megaNeonAnimators[item.unique] then
            megaNeonAnimators[item.unique] = nil
        end

        pet.model:Destroy()
        pet.model = nil

        equippedPet = nil
    end

    local function equip(item, skipFusionCheck)
        if fusionInProgress and not skipFusionCheck then
            print("[FUSION] Skipping equip during fusion process")
            return
        end
        
        if item.category == 'pets' then
            if equippedPet then
                unequip(equippedPet)
            end

            local petModel = getPetModel(item.kind):Clone()
            
            -- Position the pet at its designated non-stacked position
            local spawnPos = pets[item.unique] and pets[item.unique].spawn_position or getNonStackedPosition()
            petModel:PivotTo(CFrame.new(spawnPos))
            
            petModel.Parent = workspace
            pets[item.unique].model = petModel

            if item.properties.neon or item.properties.mega_neon then
                applyNeonEffect(petModel, item.properties.neon, item.properties.mega_neon, item.kind, item.unique, item.id)
            end

            equippedPet = item

            local age = item.properties.age or 6
            local percentage = 0
            if age == 1 then percentage = 0.10
            elseif age == 2 then percentage = 0.30
            elseif age == 3 then percentage = 0.50
            elseif age == 4 then percentage = 0.60
            elseif age == 5 then percentage = 0.80
            else percentage = 1.0
            end

            addPetWrapper({
                char = petModel,
                mega_neon = item.properties.mega_neon or false,
                neon = item.properties.neon or false,
                player = game.Players.LocalPlayer,
                entity_controller = game.Players.LocalPlayer,
                controller = game.Players.LocalPlayer,
                rp_name = item.properties.rp_name or '',
                pet_trick_level = item.properties.pet_trick_level or 1,
                pet_unique = item.unique,
                pet_id = item.id,
                location = {
                    full_destination_id = 'housing',
                    destination_id = 'housing',
                    house_owner = game.Players.LocalPlayer,
                },
                pet_progression = {
                    age = age,
                    percentage = percentage
                },
                are_colors_sealed = false,
                is_pet = true,
            })

            addPetState({
                char = petModel,
                player = game.Players.LocalPlayer,
                store_key = 'pet_state_managers',
                is_sitting = false,
                chars_connected_to_me = {},
                states = {},
            })
        else
            return oldGet('ToolAPI/Equip'):InvokeServer(item.unique)
        end
    end

    local oldGet = router.get

    local function createRemoteFunctionMock(callback)
        return {
            InvokeServer = function(_, ...)
                return callback(...)
            end,
        }
    end

    local function createRemoteEventMock(callback)
        return {
            FireServer = function(_, ...)
                return callback(...)
            end,
        }
    end

    -- Get the original DoNeonFusion remote before we override it
    if router.get('PetAPI/DoNeonFusion') then
        originalDoNeonFusion = router.get('PetAPI/DoNeonFusion')
    end

    -- Function to rename equipped pet
    local function renameEquippedPet(newName)
        if not equippedPet then
            game.StarterGui:SetCore('SendNotification', {
                Title = 'Error',
                Text = 'No pet equipped to rename!',
                Duration = 3,
                Icon = "rbxassetid://4483345998"
            })
            return false
        end
        
        -- Update the pet's RP name in the wrapper
        local petWrapper = nil
        local petWrappers = clientData.get('pet_char_wrappers')
        
        for _, wrapper in pairs(petWrappers) do
            if wrapper.pet_unique == equippedPet.unique then
                petWrapper = wrapper
                break
            end
        end
        
        if petWrapper then
            updateData('pet_char_wrappers', function(wrappers)
                for i, wrapper in pairs(wrappers) do
                    if wrapper.pet_unique == equippedPet.unique then
                        local clonedWrapper = table.clone(wrapper)
                        clonedWrapper.rp_name = newName
                        wrappers[i] = clonedWrapper
                        break
                    end
                end
                return wrappers
            end)
            
            -- Also update the pet data properties
            if pets[equippedPet.unique] then
                pets[equippedPet.unique].data.properties.rp_name = newName
                
                updateData('inventory', function(inventory)
                    if inventory.pets[equippedPet.unique] then
                        inventory.pets[equippedPet.unique].properties.rp_name = newName
                    end
                    return inventory
                end)
            end
            
            game.StarterGui:SetCore('SendNotification', {
                Title = 'Success',
                Text = 'Pet renamed to: ' .. newName,
                Duration = 3,
                Icon = "rbxassetid://4483345998"
            })
            return true
        end
        
        return false
    end

    -- Create a mock for neon fusion that automatically fuses 4 neon pets into mega without popup
    local doNeonFusionRemote = createRemoteFunctionMock(function(petIds, isMega)
        fusionInProgress = true
        pendingAutoEquip = nil
        
        print("[FUSION] Starting fusion process, blocking equips")
        
        task.delay(0.5, function()
            print("[FUSION] Checking pet IDs:", #petIds, "pets")
            print("[FUSION] isMega parameter:", isMega)
            
            local validPetData = {}
            local allExist = true
            local allAreNeon = true
            local allAreSameType = true
            local firstPetId = nil
            local hasFlyRide = false
            local petKind = nil
            
            for _, petId in ipairs(petIds) do
                local pet = pets[petId]
                print("[FUSION] Checking pet ID:", petId, "Exists:", pet ~= nil)
                
                if pet then
                    local isNeon = pet.data.properties.neon or false
                    print("[FUSION] Pet neon status:", isNeon)
                    
                    if not petKind then
                        petKind = pet.data.kind
                    end
                    
                    local hasFly = pet.data.properties.flyable or false
                    local hasRide = pet.data.properties.rideable or false
                    if hasFly or hasRide then
                        hasFlyRide = true
                        print("[FUSION] Pet has fly/ride:", hasFly, hasRide)
                    end
                    
                    if not isNeon then
                        allAreNeon = false
                    end
                    
                    if firstPetId == nil then
                        firstPetId = pet.data.id
                    elseif pet.data.id ~= firstPetId then
                        allAreSameType = false
                    end
                    
                    table.insert(validPetData, {
                        unique = petId,
                        id = pet.data.id,
                        kind = pet.data.kind,
                        properties = pet.data.properties or {}
                    })
                else
                    print("[FUSION] Pet not found in spawned pets")
                    allExist = false
                    break
                end
            end
            
            print("[FUSION] All exist:", allExist)
            print("[FUSION] All are neon:", allAreNeon)
            print("[FUSION] All same type:", allAreSameType)
            print("[FUSION] Has fly/ride:", hasFlyRide)
            print("[FUSION] Pet kind:", petKind)
            print("[FUSION] Valid pet count:", #validPetData)
            
            if allExist and #validPetData == 4 and allAreNeon and allAreSameType then
                print("[FUSION] Attempting automatic mega fusion...")
                
                local basePet = validPetData[1]
                local fusedPetId = basePet.id
                
                local petName = ""
                for name, id in pairs(items) do
                    if type(id) == "table" and id.kind == petKind then
                        petName = name
                        break
                    end
                end
                
                print("[FUSION] Creating mega neon for pet:", petName)
                
                local flags = {
                    neon = false,
                    mega_neon = true,
                    age = 1,
                    rp_name = '',
                    pet_trick_level = 1,
                    rideable = hasFlyRide,
                    flyable = hasFlyRide,
                    is_mega = true,
                    fusion_rank = "mega",
                    pet_name = petName
                }
                
                print("[FUSION] Creating mega pet with flags:", flags)
                
                local fusedPet = createPet(fusedPetId, flags, getNonStackedPosition())
                
                if fusedPet then
                    print("[FUSION] Fused pet created successfully")
                    print("[FUSION] Mega pet properties:", fusedPet.properties)
                    
                    pendingAutoEquip = fusedPet
                    
                    for _, petData in ipairs(validPetData) do
                        if pets[petData.unique] then
                            if pets[petData.unique].model then
                                pets[petData.unique].model:Destroy()
                            end
                            pets[petData.unique] = nil
                            
                            updateData('inventory', function(inventory)
                                if inventory.pets[petData.unique] then
                                    inventory.pets[petData.unique] = nil
                                end
                                return inventory
                            end)
                        end
                    end
                    
                    task.delay(3.5, function()
                        print("[FUSION] Orb animation complete, auto-equipping pet")
                        if pendingAutoEquip then
                            fusionInProgress = false
                            equip(pendingAutoEquip, true)
                            pendingAutoEquip = nil
                        else
                            fusionInProgress = false
                        end
                    end)
                    
                    game.StarterGui:SetCore('SendNotification', {
                        Title = 'Auto-Fusion Complete!',
                        Text = '4 neon ' .. petName .. ' fused into ' .. (hasFlyRide and 'MFR ' or 'Mega ') .. petName .. '!',
                        Duration = 3,
                        Icon = "rbxassetid://4483345998"
                    })
                    
                    return true, {
                        success = true,
                        message = "Mega neon fusion completed automatically"
                    }
                else
                    print("[FUSION] Failed to create fused pet")
                    fusionInProgress = false
                end
            elseif allExist and #validPetData >= 4 then
                print("[FUSION] Attempting regular fusion...")
                
                local basePet = validPetData[1]
                local fusedPetId = basePet.id
                
                local petName = ""
                for name, id in pairs(items) do
                    if type(id) == "table" and id.kind == petKind then
                        petName = name
                        break
                    end
                end
                
                local hasAnyFlyRide = false
                for _, petData in ipairs(validPetData) do
                    if petData.properties.rideable or petData.properties.flyable then
                        hasAnyFlyRide = true
                        break
                    end
                end
                
                local flags = {
                    neon = not isMega,
                    mega_neon = isMega,
                    age = 1,
                    rp_name = '',
                    pet_trick_level = 1,
                    rideable = hasAnyFlyRide,
                    flyable = hasAnyFlyRide,
                    is_mega = isMega,
                    fusion_rank = isMega and "mega" or "neon",
                    pet_name = petName
                }
                
                print("[FUSION] Creating regular fused pet with flags:", flags)
                
                local fusedPet = createPet(fusedPetId, flags, getNonStackedPosition())
                
                if fusedPet then
                    print("[FUSION] Regular fusion successful")
                    print("[FUSION] Fused pet properties:", fusedPet.properties)
                    
                    pendingAutoEquip = fusedPet
                    
                    for _, petData in ipairs(validPetData) do
                        if pets[petData.unique] then
                            if pets[petData.unique].model then
                                pets[petData.unique].model:Destroy()
                            end
                            pets[petData.unique] = nil
                            
                            updateData('inventory', function(inventory)
                                if inventory.pets[petData.unique] then
                                    inventory.pets[petData.unique] = nil
                                end
                                return inventory
                            end)
                        end
                    end
                    
                    task.delay(3.5, function()
                        print("[FUSION] Orb animation complete, auto-equipping pet")
                        if pendingAutoEquip then
                            fusionInProgress = false
                            equip(pendingAutoEquip, true)
                            pendingAutoEquip = nil
                        else
                            fusionInProgress = false
                        end
                    end)
                    
                    game.StarterGui:SetCore('SendNotification', {
                        Title = (isMega and 'Mega' or 'Neon') .. (hasAnyFlyRide and ' FR ' or ' ') .. 'Fusion Successful!',
                        Text = (isMega and 'Mega' or 'Neon') .. (hasAnyFlyRide and ' FR ' or ' ') .. petName .. ' has been created!',
                        Duration = 5,
                        Icon = "rbxassetid://4483345998"
                    })
                    
                    return true, {
                        success = true,
                        message = isMega and "Mega fusion completed" or "Neon fusion completed"
                    }
                end
            end
            
            print("[FUSION] Fusion conditions not met or failed")
            fusionInProgress = false
            
            if originalDoNeonFusion then
                print("[FUSION] Forwarding to original handler...")
                return originalDoNeonFusion:InvokeServer(petIds, isMega)
            end
            
            game.StarterGui:SetCore('SendNotification', {
                Title = 'Fusion Failed',
                Text = 'Unable to fuse pets. Make sure you have 4 of the same neon pet!',
                Duration = 3,
                Icon = "rbxassetid://4483345998"
            })
            
            return false, {
                success = false,
                message = "Fusion failed - check requirements"
            }
        end)
        
        return true, {processing = true}
    end)

    -- Only intercept pet equips (with fusion check)
    local equipRemote = createRemoteFunctionMock(function(uniqueId, metadata)
        if fusionInProgress then
            print("[EQUIP] Blocked during fusion process")
            return false, {error = "Cannot equip during fusion"}
        end
        
        local pet = pets[uniqueId]

        if pet then
            equip(pet.data)
            return true,
                {
                    action = 'equip',
                    is_server = true,
                }
        end

        return oldGet('ToolAPI/Equip'):InvokeServer(uniqueId, metadata)
    end)

    -- Only intercept pet unequips
    local unequipRemote = createRemoteFunctionMock(function(uniqueId)
        local pet = pets[uniqueId]

        if pet then
            unequip(pet.data)
            return true,
                {
                    action = 'unequip',
                    is_server = true,
                }
        end

        return oldGet('ToolAPI/Unequip'):InvokeServer(uniqueId)
    end)

    -- Pet-specific remotes remain unchanged
    local rideRemote = createRemoteFunctionMock(function(item)
        ride(item.pet_unique)
    end)

    local flyRemote = createRemoteFunctionMock(function(item)
        fly(item.pet_unique)
    end)

    local unmountRemoteFunction = createRemoteFunctionMock(function()
        unmount(mountedPet)
    end)

    local unmountRemoteEvent = createRemoteEventMock(function()
        unmount(mountedPet)
    end)

    -- Override the router's get function to intercept fusion calls
    local originalRouterGet = router.get
    router.get = function(name)
        if name == 'ToolAPI/Equip' then
            return equipRemote
        elseif name == 'ToolAPI/Unequip' then
            return unequipRemote
        elseif name == 'AdoptAPI/RidePet' then
            return rideRemote
        elseif name == 'AdoptAPI/FlyPet' then
            return flyRemote
        elseif name == 'AdoptAPI/ExitSeatStatesYield' then
            return unmountRemoteFunction
        elseif name == 'AdoptAPI/ExitSeatStates' then
            return unmountRemoteEvent
        elseif name == 'PetAPI/DoNeonFusion' then
            print("[ROUTER] Intercepting PetAPI/DoNeonFusion")
            return doNeonFusionRemote
        end

        return originalRouterGet(name)
    end

    -- Only unequip pets on startup
    for _, charWrapper in pairs(clientData.get('pet_char_wrappers')) do
        oldGet('ToolAPI/Unequip'):InvokeServer(charWrapper.pet_unique)
    end

    local Loads = require(game.ReplicatedStorage.Fsys).load
    local InventoryDB = Loads('InventoryDB')

    function GetPetByName(name)
        for i, v in pairs(InventoryDB.pets) do
            if v.name:lower() == name:lower() then
                return v.id
            end
        end
        return false
    end

    function GetToyByName(name)
        for i, v in pairs(InventoryDB.toys) do
            if v.name:lower() == name:lower() then
                return v.id
            end
        end
        return false
    end

    -- PET WEAR FUNCTIONS (NEW)
    local function GetPetWearByName(name)
        for id, v in pairs(InventoryDB.pet_accessories or {}) do
            if v.name and v.name:lower() == name:lower() then return id end
        end
        return false
    end

    local function equipWearOnPet(wearId)
        local IDB2 = require(game.ReplicatedStorage.Fsys).load('InventoryDB')
        local PetAccessoryEquipHelper = require(game.ReplicatedStorage.Fsys).load('PetAccessoryEquipHelper')
        local dl = require(game.ReplicatedStorage.Fsys).load('DownloadClient')

        local wearEntry = IDB2.pet_accessories and IDB2.pet_accessories[wearId]
        if not wearEntry then
            warn('[PetWear] No entry in InventoryDB.pet_accessories for: ' .. tostring(wearId))
            game.StarterGui:SetCore('SendNotification', {Title='Not Found', Text='Wear entry missing from DB.', Duration=4})
            return false
        end

        local wrappers = clientData.get('pet_char_wrappers')
        if not wrappers or #wrappers == 0 then
            game.StarterGui:SetCore('SendNotification', {Title='No Pet Equipped', Text='Equip a pet first!', Duration=4})
            return false
        end

        local petModel = wrappers[#wrappers].char
        if not petModel or not petModel:IsDescendantOf(workspace) then
            game.StarterGui:SetCore('SendNotification', {Title='Pet Not Found', Text='Could not find pet model in workspace.', Duration=4})
            return false
        end

        task.spawn(function()
            local ok, accessoryAsset = pcall(function()
                return dl.promise_download_copy('PetAvatarResources', wearEntry.model_handle):expect()
            end)
            if not ok or not accessoryAsset then
                warn('[PetWear] Failed to download asset for: ' .. tostring(wearEntry.model_handle))
                game.StarterGui:SetCore('SendNotification', {Title='Download Failed', Text='Could not load accessory model.', Duration=4})
                return
            end
            local success, result = pcall(function()
                return PetAccessoryEquipHelper.equip_accessory({
                    pet_model            = petModel,
                    accessory_base_asset = accessoryAsset,
                    accessory_item_entry = wearEntry,
                    play_poof_effect     = true,
                    is_mannequin         = false,
                })
            end)
            if success and result then
                game.StarterGui:SetCore('SendNotification', {Title='🪽 Equipped!', Text=(wearEntry.name or wearId)..' equipped on your pet.', Duration=4})
            else
                warn('[PetWear] equip_accessory failed: ' .. tostring(result))
                game.StarterGui:SetCore('SendNotification', {Title='Equip Failed', Text='Check console for error.', Duration=4})
            end
        end)
        return true
    end

    -- UI Setup
    local screenGui = Instance.new('ScreenGui')
    screenGui.Name = 'SkaiAdmSpawner'
    screenGui.Parent = LocalPlayer:WaitForChild('PlayerGui')

    -- Main frame (with colored stroke)
    local mainFrame = Instance.new('Frame')
    mainFrame.Size = UDim2.new(0, 340, 0, 520) -- Increased height to accommodate pet wear buttons
    mainFrame.Position = UDim2.new(0.5, -170, 0.4, -210)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BackgroundTransparency = 1
    mainFrame.BorderSizePixel = 0
    mainFrame.ZIndex = 1
    mainFrame.Parent = screenGui

    -- Rounded corners for main frame
    local uiCorner = Instance.new('UICorner')
    uiCorner.CornerRadius = UDim.new(0, 10)
    uiCorner.Parent = mainFrame

    -- Colored animated stroke (inner border)
    local uiStroke = Instance.new('UIStroke')
    uiStroke.Color = Color3.fromRGB(170, 0, 255)
    uiStroke.Thickness = 3
    uiStroke.Transparency = 0
    uiStroke.Parent = mainFrame

    -- Black background frame (fake outer stroke)
    local blackFrame = Instance.new('Frame')
    blackFrame.Size = UDim2.new(0, 350, 0, 530)
    blackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    blackFrame.BackgroundTransparency = 0
    blackFrame.BorderSizePixel = 0
    blackFrame.ZIndex = 0
    blackFrame.Parent = screenGui

    -- Rounded corners for black frame
    local blackCorner = Instance.new('UICorner')
    blackCorner.CornerRadius = UDim.new(0, 15.5)
    blackCorner.Parent = blackFrame

    -- Make blackFrame follow mainFrame's position dynamically
    mainFrame:GetPropertyChangedSignal('Position'):Connect(function()
        blackFrame.Position = UDim2.new(
            mainFrame.Position.X.Scale,
            mainFrame.Position.X.Offset - 5,
            mainFrame.Position.Y.Scale,
            mainFrame.Position.Y.Offset - 5
        )
    end)

    -- Initialize position
    blackFrame.Position = UDim2.new(
        mainFrame.Position.X.Scale,
        mainFrame.Position.X.Offset - 5,
        mainFrame.Position.Y.Scale,
        mainFrame.Position.Y.Offset - 5
    )

    -- Adjusted color palette
    local colorPalette = {
        Color3.fromRGB(170, 0, 255),
        Color3.fromRGB(120, 0, 255),
        Color3.fromRGB(0, 100, 255),
        Color3.fromRGB(0, 200, 255),
        Color3.fromRGB(0, 255, 150),
        Color3.fromRGB(0, 255, 100),
        Color3.fromRGB(255, 100, 0),
        Color3.fromRGB(255, 50, 150),
    }

    -- Animation parameters
    local TRANSITION_TIME = 4
    local currentIndex = 1

    -- Smooth color transition function
    local function animateToNextColor()
        local nextIndex = currentIndex % #colorPalette + 1

        TweenService:Create(
            uiStroke,
            TweenInfo.new(
                TRANSITION_TIME,
                Enum.EasingStyle.Linear,
                Enum.EasingDirection.Out
            ),
            {
                Color = colorPalette[nextIndex],
            }
        ):Play()

        currentIndex = nextIndex
        wait(TRANSITION_TIME)
        animateToNextColor()
    end

    -- Start the animation
    coroutine.wrap(animateToNextColor)()

    local titleLabel = Instance.new('TextLabel')
    titleLabel.Size = UDim2.new(1, 0, 0, 25)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = 'gremories_scripts & solrscriptz'
    titleLabel.Font = Enum.Font.FredokaOne
    titleLabel.TextSize = 16
    titleLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
    titleLabel.Parent = mainFrame

    -- Tab buttons
    local tabFrame = Instance.new('Frame')
    tabFrame.Size = UDim2.new(1, 0, 0, 30)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Parent = mainFrame

    local petTab = Instance.new('TextButton')
    petTab.Size = UDim2.new(0.5, 0, 1, 0)
    petTab.Position = UDim2.new(0, 0, 0, 0)
    petTab.Text = 'Pets'
    petTab.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    petTab.BackgroundTransparency = 0.1
    petTab.Font = Enum.Font.FredokaOne
    petTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    petTab.TextSize = 16
    petTab.Parent = tabFrame

    local toyTab = Instance.new('TextButton')
    toyTab.Size = UDim2.new(0.5, 0, 1, 0)
    toyTab.Position = UDim2.new(0.5, 0, 0, 0)
    toyTab.Text = 'Toys'
    toyTab.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    toyTab.BackgroundTransparency = 0.1
    toyTab.Font = Enum.Font.FredokaOne
    toyTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    toyTab.TextSize = 16
    toyTab.Parent = tabFrame

    -- Tab corner
    local tabCorner = Instance.new('UICorner')
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = petTab
    tabCorner:Clone().Parent = toyTab

    -- Tab stroke
    local tabStroke = Instance.new('UIStroke')
    tabStroke.Color = Color3.fromRGB(255, 255, 255)
    tabStroke.Thickness = 1.5
    tabStroke.Transparency = 0.1
    tabStroke.Parent = petTab
    tabStroke:Clone().Parent = toyTab

    -- Tab text stroke
    local tabTextStroke = Instance.new('UIStroke')
    tabTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    tabTextStroke.Color = Color3.new(0, 0, 0)
    tabTextStroke.Thickness = 1.5
    tabTextStroke.Transparency = 0
    tabTextStroke.Parent = petTab
    tabTextStroke:Clone().Parent = toyTab

    -- Content frames
    local petContent = Instance.new('Frame')
    petContent.Size = UDim2.new(1, 0, 1, -55)
    petContent.Position = UDim2.new(0, 0, 0, 55)
    petContent.BackgroundTransparency = 1
    petContent.Visible = true
    petContent.Parent = mainFrame

    local toyContent = Instance.new('Frame')
    toyContent.Size = UDim2.new(1, 0, 1, -55)
    toyContent.Position = UDim2.new(0, 0, 0, 55)
    toyContent.BackgroundTransparency = 1
    toyContent.Visible = false
    toyContent.Parent = mainFrame

    -- Tab switching
    petTab.MouseButton1Click:Connect(function()
        petContent.Visible = true
        toyContent.Visible = false
        petTab.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
        toyTab.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    end)

    toyTab.MouseButton1Click:Connect(function()
        petContent.Visible = false
        toyContent.Visible = true
        petTab.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        toyTab.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    end)

    -- Initialize tabs
    petTab.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    toyTab.BackgroundColor3 = Color3.fromRGB(60, 60, 80)

    -- PET CONTENT
    -- TextBox to input pet name
    local petNameBox = Instance.new('TextBox')
    petNameBox.Size = UDim2.new(0.85, 0, 0, 28)
    petNameBox.Position = UDim2.new(0.075, 0, 0.05, 0)
    petNameBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    petNameBox.BackgroundTransparency = 0.2
    petNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    petNameBox.TextSize = 14
    petNameBox.Font = Enum.Font.FredokaOne
    petNameBox.PlaceholderText = 'Enter Pet Name to Spawn'
    petNameBox.Text = ''
    petNameBox.ClearTextOnFocus = false
    petNameBox.Parent = petContent

    -- Rounded corners
    local boxCorner = Instance.new('UICorner')
    boxCorner.CornerRadius = UDim.new(0, 6)
    boxCorner.Parent = petNameBox

    -- Black text outline
    local textStroke = Instance.new('UIStroke')
    textStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    textStroke.Color = Color3.new(0, 0, 0)
    textStroke.Thickness = 1.2
    textStroke.Transparency = 0
    textStroke.Parent = petNameBox

    -- Glowing outline
    local boxGlow = Instance.new('UIStroke')
    boxGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    boxGlow.Color = Color3.fromRGB(255, 255, 255)
    boxGlow.Thickness = 2.2
    boxGlow.Transparency = 0.25
    boxGlow.Parent = petNameBox

    -- Store the valid pet names list
    local validPetNames = {}
    local validPetNamesClean = {}

    local function loadPetNames()
        local inventory_db =
            require(game.ReplicatedStorage.Fsys).load('InventoryDB')
        for category_name, category_table in pairs(inventory_db) do
            if category_name == 'pets' then
                for id, item in pairs(category_table) do
                    validPetNames[#validPetNames + 1] = item.name
                    validPetNamesClean[#validPetNamesClean + 1] =
                        item.name:lower():gsub('%s+', '')
                end
                break
            end
        end
    end

    loadPetNames()

    -- Color palette
    local COLORS = {
        NEUTRAL = Color3.fromRGB(220, 220, 255),
        VALID = Color3.fromRGB(120, 255, 150),
        INVALID = Color3.fromRGB(255, 120, 120),
    }

    -- Current color tween reference
    local currentColorTween = nil

    -- Function to capitalize each word
    local function capitalizeWords(str)
        local result = ''
        local i = 1
        local n = #str

        while i <= n do
            if str:sub(i, i):match('%S') then
                local wordStart = i
                while i <= n and str:sub(i, i):match('%S') do
                    i = i + 1
                end
                local word = str:sub(wordStart, i - 1)
                if #word > 0 then
                    word = word:sub(1, 1):upper() .. word:sub(2):lower()
                end
                result = result .. word
            else
                result = result .. str:sub(i, i)
                i = i + 1
            end
        end

        return result
    end

    -- Store cursor position
    local lastCursorPosition = 1

    -- Smooth color transition function
    local function setGlowColor(targetColor)
        if currentColorTween then
            currentColorTween:Cancel()
        end

        currentColorTween = TweenService:Create(
            boxGlow,
            TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Color = targetColor }
        )
        currentColorTween:Play()
    end

    petNameBox:GetPropertyChangedSignal('Text'):Connect(function()
        lastCursorPosition = petNameBox.CursorPosition
        local inputText = petNameBox.Text

        local newText = capitalizeWords(inputText)
        if newText ~= inputText then
            petNameBox.Text = newText
            local addedChars = #newText - #inputText
            petNameBox.CursorPosition = math.max(
                1,
                math.min(lastCursorPosition + addedChars, #newText + 1)
            )
            return
        end

        local displayedText = petNameBox.Text
        local cleanName = displayedText:lower():gsub('%s+', '')

        local isExactMatch = false
        local isCleanMatch = false

        for _, name in ipairs(validPetNames) do
            if name:lower() == displayedText:lower() then
                isExactMatch = true
                break
            end
        end

        isCleanMatch = table.find(validToyNamesClean, cleanName) ~= nil

        local targetColor
        if displayedText == '' then
            targetColor = COLORS.NEUTRAL
        elseif isExactMatch then
            targetColor = COLORS.VALID
        elseif isCleanMatch then
            targetColor = COLORS.VALID
        else
            targetColor = COLORS.INVALID
        end

        setGlowColor(targetColor)
    end)

    -- Initialize with neutral color
    setGlowColor(COLORS.NEUTRAL)

    -- PET PROPERTIES SECTION
    local propertiesLabel = Instance.new('TextLabel')
    propertiesLabel.Size = UDim2.new(0.85, 0, 0, 20)
    propertiesLabel.Position = UDim2.new(0.075, 0, 0.12, 0) -- Adjusted position
    propertiesLabel.BackgroundTransparency = 1
    propertiesLabel.Text = 'Pet Properties'
    propertiesLabel.Font = Enum.Font.FredokaOne
    propertiesLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
    propertiesLabel.TextSize = 16
    propertiesLabel.Parent = petContent

    -- Property toggle buttons (MFR, NFR, FR)
    local propertyToggles = {
        MFR = false,
        NFR = false,
        FR = false
    }

    local propertyButtons = {}

    local propertyColors = {
        MFR = Color3.fromRGB(255, 0, 255),
        NFR = Color3.fromRGB(57, 255, 20),
        FR = Color3.fromRGB(255, 150, 50)
    }

    -- Age toggle buttons
    local ageToggles = {
        Newborn = false,
        Junior = false,
        PreTeen = false,
        Teen = false,
        PostTeen = false,
        FullGrown = false,
        Luminous = false
    }

    local ageButtons = {}

    local ageColors = {
        Newborn = Color3.fromRGB(255, 100, 100),
        Junior = Color3.fromRGB(255, 150, 100),
        PreTeen = Color3.fromRGB(255, 200, 100),
        Teen = Color3.fromRGB(200, 255, 100),
        PostTeen = Color3.fromRGB(150, 255, 150),
        FullGrown = Color3.fromRGB(100, 255, 200),
        Luminous = Color3.fromRGB(100, 200, 255)
    }

    -- Age values for each stage
    local ageValues = {
        Newborn = 1,
        Junior = 2,
        PreTeen = 3,
        Teen = 4,
        PostTeen = 5,
        FullGrown = 6,
        Luminous = 6
    }

    -- Create property toggle buttons with better spacing
    local propertyNames = {'MFR', 'NFR', 'FR'}
    for i, property in ipairs(propertyNames) do
        local button = Instance.new('TextButton')
        button.Size = UDim2.new(0.25, 0, 0, 25)
        button.Position = UDim2.new(0.075 + (i-1)*0.31, 0, 0.17, 0) -- Adjusted position
        button.Text = property
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        button.BackgroundTransparency = 0.2
        button.Font = Enum.Font.FredokaOne
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 14
        button.Parent = petContent
        propertyButtons[property] = button

        local buttonCorner = Instance.new('UICorner')
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = button

        local buttonStroke = Instance.new('UIStroke')
        buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        buttonStroke.Color = propertyColors[property]
        buttonStroke.Thickness = 2
        buttonStroke.Transparency = 0.5
        buttonStroke.Parent = button

        local textStroke = Instance.new('UIStroke')
        textStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
        textStroke.Color = Color3.new(0, 0, 0)
        textStroke.Thickness = 1.2
        textStroke.Transparency = 0
        textStroke.Parent = button

        button.MouseButton1Click:Connect(function()
            if propertyToggles[property] then
                propertyToggles[property] = false
                button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                TweenService:Create(buttonStroke, TweenInfo.new(0.3), {
                    Color = propertyColors[property],
                    Thickness = 2,
                    Transparency = 0.5
                }):Play()
            else
                for prop, propButton in pairs(propertyButtons) do
                    if prop ~= property then
                        propertyToggles[prop] = false
                        propButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                        TweenService:Create(propButton.UIStroke, TweenInfo.new(0.3), {
                            Color = propertyColors[prop],
                            Thickness = 2,
                            Transparency = 0.5
                        }):Play()
                    end
                end
                
                propertyToggles[property] = true
                button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                TweenService:Create(buttonStroke, TweenInfo.new(0.3), {
                    Color = Color3.fromRGB(0, 255, 0),
                    Thickness = 3,
                    Transparency = 0.2
                }):Play()
            end
        end)

        button.MouseEnter:Connect(function()
            if not propertyToggles[property] then
                button.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
                TweenService:Create(buttonStroke, TweenInfo.new(0.2), {
                    Thickness = 2.5,
                    Transparency = 0.3
                }):Play()
            end
        end)

        button.MouseLeave:Connect(function()
            if not propertyToggles[property] then
                button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                TweenService:Create(buttonStroke, TweenInfo.new(0.2), {
                    Thickness = 2,
                    Transparency = 0.5
                }):Play()
            end
        end)
    end

    -- Age selection section with MORE SPACING
    local ageLabel = Instance.new('TextLabel')
    ageLabel.Size = UDim2.new(0.85, 0, 0, 20)
    ageLabel.Position = UDim2.new(0.075, 0, 0.23, 0) -- Adjusted position
    ageLabel.BackgroundTransparency = 1
    ageLabel.Text = 'Pet Age (For Non-Mega)'
    ageLabel.Font = Enum.Font.FredokaOne
    ageLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
    ageLabel.TextSize = 14
    ageLabel.Parent = petContent

    -- Create age toggle buttons in two rows with SIGNIFICANTLY MORE SPACING
    local ageNames = {'Newborn', 'Junior', 'PreTeen', 'Teen', 'PostTeen', 'FullGrown', 'Luminous'}
    for i, age in ipairs(ageNames) do
        local row = i <= 4 and 0 or 1
        local col = i <= 4 and (i-1) or (i-5)
        
        local button = Instance.new('TextButton')
        button.Size = UDim2.new(0.19, 0, 0, 20) -- Slightly smaller to allow more spacing
        button.Position = UDim2.new(0.075 + col*0.24, 0, 0.27 + row*0.07, 0) -- Adjusted position
        button.Text = age
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        button.BackgroundTransparency = 0.2
        button.Font = Enum.Font.FredokaOne
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 10 -- Smaller text to fit
        button.Parent = petContent
        ageButtons[age] = button

        local buttonCorner = Instance.new('UICorner')
        buttonCorner.CornerRadius = UDim.new(0, 4)
        buttonCorner.Parent = button

        local buttonStroke = Instance.new('UIStroke')
        buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        buttonStroke.Color = ageColors[age]
        buttonStroke.Thickness = 1.5
        buttonStroke.Transparency = 0.5
        buttonStroke.Parent = button

        local textStroke = Instance.new('UIStroke')
        textStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
        textStroke.Color = Color3.new(0, 0, 0)
        textStroke.Thickness = 1
        textStroke.Transparency = 0
        textStroke.Parent = button

        button.MouseButton1Click:Connect(function()
            if ageToggles[age] then
                ageToggles[age] = false
                button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                TweenService:Create(buttonStroke, TweenInfo.new(0.3), {
                    Color = ageColors[age],
                    Thickness = 1.5,
                    Transparency = 0.5
                }):Play()
            else
                for ageName, ageButton in pairs(ageButtons) do
                    if ageName ~= age then
                        ageToggles[ageName] = false
                        ageButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                        TweenService:Create(ageButton.UIStroke, TweenInfo.new(0.3), {
                            Color = ageColors[ageName],
                            Thickness = 1.5,
                            Transparency = 0.5
                        }):Play()
                    end
                end
                
                ageToggles[age] = true
                button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                TweenService:Create(buttonStroke, TweenInfo.new(0.3), {
                    Color = Color3.fromRGB(0, 255, 0),
                    Thickness = 2,
                    Transparency = 0.2
                }):Play()
            end
        end)

        button.MouseEnter:Connect(function()
            if not ageToggles[age] then
                button.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
                TweenService:Create(buttonStroke, TweenInfo.new(0.2), {
                    Thickness = 2,
                    Transparency = 0.3
                }):Play()
            end
        end)

        button.MouseLeave:Connect(function()
            if not ageToggles[age] then
                button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                TweenService:Create(buttonStroke, TweenInfo.new(0.2), {
                    Thickness = 1.5,
                    Transparency = 0.5
                }):Play()
            end
        end)
    end

    -- Default to FullGrown age
    ageToggles.FullGrown = true
    ageButtons.FullGrown.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    TweenService:Create(ageButtons.FullGrown.UIStroke, TweenInfo.new(0.3), {
        Color = Color3.fromRGB(0, 255, 0),
        Thickness = 2,
        Transparency = 0.2
    }):Play()

    -- Function to get selected age
    local function getSelectedAge()
        for age, isSelected in pairs(ageToggles) do
            if isSelected then
                return ageValues[age]
            end
        end
        return 6
    end

    -- Function to check if pet is an egg
    local function isEggPet(petName)
        return petName:lower():find("egg") ~= nil
    end

    -- Function to get property flags based on toggle states
    local function getPropertyFlags(petName)
        local isEgg = isEggPet(petName)
        local isMegaNeon = propertyToggles.MFR and not isEgg
        local isNeon = (propertyToggles.NFR or propertyToggles.MFR) and not isEgg
        local isFR = (propertyToggles.MFR or propertyToggles.NFR or propertyToggles.FR) and not isEgg
        
        local age = isMegaNeon and 1 or getSelectedAge()
        
        if age == 6 then
            for ageName, isSelected in pairs(ageToggles) do
                if isSelected and ageName == "Luminous" then
                    isNeon = true
                    isMegaNeon = false
                    break
                end
            end
        end
        
        return {
            mega_neon = isMegaNeon,
            neon = isNeon and not isMegaNeon,
            rideable = isFR,
            flyable = isFR,
            age = age,
            fusion_ready = true,
            is_fusable = true,
            neon_ready = isNeon or isMegaNeon
        }
    end

    -- High Tier Pets List
    local highTierPets = {
        'Shadow Dragon',
        'Giant Panda',
        'Cryptid',
        'Bat Dragon',
        'Frost Dragon',
        'Giraffe',
        'Owl',
        'Parrot',
        'Crow',
        'Evil Unicorn',
        'Arctic Reindeer',
        'Hedgehog',
        'Dalmatian',
        'Turtle',
        'Kangaroo',
        'Lion',
        'Elephant',
        'Rhino',
        'Chocolate Chip Bat Dragon',
        'Cow',
        'Blazing Lion',
        'African Wild Dog',
        'Flamingo',
        'Diamond Butterfly',
        'Mini Pig',
        'Caterpillar',
        'Albino Monkey',
        'Candyfloss Chick',
        'Pelican',
        'Blue Dog',
        'Pink Cat',
        'Haetae',
        'Peppermint Penguin',
        'Winged Tiger',
        'Sugar Glider',
        'Shark Puppy',
        'Goat',
        'Sheeeeep',
        'Lion Cub',
        'Nessie',
        'Flamingo',
        'Frostbite Bear',
        'Balloon Unicorn',
        'Honey Badger',
        'Hot Doggo',
        'Crocodile',
        'Hare',
        'Ram',
        'Yeti',
        'Meetkat',
        'Jellyfish',
        'Happy Clown',
        'Orchid Butterfly',
        'Many Mackerel',
        'Strawberry Shortcake Bat Dragon',
        'Zombie Buffalo',
        'Fairy Bat Dragon',
    }

    -- High Tier Spawn Button
    local highTierButton = Instance.new('TextButton')
    highTierButton.Size = UDim2.new(0.6, 0, 0, 25)
    highTierButton.Position = UDim2.new(0.2, 0, 0.39, 0) -- Adjusted position
    highTierButton.Text = 'Spawn High Tier'
    highTierButton.BackgroundColor3 = Color3.fromRGB(200, 0, 200)
    highTierButton.BackgroundTransparency = 0.1
    highTierButton.Font = Enum.Font.FredokaOne
    highTierButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    highTierButton.TextSize = 16
    highTierButton.Parent = petContent

    local highTierCorner = Instance.new('UICorner')
    highTierCorner.CornerRadius = UDim.new(0, 8)
    highTierCorner.Parent = highTierButton

    local highTierStroke = Instance.new('UIStroke')
    highTierStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    highTierStroke.Color = Color3.fromRGB(255, 255, 255)
    highTierStroke.Thickness = 1.5
    highTierStroke.Transparency = 0.1
    highTierStroke.Parent = highTierButton

    local highTierTextStroke = Instance.new('UIStroke')
    highTierTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    highTierTextStroke.Color = Color3.new(0, 0, 0)
    highTierTextStroke.Thickness = 1.5
    highTierTextStroke.Transparency = 0
    highTierTextStroke.Parent = highTierButton

    local highTierOriginalProperties = {
        BackgroundColor3 = highTierButton.BackgroundColor3,
        BackgroundTransparency = highTierButton.BackgroundTransparency,
        StrokeColor = Color3.fromRGB(255, 255, 255),
        StrokeThickness = 1.5,
        StrokeTransparency = 0.1,
    }

    local highTierActiveAnimation = {
        endTime = 0,
        strokeTween = nil,
        resetThread = nil,
        intensity = 1.0,
    }

    highTierButton.MouseEnter:Connect(function()
        if highTierActiveAnimation.endTime < os.clock() then
            highTierButton.BackgroundColor3 = Color3.fromRGB(220, 0, 220)
            TweenService:Create(highTierStroke, TweenInfo.new(0.2), {
                Thickness = 2,
                Transparency = 0.05,
            }):Play()
        end
    end)

    highTierButton.MouseLeave:Connect(function()
        if highTierActiveAnimation.endTime < os.clock() then
            highTierButton.BackgroundColor3 =
                highTierOriginalProperties.BackgroundColor3
            TweenService
                :Create(highTierStroke, TweenInfo.new(0.2), {
                    Thickness = highTierOriginalProperties.StrokeThickness,
                    Transparency = highTierOriginalProperties.StrokeTransparency,
                })
                :Play()
        end
    end)

    highTierButton.MouseButton1Click:Connect(function()
        local currentTime = os.clock()
        local extendDuration = 1.5

        local isExtension = currentTime < highTierActiveAnimation.endTime

        if isExtension then
            highTierActiveAnimation.intensity =
                math.min(highTierActiveAnimation.intensity + 0.3, 1.5)
            extendDuration = 1.5
        else
            highTierActiveAnimation.intensity = 1.0
        end

        if highTierActiveAnimation.strokeTween then
            highTierActiveAnimation.strokeTween:Cancel()
        end
        if highTierActiveAnimation.resetThread then
            coroutine.close(highTierActiveAnimation.resetThread)
        end

        local feedbackColor = Color3.fromRGB(255, 50, 50)
        local spawnSuccess = false

        for _, petName in ipairs(highTierPets) do
            local petId = GetPetByName(petName)
            if petId then
                local flags = getPropertyFlags(petName)
                
                createPet(petId, {
                    pet_trick_level = math.random(1, 5),
                    mega_neon = flags.mega_neon,
                    neon = flags.neon,
                    rideable = flags.rideable,
                    flyable = flags.flyable,
                    age = flags.age,
                    rp_name = '',
                })
                spawnSuccess = true
            end
        end

        if spawnSuccess then
            feedbackColor =
                Color3.fromRGB(0, 255 * highTierActiveAnimation.intensity, 0)
            game.StarterGui:SetCore('SendNotification', {
                Title = 'High Tier Pets Spawned!',
                Text = 'All high tier pets have been spawned!',
                Duration = 5,
            })
        else
            game.StarterGui:SetCore('SendNotification', {
                Title = 'Error',
                Text = 'Failed to spawn high tier pets!',
                Duration = 3,
            })
        end

        highTierStroke.Color = feedbackColor
        highTierStroke.Thickness = 2 * highTierActiveAnimation.intensity
        highTierStroke.Transparency = 0.1 / highTierActiveAnimation.intensity

        if isExtension then
            highTierActiveAnimation.strokeTween = TweenService:Create(
                highTierStroke,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                {
                    Thickness = 2.5 * highTierActiveAnimation.intensity,
                    Transparency = 0.05 / highTierActiveAnimation.intensity,
                }
            )
            highTierActiveAnimation.strokeTween:Play()
        end

        highTierActiveAnimation.endTime = currentTime + extendDuration

        highTierActiveAnimation.resetThread = task.delay(
            extendDuration,
            function()
                if os.clock() >= highTierActiveAnimation.endTime then
                    TweenService
                        :Create(
                            highTierStroke,
                            TweenInfo.new(0.5, Enum.EasingStyle.Quad),
                            {
                                Color = highTierOriginalProperties.StrokeColor,
                                Thickness = highTierOriginalProperties.StrokeThickness,
                                Transparency = highTierOriginalProperties.StrokeTransparency,
                            }
                        )
                        :Play()
                end
            end
        )
    end)

    -- 10x High Tier Spawn Button
    local highTier10xButton = Instance.new('TextButton')
    highTier10xButton.Size = UDim2.new(0.6, 0, 0, 25)
    highTier10xButton.Position = UDim2.new(0.2, 0, 0.45, 0) -- Adjusted position
    highTier10xButton.Text = 'Spawn 10x High Tier'
    highTier10xButton.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    highTier10xButton.BackgroundTransparency = 0.1
    highTier10xButton.Font = Enum.Font.FredokaOne
    highTier10xButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    highTier10xButton.TextSize = 14
    highTier10xButton.Parent = petContent

    local highTier10xCorner = Instance.new('UICorner')
    highTier10xCorner.CornerRadius = UDim.new(0, 8)
    highTier10xCorner.Parent = highTier10xButton

    local highTier10xStroke = Instance.new('UIStroke')
    highTier10xStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    highTier10xStroke.Color = Color3.fromRGB(255, 255, 255)
    highTier10xStroke.Thickness = 1.5
    highTier10xStroke.Transparency = 0.1
    highTier10xStroke.Parent = highTier10xButton

    local highTier10xTextStroke = Instance.new('UIStroke')
    highTier10xTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    highTier10xTextStroke.Color = Color3.new(0, 0, 0)
    highTier10xTextStroke.Thickness = 1.5
    highTier10xTextStroke.Transparency = 0
    highTier10xTextStroke.Parent = highTier10xButton

    local highTier10xOriginalProperties = {
        BackgroundColor3 = highTier10xButton.BackgroundColor3,
        BackgroundTransparency = highTier10xButton.BackgroundTransparency,
        StrokeColor = Color3.fromRGB(255, 255, 255),
        StrokeThickness = 1.5,
        StrokeTransparency = 0.1,
    }

    local highTier10xActiveAnimation = {
        endTime = 0,
        strokeTween = nil,
        resetThread = nil,
        intensity = 1.0,
    }

    highTier10xButton.MouseEnter:Connect(function()
        if highTier10xActiveAnimation.endTime < os.clock() then
            highTier10xButton.BackgroundColor3 = Color3.fromRGB(255, 130, 30)
            TweenService:Create(highTier10xStroke, TweenInfo.new(0.2), {
                Thickness = 2,
                Transparency = 0.05,
            }):Play()
        end
    end)

    highTier10xButton.MouseLeave:Connect(function()
        if highTier10xActiveAnimation.endTime < os.clock() then
            highTier10xButton.BackgroundColor3 =
                highTier10xOriginalProperties.BackgroundColor3
            TweenService
                :Create(highTier10xStroke, TweenInfo.new(0.2), {
                    Thickness = highTier10xOriginalProperties.StrokeThickness,
                    Transparency = highTier10xOriginalProperties.StrokeTransparency,
                })
                :Play()
        end
    end)

    highTier10xButton.MouseButton1Click:Connect(function()
        local currentTime = os.clock()
        local extendDuration = 2.0

        local isExtension = currentTime < highTier10xActiveAnimation.endTime

        if isExtension then
            highTier10xActiveAnimation.intensity =
                math.min(highTier10xActiveAnimation.intensity + 0.3, 1.5)
            extendDuration = 2.0
        else
            highTier10xActiveAnimation.intensity = 1.0
        end

        if highTier10xActiveAnimation.strokeTween then
            highTier10xActiveAnimation.strokeTween:Cancel()
        end
        if highTier10xActiveAnimation.resetThread then
            coroutine.close(highTier10xActiveAnimation.resetThread)
        end

        local feedbackColor = Color3.fromRGB(255, 50, 50)
        local spawnSuccess = false
        local spawnCount = 0

        -- Spawn each high tier pet 10 times
        for i = 1, 10 do
            for _, petName in ipairs(highTierPets) do
                local petId = GetPetByName(petName)
                if petId then
                    local flags = getPropertyFlags(petName)
                    
                    createPet(petId, {
                        pet_trick_level = math.random(1, 5),
                        mega_neon = flags.mega_neon,
                        neon = flags.neon,
                        rideable = flags.rideable,
                        flyable = flags.flyable,
                        age = flags.age,
                        rp_name = '',
                    })
                    spawnSuccess = true
                    spawnCount = spawnCount + 1
                    
                    -- Small delay to prevent lag
                    if spawnCount % 5 == 0 then
                        task.wait(0.05)
                    end
                end
            end
        end

        if spawnSuccess then
            feedbackColor =
                Color3.fromRGB(0, 255 * highTier10xActiveAnimation.intensity, 0)
            game.StarterGui:SetCore('SendNotification', {
                Title = '10x High Tier Pets Spawned!',
                Text = 'All high tier pets have been spawned 10 times!',
                Duration = 5,
            })
        else
            game.StarterGui:SetCore('SendNotification', {
                Title = 'Error',
                Text = 'Failed to spawn high tier pets!',
                Duration = 3,
            })
        end

        highTier10xStroke.Color = feedbackColor
        highTier10xStroke.Thickness = 2 * highTier10xActiveAnimation.intensity
        highTier10xStroke.Transparency = 0.1 / highTier10xActiveAnimation.intensity

        if isExtension then
            highTier10xActiveAnimation.strokeTween = TweenService:Create(
                highTier10xStroke,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                {
                    Thickness = 2.5 * highTier10xActiveAnimation.intensity,
                    Transparency = 0.05 / highTier10xActiveAnimation.intensity,
                }
            )
            highTier10xActiveAnimation.strokeTween:Play()
        end

        highTier10xActiveAnimation.endTime = currentTime + extendDuration

        highTier10xActiveAnimation.resetThread = task.delay(
            extendDuration,
            function()
                if os.clock() >= highTier10xActiveAnimation.endTime then
                    TweenService
                        :Create(
                            highTier10xStroke,
                            TweenInfo.new(0.5, Enum.EasingStyle.Quad),
                            {
                                Color = highTier10xOriginalProperties.StrokeColor,
                                Thickness = highTier10xOriginalProperties.StrokeThickness,
                                Transparency = highTier10xOriginalProperties.StrokeTransparency,
                            }
                        )
                        :Play()
                end
            end
        )
    end)

    -- Regular Spawn Button
    local startButton = Instance.new('TextButton')
    startButton.Size = UDim2.new(0.6, 0, 0, 25)
    startButton.Position = UDim2.new(0.2, 0, 0.51, 0) -- Adjusted position
    startButton.Text = 'Spawn Pet'
    startButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    startButton.BackgroundTransparency = 0.1
    startButton.Font = Enum.Font.FredokaOne
    startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    startButton.TextSize = 16
    startButton.Parent = petContent

    local buttonCorner = Instance.new('UICorner')
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = startButton

    local buttonStroke = Instance.new('UIStroke')
    buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    buttonStroke.Color = Color3.fromRGB(255, 255, 255)
    buttonStroke.Thickness = 1.5
    buttonStroke.Transparency = 0.1
    buttonStroke.Parent = startButton

    local textStroke = Instance.new('UIStroke')
    textStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    textStroke.Color = Color3.new(0, 0, 0)
    textStroke.Thickness = 1.5
    textStroke.Transparency = 0
    textStroke.Parent = startButton

    local originalProperties = {
        BackgroundColor3 = startButton.BackgroundColor3,
        BackgroundTransparency = startButton.BackgroundTransparency,
        StrokeColor = Color3.fromRGB(255, 255, 255),
        StrokeThickness = 1.5,
        StrokeTransparency = 0.1,
    }

    local activeAnimation = {
        endTime = 0,
        strokeTween = nil,
        resetThread = nil,
        intensity = 1.0,
        lastSuccess = false,
    }

    startButton.MouseEnter:Connect(function()
        if activeAnimation.endTime < os.clock() then
            startButton.BackgroundColor3 = Color3.fromRGB(0, 130, 230)
            TweenService:Create(buttonStroke, TweenInfo.new(0.2), {
                Thickness = 2,
                Transparency = 0.05,
            }):Play()
        end
    end)

    startButton.MouseLeave:Connect(function()
        if activeAnimation.endTime < os.clock() then
            startButton.BackgroundColor3 = originalProperties.BackgroundColor3
            TweenService
                :Create(buttonStroke, TweenInfo.new(0.2), {
                    Thickness = originalProperties.StrokeThickness,
                    Transparency = originalProperties.StrokeTransparency,
                })
                :Play()
        end
    end)

    startButton.MouseButton1Click:Connect(function()
        local pet_name = petNameBox.Text
        local currentTime = os.clock()
        local extendDuration = 1.5

        local isExtension = currentTime < activeAnimation.endTime

        if isExtension then
            activeAnimation.intensity =
                math.min(activeAnimation.intensity + 0.3, 1.5)
            extendDuration = 1.5
        else
            activeAnimation.intensity = 1.0
        end

        if activeAnimation.strokeTween then
            activeAnimation.strokeTween:Cancel()
        end
        if activeAnimation.resetThread then
            coroutine.close(activeAnimation.resetThread)
        end

        local feedbackColor = Color3.fromRGB(255, 50, 50)
        local spawnSuccess = false

        if pet_name ~= '' then
            local petId = GetPetByName(pet_name)
            if petId then
                local flags = getPropertyFlags(pet_name)
                
                createPet(petId, {
                    pet_trick_level = math.random(1, 5),
                    mega_neon = flags.mega_neon,
                    neon = flags.neon,
                    rideable = flags.rideable,
                    flyable = flags.flyable,
                    age = flags.age,
                    rp_name = '',
                })
                spawnSuccess = true
                game.StarterGui:SetCore('SendNotification', {
                    Title = 'Pet Spawned!',
                    Text = pet_name .. ' has been spawned!',
                    Duration = 5,
                })
            else
                game.StarterGui:SetCore('SendNotification', {
                    Title = 'Error',
                    Text = 'Pet not found: ' .. pet_name,
                    Duration = 3,
                })
            end
        else
            game.StarterGui:SetCore('SendNotification', {
                Title = 'Error',
                Text = 'Please enter a pet name!',
                Duration = 3,
            })
        end

        activeAnimation.lastSuccess = spawnSuccess

        if isExtension and activeAnimation.lastSuccess then
            feedbackColor =
                Color3.fromRGB(0, 255 * activeAnimation.intensity, 0)
        end

        buttonStroke.Color = feedbackColor
        buttonStroke.Thickness = 2 * activeAnimation.intensity
        buttonStroke.Transparency = 0.1 / activeAnimation.intensity

        if isExtension then
            activeAnimation.strokeTween = TweenService:Create(
                buttonStroke,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                {
                    Thickness = 2.5 * activeAnimation.intensity,
                    Transparency = 0.05 / activeAnimation.intensity,
                }
            )
            activeAnimation.strokeTween:Play()
        end

        activeAnimation.endTime = currentTime + extendDuration

        activeAnimation.resetThread = task.delay(extendDuration, function()
            if os.clock() >= activeAnimation.endTime then
                TweenService
                    :Create(
                        buttonStroke,
                        TweenInfo.new(0.5, Enum.EasingStyle.Quad),
                        {
                            Color = originalProperties.StrokeColor,
                            Thickness = originalProperties.StrokeThickness,
                            Transparency = originalProperties.StrokeTransparency,
                        }
                    )
                    :Play()
            end
        end)
    end)

    -- Pet Rename Section
    local renameLabel = Instance.new('TextLabel')
    renameLabel.Size = UDim2.new(0.85, 0, 0, 20)
    renameLabel.Position = UDim2.new(0.075, 0, 0.57, 0) -- Adjusted position
    renameLabel.BackgroundTransparency = 1
    renameLabel.Text = 'Rename Equipped Pet'
    renameLabel.Font = Enum.Font.FredokaOne
    renameLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
    renameLabel.TextSize = 14
    renameLabel.Parent = petContent

    local renameBox = Instance.new('TextBox')
    renameBox.Size = UDim2.new(0.6, 0, 0, 25)
    renameBox.Position = UDim2.new(0.075, 0, 0.60, 0) -- Adjusted position
    renameBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    renameBox.BackgroundTransparency = 0.2
    renameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    renameBox.TextSize = 14
    renameBox.Font = Enum.Font.FredokaOne
    renameBox.PlaceholderText = 'Enter new pet name'
    renameBox.Text = ''
    renameBox.ClearTextOnFocus = false
    renameBox.Parent = petContent

    local renameBoxCorner = Instance.new('UICorner')
    renameBoxCorner.CornerRadius = UDim.new(0, 6)
    renameBoxCorner.Parent = renameBox

    local renameBoxGlow = Instance.new('UIStroke')
    renameBoxGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    renameBoxGlow.Color = Color3.fromRGB(255, 255, 255)
    renameBoxGlow.Thickness = 2.2
    renameBoxGlow.Transparency = 0.25
    renameBoxGlow.Parent = renameBox

    local renameButton = Instance.new('TextButton')
    renameButton.Size = UDim2.new(0.25, 0, 0, 25)
    renameButton.Position = UDim2.new(0.7, 0, 0.60, 0) -- Adjusted position
    renameButton.Text = 'Rename'
    renameButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    renameButton.BackgroundTransparency = 0.1
    renameButton.Font = Enum.Font.FredokaOne
    renameButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    renameButton.TextSize = 14
    renameButton.Parent = petContent

    local renameButtonCorner = Instance.new('UICorner')
    renameButtonCorner.CornerRadius = UDim.new(0, 6)
    renameButtonCorner.Parent = renameButton

    local renameButtonStroke = Instance.new('UIStroke')
    renameButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    renameButtonStroke.Color = Color3.fromRGB(255, 255, 255)
    renameButtonStroke.Thickness = 1.5
    renameButtonStroke.Transparency = 0.1
    renameButtonStroke.Parent = renameButton

    local renameButtonTextStroke = Instance.new('UIStroke')
    renameButtonTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    renameButtonTextStroke.Color = Color3.new(0, 0, 0)
    renameButtonTextStroke.Thickness = 1.5
    renameButtonTextStroke.Transparency = 0
    renameButtonTextStroke.Parent = renameButton

    renameButton.MouseButton1Click:Connect(function()
        local newName = renameBox.Text
        if newName ~= '' then
            if renameEquippedPet(newName) then
                renameBox.Text = ''
            end
        else
            game.StarterGui:SetCore('SendNotification', {
                Title = 'Error',
                Text = 'Please enter a name!',
                Duration = 3,
            })
        end
    end)

    renameButton.MouseEnter:Connect(function()
        renameButton.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
        TweenService:Create(renameButtonStroke, TweenInfo.new(0.2), {
            Thickness = 2,
            Transparency = 0.05,
        }):Play()
    end)

    renameButton.MouseLeave:Connect(function()
        renameButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        TweenService:Create(renameButtonStroke, TweenInfo.new(0.2), {
            Thickness = 1.5,
            Transparency = 0.1,
        }):Play()
    end)

    -- PET WEAR SECTION (NEW)
    local petWearNameBox = Instance.new('TextBox')
    petWearNameBox.Size = UDim2.new(0.85, 0, 0, 26)
    petWearNameBox.Position = UDim2.new(0.075, 0, 0.66, 0) -- Adjusted position
    petWearNameBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    petWearNameBox.BackgroundTransparency = 0.2
    petWearNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    petWearNameBox.TextSize = 13
    petWearNameBox.Font = Enum.Font.FredokaOne
    petWearNameBox.PlaceholderText = 'Enter Pet Wear Name'
    petWearNameBox.Text = ''
    petWearNameBox.ClearTextOnFocus = false
    petWearNameBox.Parent = petContent
    do
        local c = Instance.new('UICorner'); c.CornerRadius = UDim.new(0,6); c.Parent = petWearNameBox
        local s = Instance.new('UIStroke'); s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Color = Color3.fromRGB(220,180,255); s.Thickness = 1.8; s.Transparency = 0.25; s.Parent = petWearNameBox
        local ts = Instance.new('UIStroke'); ts.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
        ts.Color = Color3.new(0,0,0); ts.Thickness = 1.2; ts.Parent = petWearNameBox
    end
    petWearNameBox:GetPropertyChangedSignal('Text'):Connect(function()
        local cursor = petWearNameBox.CursorPosition
        local inputText = petWearNameBox.Text
        local newText = capitalizeWords(inputText)
        if newText ~= inputText then
            petWearNameBox.Text = newText
            petWearNameBox.CursorPosition = math.max(1, math.min(cursor + (#newText - #inputText), #newText + 1))
        end
    end)

    local addPetWearBtn = Instance.new('TextButton')
    addPetWearBtn.Size = UDim2.new(0.85, 0, 0, 26)
    addPetWearBtn.Position = UDim2.new(0.075, 0, 0.71, 0) -- Adjusted position
    addPetWearBtn.Text = '✦ Add PetWear'
    addPetWearBtn.BackgroundColor3 = Color3.fromRGB(180, 100, 255)
    addPetWearBtn.BackgroundTransparency = 0.1
    addPetWearBtn.Font = Enum.Font.FredokaOne
    addPetWearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    addPetWearBtn.TextSize = 13
    addPetWearBtn.Parent = petContent
    do
        local c = Instance.new('UICorner'); c.CornerRadius = UDim.new(0,8); c.Parent = addPetWearBtn
        local s = Instance.new('UIStroke'); s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Color = Color3.fromRGB(220,180,255); s.Thickness = 1.8; s.Transparency = 0.1; s.Parent = addPetWearBtn
        local ts = Instance.new('UIStroke'); ts.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
        ts.Color = Color3.new(0,0,0); ts.Thickness = 1.2; ts.Parent = addPetWearBtn
    end
    addPetWearBtn.MouseEnter:Connect(function()
        TweenService:Create(addPetWearBtn, TweenInfo.new(0.12), {BackgroundColor3=Color3.fromRGB(200,130,255)}):Play()
    end)
    addPetWearBtn.MouseLeave:Connect(function()
        TweenService:Create(addPetWearBtn, TweenInfo.new(0.12), {BackgroundColor3=Color3.fromRGB(180,100,255)}):Play()
    end)
    addPetWearBtn.MouseButton1Click:Connect(function()
        local wearName = petWearNameBox.Text
        if wearName == '' then
            game.StarterGui:SetCore('SendNotification', {Title='Error', Text='Enter a pet wear name!', Duration=3})
            return
        end
        local wearId = GetPetWearByName(wearName)
        if wearId then
            equipWearOnPet(wearId)
        else
            warn('[PetWear] "' .. wearName .. '" not found.')
            game.StarterGui:SetCore('SendNotification', {Title='Not Found', Text='"'..wearName..'" not found — check console.', Duration=5})
        end
    end)

    local PREPPY_WEARS = { 'Unicorn Horn', 'Pink Cat Ear Headphones', 'Rainbow Maker', '2022 Birthday Cupcake Shoes' }

    local preppyPWBtn = Instance.new('TextButton')
    preppyPWBtn.Size = UDim2.new(0.85, 0, 0, 26)
    preppyPWBtn.Position = UDim2.new(0.075, 0, 0.76, 0) -- Adjusted position
    preppyPWBtn.Text = '🎀 Add Preppy PW'
    preppyPWBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 180)
    preppyPWBtn.BackgroundTransparency = 0.1
    preppyPWBtn.Font = Enum.Font.FredokaOne
    preppyPWBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    preppyPWBtn.TextSize = 13
    preppyPWBtn.Parent = petContent
    do
        local c = Instance.new('UICorner'); c.CornerRadius = UDim.new(0,8); c.Parent = preppyPWBtn
        local s = Instance.new('UIStroke'); s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Color = Color3.fromRGB(255,180,220); s.Thickness = 1.8; s.Transparency = 0.1; s.Parent = preppyPWBtn
        local ts = Instance.new('UIStroke'); ts.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
        ts.Color = Color3.new(0,0,0); ts.Thickness = 1.2; ts.Parent = preppyPWBtn
    end
    preppyPWBtn.MouseEnter:Connect(function()
        TweenService:Create(preppyPWBtn, TweenInfo.new(0.12), {BackgroundColor3=Color3.fromRGB(255,130,200)}):Play()
    end)
    preppyPWBtn.MouseLeave:Connect(function()
        TweenService:Create(preppyPWBtn, TweenInfo.new(0.12), {BackgroundColor3=Color3.fromRGB(255,100,180)}):Play()
    end)
    preppyPWBtn.MouseButton1Click:Connect(function()
        local added, missed = {}, {}
        for _, wearName in ipairs(PREPPY_WEARS) do
            local wearId = GetPetWearByName(wearName)
            if wearId then equipWearOnPet(wearId); table.insert(added, wearName)
            else warn('[PetWear] Not found: '..wearName); table.insert(missed, wearName) end
        end
        if #added > 0 then
            game.StarterGui:SetCore('SendNotification', {
                Title = '🎀 Preppy PW Equipped!',
                Text = #added..' wears equipped'..(#missed > 0 and ' ('..#missed..' not found)' or '')..'.',
                Duration = 5,
            })
        else
            game.StarterGui:SetCore('SendNotification', {Title='None Found', Text='No preppy wears found.', Duration=4})
        end
    end)

    -- TOY CONTENT
    -- TextBox to input toy name
    local toyNameBox = Instance.new('TextBox')
    toyNameBox.Size = UDim2.new(0.85, 0, 0, 28)
    toyNameBox.Position = UDim2.new(0.075, 0, 0.1, 0)
    toyNameBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    toyNameBox.BackgroundTransparency = 0.2
    toyNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    toyNameBox.TextSize = 14
    toyNameBox.Font = Enum.Font.FredokaOne
    toyNameBox.PlaceholderText = 'Enter Toy Name to Spawn'
    toyNameBox.Text = ''
    toyNameBox.ClearTextOnFocus = false
    toyNameBox.Parent = toyContent

    local toyBoxCorner = Instance.new('UICorner')
    toyBoxCorner.CornerRadius = UDim.new(0, 6)
    toyBoxCorner.Parent = toyNameBox

    local toyTextStroke = Instance.new('UIStroke')
    toyTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    toyTextStroke.Color = Color3.new(0, 0, 0)
    toyTextStroke.Thickness = 1.2
    toyTextStroke.Transparency = 0
    toyTextStroke.Parent = toyNameBox

    local toyBoxGlow = Instance.new('UIStroke')
    toyBoxGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    toyBoxGlow.Color = Color3.fromRGB(255, 255, 255)
    toyBoxGlow.Thickness = 2.2
    toyBoxGlow.Transparency = 0.25
    toyBoxGlow.Parent = toyNameBox

    local validToyNames = {}
    local validToyNamesClean = {}

    local function loadToyNames()
        local inventory_db =
            require(game.ReplicatedStorage.Fsys).load('InventoryDB')
        for category_name, category_table in pairs(inventory_db) do
            if category_name == 'toys' then
                for id, item in pairs(category_table) do
                    validToyNames[#validToyNames + 1] = item.name
                    validToyNamesClean[#validToyNamesClean + 1] =
                        item.name:lower():gsub('%s+', '')
                end
                break
            end
        end
    end

    loadToyNames()

    local toyCurrentColorTween = nil

    toyNameBox:GetPropertyChangedSignal('Text'):Connect(function()
        lastCursorPosition = toyNameBox.CursorPosition
        local inputText = toyNameBox.Text

        local newText = capitalizeWords(inputText)
        if newText ~= inputText then
            toyNameBox.Text = newText
            local addedChars = #newText - #inputText
            toyNameBox.CursorPosition = math.max(
                1,
                math.min(lastCursorPosition + addedChars, #newText + 1)
            )
            return
        end

        local displayedText = toyNameBox.Text
        local cleanName = displayedText:lower():gsub('%s+', '')

        local isExactMatch = false
        local isCleanMatch = false

        for _, name in ipairs(validToyNames) do
            if name:lower() == displayedText:lower() then
                isExactMatch = true
                break
            end
        end

        isCleanMatch = table.find(validToyNamesClean, cleanName) ~= nil

        local targetColor
        if displayedText == '' then
            targetColor = COLORS.NEUTRAL
        elseif isExactMatch then
            targetColor = COLORS.VALID
        elseif isCleanMatch then
            targetColor = COLORS.VALID
        else
            targetColor = COLORS.INVALID
        end

        if toyCurrentColorTween then
            toyCurrentColorTween:Cancel()
        end

        toyCurrentColorTween = TweenService:Create(
            toyBoxGlow,
            TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Color = targetColor }
        )
        toyCurrentColorTween:Play()
    end)

    if toyCurrentColorTween then
        toyCurrentColorTween:Cancel()
    end
    toyCurrentColorTween = TweenService:Create(
        toyBoxGlow,
        TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Color = COLORS.NEUTRAL }
    )
    toyCurrentColorTween:Play()

    -- Toy spawn button
    local toySpawnButton = Instance.new('TextButton')
    toySpawnButton.Size = UDim2.new(0.6, 0, 0, 25)
    toySpawnButton.Position = UDim2.new(0.2, 0, 0.3, 0)
    toySpawnButton.Text = 'Spawn Toy'
    toySpawnButton.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
    toySpawnButton.BackgroundTransparency = 0.1
    toySpawnButton.Font = Enum.Font.FredokaOne
    toySpawnButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toySpawnButton.TextSize = 16
    toySpawnButton.Parent = toyContent

    local toyButtonCorner = Instance.new('UICorner')
    toyButtonCorner.CornerRadius = UDim.new(0, 8)
    toyButtonCorner.Parent = toySpawnButton

    local toyButtonStroke = Instance.new('UIStroke')
    toyButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    toyButtonStroke.Color = Color3.fromRGB(255, 255, 255)
    toyButtonStroke.Thickness = 1.5
    toyButtonStroke.Transparency = 0.1
    toyButtonStroke.Parent = toySpawnButton

    local toyTextStroke = Instance.new('UIStroke')
    toyTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    toyTextStroke.Color = Color3.new(0, 0, 0)
    toyTextStroke.Thickness = 1.5
    toyTextStroke.Transparency = 0
    toyTextStroke.Parent = toySpawnButton

    local toyOriginalProperties = {
        BackgroundColor3 = toySpawnButton.BackgroundColor3,
        BackgroundTransparency = toySpawnButton.BackgroundTransparency,
        StrokeColor = Color3.fromRGB(255, 255, 255),
        StrokeThickness = 1.5,
        StrokeTransparency = 0.1,
    }

    local toyActiveAnimation = {
        endTime = 0,
        strokeTween = nil,
        resetThread = nil,
        intensity = 1.0,
        lastSuccess = false,
    }

    toySpawnButton.MouseEnter:Connect(function()
        if toyActiveAnimation.endTime < os.clock() then
            toySpawnButton.BackgroundColor3 = Color3.fromRGB(220, 120, 0)
            TweenService:Create(toyButtonStroke, TweenInfo.new(0.2), {
                Thickness = 2,
                Transparency = 0.05,
            }):Play()
        end
    end)

    toySpawnButton.MouseLeave:Connect(function()
        if toyActiveAnimation.endTime < os.clock() then
            toySpawnButton.BackgroundColor3 =
                toyOriginalProperties.BackgroundColor3
            TweenService
                :Create(toyButtonStroke, TweenInfo.new(0.2), {
                    Thickness = toyOriginalProperties.StrokeThickness,
                    Transparency = toyOriginalProperties.StrokeTransparency,
                })
                :Play()
        end
    end)

    toySpawnButton.MouseButton1Click:Connect(function()
        local toy_name = toyNameBox.Text
        local currentTime = os.clock()
        local extendDuration = 1.5

        local isExtension = currentTime < toyActiveAnimation.endTime

        if isExtension then
            toyActiveAnimation.intensity =
                math.min(toyActiveAnimation.intensity + 0.3, 1.5)
            extendDuration = 1.5
        else
            toyActiveAnimation.intensity = 1.0
        end

        if toyActiveAnimation.strokeTween then
            toyActiveAnimation.strokeTween:Cancel()
        end
        if toyActiveAnimation.resetThread then
            coroutine.close(toyActiveAnimation.resetThread)
        end

        local feedbackColor = Color3.fromRGB(255, 50, 50)
        local spawnSuccess = false

        if toy_name ~= '' then
            local toyId = GetToyByName(toy_name)
            if toyId then
                createToy(toyId)
                spawnSuccess = true
                game.StarterGui:SetCore('SendNotification', {
                    Title = 'Toy Spawned!',
                    Text = toy_name .. ' has been spawned!',
                    Duration = 5,
                })
            else
                game.StarterGui:SetCore('SendNotification', {
                    Title = 'Error',
                    Text = 'Toy not found: ' .. toy_name,
                    Duration = 3,
                })
            end
        else
            game.StarterGui:SetCore('SendNotification', {
                Title = 'Error',
                Text = 'Please enter a toy name!',
                Duration = 3,
            })
        end

        toyActiveAnimation.lastSuccess = spawnSuccess

        if isExtension and toyActiveAnimation.lastSuccess then
            feedbackColor =
                Color3.fromRGB(0, 255 * toyActiveAnimation.intensity, 0)
        end

        toyButtonStroke.Color = feedbackColor
        toyButtonStroke.Thickness = 2 * toyActiveAnimation.intensity
        toyButtonStroke.Transparency = 0.1 / toyActiveAnimation.intensity

        if isExtension then
            toyActiveAnimation.strokeTween = TweenService:Create(
                toyButtonStroke,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                {
                    Thickness = 2.5 * toyActiveAnimation.intensity,
                    Transparency = 0.05 / toyActiveAnimation.intensity,
                }
            )
            toyActiveAnimation.strokeTween:Play()
        end

        toyActiveAnimation.endTime = currentTime + extendDuration

        toyActiveAnimation.resetThread = task.delay(extendDuration, function()
            if os.clock() >= toyActiveAnimation.endTime then
                TweenService
                    :Create(
                        toyButtonStroke,
                        TweenInfo.new(0.5, Enum.EasingStyle.Quad),
                        {
                            Color = toyOriginalProperties.StrokeColor,
                            Thickness = toyOriginalProperties.StrokeThickness,
                            Transparency = toyOriginalProperties.StrokeTransparency,
                        }
                    )
                    :Play()
            end
        end)
    end)

    local function loadInMainFrame()
        local tweenInfo =
            TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local sizeGoal = { Size = UDim2.new(0, 340, 0, 520) } -- Updated size
        local transparencyGoal = { BackgroundTransparency = 0 }

        local sizeTween = TweenService:Create(mainFrame, tweenInfo, sizeGoal)
        local transparencyTween =
            TweenService:Create(mainFrame, tweenInfo, transparencyGoal)

        sizeTween:Play()
        transparencyTween:Play()
    end

    loadInMainFrame()

    local dragging, dragStart, startPos
    mainFrame.InputBegan:Connect(function(input)
        if
            input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
        then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    mainFrame.InputChanged:Connect(function(input)
        if
            dragging
            and (
                input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch
            )
        then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    local function testNeonSystem()
        print("[TEST] PetNeonHelper integrated successfully")
        print("[TEST] Available functions:")
        for funcName, _ in pairs(PetNeonHelper) do
            print("[TEST] - " .. funcName)
        end
        print("[TEST] Mega neon default colors:", #PetNeonHelper.get_mega_neon_defaults(), "colors")
    end
    
    task.delay(3, testNeonSystem)
end)
