#!/usr/bin/env python3
import os
import sys
import time
import re
import shutil
import logging
import subprocess
import configparser

# Polling monitor that starts/stops a systemd service when a phone is connected.
# Detection methods (in order): adb devices, simple MTP probe, lsusb vendor ID match.

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
CONFIG_CANDIDATES = [
    '/etc/pi_headunit/openauto.conf',
    os.path.join(REPO_ROOT, 'config', 'openauto.conf')
]
DEFAULTS = {
    'service_name': 'openauto.service',
    'check_interval': '2',
    'vendor_ids': '18d1,04e8,12d1,0bb4,2a70,2a47,22d9,2b7c'
}


def run_cmd(cmd):
    try:
        return subprocess.check_output(cmd, stderr=subprocess.STDOUT, text=True)
    except subprocess.CalledProcessError as e:
        return e.output
    except Exception:
        return ''


def load_config():
    cfg = configparser.ConfigParser()
    for p in CONFIG_CANDIDATES:
        if os.path.exists(p):
            cfg.read(p)
            break
    else:
        cfg['openauto'] = DEFAULTS
    c = cfg['openauto']
    service = c.get('service_name', DEFAULTS['service_name']).strip()
    interval = int(c.get('check_interval', DEFAULTS['check_interval']))
    vendor_ids = [v.strip().lower() for v in c.get('vendor_ids', DEFAULTS['vendor_ids']).split(',') if v.strip()]
    return service, interval, vendor_ids


def lsusb_vendor_ids():
    out = run_cmd(['lsusb'])
    ids = []
    for line in out.splitlines():
        m = re.search(r'ID\s+([0-9a-fA-F]{4}):([0-9a-fA-F]{4})', line)
        if m:
            ids.append(m.group(1).lower())
    return ids


def adb_has_device():
    adb = shutil.which('adb')
    if not adb:
        return False
    try:
        out = run_cmd([adb, 'devices'])
        lines = [l.strip() for l in out.splitlines() if l.strip()]
        if len(lines) <= 1:
            return False
        for l in lines[1:]:
            # lines look like: <serial>\tdevice
            if '\tdevice' in l and not l.endswith('offline'):
                return True
    except Exception:
        return False
    return False


def mtp_has_device():
    mtpdetect = shutil.which('mtp-detect')
    if not mtpdetect:
        return False
    try:
        out = run_cmd([mtpdetect])
        if out and ('Manufacturer:' in out or 'Device 0:' in out):
            return True
    except Exception:
        return False
    return False


def is_phone_connected(vendor_ids):
    # Fast checks
    if adb_has_device():
        return True
    if mtp_has_device():
        return True
    usb_ids = lsusb_vendor_ids()
    for vid in usb_ids:
        if vid in vendor_ids:
            return True
    return False


def service_is_active(name):
    rc = subprocess.call(['systemctl', 'is-active', '--quiet', name])
    return rc == 0


def start_service(name):
    subprocess.call(['systemctl', 'start', name])


def stop_service(name):
    subprocess.call(['systemctl', 'stop', name])


if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)s: %(message)s', datefmt='%Y-%m-%d %H:%M:%S')
    service_name, interval, vendor_ids = load_config()
    logging.info('Starting OpenAuto monitor: service=%s interval=%ss vendor_ids=%s', service_name, interval, vendor_ids)
    try:
        while True:
            try:
                present = is_phone_connected(vendor_ids)
                active = service_is_active(service_name)
                if present and not active:
                    logging.info('Phone detected — starting %s', service_name)
                    start_service(service_name)
                elif not present and active:
                    logging.info('No phone present — stopping %s', service_name)
                    stop_service(service_name)
            except Exception:
                logging.exception('Loop error')
            time.sleep(interval)
    except KeyboardInterrupt:
        logging.info('Monitor exiting')
