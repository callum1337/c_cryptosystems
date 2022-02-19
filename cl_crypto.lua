local cfg = module("cfg/cfg_crypto")
local selected_system = nil
local selected_managed_system = nil
local cryptoprice = 0

local machines_owned = {}



RMenu.Add('CryptoMiner', 'main', RageUI.CreateMenu("Callum's Crypto", "~g~Crypto Systems",1250,100))
RMenu.Add('CryptoMiner', 'buy_systems',  RageUI.CreateSubMenu(RMenu:Get("CryptoMiner", "main")))
RMenu.Add('CryptoMiner', 'buy_systems_manage',  RageUI.CreateSubMenu(RMenu:Get("CryptoMiner", "buy_systems")))
RMenu.Add('CryptoMiner', 'manage_systems',  RageUI.CreateSubMenu(RMenu:Get("CryptoMiner", "main")))
RMenu.Add('CryptoMiner', 'manage_systems_sub',  RageUI.CreateSubMenu(RMenu:Get("CryptoMiner", "manage_systems")))


RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get('CryptoMiner', 'main')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            RageUI.Button("Buy Systems", "", {}, true, function(Hovered, Active, Selected) 
                if Selected then end
            end, RMenu:Get("CryptoMiner", "buy_systems"))

            RageUI.Button("Manage Systems", "", {}, true, function(Hovered, Active, Selected) 
                if Selected then 
                    TriggerServerEvent("vRPCrypto:CRYPTO:ReceiveMiners")
                end
            end, RMenu:Get("CryptoMiner", "manage_systems"))
        end)
    end
    if RageUI.Visible(RMenu:Get('CryptoMiner', 'buy_systems')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            for i=1, #cfg.systems do
                RageUI.Button(cfg.systems[i].name, "", {}, true, function(Hovered, Active, Selected)
                    if Selected then 
                        selected_system = cfg.systems[i]
                    end
                end, RMenu:Get("CryptoMiner", "buy_systems_manage"))
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('CryptoMiner', 'buy_systems_manage')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            RageUI.Separator("GPU: "..selected_system.gpu, function() end)
            RageUI.Separator("CPU: "..selected_system.cpu, function() end)
            RageUI.Separator("Amount Per Minute "..selected_system.stringedFormat, function() end)
            RageUI.Button("Buy", '£'..GetMoneyString2(selected_system.price), {}, true, function(Hovered, Active, Selected)
                if Selected then 
                    TriggerServerEvent('vRPCrypto:buy_crypto_system', selected_system)
                end
            end, RMenu:Get("CryptoMiner", "main"))
        end)
    end
    if RageUI.Visible(RMenu:Get('CryptoMiner', 'manage_systems')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            for i=1, #machines_owned do
                RageUI.Button('Machine Id: '..machines_owned[i].machineid, cfg.systems[machines_owned[i].pc_id].name, {}, true, function(Hovered, Active, Selected)
                    if Selected then 
                        selected_managed_system = machines_owned[i]
                    end
                end, RMenu:Get("CryptoMiner", "manage_systems_sub"))
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('CryptoMiner', 'manage_systems_sub')) then
        RageUI.DrawContent({ header = false, glare = false, instructionalButton = false}, function()
            RageUI.Separator("GPU: "..cfg.systems[selected_managed_system.pc_id].gpu, function() end)
            RageUI.Separator("CPU: "..cfg.systems[selected_managed_system.pc_id].cpu, function() end)
            RageUI.Separator("Amount Per Minute "..cfg.systems[selected_managed_system.pc_id].stringedFormat, function() end)
            local amount_mined_string = noScience(tostring(selected_managed_system.amountmined))
            RageUI.Separator("Current Balance(BTC): "..amount_mined_string, function() end)
            RageUI.Button("Withdraw BTC", '£'..roundToWholeNumber((selected_managed_system.amountmined) * cryptoprice), {}, true, function(Hovered, Active, Selected)
                if Selected then 
                    TriggerServerEvent('vRPCrypto:Withdraw:Crypto', selected_managed_system)
                end
            end, RMenu:Get("CryptoMiner", "main"))
            RageUI.Button("Sell Machine","Amount Refunded: £".. roundToWholeNumber(cfg.systems[selected_managed_system.pc_id].price / 4), {}, true, function(Hovered, Active, Selected)
                if Selected then
                    TriggerServerEvent('vRPCrypto:Sell:System', selected_managed_system)
                end
            end, RMenu:Get("CryptoMiner", "main"))
            RageUI.Separator("~r~[WARNING]", function() end)
            RageUI.Separator("~r~If You Sell Your Machine", function() end)
            RageUI.Separator("~r~All Bitcoin Will Be Lost", function() end)
            RageUI.Separator("~r~Selling Machine = 25% Of Buy Price", function() end)


        end)
    end
end)

function roundToWholeNumber(num)
    return math.floor(num + 0.5)
end



function noScience(num)
    return string.format("%f", num)
end


function GetMoneyString2(cashString)
	local i, j, minus, int, fraction = tostring(cashString):find('([-]?)(%d+)([.]?%d*)')
	int = int:reverse():gsub("(%d%d%d)", "%1,")
	return minus .. int:reverse():gsub("^,", "") .. fraction 
end


RegisterNetEvent('vRPCryptocore:setCryptoPrice', function(price)
    cryptoprice = price
end)

RegisterNetEvent('vRPCrypto:CRYPTO:SetMiners', function(miners)
    machines_owned = miners
end)










Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        TriggerServerEvent('vRPCryptocore:getCryptoPrice')
    end
end)

Citizen.CreateThread(function()
    local v3 = vector3(1726.0233154297,4689.494140625,17.117039489746)
    while true do
        if isInArea(v3, 50.0) then 
            Draw3DText(v3, '~r~BTC: ~g~'..cryptoprice) 
        end
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function() 
    isCryptoMenu = false
    while true do
        local x,y,z = table.unpack(cfg.coords)
        local cfgcoords = vector3(x,y,z)
        if isInArea(cfgcoords, 100.0) then 
            DrawMarker(27, vector3(x,y,z-0.9), 0, 0, 0, 0, 0, 0, 0.8, 0.8, 0.8, 230, 0, 0, 150, 0, 0, 0, 0, 0, 0, 0)
        end
        if isCryptoMenu == false then
            if isInArea(cfgcoords, 1.4) then 
                alert('Press ~INPUT_CONTEXT~ to buy or manage your systems.')
                if IsControlJustPressed(0, 51) then 
                    RageUI.Visible(RMenu:Get("CryptoMiner", "main"), true)
                    isCryptoMenu = true
                end
            end
        end
        if isInArea(cfgcoords, 1.4) == false and isCryptoMenu then
            RageUI.ActuallyCloseAll()
            RageUI.Visible(RMenu:Get("CryptoMiner", "main"), false)
            isCryptoMenu = false
        end
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function() 
    while true do
        local x,y,z = table.unpack(cfg.exit)
        local cfgcoords = vector3(x,y,z)
        if isInArea(cfgcoords, 100.0) then 
            DrawMarker(27, vector3(x,y,z-0.9), 0, 0, 0, 0, 0, 0, 0.8, 0.8, 0.8, 230, 0, 0, 150, 0, 0, 0, 0, 0, 0, 0)
        end
        if isInArea(cfgcoords, 1.4) then 
            alert('Press ~INPUT_CONTEXT~ to exit the server room.')
            if IsControlJustPressed(0, 51) then 
                TriggerServerEvent('vRPCrypto:CRYPTO:EXIT')
            end
        end
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function() 
    while true do
        local x,y,z = table.unpack(cfg.enter)
        local cfgcoords = vector3(x,y,z)
        if isInArea(cfgcoords, 100.0) then 
            DrawMarker(27, vector3(x,y,z-0.9), 0, 0, 0, 0, 0, 0, 0.8, 0.8, 0.8, 230, 0, 0, 150, 0, 0, 0, 0, 0, 0, 0)
        end
        if isInArea(cfgcoords, 1.4) then 
            alert('Press ~INPUT_CONTEXT~ to enter the server room.')
            if IsControlJustPressed(0, 51) then 
                TriggerServerEvent('vRPCrypto:CRYPTO:ENTER')
            end
        end
        Citizen.Wait(0)
    end
end)

