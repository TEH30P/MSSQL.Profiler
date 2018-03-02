<# 
.SYNOPSIS
	Changing sql server target version in *.tdf (profiler trace template) file.
.DESCRIPTION
	Changing sql server target version in *.tdf (trace template) file.
	To create *.tdf go to <SQL Server Profiler>\"File"\"Templates"\"Export Template...". To load *.tdf into templates list go to <SQL Server Profiler>\"File"\"Templates"\"Import Template..."
.PARAMETER iPath
	Source *.tdf file.
.PARAMETER iPathNew
	Destination *.tdf file. If ommitted then file $iPath will be rewrited. If file $iPathNew exists it will be overwrited.
.PARAMETER iVerNew
	Required target MS SQL Version for trace template in format 'X.X' or 'X'.
	Eg: 10.5 for MS SQL Server 2008 R2, 11 for MS SQL Server 2012. You can google it with query "ms sql versions".
.INPUTS
	<none>
.OUTPUTS
	<none>
.EXAMPLE
	mssql.profiler.template.sql_ver.chg.ps1 try_105.tdf try_13.tdf 13
	Will change 
.LINK
	https://github.com/TEH30P/MSSQL.Profiler
#>

param
(	[parameter(Mandatory=1, position=0)][String]$iPath
,	[parameter(Mandatory=0, position=1)][String]$iPathNew
,	[parameter(Mandatory=0, position=2)][String]$iVerNew
)

try {

if ([IO.Path]::GetExtension($iPath) -ne '.tdf')
{	[String]$Answ = Read-Host -Prompt 'It is not a *.tdf file. Are you sure? {Y|[N]}';
	
	if (!$Answ.Length -or $Answ -eq 'N')
	{	throw 'Canceled'}
}

[String]$PathAbs = (Convert-Path $iPath);
[Byte[]]$aBuff = [IO.File]::ReadAllBytes($PathAbs);

if ($aBuff.Count -le 391)
{	throw 'File is to small. Possible corrupted.'}

if ([String]::IsNullOrEmpty($iVerNew))
{	$iVerNew = Read-Host -Prompt "Current version is $($aBuff[390]).$($aBuff[391]). Enter new version:";

	if (!$iVerNew.Length)
	{	throw 'Canceled'}
}

[Version]$Ver = New-Object Version;
[UInt32]$VerMajor = 0;
[UInt32]$VerMinor = 0;

if (![UInt32]::TryParse($iVerNew, [ref]$VerMajor))
{	[Version]$iVerNew | % {$VerMajor = $_.Major; $VerMinor = "$($_.Minor)0".Substring(0,2)}}

$aBuff[390] = $VerMajor;
$aBuff[391] = $VerMinor;

if (![String]::IsNullOrEmpty($iPathNew))
{	[String]$PathAbs = (Convert-Path $iPathNew)}

[IO.File]::WriteAllBytes($PathAbs, $aBuff);

} catch 
{	throw}