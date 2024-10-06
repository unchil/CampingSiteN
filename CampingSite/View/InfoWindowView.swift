//
//  InfoWindowView.swift 
//  CampingSite
//
//  Created by 여운칠 on 2022/10/27.
//

import SwiftUI

struct InfoWindowView: View {

	let markerController = GMSMarkerController.controller
	var frameWidth:CGFloat
	var frameHeight:CGFloat
	var radius:CGFloat = 6

    var body: some View {

		ZStack {

			RoundedRectangle(cornerRadius: self.radius )
			.foregroundColor(.clear)

			if let userData = self.markerController.currentMarker?.userData as? CampingSiteData {
				VStack(spacing:6){

					Text(userData.facltNm)
					.font(.system(size: 12, weight: .bold, design: .default))

					if !userData.lineIntro.isEmpty {
						Text(userData.lineIntro)
						.frame(width: self.frameWidth - 20, height: 10)
						.font(.system(size: 10, weight: .light, design: .default))
					}

					ImageView(url:URL(string: userData.firstImageUrl),imgCallerView: "InfoWindowView")
					.frame(width: 150, height: 100)
					.cornerRadius(6)

				}
			}

		}
		.frame(width: self.frameWidth, height: self.frameHeight)
		.background(.clear)
		.shadow(color: .gray, radius: 3, x: 3, y: 3)
	}

}

struct InfoWindowView_Previews: PreviewProvider {
	static let userdata = CampingSiteData.makeDefaultValue()
    static var previews: some View {
        InfoWindowView(frameWidth: 190,frameHeight: 170)
    }
}
