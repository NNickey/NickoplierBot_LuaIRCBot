return function(host,nick,fmsg,torr,channel) --host ip, nick, fullmessage, typeofreply, channel
	if (fmsg:sub(1,1)=="-" or fmsg:sub(1,1)=="~" or fmsg:sub(1,1)==".") and fmsg:sub(1,2)~="~~" then
		msg=fmsg:sub(2):lower()
		if msg:sub(1,7)=="gethost" then
			SendMessage("Your bot host id is "..host,nick,torr,channel)
		elseif msg:sub(1,8)=="shakewin" then
			if #isbotletsrollwinner==0 then
				SendMessage("No one won the shakeaton yet..",nick,torr,channel)
			else
				SendMessage("List of shake winners. "..table.concat(isbotletsrollwinner,","),nick,torr,channel)
			end 
		elseif msg:sub(1,5)=="shake" then
			local waits=false
			local num=0
			if #isbotletsrollblockedwait~=0 then
				for a=1,#isbotletsrollblockedwait do
					if isbotletsrollblockedwait[a][1]==host then
						waits=true
						num=a
						if isbotletsrollblockedwait[a][2]<=tonumber(os.time()) then
							isbotletsrollblockedwait[a][2]=tonumber(os.time())+900
							table.save(isbotletsrollblockedwait,"TimeoutWaitRoll")
							waits=false
						end 
					end 
				end 
			end 
			if waits==false and num==0 then
				table.insert(isbotletsrollblockedwait,{host,tonumber(os.time())+900})
				table.save(isbotletsrollblockedwait,"TimeoutWaitWin")
			end 
			if waits==false then
				local num=math.random(1,512)
				if num==152 then
					SendMessage("You're the winner! You are now on the acknowledge board! Wait 15m to go again.",nick,torr,channel)
					table.insert(isbotletsrollwinner,nick)
					table.save(isbotletsrollwinner,"TimeoutWaitWin")
				else
					SendMessage("You didn't win :(, shake it again in 15 minutes.",nick,torr,channel)
				end 
			else
				local nSeconds=isbotletsrollblockedwait[num][2]-tonumber(os.time())
				local nHours = string.format("%02.f", math.floor(nSeconds/3600));
				local nMins = string.format("%02.f", math.floor(nSeconds/60 - (nHours*60)));
				local nSecs = string.format("%02.f", math.floor(nSeconds - nHours*3600 - nMins *60));
				SendMessage("You can't shake until "..nHours.."h "..nMins.."m "..nSecs.."s.",nick,torr,channel)
			end 
		elseif CheckPerm(host) then
			if msg:sub(1,7)=="saveall" then
				SendMessage("Saving all.. ",nick,torr,channel)
				table.save(botmoderators,"BotMods.lua")
				table.save(fullnameindex,"")
			elseif msg:sub(1,3)=="ttn" or msg:sub(1,13)=="triggernotify" then
				if isbotinnoticetriggermode==true then
					SendMessage("The bot is now sending channel messages when a trigger is found.",nick,torr,channel)
					isbotinnoticetriggermode=false
				else
					SendMessage("The bot is now sending notices when a trigger is found.",nick,torr,channel)
					isbotinnoticetriggermode=true
				end
			elseif msg:sub(1,6)=="notify" then
				if isbotinnoticemode==true then
					SendMessage("The bot is now allowed to chat globally.",nick,torr,channel)
					isbotinnoticemode=false
				else
					SendMessage("The bot is now forced to use notice for global.",nick,torr,channel)
					isbotinnoticemode=true
				end
			elseif msg:sub(1,4)=="hush" then
				if isbotinhushmode==true then
					isbotinhushmode=false
					SendMessage("The bot is now longer in hush mode..",nick,torr,channel)
				else
					if msg:sub(5,5)==" " then
						local num=tonumber(msg:sub(6))
						if num==nil then
							SendMessage("The bot stares at you with a retarded face..",nick,torr,channel)
						else
							isbothushdatahushlength=num
							SendMessage("The bot is now in hush mode. ("..isbothushdatahushlength..")",nick,torr,channel)
							isbotinhushmode=true
						end 
					else
						isbothushdatahushlength=30
						SendMessage("The bot is now in hush mode. ("..isbothushdatahushlength..")",nick,torr,channel)
						isbotinhushmode=true
					end 
				end
			elseif msg:sub(1,6)=="addmod" then
			elseif msg:sub(1,5)=="join " then
				if msg:sub(6)~=nil then
					SendRAWMessage("JOIN #"..msg:sub(6))
				end 
			elseif msg:sub(1,7)=="refresh" then
				SendMessage("Refreshing bot chat function..",nick,torr,channel)
				botforcerefresh=true
			elseif msg:sub(1,7)=="killbot" then
				botforcereboot=true
			end 
		end 
	else --Trigger Check
		local responce=nil
		local trigger={
			{	{"~~"
				},
				{"I am a bot. All messages that look like ~message or .message or -message are messages that make me say a predefined message."
				}
			},
			{	{"why wont my skin work","skin is broken",
					"skin not working","skin is not working",
					"skin isn't working","skin isnt working",
					"use my skin","skin wont work"
				},
				{"If you just uploaded your skin, it may take some time for the server. But, to use a skin that you uploaded, make sure you use an * before your name. (EX:*"..nick..")"
				}
			},
			{	{"agor"
				},
				{"WARNING! That site is a known jumpscare website! Do not open the link!"
				}
			},
				--Spanish
			{	{"español","alguien","pasa","ukljucim","mi das","holla","izbacila","srbine","imaju"
				},
				{"No se permite hablar cualquier otra idioma aparte de Inglés, por las reglas. Si quieres hablar en tu idioma, puedes hablar con otras personas en privado, utilizando /msg <nombre> <mensaje> , con las personas que también hablan tu idioma."
				}
			},
				--Polish
			{	{"hej","jakiś","hajs"
				},
				{"Proszę mówić po angielsku w tym kanale. Zapoznaj się z regulaminem. Jeśli chcesz, aby mówić w innym języku należy to zrobić w prywatną wiadomość za pomocą / msg <nazwa> <wiadomość>."
				}
			},
				--portuguese
			{	{"esses","Olá","você","está"
				},
				{"Por favor, fale em Inglês neste canal. Leia as regras. Se você quiser falar em outro idioma, por favor fazê-lo em uma mensagem particular usando / msg <nome> <mensagem>."
				}
			},
			
			--Agariodown
			--[[{	{"mods dont work","mods don't work","when the update","update agar.io","updated thing","it doesnt work",
				"update the agariomods","want to update","update agariomods","INSTALL EVERGREEN","mod isnt working","mod doesnt work","agario wont work","agar.io wont work","agario won't work","mods wont work","mod wont work","mod be updated","agariomods is being updated","why wont my agario mods work","AGARIOMODS NOT","agario not work","agario mods are not","agario mods not","agar.io does not","updated again to catch up","update the agar.io","How do I update","agar.io not work","agario isnt working"
				},
				{"The agariomods extension is going under maintenance for updates to work with the new agar.io code. There is also no ETA, you'll have to wait until the developers release."
				}
			},]]
		}
		for a=1,#trigger do
			for b=1,#trigger[a][1] do
				if msg:lower():find(trigger[a][1][b]:lower()) then
					responce=trigger[a][2][math.random(1,#trigger[a][2])]
				end
			end
		end
		if responce~=nil then
			--SendMessage(msg,nick,torr,channel,forces,wasatrigger)
			SendMessage(responce,nick,torr,channel,nil,true)
			SendMessage("sent a trigger to "..nick,"Nickoplier","NOTICE","Nickoplier",nil)
		end 
	end 
end 