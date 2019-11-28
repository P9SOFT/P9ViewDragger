P9ViewDragger
============

Developers can easily implement dragging view function with P9ViewDragger.

# Installation

You can download the latest framework files from our Release page.
P9ViewDragger also available through CocoaPods. To install it simply add the following line to your Podfile.
pod ‘P9ViewDragger’

# Play

For dragging, rotating and scaling, you just set a view to P9ViewDragger.

```swift
P9ViewDragger.default().trackingView(someView, parameters: nil, ready: nil, trackingHandler: nil, completion: nil)
```

That's all do to dragging, rotating and scaling sameView.

P9ViewDragger handing view to dragging, rotating and scaling by default.
But, for example. If you want to allow dragging only for view.
You can handing it by passing lock flag parameters.

```swift
P9ViewDragger.default().trackingView(someView, parameters: [P9ViewDraggerLockRotateKey:true, P9ViewDraggerLockScaleKey:true], ready: nil, trackingHandler: nil, completion: nil)
```

Here are reserved parameters you can use.

| Parameter Key                          | value type |  description                           |
| -------------------------------------- |:----------:| --------------------------------------:|
| P9ViewDraggerLockTranslateKey          | boolean    | disable translate                      |
| P9ViewDraggerLockScaleKey              | boolean    | disable scale                          |
| P9ViewDraggerLockRotateKey             | boolean    | disable rotate                         |
| P9ViewDraggerSnapshotImageKey          | UIImage    | give decoy image when dragging         |
| P9ViewDraggerDecoyViewKey              | UIView     | give decoy view when dragging          |
| P9ViewDraggerRemainDecoyViewOnStageKey | boolean    | don't remove decoy view after dragging |
| P9ViewDraggerStartWhenTouchDownKey     | boolean    | start tracking when touch down         |

You can put your business code to each event point like drag ready, dragging and drag complete by passing handling block code.
Check example below, change alpha value of view when start dragging, allow y translation only when dragging, change alpha value of view when drag complete.

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

P9ViewDragger use given view when dragging animation directly.
If you want to remain the given view without any changing and want to use another view or image when animating, then use decoy function.
P9ViewDragger make decoy view on given stage view.
So, before using decoy function, you need to decide the stage view.
If you set default stage view already, you can pass nil to stage view parameter then P9ViewDragger use default stage view.

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
