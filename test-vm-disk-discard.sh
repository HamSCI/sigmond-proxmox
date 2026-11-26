#!/bin/bash
# test-vm-disk-discard.sh — first boot attaches the decoder disk with discard=on.
# Without it QEMU drops the guest's trims, and every block the guest ever wrote
# stays allocated in the thin pool: B4 (2026-11-26) held 246 GiB in the pool
# for a guest using 195 GiB, and the pool crossed pm-storage's 70 % snapshot cap.
set -u
cd "$(dirname "$0")" || exit 1
F="${1:-firstboot-v3.sh}"
PASS=0; FAIL=0
ok(){ PASS=$((PASS+1)); echo "  ok    $*"; }
bad(){ FAIL=$((FAIL+1)); echo "  FAIL  $*"; }
bash -n "$F" || { echo "FATAL: $F does not parse"; exit 1; }
attach=$(grep -E 'qm set "\$VMID" --scsi0 ' "$F")
[ "$(grep -cE 'qm set "\$VMID" --scsi0 ' "$F")" -eq 1 ] && ok "one place attaches scsi0" || bad "scsi0 attached in $(grep -cE 'qm set "\$VMID" --scsi0 ' "$F") places"
grep -q -- '--scsi0 "$DISK,discard=on,ssd=1"' <<<"$attach" && ok "scsi0 carries discard=on,ssd=1" || bad "scsi0 attached without discard=on,ssd=1: $attach"
echo; echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
