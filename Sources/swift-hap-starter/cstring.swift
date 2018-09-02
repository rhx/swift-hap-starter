//
//  cstring.swift
//  posix
//
//  Created by Rene Hexel on 2/08/2014.
//  Copyright (c) 2014, 2015, 2016, 2017, 2018 Rene Hexel. All rights reserved.
//
import Foundation

/// Convert a Swift String (or UnsafePointer<Char>) into an
/// UnsafeMutablePointer<CChar> as used by many POSIX functions,
/// then perform a given function or closure with that pointer.
///
/// This is a convenience method, typically used for C functions
/// that take `char *` or `unsigned char *` instead of the expected
/// `const char *`.
///
/// DO NOT USE THIS WITH FUNCTIONS THAT ACTUALLY MUTATE THE GIVEN STRING!
///
/// - Parameters:
///   - cString: C string to perform the given function on
///   - call: function or closure to call
/// - Returns: return value of the given template type `T` (can be `Void`)
public func with<T>(cString: UnsafePointer<CChar>, call: (UnsafeMutablePointer<CChar>) -> T) -> T {
    return call(UnsafeMutablePointer(mutating: cString))
}


/// Convert a Swift String (or UnsafePointer<Char>) into another String
/// using a POSIX function that takes a `const char *` and returns a
/// generic C string pointer.
///
/// - Parameters:
///   - cString: string to convert
///   - using: C function to call for conversion
/// - Returns: a new string from the pointer returned by the C function
public func convert<T>(_ cString: UnsafePointer<CChar>, using: (UnsafePointer<CChar>) -> UnsafePointer<T>) -> String {
    return using(cString).withMemoryRebound(to: CChar.self, capacity: 1) {
        String(cString: $0)
    }
}


/// Convert a Swift String (or UnsafePointer<Char>) into another String
/// using a POSIX function that takes a mutable `char *` and returns a
/// generic, mutable C string pointer.
///
/// - Parameters:
///   - cString: string to convert
///   - using: C function to call for conversion
/// - Returns: a new string from the pointer returned by the C function
public func convert<T>(_ cString: UnsafePointer<CChar>, using: (UnsafeMutablePointer<CChar>?) -> UnsafeMutablePointer<T>?) -> String {
    return with(cString: cString) {
        using($0)?.withMemoryRebound(to: CChar.self, capacity: 1) {
            String(cString: $0)
        } ?? ""
    }
}
