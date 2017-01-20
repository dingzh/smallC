//This file gives implemenation of relevent functions to constructing the abstract syntax tree.
#ifndef FILE_AST_H
#define FILE_AST_H

#include <cstdio>
#include <cstdlib>
#include <cassert>
#include <cstdarg>
#include <vector>
#include <map>
#include <cstring>


typedef enum {
    _PROGRAM,
    _EXTDEFS,
    _EXTDEF,
    _SEXTVARS,
    _EXTVARS,
    _STSPEC,
    _FUNC,
    _PARAS,
    _STMTBLOCK,
    _STMTS,
    _STMT,
    _DEFS,
    _SDEFS,
    _SDECS,
    _DECS,
    _VAR,
    _INIT,
    _EXP,
    _EXPS,
    _ARRS,
    _ARGS,
    _UNARYOP,
    _ID,
    _OPERATOR,
    _KEYWORDS,
    _TYPE,
    _INT,
    _NULL
} TreeNodeType;

typedef struct TreeNode {
    TreeNodeType type; //type of the treenodes
    int line_num;
    char* data;
    int size, capacity;
    struct TreeNode** children;
    //struct InfoNode* info;
} TreeNode;


extern TreeNode* treeroot;
TreeNode* create_node(int, TreeNodeType, char const*, int, ...);
TreeNode* merge_node(TreeNode*, TreeNode*);
void double_space(TreeNode*);
void print_ast(TreeNode*, int);



#endif

