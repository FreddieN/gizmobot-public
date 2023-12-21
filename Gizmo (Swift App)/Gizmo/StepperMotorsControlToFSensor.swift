//
//  StepperMotorsControlStatusMonitor.swift
//  Gizmo
//
//  Created by Freddie Nicholson on 01/12/2023.
//
//CITATION: Apple developer docs 1/12/23 https://developer.apple.com/documentation/charts/creating-a-chart-using-swift-charts

import Foundation

import SwiftUI
import Charts



struct StepperMotorsControlToFSensor: View {
    @EnvironmentObject var bluetoothService: BluetoothService
    @State var tof1: Int64 = 0 //tof sensor readings
    @State var tof2: Int64 = 0
    @State var tof3: Int64 = 0
    @State var tof4: Int64 = 0
    @State private var loaded = false //whether the view is loaded (data received)
    @State private var open: Bool = false //whether the view is open
    @State var updateTimer: Timer?

    var body: some View {
        NavigationView {
            VStack() {
            if(loaded) {
                    Chart { //swift chart for displaying line sensor data
                        BarMark(
                            x: .value("Sensor", "S3 (right)"),
                            y: .value("Distance", tof1)
                        ).foregroundStyle(.blue)
                        BarMark(
                            x: .value("Sensor", "S4 (back)"),
                            y: .value("Distance", tof2)
                        ).foregroundStyle(.green)
                        BarMark(
                            x: .value("Sensor", "S1 (left)"),
                            y: .value("Distance", tof3)
                        ).foregroundStyle(.red)
                        BarMark(
                            x: .value("Sensor", "S2 (front)"),
                            y: .value("Distance", tof4)
                        ).foregroundStyle(.yellow)
                    }
                    
            } else {
                ProgressView()
                Text("Waiting for data...").padding()
                Spacer()
            }
            }.padding(20).onAppear() {
                open = true
                updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
                    timer in updateToFStateVars() //command that polls the robot for data
                }

            }
            .onDisappear() {
                open = false
                bluetoothService.sendData(dataToSend: "pixel 0 17 0 255 0")
                updateTimer?.invalidate()
            }
            
            
            
        }.padding([.top],1).navigationTitle("ToF Sensors").onReceive( bluetoothService.$statusValues) {
                newStatusValues in updateToFStateVars()
            }
    }
    
    func updateToFStateVars() {
        if let statusValues = bluetoothService.statusValues as? [String: Any]
        {
            if let sensors = statusValues["sensors"] as? [Int64] {
                tof1 = sensors[0] //updates state variables to various tof values
                tof2 = sensors[1]
                tof3 = sensors[2]
                tof4 = sensors[3]
                
                if(open) {
                    

                    bluetoothService.sendData(dataToSend: "pixel 0 5 255 0 0") //set the color of the LED strip for each sensor to give visual indicator of what sensor you are interacting with.
                    bluetoothService.sendData(dataToSend: "pixel 5 9 0 255 0")
                    bluetoothService.sendData(dataToSend: "pixel 9 14 0 0 255 ")
                    bluetoothService.sendData(dataToSend: "pixel 14 17 60 100 100")
                }
                
                loaded = true
                print(String(tof1) + "tof")
            }
        }
    }
        
}

struct StepperMotorsControlToFSensor_Previews: PreviewProvider {
    static var previews: some View {
        StepperMotorsControlToFSensor()
    }
}
