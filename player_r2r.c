// player_r2r.c
//
// gcc -std=gnu11 -Wall -Wextra -pedantic -O4 player_r2r.c -o player_r2r
// sudo ./player_r2r

#define __USE_FILE_OFFSET64
#include <stdio.h>
#include <limits.h>
#include <stdint.h>
#include <assert.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <time.h>

#define CHUNK	2048

struct timespec interv = { 0,  5000000 };	// 5 ms

volatile uint32_t * mmap_dev_mem(off_t offset, size_t length) {
    int fd = open("/dev/mem", O_RDWR);
        if (fd == -1) {
        perror("open");
        return NULL;
    }
    volatile uint32_t * ptr = (volatile uint32_t*)mmap(NULL, length, PROT_READ | PROT_WRITE, MAP_SHARED, fd, offset);
        close(fd);
       if (ptr == MAP_FAILED) {
               perror("mmap");
               return NULL;
       }

    return ptr;
}

void munmap_dev_mem(volatile uint32_t * ptr, size_t length) {
    if (-1 == munmap((void*)ptr, length)) {
        perror("munmap");
    }
}



int main() {

        volatile uint32_t * axilite = mmap_dev_mem(0x40000000, 64*1024);
		uint8_t buf[0x1000];
		FILE *wfp;
		int rdbytes;
		uint32_t write_idx, play_idx;
		uint32_t remain;
		
		// Open wav-file
		wfp = fopen("TuffEnuff.wav","rb");
		if (wfp == NULL)
		{
			perror("fopen");
			exit(1);
		}
		
		// Bypass header
		rdbytes = fread(buf,1,44,wfp);
		
		// Write index base = current value from PL
		write_idx = axilite[0];
		
		while (1)
		{
			// Read chunk from wav-file
			rdbytes = fread(buf,1,CHUNK,wfp);
			if (rdbytes != CHUNK)
				break;
			
			// Write chunk to PL sample buffer
			for (int i = 0; i < CHUNK; i++)
			{
				write_idx = (write_idx + 1) & 0xFFF;
				axilite[write_idx] = buf[i];
			}
			
			// Wait until sample buffer level low enough
			do {
				nanosleep(&interv,NULL);
				
				play_idx = axilite[0];
				remain = (write_idx - play_idx) & 0xFFF;
			} 
			while (remain > CHUNK/2);
        }
		
		fclose(wfp);

        return 0;
}
