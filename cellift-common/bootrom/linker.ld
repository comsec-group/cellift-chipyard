SECTIONS
{
    ROM_BASE = 0x10000; /* ... but actually position independent */

    . = ROM_BASE;
    .data_padding : { *(.data_padding)}
    .text.start : { *(.text.start) }
/*    . = ROM_BASE + 0x40;           */
/*    .text.hang : { *(.text.hang) } */
}
