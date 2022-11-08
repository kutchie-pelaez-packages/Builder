public protocol Builder<Dependencies, Product> {
    associatedtype Dependencies
    associatedtype Product

    func build(using dependencies: Dependencies) -> Product
}

extension Builder where Dependencies == Void {
    public func build() -> Product {
        build(using: ())
    }
}

extension Builder {
    public func scoped<Args>(_ dependenciesResolver: @escaping (Args) -> Dependencies) -> some Builder<Args, Product> {
        let productResolver = { args in
            let dependencies = dependenciesResolver(args)
            let product = build(using: dependencies)

            return product
        }

        return ScopedBuilder(productResolver: productResolver)
    }
}

private struct ScopedBuilder<Dependencies, Product>: Builder {
    private let productResolver: (Dependencies) -> Product

    fileprivate init(productResolver: @escaping (Dependencies) -> Product) {
        self.productResolver = productResolver
    }

    // MARK: Builder

    fileprivate func build(using dependencies: Dependencies) -> Product {
        productResolver(dependencies)
    }
}
