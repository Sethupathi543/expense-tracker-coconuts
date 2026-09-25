@echo off
if not defined JAVA_HOME (
    set "JAVA_HOME=C:\Program Files\Java\jdk-21.0.12"
)
set "MAVEN_BIN=%~dp0.tools\apache-maven-3.9.9\bin\mvn.cmd"
"%MAVEN_BIN%" %*
