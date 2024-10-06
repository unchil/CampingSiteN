//
//  EmtpyGroupBoxView.swift
//  CampingSite
//
//  Created by 여운칠 on 2022/10/27.
//

import SwiftUI

struct EmtpyGroupBoxView: View {

	@Binding var labelText:String
	@Binding var labelImg:String
	@Binding var emptyBoxMsg:String
	@Binding var emptyBoxImg:String

    var body: some View {
		GroupBox {

			VStack{
				Spacer()
				HStack{
					Spacer()
					Label(self.emptyBoxMsg, systemImage: self.emptyBoxImg)
					.font(.system(size: 16, weight: .bold, design: .default))
					.scaleEffect(1, anchor: .center)
					Spacer()
				}
				Spacer()
			}

		} label: {
				Label( self.labelText , systemImage: self.labelImg)
		}.groupBoxStyle(ItemSCrollGroupBoxStyle())
    }
}

struct EmtpyGroupBoxView_Previews: PreviewProvider {
    static var previews: some View {
        EmtpyGroupBoxView(
			labelText:.constant("경기도 안양시 만안구 : "),
			labelImg: .constant("signpost.right"),
			emptyBoxMsg: .constant("Data Loading ..."),
			emptyBoxImg: .constant("doc.text.magnifyingglass")
		)
    }
}
