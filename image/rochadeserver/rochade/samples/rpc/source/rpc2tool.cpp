/* Copyright (c) 1982-2010 ASG GmbH & Co. KG. All Rights Reserved.        */
/* This program is protected by U.S. and international copyright laws     */

#define MODULKENNUNG    "@(#) rpctool 7.00.02"

/****************************************************************************
**
**              R P C - S E R V I C E  ( T O O L S )
**    
** Description: This module provides a set of functions for frequently used 
**              tasks. It makes the handling of the API more 
**              convenient. It includes:
**              - handling of working areas
**                (create, open, close, delete, read, write)
**              - access to Rochade variables
**                (read, write)
**              - executing a Rochade command line
**
** Important for WindowsNT based services :
**              The service modules must be compiled with the "-zp4"
**              option using Watcom-C. The library "roapiaxn.lib" 
**              must be used for linking the executable. 
**              The executable itself should be 
**              a character based executable.
**
** History ******************************************************************
**
**  05.08.02 GG 6.02.01 created
**  08.08.02 GG 6.02.02 prototypes, enhancements
**  05.02.03 GG 6.02.03 Copyright 2003
**  24.02.03 LG 6.02.04 execWA parameter changed to ROAPI_OUT_STRING &
**  27.02.03 LG 6.02.05 expectedRc parameter added to execCmd
**  30.10.03 AI 6.02.06 ROUNICODE for RPC Service sample 7
**  30.07.10 GG 7.00.01 bug fixed unicode handling, rounicode enabled
**
*****************************************************************************/

#include "rpc2tool.h"
#include "rpc2stub.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef MVS
#pragma convlit(suspend)
#endif
static ROAPI_PCNSTC mes1 = "Parameter error: DoWa";
static ROAPI_PCNSTC mes2 = "Parameter error: ReadInWa";
static ROAPI_PCNSTC mes3 = "Parameter error: WriteOutWa";

#ifdef MVS
#pragma convlit(resume)
#endif


/***************************************************************************\
* RPC_EXCEPTION:  Exception object                                          *
\***************************************************************************/

RPC_EXCEPTION::RPC_EXCEPTION(ROAPI_PCNSTC pMsg) {
    mMsg = pMsg;
}

RPC_EXCEPTION::RPC_EXCEPTION(const RPC_EXCEPTION& e) {
    mMsg = e.mMsg;
}

RPC_EXCEPTION::~RPC_EXCEPTION() {}
    
ROAPI_PCNSTC RPC_EXCEPTION::getMessage() {
    return mMsg;    
}

/***************************************************************************\
* execCmd():   executes a Rochade command line                              *
* IN:          ROAPI_SESSION session   current Rochade session              *
* IN:          ROAPI_PCHAR   cmd       command line                         *
* IN:          ROAPI_PCHAR   errMsg    errorMessage for RETCODE != T        *
\***************************************************************************/

#ifdef ROUNICODE
void execCmd(ROAPI_SESSION& session, ROWAPI_PCNSTC cmd, ROAPI_PCNSTC  errMsg,
             ROWAPI_PCNSTC expectedRc)
#else
void execCmd(ROAPI_SESSION& session, ROAPI_PCNSTC cmd, ROAPI_PCNSTC  errMsg,
             ROAPI_PCNSTC expectedRc)
#endif
{             
    RoAPIString _cmd(cmd);
    RoAPIString retc;
    session.exec(retc, _cmd);
    
    if ((expectedRc) &&
#ifdef ROUNICODE
     (utf16cmp(retc.getWRef(), expectedRc) != 0)
#else
     (strcmp(retc.getRef(), expectedRc) != 0)
#endif
    ) throw RPC_EXCEPTION(errMsg);
}

/***************************************************************************\
* execWA():    executes all Rochade commands given in a working area        *
* IN:          ROAPI_SESSION       session   current Rochade session        *
* IN:          ROAPI_PCHAR         name      name of the working area       *
* OUT:         ROAPI_OUT_STRING &  rc    retcode (last executed #$exit rc)  *
\***************************************************************************/

#ifdef ROUNICODE
void execWA(ROAPI_SESSION& session, ROWAPI_PCNSTC name, ROAPI_OUT_STRING &rc) {
    ROWAPI_CHAR  tmp[ROCOSIZE+1];           /* Rochade command line    */
#else
void execWA(ROAPI_SESSION& session, ROAPI_PCNSTC name, ROAPI_OUT_STRING &rc) {
    ROAPI_CHAR  tmp[ROCOSIZE+1];           /* Rochade command line    */
#endif
   
    RoAPIString cmd;
    if (name == NULL)
        throw RPC_EXCEPTION(mes1);

    /* execute $DO <name> */
#ifdef ROUNICODE
    utf16cpy(tmp, ROTEXT("$DO "));
    utf16cat(tmp, name);
#else
    sprintf(tmp,ROTEXT("$DO %s"), name);
#endif
   
    cmd.setValue(tmp);
    session.exec(rc, cmd);
}

/***************************************************************************\
* clearWa():   deletes all lines in the current wa                          *
* IN:          ROAPI_SESSION   session   current Rochade session            *
\***************************************************************************/

void clearWA(ROAPI_SESSION& session) {
    RoAPIString cmd(ROTEXT("$DEL 1 $"));
    RoAPIString retc;
    session.exec(retc, cmd);
    // both retcode values 'T' and 'F' are OK.
}

/***************************************************************************\
* readInWA():  read a text file into the current wa                         *
* IN:          ROAPI_SESSION   session   current Rochade session            *
* IN:          ROAPI_PCHAR     name      file name to be read               *
* OUT:         ROAPI_PCHAR     rc        retcode of reading the file        *
\***************************************************************************/

#ifdef ROUNICODE
void readInWA(ROAPI_SESSION& session, ROWAPI_PCNSTC name, ROWAPI_PCHAR rc) {
    ROWAPI_CHAR  tmp[ROCOSIZE+1];           /* Rochade command line    */
#else
void readInWA(ROAPI_SESSION& session, ROAPI_PCNSTC name, ROAPI_PCHAR rc) {
    ROAPI_CHAR  tmp[ROCOSIZE+1];           /* Rochade command line    */
#endif
    
    RoAPIString cmd;
    RoAPIString retc;
    
    if (name == NULL || rc == NULL)
        throw RPC_EXCEPTION(mes2);

    /* execute $RSAM <name> */
#ifdef ROUNICODE
    utf16cpy(tmp, ROTEXT("$RSAM "));
    utf16cat(tmp, name);
#else
    sprintf(tmp,ROTEXT("$RSAM %s"), name);
#endif
    cmd.setValue(tmp);
    session.exec(retc, cmd);
    
#ifdef ROUNICODE
    *rc = retc.getWRef()[0];
#else
    *rc = retc.getRef()[0];
#endif
    
}


/***************************************************************************\
* writeOutWA(): writes the content of the current wa to a file              *
* IN:          ROAPI_SESSION   session   current Rochade session            *
* IN:          ROAPI_PCHAR     name      file name to be written            *
* OUT:         ROAPI_PCHAR     rc        retcode of writing the file        *
\***************************************************************************/

#ifdef ROUNICODE
void writeOutWA(ROAPI_SESSION& session, ROWAPI_PCNSTC name, ROWAPI_PCHAR rc) {
    ROWAPI_CHAR  tmp[ROCOSIZE+1];           /* Rochade command line    */
#else
void writeOutWA(ROAPI_SESSION& session, ROAPI_PCNSTC name, ROAPI_PCHAR rc) {
    ROAPI_CHAR  tmp[ROCOSIZE+1];           /* Rochade command line    */
#endif
    
    RoAPIString cmd;
    RoAPIString retc;

    if (name == NULL || rc == NULL)
        throw RPC_EXCEPTION(mes3);

    /* execute $WSAM <name> */
#ifdef ROUNICODE
    // wsprintfW(tmp, ROTEXT("$WSAM %s"), name);
    utf16cpy(tmp, ROTEXT("$WSAM "));
    utf16cat(tmp, name);
#else
    sprintf(tmp,ROTEXT("$WSAM %s"), name);
#endif
    
    cmd.setValue(tmp);
    session.exec(retc, cmd);
    
#ifdef ROUNICODE
    *rc = retc.getWRef()[0];
#else
    *rc = retc.getRef()[0];
#endif
}
