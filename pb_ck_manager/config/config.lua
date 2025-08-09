Config = {}

-- Příkazy
Config.CKCommand = 'ckmenu'

-- Kdo smí použít CK
Config.AllowedGroups = { 'admin', 'owner' }

-- Webhook vyhrazený pro CK logy
Config.DiscordWebhookCK = 'YOUR_WEBHOOK' -- vyplň si URL

-- (Volitelné) další tabulky k vyčištění podle owner/identifier
-- nech prázdné, pokud nechceš zásahy mimo users/owned_vehicles
Config.ExtraOwnerTables = {
  -- { table = 'addon_account_data', column = 'owner' },
--   { table = 'datastore_data',    column = 'owner' },
  -- { table = 'user_licenses',     column = 'owner' },
}

-- Bezpečnostní pojistka – vyžádat slovíčko CONFIRM v posledním kroku
Config.RequireConfirmWord = true
Config.ConfirmWord = 'CK'

-- Texty
Config.Locale = {
  no_perm = 'Nemáš oprávnění.',
  invalid_id = 'Neplatné ID hráče.',
  not_found = 'Postava nenalezena.',
  done = 'CK proběhlo. Postava a vozidla odstraněny.',
  fail = 'Chyba databáze.',
  confirm_header = 'Potvrdit CK',
  confirm_content = 'Opravdu chceš provést CK?\nTato akce je nevratná.',
  confirm_word = 'Pro potvrzení napiš: %s',
}
