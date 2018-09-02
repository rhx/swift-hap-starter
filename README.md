# swift-hap-starter

A simple Homekit Accessory Protocol (HAP) starter project in Swift that uses
[Bouke Haarsma's excellent HAP package](https://github.com/Bouke/HAP).

## Build and Test

### Prerequistes

#### macOS

Install libsodium using [Homebrew](https://brew.sh/):
```
	brew install libsodium
```

#### Linux

Install the necessary dependencies, e.g. using `apt`:
```
	sudo apt install openssl libssl1.0-dev libsodium-dev
```

### Build and run using the Swift Package Manager
```
swift build -c release
.build/release/swift-hap-starter
```

## Customize

To customise, edit `main.swift` in the `Sources/swift-hap-starter` subdirectory.  Under macOS you might want to create an Xcode project for easier editing:
```
swift package generate-xcodeproj
open swift-hap-starter.xcodeproj
```

## Troubleshooting

### Linux

* The [BlueSignals](https://github.com/IBM-Swift/BlueSignals) dependency package currently does not build under Ubuntu 18.04 against the Swift 4.2-CONVERGENCE toolchain (`error: converting non-escaping value to 'T' may allow it to escape`).

* The [BlueCryptor](https://github.com/IBM-Swift/BlueCryptor) dependency package currently only works with OpenSSL-1.0.x (not 1.1.x or newer).  For older linux distributions, this may be the default, in which case you may want to `apt-get install libssl-dev libcurl4-openssl-dev` (instead of `libssl1.0-dev`, which is required for newer versions of Debian or Ubuntu).

* As of Swift 4.2 beta, ARM-based Linux versions (e.g. for the Raspberry Pi) seem to have a bug that makes them crash.

## Credits

This project would not be possible without the excellent [Swift HAP library](https://github.com/Bouke/HAP) written by [Bouke Haarsma](https://twitter.com/BoukeHaarsma) and [contributors](https://github.com/Bouke/HAP/graphs/contributors).
