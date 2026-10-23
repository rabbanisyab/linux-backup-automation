
#!/usr/bin/env bash

set -Eeuo pipefail

# Linux Backup Automation
# Exit status:
# 0 = berhasil
# 1 = proses gagal
# 2 = parameter tidak valid

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/backup.log"

log_message() {
    local level="$1"
    shift
    local message="$*"

    if ! mkdir -p -- "$LOG_DIR"; then
        printf 'ERROR: Tidak dapat membuat direktori log.\n' >&2
        return 1
    fi

    if ! printf '[%s] [%s] %s\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" \
        "$level" "$message" >> "$LOG_FILE"; then
        printf 'ERROR: Tidak dapat menulis log.\n' >&2
        return 1
    fi

    printf '[%s] %s\n' "$level" "$message"
}

usage() {
    printf 'Penggunaan: %s <direktori_sumber> <direktori_backup>\n' "$0" >&2
}

validate_input() {
    if [[ $# -ne 2 ]]; then
        usage
        return 2
    fi

    local source_dir="$1"
    local backup_dir="$2"

    if [[ ! -d "$source_dir" ]]; then
        log_message ERROR "Direktori sumber tidak ditemukan: $source_dir" || true
        return 1
    fi

    if [[ ! -r "$source_dir" || ! -x "$source_dir" ]]; then
        log_message ERROR "Direktori sumber tidak dapat diakses: $source_dir" || true
        return 1
    fi

    if [[ -e "$backup_dir" && ! -d "$backup_dir" ]]; then
        log_message ERROR "Tujuan backup bukan direktori: $backup_dir" || true
        return 1
    fi

    if [[ -d "$backup_dir" && "$source_dir" -ef "$backup_dir" ]]; then
        log_message ERROR "Sumber dan tujuan backup tidak boleh sama." || true
        return 2
    fi

    if [[ -d "$backup_dir" && "$source_dir" -ef "$SCRIPT_DIR" ]]; then
        log_message ERROR "Folder proyek tidak boleh dijadikan sumber backup." || true
        return 2
    fi
}

run_backup() {
    local source_dir="$1"
    local backup_dir="$2"
    local timestamp
    local destination

    if ! mkdir -p -- "$backup_dir"; then
        log_message ERROR "Tidak dapat membuat direktori tujuan: $backup_dir" || true
        return 1
    fi

    # Cegah backup ke dalam direktori sumber sendiri.
    local source_abs backup_abs
    source_abs="$(realpath -e -- "$source_dir")" || return 1
    backup_abs="$(realpath -e -- "$backup_dir")" || return 1

    case "$backup_abs/" in
        "$source_abs/"*)
            log_message ERROR "Tujuan backup berada di dalam direktori sumber." || true
            return 2
            ;;
    esac

    timestamp="$(date '+%Y%m%d_%H%M%S')"
    destination="$backup_abs/backup_${timestamp}.tar.gz"

    if ! tar -czf "$destination" -C "$source_abs" .; then
        rm -f -- "$destination"
        log_message ERROR "Pembuatan arsip backup gagal." || true
        return 1
    fi

    if ! tar -tzf "$destination" >/dev/null; then
        rm -f -- "$destination"
        log_message ERROR "Verifikasi arsip backup gagal." || true
        return 1
    fi

    log_message INFO "Backup berhasil: $destination"
}

main() {
    validate_input "$@" || return $?
    run_backup "$1" "$2"
}

main "$@"

