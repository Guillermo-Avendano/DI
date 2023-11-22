
/* Copyright (c) 1982-2003 ASG GmbH & Co. KG. All Rights Reserved.        */
/* This program is protected by U.S. and international copyright laws     */

#define MODULKENNUNG    "@(#) rosmpstr.cpp 7.00.01"
/*-----------------------------------------------------------------*/
/*                                                                 */
/*                       R O S M P S T R . C P P                   */
/*                                                                 */
/*  a Sample-implementation for ROAPI_IN_STRING, ROAPI_OUT_STRING  */
/*                                                                 */
/*-----------------------------------------------------------------*/
/* AENDERUNGSGESCHICHTE:                                          
** ---------------------
** 05.08.02 GG 6.02.01 created
** 26.08.02 LG 6.02.02 Solaris compileable
** 29.10.02 LG 6.02.03 include stdlib.h
** 07.11.02 LG 6.02.04 do not include malloc.h on MVS
** 05.02.03 GG 6.02.05 Copyright 2003
** 30.10.03 AI 6.02.03 ROUNICODE for RPC Service sample 7
** 10.09.10 LG 7.00.00 provide achar and wchar implementation independently
**                     from ROUNICODE
** 16.09.10 LG 7.00.01 uni2local/local2uni added
*/

#include "rosmpstr.h"
#ifndef MVS
#include <malloc.h>
#endif
#include <string.h>
#include <stdlib.h>
#include <wchar.h>

RoAPIStringA::RoAPIStringA()
               : pString(0), sLen(0), bLen(0) {
}

RoAPIStringA::RoAPIStringA(const RoAPIStringA& s) {
   pString = 0;
   (void)setValue(s.sLen, s.pString);
}

RoAPIStringA::RoAPIStringA(ROAPI_PCNSTC s) {
   pString = 0;
   (void)setValue((ROAPI_SHORT)strlen(s), s);
}

RoAPIStringA::RoAPIStringA(ROAPI_SHORT len, ROAPI_PCNSTC s) {
   pString = 0;
   (void)setValue(len, s);
}

RoAPIStringA::~RoAPIStringA() {
   if (pString) free(pString);
}


const RoAPIStringA& RoAPIStringA::operator= (const RoAPIStringA& s) {
   (void)setValue(s.sLen, s.pString);
   return *this;
}

const RoAPIStringA& RoAPIStringA::operator= (ROAPI_PCNSTC s) {
   (void)setValue((ROAPI_SHORT)strlen(s), s);
   return *this;
}

ROAPI_SHORT RoAPIStringA::getLen() {
    return sLen;
}

ROAPI_SHORT RoAPIStringA::getWLen() {
    return -1;           // wide characters are not implemented
}

ROAPI_PCNSTC RoAPIStringA::getRef() {
   if (pString) return pString;
   else         return "";
}

ROWAPI_PCNSTC RoAPIStringA::getWRef() {
   return 0;            // wide characters not implemented
}

ROAPI_BOOL RoAPIStringA::setValue(ROAPI_SHORT len, ROAPI_PCNSTC s) {
   if (len >= bLen && pString) {
      free(pString);
      pString = 0;
      bLen = 0;      
   }  
           
   if (!pString) {
       bLen = (ROAPI_SHORT)(len + 1);
       pString = (ROAPI_PCHAR)malloc(bLen);
       if (!pString) bLen = 0;
   }    
       
   if (pString) {
       sLen = len;
       memcpy((void *)pString, s, sLen);
       pString[sLen] = '\0';
   }
   else { 
       sLen = 0;
   }    
   
   return ROAPI_TRUE;
}

ROAPI_BOOL RoAPIStringA::setValue(ROAPI_SHORT len, ROWAPI_PCNSTC s) {
   (void)len;
   (void)s;
   return ROAPI_FALSE;  // wide charachters not implemented
}

ROAPI_BOOL RoAPIStringA::setValue(ROAPI_PCNSTC s) {
   return setValue((ROAPI_SHORT)strlen(s), s);
}

ROAPI_BOOL RoAPIStringA::setValue(ROWAPI_PCNSTC s) {
   (void)s;
   return ROAPI_FALSE;   // wide characters not implemented
}


RoAPIStringW::RoAPIStringW()
               : pString(0), sLen(0), bLen(0) {
}

RoAPIStringW::RoAPIStringW(const RoAPIStringW& s) {
   pString = 0;
   (void)setValue(s.sLen, s.pString);
}

RoAPIStringW::RoAPIStringW(ROWAPI_PCNSTC s) {
   pString = 0;
   (void)setValue((ROAPI_SHORT)utf16len(s), s);
}

RoAPIStringW::RoAPIStringW(ROAPI_SHORT len, ROWAPI_PCNSTC s) {
   pString = 0;
   (void)setValue(len, s);
}

RoAPIStringW::~RoAPIStringW() {
   if (pString) free(pString);
}


const RoAPIStringW& RoAPIStringW::operator= (const RoAPIStringW& s) {
   (void)setValue(s.sLen, s.pString);
   return *this;
}

const RoAPIStringW& RoAPIStringW::operator= (ROWAPI_PCNSTC s) {
   (void)setValue((ROAPI_SHORT)utf16len(s), s);
   return *this;
}

ROAPI_SHORT RoAPIStringW::getLen() {
    return -1;           // non-wide characters are not implemented
}

ROAPI_SHORT RoAPIStringW::getWLen() {
    return sLen;
}

ROAPI_PCNSTC RoAPIStringW::getRef() {
   return 0;            // non-wide characters not implemented
}

ROWAPI_PCNSTC RoAPIStringW::getWRef() {
   if (pString) return pString;
   else         return (ROWAPI_PCNSTC)L"";
}

ROAPI_BOOL RoAPIStringW::setValue(ROAPI_SHORT len, ROAPI_PCNSTC s) {
   (void)len;
   (void)s;
   return ROAPI_FALSE;  // non-wide charachters not implemented
}

ROAPI_BOOL RoAPIStringW::setValue(ROAPI_SHORT len, ROWAPI_PCNSTC s) {
   if (len >= bLen && pString) {
      free(pString);
      pString = 0;
      bLen = 0;      
   }  
           
   if (!pString) {
       bLen = (ROAPI_SHORT)(len + 1);
       pString = (ROWAPI_PCHAR)malloc(bLen*sizeof(ROWAPI_CHAR));
       if (!pString) bLen = 0;
   }    
       
   if (pString) {
       sLen = len;
       memcpy((void *)pString, s, sLen*sizeof(ROWAPI_CHAR));
       pString[sLen] = '\0';
   }
   else { 
       sLen = 0;
   }    
   
   return ROAPI_TRUE;
}

ROAPI_BOOL RoAPIStringW::setValue(ROAPI_PCNSTC s) {
   (void)s;
   return ROAPI_FALSE;   // non-wide characters not implemented
}

ROAPI_BOOL RoAPIStringW::setValue(ROWAPI_PCNSTC s) {
   return setValue((ROAPI_SHORT)utf16len(s), s);
}

int utf16cmp(ROWAPI_PCNSTC str1, ROWAPI_PCNSTC str2) {
   ROWAPI_PCNSTC pos1 = str1;
   ROWAPI_PCNSTC pos2 = str2;

   for(;;) {
      if( *pos1 < *pos2 ) return  -1;
      if( *pos1 > *pos2 ) return   1;
      if( *pos1 == 0    ) return   0;
      pos1++;
      pos2++;
   }
}

ROWAPI_PCHAR utf16cat(ROWAPI_PCHAR dst, ROWAPI_PCNSTC src) {
   ROWAPI_PCHAR  dstPos = dst;
   ROWAPI_PCNSTC srcPos = src;

   while (*dstPos) dstPos++;

   while (*srcPos) {
      *dstPos = *srcPos;
      dstPos++;
      srcPos++;
   }
   *dstPos = 0;

   return dst;
}

ROWAPI_PCHAR utf16cpy(ROWAPI_PCHAR dst, ROWAPI_PCNSTC src) {
   ROWAPI_PCHAR  dstPos = dst;
   ROWAPI_PCNSTC srcPos = src;

   while (*srcPos){
      *dstPos = *srcPos;
      dstPos++;
      srcPos++;
   }
   *dstPos = 0;

   return dst;
}

unsigned int utf16len(ROWAPI_PCNSTC str) {
   int len = 0;
   while( *str ) {
      len++;
      str++;
   }
   return (unsigned int)len;
}

void uni2local(ROAPI_SESSION& session, RoAPIStringW& in, RoAPIStringA& out) {
   RoAPIStringW varName(ROWTEXT("argconv"));
   session.putVariable(varName, in);
   session.getVariable(varName, out);
}

void local2uni(ROAPI_SESSION& session, RoAPIStringA& in, RoAPIStringW& out) {
   RoAPIStringW varName(ROWTEXT("argconv"));
   session.putVariable(varName, in);
   session.getVariable(varName, out);
}
