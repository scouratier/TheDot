dot = LibStub("AceAddon-3.0"):NewAddon("dot", "AceConsole-3.0", "AceEvent-3.0")

function dot:OnInitialize()
    -- Called when the addon is loaded
    self:Print("DOT LOADED: The Dot-1.0")
end

function dot:OnEnable()
    local specModules = {   "TheDot-Arms" ,
                            "TheDot-Fury" ,
                            "TheDot-Prot" , 
                            "TheDot-Elemental" ,
                            "TheDot-Enhancement" ,
                            "TheDot-Resto"
                        }
    
    local f = CreateFrame( "Frame" , "one" , UIParent )
    f:SetFrameStrata( "HIGH" )
    f:SetWidth( 15 )
    f:SetHeight( 15 )
    f:SetPoint( "TOPLEFT" )
    
    self.one = CreateFrame( "StatusBar" , nil , f )
    self.one:SetPoint( "TOPLEFT" )
    self.one:SetWidth( 15 )
    self.one:SetHeight( 15 )    
    self.one:SetStatusBarTexture("Interface\\AddOns\\thedot\\Images\\Gloss")
    self.one:SetStatusBarColor( 0 , 0 , 0 )

    
    -- get the spec by looking for a specific spell in the spell books
    self.spec = getSpecId()
    self.casting = 0
    self.combat = 0
    self.follow = 0
    self.forceFollow = 0
    self.range = 0
    self.status = 0
    self.mount = 0
        
    local loaded , reason = LoadAddOn( specModules[self.spec] )
    if not loaded then
        self:Print( "Could not load Spec: ",reason )
    end
    self.one:SetStatusBarColor( self.spec/255 , 0 , 0 )
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("UNIT_SPELLCAST_START")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    self:RegisterEvent("AUTOFOLLOW_BEGIN")
    self:RegisterEvent("AUTOFOLLOW_END")
    self:RegisterEvent("CHAT_MSG_WHISPER")
end

function dot:OnDisable()
    
end

function dot:CHAT_MSG_WHISPER( filler , msg , who , poo , status , id , unkn , lineId , sguid )
    if who == "Hexloob" or who == "Xloob" then
        if msg == "+" then
            self:Print("Force Following")
            self.forceFollow = 4
        end
        if msg == "-" then
            self.forceFollow = 0
        end
        if msg == "up" then
            self.mount = 8
        end
        if msg == "down" then
            self.mount = 0
        end
        self.status = self.combat + self.follow + self.forceFollow
        self.one:SetStatusBarColor( self.spec/255 , self.status/255 , self.casting/255 );
    end
end

function dot:COMBAT_LOG_EVENT_UNFILTERED( poo , t , event , hideCaster , sWho , sName , sFlags , dWho , dName , dFlags , spellId , spellName , spellSchool )
    self.spec = getSpecId()
    self.combat = 0
    if InCombatLockdown() == 1 or UnitAffectingCombat("focus") == 1 then
        self.combat = 1
    end
    
    if self.combat == 0 then
        if self.follow == 0 then
            if ( CheckInteractDistance("focus", 4) ) then
                FollowUnit("focus")
                self.follow = 2
            end
        end
    end

    if self.forceFollow == 4 then
        if ( CheckInteractDistance("focus", 4) ) then
            FollowUnit("focus")
            self.follow = 2
        end
    end


    self.status = self.combat + self.follow + self.forceFollow
    self.one:SetStatusBarColor( self.spec/255 , self.status/255 , self.casting/255 );
end

function getSpecId()
    local int id = 1
    local specSpells = { "Mortal Strike" ,
                         "Bloodthirst" ,
                         "Shield Slam" ,
                         "Thunderstorm" ,
                         "Lava Lash" ,
                         "Earth Shield" }
    local specId
    
    while true do
    
        local spellName, spellSubName = GetSpellBookItemName( id, "spell" );
        if not spellName then
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
    return 0
end

function dot:AUTOFOLLOW_BEGIN( f )
    self.follow = 2
    self.status = self.combat + self.follow + self.forceFollow
    self.one:SetStatusBarColor( self.spec/255 , self.status/255 , self.casting/255 );
end

function dot:AUTOFOLLOW_END()
    self.follow = 0
    self.status = self.combat + self.follow + self.forceFollow
    self.one:SetStatusBarColor( self.spec/255 , self.status/255 , self.casting/255 );
end

function dot:UNIT_SPELLCAST_START( f , p , s )
    -- spell cast has started, block stuff
    if p == "player" then
        self.casting = 255
        self.status = self.combat + self.follow + self.forceFollow
        self.one:SetStatusBarColor( self.spec/255 , self.status/255 , self.casting/255 );
    end
end

function dot:UNIT_SPELLCAST_SUCCEEDED( f, p , s)
    if p == "player" then
        self.casting = 0
        self.status = self.combat + self.follow + self.forceFollow
        self.one:SetStatusBarColor( self.spec/255 , self.status/255 , self.casting/255 );
    end
end