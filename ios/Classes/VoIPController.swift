//
//  VoIPController.swift
//  connectycube_flutter_call_kit
//
//  Created by Tereha on 19.11.2021.
//

import Foundation
import PushKit

class VoIPController : NSObject{
    let callKitController: CallKitController
    var tokenListener : ((String)->Void)?
    var voipToken: String?
    
    public required init(withCallKitController callKitController: CallKitController) {
        self.callKitController = callKitController
        super.init()
        
        //http://stackoverflow.com/questions/27245808/implement-pushkit-and-test-in-development-behavior/28562124#28562124
        let pushRegistry = PKPushRegistry(queue: .main)
        pushRegistry.delegate = self
        pushRegistry.desiredPushTypes = Set<PKPushType>([.voIP])
    }
    
    func getVoIPToken() -> String? {
        return voipToken
    }
}

//MARK: VoIP Token notifications
extension VoIPController: PKPushRegistryDelegate {
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        if pushCredentials.token.count == 0 {
            print("[VoIPController][pushRegistry] No device token!")
            return
        }
        
        print("[VoIPController][pushRegistry] token: \(pushCredentials.token)")
        
        let deviceToken: String = pushCredentials.token.reduce("", {$0 + String(format: "%02X", $1) })
        print("[VoIPController][pushRegistry] deviceToken: \(deviceToken)")
        
        self.voipToken = deviceToken
        
        if tokenListener != nil {
            print("[VoIPController][pushRegistry] notify listener")
            tokenListener!(self.voipToken!)
        }
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        print("[VoIPController][pushRegistry][didReceiveIncomingPushWith] payload: \(payload.dictionaryPayload)")
        
        let callData = payload.dictionaryPayload

        if type == .voIP {
            if  let data = callData["data"] as? [String: Any], 
                let avatarURL = data["avatar_url"] as? String,
                let callTypeString = data["call_type"] as? String,
                let conversationSID = data["conversation_sid"] as? String,
                let id = data["id"] as? String,
                let name = data["name"] as? String,
                let status = data["status"] as? String,
                let title = data["title"] as? String,
                let token = data["token"] as? String {

                    if (status != "ringing") {
                        self.callKitController.reportCallEnded(uuid: UUID(uuidString: id)!, reason: CXCallEndedReason.remoteEnded);
                        completion()
                        return
                    }

                    let callOpponentsString = "0"
                    let callOpponents = callOpponentsString.components(separatedBy: ",").map { Int($0) ?? 0 }
                    let callType = callTypeString == "voice_call" ? 0 : 1
                    self.callKitController.reportIncomingCall(uuid: id, callType: callType, callInitiatorId: 0, callInitiatorName: name, opponents: callOpponents, userInfo: convertToJSON(dictionary: data)) { (error) in
                        completion()
                        if(error == nil){
                            print("[VoIPController][didReceiveIncomingPushWith] reportIncomingCall SUCCESS")
                        } else {
                            print("[VoIPController][didReceiveIncomingPushWith] reportIncomingCall ERROR: \(error?.localizedDescription ?? "none")")
                        }
                    }
            } else {
                completion()
                print("Payload is nil, invalid fields or not a dictionary")
            }
        } else {
            completion()
        }
    }

func convertToJSON(dictionary: [String: Any]) -> String? {
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
        let jsonString = String(data: jsonData, encoding: .utf8)
        return jsonString
    } catch {
        print("Error converting to JSON: \(error.localizedDescription)")
        return nil
    }
}
}
          