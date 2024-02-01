-- Fill Table 


local ox_inventory = exports.ox_inventory
local locales = Config.Locales[Config.Language]
plants = {}

isLoaded = false
Citizen.CreateThread(function()
    while isLoaded == false do 
        Citizen.Wait(1000)
        local playerData = ESX.GetPlayerData()
        if ESX.IsPlayerLoaded(PlayerId) then 
            isLoaded = true
            Citizen.Wait(1500)
            loadPlants()
        end
    end 
end)

function loadPlants()
    ESX.TriggerServerCallback('fcannabis:getData', function(data)
        for k,v in pairs(data) do 
            local pos = vector3(json.decode(v.position).x, json.decode(v.position).y, json.decode(v.position).z)
            table.insert(plants, {pos, v.plantid, v.stage, 0, false})
        end 
    end)
end 


AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		for k, v in pairs(plants) do
            DeleteObject(v[4])
		end
	end
end)

RegisterNetEvent('fcannabis:plantServer')
AddEventHandler('fcannabis:plantServer', function(pos, plantid)
    table.insert(plants, {pos, plantid, 1, 0, false})
end)

RegisterNetEvent('fcannabis:deletePlant')
AddEventHandler('fcannabis:deletePlant', function(plantid)
    for k,v in pairs(plants) do 
        if v[2] == plantid then 
            if v[5] == true then 
                DeleteObject(v[4])
            end 
            table.remove(plants, k)
        end 
    end 
end)

RegisterNetEvent('fcannabis:fertilizeServer')
AddEventHandler('fcannabis:fertilizeServer', function(plantid, newStage)
    for k,v in pairs(plants) do 
        if v[2] == plantid then 

            plants[k][3] = tonumber(newStage)

            if v[5] == true then 
                DeleteObject(v[4])
                plants[k][5] = false 
            end 
        end 
    end 
end)



Citizen.CreateThread(function()
    while true do 
        local pedCoords = GetEntityCoords(PlayerPedId())
        for k,v in pairs(plants) do 

            local pos = v[1]
            if #(pos - pedCoords) < Config.RenderDistance then 
                if v[5] == false then 
                    local obj = CreateObject(Config.Stages[v[3]].prop, pos, false, false)
                    Citizen.Wait(3)
                    PlaceObjectOnGroundProperly(obj)

                    while #(pos - GetEntityCoords(obj)) > 0.3 do 
                        Citizen.Wait(0)
                        PlaceObjectOnGroundProperly(obj)
                    end 

                    FreezeEntityPosition(obj, true)
                    plants[k][4] = obj
                    plants[k][5] = true 
                end 
            else 
                if v[5] == true then 
                    DeleteObject(v[4])
                    plants[k][4] = 0
                    plants[k][5] = false 
                end 
            end 
        end 
        Citizen.Wait(200)
    end 
end)    

-- Place Weed 

exports('plant', function()
    ESX.TriggerServerCallback('fcannabis:checkcount', function(xCount)
        if xCount >= Config.Cops then 
            checkcoords()
        else 
            Config.Notifcation(locales['no_cops'])
        end 
    end) 
end)

exports('fertilize', function()
    print('plate')
end)

function checkcoords()
    if Config.CheckCoords.enabled then 
        local pedCoords = GetEntityCoords(PlayerPedId())
        if pedCoords.x > Config.CheckCoords.MinX and pedCoords.x < Config.CheckCoords.MaxX then 
            if pedCoords.y > Config.CheckCoords.MinY and pedCoords.y < Config.CheckCoords.MaxY then
                if pedCoords.z > Config.CheckCoords.MinZ and pedCoords.z < Config.CheckCoords.MaxZ then
                    place()
                else 
                    Config.Notifcation(locales['cant_place'])
                end 
            else 
                Config.Notifcation(locales['cant_place'])
            end 
        else 
            Config.Notifcation(locales['cant_place'])
        end 
    else 
        place()
    end 
end 

function place()


    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local pedHeading = GetEntityHeading(ped)

    coords = vector3((pedCoords.x + (Sin(pedHeading) * (-1))), (pedCoords.y + Cos(pedHeading)), pedCoords.z)

    canplace = true 

    for k,v in pairs(plants) do 
        local pos = v[1]
        local dist = #(coords - pos)
        if dist < Config.SpacingDist then 
            canplace = false 
        end 
    end 

    if canplace then 

        TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_GARDENER_PLANT', 0, true)
        Citizen.Wait(Config.PlaceTime * 1000)
        ClearPedTasksImmediately(ped)

        local unique = GetRandomIntInRange(0, 9999999999)
        Config.Notifcation(locales['planted'])

        local obj = CreateObject(Config.Stages[1].prop, coords, false, false)
        Citizen.Wait(3)
        PlaceObjectOnGroundProperly(obj)
        Citizen.Wait(3)
        local pos = GetEntityCoords(obj)
        DeleteObject(obj)
        

        TriggerServerEvent('fcannabis:removeItem', 'cannabis_seed', 1)
        TriggerServerEvent('fcannabis:plantSQL', pos, unique)

    else 
        Config.Notifcation(locales['cant_place'])
    end 
end 

-- Check Pos

local markerNum = 0
local markeractive = false 

Citizen.CreateThread(function()
    while true do 
        local pedCoords = GetEntityCoords(PlayerPedId())

        isnearp = false 
        for k, v in pairs(plants) do 
            local plantid = v[2]
            local pos = v[1]
            if #(pedCoords - pos) < Config.InteractDist then 
                isnearp = true 

                if not markeractive then 
                    markeractive = true  
                    markerNum = k
                    Config.InfoBar(locales['interact'], true)
                end 

                if IsControlJustPressed(0, 38) then 
                    openweed(plantid)
                end 
            else 
                if markeractive and markerNum == k then 
                    markeractive = false 
                    Config.InfoBar(locales['interact'], false)
                end 
            end 
        end
        
        if isnearp then 
            Citizen.Wait(1)
        else 
            Citizen.Wait(200)
        end 
    end 
end)

function openweed(plantid)
    Citizen.Wait(150)
    openmenu(plantid)
end

function openmenu(plantid)
    ESX.TriggerServerCallback('fcannabis:getDataFromPlant', function(xData)

        local stages = Config.Stages[xData.stage + 1]

        local s_time = xData.time
        if s_time > stages.time then 
            s_time = stages.time
        end 

        p_time = (s_time .. '/' .. stages.time)
        p_progress = math.floor((xData.time / stages.time)*100)
        if p_progress > 100.0 then 
            p_progress = 100
        end 
        if p_progress > -1 and p_progress < 101 then 
            --
        else 
            p_progress = 0
        end 

        print(p_time, p_progress)
        print(json.encode(xData, {indent = true}))

        local options = {
            {
                title = Config.plantStage .. xData.stage,
                description = Config.plateStage_desc,
                icon = 'arrow-up',
            },
            {
                title = Config.Time .. p_time,
                description = Config.Time_desc,
                icon = 'stopwatch-20',
            },
            {
                title = Config.Progress .. p_progress.. '%',
                description = Config.Progress_desc,
                icon = 'bars-progress',
                progress = p_progress,
            },
        }

        if p_progress >= 100 then 
            if (xData.stage + 1) == #Config.Stages then 
                table.insert(options, {
                    title = Config.harvest, 
                    description = Config.harvest_desc,
                    onSelect = function()
                        harvest(plantid, xData.position)
                    end,
                })
            else 
                table.insert(options, {
                    title = Config.fertilize, 
                    description = Config.fertilize_desc,
                    onSelect = function()
                        fertilize(plantid, xData.stage)
                    end,
                })
            end 
        end 
        table.insert(options, {
            title = Config.eliminate, 
            description = Config.eliminate_desc, 
            onSelect = function()
                eliminate(plantid, xData.position)
            end,
        })

        lib.registerContext({
            id = 'f_cannabis',
            title = Config.UiName,
            options = options,
        })
        lib.showContext('f_cannabis')

    end, plantid) 
end 

function fertilize(plantid, stage)

    ESX.TriggerServerCallback('fcannabis:hasItem', function(xHas)
        if xHas then 
            local ped = PlayerPedId()
            local lib, anim = 'mp_arresting', 'a_uncuff'
            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(ped, lib, anim, 8.0, -8.0, -1, 0, 0.0, false, false, false)
            end)
            TriggerServerEvent('fcannabis:removeItem', 'cannabis_fertilizer', 1)
            TriggerServerEvent('fcannabis:fertilize', plantid, stage)
            Config.Notifcation(locales['fertilized'])
        else 
            Config.Notifcation(locales['no_fertilizer'])
        end 
    end, 'cannabis_fertilizer', 1)

end 

function harvest(plantid, pos)
    local ped = PlayerPedId()
    local lib, anim = 'mp_arresting', 'a_uncuff'
    ESX.Streaming.RequestAnimDict(lib, function()
        TaskPlayAnim(ped, lib, anim, 8.0, -8.0, -1, 0, 0.0, false, false, false)
    end)
    Citizen.Wait(500)
    TriggerServerEvent('fcannabis:eliminate', plantid, pos)
    local add = GetRandomIntInRange(Config.ItemCount[1], Config.ItemCount[2])
    TriggerServerEvent('fcannabis:addItem', 'cannabis', add)
    Citizen.Wait(1500)
    Config.InfoBar(locales['interact'], false)
end 

function eliminate(plantid, pos)
    local ped = PlayerPedId()
    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_STAND_FIRE', 0, true)
    Citizen.Wait(Config.PlaceTime * 1000)
    ClearPedTasksImmediately(ped)
    TriggerServerEvent('fcannabis:eliminate', plantid, pos)
    Config.Notifcation(locales['deleted'])
    Citizen.Wait(1500)
    Config.InfoBar(locales['interact'], false)
end 

