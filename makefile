CC=g++
ASMBIN=nasm

all : asm cc link
asm :
	$(ASMBIN) -o markers.o -f elf64 -g -l markers.lst markers.asm
cc :
	$(CC)  -c -g -O0 main.cpp &> errors.txt
link :
	$(CC)  -g -o test main.o markers.o
clean :
	rm *.o
	rm test
	rm errors.txt
	rm markers.lst
