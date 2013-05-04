-- CraftOS+ by Sirharry0077

-- Variables
name = "CraftOS+ "
changesVersion = "7.0.1" -- Development Purposes Only
OSversion = "7.0"  -- Displays
noconnection = "true"
version = "recommended"
newVersion = 0
testNumber = 0
if term.isColor() then
	color = true
else
	color = false
end

-- Main Functions

function MainEncrypt()
local function zfill(N)
	N=string.format("%X",N)
	Zs=""
	if #N==1 then
		Zs="0"
	end
	return Zs..N
end

local function serializeImpl(t)	
	local sType = type(t)
	if sType == "table" then
		local lstcnt=0
		for k,v in pairs(t) do
			lstcnt = lstcnt + 1
		end
		local result = "{"
		local aset=1
		for k,v in pairs(t) do
			if k==aset then
				result = result..serializeImpl(v)..","
				aset=aset+1
			else
				result = result..("["..serializeImpl(k).."]="..serializeImpl(v)..",")
			end
		end
		result = result.."}"
		return result
	elseif sType == "string" then
		return string.format("%q",t)
	elseif sType == "number" or sType == "boolean" or sType == "nil" then
		return tostring(t)
	elseif sType == "function" then
		local status,data=pcall(string.dump,t)
		if status then
			return 'func('..string.format("%q",data)..')'
		else
			error()
		end
	else
		error()
	end
end

local function split(T,func)
	if func then
		T=func(T)
	end
	local Out={}
	if type(T)=="table" then
		for k,v in pairs(T) do
			Out[split(k)]=split(v)
		end
	else
		Out=T
	end
	return Out
end

local function serialize( t )
	t=split(t)
	return serializeImpl( t, tTracking )
end

local function unserialize( s )
	local func, e = loadstring( "return "..s, "serialize" )
	local funcs={}
	if not func then
		return e
	end
	setfenv( func, {
		func=function(S)
			local new={}
			funcs[new]=S
			return new
		end,
	})
	return split(func(),function(val)
		if funcs[val] then
			return loadstring(funcs[val])
		else
			return val
		end
	end)
end

local function sure(N,n)
	if (l2-n)<1 then N="0" end
	return N
end

local function splitnum(S)
	Out=""
	for l1=1,#S,2 do
		l2=(#S-l1)+1
		CNum=tonumber("0x"..sure(string.sub(S,l2-1,l2-1),1) .. sure(string.sub(S,l2,l2),0))
		Out=string.char(CNum)..Out
	end
	return Out
end

local function wrap(N)
	return N-(math.floor(N/256)*256)
end

function checksum(S,num)
	local sum=0
	for char in string.gmatch(S,".") do
		for l1=1,(num or 1) do
			math.randomseed(string.byte(char)+sum)
			sum=sum+math.random(0,9999)
		end
	end
	math.randomseed(sum)
	return sum
end

local function genkey(len,psw)
	checksum(psw)
	local key={}
	local tKeys={}
	for l1=1,len do
		local num=math.random(1,len)
		while tKeys[num] do
			num=math.random(1,len)
		end
		tKeys[num]=true
		key[l1]={num,math.random(0,255)}
	end
	return key
end

function encrypt(data,psw)
	data=serialize(data)
	local chs=checksum(data)
	local key=genkey(#data,psw)
	local out={}
	local cnt=1
	for char in string.gmatch(data,".") do
		table.insert(out,key[cnt][1],zfill(wrap(string.byte(char)+key[cnt][2])),chars)
		cnt=cnt+1
	end
	return string.sub(serialize({chs,table.concat(out)}),2,-3)
end

function decrypt(data,psw)
	local oData=data
	data=unserialize("{"..data.."}")
	if type(data)~="table" then
		return oData
	end
	local chs=data[1]
	data=data[2]
	local key=genkey((#data)/2,psw)
	local sKey={}
	for k,v in pairs(key) do
		sKey[v[1]]={k,v[2]}
	end
	local str=splitnum(data)
	local cnt=1
	local out={}
	for char in string.gmatch(str,".") do
		table.insert(out,sKey[cnt][1],string.char(wrap(string.byte(char)-sKey[cnt][2])))
		cnt=cnt+1
	end
	out=table.concat(out)
	if checksum(out or "")==chs then
		return unserialize(out)
	end
	return oData,out,chs
end

end

function MainAPI()

function download(url, path)
 http.request(url)
 local requesting = true
 while requesting do
  local event, url, sourceText = os.pullEvent()
  if event == "http_success" then
   local respondedText = sourceText.readAll()
   requesting = false
   local getFile = http.get(url)
   local text = getFile.readAll()
   getFile.close()
   file = fs.open(path, "w")
   file.write(text)
   file.close()
   success = true
  elseif event == "http_failure" then
   requesting = false
   success = false
  end
 end
end

function screenClear()
  termClear()
  if color == true then term.setTextColor(colors.yellow) end
  print(name..OSversion)
  print("------------")
  if color == true then term.setTextColor(colors.red) end
end

function makeLine(text)
	length = string.len(text)
	length = length - 1
	line = "-"
	repeat
		line = line.."-"
		length = length - 1
	until length == 0
	return line
end

function decryptFile(program, password)
	if fs.exists(program) == true then
		file = fs.open(program, "r")
		data = file.readAll()
		file.close()
		data = decrypt(data, password)
		fs.delete(program)
		file = fs.open(program, "w")
		file.write(data)
		file.close()
	else
		print("File Does Not Exist")
	end
end

function encryptFile(program, password)
	if fs.exists(program) == true then
		file = fs.open(program, "r")
		data = file.readAll()
		file.close()
		data = encrypt(data, password)
		fs.delete(program)
		file = fs.open(program, "w")
		file.write(data)
		file.close()
	else
		print("File Does Not Exist")
	end
end

function termClear()
	term.clear()
	term.setCursorPos(1,1)
end

function yn()
	yes = false
	stop = false
	repeat
	write("Y/N: ")
	r = read()
	if r == "y" or r == "Y" then
		yes = true
		stop = true
	elseif r == "n" or r == "N" then
		yes = false
		stop = true
	else
		print("Invalid Response")
		stop = false
	end
	until stop == true
end

function center(text, xoffset, yoffset)
	if xoffset == nil then xoffset = 0 end
	if yoffset == nil then yoffset = 0 end
	if text ~= nil then
		len = string.len(text)
		len = math.ceil(len / 2)
	else
		len = 2
	end
	local x,y = term.getSize()
	x = math.ceil((x / 2) - len + xoffset)
	y = math.ceil((y / 2) + yoffset)
	term.setCursorPos(x, y)
	if text ~= nil then
		print(text)
	end
end

function startMenu( tMenu, sTitle )
        local function printMenu( tMenu, sTitle, nSelected )
                for index, text in pairs( tMenu ) do
                        term.setCursorPos( startXPos, startYPos + index - 1 )
                        write( (nSelected == index and '[' or ' ') .. text .. (nSelected == index and ']' or ' ')  )
                end
        end
        local selection = 1
        while true do
                printMenu( tMenu, sTitle, selection )
                event, but = os.pullEvent("key")
                if but == keys.up then
                        -- Up
                        selection = selection - 1
                elseif but == keys.down then
                        -- Down
                        selection = selection + 1
                elseif but == keys.enter then
                        -- Enter
                        return tMenu[selection], selection -- returns the text AND the number
                end
                selection = selection < 1 and #tMenu or selection > #tMenu and 1 or selection
        end
end

function checkStartup()
	if fs.exists("bin/startup") == true then
		file = fs.open("bin/startup", "r")
		text = file.readLine()
		file.close()
		if fs.exists(text) == true then
			shell.run(text)
		end
	end
end

end

function MainComputerFunctions()

function checkFirstTime()
 if fs.exists("bin") == false then
  if color == true then term.setTextColor(colors.yellow) end
  print("Welcome To "..name)
  print("-------------------")
  if color == true then term.setTextColor(colors.red) end
  print("Just Press ENTER To Proceed")
  read()
  termClear()
 end
 
 if fs.exists("bin/username") == false then
  if color == true then term.setTextColor(colors.yellow) end
  print("Create Username")
  print("---------------")
  if color == true then term.setTextColor(colors.red) end
  write("Username: ")
  newusername = read()
  fs.makeDir("bin")
  file = fs.open("bin/username", "w")
  file.write(newusername)
  file.close()
  termClear()
 end

 if fs.exists("bin/password") == false then
  if color == true then term.setTextColor(colors.yellow) end
  print("Create Password")
  print("---------------")
  if color == true then term.setTextColor(colors.red) end
  write("Password: ")
  newpassword = read("*")
  newpassword = encrypt(newpassword, newpassword)
  fs.makeDir("bin")
  file = fs.open("bin/password", "w")
  file.write(newpassword)
  file.close()
  termClear()
 end
end

function fetchComputerID()
computerid = os.computerID()
end

function writeLoginSreen() 
 termClear()
 term.setCursorPos(1, 1)
 if color == true then term.setTextColor(colors.red) end
 print("Computer #", computerid)
 
 if color == true then term.setTextColor(colors.yellow) end
 text1 = name..OSversion
 center(text1, 0, -4)
 
 if color == true then term.setTextColor(colors.yellow) end
 text2 = name..OSversion
 writeLine(text2)
 center(line, 0, -3)
 
 if color == true then term.setTextColor(colors.red) end
 text3 = "Username: "
 center(text3, -4, -1)
 file = fs.open("bin/username", "r")
 user = file.readLine()
 file.close()
 text6 = nil
 center(text6, 3, -1)
 print(user)

 if color == true then term.setTextColor(colors.red) end
 text4 = "Password: "
 center(text4, -4, 0)
 file = fs.open("bin/password", "r")
 pass = file.readLine()
 file.close()
 text5 = nil
 center(text5, 3, 0)
 pass2 = read("*")
 pass1 = encrypt(pass2, pass2)
 if pass1 == pass then
  screenClear()
 else
  writeLoginSreen()
 end
end

function setComputerLabel()
 file = fs.open("bin/username", "r")
 user = file.readLine()
 file.close()
 cid = os.getComputerID()
 label = user.."'s Computer | ID "..cid
 os.setComputerLabel(label)
end

function helpFunction()
termClear()
if color == true then term.setTextColor(colors.yellow) end
print(name.."Help")
print("-------------")
if color == true then term.setTextColor(colors.red) end
help = [[
Command Line:
	-Access To Built In ComputerCraft Programs.
	-Access To Encrypt/Decrypt Programs.
Firewolf:
	-RedNet Internet Browser.
Press ENTER To Exit
]]
print(help)
read()
end

end

function MainMenus()

function mainMenu()
	termClear()
	term.setCursorPos(1,1)
	if color == true then term.setTextColor(colors.yellow) end
	print(name..OSversion)
	print("------------")
	if color == true then term.setTextColor(colors.red) end
	local tSelections = {
			"Command Line",
			"Rednet",
			"Logout",
			"Help"
	}
	startYPos = 4
	startXPos = 5
	
	sOption, nNumb = startMenu( tSelections )

	if nNumb == 1 then
		commandLine()
	elseif sOption == "Help" then
		helpFunction()
		mainMenu()
	elseif sOption == "Logout" then
		writeLoginSreen()
		mainMenu()
	elseif sOption == "Rednet" then
		rednet()
	end
end

function rednet()
	termClear()
	term.setCursorPos(1,1)
	if color == true then term.setTextColor(colors.yellow) end
	print("Rednet")
	print("------")
	if color == true then term.setTextColor(colors.red) end
	x = 6
	stop = false
	repeat
		if x == 6 then side = "top"
		elseif x == 5 then side = "bottom"
		elseif x == 4 then side = "front"
		elseif x == 3 then side = "back"
		elseif x == 2 then side = "right"
		elseif x == 1 then side = "left"
		elseif x == 0 then 
			print("There is no modem connected.")
			print("Please connect a modem before using rednet.")
			sleep(5)
			mainMenu()
		end
		
		if peripheral.isPresent(side) == true then
			if peripheral.getType(side) == "modem" then
				modem = peripheral.wrap(side)
				stop = true
			end
		end
		x = x - 1
	until stop == true
	local tSelections = {
			"Chat",
			"Broadcast",
			"Back",
			"Help"
	}
	startYPos = 4
	startXPos = 5
	
	sOption, nNumb = startMenu( tSelections )

	if sOption == "Back" then
		mainMenu()
	elseif sOption == "Broadcast" then
		termClear()
		if color == true then term.setTextColor(colors.yellow) end
		print("Broadcast")
		print("---------")
		if color == true then term.setTextColor(colors.red) end
		write("Channel: ")
		channel = read()
		write("Message: ")
		msg = read()
		channel = tonumber(channel)
		modem.transmit(channel, channel, msg)
		print("Sent!")
		sleep(3)
	elseif sOption == "Chat" then
		override = false
		yPos = 1
		screenSizeX, screenSizeY = term.getSize()
		
		termClear()
		if color == true then term.setTextColor(colors.yellow) end
		print("Chat")
		print("----")
		if color == true then term.setTextColor(colors.red) end
		print("Chose A Username")
		write("Username: ")
		username = read()
		print("Chose A Channel")
		stop = false
		repeat
		write("Channel: ")
		channel = read()
		channel = tonumber(channel)
		if type(channel) ~= "number" then
			print("Channel Must Be A Number")
		else
			stop = true
		end
		until stop == true
		test()
		msg = username..": "
		modem.open(channel)
		term.clear()
		messageTable = {}
		numberMsgString = tostring(numberMsg)
		term.setCursorPos(1, 1)
		while true do
			sleep(1)
			
			-- Print Out All Messages And Formating
			termClear()
			numberMsg = #messageTable
			term.setCursorPos(1,1)
			greeting = "Chatroom: "..channel
			print(greeting)
			print(writeLine(greeting))
			term.setCursorPos(1,3)
			number = numberMsg - 12
			repeat
			number = number + 1
			until  number >= 0
			while true do
				number = number + 1
				print(messageTable[number])
				if number == #messageTable then break end
			end
			term.setCursorPos(1, screenSizeY)
			print(msg)
			
			-- Wait For Event
			numberMsg = #messageTable
			event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent()
			if event == "key" then
				if modemSide == 28 then  -- Enter Key
					table.insert(messageTable, msg)
					modem.transmit(channel, channel, msg)
					msg = username..": "
				elseif modemSide == 14 then  -- Backspace Key
					msg = string.sub(msg, 1, string.len(msg) - 1)
				end
			elseif event == "char" then
				msg = msg..modemSide
			elseif event == "modem_message" then
				table.insert(messageTable, message)
			end
			
			if override == true then break end
		end
	end
	rednet()
end

function commandLine()
termClear()
if color == true then term.setTextColor(colors.yellow) end
print("Command Line")
print("------------")
if color == true then term.setTextColor(colors.red) end
print('Type "exit" To Exit The Command Line')
arguments = {}
invalidcommands = {}
fail = false
while true do
 if color == true then term.setTextColor(colors.red) end
 oldpullEvent = os.pullEvent
 os.pullEvent = os.pullEventRaw
 
 write("> ")
 local command = read()
 for match in string.gmatch(command, "[^ \t]+") do
   table.insert( arguments, match )
 end
 
 for i,v in ipairs(invalidcommands) do
  if arguments[1] == v then
   print("Invalid command.")
   sleep(1)
   fail = true
  end
 end
 
 if not fail then
  if arguments[1] == "clear" then
   clearSreen()
  elseif arguments[1] == "encrypt" then
   commandEncrypt()
  elseif arguments[1] == "decrypt" then
   commandDecrypt()
  elseif arguments[1] == "exit" then
   setColor()
   mainMenu()
  elseif arguments[1] == "network" then
   network(arguments[2])
  else
   if #arguments == 1 then
    shell.run(arguments[1])
   elseif #arguments == 2 then
    shell.run(arguments[1], arguments[2])
   elseif #arguments == 3 then
    shell.run(arguments[1], arguments[2], arguments[3])
   elseif #arguments == 4 then
    shell.run(arguments[1], arguments[2], arguments[3], arguments[4])
   elseif #arguments == 5 then
    shell.run(arguments[1], arguments[2], arguments[3], arguments[4], arguments[5])
   elseif #arguments > 5 then
    print("Too Many Arguments")
   end
   if fs.exists(arguments[1]) == true or arguments[1] == "edit" then
    termClear()
    if color == true then term.setTextColor(colors.yellow) end
    print("Command Line")
    print("------------")
    if color == true then term.setTextColor(colors.red) end
    print('Type "exit" To Exit The Command Line')
   end
  end
 end
 fail = false
 arguments = {}
 
 os.pullEvent = oldpullEvent
end
end


end

function MainCommands()

function commandEncrypt()
	if #arguments == 3 or #arguments == 4 then
		program = arguments[2]
		password = arguments[3]
		if fs.exists(program) == true then
			print("Encrypting "..program)
			file = fs.open(program, "r")
			data = file.readAll()
			file.close()
			data = encrypt(data, password)
			fs.delete(program)
			file = fs.open(program, "w")
			file.write(data)
			file.close()
			print("Encrypted "..program)
			if arguments[4] == "print" then
				print(data)
			end
		else
			print("File Does Not Exist")
		end
	else
		print("Usage: encrypt <file> <password>")
	end
end

function commandDecrypt()
	if #arguments == 3 or #arguments == 4 then
		program = arguments[2]
		password = arguments[3]
		if fs.exists(program) == true then
			print("Decrypting "..program)
			file = fs.open(program, "r")
			data = file.readAll()
			file.close()
			data1 = decrypt(data, password)
			fs.delete(program)
			file = fs.open(program, "w")
			file.write(data1)
			file.close()
			if encrypt(data1, password) == data then
				print("Decrypted "..program)
				if arguments[4] == "print" then
					print(data1)
				end
			else
				print("Incorrect Decryption Password")
			end
		else
			print("File Does Not Exist")
		end
	else
		print("Usage: decrypt <file> <password>")
	end
end

end

function MainOther()

function setColor()
	if color == true then
		if color == true then term.setTextColor(colors.yellow) end
	end
end

function test()
	testNumber = testNumber + 1
	print("Test: "..testNumber)
end

end

function MainLoadFunctions()
    MainEncrypt()
    MainAPI()
    MainComputerFunctions()
    MainMenus()
    MainCommands()
    MainOther()
end

function MainStartup()
MainLoadFunctions()
setColor()
termClear()
oldpullEvent = os.pullEvent
os.pullEvent = os.pullEventRaw

checkFirstTime()
checkStartup()
termClear()
print("Loading...")

fetchComputerID()
setComputerLabel()
writeLoginSreen()

mainMenu()
end

-- Code

MainStartup()

-- End