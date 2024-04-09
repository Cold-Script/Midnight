-- Version: 1.0-alpha

-- Version (1.0-beta)

--[[
    Credits:
    - Violin Suzutsuk: Linoria Cursor
    - shlexware: Orion Slider
    - Vape V4: Inspiration
]]

local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")


local Midnight = {
    Connections = {},
    Flags = {},
    Tabs = {},

    LocalPlayer = Players.LocalPlayer,

    ToggleKeybind = Enum.KeyCode.RightShift,
    Opened = false,

    Mobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled,
    Studio = RunService:IsStudio()
}

export type WindowOptions = {
    Title: string,
    ToggleKeybind: Enum.KeyCode
}

export type ElementButtonOptions = {
    Name: string,
    Enabled: boolean,
    Flag: string,
    Type: "Button" | "Toggle"
}

export type ToggleOptions = {
    Name: string,
    Enabled: boolean,
    Flag: string,
}

export type SliderOptions = {
    Name: string,
    Value: number,
    Flag: string,
    Increment: number,
    Min: number,
    Max: number,
}

export type TextboxOptions = {
    Name: string,
    Flag: string,
    ResetOnFocus: boolean,
    Text: string,
}


local defaultToggleColor = Color3.fromRGB(60, 60, 60)
local hoveringToggleColor = Color3.fromRGB(100, 100, 100)
local enabledToggleColor = Color3.fromRGB(140, 140, 140)

local titleFont = Font.fromId(12187365364, Enum.FontWeight.SemiBold)
local tabFont = Font.fromId(12187365364, Enum.FontWeight.Medium)
local regularFont = Font.fromId(12187365364)


local function HasProperty(instance: Instance, property: string)
    local _ = instance[property]
end

local function Create(class: string, properties: table): Instance
    local instance = Instance.new(class)

    local borderSuccess = pcall(HasProperty, instance, "BorderSizePixel")
    if borderSuccess then
        instance["BorderSizePixel"] = 0
    end

    for property, value in pairs(properties) do
        instance[property] = value
    end

    return instance
end

local function Round(number, factor)
    local result = math.floor(number / factor + (math.sign(number) * 0.5)) * factor
    if result < 0 then result += factor end
    return result
end


local function MakeDraggable(instance: Instance, main: Instance)
    local dragging = false
    local dragInput
    local mousePos
    local framePos

    instance.InputBegan:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = main.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    instance.InputChanged:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input: InputObject)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            main.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end


local UI = Create("ScreenGui", {
    DisplayOrder = 0,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

    Parent = Midnight.Studio and Midnight.LocalPlayer.PlayerGui or CoreGui
})

local Windows = Create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1,
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(1, -12, 1, -12),

    Parent = UI
})


function Midnight.AddConnection(connection)
    table.insert(Midnight.Connections, connection)
end

function Midnight.CreateWindow(options: WindowOptions)
    Midnight.ToggleKeybind = options.ToggleKeybind or Enum.KeyCode.RightShift

    Midnight.Blur = Create("BlurEffect", {
        Size = 12,
        Parent = Lighting
    })

    --// Main Window \\--
    local MainWindow = Create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        Size = UDim2.fromOffset(220, 0),
        Parent = Windows
    })
    table.insert(Midnight.Tabs, MainWindow)

    Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = MainWindow
    })

    Create("UIListLayout", {
        Parent = MainWindow
    })

    --// Top \\--
    local Top = Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        Size = UDim2.new(1, 0, 0, 40),
        Parent = MainWindow
    })

    Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = Top
    })

    Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        Position = UDim2.fromScale(0.5, 1),
        Size = UDim2.fromScale(1, 0.25),
        Parent = Top
    })

    local Title = Create("TextLabel", {
        BackgroundTransparency = 1,
        FontFace = titleFont,
        Size = UDim2.fromScale(1, 1),
        Text = options.Title or "No Title",
        TextColor3 = Color3.new(1, 1, 1),
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Top
    })

    Create("UIPadding", {
        PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 6),
        Parent = Title
    })

    --// Separator \\--
    Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        Size = UDim2.new(1, 0, 0, 1),
        Parent = MainWindow
    })

    --// Tab Buttons \\--
    local TabButtons = Create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0),
        Parent = MainWindow
    })

    Create("UIListLayout", {
        Parent = TabButtons
    })

    --// Separator \\--
    Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        Size = UDim2.new(1, 0, 0, 1),
        Parent = MainWindow
    })

    --// Extra \\-
    Create("Frame", {
        BackgroundTransparency = 1,
        LayoutOrder = 999,
        Size = UDim2.new(1, 0, 0, 6),
        Parent = MainWindow
    })

    task.spawn(Midnight.Toggle)

    local Window = {}

    function Window.AddTab(tabName: string)
        --// Tab Holder \\--
        local TabHolder: Frame = Create("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            Position = UDim2.fromOffset(226 * #Midnight.Tabs, 0),
            Size = UDim2.fromOffset(220, 0),
            Visible = false,
            Parent = Windows,
        })
        table.insert(Midnight.Tabs, MainWindow)
    
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = TabHolder
        })
    
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TabHolder
        })
    
        --// Top \\--
        local Top = Create("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            Size = UDim2.new(1, 0, 0, 40),
            Text = "",
            Parent = TabHolder
        })
    
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = Top
        })
    
        Create("Frame", {
            AnchorPoint = Vector2.new(0.5, 1),
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            Position = UDim2.fromScale(0.5, 1),
            Size = UDim2.fromScale(1, 0.25),
            Parent = Top
        })
    
        local Title = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = tabFont,
            Size = UDim2.fromScale(1, 1),
            Text = tabName or "No Name",
            TextColor3 = Color3.new(1, 1, 1),
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Top
        })
    
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            PaddingTop = UDim.new(0, 6),
            Parent = Title
        })
    
        --// Separator \\--
        Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(60, 60, 60),
            Size = UDim2.new(1, 0, 0, 1),
            Parent = TabHolder
        })
    
        --// Elements \\--
        local Elements = Create("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            CanvasSize = UDim2.fromScale(0, 0),
            ScrollBarImageColor3 = Color3.fromRGB(95, 95, 95),
            ScrollBarThickness = 4,
            Size = UDim2.fromScale(1, 0),
            TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            Parent = TabHolder
        })
    
        local ElementsListLayout = Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = Elements
        })
    
        --// Separator \\--
        Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(60, 60, 60),
            Size = UDim2.new(1, 0, 0, 1),
            Parent = TabHolder
        })
    
        --// Extra \\-
        Create("Frame", {
            BackgroundTransparency = 1,
            LayoutOrder = 999,
            Size = UDim2.new(1, 0, 0, 6),
            Parent = TabHolder
        })
    

        --// Tab Button \\--
        local TabButton: TextButton = Create("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            Size = UDim2.new(1, 0, 0, 36),
            Text = "",
            Parent = TabButtons
        })

        local TabButtonText = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = regularFont,
            Size = UDim2.fromScale(1, 1),
            Text = tabName or "No Name",
            TextColor3 = Color3.new(1, 1, 1),
            TextScaled = true,
            TextTransparency = 0.5,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabButton
        })

        Create("ImageLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            Image = "rbxassetid://7072706745",
            ImageTransparency = 0.5,
            Position = UDim2.new(1, -5, 0.5, 0),
            Size = UDim2.fromOffset(20, 20),
            ZIndex = 2,
            Parent = TabButton
        })
    
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 11),
            PaddingRight = UDim.new(0, 11),
            PaddingTop = UDim.new(0, 8),
            Parent = TabButtonText
        })

        --// Tab Table \\--
        local Tab = {
            Hovering = false,
            Opened = false
        }

        function Tab.AddElementButton(options: ElementButtonOptions)
            local ElementHolder: TextButton = Create("TextButton", {
                AutoButtonColor = false,
                BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                Size = UDim2.new(1, 0, 0, 36),
                Text = "",
                Parent = Elements
            })

            local ButtonFrame: TextButton = Create("TextButton", {
                AutoButtonColor = false,
                BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                FontFace = regularFont,
                Size = UDim2.new(1, 0, 0, 36),
                Text = options.Name or "Button",
                TextColor3 = Color3.new(1, 1, 1),
                TextScaled = true,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ElementHolder
            })

            local Components = Create("Frame", {
                AnchorPoint = Vector2.new(0.5, 1),
                BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                Position = UDim2.fromScale(0.5, 1),
                Size = UDim2.new(1, 0, 1, -36),
                Parent = ElementHolder
            })

            local ComponentsListLayout = Create("UIListLayout", {
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = Components
            })
            
            local Icon: ImageLabel = Create("ImageLabel", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Image = "rbxassetid://7072719531",
                ImageTransparency = 0.5,
                Position = UDim2.new(1, -4, 0, 8),
                Size = UDim2.fromOffset(20, 20),
                ZIndex = 2,
                Parent = ElementHolder
            })

            Create("UIPadding", {
                PaddingBottom = UDim.new(0, 8), 
                PaddingLeft = UDim.new(0, 11),
                PaddingRight = UDim.new(0, 11),
                PaddingTop = UDim.new(0, 8),
                Parent = ButtonFrame
            })

            --// Element Button Table \\--
            local ElementButton = {
                Hovering = false,
                Locked = false,
                Opened = false,

                Name = options.Name or "Button",
                Enabled = options.Enabled or false,
                Type = options.Type or "Toggle"
            }

            function ElementButton.Activate()
                if ElementButton.Type == "Button" then
                    local success, error = pcall(options.Callback)
                    if not success then
                        warn("(" .. ElementButton.Name .. ") " .. tostring(error))
                    end
                else
                    ElementButton.Set(not ElementButton.Enabled)
                end
            end

            function ElementButton.SetLocked(locked: boolean)
                ElementButton.Locked = locked
                if ElementButton.Hovering then
                    Icon.Position = ElementButton.Locked and UDim2.new(1, -7, 0, 8) or UDim2.new(1, -4, 0, 8)
                    Icon.Image = ElementButton.Locked and "rbxassetid://7072718362" or "rbxassetid://7072719531"
                end
            end

            function ElementButton.Toggle()
                ElementButton.Opened = not ElementButton.Opened

                ElementHolder.Size = ElementButton.Opened and UDim2.new(1, 0, 0, ComponentsListLayout.AbsoluteContentSize.Y + 36) or UDim2.new(1, 0, 0, 36)
            end

            if ElementButton.Type == "Toggle" then
                function ElementButton.Set(newValue: boolean)
                    local oldEnabled = ElementButton.Enabled
                    ElementButton.Enabled = newValue
                    if options.Flag then
                        Midnight.Flags[options.Flag] = ElementButton.Enabled
                    end

                    ButtonFrame.BackgroundColor3 = ElementButton.Enabled and Color3.fromRGB(35, 35, 35) or (ElementButton.Hovering and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(25, 25, 25))
                    ButtonFrame.TextTransparency = ElementButton.Enabled and 0 or (ElementButton.Hovering and 0.25 or 0.5)

                    if options.Callback and ElementButton.Enabled ~= oldEnabled then
                        local success, error = pcall(options.Callback, ElementButton.Enabled, oldEnabled)
                        if not success then
                            warn("(" .. ElementButton.Name .. ") " .. tostring(error))
                        end
                    end
                    
                end
            end

            --// Add Elements \\--
            function ElementButton.AddLabel(text: string)
                --// Text Label \\--
                local TextLabel = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    FontFace = regularFont,
                    RichText = true,
                    Size = UDim2.new(1, 0, 0, 0),
                    Text = "",
                    TextColor3 = Color3.new(1, 1, 1),
                    TextSize = 20,
                    TextTransparency = 0.5,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Components
                })

                Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 11),
                    PaddingRight = UDim.new(0, 11),
                    Parent = TextLabel
                })

                local Label = {
                    Text = text or "No Text"
                }

                function Label.Set(newText: string)
                    Label.Text = newText

                    local params = Instance.new("GetTextBoundsParams")
                    params.Text = Label.Text
                    params.Font = regularFont
                    params.Size = 20
                    params.Width = 196

                    local size = TextService:GetTextBoundsAsync(params)
                    
                    TextLabel.Size = UDim2.new(1, 0, 0, size.Y + 7)
                    TextLabel.Text = Label.Text
                end

                do
                    Label.Set(Label.Text)
                end

                return Label
            end

            function ElementButton.AddToggle(options: ToggleOptions)
                --// Toggle Holder \\--
                local ToggleHolder = Create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32),
                    Parent = Components
                })

                Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 11),
                    PaddingRight = UDim.new(0, 13),
                    Parent = ToggleHolder
                })
                
                --// Toggle Text \\--
                local ToggleText: TextLabel = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    FontFace = regularFont,
                    Size = UDim2.fromScale(1, 1),
                    Text = options.Name or "Toggle",
                    TextColor3 = Color3.new(1, 1, 1),
                    TextScaled = true,
                    TextTransparency = 0.5,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ToggleHolder
                })

                Create("UIPadding", {
                    PaddingBottom = UDim.new(0, 6),
                    PaddingTop = UDim.new(0, 6),
                    Parent = ToggleText
                })

                --// Toggle Button \\--
                local ToggleButton: TextButton = Create("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Position = UDim2.fromScale(1, 0.5),
                    Size = UDim2.fromOffset(32, 16),
                    Text = "",
                    Parent = ToggleHolder
                })

                Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = ToggleButton
                })

                Create("UIPadding", {
                    PaddingBottom = UDim.new(0, 2),
                    PaddingLeft = UDim.new(0, 2),
                    PaddingRight = UDim.new(0, 2),
                    PaddingTop = UDim.new(0, 2),
                    Parent = ToggleButton,
                })

                local ToggleStroke = Create("UIStroke", {
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    Color = Color3.fromRGB(60, 60, 60),
                    Parent = ToggleButton
                })

                --// Toggle Icon \\--
                local ToggleIcon = Create("Frame", {
                    BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                    Size = UDim2.fromScale(1, 1),
                    SizeConstraint = Enum.SizeConstraint.RelativeYY,
                    Parent = ToggleButton
                })

                Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = ToggleIcon
                })

                --// Locked \\--
                local LockedIcon = Create("ImageLabel", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://7072718362",
                    ImageTransparency = 0.5,
                    Position = UDim2.new(1, 7, 0.5, 0),
                    Size = UDim2.fromOffset(20, 20),
                    Visible = false,
                    Parent = ToggleHolder
                })

                local LockedHover: TextButton = Create("TextButton", {
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 1),
                    Text = "",
                    Visible = false,
                    Parent = ToggleHolder,
                })

                --// Toggle Table \\--
                local Toggle = {
                    Hovering = false,
                    Locked = false,
                    
                    Enabled = options.Enabled or false,
                }

                function Toggle.Activate()
                    Toggle.Set(not Toggle.Enabled)
                end

                function Toggle.SetLocked(locked: boolean)
                    Toggle.Locked = locked
                    
                    LockedHover.Visible = Toggle.Locked
                    if Toggle.Hovering then
                        ToggleButton.Visible = not Toggle.Locked
                        LockedIcon.Visible = Toggle.Locked
                    end
                end

                function Toggle.Set(newValue: boolean)
                    local oldEnabled = Toggle.Enabled
                    Toggle.Enabled = newValue
                    if options.Flag then
                        Midnight.Flags[options.Flag] = newValue
                    end

                    ToggleIcon.BackgroundColor3 = Toggle.Enabled and enabledToggleColor or (Toggle.Hovering and hoveringToggleColor or defaultToggleColor)
                    ToggleIcon.Position = Toggle.Enabled and UDim2.fromOffset(16, 0) or UDim2.fromOffset(0, 0)

                    ToggleStroke.Color = Toggle.Enabled and enabledToggleColor or (Toggle.Hovering and hoveringToggleColor or defaultToggleColor)

                    if options.Callback and Toggle.Enabled ~= oldEnabled then
                        pcall(options.Callback, Toggle.Enabled, oldEnabled)
                    end
                end

                --// Toggle Connections \\--
                do
                    if options.Flag then
                        Midnight.Flags[options.Flag] = Toggle.Enabled
                    end

                    LockedHover.MouseEnter:Connect(function()
                        ToggleButton.Visible = false
                        LockedIcon.Visible = true
                    end)

                    LockedHover.MouseLeave:Connect(function()
                        LockedIcon.Visible = false
                        ToggleButton.Visible = true
                    end)

                    ToggleButton.MouseEnter:Connect(function()
                        Toggle.Hovering = true

                        if not Toggle.Enabled and not Toggle.Locked then
                            ToggleIcon.BackgroundColor3 = hoveringToggleColor
                            ToggleStroke.Color = hoveringToggleColor
                        end
                    end)

                    ToggleButton.MouseLeave:Connect(function()
                        Toggle.Hovering = false

                        if not Toggle.Enabled and not Toggle.Locked then
                            ToggleIcon.BackgroundColor3 = defaultToggleColor
                            ToggleStroke.Color = defaultToggleColor
                        end
                    end)

                    ToggleButton.MouseButton1Click:Connect(function()
                        task.spawn(Toggle.Activate)
                    end)

                    Toggle.Set(Toggle.Enabled)
                end

                return Toggle
            end

            function ElementButton.AddSlider(options: SliderOptions)
                --// Slider Holder \\--
                local SliderHolder = Create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 48),
                    Parent = Components
                })

                Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 11),
                    PaddingRight = UDim.new(0, 11),
                    Parent = SliderHolder
                })

                --// Slider Text \\--
                local SliderText = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    FontFace = regularFont,
                    Size = UDim2.new(1, -48, 0, 32),
                    Text = options.Name or "No Name",
                    TextColor3 = Color3.new(1, 1, 1),
                    TextScaled = true,
                    TextTransparency = 0.5,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = SliderHolder
                })

                Create("UIPadding", {
                    PaddingBottom = UDim.new(0, 6),
                    PaddingTop = UDim.new(0, 6),
                    Parent = SliderText
                })

                --// Slider Value \\--
                local SliderValue = Create("TextLabel", {
                    AnchorPoint = Vector2.new(1, 0),
                    BackgroundTransparency = 1,
                    FontFace = regularFont,
                    Position = UDim2.new(1, 0, 0, 2),
                    Size = UDim2.fromOffset(48, 30),
                    Text = "100",
                    TextColor3 = Color3.new(1, 1, 1),
                    TextScaled = true,
                    TextTransparency = 0.5,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = SliderHolder
                })

                Create("UIPadding", {
                    PaddingBottom = UDim.new(0, 6),
                    PaddingTop = UDim.new(0, 6),
                    Parent = SliderValue
                })

                --// Locked Icon \\--
                local LockedIcon = Create("ImageLabel", {
                    AnchorPoint = Vector2.new(1, 0),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://7072718362",
                    ImageTransparency = 0.5,
                    Position = UDim2.new(1, 6, 0, 7),
                    Size = UDim2.fromOffset(20, 20),
                    Visible = false,
                    Parent = SliderHolder
                })

                --// Locked Hover \\--
                local LockedHover: TextButton = Create("TextButton", {
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 1),
                    Text = "",
                    Visible = false,
                    Parent = SliderHolder,
                })

                --// Slider Bar \\--
                local SliderBar: TextButton = Create("TextButton", {
                    AnchorPoint = Vector2.new(0, 1),
                    AutoButtonColor = false,
                    BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                    Position = UDim2.new(0, 0, 1, -10),
                    Size = UDim2.new(1, 0, 0, 6),
                    Text = "",
                    Parent = SliderHolder
                })

                Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = SliderBar
                })

                local SliderFillBar = Create("Frame", {
                    BackgroundColor3 = Color3.fromRGB(140, 140, 140),
                    Size = UDim2.fromScale(0.5, 1),
                    Parent = SliderBar
                })

                Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = SliderFillBar
                })

                local Slider = {
                    Dragging = false,
                    Hovering = false,
                    Locked = false,

                    Increment = options.Increment or 1,
                    Min = options.Min or 0,
                    Max = options.Max or 100,
                    Value = options.Value or (options.Min or 0),
                }

                function Slider.Set(newValue: number)
                    local oldValue = Slider.Value
                    Slider.Value = math.floor(math.clamp(Round(newValue, Slider.Increment), Slider.Min, Slider.Max) * (100 * Slider.Max)) / (100 * Slider.Max)

                    SliderValue.Text = tostring(Slider.Value)
                    SliderFillBar.Size = UDim2.fromScale((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min), 1)

                    if options.Callback and Slider.Value ~= oldValue then
                        pcall(options.Callback, Slider.Value, oldValue)
                    end
                end

                function Slider.SetLocked(locked: boolean)
                    Slider.Locked = locked

                    LockedHover.Visible = Slider.Locked
                    if Slider.Hovering then
                        SliderValue.Visible = not Slider.Locked
                        LockedIcon.Visible = Slider.Locked
                    end
                end

                function Slider.SetMin(newMin: number)
                    if newMin > Slider.Max then
                        return warn("Slider minimum value should be smaller than maximum value")
                    end

                    Slider.Min = newMin
                    if Slider.Value < Slider.Min then
                        Slider.Set(Slider.Min)
                    end
                end

                function Slider.SetMax(newMax: number)
                    if newMax < Slider.Min then
                        return warn("Slider maximum value should be higher than minimum value")
                    end

                    Slider.Max = newMax
                    if Slider.Value > Slider.Max then
                        Slider.Set(Slider.Max)
                    end
                end

                do
                    if options.Flag then
                        Midnight.Flags[options.Flag] = Slider.Value
                    end

                    LockedHover.MouseEnter:Connect(function()
                        SliderValue.Visible = false
                        LockedIcon.Visible = true
                    end)

                    LockedHover.MouseLeave:Connect(function()
                        LockedIcon.Visible = false
                        SliderValue.Visible = true
                    end)

                    SliderBar.MouseEnter:Connect(function()
                        Slider.Hovering = true
                    end)

                    SliderBar.MouseLeave:Connect(function()
                        Slider.Hovering = true
                    end)

                    SliderBar.InputBegan:Connect(function(input: InputObject)
                        if not Slider.Locked and input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            Slider.Dragging = true
                        end
                    end)

                    SliderBar.InputEnded:Connect(function(input: InputObject)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            Slider.Dragging = false
                        end
                    end)

                    Midnight.AddConnection(UserInputService.InputChanged:Connect(function(input: InputObject)
                        if Slider.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                            local percentage = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                            Slider.Set(Slider.Min + ((Slider.Max - Slider.Min) * percentage))
                        end
                    end))

                    Slider.Set(Slider.Value)
                end

                return Slider
            end

            function ElementButton.AddTextbox(options: TextboxOptions)
                --// Textbox Holder \\--
                local TextboxHolder = Create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 44),
                    Parent = Components
                })

                Create("UIPadding", {
                    PaddingBottom = UDim.new(0, 6),
                    PaddingLeft = UDim.new(0, 13),
                    PaddingRight  = UDim.new(0, 13),
                    PaddingTop = UDim.new(0, 6),
                    Parent = TextboxHolder
                })

                --// Locked \\--
                local LockedIcon = Create("ImageLabel", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://7072718362",
                    ImageTransparency = 0.5,
                    Position = UDim2.new(1, -5, 0.5, 0),
                    Size = UDim2.fromOffset(20, 20),
                    Visible = false,
                    Parent = TextboxHolder
                })

                --// Box \\--
                local Box: TextBox = Create("TextBox", {
                    BackgroundTransparency = 1,
                    ClearTextOnFocus = options.ResetOnFocus or false,
                    FontFace = regularFont,
                    PlaceholderColor3 = Color3.fromRGB(60, 60, 60),
                    PlaceholderText = options.Name or "No Name",
                    Size = UDim2.fromScale(1, 1),
                    Text = options.Text or "",
                    TextColor3 = Color3.fromRGB(140, 140, 140),
                    TextScaled = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = TextboxHolder
                })

                Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = Box
                })

                Create("UIPadding", {
                    PaddingBottom = UDim.new(0, 6),
                    PaddingLeft = UDim.new(0, 6),
                    PaddingRight = UDim.new(0, 6),
                    PaddingTop = UDim.new(0, 6),
                    Parent = Box
                })

                local BoxStroke = Create("UIStroke", {
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    Color = Color3.fromRGB(60, 60, 60),
                    Parent = Box
                })

                local Textbox = {
                    Hovering = false,
                    Locekd = false,

                    Text = options.Text or ""
                }

                function Textbox.Set(newText: string)
                    Textbox.Text = newText
                    if options.Flag then
                        Midnight.Flags[options.Flag] = Textbox.Text
                    end

                    Box.Text = Textbox.Text
                    if options.Callback then
                        pcall(options.Callback, Box.Text)
                    end
                end

                function Textbox.SetLocked(locked: boolean)
                    Textbox.Locked = locked

                    Box.TextEditable = not Textbox.Locked
                    LockedIcon.Visible = Textbox.Hovering and Textbox.Locked
                end

                do
                    if options.Flag then
                        Midnight.Flags[options.Flag] = Textbox.Text
                    end

                    Box.MouseEnter:Connect(function()
                        Textbox.Hovering = true

                        LockedIcon.Visible = Textbox.Locked
                    end)

                    Box.MouseLeave:Connect(function()
                        Textbox.Hovering = false

                        LockedIcon.Visible = false
                    end)

                    Box:GetPropertyChangedSignal("Text"):Connect(function()
                        Textbox.Text = Box.Text
                        if options.Flag then
                            Midnight.Flags[options.Flag] = Textbox.Text
                        end

                        if options.Callback then
                            pcall(options.Callback, Box.Text)
                        end 
                    end)
                end

                return Textbox
            end

            --// Element Button Connections \\--
            do
                if options.Flag then
                    Midnight.Flags[options.Flag] = ElementButton.Enabled
                end

                ButtonFrame.MouseEnter:Connect(function()
                    ElementButton.Hovering = true
                    Icon.Position = ElementButton.Locked and UDim2.new(1, -7, 0, 8) or UDim2.new(1, -4, 0, 8)
                    Icon.Image = ElementButton.Locked and "rbxassetid://7072718362" or "rbxassetid://7072719531"
                    
                    if not ElementButton.Enabled and not ElementButton.Locked then
                        ButtonFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                        ButtonFrame.TextTransparency = 0.25
                    end
                end)
    
                ButtonFrame.MouseLeave:Connect(function()
                    ElementButton.Hovering = false
                    Icon.Image = "rbxassetid://7072719531"
                    Icon.Position = UDim2.new(1, -4, 0, 8)

                    if not ElementButton.Enabled and not ElementButton.Locked then
                        ButtonFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                        ButtonFrame.TextTransparency = 0.5
                    end
                end)
    
                ButtonFrame.MouseButton1Click:Connect(function()
                    if not ElementButton.Locked then
                        ElementButton.Activate()
                    end
                end)

                ButtonFrame.MouseButton2Click:Connect(function()
                    ElementButton.Toggle()
                end)

                if ElementButton.Type == "Toggle" then
                    ElementButton.Set(ElementButton.Enabled)
                end
            end

            return ElementButton
        end

        function Tab.Toggle()
            Tab.Opened = not Tab.Opened

            TabHolder.Visible = Tab.Opened

            TabButton.BackgroundColor3 = Tab.Opened and Color3.fromRGB(35, 35, 35) or (Tab.Hovering and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(25, 25, 25))
            TabButtonText.TextTransparency = Tab.Opened and 0 or (Tab.Hovering and 0.25 or 0.5)
        end

        --// Tab Connections \\--
        do
            MakeDraggable(Top, TabHolder)

            Elements.Size = UDim2.new(1, 0, 0, math.clamp(ElementsListLayout.AbsoluteContentSize.Y, 0, workspace.CurrentCamera.ViewportSize.Y / 1.6))

            ElementsListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Elements.Size = UDim2.new(1, 0, 0, math.clamp(ElementsListLayout.AbsoluteContentSize.Y, 0, workspace.CurrentCamera.ViewportSize.Y / 1.6))
            end)
        
            TabButton.MouseEnter:Connect(function()
                Tab.Hovering = true
                if not Tab.Opened then
                    TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    TabButtonText.TextTransparency = 0.25
                end
            end)
        
            TabButton.MouseLeave:Connect(function()
                Tab.Hovering = false
                if not Tab.Opened then
                    TabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                    TabButtonText.TextTransparency = 0.5
                end
            end)
        
            TabButton.MouseButton1Click:Connect(function()
                task.spawn(Tab.Toggle)
            end)

            Tab.Toggle()
        end

        return Tab
    end

    --// Window Connections \\--
    do
        MakeDraggable(Top, MainWindow)
    end

    return Window
end


local ModalElement = Create("TextButton", {
    BackgroundTransparency = 1,
    Modal = true,
    Size = UDim2.new(0, 0, 0, 0),
    Text = "",
    Visible = false,
    Parent = UI
})

function Midnight.Toggle()
    Midnight.Opened = not Midnight.Opened

    ModalElement.Visible = Midnight.Opened
    Windows.Visible = Midnight.Opened
    Midnight.Blur.Enabled = Midnight.Opened

    if Midnight.Opened and not Midnight.Studio then        
        task.spawn(function()
            local oldMouseIconEnabled = UserInputService.MouseIconEnabled

            local cursor = Drawing.new("Triangle")
            cursor.Thickness = 1
            cursor.Filled = true
            cursor.Visible = true

            local cursorOutline = Drawing.new("Triangle")
            cursorOutline.Thickness = 1
            cursorOutline.Filled = false
            cursorOutline.Color = Color3.new(0, 0, 0)
            cursorOutline.Visible = true

            while Midnight.Opened and UI.Parent do
                UserInputService.MouseIconEnabled = false

                local mousePos = UserInputService:GetMouseLocation()

                cursor.Color = Color3.new(1, 1, 1)

                cursor.PointA = Vector2.new(mousePos.X, mousePos.Y);
                cursor.PointB = Vector2.new(mousePos.X + 12, mousePos.Y + 4);
                cursor.PointC = Vector2.new(mousePos.X + 4, mousePos.Y + 12);

                cursorOutline.PointA = cursor.PointA;
                cursorOutline.PointB = cursor.PointB;
                cursorOutline.PointC = cursor.PointC;

                RunService.RenderStepped:Wait()
            end

            UserInputService.MouseIconEnabled = oldMouseIconEnabled

            cursor:Remove()
            cursorOutline:Remove()
        end)
    end
end

function Midnight.Unload()
    for _, connection in pairs(Midnight.Connections) do
        connection:Disconnect()
    end

    Midnight.Blur:Destroy()
    UI:Destroy()

    if Midnight.OnUnload then
        Midnight.OnUnload()
    end
end


Midnight.AddConnection(UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent)
    if not gameProcessedEvent then
        if input.KeyCode == Midnight.ToggleKeybind then
            task.spawn(Midnight.Toggle)
        --[[
        elseif input.KeyCode == Enum.KeyCode.End then
            Midnight.Unload()]]
        end
    end
end))


return Midnight
