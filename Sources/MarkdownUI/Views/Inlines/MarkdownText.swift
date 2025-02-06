import SwiftUI
import UIKit

public struct MarkdownTextVM {
    let text: NSAttributedString
}

public struct MarkdownText: UIViewRepresentable {

    public let viewModel: MarkdownTextVM

    public init(_ viewModel: MarkdownTextVM) {
        self.viewModel = viewModel
    }

    public func makeUIView(context: Context) -> MarkdownTextView {
        let view = UIViewType()
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        view.isEditable = false
        view.isScrollEnabled = false
        view.contentInset = .zero
        view.configure(with: viewModel)
        return view
    }

    public func updateUIView(_ uiView: MarkdownTextView, context: Context) {
        uiView.configure(with: viewModel)
    }
}

public final class MarkdownTextView: UITextView {
    func configure(with vm: MarkdownTextVM) {
        self.attributedText = vm.text
//        invalidateIntrinsicContentSize()
    }

//    public override var intrinsicContentSize: CGSize {
//        let height = attributedText.boundingRect(
//            with: CGSize(width: bounds.width, height: .greatestFiniteMagnitude),
//            options: [.usesLineFragmentOrigin, .usesFontLeading],
//            context: nil
//        ).size.height
//
//        let width = attributedText.boundingRect(
//            with: CGSize(width: .greatestFiniteMagnitude, height: height),
//            options: [.usesLineFragmentOrigin, .usesFontLeading],
//            context: nil
//        ).size.height
//
//        print("[MRKDN]: bounds.width= \(bounds.width), width= \(width), height= \(height), text= \(attributedText.string)")
//
//        return CGSize(width: width, height: height)
//    }
}
