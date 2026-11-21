/* Own MIT. TRANSFORM() numeric path for hbc.
 *
 * Exact transcription of Harbour 3.2:
 *   - hb_itemStrBuf (src/vm/itemapi.c 2577-2777): the freestanding
 *     double/long field formatter with the modf digit extraction, the
 *     16-digit rounding pass (HB_NUM_PRECISION is not defined), the
 *     sign-loss overflow and the asterisk tail.
 *   - the NUMERIC branch of hb_Transform (src/rtl/transfrm.c 389-566):
 *     the picture scan, the width==0 item defaults, the bAdjust strip
 *     (iWidth - iDec == 1) and the template loop (iCount restarts at 0).
 *
 * SET FIXED is off in this compiler, so the fixed-mode width adjustment
 * (transfrm.c 435-441) is not reachable. @ picture functions are rejected
 * by the hbc checker before this helper runs, so uiPicFlags stays 0.
 * modf comes from the truncating cast (the itemStrBuf values stay inside
 * the hbc float frontier, |x| < 2^53, where both agree bit for bit).
 */
typedef long long hrt_i64;
typedef unsigned long long hrt_u64;

extern void *hbc_alloc(hrt_u64 n);
extern void hbc_freestr(char *p);

struct hrt_ret {
    char *ptr;
    hrt_u64 len;
};

static void hrt_fill(char *d, hrt_u64 n, char c)
{
    hrt_u64 i;
    for (i = 0; i < n; i++)
        d[i] = c;
}

static void hrt_move(char *d, const char *s, hrt_u64 n)
{
    hrt_u64 i;
    if (d < s)
        for (i = 0; i < n; i++)
            d[i] = s[i];
    else
        for (i = n; i > 0; i--)
            d[i - 1] = s[i - 1];
}

static double hrt_modf(double x, double *ip)
{
    if (x >= 9223372036854775808.0 || x < -9223372036854775808.0) {
        *ip = x;
        return 0.0;
    }
    {
        hrt_i64 t = (hrt_i64)x;
        *ip = (double)t;
        return x - (double)t;
    }
}

static int hrt_isfinite(double d)
{
    union {
        double d;
        hrt_u64 u;
    } v;
    v.d = d;
    return (int)((v.u >> 52) & 0x7FF) != 0x7FF;
}

/* Own string block: 16-byte header {len, cap} then data, freed by name. */
static char *hrt_alloc_str(hrt_u64 cap)
{
    char *h = (char *)hbc_alloc(cap + 16);
    *(hrt_u64 *)(h + 0) = cap;
    *(hrt_u64 *)(h + 8) = cap;
    return h + 16;
}

/* hb_itemStrBuf (itemapi.c). Returns HB_TRUE (1) or HB_FALSE (0). */
static int hrt_itemstrbuf(char *szResult, int isdouble, hrt_i64 nNumber,
                          double dNumber, int iSize, int iDec)
{
    int iPos, iDot, fNeg = 0;

    if (iDec < 0)
        iDec = 0;

    if (iDec > 0)
        iPos = iDot = iSize - iDec - 1;
    else {
        iPos = iSize;
        iDot = 0;
    }

    if (isdouble) {
        double dInt, dFract, dDig;
        int iPrec, iFirst = -1;

        iPrec = 16;

        if (!hrt_isfinite(dNumber)) {
            iPos = -1;
            dInt = dFract = dDig = 0.0;
        } else {
            if (dNumber < 0) {
                fNeg = 1;
                dFract = hrt_modf(-dNumber, &dInt);
            } else {
                fNeg = 0;
                dFract = hrt_modf(dNumber, &dInt);
            }

            while (iPos-- > 0) {
                dDig = hrt_modf(dInt / 10.0 + 0.01, &dInt) * 10.0;
                szResult[iPos] = '0' + (char)(dDig + 0.01);
                if (szResult[iPos] != '0')
                    iFirst = iPos;
                if (dInt < 1)
                    break;
            }

            if (iPos > 0)
                hrt_fill(szResult, (hrt_u64)iPos, ' ');

            if (iDec > 0 && iPos >= 0) {
                for (iPos = iDot + 1; iPos < iSize; iPos++) {
                    dFract = hrt_modf(dFract * 10.0, &dDig);
                    szResult[iPos] = '0' + (char)(dDig + 0.01);
                    if (iFirst < 0) {
                        if (szResult[iPos] != '0')
                            iFirst = iPos - 1;
                    } else if (iPos - iFirst >= iPrec)
                        break;
                }
            }

            /* now try to round the results and set 0 in places over
               defined precision, the same is done by Clipper */
            if (iPos >= 0) {
                int iZer, iLast;

                if (iFirst < 0)
                    iZer = 0;
                else
                    iZer = iSize - iFirst - iPrec - (iDec > 0 ? 1 : 0);

                dFract = hrt_modf(dFract * 10.0, &dDig);
                iLast = (int)(dDig + 0.01);

                /* hack for x.xxxx4999999999, f.e. 8.995 */
                if (iLast == 4 && iZer < 0) {
                    for (iPos = -iZer; iPos > 0; --iPos) {
                        dFract = hrt_modf(dFract * 10.0, &dDig);
                        if (dDig + 0.01 < 9 && (iPos != 1 || dDig < 2))
                            break;
                    }
                    if (iPos == 0)
                        iLast = 5;
                }
                iLast = iLast >= 5 ? 1 : 0;

                iPos = iSize;
                while (iPos-- > 0) {
                    if (iDec == 0 || iPos != iDot) {
                        if (iZer > 0) {
                            if (iDec == 0 || iPos <= iDot + 1)
                                iLast = szResult[iPos] >= '5' ? 1 : 0;
                            szResult[iPos] = '0';
                            --iZer;
                        } else if (iLast > 0) {
                            if (szResult[iPos] == '9')
                                szResult[iPos] = '0';
                            else {
                                if (szResult[iPos] < '0') {
                                    szResult[iPos] = '1';
                                    iFirst = iPos;
                                } else {
                                    szResult[iPos]++;
                                    if (iFirst < 0)
                                        iFirst = iPos;
                                }
                                break;
                            }
                        } else
                            break;
                    }
                }

                if (fNeg && iFirst >= 0 && iPos >= 0) {
                    iPos = (iDot > 0 && iFirst >= iDot) ? iDot - 2 : iFirst - 1;
                    if (iPos >= 0)
                        szResult[iPos] = '-';
                }
            }
        }
    } else {
        hrt_i64 n;

        n = nNumber;

        fNeg = (n < 0);
        while (iPos-- > 0) {
            szResult[iPos] = '0' + (char)(fNeg ? -(n % 10) : (n % 10));
            n /= 10;
            if (n == 0)
                break;
        }
        if (fNeg && iPos-- > 0)
            szResult[iPos] = '-';

        if (iPos > 0)
            hrt_fill(szResult, (hrt_u64)iPos, ' ');

        if (iDec > 0 && iPos >= 0)
            hrt_fill(&szResult[iSize - iDec], (hrt_u64)iDec, '0');
    }

    szResult[iSize] = '\0';
    /* Set to asterisks in case of overflow */
    if (iPos < 0) {
        hrt_fill(szResult, (hrt_u64)iSize, '*');
        return 0;
    } else if (iDot > 0)
        szResult[iDot] = '.';

    return 1;
}

/* SysV entry. rdi=isdouble, rsi=i64 value, rdx/rcx=pic ptr/len,
   r8=item meta (len<<16|dec, doubles), xmm0=double value.
   Returns the owned string in rax/rdx. */
struct hrt_ret hbc_transform(int isdouble, hrt_i64 ivalue,
                             const char *szPic, hrt_u64 nPicLen,
                             hrt_u64 meta, double dValue)
{
    int iWidth = 0, iDec = 0, iCount = 0;
    hrt_u64 i;
    char *szResult;
    hrt_u64 cap;
    struct hrt_ret ret;

    (void)ivalue;
    (void)meta;

    /* picture scan (transfrm.c 409-429) */
    for (i = 0; i < nPicLen; i++) {
        if (szPic[i] == '.') {
            while (++i < nPicLen) {
                if (szPic[i] == '9' || szPic[i] == '#' ||
                    szPic[i] == '$' || szPic[i] == '*') {
                    iWidth++;
                    iDec++;
                }
            }
            if (iDec)
                iWidth++;
            break;
        } else if (szPic[i] == '9' || szPic[i] == '#' ||
                   szPic[i] == '$' || szPic[i] == '*')
            iWidth++;
    }

    iCount = 0;
    if (iWidth == 0) /* Width calculated ?? (transfrm.c 432-444) */
    {
        if (isdouble) {
            iWidth = (int)(meta >> 16);
            iDec = (int)(meta & 0xFFFF);
        } else {
            /* long item length, the hbc pinned Str defaults:
               non-negative max(10, digits+1); negative 10 when
               digits+sign fit in 10, else 20 */
            int neg = ivalue < 0;
            hrt_u64 a = neg ? (hrt_u64)(-ivalue) : (hrt_u64)ivalue;
            int digits = 1;
            while (a >= 10) {
                a /= 10;
                digits++;
            }
            if (neg)
                iWidth = digits + 1 <= 10 ? 10 : 20;
            else
                iWidth = digits + 1 >= 10 ? digits + 1 : 10;
            iDec = 0;
        }
        if (iDec)
            iWidth += iDec + 1;
    } else if (iDec > 0 && iWidth - iDec == 1) {
        iCount = 1;
        iWidth++;
    }

    cap = (hrt_u64)(iWidth > 0 ? iWidth : 1) + 2;
    szResult = hrt_alloc_str(cap);
    hrt_itemstrbuf(szResult, isdouble, ivalue, dValue, iWidth, iDec);

    if (iCount) /* bAdjust strip (transfrm.c 471-482) */
    {
        iWidth--;
        if (szResult[0] != '0') {
            hrt_fill(szResult + 1, (hrt_u64)iWidth, '*');
            szResult[0] = '.';
        } else
            hrt_move(szResult, szResult + 1, (hrt_u64)iWidth);
        szResult[iWidth] = '\0';
    }

    if (nPicLen == 0) {
        ret.ptr = szResult;
        ret.len = (hrt_u64)iWidth;
    } else {
        char *szStr = szResult;
        char *szNew = hrt_alloc_str(nPicLen + 2);
        int ic = 0;

        for (i = 0; i < nPicLen; i++) {
            char cPic = szPic[i];
            if (cPic == '9' || cPic == '#') {
                szNew[i] = ic < iWidth ? szStr[ic++] : ' ';
            } else if (cPic == '$' || cPic == '*') {
                if (ic < iWidth) {
                    szNew[i] = szStr[ic] == ' ' ? cPic : szStr[ic];
                    ic++;
                } else
                    szNew[i] = ' ';
            } else if (cPic == '.' && ic < iWidth) {
                szNew[i] = '.';
                ic++;
            } else if (cPic == ',' && i && ic < iWidth) {
                if (szNew[i - 1] >= '0' && szNew[i - 1] <= '9')
                    szNew[i] = ',';
                else {
                    szNew[i] = szNew[i - 1];
                    if (szNew[i - 1] == '-') {
                        szNew[i - 1] = (i > 1 && szNew[i - 2] != '$')
                                           ? szNew[i - 2] : ' ';
                    }
                }
            } else
                szNew[i] = cPic;
        }
        hbc_freestr(szStr);
        ret.ptr = szNew;
        ret.len = nPicLen;
    }
    return ret;
}
