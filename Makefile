CC = gcc
CFLAGS = -O0

pivot_O0: src/pivot.c
	$(CC) $(CFLAGS) -o $@ $< -lm
