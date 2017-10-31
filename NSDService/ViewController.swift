import UIKit

class ViewController: UIViewController {

    private let nsdHelper = NSDHelper()
    @IBOutlet weak var showText: UITextView!
    @IBOutlet weak var inputText: UITextField!
    @IBOutlet weak var connectBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nsdHelper.delegate = self 
    }
    
    @IBAction func registerBtnTapped(_ sender: Any) {
        nsdHelper.registerSetting()
    }
    
    @IBAction func discoverBtnTapped(_ sender: Any) {
    }
    
    @IBAction func sendBtnTapped(_ sender: Any) {
        showText.text = "\(showText.text)\nme : \(String(describing: inputText.text))"
        nsdHelper.send(sendMsg: inputText.text!)
    }
}

extension ViewController: NSDHelperDelegate {
    func receivedMsg(manager: NSDHelper, msg: String) {
        print("receivedMsg => ",msg)
        showText.text = "\(showText.text!)\nthem : \(msg)"
    }
    
    func connectedDevicesChanged(manager: NSDHelper, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            print("connected Devices => ",connectedDevices)
            if connectedDevices.count > 0 {
                self.connectBtn.titleLabel?.text = "CONNECT"
            } else {
                self.connectBtn.titleLabel?.text = "DISCONNECT"
            }
        }
    }

}

