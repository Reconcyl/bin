// Randomly print one of the arguments passed.

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>

int main(int argc, char **argv) {
    if (argc < 2) {
        puts("expected arguments");
        return 1;
    }
    if (argc == 2) {
        puts(argv[1]);
        return 0;
    }

    FILE *urand = fopen("/dev/urandom", "rb");
    uint8_t bytes[4];
    uint32_t seed;

    if (fread(bytes, 1, 4, urand) != 4) {
        seed = time(0);
    } else {
        seed = bytes[0]
             | bytes[1] << 8
             | bytes[2] << 16
             | bytes[3] << 24;
    }

    srand(seed);

    int n = argc - 1;
    int max = RAND_MAX - RAND_MAX % n;

    int i;
    while ((i = rand()) > max);

    int idx = (i / (max / n));
    puts(argv[idx + 1]);

    return 0;
}
