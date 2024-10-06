//
//  WebView.swift
//  CampingSite
//
//  Created by 여운칠 on 2022/10/05.
//


import Foundation
import SwiftUI
import WebKit
import SafariServices

struct WebView:UIViewRepresentable {

	var urlToLoad:URL

	func makeUIView(context: Context) -> WKWebView {

		let urlRequest = URLRequest(url: urlToLoad, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 5)

		let preferences = WKPreferences()
		preferences.javaScriptCanOpenWindowsAutomatically = false
		let config = WKWebViewConfiguration()
		config.preferences = preferences
		config.dataDetectorTypes = .all

/*
let webView = WKWebView(frame: .zero, configuration: config) ==> frame: CGRect(x: 0.0, y: 0.0, width: 0.1, height: 0.1)
[ViewportSizing] maximumViewportInset cannot be larger than frame
[ViewportSizing] minimumViewportInset cannot be larger than frame
*/
		let webView = WKWebView(frame: CGRect(x: 0.0, y: 0.0, width: 0.1, height: 0.1), configuration: config)

	//	webView.navigationDelegate = context.coordinator
	//	webView.uiDelegate = context.coordinator

		webView.load(urlRequest)

		return webView
	}

	func updateUIView(_ uiView: WKWebView, context: Context) {

	}

}


struct SafariView:UIViewControllerRepresentable {

	var urlToLoad:URL

	func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {

		let safariViewController = SFSafariViewController(url:urlToLoad)
		safariViewController.modalTransitionStyle = .coverVertical

		return safariViewController
	}


	func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {

	}
}


struct WebView_Previews: PreviewProvider {
    static var previews: some View {

		Group{
			WebView(urlToLoad:  URL(string: "https://www.naver.com")!.chkScheme())
			SafariView(urlToLoad: URL(string:"http://apple.com")!.chkScheme())
		}

    }
}
