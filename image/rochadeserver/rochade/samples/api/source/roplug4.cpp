/* Copyright (c) 1982-2010 ASG GmbH & Co. KG. All Rights Reserved.        */
/* This program is protected by U.S. and international copyright laws     */

#define MODULKENNUNG "@(#) roplug4.cpp 7.00.02"

/*-----------------------------------------------------------------*/
/*                                                                 */
/*                       R O P L U G 4 . C P P                     */
/*                                                                 */
/*-----------------------------------------------------------------*/
/* AENDERUNGSGESCHICHTE:                                          
** ---------------------
** 31.07.02 AI 6.02.00 created (based on roesm4.cpp)
** 13.01.03 AI 6.02.01 RoCreate in comments replaced with RoXClass
**                     and roesm4n replaced with roplug4n
** 15.01.03 AI 6.02.02 $$INIT handling
** 05.02.03 GG 6.02.03 Copyright 2003
** 27.03.03 LG 6.02.04 pragma export added (MVS)
** 07.04.03 LG 6.02.05 check for OS instead of ROAPI2 define
** 16.03.04 AI 6.02.06 methods that change the locale setting added
** 13.04.04 AT 6.02.07 Bug fixed: abort() calls in implementation of ROAPI_IN_STRING removed.
** 17.08.05 GG 6.02.08 TEST_WITH_IOSTREAM
**
** 18.10.07 AI 7.00.00 testCrash added
** 18.03.10 AI 7.00.01 setlocale for UNIX corrected
** 02.06.20 AI 7.00.02 fix buffer overflow
*/

/*
** This example contains a class RochadeProxy, that is used by class
** Calculator to maintain a proxy object. The class Calculator
** implements objects that contain a floating point value and methods
** for manipulating this value.
**
** Usage:
**
** The Rochade INI file must contain a section that assigns names to
** external libraries. The section name must be defined in the client
** start section in parameter PLUGINS.
**
** Example:
** PLUGINS=PLUGIN-NT
**
** [PLUGIN-NT]
** ROPLUG4N=roplug4n.dll
**
** An Rochade proxy object can be created with:
**
** $SENDCL $ROEXTERN.ROESM4N $CREATE varname
**
** and can be used as follows:
**
** $SEND :varname s 10.5
** $SEND :varname + 3.1
** $SEND :varname - 2.2
** $SEND :varname * 1.3
** $SEND :varname / 0.4
** $SEND :varname : 7.6
** $SEND :varname g
** 
** Tests for plugins that change the locale setting:
**
** $SEND :varname d 12.34
** $SEND :varname e 12.34
**
** Tests with errors:
** 1: write to illegal address
** 2: divide by zero
** 3: read from illegal address
**
** $SEND :varname c 1
** $SEND :varname c 2
** $SEND :varname c 3
**
** The result will be returned in the system variable RETCODE.
**
** The object is deleted (destroyed) with:
**
** $SEND :varname $DESTROY
**
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <locale.h>
#include <roapi2.h>


#ifdef TEST_WITH_IOSTREAM

#if defined (HPUNIX) 
#include <iostream/iostream.h>
#else
#ifdef BS2
#include <iostream.h>
#else
#include <iostream>
#endif
#endif

#ifndef HPUNIX
using namespace std;
#endif

#endif


/*
** Switch to C environment. The entry point must not be a C++ symbol.
** The client expects an entry point with a symbolic name and calling
** conventions for C, not C++.
*/
extern "C" {
/*
** The entry point RoXClass must be exported from the DLL.
** This information must be supplied to the linker.
** Some compilers/linkers allow special declarations that mark the
** symbol (function, variable name) as exported. The following lines
** define the macro USERDLLENTRY for Windows NT (Watcom und Visual C++
** compiler), OS/2 (Watcom C++ compiler) and other systems.
** If an other compiler is used, the macro must be adjusted to the
** conventions of this compiler.
*/
#ifdef ROWIN32 /* Windows NT */
#define USERDLLENTRY __declspec(dllexport)
#endif
#ifdef UNIX5 /* UNIX */
#define USERDLLENTRY
#endif
#ifdef MVS /* MVS */
#define USERDLLENTRY
#endif
#ifdef BS2 /* BS2 */
#define USERDLLENTRY
#endif

#ifdef MVS
#pragma export(RoXClass)
#endif

/* Prototype for RoXClass */
USERDLLENTRY unsigned long ROCALLCONV RoXClass(
ROAPI_SESSION     *psess,
ROAPI_OUT_STRING&  rcObj,
int                argc,
ROAPI_IN_STRING   *argv[]
);

}

class StaticTest {
   public:
      long fac10;
      
      StaticTest();
      ~StaticTest();
};

/* Constructor */
StaticTest::StaticTest()
{
   fac10 = 1;
   
   for (int i = 2; i <= 10; i++)
      fac10 *= i;

#ifdef TEST_WITH_IOSTREAM
   /* check if cerr is initialized */
   cerr << "StaticTest::StaticTest() called" << endl;
#endif

}

/* Destructor */
StaticTest::~StaticTest()
{
   /* add system specific test code to verify execution */
}

static class StaticTest statictestobj;


/*
** Sample class that implements the ROAPI_IN_STRING interface
*/
class PluginInString : public ROAPI_IN_STRING {
private:
    ROAPI_PCNSTC aString;
public:    
    PluginInString(ROAPI_PCNSTC str) : aString(str) {}
    ~PluginInString() {}
    ROAPI_SHORT getLen() { return (ROAPI_SHORT)strlen(aString); }
    ROAPI_SHORT getWLen() { /*abort();*/ return -1; }
    ROAPI_PCNSTC getRef() { return aString; }
    ROWAPI_PCNSTC getWRef() { /*abort();*/ return NULL; }
};

/*
** Sample class that implements the ROAPI_OUT_STRING interface
*/
class PluginOutString : public ROAPI_OUT_STRING {
private:
    ROAPI_PCHAR aString;
public:
    PluginOutString() : aString(NULL) {}
    ~PluginOutString() {
        if (aString != NULL)
            free(aString);
    }
    ROAPI_BOOL setValue(ROAPI_SHORT len, ROAPI_PCNSTC str) {
        // handle memory allocation for multiple calls correctly
        if (aString != NULL)
            free(aString);
        aString = (ROAPI_PCHAR)malloc(len+1);
        memcpy(aString, str, len);
        aString[len] = '\0';
        return ROAPI_TRUE;
    }
    
    ROAPI_BOOL setValue(ROAPI_SHORT, ROWAPI_PCNSTC) {
        return ROAPI_FALSE;
    }
    
    ROAPI_PCNSTC getValue() { return aString; }
};

/*
** Sample class for maintaining a proxy object
*/
class RochadeProxy {
   private:
      char proxyid[33];
      ROAPI_SESSION *roApiObj;

   public:
      RochadeProxy(ROAPI_SESSION *roApi, ROAPI_PEXTOBJ);
      ~RochadeProxy();

      char *get_proxyid();
};

/* Constructor */
RochadeProxy::RochadeProxy(ROAPI_SESSION *roApi, ROAPI_PEXTOBJ pext) : roApiObj(roApi)
{
    PluginOutString objID;
      
    /* create proxy objekt */
    roApiObj->createProxy(objID, pext); // may throw ROAPI_EXCEPTION
    strcpy(proxyid, objID.getValue());
}

/* Destructor */
RochadeProxy::~RochadeProxy()
{
   PluginInString objID(proxyid);

   /* destroy proxy object */
   roApiObj->destroyProxy(objID);
}

/* supply proxy object ID */
char *RochadeProxy::get_proxyid()
{
   return proxyid;   
}

/*
** Sample class Calculator:
** The class contains a private variable of type double,
** which can be used in different arithmetic operations.
*/
class Calculator : public ROAPI_EXTOBJ {
   private:
      ROAPI_SESSION *roApiObj;
      RochadeProxy *m_proxy;
      double d;

      double get(void);
      double set(double);
      double add(double);
      double sub(double);
      double mul(double);
      double div(double);

      double testCrash(double);

   public:
      Calculator(ROAPI_SESSION *);
      ~Calculator();
      ROAPI_BOOL register_proxy(ROAPI_IN_STRING& objID);
      unsigned ROLONG ROCALLCONV invoke(
            ROAPI_OUT_STRING& rcObj,
            int               argc,
            ROAPI_IN_STRING  *argv[]);

};

/* Constructor */
Calculator::Calculator(ROAPI_SESSION *roApi)
: roApiObj(roApi), d(0.0), m_proxy(NULL)
{
}

Calculator::~Calculator()
{
    if (m_proxy != NULL)
        delete m_proxy;
}

ROAPI_BOOL Calculator::register_proxy(ROAPI_IN_STRING& var)
{
    try {
        m_proxy = new RochadeProxy(roApiObj, this);
        /*
        ** Get proxy object ID and store it in a Rochade variable.
        ** The name of the Rochade variable is supplied in varname.
        */
        PluginInString objID(m_proxy->get_proxyid());
        roApiObj->putVariable(var, objID);
    }
    catch (ROAPI_EXCEPTION&) {
        if (m_proxy != NULL) delete m_proxy;
        m_proxy = NULL;
        return ROAPI_FALSE;
    }

    return ROAPI_TRUE;
}

/* set a new value */
double Calculator::set(double dd)
{
   d = dd;
   return d;
}

/* get current value */
double Calculator::get(void)
{
   return d;
}

/* add a value */
double Calculator::add(double dd)
{
   d += dd;
   return d;
}

/* subtract a value */
double Calculator::sub(double dd)
{
   d -= dd;
   return d;
}

/* multiply with a value */
double Calculator::mul(double dd)
{
   d *= dd;
   return d;
}

/* divide through a value */
double Calculator::div(double dd)
{
   d /= dd;
   return d;
}

double Calculator::testCrash(double dd)
{
    if (dd < 0.5) {
        char *p = NULL;
        strcpy(p, "Some Text");
    } else if (dd < 1.5) {
        int i = 4;
        int k = 4;
        i = k / (i - k);
    } else if (dd < 2.5) {
        long *p = NULL;
        while (++p != NULL) {
            long l = *p;
        }
    }
    return dd;
}



/* proxy callback function for $SEND */
unsigned ROLONG ROCALLCONV Calculator::invoke(
ROAPI_OUT_STRING&  rcObj,
int                argc,
ROAPI_IN_STRING   *argv[]
)
{
   ROAPI_CHAR retcode[33];

   if (argc <= 1) {
      /* At least on parameter must be supplied. */
      strcpy(retcode, "X-ARG1-MISSING");
      rcObj.setValue((ROAPI_SHORT)strlen(retcode), retcode);
      return 1; /* set $CALLRC to T */
   }

   ROAPI_PCNSTC method = argv[1]->getRef();
   
   if (strcmp(method, "$$INIT") == 0) {
      /* $SENDCL ... $CREATE */

      /* set Retcode to T */
      retcode[0] = 'T'; retcode[1] = '\0';
      rcObj.setValue((ROAPI_SHORT)strlen(retcode), retcode);
      return 1; /* set $CALLRC to T */
   } else if (strcmp(method, "$$TERM") == 0) {
      /* $SEND <objid> $DESTROY */

      /* delete C++ objekt */
      /* the destructor will delete the proxy object */
      delete this; 

      /* set Retcode to T */
      retcode[0] = 'T'; retcode[1] = '\0';
      rcObj.setValue((ROAPI_SHORT)strlen(retcode), retcode);
      return 1; /* set $CALLRC to T */
   } else if (strlen(method) != 1) {
      /* All methods/actions in this example have a one-letter name. */
      strcpy(retcode, "X-INVALID-METHOD");
      rcObj.setValue((ROAPI_SHORT)strlen(retcode), retcode);
      return 1; /* set $CALLRC to T */
   } else {
      double dd;
      if (method[0] == 'G') {
         /* method G has no additional parameters */
         dd = 0.0;
      } else if (argc <= 2) {
         /* all other methods have one additional parameter */
         strcpy(retcode, "X-ARG2-MISSING");
         rcObj.setValue((ROAPI_SHORT)strlen(retcode), retcode);
         return 1; /* set $CALLRC to T */
      } else if (sscanf(argv[2]->getRef(), "%lf", &dd) != 1) {
         /* parameter is no floating point value */
         strcpy(retcode, "X-ARG2-NOT-DOUBLE");
         rcObj.setValue((ROAPI_SHORT)strlen(retcode), retcode);
         return 1; /* set $CALLRC to T */
      }
      /* parameter are ok and converted */
      /* select method and call it */
      switch (method[0]) {
      case '+':
         dd = add(dd);
         break;
      case '-':
         dd = sub(dd);
         break;
      case '*':
         dd = mul(dd);
         break;
      case '/':
      case ':':
         dd = div(dd);
         break;
      case 'G':
         dd = get();
         break;
      case 'S':
         dd = set(dd);
         break;
      case 'D':
         // Sprache auf Deutsch
#ifdef ROWIN32
         setlocale(LC_NUMERIC, "german");
#else
         if (setlocale(LC_NUMERIC, "de_DE") == NULL) {
             setlocale(LC_NUMERIC, "de_DE.utf8");
         }
#endif
         break;
      case 'E':
         // Sprache auf Englisch oder "C"
#ifdef ROWIN32
         setlocale(LC_NUMERIC, "english");
#else
         if (setlocale(LC_NUMERIC, "en_US") == NULL) {
             if (setlocale(LC_NUMERIC, "en_US.utf8") == NULL)
                 setlocale(LC_NUMERIC, "C"); // fallback to C
         }
#endif
         break;
      case 'C':
        dd = testCrash(dd);
        break;
      default:
         /* no matching method found */
         strcpy(retcode, "X-INVALID-METHOD");
         rcObj.setValue((ROAPI_SHORT)strlen(retcode), retcode);
         return 1; /* set $CALLRC to T */
      }
      /* assign new value to RETCODE */
      /* AI, 02.06.20: fix buffer overflow: %.31g may produce 33 or 34 characters
       *               because [-]0. is not counted as significant digit; double
       *               is limited to ~16 significant digits, so %.20 is sufficient
       */
      sprintf(retcode, "%.20g", dd);
      rcObj.setValue((ROAPI_SHORT)strlen(retcode), retcode);
   }
   
   return 1; /* set $CALLRC to T */
}

/* entry point for $SENDCL */
USERDLLENTRY unsigned long ROCALLCONV RoXClass(
ROAPI_SESSION     *psess,
ROAPI_OUT_STRING&  rcObj,
int                argc,
ROAPI_IN_STRING   *argv[]
)
{
   ROAPI_CHAR retcode[33];   
   /* Special test to check if constructors of static objects
   ** have been executed.
   */
   if (statictestobj.fac10 != 3628800l) {
      strcpy(retcode, "X-NO-STATIC-CONSTRUCTOR-EXECUTED");

      rcObj.setValue((ROAPI_SHORT)strlen(retcode), retcode);
      return 0;  /* set $CALLRC to F */
   }
   
   if (argc > 2 && strcmp(argv[1]->getRef(), "$CREATE") == 0) {
      /*
      ** Create object. The constuctor will create the proxy object
      ** and assigns the object ID to the given variable (name in av[2]).
      ** RoAction is the callback function assigned to this object.
      */
      Calculator *obj = new Calculator(psess);

      if (obj == NULL || obj->register_proxy(*argv[2]) != ROAPI_TRUE) {
          if (obj != NULL)
              delete obj;
          strcpy(retcode, "X-CREATE-PROXY-FAILED");
          rcObj.setValue((ROAPI_SHORT)strlen(retcode), retcode);
          return 0;
      }

      retcode[0] = 'T'; retcode[1] = '\0';
      rcObj.setValue((ROAPI_SHORT)strlen(retcode), retcode);
      return 1; /* set $CALLRC to T */
   }
   if (argc <= 2)
      strcpy(retcode, "X-INVALID-PARAM-COUNT");
   else
      strcpy(retcode, "X-INVALID-CLASS-METHOD");

   rcObj.setValue((ROAPI_SHORT)strlen(retcode), retcode);
   
   return 0;  /* set $CALLRC to F */
}

