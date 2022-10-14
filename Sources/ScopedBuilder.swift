public struct ScopedBuilder<Dependencies, Product>: Builder {
    let productResolver: (Dependencies) -> Product

    // MARK: Builder

    public func build(using dependencies: Dependencies) -> Product {
        productResolver(dependencies)
    }
}
