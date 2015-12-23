-- Idea: look at the structure of the official luac compiler and construct a pattern grammar based on that

local utils = require 'common.utils'
local undump = require 'bytecode.undump'

local decompiler = {}

local ast = {}

function ast:set(key, val)
  if not key or not val then return self end
  self[key] = val
  return self
end

function ast:list(...)
  for child in utils.loop({...}) do
    table.insert(self, child)
  end
  return self
end

function ast:children()
  return utils.loop(self)
end

local function escape(id)
  return table.concat(
    utils.map(
      function(char)
        if char == ("'"):byte() then
          return "\\'"
        else
          return string.char(char)
        end
      end,
      {id:byte(1, #id)}))
end

function ast:tostring()
  utils.dump(self, escape)
end

local function node(kind)
  return setmetatable({kind = kind}, {__index = ast, __tostring = ast.tostring})
end

local function from(kind, value)
  if not kind then
    kind = 'leaf'
  end
  local leaf = node(kind)
  leaf.value = value
  return leaf
end

--------------------------------------------
---          Puzzle Pieces               ---
--------------------------------------------

local puzzles = {}

-- OP_RETURN,/*  A B    return R(A), ... ,R(A+B-2)  (see note)  */
function puzzles.RETURN(ctx, instruction)

end


local context = {}

local closure = undump.undump(function(a) return a end)
context.closure = closure
for instruction in utils.loop(closure.code) do
  print(instruction)
end

return decompiler