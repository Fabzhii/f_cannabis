Config = {}



Config.PlaceTime = 5 
Config.FertilizeTime = 7

Config.RenderDistance = 5

Config.SpacingDist = 2.0
Config.InteractDist = 1.2

Config.CheckCoords = {
    enabled = true,
    MaxX = 10000,
    MinX = -10000,
    MaxY = 10000, 
    MinY = -10000,
    MaxZ = 10000, 
    MinZ = -10000,
}



Config.Cops = 1
Config.ItemCount = {15, 25}

Config.Language = 'DE'
Config.Locales = {
    ['DE'] = {
        ['interact'] = {'[E] - Mit Pflanze Interagieren', nil},

        ['no_cops'] = {'Es sind zu wenig Cops im Dienst!', 'error'},
        ['cant_place'] = {'Du kannst hier nichts plazieren!', 'error'},
        ['no_fertilizer'] = {'Du hast keinen Dünger dabei!', 'error'},

        ['planted'] = {'Du hast eine Cannabis Pflanze angebaut!', 'success'},
        ['fertilized'] = {'Du hast eine Cannabis Pflanze gedüngt!', 'success'},

        ['deleted'] = {'Du hast eine Cannabis Pflanze vernichtet!', 'info'},
    },
    ['EN'] = {
    },
}

Config.UiCss = 'fweed'
Config.UiName = 'Weed-Planzen'
Config.plantStage = 'Planzen Stufe:'
Config.Time = 'Zeit:'
Config.Progress = 'Fortschritt:'
Config.fertilize = 'Planze düngen'
Config.harvest = 'Planze ernten'
Config.eliminate = 'Planze vernichten'
Config.close = 'Menü schließen'


Config.Stages = {
    {
        time = 2, -- Default State when Spawned
        prop = 'bkr_prop_weed_01_small_01c',
    },
    {
        time = 3,
        prop = 'bkr_prop_weed_med_01a',
    },
    {
        time = 10,
        prop = 'bkr_prop_weed_lrg_01b',
    },
    {
        time = 15,
        prop = 'bkr_prop_weed_lrg_01a',
    },
    {
        time = 15,
        prop = 'bkr_prop_weed_lrg_01a',
    },
}

Config.Notifcation = function(notify)
    local message = notify[1]
    local notify_type = notify[2]
    lib.notify({
        position = 'top-right',
        description = message,
        type = notify_type,
    })
end 

Config.InfoBar = function(info, toggle)
    local message = info[1]
    local notify_type = info[2]
    if toggle then 
        lib.showTextUI(message, {position = 'left-center'})
    else 
        lib.hideTextUI()
    end
end 