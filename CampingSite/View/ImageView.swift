//
//  ImageView.swift
//  campsite
//
//  Created by 여운칠 on 2022/09/27.
//


import SwiftUI

struct ImageView: View {

	var url:URL?
	var imgCallerView:String?

	let viewModel = ImageViewModel()

	@State var isError = false
	@State var isEmpty = false
	@State var isLoading = false
	@State var isComplete = false

	@State var content:Image?

	let emptyImage = "forest2"
	let errorImage = "errorImg"

	var body: some View {


		VStack {

			if self.isLoading {
				ZStack{
					EmptyView()
					ProgressView("Loading...")
					.font(.system(size: 12, weight: .bold, design: .default))
					.scaleEffect(1.5)
				}
			}

			if self.isComplete, let IMG = self.content {
				IMG.resizable().cornerRadius(6).scaledToFit()
			}

			if self.isError {

				if let callerView = self.imgCallerView , callerView.elementsEqual("ItemDetailView") {
					Image(self.emptyImage).resizable().cornerRadius(6).scaledToFit()
				} else {
					ZStack{
						Image(self.errorImage).resizable().cornerRadius(6).scaledToFit()
						ErrorLoadView.errorLoadImage
						.foregroundColor(.black)
					}
				}
			}

			if self.isEmpty {
				ZStack{
					Image(self.emptyImage).resizable().cornerRadius(6).scaledToFit()
					ErrorLoadView.emptyLoadImage
					.foregroundColor(.white)
				}
			}

		}

		.onAppear{
			self.isLoading = true
			if let url = self.url {
				self.loadImage(url: url)
			} else {
				self.isLoading = false
				self.isEmpty = true
			}
		}


	}
}


extension ImageView {

	func loadImage(url:URL) {

		self.viewModel.getImage(url: url) { result, error in

			if let _ = error {
				if let callerView = self.imgCallerView ,
					( callerView.elementsEqual("ItemDescView")
					|| callerView.elementsEqual("InfoWindowView") ) {
					withAnimation(.spring()) {
						self.isLoading = false
						self.isError = true
					}
				} else {
					self.isLoading = false
					self.isError = true
				}
			}

			if let result = result {

				self.content = Image(uiImage: (result as UIImage) )


				if let callerView = self.imgCallerView ,
					( callerView.elementsEqual("ItemDescView")
					|| callerView.elementsEqual("InfoWindowView") ) {
					withAnimation(.spring()) {
						self.isLoading = false
						self.isComplete = true
					}
				} else {
					self.isLoading = false
					self.isComplete = true
				}

			}
		}


	}
}

struct ImageView_Previews: PreviewProvider {

	static let url:URL = URL(string: "https://gocamping.or.kr/upload/camp/2963/thumb/thumb_720_3546MBYdxSjqEUebEYHSYZBj.jpg")!

    static var previews: some View {

		Group{
			Image("forest2")
			Image("errorImg")
		}
    }
}
