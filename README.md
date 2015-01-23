[![](http://inspace.io/github-cover.jpg)](http://inspace.io)

# Introduction

**INSElectronicProgramGuideLayout** was written by **[Michał Zaborowski](https://github.com/m1entus)** for **[inspace.io](http://inspace.io)**

# INSElectronicProgramGuideLayout

`INSElectronicProgramGuideLayout` is a `UICollectionViewLayout` subclass for displaying Electronic Program Guide.

[![](https://raw.github.com/inspace-io/INSElectronicProgramGuideLayout/master/Screens/screen.png)](https://raw.github.com/inspace-io/INSElectronicProgramGuideLayout/master/Screens/screen.png)
[![](https://raw.github.com/inspace-io/INSElectronicProgramGuideLayout/master/Screens/animation.gif)](https://raw.github.com/inspace-io/INSElectronicProgramGuideLayout/master/Screens/animation.gif)

# Example

The example project create sample data for the next three days channel data, it use LoremIpsum framework to fill EPG data. To run, build and run the Example target in from `INSElectronicProgramGuideLayout.xcworkspace` within the Example directory.

# Usage


## CocoaPods

Add the following to your `Podfile` and run `$ pod install`.

``` ruby
pod 'INSElectronicProgramGuideLayout'
```

If you don't have CocoaPods installed, you can learn how to do so [here](http://cocoapods.org).


## Invalidating Layout

If you change the content of your `INSElectronicProgramGuideLayout`, make sure to call the `invalidateLayoutCache` method. This flushes the internal caches of your `INSElectronicProgramGuideLayout`, allowing the data to be repopulated correctly.

## Collection View Elements

`INSElectronicProgramGuideLayout` has eleven different elements that you should register `UICollectionReusableView` and `UICollectionViewCell` classes for. They are:

* **EPG Cell** (`UICollectionViewCell`)  – Represents your events.
* **Channel Column Header** (`UICollectionReusableView`) element kind of (`INSEPGLayoutElementKindSectionHeader`) – Contains the channel text, top aligned.
* **Hour Row Header** (`UICollectionReusableView`) element kind of (`INSEPGLayoutElementKindHourHeader`) – Contains the hour text, center aligned.
* **Half Hour Row Header** (`UICollectionReusableView`) element kind of (`INSEPGLayoutElementKindHalfHourHeader`) – Contains the half hour text, center aligned.
* **Channel Column Header Background** (`UICollectionReusableView`) element kind of (`INSEPGLayoutElementKindSectionHeaderBackground`) – Background of the channel column header.
* **Hour Row Header Background** (`UICollectionReusableView`) element kind of (`INSEPGLayoutElementKindHourHeaderBackground`) – Background of the hour row header.
* **Current Time Indicator** (`UICollectionReusableView`) element kind of (`INSEPGLayoutElementKindCurrentTimeIndicator`) – Displayed over the hour row header, aligned at the current time.
* **Current Time Vertical Gridline** (`UICollectionReusableView`) element kind of (`INSEPGLayoutElementKindCurrentTimeIndicatorVerticalGridline`) – Displayed under the cells, aligned to the current hour.
* **Vertical Hour Gridilne** (`UICollectionReusableView`) element kind of (`INSEPGLayoutElementKindVerticalGridline`) – Displayed under the cells, aligns with its corresponding hour row header.
* **Vertical Half Hour Gridilne** (`UICollectionReusableView`) element kind of (`INSEPGLayoutElementKindHalfHourVerticalGridline`) – Displayed under the cells, aligns with its corresponding half hour row header.
* **Horizontal Gridilne** (`UICollectionReusableView`) element kind of (`INSEPGLayoutElementKindHorizontalGridline`) – Displayed under the cells, aligns with its corresponding channel column header.
* **Floating Overlay** (`UICollectionReusableView`) element kind of (`INSEPGLayoutElementKindFloatingItemOverlay`) – Displayed over the cells, aligns with its  content.

## Interface and customization

```objective-c
@interface INSElectronicProgramGuideLayout : UICollectionViewLayout

/**
*  Vertical space between sections (channels)
*/
@property (nonatomic, assign) CGFloat sectionGap;

/**
*  Section size
*/
@property (nonatomic, assign) CGFloat sectionHeight;
@property (nonatomic, assign) CGFloat sectionHeaderWidth;

/**
*  Current time indicator and gridline size
*/
@property (nonatomic, assign) CGSize currentTimeIndicatorSize;
@property (nonatomic, assign) CGFloat currentTimeVerticalGridlineWidth;

/**
*  Gridlines size
*/
@property (nonatomic, assign) CGFloat horizontalGridlineHeight;
@property (nonatomic, assign) CGFloat verticalGridlineWidth;

/**
*  Hour width and hour header height
*/
@property (nonatomic, assign) CGFloat hourWidth;
@property (nonatomic, assign) CGFloat hourHeaderHeight;

/**
*  Default size to use for floating headers. If the delegate does not implement the collectionView:layout:sizeForFloatingItemOverlayAtIndexPath: method, the flow layout uses the value in this property to set the size of each floating header.
*/
@property (nonatomic, assign) CGSize floatingItemOverlaySize;

/**
* Horizontal space between floating header and section.
Default value is 10.0
*/
@property (nonatomic, assign) CGFloat floatingItemOffsetFromSection;

/**
* Distances between the border and the layout content view.
* Default value is UIEdgeInsetsMake(0, 0, 0, 0)
*/
@property (nonatomic, assign) UIEdgeInsets contentMargin;

/**
*  Margin between cells.
*  Default value is UIEdgeInsetsMake(0, 0, 0, 10)
*/
@property (nonatomic, assign) UIEdgeInsets cellMargin;

@property (nonatomic, assign) INSElectronicProgramGuideLayoutType headerLayoutType;

/**
*  Set to YES if you want to resize sticky background headers when UICollectionView bounces.
*/
@property (nonatomic, assign) BOOL shouldResizeStickyHeaders;

/**
*  Set to YES if you want to use floting overlay to each cell. If set to YES you have to register supplementaryViewOfKind INSEPGLayoutElementKindFloatingItemOverlay.
*/
@property (nonatomic, assign) BOOL shouldUseFloatingItemOverlay;

```

## Can I call performBatchUpdates:completion: to make stuff animate?

Don't do this. It doesn't work properly, and is a "bag of hurt".

## Requirements

`INSElectronicProgramGuideLayout` requires either iOS 7.x and above.

## Special thanks

I'd love a thank you tweet if you find this useful.

Special thanks to Eric Horacek who was originally wrote `MSCollectionViewCalendarLayout`, and i took many stuff from him.

## Storyboard

`INSElectronicProgramGuideLayout` supports storyboard.

## ARC

`INSElectronicProgramGuideLayout` uses ARC.

## Contact

[inspace.io](http://inspace.io)

[Twitter](https://twitter.com/inspace_io)

# License

*Copyright (c) 2014 inspace.io. All rights reserved.*

It is open source and covered by a standard 2-clause BSD license. That means you have to mention [inspace.io](http://inspace.io) as the original author of this code and reproduce the LICENSE text inside your app. 

You can purchase a [Non-Attribution-License](http://inspace.io) for 35 Euros for not having to include the LICENSE text.

We also accept sponsorship for specific enhancements which you might need. Please [contact us via email](mailto:contact@inspace.io?subject=INSElectronicProgramGuideLayout) for inquiries.
