//
//  Log.swift
//  MyWayy
//
//  Created by Robert Hartman on 11/10/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import Foundation

func logDebug(_ message: String, fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
    #if DEBUG
        let string = "\(name(from: fileName)) \(functionName) line \(lineNumber): \(message)"
        print(string)
    #endif
}

func logError(_ message: String? = nil, fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
    var string = "ERROR \(name(from: fileName)) \(functionName) line \(lineNumber)"
    if let m = message {
        string += ": \(m)"
    }
    print(string)
}

func logTrace(_ fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
    #if DEBUG
        let string = "\(name(from: fileName)) \(functionName) line \(lineNumber): trace"
        print(string)
    #endif
}

func logUnexpectedCase(_ message: String) {
    logError("Unexpected case: " + message)
}

func raiseMustOverrideException(_ fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
    NSException.raise(NSExceptionName.internalInconsistencyException, format: "\(name(from: fileName)) \(functionName)( \(lineNumber) This is an abstract class; descendants must override %@!", arguments: getVaList([#function]))
}

private func name(from fileName: String) -> String {
    return NSURL(fileURLWithPath: fileName).deletingPathExtension?.lastPathComponent ?? NSString(string: fileName).lastPathComponent
}
