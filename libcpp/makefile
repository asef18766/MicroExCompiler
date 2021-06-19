SRC := $(shell ls *.cpp|sed -e "s/.cpp/.o/g")
all: $(SRC)
	g++ -shared $(SRC) -o libcpp.so
%.o:%.cpp
	g++ -g -fPIC -c $^ -o $@
clean:
	rm -f *.o libcpp.so
