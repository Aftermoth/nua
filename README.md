Minetest mod: nua

==== Node Update Alerts ====

USAGE:

To raise a normal alert from any position:

	nua.event(eventpos)


To receive an alert:

	minetest.get_meta(receivernodepos):set_string("on_nbr_update","modname.functionname")

where, modname.functionname = function(receiverpos, eventpos)


Typically, a nua-aware node will have registration code like:

	on_construct = function(p)
		local m=minetest.get_meta(p)
		m:set_string("on_nbr_update","zigmod.zag")
		nua.event(p)
	end,
	after_destruct = function(p,o)
		nua.event(p)
	end,


NOTES:
"on_nbr_update" is generically named so the interface is equally usable by alternative alert mods.


EXTENSION:
Only nua-aware mods can use this mod.
Another mod, nuafan, adds nua-support to nodes from nua-ignorant mods as well.
https://github.com/Aftermoth/nuafan


----

Copyright (C) 2016 Aftermoth, Zolan Davis

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation; either version 2.1 of the License,
or (at your option) version 3 of the License.

http://www.gnu.org/licenses/lgpl-2.1.html
