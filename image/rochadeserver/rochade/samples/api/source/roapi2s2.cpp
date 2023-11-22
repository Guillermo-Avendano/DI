
/* Copyright (c) 1982-2020 ASG GmbH & Co. KG. All Rights Reserved.        */
/* This program is protected by U.S. and international copyright laws     */

#define MODULKENNUNG    "@(#) roapi2s1 6.02.07"
 
#define roasm1_c
 
/*************************************************************
**
**                      R O A P I 2 S 2 . C P P
**                      Sample 2 for API V6.2
**
**************************************************************
**
**  simple API-2 sample application which implements
**  a command line tool
**
**  command line: <command> [<section>] [<inifile>]
**          e.g.:  rapi2s2n     ROAPI   rochade.ini
**
**************************************************************
**
** CHANGE HISTORY
**
** 08.08.02 AI 6.02.01 created
** 14.08.02 AI 6.02.02 #C/#D (proxy object access) added
** 20.08.02 LG 6.02.03 BS2
** 29.10.02 LG 6.02.04 include <ctype.h>
** 05.02.03 GG 6.02.05 Copyright 2003
** 11.03.03 LG 6.02.06 main return type changed to int
** 20.05.20 AI 6.02.07 replace gets by fgets
**************************************************************/

#include "roapi2.h"
 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#ifndef ROWIN32
#include <locale.h>
#endif
 
#define  SECTION      "roapi"
#define  INIFILE      "rochade.ini"
 
#define  CMDBUFFSIZE  8192

class MyExtObj : public ROAPI_EXTOBJ {
private:
    ROAPI_SESSION *session; 
    MyExtObj() {}
    ~MyExtObj() {} // is only called by object itself ("delete this;")

public:
    MyExtObj(ROAPI_SESSION *psess)
        : session(psess) {}
    
    
    virtual unsigned long ROCALLCONV invoke(
      ROAPI_OUT_STRING&   retcode,
      int                 argc,
      ROAPI_IN_STRING    *argv[]) {

        printf("invoke called:\n");
        for (int i = 0; i < argc; i++)
            printf("argv[%d]=%s\n", i, argv[i]->getRef());
            
        retcode.setValue(1, "T");
        
        if (argc > 1 && strcmp(argv[1]->getRef(), "$$TERM") == 0) {
            ROAPI_PEXTOBJ pObj = NULL;
            session->proxy2Obj(*argv[0], pObj);
            printf("  proxy2Obj: pObj=%p (this: %p)\n", pObj, this);
            session->destroyProxy(*argv[0]);
            printf("  destroyProxy\n");
            delete this;
        }
        return 1;
    }
};



/*************************************************************
** local functions
**************************************************************/
 

/* ROAPI_IN_STRING class */
class MyInString : public ROAPI_IN_STRING {
private:
    ROAPI_PCNSTC  aString;
public:
    MyInString(ROAPI_PCNSTC str)
        : aString(str) {}
        
    ~MyInString() {}
    
    ROAPI_SHORT getWLen() {
        return -1;
    }
    
    ROAPI_SHORT getLen() {
        if (aString == NULL)
            return -1;
        return (ROAPI_SHORT)strlen(aString);
    }
    
    ROWAPI_PCNSTC getWRef() { return NULL; }
    
    ROAPI_PCNSTC getRef() { return aString; }
};


/* ROAPI_OUT_STRING class */

class MyOutString : public ROAPI_OUT_STRING {
private:
    ROAPI_PCHAR  aString;
public:
    MyOutString()
        : aString(NULL) {}
    
    ~MyOutString() {
        if (aString != NULL) free(aString);
    }
    
    ROAPI_BOOL setValue(ROAPI_SHORT, ROWAPI_PCNSTC) {
        return ROAPI_FALSE;
    }
    
    ROAPI_BOOL setValue(ROAPI_SHORT len, ROAPI_PCNSTC str) {
        if (aString != NULL)
            free(aString);
        aString = (ROAPI_PCHAR)malloc((len+1)*sizeof(ROAPI_CHAR));
        memcpy(aString, str, len*sizeof(ROAPI_CHAR));
        aString[len] = '\0';
        return ROAPI_TRUE;
    }
    
    ROAPI_PCNSTC getValue() { return aString; }
};
 
/* Trace Object */
class MyTrace : public ROAPI_TRACE {
private:
    ROAPI_SESSION *pSession;
    
public:
    MyTrace(ROAPI_SESSION *sess)
        : pSession(sess) {}
        
    ~MyTrace() {}
    int ROCALLCONV trace(
      ROAPI_IN_STRING& line,     /* next RPL line to be executed        */
      ROAPI_LINENO     lnno,     /* number of this line                 */
      ROAPI_IN_STRING& name,     /* name of procedure or class          */
      ROAPI_IN_STRING *action,   /* name of action or NULL pointer      */
      ROAPI_LINENO     lnstart,  /* first line number of action in hstr */
      ROAPI_LINENO     lnend,    /* last line number of action in hstr  */
      int              hstr      /* work area ID or RSTDIN, RDOSAM      */
   );
};

int ROCALLCONV MyTrace::trace(
      ROAPI_IN_STRING& line,     /* next RPL line to be executed        */
      ROAPI_LINENO     lnno,     /* number of this line                 */
      ROAPI_IN_STRING& name,     /* name of procedure or class          */
      ROAPI_IN_STRING *action,   /* name of action or NULL pointer      */
      ROAPI_LINENO     lnstart,  /* first line number of action in hstr */
      ROAPI_LINENO     ,         /* last line number of action in hstr  */
      int                        /* work area ID or RSTDIN, RDOSAM      */
)
{
    char cmd[CMDBUFFSIZE];
    
    if (action == NULL) {
        printf("Breakpoint in procedure %s\n", name.getRef());
    } else {
        printf("Breakpoint in action %s in class %.*s\n",
               action->getRef(), name.getLen()-1, name.getRef());
    }
   
    printf("%04ld %s\n", lnno - lnstart + 1, line.getRef());
    
    for (;!feof(stdin);) {
        printf("TRACE> ");
        fflush( stdout );
        if (fgets(cmd, CMDBUFFSIZE, stdin) != NULL) {
            size_t len = strlen(cmd);
            if (len > 0 && cmd[len-1] == '\n') {
                cmd[len-1] = '\0';
            }
        }
       
        if ((feof(stdin)))
        {
            cmd[0] = '\0';
        } 
       
        if (cmd[0] == '\0')
           return 'S';
        if (cmd[0] == '.')
           return 'R';
       
        MyOutString retcode;
        MyInString  command(cmd);
        /* execute command */
        // trace should be disabled during this execution?!
        // Or is it done internally?
        pSession->exec( retcode, command );
        /* Print result */
        printf( "RETCODE=%s ", retcode.getValue() );
      
    }
    printf( "\nEOF\n");
    fflush( stdout );

    /* expected retcodes:                                   */
    /* old trace mode: 'R': for run, 'P' for next procedure */
    /* new trace mode: 'R' or 'P' for continue              */
    return 'R';
}
    
 
/*************************************************************
** main function
**************************************************************/
#ifdef ROAPI2
quatsch!!!
#endif
 
int main( int argc, char *argv[] )
{
    char          *sec;
    char          *ini;
    ROAPI_SHORT   vers = ROAPI_VERSION;
    ROAPI_SHORT   errorCode;
    ROAPI_SESSION *session; 

#ifndef ROWIN32
    setlocale(LC_CTYPE, "");
#endif

    printf( "\n***   start API2 sample 2   ***\n" );
    
    session = newRoSession(vers, errorCode);
    if (errorCode != API_ERR_NOERROR) {
        printf("Error %d returned by newRoSession(), API version is %d\n",
               (int)errorCode, (int)vers);
        exit(1);
    }
    
    if  ( argc >= 2 )  sec = argv[1];    else      sec = SECTION;
    if  ( argc >= 3 )  ini = argv[2];    else      ini = INIFILE;
    try {
        session->connect(sec, ini, 0, ROAPI_FALSE, NULL);
        
        MyTrace traceObj(session);
        
        session->setTraceObj(&traceObj);
        printf("setTraceObj successful\n");
        
        int EndSignalled = 0;
        
        
        /*********************************************************
        * process all user input
        **********************************************************/
        
        printf("API ");
        
        while (!(feof(stdin)) & !(EndSignalled)) {
            char cmd[CMDBUFFSIZE];
            MyOutString retcode;
        
            /*****************************************************
            * get next input and process accordingly
            ******************************************************/
            printf(">");
            fflush( stdout );
            if (fgets(cmd, CMDBUFFSIZE, stdin) != NULL) {
                size_t len = strlen(cmd);
                if (len > 0 && cmd[len-1] == '\n') {
                    cmd[len-1] = '\0';
                }
            }
            if (!(feof(stdin))) {
                /*************************************************
                * is input a "special" command
                **************************************************/
        
                if (cmd[0] == '#') { 
                    /*********************************************
                    * maybe, so handle it
                    **********************************************/
                    char c;
                    ROAPI_LINENO i;
                       
                    c = cmd[1];
                    if (islower(c)) c = (char)toupper(c);
        
                    /********************************************* 
                    * based on character code H, P, S, T, I or V
                    * process the "special" command
                    **********************************************/
        
                    switch (c) {
                    /*********************************************
                    ** #H - help
                    **********************************************/
                    case 'H':
                        fprintf(stderr,
"Rochade 6.2 API Test Program\n");
                        fprintf(stderr,
"Enter any Rochade command or following special command:\n");
                        fprintf(stderr,
"#H   - displays help\n");
                        fprintf(stderr,
"#P   - displays the current work area\n");
                        fprintf(stderr,
"#T   - terminates program (or <ctrl>Z on PCs, <ctrl>D on Unix)\n");
                        fprintf(stderr,
"#I   - reinitialize API again (termAPI/initAPI)\n");
                        fprintf(stderr,
"#R   - reinitialize API again (reinitAPI)\n");
                        fprintf(stderr,
"#V <varname> - displays value of <varname>, \
name is case sensitive!\n");
                        fprintf(stderr,
"#C <varname> - create proxy, save ID in <varname>\n");
                        fprintf(stderr,
"#D <varname> - destroy proxy, ID in <varname>\n");
                        break;
        
                    /*********************************************
                    ** #P - print work area
                    **********************************************/
                    case 'P':
                    {
                        ROAPI_LINENO lineCount = session->getSizeWA();
                        for (i = 1; i <= lineCount; i++) {
                            MyOutString line;
                            session->getLine( i, line );
                            printf( "%s\n", line.getValue() );
                        }
                        break;
                    }
                    /**********************************************
                    ** #T - terminate program
                    ***********************************************/
                    case 'T':
                        EndSignalled = 1;
                        break;
        
                    /**********************************************
                    ** #I - reinitialize program (termAPI/initAPI)
                    ***********************************************/
                    case 'I':
                        session->disconnect();
                        session->connect(sec, ini, 0, ROAPI_FALSE, NULL);
                        break;
        
                    /**********************************************
                    ** #R - reinitialize program (reInitAPI)
                    ***********************************************/
                    case 'R':
                        session->reset(ROAPI_TRUE);
                        break;
        
                    /*********************************************
                    ** #V - print value of variable
                    **********************************************/
                    case 'V': 
                    {
                        /*****************************************
                        ** ensure a variable name was specified
                        ******************************************/
                        if (strlen(cmd) < 4) {
                            fprintf( stderr,
                            "API-SPEC: No variable name given\n" );
                            break;
                        }
        
                        MyInString varname(cmd+3);
                        MyOutString value;
        
                        /*****************************************
                        ** request & display value of variable
                        ******************************************/
                        if (session->isVariable( varname )) {
                            session->getVariable( varname, value );
                            printf( "%s=%s\n", cmd+3, value.getValue());
                        }
                        else {
                            fprintf(stderr, "Variable %s does not exist\n",
                                             varname.getRef());
                        }
                        break;
                    }    
                    /*********************************************
                    ** #C - create a proxy obj
                    **********************************************/
                    case 'C': 
                    {
                        /*****************************************
                        ** ensure a variable name was specified
                        ******************************************/
                        if( strlen(cmd) < 4 ) {
                            fprintf( stderr,
                            "API-SPEC: No variable name given\n");
                            break;
                        }
        
                        MyInString varname(cmd+3);
                        MyOutString value;
        
                        /*****************************************
                        ** create proxy
                        ******************************************/
                        session->createProxy( value, new MyExtObj(session));
                        printf( "%s=%s\n", cmd+3, value.getValue());
                        MyInString inValue(value.getValue());
                        session->putVariable(varname, inValue);
                        break;
                    }    
                    /*********************************************
                    ** #D - destroy a proxy obj
                    **********************************************/
                    case 'D': 
                    {
                        /*****************************************
                        ** ensure a variable name was specified
                        ******************************************/
                        if( strlen(cmd) < 4 ) {
                            fprintf( stderr,
                            "API-SPEC: No variable name given\n");
                            break;
                        }
        
                        MyInString varname(cmd+3);
                        MyOutString value;
                        session->getVariable(varname, value);
                        printf("OID: %s\n", value.getValue());
                        MyInString inValue(value.getValue());
        
                        /*****************************************
                        ** destroy proxy
                        ******************************************/
                        session->destroyProxy( inValue );
                        printf("proxy destroyed\n");
                        break;
                    }    
                    default:
                        fprintf( stderr,
                        "API-SPEC: Unknown special command: %c\n", c);
                        break;
                    }       
                }
                else {
                    /*********************************************
                    * pass input to RoExec as a ROCHADE command
                    **********************************************/
                    MyInString  command(cmd);
        
                    session->exec(retcode, command);
                    printf("RETCODE=%s ", retcode.getValue());
                }
            }
        }/* while */
        
        /*********************************************************
        * terminate the API connection
        **********************************************************/
        session->disconnect();
    }
    catch (ROAPI_EXCEPTION& e) {
        short  s;
        MyOutString msg, lastfunc;
        s = e.getState();
        e.getMessage(msg);
        e.getLastFunction(lastfunc);
        printf( "Exception: fu=%s, msg=%s \n", lastfunc.getValue(), msg.getValue());
    }
 
    
    printf( "\n***   end   API2 sample 2   ***\n" );

    session->dispose(); session = 0;

    return 0;
}
