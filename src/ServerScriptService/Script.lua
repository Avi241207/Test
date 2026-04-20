-- @ScriptType: Script
-- OBA GitHub Push Plugin
-- Install as a Plugin in Roblox Studio (not a game script)
-- Toolbar button opens a commit dialog, exports all scripts, and opens a PR on GitHub

local GITHUB_TOKEN = "REDACTED_GITHUB_TOKEN"
local GITHUB_REPO  = "Avi241207/Test"
local GITHUB_USER  = "Avi241207"
local BASE_BRANCH  = "main"

local HttpService   = game:GetService("HttpService")
local Selection     = game:GetService("Selection")
local StudioService = game:GetService("StudioService")

-- ─── Toolbar ────────────────────────────────────────────────────────────────
local toolbar   = plugin:CreateToolbar("OBA GitHub")
local btnCommit = toolbar:CreateButton(
	"Push a GitHub",
	"Exporta todos los scripts del lugar y abre un Pull Request",
	"rbxassetid://6031068420"
)

-- ─── Helpers ────────────────────────────────────────────────────────────────
local function githubRequest(method, path, body)
	local url = "https://api.github.com/" .. path
	local headers = {
		["Authorization"]        = "token " .. GITHUB_TOKEN,
		["Accept"]               = "application/vnd.github.v3+json",
		["Content-Type"]         = "application/json",
		["X-GitHub-Api-Version"] = "2022-11-28",
	}
	local ok, result = pcall(function()
		return HttpService:RequestAsync({
			Url     = url,
			Method  = method,
			Headers = headers,
			Body    = body and HttpService:JSONEncode(body) or nil,
		})
	end)
	if not ok then
		return nil, "HTTP error: " .. tostring(result)
	end
	if result.StatusCode >= 400 then
		return nil, "GitHub API error " .. result.StatusCode .. ": " .. result.Body
	end
	local decoded = HttpService:JSONDecode(result.Body)
	return decoded, nil
end

local function fetchUserRepos()
	local result, err = githubRequest("GET", "user/repos?per_page=100&sort=updated&affiliation=owner,collaborator,organization_member")
	if err then return nil, err end
	local repos = {}
	for _, repo in ipairs(result) do
		table.insert(repos, repo.full_name)
	end
	return repos, nil
end

local function ensureRepoExists(repoName)
	local result, err = githubRequest("GET", "repos/" .. repoName)
	if result then return nil end
	print("[OBA] Repositorio no encontrado.")
	return err
end

-- Base64 encode
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

local function getScriptTypeHeader(script)
	if script:IsA("LocalScript") then
		return "-- @ScriptType: LocalScript\n"
	elseif script:IsA("ModuleScript") then
		return "-- @ScriptType: ModuleScript\n"
	else
		return "-- @ScriptType: Script\n"
	end
end

local function getScriptPath(script, folderName)
	local parts = { script.Name .. ".lua" }
	local current = script.Parent
	while current and current ~= game do
		table.insert(parts, 1, current.Name)
		current = current.Parent
	end
	table.insert(parts, 1, folderName)
	return table.concat(parts, "/")
end

local SERVICES_TO_EXPORT = {
	"ServerScriptService", "ReplicatedStorage", "StarterGui",
	"StarterPlayer", "ReplicatedFirst", "ServerStorage",
}

local function collectScripts(folderName)
	local scripts = {}
	for _, serviceName in ipairs(SERVICES_TO_EXPORT) do
		local service = game:FindFirstChild(serviceName)
		if service then
			for _, desc in ipairs(service:GetDescendants()) do
				if desc:IsA("Script") or desc:IsA("LocalScript") or desc:IsA("ModuleScript") then
					local path    = getScriptPath(desc, folderName)
					local source = desc.Source or ""
					source = string.gsub(source, "ghp_[%w]+", "REDACTED_GITHUB_TOKEN")
					local content = getScriptTypeHeader(desc) .. source
					table.insert(scripts, {path = path, content = content})
				end
			end
		end
	end
	return scripts
end

local function getBaseSHA(repoName)
	local result, err = githubRequest("GET", "repos/" .. repoName .. "/git/ref/heads/" .. BASE_BRANCH)
	if err then
		if string.find(err, "409") then
			return nil, "EMPTY_REPO"
		end
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
		content  = base64Encode(content),
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
			sha  = blobSHA,
		})
	end
	local result, err = githubRequest("POST", "repos/" .. repoName .. "/git/trees", {
		base_tree = baseTreeSHA,
		tree      = treeItems,
	})
	if err then return nil, err end
	return result.sha, nil
end

local function createCommit(repoName, message, treeSHA, parentSHA)
	local result, err = githubRequest("POST", "repos/" .. repoName .. "/git/commits", {
		message = message,
		tree    = treeSHA,
		parents = parentSHA and { parentSHA } or {},
		author  = {
			name  = GITHUB_USER,
			email = GITHUB_USER .. "@users.noreply.github.com",
		},
	})
	if err then return nil, err end
	return result.sha, nil
end

local function createInitialFile(repoName)
	local _, err = githubRequest("PUT", "repos/" .. repoName .. "/contents/README.md", {
		message = "Initial commit",
		content = base64Encode("# " .. repoName .. "\n\nInicializado por plugin."),
		branch  = BASE_BRANCH,
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
		body  = body,
		head  = branchName,
		base  = BASE_BRANCH,
	})
	if err then return nil, err end
	return result.html_url, nil
end

-- ─── Main push flow ──────────────────────────────────────────────────────────
local function doPush(commitMessage, repoName, folderName)
	local placeName  = game.Name
	local timestamp  = os.date("%Y%m%d-%H%M%S")
	local branchName = "studio/" .. folderName .. "-" .. timestamp

	print("[OBA Git] Recopilando scripts de /" .. folderName .. "...")
	local scripts = collectScripts(folderName)
	print("[OBA Git] " .. #scripts .. " scripts encontrados.")

	local repoErr = ensureRepoExists(repoName)
	if repoErr then warn("[OBA Git] ERROR: " .. repoErr) return end

	print("[OBA Git] Obteniendo SHA base...")
	local baseSHA, err = getBaseSHA(repoName)

	if err == "EMPTY_REPO" then
		warn("[OBA Git] Repo vacío detectado, inicializando con README...")
		local initErr = createInitialFile(repoName)
		if initErr then
			warn("[OBA Git] ERROR inicializando repo: " .. initErr)
			return
		end
		baseSHA, err = getBaseSHA(repoName)
		if err then
			warn("[OBA Git] ERROR tras init: " .. err)
			return
		end
	elseif err then
		warn("[OBA Git] ERROR: " .. err)
		return
	end

	local baseTreeSHA, err2 = getBaseTreeSHA(repoName, baseSHA)
	if err2 then warn("[OBA Git] ERROR: " .. err2) return end

	print("[OBA Git] Creando blobs y árbol...")
	local newTreeSHA, err3 = createTree(repoName, baseTreeSHA, scripts)
	if err3 then warn("[OBA Git] ERROR: " .. err3) return end

	print("[OBA Git] Creando commit...")
	local fullMessage = commitMessage .. "\n\nPlace: " .. placeName .. " → /" .. folderName .. "\nScripts exportados: " .. #scripts
	local newCommitSHA, err4 = createCommit(repoName, fullMessage, newTreeSHA, baseSHA)
	if err4 then warn("[OBA Git] ERROR: " .. err4) return end

	print("[OBA Git] Creando branch: " .. branchName)
	local err5 = createBranch(repoName, branchName, newCommitSHA)
	if err5 then warn("[OBA Git] ERROR creando branch: " .. err5) return end

	print("[OBA Git] Abriendo Pull Request...")
	local prTitle = "[" .. folderName .. "] " .. commitMessage
	local prBody  = "**Place:** " .. placeName .. "\n**Carpeta:** `/" .. folderName .. "`\n**Scripts exportados:** " .. #scripts .. "\n\n*Generado automáticamente por OBA GitHub Push Plugin*"
	local prURL, err6 = createPR(repoName, prTitle, prBody, branchName)
	if err6 then warn("[OBA Git] ERROR creando PR: " .. err6) return end

	print("[OBA Git] ✅ PR abierto: " .. prURL)
	return prURL
end

-- ─── UI Dialog ───────────────────────────────────────────────────────────────
local widget = nil

local function openDialog()
	if widget then
		widget.Enabled = not widget.Enabled
		return
	end

	local widgetInfo = DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Float,
		true, false, 400, 280, 300, 200
	)
	widget = plugin:CreateDockWidgetPluginGui("OBAGitPush", widgetInfo)
	widget.Title = "OBA — Push a GitHub"

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BorderSizePixel = 0
	frame.Parent = widget

	local padding = Instance.new("UIPadding")
	padding.PaddingTop    = UDim.new(0, 16)
	padding.PaddingBottom = UDim.new(0, 16)
	padding.PaddingLeft   = UDim.new(0, 16)
	padding.PaddingRight  = UDim.new(0, 16)
	padding.Parent = frame

	-- Commit label & input
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 20)
	label.Position = UDim2.new(0, 0, 0, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = "Mensaje de commit:"
	label.Parent = frame

	local input = Instance.new("TextBox")
	input.Size = UDim2.new(1, 0, 0, 36)
	input.Position = UDim2.new(0, 0, 0, 26)
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
	local inputCorner = Instance.new("UICorner")
	inputCorner.CornerRadius = UDim.new(0, 4)
	inputCorner.Parent = input
	local inputPad = Instance.new("UIPadding")
	inputPad.PaddingLeft = UDim.new(0, 8)
	inputPad.Parent = input

	-- Lista de repositorios
	local listFrame = Instance.new("ScrollingFrame")
	listFrame.Size = UDim2.new(1, 0, 0, 200)
	listFrame.Position = UDim2.new(0, 0, 0, 72)
	listFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
	listFrame.BorderSizePixel = 0
	listFrame.ScrollBarThickness = 5
	listFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
	listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	listFrame.Parent = frame
	local listCorner = Instance.new("UICorner")
	listCorner.CornerRadius = UDim.new(0, 6)
	listCorner.Parent = listFrame
	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 2)
	listLayout.Parent = listFrame
	local listPad = Instance.new("UIPadding")
	listPad.PaddingTop    = UDim.new(0, 4)
	listPad.PaddingBottom = UDim.new(0, 4)
	listPad.PaddingLeft   = UDim.new(0, 4)
	listPad.PaddingRight  = UDim.new(0, 4)
	listPad.Parent = listFrame

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Size = UDim2.new(1, 0, 0, 20)
	statusLabel.Position = UDim2.new(0, 0, 1, -56)
	statusLabel.BackgroundTransparency = 1
	statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.TextSize = 12
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.Text = "Cargando repositorios..."
	statusLabel.Parent = frame

	-- Botón push
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 36)
	btn.Position = UDim2.new(0, 0, 1, -36)
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btn.TextColor3 = Color3.fromRGB(180, 180, 180)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.Text = "📤  Commit & Push PR"
	btn.BorderSizePixel = 0
	btn.Active = false
	btn.Parent = frame
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = btn

	local selectedRepo = nil
	local repoButtons  = {}

	local function selectRepo(repoName, clickedBtn)
		selectedRepo = repoName
		for _, rb in ipairs(repoButtons) do
			rb.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			rb.TextColor3 = Color3.fromRGB(200, 200, 200)
		end
		clickedBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 160)
		clickedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.BackgroundColor3 = Color3.fromRGB(0, 120, 80)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Active = true
		statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
		statusLabel.Text = "Seleccionado: " .. repoName
	end

	task.spawn(function()
		local repos, err = fetchUserRepos()
		if err then
			statusLabel.TextColor3 = Color3.fromRGB(220, 80, 80)
			statusLabel.Text = "❌ Error: " .. err
			return
		end
		if #repos == 0 then
			statusLabel.TextColor3 = Color3.fromRGB(220, 80, 80)
			statusLabel.Text = "No se encontraron repositorios"
			return
		end
		statusLabel.Text = "Elige un repositorio:"
		for i, repoName in ipairs(repos) do
			local repoBtn = Instance.new("TextButton")
			repoBtn.Size = UDim2.new(1, 0, 0, 28)
			repoBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			repoBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
			repoBtn.Font = Enum.Font.Gotham
			repoBtn.TextSize = 12
			repoBtn.Text = "  " .. repoName
			repoBtn.TextXAlignment = Enum.TextXAlignment.Left
			repoBtn.BorderSizePixel = 0
			repoBtn.LayoutOrder = i
			repoBtn.Parent = listFrame
			local repoBtnCorner = Instance.new("UICorner")
			repoBtnCorner.CornerRadius = UDim.new(0, 4)
			repoBtnCorner.Parent = repoBtn
			table.insert(repoButtons, repoBtn)
			repoBtn.MouseButton1Click:Connect(function()
				selectRepo(repoName, repoBtn)
			end)
		end
	end)

	-- ─── Botón push
	btn.MouseButton1Click:Connect(function()
		local commitMsg = input.Text

		if commitMsg == "" then
			statusLabel.TextColor3 = Color3.fromRGB(220, 80, 80)
			statusLabel.Text = "⚠ Escribe un mensaje de commit."
			return
		end

		if not selectedRepo then
			statusLabel.TextColor3 = Color3.fromRGB(220, 80, 80)
			statusLabel.Text = "⚠ Selecciona un repositorio primero."
			return
		end

		btn.Active = false
		btn.Text = "⏳ Procesando..."
		statusLabel.TextColor3 = Color3.fromRGB(150,150,150)

		task.spawn(function()
			local prURL = doPush(commitMsg, selectedRepo, "src")

			task.wait(0.1)
			if prURL then
				statusLabel.TextColor3 = Color3.fromRGB(80,200,120)
				statusLabel.Text = "✅ PR abierto: "..prURL
				btn.Text = "✅ ¡Listo!"
			else
				statusLabel.TextColor3 = Color3.fromRGB(220,80,80)
				statusLabel.Text = "❌ Error al subir scripts (revisa la salida)"
				btn.Text = "📤 Commit & Push PR"
			end
			btn.Active = true
		end)
	end)
end

btnCommit.Click:Connect(openDialog)