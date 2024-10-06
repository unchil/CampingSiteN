//
//  SiDoKeywordCampingSitesView.swift
//  CampingSite
//
//  Created by 여운칠 on 2022/10/25.
//

import SwiftUI

struct SiDoKeywordCampingSitesView: View {

	var param:ItemListParam

	@Binding var isDescPage:Bool
	@Binding var isMapView:Bool
	@Binding var isErrorLoad:Bool

	@Environment(\.managedObjectContext) private var viewContext

	@FetchRequest(
		sortDescriptors:[
			NSSortDescriptor(keyPath: \Entity_Camp_Site.doNm, ascending: true),
			NSSortDescriptor(keyPath: \Entity_Camp_Site.facltNm, ascending: true),
			NSSortDescriptor(keyPath: \Entity_Camp_Site.sigunguNm, ascending: true)])
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
			self.setCampSiteListSiDo()
		}
    }
}

extension SiDoKeywordCampingSitesView {

	private func setCampSiteListSiDo(){

		let shortName:String = Administrative_SD.list.first { item in
			item.rawValue == param.sidoName
		}?.shortName ?? ""

		if let keyword = self.param.searchKeyword, !keyword.isEmpty {
			self.resultSet_CampSite.nsPredicate = NSPredicate(format: "doNm = %@ AND facltNm CONTAINS %@", shortName, keyword )
		}else {
			self.resultSet_CampSite.nsPredicate = NSPredicate(format: "doNm = %@", shortName )
		}

		self.resultSet_CampSite.forEach { item in
			self.campingSiteList.append(item.toCampingSiteData())
		}

		self.labelText = "\(self.param.sidoName) : \(self.campingSiteList.count) 건"

		if self.campingSiteList.count == 0 {
			self.emptyBoxMsg = self.emptyBoxResultMsg
			self.emptyBoxImg = self.emptyBoxResultImg
		}
		self.isSearchLoading = false

	}

}

struct SiDoKeywordCampingSitesView_Previews: PreviewProvider {
    static var previews: some View {
        SiDoKeywordCampingSitesView(
			param: ItemListParam(sidoName:"경기도"),
			isDescPage: .constant(false),
			isMapView: .constant(false),
			isErrorLoad: .constant(false)
		)
    }
}
