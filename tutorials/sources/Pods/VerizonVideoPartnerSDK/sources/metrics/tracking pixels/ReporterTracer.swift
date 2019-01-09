class ReporterTracer {
    init(parent: Player.Tracer) {
        self.parent = parent
    }
    
    weak var parent: Player.Tracer?
    
    var currentItem: [JSøN] = []
    
    func record(cachebuster: String) {
        currentItem.append(
            ["cachebuster" : cachebuster |> json ] |> json
        )
    }
    
    func record(url: URL?) {
        currentItem.append(
            ["url" : url |> json ] |> json
        )
    }
    
    func completeItem() {
        parent?.record(metric: currentItem |> json)
        currentItem = []
    }
}
