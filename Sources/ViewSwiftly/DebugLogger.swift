//
//  DebugLogger.swift
//
//
//  Created by Mira Yang on 6/16/24.
//

import Foundation

@inlinable
public func formatLogMessage(_ message: String,
                             file: String = #file,
                             function: String = #function,
                             line: Int = #line) -> String {
    let filename = (file as NSString).lastPathComponent
    return "[\(filename):\(line) \(function)]: \(message)\n"
}


final class Logger {
    static func debug(_ message: @autoclosure () -> String,
                      file: String = #file,
                      function: String = #function,
                      line: Int = #line) {
#if DEBUG
        print(" 💚 " + formatLogMessage(message(), file: file, function: function, line: line))
#endif
    }
    
    static func info(_ message: @autoclosure () -> String,
                     file: String = #file,
                     function: String = #function,
                     line: Int = #line) {
#if DEBUG
        print(" 💛 " + formatLogMessage(message(), file: file, function: function, line: line))
#endif
    }
    
    static func warn(_ message: @autoclosure () -> String,
                     file: String = #file,
                     function: String = #function,
                     line: Int = #line) {
#if DEBUG
        print(" 🧡 " + formatLogMessage(message(), file: file, function: function, line: line))
#endif
    }
    
    static func error(_ message: @autoclosure () -> String,
                      file: String = #file,
                      function: String = #function,
                      line: Int = #line) {
#if DEBUG
        print(" 👹 " + formatLogMessage(message(), file: file, function: function, line: line))
#endif
    }
    
}
