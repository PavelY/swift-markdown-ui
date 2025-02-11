import SwiftUI
import UIKit

public struct MarkdownTextVM {
    let text: NSAttributedString
    let textStyle: TextStyle
    let attributes: AttributeContainer
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
        self.linkTextAttributes = vm.nsAttributes
        self.textStorage.setAttributes(vm.nsAttributes, range: vm.text.fullRange)
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

private extension NSAttributedString {
    var fullRange: NSRange {
        .init(location: 0, length: string.count)
    }
}

private extension MarkdownTextVM {
    var nsAttributes: [NSAttributedString.Key: Any]? {
        var attributes = [NSAttributedString.Key: Any]()

        self.text.enumerateAttribute(.link, in: self.text.fullRange) { value, _, _ in
            if let value {
                attributes[.link] = value
            }
        }

        if
            case .custom(let name) = self.attributes.fontProperties?.family,
            let size = self.attributes.fontProperties?.size
        {
            attributes[.font] = UIFont(name: name, size: size)
        }

        var container = AttributeContainer()
        self.textStyle._collectAttributes(in: &container)
        if let color = container.foregroundColor {
            attributes[.foregroundColor] = UIColor(color)
            attributes[.strokeColor] = UIColor(color)
        }

        return attributes
    }
}
