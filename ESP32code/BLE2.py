#CITATION: This code is adapted from Electronics 1 Car Project (Freddie Nicholson) which was originally adapted from David Boyle
#https://github.com/FreddieN/ESP32-MicroPython-Car 15 June 2023

##############################################################################
#
# This code allows you to easily control your ESP32 from the Bluefruit LE
# Connect app!
#
# You can find the download links for Apple or Google App stores here:
# https://learn.adafruit.com/bluefruit-le-connect/ios-setup
#
# Tested with uPy version 1.18
#
# Ensure that you change the name of your ESP32 below in line 102 from 'David's
# ESP32' to something else!
#
# Once you open the app, connect to your device. The code below allows you to
# send the message 'led' to the ESP32, which will toggle the on-board LED and
# reply to the app with current state.
#
# Experiment with the Controller in the app to understand the message formats
# sent (keep an eye on REPL in Mu and think about how to use these as
# control inputs!
#
# Read the ubluetooth docs here:
# https://docs.micropython.org/en/v1.15/library/ubluetooth.html
#
# DBoyle 08/06/2023
#
#############################################################################

from machine import Pin, Timer, SoftI2C, PWM, I2C
from time import sleep_ms
import ubluetooth
import time
#import our custom libraries allowing us to control the robot
import motorcontrol
import sensorcontrol
import json

import pixelcontrol

class BLE():
    def __init__(self, name):
        self.name = name
        self.ble = ubluetooth.BLE()
        self.ble.active(True)

# Change the pin from 2 to 25 to flash the white on-board LED while connected (using it below for another reason).
        self.led = Pin(2, Pin.OUT)
        self.timer1 = Timer(0)
        self.timer2 = Timer(1)

        self.disconnected()
        self.ble.irq(self.ble_irq)
        self.register()
        self.advertiser()
        #pixelcontrol.setPixels(0,17,255,0,0)

    def connected(self):
        self.timer1.deinit()
        self.timer2.deinit()
        pixelcontrol.setPixels(0,17,0,255,0) #when connected illuminate the neopixel ring green


    def disconnected(self):
        #pixelcontrol.setPixels(0,17,255,0,0)
        self.timer1.init(period=1000, mode=Timer.PERIODIC, callback=self.toggle_led)
        sleep_ms(200)
        self.timer2.init(period=1000, mode=Timer.PERIODIC, callback=self.toggle_led)

    def toggle_led(self):
        #when disconnected flash the neopixel ring blue
        if(self.led.value() == 1):
            self.led(0)
            pixelcontrol.setPixels(0,17,0,0,255)
        else:
            self.led(1)
            pixelcontrol.setPixels(0,17,0,0,0)

    def ble_irq(self, event, data):
        if event == 1:
            '''Central disconnected'''
            self.connected()
            self.led(1)

        elif event == 2:
            '''Central disconnected'''
            self.advertiser()
            self.disconnected()

        elif event == 3:
            '''New message received'''
            buffer = self.ble.gatts_read(self.rx)
            message = buffer.decode('UTF-8').strip()
            print(message)
            print(message[:4])
            if message[:4] == 'righ': #commands that call motor control to perform the desired functions
                print(message[4:])
                motorcontrol.right()
            if message[:4] == 'left':
                print(message[4:])
                motorcontrol.left()
            if message == 'back':
                motorcontrol.backward()
            if message == 'forward':
                motorcontrol.forward()
            if message == 'rotatecw':
                motorcontrol.rotatecw()
            if message == 'rotateacw':
                motorcontrol.rotateacw()
            if message == 'stop':
                motorcontrol.stop()
                print('stop')
            if message == 'led':
                led.value(not led.value())
                print('led', led.value())
                ble.send('led' + str(led.value()))
            if message == 'sensor':
                vals = sensorcontrol.get_sensors_vals()
                print('sensor', ' ', vals)
                ble.send('sensor'+' '+str(vals)) #send back the sensor values as a string for debug
            if message == 'status':
                sensor_vals = sensorcontrol.get_sensors_vals()
                motor_vals = motorcontrol.get_motor_status()
                ble.send('status'+' '+json.dumps({ #send back the current robot status as a json object for app screens
                "motors": motor_vals,
                "sensors": sensor_vals
                }
                ))
            if message[:5] == 'motor':
                # control a individual motor using the format 'motor (motorno) (speed) (direction);
                cmd = message.split(" ")
                print(int(cmd[1]), int(cmd[2]))
                motorcontrol.set_motor_speed(int(cmd[1]), int(cmd[2]))
                motorcontrol.set_motor_direction(int(cmd[1]), int(cmd[3]))
            if message[:5] == 'pixel':
                cmd = message.split(" ")
                #set a range of neopixels in format 'pixel (startpixel) (endpixel) (red) (green) (blue)'
                pixelcontrol.setPixels(int(cmd[1]),int(cmd[2]),int(cmd[3]),int(cmd[4]),int(cmd[5]))
            if message[:5] == 'speed':
                #set the overall speed of the robot
                print(message[5:])
                speed = int(float(message[5:8]))
                print(speed)
                motorcontrol.set_speed_multiplier(speed/100) #percent to decimal

    def register(self):
        NUS_UUID = '6E400001-B5A3-F393-E0A9-E50E24DCCA9E'
        RX_UUID = '6E400002-B5A3-F393-E0A9-E50E24DCCA9E'
        TX_UUID = '6E400003-B5A3-F393-E0A9-E50E24DCCA9E'

        BLE_NUS = ubluetooth.UUID(NUS_UUID)
        BLE_RX = (ubluetooth.UUID(RX_UUID), ubluetooth.FLAG_WRITE)
        BLE_TX = (ubluetooth.UUID(TX_UUID), ubluetooth.FLAG_NOTIFY)

        BLE_UART = (BLE_NUS, (BLE_TX, BLE_RX,))
        SERVICES = (BLE_UART, )
        ((self.tx, self.rx,), ) = self.ble.gatts_register_services(SERVICES)

    def send(self, data):
        self.ble.gatts_notify(0, self.tx, data + '\n')

    def advertiser(self):
        name = bytes(self.name, 'UTF-8')
        self.ble.gap_advertise(100, bytearray('\x02\x01\x02') + bytearray((len(name) + 1, 0x09)) + name)

# You should change this line of code to name your own ESP32 - otherwise, chaos! :)
ble = BLE("Freddies ESP32")
while True:
    #whilst running always be checking if we need to step a motor
    motorcontrol.motor_eval()
