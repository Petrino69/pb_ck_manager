# 🪓 PB CK Manager

**PB CK Manager** je administrátorský nástroj pro FiveM servery (ESX), který umožňuje provést tzv. **CK** (character kill) – kompletní a nevratné smazání postavy včetně jejích vozidel a volitelně i dalších dat z databáze.

Script funguje jak pro **online** hráče (kick + smazání), tak pro **offline** postavy (podle identifieru).  
Součástí je **UI menu** přes `ox_lib`, notifikace a **Discord logy**.

---

## ✨ Funkce

- 📋 **UI menu** přes `ox_lib` – přehledná volba online/offline CK  
- 🔹 **Online CK** – zadáš Server ID → hráč je kicknut → jeho postava + vozidla jsou smazána  
- 🔹 **Offline CK** – zadáš `char1:xxxxx` identifier → data jsou smazána i když hráč není online  
- 🗑 **Mazání i z dalších tabulek** – volitelné (`Config.ExtraOwnerTables`)  
- 🔒 **Přístup jen pro vybrané admin groupy** (`Config.AllowedGroups`)  
- 🔔 **Notifikace** pro admina i hráče (v případě online CK)  
- 📜 **Discord logy** – obsahují informace o adminovi i cílové postavě (Steam, Discord ID, license atd.)  
- ⚙ **Možnost nastavit vlastní webhook** pro CK logy  

---

## 📦 Instalace

1. **Stažení & umístění**
   - Stáhni soubory a vlož složku `pb_ck_manager` do `resources/[admin]` (nebo jiné složky podle struktury).

2. **Závislosti**
   - [ox_lib](https://overextended.dev/ox_lib)
   - [oxmysql](https://github.com/overextended/oxmysql)
   - ESX (tested on ESX Legacy)
   
3. **Config úpravy**
   - Otevři `config.lua` a nastav:
     ```lua
     Config.CKCommand = 'ck' -- příkaz pro otevření menu
     Config.AllowedGroups = { 'admin', 'superadmin' } -- kdo smí používat
     Config.DiscordWebhookCK = 'TVŮJ_DISCORD_WEBHOOK' -- kam se posílají logy
     Config.RequireConfirmWord = true -- zda je nutné potvrzovací slovo
     Config.ConfirmWord = 'CK' -- slovo, které musí admin napsat pro potvrzení
     Config.ExtraOwnerTables = { -- volitelně další tabulky k čištění
       -- { table = 'some_table', column = 'owner' },
     }
     ```
   
4. **Server config**
   - Přidej do `server.cfg`:
     ```cfg
     ensure ox_lib
     ensure oxmysql
     ensure pb_ck_manager
     ```

---

## 🎮 Použití

- **/ck** → otevře menu
- **Online CK**:
  - Zadáš **Server ID hráče** (např. 15)
  - Zobrazí se info o postavě (jméno, identifier, počet vozidel)
  - Potvrdíš akci → hráč je **kicknut** → postava + vozidla jsou **smazána**
- **Offline CK**:
  - Zadáš **identifier** postavy (např. `char1:8744a77ed67fd47db653ed184cc4a0029371d264`)
  - Potvrdíš → postava + vozidla jsou **smazána**

---

## 📜 Discord logy

Log obsahuje:
- 👮 **Admin** – jméno, Server ID, Discord ID, Steam, license
- 🎯 **Cíl** – jméno (pokud online), Server ID, Discord ID, Steam, license
- 📌 **Identifier postavy**
- 🗑 **Typ akce** (Online CK / Offline CK)
- 🕒 **Čas provedení**

---

## ⚠️ Upozornění

- CK je **nevratná akce** – po provedení není možné postavu obnovit.
- Před použitím doporučujeme **zálohu databáze**.
- Pokud máš více tabulek, kde se ukládají data podle `identifier`, přidej je do `Config.ExtraOwnerTables`.

---

## 📄 Licence

Tento projekt je licencován pod **MIT licencí** – volně k použití i úpravám, ale bez záruky.

---

## 💡 Autor
Vytvořil **Petrino** – pokud máš dotazy nebo návrhy na úpravy, můžeš vytvořit issue na GitHubu nebo mě kontaktovat přes Discord.
