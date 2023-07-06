
local info = {
    version = "0.2",
    data_line = "4-bit",
    address_line = "8-bit",
    maxCommand_line = 86,--en fazla 86 satir kod yazilabilir
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

    NOT = "8",
    INC = "9",
    DEC = "A",
    JEZ = "B",

    JNZ = "C",
    CRA = "D",
    JMP = "E",
    OUT = "F",

    PUT = "assembler_command_1"
}

local assembler_commands = {
    "START",
    "LET"
}

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

local error_Line = 1
local startingPoint

local memory_limit = 256
local memory_used = 0

local error_found = false

local error_message = "default error"

local ram_pos_x = 1

local HEX_TO_DECIMAL_NUMBERS = {
    "1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"
}

---comment
---@param str string
---@return number
local hex_to_decimal = function (str)
       
    --let str FF
    local sum = 0
    --power_ofHEX will be  = 2 - 1 = 1
    local power_ofHEX = #str - 1 
    
    for i = 1, #str, 1 do

        --sub_str will be F
        local sub_str = string.sub(str,i,i)

        for index, value in ipairs(HEX_TO_DECIMAL_NUMBERS) do

            if sub_str == value then
                sum = sum + index * 16^power_ofHEX
                power_ofHEX = power_ofHEX - 1
                
            elseif sub_str == "0" then
                power_ofHEX = power_ofHEX - 1
                break
            end
        end    
    end
    
    return math.floor(sum)
end

---comment
---@return table
local create_Ram = function ()
    local ram = {}
    
    print("ENTER: address bit width")
    --local address_bit_width = io.read("l")

    print("ENTER: data bit width")
    --local data_bit_width = io.read("l")

    --print(2 ^ address_bit_width.. " " .. data_bit_width)

    --create ram array 32x8
    for i = 1, 256, 1 do
        ram[i] = "0"
    end

    return ram
end

---comment
---@param ram table
---@return string
local translate_ram_to_string = function (ram)

    

    --translate ram to string
    local str = ""
    for i = 1, 8*32, 1 do
        str = str .. ram[i]
    end
    
    return str
end

---comment
---@param error_Line integer
---@param error_message string
local showError = function (error_Line,error_message)
    print()
    print("Syntax ERROR at line: "..error_Line + 1 .." :: "..error_message .. "\n")
    error_found = true
end

---comment
---@param line string
---@param token string
---@param ram table
local is_token_valid = function(line,token,ram)

    local right_bit_address
    local left_bit_address
    ---is token valid---
    for key, value in pairs(commandSet) do
        
        if token == key then

            if key == "HLT" or key == "OUT" or key == "NOT" or key == "DEC" or key == "INC" then
                ram[ram_pos_x] = value
                ram_pos_x = ram_pos_x + 1

            elseif key == "PUT" then

                local address = hex_to_decimal(string.sub(line,5,6)) + 1
                local variable_4bit = string.sub(line,8,8)

                ram[address] = variable_4bit
                
            else

                left_bit_address = string.sub(line,5,5)
                right_bit_address = string.sub(line,6,6)

                --load command
                ram[ram_pos_x] = value
                ram_pos_x = ram_pos_x + 1
                    
                --load address
                ram[ram_pos_x] = left_bit_address
                ram_pos_x = ram_pos_x + 1

                ram[ram_pos_x] = right_bit_address
                ram_pos_x = ram_pos_x + 1

                
            end 
            
            return

        end --IF END TOKEN == ..
        
    end --FOR END
        --#endregion

    if error_found == false then
        
        showError(error_Line,"invalid token")
        return 
    end
    
end

---comment
---@param line string
---@return string
local get_token = function (line)
    
    local token = ""

    for i = 1, #line, 1 do

        if string.sub(line,i,i) == " " then
            break            
        else                
            token = token .. string.sub(line,i,i)
        end
    end

    return token
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
    
    startingIndex = startingPoint
    print("program starting index:" .. program_StartIndex)
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
    
    while output_index < text_output:len() + 1 do

        --123456789abcde
        --a*bc,d*ef,g*tw
        
        ram_type_plain = replace_char(ram_Start,ram_type_plain,text_output:sub(output_index,output_index))
        
        
        output_index = output_index + 1
        ram_Start = ram_Start + 2 -- ram position
        

    end
    
    
    print("------OUTPUT------")
    --print(ram_type_plain)

    file_output:write(ram_type_plain)
    file_output:close()
end

local Assembler = function ()

    local ram = create_Ram()

    print("------------------")
    local file = io.open("input.txt","r")

    if file == nil then
        return
    end

    local line = file:read("L")
    
    if string.sub(line,1,6) ~= "START:" then
        showError(0,"START missing")
        return
    end

    get_StartingPosition(line)

    --#region readCommand
    
    line = file:read("l")

    local token

    while line ~= nil do
        
        line = string.upper(line)
        error_found = false
        token = ""
        

        token = get_token(line)
        
        is_token_valid(line,token,ram)

        error_Line = error_Line + 1

        if error_found then
            file:close()
            return
        end

        line = file:read("l")
    end

    file:close()

    --#endregion
    
    local machine_code = translate_ram_to_string(ram)
    
    write_source(machine_code)

end


--print(hex_to_decimal("FF"))
print("================== PROGRAM STARTED =====================")
Assembler()
--local a = "1AF3DD00000000000000000000000000"
--print(#a)

