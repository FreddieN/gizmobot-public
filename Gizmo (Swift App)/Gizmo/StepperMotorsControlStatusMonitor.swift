//
//  StepperMotorsControlStatusMonitor.swift
//  Gizmo
//
//  Created by Freddie Nicholson on 01/12/2023.
//

import Foundation

import SwiftUI

struct StepperMotorsControlStatusMonitor: View {
    @EnvironmentObject var bluetoothService: BluetoothService
    @State private var rpm1 = 0.0 //rpm of each motor
    @State private var rpm2 = 0.0
    @State private var rpm3 = 0.0
    @State private var rpm4 = 0.0
    @State private var dir1 = "ACW" //user display direction of each motor
    @State private var dir2 = "ACW"
    @State private var dir3 = "ACW"
    @State private var dir4 = "ACW"
    @State private var loaded = false //whether the page is loaded
    @State private var recentlyUpdated = false //whether a motor value was recently updated

    var body: some View {
        NavigationView {
            ScrollView{
                if(loaded) {
                    
                    VStack() {
                        
                        
                        HStack() {
                            VStack() {
                                Text("Motor 1 RPM: \(String(rpm1))").padding()
                                Slider(value: $rpm1, in: 0.0...450.0, step: 1.0) { editing in
                                    print("change")
                                    updateMotors() // on change of slider tell robot there has been a change
                                }
                            }
                            VStack() {
                                Text("Motor 1 Direction: \(dir1)").padding()
                                Button("Switch", action: {
                                    print("Switch")
                                    switchDirection(motor_no: 0)
                                })            .buttonStyle(.bordered)
                            }
                        }
                        
                        HStack() {
                            VStack() {
                                Text("Motor 2 RPM: \(String(rpm2))").padding()
                                Slider(value: $rpm2, in: 0.0...450.0, step: 1.0) { editing in
                                    print("change")
                                    updateMotors()

                                }
                            }
                            VStack() {
                                Text("Motor 2 Direction: \(dir2)").padding()
                                Button("Switch", action: {
                                    print("Switch")
                                    switchDirection(motor_no: 1)

                                })            .buttonStyle(.bordered)
                            }
                        }
                        
                        HStack() {
                            VStack() {
                                Text("Motor 3 RPM: \(String(rpm3))").padding()
                                Slider(value: $rpm3, in: 0.0...450.0, step: 1.0) { editing in
                                    print("change")
                                    updateMotors()

                                }
                            }
                            VStack() {
                                Text("Motor 3 Direction: \(dir3)").padding()
                                Button("Switch", action: {
                                    print("Switch")
                                    switchDirection(motor_no: 2)

                                })            .buttonStyle(.bordered)
                            }
                        }
                        HStack() {
                            VStack() {
                                Text("Motor 4 RPM: \(String(rpm4))").padding()
                                Slider(value: $rpm4, in: 0.0...450.0, step: 1.0) { editing in
                                    print("change")
                                    updateMotors()

                                }
                            }
                            VStack() {
                                Text("Motor 4 Direction: \(dir4)").padding()
                                Button("Switch", action: {
                                    print("Switch")
                                    switchDirection(motor_no: 3)

                                })            .buttonStyle(.bordered)
                            }
                        }
                    }.padding([.leading, .trailing], 40).padding([.top,.bottom], 20)
                    
                    
                } else {
                    ProgressView()
                    Text("Waiting for data...").padding()
                    Spacer()
                }
            }.padding([.top],1).onReceive( bluetoothService.$statusValues) {
                newStatusValues in updateMotorStateVars() //on status update from main status monitor view update motor speed
            }
        }.navigationTitle("Stepper Motors")
    }
    func switchDirection(motor_no: Int) {
        if(motor_no == 0) {
            if(dir1 == "ACW") { //switches direction of motors
                dir1 = "CW"
            } else {
                dir1 = "ACW"
            }
        }
        if(motor_no == 1) {
            if(dir2 == "ACW") {
                dir2 = "CW"
            } else {
                dir2 = "ACW"
            }
        }
        if(motor_no == 2) {
            if(dir3 == "ACW") {
                dir3 = "CW"
            } else {
                dir3 = "ACW"
            }
        }
        if(motor_no == 3) {
            if(dir4 == "ACW") {
                dir4 = "CW"
            } else {
                dir4 = "ACW"
            }
        }
        updateMotors()
    }
    func updateMotors() {
        print("updatemotors")
        bluetoothService.sendData(dataToSend: "motor 0 \(Int(rpm1.rounded())) \(dir1 == "ACW" ? 0 : 1)")  //command to update each individual motor RPM and direction on the robot
        bluetoothService.sendData(dataToSend: "motor 1 \(Int(rpm2.rounded())) \(dir2 == "ACW" ? 1 : 0)")
        bluetoothService.sendData(dataToSend: "motor 2 \(Int(rpm3.rounded())) \(dir3 == "ACW" ? 1 : 0)")
        bluetoothService.sendData(dataToSend: "motor 3 \(Int(rpm4.rounded())) \(dir4 == "ACW" ? 1 : 0)")
        recentlyUpdated = true
    }
    func updateMotorStateVars() {
        //command that updates the local view state variables from the robot status transmission
        if(!recentlyUpdated) {
        if let statusValues = bluetoothService.statusValues as? [String: Any]
            {
            if let motors = statusValues["motors"] as? [String: Any] {
                if let rpm = motors["rpm"] as? [Double] {
                    rpm1 = rpm[0]
                    rpm2 = rpm[1]
                    rpm3 = rpm[2]
                    rpm4 = rpm[3]
                    loaded = true
                }
                if let direction = motors["direction"] as? [Double] {
                    if(direction[0] == 1) {
                        dir1 = "CW"
                    } else {
                        dir1 = "ACW"
                    }
                    if(direction[1] == 0) {
                        dir2 = "CW"
                    } else {
                        dir2 = "ACW"
                    }
                    if(direction[2] == 0) {
                        dir2 = "CW"
                    } else {
                        dir2 = "ACW"
                    }
                    if(direction[3] == 0) {
                        dir3 = "CW"
                    } else {
                        dir3 = "ACW"
                    }
                }
            }
        }
            
        } else {
            recentlyUpdated = false
        }
        
    }
}



struct StepperMotorsControlStatusMonitor_Previews: PreviewProvider {
    static var previews: some View {
        StepperMotorsControlStatusMonitor()
    }
}
