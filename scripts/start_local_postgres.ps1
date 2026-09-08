param(
    [string]$PostgresBin = (Join-Path $env:USERPROFILE '.cache/ho003-tools/pgsql/bin'),
    [string]$DataDirectory = (Join-Path $env:LOCALAPPDATA 'HomeOfficeReservation/postgres-18')
)
$ErrorActionPreference = 'Stop'
$pgControl = Join-Path $PostgresBin 'pg_ctl.exe'
if (!(Test-Path -LiteralPath $pgControl) -or !(Test-Path -LiteralPath (Join-Path $DataDirectory 'PG_VERSION'))) {
    throw 'Prepared portable PostgreSQL cluster not found. Use the documented Docker Compose setup or provide the existing binary/data paths.'
}
& $pgControl -D $DataDirectory status
if ($LASTEXITCODE -ne 0) {
    $postgresLog = Join-Path (Split-Path $DataDirectory -Parent) 'postgres.log'
    $process = Start-Process -FilePath $pgControl -ArgumentList @('-D', ('"{0}"' -f $DataDirectory), '-l', ('"{0}"' -f $postgresLog), '-w', 'start') -WindowStyle Hidden -Wait -PassThru
    if ($process.ExitCode -ne 0) { throw 'PostgreSQL did not start; inspect the private postgres.log.' }
}
& (Join-Path $PostgresBin 'pg_isready.exe') -h 127.0.0.1 -p 5432
if ($LASTEXITCODE -ne 0) { throw 'PostgreSQL is not accepting connections.' }
Write-Output 'PostgreSQL accepts connections. API /health/ready independently verifies its configured connection; migrations are explicit.'
