#include "postgres.h"			/* general Postgres declarations */

#include "executor/executor.h"	/* for Attribute */

PG_MODULE_MAGIC;


/* By Reference, Variable Length */

PG_FUNCTION_INFO_V1(checklen);

Datum checklen(PG_FUNCTION_ARGS)
{
  text *t = PG_GETARG_TEXT_PP(0);
  int32 size = VARSIZE_ANY_EXHDR(t);
  if(size > 0)
    PG_RETURN_BOOL(true);
  else
    PG_RETURN_BOOL(false);
}
