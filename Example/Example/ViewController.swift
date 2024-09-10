import UIKit
import Accelera

class Log {
    
    public static let shared = Log();
    
    init() {
        
    }
    
    private var _view: UITextView?
    public var view: UITextView {
        get {
            return _view ?? UITextView()
        }
        set {
            self._view = newValue
        }
    }
    
    public func info(_ text: String) {
        let newDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.setLocalizedDateFormatFromTemplate("HH:mm:ss")
        let displayDate = dateFormatter.string(from: newDate) + ": "
       
        let newLogText = displayDate + text + "\n"
        
        view.text += newLogText + "\n"
        
        let location = view.text.count - 1
        let bottom = NSMakeRange(location, 1)
        view.scrollRangeToVisible(bottom)
    }
}

class ViewController: UIViewController {
        
    override func viewWillAppear(_ animated: Bool) {
        Log.shared.view = logTextView;
    }
    
    override func viewDidLoad() {
        
    }
    
    @IBAction func requestPushNotifications(_ sender: Any) {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.badge, .alert, .sound]) { (granted, _) in
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
    }
    
    @IBAction func setUserProfile(_ sender: Any) {
        Accelera.shared.setUserInfo("{\"clientId\": \"123\", \"email\": \"john@example.com\"}")
    }
    
    
    @IBOutlet weak var logTextView: UITextView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        //accelera?.logEvent(string: "{\"event\": \"some_event\"}")
        Accelera.shared.delegate = self
        //accelera?.loadBanner()
    }
}

extension ViewController: AcceleraDelegate {
//    func bannerViewReady(view: UIView, type: AcceleraBannerType) {
//        print("bannerViewReady")
//        //view.alpha = 0.0
//        //view.center = self.view.center
////        view.transform = CGAffineTransformMakeScale(0, 0)
//        //self.view.addSubview(view)
////
////        UIView.animate(withDuration: 2, delay: 0,
////                       usingSpringWithDamping: 0.2, initialSpringVelocity: 0, options: [], animations: {
////            view.transform = CGAffineTransformMakeScale(1, 1)
////        }, completion: nil)
//        
////        UIView.animate(withDuration: 1) {
////            //view.alpha = 1.0
////            //self.view.layoutIfNeeded()
////            view.transform = CGAffineTransformMakeScale(1, 1)
////        }
//    }
//    
//    func noBannerView() {
//        print("noBannerView")
//    }
//    
//    func bannerViewClosed() -> Bool? {
//        print("bannerViewClosed")
//        return true
//    }
//    
//    func bannerViewAction(action: String?) -> Bool? {
//        print(action)
//        return false
//    }
    
    func log(_ message: String) {
        Log.shared.info(message)
    }
}
