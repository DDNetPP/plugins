function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         local key = k
         if type(k) ~= 'number' then key = '""'..k..'""' end
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
---@param params string expected arguments string like "ssi"
---@param args string arguments we got from the user
---@return ConsoleArgParseResult
function parse_args(params, args)

   ---@class ParsedParam
   ---@field name string the name of the param
   ---@field type string the type of the param, possible values "i", "r", "s"

   ---@type ParsedParam[]
   pparams = {}

   for c in params:gmatch"." do
      table.insert(pparams, {
         name = nil,
         type = c
      })
   end

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
      print("param with type " .. param.type)

      if words[i] == nil then
         return {
            error = "missing arg. usage: " .. params,
            args = nil
         }
      end

      ---@type string|integer
      local key = param.name
      if key == nil then
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

args = parse_args("ssi", "some random 2")
if args.error then
   print("error: " .. args.error)
   os.exit(1)
end
args = args.args
print("got args: " .. dump(args))
