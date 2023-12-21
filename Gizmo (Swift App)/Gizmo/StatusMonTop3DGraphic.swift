//
//  StatusMonTop3DGraphic.swift
//  Gizmo
//
//  Created by Freddie Nicholson on 01/12/2023.
//
// CITATION: Adapted from https://github.com/FreddieN/Bouncer-WWDC23
import SwiftUI

struct StatusMonTop3DGraphic: View {
    
    var body: some View {
        VStack() {
            ViewControllerRepresentableStatusMonTop3DGraphic(parent: self).frame(width:400,height:200) //used for adding a spinning graphic at the top of the status monitor screen with our CAD model

        }
    }
}

struct ViewControllerRepresentableStatusMonTop3DGraphic:
    UIViewControllerRepresentable {
    
    func updateUIViewController(_ uiViewController: ViewControllerStatusMonTop3DGraphic, context: Context) {
        let viewController = ViewControllerStatusMonTop3DGraphic()
    }
    
    var parent: StatusMonTop3DGraphic
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ViewControllerRepresentableStatusMonTop3DGraphic>) ->
    ViewControllerStatusMonTop3DGraphic {
        let viewController = ViewControllerStatusMonTop3DGraphic()
        return viewController
    }
    
//    func updateUIViewController(_ uiViewController: ViewControllerRepresentableStatusMonTop3DGraphic, context: Context) {
//        uiViewController.viewDidLoad()
//    }
   
}

