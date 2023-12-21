//
//  ContentView.swift
//  Gizmo
//
//  Created by Freddie Nicholson on 30/11/2023.
//
//CITATION: This code is adapted from example code: https://github.com/BeauNouvelle/BluetoothReader 30/11/23

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var bluetoothService: BluetoothService
    @State var recording: Bool = false // whether we are currently recording used for UI
    @State var speed: Double = 100 // current speed state variable
    @State var ledColor: Color = Color(.sRGB, red: 0, green: 1, blue: 0) // current LED strip colour state variable
    
    var body: some View {
            
            VStack {
                VStack() {
                    Spacer()
                    VStack() {
                        Text("Speed: \(String(speed))").padding()
                        Slider(value: $speed, in: 0.0...100, step: 1.0) { editing in
                            print("change")
                            bluetoothService.sendData(dataToSend: "speed\(String(format: "%03.0f", speed))") // transmit the speed data from the slider state variable in required format
                        }
                    }.padding(40)
                    HStack() {
                        Button(action: {}) {
                            Image(systemName: "rotate.left")
                                .resizable()
                                .frame(width: 75, height: 75)
                                .foregroundColor(.blue)
                        }
                        //cite: https://serialcoder.dev/text-tutorials/swiftui/handle-press-and-release-events-in-swiftui/
                        .simultaneousGesture( //this attribute allows us to detect when the button was pressed and if so send the command to start the robot moving
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    bluetoothService.sendData(dataToSend: "rotateacw")
                                }
                                .onEnded { _ in
                                    bluetoothService.sendData(dataToSend: "stop") //when released send a command to stop the robot
                                }
                        )
                        //all buttons below follow similar format.
                        Circle().frame(width: 75, height: 75).foregroundColor(.white)
                        Button(action: {}) {
                            Image(systemName: "rotate.right")
                                .resizable()
                                .frame(width: 75, height: 75)
                                .foregroundColor(.blue)
                        }
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    bluetoothService.sendData(dataToSend: "rotatecw")
                                }
                                .onEnded { _ in
                                    bluetoothService.sendData(dataToSend: "stop")
                                }
                        )
                    }
                    HStack() {
                        
                        Button(action: {}) {
                            Image(systemName: "arrow.up.circle.fill")
                                .resizable()
                                .frame(width: 75, height: 75)
                                .foregroundColor(.blue)
                        }.simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    bluetoothService.sendData(dataToSend: "forward")
                                }
                                .onEnded { _ in
                                    bluetoothService.sendData(dataToSend: "stop")
                                }
                        )
                        
                    }
                    
                    HStack() {
                        Button(action: {}) {
                            Image(systemName: "arrow.left.circle.fill")
                                .resizable()
                                .frame(width: 75, height: 75)
                                .foregroundColor(.blue)
                        }.simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    bluetoothService.sendData(dataToSend: "left000")
                                }
                                .onEnded { _ in
                                    bluetoothService.sendData(dataToSend: "stop")
                                }
                        )
                        Circle().frame(width: 75, height: 75).foregroundColor(.white)
                        Button(action: {}) {
                            Image(systemName: "arrow.right.circle.fill")
                                .resizable()
                                .frame(width: 75, height: 75)
                                .foregroundColor(.blue)
                        }.simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    bluetoothService.sendData(dataToSend: "righ000")
                                }
                                .onEnded { _ in
                                    bluetoothService.sendData(dataToSend: "stop")
                                }
                        )
                    }
                    
                    HStack() {
                        Button(action: {}) {
                            Image(systemName: "arrow.down.circle.fill")
                                .resizable()
                                .frame(width: 75, height: 75)
                                .foregroundColor(.blue)
                        }.simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    bluetoothService.sendData(dataToSend: "back")
                                }
                                .onEnded { _ in
                                    bluetoothService.sendData(dataToSend: "stop")
                                }
                        )
                    }
                    HStack() {
                        Spacer()
                        Spacer()
                        if(!recording) { //swift handles the rendering of whether the program is currently recording steps
                            VStack() {
                                Button(action: {record(bluetoothService: bluetoothService)}) {
                                    Image(systemName: "record.circle")
                                        .resizable()
                                        .frame(width: 75, height: 75)
                                        .foregroundColor(.red)
                                }.padding(20)
                                Text("Ready").foregroundColor(.gray)
                            }
                        } else {
                            VStack() {
                                Button(action: {stop(bluetoothService: bluetoothService)}) {
                                    Image(systemName: "stop.circle")
                                        .resizable()
                                        .frame(width: 75, height: 75)
                                        .foregroundColor(.red)
                                }.padding(20)
                                Text("Recording...").foregroundColor(.red)
                            }
                        }
                    }
                    Spacer()
                    //                HStack() {
                    //                    Button("Activate Controller", action: {
                    //                                        anticlockwise(bluetoothService: bluetoothService)
                    //                                    })
                    //                }
                    Spacer()
                }
                //            
                //            Text(bluetoothService.peripheralStatus.rawValue)
                //                .font(.title)
                //            Button("Sensor", systemImage: "arrow.up", action: {
                //                sensor(bluetoothService: bluetoothService)
                //            })
                //            HStack {
                //                
                //                
                //                Button("ACW", action: {
                //                    anticlockwise(bluetoothService: bluetoothService)
                //                })
                //                Button("CW", action: {
                //                    clockwise(bluetoothService: bluetoothService)
                //                })
                //                
                //            }            .buttonStyle(.bordered)
                //            Button("Forward", systemImage: "arrow.up", action: {
                //                forward(bluetoothService: bluetoothService)
                //            }).buttonStyle(.borderedProminent)
                //
                //            HStack {
                //                
                //                
                //                Button("Left", action: {
                //                    left(bluetoothService: bluetoothService)
                //                })
                //                Button("Right", action: {
                //                    right(bluetoothService: bluetoothService)
                //                })
                //                
                //            }            .buttonStyle(.bordered)
                //
                //            Button("Backward", action: {
                //                backward(bluetoothService: bluetoothService)
                //            })            .buttonStyle(.bordered)
                //
                //            Button("Stop", action: {
                //                stop(bluetoothService: bluetoothService)
                //            })
                //            .buttonStyle(.bordered)
                //            Button("Status", action: {
                //                status(bluetoothService: bluetoothService)
                //            })
                //            .buttonStyle(.bordered)
                VStack() {
                    ColorPicker("LED Strip",selection:$ledColor,supportsOpacity: false).onChange(of: ledColor, perform: { ledColor in
                        updateColor() //SwiftUI colour picker that updates the ledColor state variable and runs the updateColor function when changed.

                        
                        
                    })
                }
            }
            .padding()
       

    }
    func updateColor() {
        // changes the LED color
        if(ledColor.description.components(separatedBy: " ").count > 2) { // split the string representation so we can extract RGB values
            var components = ledColor.description.components(separatedBy: " ")[1...3]
            var rgb: [Int] = []
            for component in components {
                if let num = Double(component) {
                    rgb.append(Int((num*255).rounded())) // we need to multiply by 255 as the values are stored between 0-1
                } else {
                    rgb.append(0)
                }
            }
            
            
            bluetoothService.sendData(dataToSend: "pixel 0 17 \(String(rgb[0])) \(String(rgb[1])) \(String(rgb[2]))") // send the command to change the strip colour
            
        }
        }
    func record(bluetoothService: BluetoothService) {
        //command to start the recording process.
        bluetoothService.toggleRecordingStatus()
        recording = true
        bluetoothService.sendData(dataToSend: "speed\(String(format: "%03.0f", speed))") //we send the current speed so the robot knows what to start at.
        updateColor() // we send the current colour of the strip to ensure it starts with the same colour

    }
    func stop(bluetoothService: BluetoothService) {
        //handling logic for stopping the recording
        bluetoothService.toggleRecordingStatus()
        recording = false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

    //all functions for transmitting the data to the robot from button presses.

func sensor(bluetoothService: BluetoothService) {
    print("Sensor Clicked")
    print(bluetoothService.peripheralStatus.rawValue)
    bluetoothService.sendData(dataToSend: "sensor")
}

func stop(bluetoothService: BluetoothService) {
    print("Stop Clicked")
    print(bluetoothService.peripheralStatus.rawValue)
    bluetoothService.sendData(dataToSend: "stop")
}

func left(bluetoothService: BluetoothService) {
    print("Left Clicked")
    print(bluetoothService.peripheralStatus.rawValue)
    bluetoothService.sendData(dataToSend: "left000")
}

func right(bluetoothService: BluetoothService) {
    print("Right Clicked")
    print(bluetoothService.peripheralStatus.rawValue)
    bluetoothService.sendData(dataToSend: "righ000")
}

func forward(bluetoothService: BluetoothService) {
    print("Forward Clicked")
    print(bluetoothService.peripheralStatus.rawValue)
    bluetoothService.sendData(dataToSend: "forward")
}

func backward(bluetoothService: BluetoothService) {
    print("Backward Clicked")
    print(bluetoothService.peripheralStatus.rawValue)
    bluetoothService.sendData(dataToSend: "back")
}

func clockwise(bluetoothService: BluetoothService) {
    print("Clockwise Clicked")
    print(bluetoothService.peripheralStatus.rawValue)
    bluetoothService.sendData(dataToSend: "rotatecw")
}

func anticlockwise(bluetoothService: BluetoothService) {
    print("Anticlockwise Clicked")
    print(bluetoothService.peripheralStatus.rawValue)
    bluetoothService.sendData(dataToSend: "rotateacw")
}

func status(bluetoothService: BluetoothService) {
    print("Anticlockwise Clicked")
    print(bluetoothService.peripheralStatus.rawValue)
    bluetoothService.sendData(dataToSend: "status")
}


