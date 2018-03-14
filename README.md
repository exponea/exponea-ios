iOS SDK
=======
The Exponea iOS SDK is available at this Git repository: [https://github.com/exponea/exponea-ios](https://github.com/exponea/exponea-ios).

Installation
------------

* Download the [latest release](https://github.com/exponea/exponea-ios/releases) of the iOS SDK
* Unzip / untar the downloaded SDK into a preferred directory
* Locate file **ExponeaSDK.xcodeproj** in the unpacked SDK directory
* Drag &amp; drop the file **ExponeaSDK.xcodeproj** to your **XCode project** in **Project navigator**
* In XCode, click on your project in Project navigator, scroll down the **General tab** and locate **Embedded Binaries** section
* Click on the **Plus sign** button (titled *Add items*)
* In the newly opened dialog window, please select **ExponeaSDK.framework** under *< Your project >* > ExponeaSDK.xcodeproj > Products and click **Add**)

* (Swift only) In your project create a new Objective-C file with **File -> New** and choose Objective-C.
* (Swift only) Accept the prompt asking whether you want to create Bridging Header from Objective-C to Swift.
* (Swift only) Delete the newly created Objective-C file but keep the **.h bridging header file**.
* (Swift only) In the bridging header file write `#import <ExponeaSDK/Exponea.h>`
* (Swift only) In **AppDelegate** file add an import statement `import ExponeaSDK`
* (Swift only) More info about the bridging process can be found [here](https://stackoverflow.com/questions/24272184/connect-objective-c-framework-to-swift-ios-8-app-parse-framework/24272545#24272545)
After completing the steps above, the Exponea iOS SDK should be included in your app, ready to be used.

Usage
-----
### Basic Interface ###

Once the IDE is set up, you may start using the Exponea library in your code. Firstly, you need to import main header file **ExponeaSDK.h** with the following code:  ```#import <ExponeaSDK/ExponeaSDK.h> ```. Secondly, you need to know the URI of your Exponea API instance (usually  ```https://api.exponea.com ```)and your project  ```token ``` (located on the Project management / Overview page in the web application). To interact with the Exponea SDK, you need to obtain a shared instance of the Exponea class using the project  `token` (the URI parameter is optional). You can do this initialization in AppDelegate file.

```
// Objective-C
// Use public Exponea instance
[Exponea getInstance:@"projectToken"];
// Use custom Exponea instance
[Exponea getInstance:@"projectToken" andWithTarget:@"http://url.to.your.instance.com"];
```
```
// Swift
// Use public Exponea instance
Exponea.getInstance("projectToken")
// Use custom Exponea instance
Exponea.getInstance("projectToken", andWithTarget: "http://url.to.your.instance.com")
```

To start tracking, the customer needs to be identified with their unique  `customerId`. The unique  `customerId` can either be an instance of NSString, or NSDictionary representing the  `customerIds` as referenced in [the API guide](http://guides.exponea.com/technical-guide/rest-client-api/). Setting

```
// Objective-C
NSString *customerId = @"123-foo-bar";
// or
NSDictionary *customerId = @{@"registered": @"123-foo-bar"};
```
```
// Swift
var customerId = "123-foo-bar"
// or
var customerId = ["registered": "123-foo-bar"]
```

In order to identify a customer, call one of the `identifyWithCustomer` or `identifyWithCustomerDict` methods on the obtained Exponea instance as follows:

```
// Objective-C
// Identify a customer with their NSString customerId
[Exponea identify:customerId];
// Identify a customer with their NSDictionary customerId
[Exponea identifyWithCustomerDict:customerId];
```
```
// Swift
// Identify a customer with their String customerId
Exponea.identify(customerId)
// Identify a customer with their Dictionary customerId
Exponea.identify(withCustomerDict: customerId)
```

The identification is performed asynchronously and there is no need to wait for it to finish. Until they are sent to the Exponea API, all tracked events are stored in the internal SQL database.

You may track any event by calling the  `track` method on the Exponea instance. The  `track` method takes one mandatory and two optional arguments. The first argument is a  ```NSString *type ``` argument categorizing your event. This argument is **required**. You may choose any string you like.

The next two arguments are  `NSDictionary *properties` and  `NSNumber *timestamp`. Properties is a dictionary which uses  `NSString` keys and the value may be any  ```NSObject ``` which is serializable to JSON. Properties can be used to attach any additional data to the event. Timestamp is a standard UNIX timestamp in seconds and it can be used to mark the time of the event's occurrence. The default timestamp is preset to the time when the event is tracked.

```
// Objective-C
NSDictionary *properties = @{@"item_id": @45};
NSNumber *timestamp = [NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]];

// Tracking of buying an item with item's properties at a specific time
[Exponea track:@"item_bought" withProperties:properties withTimestamp:timestamp];

// Tracking of buying an item at a specific time
[Exponea track:@"item_bought" withTimestamp:timestamp];

// Tracking of buying an item with item's properties
[Exponea track:@"item_bought" withProperties:properties];

// Basic tracking that an item has been bought
[Exponea track:@"item_bought"];
```
```
// Swift
var properties = ["item_id": 45]
var timestamp = Date().timeIntervalSince1970

// Tracking of buying an item with item's properties at a specific time
Exponea.track("item_bought", withProperties: properties, withTimestamp: timestamp as NSNumber)

// Tracking of buying an item at a specific time
Exponea.track("item_bought", withTimestamp: timestamp as NSNumber)

// Tracking of buying an item with item's properties
Exponea.track("item_bought", withProperties: properties)

// Basic tracking that an item has been bought
Exponea.track("item_bought")
```

The Exponea iOS SDK provides you with means to store arbitrary data that is not event-specific (e.g. customer age, gender, initial referrer). Such data is tied directly to the customer as their properties. To store such data, the  ```update ``` method is used.

```
// Objective-C
NSDictionary *properties = @{@"age": @34};
// Store customer's age
[Exponea update:properties];
```
```
// Swift
var properties = ["age": 34]
// Store customer's age
Exponea.update(properties)
```

Automatic events
----------------

Exponea iOS SDK automatically tracks some events on its own. Automatic events ensure that basic user data gets tracked with as little effort as just including the SDK into your game. Automatic events include sessions, installation, identification and payments tracking.

## Sessions ##

Session is a real time spent in the game, it starts when the game is launched and ends when the game goes to background. If the player returns to game in 60 seconds (To change TIMEOUT value, call  ```setSessionTimeOut```), game will continue in current session. Tracking of sessions produces two events,  ```session_start ``` and  ```session_end ```. To track session start call  ```trackSessionStart ``` from **applicationDidBecomeActive** method and to track session end call  `trackSessionEnd` from **applicationDidEnterBackground** in AppDelegate.m
```
// Objective-C
// AppDelegate.m
- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [Exponea trackSessionStart];
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [Exponea trackSessionEnd];
}
```
```
// Swift
// AppDelegate.swift
func applicationDidBecomeActive(_ application: UIApplication) {
    Exponea.trackSessionStart()
}
func applicationDidEnterBackground(_ application: UIApplication) {
    Exponea.trackSessionEnd()
}
```

Both events contain the timestamp of the occurence together with basic attributes about the device (OS, OS version, SDK, SDK version and device model). Event  ```session_end ``` contains also the duration of the session in seconds. Example of  ```session_end ``` event attributes in *JSON* format:

```
{
  "duration": 125,
  "device_model": "iPhone",
  "device_type": "mobile",
  "ip": "10.0.1.58",
  "os_name": "iOS",
  "os_version": "8.1.0",
  "sdk": "iOS SDK",
  "sdk_version": "1.1.1"
  "app_version": "1.0.0"
}
```

## Installation ##


Installation event is fired **only once** for the whole lifetime of the game on one device when the game is launched for the first time. Besides the basic information about the device (OS, OS version, SDK, SDK version and device model), it also contains additional attribute called **campaign_id** which identifies the source of the installation. Example of installation event:


```
{
  "campaign": "Advertisement on my website",
  "campaign_id": "ui9fj4i93jf9083094fj9043",
  "link": "https://itunes.apple.com/us/...",
  "device_model": "iPhone",
  "device_type": "mobile",
  "ip": "10.0.1.58",
  "os_name": "iOS",
  "os_version": "8.1.0",
  "sdk": "iOS SDK",
  "sdk_version": "1.1.1"
}
```

## Identification ##

Identification event is tracked each time the  `identify()` method is called. It contains all basic information regarding the device (OS, OS version, SDK, SDK version and device model) as well as **registered** attribute which identifies the player. Example of an identification event:

```
{
  "registered": "player@email.com",
  "device_model": "iPhone",
  "device_type": "mobile",
  "ip": "10.0.1.58",
  "os_name": "iOS",
  "os_version": "8.1.0",
  "sdk": "iOS SDK",
  "sdk_version": "1.1.1"
}
```

## Payments ##

Exponea iOS SDK automatically tracks all payments made in the game as the SDK instance listens on  `[SKPaymentQueue defaultQueue]` for successful transactions. Purchase events (called  ```hard_purchase ```) contain all basic information about the device (OS, OS version, SDK, SDK version and device model) combined with additional purchase attributes **brutto**, **item_id** and **item_title**. **Brutto** attribute contains price paid by the player. Attribute **item_title** consists of human-friendly name of the bought item (e.g. Silver sword) and **item_id** corresponds to the product identifier for the in-app purchase as defined in your iTunes Connect console. Example of purchase event:

```
{
  "gross_amount": 0.911702,
  "currency": "EUR",
  "payment_system": "iTunes Store",
  "product_id": "silver.sword",
  "product_title": "Silver sword",
  "device_model": "iPad",
  "device_type": "tablet",
  "ip": "10.0.1.58",
  "os_name": "iOS",
  "os_version": "8.1.0",
  "sdk": "iOS SDK",
  "sdk_version": "1.1.1"
}
```

## Virtual payment ##

If you use virtual payments (e.g. purchase with in-game gold, coins, ...) in your project, you can track them with a call to  `trackVirtualPayment`.

```
// Objective-C
[Exponea trackVirtualPayment:@"currency" withAmount:@3 withItemName:@"itemName" withItemType:@"itemType"];
```
```
// Swift
Exponea.trackVirtualPayment("currency", withAmount: 3, withItemName: "itemName", withItemType: "itemType")
```

Segmentation
------------

If you want to get current segment of your player, just call  `getCurrentSegment`. You will need id of your segmentation and project secret token.

```
// Objective-C
[Exponea getCurrentSegment:@"segmentaionId" withProjectSecret:@"projectSecret" withCallBack:^(BOOL wasSuccessful, ExponeaSegment *segment, NSString *error) {
    NSString *name = [segment getName];
}];
```
```
// Swift
Exponea.getCurrentSegment("segmentaionId", withProjectSecret: "projectSecret", withCallBack: {(_ wasSuccessful: Bool, _ segment: ExponeaSegment, _ error: String) -> Void in
    var name: String = segment.getName()
} as! onSegmentReceive)
```

Push notifications
------------------
The Exponea web application allows you to easily create complex scenarios which you can use to send push notifications directly to your players. The following section explains how to enable receiving push notifications in the Exponea iOS SDK.

## Apple Push certificate ##

Exponea uses the JWT authentication tokens with ES256 algorithm for sending push notifications. We will have to create a private key, which Exponea will use for signing your tokens and payloads.
* Go to Apple developers site and create a new key https://developer.apple.com/account/ios/authkey/ for APN. Download it.
* The **private key** file will be named AuthKey_XXXXX.p8, where XXXXX is the **Key Id**. You will also be able to see the Key Id on the Apple developer's site just before download.
* Find your **Team Id** and **bundle name** on this site https://developer.apple.com/account/ios/identifier/bundle
* The last step is to upload your Apple Push data to the Exponea web application. In the Exponea web application, navigate to **Project management -> Settings -> Push Notifications**
* Copy and paste **Key Id**, **Team Id**, contents of **private key** file, **bundle name** into proper fields in Exponea and save the settings.

Now you are ready to implement Push Notifications into your iOS application.

## Exponea iOS SDK ##
By default, receiving of push notifications is disabled. You can enable it by calling the  `registerPushNotifications` method. In Swift, requesting user to allow push notifications may look like this:
```
// Swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    Exponea.getInstance("projectToken")
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
        // Enable or disable features based on authorization.
    }
    application.registerForRemoteNotifications()
    return true
}
```

Please note that this method needs to be called only once. Push notifications remain enabled until they are unregistered. After registering for push notifications, iOS automatically calls 

```
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken 
```

which is a good place to send the device token to the Exponea web application using method  `addPushNotificationsToken`. See code sample from **AppDelegate.m** below and [Apple Push Notifications Documentation](https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Introduction.html) for more details.
```
// Objective-C
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"token: %@", deviceToken);
    [Exponea addPushNotificationsToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"failed obtaining token: %@", error);
}
```
```
// Swift
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
    print("token: \(deviceToken)")
    Exponea.addPushNotificationsToken(deviceToken)
}
func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Remote notification support is unavailable due to error: \(error.localizedDescription)")
}
```

Now, you can easily send push notifications through Exponea.

Flushing events
---------------
All tracked events are stored in the internal SQL database. By default, Exponea iOS SDK automagically takes care of flushing events to the Exponea API. This feature can be turned off with method  `disableAutomaticFlushing` which takes no arguments. Please be careful with turning automatic flushing off because if you turn it off, you need to manually call  `flush` to flush the tracked events manually everytime there is something to flush.
```
[Exponea enableAutomaticFlushing];

[Exponea disableAutomaticFlushing];
[Exponea flush];
```
