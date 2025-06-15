local Config = lib.require('config')

local function canSetJob(player, jobName)
    if jobName == "unemployed" then return true end
    return player.PlayerData.jobs[jobName] ~= nil
end

local function canSetGang(player, gangName)
    return player.PlayerData.gangs[gangName] ~= nil
end

RegisterNetEvent('randol_multijob:server:changeJob', function(job)
    local src = source
    local player = qbx:GetPlayer(src)

    if player.PlayerData.job.name == job then
        qbx:Notify(src, "You're already employed here", 'error')
        return
    end

    local jobInfo = qbx:GetJob(job)
    if not jobInfo then
        qbx:Notify(src, 'Invalid job.', 'error')
        return
    end

    if not canSetJob(player, job) then return end

    qbx:SetPlayerPrimaryJob(player.PlayerData.citizenid, job)
    qbx:Notify(src, ("You're hired at %s"):format(jobInfo.label))
    player.Functions.SetJobDuty(false)
end)

RegisterNetEvent('randol_multijob:server:changeGang', function(gang)
    local src = source
    local player = qbx:GetPlayer(src)

    if player.PlayerData.gang.name == gang then
        qbx:Notify(src, "You're already a part of this gang", 'error')
        return
    end

    local gangInfo = qbx:GetGang(gang)
    if not gangInfo then
        qbx:Notify(src, 'Invalid gang.', 'error')
        return
    end

    if not canSetGang(player, gang) then return end

    qbx:SetPlayerPrimaryGang(player.PlayerData.citizenid, gang)
    qbx:Notify(src, ("You're now a part of %s"):format(gangInfo.label))
end)

RegisterNetEvent('randol_multijob:server:deleteJob', function(job)
    local src = source
    local player = qbx:GetPlayer(src)
    local jobInfo = qbx:GetJob(job)

    if not jobInfo then
        qbx:Notify(src, 'Invalid job.', 'error')
        return
    end

    qbx:RemovePlayerFromJob(player.PlayerData.citizenid, job)
    qbx:Notify(src, ("You quit %s"):format(jobInfo.label))
end)

RegisterNetEvent('randol_multijob:server:deleteGang', function(gang)
    local src = source
    local player = qbx:GetPlayer(src)
    local gangInfo = qbx:GetGang(gang)

    if not gangInfo then
        qbx:Notify(src, 'Invalid gang.', 'error')
        return
    end

    qbx:RemovePlayerFromGang(player.PlayerData.citizenid, gang)
    qbx:Notify(src, ("You left %s"):format(gangInfo.label))
end)