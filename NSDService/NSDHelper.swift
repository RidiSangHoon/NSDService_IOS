
import Foundation
import MultipeerConnectivity

protocol NSDHelperDelegate {
    func receivedMsg(manager: NSDHelper, msg: String)
    func connectedDevicesChanged(manager: NSDHelper, connectedDevices: [String])
}

class NSDHelper : NSObject {
    
    public var delegate: NSDHelperDelegate?
    
    private let devicePeerId = MCPeerID(displayName: UIDevice.current.name)
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrower: MCNearbyServiceBrowser
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.devicePeerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    
    func send(sendMsg: String) {
        if session.connectedPeers.count > 0 {
            do {
                try self.session.send(sendMsg.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            } catch let error {
                print("Error for sending: \(error)")
            }
        }
    }
    
    override init() {
        
        print("display name => ",devicePeerId.displayName)
        
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: devicePeerId, discoveryInfo: nil, serviceType: "NsdChat")
        self.serviceBrower = MCNearbyServiceBrowser(peer: devicePeerId, serviceType: "NsdChat")
        super.init()
        
        self.serviceBrower.delegate = self
        self.serviceBrower.startBrowsingForPeers()
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrower.stopBrowsingForPeers()
    }
    
    func registerSetting() {
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
    }
}

extension NSDHelper : MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("NSD Helper did not start advertising peer")
    }
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("did Receive Invitation From Peer \(peerID)")
        invitationHandler(true, self.session)
    }
}

extension NSDHelper: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost Peer : \(peerID)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("Did not start browsing for peers : \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("found Peer => \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 20)
    }
}

extension NSDHelper : MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if state == MCSessionState.connected{
            print("connected!!!")
            
        } else if state == MCSessionState.connecting {
            print("Connecting....")
        } else if state == MCSessionState.notConnected {
            print("Not Connected!!")
        }
        self.delegate?.connectedDevicesChanged(manager: self, connectedDevices:
            session.connectedPeers.map{$0.displayName})
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("didReceiveData \(data)")
        let str = String(data: data, encoding: .utf8)!
        self.delegate?.receivedMsg(manager: self, msg: str)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("didReceiveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("didFinishReceivingResourceWithName")
    }
}
