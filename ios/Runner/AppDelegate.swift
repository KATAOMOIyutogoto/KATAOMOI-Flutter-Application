import Flutter
import UIKit
import CoreNFC

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // NFC機能のサポート確認
    if NFCNDEFReaderSession.readingAvailable {
      print("NFC機能が利用可能です")
    } else {
      print("NFC機能が利用できません")
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // ディープリンクのサポート
  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    // kataomoiapp:// スキームのサポート
    if url.scheme == "kataomoiapp" {
      print("ディープリンク受信: \(url)")
      return true
    }
    return super.application(app, open: url, options: options)
  }
}
