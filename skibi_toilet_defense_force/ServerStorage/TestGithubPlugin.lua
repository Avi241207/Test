-- @ScriptType: Script
-- OBA GitHub Push Plugin
-- Install as a Plugin in Roblox Studio (not a game script)
local GITHUB_TOKEN = "REDACTED_GITHUB_TOKEN"
local GITHUB_USER = "Avi241207"
local BASE_BRANCH = "main"

local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

-- ─── Detectar Place actual ───────────────────────────────────────────────────
local function getPlaceFolderName()
	local placeId = game.PlaceId
	local placeName = game.Name

	-- Intentar obtener el nombre real del place desde la API de Roblox
	if placeId ~= 0 then
		local ok, info = pcall(function()
			return MarketplaceService:GetProductInfo(placeId, Enum.InfoType.Asset)
		end)
		if ok and info and info.Name and info.Name ~= "" then
			placeName = info.Name
		end
	end

	local sanitized = placeName:lower()
		:gsub("%s+", "_")
		:gsub("[^%w_%-]", "")
		:gsub("_+", "_")
		:gsub("^_", "")
		:gsub("_$", "")
	if sanitized == "" then
		sanitized = "place_" .. tostring(placeId)
	end
	if placeId == 0 then
		sanitized = sanitized .. "_local"
	end
	return sanitized, placeName, placeId
end

-- ─── Toolbar ─────────────────────────────────────────────────────────────────
local toolbar = plugin:CreateToolbar("OBA GitHub")
local btnCommit = toolbar:CreateButton(
	"Push a GitHub",
	"Exporta todos los scripts del place abierto y abre un Pull Request",
	"rbxassetid://6031068420"
)

-- ─── GitHub API ───────────────────────────────────────────────────────────────
local function githubRequest(method, path, body)
	local url = "https://api.github.com/" .. path
	local headers = {
		["Authorization"] = "token " .. GITHUB_TOKEN,
		["Accept"] = "application/vnd.github.v3+json",
		["Content-Type"] = "application/json",
		["X-GitHub-Api-Version"] = "2022-11-28",
	}
	local ok, result = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = method,
			Headers = headers,
			Body = body and HttpService:JSONEncode(body) or nil,
		})
	end)
	if not ok then
		return nil, "HTTP error: " .. tostring(result)
	end
	if result.StatusCode >= 400 then
		return nil, "GitHub API error " .. result.StatusCode .. ": " .. result.Body
	end
	return HttpService:JSONDecode(result.Body), nil
end

local function ensureRepoExists(repoName)
	local result, _ = githubRequest("GET", "repos/" .. repoName)
	if result then return nil end
	return "Repositorio no encontrado: " .. repoName
end

-- ─── Base64 ───────────────────────────────────────────────────────────────────
local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function base64Encode(data)
	local result = {}
	local padding = (3 - #data % 3) % 3
	data = data .. string.rep("\0", padding)
	for i = 1, #data, 3 do
		local a, b, c = string.byte(data, i, i + 2)
		local n = a * 65536 + b * 256 + c
		table.insert(result, string.sub(b64chars, math.floor(n / 262144) + 1, math.floor(n / 262144) + 1))
		table.insert(result, string.sub(b64chars, math.floor(n / 4096) % 64 + 1, math.floor(n / 4096) % 64 + 1))
		table.insert(result, string.sub(b64chars, math.floor(n / 64) % 64 + 1, math.floor(n / 64) % 64 + 1))
		table.insert(result, string.sub(b64chars, n % 64 + 1, n % 64 + 1))
	end
	local encoded = table.concat(result)
	if padding > 0 then
		encoded = string.sub(encoded, 1, #encoded - padding) .. string.rep("=", padding)
	end
	return encoded
end

-- ─── Recolección de scripts ───────────────────────────────────────────────────
local function getScriptTypeHeader(script)
	if script:IsA("LocalScript") then return "-- @ScriptType: LocalScript\n"
	elseif script:IsA("ModuleScript") then return "-- @ScriptType: ModuleScript\n"
	else return "-- @ScriptType: Script\n" end
end

local function getScriptPath(script, placeFolderName)
	local parts = { script.Name .. ".lua" }
	local current = script.Parent
	while current and current ~= game do
		table.insert(parts, 1, current.Name)
		current = current.Parent
	end
	table.insert(parts, 1, placeFolderName)
	return table.concat(parts, "/")
end

local SERVICES_TO_EXPORT = {
	"ServerScriptService", "ReplicatedStorage", "StarterGui",
	"StarterPlayer", "ReplicatedFirst", "ServerStorage",
}

local function collectScripts(placeFolderName)
	local scripts = {}
	for _, serviceName in ipairs(SERVICES_TO_EXPORT) do
		local service = game:FindFirstChild(serviceName)
		if service then
			for _, desc in ipairs(service:GetDescendants()) do
				if desc:IsA("Script") or desc:IsA("LocalScript") or desc:IsA("ModuleScript") then
					local path = getScriptPath(desc, placeFolderName)
					local source = string.gsub(desc.Source or "", "ghp_[%w]+", "REDACTED_GITHUB_TOKEN")
					local content = getScriptTypeHeader(desc) .. source
					table.insert(scripts, { path = path, content = content })
				end
			end
		end
	end
	return scripts
end

-- ─── Git API helpers ──────────────────────────────────────────────────────────
local function getBaseSHA(repoName)
	local result, err = githubRequest("GET", "repos/" .. repoName .. "/git/ref/heads/" .. BASE_BRANCH)
	if err then
		if string.find(err, "409") then return nil, "EMPTY_REPO" end
		return nil, err
	end
	return result.object.sha, nil
end

local function getBaseTreeSHA(repoName, commitSHA)
	local result, err = githubRequest("GET", "repos/" .. repoName .. "/git/commits/" .. commitSHA)
	if err then return nil, err end
	return result.tree.sha, nil
end

local function createBlob(repoName, content)
	local result, err = githubRequest("POST", "repos/" .. repoName .. "/git/blobs", {
		content = base64Encode(content),
		encoding = "base64",
	})
	if err then return nil, err end
	return result.sha, nil
end

local function createTree(repoName, baseTreeSHA, scripts)
	local treeItems = {}
	for _, script in ipairs(scripts) do
		local blobSHA, err = createBlob(repoName, script.content)
		if err then return nil, "Blob error for " .. script.path .. ": " .. err end
		table.insert(treeItems, {
			path = script.path,
			mode = "100644",
			type = "blob",
			sha = blobSHA,
		})
	end
	local result, err = githubRequest("POST", "repos/" .. repoName .. "/git/trees", {
		base_tree = baseTreeSHA,
		tree = treeItems,
	})
	if err then return nil, err end
	return result.sha, nil
end

local function createCommit(repoName, message, treeSHA, parentSHA)
	local result, err = githubRequest("POST", "repos/" .. repoName .. "/git/commits", {
		message = message,
		tree = treeSHA,
		parents = parentSHA and { parentSHA } or {},
		author = {
			name = GITHUB_USER,
			email = GITHUB_USER .. "@users.noreply.github.com",
		},
	})
	if err then return nil, err end
	return result.sha, nil
end

local function createInitialFile(repoName)
	local _, err = githubRequest("PUT", "repos/" .. repoName .. "/contents/README.md", {
		message = "Initial commit",
		content = base64Encode("# " .. repoName .. "\n\nInicializado por plugin OBA."),
		branch = BASE_BRANCH,
	})
	return err
end

local function createBranch(repoName, branchName, commitSHA)
	local _, err = githubRequest("POST", "repos/" .. repoName .. "/git/refs", {
		ref = "refs/heads/" .. branchName,
		sha = commitSHA,
	})
	return err
end

local function createPR(repoName, title, body, branchName)
	local result, err = githubRequest("POST", "repos/" .. repoName .. "/pulls", {
		title = title,
		body = body,
		head = branchName,
		base = BASE_BRANCH,
	})
	if err then return nil, err end
	return result.html_url, nil
end

-- ─── Push principal ───────────────────────────────────────────────────────────
local function doPush(commitMessage, repoName, placeFolderName, placeName)
	local timestamp = os.date("%Y%m%d-%H%M%S")
	local branchName = "studio/" .. placeFolderName .. "-" .. timestamp

	print("[OBA Git] Place: '" .. placeName .. "' → carpeta: /" .. placeFolderName)
	print("[OBA Git] Recopilando scripts...")
	local scripts = collectScripts(placeFolderName)
	print("[OBA Git] " .. #scripts .. " scripts encontrados.")

	local repoErr = ensureRepoExists(repoName)
	if repoErr then warn("[OBA Git] ERROR: " .. repoErr) return end

	print("[OBA Git] Obteniendo SHA base...")
	local baseSHA, err = getBaseSHA(repoName)
	if err == "EMPTY_REPO" then
		warn("[OBA Git] Repo vacío, inicializando con README...")
		local initErr = createInitialFile(repoName)
		if initErr then warn("[OBA Git] ERROR inicializando: " .. initErr) return end
		baseSHA, err = getBaseSHA(repoName)
		if err then warn("[OBA Git] ERROR tras init: " .. err) return end
	elseif err then
		warn("[OBA Git] ERROR: " .. err) return
	end

	local baseTreeSHA, err2 = getBaseTreeSHA(repoName, baseSHA)
	if err2 then warn("[OBA Git] ERROR: " .. err2) return end

	print("[OBA Git] Creando blobs y árbol...")
	local newTreeSHA, err3 = createTree(repoName, baseTreeSHA, scripts)
	if err3 then warn("[OBA Git] ERROR: " .. err3) return end

	print("[OBA Git] Creando commit...")
	local fullMessage = commitMessage
		.. "\n\nPlace: " .. placeName
		.. " → /" .. placeFolderName
		.. "\nScripts exportados: " .. #scripts

	local newCommitSHA, err4 = createCommit(repoName, fullMessage, newTreeSHA, baseSHA)
	if err4 then warn("[OBA Git] ERROR: " .. err4) return end

	print("[OBA Git] Creando branch: " .. branchName)
	local err5 = createBranch(repoName, branchName, newCommitSHA)
	if err5 then warn("[OBA Git] ERROR creando branch: " .. err5) return end

	print("[OBA Git] Abriendo Pull Request...")
	local prTitle = "[" .. placeFolderName .. "] " .. commitMessage
	local prBody = "**Place:** " .. placeName
		.. "\n**Carpeta en repo:** `/" .. placeFolderName .. "`"
		.. "\n**Scripts exportados:** " .. #scripts
		.. "\n\n*Generado automáticamente por OBA GitHub Push Plugin*"

	local prURL, err6 = createPR(repoName, prTitle, prBody, branchName)
	if err6 then warn("[OBA Git] ERROR creando PR: " .. err6) return end

	print("[OBA Git] ✅ PR abierto: " .. prURL)
	return prURL
end

-- ─── UI ───────────────────────────────────────────────────────────────────────
local widget = nil

local function openDialog()
	if widget then
		widget:Destroy()
		widget = nil
	end

	local placeFolderName, placeName, _ = getPlaceFolderName()
	local GITHUB_REPO = game:GetService("ServerStorage").ClaveRepo.Value
	
	local widgetInfo = DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Float,
		true, false, 400, 220, 300, 180
	)
	widget = plugin:CreateDockWidgetPluginGui("TestGit", widgetInfo)
	widget.Title = "OBA — Push a GitHub"

	widget:GetPropertyChangedSignal("Enabled"):Connect(function()
		if not widget.Enabled then
			widget:Destroy()
			widget = nil
		end
	end)

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BorderSizePixel = 0
	frame.Parent = widget

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 16)
	padding.PaddingBottom = UDim.new(0, 16)
	padding.PaddingLeft = UDim.new(0, 16)
	padding.PaddingRight = UDim.new(0, 16)
	padding.Parent = frame

	local placeIndicator = Instance.new("TextLabel")
	placeIndicator.Size = UDim2.new(1, 0, 0, 20)
	placeIndicator.Position = UDim2.new(0, 0, 0, 0)
	placeIndicator.BackgroundTransparency = 1
	placeIndicator.TextColor3 = Color3.fromRGB(100, 200, 140)
	placeIndicator.Font = Enum.Font.GothamMedium
	placeIndicator.TextSize = 12
	placeIndicator.TextXAlignment = Enum.TextXAlignment.Left
	placeIndicator.Text = "📍 Place: " .. placeName .. " → /" .. placeFolderName
	placeIndicator.Parent = frame

	local repoIndicator = Instance.new("TextLabel")
	repoIndicator.Size = UDim2.new(1, 0, 0, 20)
	repoIndicator.Position = UDim2.new(0, 0, 0, 22)
	repoIndicator.BackgroundTransparency = 1
	repoIndicator.TextColor3 = Color3.fromRGB(120, 160, 220)
	repoIndicator.Font = Enum.Font.GothamMedium
	repoIndicator.TextSize = 12
	repoIndicator.TextXAlignment = Enum.TextXAlignment.Left
	repoIndicator.Text = "📦 Repo: " .. GITHUB_REPO
	repoIndicator.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 20)
	label.Position = UDim2.new(0, 0, 0, 52)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = "Mensaje de commit:"
	label.Parent = frame

	local input = Instance.new("TextBox")
	input.Size = UDim2.new(1, 0, 0, 36)
	input.Position = UDim2.new(0, 0, 0, 78)
	input.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	input.BorderSizePixel = 0
	input.TextColor3 = Color3.fromRGB(240, 240, 240)
	input.PlaceholderText = "ej: fix drop rate boss final"
	input.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
	input.Font = Enum.Font.Gotham
	input.TextSize = 13
	input.ClearTextOnFocus = false
	input.Text = ""
	input.Parent = frame
	Instance.new("UICorner", input).CornerRadius = UDim.new(0, 4)
	local inputPad = Instance.new("UIPadding", input)
	inputPad.PaddingLeft = UDim.new(0, 8)

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Size = UDim2.new(1, 0, 0, 20)
	statusLabel.Position = UDim2.new(0, 0, 1, -58)
	statusLabel.BackgroundTransparency = 1
	statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.TextSize = 12
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.Text = ""
	statusLabel.Parent = frame

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 36)
	btn.Position = UDim2.new(0, 0, 1, -36)
	btn.BackgroundColor3 = Color3.fromRGB(0, 120, 80)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.Text = "📤 Commit & Push PR"
	btn.BorderSizePixel = 0
	btn.Active = true
	btn.Parent = frame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	btn.MouseButton1Click:Connect(function()
		local commitMsg = input.Text
		if commitMsg == "" then
			statusLabel.TextColor3 = Color3.fromRGB(220, 80, 80)
			statusLabel.Text = "⚠ Escribe un mensaje de commit."
			return
		end
		btn.Active = false
		btn.Text = "⏳ Procesando..."
		btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
		statusLabel.Text = "Subiendo /" .. placeFolderName .. " a " .. GITHUB_REPO .. "..."

		task.spawn(function()
			local prURL = doPush(commitMsg, GITHUB_REPO, placeFolderName, placeName)
			task.wait(0.1)
			if prURL then
				statusLabel.TextColor3 = Color3.fromRGB(80, 200, 120)
				statusLabel.Text = "✅ PR abierto: " .. prURL
				btn.Text = "✅ ¡Listo!"
				btn.BackgroundColor3 = Color3.fromRGB(0, 100, 60)
				task.wait(3)
				btn.Text = "📤 Commit & Push PR"
				btn.BackgroundColor3 = Color3.fromRGB(0, 120, 80)
				btn.Active = true
				input.Text = ""
			else
				statusLabel.TextColor3 = Color3.fromRGB(220, 80, 80)
				statusLabel.Text = "❌ Error al subir (revisa el Output)"
				btn.Text = "📤 Commit & Push PR"
				btn.BackgroundColor3 = Color3.fromRGB(0, 120, 80)
				btn.Active = true
			end
		end)
	end)
end

btnCommit.Click:Connect(openDialog)