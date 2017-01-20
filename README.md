## Compiler for small C

File Name | Description
------------ | -------------
smallc.l | Lexcical analyzer with flex
smallc.y | Syntax analyzer with bison
ast.h/ast.c| Abstract syntax tree definition
semantic.h| Semantic error check
generateIR.h| Generate intermediate representation
optimize.h| Optimize intermediate reperesentation
generateMIPS.h | Generate MIPS code
lzb.s | MIPS Code for write/read
Makefile| makefile
testcase | a few test
