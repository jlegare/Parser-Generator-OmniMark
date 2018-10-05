MESSAGES
========

GRAMMAR
=======

Arbitrary blanks (i.e., space or tab characters) are allowed between tokens.

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


SEMANTIC CONSTRAINTS
====================

