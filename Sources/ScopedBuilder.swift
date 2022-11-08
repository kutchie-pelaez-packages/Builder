struct ScopedBuilder<Dependencies, Product>: Builder {
    private let productResolver: (Dependencies) -> Product

    init(productResolver: @escaping (Dependencies) -> Product) {
        self.productResolver = productResolver
    }

    // MARK: Builder

    func build(using dependencies: Dependencies) -> Product {
        productResolver(dependencies)
    }
}
