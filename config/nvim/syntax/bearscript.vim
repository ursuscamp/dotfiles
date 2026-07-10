" Vim syntax file
" Language: BearScript
" Maintainer: BearScript contributors
" Latest Revision: 2026-07-09

if exists('b:current_syntax')
  finish
endif

scriptencoding utf-8

" BearScript identifiers are made from alphabetic characters, digits, and
" underscores. Keep this local to syntax matching rather than changing the
" buffer's 'iskeyword' option.
syntax iskeyword @,48-57,_,192-255
syntax case match

" Comments and literals.
syntax match bearScriptComment '#.*$'
syntax match bearScriptNumber '\<\d\+\%(\.\d\+\)\?\>'
syntax keyword bearScriptBoolean true false
syntax keyword bearScriptNull null

" Strings may contain escaped characters and nested interpolation
" expressions. The interpolation region is recursive so map/block literals
" and nested interpolations remain highlighted correctly.
syntax match bearScriptEscape '\\["\\{}ntr0]' contained
syntax region bearScriptString start=+"+ skip=+\\.+ end=+"+ contains=bearScriptInterpolation,bearScriptEscape
syntax region bearScriptInterpolation matchgroup=bearScriptInterpolationDelimiter start='{' end='}' contained contains=@bearScriptExpression,bearScriptInterpolation

" Keywords and operators.
syntax keyword bearScriptKeyword let if else while for in fn return break continue import export as gen yield
syntax keyword bearScriptOperator and or not
syntax match bearScriptOperator '[+\-*/%<>=!]\|\.\.'

" Delimiters are kept separate from operators so colorschemes can distinguish
" structural punctuation from expressions.
syntax match bearScriptDelimiter '[(){}\[\],;:.]'

" Highlight function names in declarations and calls. Matching the identifier
" immediately before '(' is portable across Vim and Neovim syntax engines.
syntax match bearScriptFunction '\<\h\w*\ze\s*('

" Expressions inside string interpolation can use the same token groups as
" normal source. The interpolation group itself is added explicitly above to
" allow recursive braces.
syntax cluster bearScriptExpression contains=bearScriptComment,bearScriptNumber,bearScriptBoolean,bearScriptNull,bearScriptString,bearScriptKeyword,bearScriptOperator,bearScriptDelimiter,bearScriptFunction

" Use standard highlight groups so the syntax follows the user's colorscheme.
highlight default link bearScriptComment Comment
highlight default link bearScriptNumber Number
highlight default link bearScriptBoolean Boolean
highlight default link bearScriptNull Constant
highlight default link bearScriptString String
highlight default link bearScriptEscape SpecialChar
highlight default link bearScriptInterpolationDelimiter Delimiter
highlight default link bearScriptKeyword Keyword
highlight default link bearScriptOperator Operator
highlight default link bearScriptDelimiter Delimiter
highlight default link bearScriptFunction Function

let b:current_syntax = 'bearscript'
