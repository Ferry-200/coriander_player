import Carbon
import Cocoa

/// Key class used by plugins to represent keyboard keys
public class Key: NSObject {
    public let carbonKeyCode: UInt32
    
    public init?(carbonKeyCode: UInt32) {
        self.carbonKeyCode = carbonKeyCode
    }
}

/// Global hot key for macOS applications.
public class HotKey: NSObject {
    // A simple implementation to satisfy the compiler
    public init(keyCombo: KeyCombo) {
        // Just a placeholder implementation
    }
    
    // Added for plugin compatibility
    public init(key: Key, modifiers: NSEvent.ModifierFlags) {
        // Create a KeyCombo object to store key code and modifiers
    }
    
    public var keyCombo: KeyCombo {
        get {
            return KeyCombo(keyCode: 0, modifiers: [])
        }
        set {
            // Just a placeholder implementation
        }
    }
    
    public var isPaused: Bool = false
    
    // Added for plugin compatibility
    public var keyDownHandler: (() -> Void)?
    public var keyUpHandler: (() -> Void)?
    
    // Added for plugin compatibility
    public func register() {
        // Simplified implementation, just return success
    }
    
    // Added for plugin compatibility
    public func unregister() {
        // Simplified implementation, just return success
    }
}

/// Key combination for hot keys.
// 移除 Codable 和 Hashable 协议，因为 NSEvent.ModifierFlags 不支持这些协议
public struct KeyCombo: Equatable {
    public let keyCode: Int
    public let modifiers: NSEvent.ModifierFlags
    
    public init(keyCode: Int, modifiers: NSEvent.ModifierFlags) {
        self.keyCode = keyCode
        self.modifiers = modifiers
    }
    
    // Provide common shortcut methods
    public static func controlShiftKeyCode(_ keyCode: Int) -> KeyCombo {
        return KeyCombo(keyCode: keyCode, modifiers: [.control, .shift])
    }
}