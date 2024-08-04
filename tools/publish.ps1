﻿param($is_release, $is_trim)

$PUBLISH_TARGET = "..\out\ClassIsland"

if ($(Test-Path ./out) -eq $false) {
    mkdir out
} else {
    rm out/* -Recurse -Force
}
$tag = $(git describe --tags --abbrev=0)
$count = $(git rev-list --count HEAD)
$ver = [System.Version]::Parse($tag)

if ($is_release) {
    $version = $ver
} else {
    $version = [System.Version]::new(1, 0, 0, $($count -as [int]))
    
}
echo $($version -as [string])
#dotnet clean

dotnet build -c Release -p:Platform="Any CPU" -p:Version=$($version -as [string])
cp ./**/bin/Release/*.nupkg ./out
    
dotnet publish .\ClassIsland\ClassIsland.csproj -c Release -p:PublishProfile=FolderProfile -p:PublishDir=$PUBLISH_TARGET -property:DebugType=embedded -p:TrimAssets=$is_trim

Write-Host "Successfully published to $PUBLISH_TARGET" -ForegroundColor Green

Write-Host "Packaging..." -ForegroundColor Cyan

rm ./out/ClassIsland/*.xml

7z a ./out/ClassIsland.zip ./out/ClassIsland/* -r -mx=9

rm -Recurse -Force ./out/ClassIsland
