#CITATION: This code is adapted from Electronics 1 Car Project (Freddie Nicholson) which was originally adapted from David Boyle
#https://github.com/FreddieN/ESP32-MicroPython-Car 15 June 2023

#Prototyping code for using a nintendo switch controller to control the robot

import pygame
from pygame.locals import *
import json

import asyncio
from bleak import BleakScanner, BleakClient

async def scan():
    scanner = BleakScanner()
    devices = await scanner.discover()
    return devices

async def connect(device):
    async with BleakClient(device) as client:
        speed = 25

        characteristics = await client.get_services()
        pygame.init()

        await client.start_notify("6E400003-B5A3-F393-E0A9-E50E24DCCA9E", data_receive)
        
        async def set_speed(speed1):
            #code to send the speed provided in the right format
            speed_format = str(speed1).zfill(3)
            command = f"speed{speed_format}".encode()  
            await client.write_gatt_char("6E400002-B5A3-F393-E0A9-E50E24DCCA9E", command, response=True)
            print("Command sent successfully.")

        screen = pygame.display.set_mode((400, 300))
        pygame.display.set_caption("Bot Controller")

        clock = pygame.time.Clock()
        running = True

        pygame.joystick.init()
        joystick_count = pygame.joystick.get_count()
        if joystick_count == 0:
            print("No controllers found!")
            running = False
        else:
            joystick = pygame.joystick.Joystick(0)
            joystick.init()
            print("Initialized controller:", joystick.get_name())

        while running:
            for event in pygame.event.get():
                if event.type == QUIT:
                    running = False

                elif event.type == JOYBUTTONDOWN:
                    button = event.button
                    if(button == 1):
                        command = "forward".encode()  #send a command to the ESP32 via BLE based on a button press on the controller
                        await client.write_gatt_char("6E400002-B5A3-F393-E0A9-E50E24DCCA9E", command, response=True)
                        print("Command sent successfully.")
                    if(button == 0):
                        command = "back".encode()  
                        await client.write_gatt_char("6E400002-B5A3-F393-E0A9-E50E24DCCA9E", command, response=True)
                        print("Command sent successfully.")
                    if(button == 2):
                        command = "sensor".encode()  
                        await client.write_gatt_char("6E400002-B5A3-F393-E0A9-E50E24DCCA9E", command, response=True)
                        print("Command sent successfully.")
                    if(button == 11):
                        command = "forward".encode()  
                        await client.write_gatt_char("6E400002-B5A3-F393-E0A9-E50E24DCCA9E", command, response=True)
                        print("Command sent successfully.")
                    if(button == 12):
                        command = "back".encode()  
                        await client.write_gatt_char("6E400002-B5A3-F393-E0A9-E50E24DCCA9E", command, response=True)
                        print("Command sent successfully.")
                    if(button == 13):
                        command = "left000".encode()  
                        await client.write_gatt_char("6E400002-B5A3-F393-E0A9-E50E24DCCA9E", command, response=True)
                        print("Command sent successfully.")
                    if(button == 14):
                        command = "righ000".encode()  
                        await client.write_gatt_char("6E400002-B5A3-F393-E0A9-E50E24DCCA9E", command, response=True)
                        print("Command sent successfully.")
                    if(button == 9):
                        command = "rotateacw".encode()  
                        await client.write_gatt_char("6E400002-B5A3-F393-E0A9-E50E24DCCA9E", command, response=True)
                        print("Command sent successfully.")
                    if(button == 10):
                        command = "rotatecw".encode()  
                        await client.write_gatt_char("6E400002-B5A3-F393-E0A9-E50E24DCCA9E", command, response=True)
                        print("Command sent successfully.")
                    if(button == 4):
                        if(speed != 0):
                            speed-=10 #adjust the speed based on the +/- buttons on the controller
                        await set_speed(speed)
                        print(f"Speed: {speed}")
                    if(button == 6):
                        if(speed != 100):
                            speed+=10
                        await set_speed(speed)
                        print(f"Speed: {speed}")
                    print("Button {} pressed".format(button))
                elif event.type == JOYBUTTONUP: #cite: https://www.pygame.org/docs/ref/joystick.html
                    button = event.button
                    if(button != 2):
                        command = "stop".encode()  
                        await client.write_gatt_char("6E400002-B5A3-F393-E0A9-E50E24DCCA9E", command, response=True)
                        print("Command sent successfully.")

                    print("Button {} released".format(button))
                elif event.type == JOYHATMOTION:
                    hat = event.hat
                    value = event.value
                    print("Hat {} moved to {}".format(hat, value))

            screen.fill((255, 255, 255))

            pygame.display.flip()

            clock.tick(60)

        pygame.quit()
        
async def data_receive(sender, data):
    received_data = data.decode()
    print(f"RX: {received_data}") #code that receives the output from the sensor command when the sensor button is pressed reading the values out of each sensor.
    data_split = received_data.split(" ")
    if(data_split[0] == 'sensor'):
        sensor_vals = json.loads(received_data[7:-1:])
        print(sensor_vals)
        print(f'S4 (back): {sensor_vals[1]}')
        print(f'S3 (right): {sensor_vals[0]}')
        print(f'S2 (front): {sensor_vals[3]}')
        print(f'S1 (left): {sensor_vals[2]}')

async def main():
    devices = await scan()

    for device in devices:
        if device.address == '0AEF32C3-A61F-4E2C-6CD5-4816BD50888F':
            await connect(device)
            break

loop = asyncio.get_event_loop()
loop.run_until_complete(main())