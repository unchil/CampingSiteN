//
//  RefreshView.swift
//  CampingSite
//
//  Created by 여운칠 on 2022/10/31.
//

import SwiftUI

struct RefreshView: View {

	@StateObject var controller = GoCampingController.controller

	@State var isDelayView:Bool = true

	let loadingBoxMsg = "Image Download"
	let loadingBoxImg = "icloud.and.arrow.down"

	let emptyBoxResultMsg = "No Data Found"
	let emptyBoxResultImg = "tray"

    var body: some View {

		HStack{
			Spacer()
			VStack {
				Spacer()
				if self.isDelayView {
					Label(self.loadingBoxMsg, systemImage: self.loadingBoxImg)
					.font(.system(size: 16, weight: .bold, design: .default))
					.padding(.bottom)

					ProgressView()
					.scaleEffect(2)

				} else {
					Label(self.emptyBoxResultMsg, systemImage: self.emptyBoxResultImg)
					.font(.system(size: 16, weight: .bold, design: .default))
				}
				Spacer()
			}
			Spacer()
		}.onAppear{
			if let _ = self.controller.currentCampSite.isImageListLoaded {
				self.isDelayView = false
			}
		}
		.onChange(of: self.controller.currentCampSite.isImageListLoaded) { newValue in
			self.isDelayView = false
		}

    }
}


struct RefreshView_Previews: PreviewProvider {
    static var previews: some View {
        RefreshView()
    }
}
