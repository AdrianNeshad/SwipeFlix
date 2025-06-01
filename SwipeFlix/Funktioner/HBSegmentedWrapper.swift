//
//  HBSegmentedWrapper.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-06-01.
//

import SwiftUI

struct HBSegmentedPicker: UIViewRepresentable {
    @Binding var selectedIndex: Int
    var items: [String]

    func makeUIView(context: Context) -> HBSegmentedControl {
        let control = HBSegmentedControl()
        control.items = items
        control.selectedIndex = selectedIndex
        control.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged(_:)), for: .valueChanged)
        return control
    }

    func updateUIView(_ uiView: HBSegmentedControl, context: Context) {
        uiView.selectedIndex = selectedIndex
        uiView.items = items
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: HBSegmentedPicker

        init(_ parent: HBSegmentedPicker) {
            self.parent = parent
        }

        @objc func valueChanged(_ sender: HBSegmentedControl) {
            parent.selectedIndex = sender.selectedIndex
        }
    }
}
