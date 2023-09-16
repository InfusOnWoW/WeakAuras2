if not WeakAuras.IsLibsOK() then return end
local AddonName, OptionsPrivate = ...
local L = WeakAuras.L;
local noop = function() end

local shimMethods = {
  "ClearFocus",
  "SetFocus",
  "GetTTSDescription",
  "KeyHandler",
  "SkipFocus"
}

OptionsPrivate.TTSFocus = {
  focusFrame = nil,
  voiceId = 1, -- TOOD need to add inialization for this
  shims = {},
  RegisterShim = function(self, type, shim)
    for _, method in ipairs(shimMethods) do
      if not shim[method] then
        shim[method] = noop
      end
    end

    self.shims[type] = shim
  end,

  GetShim = function(self, type)
    if self.shims[type] then
      return self.shims[type]
    end
    return self.shims[""]
  end,

  SpeakText = function(self, text)
    print("SpeakText", text)
    if text and type(text) == "string" then
      C_VoiceChat.SpeakText(self.voiceId, text, 1, C_TTSSettings and C_TTSSettings.GetSpeechRate() or 0, C_TTSSettings and C_TTSSettings.GetSpeechVolume() or 100)
    end
  end,

  SetFocus = function(self, frame, silent)
    print("SetFocus")

    if self.focusFrame then
      if self.focusFrame.ttsClearFocus then
        self.focusFrame:ttsClearFocus()
      else
        local shim = self:GetShim(self.focusFrame.type)
        shim:ClearFocus(self.focusFrame)
      end
    end

    self.focusFrame = frame
    if self.focusFrame then
      if self.focusFrame.ttsSetFocus then
        self.focusFrame:ttsSetFocus()
      else
        local shim = self:GetShim(self.focusFrame.type)
        shim:SetFocus(self.focusFrame)
      end

      if not silent then
        self:ReadFocus()
      end
    end
  end,

  MoveFocus = function(self, backward)
    print("MoveFocus", backward)
    if self.focusFrame then
      local next = backward and self.focusFrame.prevFocus or self.focusFrame.nextFocus
      if next then
        local skipFocus = false
        if next.ttsSkipFocus then
          skipFocus = next.ttsSkipFocus()
        else
          local shim = self:GetShim(next.type)
          skipFocus = shim:SkipFocus(next)
        end
        if skipFocus then
          self.focusFrame = next
          self:MoveFocus(backward)
        else
          self:SetFocus(next)
        end
      end
    end
  end,

  ReadFocus = function(self)
    print("ReadFocus")
    if not self.focusFrame then
      return
    end

    local ttsDescription = self.focusFrame.ttsDescription
    if type(ttsDescription) == "function" then
      ttsDescription = ttsDescription()
    end

    if not ttsDescription then
      local shim = self:GetShim(self.focusFrame.type)
      ttsDescription = shim:GetTTSDescription(self.focusFrame)
    end

    if ttsDescription then
      self:SpeakText(ttsDescription)
    end
  end,

  ForwardKeyToFocus = function(self, key)
    print("ForwardKeyToFocus", key)
    if self.focusFrame then
      if self.focusFrame.ttsKeyHandler then
        return self.focusFrame:ttsKeyHandler(key)
      else
        local shim = self:GetShim(self.focusFrame.type)
        return shim:KeyHandler(self.focusFrame, key)
      end
    end
  end,

  SetNextFocus = function(self, frame1, frame2)
    frame1.nextFocus = frame2
    frame2.prevFocus = frame1
  end,

  HasFocus = function(self)
    return self.focusFrame
  end
}

-- default shim
OptionsPrivate.TTSFocus:RegisterShim("",
{
  GetTTSDescription = function(self, frame)
    print("Default Shim GetTTSDescription")
    if not frame then return end

    print("Unknown type", frame.type)
  end,

})

OptionsPrivate.TTSFocus:RegisterShim("CheckBox",
{
  GetTTSDescription = function(self, frame)
    local text = frame.text:GetText()
    local value = frame:GetValue()
    if frame.tristate then
      if value == nil then
        return L["Checkbox"] .. " " .. text .. ": ".. L["unchecked"]
      elseif value == false then
        return L["Checkbox"] .. " " .. text .. ": " .. L["partially checked"]
      else
        return L["Checkbox"] .. " " .. text .. ": " .. L["checked"]
      end
    else
      if value then
        return L["Checkbox"] .. " " .. text .. ": " .. L["checked"]
      else
        return L["Checkbox"] .. " " .. text .. ": ".. L["unchecked"]
      end
    end
  end,
  KeyHandler = function(self, frame, key)
    if key == "SPACE" then
      frame:ToggleChecked()
      -- TODO ugly
      frame:Fire("OnValueChanged", frame.checked)
      OptionsPrivate.TTSFocus:ReadFocus()
    end
  end
})

OptionsPrivate.TTSFocus:RegisterShim("Label",
{
  GetTTSDescription = function(self, frame)
    return L["Label"] .. " " .. (frame.label:GetText() or "No text")
  end,

  SkipFocus = function(self, frame)
    local text = frame.label:GetText()
    return not text or text == ""
  end
})

OptionsPrivate.TTSFocus:RegisterShim("WeakAurasExpand",
{
  GetTTSDescription = function(self, frame)
    -- TODO can't get expanded/collpased state easily
    local text = frame.label:GetText()
    return L["Header"] .. " " .. text
  end,

  KeyHandler = function(self, frame)
    frame:Fire("OnClick")
  end
})

OptionsPrivate.TTSFocus:RegisterShim("LSM30_Statusbar",
{
  GetTTSDescription = function(self, frame)
    local label = frame.frame.label:GetText() or ""
    local text = frame.frame.text:GetText() or ""
    return L["Dropdown"] .. " " .. label .. ": " .. text
  end,

  KeyHandler = function(self, frame)
    -- TODO implementing keyboard control for drop downs is going to a lot of work
  end

})

OptionsPrivate.TTSFocus:RegisterShim("Dropdown",
{
  GetTTSDescription = function(self, frame)
    local label = frame.label:GetText() or ""
    local text = frame.text:GetText() or ""
    return L["Dropdown"] .. " " .. label .. ": " .. text
  end,

  KeyHandler = function(self, frame)
    -- TODO implementing keyboard control for drop downs is going to a lot of work
  end
})

OptionsPrivate.TTSFocus:RegisterShim("Heading",
{
  GetTTSDescription = function(self, frame)
    return L["Header"] .. " " .. frame.label:GetText()
  end,

  SkipFocus = function(self, frame)
    local text = frame.label:GetText()
    return text == nil or text == ""
  end

})

OptionsPrivate.TTSFocus:RegisterShim("ColorPicker",
{
  GetTTSDescription = function(self, frame)
    -- TODO eh color reading?
    local label = frame.text:GetText() or ""
    return L["Color Picker"] .. " " .. label
  end,

  KeyHandler = function(self, frame)
    -- TODO color picker??
  end,
})

OptionsPrivate.TTSFocus:RegisterShim("WeakAurasSpinBox",
{
  GetTTSDescription = function(self, frame)
    local label = frame.label:GetText()
    local value = frame.editbox:GetText()

    return L["Spinbox"] .. " " .. label .. ": " .. value
  end,

  -- TODO need tab override, how to best do accomplish that?
})

OptionsPrivate.TTSFocus:RegisterShim("EditBox",
{
  GetTTSDescription = function(self, frame)
    local label = frame.label:GetText()
    local text = frame.editbox:GetText()

    return L["EditBox"] .. " " .. label .. ": " .. text
  end,

  SetFocus = function(self, frame)
    frame:SetFocus()
  end,

  ClearFocus = function(self, frame)
    frame:ClearFocus()
  end

})

OptionsPrivate.TTSFocus:RegisterShim("WeakAurasIcon",
{
  GetTTSDescription = function(self, frame)
    -- TODO should read tooltip, but tooltip is in AceConfig iirc
  end,

  KeyHandler = function(self, frame, key)
    if key == "SPACE" then
      frame:Fire("OnClick")
    end
  end
})

OptionsPrivate.TTSFocus:RegisterShim("WeakAurasAnchorButtons",
{
  GetTTSDescription = function(self, frame)
    -- TODO WeakAurasAnchorButtons
  end,

  KeyHandler = function(self, frame, key)
    -- TODO WeakAurasAnchorButtons key handler
  end

})

OptionsPrivate.TTSFocus:RegisterShim("ScrollFrame",
{
  SkipFocus = function() return true end
})

