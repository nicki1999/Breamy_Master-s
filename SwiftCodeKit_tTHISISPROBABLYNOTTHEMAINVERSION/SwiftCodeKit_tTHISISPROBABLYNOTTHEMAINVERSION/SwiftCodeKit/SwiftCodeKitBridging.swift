@_cdecl("startSwiftCodeKitController")
public func startSwiftCodeKitController() {
    SwiftCodeKit2.start()
}

@_cdecl("swiftCodeKitGetVersion")
public func swiftCodeKitGetVersion() -> UnsafePointer<CChar>? {
    let string = strdup(SwiftCodeKit2.getVersion())
    return UnsafePointer(string)
}

@_cdecl("setSwiftCodeKitDidFinish")
public func setSwiftCodeKitDidFinish(delegate: @convention(c) @escaping () -> Void) {
    SwiftCodeKit2.swiftCodeKitDidFinish = delegate
}
