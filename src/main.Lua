-- Ensure we have those values
_G.auto_anti_afk = _G.auto_anti_afk and true or false;
_G.auto_income_leave = _G.auto_income_leave and true or false;
_G.auto_rejoin = _G.auto_rejoin and true or false;

-- Avoid executing if we're not on unConventional
if not (game.PlaceId == 6673614635) then
    assert(false, "Not on unConventional!")
end

-- Use Iris Compatibility Script
loadstring(game:HttpGet("https://irisapp.ca/api/Scripts/IrisBetterCompat.lua"))()

-- Track whether we were kicked for income or not
local kicked_for_income = false;

-- Block of code to ensure we're spoofing TouchEnabled for more money (fools the localscript without messing with it)
do
    repeat wait() until game:IsLoaded();
    local PLAYERS = game:GetService("Players");
    -- Ensure we're on "mobile" whenever we rejoin
    if syn then
        PLAYERS.LocalPlayer.OnTeleport:Connect(function(State)
            if State == Enum.TeleportState.Started then
                syn.queue_on_teleport("loadstring(game:HttpGet(\"https://pastebin.com/raw/tUUGAeaH\", true))(); spoof(game:GetService(\"UserInputService\"), \"TouchEnabled\", true);")
            end
        end)
    elseif queue_on_teleport then
        PLAYERS.LocalPlayer.OnTeleport:Connect(function(State)
            if State == Enum.TeleportState.Started then
                queue_on_teleport("loadstring(game:HttpGet(\"https://pastebin.com/raw/tUUGAeaH\", true))(); spoof(game:GetService(\"UserInputService\"), \"TouchEnabled\", true);")
            end
        end)
    else
        error("You can't run this script without queue_on_teleport!")
    end

    -- If TouchEnabled is false, we rejoin to update it
    if not game:GetService("UserInputService").TouchEnabled then
        local time = 0;
        repeat
            time = time + game:GetService("RunService").Heartbeat:wait()
        until time >= 10
        game:GetService('TeleportService'):Teleport(game.PlaceId, PLAYERS.LocalPlayer)
    end
end

-- Custom wait function that uses Heartbeat
local waithb = function(s)
    local RUNSERVICE = game:GetService("RunService")
    
    if s then
        local time = 0;
        repeat
            time = time + RUNSERVICE.Heartbeat:wait() 
        until time >= s
    else
        RUNSERVICE.Heartbeat:wait() 
    end
end

-- Simple function to click Un-AFK button
function ClickUnAfkButton()
    repeat wait() until game:IsLoaded()
    local LOCALPLAYER = game:GetService("Players").LocalPlayer
    local PLAYER_UI = LOCALPLAYER:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
    local INCOME_TEXT = PLAYER_UI:WaitForChild("income")
    local UNAFK_BUTTON = INCOME_TEXT:WaitForChild("TextButton")
    
    if UNAFK_BUTTON.Visible == true then
        for _, func in pairs(getconnections(UNAFK_BUTTON.MouseButton1Click)) do
            func:Fire() 
        end
    end
end

-- Function to extract the answer for the Anti-AFK question
function ExtractAntiAfkResult()
    repeat wait() until game:IsLoaded()
    local LOCALPLAYER = game:GetService("Players").LocalPlayer
    local PLAYER_UI = LOCALPLAYER:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
    local ANTI_AFK_FRAME = PLAYER_UI:WaitForChild("AntiAFK")
    local QUESTION_TEXT = ANTI_AFK_FRAME:WaitForChild("question").Text
    local CLEANED_QUESTION = QUESTION_TEXT:gsub('[^0-9%+%-]', '') -- Thanks HamstaGang for inspiring me to use gsub!
    local ANSWER = loadstring("return " .. CLEANED_QUESTION)(); -- Thanks HamstaGang for making your friend's solution open-sourced! :D
    
    return ANSWER
end

-- Function to solve Anti-AFK
function SolveAntiAfk()
    repeat wait() until game:IsLoaded()
    local RUNSERVICE = game:GetService("RunService")
    local LOCALPLAYER = game:GetService("Players").LocalPlayer
    local PLAYER_UI = LOCALPLAYER:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
    local ANTI_AFK_FRAME = PLAYER_UI:WaitForChild("AntiAFK")
    local INCOME_TEXT = PLAYER_UI:WaitForChild("income")
    local UNAFK_BUTTON = INCOME_TEXT:WaitForChild("TextButton")
    
    if ANTI_AFK_FRAME.Visible == true or UNAFK_BUTTON.Visible == true then
        ClickUnAfkButton()
        
        waithb(math.random(5, 8))
        
        -- We find the text box which we would normally see
        local ACTIVE_TEXT_BOX;
        for _, instance in pairs(ANTI_AFK_FRAME:GetChildren()) do
            if instance.ClassName == "TextBox" then
                if instance.Visible == true then
                    ACTIVE_TEXT_BOX = instance;
                    break;
                end
            end
        end
        
        -- Then we type in the answer as if it was manually typed
        ACTIVE_TEXT_BOX:CaptureFocus()
        RUNSERVICE.Heartbeat:wait()
        ACTIVE_TEXT_BOX.Text = ExtractAntiAfkResult()
        RUNSERVICE.Heartbeat:wait()
        ACTIVE_TEXT_BOX:ReleaseFocus(true)
    end
end

-- Function to return our income as a number
function ExtractIncome()
    repeat wait() until game:IsLoaded()
    local LOCALPLAYER = game:GetService("Players").LocalPlayer
    local PLAYER_UI = LOCALPLAYER:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
    local INCOME_TEXT = PLAYER_UI:WaitForChild("income").Text
    local CLEANED_INCOME = INCOME_TEXT:gsub('[^0-9%+%-]', '')
    return(tonumber(CLEANED_INCOME))
end

-- Function that kicks if our income is below the given threshold for the given time using waithb
function KickForIncome(income_required, time_in_hours)
    repeat wait() until game:IsLoaded()
    local LOCALPLAYER = game:GetService("Players").LocalPlayer
    local KICK_TIME_IN_SECONDS = time_in_hours * 60 * 60 -- Conversion to seconds
    
    -- The if statements ensures that we weren't kicked already and that are below the threshold
    if not kicked_for_income and ExtractIncome() <= income_required then
        kicked_for_income = true;
        LOCALPLAYER:Kick("Kicked for Auto Income Leave | Left at " ..
            tostring(os.date('%H:%M', os.time())) .. 
            " | Rejoining in 2.5 hours");
        waithb(KICK_TIME_IN_SECONDS)
        game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
    end
end

-- Auto rejoin function if we're kicked for anything other than income leave, e.g., Connection is briefly lost.
spawn(function()
    repeat wait() until game:IsLoaded()
    local LOCALPLAYER = game:GetService("Players").LocalPlayer
    local PROMPT_OVERLAY = game:GetService("CoreGui"):WaitForChild("RobloxPromptGui", 3):WaitForChild("promptOverlay", 3);
    
    PROMPT_OVERLAY.DescendantAdded:Connect(function()
        if not kicked_for_income and _G.auto_rejoin then
            local ERROR_PROMPT = PROMPT_OVERLAY:FindFirstChild("ErrorPrompt")
            
            if ERROR_PROMPT then
                local ERROR_TITLE = ERROR_PROMPT:WaitForChild("TitleFrame", 3):WaitForChild("ErrorTitle", 3).Text;
                
                if ERROR_TITLE == "Disconnected" then
                    waithb(3) -- The wait is 3 seconds because this feature's main purpose is to keep AFK farming going
                    game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
                end
            end
        end
    end)
end)

-- This main spawned thread makes the script execute in the first place.
spawn(function()
    while not kicked_for_income do
        if _G.auto_anti_afk then
            pcall(SolveAntiAfk)
        end
        waithb(3)
        
        if _G.auto_income_leave then
            pcall(KickForIncome, 35, 2.5)
        end
        waithb(3)
    end
end)

-- Down here it's all of the UI
local Material = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))();

local Triantafyllo = Material.Load({
    Title = "unConventional UI by Triantafyllo",
    Style = 3,
    SizeX = 600,
    SizeY = 350,
    Theme = "Dark"
})

local Page = Triantafyllo.New({
    Title = "Income"
})

function ReturnChangelogString()
    local changelog_table = loadstring(game:HttpGet("https://raw.githubusercontent.com/Triantafyllo/unConventional-Fyllo-UI/main/changelog.lua"))();
    local final_string = ""
    for i,v in pairs(changelog_table) do
        final_string = final_string .. ("#- " .. i .. " -#")
        final_string = final_string .. "\n--- What's new? ---\n"
        for o,b in pairs(v) do
            final_string = final_string .. b .. "\n"
        end
        final_string = final_string .. "\n"
    end
    
    final_string = final_string:gsub("%s*$", '')
    final_string = final_string .. "\n"
    return final_string
end

local ChangelogButton = Page.Button({
    Text = "Show Version",
    Callback = function()
        Triantafyllo.Banner({Text = "Version 1.1.0 | First digit is major changes, second digit is minor changes, third digit is bugfixes"}) 
    end,
    Menu = {
        ["Print changelog"] = function(self)
            warn(ReturnChangelogString())
        end
    }
})

local AutoAFKToggle = Page.Toggle({
    Text = "Toggle Auto Anti-AFK questions",
    Callback = function(value)
        _G.auto_anti_afk = value
    end,
    Enabled = _G.auto_anti_afk,
    Menu = {
        Information = function(self)
            Triantafyllo.Banner({Text = "This feature auto-completes Anti-AFK questions for you; works on multiple instances, doesn't require window focus."}) 
        end,
        Warning = function(self)
            Triantafyllo.Banner({Text = "The developer is relatively active; HamstaGang's UI, the original one, has gotten many people tagged or even banned (due to being outdated). Don't use this feature after updates until the UI is updated too. (Look at the version number to know if it updated)"}) 
        end
    }
})

local AutoIncomeLeaveToggle = Page.Toggle({
    Text = "Toggle Auto Income Leave",
    Callback = function(value)
        _G.auto_income_leave = value
    end,
    Enabled = _G.auto_income_leave,
    Menu = {
        Information = function(self)
            Triantafyllo.Banner({Text = "This feature automatically kicks you when you hit 35 income and joins you back after your income is back to being full (2.5 hours)."}) 
        end
    }
})

local AutoRejoinToggle = Page.Toggle({
    Text = "Toggle Auto Rejoin",
    Callback = function(value)
        _G.auto_rejoin = value
    end,
    Enabled = _G.auto_rejoin,
    Menu = {
        Information = function(self)
            Triantafyllo.Banner({Text = "This feature automatically joins you back if you're kicked for anything other than Auto Income Leave."}) 
        end
    }
})
