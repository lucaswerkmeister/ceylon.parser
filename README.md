ceylon.parser
============

A parser for the Ceylon programming language, written in Ceylon.

This repository contains the following modules:

- `ceylon.lexer` – a lexer (tokenizer) for Ceylon
- `ceylon.parser` – a parser for Ceylon, producing a [`ceylon.ast`](https://github.com/ceylon/ceylon.ast) AST
- a `test.X` module for each of those

These are all hand-written – this is not a parser generator, and doesn’t use one either.
They will also be pure Ceylon as much as possible – file I/O will be put into a different module, so that you can have the parser itself in JS as well (taking its characters from a `String`, for example).

**DO NOT USE THIS.** As it is not an official Ceylon project, I will have to rename it before I can even think of any release – I just haven’t found a better name for it yet :D

(If you want a Ceylon parser written in Ceylon, check out [this project](https://github.com/sadmac7000/ceylon-parse/tree/master/source/ceylon/parse/ceylon) too.)

Project state
-------------

Development on this project has ceased.

**The lexer** is done, and used in [ColorTrompon](https://github.com/lucaswerkmeister/ColorTrompon), a syntax highlighter.

**The parser**… well, let’s just say that I now understand why parser generators are among the oldest tools in programming language history. I started writing it (I got as far as base types – with type arguments and variance  – and optional types) and very soon realized how boring a task a hand-written parser would be, so I abandoned it. See above for a better approach.
