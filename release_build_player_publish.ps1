# Delete Output Directory
Remove-Item -Path ".\.build" -Recurse -Force -ErrorAction Ignore

# Build Player
neato monogame-release-build ..\SokoMaker\SokoMakerPlayer\SokoMakerPlayer.csproj ".build"

# Copy outself into the mod folder (excluding the .build)
robocopy . .\.build\Mods\ld55 /S /XD .build .git .vscode

# Player adds an autorun file
New-Item .\.build\Mods\autorun -Force
Add-Content .\.build\Mods\autorun ld55

# Delete pdb files
ls .build | where name -like *.pdb | remove-item

# ////////// EVERYTHING ABOVE IS COPY-PASTED //////////

neato publish-itch ".build" "notexplosive" "summoners-incorporeal" "windows"
explorer ".build"