all:
	cd libcpp && make && cd ..
	yacc -d ch3-01.y
	flex ch3-01.l
	gcc lex.yy.c y.tab.c -o parser -ly -lfl -lcpp -L./libcpp -Wl,-rpath,`pwd`/libcpp
setup:
	sudo apt install flex bison libbison-dev
clean:
	cd libcpp && make clean && cd ..
	rm -f y.tab.* lex.yy.c parser
test: clean all
	cat test_data/3.mco | ./parser
