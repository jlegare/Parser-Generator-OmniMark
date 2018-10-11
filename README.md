# Parser Generator (OmniMark)

This is a parser generator written in [OmniMark](http://developers.stilo.com/docs/html/index.htm).
It can generate parse tables for SLR, LR(0), and LR(1) parsers, and supports left-recursive productions.
The input format is a variant of [EBNF](https://en.wikipedia.org/wiki/Extended_Backus–Naur_form); examples can be found in the `tests/` folder. 

Before making use of the parser generator, error message modules must be built. This is handled by the default target in the provided `Makefile`. 

## Analyzing Grammars

The front-end for grammar analysis is `command-line/wrapper.xom`. A typical invocation might be
```shell
omnimark -s command-line/wrapper.xom -a handle-parsing input.ebnf 2> input.log
```
This will parse the grammar `input.ebnf`, and output to `stdout` 

* a list of parse trees, one for each production,
* a list of simplified parse trees, one for each production,
* a list of flattened parse trees, one for each production, and
* the analyzed grammar, including a breakdown of terminals, non-terminals, and [first and follow sets](https://en.wikipedia.org/wiki/Canonical_LR_parser#FIRST_and_FOLLOW_sets). 

Error messages and progress information are written to `stderr`.

An [SLR](https://en.wikipedia.org/wiki/Simple_LR_parser) parse table can be added to the output by putting `-a handle-slr` on the command-line. 
Similarly, a [canonical LR(0)](https://en.wikipedia.org/wiki/Canonical_LR_parser) parse table can be had using `-a handle-lr-0`, 
and a [canonical LR(1)](https://en.wikipedia.org/wiki/Canonical_LR_parser) parse table can be had using `-a handle-lr-1`. If none of these options are provided on the command-line and `-a handle-parsing` is left off as well, the input grammar is tokenized and the token stream is written to `stdout`.

## Syntax for Grammars

The syntax for grammars is a variant of EBNF.
```
<grammar>             ::= <production>+

<production>          ::= <identifier> "::=" <expression> ";"

<expression>          ::= <term> ("|" <term>)*

<term>                ::= <factor> <factor>*

<factor>              ::=   <identifier> <occurrence-modifier>?
                          | <quoted-string> <occurrence-modifier>?
                          | "(" <expression> ")" <occurrence-modifier>?

<occurrence-modifier> ::= "*" | "+" | "?"
```
An identifier starts with an underscore (`_`) or an ASCII letter, and can be followed by zero or more characters from

- underscore (`_`),
- hyphen (`-`),
- [ASCII](https://en.wikipedia.org/wiki/ASCII) letters or digits, or
- [UTF-8](https://en.wikipedia.org/wiki/UTF-8) multibyte characters.

There is also support for *delimited identifiers*: these are delimited by angle brackets (`<` and `>`), and contain anything other than traditional newline characters (ASCII 10, ASCII 13) and the form feed character (ASCII 12). This effectively allows identifiers that contain spaces. 

A special identifier is defined, `EPSILON`, which is used to add ε to a production. `EPSILON` cannot appear on the left-hand side of a production.

Grammar terminals are represented by quoted strings. Quoted strings are delimited by single (`'`) or double quotes (`"`), and contain anything other than newline characters (ASCII 10, ASCII 13) and the form feed character (ASCII 12).

The start symbol for a grammar is the left-hand side of the first production encountered when parsing the grammar.

Grammars can contain C-style comments; these are discarded by the lexical layer that loads the grammar. 

## Messages

Error (and warning, and informational, ...) messages emitted by the analysis tool are generated from `.txt` files which are typically *beside* the module that uses then (*e.g.*, `ebnf/ebnf.xmd` uses messages generated from `ebnf/ebnf.txt`). The generator is `messages/generate.xom`. The grammar for messages files is
```
<messages file> ::= (<directive> | <specification>)+ ;

<directive>     ::=   "MODULE" "ID" ":" <module id> <line-end>
                    | "MODULE" "NAME" ":" <module name> <line-end>
                    | "INCLUDE" <file name> <line-end> ;

<specification> ::=   <number> ":" <severity> ":"? <line-end>
                      "-" <identifier> <line-end>
                      ("-" <line> <line-end>)+
                    | "FRAGMENT" <line-end>
                      "-" <identifier> <line-end>
                      ("-" <line> <line-end>)+ ;

<module id>     ::= <number> ;
<module name>   ::= <text> ;

<file name>     ::= <text> ;

<severity>      ::= "ERROR" | "FATAL" | "INFORMATION" | "INTERNAL" | "WARNING" ;

<line>          ::= "-" (<text> | "[" <text> "]" | "[*" <text> "]")+

<identifier>    ::= (letter [letter | digit | "-_"]*)
<number>        ::= digit+
<text>          ::= any-text+
```
Here [`letter`](http://developers.stilo.com/docs/html/keyword/193.htm), [`digit`](http://developers.stilo.com/docs/html/keyword/102.htm), and [`any-text`](http://developers.stilo.com/docs/html/keyword/46.htm) are [OmniMark](http://developers.stilo.com/docs/html/index.htm) character classes representing ASCII letters, digits, and in essence anything except a newline. 

The `MODULE NAME` directive specifies the share name for the generated module (*i.e.*, a unique string that identifies the module). The `MODULE ID` directive groups a sequence of message specifications into a module; presumably these messages are related. For example, `command-line/messages.txt` contains messages related to command-line handling: 
```
; ------------------------------------------------------------------------
; Error messages for the command-line interface.

MODULE NAME: command-line/messages.xmd
MODULE ID:   900
```
We see that the output file name for the generated code is specified as `command-line/messages.xmd` and the module ID is specified as `900`.

Messages can be parameterized, as for example from `grammar/messages.txt`:
```
102:ERROR:
- cyclic-production
- Cyclic production detected.
- The non-terminal [lhs] is cyclic.
```
Here, `lhs` is a (string) parameter that must be supplied at run-time when emitting the message, as in `grammar/grammar.xmd` line 1664:
```
log.emit (cyclic-production (dump (production:lhs), location-info-of (production:lhs)))
```

If there is a colon (`:`) following the severity in a message specification, the generated code takes an additional argument that provides a location in the emitted message. The type is declared in `common/utilities.xmd`, and a constructor (`location-info ()`) is also provided in that module.