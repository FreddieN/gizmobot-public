//
//  SequenceDetails.swift
//  Gizmo
//
//  Created by Freddie Nicholson on 01/12/2023.
//

import Foundation
import SwiftUI


    
struct SequenceDetailView: View {
    @EnvironmentObject var bluetoothService: BluetoothService
    @State var sequence: BluetoothService.Sequence //the sequence struct
    @State var reversed: Bool = false //whether the sequence is reversed
    
    struct ConsoleLogEntry: Identifiable, Hashable { //consolelog struct
        var text: String
        var id = UUID()
        var date = Date()
    }
    
    struct Sequence: Identifiable, Hashable { //sequence struct with each item in a sequence
        var log: [ConsoleLogEntry]
        var id = UUID()
        var date = Date()
    }
    
    var body: some View {
        NavigationView() {
            VStack() {
                    
                    Text("Sequence").font(.title).fontWeight(.bold)
                    Text(sequence.id.uuidString).font(.footnote).foregroundColor(.gray)
                Button(action: {
                    if(!reversed) { //plays the sequence dependent on whether it is reversed
                        playSequence(step:1)
                    } else {
                        playSequenceReverse(step:1)
                    }}) {
                    Image(systemName: "play.circle")
                        .resizable()
                        .frame(width: 75, height: 75)
                        .foregroundColor(.blue)

                    }.padding(40)
                
                VStack {
                    Picker("Reversed?", selection: $reversed) { //picker for selecting whether to reverse the sequence
                        Text("Original").tag(false)
                        Text("Reversed").tag(true)

                    }
                    
                }
                .pickerStyle(.segmented)

                List() { //a list of each the steps rendered using the func built into bluetooth service and using the state variables from the UI
                    ForEach(bluetoothService.funcRecordingAsEnglishSteps(log: sequence.log, reversed: reversed), id: \.self) { move in
                        Text(move)
                    }
                }
                
            }.padding(20)
        }
        
        
    }
    
    
    func playSequence(step: Int)  {
        // recursive sequence for playing the sequence in order
            var time_prev = sequence.log[step-1].date
            var time_now = sequence.log[step].date
            var time_between =  round((time_now.timeIntervalSince1970 - time_prev.timeIntervalSince1970) * 100)/100
        bluetoothService.sendData(dataToSend: sequence.log[step-1
                                                          ].text)
            DispatchQueue.main.asyncAfter(deadline: .now() + time_between) {
                print(step-1 , sequence.log.count)
                        // wait the specified amount of time before playing the next step recusively, unless end of sequence in which case we stop

                if(step+1 < sequence.log.count) {
                    bluetoothService.sendData(dataToSend: sequence.log[step
                                                                      ].text)
                    playSequence(step: step+1)
                } else {
                    bluetoothService.sendData(dataToSend: "stop")
                }
            }
    }
    
    
    
    func playSequenceReverse(step: Int)  {
        // similar to playSequence but additional logic to convert into reverse
        var time_prev = sequence.log.reversed()[step-1].date
            var time_now = sequence.log.reversed()[step].date
            var time_between =  round((time_prev.timeIntervalSince1970 - time_now.timeIntervalSince1970) * 100)/100
        if let opposite = bluetoothService.opposites[sequence.log.reversed()[step
                                                           ].text] {
            bluetoothService.sendData(dataToSend: opposite)
            print("opposite", opposite)
            print(time_between)
        } else if (sequence.log.reversed()[step
                                          ].text.prefix(5) == "speed") { //additional edge cases for speed and led strip that does a backtrack to see what the LED strip colour / speed of the robot should be.
            var steps_after = sequence.log.reversed()[step..<sequence.log.reversed().count-1]
            if let first_speed = steps_after.first(where: {
                $0.text.contains("speed")
            }) {
                
                bluetoothService.sendData(dataToSend: first_speed.text)
            }

        } else if (sequence.log.reversed()[step
                                          ].text.prefix(5) == "pixel") {
            var steps_after = sequence.log.reversed()[step..<sequence.log.reversed().count-1]
            if let first_pixel = steps_after.first(where: {
                $0.text.contains("pixel")
            }) {
                
                bluetoothService.sendData(dataToSend: first_pixel.text)
            }

        }
        
            DispatchQueue.main.asyncAfter(deadline: .now() + time_between) {
                print(step-1 , sequence.log.reversed().count)
                
                if(step+2 < sequence.log.reversed().count) {
                    if let opposite = bluetoothService.opposites[sequence.log.reversed()[step
                                                                       ].text] {
                        bluetoothService.sendData(dataToSend: opposite)
                        print("opposite", opposite)

                    } else if (sequence.log.reversed()[step
                                                      ].text.prefix(5) == "speed") {
                        var steps_after = sequence.log.reversed()[step..<sequence.log.reversed().count-1]
                        if let first_speed = steps_after.first(where: {
                            $0.text.contains("speed")
                        }) {
                            
                            bluetoothService.sendData(dataToSend: first_speed.text)
                        }
                    } else if (sequence.log.reversed()[step
                                                      ].text.prefix(5) == "pixel") {
                        var steps_after = sequence.log.reversed()[step..<sequence.log.reversed().count-1]
                        if let first_pixel = steps_after.first(where: {
                            $0.text.contains("pixel")
                        }) {
                            
                            bluetoothService.sendData(dataToSend: first_pixel.text)
                        }

                    }
                    playSequenceReverse(step: step+1)
                } else {
                    bluetoothService.sendData(dataToSend: "stop")
                }
            }
    }
    
   
}
