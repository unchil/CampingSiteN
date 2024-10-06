//
//  ItemHeaderView.swift
//  campsite
//
//  Created by 여운칠 on 2022/09/27.
//

import SwiftUI

struct ItemHeaderView: View {

	var item:CampingSiteData
	let frameWidth:CGFloat = 320
	let frameHeight:CGFloat = 200
	let imageWidth:CGFloat = 120
	let imageHeight:CGFloat = 90
	let imageRadius:CGFloat = 6
	let lineIntroWidth:CGFloat = 270
	let lineIntroHeight:CGFloat = 20
	let contentWidth:CGFloat = 280
	let contentHeight:CGFloat = 100
	let contentPadding:CGFloat = 6

	let bgColor = Color.white

    var body: some View {

		GroupBox (label: Label(item.facltNm, systemImage: "leaf"), content: {

			VStack{

				Text(item.lineIntro)
				.frame(width:self.lineIntroWidth, height: self.lineIntroHeight)

				HStack(alignment: .center){

					VStack(alignment: .leading){
						Text("업종 : \(item.induty)")
						Text("운영 : \(item.facltDivNm)")
						Text("입지 : \(item.lctCl)")
						Text("애완동물 : \(item.animalCmgCl)")
					}
					Spacer()
					ImageView(url:URL(string: item.firstImageUrl))
					.frame(width:self.imageWidth, height: self.imageHeight)


				}.frame(width:self.contentWidth, height: self.contentHeight)
				.padding([.horizontal, .bottom], self.contentPadding)

			}
		})
		.groupBoxStyle(ItemGroupBoxStyle(bgColor: self.bgColor))
		.modifier(CardView(bgColor: self.bgColor,frameWidth:self.frameWidth, frameHeight: self.frameHeight))

    }
}




struct ItemHeaderView_Previews: PreviewProvider {
    static var previews: some View {

    ItemHeaderView(item: CampingSiteData.makeDefaultValue())
/*
		ScrollView{
			ForEach(0..<5) { _ in
				ItemHeaderView(item: CampingSiteData.makeDefaultValue())
				.padding([.bottom, .trailing], 10)
			}
        }.padding(.horizontal)
*/

    }
}
