
scc:smallc.tab.c smallc.lex.c ast.h interpret.h optimize.h semantics.h translate.h
	g++ -g -o scc smallc.lex.c smallc.tab.c
smallc.lex.c:smallc.tab.h smallc.l
	flex -o smallc.lex.c smallc.l
smallc.tab.h smallc.tab.c:smallc.y
	bison -d smallc.y

.PHONY: clean
clean:
	rm smallc.tab.h smallc.tab.c smallc.lex.c
	rm scc
test:scc
	for f in testcase/*; do\
	  ./scc $$f; \
	done
