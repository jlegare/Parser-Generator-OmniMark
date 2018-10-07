# Parser Generator (OmniMark)

This is a parser generator written in [OmniMark](http://developers.stilo.com/docs/html/index.htm).
It can generate parse tables for SLR, LR(0), and LR(1) parsers, and supports left-recursive productions.
The input format is [EBNF](https://en.wikipedia.org/wiki/Extended_Backus–Naur_form); examples can be found in the `tests/` folder. 

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
