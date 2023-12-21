#CITATION: This code is adapted from Electronics 1 Car Project (Freddie Nicholson) which was originally adapted from David Boyle
#https://github.com/FreddieN/ESP32-MicroPython-Car 15 June 2023

#Prototyping code for what was developed as 'radar' mode in the app

import pygame
from pygame.locals import *
import json
from time import sleep

import asyncio
from bleak import BleakScanner, BleakClient

sensor_vals = [999,999,999,999]

work_sensor_vals = []

async def scan():
    scanner = BleakScanner()
    devices = await scanner.discover()
    return devices

async def connect(device):
    async with BleakClient(device) as client:
        characteristics = await client.get_services()

        command = f"speed100".encode()  
        await client.write_gatt_char("6E400002-B5A3-F393-E0A9-E50E24DCCA9E", command, response=True)
        print("Command sent successfully.")

        await client.start_notify("6E400003-B5A3-F393-E0A9-E50E24DCCA9E", data_receive)
        for i in range(12): #this code spins the robot 90 degrees over 12 ticks allowing it to join all the data together creating a radar plot.
            command = "rotatecw".encode()  
            await client.write_gatt_char("6E400002-B5A3-F393-E0A9-E50E24DCCA9E", command, response=True)
            print("Command sent successfully.")
            sleep(0.01)
            command = "sensor".encode()  
            await client.write_gatt_char("6E400002-B5A3-F393-E0A9-E50E24DCCA9E", command, response=True)
            print("Command sent successfully.")
            command = "stop".encode()  
            await client.write_gatt_char("6E400002-B5A3-F393-E0A9-E50E24DCCA9E", command, response=True)
            print("Command sent successfully.")
            sleep(1)
        with open('results', 'w') as file:
            file.write(str(work_sensor_vals)) #write out the results to be handled by another scripts (resultsprocess.py)
async def data_receive(sender, data):
    global sensor_vals #code that receives the output from the sensor command when the sensor button is pressed reading the values out of each sensor.
    global work_sensor_vals
    received_data = data.decode()
    print(f"RX: {received_data}")
    data_split = received_data.split(" ")
    if(data_split[0] == 'sensor'):
        sensor_vals = json.loads(received_data[7:-1:])
        work_sensor_vals.append(sensor_vals)
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