#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include "./ast/ast.h"
#include "semantic_analysis.h"


vector<vector<char*>*> symbolTables;
int errorsDetected = 0;


int semanticAnalyzer(astNode* root){
  semanticAnalysis(root, 0);

  if(errorsDetected > 0){
    printf("*** ERROR: Found Semantic Errors ***\n");

    return 1;
  } else {
    return 0;
  }
}

void semanticAnalysis(astNode* root, int n) {
  if (root == NULL) {
    return;
  }

  switch(root->type) {

    case ast_prog: {
      semanticAnalysis(root -> prog.func, n+1);
      break;
    }

    case ast_func: {
      vector<char*> symbolTable;
      symbolTables.push_back(&symbolTable);

      if(root->func.param != NULL){
        symbolTables.back()->push_back(root->func.param->var.name);
        fflush(stdout);
      }

      semanticAnalysis(root->func.body, n+1);
      symbolTables.pop_back();
      fflush(stdout);
      break;
    }

    case ast_stmt: {
      traverseStatement(&root->stmt, n+1);
      break;
    }

    case ast_extern: {
      break;
    }

    case ast_var: {
      fflush(stdout);

      bool declared = false;

      for (int i = 0; i < (int)symbolTables.size(); i++){
        for (int j = 0; j < (int)symbolTables[i]->size(); j++){
          if (strcmp(symbolTables[i]->at(j), root->var.name) == 0){
            declared = true;
          }
        }
      }

      if (declared == true){
        fflush(stdout);
      } else {
        errorsDetected++;
      }

      break;
    }

    case ast_cnst: {
      break;
    }
		
    case ast_rexpr: {
      semanticAnalysis(root->rexpr.lhs, n+1);
      semanticAnalysis(root->rexpr.rhs, n+1);
      break;
    }
    
    case ast_bexpr: {
      semanticAnalysis(root->bexpr.lhs, n+1);
      semanticAnalysis(root->bexpr.rhs, n+1);
      break;
    }

    case ast_uexpr: {
      semanticAnalysis(root->uexpr.expr, n+1);
    }

    default: {
      fprintf(stderr,"Error: invalid Node type\n");
      break;
    }
  }
}

void traverseStatement(astStmt* stmt, int n) {
  if (stmt == NULL) {
    return ;
  }

  switch(stmt->type) {

    case ast_call: {
      if (stmt->call.param != NULL){
        semanticAnalysis(stmt->call.param, n+1);
      }
      break;
    }
    case ast_ret: {
      if (stmt->ret.expr != NULL){
        semanticAnalysis(stmt->ret.expr, n+1);
      }
      break;
    }
		
    case ast_block: {
      fflush(stdout);
      vector<char*> symbolTable;
      symbolTables.push_back(&symbolTable);

      for (int i=0; i < (int)stmt->block.stmt_list->size(); i++){
        semanticAnalysis(stmt->block.stmt_list->at(i), n+1);
      }
      symbolTables.pop_back();
      fflush(stdout);
      break;
    }

    case ast_while: {
      semanticAnalysis(stmt->whilen.cond, n+1);
      semanticAnalysis(stmt->whilen.body, n+1);
      break;
    }

    case ast_if: {
      semanticAnalysis(stmt->ifn.cond, n+1);
      semanticAnalysis(stmt->ifn.if_body, n+1);
      if(stmt->ifn.else_body != NULL) {
        semanticAnalysis(stmt->ifn.else_body, n+1);
      }
      break;
    } 

    case ast_asgn: {
      semanticAnalysis(stmt->asgn.lhs, n+1);
      semanticAnalysis(stmt->asgn.rhs, n+1);
      break;
    }

    case ast_decl: {
      symbolTables.back()->push_back(stmt->decl.name);
      fflush(stdout);
      break;
    }

    default: {
      fprintf(stderr, "Error: Invalid Node type");
      break;
    }
  }
}

