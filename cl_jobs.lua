local Config = lib.require('config')

local function viewGangs()
    local sharedGangs = qbx:GetGangs()
    local PlayerData = QBX.PlayerData
    local opts = {}
    for gang, grade in pairs(PlayerData.gangs) do
        local isDisabled = PlayerData.gang.name == gang
        local data = sharedGangs[gang]
        opts[#opts + 1] = {
            title = data.label,
            description = ('Grade: %s [%s]'):format(data.grades[grade].name, grade),
            icon = Config.GangIcons[gang] or 'fa-solid fa-user-ninja',
            arrow = true,
            disabled = isDisabled,
            event = 'randol_multijob:client:choiceMenu',
            args = {gangLabel = data.label, gang = gang, grade = grade},
        }
    end
    lib.registerContext({id = 'gang_menu', menu = 'multi_main', title = 'My Gangs', options = opts})
    lib.showContext('gang_menu')
end

local function viewJobs()
    local sharedJobs = qbx:GetJobs()
    local PlayerData = QBX.PlayerData
    local dutyStatus = PlayerData.job.onduty and 'On Duty' or 'Off Duty'
    local dutyIcon = PlayerData.job.onduty and 'fa-solid fa-toggle-on' or 'fa-solid fa-toggle-off'
    local colorIcon = PlayerData.job.onduty and '#5ff5b4' or 'red'
    local jobMenu = {
        id = 'job_menu',
        title = 'My Jobs',
        menu = 'multi_main',
        options = {
            {
                title = 'Toggle Duty',
                description = 'You are ' .. dutyStatus,
                icon = dutyIcon,
                iconColor = colorIcon,
                onSelect = function()
                    TriggerServerEvent('QBCore:ToggleDuty')
                    Wait(200)
                    viewJobs()
                end
            }
        }
    }
    local seenJobs = {}
    for job, grade in pairs(PlayerData.jobs) do
        local data = sharedJobs[job]
        if data then
            jobMenu.options[#jobMenu.options + 1] = {
                title = data.label,
                description = ('You are a %s [%s]\nYou make $%s per paycheck'):format(data.grades[grade].name, grade, data.grades[grade].payment),
                icon = Config.JobIcons[job] or 'fa-solid fa-briefcase',
                arrow = true,
                disabled = PlayerData.job.name == job,
                event = 'randol_multijob:client:choiceMenu',
                args = { jobLabel = data.label, job = job, grade = grade },
            }
            seenJobs[job] = true
        end
    end
    if sharedJobs["unemployed"] and not seenJobs["unemployed"] then
        local data = sharedJobs["unemployed"]
        jobMenu.options[#jobMenu.options + 1] = {
            title = data.label,
            description = 'You are Unemployed\nYou make $500 per paycheck',
            icon = Config.JobIcons["unemployed"] or 'fa-solid fa-user-slash',
            arrow = true,
            disabled = PlayerData.job.name == "unemployed",
            event = 'randol_multijob:client:choiceMenu',
            args = {jobLabel = data.label, job = "unemployed", grade = 0},
        }
    end
    lib.registerContext(jobMenu)
    lib.showContext('job_menu')
end

local function showMainMenu()
    lib.registerContext({
        id = 'multi_main',
        title = 'Management Menu',
        options = {
            {
                title = 'Jobs',
                description = 'View and manage your current employment',
                icon = 'fa-solid fa-briefcase',
                arrow = true,
                onSelect = viewJobs
            },
            {
                title = 'Gangs',
                description = 'View and manage your current situation',
                icon = 'fa-solid fa-user-ninja',
                arrow = true,
                onSelect = viewGangs
            }
        }
    })
    lib.showContext('multi_main')
end

AddEventHandler('randol_multijob:client:choiceMenu', function(args)
    local isJob = args.job ~= nil
    local title = isJob and 'Job Actions' or 'Gang Actions'
    local menu = isJob and 'job_menu' or 'gang_menu'
    local options = {
        {
            title = isJob and 'Switch Job' or 'Switch Gang',
            description = isJob and ('Switch to %s'):format(args.jobLabel) or ('Change affiliation to %s'):format(args.gangLabel),
            icon = 'fa-solid fa-circle-check',
            onSelect = function()
                TriggerServerEvent(isJob and 'randol_multijob:server:changeJob' or 'randol_multijob:server:changeGang', isJob and args.job or args.gang)
                Wait(200)
                if isJob then viewJobs() else viewGangs() end
            end
        }
    }
    if isJob then
        if args.job ~= "unemployed" then
            table.insert(options, {
                title = 'Quit Job',
                description = ('Quit working at %s'):format(args.jobLabel),
                icon = 'fa-solid fa-trash-can',
                onSelect = function()
                    TriggerServerEvent('randol_multijob:server:deleteJob', args.job)
                    Wait(200)
                    viewJobs()
                end
            })
        else
            table.insert(options, {
                title = 'Cannot Quit Civilian Job',
                description = 'You cannot quit your civilian/unemployed job.',
                icon = 'fa-solid fa-ban',
                disabled = true
            })
        end
    else
        table.insert(options, {
            title = 'Quit Gang',
            description = ('Leave your homies at %s behind'):format(args.gangLabel),
            icon = 'fa-solid fa-trash-can',
            onSelect = function()
                TriggerServerEvent('randol_multijob:server:deleteGang', args.gang)
                Wait(200)
                viewGangs()
            end
        })
    end
    lib.registerContext({id = 'choice_menu', title = title, menu = menu, options = options})
    lib.showContext('choice_menu')
end)

lib.addKeybind({name = 'multi', description = 'Job/Gang Management', defaultKey = 'F10', onPressed = function(self) showMainMenu() end})