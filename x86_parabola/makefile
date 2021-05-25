CC=gcc
CFLAGS=-m32 -Wall

all:	main.o f.o
	$(CC) $(CFLAGS) main.o f.o -o fun

main.o:	main.c
	$(CC) $(CFLAGS) -O0 -fpack-struct -c main.c -o main.o

f.o:	f.s
	nasm -f elf f.s


clean:
	rm -f *.o

