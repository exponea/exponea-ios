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


After completing the steps above, the Exponea iOS SDK should be included in your app, ready to be used.

Usage
-----
### Basic Interface ###

Once the IDE is set up, you may start using the Exponea library in your code. Firstly, you need to import main header file **ExponeaSDK.h** with the following code:  ```#import <ExponeaSDK/ExponeaSDK.h> ```. Secondly, you need to know the URI of your Exponea API instance (usually  ```https://api.exponea.com ```)and your project  ```token ``` (located on the Project management / Overview page in the web application). To interact with the Exponea SDK, you need to obtain a shared instance of the Exponea class using the project  `token` (the URI parameter is optional):

```
// Use public Exponea instance
[Exponea getInstance:@"projectToken"];

// Use custom Exponea instance
[Exponea getInstance:@"projectToken" andWithTarget:@"http://url.to.your.instance.com"];
```
To start tracking, the customer needs to be identified with their unique  `customerId`. The unique  `customerId` can either be an instance of NSString, or NSDictionary representing the  `customerIds` as referenced in [the API guide](http://guides.exponea.com/technical-guide/rest-client-api/#Detailed_key_descriptions). Setting

```
NSString *customerId = @"123-foo-bar";
```
is equivalent to
```
NSDictionary *customerId = @{@"registered": @"123-foo-bar"};
```
In order to identify a customer, call one of the `identifyWithCustomer` or `identifyWithCustomerDict` methods on the obtained Exponea instance as follows:
```
// Identify a customer with their NSString customerId
[Exponea identify:customerId];

// Identify a customer with their NSDictionary customerId
[Exponea identifyWithCustomerDict:customerId];
```
The identification is performed asynchronously and there is no need to wait for it to finish. Until they are sent to the Exponea API, all tracked events are stored in the internal SQL database.

You may track any event by calling the  `track` method on the Exponea instance. The  `track` method takes one mandatory and two optional arguments. The first argument is a  ```NSString *type ``` argument categorizing your event. This argument is **required**. You may choose any string you like.

The next two arguments are  `NSDictionary *properties` and  `NSNumber *timestamp`. Properties is a dictionary which uses  `NSString` keys and the value may be any  ```NSObject ``` which is serializable to JSON. Properties can be used to attach any additional data to the event. Timestamp is a standard UNIX timestamp in seconds and it can be used to mark the time of the event's occurrence. The default timestamp is preset to the time when the event is tracked.

```
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
The Exponea iOS SDK provides you with means to store arbitrary data that is not event-specific (e.g. customer age, gender, initial referrer). Such data is tied directly to the customer as their properties. To store such data, the  ```update ``` method is used.

```
NSDictionary *properties = @{@"age": @34};

// Store customer's age
[Exponea update:properties];
```

Automatic events
----------------

Exponea iOS SDK automatically tracks some events on its own. Automatic events ensure that basic user data gets tracked with as little effort as just including the SDK into your game. Automatic events include sessions, installation, identification and payments tracking.

## Sessions ##

Session is a real time spent in the game, it starts when the game is launched and ends when the game goes to background. If the player returns to game in 60 seconds (To change TIMEOUT value, call  ```setSessionTimeOut```), game will continue in current session. Tracking of sessions produces two events,  ```session_start ``` and  ```session_end ```. To track session start call  ```trackSessionStart ``` from **applicationDidBecomeActive** method and to track session end call  `trackSessionEnd` from **applicationDidEnterBackground** in AppDelegate.m
```
//AppDelegate.m

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


Installation event is fired **only once** for the whole lifetime of the game on one device when the game is launched for the first time. Besides the basic information about the device (OS, OS version, SDK, SDK version and device model), it also contains additional attribute called **campaign_id** which identifies the source of the installation. For more information about this topic, please refer to the [aquisition documentation](http://guides.exponea.com/user-guide/acquisition/). Example of installation event:


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
[Exponea trackVirtualPayment:@"currency" withAmount:@3 withItemName:@"itemName" withItemType:@"itemType"];
```

Segmentation
------------

If you want to get current segment of your player, just call  `getCurrentSegment`. You will need id of your segmentation and project secret token.

```
[Exponea getCurrentSegment:@"segmentaionId" withProjectSecret:@"projectSecret" withCallBack:^(BOOL wasSuccessful, ExponeaSegment *segment, NSString *error) {
    NSString *name = [segment getName];
}];
```

Push notifications
------------------
The Exponea web application allows you to easily create complex scenarios which you can use to send push notifications directly to your players. The following section explains how to enable receiving push notifications in the Exponea iOS SDK.

## Apple Push certificate ##

For push notifications to work, you need a push notifications certificate with a corresponding private key in a single file in PEM format. The following steps show you how to export one from the Keychain Access application on your Mac:

* Launch Keychain Access application on your Mac
* Find Apple Push certificate for your app in *Certificates* or *My certificates* section (it should start with **Apple Development IOS Push Services:** for development certificate or **Apple Production IOS Push Services:** for production certificate)
* The certificate should contain a **private key**, select both certificate and its corresponding private key, then right click and click **Export 2 items**
* In the saving modal window, choose a filename and saving location which you prefer and select the file format **Personal Information Exchange (.p12)** and then click **Save**
* In the next modal window, you will be prompted to choose a password, leave the password field blank and click **OK**. Afterwards, you will be prompted with you login password, please enter it.
* Convert p12 file format to PEM format using OpenSSL tools in terminal. Please launch **Terminal** and navigate to the folder, where the .p12 certificate is saved (e.g.  `~/Desktop/ `)
* Run the following command  `openssl pkcs12 -in certificate.p12 -out certificate.pem -clcerts -nodes`, where **certificate.p12** is the exported certificate from Keychain Access and **certificate.pem** is the converted certificate in PEM format containing both Apple Push certificate and its private key
* The last step is to upload the Apple Push certificate to the Exponea web application. In the Exponea web application, navigate to **Project management -> Settings -> Notifications**
* Copy the content of **certificate.pem** into **Apple Push Notifications Certificate** and click **Save**


Now you are ready to implement Push Notifications into your iOS application.

## Exponea iOS SDK ##
By default, receiving of push notifications is disabled. You can enable it by calling the  `registerPushNotifications` method. Please note that this method needs to be called only once. Push notifications remain enabled until they are unregistered. After registering for push notifications, iOS automatically calls  ```didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken ``` which is a good place to send the device token to the Exponea web application using method  ```addPushNotificationsToken ```. See code sample from **AppDelegate.m** below and [Apple Push Notifications Documentation](https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Introduction.html) for more details.
```
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"token: %@", deviceToken);
    [Exponea addPushNotificationsToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"failed obtaining token: %@", error);
}
```

Flushing events
---------------
All tracked events are stored in the internal SQL database. By default, Exponea iOS SDK automagically takes care of flushing events to the Exponea API. This feature can be turned off with method  ```disableAutomaticFlushing ``` which takes no arguments. Please be careful with turning automatic flushing off because if you turn it off, you need to manually call  `flush` to flush the tracked events manually everytime there is something to flush.
```
[Exponea enableAutomaticFlushing];

[Exponea disableAutomaticFlushing];
[Exponea flush];
```
