#!/usr/bin/env python3
import configparser
import subprocess
import time
import os
import sys
import signal
import RPi.GPIO as GPIO

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
STEP = getint('VOLUME', 'step_percent', fallback=5)
HOLD = getint('POWER', 'hold_seconds', fallback=2)

shutdown_in_progress = False
_power_press_time = None

GPIO.setmode(GPIO.BCM)
GPIO.setup(A_PIN, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(B_PIN, GPIO.IN, pull_up_down=GPIO.PUD_UP)
for p in (SW_PIN, BTN_PREV, BTN_NEXT, BTN_PLAY, BTN_POWER, ACC_PIN):
    GPIO.setup(p, GPIO.IN, pull_up_down=GPIO.PUD_UP)


def change_volume(delta_percent):
    if delta_percent >= 0:
        arg = f'+{int(delta_percent)}%'
    else:
        arg = f'-{int(abs(delta_percent))}%'
    subprocess.run(['pactl', 'set-sink-volume', '@DEFAULT_SINK@', arg])


def playerctl(cmd):
    subprocess.run(['playerctl', cmd])


def safe_shutdown():
    global shutdown_in_progress
    if shutdown_in_progress:
        return
    shutdown_in_progress = True
    time.sleep(0.2)
    subprocess.run(['systemctl', 'poweroff'])


def on_rotate_a(channel):
    if GPIO.input(B_PIN) == GPIO.LOW:
        change_volume(STEP)
    else:
        change_volume(-STEP)


def on_rotate_b(channel):
    if GPIO.input(A_PIN) == GPIO.HIGH:
        change_volume(STEP)
    else:
        change_volume(-STEP)


def btn_prev_cb(channel):
    playerctl('previous')


def btn_next_cb(channel):
    playerctl('next')


def btn_play_cb(channel):
    playerctl('play-pause')


def power_pressed(channel):
    global _power_press_time
    _power_press_time = time.time()


def power_released(channel):
    global _power_press_time
    if _power_press_time is None:
        return
    elapsed = time.time() - _power_press_time
    _power_press_time = None
    if elapsed >= HOLD:
        safe_shutdown()


def acc_off_cb(channel):
    safe_shutdown()


GPIO.add_event_detect(A_PIN, GPIO.RISING, callback=on_rotate_a, bouncetime=5)
GPIO.add_event_detect(B_PIN, GPIO.RISING, callback=on_rotate_b, bouncetime=5)
GPIO.add_event_detect(BTN_PREV, GPIO.FALLING, callback=btn_prev_cb, bouncetime=200)
GPIO.add_event_detect(BTN_NEXT, GPIO.FALLING, callback=btn_next_cb, bouncetime=200)
GPIO.add_event_detect(BTN_PLAY, GPIO.FALLING, callback=btn_play_cb, bouncetime=200)
GPIO.add_event_detect(BTN_POWER, GPIO.FALLING, callback=power_pressed, bouncetime=200)
GPIO.add_event_detect(BTN_POWER, GPIO.RISING, callback=power_released, bouncetime=200)
GPIO.add_event_detect(ACC_PIN, GPIO.FALLING, callback=acc_off_cb, bouncetime=500)


def cleanup(signum=None, frame=None):
    GPIO.cleanup()
    sys.exit(0)

signal.signal(signal.SIGINT, cleanup)
signal.signal(signal.SIGTERM, cleanup)

if __name__ == '__main__':
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        cleanup()
