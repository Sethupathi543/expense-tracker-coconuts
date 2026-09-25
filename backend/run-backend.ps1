# Launcher script for Spring Boot Backend
$ErrorActionPreference = "Stop"
$env:JAVA_HOME = "C:\Program Files\Java\jdk-21.0.12"
$mvnCmd = Join-Path $PSScriptRoot ".tools\apache-maven-3.9.9\bin\mvn.cmd"

Write-Host "==================================================" -ForegroundColor Green
Write-Host " Starting Coconut Expense Tracker Backend (Spring Boot 3) " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green

& $mvnCmd spring-boot:run
