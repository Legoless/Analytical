//
//  Mixpanel.swift
//  Mixpanel
//
//  Created by Yarden Eitan on 6/1/16.
//  Copyright © 2016 Mixpanel. All rights reserved.
//

import Foundation

/// The primary class for integrating Mixpanel with your app.
public class Mixpanel {

    /**
     Initializes an instance of the API with the given project token.

     Returns a new Mixpanel instance API object. This allows you to create more than one instance
     of the API object, which is convenient if you'd like to send data to more than
     one Mixpanel project from a single app.

     - parameter token:         your project token
     - parameter launchOptions: Optional. App delegate launchOptions
     - parameter flushInterval: Optional. Interval to run background flushing
     - parameter instanceName:  Optional. The name you want to call this instance

     - important: If you have more than one Mixpanel instance, it is beneficial to initialize
     the instances with an instanceName. Then they can be reached by calling getInstance with name.

     - returns: returns a mixpanel instance if needed to keep throughout the project.
     You can always get the instance by calling getInstance(name)
     */
    public class func initialize(token apiToken: String,
                                 launchOptions: [NSObject: AnyObject]? = nil,
                                 flushInterval: Double = 60,
                                 instanceName: String = NSUUID().UUIDString) -> MixpanelInstance {
        return MixpanelManager.sharedInstance.initialize(token:         apiToken,
                                                         launchOptions: launchOptions,
                                                         flushInterval: flushInterval,
                                                         instanceName:  instanceName)
    }

    /**
     Gets the mixpanel instance with the given name

     - parameter name: the instance name

     - returns: returns the mixpanel instance
     */
    public class func getInstance(name name: String) -> MixpanelInstance? {
        return MixpanelManager.sharedInstance.getInstance(name: name)
    }

    /**
     Returns the main instance that was initialized.

     If not specified explicitly, the main instance is always the last instance added

     - returns: returns the main Mixpanel instance
     */
    public class func mainInstance() -> MixpanelInstance {
        return MixpanelManager.sharedInstance.getMainInstance()!
    }

    /**
     Sets the main instance based on the instance name

     - parameter name: the instance name
     */
    public class func setMainInstance(name name: String) {
        MixpanelManager.sharedInstance.setMainInstance(name: name)
    }

    /**
     Removes an unneeded Mixpanel instance based on its name

     - parameter name: the instance name
     */
    public class func removeInstance(name name: String) {
        MixpanelManager.sharedInstance.removeInstance(name: name)
    }

}

class MixpanelManager {

    static let sharedInstance = MixpanelManager()
    private var instances: [String: MixpanelInstance]
    private var mainInstance: MixpanelInstance?

    init() {
        instances = [String: MixpanelInstance]()
        Logger.addLogging(PrintLogging())
    }

    func initialize(token apiToken: String,
                    launchOptions: [NSObject: AnyObject]?,
                    flushInterval: Double,
                    instanceName: String) -> MixpanelInstance {
        let instance = MixpanelInstance(apiToken: apiToken,
                                        launchOptions: launchOptions,
                                        flushInterval: flushInterval)
        mainInstance = instance
        instances[instanceName] = instance

        return instance
    }

    func getInstance(name instanceName: String) -> MixpanelInstance? {
        guard let instance = instances[instanceName] else {
            Logger.warn(message: "no such instance: \(instanceName)")
            return nil
        }
        return instance
    }

    func getMainInstance() -> MixpanelInstance? {
        return mainInstance
    }

    func setMainInstance(name instanceName: String) {
        guard let instance = instances[instanceName] else {
            return
        }
        mainInstance = instance
    }

    func removeInstance(name instanceName: String) {
        instances[instanceName] = nil
    }

}
