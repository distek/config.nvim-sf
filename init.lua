-- This is to deal with bootstrapping
-- so we don't load the rest of the config
local init = require("plugins")
if init then
	return
end

require("util")
require("themes")
require("plugin-configs")
require("globals")
require("autocmds")
require("mappings")

if vim.g.neovide then
	require("neovide-settings")
end
