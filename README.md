# Builder

Tiny layer of abstraction for building logic.

## Usage

Here's common builder injection scenario. `UIViewController`s are used only for demonstration  
sake, it can be any app module (router, coordinaror, etc.) or type in general.

Assume there are two screens in the app - `Home` and `Profile`. On each screen there is an option  
to present `Paywall` screen which depends on `PurchasesService` and `AnalyticsTracker` services and  
`PawallSource` argument.

```swift
public enum PaywallSource {
    case home
    case profile
}
```

There are all dependencies for `Paywall` sceen:

```swift
public protocol PaywallDeps {
    associatedtype PurchasesServiceType: PurchasesService
    associatedtype AnalyticsTrackerType: AnalyticsTracker

    var source: PawallSource { get }
    var purchasesService: PurchasesServiceType { get }
    var analyticsTracker: AnalyticsTrackerType { get }
}
```

And this is how `PaywallBuilder` can be implemented, it takes `Deps` constrainted to `PaywallDeps` and returns  
abstract `UIViewController` hiding all implementstion details about `PaywallInteractor` and `PaywallViewController`.

```swift
public struct PaywallBuilder<Deps: PaywallDeps>: Builder {
    public init() {}

    public func build(using deps: Deps) -> UIViewController {
        let interactor = PaywallInteractor(
            purchasesService: deps.purchasesService,
            analyticsTracker: deps.analyticsTracker
        )
        let viewController = PaywallViewController(
            source: deps.source,
            interactor: interactor
        )
        interactor.viewController = viewController

        return viewController
    }
}
```

In dependencies for `Home` and `Profile` screens we can now add `PaywallBuilder`, but  
with dependencies declared as `PaywallSource` instead of `PaywallDeps`, because `Home` and `Profile`  
do not have to depend on services from `PaywallDeps` (`PurchasesService` for instance).

```swift
public protocol HomeDeps {
    associatedtype PawallBuilderType: Builder<PaywallSource, UIViewController>

    var paywallBuilder: PawallBuilderType { get }
    ...
}
```

```swift
public protocol ProfileDeps {
    associatedtype PawallBuilderType: Builder<PaywallSource, UIViewController>

    var paywallBuilder: PawallBuilderType { get }
    ...
}
```

In order to resolve these dependencies somewhere externally (`AppDelegate` for exmample) we can declare `...DepsImpl`  
for each dependencies and pass `AppDelegate` as parent with all services/bulders initialization made inside `AppDelegate`.

```swift
struct PaywallDepsImpl {
    let parent: AppDelegate
    let source: PawallSource

    var purchasesService: some PurchasesService { parent.purchasesService }
    var analyticsTracker: some AnalyticsTracker { parent.analyticsTracker }
}
```

```swift
final class AppDelegate: UIApplicationDelegate {
    lazy var purchasesService: some PurchasesService = {
        PurchasesServiceImpl()
    }()

    lazy var analyticsTracker: some AnalyticsTracker = {
        AnalyticsTrackerImpl()
    }()

    lazy var paywallBuilder: some Builder<PaywallSource, UIViewController> = { 
        PaywallBuilder().scoped { source in
            PaywallDepsImpl(parent: self, source: source)
        }
    }
}
```

```swift
struct HomeDepsImpl {
    let parent: AppDelegate

    var paywallBuilder: some Builder<PaywallSource, UIViewController> { parent.paywallBuilder }
    ...
}
```

```swift
struct ProfileDepsImpl {
    let parent: AppDelegate

    var paywallBuilder: some Builder<PaywallSource, UIViewController> { parent.paywallBuilder }
    ...
}
```

Using `Builder` helped to hide implementation details and expose barely minimum interface for client (`Home` and `Profile` in  
this example). That's how `Paywall` sceen can be built inside `Home` screen:

```swift
final class HomeViewController<PB: Builder<PaywallSource, UIViewController>>: UIViewController {
    let paywallBuilder: PB

    init(paywallBuilder: PB) {
        self.paywallBuilder = paywallBuilder
        super.init(nibName: nil, bundle: NIL)
    }

    func presentPaywall() {
        let paywallViewController = paywallBuilder.build(using: .home)
        present(paywallViewController, animated: true)
    }
}
```
