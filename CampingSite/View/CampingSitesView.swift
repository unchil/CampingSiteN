//
//  NewCampingSitesView.swift
//  CampingSite
//
//  Created by 여운칠 on 2022/10/25.
//

import SwiftUI

struct CampingSitesView: View {

	var param:ItemListParam
	
    @Environment(\.managedObjectContext) private var viewContext

	@State var isDescPage:Bool = false
	@State var isMapView:Bool = false
	@State var isErrorLoad = false
	@State var selection:TagName?

    var body: some View {

		let sheetTopView: some View = Image(systemName: "eject")
			.rotationEffect(.degrees(180))
			.padding(.vertical, 12)

		ZStack{

			switch self.selection {
				case .Near:
					NearCampingSitesView(
						param: self.param,
						isDescPage: $isDescPage,
						isMapView: $isMapView,
						isErrorLoad: self.$isErrorLoad)

				case .SeJong:
					SeJongCampingSitesView(
						param: self.param,
						isDescPage:$isDescPage,
						isMapView: $isMapView,
						isErrorLoad: self.$isErrorLoad)

				case .SiDo:
					SiDoCampingSitesView(
						param: self.param,
						isDescPage: $isDescPage,
						isMapView: $isMapView,
						isErrorLoad: self.$isErrorLoad)

				case .SiDoKeyword:
					SiDoKeywordCampingSitesView(
						param: self.param,
						isDescPage: $isDescPage,
						isMapView: $isMapView,
						isErrorLoad: self.$isErrorLoad)

				case .SiGunGu:
					SiggCampingSitesView(
						param: self.param,
						isDescPage: $isDescPage,
						isMapView: $isMapView,
						isErrorLoad: self.$isErrorLoad)

				case .none:
					Spacer()
			}

		}
		.onAppear{
			self.selectView()
		}
		.sheet(isPresented: $isMapView, content: {
			VStack(spacing:0){
				sheetTopView
				MapContainerView(
					isDescPage: self.$isDescPage,
					isMapView: self.$isMapView,
					isErrorLoad: self.$isErrorLoad )
			}
		})
		.sheet(isPresented: $isErrorLoad) {
			VStack(spacing:0){
				sheetTopView
				ErrorLoadView(
					isErrorLoad: self.$isErrorLoad,
					errorCallerView: "\(CampingSitesView.self)",
					isDescPage: self.$isDescPage)
			}
		}
		.sheet(isPresented: $isDescPage, content: {
			VStack(spacing:0){
				sheetTopView
				ItemInfoView()
				.padding([.horizontal,.bottom])
			}

		})

    }
}

extension CampingSitesView {
	enum TagName:String {
		case Near = "near"
		case SiGunGu = "sigungu"
		case SiDoKeyword = "sidokeyword"
		case SiDo = "sido"
		case SeJong = "sejong"
	}
}

extension CampingSitesView {

	private func selectView() {
		switch self.param.sidoName {
			case VWorldService.CURRENT.labelName:
				self.selection = TagName.Near
			case MergeSiDoName.세종특별자치시.rawValue:
				self.selection = TagName.SeJong
			default:
				do {
					if let siggNm = self.param.sigunguName {
						switch siggNm {
							case VWorldService.SIGGF.labelName: do {
								if let keyword = self.param.searchKeyword, keyword.isEmpty {
									self.selection = TagName.SiDo
								} else {
									self.selection = TagName.SiDoKeyword
								}
							}
							default:
								self.selection = TagName.SiGunGu
						}
					}
				}
		}
	}

}

struct NewCampingSitesView_Previews: PreviewProvider {
    static var previews: some View {
        CampingSitesView(param: ItemListParam(sidoName:"현위치"))
    }
}
