//
//  ViewController.swift
//  VoIP Test
//
//  Created by Alex Agarkov on 28.09.2022.
//

import UIKit
import CallKit
import PushKit

class ViewController: UIViewController, CXProviderDelegate, PKPushRegistryDelegate {

    override func viewDidLoad() {
        let registry = PKPushRegistry(queue: nil)
        registry.delegate = self
        registry.desiredPushTypes = [PKPushType.voIP]
    }

    func providerDidReset(_ provider: CXProvider) {
        
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        action.fulfill()
    }

    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        print(pushCredentials.token.map { String(format: "%02.2hhx", $0) }.joined())
    }

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        print(payload.dictionaryPayload)
        let config = CXProviderConfiguration()
        //config.iconTemplateImageData = UIImage(named: "pizza")!.pngData()
        config.ringtoneSound = "ringtone.caf"
        config.includesCallsInRecents = false;
        config.supportsVideo = true;
        let provider = CXProvider(configuration: config)
        provider.setDelegate(self, queue: nil)
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: (payload.dictionaryPayload["displayName"] as? String ?? ""))
        let video = payload.dictionaryPayload["video"] as? Bool ?? false
        update.hasVideo = video
        provider.reportNewIncomingCall(with: UUID(), update: update, completion: { error in })
    }

}
