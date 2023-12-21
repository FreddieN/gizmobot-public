//
//  GizmoApp.swift
//  Gizmo
//
//  Created by Freddie Nicholson on 30/11/2023.
//
//CITATION: This code is adapted from example code: https://github.com/BeauNouvelle/BluetoothReader 30/11/23
import SwiftUI

@main
struct GizmoApp: App {
    @StateObject private var bluetoothService = BluetoothService()
//    @State private var selectedTab: Int = 1

    var body: some Scene {

        WindowGroup {
            TabView() { // overall tab view for all the views within the app giving the tabs at the bottom.
                StatusView().tabItem {
                    Label("Status Monitor", systemImage: "speedometer")
                }
                
                ContentView().tabItem {
                    Label("Controller", systemImage: "gamecontroller")
                }
                SequenceListingView().tabItem {
                                    Label("Sequences", systemImage: "list.star")
                                }
//
//                ContentView().tabItem {
//                    Label("AR View", systemImage: "move.3d")
//                }
                
            }
        }
        .environmentObject(bluetoothService)
       
    }
}
