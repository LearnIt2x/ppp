local curl = require("pantran.curl")
local config = require("pantran.config")

local argos = {
  name = "Argos Translate",
  config = {
    url = "https://translate.terraprint.co",
    api_key = vim.NIL, -- optional for many libretranslate instances
    default_source = "auto",
    default_target = "en"
  }
}

function argos.detect(text)
  return argos._api:post("detect", {q = text})[1].language
end

function argos.languages()
  local languages = {
    source = {
      auto = "Auto"
    },
    target = {}
  }

  for _, lang in pairs(argos._api:get("languages")) do
    languages.source[lang.code] = lang.name
    languages.target[lang.code] = lang.name
  end

  return languages
end

function argos.switch(source, target)
  if source == "auto" then
    return source, target
  else
    return target, source
  end
end

function argos.translate(text, source, target)
  source, target = source or argos.config.default_source, target or argos.config.default_target

  local translation = argos._api:post("translate", {
    q = text,
    source = source,
    target = target
  })

  return {
    text = translation.translatedText,
    detected = source == "auto" and argos.detect(text) or nil
  }
end

function argos.setup()
  argos._api = curl.new{
    url = argos.config.url,
    fmt_error = function(response) return response.error end,
    data = {api_key = argos.config.api_key},
    static_paths = {"languages"}
  }
end

return config.apply(config.user.engines.argos, argos)
