import SwiftUI

extension [InlineNode] {
    @ViewBuilder
    func render(
        baseURL: URL?,
        textStyles: InlineTextStyles,
        images: [String: Image],
        softBreakMode: SoftBreak.Mode,
        attributes: AttributeContainer
    ) -> some View {
        ForEach(lines(), id: \.self) {
            if case .link = $0.first {
                $0.renderMarkdownText(
                    baseURL: baseURL,
                    textStyles: textStyles,
                    images: images,
                    softBreakMode: softBreakMode,
                    attributes: attributes
                )
            } else {
                $0.renderText(
                    baseURL: baseURL,
                    textStyles: textStyles,
                    images: images,
                    softBreakMode: softBreakMode,
                    attributes: attributes
                )
            }
        }
    }

    @ViewBuilder
    private func renderMarkdownText(
        baseURL: URL?,
        textStyles: InlineTextStyles,
        images: [String: Image],
        softBreakMode: SoftBreak.Mode,
        attributes: AttributeContainer
    ) -> some View {
        var renderer = MarkdownTextInlineRenderer(
            baseURL: baseURL,
            textStyles: textStyles,
            images: images,
            softBreakMode: softBreakMode,
            attributes: attributes
        )
        renderer.render(self)
    }

    private func lines() -> [[InlineNode]] {
        var lines = [[InlineNode]]()
        var nodesLine: [InlineNode]?
        self.forEach {
            if case .link = $0 {
                if nodesLine != nil {
                    lines.append(nodesLine!)
                    nodesLine = nil
                }
                lines.append([$0])
            } else if nodesLine == nil {
                nodesLine = [$0]
            } else {
                nodesLine?.append($0)
            }
        }

        if nodesLine != nil {
            lines.append(nodesLine!)
        }

        return lines
    }
}

struct MarkdownTextInlineRenderer {

    private let baseURL: URL?
    private let textStyles: InlineTextStyles
    private let images: [String: Image]
    private let softBreakMode: SoftBreak.Mode
    private let attributes: AttributeContainer
    private static var shouldSkipNextWhitespace = false

    init(
        baseURL: URL?,
        textStyles: InlineTextStyles,
        images: [String: Image],
        softBreakMode: SoftBreak.Mode,
        attributes: AttributeContainer
    ) {
        self.baseURL = baseURL
        self.textStyles = textStyles
        self.images = images
        self.softBreakMode = softBreakMode
        self.attributes = attributes
    }

    @ViewBuilder
    func render(_ inlines: [InlineNode]) -> some View {
        ForEach(inlines, id: \.id) {
            switch $0 {
            case .text(let content):
                self.renderText(content)
            case .softBreak:
                self.renderSoftBreak()
            case .html(let content):
                self.renderHTML(content)
            case .image(let source, _):
                self.renderImage(source)
            case .link:
                self.renderLink($0)
            default:
                self.defaultRender($0)
            }
        }
    }

    private func renderText(_ text: String) -> some View {
        var text = text

        if Self.shouldSkipNextWhitespace {
            Self.shouldSkipNextWhitespace = false
            text = text.replacingOccurrences(of: "^\\s+", with: "", options: .regularExpression)
        }

        return self.defaultRender(.text(text))
    }

    private func renderSoftBreak() -> some View {
        switch self.softBreakMode {
        case .space where Self.shouldSkipNextWhitespace:
            Self.shouldSkipNextWhitespace = false
            return self.defaultRender(.text(""))
        case .space:
            return self.defaultRender(.softBreak)
        case .lineBreak:
            Self.shouldSkipNextWhitespace = true
            return self.defaultRender(.lineBreak)
        }
    }

    private func renderHTML(_ html: String) -> some View {
        let tag = HTMLTag(html)

        switch tag?.name.lowercased() {
        case "br":
            Self.shouldSkipNextWhitespace = true
            return self.defaultRender(.lineBreak)
        default:
            return self.defaultRender(.html(html))
        }
    }

    private func renderImage(_ source: String) -> some View {
        if let image = self.images[source] {
            return Text(image)
        }
        return Text("")
    }

    private func defaultRender(_ inline: InlineNode) -> some View {
        Text(inline.renderAttributedString(
            baseURL: self.baseURL,
            textStyles: self.textStyles,
            softBreakMode: self.softBreakMode,
            attributes: self.attributes
        ))
    }

    private func renderLink(_ inline: InlineNode) -> some View {
        let text = inline.renderAttributedString(
            baseURL: self.baseURL,
            textStyles: self.textStyles,
            softBreakMode: self.softBreakMode,
            attributes: self.attributes
        )

        return MarkdownText(
            .init(
                text: NSAttributedString(text),
                textStyle: textStyles.link,
                attributes: attributes
            )
        )
    }
}
