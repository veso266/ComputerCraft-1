--[[

 CraftOS+ By Sirharry0077   
    
]]--

-- Varibles
devVersion = "8.0.0" -- Development Purposes Only
version = "8.0"
name = "CraftOS+"
defaultTextColor = 16
defaultTitleColor = 16384
defaultBackgroundColor = 32768

-- Functions
function API()


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
        print(name.." "..version)
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
        local title = name.." "..version
        centerPrint(title, 0, -4)
        centerPrint(makeLine(title), 0, -3)

        textColor()
        local title = "Username: "
        centerPrint(title, -4, -1)
        ux, uy = term.getCursorPos()
        local title = "Password: "
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

function Load()
    oldpullEvent = os.pullEvent
    os.pullEvent = os.pullEventRaw
    API()
    if fs.exists("bin") == false or fs.exists("bin") == true then
        clear()
        titleColor()
        local title = "Welcome To "..name
        print(title)
        print(makeLine(title))
        print("Chose Installation Type")
        textColor()
        options = {
            "Client",
            "Server"
        }
        option, number = startMenu( options, 4, 5)
        
        if option == "Client" then
            Client()
        elseif option == "Server" then
            Server()
        else
            error("Invalid Menu Option", true)
        end
    end
end

-- Startup
Load() -- Loads API and Intializes Program

-- End