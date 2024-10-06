//
//  ItemDetailView.swift
//  campsite
//
//  Created by 여운칠 on 2022/09/27.
//

import SwiftUI

struct ItemDetailView: View {

	var item:CampingSiteData
	let frameWidth:CGFloat = ( UIScreen.main.bounds.size.width * (7/10) )
	let frameHeight:CGFloat = ( UIScreen.main.bounds.size.height * (5/10) )
	let backgroundImg = "forest2.jpg"
	
    var body: some View {

		ZStack{
			if item.firstImageUrl.isEmpty {
				Image(uiImage: UIImage(named: self.backgroundImg)!)
				.scaledToFill()
			} else {
				ImageView( url: URL(string: item.firstImageUrl), imgCallerView: "ItemDetailView")
				.scaledToFill()
			}

			RoundedRectangle(cornerRadius: 8)
			.foregroundColor(.white.opacity(0.6))
			.frame(width: self.frameWidth, height: self.frameHeight)
			.overlay {

				VStack(alignment: .center){

					Label(item.facltNm, systemImage: "arrowshape.bounce.right")
					.font(.system(size: 18, weight: .bold, design: .default))
					.labelStyle(.titleOnly)
					.padding(.vertical)

					VStack(alignment: .leading){

						if !item.tel.isEmpty {
							Label("전화번호 :", systemImage: "phone.down.circle")
							Text("\t\(item.tel)")
						}

						if !item.addr1.isEmpty {
							Label("주소 :", systemImage: "signpost.right")
							Text("\t\(item.addr1)")
						}

						if !item.resveCl.isEmpty {
							Label("예약구분 :", systemImage: "note.text.badge.plus")
							Text("\t\(item.resveCl)")
						}

						if !item.sbrsCl.isEmpty {
							Label("캠핑시설 :", systemImage: "suit.spade")
							Text("\t\(item.sbrsCl)")
						}

						if !item.eqpmnLendCl.isEmpty {
							Label("대여장비 :", systemImage: "suit.spade")
							Text("\t\(item.eqpmnLendCl)")
						}

						if !item.glampInnerFclty.isEmpty {
							Label("글램핑시설 :", systemImage: "suit.spade")
							Text("\t\(item.glampInnerFclty)")
						}

					}
					.padding()
				}

			}

		}
    }
}



struct ItemDetailView_Previews: PreviewProvider {
    static var previews: some View {

		Group{
			ItemDetailView(item: CampingSiteData.makeDefaultValue())
		}
    }
}

