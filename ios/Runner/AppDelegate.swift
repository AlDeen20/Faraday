import UIKit
import Flutter
import FirebaseCore

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate{
    weak var screen : UIView? = nil

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller:FlutterViewController=window?.rootViewController as! FlutterViewController
        let METHOD_CHANNEL_NAME="com.hesham/native-code"
        let recordingChannel=FlutterMethodChannel(name: METHOD_CHANNEL_NAME,
                                                  binaryMessenger: controller.binaryMessenger)
        recordingChannel.setMethodCallHandler({
            (call:FlutterMethodCall,result:@escaping FlutterResult)->Void in

            switch call.method{
            case "isRecording":
                result(self.isRecording())
            default:
                result(FlutterMethodNotImplemented)
            }
        })
        FirebaseApp.configure()
        
        
        GeneratedPluginRegistrant.register(with: self)
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }
        if #available(iOS 11.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(preventScreenRecording), name: UIScreen.capturedDidChangeNotification, object: nil)
        }
        
   
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        
    }
    private func isRecording()->Bool{
        let isCaptured = UIScreen.main.isCaptured
        return isCaptured
    }
    
    @objc func preventScreenRecording() {
        let isCaptured = UIScreen.main.isCaptured
        if isCaptured {
            blurScreen()
        }
        else {
            removeBlurScreen()
        }
    }

    func blurScreen(style: UIBlurEffect.Style = UIBlurEffect.Style.regular) {
        screen = UIScreen.main.snapshotView(afterScreenUpdates: false)
        let blurEffect = UIBlurEffect(style: style)
        let blurBackground = UIVisualEffectView(effect: blurEffect)
        screen?.addSubview(blurBackground)
        blurBackground.frame = (screen?.frame)!
        window?.addSubview(screen!)
    }

    func removeBlurScreen() {
        screen?.removeFromSuperview()
    }
    
     

  
    
    
}
 


