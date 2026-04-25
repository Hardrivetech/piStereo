#!/usr/bin/env python3
"""Simple fullscreen now-playing display using playerctl (polling).
Requires: playerctl, python3-tk (for GUI)
Run: python3 src/display_now_playing.py
"""
import subprocess
import time
import tkinter as tk

POLL_INTERVAL = 1.0


def get_now_playing():
    try:
        out = subprocess.check_output(['playerctl', 'metadata', '--format', '{{artist}} - {{title}}'], text=True)
        return out.strip() or None
    except subprocess.CalledProcessError:
        return None
    except FileNotFoundError:
        return None


class NowPlayingApp:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title('Now Playing')
        self.root.attributes('-fullscreen', True)
        self.label = tk.Label(self.root, text='No playback', font=('Sans', 36), wraplength=1200, justify='center')
        self.label.pack(expand=True)
        self.update_loop()

    def update_loop(self):
        meta = get_now_playing()
        if meta:
            self.label.config(text=meta)
        else:
            self.label.config(text='No playback')
        self.root.after(int(POLL_INTERVAL * 1000), self.update_loop)

    def run(self):
        self.root.mainloop()


if __name__ == '__main__':
    app = NowPlayingApp()
    app.run()
