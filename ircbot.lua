--dofile("A:/LUA/ircbot.lua")
print("[++++]First Start")

--filepathdir="C:/Users/Nickoplier/Dropbox/FORMATTINGSAVE/LUA/TheYouSrslyBot"
botmoderators={} --Bot Host Names DONT ADD HERE, IT IS ADDED ON BOTMODS.LUA
fullnameindex={} --When someone chats, their nick is added here for future reference.
ignorehosts={} --When someone requests to be ignored by the bot, host is added.
isbotforcednotice=false --Is the bot required to always use notice?
isbotinhushmode=false --Is the bot in a hush mode?
isbotinnoticetriggermode=false --Require the bot to use notices if a trigger was found.
isbotinnoticemode=false --Require the bot to be in full notice mode..

isbotletsrollblockedwait={}
isbotletsrollwinner={"botfilefail"}

--Don't modify Required to stay for default operation, Modification may fuck bot up.
botforcereboot=false --Scripted variable to force hault.
botforcerefresh=false --Scripted variable to force chatted refresh.
isbothushdatalastmsgtime=0 --For hush lastmsg os.timeout
isbothushdatahushlength=30 --For default 30 seconds of hush.

--oldpackagepath=package.path
--package.path = filepathdir..'/?.lua;' .. package.path
require("settings")

do --TableSave and Load functions.
   -- declare local variables
   --// exportstring( string )
   --// returns a "Lua" portable version of the string
   local function exportstring( s )
      return string.format("%q", s)
   end

   --// The Save Function
   function table.save(  tbl,filename )
      local charS,charE = "   ","\n"
      local file,err = io.open( filename, "wb" )
      if err then return err end

      -- initiate variables for save procedure
      local tables,lookup = { tbl },{ [tbl] = 1 }
      file:write( "return {"..charE )

      for idx,t in ipairs( tables ) do
         file:write( "-- Table: {"..idx.."}"..charE )
         file:write( "{"..charE )
         local thandled = {}

         for i,v in ipairs( t ) do
            thandled[i] = true
            local stype = type( v )
            -- only handle value
            if stype == "table" then
               if not lookup[v] then
                  table.insert( tables, v )
                  lookup[v] = #tables
               end
               file:write( charS.."{"..lookup[v].."},"..charE )
            elseif stype == "string" then
               file:write(  charS..exportstring( v )..","..charE )
            elseif stype == "number" then
               file:write(  charS..tostring( v )..","..charE )
            end
         end

         for i,v in pairs( t ) do
            -- escape handled values
            if (not thandled[i]) then
            
               local str = ""
               local stype = type( i )
               -- handle index
               if stype == "table" then
                  if not lookup[i] then
                     table.insert( tables,i )
                     lookup[i] = #tables
                  end
                  str = charS.."[{"..lookup[i].."}]="
               elseif stype == "string" then
                  str = charS.."["..exportstring( i ).."]="
               elseif stype == "number" then
                  str = charS.."["..tostring( i ).."]="
               end
            
               if str ~= "" then
                  stype = type( v )
                  -- handle value
                  if stype == "table" then
                     if not lookup[v] then
                        table.insert( tables,v )
                        lookup[v] = #tables
                     end
                     file:write( str.."{"..lookup[v].."},"..charE )
                  elseif stype == "string" then
                     file:write( str..exportstring( v )..","..charE )
                  elseif stype == "number" then
                     file:write( str..tostring( v )..","..charE )
                  end
               end
            end
         end
         file:write( "},"..charE )
      end
      file:write( "}" )
      file:close()
   end
   --// The Load Function
   function table.load( sfile )
      local ftables,err = loadfile( sfile )
      if err then return _,err end
      local tables = ftables()
      for idx = 1,#tables do
         local tolinki = {}
         for i,v in pairs( tables[idx] ) do
            if type( v ) == "table" then
               tables[idx][i] = tables[v[1]]
            end
            if type( i ) == "table" and tables[i[1]] then
               table.insert( tolinki,{ i,tables[i[1]] } )
            end
         end
         -- link indices
         for _,v in ipairs( tolinki ) do
            tables[idx][v[2]],tables[idx][v[1]] =  tables[idx][v[1]],nil
         end
      end
      return tables[1]
   end
-- close do
end


do --Load data tables..
	local function file_exists(name)
	   local f=io.open(name,"r")
	   if f~=nil then io.close(f) return true else return false end
	end
	if file_exists("BotMods")==false then
		table.save(botmoderators,"BotMods")
	end
	if file_exists("TimeoutWaitRoll")==false then
		table.save(isbotletsrollblockedwait,"TimeoutWaitRoll")
	end
	if file_exists("TimeoutWaitWin")==false then
		table.save(isbotletsrollwinner,"TimeoutWaitWin")
	end
	botmoderators=table.load("BotMods")
	isbotletsrollblockedwait=table.load("TimeoutWaitRoll")
	isbotletsrollwinner=table.load("TimeoutWaitWin")
end 

function CheckPerm(p)
	local ok=false
	for a=1,#botmoderators do
		if p==botmoderators[a] then 
			ok=true 
		end
	end
	return ok
end 
function SendRAWMessage(msg)
	IRCSend(msg)
end 
function SendMessage(msg,nick,torr,channel,forces,wasatrigger)
	if (channel=="NickoplierBot" and torr=="NOTICE") or forces==true then
		IRCSend("NOTICE "..nick.." :NOTICE: "..msg)
	elseif channel:sub(1,1)~="#" then
		IRCSend(torr.." "..nick.." :MSG: "..msg)
	else
		if isbotinnoticemode==true then
			IRCSend("NOTICE "..nick.." :FNM:|"..nick..": "..msg)
		elseif (isbotinnoticetriggermode==true and wasatrigger==true) then
			IRCSend("NOTICE "..nick.." :FNMT|"..nick..": "..msg)
		elseif isbotinhushmode==true then
			if isbothushdatalastmsgtime>tonumber(os.time()) then
				IRCSend("NOTICE "..nick.." :HUSH|"..nick..": "..msg)
			else
				IRCSend(torr.." "..channel.." :"..nick..": "..msg)
				isbothushdatalastmsgtime=tonumber(os.time())+isbothushdatahushlength
			end 
		else
			IRCSend(torr.." "..channel.." :"..nick..": "..msg)
		end 
	end 
end 

Chatted=require("chatted")


----------------------
----------------------
--Begin bot receiver--
----------------------
----------------------


do
	local copas = require("copas")
	local socket = require("socket")
	do --Global
		local skt=nil
		local host=irc.host
		local port=irc.port
		local channel=irc.channel
		local nickname=irc.nickname
		local password=irc.password
		local connected=false
		local buffer=""
		local err=""
		skt = socket.tcp()
		skt:settimeout(0) --nonblocking
		skt:connect(host, port)
		function IRCSend(data)
			skt:send(data.."\r\n")
			print("[+++]Send Message ".. data)
			io.flush()
		end 
		while true do
			local buffer, err = skt:receive("*l")
			--print("[++]G Receive ",buffer,err)
			if err=="closed" or botforcereboot==true then
				error("im done..")
			elseif err == nil or err == "timeout" then
				if connected==false then
					print("[++]Sent connection data.")
					IRCSend("NICK "..nickname)
					connected = true
				end
			end
			if botforcerefresh==true then
				botforcerefresh=false
				Chatted=function() end;
				Chatted=nil;
				package.loaded['chatted'] = nil
				Chatted=require("chatted")
				print("Forced the refresh..")
			end 
			if buffer ~= nil then
				io.flush()
				if string.sub(buffer,1,4) == "PING" then
					print("[++]Ping Request")
					IRCSend(string.gsub(buffer,"PING","PONG",1))
				else
					print("[++] '"..buffer.."'")
					userhostname, cmd, param = string.match(buffer, "^:([^ ]+) ([^ ]+)(.*)$")
					--print("[++]DataReceive: ".. buffer .." \n")
					if cmd == "NOTICE" and param:sub(1,16)==" AUTH :*** No Id" then
						IRCSend("USER testing 0 * Testing")
						IRCSend("NAME "..nickname)
						IRCSend("JOIN "..channel)
					end
					user, userhost = string.match(buffer,"^([^!]+)!(.*)$")
					if user~=":jtv" and user~=nil then
						--io.write("|irc.lua|>Subcontent: ".. buffer .." \n")
						prefix, cmd, param = string.match(buffer, "^:([^ ]+) ([^ ]+)(.*)$")
						if prefix~=nil and cmd~=nil and param~=nil then
							param1, msg = string.match(param,"^([^:]+) :(.*)$")
							if msg~=nil then
								local channel=param1:sub(2)
								user=user:sub(2)
								do
									local num=userhostname:match("^.*()@")
									userhostname=userhostname:sub(num+1)
								end 
								print("[++]G "..user..":"..msg)
								Chatted(userhostname,user,msg,cmd,channel) --Host, Nick, Message, Type, Channel
							end 
						end 
					end 
				end
			end
		end 
	end 
end 