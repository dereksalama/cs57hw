lexdriver:		lex.yy.o lexdriver.o
						gcc -std=c99 -o lexdriver lex.yy.o lexdriver.o -lfl

lex.yy.o:		lex.yy.c tokens.h
						gcc -std=c99 -c lex.yy.c

lex.yy.c:		lexer.l
						flex lexer.l

lexdriver.o:	lexdriver.c tokens.h
						gcc -std=c99 -c lexdriver.c
clean:
						rm ./*.o
						rm lex.yy.c
						rm lexdriver
