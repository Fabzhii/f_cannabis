
local ox_inventory = exports.ox_inventory

ESX.RegisterCommand({'clearcannabis'}, 'admin', function(xPlayer, args, showError)
    MySQL.Async.fetchAll('SELECT * FROM f_cannabis', {
    }, function(data)
        for k,v in pairs(data) do 
            MySQL.Async.execute('DELETE FROM f_cannabis WHERE plantid = @plantid', {
                ['@plantid']  = v.plantid,
            })
        end 
    end)
    print('-- SQL CLEARED --')
end, true)


Citizen.CreateThread(function()
    while true do
        MySQL.Async.fetchAll('SELECT * FROM f_cannabis', {
        }, function(data)
            for k,v in pairs(data) do 
                local pos = v.position
                local time = v.time + 1
                if time > Config.Stages[v.stage].time + 10 then 
                    MySQL.Async.execute('DELETE FROM f_cannabis WHERE plantid = @plantid', {
                        ['@plantid']  = v.plantid,
                    })
                    Citizen.Wait(500)
                    TriggerClientEvent('fcannabis:deletePlant', -1, plantid)
                else 
                    MySQL.Async.execute('UPDATE f_cannabis SET time = @time WHERE position = @position', {
                        ['@position']  = pos,
                        ['@time'] = time,
                    })
                end 
            end 
        end)
        Citizen.Wait(60000)
    end 
end)

RegisterServerEvent('fcannabis:removeItem')
AddEventHandler('fcannabis:removeItem', function(item, count)
    exports.ox_inventory:RemoveItem(source, item, count, nil)
end)

RegisterServerEvent('fcannabis:addItem')
AddEventHandler('fcannabis:addItem', function(item, count)
    exports.ox_inventory:AddItem(source, item, count, nil)
end)

RegisterServerEvent('fcannabis:plantSQL')
AddEventHandler('fcannabis:plantSQL', function(pos, unique)
    
    MySQL.Async.execute("INSERT INTO f_cannabis (plantid, position, stage, time) VALUES (@plantid, @position, @stage, @time)", {
        ['@plantid'] = unique,
        ['@position'] = json.encode(pos),
        ['@stage'] = 1,
        ['@time'] = 0,
    })
    Citizen.Wait(500)
    TriggerClientEvent('fcannabis:plantServer', -1, pos, unique)
end)


RegisterServerEvent('fcannabis:fertilize')
AddEventHandler('fcannabis:fertilize', function(plantid, stage)
    MySQL.Async.execute('UPDATE f_cannabis SET stage = @stage WHERE plantid = @plantid', {
        ['@plantid']  = plantid,
        ['@stage'] = stage + 1,
    })
    MySQL.Async.execute('UPDATE f_cannabis SET time = @time WHERE plantid = @plantid', {
        ['@plantid']  = plantid,
        ['@time'] = 0,
    })
    Citizen.Wait(500)
    TriggerClientEvent('fcannabis:fertilizeServer', -1, plantid, stage + 1)
end)

RegisterServerEvent('fcannabis:eliminate')
AddEventHandler('fcannabis:eliminate', function(plantid, pos)
    MySQL.Async.execute('DELETE FROM f_cannabis WHERE plantid = @plantid', {
        ['@plantid']  = plantid,
    })
    Citizen.Wait(500)
    TriggerClientEvent('fcannabis:deletePlant', -1, plantid)
end)

-- CALLBACKS

ESX.RegisterServerCallback("fcannabis:getData", function(source, cb) 
    MySQL.Async.fetchAll('SELECT * FROM f_cannabis', {
    }, function(data)
        cb(data)
    end)
end) 

ESX.RegisterServerCallback("fcannabis:checkcount", function(source, cb) 
    local xPlayers = ESX.GetExtendedPlayers('job', 'police')
    count = #xPlayers
    cb(count)
end) 

ESX.RegisterServerCallback("fcannabis:getDataFromPlant", function(source, cb, plantid) 
    MySQL.Async.fetchAll('SELECT * FROM f_cannabis WHERE plantid = @plantid', {
        ['@plantid'] = plantid,
    }, function(data)
        cb(data[1])
    end)
end) 

ESX.RegisterServerCallback("fcannabis:hasItem", function(source, cb, item, count) 
    local count = exports.ox_inventory:GetItemCount(source, item) or 0 
    if count > 0 then 
        cb(true)
    else 
        cb(false)
    end 
end) 
