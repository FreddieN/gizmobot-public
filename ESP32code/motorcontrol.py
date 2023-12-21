print("motor control loaded")
from machine import Pin
from time import sleep_us, sleep
from utime import ticks_us

def monotonic_us(): #cite: https://github.com/Rybec/pyRTOS/issues/9 29/11/23
    return ticks_us()

dir1 = Pin(13, Pin.OUT) #setup stepper drivers pinout
step1 = Pin(12, Pin.OUT)
dir2 = Pin (14, Pin.OUT)
step2 = Pin(27, Pin.OUT)
dir3 = Pin(26, Pin.OUT)
step3 = Pin(25, Pin.OUT)
dir4 = Pin(33, Pin.OUT)
step4 = Pin(32, Pin.OUT)

def motor_rpm_to_us(rpm):
    if(rpm!=0): 
        return int(45000000/(rpm*200)) #convert provided rpm into a microseconds per tick
    else:
        return 99999999

step1rpm = 0 #global variables for real time control of motors speed and direction
step2rpm = 0
step3rpm = 0
step4rpm = 0
step1direction = 0
step2direction = 1
step3direction = 0
step4direction = 1
step1lasttick = -1
step2lasttick = -1
step3lasttick = -1
step4lasttick = -1

overall_speed_multiplier = 1 #overall speed of motors from 0 to 1

def set_speed_multiplier(speed_multiplier): #set speed of motors
    global overall_speed_multiplier
    overall_speed_multiplier = speed_multiplier


def backward(): #functions for each direction setting desired speeds and direction to obtain the required movement
    global step1direction
    global step2direction
    global step3direction
    global step4direction
    global step1rpm
    global step2rpm
    global step3rpm
    global step4rpm


    step1direction = 1
    step2direction = 1
    step3direction = 1
    step4direction = 1

    step1rpm = 450 # front left
    step2rpm = 0
    step3rpm = 450 # front right
    step4rpm = 0 #back

def forward():
    global step1direction
    global step2direction
    global step3direction
    global step4direction
    global step1rpm
    global step2rpm
    global step3rpm
    global step4rpm

    step1direction = 0
    step2direction = 1
    step3direction = 0
    step4direction = 1

    step1rpm = 450 # front left
    step2rpm = 0
    step3rpm = 450 # front right
    step4rpm = 0 #back

def rotatecw():
    global step1direction
    global step2direction
    global step3direction
    global step4direction
    global step1rpm
    global step2rpm
    global step3rpm
    global step4rpm

    step1direction = 0
    step2direction = 1
    step3direction = 1
    step4direction = 1

    step1rpm = 450 # front left
    step2rpm = 0
    step3rpm = 450 # front right
    step4rpm = 450 #back

def rotateacw():
    global step1direction
    global step2direction
    global step3direction
    global step4direction
    global step1rpm
    global step2rpm
    global step3rpm
    global step4rpm

    step1direction = 1
    step2direction = 1
    step3direction = 0
    step4direction = 0

    step1rpm = 450 # front left
    step2rpm = 0
    step3rpm = 450 # front right
    step4rpm = 450 #back

def left():
    global step1direction
    global step2direction
    global step3direction
    global step4direction
    global step1rpm
    global step2rpm
    global step3rpm
    global step4rpm

    step1direction = 1
    step2direction = 1
    step3direction = 0
    step4direction = 1

    step1rpm = 250 # front left
    step2rpm = 0
    step3rpm = 250 # front right
    step4rpm = 450 #back

def right():
    global step1direction
    global step2direction
    global step3direction
    global step4direction
    global step1rpm
    global step2rpm
    global step3rpm
    global step4rpm

    step1direction = 0
    step2direction = 0
    step3direction = 1
    step4direction = 0

    step1rpm = 250 # front left
    step2rpm = 0
    step3rpm = 250 # front right
    step4rpm = 450 #back

def stop():
    global step1direction
    global step2direction
    global step3direction
    global step4direction
    global step1rpm
    global step2rpm
    global step3rpm
    global step4rpm

    step1direction = 0
    step2direction = 0
    step3direction = 0
    step4direction = 0
    step1rpm = 0 # front left
    step2rpm = 0
    step3rpm = 0 # front right
    step4rpm = 0 #back

def get_motor_status():
    #function that returns the current motor status
    global step1direction
    global step2direction
    global step3direction
    global step4direction
    global step1rpm
    global step2rpm
    global step3rpm
    global step4rpm
    return {
    "direction": [step1direction, step2direction, step3direction,step4direction],
    "rpm": [step1rpm, step2rpm, step3rpm,step4rpm]
    }

def check_motor_spin():
    #function that checks whether we should be stepping a motor
    global step1lasttick
    global step2lasttick
    global step3lasttick
    global step4lasttick


    if(step1rpm):

        if(monotonic_us() - step1lasttick > motor_rpm_to_us(step1rpm*overall_speed_multiplier)): #check how long it has been since the last tick of this motor if it has been long enough then we can step the motor
            step1lasttick = monotonic_us()
            if(step1.value()):
                step1.off()
            else:
                step1.on()
    if(step2rpm):

        if(monotonic_us() - step2lasttick > motor_rpm_to_us(step2rpm*overall_speed_multiplier)):
            step2lasttick = monotonic_us()
            if(step2.value()):
                step2.off()
            else:
                step2.on()
    if(step3rpm):

            if(monotonic_us() - step3lasttick > motor_rpm_to_us(step3rpm*overall_speed_multiplier)):
                step3lasttick = monotonic_us()
                if(step3.value()):
                    step3.off()
                else:
                    step3.on()
    if(step4rpm):

        if(monotonic_us() - step4lasttick > motor_rpm_to_us(step4rpm*overall_speed_multiplier)):
            step4lasttick = monotonic_us()
            if(step4.value()):
                step4.off()
            else:
                step4.on()

def set_motor_speed(motor, rpm):
    #sets the speed of a specific motor
    global step1rpm
    global step2rpm
    global step3rpm
    global step4rpm

    if(motor == 0):
        step1rpm = rpm
    if(motor == 1):
        step2rpm = rpm
    if(motor == 2):
        step3rpm = rpm
    if(motor == 3):
        step4rpm = rpm

def set_motor_direction(motor, direction):
    #sets the direction of a specific motor
    global step1direction
    global step2direction
    global step3direction
    global step4direction

    if(motor == 0):
        step1direction = direction
    if(motor == 1):
        step2direction = direction
    if(motor == 2):
        step3direction = direction
    if(motor == 3):
        step4direction = direction

def motor_eval():
    #evaluates whether we need to swap the direction of a motor and runs the logic to check whether we need to step a motor
    if(step1direction):
        dir1.on()
    else:
        dir1.off()
    if(step2direction):
        dir2.on()
    else:
        dir2.off()
    if(step3direction):
        dir3.on()
    else:
        dir3.off()
    if(step4direction):
        dir4.on()
    else:
        dir4.off()

    check_motor_spin()

#init motors variables
step1rpm = 1 # front left
step2rpm = 1
step3rpm = 1 # front right
step4rpm = 1 #back

#while True:
#    for i in range(200):
#        right()
#    sleep(2);
#    stop()
#    sleep(2)
