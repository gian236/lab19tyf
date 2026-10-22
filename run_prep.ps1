$nak = "$env:USERPROFILE\go\bin\nak.exe"

# 1. Generar llave de prueba usando NOSTR_SECRET_KEY sin imprimirla
$env:NOSTR_SECRET_KEY = (& $nak key generate)

# 2. Clave pública en hex y npub
$pubkey = & $nak key public
$npub = & $nak encode npub $pubkey

Write-Output "PUBKEY: $pubkey"
Write-Output "NPUB: $npub"

# 3. Crear nota1.json con contenido exacto y etiqueta
$note1 = & $nak event -c "CS031 Lab 19 · nota de prueba" -t t=cs031lab19
[System.IO.File]::WriteAllText("$PSScriptRoot\nota1.json", $note1, [System.Text.Encoding]::UTF8)

# 4. Extraer solo el ID de la nota
$note1Json = $note1 | ConvertFrom-Json
$note1Id = $note1Json.id
Write-Output "NOTE1_ID: $note1Id"

# 5. Verificar nota original usando cmd pipe para EOF correcto
$verify1 = (cmd /c "type `"$PSScriptRoot\nota1.json`" | `"$nak`" verify 2>&1")
if ([string]::IsNullOrWhiteSpace($verify1)) {
    Write-Output "VERIFY_NOTA1: OK (valida - salida vacia)"
} else {
    Write-Output "VERIFY_NOTA1_OUTPUT: $verify1"
}

# 6. Crear nota1_alterada.json cambiando una sola letra del contenido ('prueba' -> 'pruebx')
$note1AlteredObj = $note1 | ConvertFrom-Json
$note1AlteredObj.content = "CS031 Lab 19 · nota de pruebx"
$note1Altered = $note1AlteredObj | ConvertTo-Json -Compress
[System.IO.File]::WriteAllText("$PSScriptRoot\nota1_alterada.json", $note1Altered, [System.Text.Encoding]::UTF8)

# 7. Verificar copia alterada y capturar la falla esperada (invalid .id)
$verifyAltered = (cmd /c "type `"$PSScriptRoot\nota1_alterada.json`" | `"$nak`" verify 2>&1")
Write-Output "VERIFY_ALTERED_OUTPUT: $verifyAltered"

# Guardar información pública
@{
    pubkey = $pubkey
    npub = $npub
    note1_id = $note1Id
    verify1 = if ([string]::IsNullOrWhiteSpace($verify1)) { "OK" } else { $verify1 }
    verify_altered = $verifyAltered
} | ConvertTo-Json | Set-Content -Encoding utf8 "$PSScriptRoot\public_data.json"
