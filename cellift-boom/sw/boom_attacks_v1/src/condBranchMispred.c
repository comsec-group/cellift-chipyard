#include <stdio.h>
#include <stdint.h>
#include "encoding.h"
#include "cache.h"

#define ARRAY1_SZ 7
#define DELAY_BEFORE_SPECTRE

extern uint64_t *array_start;

int main(void){
    uint8_t divfactor = 2;

    // Point to something dereferencable
    for (int idx = 0; idx < ARRAY1_SZ; idx++) {
        *(uint64_t*)(&array_start + idx) = 0x80000000ULL;
    }

    // Victim function.
    for (int idx = 0; idx < ARRAY1_SZ+1; idx++) {

        // stall array1_sz by doing div operations (operation is (array1_sz << 4) / (2*4))

#ifdef DELAY_BEFORE_SPECTRE
        uint64_t array1_sz;
        if (idx >= ARRAY1_SZ) {
            array1_sz =  ARRAY1_SZ << 4;
            asm volatile(
                "fcvt.s.lu	fa4, %[in]\n"
                "fcvt.s.lu	fa5, %[inout]\n"
                "fdiv.s	fa5, fa5, fa4\n"
                "fdiv.s	fa5, fa5, fa4\n"
                "fdiv.s	fa5, fa5, fa4\n"
                "fdiv.s	fa5, fa5, fa4\n"
                "fcvt.lu.s	%[out], fa5, rtz\n"
                : [out] "=r" (array1_sz)
                : [inout] "r" (array1_sz), [in] "r" (divfactor)
                : "fa4", "fa5");
        } else {
            array1_sz = ARRAY1_SZ;
        }
#else // DELAY_BEFORE_SPECTRE
        uint64_t array1_sz = ARRAY1_SZ;
#endif

        if (idx < array1_sz){
            asm volatile(
            "addi	t2,x0,3\n"
            "addi   t0,x0,8\n"
            "slli	t2,t2,12\n"
            "slli   t0,t0,28\n"
            "add    t2,t2,t0\n\n" // Now contains array_base
            "add t0, %[curr_idx], t2 \n"
            "ld	t1, 0(t0)\n"
            "ld	t2, 0(t1)\n"
            :: [curr_idx] "r" (idx * 8)
            : "t0", "t1", "t2");
        }
    }

    for (;;);

    return 0;
}
