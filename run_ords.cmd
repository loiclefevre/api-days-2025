@echo off
REM JAVA_HOME must point to a GraalVM JDK 17
REM so that it gets access to JavaScript engine required for GraphQL and GraphiQL
set JAVA_HOME=C:\dev\graalvm-jdk-17.0.10+11.1
set GRAALVM_HOME=%JAVA_HOME%
cd ords-latest\bin
set ORDS_CONFIG_FOLDER=..\config

.\ords.exe --config %ORDS_CONFIG_FOLDER% serve
