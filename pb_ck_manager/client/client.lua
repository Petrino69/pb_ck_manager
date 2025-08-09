local ESX = exports['es_extended']:getSharedObject()

local function isAllowed()
    return lib.callback.await('pb_ck:isAllowed', false)
end

local function openCKMenu()
    if not isAllowed() then
        lib.notify({type='error', description=Config.Locale.no_perm})
        return
    end

    lib.registerContext({
        id = 'pb_ck_main',
        title = 'CK Manager',
        options = {
            {
                title = 'Online CK (podle server ID)',
                icon = 'user-xmark',
                onSelect = function()
                    local input = lib.inputDialog('Zadej server ID hráče', {
                        { type='number', label='Server ID', placeholder='např. 12', required=true, min=1 }
                    })
                    if not input or not tonumber(input[1]) then
                        lib.notify({type='error', description=Config.Locale.invalid_id})
                        return
                    end

                    local sid = tonumber(input[1])
                    -- Získání info z serveru, ověření že hráč je online
                    local info = lib.callback.await('pb_ck:getOnlineInfo', false, sid)
                    if not info or not info.identifier then
                        lib.notify({type='error', description=Config.Locale.not_found})
                        return
                    end

                    local confirm = lib.alertDialog({
                        header   = Config.Locale.confirm_header,
                        content  = string.format(
                            "%s\n\n**Hráč:** %s (ID %s)\n**Identifier:** %s\n**Vozidel:** %d",
                            Config.Locale.confirm_content,
                            info.name or 'Unknown', sid, info.identifier, info.vehCount or 0
                        ),
                        centered = true,
                        cancel   = true
                    })

                    if confirm ~= 'confirm' then return end

                    TriggerServerEvent('pb_ck:doCKOnline', sid)
                end
            },
            {
                title = 'Offline CK (podle identifieru)',
                icon = 'id-card',
                onSelect = function()
                    local input = lib.inputDialog('Zadej identifier postavy', {
                        { type='input', label='Identifier (např. char1:xxxxxxxx)', required=true, min=6 }
                    })
                    if not input or not input[1] or input[1] == '' then
                        lib.notify({type='error', description=Config.Locale.invalid_id})
                        return
                    end

                    local ident = input[1]
                    local info = lib.callback.await('pb_ck:getOfflineInfo', false, ident)
                    if not info or not info.exists then
                        lib.notify({type='error', description=Config.Locale.not_found})
                        return
                    end

                    local confirm = lib.alertDialog({
                        header   = Config.Locale.confirm_header,
                        content  = string.format(
                            "%s\n\n**Identifier:** %s\n**Vozidel:** %d",
                            Config.Locale.confirm_content,
                            ident, info.vehCount or 0
                        ),
                        centered = true,
                        cancel   = true
                    })

                    if confirm ~= 'confirm' then return end

                    TriggerServerEvent('pb_ck:doCKOffline', ident)
                end
            }
        }
    })
    lib.showContext('pb_ck_main')
end

RegisterCommand(Config.CKCommand, function()
    openCKMenu()
end, false)

RegisterNetEvent('pb_ck:notify', function(kind, msg)
    lib.notify({type = kind or 'inform', description = msg or ''})
end)
