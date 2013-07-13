--[[

 CraftOS+ By Sirharry0077   
    
]]--

-- Varibles
devVersion = "8.0.0" -- Development Purposes Only
version = "8.0"
OSName = "CraftOS+"
defaultTextColor = 16
defaultTitleColor = 16384
defaultBackgroundColor = 32768
bin = "bin"
configFile = bin.."/config.txt"

-- Functions
function API()

	function setSetting(file, name, setting)
		reading = true
		exist = true
		if fs.exists(file) == false then
			reading = false
			exist = false
		end
        if exist == true then
            config = fs.open(file, "r")
        end
		n = 0
		settings  = {}
		while reading do  -- Find if setting already exists and skip it
			n = n + 1
			line = config.readLine()
			if line == nil then
				reading = false
			elseif string.sub(line, 1, string.len(name) + 1) == name..":" then
				line = "Skipped"
			else
				settings[#settings + 1] = line  -- Save all settings except for pre-existing new one
			end
		end
		if exist == true then config.close() end
		fs.delete(file)  -- Delete File
		config = fs.open(file, "w")
		if exist == true then writing = true else writing = false end
		n = 0
		while writing do  -- Rewrite File
			if #settings ~= 0 then
				n = n + 1
				config.writeLine(settings[n])
			end
			if n == #settings then
				writing = false
			end
		end
		config.writeLine(name..": "..setting)  -- Write New Setting
		config.close()
	end
	
	function getSetting(file, name)
		if fs.exists(file) == false then error("No Such Config File", true) end
		config = fs.open(file, "r")
		reading = true
		while reading do
			line = config.readLine()
			if string.sub(line, 1, string.len(name) + 1) == name..":" then
				setting = string.sub(line, string.len(name) + 3, string.len(line))
				reading = false
			elseif line == nil then
				setting = nil
				reading = false
			end
		end
		config.close()
		return setting
	end
	
    function displayMessage(title, what, time)
        clear()
        titleColor()
        print(title)
        print(makeLine(title))
        textColor()
        print(what)
        sleep(time)
    end
    
    function askInput(title, what)
        clear()
        titleColor()
        print(title)
        print(makeLine(title))
        textColor()
        write(what..": ")
        return read()
    end
    
    function textColor()
        term.setTextColor(defaultTextColor)
    end
    
    function titleColor()
        term.setTextColor(defaultTitleColor)
    end
    
    function backgroundColor()
        term.setBackgroundColor(defaultBackgroundColor)
    end

    function ENC()
    
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

    function download(url, path)
        http.request(url)
        local requesting = true
        while requesting do
            local event, url, sourceText = os.pullEvent()
            if event == "http_success" then
                --local respondedText = sourceText.readAll()
                requesting = false
                local getFile = http.get(url)
                local text = getFile.readAll()
                --getFile.close()
                if fs.exists("path") == true then
                    fs.delete("path")
                end
                local file = fs.open(path, "w")
                file.write(text)
                file.close()
                return true
            elseif event == "http_failure" then
                requesting = false
                return false
            end
        end
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

    function yn(title, question)
        clear()
        print(title)
        print(makeLine(title))
        print(question)
        stop = false
        repeat
            write("Y/N: ")
            local response = read()
            response = string.lower(response)
            if response == "y" or "yes" then
                stop = true
                return true
            elseif response == "n" or "no" then
                stop = true
                return false
            else
                print("Invalid Response")
            end
        until stop == true
    end
    
    function centerPrint(text, xoffset, yoffset)
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
    
    function clear()
        term.clear()
        term.setCursorPos(1,1)
    end
    
    function startMenu( tMenu, startXPos, startYPos, sTitle )
            local function printMenu( tMenu, sTitle, nSelected )
                    for index, text in pairs( tMenu ) do
                            term.setCursorPos( startXPos, startYPos + index - 1 )
                            write( (nSelected == index and '[' or ' ') .. text .. (nSelected == index and ']' or ' ')  )
                    end
            end
            local selection = 1
            while true do
                    printMenu( tMenu, sTitle, selection )
                    event, button = os.pullEvent("key")
                    if button == keys.up then
                            -- Up
                            selection = selection - 1
                    elseif button == keys.down then
                            -- Down
                            selection = selection + 1
                    elseif button == keys.enter then
                            -- Enter
                            return tMenu[selection], selection -- returns the text AND the number
                    end
                    selection = selection < 1 and #tMenu or selection > #tMenu and 1 or selection
            end
    end
    
    function error(error, terminate)
        clear()
        titleColor()
        local title = "Error"
        print(title)
        print(makeLine(title))
        textColor()
        print("ERROR: "..error)
        sleep(5)
        if terminate == true then
            os.reboot()
        end
    end
    
    ENC() -- Loads Encryption Functions
    
end

function Client()
    function mainMenu()
        clear()
        term.setCursorPos(1,1)
        titleColor()
        print(OSName.." "..version)
        print("------------")
        textColor()
        local tSelections = {
                "Command Line",
                "Rednet",
                "Logout",
                "Help"
        }

	
        sOption, nNumb = startMenu(tSelections, 4, 4)

        if nNumb == 1 then
            commandLine()
        elseif sOption == "Help" then
            helpFunction()
            mainMenu()
        elseif sOption == "Logout" then
            writeLoginScreen()
        elseif sOption == "Rednet" then
            rednet()
        end
    end

    function writeLoginScreen() 
        clear()
        term.setCursorPos(1, 1)
        textColor()
        print("Computer #"..os.getComputerID())
 
        titleColor()
        title = OSName.." "..version
        centerPrint(title, 0, -4)
        centerPrint(makeLine(title), 0, -3)

        textColor()
        title = "Username: "
        centerPrint(title, -4, -1)
        ux, uy = term.getCursorPos()
        title = "Password: "
        centerPrint(title, -4, 0)
        px, py = term.getCursorPos()
        
        
        centerPrint(nil, 3, -1)
        user = read()
        centerPrint(nil, 3, 0)
        tPassword = read("*")
        
        if fs.exists("bin/UserData") == false then
            error("No User Data", true)
        else
            file = fs.open("bin/UserData", "r")
            repeat
                line = file.readLine()
            until line == nil or line == user
            if line == nil then
                error("Incorrect Username/Password", false)
                writeLoginScreen()
            elseif line == user then
                ePassword = file.readLine()
            end
            
            if tPassword == decrypt(ePassword, tPassword) then
                mainMenu()
            else
                error("Incorrect Username/Password", false)
                writeLoginScreen()
            end
        end
    end

    function createAccount()
        local username = askInput("Pick Username", "Username")
        repeat
            password = askInput("Create Password", "Password")
            password2 = askInput("Re-Enter Your Password", "Password")
            if password ~= password2 then
                displayMessage("ERROR", "Passwords Did Not Match.  Please Try Again.", 3)
            end
        until password == password2
        file = fs.open("bin/UserData", "a")
        file.writeLine(username)
        file.writeLine(encrypt(password, password))
        file.close()
    end
    
    function checkFirstTime()
        if fs.exists("bin/UserData") == false then
            fs.makeDir("bin")
            createAccount()
        end
    end
    
    function ClientStartup()
        checkFirstTime()
        writeLoginScreen()
    end
    
    
    ClientStartup() -- Start Client
end

function Server()
    
end

function KeyPad()
	number = {}
	number[1] = {1, 2, 1}
	number[2] = {2, 2, 2}
	number[3] = {3, 2, 3}
	number[4] = {1, 3, 4}
	number[5] = {2, 3, 5}
	number[6] = {3, 3, 6}
	number[7] = {1, 4, 7}
	number[8] = {2, 4, 8}
	number[9] = {3, 4, 9}
	number[10] = {2, 5, 0}
	function draw()
		mon.setCursorPos(1,1)
		mon.clearLine()
		if #input ~= 0 then
			n = #input
			repeat
				mon.write("*")
				n = n - 1
			until n == 0
		end
		mon.setCursorPos(7,1)
		mon.write("X")
		pn = 0
		printing = true
		while printing do
			pn = pn + 1
			mon.setCursorPos(number[pn][1], number[pn][2])
			mon.write(tostring(number[pn][3]))
			if pn == 10 then printing = false end
		end
	end
	function waitInput()
		event, side, x, y = os.pullEvent("monitor_touch")
		return x, y
	end
	function figure(x, y)
		figureing = true
		success = false
		rn = 0
		while figureing do
			rn = rn + 1
			if number[rn][1] == x and number[rn][2] == y then
				success = true
				figureing = false
			elseif rn == 10 then
				figureing = false
			end
		end
		if success == true then
			return rn
		elseif success == false then
			return nil
		end
	end
	function after(n, x, y)
		if n ~= nil then
			input[#input + 1] = tostring(number[n][3])
			draw()
		end
		if x == 7 and y == 1 then
			if #input ~= 0 and #input ~= 1 then
				a = #input - 1
				temp = {}
				repeat
					temp[a] = input[a]
					a = a - 1
				until a == 0
				input = {}
				a = 0
				repeat
					a = a + 1
					input[a] = temp[a]
				until a == #temp
				draw()
			elseif #input == 1 then
				input = {}
				draw()
			end
		end
		if #input == 4 then
			if tostring(input[1]..input[2]..input[3]..input[4]) == password then			
				mon.clear()
				mon.setCursorPos(1,1)
				mon.write("    ")
				mon.setBackgroundColor(8192)
				input = {}
				draw()
				
				-- Password Correct Code Here
				
				mon.setBackgroundColor(32768)
			else
			
				mon.clear()
				mon.setCursorPos(1,1)
				mon.write("    ")
				mon.setBackgroundColor(16384)
			
				input = {}
				sleep(2)
				draw()
			end
		end
	end
	password = "1234"
	mon = peripheral.wrap("back")
	input = {}
	working = true
	draw()
	rn = 0
	while working do
		rx, ry = waitInput()
		z = figure(rx, ry)
		after(z, rx, ry)
	end
end

function Load()
    if fs.exists(bin) == false then
        fs.makeDir(bin)
    end
    oldpullEvent = os.pullEvent
    os.pullEvent = os.pullEventRaw
    API()
    if fs.exists("bin") == false or fs.exists("bin") == true then
        clear()
        titleColor()
        local title = "Welcome To "..OSName
        print(title)
        print(makeLine(title))
        print("Chose Installation Type")
        textColor()
        options = {
            "Client",
            "Server",
			"Key Pad",
            "Card Reader"
        }
        option, number = startMenu( options, 4, 5)
        
        if option == "Client" then
            Client()
        elseif option == "Server" then
            Server()
		elseif option == "Key Pad" then
			KeyPad()
        elseif option == "Card Reader" then
            cardReader()
        else
            error("Invalid Menu Option", true)
        end
    end
end

function cardReader()
    rConfig = "bin/ReaderConfig"
    if fs.exists("rConfig") == false then
        masterPass = "1"
        repeat
            masterPass = masterPass..tostring(math.random(1, 9))
        until string.len(masterPass) == 32
        setSetting(rConfig, "MasterPass", masterPass)
    end
    function menu()
        tMenu = {
            "Start",
            "Stop",
            "Generate New"
        }
        allowed = true
        startXPos = 4
        startYPos = 4
        sTitle = "Ello"
        local function printMenu( tMenu, sTitle, nSelected )
            clear()
            titleColor()
            title = "Card Reader"
            print(title)
            print(makeLine(title))
            if allowed == true then
                print("Status: Enabled")
            elseif allowed == false then
                print("Status: Disabled")
            end
            for index, text in pairs( tMenu ) do
                term.setCursorPos( startXPos, startYPos + index - 1 )
                write( (nSelected == index and '[' or ' ') .. text .. (nSelected == index and ']' or ' ')  )
            end
        end
        local selection = 1
        event = {}
        while true do
            printMenu( tMenu, sTitle, selection )
            event, event2 = os.pullEvent()
            if event == "key" then
                if event2 == keys.up then
                    -- Up
                    selection = selection - 1
                elseif event2 == keys.down then
                    -- Down
                    selection = selection + 1
                elseif event2 == keys.enter then
                    -- Enter
                    tMenu[selection] = pick
                    if pick == "Start" then
                        allowed = true
                    elseif pick == "Stop" then
                        allowed = false
                    elseif pick == "Generate New" then
                        clear()
                        titleColor()
                        title = "Generate New Card"
                        print(title)
                        print(makeLine(title))
                        textColor()
                        print("Insert Disk")
                        id = tostring(disk.getID())
                        event, side = os.pullEvent("disk")
                        write("Name: ")
                        name = read()
                        number = "1"
                        repeat
                            number = number..tostring(math.random(1, 9))
                        until string.len(number) == 256
                        setSetting(rconfig, number, id)
                        setSetting(rconfig, id, name)
                        number = encrypt(number, getSetting(rConfig, "MasterPass"))
                        path = disk.getMountPath(side)
                        file = fs.open(path.."/number", "w")
                        file.write(number)
                        file.close()
                        disk.setLabel(side, name.."'s ID Card")
                        print("Done")
                        print("Ejecting Disk")
                        disk.eject(side)
                        sleep(2)
                    end
                end
                selection = selection < 1 and #tMenu or selection > #tMenu and 1 or selection
            elseif event == "disk" then
                side = event2
                id = tostring(disk.getID(side))
                path = disk.getMountPath(side)
                if fs.exists(path.."/number") == true then
                    file = fs.open(path.."/number", "r")
                    number = file.readLine()
                    file.close()
                    if number ~= nil then
                        number = decrypt(number, getSetting(rConfig, "MasterPass"))
                        rID = getSetting(rConfig, number)
                        if rID ~= nil then
                            if rID == id then
                                --Allowed Card Inserted Code Here
                                disk.eject(side)
                                redstone.setOutput("back", true)
                                sleep(3)
                                redstone.setOutput("back", false)
                            end
                        end
                    end
                else
                    disk.eject(side)
                end
            end    
        end
    end
    menu()
end

-- Startup
Load() -- Loads API and Intializes Program

-- End