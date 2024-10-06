//
//  ItemInfoView.swift
//  CampingSite
//
//  Created by 여운칠 on 2022/10/15.
//

import SwiftUI
import SafariServices

struct ItemInfoView: View {

	let controller = GoCampingController.controller

	@State var selectedTab:Int = PreviewContextMenu.DESC.rawValue
	@State var isSafariView:Bool = false
	@State var currentURL:String?

    var body: some View {

		TabView(selection: $selectedTab) {

			ItemDescView()
			.modifier(CardModifier(lineWidth: 2, radius: 6))
			.tabItem({
				Label(PreviewContextMenu.DESC.title,systemImage: PreviewContextMenu.DESC.systemImage) })
			.tag(PreviewContextMenu.DESC.rawValue)

			ImagePageView()
			.modifier(CardModifier(lineWidth: 2, radius: 6))
			.tabItem({
				Label(PreviewContextMenu.IMAGE.title, systemImage: PreviewContextMenu.IMAGE.systemImage) })
			.tag(PreviewContextMenu.IMAGE.rawValue)

			if !self.controller.currentCampSite.homepage.isEmpty,
				let url = URL(string: self.controller.currentCampSite.homepage)
			//	let chkURL = url.chkScheme()
            {

			//	SafariView(urlToLoad:chkURL)
                SafariView(urlToLoad:url)
				.modifier(CardModifier(lineWidth: 2, radius: 6))
				.tabItem({
					Label(PreviewContextMenu.HOME_PAGE.title, systemImage: PreviewContextMenu.HOME_PAGE.systemImage) })
				.tag(PreviewContextMenu.HOME_PAGE.rawValue)
			}

			if !self.controller.currentCampSite.resveUrl.isEmpty,
				let url = URL(string: self.controller.currentCampSite.resveUrl)
               // ,let chkURL = url.chkScheme()
            {

				//SafariView(urlToLoad: chkURL)
                SafariView(urlToLoad: url)
				.modifier(CardModifier(lineWidth: 2, radius: 6))
				.tabItem({
					Label(PreviewContextMenu.RESERVATION_PAGE.title, systemImage: PreviewContextMenu.RESERVATION_PAGE.systemImage) })
				.tag(PreviewContextMenu.RESERVATION_PAGE.rawValue)
			}

		}.onChange(of: selectedTab) { newValue in
			UISelectionFeedbackGenerator().selectionChanged()
		}

    }
}


struct ItemInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ItemInfoView()
    }
}
