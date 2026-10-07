#!/usr/bin/env bash

set -u

iommu_root="/sys/kernel/iommu_groups"

if [ ! -d "$iommu_root" ]; then
  echo "No IOMMU groups were found in $iommu_root"
  echo "Check that the kernel and system configuration have IOMMU enabled."
  exit 1
fi

echo "Available IOMMU groups:"
echo

for group in "$iommu_root"/*; do
  [ -d "$group" ] || continue

  group_id=$(basename "$group")
  echo "=== IOMMU Group $group_id ==="

  devices=0
  for dev in "$group"/devices/*; do
    [ -e "$dev" ] || continue
    bdf=$(basename "$dev")
    desc=$(lspci -s "$bdf" 2>/dev/null || true)

    if [ -n "$desc" ]; then
      echo "  $bdf  ->  $desc"
      devices=$((devices + 1))
    else
      echo "  $bdf"
      devices=$((devices + 1))
    fi
  done

  if [ "$devices" -eq 0 ]; then
    echo "  No PCI devices associated"
  fi

  echo
done
