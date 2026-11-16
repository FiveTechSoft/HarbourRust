/* Field write encoders for the owned mutable DBF snapshot.
 * Ported from OpenADS (MIT License), Copyright (c) 2026 OpenADS
 * contributors, src/drivers/dbf_common.cpp (encode_field_string /
 * encode_field_double / encode_field_logical / encode_field_null and
 * set_record_deleted). HarbourRust adaptations: freestanding C99 with no
 * libc, and numeric formatting through an own correctly-rounded fixed
 * formatter instead of snprintf. Harbour remains the behavioral oracle. */
#ifndef HRDBF_WRITE_H
#define HRDBF_WRITE_H
#include "hrdbf.h"

/* All encoders write exactly f->width bytes at rec + f->offset (rec points
 * at the record start, delete flag included). They validate the field type
 * and return HRDBF_TYPE on a type mismatch, HRDBF_DATA on an unencodable
 * value, HRDBF_LIMIT when the exact decimal coefficient cannot be rescaled
 * without overflow. Numeric overflow of the field width renders '*' bytes,
 * the xBase overflow convention (as hrv_render already does). */

/* C <- text: verbatim copy truncated to width, space-padded. */
hrdbf_error hrdbf_write_char(unsigned char *rec, const hrdbf_field *f,
                             const unsigned char *text, size_t len);

/* N <- exact decimal coefficient: value = scaled / 10^decimals, rescaled to
 * the field decimals rounding half away from zero. Mirrors Harbour storing
 * a numeric item into a numeric field. */
hrdbf_error hrdbf_write_number_scaled(unsigned char *rec, const hrdbf_field *f,
                                      int64_t scaled, unsigned decimals);

/* N <- double (arithmetic results): Harbour semantics - the double's
 * 16-significant-digit decimal string rounded half away from zero at the
 * field decimals (oracle: 2.685->2.69, 15.5555->15.56, 0.045->0.05,
 * -0.001 dec2 -> 0.00 without sign). NOT glibc "%.*f". */
hrdbf_error hrdbf_write_number_double(unsigned char *rec, const hrdbf_field *f,
                                      double value);

/* D <- YYYYMMDD; 0 writes 8 spaces (blank date). Validates month/day. */
hrdbf_error hrdbf_write_date(unsigned char *rec, const hrdbf_field *f,
                             uint32_t yyyymmdd);

/* L <- logical: 'T' or 'F'. */
hrdbf_error hrdbf_write_logical(unsigned char *rec, const hrdbf_field *f,
                                unsigned char value);

/* Blank-fill one field (encode_field_null port): spaces. */
hrdbf_error hrdbf_write_blank(unsigned char *rec, const hrdbf_field *f);

/* Delete flag (set_record_deleted port): rec[0] = '*' or ' '. */
void hrdbf_write_deleted(unsigned char *rec, unsigned char deleted);

/* Harbour N-field formatter, exposed for host differential tests against
 * the official-Harbour probe truth. Writes the bare number (no width
 * padding, minus sign only for negative nonzero results) into out;
 * returns the length, or 0 when the value is not finite or cap is
 * insufficient (never writes then). dec <= 32. */
unsigned hrdbf_fmt_harbour(unsigned char *out, unsigned cap, double value,
                           unsigned dec);
/* Reference exact-binary fixed formatter ("C %.*f", round-half-even),
 * kept for host differential tests. */
unsigned hrdbf_fmt_fixed(unsigned char *out, unsigned cap, double value,
                         unsigned dec);

#endif
