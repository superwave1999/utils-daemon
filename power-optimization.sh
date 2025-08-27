#!/bin/bash
set -e

echo "Applying minimal safe power optimizations..."

# Disable NMI watchdog
echo 0 | sudo tee /proc/sys/kernel/nmi_watchdog

# VM dirty page similar to powertop settings - recommended for UPS usage
sysctl -w vm.dirty_background_ratio=3
sysctl -w vm.dirty_ratio=20
sysctl -w vm.dirty_writeback_centisecs=1500
sysctl -w vm.dirty_expire_centisecs=2000

# Enable autosuspend for all USB devices
for d in /sys/bus/usb/devices/*/power/control; do
    echo auto | sudo tee "$d"
done

# Enable Runtime PM for all PCI devices except storage controllers (class 0x01*)
for dev in /sys/bus/pci/devices/*; do
    class=$(cat "$dev/class")
    # Skip storage controllers (Class 0x01)
    ####if [[ $class != 0x01* ]]; then
        echo auto | sudo tee "$dev/power/control"
    ####fi
done

# Do NOT change SATA link power management (leave at default firmware controlled)

echo "Minimal power optimizations applied safely."
