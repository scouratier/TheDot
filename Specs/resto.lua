resto = LibStub("AceAddon-3.0"):NewAddon("resto", "AceConsole-3.0", "AceEvent-3.0")

function resto:OnInitialize()
    -- Called when the addon is loaded
    self:Print("DOT LOADED: Shaman-3.0")
end

function resto:OnEnable()
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
    
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

end

function resto:OnDisable()
    -- Called when the addon is disabled
end

function resto:COMBAT_LOG_EVENT_UNFILTERED( poo , t , event , hideCaster , sWho , sName , sFlags , dWho , dName , dFlags , spellId , spellName , spellSchool )
    if event == "SPELL_CAST_SUCCESS" then
        self.Print( "RS: Spell cast:" , sName , " => " , dName , " / " , spellName )    
    end
    
    if event == "SPELL_HEAL" then
        self.Print( "RS: Heal :" , sName , " => " , dName , " / " , spellName )    
    end
    
    if event == "SPELL_AURA_APPLIED" then
        self.Print( "RS: Aura ON :" , sName , " => " , dName , " / " , spellName )    
    end
    
    if event == "SPELL_REMOVED" then
        self.Print( "RS: Aura OFF :" , sName , " => " , dName , " / " , spellName )    
    end
    
    
end