param(
    [Parameter(Mandatory=$true)]
    $licenseName,
    [Parameter(Mandatory=$true)]
    $author,
    [Parameter(Mandatory=$true)]
    $year,
    [Parameter(Mandatory=$false)]
    $repoPath = ".",
    [Parameter(Mandatory=$false)]
    $description = "")

$licenses = @(
@{
    name = 'apache2'
    alternate_names = @("apache")
    licensePathName = 'APACHE2'
},
@{
    name = 'boost1'
    alternate_names = @("boost1")
    licensePathName = 'BOOST1'
},
@{
    name = 'gnu_agpl3'
    alternate_names = @("agpl3")
    licensePathName = 'GNU_AGPLv3'
},
@{
    name = 'gnu_gpl3'
    alternate_names = @("gpl","gpl3")
    licensePathName = 'GNU_GPLv3'
},
@{
    name = 'gnu_lgpl3'
    alternate_names = @("lgpl3")
    licensePathName = 'GNU_LGPLv3'
},
@{
    name = 'mozilla'
    alternate_names = @("mozilla2")
    licensePathName = 'MOZILLA2'
},
@{
    name = 'unlicense'
    alternate_names = @()
    licensePathName = 'UNLICENSE'
},
@{
    name = 'mit'
    alternate_names = @()
    licensePathName = 'MIT'
}
)

$fileexts = @{
".go" = @{
     first = ""
     middle = "// "
     last = ""
 }
 ".js" = @{
    first = "/* "
    middle = " * "
    last = " */"
 }
 ".java" = @{
    first = "/* "
    middle = " * "
    last = " */"
}
".kt" = @{
    first = "/* "
    middle = " * "
    last = " */"
}
".rs" = @{
    first = "/* "
    middle = " * "
    last = " */"
}
".ts" = @{
    first = "/* "
    middle = " * "
    last = " */"
}
".xml" = @{
    first = "<!--"
    middle = "~ "
    last = "-->"
}
}

function GetLicenseInfo {
    param (
        $licenseName
    )

    ForEach ($licenseInfo in $licenses) {
        if (($licenseInfo.name -eq $licenseName) -or ($_.alternate_names.Contains($licenseName))) {
            return $licenseInfo
        }
    }

}

function GetBoilerPlate {
    param (
        $licenseFilename,
        $author,
        $year,
        $description
    )

    $bpRawLines = $boilerplateRaw.Split("`n")
    $boilerplate = @()
    ForEach ($bpRawLine in $bpRawLines) {
        $bpRawLine = $bpRawLine -replace "\[YEAR\]", "$year"
        $bpRawLine = $bpRawLine -replace "\[NAME\]", "$author"
        $bpRawLine = $bpRawLine -replace "\[DESCRIPTION\]", "$description"
        $boilerplate += $bpRawLine
    }
    return $boilerplate
}

function LicenseInFile {
    param (
        $filepath,
        $licenseLines
    )

    $fileStr = Get-Content -Path "$filepath" -Raw;

    if((!$fileStr) -or ($fileStr -eq "") -or ($licenseLines.count -eq 0)) {
        return $FALSE
    }

    ForEach ($licenseLine in $licenseLines) {
        if($fileStr.IndexOf($licenseLine) -eq -1) {
            return $FALSE
        }
    }

    return $true
}

$licenseInfo = GetLicenseInfo($licenseName)

$BASE_URL = "https://raw.githubusercontent.com/silvagpmiguel/license-prepender/main/"
$boilerplateRaw = (Invoke-WebRequest -Uri "$BASE_URL/boilerplates/$($licenseInfo.licensePathName)" -UseBasicParsing).Content

$repoPathNormalized = $repoPath.TrimEnd(@('/', '\'))

Get-ChildItem -Path $repoPathNormalized -Recurse | Foreach-Object {

    if ($fileexts.Contains($_.Extension)) {
        $extObj = $fileexts[$_.Extension]

        $bpLines = GetBoilerPlate $licenseInfo.licensePathName "$author" "$year" "$description" 
        $prepend = @()
        $i = 0
        $bpLines | Foreach-Object {
            if ($i -eq 0) {
                if ($($extObj.first) -ne ""){
                    $prepend += "$($extObj.first)"
                }
                $prepend += "$($extObj.middle)${_}"
            } elseif ($i -eq ($bpLines.Length)-1) {
                $prepend += "$($extObj.middle)${_}"
                if ($($extObj.last) -ne ""){
                    $prepend += "$($extObj.last)"
                }
            } else {
                $prepend += "$($extObj.middle)${_}"
            }
            $i++
        }
        
        $fileContents = Get-Content $_.FullName
        if(LicenseInFile $_.FullName  $bpLines) {
            Write-Host "License already present in $($_.FullName)";
        } else {
            Write-Host "Adding license to $($_.FullName)";
            $prepend + "`r`n" +  $fileContents | Set-Content $_.FullName;
        }
    }

}

if( !(Test-Path "$repoPathNormalized/LICENSE" -PathType Leaf) -and !(Test-Path "$repoPathNormalized/LICENSE.txt" -PathType Leaf) ) {
    $licenseRawLines = (Invoke-WebRequest -Uri "$BASE_URL/licenses/$($licenseInfo.licensePathName)" -UseBasicParsing).Content.Split("`n")
    $finalLicense = @()
    ForEach ($licenseRawLine in $licenseRawLines) {
        $licenseRawLine = $licenseRawLine -replace "\[YEAR\]", "$year"
        $licenseRawLine = $licenseRawLine -replace "\[NAME\]", "$author"
        $licenseRawLine = $licenseRawLine -replace "\[DESCRIPTION\]", "$description"
        $finalLicense += $licenseRawLine
    }

    $finalLicense | Set-Content "$repoPathNormalized/LICENSE";
}
