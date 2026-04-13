@echo off
setlocal

set "ROOT_DIR=%~dp0"
cd /d "%ROOT_DIR%"

.\mvnw.cmd spring-boot:run

endlocal
