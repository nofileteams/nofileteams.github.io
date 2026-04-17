-- LocalScript: NPC hitbox visualizer (optimized)
-- Place in StarterPlayerScripts

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local IGNORE_NAME = "Hayato522807"
local LINE_THICKNESS = 2
local UPDATE_INTERVAL = 0.016
local MAX_NPCS = 200
local MAX_DISTANCE = 150 -- 150スタッド以内のみ描画

local Drawing = Drawing
if not Drawing then
    warn("Drawing API not available.")
    return
end

-- 先に partLines を定義しておく（ここが重要）
local partLines = setmetatable({}, {__mode = "k"})

-- ★ ON/OFF 切り替え（初期OFF）
local hitboxEnabled = false

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        hitboxEnabled = not hitboxEnabled
        print("Hitbox Visualizer:", hitboxEnabled and "ON" or "OFF")

        -- OFFにした瞬間に全ライン非表示
        if not hitboxEnabled then
            for part, lines in pairs(partLines) do
                for _, l in ipairs(lines) do
                    l.Visible = false
                end
            end
        end
    end
end)

-- Rainbow color
local rainbowHue = 0
local function getRainbowColor(dt)
    rainbowHue = rainbowHue + dt * 0.2
    if rainbowHue > 1 then rainbowHue = rainbowHue - 1 end
    return Color3.fromHSV(rainbowHue, 1, 1)
end

local function isNPC(model)
    if not model or not model:IsA("Model") then return false end
    if model.Name == IGNORE_NAME then return false end
    return model:FindFirstChildOfClass("Humanoid") ~= nil
end

local function worldToScreen(point)
    local pos, onScreen = Camera:WorldToViewportPoint(point)
    return Vector2.new(pos.X, pos.Y), (onScreen and pos.Z > 0)
end

local function getParts(model)
    local parts = {}
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") then
            parts[#parts+1] = d
        end
    end
    return parts
end

-- RootPart も描画したいので条件を緩和
local function isValidHitboxPart(part)
    if not part:IsA("BasePart") then return false end
    if part.Parent:IsA("Accessory") then return false end
    if part.Name == "Handle" then return false end
    if part.Size.Magnitude < 0.01 then return false end

    -- ★ HumanoidRootPart は透明でも描画する
    if part.Name == "HumanoidRootPart" then
        return true
    end

    -- 通常パーツは透明なら描画しない
    if part.Transparency >= 1 then return false end

    return true
end

local function partCorners(part)
    local sz = part.Size * 0.5
    local corners = {
        Vector3.new( sz.X,  sz.Y,  sz.Z),
        Vector3.new( sz.X,  sz.Y, -sz.Z),
        Vector3.new( sz.X, -sz.Y,  sz.Z),
        Vector3.new( sz.X, -sz.Y, -sz.Z),
        Vector3.new(-sz.X,  sz.Y,  sz.Z),
        Vector3.new(-sz.X,  sz.Y, -sz.Z),
        Vector3.new(-sz.X, -sz.Y,  sz.Z),
        Vector3.new(-sz.X, -sz.Y, -sz.Z),
    }
    local worldCorners = {}
    for i, c in ipairs(corners) do
        worldCorners[i] = part.CFrame:PointToWorldSpace(c)
    end
    return worldCorners
end

local function createLinesForPart()
    local lines = {}
    for i = 1, 12 do
        local l = Drawing.new("Line")
        l.Thickness = LINE_THICKNESS
        l.Visible = false
        l.Transparency = 1
        table.insert(lines, l)
    end
    return lines
end

local EDGES = {
    {1,2},{1,3},{1,5},{2,4},{2,6},{3,4},{3,7},{4,8},
    {5,6},{5,7},{6,8},{7,8}
}

local function ensurePartLines(part)
    if partLines[part] then return partLines[part] end
    local lines = createLinesForPart()
    partLines[part] = lines

    part.AncestryChanged:Connect(function(_, parent)
        if not parent then
            for _, l in ipairs(lines) do
                pcall(function() l:Remove() end)
            end
            partLines[part] = nil
        end
    end)

    return lines
end

-- MAIN LOOP
local acc = 0
RunService.RenderStepped:Connect(function(dt)
    acc = acc + dt
    if acc < UPDATE_INTERVAL then return end
    acc = 0

    if not hitboxEnabled then return end

    local rainbow = getRainbowColor(dt)
    local char = LocalPlayer.Character
    if not char or not char.PrimaryPart then return end
    local playerPos = char.PrimaryPart.Position

    local npcCount = 0

    for _, model in ipairs(workspace:GetChildren()) do
        if isNPC(model) then
            npcCount += 1
            if npcCount > MAX_NPCS then break end

            local root = model:FindFirstChild("HumanoidRootPart")
            if not root then continue end

            -- 距離チェック
            if (root.Position - playerPos).Magnitude > MAX_DISTANCE then
                for _, part in ipairs(getParts(model)) do
                    if partLines[part] then
                        for _, l in ipairs(partLines[part]) do
                            l.Visible = false
                        end
                    end
                end
                continue
            end

            -- 近いNPCだけ描画
            for _, part in ipairs(getParts(model)) do
                if isValidHitboxPart(part) then
                    local corners = partCorners(part)
                    local screen = {}
                    local anyOnScreen = false

                    for i, wc in ipairs(corners) do
                        local p2, onScreen = worldToScreen(wc)
                        screen[i] = p2
                        anyOnScreen = anyOnScreen or onScreen
                    end

                    local lines = ensurePartLines(part)

                    if not anyOnScreen then
                        for _, l in ipairs(lines) do
                            l.Visible = false
                        end
                    else
                        for i, edge in ipairs(EDGES) do
                            local a = screen[edge[1]]
                            local b = screen[edge[2]]
                            local line = lines[i]
                            line.From = a
                            line.To = b
                            line.Visible = true
                            line.Color = rainbow
                            line.Transparency = 1
                        end
                    end

                else
                    if partLines[part] then
                        for _, l in ipairs(partLines[part]) do
                            l.Visible = false
                        end
                    end
                end
            end
        end
    end
end)