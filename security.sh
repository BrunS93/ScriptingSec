#!/bin/bash

# ruta
directorio=$(dirname "$(readlink -f "$0")")

# Patrones
patrones=("ataque" "acceso no autorizado" "vulnerabilidad")

# Archivo de salida 
archivo_salida="auditoria.txt"

# imprimir resultados en el archivo de salida
imprimir_resultado() {
    echo "$1" >> "$archivo_salida"
}

# escaneo achivos
for archivo in $directorio/*; do
    imprimir_resultado "=== Análisis de archivo: $archivo ==="

    # información básica del archivo
    file_info=$(file "$archivo")
    imprimir_resultado "Información del archivo: $file_info"

    # hash MD5 del archivo
    md5sum=$(md5sum "$archivo" | awk '{print $1}')
    imprimir_resultado "Hash MD5: $md5sum"

    # ClamAV
    clamscan_result=$(clamscan --no-summary "$archivo")
    imprimir_resultado "Resultado de escaneo con ClamAV: $clamscan_result"

    imprimir_resultado "--------------------------------------------------"
done

# escaneo usuarios
imprimir_resultado "=== Usuarios con shell válido ==="
usuarios_shell_valido=$(grep -E "/(bash|sh|zsh)$" /etc/passwd | cut -d: -f1)
imprimir_resultado "$usuarios_shell_valido"
imprimir_resultado ""

# servicios
imprimir_resultado "=== Servicios en ejecución ==="
servicios_en_ejecucion=$(systemctl list-units --type=service --state=running --no-pager)
imprimir_resultado "$servicios_en_ejecucion"
imprimir_resultado ""

# puertos visibles
imprimir_resultado "=== Puertos abiertos ==="
puertos_abiertos=$(netstat -tuln)
imprimir_resultado "$puertos_abiertos"


imprimir_resultado "=== Fin de analisis ==="

echo "Analisis completado. Los resultados se han guardado en $archivo_salida."
