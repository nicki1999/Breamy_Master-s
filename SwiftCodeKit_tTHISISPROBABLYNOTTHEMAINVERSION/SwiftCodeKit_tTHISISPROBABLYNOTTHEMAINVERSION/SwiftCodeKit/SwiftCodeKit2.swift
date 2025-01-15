import SwiftUI
import RealityKit

public class SwiftCodeKit2 {
    public static func start() {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                let viewController = SwiftCodeKitViewController()
                rootViewController.present(viewController, animated: true)
            }            
        }
    }
    
    public static func getVersion() -> String {
        return "Popup Closed"
    }
    

}
public extension SwiftCodeKit2{
    static var swiftCodeKitDidFinish: (() -> Void)?

}
