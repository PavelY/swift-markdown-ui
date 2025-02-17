import SwiftUI
import UIKit

public struct InlineTextVM {
    let text: NSAttributedString
//    let textStyle: TextStyle
//    let attributes: AttributeContainer
}

public struct InlineTextView: UIViewRepresentable {

    public let viewModel: InlineTextVM

    public init(_ viewModel: InlineTextVM) {
        self.viewModel = viewModel
    }

    public func makeUIView(context: Context) -> InlineUITextView {
        let view = UIViewType()
        view.isEditable = false
        view.isScrollEnabled = false
        view.contentInset = .zero
        view.backgroundColor = .clear
        view.configure(with: viewModel)
        return view
    }

    public func updateUIView(_ uiView: InlineUITextView, context: Context) {
        uiView.configure(with: viewModel)
    }
}

public final class InlineUITextView: UITextView {
    func configure(with vm: InlineTextVM) {
        self.attributedText = vm.text
//        self.linkTextAttributes = vm.nsAttributes
//        self.textStorage.setAttributes(vm.nsAttributes, range: vm.text.fullRange)
        self.textContainer.lineBreakMode = .byWordWrapping
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        if !self.bounds.size.equalTo(self.intrinsicContentSize) {
            invalidateIntrinsicContentSize()
        }
    }

    public override var intrinsicContentSize: CGSize {
        let superIntrinsic = super.intrinsicContentSize

        let width = self.bounds.width
        let size = attributedText.boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin],
            context: nil
        ).size
        let height = size.height + textContainerInset.top + textContainerInset.bottom + 5
        return CGSize(width: width, height: height)
    }
}

private extension NSAttributedString {
    var fullRange: NSRange {
        .init(location: 0, length: string.count)
    }
}

//private extension InlineTextVM {
//    var nsAttributes: [NSAttributedString.Key: Any]? {
//        var attributes = [NSAttributedString.Key: Any]()
//
//        self.text.enumerateAttribute(.link, in: self.text.fullRange) { value, _, _ in
//            if let value {
//                attributes[.link] = value
//            }
//        }
//
//        if
//            case .custom(let name) = self.attributes.fontProperties?.family,
//            let size = self.attributes.fontProperties?.size
//        {
//            attributes[.font] = UIFont(name: name, size: size)
//        }
//
//        var container = AttributeContainer()
//        self.textStyle._collectAttributes(in: &container)
//        if let color = container.foregroundColor {
//            attributes[.foregroundColor] = UIColor(color)
//            attributes[.strokeColor] = UIColor(color)
//        }
//
//        return attributes
//    }
//}
