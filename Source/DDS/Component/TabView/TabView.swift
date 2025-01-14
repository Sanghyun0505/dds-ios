import SwiftUI
import Combine

@available(macOS 12, iOS 15, *)
public struct DodamTabView: View {
    
    private let contents: [DodamPage]
    
    public init(
        selection: Binding<Int>? = nil,
        @DodamPage.Builder contents: () -> [DodamPage]
    ) {
        self.selection = selection
        let selected = selection?.wrappedValue ?? 0
        self.selected = selected
        self.animatedSelection = selected
        self.contents = contents()
    }
    
    @Namespace private var animation
    @State private var selection: Binding<Int>?
    @State private var selected: Int
    @State private var animatedSelection: Int
    
    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                ForEach(contents.indices, id: \.self) { idx in
                    if selected == idx {
                        contents[idx].content
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                HStack {
                    Spacer()
                    ForEach(contents.indices, id: \.self) { idx in
                        let isSelected = animatedSelection == idx
                        if case let .icon(image) = contents[idx].label {
                            Button {
                                if selected != idx {
                                    selected = idx
                                    withAnimation(.spring(duration: 0.2)) {
                                        animatedSelection = idx
                                    }
                                }
                            } label: {
                                Dodam.icon(image, size: 24)
                                    .padding(8)
                                    .dodamColor(
                                        isSelected ? .onPrimary : .onSurface
                                    )
                            }
                            .background(
                                Group {
                                    if isSelected {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.tint)
                                            .matchedGeometryEffect(
                                                id: 0,
                                                in: animation
                                            )
                                    }
                                }
                            )
                            Spacer()
                        }
                    }
                }
                .padding(.vertical, 12)
                .background(Dodam.color(.surfaceContainer))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 16)
                .padding(
                    .bottom,
                    proxy.safeAreaInsets.bottom == 0 ? 16 : 0
                )
            }
        }
        .onChange(of: selected) { newValue in
            selection?.wrappedValue = newValue
        }
        .onReceive(Just(selection)) { newValue in
            if let newValue,
               selected != newValue.wrappedValue {
                withAnimation(.spring) {
                    selected = newValue.wrappedValue
                }
            }
        }
    }
}

#Preview {
    struct DodamPagePreview: View {
        
        @State private var selection: Int = 0
        
        var body: some View {
            DodamTabView(selection: $selection) {
                Text("Home")
                    .page(.icon(.home))
                Text("Meal")
                    .page(.icon(.forkAndKnife))
                Text("Out")
                    .page(.icon(.doorOpen))
                Text("NightStudy")
                    .page(.icon(.moonPlus))
                Text("Menu")
                    .page(.icon(.menu))
            }
        }
    }
    return DodamPagePreview()
}
