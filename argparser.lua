function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
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
end

res = parse_args("", "some random args")
