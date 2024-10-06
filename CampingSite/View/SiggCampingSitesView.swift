//
//  SiggCampingSitesView.swift
//  CampingSite
//
//  Created by 여운칠 on 2022/10/25.
//

import SwiftUI

struct SiggCampingSitesView: View {

	var param:ItemListParam

	@Binding var isDescPage:Bool
	@Binding var isMapView:Bool
	@Binding var isErrorLoad:Bool

	@Environment(\.managedObjectContext)
	private var viewContext

	@FetchRequest( sortDescriptors: [])
	private var resultSet_CampSite: FetchedResults<Entity_Camp_Site>

	@State var campingSiteList:[CampingSiteData] = []

	@State var isSearchLoading:Bool = true
	@State var labelText:String = ""
	@State var labelImg:String = "signpost.right"
	@State var emptyBoxMsg:String = "Data Loading ..."
	@State var emptyBoxImg:String = "doc.text.magnifyingglass"

	let emptyBoxResultMsg = "No Data Found"
	let emptyBoxResultImg = "tray"

    var body: some View {

		VStack{
			if self.campingSiteList.isEmpty {
				EmtpyGroupBoxView(
					labelText:self.$labelText,
					labelImg: self.$labelImg,
					emptyBoxMsg: self.$emptyBoxMsg,
					emptyBoxImg: self.$emptyBoxImg
				)

			} else {
			
				ScrollGroupBoxView(
					campingSiteList:self.$campingSiteList,
					isDescPage: self.$isDescPage,
					isMapView: self.$isMapView,
					isErrorLoad: self.$isErrorLoad,
					labelText:self.$labelText,
					labelImg: self.$labelImg
				)
			}
		}
		.overlay {
			if self.isSearchLoading {
				ProgressView()
				.scaleEffect(2)
			}
		}
		.onAppear{
			self.setCampSiteListSigg()
		}

    }
}

extension SiggCampingSitesView {

	func setCampSiteListSigg() {

		let shortName:String = Administrative_SD.list.first { item in
			item.rawValue == param.sidoName
		}?.shortName ?? ""

		if let keyword = param.searchKeyword, keyword.count != 0 {

			self.resultSet_CampSite.nsSortDescriptors =
				[ NSSortDescriptor(keyPath: \Entity_Camp_Site.doNm, ascending: true),
					NSSortDescriptor(keyPath: \Entity_Camp_Site.facltNm, ascending: true),
					NSSortDescriptor(keyPath: \Entity_Camp_Site.sigunguNm, ascending: true)]

			if let sigunguNmae = param.sigunguName {
				if sigunguNmae.contains(" ") {
					self.resultSet_CampSite.nsPredicate =
						NSPredicate(format: "doNm = %@ AND facltNm CONTAINS %@ AND addr1 CONTAINS %@", shortName, keyword, sigunguNmae )
				} else {
					self.resultSet_CampSite.nsPredicate =
						NSPredicate(format: "doNm = %@ AND facltNm CONTAINS %@ AND sigunguNm BEGINSWITH %@", shortName, keyword, sigunguNmae )
				}
			}
		} else {

			self.resultSet_CampSite.nsSortDescriptors =
			 [ NSSortDescriptor(keyPath: \Entity_Camp_Site.doNm, ascending: true),
				NSSortDescriptor(keyPath: \Entity_Camp_Site.sigunguNm, ascending: true),
				NSSortDescriptor(keyPath: \Entity_Camp_Site.facltNm, ascending: true)]

			if let sigunguNmae = param.sigunguName {
				if sigunguNmae.contains(" ") {
					self.resultSet_CampSite.nsPredicate =
						NSPredicate(format: "doNm = %@ AND addr1 CONTAINS %@", shortName, sigunguNmae )
				} else {
					self.resultSet_CampSite.nsPredicate =
						NSPredicate(format: "doNm = %@ AND sigunguNm BEGINSWITH %@", shortName, sigunguNmae )
				}
			}
		}

		self.resultSet_CampSite.forEach { item in
			self.campingSiteList.append(item.toCampingSiteData())
		}

		self.labelText = "\(self.param.sidoName) \(self.param.sigunguName ?? "") : \(self.campingSiteList.count) 건"

		if self.campingSiteList.count == 0 {
			self.emptyBoxMsg = self.emptyBoxResultMsg
			self.emptyBoxImg = self.emptyBoxResultImg
		}
		self.isSearchLoading = false

	}

}


struct SiggCampingSitesView_Previews: PreviewProvider {
    static var previews: some View {
        SiggCampingSitesView(
			param: ItemListParam(
						sidoName:"경기도",
						sigunguName: "안양시 만안구"),
			isDescPage: .constant(false),
			isMapView: .constant(false),
			isErrorLoad: .constant(false))
    }
}
