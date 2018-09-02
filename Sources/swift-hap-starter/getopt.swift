//
//  getopt.swift
//  posix
//
//  Created by Rene Hexel on 22/03/2016.
//  Copyright © 2016, 2017, 2018 Rene Hexel. All rights reserved.
//
import Foundation

///
/// Wrapper for POSIX `getopt()` to return a Swift tuple.
/// Returns `nil` if the `getopt()` returned -1,
/// otherwise returns a tuple of the option character
/// with an optional argument
///
func get(options: String) -> (Character, String?)? {
    let ch = getopt(CommandLine.argc, CommandLine.unsafeArgv, options)
    guard ch != -1 else { return nil }
    guard let u = UnicodeScalar(UInt32(ch)) else { return nil }
    let option = Character(u)
    let argument: String? = optarg != nil ? String(cString: optarg) : nil
    return (option, argument)
}
