if vim.loader then
	vim.loader.enable()
end

-- _G.dd = function(...)
--     require("util.debug").dump(...)
-- end
-- vim.print = _G.dd

_G.Alvaldes = require("alvaldes.utils")
require("alvaldes.config.options")
require("alvaldes.config.keymaps")
require("alvaldes.config.autocmds")
require("alvaldes.config.commands")
require("alvaldes.config.workarounds")
require("alvaldes.plugins")
