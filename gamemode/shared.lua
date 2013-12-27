GM.Name = "Hide and Seek"
GM.Author = "McSimp"
GM.Email = "will@mcsi.mp"
GM.Website = "http://mcsi.mp"

include("sh_config.lua")
include("sh_globals.lua")
include("sh_teammanager.lua")

HS.Globals.RegisterReplicated("RoundCount", 0)

PrecacheParticleSystem("bday_confetti")
PrecacheParticleSystem("unusual_storm")
PrecacheParticleSystem("superrare_confetti_green")
