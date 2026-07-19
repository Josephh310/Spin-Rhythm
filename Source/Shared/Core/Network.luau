local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remote = require(ReplicatedStorage.Packages.Remote)

local _RemoteFunction, _RemoteEvent, _UnreliableRemoteEvent = Remote.parent()

type RF<T..., R...> = Remote.Function<T..., R...>
type RE<T...> = Remote.Event<T...>

local Network = {}

function Network.FireClients<T...>(Event: RE<T...>, Recipients: {Player}, ...: T...)
    for _, Player in Recipients do
        Event:FireClient(Player, ...)
    end
end

function Network.FireAllClientsExcept<T...>(Event: RE<T...>, Except: Player | {Player}, ...: T...)
    local ExceptSet: {[Player]: true} = {}
    if typeof(Except) == "Instance" then
        ExceptSet[Except] = true
    else
        for _, Player in Except do
            ExceptSet[Player] = true
        end
    end
    for _, Player in Players:GetPlayers() do
        if ExceptSet[Player] then continue end
        Event:FireClient(Player, ...)
    end
end

function Network.FireClientsInRadius<T...>(Event: RE<T...>, Position: Vector3, Radius: number, ...: T...)
    for _, Player in Players:GetPlayers() do
        local Root = Player.Character and Player.Character.PrimaryPart
        if not Root then continue end
        if (Root.Position - Position).Magnitude > Radius then continue end
        Event:FireClient(Player, ...)
    end
end

return Network
