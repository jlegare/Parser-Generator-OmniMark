# Parser Generator (OmniMark)

This is a parser generator written in [OmniMark](http://developers.stilo.com/docs/html/index.htm).
It can generate parse tables for SLR, LR(0), and LR(1) parsers, and supports left-recursive productions.
The input format is [EBNF](https://en.wikipedia.org/wiki/Extended_Backus–Naur_form); examples can be found in the `tests/` folder. 

Before making use of the parser generator, error message modules must be built. This is handled by the default target in the provided `Makefile`. 

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

There is also support for *delimited identifiers*: these are delimited by angle brackets (`<` and `>`), and contain anything other than traditional newline characters (ASCII 10, ASCII 13) and the form feed character (ASCII 12).

A special identifier is defined, `EPSILON`, which is used to add ε to a production. `EPSILON` cannot appear on the left-hand side of a production.

Grammar terminals are represented by quoted strings. Quoted strings are delimited by single (`'`) or double quotes (`"`), and contain anything other than newline characters (ASCII 10, ASCII 13) and the form feed character (ASCII 12).

The start symbol for a grammar is the left-hand side of the first production. 

Grammars can contain C-style comments; these are discarded by the lexical layer that loads the grammar. 

## Messages

Error messages are generated from `.txt` files which are typically *beside* the module that uses then (*e.g.*, `ebnf/ebnf.xmd` uses messages generated from `ebnf/ebnf.txt`). The generator is `messages/generate.xom`. The grammar for messages files is
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
