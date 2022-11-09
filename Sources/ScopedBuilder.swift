struct ScopedBuilder<Deps, Product>: Builder {
    private let productResolver: (Deps) -> Product

    init(productResolver: @escaping (Deps) -> Product) {
        self.productResolver = productResolver
    }

    // MARK: Builder

    func build(using deps: Deps) -> Product {
        productResolver(deps)
    }
}
