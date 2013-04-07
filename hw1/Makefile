sub:		lex.yy.o 
						gcc -o sub lex.yy.c -lfl

lex.yy.c:		sub.l
						flex sub.l
clean:
						rm ./*.o
						rm lex.yy.c
						rm sub 
