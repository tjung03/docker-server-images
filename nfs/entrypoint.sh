#!/bin/bash
set -euo pipefail

log() {
    echo "[infra-nfs] $*"
}

NFS_V4_ROOT="${NFS_V4_ROOT:-/exports}"
NFS_EXPORT_NAME="${NFS_EXPORT_NAME:-share}"
NFS_EXPORT_DIR="${NFS_EXPORT_DIR:-${NFS_V4_ROOT}/${NFS_EXPORT_NAME}}"
NFS_LOG_DIR="${NFS_LOG_DIR:-${NFS_EXPORT_DIR}/logs}"

NFS_ALLOWED_CLIENTS="${NFS_ALLOWED_CLIENTS:-*}"
NFS_EXPORT_OPTIONS="${NFS_EXPORT_OPTIONS:-rw,sync,no_subtree_check,no_root_squash,insecure}"
NFS_V4_ROOT_OPTIONS="${NFS_V4_ROOT_OPTIONS:-rw,fsid=0,crossmnt,no_subtree_check,no_root_squash,insecure}"

NFS_SERVER_THREADS="${NFS_SERVER_THREADS:-8}"
NFS_SHARE_MODE="${NFS_SHARE_MODE:-0777}"

EXPORTS_FILE="/etc/exports.d/nfs.exports"

MOUNTD_PID=""

mkdir -p \
    "${NFS_V4_ROOT}" \
    "${NFS_EXPORT_DIR}" \
    "${NFS_LOG_DIR}" \
    /etc/exports.d \
    /proc/fs/nfsd \
    /var/lib/nfs/rpc_pipefs \
    /run

touch /etc/exports

chmod 755 "${NFS_V4_ROOT}" || true
chmod "${NFS_SHARE_MODE}" "${NFS_EXPORT_DIR}" "${NFS_LOG_DIR}" || true

log "NFSv4 pseudo-root: ${NFS_V4_ROOT}"
log "Export directory: ${NFS_EXPORT_DIR}"
log "NFSv4 visible export path: /${NFS_EXPORT_NAME}"
log "Log directory: ${NFS_LOG_DIR}"
log "Allowed clients: ${NFS_ALLOWED_CLIENTS}"
log "Export options: ${NFS_EXPORT_OPTIONS}"
log "NFSv4 root options: ${NFS_V4_ROOT_OPTIONS}"

log "Generating ${EXPORTS_FILE}"

{
    printf "%s" "${NFS_V4_ROOT}"

    for client in ${NFS_ALLOWED_CLIENTS}; do
        printf " %s(%s)" "${client}" "${NFS_V4_ROOT_OPTIONS}"
    done

    printf "\n"

    printf "%s" "${NFS_EXPORT_DIR}"

    for client in ${NFS_ALLOWED_CLIENTS}; do
        printf " %s(%s)" "${client}" "${NFS_EXPORT_OPTIONS}"
    done

    printf "\n"
} > "${EXPORTS_FILE}"

log "NFS export configuration:"
cat "${EXPORTS_FILE}"

if ! mountpoint -q /proc/fs/nfsd; then
    log "Mounting nfsd filesystem on /proc/fs/nfsd"

    if ! mount -t nfsd nfsd /proc/fs/nfsd; then
        log "ERROR: failed to mount /proc/fs/nfsd"
        log "Run this container with --privileged."
        log "Also check that the host kernel supports nfsd."
        exit 1
    fi
fi

if ! mountpoint -q /var/lib/nfs/rpc_pipefs; then
    mount -t rpc_pipefs rpc_pipefs /var/lib/nfs/rpc_pipefs 2>/dev/null || true
fi

if command -v rpc.idmapd >/dev/null 2>&1; then
    rpc.idmapd 2>/dev/null || true
fi

log "Starting NFSv4 kernel server threads"
rpc.nfsd -N 3 -V 4 "${NFS_SERVER_THREADS}"

log "Applying export table"
exportfs -rav

log "Current exports:"
exportfs -v

if command -v rpc.mountd >/dev/null 2>&1; then
    log "Starting rpc.mountd helper"
    rpc.mountd -F &
    MOUNTD_PID="$!"
else
    log "ERROR: rpc.mountd not found"
    exit 1
fi

cleanup() {
    log "Stopping NFS server"

    if [[ -n "${MOUNTD_PID:-}" ]]; then
        kill "${MOUNTD_PID}" 2>/dev/null || true
    fi

    exportfs -au 2>/dev/null || true
    rpc.nfsd 0 2>/dev/null || true
    exit 0
}

trap cleanup SIGTERM SIGINT

log "NFSv4 server is running"

wait "${MOUNTD_PID}"
cleanup
