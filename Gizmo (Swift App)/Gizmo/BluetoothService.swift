//
//  BluetoothService.swift
//  BluetoothReader
//
//  Created by Beau Nouvelle on 14/2/2023. (Adapted by Freddie Nicholson 01/12/23)
//
//CITATION: This code is adapted from example code: https://github.com/BeauNouvelle/BluetoothReader 30/11/23

import Foundation
import CoreBluetooth

enum ConnectionStatus: String { // different states for UI displaying current connection status
    case connected
    case disconnected
    case scanning
    case connecting
    case error
}

let droneService: CBUUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E") //bluetooth service ID
let droneCharacteristic: CBUUID = CBUUID(string: "6e400002-b5a3-f393-e0a9-e50e24dcca9e") //bot rx characteristic
let droneTXCharacteristic: CBUUID = CBUUID(string: "6e400003-b5a3-f393-e0a9-e50e24dcca9e") // bot tx characteristic

class BluetoothService: NSObject, ObservableObject { //service that other views can access to access @Published objects and perform functions with bluetooth

    private var centralManager: CBCentralManager! // CoreBluetooth is the apple framework to access BLE devices

    var dronePeripheral: CBPeripheral? // The peripheral object we connect to
    @Published var peripheralStatus: ConnectionStatus = .disconnected //UI Display for current connection status
    @Published var statusValues: [String: Any] = [:] // JSON object containing current status of the robot whether motors are on, sensors detect anything and ToF sensor values
    var recording: Bool = false // active when the user presses the record button

    struct ConsoleLogEntry: Identifiable, Hashable {
        var text: String
        var id = UUID()
        var date = Date()
    } // data structure for each log entry when a command is sent via BLE
    var consoleLog: [ConsoleLogEntry] = [] // a log of the past 100 commands transmitted
    var recordingLog: [ConsoleLogEntry] = [] // a log of the recorded commands when the record button is pressed
    
    struct Sequence: Identifiable, Hashable {
        var log: [ConsoleLogEntry]
        var id = UUID()
        var date = Date()
    } // Data structure for a sequence that is recorded
    var sequences: [Sequence] = [] // a log of all the sequences recorded whilst the app is open


    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil) // initialise the manager on first init of service
    }

    func scanForPeripherals() {
        peripheralStatus = .scanning
        centralManager.scanForPeripherals(withServices: nil) // function to scan for ESP 32 when found will call service commands below
    }
    func addtoconsole(textToAdd: String) {
        if(consoleLog.count > 100) {
            consoleLog.remove(at:consoleLog.count-1) //logic to work out whether to drop a log entry from the list if too many
        }
        consoleLog.append(ConsoleLogEntry(text:textToAdd)) // add entry to log
    }
    func addtorecording(textToAdd: String) {

        recordingLog.append(ConsoleLogEntry(text:textToAdd)) // add a command to a recording
    }
    func getConsoleLog() -> [ConsoleLogEntry] {
        return consoleLog // returns the console log object allowing UI to display
    }
    func getSequenceList() -> [Sequence] {
        return sequences // returns the sequence list object allowing the UI to display
    }
    func getRecordingStatus() -> Bool {
        return recording  // returns the recording status allowing the UI to display
    }
    
    func toggleRecordingStatus() {
        if(recording) { // toggle that inverts the recording variable and if recording performs the logic required to save the recording and init for next recording.
            print(recordingLog)
            sequences.append(Sequence(log:recordingLog))
            recordingLog.removeAll()
            print(sequences)
        }
        
        recording = !recording
    }
    var commandToEnglish = [ // a translation between the commands sent to the robot and what a human would understand
        "back": "Move backwards",
        "righ000": "Move right",
        "forward": "Move forward",
        "left000": "Move left",
        "rotatecw": "Rotate clockwise",
        "rotateacw": "Rotate anticlockwise",
        "stop": "Stop",
    ]
    
    var opposites = [ // a dictionary of opposites that can be used to reverse the sequence recorded
        "back": "forward",
        "righ000": "left000",
        "forward": "back",
        "left000": "righ000",
        "rotatecw": "rotateacw",
        "rotateacw": "rotatecw",
        "stop": "stop",
    ]
    
     func cmdtoeng(cmd: String, reversed: Bool = false) -> String? {
        // This command converts the inputed command into a human readable form.
        var move: String?
        if(cmd.prefix(5) == "speed") { // edge case for speed to be able to print the correct speed value
            move = "Change speed to \(cmd.suffix(5-2))"
        }
         if(cmd.prefix(5) == "pixel") { // edge case for pixel to be able to print the correct light value
             move = "Change light to \(cmd.suffix(cmd.count-5))"
         }
         if(!reversed) {
             if commandToEnglish.keys.contains(cmd) {
                 move = commandToEnglish[cmd]
             }
         } else {
             if let opposite =  opposites[cmd] { // edge case for opposites
                 if commandToEnglish.keys.contains(opposite) {
                     move = commandToEnglish[opposite]
                 }
             }
         }
        return move
    }
    
    func funcRecordingAsEnglishSteps(log: [ConsoleLogEntry], reversed: Bool = false) -> [String] {
        // Command that returns a list of all the human readable text for each command in a sequence.
        var steps: [String] = []
        log.enumerated().forEach { logentry in
            if(logentry.offset > 0) {
                if(!reversed) {
                    var time_prev = log[logentry.offset-1].date //time logic for working out how long to send the command for
                    var time_now = log[logentry.offset].date
                    var time_between =  round((time_now.timeIntervalSince1970 - time_prev.timeIntervalSince1970) * 100)/100
                    if let move = cmdtoeng(cmd: log[logentry.offset-1].text) {
                        steps.append("\(move) for \(time_between)s")
                    }
                } else {
                    if(logentry.offset > 1) { //reversed edge case that displays sequence in reverse
                        var time_prev = log.reversed()[logentry.offset-2].date 
                        var time_now = log.reversed()[logentry.offset-1].date
                        var time_between =  round((time_prev.timeIntervalSince1970 - time_now.timeIntervalSince1970) * 100)/100
                        if let move = cmdtoeng(cmd: log.reversed()[logentry.offset-1].text, reversed: true) {
                            steps.append("\(move) for \(time_between)s")
                        }
                    }
                }
            }
//            print("\(logentry.text) for \(logentry.date)")
        }
        steps.append("Stop")
        return steps
    }
    
    func sendData(dataToSend: String) {
        // this command transmits data to the robot
        if let services = dronePeripheral?.services { //get the peripheral available services
            for service in services {
                if service.uuid.uuidString == droneService.uuidString { // find the esp32 service
                    if let characteristic = dronePeripheral?.services { 
                        for characteristic in service.characteristics ?? [] {
                            print(characteristic.uuid.uuidString == droneCharacteristic.uuidString, characteristic.uuid.uuidString)
                            if(characteristic.uuid.uuidString == droneCharacteristic.uuidString) { //find the ESP32 RX characteristic
                                let commandData = dataToSend.data(using: .utf8)!
                                dronePeripheral?.writeValue(commandData, for: characteristic, type: .withResponse) //transmit the message using utf8 via BLE
                                print(dataToSend+"Command sent successfully.")
                                addtoconsole(textToAdd: "TX: "+dataToSend) // add a log entry to the console
                                if(recording) { // add a log entry to the recording log
                                    if let lastEntry = recordingLog.last {
                                        if(dataToSend != lastEntry.text) {
                                            addtorecording(textToAdd: dataToSend)
                                        }
                                    } else {
                                        addtorecording(textToAdd: dataToSend)

                                    }
                                    
                                }
                            }
                        }
                }
                }
            }
        } else {
            print("No services available.")
        }
    }

}

extension BluetoothService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) { //begin scanning for peripherals to connect to
        if central.state == .poweredOn {
            print("CB Powered On")
            scanForPeripherals()
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral.identifier.uuidString, peripheral.name) //on peripheral discover check if UUID is the one we want and if so connect, the UUID is unique between devices and is hard coded for purpose of demo.
        if peripheral.identifier.uuidString == "6DFE398E-8B06-B383-5837-0312D4DFEB32" {
            print("Discovered \(peripheral.name ?? "no name") \(peripheral.identifier.uuidString)")
            dronePeripheral = peripheral
            centralManager.connect(dronePeripheral!)
            peripheralStatus = .connecting
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheralStatus = .connected

        peripheral.delegate = self
        peripheral.discoverServices([droneService]) // discover services available for bluetooth
        centralManager.stopScan() // stop scanning as we are now connected
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        peripheralStatus = .disconnected
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        peripheralStatus = .error
        print(error?.localizedDescription ?? "no error")
    }

}

extension BluetoothService: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print(peripheral.services)
        for service in peripheral.services ?? [] {
            if service.uuid == droneService { // check if service is equal to drone service that we want
                print("found service for \(droneService)") // find characteristics allowing us to RX and TX from CoreBluetooth
                peripheral.discoverCharacteristics([droneCharacteristic, droneTXCharacteristic], for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics ?? [] {
            peripheral.setNotifyValue(true, for: characteristic) // set a handler that manages when the robot sends us data
            print(characteristic.uuid)
            print("found characteristic, waiting on values.")
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // data handling function that receives all data send on the TX characteristic.
        if characteristic.uuid.uuidString == droneTXCharacteristic.uuidString { 
            guard let data = characteristic.value else {
                print("No data received for \(characteristic.uuid.uuidString)")
                return
            }

            print("data received", String(data: data, encoding: .utf8))
            addtoconsole(textToAdd: "RX: "+(String(data: data, encoding: .utf8) ?? "Error")) // add to console what has been received
            var received = String(data: data, encoding: .utf8)
            if let received = received { // guard as received is optional type
                if(received.contains("status")) { // edge case for if there is a status update we need to handle
                    print("status update")
                    var json_string = String(received.suffix(received.count - 7)) // get the last bit of the command after status which we know is the json object
                    do {
                            if let jsonData = json_string.data(using: .utf8) { // serialise the json object from the string that has been transmitted into our local statusValues object.
                                if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                                    statusValues = jsonObject

                                    
                                }
                            }
                        } catch {
                            print("Error parsing JSON: \(error)")
                        }
                }
            }

            
        }
    }

}
