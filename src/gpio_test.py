#!/usr/bin/env python3
import configparser
import os
import sys
import time

CONFIG_PATHS = ['/etc/pi_headunit/config.ini', os.path.join(os.path.dirname(__file__), '..', 'config', 'config.ini')]
cfg = configparser.ConfigParser()
found = cfg.read(CONFIG_PATHS)
if not found:
    print('No config found in:', CONFIG_PATHS)
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
    print('RPi.GPIO not available:', e)
    sys.exit(1)

GPIO.setmode(GPIO.BCM)
GPIO.setup(A_PIN, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(B_PIN, GPIO.IN, pull_up_down=GPIO.PUD_UP)
for p in (SW_PIN, BTN_PREV, BTN_NEXT, BTN_PLAY, BTN_POWER, ACC_PIN):
    GPIO.setup(p, GPIO.IN, pull_up_down=GPIO.PUD_UP)

print('Reading GPIO states. Ctrl-C to exit.')
try:
    while True:
        states = {
            'A': GPIO.input(A_PIN),
            'B': GPIO.input(B_PIN),
            'SW': GPIO.input(SW_PIN),
            'PREV': GPIO.input(BTN_PREV),
            'NEXT': GPIO.input(BTN_NEXT),
            'PLAY': GPIO.input(BTN_PLAY),
            'PWR': GPIO.input(BTN_POWER),
            'ACC': GPIO.input(ACC_PIN),
        }
        print(' | '.join(f"{k}:{v}" for k, v in states.items()), end='\r')
        time.sleep(0.2)
except KeyboardInterrupt:
    print('\nExiting.')
finally:
    GPIO.cleanup()
