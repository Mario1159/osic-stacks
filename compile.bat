@echo off
setlocal

SET STACK=analog-xk

SET DOCKER_USER=akilesalreadytaken
SET DOCKER_IMAGE=analog-tools
SET DOCKER_TAG=latest


SET CALL=call
:parse
    IF /I ""%1""==""""       GOTO run
    IF /I ""%1""==""--help"" GOTO documentation
    IF /I ""%1""==""-h""     GOTO documentation
    IF /I ""%1""==""--dry""  ( SET "CALL=echo" )
    IF /I ""%1""==""-s""     ( SET "CALL=echo" )
    IF /I ""%1""==""--path"" ( SET "DESIGNS=%~2" && SHIFT )
    IF /I ""%1""==""-p""     ( SET "DESIGNS=%~2" && SHIFT )
    SHIFT
    GOTO parse


:documentation
    echo Usage: run.bat %~nx0 [-h^|--help] [-s^|--dry-run]
    GOTO end


:run
    SET TAG=%DOCKER_USER%/%DOCKER_IMAGE%
    IF DEFINED DOCKER_TAG SET TAG=%TAG%:%DOCKER_TAG%

    %CALL% docker build --rm -t osicstacks-base-desktop -f base/desktop.Dockerfile .
    %CALL% docker build --rm -t osicstacks-base-web -f base/web.Dockerfile .
    %CALL% docker build --rm --build-arg BASE_IMG=osicstacks-base-web --target %STACK%-desktop -t %DOCKER_USER%/%STACK%:latest -f stacks/%STACK%.Dockerfile .
    ::%CALL% docker build --rm --build-arg BASE_IMG=%DOCKER_USER%/%STACK%:latest -t %TAG% -f stacks/analog/Dockerfile
    GOTO end

:end
    endlocal


:normalizepath
    SET DESIGNS=%~f1
    EXIT /B


:: Get DISPLAY from WSL
::wsl --exec bash --norc -c 'echo $DISPLAY'

:: Get current path of batsh script
::SET BATCH_PATH=%~dpnx0