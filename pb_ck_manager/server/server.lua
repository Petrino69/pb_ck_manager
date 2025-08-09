local ESX = exports['es_extended']:getSharedObject()

-- ===== server-side perms helper 
local function isAllowedServer(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return false end
    local g = xPlayer.getGroup()
    for _, ag in ipairs(Config.AllowedGroups) do
        if g == ag then return true end
    end
    return false
end

-- ===== client-side callback pro rychlou kontrolu v UI 
lib.callback.register('pb_ck:isAllowed', function(source)
    return isAllowedServer(source)
end)

-- ===== IDs + logy
local function getIds(src)
    local ids = GetPlayerIdentifiers(src)
    local out = { discord='N/A', steam='N/A', license='N/A' }
    for _, id in ipairs(ids) do
        if id:sub(1,8) == 'discord:' then out.discord = id:sub(9)
        elseif id:sub(1,6) == 'steam:' then out.steam = id:sub(7)
        elseif id:sub(1,8) == 'license:' then out.license = id:sub(9)
        end
    end
    return out
end

local function baseEmbed(title, color)
    return { title = title or 'CK Log', color = color or 16733525,
        timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
        footer = { text = os.date('%d.%m.%Y %H:%M:%S') } }
end

local function fmtUserBlock(title, name, src, ids)
    local lines = {
        ('**Jméno:** %s'):format(name or 'Unknown'),
        ('**Server ID:** %s'):format(src or 'N/A'),
        ('**Discord:** %s'):format(ids.discord ~= 'N/A' and ('<@%s> (`%s`)'):format(ids.discord, ids.discord) or 'N/A'),
        ('**Steam:** `%s`'):format(ids.steam),
        ('**License:** `%s`'):format(ids.license)
    }
    return { name = title, value = table.concat(lines, '\n'), inline = true }
end

local function sendCKLog(embed)
    local webhook = Config.DiscordWebhookCK
    if not webhook or webhook == '' then return end
    PerformHttpRequest(webhook, function() end, 'POST',
        json.encode({ username = 'CK Manager', embeds = { embed } }),
        { ['Content-Type'] = 'application/json' })
end

-- ===== Helpery
local function countVehicles(identifier)
    local rows = exports.oxmysql:executeSync('SELECT COUNT(*) AS c FROM owned_vehicles WHERE owner = ?', { identifier })
    return rows and rows[1] and rows[1].c or 0
end

-- ===== Callbacky pro UI 
lib.callback.register('pb_ck:getOnlineInfo', function(source, sid)
    if not isAllowedServer(source) then return nil end
    local sidNum = tonumber(sid)
    if not sidNum then return nil end
    local xp = ESX.GetPlayerFromId(sidNum)
    if not xp then return nil end
    local ident = xp.identifier
    return {
        name = GetPlayerName(xp.source),
        identifier = ident,
        vehCount = countVehicles(ident)
    }
end)

lib.callback.register('pb_ck:getOfflineInfo', function(source, ident)
    if not isAllowedServer(source) then return nil end
    if not ident or ident == '' then return nil end
    local u = exports.oxmysql:executeSync('SELECT identifier FROM users WHERE identifier = ? LIMIT 1', { ident })
    return { exists = (u and u[1] ~= nil), vehCount = u and u[1] and countVehicles(ident) or 0 }
end)

-- ===== Tvrdé CK
local function purgeExtraTables(identifier)
    if not Config.ExtraOwnerTables then return end
    for _, t in ipairs(Config.ExtraOwnerTables) do
        if t.table and t.column then
            exports.oxmysql:executeSync(('DELETE FROM `%s` WHERE `%s` = ?'):format(t.table, t.column), { identifier })
        end
    end
end

local function hardDeleteCharacter(identifier)
    exports.oxmysql:executeSync('DELETE FROM owned_vehicles WHERE owner = ?', { identifier })
    exports.oxmysql:executeSync('DELETE FROM users WHERE identifier = ?', { identifier })
    purgeExtraTables(identifier)
    local u = exports.oxmysql:executeSync('SELECT 1 FROM users WHERE identifier = ? LIMIT 1', { identifier })
    local v = exports.oxmysql:executeSync('SELECT 1 FROM owned_vehicles WHERE owner = ? LIMIT 1', { identifier })
    return (not (u and u[1])) and (not (v and v[1]))
end

-- ===== Online CK
RegisterNetEvent('pb_ck:doCKOnline', function(sid)
    local src = source
    if not isAllowedServer(src) then
        TriggerClientEvent('pb_ck:notify', src, 'error', Config.Locale.no_perm); return
    end

    local sidNum = tonumber(sid)
    if not sidNum then
        TriggerClientEvent('pb_ck:notify', src, 'error', Config.Locale.invalid_id); return
    end

    local xp = ESX.GetPlayerFromId(sidNum)
    if not xp then
        TriggerClientEvent('pb_ck:notify', src, 'error', Config.Locale.not_found); return
    end

    local ident      = xp.identifier
    local targetSrc  = xp.source
    local targetName = GetPlayerName(targetSrc) or 'Unknown'
    local adminIds   = getIds(src)
    local targetIds  = getIds(targetSrc)

    -- 1) kick
    DropPlayer(targetSrc, 'Tvoje postava byla CK (Character Kill) administrátorem. Kontaktuj podporu.')

    -- 2) po krátké prodlevě smažeme data
    SetTimeout(1500, function()
        local ok = hardDeleteCharacter(ident)
        if not ok then
            TriggerClientEvent('pb_ck:notify', src, 'error', Config.Locale.fail); return
        end

        TriggerClientEvent('pb_ck:notify', src, 'success', Config.Locale.done)

        -- 3) log
        local embed = baseEmbed('☠️ CK – Online', 16733525)
        embed.fields = {
            fmtUserBlock('👮 Admin', GetPlayerName(src) or 'Unknown', src, adminIds),
            fmtUserBlock('🎯 Cíl (hráč)', targetName, sidNum, targetIds),
            { name='Identifier', value=('`%s`'):format(ident), inline=false },
            { name='Akce', value='Kick → hard delete: users + owned_vehicles (+ extra tabulky)', inline=false }
        }
        sendCKLog(embed)
    end)
end)

-- ===== Offline CK
RegisterNetEvent('pb_ck:doCKOffline', function(identifier)
    local src = source
    if not isAllowedServer(src) then
        TriggerClientEvent('pb_ck:notify', src, 'error', Config.Locale.no_perm); return
    end

    if not identifier or identifier == '' then
        TriggerClientEvent('pb_ck:notify', src, 'error', Config.Locale.not_found); return
    end

    local u = exports.oxmysql:executeSync('SELECT identifier FROM users WHERE identifier = ? LIMIT 1', { identifier })
    if not u or not u[1] then
        TriggerClientEvent('pb_ck:notify', src, 'error', Config.Locale.not_found); return
    end

    local ok = hardDeleteCharacter(identifier)
    if not ok then
        TriggerClientEvent('pb_ck:notify', src, 'error', Config.Locale.fail); return
    end

    TriggerClientEvent('pb_ck:notify', src, 'success', Config.Locale.done)

    local embed = baseEmbed('☠️ CK – Offline', 16733525)
    local adminIds = getIds(src)
    embed.fields = {
        fmtUserBlock('👮 Admin', GetPlayerName(src) or 'Unknown', src, adminIds),
        { name='Identifier', value=('`%s`'):format(identifier), inline=false },
        { name='Akce', value='Hard delete: users + owned_vehicles (+ extra tabulky)', inline=false }
    }
    sendCKLog(embed)
end)
