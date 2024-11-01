import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_api/sass_api.dart' as sass;
import 'stylesheet_document_link.dart';

typedef UnresolvedLinkData = (StylesheetDocumentLink, bool);

class LinkVisitor with sass.RecursiveStatementVisitor {
  List<UnresolvedLinkData> unresolvedLinks = [];

  @override
  void visitUseRule(sass.UseRule node) {
    super.visitUseRule(node);
    const isSassLink = true;
    unresolvedLinks.add((
      StylesheetDocumentLink(
        type: LinkType.use,
        target: node.url,
        range: lsp.Range(
          end: lsp.Position(
              line: node.urlSpan.end.line, character: node.urlSpan.end.column),
          start: lsp.Position(
              line: node.urlSpan.start.line,
              character: node.urlSpan.start.column),
        ),
        alias: node.namespace == null ||
                node.url.toString().contains(node.namespace!)
            ? null
            : node.namespace,
        namespace: node.namespace,
      ),
      isSassLink
    ));
  }

  @override
  void visitForwardRule(sass.ForwardRule node) {
    super.visitForwardRule(node);
    const isSassLink = true;
    unresolvedLinks.add((
      StylesheetDocumentLink(
        type: LinkType.forward,
        target: node.url,
        range: lsp.Range(
          end: lsp.Position(
              line: node.urlSpan.end.line, character: node.urlSpan.end.column),
          start: lsp.Position(
              line: node.urlSpan.start.line,
              character: node.urlSpan.start.column),
        ),
        shownVariables: node.shownVariables,
        hiddenVariables: node.hiddenVariables,
      ),
      isSassLink
    ));
  }

  @override
  void visitImportRule(sass.ImportRule node) {
    super.visitImportRule(node);
    const isSassLink = true;
    for (var import in node.imports) {
      if (import is sass.DynamicImport) {
        unresolvedLinks.add((
          StylesheetDocumentLink(
            type: LinkType.import,
            range: lsp.Range(
              end: lsp.Position(
                  line: import.urlSpan.end.line,
                  character: import.urlSpan.end.column),
              start: lsp.Position(
                  line: import.urlSpan.start.line,
                  character: import.urlSpan.start.column),
            ),
          ),
          isSassLink
        ));
      } else {
        var staticImport = import as sass.StaticImport;
        unresolvedLinks.add((
          StylesheetDocumentLink(
            type: LinkType.import,
            range: lsp.Range(
              end: lsp.Position(
                  line: staticImport.url.span.end.line,
                  character: staticImport.url.span.end.column),
              start: lsp.Position(
                  line: staticImport.url.span.start.line,
                  character: staticImport.url.span.start.column),
            ),
          ),
          isSassLink
        ));
      }
    }
  }
}
