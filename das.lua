local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "GlassPanel"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local GLASS_BG      = Color3.fromRGB(12, 12, 20)
local GLASS_SURFACE = Color3.fromRGB(24, 24, 38)
local GLASS_BORDER  = Color3.fromRGB(255, 255, 255)
local ACCENT        = Color3.fromRGB(120, 90, 255)
local ACCENT2       = Color3.fromRGB(70, 180, 255)
local TEXT_PRIMARY  = Color3.fromRGB(235, 235, 245)
local TEXT_MUTED    = Color3.fromRGB(140, 140, 165)
local SUCCESS       = Color3.fromRGB(50, 200, 120)
local DANGER        = Color3.fromRGB(220, 70, 80)

-------------------------------------------------------
-- KEYBIND SYSTEM
-------------------------------------------------------
local binds = {
    killaura    = Enum.KeyCode.Unknown,
    infjump     = Enum.KeyCode.Unknown,
    thirdperson = Enum.KeyCode.Unknown,
    fly         = Enum.KeyCode.Unknown,
    gui         = Enum.KeyCode.K,
}
local bindListening = nil

-- Overlay GUI for bind listening
local bindOverlay = Instance.new("Frame", gui)
bindOverlay.Size = UDim2.new(1, 0, 1, 0)
bindOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bindOverlay.BackgroundTransparency = 0.45
bindOverlay.BorderSizePixel = 0
bindOverlay.ZIndex = 200
bindOverlay.Visible = false

local bindOverlayCard = Instance.new("Frame", bindOverlay)
bindOverlayCard.Size = UDim2.new(0, 320, 0, 120)
bindOverlayCard.Position = UDim2.new(0.5, -160, 0.5, -60)
bindOverlayCard.BackgroundColor3 = GLASS_SURFACE
bindOverlayCard.BackgroundTransparency = 0.08
bindOverlayCard.BorderSizePixel = 0
bindOverlayCard.ZIndex = 201
Instance.new("UICorner", bindOverlayCard).CornerRadius = UDim.new(0, 16)
local bindCardStroke = Instance.new("UIStroke", bindOverlayCard)
bindCardStroke.Color = ACCENT2
bindCardStroke.Thickness = 1.5
bindCardStroke.Transparency = 0.3

local bindOverlayTitle = Instance.new("TextLabel", bindOverlayCard)
bindOverlayTitle.Size = UDim2.new(1, 0, 0, 36)
bindOverlayTitle.Position = UDim2.new(0, 0, 0, 14)
bindOverlayTitle.BackgroundTransparency = 1
bindOverlayTitle.Text = "Naciśnij klawisz..."
bindOverlayTitle.TextColor3 = TEXT_PRIMARY
bindOverlayTitle.Font = Enum.Font.GothamBold
bindOverlayTitle.TextSize = 17
bindOverlayTitle.ZIndex = 202

local bindOverlaySub = Instance.new("TextLabel", bindOverlayCard)
bindOverlaySub.Size = UDim2.new(1, 0, 0, 22)
bindOverlaySub.Position = UDim2.new(0, 0, 0, 52)
bindOverlaySub.BackgroundTransparency = 1
bindOverlaySub.Text = ""
bindOverlaySub.TextColor3 = ACCENT2
bindOverlaySub.Font = Enum.Font.GothamMedium
bindOverlaySub.TextSize = 13
bindOverlaySub.ZIndex = 202

local bindOverlayEsc = Instance.new("TextLabel", bindOverlayCard)
bindOverlayEsc.Size = UDim2.new(1, 0, 0, 18)
bindOverlayEsc.Position = UDim2.new(0, 0, 0, 92)
bindOverlayEsc.BackgroundTransparency = 1
bindOverlayEsc.Text = "[Escape] — anuluj"
bindOverlayEsc.TextColor3 = TEXT_MUTED
bindOverlayEsc.Font = Enum.Font.GothamMedium
bindOverlayEsc.TextSize = 11
bindOverlayEsc.ZIndex = 202

local bindKeyLabels = {} -- [bindKey] = TextLabel reference, updated on bind

local function startListening(bindKey, friendlyName, keyLbl)
    bindListening = { key = bindKey, lbl = keyLbl }
    bindOverlaySub.Text = "Dla: " .. friendlyName
    bindOverlay.Visible = true
end

-------------------------------------------------------
-- NOTIFICATIONS
-------------------------------------------------------
local notifFrame = Instance.new("Frame", gui)
notifFrame.AnchorPoint = Vector2.new(1, 1)
notifFrame.Position = UDim2.new(1, -18, 1, -18)
notifFrame.Size = UDim2.new(0, 260, 0, 400)
notifFrame.BackgroundTransparency = 1
notifFrame.ZIndex = 100

local notifLayout = Instance.new("UIListLayout", notifFrame)
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifLayout.Padding = UDim.new(0, 8)

local function notify(text, kind)
    kind = kind or "info"
    local col = kind == "success" and SUCCESS or kind == "danger" and DANGER or ACCENT2
    local snd = Instance.new("Sound", workspace)
    snd.SoundId = "rbxassetid://4590662766"
    snd.Volume = 0.5; snd.RollOffMaxDistance = 0; snd:Play()
    game:GetService("Debris"):AddItem(snd, 3)
    local card = Instance.new("Frame", notifFrame)
    card.Size = UDim2.new(1, 0, 0, 50)
    card.BackgroundColor3 = GLASS_SURFACE; card.BackgroundTransparency = 0.1
    card.BorderSizePixel = 0; card.ClipsDescendants = false; card.ZIndex = 100
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)
    local bar = Instance.new("Frame", card)
    bar.Size = UDim2.new(0, 3, 1, 0); bar.BackgroundColor3 = col
    bar.BorderSizePixel = 0; bar.ZIndex = 101
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)
    local bottomLine = Instance.new("Frame", card)
    bottomLine.Size = UDim2.new(0, 0, 0, 2); bottomLine.Position = UDim2.new(0, 0, 1, -2)
    bottomLine.BackgroundColor3 = col; bottomLine.BackgroundTransparency = 0.4
    bottomLine.BorderSizePixel = 0; bottomLine.ZIndex = 102
    Instance.new("UICorner", bottomLine).CornerRadius = UDim.new(0, 2)
    local lbl = Instance.new("TextLabel", card)
    lbl.Size = UDim2.new(1, -20, 1, 0); lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextColor3 = TEXT_PRIMARY
    lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextWrapped = true; lbl.ZIndex = 101
    card.Position = UDim2.new(-1, -10, 0, 0)
    TweenService:Create(card, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    TweenService:Create(bottomLine, TweenInfo.new(3, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, 0, 2)}):Play()
    task.delay(3, function()
        local snd2 = Instance.new("Sound", workspace)
        snd2.SoundId = "rbxassetid://4590657391"; snd2.Volume = 0.3; snd2.RollOffMaxDistance = 0; snd2:Play()
        game:GetService("Debris"):AddItem(snd2, 2)
        local t = TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2.new(1, 20, 0, 0)})
        t:Play(); t.Completed:Connect(function() card:Destroy() end)
    end)
end

-------------------------------------------------------
-- MAIN WINDOW
-------------------------------------------------------
local W, H = 440, 480
local main = Instance.new("Frame", gui)
main.Name = "GlassWindow"; main.Size = UDim2.new(0, W, 0, H)
main.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
main.BackgroundColor3 = GLASS_BG; main.BackgroundTransparency = 0.08
main.BorderSizePixel = 0; main.ClipsDescendants = true; main.ZIndex = 2
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 18)

local titlebar = Instance.new("Frame", main)
titlebar.Size = UDim2.new(1, 0, 0, 46); titlebar.BackgroundColor3 = GLASS_SURFACE
titlebar.BackgroundTransparency = 0.45; titlebar.BorderSizePixel = 0; titlebar.ZIndex = 3
Instance.new("UICorner", titlebar).CornerRadius = UDim.new(0, 18)
local tbFill = Instance.new("Frame", titlebar)
tbFill.Size = UDim2.new(1, 0, 0.5, 0); tbFill.Position = UDim2.new(0, 0, 0.5, 0)
tbFill.BackgroundColor3 = GLASS_SURFACE; tbFill.BackgroundTransparency = 0.45; tbFill.BorderSizePixel = 0; tbFill.ZIndex = 2
local tbDivider = Instance.new("Frame", main)
tbDivider.Size = UDim2.new(1, 0, 0, 1); tbDivider.Position = UDim2.new(0, 0, 0, 46)
tbDivider.BackgroundColor3 = GLASS_BORDER; tbDivider.BackgroundTransparency = 0.82; tbDivider.BorderSizePixel = 0; tbDivider.ZIndex = 3
local function makeDot(x, col)
    local d = Instance.new("Frame", titlebar); d.Size = UDim2.new(0, 11, 0, 11)
    d.Position = UDim2.new(0, x, 0.5, -6); d.BackgroundColor3 = col; d.BorderSizePixel = 0; d.ZIndex = 5
    Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
end
makeDot(14, Color3.fromRGB(255,90,90)); makeDot(30, Color3.fromRGB(255,190,60)); makeDot(46, Color3.fromRGB(50,200,90))
local titleLbl = Instance.new("TextLabel", titlebar)
titleLbl.Size = UDim2.new(1,0,1,0); titleLbl.BackgroundTransparency = 1
titleLbl.Text = "Expander HUB"; titleLbl.TextColor3 = TEXT_PRIMARY
titleLbl.Font = Enum.Font.GothamBold; titleLbl.TextSize = 13; titleLbl.ZIndex = 5

local closeBtn = Instance.new("TextButton", main)
closeBtn.Size = UDim2.new(0,28,0,28); closeBtn.Position = UDim2.new(1,-40,0,9)
closeBtn.BackgroundColor3 = Color3.fromRGB(220,70,80); closeBtn.BackgroundTransparency = 0.5
closeBtn.Text = "✕"; closeBtn.TextColor3 = TEXT_PRIMARY; closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 13; closeBtn.BorderSizePixel = 0; closeBtn.AutoButtonColor = false; closeBtn.ZIndex = 10
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
closeBtn.MouseEnter:Connect(function() TweenService:Create(closeBtn,TweenInfo.new(0.12),{BackgroundTransparency=0.15}):Play() end)
closeBtn.MouseLeave:Connect(function() TweenService:Create(closeBtn,TweenInfo.new(0.12),{BackgroundTransparency=0.5}):Play() end)

local guiOpen = true
local function closeGui()
    if not guiOpen then return end; guiOpen = false
    TweenService:Create(main, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {BackgroundTransparency=1, Size=UDim2.new(0,W,0,0)}):Play()
    task.delay(0.36, function() main.Visible=false; main.Size=UDim2.new(0,W,0,H) end)
    local kname = binds.gui == Enum.KeyCode.Unknown and "—" or binds.gui.Name
    notify("GUI zamknięte  •  ["..kname.."] by otworzyć")
end
local function openGui()
    if guiOpen then return end; guiOpen = true
    main.Visible=true; main.BackgroundTransparency=1; main.Size=UDim2.new(0,W,0,0)
    main.Position=UDim2.new(0.5,-W/2,0.5,-H/2)
    TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency=0.08, Size=UDim2.new(0,W,0,H)}):Play()
end
closeBtn.MouseButton1Click:Connect(closeGui)

local dragging, dragStart, startPos
titlebar.InputBegan:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; dragStart=inp.Position; startPos=main.Position end
end)
UIS.InputChanged:Connect(function(inp)
    if dragging and inp.UserInputType==Enum.UserInputType.MouseMovement then
        local d=inp.Position-dragStart
        main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
end)
UIS.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)

-------------------------------------------------------
-- TAB BAR
-------------------------------------------------------
local tabBar = Instance.new("Frame", main)
tabBar.Size=UDim2.new(1,-32,0,34); tabBar.Position=UDim2.new(0,16,0,54)
tabBar.BackgroundColor3=GLASS_SURFACE; tabBar.BackgroundTransparency=0.5; tabBar.BorderSizePixel=0; tabBar.ZIndex=3
Instance.new("UICorner",tabBar).CornerRadius=UDim.new(0,10)
local tabStroke=Instance.new("UIStroke",tabBar); tabStroke.Color=GLASS_BORDER; tabStroke.Thickness=0.5; tabStroke.Transparency=0.78
local tabW=math.floor((W-32)/4)
local indicator=Instance.new("Frame",tabBar)
indicator.Size=UDim2.new(0,tabW-6,0,26); indicator.Position=UDim2.new(0,3,0,4)
indicator.BackgroundColor3=ACCENT; indicator.BackgroundTransparency=0.7; indicator.BorderSizePixel=0; indicator.ZIndex=3
Instance.new("UICorner",indicator).CornerRadius=UDim.new(0,7)
local indStroke=Instance.new("UIStroke",indicator); indStroke.Color=ACCENT; indStroke.Thickness=1; indStroke.Transparency=0.4

-------------------------------------------------------
-- CONTENT AREA + PAGES
-------------------------------------------------------
local content=Instance.new("Frame",main); content.Name="Content"
content.Size=UDim2.new(1,-32,1,-108); content.Position=UDim2.new(0,16,0,98)
content.BackgroundTransparency=1; content.ZIndex=2
local pages={}; local tabBtns={}
local TAB_NAMES={"ESP","MOVE","MISC","KILL"}
for i,name in ipairs(TAB_NAMES) do
    local page
    if name=="MISC" or name=="KILL" then
        page=Instance.new("ScrollingFrame",content); page.ScrollBarThickness=3
        page.ScrollBarImageColor3=ACCENT; page.CanvasSize=UDim2.new(0,0,0,540)
        page.ScrollingDirection=Enum.ScrollingDirection.Y; page.ElasticBehavior=Enum.ElasticBehavior.Never
    else page=Instance.new("Frame",content) end
    page.Name=name.."Page"; page.Size=UDim2.new(1,0,1,0); page.BackgroundTransparency=1; page.Visible=(i==1); page.ZIndex=2
    pages[name]=page
    local xPos=(i-1)*tabW
    local btn=Instance.new("TextButton",tabBar); btn.Name=name.."Tab"
    btn.Size=UDim2.new(0,tabW,1,0); btn.Position=UDim2.new(0,xPos,0,0); btn.BackgroundTransparency=1
    btn.Text=name; btn.TextColor3=(i==1) and TEXT_PRIMARY or TEXT_MUTED
    btn.Font=Enum.Font.GothamBold; btn.TextSize=12; btn.ZIndex=4
    tabBtns[name]=btn
    local iCopy=i
    btn.MouseButton1Click:Connect(function()
        local snd=Instance.new("Sound",workspace); snd.SoundId="rbxassetid://876939830"
        snd.Volume=0.25; snd.RollOffMaxDistance=0; snd:Play(); game:GetService("Debris"):AddItem(snd,2)
        for _,p in pairs(pages) do p.Visible=false end
        for _,b in pairs(tabBtns) do b.TextColor3=TEXT_MUTED end
        page.Visible=true; btn.TextColor3=TEXT_PRIMARY
        TweenService:Create(indicator, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position=UDim2.new(0,(iCopy-1)*tabW+3,0,4)}):Play()
    end)
end

-------------------------------------------------------
-- HELPERS
-------------------------------------------------------
local function glassCard(parent,y,h)
    local c=Instance.new("Frame",parent); c.Size=UDim2.new(1,0,0,h); c.Position=UDim2.new(0,0,0,y)
    c.BackgroundColor3=GLASS_SURFACE; c.BackgroundTransparency=0.5; c.BorderSizePixel=0; c.ZIndex=3
    Instance.new("UICorner",c).CornerRadius=UDim.new(0,12)
    local s=Instance.new("UIStroke",c); s.Color=GLASS_BORDER; s.Thickness=0.5; s.Transparency=0.75
    return c
end
local function glassBtn(parent,text,y,col,wScale,xScale)
    col=col or ACCENT; wScale=wScale or 1; xScale=xScale or 0
    local btn=Instance.new("TextButton",parent)
    btn.Size=UDim2.new(wScale,wScale<1 and -4 or 0,0,36); btn.Position=UDim2.new(xScale,xScale>0 and 2 or 0,0,y)
    btn.BackgroundColor3=col; btn.BackgroundTransparency=0.72; btn.Text=text; btn.TextColor3=TEXT_PRIMARY
    btn.Font=Enum.Font.GothamSemibold; btn.TextSize=13; btn.BorderSizePixel=0; btn.AutoButtonColor=false; btn.ZIndex=4
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,10)
    local s=Instance.new("UIStroke",btn); s.Color=col; s.Thickness=1; s.Transparency=0.5
    btn.MouseEnter:Connect(function() TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundTransparency=0.5}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundTransparency=0.72}):Play() end)
    return btn
end
local function sectionLabel(parent,text,y)
    local l=Instance.new("TextLabel",parent); l.Size=UDim2.new(1,0,0,16); l.Position=UDim2.new(0,2,0,y)
    l.BackgroundTransparency=1; l.Text=text:upper(); l.TextColor3=TEXT_MUTED
    l.Font=Enum.Font.GothamBold; l.TextSize=10; l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=4
end
local function statRow(parent,label,y)
    local row=Instance.new("Frame",parent); row.Size=UDim2.new(1,-20,0,22); row.Position=UDim2.new(0,10,0,y)
    row.BackgroundTransparency=1; row.ZIndex=4
    local lbl=Instance.new("TextLabel",row); lbl.Size=UDim2.new(0.6,0,1,0); lbl.BackgroundTransparency=1
    lbl.Text=label; lbl.TextColor3=TEXT_MUTED; lbl.Font=Enum.Font.Gotham; lbl.TextSize=12
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=4
    local val=Instance.new("TextLabel",row); val.Size=UDim2.new(0.4,0,1,0); val.Position=UDim2.new(0.6,0,0,0)
    val.BackgroundTransparency=1; val.Text="--"; val.TextColor3=TEXT_PRIMARY
    val.Font=Enum.Font.GothamBold; val.TextSize=12; val.TextXAlignment=Enum.TextXAlignment.Right; val.ZIndex=4
    return val
end

-- ─── BIND ROW HELPER (nowy design) ───────────────
local function makeBindRow(parent, y, bindKey, friendlyName, col)
    col = col or ACCENT
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -16, 0, 34)
    row.Position = UDim2.new(0, 8, 0, y)
    row.BackgroundColor3 = GLASS_BG
    row.BackgroundTransparency = 0.25
    row.BorderSizePixel = 0; row.ZIndex = 5
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 9)
    local rowStroke = Instance.new("UIStroke", row)
    rowStroke.Color = col; rowStroke.Thickness = 0.5; rowStroke.Transparency = 0.7

    -- ikona klawiatury
    local iconLbl = Instance.new("TextLabel", row)
    iconLbl.Size = UDim2.new(0,22,0,22); iconLbl.Position = UDim2.new(0,8,0.5,-11)
    iconLbl.BackgroundColor3 = col; iconLbl.BackgroundTransparency = 0.7
    iconLbl.Text = "⌨"; iconLbl.TextColor3 = col; iconLbl.Font = Enum.Font.GothamBold
    iconLbl.TextSize = 13; iconLbl.BorderSizePixel = 0; iconLbl.ZIndex = 6
    Instance.new("UICorner", iconLbl).CornerRadius = UDim.new(0, 6)

    local nameLbl = Instance.new("TextLabel", row)
    nameLbl.Size = UDim2.new(0.38, 0, 1, 0); nameLbl.Position = UDim2.new(0, 36, 0, 0)
    nameLbl.BackgroundTransparency = 1; nameLbl.Text = friendlyName
    nameLbl.TextColor3 = TEXT_MUTED; nameLbl.Font = Enum.Font.GothamMedium
    nameLbl.TextSize = 11; nameLbl.TextXAlignment = Enum.TextXAlignment.Left; nameLbl.ZIndex = 6

    -- aktualny bind jako "pill"
    local pillBg = Instance.new("Frame", row)
    pillBg.Size = UDim2.new(0, 64, 0, 22); pillBg.Position = UDim2.new(0.5, -8, 0.5, -11)
    pillBg.BackgroundColor3 = col; pillBg.BackgroundTransparency = 0.75; pillBg.BorderSizePixel = 0; pillBg.ZIndex = 6
    Instance.new("UICorner", pillBg).CornerRadius = UDim.new(1, 0)

    local kn = binds[bindKey]
    local keyLbl = Instance.new("TextLabel", pillBg)
    keyLbl.Size = UDim2.new(1, 0, 1, 0); keyLbl.BackgroundTransparency = 1
    keyLbl.Text = kn == Enum.KeyCode.Unknown and "—" or kn.Name
    keyLbl.TextColor3 = col; keyLbl.Font = Enum.Font.GothamBold
    keyLbl.TextSize = 11; keyLbl.ZIndex = 7
    bindKeyLabels[bindKey] = keyLbl

    local bindBtn = Instance.new("TextButton", row)
    bindBtn.Size = UDim2.new(0, 52, 0, 24); bindBtn.Position = UDim2.new(1, -58, 0.5, -12)
    bindBtn.BackgroundColor3 = col; bindBtn.BackgroundTransparency = 0.65
    bindBtn.Text = "Ustaw"; bindBtn.TextColor3 = TEXT_PRIMARY
    bindBtn.Font = Enum.Font.GothamBold; bindBtn.TextSize = 10
    bindBtn.BorderSizePixel = 0; bindBtn.AutoButtonColor = false; bindBtn.ZIndex = 7
    Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0, 7)
    bindBtn.MouseEnter:Connect(function() TweenService:Create(bindBtn,TweenInfo.new(0.12),{BackgroundTransparency=0.4}):Play() end)
    bindBtn.MouseLeave:Connect(function() TweenService:Create(bindBtn,TweenInfo.new(0.12),{BackgroundTransparency=0.65}):Play() end)
    bindBtn.MouseButton1Click:Connect(function()
        startListening(bindKey, friendlyName, keyLbl)
    end)
    return keyLbl
end

-------------------------------------------------------
-- GLOBAL INPUT HANDLER
-------------------------------------------------------
local toggleFunctions = {}

UIS.InputBegan:Connect(function(inp, gp)
    if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end

    if bindListening then
        if inp.KeyCode == Enum.KeyCode.Escape then
            bindOverlay.Visible = false
            bindListening = nil
            return
        end
        local newKey = inp.KeyCode
        binds[bindListening.key] = newKey
        local kname = newKey.Name
        bindListening.lbl.Text = kname
        -- update pill color
        bindOverlay.Visible = false
        notify("Bind ["..bindListening.key.."] = "..kname, "success")
        bindListening = nil
        return
    end

    if gp then return end
    local kc = inp.KeyCode

    -- GUI toggle — zawsze K lub ustawiony bind
    if kc == binds.gui then
        if guiOpen then closeGui() else openGui() end
        return
    end
    -- Pozostałe — tylko jeśli bind != Unknown
    if binds.fly ~= Enum.KeyCode.Unknown and kc == binds.fly then
        if toggleFunctions.fly then toggleFunctions.fly() end
    elseif binds.thirdperson ~= Enum.KeyCode.Unknown and kc == binds.thirdperson then
        if toggleFunctions.thirdperson then toggleFunctions.thirdperson() end
    elseif binds.killaura ~= Enum.KeyCode.Unknown and kc == binds.killaura then
        if toggleFunctions.killaura then toggleFunctions.killaura() end
    elseif binds.infjump ~= Enum.KeyCode.Unknown and kc == binds.infjump then
        if toggleFunctions.infjump then toggleFunctions.infjump() end
    end
end)

-------------------------------------------------------
-- ESP PAGE
-------------------------------------------------------
local espPage = pages["ESP"]
local espState = {nametags=false, hp=false, boxes=false, tracers=false, teamColor=false}
local espObjects = {}
local espFolder = Instance.new("Folder", workspace); espFolder.Name = "ESPFolder"
local ESP_TEAM_ON  = Color3.fromRGB(80, 220, 120)
local ESP_ENEMY_ON = Color3.fromRGB(220, 70, 80)
local ESP_DEFAULT  = Color3.fromRGB(120, 90, 255)

local function getTeamColor(p)
    if espState.teamColor then
        if p.Team and player.Team then return p.Team==player.Team and ESP_TEAM_ON or ESP_ENEMY_ON end
        return ESP_DEFAULT
    end
    return ESP_DEFAULT
end

-- Drawing-based 3D boxes + tracers (z drugiego kodu)
local drawingObjects = {} -- [playerName] = { lines[1..12], tracer }

local function newDrawLine()
    local l = Drawing.new("Line")
    l.Visible = false; l.Thickness = 1.4; l.Transparency = 1
    return l
end

local function createDrawingForPlayer(p)
    if drawingObjects[p.Name] then return end
    local d = { tracer = newDrawLine() }
    for i = 1, 12 do d[i] = newDrawLine() end
    drawingObjects[p.Name] = d
end

local function removeDrawingForPlayer(p)
    local d = drawingObjects[p.Name]; if not d then return end
    for _, l in pairs(d) do pcall(function() l:Remove() end) end
    drawingObjects[p.Name] = nil
end

local function setDrawingVisible(d, vis)
    for _, l in pairs(d) do l.Visible = vis end
end

-- Billboard / SelectionBox ESP
local function buildESP(p)
    if p==player then return end; if not p.Character then return end
    local char=p.Character; local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local data=espObjects[p.Name] or {}; espObjects[p.Name]=data

    if espState.nametags or espState.hp or espState.teamColor then
        if not data.highlight or not data.highlight.Parent then
            local hl=Instance.new("SelectionBox",espFolder); hl.Adornee=char
            hl.Color3=getTeamColor(p); hl.LineThickness=0.04; hl.SurfaceTransparency=0.85; hl.SurfaceColor3=getTeamColor(p)
            data.highlight=hl
        else data.highlight.Color3=getTeamColor(p); data.highlight.SurfaceColor3=getTeamColor(p) end
    elseif data.highlight then data.highlight:Destroy(); data.highlight=nil end

    if espState.nametags or espState.hp then
        if not data.billboard or not data.billboard.Parent then
            local bb=Instance.new("BillboardGui",espFolder); bb.Adornee=hrp
            bb.Size=UDim2.new(0,120,0,44); bb.StudsOffset=Vector3.new(0,3.2,0)
            bb.AlwaysOnTop=true; bb.ResetOnSpawn=false; data.billboard=bb
            local nL=Instance.new("TextLabel",bb); nL.Name="NameLbl"
            nL.Size=UDim2.new(1,0,0.5,0); nL.BackgroundTransparency=1; nL.Font=Enum.Font.GothamBold
            nL.TextSize=14; nL.TextStrokeTransparency=0.4; nL.TextColor3=getTeamColor(p)
            nL.Text=espState.nametags and p.Name or ""
            local hL=Instance.new("TextLabel",bb); hL.Name="HpLbl"
            hL.Size=UDim2.new(1,0,0.5,0); hL.Position=UDim2.new(0,0,0.5,0)
            hL.BackgroundTransparency=1; hL.Font=Enum.Font.GothamMedium; hL.TextSize=12
            hL.TextStrokeTransparency=0.4; hL.TextColor3=Color3.fromRGB(220,220,220); hL.Text=""
        else
            local bb=data.billboard
            local nL=bb:FindFirstChild("NameLbl"); local hL=bb:FindFirstChild("HpLbl")
            if nL then nL.Text=espState.nametags and p.Name or ""; nL.TextColor3=getTeamColor(p) end
            if hL then hL.Text="" end
        end
    elseif data.billboard then data.billboard:Destroy(); data.billboard=nil end

    -- Drawing boxes
    if espState.boxes or espState.tracers then
        createDrawingForPlayer(p)
    end
end

local function removeESP(p)
    local data=espObjects[p.Name]; if not data then return end
    if data.highlight then data.highlight:Destroy() end
    if data.billboard then data.billboard:Destroy() end
    espObjects[p.Name]=nil
    removeDrawingForPlayer(p)
end

local function refreshAllESP()
    for _,d in pairs(espObjects) do
        if d.highlight then d.highlight:Destroy() end
        if d.billboard then d.billboard:Destroy() end
    end
    espObjects={}
    for _,d in pairs(drawingObjects) do for _,l in pairs(d) do pcall(function() l.Visible=false end) end end
    local anyOn=espState.nametags or espState.hp or espState.boxes or espState.tracers or espState.teamColor
    if not anyOn then return end
    for _,p in pairs(Players:GetPlayers()) do buildESP(p) end
end

RunService.Heartbeat:Connect(function()
    if not espState.hp then return end
    for _,p in pairs(Players:GetPlayers()) do
        if p~=player and p.Character then
            local hum=p.Character:FindFirstChildOfClass("Humanoid"); local data=espObjects[p.Name]
            if hum and data and data.billboard then
                local hL=data.billboard:FindFirstChild("HpLbl")
                if hL then
                    local hp=math.round(hum.Health); local mx=math.round(hum.MaxHealth)
                    local pct=mx>0 and (hp/mx) or 0
                    hL.Text="HP: "..hp.." / "..mx
                    hL.TextColor3=Color3.fromRGB(math.round((1-pct)*220),math.round(pct*200),80)
                end
            end
        end
    end
end)

-- 3D Box + Tracer render loop (Drawing API — z drugiego kodu)
RunService.RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    local anyBoxOrTracer = espState.boxes or espState.tracers

    for _, p in pairs(Players:GetPlayers()) do
        if p == player then continue end
        local d = drawingObjects[p.Name]
        if not d then
            if anyBoxOrTracer and p.Character then createDrawingForPlayer(p); d = drawingObjects[p.Name] end
            if not d then continue end
        end

        local char = p.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        local head = char and char:FindFirstChild("Head")

        if not anyBoxOrTracer or not char or not hrp or not hum or hum.Health<=0 or not head then
            setDrawingVisible(d, false); continue
        end

        local _, vis = cam:WorldToViewportPoint(hrp.Position)
        if not vis then setDrawingVisible(d, false); continue end

        local col = getTeamColor(p)
        local Scale = head.Size.Y / 2
        local Size = Vector3.new(2, 3, 1.5) * (Scale * 2)

        local function wp(offset)
            local v = cam:WorldToViewportPoint((hrp.CFrame * CFrame.new(offset)).p)
            return Vector2.new(v.X, v.Y)
        end

        local T1=wp(Vector3.new(-Size.X, Size.Y,-Size.Z))
        local T2=wp(Vector3.new(-Size.X, Size.Y, Size.Z))
        local T3=wp(Vector3.new( Size.X, Size.Y, Size.Z))
        local T4=wp(Vector3.new( Size.X, Size.Y,-Size.Z))
        local B1=wp(Vector3.new(-Size.X,-Size.Y,-Size.Z))
        local B2=wp(Vector3.new(-Size.X,-Size.Y, Size.Z))
        local B3=wp(Vector3.new( Size.X,-Size.Y, Size.Z))
        local B4=wp(Vector3.new( Size.X,-Size.Y,-Size.Z))

        if espState.boxes then
            local edges = {{T1,T2},{T2,T3},{T3,T4},{T4,T1},{B1,B2},{B2,B3},{B3,B4},{B4,B1},{B1,T1},{B2,T2},{B3,T3},{B4,T4}}
            for i=1,12 do
                d[i].From=edges[i][1]; d[i].To=edges[i][2]
                d[i].Color=col; d[i].Thickness=1.4; d[i].Transparency=1; d[i].Visible=true
            end
        else
            for i=1,12 do d[i].Visible=false end
        end

        if espState.tracers then
            local tracePos = wp(Vector3.new(0,-Size.Y,0))
            d.tracer.From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y)
            d.tracer.To   = tracePos
            d.tracer.Color = col; d.tracer.Thickness = 1.4; d.tracer.Transparency = 1; d.tracer.Visible = true
        else
            d.tracer.Visible = false
        end
    end
end)

Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() task.wait(0.5); buildESP(p) end) end)
Players.PlayerRemoving:Connect(removeESP)
for _,p in pairs(Players:GetPlayers()) do
    if p~=player then p.CharacterAdded:Connect(function() task.wait(0.5); buildESP(p) end) end
end

-- ESP UI
sectionLabel(espPage,"ESP Settings",4)
local espCard=glassCard(espPage,24,304)

local function toggleRow(parent,label,desc,y,key,col)
    local row=Instance.new("Frame",parent); row.Size=UDim2.new(1,-16,0,52); row.Position=UDim2.new(0,8,0,y)
    row.BackgroundColor3=GLASS_BG; row.BackgroundTransparency=0.3; row.BorderSizePixel=0; row.ZIndex=4
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)
    local icon=Instance.new("Frame",row); icon.Size=UDim2.new(0,32,0,32); icon.Position=UDim2.new(0,10,0.5,-16)
    icon.BackgroundColor3=col; icon.BackgroundTransparency=0.6; icon.BorderSizePixel=0; icon.ZIndex=5
    Instance.new("UICorner",icon).CornerRadius=UDim.new(0,8)
    local iconLbl=Instance.new("TextLabel",icon); iconLbl.Size=UDim2.new(1,0,1,0); iconLbl.BackgroundTransparency=1
    iconLbl.Text=key=="nametags" and "N" or key=="hp" and "HP" or key=="boxes" and "3D" or key=="tracers" and "T" or "C"
    iconLbl.TextColor3=col; iconLbl.Font=Enum.Font.GothamBold; iconLbl.TextSize=11; iconLbl.ZIndex=6
    local tL=Instance.new("TextLabel",row); tL.Size=UDim2.new(1,-110,0,20); tL.Position=UDim2.new(0,52,0,8)
    tL.BackgroundTransparency=1; tL.Text=label; tL.TextColor3=TEXT_PRIMARY; tL.Font=Enum.Font.GothamBold
    tL.TextSize=13; tL.TextXAlignment=Enum.TextXAlignment.Left; tL.ZIndex=5
    local dL=Instance.new("TextLabel",row); dL.Size=UDim2.new(1,-110,0,16); dL.Position=UDim2.new(0,52,0,28)
    dL.BackgroundTransparency=1; dL.Text=desc; dL.TextColor3=TEXT_MUTED; dL.Font=Enum.Font.Gotham
    dL.TextSize=10; dL.TextXAlignment=Enum.TextXAlignment.Left; dL.ZIndex=5
    local switchBg=Instance.new("Frame",row); switchBg.Size=UDim2.new(0,44,0,24); switchBg.Position=UDim2.new(1,-54,0.5,-12)
    switchBg.BackgroundColor3=Color3.fromRGB(50,50,70); switchBg.BorderSizePixel=0; switchBg.ZIndex=5
    Instance.new("UICorner",switchBg).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame",switchBg); knob.Size=UDim2.new(0,18,0,18); knob.Position=UDim2.new(0,3,0.5,-9)
    knob.BackgroundColor3=Color3.fromRGB(160,160,180); knob.BorderSizePixel=0; knob.ZIndex=6
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local active=espState[key]
    local function updateSwitch(on)
        TweenService:Create(knob,TweenInfo.new(0.2,Enum.EasingStyle.Quint),{Position=on and UDim2.new(0,23,0.5,-9) or UDim2.new(0,3,0.5,-9),BackgroundColor3=on and col or Color3.fromRGB(160,160,180)}):Play()
        TweenService:Create(switchBg,TweenInfo.new(0.2),{BackgroundColor3=on and Color3.fromRGB(30,30,50) or Color3.fromRGB(50,50,70)}):Play()
    end
    updateSwitch(active)
    local btn=Instance.new("TextButton",row); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""; btn.ZIndex=7
    btn.MouseButton1Click:Connect(function()
        espState[key]=not espState[key]; updateSwitch(espState[key]); refreshAllESP()
        notify(label..": "..(espState[key] and "ON" or "OFF"), espState[key] and "success" or "danger")
    end)
end

toggleRow(espCard,"Nametagi",    "Imię gracza nad głową",          8,  "nametags",  ACCENT2)
toggleRow(espCard,"HP",          "Zdrowie gracza",                  68, "hp",        SUCCESS)
toggleRow(espCard,"Boxy 3D",     "Sześcienny box wokół gracza",    128, "boxes",     ACCENT)
toggleRow(espCard,"Tracery",     "Linia od dołu ekranu do gracza", 188, "tracers",   Color3.fromRGB(255,160,50))
toggleRow(espCard,"Kolor drużyn","Wróg=czerwony, sojusznik=zielony",248,"teamColor", Color3.fromRGB(200,80,200))

-------------------------------------------------------
-- KILL PAGE
-------------------------------------------------------
local killPage=pages["KILL"]
local KillAuraActive=false; local KillAuraDis=18; local ExcludedPlayers={}

sectionLabel(killPage,"Kill Aura",4)
local kaCard=glassCard(killPage,24,218)

local kaStatusRow=Instance.new("Frame",kaCard); kaStatusRow.Size=UDim2.new(1,-20,0,22); kaStatusRow.Position=UDim2.new(0,10,0,8)
kaStatusRow.BackgroundTransparency=1; kaStatusRow.ZIndex=4
local kaStatusLbl=Instance.new("TextLabel",kaStatusRow); kaStatusLbl.Size=UDim2.new(0.6,0,1,0); kaStatusLbl.BackgroundTransparency=1
kaStatusLbl.Text="Status"; kaStatusLbl.TextColor3=TEXT_MUTED; kaStatusLbl.Font=Enum.Font.Gotham; kaStatusLbl.TextSize=12
kaStatusLbl.TextXAlignment=Enum.TextXAlignment.Left; kaStatusLbl.ZIndex=4
local kaStatusVal=Instance.new("TextLabel",kaStatusRow); kaStatusVal.Size=UDim2.new(0.4,0,1,0); kaStatusVal.Position=UDim2.new(0.6,0,0,0)
kaStatusVal.BackgroundTransparency=1; kaStatusVal.Text="OFF"; kaStatusVal.TextColor3=DANGER; kaStatusVal.Font=Enum.Font.GothamBold
kaStatusVal.TextSize=12; kaStatusVal.TextXAlignment=Enum.TextXAlignment.Right; kaStatusVal.ZIndex=4

local kaRangeRow=Instance.new("Frame",kaCard); kaRangeRow.Size=UDim2.new(1,-20,0,22); kaRangeRow.Position=UDim2.new(0,10,0,34)
kaRangeRow.BackgroundTransparency=1; kaRangeRow.ZIndex=4
local kaRangeLbl=Instance.new("TextLabel",kaRangeRow); kaRangeLbl.Size=UDim2.new(0.6,0,1,0); kaRangeLbl.BackgroundTransparency=1
kaRangeLbl.Text="Zasięg"; kaRangeLbl.TextColor3=TEXT_MUTED; kaRangeLbl.Font=Enum.Font.Gotham; kaRangeLbl.TextSize=12
kaRangeLbl.TextXAlignment=Enum.TextXAlignment.Left; kaRangeLbl.ZIndex=4
local kaRangeVal=Instance.new("TextLabel",kaRangeRow); kaRangeVal.Size=UDim2.new(0.4,0,1,0); kaRangeVal.Position=UDim2.new(0.6,0,0,0)
kaRangeVal.BackgroundTransparency=1; kaRangeVal.Text=tostring(KillAuraDis); kaRangeVal.TextColor3=TEXT_PRIMARY
kaRangeVal.Font=Enum.Font.GothamBold; kaRangeVal.TextSize=12; kaRangeVal.TextXAlignment=Enum.TextXAlignment.Right; kaRangeVal.ZIndex=4

local kaDivider=Instance.new("Frame",kaCard); kaDivider.Size=UDim2.new(1,-20,0,1); kaDivider.Position=UDim2.new(0,10,0,62)
kaDivider.BackgroundColor3=GLASS_BORDER; kaDivider.BackgroundTransparency=0.82; kaDivider.BorderSizePixel=0; kaDivider.ZIndex=4

local kaRLbl=Instance.new("TextLabel",kaCard); kaRLbl.Size=UDim2.new(0,80,0,30); kaRLbl.Position=UDim2.new(0,10,0,70)
kaRLbl.BackgroundTransparency=1; kaRLbl.Text="Zasięg:"; kaRLbl.TextColor3=TEXT_MUTED; kaRLbl.Font=Enum.Font.GothamMedium
kaRLbl.TextSize=12; kaRLbl.TextXAlignment=Enum.TextXAlignment.Left; kaRLbl.ZIndex=4
local kaRangeBox=Instance.new("TextBox",kaCard); kaRangeBox.Size=UDim2.new(0,80,0,28); kaRangeBox.Position=UDim2.new(0,90,0,71)
kaRangeBox.BackgroundColor3=GLASS_BG; kaRangeBox.BackgroundTransparency=0.3; kaRangeBox.Text="18"; kaRangeBox.TextColor3=TEXT_PRIMARY
kaRangeBox.Font=Enum.Font.GothamBold; kaRangeBox.TextSize=13; kaRangeBox.BorderSizePixel=0; kaRangeBox.ClearTextOnFocus=false; kaRangeBox.ZIndex=5
Instance.new("UICorner",kaRangeBox).CornerRadius=UDim.new(0,8)
local kaRBoxS=Instance.new("UIStroke",kaRangeBox); kaRBoxS.Color=DANGER; kaRBoxS.Thickness=1; kaRBoxS.Transparency=0.55
local kaSetBtn=Instance.new("TextButton",kaCard); kaSetBtn.Size=UDim2.new(0,64,0,28); kaSetBtn.Position=UDim2.new(0,178,0,71)
kaSetBtn.BackgroundColor3=DANGER; kaSetBtn.BackgroundTransparency=0.72; kaSetBtn.Text="Ustaw"; kaSetBtn.TextColor3=TEXT_PRIMARY
kaSetBtn.Font=Enum.Font.GothamSemibold; kaSetBtn.TextSize=12; kaSetBtn.BorderSizePixel=0; kaSetBtn.AutoButtonColor=false; kaSetBtn.ZIndex=5
Instance.new("UICorner",kaSetBtn).CornerRadius=UDim.new(0,8); Instance.new("UIStroke",kaSetBtn).Color=DANGER
kaSetBtn.MouseEnter:Connect(function() TweenService:Create(kaSetBtn,TweenInfo.new(0.12),{BackgroundTransparency=0.45}):Play() end)
kaSetBtn.MouseLeave:Connect(function() TweenService:Create(kaSetBtn,TweenInfo.new(0.12),{BackgroundTransparency=0.72}):Play() end)
kaSetBtn.MouseButton1Click:Connect(function()
    local v=tonumber(kaRangeBox.Text); if not v then notify("Nieprawidłowy zasięg!","danger") return end
    v=math.clamp(math.round(v),1,999); KillAuraDis=v; kaRangeVal.Text=tostring(v)
    notify("Kill Aura zasięg: "..v,"success")
end)

local kaToggle=glassBtn(kaCard,"KILL AURA OFF",110,DANGER,1,0)
makeBindRow(kaCard, 154, "killaura", "Kill Aura", DANGER)

local function setKABtn(on)
    kaToggle.Text=on and "KILL AURA ON" or "KILL AURA OFF"
    kaToggle.BackgroundColor3=on and Color3.fromRGB(180,40,50) or DANGER
    local s=kaToggle:FindFirstChildOfClass("UIStroke"); if s then s.Color=kaToggle.BackgroundColor3 end
    kaStatusVal.Text=on and "ON" or "OFF"; kaStatusVal.TextColor3=on and SUCCESS or DANGER
end
toggleFunctions.killaura=function()
    KillAuraActive=not KillAuraActive; setKABtn(KillAuraActive)
    notify("Kill Aura: "..(KillAuraActive and "ON" or "OFF"), KillAuraActive and "success" or "danger")
end
kaToggle.MouseButton1Click:Connect(toggleFunctions.killaura)

sectionLabel(killPage,"Wyklucz graczy",252); local kaExcCard=glassCard(killPage,272,110)
local kaScroll=Instance.new("ScrollingFrame",kaExcCard); kaScroll.Size=UDim2.new(1,-8,0,62); kaScroll.Position=UDim2.new(0,4,0,4)
kaScroll.BackgroundTransparency=1; kaScroll.BorderSizePixel=0; kaScroll.ScrollBarThickness=3; kaScroll.ScrollBarImageColor3=DANGER
kaScroll.CanvasSize=UDim2.new(0,0,0,0); kaScroll.ScrollingDirection=Enum.ScrollingDirection.Y; kaScroll.ElasticBehavior=Enum.ElasticBehavior.Never; kaScroll.ZIndex=4
local kaScrollLayout=Instance.new("UIListLayout",kaScroll); kaScrollLayout.Padding=UDim.new(0,3); kaScrollLayout.SortOrder=Enum.SortOrder.LayoutOrder

local function refreshKAList()
    for _,v in pairs(kaScroll:GetChildren()) do if v:IsA("TextButton") or v:IsA("TextLabel") then v:Destroy() end end
    if #ExcludedPlayers==0 then
        local e=Instance.new("TextLabel",kaScroll); e.Size=UDim2.new(1,0,0,24); e.BackgroundTransparency=1
        e.Text="Brak wykluczonych"; e.TextColor3=TEXT_MUTED; e.Font=Enum.Font.GothamMedium; e.TextSize=11; e.ZIndex=5
    end
    for i,p in pairs(ExcludedPlayers) do
        local row=Instance.new("TextButton",kaScroll); row.Size=UDim2.new(1,-2,0,24); row.BackgroundColor3=Color3.fromRGB(80,30,30)
        row.BackgroundTransparency=0.4; row.Text="✕  "..p.Name; row.TextColor3=TEXT_PRIMARY; row.Font=Enum.Font.GothamMedium
        row.TextSize=11; row.BorderSizePixel=0; row.AutoButtonColor=false; row.ZIndex=5
        Instance.new("UICorner",row).CornerRadius=UDim.new(0,6)
        local iCopy=i; row.MouseButton1Click:Connect(function() table.remove(ExcludedPlayers,iCopy); refreshKAList(); notify(p.Name.." usunięty z wykluczeń") end)
    end
    task.wait(); kaScroll.CanvasSize=UDim2.new(0,0,0,kaScrollLayout.AbsoluteContentSize.Y+4)
end

glassBtn(kaExcCard,"Wyklucz sojuszników",72,Color3.fromRGB(160,80,40),1,0).MouseButton1Click:Connect(function()
    ExcludedPlayers={}
    if player.Team then for _,p in pairs(Players:GetPlayers()) do if p~=player and p.Team==player.Team then table.insert(ExcludedPlayers,p) end end end
    refreshKAList(); notify("Wykluczono "..(#ExcludedPlayers).." sojuszników")
end)
glassBtn(killPage,"Wyczyść wykluczone",390,DANGER,1,0).MouseButton1Click:Connect(function()
    ExcludedPlayers={}; refreshKAList(); notify("Wyczyszczono wykluczone")
end)

local function isExcluded(p) for _,ex in pairs(ExcludedPlayers) do if ex==p then return true end end return false end
local function getClosestPlayer()
    local closestDist=KillAuraDis; local closestPlayer=nil
    for _,p in pairs(Players:GetPlayers()) do
        if p~=player and not isExcluded(p) then
            local char=p.Character; local myChar=player.Character
            if char and myChar and char.PrimaryPart and myChar.PrimaryPart then
                local dist=(myChar.PrimaryPart.Position-char.PrimaryPart.Position).Magnitude
                if dist<closestDist then closestDist=dist; closestPlayer=p end
            end
        end
    end
    return closestPlayer
end

local kaAtck=nil; pcall(function()
    local rs2=game:GetService("ReplicatedStorage"); if rs2:FindFirstChild("GameRemotes") then kaAtck=rs2.GameRemotes.Attack end
end)
local tempplr=nil
task.spawn(function()
    while wait(0.1) do
        if KillAuraActive then
            pcall(function() tempplr=getClosestPlayer(); if tempplr~=nil and tempplr.Character~=nil then kaAtck:InvokeServer(tempplr.Character) end end)
        end
    end
end)

pages["KILL"].CanvasSize=UDim2.new(0,0,0,440)
refreshKAList()

-------------------------------------------------------
-- MOVE PAGE
-------------------------------------------------------
local movePage=pages["MOVE"]
sectionLabel(movePage,"Movement",4); local moveCard=glassCard(movePage,24,230)
local speedVal=statRow(moveCard,"Walk Speed",8); local jumpVal=statRow(moveCard,"Jump Power",34)
local divider=Instance.new("Frame",moveCard); divider.Size=UDim2.new(1,-20,0,1); divider.Position=UDim2.new(0,10,0,62)
divider.BackgroundColor3=GLASS_BORDER; divider.BackgroundTransparency=0.82; divider.BorderSizePixel=0; divider.ZIndex=4

local sIL=Instance.new("TextLabel",moveCard); sIL.Size=UDim2.new(0,80,0,30); sIL.Position=UDim2.new(0,10,0,70)
sIL.BackgroundTransparency=1; sIL.Text="Speed:"; sIL.TextColor3=TEXT_MUTED; sIL.Font=Enum.Font.GothamMedium; sIL.TextSize=12; sIL.TextXAlignment=Enum.TextXAlignment.Left; sIL.ZIndex=4
local speedBox=Instance.new("TextBox",moveCard); speedBox.Size=UDim2.new(0,80,0,28); speedBox.Position=UDim2.new(0,90,0,71)
speedBox.BackgroundColor3=GLASS_BG; speedBox.BackgroundTransparency=0.3; speedBox.Text="100"; speedBox.TextColor3=TEXT_PRIMARY
speedBox.Font=Enum.Font.GothamBold; speedBox.TextSize=13; speedBox.BorderSizePixel=0; speedBox.ClearTextOnFocus=false; speedBox.ZIndex=5
Instance.new("UICorner",speedBox).CornerRadius=UDim.new(0,8); local sSB=Instance.new("UIStroke",speedBox); sSB.Color=ACCENT; sSB.Thickness=1; sSB.Transparency=0.6
local setSpeedBtn=Instance.new("TextButton",moveCard); setSpeedBtn.Size=UDim2.new(0,64,0,28); setSpeedBtn.Position=UDim2.new(0,178,0,71)
setSpeedBtn.BackgroundColor3=ACCENT; setSpeedBtn.BackgroundTransparency=0.72; setSpeedBtn.Text="Set"; setSpeedBtn.TextColor3=TEXT_PRIMARY
setSpeedBtn.Font=Enum.Font.GothamSemibold; setSpeedBtn.TextSize=12; setSpeedBtn.BorderSizePixel=0; setSpeedBtn.AutoButtonColor=false; setSpeedBtn.ZIndex=5
Instance.new("UICorner",setSpeedBtn).CornerRadius=UDim.new(0,8); Instance.new("UIStroke",setSpeedBtn).Color=ACCENT
setSpeedBtn.MouseEnter:Connect(function() TweenService:Create(setSpeedBtn,TweenInfo.new(0.12),{BackgroundTransparency=0.5}):Play() end)
setSpeedBtn.MouseLeave:Connect(function() TweenService:Create(setSpeedBtn,TweenInfo.new(0.12),{BackgroundTransparency=0.72}):Play() end)

local jIL=Instance.new("TextLabel",moveCard); jIL.Size=UDim2.new(0,80,0,30); jIL.Position=UDim2.new(0,10,0,110)
jIL.BackgroundTransparency=1; jIL.Text="Jump:"; jIL.TextColor3=TEXT_MUTED; jIL.Font=Enum.Font.GothamMedium; jIL.TextSize=12; jIL.TextXAlignment=Enum.TextXAlignment.Left; jIL.ZIndex=4
local jumpBox=Instance.new("TextBox",moveCard); jumpBox.Size=UDim2.new(0,80,0,28); jumpBox.Position=UDim2.new(0,90,0,111)
jumpBox.BackgroundColor3=GLASS_BG; jumpBox.BackgroundTransparency=0.3; jumpBox.Text="100"; jumpBox.TextColor3=TEXT_PRIMARY
jumpBox.Font=Enum.Font.GothamBold; jumpBox.TextSize=13; jumpBox.BorderSizePixel=0; jumpBox.ClearTextOnFocus=false; jumpBox.ZIndex=5
Instance.new("UICorner",jumpBox).CornerRadius=UDim.new(0,8); local jSB=Instance.new("UIStroke",jumpBox); jSB.Color=ACCENT2; jSB.Thickness=1; jSB.Transparency=0.6
local setJumpBtn=Instance.new("TextButton",moveCard); setJumpBtn.Size=UDim2.new(0,64,0,28); setJumpBtn.Position=UDim2.new(0,178,0,111)
setJumpBtn.BackgroundColor3=ACCENT2; setJumpBtn.BackgroundTransparency=0.72; setJumpBtn.Text="Set"; setJumpBtn.TextColor3=TEXT_PRIMARY
setJumpBtn.Font=Enum.Font.GothamSemibold; setJumpBtn.TextSize=12; setJumpBtn.BorderSizePixel=0; setJumpBtn.AutoButtonColor=false; setJumpBtn.ZIndex=5
Instance.new("UICorner",setJumpBtn).CornerRadius=UDim.new(0,8); Instance.new("UIStroke",setJumpBtn).Color=ACCENT2
setJumpBtn.MouseEnter:Connect(function() TweenService:Create(setJumpBtn,TweenInfo.new(0.12),{BackgroundTransparency=0.5}):Play() end)
setJumpBtn.MouseLeave:Connect(function() TweenService:Create(setJumpBtn,TweenInfo.new(0.12),{BackgroundTransparency=0.72}):Play() end)
local d2=Instance.new("Frame",moveCard); d2.Size=UDim2.new(1,-20,0,1); d2.Position=UDim2.new(0,10,0,148)
d2.BackgroundColor3=GLASS_BORDER; d2.BackgroundTransparency=0.82; d2.BorderSizePixel=0; d2.ZIndex=4
glassBtn(moveCard,"Reset to Default",156,DANGER,1,0).MouseButton1Click:Connect(function()
    local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then local oS=math.round(hum.WalkSpeed); local oJ=math.round(hum.JumpPower)
    hum.WalkSpeed=16; hum.JumpPower=50; notify("Speed: "..oS.." -> 16 | Jump: "..oJ.." -> 50") end
end)
setSpeedBtn.MouseButton1Click:Connect(function()
    local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local val=tonumber(speedBox.Text); if not val then notify("Invalid speed!","danger") return end
    val=math.clamp(val,0,1000); local old=math.round(hum.WalkSpeed); hum.WalkSpeed=val; notify("Speed: "..old.." -> "..val,"success")
end)
setJumpBtn.MouseButton1Click:Connect(function()
    local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local val=tonumber(jumpBox.Text); if not val then notify("Invalid jump!","danger") return end
    val=math.clamp(val,0,1000); local old=math.round(hum.JumpPower); hum.JumpPower=val; notify("Jump: "..old.." -> "..val,"success")
end)
RunService.Heartbeat:Connect(function()
    local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then speedVal.Text=tostring(math.round(hum.WalkSpeed)); jumpVal.Text=tostring(math.round(hum.JumpPower)) end
end)

-------------------------------------------------------
-- MISC PAGE
-------------------------------------------------------
local miscPage=pages["MISC"]; local SelectedTargets={}; local FlingActive=false

sectionLabel(miscPage,"Fly",4); local flyCard=glassCard(miscPage,24,108)
local flyBindLbl=Instance.new("TextLabel",flyCard); flyBindLbl.Size=UDim2.new(1,-20,0,20); flyBindLbl.Position=UDim2.new(0,10,0,6)
flyBindLbl.BackgroundTransparency=1; flyBindLbl.Text="WASD = kierunek  |  E = góra  |  Q = dół"
flyBindLbl.TextColor3=TEXT_MUTED; flyBindLbl.Font=Enum.Font.GothamMedium; flyBindLbl.TextSize=11
flyBindLbl.TextXAlignment=Enum.TextXAlignment.Left; flyBindLbl.ZIndex=4
local flyActive=false; local flyBtn=glassBtn(flyCard,"FLY OFF",32,SUCCESS,1,0)
makeBindRow(flyCard,76,"fly","Fly",SUCCESS)

local flyBodyVel,flyBodyGyro
local function startFly()
    local char=player.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); local hum=char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end; hum.PlatformStand=true
    flyBodyVel=Instance.new("BodyVelocity",hrp); flyBodyVel.Velocity=Vector3.new(0,0,0); flyBodyVel.MaxForce=Vector3.new(1e5,1e5,1e5)
    flyBodyGyro=Instance.new("BodyGyro",hrp); flyBodyGyro.MaxTorque=Vector3.new(1e5,1e5,1e5); flyBodyGyro.P=1e4; flyBodyGyro.CFrame=hrp.CFrame
    local flySpeed=60; local cam=workspace.CurrentCamera
    local flyConn; flyConn=RunService.Heartbeat:Connect(function()
        if not flyActive then flyConn:Disconnect() return end
        local hrp2=player.Character and player.Character:FindFirstChild("HumanoidRootPart"); if not hrp2 then flyConn:Disconnect() return end
        local dir=Vector3.new(0,0,0); local cf=cam.CFrame
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir=dir+cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir=dir-cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir=dir-cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir=dir+cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.E) then dir=dir+Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.Q) then dir=dir-Vector3.new(0,1,0) end
        flyBodyVel.Velocity=dir.Magnitude>0 and dir.Unit*flySpeed or Vector3.new(0,0,0); flyBodyGyro.CFrame=cf
    end)
end
local function stopFly()
    if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel=nil end
    if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro=nil end
    local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid"); if hum then hum.PlatformStand=false end
end
toggleFunctions.fly=function()
    flyActive=not flyActive
    if flyActive then startFly(); flyBtn.Text="FLY ON"; flyBtn.BackgroundColor3=ACCENT2; local fs=flyBtn:FindFirstChildOfClass("UIStroke"); if fs then fs.Color=ACCENT2 end; notify("Fly włączony  •  WASD+E/Q","success")
    else stopFly(); flyBtn.Text="FLY OFF"; flyBtn.BackgroundColor3=SUCCESS; local fs=flyBtn:FindFirstChildOfClass("UIStroke"); if fs then fs.Color=SUCCESS end; notify("Fly wyłączony","danger") end
end
flyBtn.MouseButton1Click:Connect(toggleFunctions.fly)
player.CharacterAdded:Connect(function() if flyActive then task.wait(1); startFly() end end)

sectionLabel(miscPage,"Infinity Jump",142); local ijCard=glassCard(miscPage,162,82)
local ijActive=false; local ijConn=nil; local ijBtn=glassBtn(ijCard,"INFINITY JUMP OFF",8,Color3.fromRGB(180,100,255),1,0)
makeBindRow(ijCard,52,"infjump","Infinity Jump",Color3.fromRGB(180,100,255))
local function setIJBtn(on)
    ijBtn.Text=on and "INFINITY JUMP ON" or "INFINITY JUMP OFF"; ijBtn.BackgroundColor3=on and Color3.fromRGB(120,50,255) or Color3.fromRGB(180,100,255)
    local s=ijBtn:FindFirstChildOfClass("UIStroke"); if s then s.Color=ijBtn.BackgroundColor3 end
end
toggleFunctions.infjump=function()
    ijActive=not ijActive
    if ijActive then
        ijConn=UIS.JumpRequest:Connect(function() local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid"); if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end end)
        setIJBtn(true); notify("Infinity Jump: ON","success")
    else if ijConn then ijConn:Disconnect(); ijConn=nil end; setIJBtn(false); notify("Infinity Jump: OFF","danger") end
end
ijBtn.MouseButton1Click:Connect(toggleFunctions.infjump)
player.CharacterAdded:Connect(function()
    if ijActive and not ijConn then
        ijConn=UIS.JumpRequest:Connect(function() local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid"); if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end end)
    end
end)

sectionLabel(miscPage,"Teleport",254); local tpCard=glassCard(miscPage,274,148)
glassBtn(tpCard,"Teleport to Random Player",10,ACCENT2,1,0).MouseButton1Click:Connect(function()
    local others={}; for _,p in pairs(Players:GetPlayers()) do if p~=player then table.insert(others,p) end end
    if #others==0 then notify("Brak innych graczy!","danger") return end
    local target=others[math.random(1,#others)]
    if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame=target.Character.HumanoidRootPart.CFrame+Vector3.new(0,4,0); notify("Teleportowano do: "..target.Name,"success") end
end)
glassBtn(tpCard,"Teleport to Spawn",54,ACCENT,1,0).MouseButton1Click:Connect(function()
    local spawn=workspace:FindFirstChild("SpawnLocation")
    if spawn then player.Character.HumanoidRootPart.CFrame=spawn.CFrame+Vector3.new(0,5,0); notify("Teleportowano do Spawna","success")
    else notify("Spawn nie znaleziony","danger") end
end)
local nickBox=Instance.new("TextBox",tpCard); nickBox.Size=UDim2.new(1,-88,0,30); nickBox.Position=UDim2.new(0,8,0,102)
nickBox.BackgroundColor3=GLASS_BG; nickBox.BackgroundTransparency=0.25; nickBox.Text=""; nickBox.PlaceholderText="Wpisz nick gracza..."; nickBox.PlaceholderColor3=TEXT_MUTED
nickBox.TextColor3=TEXT_PRIMARY; nickBox.Font=Enum.Font.GothamMedium; nickBox.TextSize=12; nickBox.BorderSizePixel=0; nickBox.ClearTextOnFocus=false; nickBox.ZIndex=5
Instance.new("UICorner",nickBox).CornerRadius=UDim.new(0,8); local nbS=Instance.new("UIStroke",nickBox); nbS.Color=ACCENT2; nbS.Thickness=1; nbS.Transparency=0.55
local tpNickBtn=Instance.new("TextButton",tpCard); tpNickBtn.Size=UDim2.new(0,70,0,30); tpNickBtn.Position=UDim2.new(1,-78,0,102)
tpNickBtn.BackgroundColor3=ACCENT2; tpNickBtn.BackgroundTransparency=0.72; tpNickBtn.Text="TP"; tpNickBtn.TextColor3=TEXT_PRIMARY
tpNickBtn.Font=Enum.Font.GothamBold; tpNickBtn.TextSize=13; tpNickBtn.BorderSizePixel=0; tpNickBtn.AutoButtonColor=false; tpNickBtn.ZIndex=5
Instance.new("UICorner",tpNickBtn).CornerRadius=UDim.new(0,8); local tnS=Instance.new("UIStroke",tpNickBtn); tnS.Color=ACCENT2; tnS.Thickness=1; tnS.Transparency=0.5
tpNickBtn.MouseEnter:Connect(function() TweenService:Create(tpNickBtn,TweenInfo.new(0.12),{BackgroundTransparency=0.45}):Play() end)
tpNickBtn.MouseLeave:Connect(function() TweenService:Create(tpNickBtn,TweenInfo.new(0.12),{BackgroundTransparency=0.72}):Play() end)
tpNickBtn.MouseButton1Click:Connect(function()
    local nick=nickBox.Text:lower():match("^%s*(.-)%s*$"); if nick=="" then notify("Wpisz nick gracza!","danger") return end
    local found; for _,p in pairs(Players:GetPlayers()) do if p~=player and p.Name:lower()==nick then found=p; break end end
    if not found then for _,p in pairs(Players:GetPlayers()) do if p~=player and p.Name:lower():find(nick,1,true) then found=p; break end end end
    if not found then notify("Nie znaleziono: "..nickBox.Text,"danger"); return end
    local hrp=found.Character and found.Character:FindFirstChild("HumanoidRootPart")
    if hrp then player.Character.HumanoidRootPart.CFrame=hrp.CFrame+Vector3.new(0,4,0); notify("TP do: "..found.Name,"success")
    else notify(found.Name.." nie ma postaci","danger") end
end)

sectionLabel(miscPage,"Fling",430); local listCard=glassCard(miscPage,450,160); listCard.ClipsDescendants=true
local scroll=Instance.new("ScrollingFrame",listCard); scroll.Size=UDim2.new(1,-8,1,-8); scroll.Position=UDim2.new(0,4,0,4)
scroll.BackgroundTransparency=1; scroll.BorderSizePixel=0; scroll.ScrollBarThickness=4; scroll.ScrollBarImageColor3=ACCENT
scroll.CanvasSize=UDim2.new(0,0,0,0); scroll.ScrollingDirection=Enum.ScrollingDirection.Y; scroll.ElasticBehavior=Enum.ElasticBehavior.Never; scroll.ZIndex=4
local scrollLayout=Instance.new("UIListLayout",scroll); scrollLayout.Padding=UDim.new(0,4); scrollLayout.SortOrder=Enum.SortOrder.LayoutOrder
local scrollPad=Instance.new("UIPadding",scroll); scrollPad.PaddingLeft=UDim.new(0,2); scrollPad.PaddingRight=UDim.new(0,2); scrollPad.PaddingTop=UDim.new(0,2)
local function RefreshList()
    for _,v in pairs(scroll:GetChildren()) do if v:IsA("TextButton") or v:IsA("TextLabel") then v:Destroy() end end
    local count=0
    for _,p in pairs(Players:GetPlayers()) do if p~=player then count=count+1; local sel=SelectedTargets[p.Name]~=nil
        local row=Instance.new("TextButton",scroll); row.Name="Row_"..p.Name; row.Size=UDim2.new(1,0,0,32)
        row.BackgroundColor3=sel and ACCENT or GLASS_BG; row.BackgroundTransparency=sel and 0.55 or 0.25
        row.Text=""; row.BorderSizePixel=0; row.AutoButtonColor=false; row.ZIndex=5
        Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
        local dot=Instance.new("Frame",row); dot.Size=UDim2.new(0,7,0,7); dot.Position=UDim2.new(0,10,0.5,-3)
        dot.BackgroundColor3=sel and SUCCESS or TEXT_MUTED; dot.BorderSizePixel=0; dot.ZIndex=6
        Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
        local nL=Instance.new("TextLabel",row); nL.Size=UDim2.new(1,-32,1,0); nL.Position=UDim2.new(0,24,0,0)
        nL.BackgroundTransparency=1; nL.Text=p.Name; nL.TextColor3=TEXT_PRIMARY; nL.Font=Enum.Font.GothamMedium; nL.TextSize=12; nL.TextXAlignment=Enum.TextXAlignment.Left; nL.ZIndex=6
        row.MouseButton1Click:Connect(function()
            if SelectedTargets[p.Name] then SelectedTargets[p.Name]=nil; dot.BackgroundColor3=TEXT_MUTED; row.BackgroundColor3=GLASS_BG; row.BackgroundTransparency=0.25
            else SelectedTargets[p.Name]=p; dot.BackgroundColor3=SUCCESS; row.BackgroundColor3=ACCENT; row.BackgroundTransparency=0.55 end
        end)
    end end
    if count==0 then local e=Instance.new("TextLabel",scroll); e.Size=UDim2.new(1,0,0,30); e.BackgroundTransparency=1
    e.Text="Brak innych graczy"; e.TextColor3=TEXT_MUTED; e.Font=Enum.Font.GothamMedium; e.TextSize=12; e.ZIndex=5 end
    task.wait(); scroll.CanvasSize=UDim2.new(0,0,0,scrollLayout.AbsoluteContentSize.Y+6)
end
local flingCard=glassCard(miscPage,618,52); local startBtn=glassBtn(flingCard,"START FLING",8,SUCCESS,0.5,0); local stopBtn=glassBtn(flingCard,"STOP",8,DANGER,0.5,0.5)
glassBtn(miscPage,"Refresh Player List",678,ACCENT,1,0).MouseButton1Click:Connect(function() RefreshList(); notify("Lista odświeżona") end)

sectionLabel(miscPage,"Kamera",730); local camCard=glassCard(miscPage,750,82)
local camActive=false; local camBtn=glassBtn(camCard,"3RD PERSON OFF",8,Color3.fromRGB(200,150,50),1,0)
makeBindRow(camCard,52,"thirdperson","3rd Person",Color3.fromRGB(200,150,50))
toggleFunctions.thirdperson=function()
    camActive=not camActive; camBtn.Text=camActive and "3RD PERSON ON" or "3RD PERSON OFF"
    camBtn.BackgroundColor3=camActive and SUCCESS or Color3.fromRGB(200,150,50)
    local s=camBtn:FindFirstChildOfClass("UIStroke"); if s then s.Color=camBtn.BackgroundColor3 end
    if not camActive then player.CameraMode=Enum.CameraMode.LockFirstPerson; player.CameraMinZoomDistance=0.5; player.CameraMaxZoomDistance=128 end
    notify("Kamera 3-osobowa: "..(camActive and "ON" or "OFF"), camActive and "success" or "danger")
end
camBtn.MouseButton1Click:Connect(toggleFunctions.thirdperson)
RunService.RenderStepped:Connect(function()
    if camActive then player.CameraMode=Enum.CameraMode.Classic; player.CameraMinZoomDistance=12; player.CameraMaxZoomDistance=12 end
end)
pages["MISC"].CanvasSize=UDim2.new(0,0,0,845)

local function DoFling(Target)
    local char=player.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); local thrp=Target.Character and Target.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not thrp then return end; local oldFPDH=workspace.FallenPartsDestroyHeight; workspace.FallenPartsDestroyHeight=0/0
    local bv=Instance.new("BodyVelocity",hrp); bv.Velocity=Vector3.new(0,0,0); bv.MaxForce=Vector3.new(0,math.huge,0)
    local bav=Instance.new("BodyAngularVelocity",hrp); bav.AngularVelocity=Vector3.new(0,99999,0); bav.MaxTorque=Vector3.new(0,math.huge,0)
    local start=tick()
    while FlingActive and Target.Parent and tick()-start<1.5 do
        for _,v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=false end end
        hrp.CFrame=thrp.CFrame; hrp.Velocity=Vector3.new(4000,4000,4000); RunService.Heartbeat:Wait(); hrp.Velocity=Vector3.new(0,0,0)
    end
    bv:Destroy(); bav:Destroy(); workspace.FallenPartsDestroyHeight=oldFPDH
end
startBtn.MouseButton1Click:Connect(function()
    if FlingActive then return end; local hasTargets=false; for _ in pairs(SelectedTargets) do hasTargets=true; break end
    if not hasTargets then notify("Wybierz cel z listy!","danger") return end
    local hrp=player.Character and player.Character:FindFirstChild("HumanoidRootPart"); if not hrp then notify("Brak postaci!","danger") return end
    local oldPos=hrp.CFrame; FlingActive=true; notify("Flinguję...","success")
    task.spawn(function()
        while FlingActive do local found=false
            for _,target in pairs(SelectedTargets) do if target and target.Parent then found=true; DoFling(target); task.wait(0.1) end end
            if not found then break end; task.wait(0.2)
        end
        FlingActive=false; local curHrp=player.Character and player.Character:FindFirstChild("HumanoidRootPart"); if curHrp then curHrp.CFrame=oldPos end; notify("Fling zatrzymany.")
    end)
end)
stopBtn.MouseButton1Click:Connect(function() FlingActive=false; notify("Zatrzymano.","danger") end)

-------------------------------------------------------
-- ENTRY ANIMATION
-------------------------------------------------------
main.Position=UDim2.new(0.5,-W/2,0.5,-H/2+20); main.BackgroundTransparency=1
TweenService:Create(main,TweenInfo.new(0.45,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{BackgroundTransparency=0.08,Position=UDim2.new(0.5,-W/2,0.5,-H/2)}):Play()

RefreshList()
notify("Expander HUB loaded!","success")
