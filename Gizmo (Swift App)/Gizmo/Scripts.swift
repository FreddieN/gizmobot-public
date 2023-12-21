//
//  Scripts.swift
//  Gizmo
//
//  Created by Freddie Nicholson on 01/12/2023.
//

import Foundation
import SwiftUI
import Charts

struct RadarPoint: Identifiable { // cite: freddie nicholson bouncer 2023
    let id = UUID()
    let x: Float
    let y: Float
    
    init(x: Float, y: Float) {
        self.x=x
        self.y=y
    }
}
func deg2rad(_ number: Double) -> Double {
    return number * .pi / 180
}

func dtan(_ degree: Int) -> Double { // cite: freddie nicholson bouncer 2023
    return tan(deg2rad(Double(degree)))
}

func dcos(_ degree: Int) -> Double {
    return cos(deg2rad(Double(degree)))
}

func dsin(_ degree: Int) -> Double {
    return Double(sin(deg2rad(Double(degree))))
}
    
struct ScriptsView: View {
    @EnvironmentObject var bluetoothService: BluetoothService 
    @State private var command: String = "roam" //current active command
    @State private var running: Bool = false //whether the command is running
    @State var tof1: Int64 = 0 // tof sensor value
    @State var tof2: Int64 = 0 // tof sensor value
    @State var tof3: Int64 = 0 // tof sensor value
    @State var tof4: Int64 = 0 // tof sensor value
    @State var open: Bool = false // whether the scripts page is currently open (as this is a nested view within the navigation stack it will always be loaded when status monitor is opened)
    @State var updateTimer: Timer? //a timer used to ensure the tof sensor values are up to date
    @State var workRadar: [[Int64]] = [] //a list of each tof sensor values for the radar function
    @State var showingPopover: Bool = false
    @State var radarPoints: [RadarPoint] = []

    var body: some View {
        ScrollView {
            ZStack() {
                VStack() {
                    VStack() {
                        HStack() {
                            Picker("Select a script", selection: $command) { //cite: https://www.hackingwithswift.com/quick-start/swiftui/how-to-let-users-pick-options-from-a-menu
                                Text("Roam").tag("roam")
                                Text("Follow me").tag("followme")
                                Text("Radar").tag("radar") //allows the user to select a command and run it. The tag attribute goes into the command state variable.
                                
                            }
                            .pickerStyle(.menu)
                            if(running) { // if script is running a progress spinner is shown
                                ProgressView().padding()
                            }
                            Button(action: { //logic to start and stop a command
                                if(running) {
                                    bluetoothService.sendData(dataToSend: "stop")
                                    bluetoothService.sendData(dataToSend: "speed100")
                                } else {
                                    bluetoothService.sendData(dataToSend: "pixel 0 17 0 0 0")
                                }
                                
                                running = !running
                                
                            }) {
                                if(!running) {
                                    Text("Run")
                                } else {
                                    Text("Stop")

                                }
                            }
                        }.buttonStyle(.bordered).popover(isPresented: $showingPopover) { //https://www.hackingwithswift.com/quick-start/swiftui/how-to-show-a-popover-view
                            Text("Radar")
                                .font(.title).bold()
                                .padding()
                            GroupBox ( "Radar Chart") { //UI popover for radar script with a Swift Chart showing the data
                                Chart {
                                    ForEach(radarPoints) {
                                        LineMark(
                                            x: .value("x", $0.x),
                                            y: .value("y", $0.y)
                                        )
                                    }
                                }
                            }
                        }
                    }
                    ConsoleView()
                    
                }.padding(20).onReceive( bluetoothService.$statusValues) {
                    newStatusValues in updateToFStateVars() // update Tof variables when statusValues updated
                }
                .onAppear() {
                        open = true
                            updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
                                timer in updateToFStateVars() // timer to update variables in case of no refresh.
                            }
                    }
                    .onDisappear() {
                        open = false // on view unload stop the scripts
                        bluetoothService.sendData(dataToSend: "pixel 0 17 0 255 0")
                        updateTimer?.invalidate()

                    }
                }

            }
            
        }
        
    func updateToFStateVars() {
        //handling command for all the functions
        if let statusValues = bluetoothService.statusValues as? [String: Any] //guard for checking if the statusValues exist
        {
            if let sensors = statusValues["sensors"] as? [Int64] { // guard for converting the sensor values into a sensors array with each value
                
                tof1 = sensors[0]
                tof2 = sensors[1]
                tof3 = sensors[2]
                tof4 = sensors[3] // pretifying the variable names
                
                print(tof1, tof2, tof3, tof4)
                if(running) { 
                    
                    if command == "roam" {
                        bluetoothService.sendData(dataToSend: "speed100")

                        var dir_matrix = ["back", "rotatecw", "rotateacw", "forward"]
                        if let maxnumber =  sensors.max() { //find the sensor with the biggest reading
                            if let direction = sensors.firstIndex(of:maxnumber) { 
                                var directionInt = sensors.distance(from: sensors.startIndex, to: direction)
                                if(sensors[3]>600) { // if forward sensor is bigger than 600mm then go forwards and turn light green
                                    print(directionInt)
                                    bluetoothService.sendData(dataToSend: "forward")
                                    bluetoothService.sendData(dataToSend: "pixel 0 17 0 255 0")

                                    
                                }
                                else if(sensors[directionInt] > 400 ) { // otherwise go in the direction with the most space
                                    print(dir_matrix[directionInt])
                                    bluetoothService.sendData(dataToSend: dir_matrix[directionInt])
                                    bluetoothService.sendData(dataToSend: "pixel 0 17 255 0 0")

                                    
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    bluetoothService.sendData(dataToSend: "stop") //after 2 seconds stop
                                }
                            }
                            }
                        
                    }
                    
                    if command == "followme" {
                        bluetoothService.sendData(dataToSend: "speed025") //set speed low to avoid injury to the user
                        var dir_matrix = ["rotatecw", "back", "rotateacw", "forward"]
                        if let maxnumber =  sensors.min() { //get sensor with hand closest
                            if let direction = sensors.firstIndex(of:maxnumber) {
                                var directionInt = sensors.distance(from: sensors.startIndex, to: direction)
                                
                                if(sensors[directionInt] < 200 ) { //go to sensor which has a value smaller than 200mm ie the users hand is covering the sensor
                                    print(dir_matrix[directionInt])
                                    print("debug552", directionInt)
                                    bluetoothService.sendData(dataToSend: dir_matrix[directionInt])
                                    bluetoothService.sendData(dataToSend: "pixel 0 17 0 0 0 ")

                                    if(directionInt == 0) {
                                        bluetoothService.sendData(dataToSend: "pixel 9 14 0 0 255 ") //illuminate the sensor that was covered
                                    }
                                    if(directionInt == 2) {
                                        bluetoothService.sendData(dataToSend: "pixel 0 5 255 0 0")
                                    }
                                    if(directionInt == 1) {
                                        bluetoothService.sendData(dataToSend: "pixel 5 9 0 255 0")
                                    }
                                    if(directionInt == 3) {
                                        bluetoothService.sendData(dataToSend: "pixel 14 17 60 100 100")
                                    }
                                    

                                    
                                }
                                
                            }
                            }
                        
                    }
                    
                    if command == "radar" {
                        bluetoothService.sendData(dataToSend: "speed100")
                        var overall: [Int64] = [] //store for all the variables in order
                        var angles: [Double] = [] //store for the angles
                         
                        if(workRadar.count > 12) {
                            var order = [1,2,3,0] //the order to append the sensor values together to plot it correctly on a radar plot.
                            for i in order {
                                for workItem in workRadar {
                                    if(workItem[i] < 7000) { // check value is less than 7000 (a valid reading)
                                        overall.append(workItem[i]) //append to overall the reading
                                    } else {
                                        overall.append(0) //otherwise no value
                                    }
                                }
                                
                                workRadar.removeAll() //wipe workRadar
                                radarPoints.removeAll() //wipe radarPoints
                                var i = 0
                                for angle in stride(from: 0.0, through: 360.0, by: 30) {
                                    let foveralli = Float(overall[i]) //for each angle plot a point with the respective angle using trig.
                                    let iangle = Int(angle.rounded())
                                    let fsiny = Float(dsin(iangle))
                                    let fcosx = Float(dcos(iangle))

                                    radarPoints.append(RadarPoint(x:fcosx*foveralli,y:fsiny*foveralli))
                                    
                                    i+=1
                                }
                                print(radarPoints)
                                print("Work radar finished", overall)
                                showingPopover = true //display the chart on a graph.
                            }
                        }
                        var workArray = [tof1,tof2,tof3,tof4]
                        workRadar.append(workArray)
                        
                        bluetoothService.sendData(dataToSend: "rotatecw") // rotate the robot by a tick.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            bluetoothService.sendData(dataToSend: "stop")
                        }
                    }
                    
                    
                    
                }
            }
    }
    
    }
    
    
    
    
    struct ScriptsView_Previews: PreviewProvider {
        static var previews: some View {
            ScriptsView()
        }
    }
}
