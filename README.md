[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](https://github.com/mercadopago/px-ios)
![build](https://travis-ci.org/mercadopago/px-ios.svg?branch=development)
[![codecov](https://codecov.io/gh/mercadopago/px-ios/branch/master/graph/badge.svg)](https://codecov.io/gh/mercadopago/px-ios)

# MercadoPago iOS (Swift 3.1) SDK
The MercadoPago iOS SDK make it easy to collect your users' credit card details inside your iOS app. By creating tokens, MercadoPago handles the bulk of PCI compliance by preventing sensitive card data from hitting your server.

![Screenshot iOS](https://cloud.githubusercontent.com/assets/9399970/20975888/96dd46e4-bc7f-11e6-9aab-436cf8ff97f5.png)

## Installation

There are two ways to add MercadoPago to your project:

### CocoaPods (iOS 8.0 or later)

#### Step 1: Download CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C and Swift, which automates and simplifies the process of using 3rd-party libraries like MercadoPagoSDK in your projects.

CocoaPods is distributed as a ruby gem, and is installed by running the following commands in Terminal.app:

    $ sudo gem install cocoapods
    $ pod setup

> Depending on your Ruby installation, you may not have to run as `sudo` to install the cocoapods gem.

> :warning: MercadoPagoSDK requires cocoapods 1.0.0 or higher. With pod --version you can verify the current version you have installed. This framework was built with Swift 3.0 so you will need Xcode 8.0 or higer in order to use it. In case you need support for older Xcode versions just contact the development team creating an issue.

#### Step 2: Create a Podfile

Project dependencies to be managed by CocoaPods are specified in a file called `Podfile`. Create this file in the same directory as your Xcode project (`.xcodeproj`) file:

    $ touch Podfile
    $ open -a Xcode Podfile

You just created the pod file and opened it using Xcode! Ready to add some content to the empty pod file?

Copy and paste the following lines into the TextEdit window:  

    source 'https://github.com/CocoaPods/Specs.git'
    use_frameworks!
    platform :ios, '8.0'
    pod 'MercadoPagoSDK', '3.6.4'

> You shouldn’t use TextEdit to edit the pod file because TextEdit likes to replace standard quotes with more graphically appealing quotes. This can cause CocoaPods to get confused and display errors, so it’s best to just use Xcode or another programming text editor.

#### Step 3: Install Dependencies

Now you can install the dependencies in your project:

    $ pod install

From now on, be sure to always open the generated Xcode workspace (`.xcworkspace`) instead of the project file when building your project:

    $ open <YourProjectName>.xcworkspace

### Copy manually (iOS 7.0 or later)

- Open the MercadoPagoSDK folder, and drag MercadoPagoSDK.xcodeproj into the file navigator of your app project.
- In Xcode, navigate to the target configuration window by clicking on the blue project icon, and selecting the application target under the "Targets" heading in the sidebar.
- Ensure that the deployment target of MercadoPagoSDK.framework matches that of the application target.
- In the tab bar at the top of that window, open the "Build Phases" panel.
- Expand the "Target Dependencies" group, and add MercadoPagoSDK.framework.
- Click on the + button at the top left of the panel and select "New Copy Files Phase". Rename this new phase to "Copy Frameworks", set the "Destination" to "Frameworks", and add MercadoPagoSDK.framework.

## Examples

This project includes two Xcode Projects with examples using MercadoPagoSDK: MercadoPagoSDKExamples written in swift and MercadoPagoSDKExamplesObjectiveC. In case you need support contact the development team.

## Documentation
+ [See the GitHub Project](https://github.com/mercadopago/px-ios)
+ [Read more about this 6 steps integration.](https://mercadopago.github.io/px-ios)
+ [Check out MercadoPago Developers Site!](http://www.mercadopago.com.ar/developers)

## Feedback

You can join the MercadoPago Developers Community on MercadoPago Developers Site:

+ [English](https://www.mercadopago.com.ar/developers/en/community/forum/)
+ [Español](https://www.mercadopago.com.ar/developers/es/community/forum/)
+ [Português](https://www.mercadopago.com.br/developers/pt/community/forum/)
