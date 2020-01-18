P9ViewDragger
============

You can easily implement dragging view function with P9ViewDragger.

# Installation

You can download the latest framework files from our Release page.
P9ViewDragger also available through the CocoaPods. You simply add the following line to your Podfile to install.
pod ‘P9ViewDragger’

# Play


Do following line to drag, rotate and scale for your UIView.

```swift
P9ViewDragger.default().trackingView(yourView, parameters: nil, ready: nil, trackingHandler: nil, completion: nil)
```

That's all you need to do to drag, rotate and scale your UIView.

Dragging, Ratating and Scaling features in the P9ViewDragger are enabled by default.
You can enable/disable each feature by below.

```swift
P9ViewDragger.default().trackingView(someView, parameters: [P9ViewDraggerLockRotateKey:true, P9ViewDraggerLockScaleKey:true], ready: nil, trackingHandler: nil, completion: nil)
```

Here are reserved parameters you can use.

| Parameter Key                          | value type |  description                           |
| -------------------------------------- |:----------:| --------------------------------------:|
| P9ViewDraggerLockTranslateKey          | boolean    | enable/disable translate               |
| P9ViewDraggerLockScaleKey              | boolean    | enable/disable scale                   |
| P9ViewDraggerLockRotateKey             | boolean    | enable/disable rotate                  |
| P9ViewDraggerSnapshotImageKey          | UIImage    | set decoy image view                   |
| P9ViewDraggerDecoyViewKey              | UIView     | set decoy view                         |
| P9ViewDraggerRemainDecoyViewOnStageKey | boolean    | set false to remove decoy view at the end of the dragging |
| P9ViewDraggerStartWhenTouchDownKey     | boolean    | start tracking a view at the touch down event |

You can set event handlers for the tracking and completion events in the P9ViewDragger:trackingView() method.

Here is the exmaple below that shows you how to drag your UIView only vertically with it's alpha changes.
As you can see in this example, you can be notified at the `ready`, `trackingHandler` and `completion` closers.


```swift
P9ViewDragger.default().trackingView(someView, parameters: nil, ready: { [weak self] (trackingView:UIView?) in
    guard let `self` = self else {
        return
    }
    self.someView.alpha = 0.2
}, trackingHandler: { [weak self] (trackingView:UIView?) in
    guard let _ = self, let trackingView = trackingView else {
        return
    }
    var transform = trackingView.transform
    transform.tx = 0
    trackingView.transform = transform
}) { [weak self] (trackingView:UIView?) in
    guard let `self` = self else {
        return
    }
    self.someView.alpha = 1.0
}
```

You can also use `trackingDecoyView()` method if you want to move decoy view instead of moving your UIView during the animation.

You don't have to create decoy view by yourself. `P9ViewDragger` is going to create decoy view for you as a child view of the `stageView`.
If `stageView` is nil, then `defaultStateView` in the `P9ViewDragger` will be used.


```swift
P9ViewDragger.default().trackingDecoyView(someView, stageView: stageView, parameters: nil, ready: { [weak self] (trackingView:UIView?) in
    guard let `self` = self else {
        return
    }
    self.someView.alpha = 0.2
}, trackingHandler: nil) { [weak self] (trackingView:UIView?) in
    guard let `self` = self, let trackingView = trackingView else {
        return
    }
    self.someView.alpha = 1.0
    self.someView.transform = trackingView.transform
}
```

# License

MIT License, where applicable. http://en.wikipedia.org/wiki/MIT_License
