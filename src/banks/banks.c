#include "postgres.h"			/* general Postgres declarations */

#include "executor/executor.h"	/* for Attribute */
#include <stdio.h>
#include <string.h>
#include "banks.h"

PG_MODULE_MAGIC;

static const int8_t tr1[256] = {
    ['0'] = 0, ['1'] = 1, ['2'] = 2, ['3'] = 3, ['4'] = 4,
    ['5'] = 5, ['6'] = 6, ['7'] = 7, ['8'] = 8, ['9'] = 9,

    ['A'] = 0, ['B'] = 1, ['C'] = 2, ['D'] = 3, ['E'] = 4,
    ['F'] = 5, ['G'] = 6, ['H'] = 7, ['I'] = 8, ['J'] = 9
};

static const int8_t tr2[256] = 
{
  ['0'] = 0,
  ['1'] = 1,
  ['2'] = 2,
  ['3'] = 3,
  ['4'] = 4,
  ['5'] = 5,
  ['6'] = 6,
  ['7'] = 7,
  ['8'] = 8,
  ['9'] = 9,
  ['A'] = 0,
  ['B'] = 1,
  ['C'] = 2,
  ['E'] = 3,
  ['H'] = 4,
  ['K'] = 5,
  ['M'] = 6,
  ['P'] = 7,
  ['T'] = 8,
  ['X'] = 9
};

char cck(const char *bik, const char *account)
{
    static const int weight[3] = {7, 1, 3};
    int sum = 0;
    int pos = 0;
#define ADD_DIGIT(d) \
    do { \
        sum += (d) * weight[pos % 3]; \
        ++pos; \
    } while (0)
    /* первые 3 цифры */
    if (!memcmp(bik + 6, "000", 3) || !memcmp(bik + 6, "001", 3) || !memcmp(bik + 6, "002", 3))
    {
        ADD_DIGIT(0);
        ADD_DIGIT(bik[4] - '0');
        ADD_DIGIT(bik[5] - '0');
    }
    else
    {
        ADD_DIGIT(bik[6] - '0');
        ADD_DIGIT(bik[7] - '0');
        ADD_DIGIT(bik[8] - '0');
    }
    /* account[1..5] */
    for (int i = 0; i < 5; ++i)
        ADD_DIGIT(tr1[(uint8_t)account[i]]);
    /* account[6..8] */
    for (int i = 5; i < 8; ++i)
        ADD_DIGIT(tr2[(uint8_t)account[i]]);
    /* добавленная '0' */
    ADD_DIGIT(0);
    /* account[10..20] */
    for (int i = 9; i < 20; ++i)
        ADD_DIGIT(account[i] - '0');
#undef ADD_DIGIT
   return ('0' + ((sum * 3) % 10));
}

PG_FUNCTION_INFO_V1(account_cck);
Datum account_cck(PG_FUNCTION_ARGS)
{
  text *bik = PG_GETARG_TEXT_PP(0);
  text *account = PG_GETARG_TEXT_PP(1);
  char *a = VARDATA_ANY(account);
  char key;
  key = cck( VARDATA(bik), a);
  a[8] = key;
  PG_RETURN_TEXT_P(account);
}

PG_FUNCTION_INFO_V1(check_cck);
Datum check_cck(PG_FUNCTION_ARGS)
{
  text *bik = PG_GETARG_TEXT_PP(0);
  text *account = PG_GETARG_TEXT_PP(1);
  char *a = VARDATA_ANY(account);
  char old_key = a[8];
  char key;
  key = cck( VARDATA(bik), a);
  if(old_key == key)
    PG_RETURN_BOOL(true);
  else
    PG_RETURN_BOOL(false);
}
