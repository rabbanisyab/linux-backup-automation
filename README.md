# Linux Backup Automation

## Deskripsi
Script Bash untuk membuat backup direktori ke arsip tar.gz.

## Fitur
- Validasi argumen dan direktori sumber
- Membuat direktori tujuan backup
- Membuat dan memverifikasi arsip
- Mencatat hasil proses ke log
- Menggunakan exit code untuk hasil proses

## Kebutuhan
- Linux atau WSL Ubuntu
- Bash
- tar
- realpath

## Cara menjalankan
./backup.sh tests/sample-data tests/hasil-backup

## Exit code
- 0: berhasil
- 1: proses gagal
- 2: parameter tidak valid

## Log
Log disimpan di logs/backup.log.

## Pengujian
- bash -n backup.sh
- Backup berhasil dengan exit code 0
- Sumber tidak ditemukan menghasilkan exit code 1
- Argumen kurang menghasilkan exit code 2
