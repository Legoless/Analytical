//
//  Analytics.swift
//  Analytical
//
//  Created by Dal Rupnik on 15/09/16.
//  Copyright © 2016 Unified Sense. All rights reserved.
//

import Analytical

public enum Track {
    public enum Event : String {
        case simpleTap  = "SimpleTap"
        case anotherTap = "AnotherTap"
    }
    
    public enum Screen : String {
        case first  = "first"
        case second = "second"
    }
}

let analytics = Analytics() <<~ GoogleProvider(trackingId: "<TRACKING-ID>") <<~ MixpanelProvider(token: "<MIXPANEL-ID>") <<~ FacebookProvider()

extension Analytical {
    func track(_ track: Track.Event, properties: Properties? = nil) {
        event(name: track.rawValue, properties: properties)
    }
    
    func track(_ track: Track.Screen, properties: Properties? = nil) {
        screen(name: track.rawValue, properties: properties)
    }
    
    func time(_ track: Track.Event, properties: Properties? = nil) {
        time(name: track.rawValue, properties: properties)
    }
    
    func finish(_ track: Track.Event, properties: Properties? = nil) {
        finish(name: track.rawValue, properties: properties)
    }
}
