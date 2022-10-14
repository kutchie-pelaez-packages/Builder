public protocol Builder {
    associatedtype Dependencies
    associatedtype Product

    func build(using dependencies: Dependencies) -> Product
}

extension Builder {
    public func scoped<Args>(_ dependenciesResolver: @escaping (Args) -> Dependencies) -> ScopedBuilder<Args, Product> {
        let productResolver = { args in
            let dependencies = dependenciesResolver(args)
            let product = build(using: dependencies)

            return product
        }

        return ScopedBuilder(productResolver: productResolver)
    }
}
