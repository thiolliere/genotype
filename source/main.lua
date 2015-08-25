-- librairies
require "enet"
require "core"
require "deb"
require "world"

mute = true

if arg[#arg] == "-debug" then require("mobdebug").start() end
if arg[2] and arg[2] == "server" then
	require "server"
else
	require "client"
end
