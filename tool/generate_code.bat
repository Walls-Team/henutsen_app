@ECHO OFF

REM Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).

call flutter packages pub run build_runner build --delete-conflicting-outputs
del lib\src\*.reflectable.dart
del lib\generated_plugin_registrant.reflectable.dart
copy bin\main.reflectable.dart lib\
