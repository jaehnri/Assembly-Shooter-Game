@echo off

if not exist rsrc.rc goto over1
c:\masm32\bin\rc /v rsrc.rc
c:\masm32\bin\cvtres /machine:ix86 rsrc.res
:over1

if exist %1.obj del %1.obj
if exist %1.exe del %1.exe

c:\masm32\bin\ml /c /coff %1.asm
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

c:\masm32\bin\Link /SUBSYSTEM:WINDOWS /OPT:NOREF %1.obj rsrc.obj
if errorlevel 1 goto errlink

dir %1.*
goto TheEnd

:nores
c:\masm32\bin\Link /SUBSYSTEM:WINDOWS /OPT:NOREF %1.obj
if errorlevel 1 goto errlink
dir %1.*
goto TheEnd

:errlink
echo _
echo Link error
goto TheEndErro

:errasm
echo _
echo Assembly Error
goto TheEndErro

:TheEnd

start %1.exe



:TheEndErro

