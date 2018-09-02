//
//  swift-hap-starter
//
//  Created by Rene Hexel on 25/11/2017.
//  Copyright © 2017, 2018 Rene Hexel. All rights reserved.
//
import Foundation
import Dispatch
import HAP

enum AccessoryKind: String {
    case light
    case outlet
    case `switch`
}

let args = CommandLine.arguments
let cmd = args[0]                   ///< command name
var name = convert(cmd, using: basename)
var reset = false                   ///< reset and recreate config
var alwaysPrintQR = false           ///< always display QR code in terminal
var verbosity = 1                   ///< verbosity level
var port = 0                        ///< port to listen on (0 = random)
var pin = Device.SetupCode.random   ///< start with a random setup code
var pinSpecified = false            ///< pin was given on the command line
var vendor = "AVendor"              ///< default vendor
var type = "Some Device"            ///< type of device
var serial = "123"                  ///< serial number
var version = "1.0.0"               ///< version
var kind = AccessoryKind.outlet     ///< device kind
var customConfig: String?

fileprivate func usage() -> Never {
    print("Usage: \(cmd) <options>")
    print("Options:")
    print("  -c <config_file>   custom JSON configuration file to use")
    print("  -d                 print debug output")
    print("  -f <version>       firmware version [\(version)]")
//    print("  -h <host>          host device [\(host)]")
    print("  -k <accessorykind> \(AccessoryKind.light.rawValue), \(AccessoryKind.outlet.rawValue), or \(AccessoryKind.switch.rawValue) [\(kind.rawValue)]")
    print("  -l <port>          listen on specific port")
    print("  -m <manufacturer>  name of the manufacturer [\(vendor)]")
    print("  -n <name>          name of the HomeKit bridge [\(name)]")
//    print("  -p <port>          broadcast to <port> instead of \(outp)")
    print("  -q                 turn off all non-critical logging output")
    print("  -Q                 print QR code (default unless -S is passed in)")
    print("  -R                 reset and recreate configuration")
    print("  -s <SECRET_PIN>    HomeKit PIN for authentication [random]")
    print("  -S <serial>        Device serial number [\(serial)]")
    print("  -t <type>          name of the model/type [\(type)]")
    print("  -v                 increase logging verbosity\n")
    exit(EXIT_FAILURE)
}

while let result = get(options: "c:df:h:k:l:m:n:p:qQRs:S:t:v") {
    let option = result.0
    let arg = result.1
    switch option {
    case "c": customConfig = arg
    case "d": verbosity = 9
    case "f": version = arg!
//    case "h": host = arg!
    case "k": kind = AccessoryKind(rawValue: arg!)!
    case "l": if let p = Int(arg!) {
        port = p
    } else { usage() }
    case "m": vendor = arg!
    case "n": name = arg!
//    case "p": if let p = Int(arg!) {
//        outp = p
//    } else { usage() }
    case "q": verbosity  = 0
    case "Q": alwaysPrintQR = true
    case "s": pin = .override(arg!) ; pinSpecified = true
    case "S": serial = arg!
    case "t": type = arg!
    case "v": verbosity += 1
    default:
        print("Unknown option \(option)!")
        usage()
    }
}

let fm = FileManager.default
let pathURL = try! fm.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(name)
try? fm.createDirectory(at: pathURL, withIntermediateDirectories: true)
let config = customConfig ?? pathURL.appendingPathComponent("configuration.json").path
let configExists = fm.fileExists(atPath: config)
let db = FileStorage(filename: config)
if !configExists { RunLoop.main.run(until: Date(timeIntervalSinceNow: 2)) }

let serviceInfo = Service.Info(name: name, serialNumber: serial, manufacturer: vendor, model: type, firmwareRevision: version)
let accessory: Accessory
switch kind {
case .light:  accessory = Accessory.Lightbulb(info: serviceInfo)
case .outlet: accessory = Accessory.Outlet(info: serviceInfo)
case .switch: accessory = Accessory.Switch(info: serviceInfo)
}
let device = Device(bridgeInfo: Service.Info(name: name + "-bridge", serialNumber: serial, manufacturer: vendor, model: type, firmwareRevision: version), setupCode: pin, storage: db, accessories: [accessory])

var active = true
signal(SIGINT) { sig in
    DispatchQueue.main.async {
        active = false
        if verbosity > 0 { fputs("Caught signal \(sig) - stopping!\n", stderr) }
    }
}

//
// get/set the device status
//
var deviceStatus: Bool? {
    get {
        switch accessory {
        case let light as Accessory.Lightbulb: return light.lightbulb.on.value
        case let outlet as Accessory.Outlet: return outlet.outlet.on.value
        case let `switch` as Accessory.Switch: return `switch`.switch.on.value
        default: return nil
        }
    }
    set {
        if verbosity > 0 { print("Setting \(String(describing: newValue))") }
        switch accessory {
        case let a as Accessory.Lightbulb: a.lightbulb.on.value = newValue
        case let a as Accessory.Outlet:    a.outlet.on.value    = newValue
        case let a as Accessory.Switch:    a.switch.on.value    = newValue
        default: return
        }
    }
}

//
// Customise this class to handle device callbacks
//
class HAPDeviceDelegate: DeviceDelegate {
    func didRequestIdentification() {
        print(" *** Bridge Identification: \(name)-bridge")
    }
    func didRequestIdentificationOf(_ accessory: Accessory) {
        print(" *** Accessory Identification: \(accessory.info.name.value ?? name)")
    }
    func characteristicListenerDidSubscribe(_ accessory: Accessory, service: Service, characteristic: AnyCharacteristic) {
        print("Subscription for characteristic \(characteristic) for service \(service.type) of accessory \(accessory.info.name.value ?? name)")
    }
    func characteristicListenerDidUnsubscribe(_ accessory: Accessory, service: Service, characteristic: AnyCharacteristic) {
        print("Unsubscribe received for characteristic \(characteristic) of service \(service.type) of accessory \(accessory.info.name.value ?? name)")
    }
    func characteristic<T>(_ characteristic: GenericCharacteristic<T>, ofService service: Service, ofAccessory accessory: Accessory, didChangeValue newValue: T?) {
        print(" --> Characteristic \(characteristic) of service \(service.type) of accessory \(accessory.info.name.value ?? name) changed to: \(String(describing: newValue))")
        switch newValue {
        case let s as Bool?: print(" --> \(s != nil ? "\(s!)" : "<unset>")")
        default: print("Unknown value")
        }
    }
}


let delegate = HAPDeviceDelegate()
device.delegate = delegate

let server = try Server(device: device, port: port)
server.start()

if alwaysPrintQR || !pinSpecified {
    let qr = device.setupQRCode.asBigText
    try? qr.write(to: pathURL.appendingPathComponent("qr.txt"), atomically: true, encoding: .utf8)
    print("\nQR Code for pairing:\n\n\(qr)\n")
}

withExtendedLifetime([delegate]) {
    while active {
        RunLoop.current.run(until: Date().addingTimeInterval(2))
        deviceStatus = !(deviceStatus ?? false)
    }
}

if verbosity > 2 { fputs("Stopping server.\n", stderr) }
server.stop()
if verbosity > 0 { fputs("Exiting.\n", stderr) }
