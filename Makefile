ifeq ($(OS), Windows_NT)
	include config_windows.mk
else
	UNAME_S = $(shell uname -s)
	ifeq ($(UNAME_S), Linux)
		include config_linux.mk
	endif
	ifeq ($(UNAME_S), Darwin)
		include config_osx.mk
	endif
endif

SRC  = hello.c
OBJ  = $(SRC:.c=.o)
TEST = test_hello

all: options mylib.so test 

help:
	@echo Possible targets:
	@echo   "all      - build mylib.so and run tests"
	@echo   "mylib.so - build mylib.so"
	@echo   "options  - print build options"
	@echo   "clean    - clean build files"
	@echo   "test     - run tests"
	@echo   "cov      - generate gcov test coverage reports"

options:
	@echo build options:
	@echo "CFLAGS  = $(CFLAGS)"
	@echo "CC      = $(CC)"

clean:
	@echo cleaning
	@rm -f mylib.so
	@rm -f $(TEST)
	@rm -f *.d *.gcda *.gcno *.gcov *.o
	@rm -f lint_cmac.h gcc-include-path.lnt size-options.lnt

%.o: %.c
	@echo CC $<
	@$(CC) $(CFLAGS) -c $<

unity.o: unity.c
	@echo CC $<
	@$(CC) $(CFLAGS) -w -c $<

mylib.so: $(OBJ)
	@echo LINK $@
	@$(CC) $(CFLAGS) -shared $(OBJ) -o $@

test: $(TEST)

test_hello: unity.o hello.o test_hello.o
	@echo LINK $@
	@$(CC) $(CFLAGS) $^ -o $@
	@$(VALGRIND) ./$@

cov: test
	gcov $(SRC)

# The following targets require Gimpel Software's FlexeLint
lint: *.c *.h lint_cmac.h gcc-include-path.lnt size-options.lnt
	@lint co-gcc.lnt std.lnt *.c

lint_cmac.h: config_linux.mk config_osx.mk
	@make -s -f co-gcc.mak lint_cmac.h

gcc-include-path.lnt: config_linux.mk config_osx.mk
	@make -s -f co-gcc.mak gcc-include-path.lnt

size-options.lnt: config_linux.mk config_osx.mk
	@make -s -f co-gcc.mak size-options.lnt

.PHONY: all options clean test
include $(wildcard *.d)
