CC=gcc
# CFLAGS=-Wall -rdynamic -g

all:	main.o f.o
	$(CC) -Wall -rdynamic -g -lm main.o f.o -o fun `pkg-config --cflags-only-other --libs gtk+-3.0`

main.o:	main.c
	$(CC) -Wall -rdynamic -g `pkg-config --cflags-only-I --libs gtk+-3.0` -c main.c -o main.o


f.o:	f.s
	nasm -f elf64 f.s


clean:
	rm -f *.o
