@ECHO OFF

REM Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).

del ..\bin\*.reflectable.dart
del ..\lib\*.reflectable.dart
del ..\lib\src\*.reflectable.dart
del ..\test\*.reflectable.dart
call flutter clean
call flutter packages pub upgrade

Pause