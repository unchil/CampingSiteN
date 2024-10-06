//
//  SiDoCampingSitesView.swift
//  CampingSite
//
//  Created by 여운칠 on 2022/10/25.
//

import SwiftUI

struct SiDoCampingSitesView: View {

	var param:ItemListParam

	@Binding var isDescPage:Bool
	@Binding var isMapView:Bool
	@Binding var isErrorLoad:Bool

	@Environment(\.managedObjectContext)
	private var viewContext


	@FetchRequest(
		sortDescriptors: [NSSortDescriptor(keyPath: \Entity_SiGunGu.sig_kor_nm , ascending: true)],
		animation: .default)
	private var resultSet_SiGunGu: FetchedResults<Entity_SiGunGu>


    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Entity_Camp_Site.doNm, ascending: true),
			NSSortDescriptor(keyPath: \Entity_Camp_Site.sigunguNm, ascending: true),
			NSSortDescriptor(keyPath: \Entity_Camp_Site.facltNm, ascending: true)])
    private var resultSet_CampSite: FetchedResults<Entity_Camp_Site>

    var body: some View {

        VStack{

			ScrollView(.horizontal) {

				HStack {

					ForEach(self.resultSet_SiGunGu,  id:\.self.id) { item in
					
						let newParam = ItemListParam( sidoName: self.param.sidoName, sigunguName: item.sig_kor_nm)
						if self.getRowCntSigg(param: newParam) == 0 {
							EmptyView()
						} else {
							SiggCampingSitesView(
								param: newParam,
								isDescPage: $isDescPage,
								isMapView: $isMapView,
								isErrorLoad: self.$isErrorLoad
							)
						}
					}


				}
			}
			.padding(.bottom, 10)
		
		}
		.onAppear{
			self.resultSet_SiGunGu.nsPredicate = NSPredicate(format: "sig_cd BEGINSWITH %@", self.param.sidoCode! )
		}

    }
}

extension SiDoCampingSitesView {


	private func getRowCntSigg(param:ItemListParam) -> Int  {

		if let siggNm = param.sigunguName {

			let shortName:String = Administrative_SD.list.first { item in
				item.rawValue == param.sidoName
			}?.shortName ?? ""

			if siggNm.contains(" ") {
				self.resultSet_CampSite.nsPredicate =
					NSPredicate(format: "doNm = %@ AND sigunguNm BEGINSWITH %@ AND addr1 CONTAINS %@", shortName, siggNm, siggNm)

				return self.resultSet_CampSite.count

			} else {

				self.resultSet_CampSite.nsPredicate =
					NSPredicate(format: "doNm = %@ AND sigunguNm BEGINSWITH %@", shortName, siggNm)

				return self.resultSet_CampSite.count
			}

		} else {
			return 0
		}
	}


}

struct SiDoCampingSitesView_Previews: PreviewProvider {
    static var previews: some View {
        SiDoCampingSitesView(
			param: ItemListParam(sidoName:"경기도"),
			isDescPage: .constant(false),
			isMapView: .constant(false),
			isErrorLoad: .constant(false)
		)
    }
}
