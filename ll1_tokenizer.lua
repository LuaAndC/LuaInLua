-- Frontend lexer for the parser

local lex = require 'lex'
local re = require 're'

local code_stack = {}
local string_stack = {}
local function id(token) return function(...) return {token, ...} end end
local function ignore(...) return end
local function pop(stack) return table.remove(stack) end
local function push(item, stack) table.insert(stack, item) end

return lex.lex {
  root = {
    {'%convert', id 'CONVERT'},
    {'%prologue', id 'PROLOGUE'},
    {'%production', id 'PRODUCTION'},
    {':=', id 'GETS'},
    {'|', id 'OR'},
    {re '$(%a|_)(%a|%d|_|\')*', id 'VARIABLE'},
    {re '(%a|_)(%a|%d|_|\')*', id 'IDENTIFIER'},
    
    {'{:', function(piece, lexer) lexer:go 'code'; push('', code_stack) end},
    {'"', function(piece, lexer) lexer:go 'string'; push('', string_stack) end},
    
    {re '%s+', ignore},
    {re '/%*', function(piece, lexer) lexer:go 'comment' end},
    {re '//[^\n]+', ignore},
    
  },
  code = {
    {':}', function(piece, lexer) 
      lexer:go 'root'
      return {'CODE', pop(code_stack)}
    end},
    {re '.', function(piece, lexer) 
      push(pop(code_stack) .. piece, code_stack)
    end}
  },
  string = {
    {'"', function(piece, lexer) 
      lexer:go 'root'
      return {'STRING', pop(string_stack)}
    end},
    {re '.', function(piece, lexer) 
      push(pop(string_stack) .. piece, string_stack)
    end}
  },
  comment = {
    {re '%*/', function(piece, lexer) lexer:go 'root' end},
    {re '.', ignore},
  }
}