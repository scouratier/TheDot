fury = LibStub("AceAddon-3.0"):NewAddon("fury", "AceConsole-3.0", "AceEvent-3.0")

function fury:OnInitialize()
    -- Called when the addon is loaded
    self:Print("DOT LOADED: Fury-1.0")
end

function fury:OnEnable()
    local f = CreateFrame( "Frame" , "one" , UIParent )
    f:SetFrameStrata( "HIGH" )
    f:SetWidth( 30 )
    f:SetHeight( 15 )
    f:SetPoint( "TOPLEFT" , 15 , 0 )
    
    self.two = CreateFrame( "StatusBar" , nil , f )
    self.two:SetPoint( "TOPLEFT" )
    self.two:SetWidth( 15 )
    self.two:SetHeight( 15 )
    self.two:SetStatusBarTexture("Interface\\AddOns\\thedot\\Images\\Gloss")
    self.two:SetStatusBarColor( 0 , 1 , 0 )
    
    self.three = CreateFrame( "StatusBar" , nil , f )
    self.three:SetPoint( "TOPLEFT" , 15 , 0)
    self.three:SetWidth( 15 )
    self.three:SetHeight( 15 )
    self.three:SetStatusBarTexture("Interface\\AddOns\\thedot\\Images\\Gloss")
    self.three:SetStatusBarColor( 0 , 0 , 1 )
end

function fury:OnDisable()
    -- Called when the addon is disabled
end

function fury:COMBAT_LOG_EVENT_UNFILTERED()
    -- Start by reseting the dot state:
    self.two:SetStatusBarColor(0, 0, 0);
    self.three:SetStatusBarColor(0, 0, 0);
        

    -- This is set to 1 because not all spell have a range
    local battleShout = 0
    local bloodsurge = 0
    local rank = 0
    local rage = 0
    local sunders = 0
    local rend = 0
    local inRange = 1
    local spellName
    local red = 0
    local green = 0
    local blue = 0
    local shade = 0
	
    combat = 2	
    if InCombatLockdown() == 1 then
		 
        combat = 1
	--local rend, rendrank, rendicon, rendcount, renddebuffType, rendduration, rendexpirationTime, rendisMine, rendisStealable  = UnitDebuff("target","Rend");
		
	--if rend == nil then
	--	green = green + 16
	--else	if rendexpirationTime then
	--			rendexpirein = rendexpirationTime - GetTime();
	--		end
	--end	
	
	for id = 1, 150	do
            spellName, spellSubName = GetSpellBookItemName( id, "spell" );

            if SpellIsMonitored(spellName,spellRank) == 1 then
		local usable, noRage = IsUsableSpell(spellName)
			
			
		-- Test to see if the spell needs a range
		rangeTest = SpellHasRange(spellName)
		-- If if does need a range, then test the range
		if rangeTest == 1 then
                    -- inRange = IsSpellInRange(spellName, "target")
		end
			
		if usable == 1 and inRange == 1 then
                    start, duration, enable = GetSpellCooldown( id, "spell" )
                    if start == 0 then
                        r , g , b = GetColorCode(spellName)
                                                
                        red = red + r
                        green = green + g
                        blue = blue + b
						
                        self.two:SetStatusBarColor(red/255, green/255, blue/255);
                    end
                end
            end
        end
        red = 0
        green = 0
        blue = 0
        battleShout, rank = UnitBuff("player","Battle Shout")
        if battleShout == nil then
            red = red + 1
        end
        rage = UnitMana("player")
        if rage > 80 then
            red = red + 2
        end
        if rage > 90 then
            red = red + 4
        end
        bloodsurge, rank = UnitBuff("player","Bloodsurge")
        if bloodsurge == "Bloodsurge" then
            red = red + 8
        end
        self.two:SetStatusBarColor( red/255, green/255, blue/255 );
                
    end
    self.three:SetStatusBarColor(0, 0, combat/255);
end

function SpellIsMonitored(inSpell,inRank)
    if	inSpell == "Bloodthirst" or
        --inSpell == "Whirlwind" or
        inSpell == "Bloodrage" or
        inSpell == "Berserker Rage" or
        inSpell == "Raging Blow" or
        inSpell == "Execute" or
        inSpell == "Death Wish" or
        inSpell == "Recklessness" or
        inSpell == "Inner Rage" or
        inSpell == "Victory Rush" or
        inSpell == "Heroic Throw" then
        return 1
    end
    return 0
end

function GetColorCode(inSpell)
    if inSpell == "Bloodthirst" or inSpell == "Mortal Strike" or inSpell == "Shield Slam" then
        return 1 , 0 , 0
    end
    if inSpell == "Whirlwind" then
        return 2 , 0 , 0
    end
    if inSpell == "Bloodrage" then
        return 4 , 0 , 0
    end
    if inSpell == "Berserker Rage" then
        return 8 , 0 , 0
    end
    if inSpell == "Raging Blow" then
        return 16 , 0 , 0
    end
    if inSpell == "Execute" then
        return 32 , 0 , 0
    end
    if inSpell == "Death Wish" then
        return 64 , 0 , 0
    end
    if inSpell == "Victory Rush" then
        return 128 , 0 , 0
    end
    if inSpell == "Colossus Smash" then
        return 0 , 1 , 0
    end
    --if inSpell == "hiRage" then
        --    return 0 , 2 , 0
    --end
    if inSpell == "Recklessness" then
        return 0 , 4 , 0
    end
    if inSpell == "Inner Rage" then
        return 0 , 8 , 0
    end
    if inSpell == "Cleave" then
        return 0 , 16 , 0
    end
    if inSpell == "Enraged Regeneration" then
        return 0 , 32 , 0
    end
    if inSpell == "Heroic Throw" then
        return 0 , 64 , 0
    end
    if inSpell == "Shockwave" then
        return 0 , 128 , 0
    end
    if inSpell == "Devastate" then
    return 0 , 0 , 1
    end

    return 0 , 0 , 0
end