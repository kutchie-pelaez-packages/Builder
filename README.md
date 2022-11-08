# Builder

Tiny layer of abstraction for building logic injection.

## Usage

Here's common builder injection scenario. `UIViewController`s are used only for demonstration sake.

Some module `Foo` declares public builder and dependencies (with arguments if needed).  
These declarations can be made in defferent submodules in order to make further usage of  
builder independet of implementation details.

```swift
public protocol FooDependencies {
    associatedtype NetworkingType: Networking
    associatedtype AnaliticsType: Analitics

    var stringArg: String { get }
    var networking: NetworkingType { get }
    var analytics: AnaliticsType { get }
}

public struct FooArgs {
    public let stringArg: String

    public init(stringArg: String) {
        self.stringArg = stringArg
    }
}
```

```swift
public struct FooBuilder<Dependencies: FooDependencies>: Builder {
    public init() {}

    public func build(using dependencies: Dependencies) -> UIViewController {
        FooViewController(
            stringArg: dependencies.stringArg,
            networking: dependencies.networking,
            analytics: dependencies.analytics
        )
    }
}
```

In some module `Bar` we want to build `FooBuilder`'s product using `FooArgs`:

```swift
final class BarViewController<FB: Builder<FooArgs, UIViewController>>: UIViewController {
    private let fooBuilder: FB

    init(fooBuilder: FB) {
        self.fooBuilder = fooBuilder
        super.init(nibName: nil, bundle: nil)
    }

    func buildFooProduct() -> UIViewController {
        let args = FooArgs(stringArg: "stringArg")
        fooBuilder.build(using: args)
    }
}
```

In order to resolve other dependencies from `FooDependencies` externally (apart from `stringArg`)  
we can inject scoped builder into `BarViewController` as follows:

```swift
struct FooDependenciesImpl: FooDependencies {
    let stringArg: String
    let networking: Networking
    let analytics: Analytics
}

...

let networking = NetworkingImpl()
let analytics = AnalyticsImpl()
let scopedFooBuilder: some Builder<FooArgs, UIViewController> = FooBuilder().scoped { args in
    FooDependenciesImpl(
        stringArg: args.stringArg,
        networking: networking,
        analytics: analytics
    )
}
let barViewController = BarViewController(fooBuilder: scopedFooBuilder)
```
