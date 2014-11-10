dot = LibStub("AceAddon-3.0"):NewAddon("dot", "AceConsole-3.0", "AceEvent-3.0")

function dot:OnInitialize()
    -- Called when the addon is loaded
    self:Print("DOT LOADED: The Dot-1.0.0")
end

function dot:OnEnable()
    local specModules = {   "TheDot-Arms" ,
                            "TheDot-Fury" ,
                            "TheDot-Prot" , 
                            "TheDot-Elemental" ,
                            "TheDot-Enhancement" ,
                            "TheDot-Resto",
                            "TheDot-Ret",
                            "TheDot-Blood",
                            "TheDot-Frost"
                        }
    
    local f = CreateFrame( "Frame" , "one" , UIParent )
    square_size = 5
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
    if who == "Hexloob-DarkIron" 
        or who == "Xloob-DarkIron" 
        or who == "Vexloob-DarkIron"
        or who == "Paloob-DarkIron"
        or who == "Hexloob-DarkIron"
        or who == "Rexloob-DarkIron" then

        if msg == "+" then
            self:Print("Force Following")
            self.forceFollow = 4
        end
        if msg == "-" then
            self.Print("No longer Force Following")
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
        self.status = self.combat + self.follow + self.forceFollow + self.mount
        self:Print(self.follow, self.mount)
        self.one:SetStatusBarColor( self.spec/255 , self.status/255 , self.casting/255 );
    end
end

function dot:COMBAT_LOG_EVENT_UNFILTERED( poo , t , event , hideCaster , sWho , sName , sFlags , dWho , dName , dFlags , spellId , spellName , spellSchool )
    self.spec = getSpecId()
    self.combat = 0
    if InCombatLockdown() == true or UnitAffectingCombat("focus") == true then
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
                         "Earth Shield",
                         "Exorcism",
                         "Bone Shield",
                         "Obliterate" }
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