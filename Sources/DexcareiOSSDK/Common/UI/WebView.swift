//
//  WebView.swift
//  DexcareiOSSDK
//
//  Created by Alex Maslov on 2024-07-25.
//  Copyright © 2024 DexCare. All rights reserved.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let surveyExitMessageName = "onExitSurvey"

    let request: URLRequest
    let didExitSurvey: (() -> Void)?

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()

        webView.configuration.userContentController.add(context.coordinator, name: surveyExitMessageName)
        webView.navigationDelegate = context.coordinator

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.load(request)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == parent.surveyExitMessageName {
                parent.didExitSurvey?()
            }
        }

        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }
    }
}

struct SurveyWebView: View {
    let request: URLRequest
    let didExitSurvey: (() -> Void)?
    let didTapClose: (() -> Void)?

    var body: some View {
        WebView(request: request, didExitSurvey: didExitSurvey)
            .navigationBarItems(leading: Button(action: {
                didTapClose?()
            }) {
                Text(localizeString("waitingRoom_message_dismiss"))
            })
            .navigationBarBackButtonHidden()
    }
}
