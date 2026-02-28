---@class ConsoleArgParseResult
---@field error string|nil error message or nil if it was successful
---@field args table<string,any>|nil the parses arguments with their name as key and value as value or nil on error

--- Parse console arguments. Similar to how the teeworlds console code does it.
---
--- Example:
---
--- ```lua
--- args = parse_args("i[client id]s[name]?i[code]", "1 steve 255")
--- if args.error then
---    print("arg error: " .. args.error)
---    os.exit(1)
--- end
--- args = args.args
--- print("got name=" .. args.name .. " and client_id=" .. args["client id"])
--- ```
---
---@param params string expected teeworlds rcon arguments string. Example: "s[name]i[id]"
---@param args string arguments we got from the user
---@return ConsoleArgParseResult
function parse_args(params, args)

   ---@class ParsedParam
   ---@field name string the name of the param
   ---@field type string the type of the param, possible values "i", "r", "s"
   ---@field optional boolean

   ---@type ParsedParam[]
   pparams = {}

   ---@type string|false
   local current_name = false

   ---@type string|false
   local current_type = false

   ---@type boolean
   local current_optional = false

   -- TODO: error if optional is followed by non optional

   for i = 1, #params do
      local c = params:sub(i,i)
      local last = params:sub(i+1,i+1) == ""
      if current_name then
         if c == "]" then
            table.insert(pparams, {
               name = current_name,
               type = current_type,
               optional = current_optional
            })
            current_name = false
            current_type = false
            current_optional = false
         else
            current_name = current_name .. c
         end
      elseif c == "[" then
         current_name = ""
      elseif c == "?" then
         current_optional = true
      elseif (c == "i") or (c == "s") then
         if current_type then
            table.insert(pparams, {
               name = current_name,
               type = current_type,
               optional = current_optional
            })
            current_name = false
            current_type = false
            current_optional = false
         end
         -- only flush prev type and queue next
         -- unless its end of string then we flush both
         current_type = c
         if last then
            table.insert(pparams, {
               name = current_name,
               type = current_type,
               optional = current_optional
            })
            current_name = false
            current_type = false
            current_optional = false
         end
      else
         return {
            error = "unsupported parameter type '" .. c .. "'",
            args = nil
         }
      end
   end

   if current_optional or current_name or current_type then
      return {
         error = "unexpected end of parameters",
         args = nil
      }
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
      if words[i] == nil then
         if param.optional then
            break
         end
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
   end

   return result
end
