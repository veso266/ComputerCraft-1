-- CraftOS+ Client by Sirharry0077

-- Variables
changesVersion = "6.2.2" -- Development Purposes Only
OSversion = "6.2"  -- Displays
noconnection = "true"
version = "recommended"
newVersion = 0
skip = "false"

-- Get Variable
rootFolder1 = "https://raw.github.com/Sirharry0077/ComputerCraft/master/"
rootFolder = rootFolder1..version.."/"
if term.isColor() then
	color = true
else
	color = false
end

-- Functions

local function openRednet()
local listOfSides = rs.getSides()
local listofPossibles = {}
local counter1 = 0
while true do
  counter1 = counter1 +1

  if peripheral.isPresent(tostring(listOfSides[counter1])) and peripheral.getType(listOfSides[counter1]) == "modem" then
   table.insert(listofPossibles,tostring(listOfSides[counter1]))
  end

  if counter1 == 6 and table.maxn(listofPossibles) == 0 then
   print("no wifi present")
   return nil
  end

  if counter1 == 6 and table.maxn(listofPossibles) ~= 0 then
   rednet.open(listofPossibles[1])
   return listofPossibles[1]
  end
end
end
modemOn = openRednet()
if modemOn == nil then
print("No WIFI Modem")
print("Will shutdown in 3 seconds")
sleep(3)
os.shutdown()
else
print("Opened wifi on "..modemOn.." side")
end

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

function setServerID()
 file = fs.open("bin/server", "r")
 serverid = file.readLine()
 file.close()
 serverid = tonumber(serverid)
end

function checkNewerVersion()
 download(rootFolder.."programs/version", "bin/version")
 file = fs.open("bin/version", "r")
 newVersion = file.readLine()
 file.close()
 fs.delete("bin/version")
 if success == false then
  newVersion = "0"
 end
 vnumber = tonumber(OSversion)
 newvnumber = tonumber(newVersion)
 if newvnumber > vnumber then
  termClear()
  if color == true then term.setTextColor(colors.yellow) end
  print("Update ", newversion, " Available")
  print("---------------------")
  if color == true then term.setTextColor(colors.red) end
  download(rootFolder.."programs/changelog", "bin/changelog")
  file = fs.open("bin/changelog", "r")
  changelog = file.readAll()
  file.close()
  if success == false then
   print("Did Not Receive Change Log")
  else
   print("Change Log: ")
   print(changelog)
  end
  write("Update Y/N?: ")
  answer = read()
  termClear()
  if answer == "y" then
   shell.run("install")
  elseif answer == "n" then
   if color == true then term.setTextColor(colors.yellow) end
   print("Loading...")
  elseif answer == "Y" then
   shell.run("install")
  elseif answer == "N" then
   if color == true then term.setTextColor(colors.yellow) end
   print("Loading...")
  else
   print("Unrecognized Answer")
   print("Update Canceled")
   sleep(2)
  end  
 end
end

function testServerConnection()
 rednet.send(serverid, "testconnection")
 id, connection = rednet.receive(3)
 if id == nil then
  noconnection = "true"
 elseif id == serverid then
  noconnection = "false"
 end
end

local function checkFirstTime()
 if fs.exists("bin") == false then
  if color == true then term.setTextColor(colors.yellow) end
  print("Welcome To CraftOS+")
  print("-------------------")
  if color == true then term.setTextColor(colors.red) end
  print("Just Press ENTER To Proceed")
  read()
  termClear()
 end

 if fs.exists("bin/server") == false then
  if color == true then term.setTextColor(colors.yellow) end
  print("Choose Server")
  print("-------------")
  if color == true then term.setTextColor(colors.red) end
  print("This Is The ID of The Server That You Would Like To Use")
  print("The ID Must Be A Number")
  write("Server: ")
  newserver = read()
  fs.makeDir("bin")
  file = fs.open("bin/server", "w")
  file.write(newserver)
  file.close()
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

function screenClear()
  termClear()
  if color == true then term.setTextColor(colors.yellow) end
  print("CraftOS+ ", OSversion)
  print("------------")
  if color == true then term.setTextColor(colors.red) end
end

function writeLine(text)
	length = string.len(text)
	length = length - 1
	line = "-"
	repeat
		line = line.."-"
		length = length - 1
	until length == 0
end

function writeLoginSreen() 
 termClear()
 term.setCursorPos(1, 1)
 if color == true then term.setTextColor(colors.red) end
 print("Computer #", computerid)
 
 if color == true then term.setTextColor(colors.yellow) end
 text1 = "CraftOS+ "..OSversion
 center(text1, 0, -4)
 
 if color == true then term.setTextColor(colors.yellow) end
 text2 = "CraftOS+ "..OSversion
 writeLine(text2)
 center(line, 0, -3)
 
 if color == true then term.setTextColor(colors.red) end
 term.setCursorPos(1, 1)
 if noconnection == "true" then
  print("No Server Connection")
 end

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

local function setComputerLabel()
 file = fs.open("bin/username", "r")
 user = file.readLine()
 file.close()
 cid = os.getComputerID()
 label = user.."'s Computer | ID "..cid
 os.setComputerLabel(label)
end

function commandUpload()
 termClear()
 if color == true then term.setTextColor(colors.yellow) end
 print("Upload To Server")
 print("----------------")
 if color == true then term.setTextColor(colors.red) end
 write("File: ")
 filename = read()
 if fs.exists(filename) == false then
  print("File Doesn't Exist")
  sleep(2)
  --commandUpload()
  return
 end
 write("Destination: ")
 destination = read()
 file = fs.open(filename, "r")
 filetext = file.readAll()
 file.close()
 rednet.send(serverid, "upload")
 sleep(1)
 rednet.send(serverid, destination)
 sleep(1)
 rednet.send(serverid, filetext)
 id, msg = rednet.receive(5)
 if msg == "success" then
  print("Upload Successful")
 elseif id == nil then
  print("No Server Response")
 else
  print("Upload Unsuccessful")
 end
 sleep(2)
 screenClear()
end

function commandDownload()
 if color == true then term.setTextColor(colors.yellow) end
 termClear()
 print("Download")
 print("--------")
 if color == true then term.setTextColor(colors.red) end
 write("File: ")
 filename = read()
 write("Location: ")
 filename2 = read()
 rednet.send(serverid, "download")
 sleep(1)
 rednet.send(serverid, filename2)
 id, filetext = rednet.receive(5)
 if id == serverid and id ~= nil then
  print("File Received")
  file = fs.open(filename, "w")
  file.write(filetext)
  file.close()
 else
  print("No Server Response")
 end
 sleep(2)
 screenClear()
end

function stopServer()
 termClear()
 if color == true then term.setTextColor(colors.yellow) end
 print("Stopping Server...")
 print("------------------")
 if color == true then term.setTextColor(colors.red) end
 rednet.send(serverid, "stop")
 id, msg = rednet.receive(5)
 if msg == "stopped" then
  print("Server Stopped")
 elseif id == nil then
  print("No Server Response")
 end
 sleep(2)
 screenClear()
end

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

function setColor()
	if color == true then
		if color == true then term.setTextColor(colors.yellow) end
	end
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
  elseif arguments[1] == "upload" then
   commandUpload()
  elseif arguments[1] == "download" then
   commandDownload()
  elseif arguments[1] == "encrypt" then
   commandEncrypt()
  elseif arguments[1] == "decrypt" then
   commandDecrypt()
  elseif arguments[1] == "firewolf" then
   shell.run("firewolf")
   screenClear()
   openRednet()
  elseif arguments[1] == "stop" then
   stopServer()
  elseif arguments[1] == "exit" then
   setColor()
   menu()
  elseif arguments[1] == "extra" then
   extraFunction()
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

function menu()
termClear()
term.setCursorPos(1,1)
if color == true then term.setTextColor(colors.yellow) end
print("CraftOS+ "..OSversion)
print("------------")
if color == true then term.setTextColor(colors.red) end

-- Create a table with the selections
local tSelections = {
        "Command Line",
		"Firewolf",
        "Download",
		"Upload",
		"Logout",
		"Help"
}
-- Starting co-ords for table
local startYPos = 4
local startXPos = 5

-- Menu to create/print ... do everything really :P/>
local function startMenu( tMenu, sTitle )
        -- This function just prints the menu
        local function printMenu( tMenu, sTitle, nSelected )
                for index, text in pairs( tMenu ) do
                        term.setCursorPos( startXPos, startYPos + index - 1 )
                        write( (nSelected == index and '[' or ' ') .. text .. (nSelected == index and ']' or ' ')  )
                end
        end
        
        -- Set default selection to the first one
        local selection = 1
        -- Inifinite loop until enter is clicked
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
                -- Advanced way to make the selection 1 if you have gone past the amount of items in the menu,
                -- or make it the amount of items in the menu/table if you have gone past above the first selection
                selection = selection < 1 and #tMenu or selection > #tMenu and 1 or selection
        end
end

sOption, nNumb = startMenu( tSelections ) -- start the function ... 'sOption' and 'nNumb'

if nNumb == 1 then
	commandLine()
elseif sOption == "Download" then
	commandDownload()
	menu()
elseif sOption == "Upload" then
	commandUpload()
	menu()
elseif sOption == "Firewolf" then
	if fs.exists("firewolf") == true then
		shell.run("firewolf")
		setColor()
		openRednet()
		menu()
	end
elseif sOption == "Help" then
	helpFunction()
	menu()
elseif sOption == "Logout" then
	writeLoginSreen()
	menu()
end
end

function helpFunction()
termClear()
if color == true then term.setTextColor(colors.yellow) end
print("CraftOS+ Help")
print("-------------")
if color == true then term.setTextColor(colors.red) end
help = [[
Command Line:
	-Access To Built In ComputerCraft Programs.
	-Access To Encrypt/Decrypt Programs.
	-Download extra programs with "extra".
Firewolf:
	-RedNet Internet Browser.
Download:
	-Download Files From Server.
Upload:
	-Upload Files To Server.
	
Press ENTER To Exit
]]
print(help)
read()
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

function extraFunction()
	usage = "Usage: extra install <program>"
	if #arguments == 3 then
		if arguments[2] == "install" then
			program = arguments[3]
			url = rootFolder1.."extra/"..program
			download(url, program)
			if success == true then
				print(program.." Downloaded Successfully")
			else
				print("Program Doesn't Exist")
			end
		else
			print(usage)
		end
	else
		print(usage)
	end
end
-- Code
setColor()
openRednet()
termClear()
oldpullEvent = os.pullEvent
os.pullEvent = os.pullEventRaw

checkFirstTime()
checkStartup()
termClear()
print("Loading...")

checkNewerVersion()
setServerID()
testServerConnection()
fetchComputerID()
setComputerLabel()
writeLoginSreen()

menu()

-- End