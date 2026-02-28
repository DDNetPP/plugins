function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         local key = k
         if k == true then key = "true"
         elseif k == false then key = "false"
         elseif type(k) ~= 'number' then key = '""'..k..'""' end
         s = s .. '['..key..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end


---@class ConsoleArgParseResult
---@field error string|nil error message or nil if it was successful
---@field args table<string,any>|nil the parses arguments with their name as key and value as value or nil on error

--- Parse console arguments 
---@param params string expected teeworlds rcon arguments string. Example: "s[name]i[id]"
---@param args string arguments we got from the user
---@return ConsoleArgParseResult
function parse_args(params, args)

   ---@class ParsedParam
   ---@field name string the name of the param
   ---@field type string the type of the param, possible values "i", "r", "s"

   ---@type ParsedParam[]
   pparams = {}

   ---@type string|false
   local current_name = false

   ---@type string|false
   local current_type = false

   for c in params:gmatch"." do
      print("c = " .. c)
      if current_name then
         if c == "]" then
            table.insert(pparams, {
               name = current_name,
               type = current_type
            })
            current_name = false
            current_type = false
         else
            current_name = current_name .. c
         end
      elseif c == "[" then
         current_name = ""
      elseif (c == "i") or (c == "s") then
         if current_type then
            table.insert(pparams, {
               name = current_name,
               type = current_type
            })
            current_name = false
            current_type = false
         end
         current_type = c
      else
         return {
            error = "unsupported parameter type '" .. c .. "'",
            args = nil
         }
      end
   end

   print(dump(pparams))

   local result = {
      error = nil,
      args = {}
   }

   -- TODO: add multi word arg support with quotes
   local words = {}
   for word in string.gmatch(args, "%S+") do
      words[#words+1] = word
   end
   for i,param in ipairs(pparams) do
      print(dump(param))
      print("param with type " .. param.type)

      if words[i] == nil then
         return {
            error = "missing arg. usage: " .. params,
            args = nil
         }
      end

      ---@type string|integer
      local key = param.name
      if key == false then
         key = #result.args+1
      end

      if param.type == "s" then
         result.args[key] = words[i]
      elseif param.type == "i" then
         local num = tonumber(words[i])
         if num == nil then
            return {
               error = "argument '" .. words[i] .. "' is not a valid integer",
               args = nil
            }
         end
         result.args[key] = num
      else
         return {
            error = "unknown parameter type " .. param.type,
            args = nil
         }
      end

      print(" arg: " .. words[i])
   end

   return result
end

args = parse_args("s[name]si[age]", "some random 2")
if args.error then
   print("error: " .. args.error)
   os.exit(1)
end
args = args.args
print(" got name " .. args.name .. " and age " .. args.age)
print("got args: " .. dump(args))
