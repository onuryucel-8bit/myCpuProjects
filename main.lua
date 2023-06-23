
local info = {
    version = "0.1",
    data_line = "4-bit",
    address_line = "8-bit",
    maxCommand_line = 86,
    ram = "256 x 4 :: 1kb",
    command_limit = 16
}

local commandSet = {
    HLT = "0",
    LDA = "1",
    STR = "2",
    ADD = "3",

    SUB = "4",
    AND = "5",
    OR  = "6",
    XOR = "7",

    INC = "8",
    DEC = "9",
    OUT = "A",
    JMP = "B",

    JNE = "C",
    JE  = "D",
    JLT = "E",
    JGT = "F"
}

local startingPoint

local ram_type_plain =[[v3.0 hex words plain
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
]]

local ram = [[v3.0 hex words addressed
00: 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
20: 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
40: 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
60: 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
80: 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
a0: 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
c0: 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
e0: 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]]


--[[
TODOS 
-create_Ram
-fix startingPoint of program
]]--

local create_Ram = function (size)
    local ram = ""
    
    --code here

    return ram
end

local get_StartingPosition = function (line)
    ---take starting point of program--
    local index = 8
    local startingIndex = 8
    local program_StartIndex

    while string.sub(line,index,index) ~= '\n' do
        program_StartIndex = string.sub(line,startingIndex,index)
        index = index + 1
    end
    
    print("program starting index:" .. program_StartIndex)
end

local showError = function (error_Line,error_message)
    print()
    print("Syntax ERROR at line: "..error_Line.." :: "..error_message .. "\n")
    
end

local replace_char = function(pos, str, r)
    return str:sub(1, pos-1) .. r .. str:sub(pos+1)
end

local write_source = function (text_output)
    
    
    local file_output = io.open("output.txt","w")

    if file_output == nil then
        print("ERROR: output.txt")
        return
    end

    ---output.txt---

    local ram_Start = 22
    local output_index = 1
    
    while output_index < text_output:len() do

        --123456789abcde
        --a*bc,d*ef,g*tw
        
        ram_type_plain = replace_char(ram_Start,ram_type_plain,text_output:sub(output_index,output_index))
        
        output_index = output_index + 2
        ram_Start = ram_Start + 2 -- ram position
        

    end
    
    print("------OUTPUT------")
    print(ram_type_plain)

    file_output:write(ram_type_plain)
    file_output:close()
end

local Assembler = function ()

    print("------------------")
    local file = io.open("input.txt","r")

    if file == nil then
        return
    end

    local line = file:read("L")
    
    if string.sub(line,1,6) ~= "START:" then
        print("ERROR start")
        return
    end

    get_StartingPosition(line)

    --#region readCommand
    
    local error_message = "default error"
    local foundit = false
    local error_Line = 1

    line = file:read("l")

    local text_output = ""

    local token = ""
    local address

    local memory_limit = 256
    local memory_used = 0

    local array_ram = {}
    for i = 1, 256, 1 do
        table.insert(array_ram,0)
    end

    while line ~= nil do
        
        line = string.upper(line)
        foundit = false
        token = ""
        address = ""
        
        --#region tokens
        ---Get token---
        for i = 1, #line, 1 do

            if string.sub(line,i,i) == " " then
                break            
            else                
                token = token .. string.sub(line,i,i)
            end
        end
        --print("TOKEN:"..token)

        ---is token valid---
        for key, value in pairs(commandSet) do
            
            if token == key then
                
                --PUT <address> <data>
                if key == "PUT" then
                    local dec_addr = tonumber("address",16)
                end

                
                if key == "HLT" or key == "OUT" then
                    
                    --ELSE  HLT or OUT
                    memory_used = memory_used + 1
                     
                    if memory_used > memory_limit then
                        foundit = false
                        error_message = "Memory limit exceed"
                        break
                    end
 
                    text_output = text_output .. value .. ","                 
                    foundit = true
                    break

                ---take address
                else
                    
                    ---ADD f
                    memory_used = memory_used + 3
                    

                    if memory_used > memory_limit then
                        foundit = false
                        error_message = "Memory limit exceed"
                        break
                    end

                    if string.sub(line,4,5) == " " then
                        error_message = "you forget the address"
                        foundit = false
                        break
                    end

                    
                    address = string.sub(line,5,6)
                    
                    text_output = text_output .. value .. "*" .. string.sub(address,1,1) .. "*" .. string.sub(address,2,2) .. ","
                    
                    foundit = true
                    break
                end

            
            end --IF END TOKEN == ..
        
        end --FOR END
        --#endregion

        if foundit == false then
            
            showError(error_Line,error_message)
            return
        end

        error_Line = error_Line + 1
        --print(text_output)
        
        

        line = file:read("l")
    end

    file:close()

    --#endregion
    
    write_source(text_output)

end

Assembler()

