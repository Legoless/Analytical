//
//  Analytics.swift
//  Analytical
//
//  Created by Dal Rupnik on 15/09/16.
//  Copyright © 2016 Unified Sense. All rights reserved.
//

import Analytical
import AdSupport

public enum Track {
    public enum Event : String {
        case secondScreenTap  = "SecondScreenTap"
        case closeTap = "CloseTap"
    }
    
    public enum Screen : String {
        case first  = "first"
        case second = "second"
    }
}

//let analytics = Analytics() <<~ GoogleProvider(trackingId: "<TRACKING-ID>") <<~ MixpanelProvider(token: "<MIXPANEL-ID>") <<~ FacebookProvider()

func provider(type: IdentifierType) -> UUID? {
    switch type {
    case .idfv:
        return UIDevice.current.identifierForVendor
    case .idfa:
        return ASIdentifierManager.shared().isAdvertisingTrackingEnabled ? ASIdentifierManager.shared().advertisingIdentifier : nil
    }
}

let analytics = Analytics(identityProvider: provider) <<~ LogProvider()

extension AnalyticalProvider {
    func track(event: Track.Event, properties: Properties? = nil) {
        self.event(name: event.rawValue, properties: properties)
    }
    
    func track(screen: Track.Screen, properties: Properties? = nil) {
        self.screen(name: screen.rawValue, properties: properties)
    }
    
    func time(event: Track.Event, properties: Properties? = nil) {
        self.time(name: event.rawValue, properties: properties)
    }
    
    func finish(event: Track.Event, properties: Properties? = nil) {
        self.finish(name: event.rawValue, properties: properties)
    }
}
