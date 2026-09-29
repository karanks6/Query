import pygetwindow as gw
import pyautogui
import time
import sys
import os

try:
    windows = gw.getWindowsWithTitle('query')
    if not windows:
        print("No window found")
        sys.exit(1)

    # find the exact window (could be query, or query - Flutter)
    win = None
    for w in windows:
        if 'query' in w.title.lower():
            win = w
            break
            
    if not win:
        print("No window found")
        sys.exit(1)

    win.restore()
    win.activate()
    # Move to top left and resize to typical mobile aspect ratio
    win.moveTo(10, 10)
    win.resizeTo(400, 850) # includes window borders
    time.sleep(2) # wait for flutter to re-layout and render

    # Take screenshot of the exact window region
    # add small margin for border
    screenshot = pyautogui.screenshot(region=(win.left + 8, win.top + 30, win.width - 16, win.height - 38))
    
    out_path = "C:/Users/user/.gemini/antigravity-ide/brain/4a324842-4df8-4c8c-805e-7e7654b83db5/mobile_app_screenshot.png"
    screenshot.save(out_path)
    print(f"Screenshot saved to {out_path}")
    
except Exception as e:
    print(f"Error: {e}")
