.PHONY: all
all: clean test

test: mm.o test.o
	gcc $^ -o $@

test.o: test.c
	gcc $^ -c -o $@

mm.o: mm.s
	as $^ -o $@ 

.PHONY: clean
clean:
	rm -rf *.o test
