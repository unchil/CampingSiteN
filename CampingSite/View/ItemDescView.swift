//
//  ItemDescView.swift
//  CampingSite
//
//  Created by 여운칠 on 2022/10/15.
//

import SwiftUI

struct ItemDescView: View {

	let controller = GoCampingController.controller

    var body: some View {

		GroupBox (
			label: Label(self.controller.currentCampSite.facltNm, systemImage: "arrowshape.bounce.right"),
			content: {
				if self.controller.currentCampSite.firstImageUrl.isEmpty && self.controller.currentCampSite.intro.isEmpty {
					VStack{
						Spacer()
						HStack{
							Spacer()
							Label("No Data Found", systemImage: "exclamationmark.triangle")
							.font(.system(size: 16, weight: .bold, design: .default))
							Spacer()
						}
						Spacer()
					}
				} else {

					VStack(){

						if !self.controller.currentCampSite.firstImageUrl.isEmpty {
							ImageView(url:URL(string: self.controller.currentCampSite.firstImageUrl),imgCallerView: "ItemDescView")
								.cornerRadius(6)
						}

						if !self.controller.currentCampSite.intro.isEmpty {

							ScrollView{
								HStack{
									Spacer()
									Text(self.controller.currentCampSite.intro)
									Spacer()
								}
							}
						}
					}.padding([.horizontal,.bottom])
				}
		}).groupBoxStyle(ItemDescGroupBoxStyle())

    }
}



struct ItemDescView_Previews: PreviewProvider {
    static var previews: some View {
        ItemDescView()
    }
}
