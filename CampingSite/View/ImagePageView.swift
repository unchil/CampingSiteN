//
//  ImagePageView.swift
//  campsite
//
//  Created by 여운칠 on 2022/09/28.
//

import SwiftUI

struct ImagePageView: View {

	@StateObject var controller = GoCampingController.controller
	@State var selected:Int = 0

	var body: some View {

		ZStack{

			if self.controller.imageUrlPathList.isEmpty {
				RefreshView()
			} else {

				TabView (selection: $selected) {

					ForEach(self.controller.imageUrlPathList, id:\.self) { url in

						WebView(urlToLoad: url.chkScheme() )
						.cornerRadius(6)
						.tabItem {
							Label("", systemImage: "circle.fill")
						}.tag(url.hashValue)
					}
				}
				.tabViewStyle(.page)
				.indexViewStyle(.page(backgroundDisplayMode: .always))
			}

		}
	}
}

struct ImagePageView_Previews: PreviewProvider {


    static var previews: some View {
		ImagePageView()
    }
}
