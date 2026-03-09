from pynput import keyboard 

def on_press(key): 
    print("Preesed:", key)

with keyboard.Listener(on_press=on_press) as listener: 
    listener.join()