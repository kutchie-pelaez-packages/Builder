public protocol Builder<Deps, Product> {
    associatedtype Deps
    associatedtype Product

    func build(using deps: Deps) -> Product
}

extension Builder where Deps == Void {
    public func build() -> Product {
        build(using: ())
    }
}

extension Builder {
    public func scoped<Args>(_ depsResolver: @escaping (Args) -> Deps) -> some Builder<Args, Product> {
        let productResolver = { args in
            let deps = depsResolver(args)
            let product = build(using: deps)

            return product
        }

        return ScopedBuilder(productResolver: productResolver)
    }
}
