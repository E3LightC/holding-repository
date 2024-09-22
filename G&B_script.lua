--// @_x4yz //--

--// Info. //--
--// If you have an axe, and can shove with it, press Q
--// When killing a group/horde of zombies, pressing Z or X will help with it will help clear them out //--
--// If you have a musket, holding it out and pressing B will make it spam the bayonet, you can shred a good bit of zombies //--
--// All hits done with melee will be sent to the server as if you hit the head //--

--// Binds. //--
--// Q / Shove Bind //--
--// Z or X / Murder Bind //--
--// B / Bayonet Spam Bind //--

--///////////////////////////////////////--
--//////////////////////////////////////--
--// code definitely can be improved //--
--/////////////// CODE ///////////////--

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Backpack = Player.Backpack
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local AFKSignal = Remotes:WaitForChild("OnAFKSignalReceived")

_G["BayonetSpam_Active"] = false
--// Binds.
if _G["ShoveBind"] ~= nil then 
    _G["ShoveBind"]:Disconnect()
end
if _G["MurderBind"] ~= nil then 
    _G["MurderBind"]:Disconnect()
end
if _G["BayonetSpamBind"] ~= nil then 
    _G["BayonetSpamBind"]:Disconnect()
end
if _G["BayonetSpam"] ~= nil then 
    _G["BayonetSpam"]:Disconnect()
end
--//

local ShoveRange = 6
local MurderRange = 9

--// true = ignore; 
--// false = don't ignore;
local ZombieTypesList = {
    ["Barrel"] = true;
    ["BigBoy"] = false;
    ["Crawler"] = false;
    ["Fast"] = false;
    ["Igniter"] = false;
    ["Normal"] = false;
    ["Sapper"] = false;
}

local ZombiesFolder = workspace:FindFirstChild("Zombies") or workspace:WaitForChild("Zombies")

local function GetMeleeWeapon()
    local Character = Player.Character

    if Character == nil then 
        print("[INFO]: Character doesn't exist?")
        return false
    end
    if Character.Parent == nil then 
        print("[INFO]: Character's parent is equal to nil")
        return false
    end

    local WeaponFound

    for _, Tool:Tool in pairs(Character:GetChildren()) do 
        if Tool ~= nil and Tool:IsA("Tool") and Tool.Parent ~= nil then 
            if Tool:FindFirstChild("MeleeBase") then 
                WeaponFound = Tool
                break
            end
        end
    end
    if WeaponFound == nil then 
        for _, Tool:Tool in pairs(Backpack:GetChildren()) do 
            if Tool ~= nil and Tool:IsA("Tool") and Tool.Parent ~= nil then 
                if Tool:FindFirstChild("MeleeBase") then 
                    WeaponFound = Tool
                    break
                end
            end
        end
    end

    if WeaponFound ~= nil then
        return WeaponFound, WeaponFound:FindFirstChildWhichIsA("RemoteEvent")
    end
    return false
end

local function GetZombiesInRange(Range:number)
    if Range == nil then 
        print("[INFO]: 'Range' is equal to nil.")
        return false
    end

    if typeof(Range) ~= "number" then 
        print("[INFO]: 'Range' is not a number.")
        return false
    end

    if Range <= 0 then 
        Range = 4
    end

    local Character = Player.Character
    local CharHRP = Character:FindFirstChild("HumanoidRootPart")

    if not CharHRP then 
        print("[INFO]: No HumanoidRootPart found.")
        return false
    end

    local ZombiesInRange = {}

    if Character ~= nil and Character.Parent ~= nil then 
        for _, Agent:Model in pairs(ZombiesFolder:GetChildren()) do 
            if Agent ~= nil and Agent.Parent ~= nil then 
                local HRP = Agent:FindFirstChild("HumanoidRootPart")

                local ZombieType = Agent:GetAttribute("Type")::string
                local IgnoreVal = ZombieTypesList[ZombieType]::boolean

                if HRP and IgnoreVal ~= nil and typeof(IgnoreVal) == "boolean" and not IgnoreVal then 
                    local Distance = (CharHRP.Position - HRP.Position).Magnitude

                    if Distance <= Range then 
                        table.insert(ZombiesInRange, Agent)
                    end
                end
            end
        end

        return ZombiesInRange
    end

    return false
end

local function SortFunc(Table, Func)
    if Table ~= nil and Func ~= nil then 
        if typeof(Table) ~= "table" then 
            print("[INFO]: 'Table' is not a table.")
            return false
        end
        
        if typeof(Func) ~= "function" then 
            print("[INFO]: 'Func' is not a function.")
            return false
        end

        for i, v in pairs(Table) do 
            task.spawn(function()
                Func(i, v)
            end)
        end
        
        return true
    end

    return false
end

_G["ShoveBind"] = UserInputService.InputBegan:Connect(function(Key, Process)
    if not Process then 
        if Key.KeyCode == Enum.KeyCode.Q then 
            if Player.Character ~= nil and Player.Character.Parent ~= nil then
                local Character = Player.Character
                local HRP = Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Torso")
                local ZombiesInRange = GetZombiesInRange(ShoveRange)

                if typeof(ZombiesInRange) ~= "table" then 
                    return
                end

                if not HRP then 
                    print("[INFO]: Character has no HumanoidRootPart/Torso?")
                    return
                end

                if #ZombiesInRange <= 0 then
                    print("[INFO]: No zombies found in range.")
                    return
                end

                local Weapon = Character:FindFirstChild("Axe") or Character:FindFirstChild("Carbine") or Backpack:FindFirstChild("Axe") or Backpack:FindFirstChild("Carbine")

                if Weapon and Weapon ~= nil and Weapon.Parent ~= nil then
                    local Remote = Weapon:FindFirstChildWhichIsA("RemoteEvent")

                    if Remote then
                        local BraceBlock = {
                            [1] = "BraceBlock";
                        }
                        local StopBraceBlock = {
                            [1] = "StopBraceBlock";
                        }
                        local Shove = {
                            [1] = "Shove"
                        }

                        if Weapon.Name == "Axe" then
                            Remote:FireServer(unpack(BraceBlock))
                            Remote:FireServer(unpack(StopBraceBlock))
                        elseif Weapon.Name == "Carbine" then
                            Remote:FireServer(unpack(Shove))
                        end

                        SortFunc(ZombiesInRange, function(Key, Agent)
                            if Agent ~= nil and Agent:IsA("Model") and Agent.Parent ~= nil and Agent:FindFirstChild("Head") and Agent:FindFirstChild("State") and (Agent:FindFirstChild("State").Value ~= "Stunned") then 
                                local StunArgs = {
                                    [1] = "FeedbackStun";
                                    [2] = Agent;
                                    [3] = HRP.Position;
                                }

                                Remote:FireServer(unpack(StunArgs))
                            end

                            task.wait()
                        end)
                    end
                end
            end
        end
    end
end)

_G["MurderBind"] = UserInputService.InputBegan:Connect(function(Key, Process)
    if not Process then 
        if Key.KeyCode == Enum.KeyCode.Z or Key.KeyCode == Enum.KeyCode.X then 
            if Player.Character ~= nil and Player.Character.Parent ~= nil then
                local ZombiesInRange = GetZombiesInRange(MurderRange)

                if typeof(ZombiesInRange) ~= "table" then 
                    return
                end

                if #ZombiesInRange <= 0 then
                    print("[INFO]: No zombies found in range.")
                    return
                end

                local Weapon, WeaponRemote = GetMeleeWeapon()

                if Weapon ~= nil and typeof(Weapon) ~= "boolean" then 
                    if WeaponRemote ~= nil and WeaponRemote:IsA("RemoteEvent") then 
                        local SwingArgs = {
                            [1] = "Swing";
                            [2] = "Over";
                        }

                        WeaponRemote["FireServer"](WeaponRemote, unpack(SwingArgs))

                        SortFunc(ZombiesInRange, function(Key, Agent) 
                            if Agent ~= nil and Agent:IsA("Model") and Agent.Parent ~= nil and Agent:FindFirstChild("Head") and Agent:FindFirstChild("State") and (Agent:FindFirstChild("State").Value ~= "Stunned") then 
                                local HitArgs = {
                                    [1] = "HitZombie";
                                    [2] = Agent;
                                    [3] = Agent:WaitForChild("Head").Position;
                                    [4] = true;
                                }

                                WeaponRemote["FireServer"](WeaponRemote, unpack(HitArgs))
                            end
                        end)
                    end
                end
            end
        end
    end
end)

_G["BayonetSpamBind"] = UserInputService.InputBegan:Connect(function(Key, Process)
    if not Process then 
        if Key.KeyCode == Enum.KeyCode.B then
            if (_G["BayonetSpam_Active"]) then 
                _G["BayonetSpam_Active"] = false

                if _G["BayonetSpam"] ~= nil then 
                    _G["BayonetSpam"]:Disconnect()
                end
            elseif not (_G["BayonetSpam_Active"]) then 
                _G["BayonetSpam_Active"] = true

                if _G["BayonetSpam"] ~= nil then 
                    _G["BayonetSpam"]:Disconnect()
                end

                _G["BayonetSpam"] = RunService.Heartbeat:Connect(function()
                    local Character = Player.Character

                    if Character ~= nil and Character.Parent ~= nil then 
                        local Musket = Character:FindFirstChild("Musket")

                        if Musket then 
                            local MusketRemote = Musket:FindFirstChildWhichIsA("RemoteEvent")
                            
                            if MusketRemote then 
                                local ThrustBayonet = {
                                    [1] = "ThrustBayonet";
                                }

                                MusketRemote["FireServer"](MusketRemote, unpack(ThrustBayonet))

                                task.wait()
                            end
                        end
                    end
                    
                    task.wait()
                end)
            end
        end
    end
end)

local OldNameCall = nil
OldNameCall = hookmetamethod(game, "__namecall", function(Remote, ...)
    local Args = {...}
    local NamecallMethod = getnamecallmethod()

    if not checkcaller() and NamecallMethod == "FireServer" then
        if Remote == AFKSignal or Remote.Name == "OnAFKSignalReceived" then
            print("[INFO]: AFK signal attempted to fire.")
            
            return task.wait(9e9)
        elseif Remote.Name == "ForceKill" then 
            print("[INFO]: ForceKill remote attempted to fire.")

            return task.wait(9e9)
        else
            if Args[1] ~= nil then 
                if Args[1] == "HitZombie" then 
                    Args[4] = true
                    local Agent = Args[2]
                    
                    if Agent ~= nil then
                        local ZombieType = Agent:GetAttribute("Type")::string
                        local IgnoreVal = ZombieTypesList[ZombieType]::boolean
                        
                        if typeof(IgnoreVal) == "boolean" and not IgnoreVal then
                            return OldNameCall(Remote, unpack(Args))
                        end

                        return task.wait(9e9)
                    elseif Agent == nil then
                        return OldNameCall(Remote, ...)
                    end
                end
            end
        end
    end

    return OldNameCall(Remote, ...)
end)

print("[INFO]: script successfully executed!")
