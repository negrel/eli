files := $(wildcard *.lisp)
names := $(files:.lisp=)

.PHONY: all clean $(names)

all: $(names)

$(names): %: bin/%

bin/%: %.lisp build-bin.sh Makefile
	mkdir -p bin
	./build-bin.sh $<
	mv $(@F) bin/

clean:
	rm -rf bin
