#include <stdio.h>
#include <stdint.h>
#include "encoding.h"
#include "cache.h"

#define ARRAY1_SZ 7

extern int array_start;

int main(void){
    uint8_t divfactor = 2;

    // Victim function.
    for (int idx = 0; idx < ARRAY1_SZ+1; idx++) {

        // stall array1_sz by doing div operations (operation is (array1_sz << 4) / (2*4))

        uint64_t array1_sz;
        if (idx >= ARRAY1_SZ) {
            array1_sz = ARRAY1_SZ;
        } else {
            array1_sz = ARRAY1_SZ;
        }

        if (idx < array1_sz){
            asm volatile(
            "addi	t2,x0,3\n"
            "addi   t0,x0,8\n"
            "slli	t2,t2,12\n"
            "slli   t0,t0,28\n"
            "add    t2,t2,t0\n\n" // Now contains array_base
            "add t0, %[curr_idx], t2 \n"
            "ld	t1, 0(t0)\n"
            :: [curr_idx] "r" (idx * 8)
            : "t0", "t1", "t2");
        }
    }

    for (;;);

    return 0;
}
