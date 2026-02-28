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
         name = "unnamed",
         type = c
      })
   end

   for _,param in ipairs(pparams) do
      print("param " .. param.name .. " with type " .. param.type)

   end

   return {
      error = "not implemented",
      args = nil
   }
end

args = parse_args("ssi", "some random args")
if args.error then
   print("error: " .. args.error)
   os.exit(1)
end
args = args.args
print("got args: " .. dump(args))
