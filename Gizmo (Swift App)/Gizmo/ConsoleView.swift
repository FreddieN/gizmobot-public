//
//  Console.swift
//  Gizmo
//
//  Created by Freddie Nicholson on 01/12/2023.
//

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
                            bluetoothService.sendData(dataToSend: command) //when press button send data that was entered in text field.
                            command = ""
                        })            .buttonStyle(.bordered)
                        
                    }

                        List {
                            ForEach(bluetoothService.getConsoleLog().reversed(), id: \.self) { consoleEntry in
                                Text(consoleEntry.text) //swift automatically handles the rendering of the current console log. We have set it to show in chronological order by reversing the list
                            }


                        }.listStyle(.plain).frame(height:400)
                    }
                    
            }.padding(20).navigationBarTitle("Console")
           
            Spacer()
            
        }
    }
    
    
    
    struct ConsoleView_Previews: PreviewProvider {
        static var previews: some View {
            ConsoleView()
        }
    }
}
