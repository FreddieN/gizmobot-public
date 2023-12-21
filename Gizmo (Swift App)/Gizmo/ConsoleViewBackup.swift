//
//  Console.swift
//  Gizmo
//
//  Created by Freddie Nicholson on 01/12/2023.
//
// This file is not used
import Foundation
import SwiftUI


    
struct ConsoleView: View {
    @EnvironmentObject var bluetoothService: BluetoothService
    @State private var command: String = ""
    
    var body: some View {
        ScrollView {
            VStack() {
                VStack() {
                    HStack() {
                        TextField("Enter command", text: $command)
                        Button("Send", action: {
                            print("send")
                        })            .buttonStyle(.bordered)
                        
                    }

//                        List {
//                            ForEach(bluetoothService.console.reversed(), id: \.self) { consoleEntry in
//                                Text(consoleEntry.text)
//                            }
//                                                    
//                           
//                        }.listStyle(.plain).frame(height:400)
                    }
                    
            }.padding(20)
           
            Spacer()
            
        }.navigationTitle("Console")
    }
    
    
    
    struct ConsoleView_Previews: PreviewProvider {
        static var previews: some View {
            ConsoleView()
        }
    }
}
