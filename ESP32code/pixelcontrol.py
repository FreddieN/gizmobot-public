import machine, neopixel

np = neopixel.NeoPixel(machine.Pin(5), 17) #init neopixel strip

def setPixels(start,end,red,green,blue):
    #set a range of pixels from start to end to the desired RGB values provided in function parameters.
    for i in range(start,end):
        np[i] = (red,green,blue)
        #print("led updated")
    np.write()

