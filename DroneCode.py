#CITATION: This code is adapted from Electronics 1 Car Project (Freddie Nicholson) which was originally adapted from David Boyle
#https://github.com/FreddieN/ESP32-MicroPython-Car 15 June 2023

#Prototyping code for what was developed as 'roam mode' in the app

import pygame
from pygame.locals import *
import json
from time import sleep

import asyncio
from bleak import BleakScanner, BleakClient

sensor_vals = [999,999,999,999] #init sensor values with large values t

async def scan():
    scanner = BleakScanner()
    devices = await scanner.discover()
    return devices

async def connect(device):
    async with BleakClient(device) as client:
        characteristics = await client.get_services()

        command = f"speed075".encode()  #slow down speed to avoid injury
        await client.write_gatt_char("6E400002-B5A3-F393-E0A9-E50E24DCCA9E", command, response=True)
        print("Command sent successfully.")

        await client.start_notify("6E400003-B5A3-F393-E0A9-E50E24DCCA9E", data_receive)
        direction = "forward"
        while True: #while running check sensor values and then perform actions based upon them
            command = "sensor".encode()  
            await client.write_gatt_char("6E400002-B5A3-F393-E0A9-E50E24DCCA9E", command, response=True)
            print("Command sent successfully.")

            dir_matrix = ['back', 'rotatecw', 'rotateacw', 'forward'] #matrix of each direction dependent on which sensor is reading furthest distance
            direction = sensor_vals.index(max(sensor_vals)) #work out which one has max value
            if(sensor_vals[3]>800): # if forward sensor is greater than 800mm then head forwards
                command = 'forward'.encode()  
                await client.write_gatt_char("6E400002-B5A3-F393-E0A9-E50E24DCCA9E", command, response=True)
                print("Command sent successfully.")
            elif(sensor_vals[direction] > 400 ): # if other sensor is greater than 400mm then head in that direction
                print(dir_matrix[direction])
                command = dir_matrix[direction].encode()  
                await client.write_gatt_char("6E400002-B5A3-F393-E0A9-E50E24DCCA9E", command, response=True)
                print("Command sent successfully.")
            sleep(1)
            command = "stop".encode()  #stop after 1 second
            await client.write_gatt_char("6E400002-B5A3-F393-E0A9-E50E24DCCA9E", command, response=True)
            print("Command sent successfully.")
            
        
async def data_receive(sender, data):
    global sensor_vals #code that receives the output from the sensor command when the sensor button is pressed reading the values out of each sensor.
    received_data = data.decode()
    print(f"RX: {received_data}")
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