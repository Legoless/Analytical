//
//  Analytics.swift
//  Analytical
//
//  Created by Dal Rupnik on 15/09/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
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
        event(track.rawValue, properties: properties)
    }
    
    func track(_ track: Track.Screen, properties: Properties? = nil) {
        screen(track.rawValue, properties: properties)
    }
    
    func time(_ track: Track.Event, properties: Properties? = nil) {
        time(track.rawValue, properties: properties)
    }
    
    func finish(_ track: Track.Event, properties: Properties? = nil) {
        finish(track.rawValue, properties: properties)
    }
}
