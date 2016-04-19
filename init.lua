
--[[

Copyright (C) 2016 Aftermoth, Zolan Davis

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation; either version 2.1 of the License,
or (at your option) version 3 of the License.

http://www.gnu.org/licenses/lgpl-2.1.html

--]]

nua = {
	event,		-- = function(eventpos) Alert under normal timing.
	alert,		-- = function(eventpos) Alert immediately.
}

--====== still tuning

local nua_ready = 0.5  -- Seconds after event before confirmed for alert. Merges multi-event changes at the same position.
local nua_slack = 0.2  -- Seconds additional tolerance before alert. Callback period while active.


--====== send alerts

nua.alert = function(p)
	local q, s
	q = {x=p.x, y=p.y-1, z=p.z}
	s=minetest.get_meta(q):get_string("on_nbr_update")
	if s and s ~= "" then loadstring('return '..s..'(...)')(q, p) end
	q = {x=p.x-1, y=p.y, z=p.z}
	s=minetest.get_meta(q):get_string("on_nbr_update")
	if s and s ~= "" then loadstring('return '..s..'(...)')(q, p) end
	q = {x=p.x+1, y=p.y, z=p.z}
	s=minetest.get_meta(q):get_string("on_nbr_update")
	if s and s ~= "" then loadstring('return '..s..'(...)')(q, p) end
	q = {x=p.x, y=p.y, z=p.z-1}
	s=minetest.get_meta(q):get_string("on_nbr_update")
	if s and s ~= "" then loadstring('return '..s..'(...)')(q, p) end
	q = {x=p.x, y=p.y, z=p.z+1}
	s=minetest.get_meta(q):get_string("on_nbr_update")
	if s and s ~= "" then loadstring('return '..s..'(...)')(q, p) end
	q = {x=p.x, y=p.y+1, z=p.z}
	s=minetest.get_meta(q):get_string("on_nbr_update")
	if s and s ~= "" then loadstring('return '..s..'(...)')(q, p) end
end


--====== common

local nua_list = {}
local nua_init
local nua_initok
local function nua_nil() end
local function nua_initkey()
	nua_initok = nua_nil
	nua_init()
end


--====== process

local nua_noproc = true

local nua_pstop = true
local nua_pbye = 0

function nua_process()
	local t0 = minetest.get_gametime()
	
	local now_list = {}
	for ps,t in pairs(nua_list) do
		now_list[ps]=t
	end
	nua_list = {}
	
	local rem = false
	local new_list = {}
	
	local t1 = minetest.get_gametime()
	
	for ps,t in pairs(now_list) do
		if t1 - t < nua_ready then
			rem = true
			new_list[ps]=t
		else
			nua.alert(minetest.string_to_pos(ps))
		end
	end
	
	if rem then
		for ps,t in pairs(new_list) do
			nua_list[ps]=t
		end
	elseif nua_pstop then
		-- Delay for all pre-initkey events to be processed before exit.
		if t0 - nua_pbye > 0.1 then
			nua_noproc = true
			return
		end
	else
		nua_initok = nua_initkey
		nua_pstop = true
		nua_pbye = minetest.get_gametime()
	end
	
	minetest.after(math.max(0, nua_slack + t0 - minetest.get_gametime()), nua_process)
	
end


--====== (re)start daemon

local nua_nostart = true

-- nua_ready = max hiatus on waiting events.
function nua_start()
	if nua_noproc then
		nua_noproc = false
		nua_pstop = false
		nua_process()
		nua_nostart = true
	else
		minetest.after(nua_ready,nua_start)
	end
end


--====== init

nua_initok = nua_initkey

nua_init = function ()
	if nua_nostart then
		nua_nostart = false
		nua_start()
	end
end


--====== events

nua.event = function (pos)
	nua_list[minetest.pos_to_string(pos)] = minetest.get_gametime() -- uses latest time for pos. Alert delayed until settled.
	nua_initok()
end
