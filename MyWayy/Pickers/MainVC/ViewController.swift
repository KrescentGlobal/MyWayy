
import UIKit

class ViewController: UIViewController {

    
    var count = 0;
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.normalTap(_:)))
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress(_:)))
        tapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture)
        self.view.addGestureRecognizer(longGesture)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        count = 0
    }
    
      @objc func normalTap(_ sender: UITapGestureRecognizer) {
        if count > 1 {
           self.performSegue(withIdentifier: "settings", sender: self)
        }
        
    }
    
    @objc func longPress(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == .ended {
            print("UIGestureRecognizerStateEnded")
            count = count + 1
            //Do Whatever You want on End of Gesture
        }
        else if sender.state == .began {
            print("UIGestureRecognizerStateBegan.")
            //Do Whatever You want on Began of Gesture
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func scanAc(_ sender: Any) {
        let nxtVc = self.storyboard?.instantiateViewController(withIdentifier: "cameraNav") as! UINavigationController
        self.present(nxtVc, animated: true, completion: nil)
    }
    
}

