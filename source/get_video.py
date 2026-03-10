from djitellopy import Tello 
import cv2 

tello = Tello()
tello.connect()

tello.streamon()

frame_read = tello.get_frame_read()

while True: 
    frame = frame_read.frame
    cv2.imshow("Tello", frame)

    if cv2.waitKey(1) & 0xFF == 27: 
        break