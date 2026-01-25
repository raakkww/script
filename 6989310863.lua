local Player = game:GetService("Players").LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Character
local Humanoid
local connections = {} -- para guardar todos os Connects

-- Armazena o tema atual (começa com o tema Discord)
local currentTheme = "Discord"

-- Tabela de Configuração dos Temas
local THEMES = {
	-- Tema Original: Estilo Dark/Discord
	Discord = {
		FrameBG = Color3.fromRGB(54, 57, 63),
		TextPrimary = Color3.fromRGB(255, 255, 255),
		TextSecondary = Color3.fromRGB(180, 180, 180),
		ButtonTP = Color3.fromRGB(88, 101, 242), -- Azul
		ButtonRefresh = Color3.fromRGB(67, 181, 129), -- Verde
		ButtonClose = Color3.fromRGB(237, 66, 69), -- Vermelho
		ButtonTheme = Color3.fromRGB(250, 166, 26), -- Laranja/Amarelo
		WarningBG_Wild = Color3.fromRGB(67, 181, 129), -- Verde para selvagem
		WarningBG_Other = Color3.fromRGB(255, 69, 0), -- Laranja/Vermelho para não selvagem
		WarningText = Color3.fromRGB(255, 255, 255), -- Branco
		CornerRadius = UDim.new(0, 8),
		ButtonCorner = UDim.new(0, 6),
		StrokeColor = Color3.fromRGB(40, 42, 46), -- Borda sutil
		StrokeThickness = 1,
		StrokeTransparency = 0
	},
	-- NOVO TEMA: Estilo Oeste (Western) com ripas/painéis (cores e stroke)
	Western = {
		FrameBG = Color3.fromRGB(206, 160, 109), -- Tonalidade do Marrom Claro (fundo esquerdo)

		-- Cores de Texto (Alteradas para Branco Puro)
		TextPrimary = Color3.fromRGB(255, 255, 255), -- Branco Puro para Títulos/Status
		TextSecondary = Color3.fromRGB(255, 255, 255),-- Branco Puro para Rótulos

		-- Cores de Botão e Borda, baseadas no Marrom Escuro (formas arredondadas direitas)
		ButtonTP = Color3.fromRGB(143, 109, 74), -- Marrom Escuro (para contraste)
		ButtonRefresh = Color3.fromRGB(143, 109, 74), -- Marrom Escuro
		ButtonClose = Color3.fromRGB(255, 0, 0), -- Vermelho para fechar, para destaque
		ButtonTheme = Color3.fromRGB(143, 109, 74), -- Marrom Escuro
		WarningBG_Wild = Color3.fromRGB(50, 150, 50), -- Verde Escuro
		WarningBG_Other = Color3.fromRGB(165, 42, 42), -- Marrom Escuro Avermelhado
		WarningText = Color3.fromRGB(255, 255, 255), -- Branco

		CornerRadius = UDim.new(0, 15),
		ButtonCorner = UDim.new(0, 10),

		StrokeColor = Color3.fromRGB(155, 119, 81), -- Marrom Mais Escuro para Borda/Stroke
		StrokeThickness = 1,
		StrokeTransparency = 0
	}
}

-- Função helper para conectar eventos e salvar para cleanup
local function safeConnect(signal, func)
	local conn = signal:Connect(func)
	table.insert(connections, conn)
	return conn
end

-- Atualiza Character no spawn
local function setupCharacter(char)
	Character = char
	Humanoid = char:WaitForChild("Humanoid")
end

setupCharacter(Player.Character or Player.CharacterAdded:Wait())
safeConnect(Player.CharacterAdded, setupCharacter)

-- GUI
local GUI = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local IslandLabel = Instance.new("TextLabel")
local StatusLabel = Instance.new("TextLabel")
local WarningLabel = Instance.new("TextLabel") -- Label de Aviso
local TeleportButton = Instance.new("TextButton")
local RefreshButton = Instance.new("TextButton")
local ThemeButton = Instance.new("TextButton")
local CloseButton = Instance.new("TextButton")

-- UICorners
local FrameCorner = Instance.new("UICorner")
local TeleportCorner = Instance.new("UICorner")
local RefreshCorner = Instance.new("UICorner")
local ThemeCorner = Instance.new("UICorner")
local CloseCorner = Instance.new("UICorner")
local WarningCorner = Instance.new("UICorner") -- Corner para o Aviso

-- UIStrokes (Para simular as bordas das ripas/painéis)
local FrameStroke = Instance.new("UIStroke")
local TeleportStroke = Instance.new("UIStroke")
local RefreshStroke = Instance.new("UIStroke")
local ThemeStroke = Instance.new("UIStroke")
local CloseStroke = Instance.new("UIStroke")
local WarningStroke = Instance.new("UIStroke") -- Stroke para o Aviso

-- Parent dos Corners
FrameCorner.Parent = Frame
TeleportCorner.Parent = TeleportButton
RefreshCorner.Parent = RefreshButton
ThemeCorner.Parent = ThemeButton
CloseCorner.Parent = CloseButton
WarningCorner.Parent = WarningLabel

-- Parent dos Strokes
FrameStroke.Parent = Frame
TeleportStroke.Parent = TeleportButton
RefreshStroke.Parent = RefreshButton
ThemeStroke.Parent = ThemeButton
CloseStroke.Parent = CloseButton
WarningStroke.Parent = WarningLabel

GUI.Name = "TeleportGUI"
GUI.Parent = Player:WaitForChild("PlayerGui")
GUI.ResetOnSpawn = false

-- Frame Base
Frame.Name = "TPFrame"
Frame.Size = UDim2.new(0, 320, 0, 240)
Frame.Position = UDim2.new(0.5, -160, 0.5, -120)
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.BorderSizePixel = 0
Frame.Parent = GUI

-- Título
TitleLabel.Size = UDim2.new(1, -40, 0, 30)
TitleLabel.Position = UDim2.new(0, 10, 0, 5)
TitleLabel.Text = "TP Horse"
TitleLabel.Font = Enum.Font.SourceSansSemibold
TitleLabel.TextSize = 20
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Frame

-- Rótulo da Ilha
IslandLabel.Name = "IslandLabel"
IslandLabel.Size = UDim2.new(1, -40, 0, 20)
IslandLabel.Position = UDim2.new(0, 10, 0, 35)
IslandLabel.Text = "Island: Searching..."
IslandLabel.Font = Enum.Font.SourceSans
IslandLabel.TextSize = 14
IslandLabel.BackgroundTransparency = 1
IslandLabel.TextXAlignment = Enum.TextXAlignment.Left
IslandLabel.Parent = Frame

-- Botão de fechar (X)
CloseButton.Size = UDim2.new(0, 28, 0, 28)
CloseButton.Position = UDim2.new(1, -35, 0, 6)
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 18
CloseButton.AutoButtonColor = false
CloseButton.Parent = Frame

-- Status (Informação do Cavalo)
StatusLabel.Size = UDim2.new(1, -20, 0.3, 0)
StatusLabel.Position = UDim2.new(0, 10, 0.25, 0)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 16
StatusLabel.TextWrapped = true
StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
StatusLabel.BackgroundTransparency = 1
StatusLabel.Parent = Frame

-- Warning (Aviso de Cavalo Selvagem/Não Selvagem)
WarningLabel.Name = "WarningLabel"
WarningLabel.Size = UDim2.new(1, -20, 0, 30)
WarningLabel.Position = UDim2.new(0, 10, 0.55, 0)
WarningLabel.Text = "..."
WarningLabel.Font = Enum.Font.SourceSansSemibold
WarningLabel.TextSize = 16
WarningLabel.TextColor3 = THEMES.Discord.WarningText
WarningLabel.BackgroundColor3 = THEMES.Discord.WarningBG_Other -- Inicia com cor 'Não Selvagem' por padrão
WarningLabel.BorderSizePixel = 0
WarningLabel.Visible = false -- Começa invisível
WarningLabel.Parent = Frame
WarningCorner.CornerRadius = UDim.new(0, 5)

-- Botões 
TeleportButton.Size = UDim2.new(0, 93, 0, 40)
TeleportButton.Position = UDim2.new(0, 10, 0.78, 0)
TeleportButton.Text = "TP"
TeleportButton.Font = Enum.Font.SourceSansSemibold
TeleportButton.TextSize = 18
TeleportButton.AutoButtonColor = false
TeleportButton.Parent = Frame

RefreshButton.Size = UDim2.new(0, 93, 0, 40)
RefreshButton.Position = UDim2.new(0, 114, 0.78, 0)
RefreshButton.Text = "Search"
RefreshButton.Font = Enum.Font.SourceSansSemibold
RefreshButton.TextSize = 18
RefreshButton.AutoButtonColor = false
RefreshButton.Parent = Frame

ThemeButton.Size = UDim2.new(0, 93, 0, 40)
ThemeButton.Position = UDim2.new(1, -103, 0.78, 0)
ThemeButton.Text = "Theme"
ThemeButton.Font = Enum.Font.SourceSansSemibold
ThemeButton.TextSize = 18
ThemeButton.AutoButtonColor = false
ThemeButton.Parent = Frame

GUI.Enabled = false

-- Função para aplicar o estilo do tema
local function applyTheme(themeName)
	local theme = THEMES[themeName]
	if not theme then return end

	-- Frame Principal
	Frame.BackgroundColor3 = theme.FrameBG
	FrameCorner.CornerRadius = theme.CornerRadius
	FrameStroke.Color = theme.StrokeColor
	FrameStroke.Thickness = theme.StrokeThickness
	FrameStroke.Transparency = theme.StrokeTransparency

	-- Textos
	TitleLabel.TextColor3 = theme.TextPrimary
	StatusLabel.TextColor3 = theme.TextPrimary
	IslandLabel.TextColor3 = theme.TextSecondary

	-- Warning (Mantém a cor do texto, a cor de fundo é definida em checkCurrentModelStatus)
	WarningLabel.TextColor3 = theme.WarningText
	WarningStroke.Color = theme.StrokeColor
	WarningStroke.Thickness = theme.StrokeThickness
	WarningStroke.Transparency = theme.StrokeTransparency

	-- Botões
	TeleportButton.BackgroundColor3 = theme.ButtonTP
	RefreshButton.BackgroundColor3 = theme.ButtonRefresh
	CloseButton.BackgroundColor3 = theme.ButtonClose
	ThemeButton.BackgroundColor3 = theme.ButtonTheme

	TeleportButton.TextColor3 = theme.TextPrimary
	RefreshButton.TextColor3 = theme.TextPrimary
	ThemeButton.TextColor3 = theme.TextPrimary
	CloseButton.TextColor3 = theme.TextPrimary

	-- Corners dos Botões
	local bCorner = theme.ButtonCorner
	TeleportCorner.CornerRadius = bCorner
	RefreshCorner.CornerRadius = bCorner
	ThemeCorner.CornerRadius = bCorner
	CloseCorner.CornerRadius = bCorner

	-- Strokes dos Botões
	local bStrokeColor = theme.StrokeColor
	local bStrokeThickness = theme.StrokeThickness
	local bStrokeTransparency = theme.StrokeTransparency
	TeleportStroke.Color = bStrokeColor
	TeleportStroke.Thickness = bStrokeThickness
	TeleportStroke.Transparency = bStrokeTransparency
	RefreshStroke.Color = bStrokeColor
	RefreshStroke.Thickness = bStrokeThickness
	RefreshStroke.Transparency = bStrokeTransparency
	ThemeStroke.Color = bStrokeColor
	ThemeStroke.Thickness = bStrokeThickness
	ThemeStroke.Transparency = bStrokeTransparency
	CloseStroke.Color = bStrokeColor
	CloseStroke.Thickness = bStrokeThickness
	CloseStroke.Transparency = bStrokeTransparency

	currentTheme = themeName
end

-- Teleport logic
local validModels = {}
local currentModelIndex = 1

local function findValidModels()
	local islandsFolder = workspace:FindFirstChild("Islands")
	if not islandsFolder then
		warn("'Islands' folder not found in Workspace")
		return {}, "Error: Islands Missing"
	end

	-- Remove highlights antigos
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Highlight") and obj.Name == "TeleportHighlight" then
			obj:Destroy()
		end
	end

	-- Lógica para encontrar a ilha do jogador
	local playerIslandFolder = Character and Character.Parent
	local islandContainer = nil

	while playerIslandFolder and playerIslandFolder ~= islandsFolder and playerIslandFolder ~= workspace do
		if playerIslandFolder.Parent == islandsFolder then
			islandContainer = playerIslandFolder
			break
		end
		playerIslandFolder = playerIslandFolder.Parent
	end

	if not islandContainer then
		warn("Unidentified player island within the 'Islands' folder.")
		return {}, "Error: Not on the Island"
	end

	local islandName = islandContainer.Name
	local wildHorses = {} -- Cavalos com CaptureProgress 
	local otherHorses = {} -- Outros cavalos

	-- Pega as cores do tema ATUAL para o Highlight
	local currentThemeColors = THEMES[currentTheme]

	for _, descendant in ipairs(islandContainer:GetDescendants()) do
		if descendant:IsA("Model")
			and descendant:FindFirstChildOfClass("Humanoid")
			and descendant:FindFirstChild("HumanoidRootPart")
			and descendant.Name:match("^%b{}$") then

			local rootPart = descendant:FindFirstChild("HumanoidRootPart")
			-- Verifica se existe o objeto "CaptureProgress" (independentemente do seu tipo)
			local hasCaptureProgress = false
			-- Percorre TODOS os filhos, netos, bisnetos, etc., do modelo
			for _, element in ipairs(descendant:GetDescendants()) do
				if element.Name == "CaptureProgress" then
					hasCaptureProgress = true
					break -- Sai do loop assim que encontrar o primeiro
				end
			end

			local highlight = Instance.new("Highlight")
			highlight.Name = "TeleportHighlight"

			-- Usa as cores do tema ATUAL para o Highlight
			highlight.FillColor = hasCaptureProgress and currentThemeColors.WarningBG_Wild or currentThemeColors.ButtonTP

			highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
			highlight.FillTransparency = 0.5
			highlight.OutlineTransparency = 0
			highlight.Adornee = descendant
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.Parent = descendant

			local horseData = {
				Model = descendant,
				RootPart = rootPart,
				-- Define o estado inicial se é selvagem
				IsWild = hasCaptureProgress
			}

			if horseData.IsWild then
				table.insert(wildHorses, horseData)
			else
				table.insert(otherHorses, horseData)
			end
		end
	end

	-- Ordena as listas por nome
	table.sort(wildHorses, function(a, b)
		return a.Model.Name < b.Model.Name
	end)
	table.sort(otherHorses, function(a, b)
		return a.Model.Name < b.Model.Name
	end)

	-- Concatena as listas, priorizando os cavalos selvagens (wildHorses)
	local allHorses = {}
	for _, horse in ipairs(wildHorses) do
		table.insert(allHorses, horse)
	end
	for _, horse in ipairs(otherHorses) do
		table.insert(allHorses, horse)
	end

	return allHorses, islandName
end

-- **NOVA FUNÇÃO:** Checa o status do cavalo atualmente selecionado em tempo real
local function checkCurrentModelStatus()
	-- Sai se a GUI não estiver ativa, se não houver modelos, ou se o índice for inválido
	if GUI.Enabled == false or #validModels == 0 or currentModelIndex > #validModels then
		WarningLabel.Visible = false
		return
	end

	local theme = THEMES[currentTheme]
	local modelInfo = validModels[currentModelIndex]
	local currentModel = modelInfo.Model

	-- 1. Verifica no modelo selecionado se o objeto "CaptureProgress" existe
	local isWildNow = false
	-- Percorre TODOS os filhos, netos, bisnetos, etc., do modelo
	for _, element in ipairs(currentModel:GetDescendants()) do
		if element.Name == "CaptureProgress" then
			isWildNow = true
			break
		end
	end

	-- 2. Atualiza o objeto 'modelInfo' na lista para refletir o estado atual
	modelInfo.IsWild = isWildNow

	-- 3. Atualiza o Warning Label na GUI
	if isWildNow then
		WarningLabel.Text = "It's a WILD HORSE (LIVE)"
		WarningLabel.BackgroundColor3 = theme.WarningBG_Wild
		WarningLabel.Visible = true
	else
		WarningLabel.Text = "IT'S NOT A WILD HORSE (LIVE)"
		WarningLabel.BackgroundColor3 = theme.WarningBG_Other
		WarningLabel.Visible = true
	end
end


-- Atualiza o Status Label (posição e nome) e chama o check em tempo real
local function updateGUIStatus()
	if #validModels == 0 then
		StatusLabel.Text = "No horses found with names between { }"
		WarningLabel.Visible = false
		return
	end

	local modelInfo = validModels[currentModelIndex]
	local pos = modelInfo.RootPart.Position

	StatusLabel.Text = string.format("Horse %d of %d:\n%s\nPosition: %.1f, %.1f, %.1f",
		currentModelIndex,
		#validModels,
		modelInfo.Model.Name,
		pos.X, pos.Y, pos.Z)

	-- Chama a checagem em tempo real para garantir que o Warning Label seja atualizado
	-- imediatamente após um TP/Busca.
	checkCurrentModelStatus() 
end

-- Função para trocar o tema
local function toggleTheme()
	if currentTheme == "Discord" then
		applyTheme("Western")
	else
		applyTheme("Discord")
	end
	-- Re-aplica o status para garantir que o WarningLabel tenha as cores atualizadas do tema
	checkCurrentModelStatus() -- Usa o check em tempo real para as cores
end

local function teleportToNextModel()
	if GUI.Enabled == false or #validModels == 0 then return end

	currentModelIndex += 1
	if currentModelIndex > #validModels then
		currentModelIndex = 1
	end

	local target = validModels[currentModelIndex]
	if target and target.Model and target.RootPart and Character then
		-- Teleporta para o cavalo
		Character:PivotTo(CFrame.new(target.RootPart.Position + Vector3.new(0, 3, 0)))
		updateGUIStatus() -- Atualiza status após o teleporte, o que chama checkCurrentModelStatus
	end
end

local function refreshHorseList()
	local islandName
	if GUI.Enabled == false then return end

	validModels, islandName = findValidModels()
	currentModelIndex = 1

	if islandName and islandName:sub(1, 4) == "Erro" then
		IslandLabel.Text = "Island: Identification failure"
	else
		IslandLabel.Text = "Island: " .. (islandName or "Unknown")
	end

	updateGUIStatus() -- Atualiza status após a busca, o que chama checkCurrentModelStatus
end

-- **CORREÇÃO DE FECHAMENTO/CLEANUP**
local function cleanup()
	-- 1. Desativa a GUI imediatamente para parar a interação (ex: binds de teclado e arrastar)
	if GUI then
		GUI.Enabled = false
	end

	-- 2. Desconecta todos os eventos (o coração do cleanup)
	for _, conn in pairs(connections) do
		if conn:IsConnected() then
			conn:Disconnect()
		end
	end
	connections = {}

	-- 3. Remove os Highlights
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Highlight") and obj.Name == "TeleportHighlight" then
			obj:Destroy()
		end
	end

	-- 4. Destrói o ScreenGui
	if GUI then
		GUI:Destroy()
	end
end

-- Conecta botões
safeConnect(TeleportButton.MouseButton1Click, teleportToNextModel)
safeConnect(RefreshButton.MouseButton1Click, refreshHorseList)
safeConnect(ThemeButton.MouseButton1Click, toggleTheme)
safeConnect(CloseButton.MouseButton1Click, cleanup) -- Conecta a função de cleanup aprimorada

-- Teclado
safeConnect(UIS.InputBegan, function(input, gameProcessed)
	if gameProcessed or GUI.Enabled == false then return end -- Verifica se a GUI está ativa

	if input.KeyCode == Enum.KeyCode.Z then
		teleportToNextModel()
	elseif input.KeyCode == Enum.KeyCode.X then
		refreshHorseList()
	elseif input.KeyCode == Enum.KeyCode.C then
		toggleTheme()
	end
end)

-- Arrastar GUI (mantido o mesmo)
local dragInput, mousePos, framePos

safeConnect(Frame.InputBegan, function(input)
	if GUI.Enabled == false then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragInput = input
		mousePos = UIS:GetMouseLocation()
		framePos = Frame.Position

		safeConnect(input.Changed, function()
			if dragInput and dragInput.UserInputState == Enum.UserInputState.End then
				dragInput = nil
			end
		end)
	end
end)

safeConnect(RunService.Heartbeat, function()
	if dragInput and GUI.Enabled then
		local delta = UIS:GetMouseLocation() - mousePos
		Frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
	end
end)

-- **LOOP DE VERIFICAÇÃO CONTÍNUA**
-- Conecta a função de checagem ao Heartbeat (executa a cada frame)
safeConnect(RunService.Heartbeat, checkCurrentModelStatus)

-- Garante que o Character esteja carregado antes de qualquer coisa
if not Character then
	Player.CharacterAdded:Wait()
	Character = Player.Character
end

-- Inicializa
applyTheme(currentTheme)
refreshHorseList()
GUI.Enabled = true -- Ativa a GUI após a inicialização
