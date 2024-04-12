@echo off
setlocal

set src=%cd%

echo Pulling SokoMaker at: %cd%
cd /d "../SokoMaker"
git checkout main
git pull

:: :: Skip mods because we don't need it
:: cd /d "Mods"
:: echo Pulling Mods at: %cd%
:: git checkout main
:: git pull

cd /d "explogine"
echo Pulling explogine at: %cd%
git checkout main
git pull

cd /d ".."
echo This should be your SokoMaker root directory: %cd%

dotnet run --project LuaDoc --repoPath=%cd%
xcopy "Manual\snippets.json" "%src%\.vscode\luasnippets.code-snippets" /Y

dotnet run --project LuaDoc --repoPath=%cd%

dotnet build SokoMakerEditor --configuration Release
endlocal
