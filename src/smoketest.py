#!/usr/bin/env python3
import subprocess
import json
import os
import sys
import datetime

LOGFILE = '/var/log/pi_headunit_smoketest.json'

def run(cmd):
    try:
        p = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        return {'rc': p.returncode, 'out': p.stdout.strip(), 'err': p.stderr.strip()}
    except Exception as e:
        return {'rc': 1, 'out': '', 'err': str(e)}

def check_service(name):
    r = run(['systemctl', 'is-active', name])
    active = (r['rc'] == 0 and 'active' in r['out'])
    return {'name': name, 'active': active, 'raw': r}

def check_pactl_sinks():
    r = run(['pactl', 'list', 'short', 'sinks'])
    sinks = r['out'].splitlines() if r['out'] else []
    return {'count': len(sinks), 'sinks': sinks, 'raw': r}

def check_lsusb():
    r = run(['lsusb'])
    return {'raw': r}

def check_gpio_probe():
    probe = '/opt/pi_headunit/src/gpio_probe.py'
    if not os.path.exists(probe):
        return {'exists': False, 'err': 'missing probe script', 'path': probe}
    r = run(['python3', probe])
    return {'exists': True, 'rc': r['rc'], 'out': r['out'], 'err': r['err']}


def main():
    results = {}
    fails = 0
    results['time'] = datetime.datetime.now().isoformat()

    # services
    services = ['pi_headunit', 'bluetooth']
    results['services'] = {}
    for s in services:
        r = check_service(s)
        results['services'][s] = r
        if not r['active']:
            fails += 1

    # sinks
    results['sinks'] = check_pactl_sinks()
    if results['sinks']['count'] == 0:
        fails += 1

    # lsusb
    results['lsusb'] = check_lsusb()

    # gpio probe
    results['gpio_probe'] = check_gpio_probe()
    if results['gpio_probe'].get('exists') and results['gpio_probe'].get('rc', 1) != 0:
        fails += 1

    # write log
    try:
        with open(LOGFILE, 'a') as f:
            f.write(json.dumps(results) + "\n")
    except Exception:
        pass

    print(json.dumps(results, indent=2))
    sys.exit(fails)

if __name__ == '__main__':
    main()
