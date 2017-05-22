#!/bin/bash

allCSProjs=""
csProjs32Bit=""
csProjWsExe=""

function getAllWsCsProjs()
{
    find -name "*.csproj" \
        -not -path "./*/as/*"
}

#32 bit executables checked by TSDCop
function get32BitCSProjs()
{
    find -name "*.csproj" -and \
        \( \
        -path "./core/ws/CrystalReportsLauncher/*" \
        -or -path "./diag/ws/*" \
        -or -path "./vm/ws/DVTelExternalViewer/*" \
        -or -path "./vm/ws/SecurityCenterExternalViewer/*" \
        -or -path "./vm/ws/OmniExternalViewer/*" \
        \)
}

function getExeCSProjs()
{
    getAllWsCsProjs | xargs grep -il -e "<OutputType>WinExe" -e "<OutputType>Exe"
}

function getLibCSProjs()
{
    getAllWsCsProjs | xargs grep -il "<OutputType>Library"
}

function removePrefer32Bit()
{
    sed -i -b "/<Prefer32Bit>.*/d" "$@"
}

function SetProjsToAnyCpu()
{
    #-b so we preserve line endings
    sed -i -b -e "s|<PlatformTarget>.*</PlatformTarget>|<PlatformTarget>AnyCPU</PlatformTarget>|g" "$@"
}

function addFalsePrefer32BitFlag()
{
    sed -i -b '/<PlatformTarget>AnyCPU<\/PlatformTarget>/a \ \ \ \ <Prefer32Bit>false<\/Prefer32Bit>' "$@"
}


function init()
{
    allCSProjs=$(getAllWsCsProjs)
    csProjs32Bit=$(get32BitCSProjs)
    csProjWsExe=$(getExeCSProjs)
}

init

SetProjsToAnyCpu $allCSProjs
removePrefer32Bit $allCSProjs

#set all exe to prefer32bit = false. i.e. All executables to set to run as 64bit if possible
addFalsePrefer32BitFlag $csProjWsExe

#set 32bit only exe's prefer32bit=true (remove the flag entirely)
removePrefer32Bit $csProjs32Bit

