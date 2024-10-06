//
//  ErrorLoadView.swift
//  CampingSite
//
//  Created by 여운칠 on 2022/10/28.
//

import SwiftUI

struct ErrorLoadView: View {

    @Environment(\.managedObjectContext) private var viewContext
	@Binding var isErrorLoad:Bool
	var errorCallerView:String
	@Binding var isDescPage:Bool

	let controller = GoCampingController.controller

	static let locationAuthMsg = LocationAuthMessageView()
	static let errorMsg = ErrorLoadMessageView()
	static let downLoadMsg = DownLoadMessageView()
	static let delayMsg = DelayLoadMessageView()
	static let errorLoadImage = ErrorLoadImageView()
	static let emptyLoadImage = EmptyLoadImageView()


	@State var isErrorMsg = true

    var body: some View {

		VStack{

			Image(systemName: "exclamationmark.triangle")
			.foregroundColor(.red)
			.scaleEffect(2)
			.padding(.bottom, 20)

			Text("네트워크 상황이 불안정하거나 서버 문제로 \n 데이터를 불러오지 못했습니다.\n")
			.font(.system(size: 16, weight: .regular, design: .default))

		//	if let viewName = self.errorCallerView {
			//	switch viewName {
            switch  self.errorCallerView {
					case "\(IntroView.self)" : do {
						Text("삭제 후 다시 설치해 주세요.")
						.font(.system(size: 20, weight: .regular, design: .default))
					}
					case "\(CampingSitesView.self)" : do {
						Button("재시도") {
							UISelectionFeedbackGenerator().selectionChanged()
							self.isErrorLoad.toggle()
							self.isDescPage.toggle()

							DispatchQueue.global(qos:.default).async {
								self.controller.getCampSiteImageList(
									context: self.viewContext
								){ result in
									if result == false {
										self.isDescPage.toggle()
										self.isErrorLoad.toggle()
									}
								}
							}
						}
					}
					default: Spacer()
				}

			//}

		}
    }



}

extension ErrorLoadView {

	struct LocationAuthMessageView: View {
		var body: some View {

			RoundedRectangle(cornerRadius: 6)
				.frame(width: 300, height: 60)
				.foregroundColor(Color.white.opacity(0.8))
				.overlay(content: {
					Text("[설정]의 [Search Camp/위치]에서 [위치 접근 허용]을 [앱을 사용하는 동안]에 체크 하신후 사용하시기 바랍니다.")
						.font(.system(size: 16, weight: .regular, design: .default))
				})
		}
	}

	struct DownLoadMessageView: View {
		var body: some View {

			RoundedRectangle(cornerRadius: 6)
				.frame(width: 300, height: 60)
				.foregroundColor(Color.white.opacity(0.8))
				.overlay(content: {
					Text("서버로부터 최신 데이터를 다운로드 중 입니다.")
						.font(.system(size: 16, weight: .regular, design: .default))
				})

		}
	}

	struct ErrorLoadMessageView: View {
		var body: some View {

			RoundedRectangle(cornerRadius: 6)
				.frame(width: 300, height: 60)
				.foregroundColor(Color.white.opacity(0.8))
				.overlay(content: {
					Text("네트워크 상황이 불안정하거나 서버 문제로 데이터를 불러오지 못했습니다.")
						.font(.system(size: 16, weight: .regular, design: .default))
				})

		}
	}

	struct ErrorLoadImageView: View {
		var body: some View {
			RoundedRectangle(cornerRadius: 6)
				.frame(width: 100, height: 40)
				.foregroundColor(Color.yellow.opacity(0.2))
				.overlay(content: {
					Text("이미지 불러오기에 실패했습니다.")
						.font(.system(size: 12, weight: .regular, design: .default))
				})
		}
	}


	struct EmptyLoadImageView: View {
		var body: some View {
			Text("이미지 데이터가 존재하지 않습니다.")
				.font(.system(size: 12, weight: .regular, design: .default))
		}
	}

	struct DelayLoadMessageView: View {
		var body: some View {
			RoundedRectangle(cornerRadius: 6)
				.frame(width: 320, height: 50)
				.foregroundColor(Color.white.opacity(0.8))
				.overlay(content: {
					Text("검색어 없는 [전체 시/군/구] 검색 또는 검색된 결과가 다수 일 경우 지연될 수 있습니다.")
						.font(.system(size: 16, weight: .regular, design: .default))
				})

		}
	}
}



struct ErrorLoadView_Previews: PreviewProvider {

    static var previews: some View {

		Group {

			ErrorLoadView(
				isErrorLoad: .constant(false),
				errorCallerView: "\(IntroView.self)",
				isDescPage: .constant(false))

			ErrorLoadView(
				isErrorLoad: .constant(false),
				errorCallerView: "\(CampingSitesView.self)",
				isDescPage: .constant(false))

			ErrorLoadView.errorMsg
			ErrorLoadView.delayMsg
			ErrorLoadView.emptyLoadImage
			ErrorLoadView.errorLoadImage

		}
	}
}
