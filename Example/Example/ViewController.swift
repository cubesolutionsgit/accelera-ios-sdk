import UIKit
import Accelera

class ViewController: UIViewController {
    
    var accelera: Accelera?
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        accelera = Accelera(
            config: AcceleraConfig(
                token: "Token",
                url: "https://flow2.accelera.ai",
                userId: "userId"
            )
        )
        //accelera?.logEvent(string: "{\"event\": \"some_event\"}")
        accelera?.delegate = self
        accelera?.loadBanner()
    }
}

extension ViewController: AcceleraDelegate {
    func bannerViewReady(view: UIView, type: AcceleraBannerType) {
        print("bannerViewReady")
        //view.alpha = 0.0
        //view.center = self.view.center
//        view.transform = CGAffineTransformMakeScale(0, 0)
        self.view.addSubview(view)
//
//        UIView.animate(withDuration: 2, delay: 0,
//                       usingSpringWithDamping: 0.2, initialSpringVelocity: 0, options: [], animations: {
//            view.transform = CGAffineTransformMakeScale(1, 1)
//        }, completion: nil)
        
//        UIView.animate(withDuration: 1) {
//            //view.alpha = 1.0
//            //self.view.layoutIfNeeded()
//            view.transform = CGAffineTransformMakeScale(1, 1)
//        }
    }
    
    func noBannerView() {
        print("noBannerView")
    }
    
    func bannerViewClosed() -> Bool? {
        print("bannerViewClosed")
        return true
    }
    
    func bannerViewAction(action: String?) -> Bool? {
        print(action)
        return false
    }
}
