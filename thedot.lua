dot = LibStub("AceAddon-3.0"):NewAddon("dot", "AceConsole-3.0", "AceEvent-3.0")

lastUpdated = 0
updateInterval = 0.1

key_map = {}
key_map["1"] = 0x31
key_map["2"] = 0x32
key_map["3"] = 0x33
key_map["4"] = 0x34
key_map["5"] = 0x35
key_map["6"] = 0x36
key_map["7"] = 0x37
key_map["8"] = 0x38
key_map["9"] = 0x39
key_map["0"] = 0x30
key_map["-"] = 0xBD
key_map["="] = 0xBB

key_map["E"] = 0x45
key_map["R"] = 0x52
key_map["F"] = 0x46
key_map["G"] = 0x47
key_map["Z"] = 0x5A
key_map["X"] = 0x58
key_map["C"] = 0x43
key_map["`"] = 0xC0

function dot:OnInitialize()
    -- Called when the addon is loaded
    self:Print("DOT LOADED: The Dot-2.0.0")
    self.lastUpdated = 0
    self.update_interval = 1
end

function dot:OnEnable()
    -- get the spec by looking for a specific spell in the spell books
    self.spec = getSpecId()
    self.casting = 0
    self.combat = 0
    self.follow = 0
    self.following = 0
    self.forceFollow = 0
    self.range = 0
    self.status = 0
    self.mount = 0
    self.lastUpdated = 0
    self:Print("DOT: Timer set to", self.lastUpdated)
	self:Print("DOT: Interval set to", self.update_interval)
    local specModules = {   "TheDot-Arms" ,
                            "TheDot-Fury" ,
                            "TheDot-Prot" , 
                            "TheDot-Elemental" ,
                            "TheDot-Enhancement" ,
                            "TheDot-Resto",
                            "TheDot-Ret",
                            "TheDot-Blood",
                            "TheDot-Frost",
                            "TheDot-Destruction",
                            "TheDot-Demonology",
                            "TheDot-Holy",
                            "TheDot-Havoc",
                            "TheDot-Vengeance",
                            "TheDot-Affliction",
                            "TheDot-Unholy",
                            "TheDot-Augmentation"
                        }

    
    local f = CreateFrame( "Frame" , "one" , UIParent )
    square_size = 15
    f:SetScript("OnUpdate", onUpdate)
    f:SetFrameStrata( "HIGH" )
    f:SetWidth( square_size * 2 )
    f:SetHeight( square_size )
    f:SetPoint( "TOPLEFT" )
    
    self.zero = CreateFrame( "StatusBar" , nil , f )
    self.zero:SetPoint( "TOPLEFT" )
    self.zero:SetWidth( square_size )
    self.zero:SetHeight( square_size )    
    self.zero:SetStatusBarTexture("Interface\\AddOns\\thedot\\Images\\Gloss")
    self.zero:SetStatusBarColor( 230/255 , 244/255 , 225/255 )

    self.one = CreateFrame( "StatusBar" , nil , f )
    self.one:SetPoint( "TOPLEFT" , square_size , 0 )
    self.one:SetWidth( square_size )
    self.one:SetHeight( square_size )    
    self.one:SetStatusBarTexture("Interface\\AddOns\\thedot\\Images\\Gloss")
    self.one:SetStatusBarColor( 0 , 0 , 0 )	
        
    -- self:Print( self.spec )
    local loaded , reason = LoadAddOn( specModules[self.spec] )
    if not loaded then
        self:Print( "Could not load Spec: ", reason )
    end
    self.one:SetStatusBarColor( self.spec/255 , 0 , 0 )
    --self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("UNIT_SPELLCAST_START")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    self:RegisterEvent("AUTOFOLLOW_BEGIN")
    self:RegisterEvent("AUTOFOLLOW_END")
    self:RegisterEvent("CHAT_MSG_WHISPER")
end

function dot:OnDisable()
    
end

function shouldIInterupt(unit)
    local badSpell = {}
    spell, rank, displayName, icon, startTime, endTime, isTradeSkill, castID, interrupt = UnitCastingInfo(unit)

    if not spell == nil then
        if interrupt == true then
            return true
        end
    end
end

function doDot(target, spell, nextCast)
    local s, scount, sexpirationTime, sisMine = isUnitDeBuffed(target, spell)
    if s ~= nil and sisMine == "player" then
        if sexpirationTime then
            sexpirein = sexpirationTime - GetTime();
        end
        if sexpirein > 0 and sexpirein < 2 then
            return ifPossible(spell, nextCast)
        end
    else
        return ifPossible(spell, nextCast)
    end
    return nextCast
end

function isUnitBuffed(unit, spellname)
    for i=1,40 do
        local name, _, count, _, _, expiresAt = UnitBuff(unit,i)
        if name == spellname then
            return true, count, expiresAt
        end
    end
    return false, 0, 0
end

function isUnitDeBuffed(unit, spellname)
    for i=1,40 do
        local name, _, count, _, _, expiresAt, owner = UnitDebuff(unit,i)
        if name == spellname then
            return true, count, expiresAt, owner
        end
    end
    return false, 0, 0
end

function ifPossible(spell, nextCast)
    s, scooldown = canCastNow( spell )

    --for k, v in pairs(spells) do
      --  print(k, v)
    --end
    if s == true then
        local m = spells[spell]
        if m == nil then
            print(m, spell)
        end
        return m
    else
        return nextCast
    end
end

function ifMacroPossible(spell, nextCast, realSpell)
    s, scooldown = canCastNow( realSpell )
    --for k, v in pairs(spells) do
    --    print(k, v)
    --end
    if s == true then
        local m = spells[spell]
        if m == nil then
            print(m, realSpell)
        end
        return m
    else
        return nextCast
    end
end

function debuffUp(spell)
    ret = true
    local d, drank, dicon, dcount, ddebuffType, dduration, dexpirationTime, cisMine, disStealable  = UnitDebuff("target",spell);
    if d ~= nil and disMine == "player" then
        if dexpirationTime then
            dexpirein = dexpirationTime - GetTime();
        end
        if dexpirein > 0 and dexpirein < 1 then
            ret = false
        end
    else
        ret = false
    end  
    return ret
end

function buffUp(spell)
    sbuff, srank, sicon, scount = UnitBuff( "player" , spell)
    if sbuff ~= nil then
        return true
    end
    return false
end

function canCastNow(inSpell)
    local start, duration, enable, inRange
    local usable, noRage = IsUsableSpell( inSpell )
    if SpellHasRange( inSpell ) then
        inRange = IsSpellInRange( inSpell , "target" )
    else
        inRange = 1
    end
    -- catch all.. ugly. AOE spell return nil
    if inRange == nil then
        inRange = 1
    end

    --print(GetSpellInfo( inSpell ))
    --print(inSpell, inRange)
    --print(inSpell, usable)
        if usable == true and inRange == 1 then
            start, duration, enable = GetSpellCooldown( inSpell )
            if start == 0 then
                return true , 0
            end
        else
            return false , 0
        end
    return false , (start+duration - GetTime())
end

function GetBindingActionText( command )
    local text
    local action, target = command:match( "^(%S+) ?(.*)$" )
    

    --if string.find(action, "ACTION") ~= nil then
    --	print(action)
    --end

    --slotOffset = (1 + (NUM_ACTIONBAR_PAGES + GetBonusBarOffset() - 1) * NUM_ACTIONBAR_BUTTONS)
    --print("Slot Offset = ", slotOffset)

	if action:sub( 1, 17 ) == "BONUSACTIONBUTTON" then
        actionN = tonumber( action:match( "%d+" ) )
        slotOffset = (NUM_ACTIONBAR_PAGES + GetBonusBarOffset() - 1) * NUM_ACTIONBAR_BUTTONS
        actionN = actionN + slotOffset
        
        local type, spell, subtype = GetActionInfo( actionN )
        local lActionText = GetActionText(actionN);
        
        if type == "companion" then
            spell = select( 2, GetCompanionInfo( "CRITTER", spell ) )
            text = spell
        elseif type == "equipmentset" then
            text = spell
        elseif type == "item" then
            spell = GetItemInfo( spell )
            text = spell
        elseif type == "macro" then
            if lActionText then
                text = lActionText
            end
            print("result", text, spell)
        elseif type == "spell" then
            spell = GetSpellInfo( spell )
            text = spell
        end
    end    

	if action:sub( 1, 12 ) == "ACTIONBUTTON" then
        actionN = tonumber( action:match( "%d+" ) )
        local type, spell, subtype = GetActionInfo( actionN )
        local lActionText = GetActionText(actionN)
        --print(type, spell)
        if type == "companion" then
            spell = select( 2, GetCompanionInfo( "CRITTER", spell ) )
            text = spell
        elseif type == "equipmentset" then
            text = spell
        elseif type == "item" then
            spell = GetItemInfo( spell )
            text = spell
        elseif type == "macro" then
            if lActionText then
                text = lActionText
            end
            print("result", text, spell)
        elseif type == "spell" then
            spell = GetSpellInfo( spell )
            text = spell
        end
    end
    if action:sub( 1, 14 ) == "MULTIACTIONBAR" then
        barN = tonumber( action:match( "%a+(%d+)%a+%d+" ) )
        actionT = tonumber( action:match( "%a+%d+%a+(%d+)" ) )
        actionN = barN*12 + actionT - 12
        local type, spell, subtype = GetActionInfo( actionN )
        local lActionText = GetActionText(actionN)
       -- print(type, spell)
        if type == "companion" then
            spell = select( 2, GetCompanionInfo( "CRITTER", spell ) )
            text = spell
        elseif type == "equipmentset" then
            text = spell
        elseif type == "item" then
            spell = GetItemInfo( spell )
            text = spell
        elseif type == "macro" then
            if lActionText then
                text = lActionText
            end
            print("result", text, spell)
        elseif type == "spell" then
            spell = GetSpellInfo( spell )
            text = spell
        end
    end

    return text
end

function saveme()
	    if action:sub( 1, 12 ) == "ACTIONBUTTON" then
        actionN = tonumber( action:match( "%d+" ) )
        local type, spell, subtype = GetActionInfo( actionN )
        if type == "companion" then
            spell = select( 2, GetCompanionInfo( "CRITTER", spell ) )
            text = spell
        elseif type == "equipmentset" then
            text = spell
        elseif type == "item" then
            spell = GetItemInfo( spell )
            text = spell
        elseif type == "macro" then
            print(spell)
            spell = GetMacroInfo( spell )
            print(spell)
            text = spell
        elseif type == "spell" then
            spell = GetSpellInfo( spell )
            text = spell
        end
    end
    if action:sub( 1, 14 ) == "MULTIACTIONBAR" then
        barN = tonumber( action:match( "%a+(%d+)%a+%d+" ) )
        actionT = tonumber( action:match( "%a+%d+%a+(%d+)" ) )
        actionN = barN*12 + actionT - 12
        local type, spell, subtype = GetActionInfo( actionN )
        if type == "companion" then
            spell = select( 2, GetCompanionInfo( "CRITTER", spell ) )
            text = spell
        elseif type == "equipmentset" then
            text = spell
        elseif type == "item" then
            spell = GetItemInfo( spell )
            text = spell
        elseif type == "macro" then
            spell = GetMacroInfo( spell )
            text = spell
        elseif type == "spell" then
            spell = GetSpellInfo( spell )
            text = spell
        end
    end
end

function reportActionButtons()
	local lActionSlot = 0;
	for lActionSlot = 1, 120 do
		local type, id, subType, spellID = GetActionInfo(lActionSlot)
		local lActionText = GetActionText(lActionSlot);
		local lActionTexture = GetActionTexture(lActionSlot);
		if lActionTexture then
			local lMessage = "Slot " .. lActionSlot .. ": [" .. lActionTexture .. "]";
			if lActionText then
				lMessage = lMessage .. " \"" .. lActionText .. "\"";
			end
			DEFAULT_CHAT_FRAME:AddMessage(lMessage);
			--print(lActionSlot, type, id, subType, spellID)
		end
	end
end

function GetBindings()
	reportActionButtons()
    spells = {}
    local i, j
    for i = 1, GetNumBindings() do
        
        local command, key1, key2 = GetBinding( i )
        --print(command, key1, key2)
        if command == "ACTIONBUTTON9" then
                spell = GetBindingActionText( command )
                if command ~= nil then
                    
                end
                print(spell,":" ,command,":", key1,":", key2)
        --      print(macro,":" ,command,":", key1,":", key2)
        end

        if command ~= "NONE" and command ~= "CLICK" then
            for j = 2, select( "#", GetBinding( i ) ) do
                
                local key = GetBindingText( select( j, GetBinding( i ) ), "KEY_" )
                local spell = GetBindingActionText( command )
                --print("command" , command)
                --print("key", key)
                --print(GetBindingActionText(GetBindingByKey("R")))
                --print(GetBindingActionText(GetBindingByKey("E")))
                --local type, id, subType, spellID = GetActionInfo(command)
                
                --if type == "macro" then
                --    local name, iconTexture, body, isLocal GetMacroInfo( id )
                --    print("macro name", name)
                --    spell = name     
                --end

                --if command == "ACTIONBUTTON9" then
                --    spell = GetBindingActionText( command )
                --    if command ~= nil then
                        
                --    end
                --    print(spell,":" ,command,":", key1,":", key2)
            --      print(macro,":" ,command,":", key1,":", key2)
                --end
                
                if spell ~= nil and key ~= "BINDING_HEADER_ACTIONBAR" and key ~= "BINDING_HEADER_MULTIACTIONBAR" then
                    --print(key,spell,command)
                    if key:sub(1, 24) ~= "BINDING_HEADER_ACTIONBAR" then
                        if command:sub( 6, 17 ) == "ACTIONBUTTON" then
                            --key = command:match( "%d+" )
                        end
                        --print("KEY", key, spell)
                        local hexkey = key_map[key]
                        spells[spell] = hexkey
                    end
                end
            end
        end
    end
    return spells
end

function dot:CHAT_MSG_WHISPER( filler , msg , who , poo , status , id , unkn , lineId , sguid )
    --if who == "Hexloob" or 
    --	who == "Feloob-DarkIron" or
    --	who == "Feloob-Hydraxis" or
      --  who == "Xloob" or 
    --    who == "Rexloob-DarkIron" or
    --    who == "Dloob-DarkIron" or
    --    who == "Dloob-Hydraxis" or
    --    who == "Sloob-DarkIron" or
    --    who == "Demoob-Hydraxis" or
    --    who == "Paloob-Hydraxis" then
        print("Got a message")
        if msg == "+" then
            self:Print("Force Following")
            self.forceFollow = 4
        end
        if msg == "-" then
            self.forceFollow = 0
        end
        self.mount = 0
        if msg == "up" and IsMounted() == false then
            self:Print("Not mounted, lets fix that..")
            self.mount = 8
        end
           -- self:Print("Mounted already..")
           -- self.mount = 0
           -- end
        --end
        if msg == "down" and IsMounted() == true then
            self:Print("On foot!")
            self.mount = 16
        end
        self.status = self.combat + self.follow + self.forceFollow + self.following
        self.one:SetStatusBarColor( self.spec/255 , self.status/255 , self.casting/255 );
    --end
end

function dot:meh(el)
	if (self.follow == nil) then
		DEFAULT_CHAT_FRAME:AddMessage("nil")
	else
		DEFAULT_CHAT_FRAME:AddMessage("yay")
		self:Print(el)
	end
end

function dot:Update()
	self.spec = getSpecId()
    self.combat = 0
    if InCombatLockdown() == true or UnitAffectingCombat("Focus") == true then
       	self.combat = 1
        self.follow = 0
    end
    
    if self.combat == 0 then
       	if self.follow == 0 then
           --self:Print("Need to follow")
           	if ( CheckInteractDistance("Focus", 4) ) then
                self:Print("Following")
               	self.follow = 2
           	end
       	end
    end

    if self.forceFollow == 4 then
       	if ( CheckInteractDistance("Focus", 4) ) then
           	self.follow = 2
       	end
    end
    self.status = self.combat + self.follow + self.forceFollow + self.following
    self.one:SetStatusBarColor( self.spec/255 , self.status/255 , self.casting/255 );
end

function onUpdate(self, elapsed)
	--self.lastUpdated = self.lastUpdated + elapsed
    lastUpdated = lastUpdated + elapsed
	--if (self.lastUpdated > self.update_interval) then
    if (lastUpdated > updateInterval) then
    	dot:Update()
    	lastUpdated = 0
    end
end

function getSpecId()
    local int id = 1
    local specSpells = { "Mortal Strike",
                         "Bloodthirst",
                         "Thunder Clap",
                         "Thunderstorm",
                         "Lava Lash",
                         "Earth Shield",
                         "Crusader Strike",
                         "Marrowrend",
                         "Obliterate",
                         "Chaos Bolt",
                         "Call Dreadstalkers",
                         "Light of Dawn",
                         "Eye Beam",
                         "Demon Spikes",
                         "Unstable Affliction",
                         "Festering Strike",
                         "Ebon Might"
                        }
    local specId
    
    while true do
    
        local spellName, spellSubName = GetSpellBookItemName( id, "spell" );
        if not spellName then
            --self:Print("No spec found", id)
            do break end
        end
    
        specId = 1   
        spell = specSpells[specId]
        while spell do
            if spellName == spell then
                return specId
            end
            specId = specId + 1
            spell = specSpells[ specId ]
        end 
        id = id + 1
    end
    return 1
end

function AddDot(offset, size)
    -- Add a single dots
    -- make room for the normal dots
    local real_offset = 3+offset
    raidDot = CreateFrame( "StatusBar" , nil , UIParent )
    raidDot:SetPoint( "TOPLEFT" , size*real_offset , 0)
    raidDot:SetWidth( size )
    raidDot:SetHeight( size )
    raidDot:SetStatusBarTexture("Interface\\AddOns\\thedot\\Images\\Gloss")
    raidDot:Hide()

    raidButton = CreateFrame("Button", nil, UIParent, "SecureActionButtonTemplate")
    raidButton:SetPoint( "TOPLEFT" , size*real_offset , 0)
    raidButton:SetWidth( size )
    raidButton:SetHeight( size )
    local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(offset)
    raidButton:SetAttribute("*type1", "target")
    raidButton:SetAttribute("unit", name)
    raidButton:Hide()
    return raidDot, raidButton
end

function dot:AUTOFOLLOW_BEGIN( f )
    self.following = 8
    self.status = self.combat + self.follow + self.forceFollow + self.following
    self.one:SetStatusBarColor( self.spec/255 , self.status/255 , self.casting/255 );
end

function dot:AUTOFOLLOW_END()
    self.following = 0
    self.status = self.combat + self.follow + self.forceFollow + self.following
    self.one:SetStatusBarColor( self.spec/255 , self.status/255 , self.casting/255 );
end

function dot:UNIT_SPELLCAST_START( f , p , s )
    -- spell cast has started, block stuff
    if p == "player" then
        self.casting = 255
        self.status = self.combat + self.follow + self.forceFollow + self.following
        self.one:SetStatusBarColor( self.spec/255 , self.status/255 , self.casting/255 );
    end
end

function dot:UNIT_SPELLCAST_SUCCEEDED( f, p , s)
    if p == "player" then
        self.casting = 0
        self.status = self.combat + self.follow + self.forceFollow + self.following
        self.one:SetStatusBarColor( self.spec/255 , self.status/255 , self.casting/255 );
    end
end