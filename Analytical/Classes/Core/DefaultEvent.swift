//
//  DefaultEvent.swift
//  Analytical
//
//  Created by Dal Rupnik on 16/09/2017.
//  Copyright © 2017 Unified Sense. All rights reserved.
//

import Foundation

/// Some providers may not support logging certain events separately. Analytical still logs those events,
/// using Analytical methods, but default event names are used instead and are tracked as normal events.
/// - Purchase:            Log a purchase
/// - ScreenView:          Log a screen view
/// - PushNotification:    Log a received push notification
/// - SignUp:              Log a sign up
public enum DefaultEvent : String {
    case activated              = "AnalyticalActivated"
    
    case purchase               = "AnalyticalEventPurchase"
    case screenView             = "AnalyticalEventScreenView"
    case pushNotification       = "AnalyticalEventPushNotification"
    case signUp                 = "AnalyticalSignUp"
    case login                  = "AnalyticalLogin"
    case viewContent            = "AnalyticalViewContent"
    case share                  = "AnalyticalShare"
    case search                 = "AnalyticalSearch"
    case searchResults          = "AnalyticalSearchResults"
    
    case spendCredits           = "AnalyticalSpendCredits"
    case earnCredits            = "AnalyticalEarnCredits"
    
    // Common events from Facebook SDK
    case achievedLevel          = "AnalyticalAchievedLevel"
    case addedPaymentInfo       = "AnalyticalAddedPaymentInfo"
    case addedToCart            = "AnalyticalAddedToCart"
    case addedToWishlist        = "AnalyticalAddedToWishlist"
    case completedRegistration  = "AnalyticalCompletedRegistration"
    
    case completedTutorial      = "AnalyticalCompletedTutorial"
    case initiatedCheckout      = "AnalyticalInitiatedCheckout"
    case rating                 = "AnalyticalRating"
    
    case unlockedAchievement    = "AnalyticalUnlockedAchievement"
    
    case contact                = "AnalyticalContact"
    case customizeProduct       = "AnalyticalCustomizeProduct"
    case donate                 = "AnalyticalDonate"
    case findLocation           = "AnalyticalFindLocation"
    case schedule               = "AnalyticalSchedule"
    
    case startTrial             = "AnalyticalStartTrial"
    case submitApplication      = "AnalyticalSubmitApplication"
    case subscribe              = "AnalyticalSubscribe"
    case subscriptionHeartbeat  = "AnalyticalSubscriptionHeartbeat"
    case adImpression           = "AnalyticalAdImpression"
    case adClick                = "AnalyticalAdClick"
    
    // Common events from Firebase SDK
    case checkoutProgress       = "AnalyticalCheckoutProgress"
    case campaignEvent          = "AnalyticalCampaignEvent"
    
    case generateLead           = "AnalyticalGenerateLead"
    case joinGroup              = "AnalyticalJoinGroup"
    case levelUp                = "AnalyticalLevelUp"
    case postScore              = "AnalyticalPostScore"
    case presentOffer           = "AnalyticalPresentOffer"
    case refund                 = "AnalyticalRefund"
    case removeFromCart         = "AnalyticalRemoveFromCart"
    case checkoutOption         = "AnalyticalCheckoutOption"
    
    case viewItem               = "AnalyticalViewItem"
    case viewItemList           = "AnalyticalViewItemList"
    
    case beginTutorial          = "AnalyticalBeginTutorial"
    
    // Common events from AppsFlyer SDK
    case invite                 = "AnalyticalEventInvite"
    case travelBooking          = "AnalyticalEventTravelBooking"
}

public extension DefaultEvent {
    func event() -> AnalyticalEvent {
        return AnalyticalEvent(type: .default, name: self.rawValue, properties: nil)
    }
}
