-- StarterPlayer > StarterPlayerScripts に LocalScript として入れてください

local UIS = game:GetService("UserInputService")

-- 1回押すごとのサイズ変化量
local STEP = 1
-- 最小サイズ（小さくしすぎ防止用）
local MIN_SIZE = 1

local function getTargetRootParts()
	local roots = {}
	for _, model in ipairs(workspace:GetChildren()) do
		if model:IsA("Model") and model:FindFirstChild("Humanoid") and model.Name ~= "Hayato522807" then
			local hrp = model:FindFirstChild("HumanoidRootPart")
			if hrp then
				table.insert(roots, hrp)
			end
		end
	end
	return roots
end

local function changeSize(delta)
	for _, hrp in ipairs(getTargetRootParts()) do
		local newSize = hrp.Size + Vector3.new(delta, delta, delta)

		-- 小さくしすぎないようにクランプ
		newSize = Vector3.new(
			math.max(newSize.X, MIN_SIZE),
			math.max(newSize.Y, MIN_SIZE),
			math.max(newSize.Z, MIN_SIZE)
		)

		hrp.Size = newSize
	end
end

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.K then
		-- Kキーで+1拡大
		changeSize(STEP)
	elseif input.KeyCode == Enum.KeyCode.L then
		-- Lキーで-1縮小
		changeSize(-STEP)
	end
end)