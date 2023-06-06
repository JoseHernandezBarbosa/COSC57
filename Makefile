filename = lex_analyzer

$(filename).out: $(filename).l $(filename).y ./ast/ast.h ./ast/ast.c semantic_analysis.c semantic_analysis.h
	yacc -d -v -t $(filename).y
	lex $(filename).l
	g++ -g -o $(filename).out lex.yy.c y.tab.c ./ast/ast.c semantic_analysis.c
clean:
	rm $(filename).out lex.yy.c y.tab.c y.tab.h y.output
valgrind:
	valgrind --leak-check=full --show-leak-kinds=all ./$(filename).out < mini.c
