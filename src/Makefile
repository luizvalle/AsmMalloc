.PHONY: all
all: clean mm

mm: mm.o
	ld $^ -o $@

mm.o: mm.s
	as $^ -o $@ 

.PHONY: clean
clean:
	rm -rf *.o mm
