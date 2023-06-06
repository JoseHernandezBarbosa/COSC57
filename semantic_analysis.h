#ifndef SEMANTIC_ANALYSIS_H
#define SEMANTIC_ANALYSIS_H

#include <vector>
#include <stack>
#include <string.h>
#include <cstddef>
#include "./ast/ast.h"

using namespace std;

extern int errorsDetected;

int semanticAnalyzer(astNode* root);

void semanticAnalysis(astNode* root, int n);

void traverseStatement(astStmt* statement, int n);


#endif 