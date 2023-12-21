//
//  ViewControllerStatusMonTop3DGraphic.swift
//  Gizmo
//
//  Created by Freddie Nicholson on 01/12/2023.
//
// CITATION: Adapted from https://github.com/FreddieN/Bouncer-WWDC23

import SwiftUI
import SceneKit

public class ViewControllerStatusMonTop3DGraphic: UIViewController {
    var scene: SCNScene = SCNScene()
    var sceneView: SCNView = SCNView()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
    }
    
    func setup() {
        //this loads in a usdz 3d model file into a SceneKit scene and rotates the model forever. It is mainly for aesthetics.
        view.addSubview(sceneView)
        
        sceneView.backgroundColor = UIColor(red: CGFloat(255/255.0), green: CGFloat(255/255.0), blue: CGFloat(255/255.0), alpha: CGFloat(1.0))
        sceneView.frame = CGRect(origin:.zero,size:view.frame.size)
        
        sceneView.scene = scene
        
        let universe = scene.rootNode
        
        let camera = SCNCamera()
        let observer = SCNNode()
        observer.camera = camera
        observer.position = SCNVector3(x: 0, y: 2, z: 5)
        universe.addChildNode(observer)
        
        let light = SCNLight()
        light.type = .omni
        light.intensity = 200
        let torch = SCNNode()
        torch.light = light
        torch.position = SCNVector3(x: 0, y: 5, z: -5)
        universe.addChildNode(torch)
        
        let light2 = SCNLight()
        light2.type = .omni
        light2.intensity = 200
        let torch2 = SCNNode()
        torch2.light = light2
        torch2.position = SCNVector3(x: 0, y: 5, z: 5)
        universe.addChildNode(torch2)
        
        let light3 = SCNLight()
        light3.type = .omni
        light3.intensity = 200
        let torch3 = SCNNode()
        torch3.light = light2
        torch3.position = SCNVector3(x: -5, y: 0, z: 0)
        universe.addChildNode(torch2)
        
        let light4 = SCNLight()
        light4.type = .omni
        light4.intensity = 200
        let torch4 = SCNNode()
        torch4.light = light2
        torch4.position = SCNVector3(x: 5, y: 0, z: 0)
        universe.addChildNode(torch4)

        if let usdzURL = Bundle.main.url(forResource: "Robot", withExtension: "usdz") {
           do {
           let usdzNode = SCNNode()
           let usdzObject = try SCNScene(url: usdzURL, options: nil)
           
               if let usdzChildNode = usdzObject.rootNode.childNodes.first {
                   usdzNode.addChildNode(usdzChildNode)
                   
                   usdzNode.position = SCNVector3(x: 0, y: 0, z: 0)
                   usdzNode.scale = SCNVector3(x: 0.02, y: 0.02, z: 0.02)
                   universe.addChildNode(usdzNode)
                   observer.look(at: usdzNode.position)
                   
                 
                   usdzNode.runAction(SCNAction.repeatForever(SCNAction.rotate(by: .pi, around: SCNVector3(0, 1, 0), duration: 5))) // stack overflow https://stackoverflow.com/questions/45227401/how-to-make-scnnode-rotate-spin-horizontally
//                   if let firstNode = usdzNode.childNodes.first { I did want the wheels to rotate according to the RPM but I couldn't get it to work in time
//                       if let secondNode = firstNode.childNodes.first {
//                           let filterednodes = secondNode.childNodes.filter{$0.name == "Body1__3_" || $0.name == "Body2"}
//                           if let axle = secondNode.childNodes.filter{$0.name == "Body1__1___1_"}.first {
//                               for node1 in filterednodes {
//                                   print(axle.convertPosition(axle.position, to: nil))
//                                   node1.runAction(SCNAction.repeatForever(SCNAction.rotate(by: .pi, around: SCNVector3(1.1, 1.1, 0), duration: 5)))
//                               }
//                           }
//                           
//                       }
//                   }
               }
           } catch {
               print("cannot load usdz")
           }
       }

        sceneView.frame = CGRect(x: 0, y: 0, width: 400, height: 200)
        sceneView.allowsCameraControl = true
        
  
        
    }
}

