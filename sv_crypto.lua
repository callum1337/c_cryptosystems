local cryptoprice = 0
local url = "https://blockchain.info/ticker"



local cfg = module("cfg/cfg_crypto")



function getBitcoinCurrentPrice() 
    local p = promise.new()
    PerformHttpRequest(url, function(err, res)
        local res = json.decode(res)
        price = res.GBP.buy
        if err == 200 then 
            p:resolve(res.GBP.buy)
        end
    end)
    cryptoprice = Citizen.Await(p)
end

Citizen.CreateThread(function()
    while true do
        getBitcoinCurrentPrice()
        Citizen.Wait(5000)
     end
end)

RegisterServerEvent('vRPCryptocore:getCryptoPrice', function()
    TriggerClientEvent('vRPCryptocore:setCryptoPrice', source, cryptoprice)
end)

function CalculateBitcoin(amount)
    return cryptoprice * amount
end

RegisterServerEvent('vRPCrypto:Withdraw:Crypto')
AddEventHandler('vRPCrypto:Withdraw:Crypto', function(system)
    local source = source
    local user_id = vRP.getUserId(source)
    local player_coords = GetEntityCoords(GetPlayerPed(source))
    local x,y,z = table.unpack(cfg.coords)
    local manage_spot = vector3(x,y,z)
    local amount_bank = roundToWholeNumber(CalculateBitcoin(system.amountmined))
    if system.user_id == user_id then
        if #(player_coords - manage_spot) < 5 then
            exports['ghmattimysql']:executeSync("UPDATE c_cryptominers SET amountmined = 0 WHERE user_id = @user_id AND machineid = @machineid", {user_id = user_id, machineid = system.machineid}, function() end)
            vRP.giveBankMoney(user_id, CalculateBitcoin(system.amountmined))
            vRPclient.notifyPicture(source,{"CHAR_BANK_MAZE",1,'Crypto Systems',false,"Withdraw Successfull: £"..amount_bank})
        else
            print(user_id .. " Is Cheating Or He Moved Away From The Mining Spot")
        end
    else
        print(user_id .. " Is Cheating")
    end 
end)

RegisterServerEvent('vRPCrypto:Sell:System')
AddEventHandler('vRPCrypto:Sell:System', function(system)
    local source = source
    local user_id = vRP.getUserId(source)
    local system_user_id = system.user_id
    local player_coords = GetEntityCoords(GetPlayerPed(source))
    local x,y,z = table.unpack(cfg.coords)
    local manage_spot = vector3(x,y,z)
    local sell_amount = roundToWholeNumber(cfg.systems[system.pc_id].price / 4)
    if system_user_id == user_id then
        if #(player_coords - manage_spot) < 5 then
            exports['ghmattimysql']:executeSync("DELETE FROM c_cryptominers WHERE user_id = @user_id AND machineid = @machineid", {user_id = user_id, machineid = system.machineid}, function()end)
            vRP.giveMoney(user_id,sell_amount)
            vRPclient.notifyPicture(source,{"CHAR_BANK_MAZE",1,'Crypto Systems',false,"You've been paid! Amount: £"..sell_amount})
        else
            print(user_id .. " Is Cheating Or He Moved Away From The Mining Spot")
        end
    else
        print(user_id .. " Is Cheating")
    end
end)



RegisterServerEvent("vRPCrypto:buy_crypto_system")
AddEventHandler("vRPCrypto:buy_crypto_system", function(system)
    local player = source
    local price = system.price
    local idofmachine = system.id
    local amountPerMin = system.amountPerMin
    local user_id = vRP.getUserId(player)
    local player_coords = GetEntityCoords(GetPlayerPed(player))
    local x,y,z = table.unpack(cfg.coords)
    local system_coords = vector3(x,y,z)
    if #(player_coords - system_coords) < 7 then
        if vRP.tryPayment(user_id,system.price) then
            vRPclient.notify(player, {"~b~You bought a System For £"..price})
            vRPclient.notify(player, {"~p~ We Are Setting Up Your System"})
            exports['ghmattimysql']:executeSync("INSERT INTO c_cryptominers(user_id, pc_id,amountmined) VALUES( @user_id, @pc_id, @amountmined)", {user_id = user_id, pc_id = idofmachine, amountmined = 0}, function() end)        
        else
            vRPclient.notify(player, {"~r~You Do Not Have Enough Money In Your Wallet To Pay The Man."})
        end
    else
        print(user_id ..' Might Be Cheating, Take A Look')
    end
end)

RegisterServerEvent("vRPCrypto:CRYPTO:ENTER")
AddEventHandler('vRPCrypto:CRYPTO:ENTER', function()
    local player = source

    local coords_exit = cfg.exit
    local player_coords = GetEntityCoords(GetPlayerPed(player))
    local coords_enter = vector3(table.unpack(cfg.enter))
    local coords_exit = vector3(table.unpack(cfg.exit))
    if #(player_coords - coords_enter) < 5 then
        SetEntityCoords(GetPlayerPed(player), coords_exit)
        SetPlayerRoutingBucket(player, player+1)
    end
end)



RegisterServerEvent("vRPCrypto:CRYPTO:EXIT")
AddEventHandler('vRPCrypto:CRYPTO:EXIT', function()
    local player = source
    local coords_exit = cfg.exit
    local player_coords = GetEntityCoords(GetPlayerPed(player))
    local coords_enter = vector3(table.unpack(cfg.enter))
    local coords_exit = vector3(table.unpack(cfg.exit))
    if #(player_coords - coords_exit) < 6 then
        SetEntityCoords(GetPlayerPed(player), coords_enter)
        SetPlayerRoutingBucket(player, 0)

    end
end)

RegisterServerEvent("vRPCrypto:CRYPTO:ReceiveMiners")
AddEventHandler('vRPCrypto:CRYPTO:ReceiveMiners', function()
    local player = source
    local user_id = vRP.getUserId(player)
    local miners = exports['ghmattimysql']:executeSync("SELECT * FROM c_cryptominers WHERE user_id = @user_id", {user_id = user_id})
    TriggerClientEvent('vRPCrypto:CRYPTO:SetMiners', player, miners)
end)


--Citizen.CreateThread(function()
--    while true do
--        Citizen.Wait(60000)
--        systems = exports['ghmattimysql']:executeSync("SELECT * FROM c_cryptominers WHERE user_id = @uid", {uid = user_id})
--        for i,v in pairs(systems) do
--            local pc_id = v.pc_id
--            local pcPricePermMin = cfg.systems[pc_id].amountPerMin
--            exports['ghmattimysql']:executeSync("UPDATE c_cryptominers SET amountmined = @amount WHERE machineid = @muid AND user_id = @uid", {muid = v.machineid, uid = user_id, amount = tonumber(v.amountmined + pcPricePermMin)})
--        end
--    end
--end)




Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000)
        for i, p in pairs(GetPlayers()) do
            local user_id = vRP.getUserId(p)
            systems = exports['ghmattimysql']:executeSync("SELECT * FROM c_cryptominers WHERE user_id = @uid", {uid = user_id})
            if systems == nil then return end
            for i,v in pairs(systems) do
                local pc_id = v.pc_id
                local pcPricePermMin = cfg.systems[pc_id].amountPerMin
                exports['ghmattimysql']:executeSync("UPDATE c_cryptominers SET amountmined = @amount WHERE machineid = @muid AND user_id = @uid", {muid = v.machineid, uid = user_id, amount = tonumber(v.amountmined + pcPricePermMin)})
            end
        end
    end
end)
