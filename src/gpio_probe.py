#!/usr/bin/env python3
import configparser
import os
import sys
import json

CONFIG_PATHS = ['/etc/pi_headunit/config.ini', os.path.join(os.path.dirname(__file__), '..', 'config', 'config.ini')]
cfg = configparser.ConfigParser()
found = cfg.read(CONFIG_PATHS)
if not found:
    print(json.dumps({'error': 'config not found', 'paths': CONFIG_PATHS}))
    sys.exit(1)

def getint(section, key, fallback=0):
    try:
        return cfg.getint(section, key)
    except Exception:
        return fallback

A_PIN = getint('GPIO', 'vol_encoder_a')
B_PIN = getint('GPIO', 'vol_encoder_b')
SW_PIN = getint('GPIO', 'vol_switch')
BTN_PREV = getint('GPIO', 'btn_prev')
BTN_NEXT = getint('GPIO', 'btn_next')
BTN_PLAY = getint('GPIO', 'btn_play')
BTN_POWER = getint('GPIO', 'btn_power')
ACC_PIN = getint('GPIO', 'acc_sense')

try:
    import RPi.GPIO as GPIO
except Exception as e:
    print(json.dumps({'error': 'RPi.GPIO import failed', 'exception': str(e)}))
    sys.exit(2)

GPIO.setmode(GPIO.BCM)
try:
    pins = [A_PIN, B_PIN, SW_PIN, BTN_PREV, BTN_NEXT, BTN_PLAY, BTN_POWER, ACC_PIN]
    for p in pins:
        GPIO.setup(p, GPIO.IN, pull_up_down=GPIO.PUD_UP)

    state = {
        'A': int(GPIO.input(A_PIN)),
        'B': int(GPIO.input(B_PIN)),
        'SW': int(GPIO.input(SW_PIN)),
        'PREV': int(GPIO.input(BTN_PREV)),
        'NEXT': int(GPIO.input(BTN_NEXT)),
        'PLAY': int(GPIO.input(BTN_PLAY)),
        'PWR': int(GPIO.input(BTN_POWER)),
        'ACC': int(GPIO.input(ACC_PIN)),
    }
    print(json.dumps({'ok': True, 'states': state}))
    sys.exit(0)
finally:
    GPIO.cleanup()
