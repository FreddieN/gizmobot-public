//
//  SequenceListingView.swift
//  Gizmo
//
//  Created by Freddie Nicholson on 01/12/2023.
//

import Foundation
import SwiftUI


    
struct SequenceListingView: View {
    @EnvironmentObject var bluetoothService: BluetoothService
    @State var sequences: [BluetoothService.Sequence]?
    

    var body: some View {
        
        NavigationStack {
            List() {
                if let sequences1 = sequences {
                    if(sequences1.count != 0) {
                        ForEach(sequences1, id: \.self) { sequenceEntry in //list of each sequence from the bluetoothService
                            NavigationLink(sequenceEntry.id.uuidString, value: sequenceEntry)
                        }
                    } else {
                        Text("No Sequences")
                    }
                }
            }.navigationDestination(for: BluetoothService.Sequence.self) { sequence in
                SequenceDetailView(sequence: sequence) //a navigation link with the sequence selected passed through displaying the view required.
            }.listStyle(.plain).navigationTitle("Sequences")
            
        }.listStyle(.plain).onAppear {
            sequences = bluetoothService.getSequenceList().reversed() //reverse order so chronological
            print("open sequences")
    }
        
    
    
            
        
    }
    
    
    
    struct SequenceListingView_Previews: PreviewProvider {
        static var previews: some View {
            SequenceListingView()
        }
    }
}
