//
//  StatusView.swift
//  Gizmo
//
//  Created by Freddie Nicholson on 01/12/2023.
//

import Foundation
import SwiftUI


var connectionColors = [ //colors for connection status indicator
    "fill": [
        "connected": Color(red: 0.38, green: 0.77, blue: 0.33),
        "scanning": Color(red: 0.96, green: 0.76, blue: 0.32),
        "disconnected": Color(red: 0.93, green: 0.42, blue: 0.37),


    ],
    "stroke": [
        "connected": Color(red: 0.3, green: 0.64, blue: 0.22),
        "scanning": Color(red: 0.84, green: 0.62, blue: 0.22),
        "disconnected": Color(red: 0.81, green: 0.31, blue: 0.26),

    ]
]
    
struct StatusView: View {
    @EnvironmentObject var bluetoothService: BluetoothService
    @State private var polltimer: Timer? //timer for polling the robot for status
    @State private var refreshTimer: Timer? //timer for refresh UI display

    @State private var lastPollTime: Date? //track of when last refreshed
    @State private var refreshString: String = "Not connected" //UI display for whether we are connected or not

    var body: some View {
            ScrollView {
                VStack() {
                    StatusMonTop3DGraphic()
                    Text("Group 21 Gizmo Bot").font(.largeTitle)
                        .fontWeight(.heavy)
                    Text("9A9E918E-284E-F531-7943-559F04FF97A8").font(.footnote).foregroundStyle(.gray)
                    HStack() {
                        Circle()
                            .fill(
                                connectionColors["fill"]?[bluetoothService.peripheralStatus.rawValue] ?? Color(red: 0, green: 0.59, blue: 1.0))
                            .stroke(
                                connectionColors["stroke"]?[bluetoothService.peripheralStatus.rawValue] ?? Color(red: 0, green: 0.42, blue: 1), lineWidth: 1)
                            .frame(width:10, height:10)
                        Text(bluetoothService.peripheralStatus.rawValue.capitalized)
                        
                    }.padding(2)
                    Text("Last Refresh: \(refreshString)").font(.footnote).foregroundStyle(.gray)
                    //                HStack() {
                    //                    Button("Console", action: {
                    //                        print("Console")
                    //                    })            .buttonStyle(.bordered)
                    //                    Button("EMGSTOP", action: {
                    //                        print("EMGSTOP")
                    //                    })            .buttonStyle(.bordered)
                    //                }.padding([.top],20)
                    
                    NavigationView {
                        List {
                            NavigationLink("Stepper Motors", destination: StepperMotorsControlStatusMonitor())
                            NavigationLink("ToF Sensors", destination: StepperMotorsControlToFSensor())
                            NavigationLink("Console", destination: ConsoleView())
                            NavigationLink("Scripts", destination: ScriptsView())
                            
                        }
                        .navigationTitle("Status Monitor")
                    }
                    
                }
                
            }
            .onAppear {
                beginPollingStatus() //on appear start talking to the robot about its status
                beginRefreshCount()
            }
            .onDisappear {
                stopPollingStatus() //on page unload stop talking to the robot about its status
                stopRefreshCount()
            }
            
        
    }
    
    func beginPollingStatus() {
        bluetoothService.sendData(dataToSend: "status")
        polltimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in //timer that runs the status command on the robot every 5s
            lastPollTime = Date()
            bluetoothService.sendData(dataToSend: "status")
        }
    }
    
    func stopPollingStatus() {
        polltimer?.invalidate() //stops timer
        polltimer = nil
    }
    
    func beginRefreshCount() {
        print(lastPollTime?.timeIntervalSinceNow) //pretty formatting for the last refresh time
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            var secondssince = Int32(abs(lastPollTime?.timeIntervalSinceNow ?? 0).rounded())
            if(secondssince == 0) {
                refreshString = "Just now"
            }else if (secondssince == 1) {
                refreshString = "1 second ago"
            }
            else {
                refreshString = "\(secondssince) seconds ago"
            }
        }
    }
    
    func stopRefreshCount() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    
    
    }
    


struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        StatusView()
    }
}
