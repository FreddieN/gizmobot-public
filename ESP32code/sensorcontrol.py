#citation: https://github.com/kevinmcaleer/vl53l0x/blob/master/tof_test.py / https://www.az-delivery.uk/blogs/azdelivery-blog-fur-arduino-und-raspberry-pi/digitales-theremin-mit-esp32-in-micropython
print("sensorcontrol_loaded")
from machine import Pin, I2C
import vl53l0x as VL53L0X

print("setting up i2c")
sda = Pin(21)
scl = Pin(22)

i2c = I2C(sda=sda, scl=scl)


addr = [b'\x04',b'\x08',b'\x10',b'\x20'] #multiplexer tof addresses for each sensor
def get_sensors_vals():
    vals = [-1,-1,-1,-1] #init sensor vals array to -1,-1,-1,-1
    for i, address in enumerate(addr):
        i2c.writeto(0x70, address) #write to address what sensor we want to read
        tof = VL53L0X.VL53L0X(i2c)
        tof.set_Vcsel_pulse_period(tof.vcsel_period_type[0], 18) #set period of pulses for ToF sensors
        tof.set_Vcsel_pulse_period(tof.vcsel_period_type[1], 14)
        tof.start()
        # Start ranging
        tof.read()
        vals[i]=tof.read() #read in ToF values
    return (vals) #return sensor values
