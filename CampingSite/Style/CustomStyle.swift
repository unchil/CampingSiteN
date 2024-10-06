//
//  CustomStyle.swift
//  CampingSite
//
//  Created by 여운칠 on 2022/10/29.
//

import Foundation
import SwiftUI

struct CardModifier: ViewModifier {
	var lineWidth:CGFloat
	var color:Color = .gray
	var radius:CGFloat = 10
    func body(content: Content) -> some View {
    
        content
		.overlay(
			RoundedRectangle(cornerRadius: self.radius)
			.stroke( self.color , lineWidth: self.lineWidth)
		)
    }
}

struct ItemDescGroupBoxStyle: GroupBoxStyle {

	var bgColor = Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))

    func makeBody(configuration: Configuration) -> some View {

        VStack(alignment: .center) {

			configuration.label
			.font(.system(size: 20, weight: .bold, design: .default))
			.labelStyle(.titleOnly)
			.padding(.top)

            configuration.content
        }
        .background(Color.clear)


    }
}



struct ItemSCrollGroupBoxStyle: GroupBoxStyle {

	var bgColor = Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))

    func makeBody(configuration: Configuration) -> some View {

		ZStack{

			bgColor.opacity(0.1)

			VStack(alignment: .center, spacing: 0) {

				configuration.label
				.font(.system(size: 16, weight: .bold, design: .serif))
				.padding()

				configuration.content

			}

		}

    }
}



struct ItemGroupBoxStyle: GroupBoxStyle {

	var bgColor:Color

    func makeBody(configuration: Configuration) -> some View {

			VStack(alignment: .center, spacing: 0) {

				configuration.label
				.font(.system(size: 16, weight: .bold, design: .default))
				.padding()

				configuration.content
				.font(.system(size: 14, weight: .regular, design: .default))

			}
			.background(bgColor)

    }
}


struct CardView: ViewModifier {

	var bgColor:Color

	var frameWidth:CGFloat
	var frameHeight:CGFloat

    func body(content: Content) -> some View {

		ZStack{

			Rectangle()
			.foregroundColor(.clear)

			RoundedRectangle(cornerRadius: 10)
			.foregroundColor(self.bgColor)
			.shadow(color: .gray, radius: 3, x: 6, y: 3)

			RoundedRectangle(cornerRadius: 10)
			.stroke(.gray, lineWidth: 1)

			content

		}
		.frame(width: self.frameWidth, height: self.frameHeight)

    }
}




struct StyleTestView: View {

	var item = CampingSiteData.makeDefaultValue()

	let frameWidth:CGFloat = 300
	let frameHeight:CGFloat = 210

	let imageWidth:CGFloat = 120
	let imageHeight:CGFloat = 90

	let bgColor =  Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))

    var body: some View {


ScrollView(.horizontal) {
HStack {
ForEach(0..<5) { _ in



	GroupBox{
		ScrollView{
			ForEach(0..<5) { _ in
				GroupBox (label: Label(item.facltNm, systemImage: "leaf"), content: {

					VStack{

						Text("동해물과 백두산이 마르고 닳도록 하느님이")
						.frame(width:270, height: 20)

						HStack{

							VStack(alignment: .leading, spacing: 0){
								Text("업종 : " + item.induty)
								Text("운영 : " + item.facltDivNm)
								Text("입지 : " + item.lctCl)
								Text("애완동물 : 호랑이 사자 곰 코끼리 " )
							}

							ImageView(url:URL(string: item.firstImageUrl))
							.cornerRadius(6)
							.frame(width:self.imageWidth, height: self.imageHeight)


						}.frame(height: 100)
						.padding([.horizontal, .bottom], 6)
					}

				})
				.groupBoxStyle(ItemGroupBoxStyle(bgColor: self.bgColor))
				.modifier(CardView(bgColor: self.bgColor, frameWidth: self.frameWidth, frameHeight: self.frameHeight))
				.padding([.bottom, .trailing], 10)
			}
        }.padding(.horizontal)

	}label: {
		Label( "경기도 군포시 :" , systemImage: "signpost.right")
	}
	.groupBoxStyle(ItemSCrollGroupBoxStyle())
	.modifier(CardModifier(lineWidth: 1))


}}}

	}
}



struct StyleTestView_Previews: PreviewProvider {
    static var previews: some View {
        StyleTestView()
    }
}

