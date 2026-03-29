import SwiftUI
import WebKit

struct LocalLegalView: View {
    let filename: String
    let title: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            WebView(filename: filename)
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(L("action_cancel")) { dismiss() }
                    }
                }
        }
    }
}

struct WebView: UIViewRepresentable {
    let filename: String
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Search in public folder reference (Blue folder)
        if let url = Bundle.main.url(forResource: filename, withExtension: "html", subdirectory: "public") {
            uiView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
            return
        }
        
        // Search in main bundle directly (Yellow folder/Group)
        if let url = Bundle.main.url(forResource: filename, withExtension: "html") {
            uiView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
            return
        }
        
        // If still not found, load a clear error message
        let errorHtml = "<html><body><h1 style='font-family:sans-serif;text-align:center;margin-top:100px;'>Document Not Found</h1><p style='text-align:center;color:gray;'>Please ensure \(filename).html is added to the Xcode bundle.</p></body></html>"
        uiView.loadHTMLString(errorHtml, baseURL: nil)
    }
}
