/* Versioned Dyn float contract shared by runtime readers. Low kind stays 5;
 * the 16-byte casilla ABI is unchanged. Do not reuse reserved bits. */
#ifndef HR_DYN_H
#define HR_DYN_H
#define HR_DYN_FLOAT_KIND 5ULL
#define HR_DYN_FLOAT_HEAP 0x8000000000000000ULL
#define HR_DYN_BRIDGE_HEAP_CAP 0x0000000100000000ULL
#define HR_DYN_ARGC_MAX 0x000000007fffffffULL
#endif
