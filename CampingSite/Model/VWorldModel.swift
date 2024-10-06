//
//  VWorldModel.swift
//  campsite
//
//  Created by 여운칠 on 2022/09/20.
//

import Foundation
import CoreData


enum MergeSiDoName:String {

	case 서울특별시 = "서울특별시"
	case 부산광역시 = "부산광역시"
	case 대구광역시 = "대구광역시"
	case 인천광역시 = "인천광역시"
	case 광주광역시 = "광주광역시"
	case 대전광역시 = "대전광역시"
	case 울산광역시 = "울산광역시"
	case 세종특별자치시 = "세종특별자치시"
	case 제주특별자치도 = "제주특별자치도"
	case 경기도 = "경기도"
	case 강원도 = "강원도"
	case 충청북도 = "충청북도"
	case 충청남도 = "충청남도"
	case 전라북도 = "전라북도"
	case 전라남도 = "전라남도"
	case 경상북도 = "경상북도"
	case 경상남도 = "경상남도"


	var shortName:String {
		switch self {

			case .서울특별시:
				return "서울시"
			case .부산광역시:
				return "부산시"
			case .대구광역시:
				return "대구시"
			case .인천광역시:
				return "인천시"
			case .광주광역시:
				return "광주시"
			case .대전광역시:
				return "대전시"
			case .울산광역시:
				return "울산시"
			case .세종특별자치시:
				return "세종시"
			case .제주특별자치도:
				return "제주도"
			case .경기도:
				return "경기도"
			case .강원도:
				return "강원도"
			case .충청북도:
				return "충청북도"
			case .충청남도:
				return "충청남도"
			case .전라북도:
				return "전라북도"
			case .전라남도:
				return "전라남도"
			case .경상북도:
				return "경상북도"
			case .경상남도:
				return "경상남도"
		}
	}

	var ctprvn_cd:String {
		switch self {

			case .서울특별시:
				return "11"
			case .부산광역시:
				return "26"
			case .대구광역시:
				return "27"
			case .인천광역시:
				return "28"
			case .광주광역시:
				return "29"
			case .대전광역시:
				return "30"
			case .울산광역시:
				return "31"
			case .세종특별자치시:
				return "36"
			case .제주특별자치도:
				return "50"
			case .경기도:
				return "41"
			case .강원도:
				return "42"
			case .충청북도:
				return "43"
			case .충청남도:
				return "44"
			case .전라북도:
				return "45"
			case .전라남도:
				return "46"
			case .경상북도:
				return "47"
			case .경상남도:
				return "48"
		}
	}



}

enum VWorldService:String {
	case CURRENT = "CURRENT_LOCATION_INFO"  //현위치
	case SIDO = "LT_C_ADSIDO_INFO"  //광역시도
	case SIGGF = "LT_C_ADSIGG_INFO_F"  //시군구 전체
	case SIGG = "LT_C_ADSIGG_INFO"  //시군구
	/*
	case EMD  = "LT_C_ADEMD_INFO"  //읍면동
	case RI = "LT_C_ADRI_INFO"  //리
	*/

	var filterCodeName:String {
		switch self {
			case .CURRENT : return ""
			case .SIDO : return ""
			case .SIGGF : return ""
			case .SIGG : return "sig_cd"
			/*
			case .EMD : return "emd_cd"
			case .RI : return "li_cd"
			*/
		}
	}

	var labelName:String {
		switch self {
			case .CURRENT : return "현위치"
			case .SIDO : return "광역시/도"
			case .SIGGF : return "전체 시/군/구"
			case .SIGG : return "시/군/구"
			/*
			case .EMD : return "읍면동"
			case .RI : return "리"
			*/
		}
	}

}

enum VWorldResponseStatus:String {
	case OK = "OK"
	case NOT_FOUND = "NOT_FOUND"
	case ERROR = "ERROR"

	var statusText:String {
		switch self {
			case .OK : return "성공"
			case .NOT_FOUND : return "결과없음"
			case .ERROR: return "에러"
		}
	}
}

// Parameters ( *: required)
struct VWorldDefaultParam {
	var request:String // (*) 요청 서비스 오퍼레이션	(getfeature)
	var key:String // (*) 발급받은 api key
	var data:String // (*)  조회할 서비스ID (광역시도:LT_C_ADSIDO_INFO, 시군구:LT_C_ADSIGG_INFO, 읍면동:LT_C_ADEMD_INFO, 리:LT_C_ADRI_INFO )
	var geomFilter:String // (*) 지오메트리 필터  BOX(13663271.680031825,3894007.9689600193,14817776.555251127,4688953.0631258525)
	var size:Int // 한 페이지에 출력될 응답결과 건수 max(1000)
	var geometry:Bool // 지오메트리 반환 여부  (false)
	var crs:String // 응답결과 좌표계  (Google Mercator:	EPSG:3857, EPSG:900913)
}


extension VWorldDefaultParam {

	static var responseStatus:[VWorldResponseStatus] = [
		VWorldResponseStatus.OK,
		VWorldResponseStatus.NOT_FOUND,
		VWorldResponseStatus.ERROR
	]
}

struct Administrative_SD: Hashable, Codable, Identifiable{
	var id:UUID = UUID()
	var ctprvn_cd:String?
	var ctp_kor_nm:String?
	var ctp_eng_nm:String?
}

struct Administrative_SGG: Hashable, Codable, Identifiable{
	var id:UUID = UUID()
	var full_nm:String?
	var sig_cd:String?
	var sig_kor_nm:String?
	var sig_eng_nm:String?
}

struct Administrative_EMD: Hashable, Codable, Identifiable{
	var id:UUID = UUID()
	var full_nm:String?
	var emd_cd:String?
	var emd_kor_nm:String?
	var emd_eng_nm:String?
}

struct Administrative_L: Hashable, Codable, Identifiable{
	var id:UUID = UUID()
	var full_nm:String?
	var li_cd:String?
	var li_kor_nm:String?
	var li_eng_nm:String?
}

struct VWorldRecvData : Hashable, Codable{

	var service:Service
	var status:String // 문자	처리 결과의 상태 표시, 유효값 : OK(성공), NOT_FOUND(결과없음), ERROR(에러)
	var record:Record
	var page:Page
	var result:Result?
	var error:Error?

	struct Service: Hashable, Codable {
		var name:String
		var version:String
		var operation:String
		var time:String
	}

	struct Record: Hashable, Codable {
		var total:String
		var current:String
	}

	struct Page: Hashable, Codable {
		var total:String
		var current:String
		var size:String
	}

	struct Properties: Hashable, Codable{

		var ctprvn_cd:String?
		var ctp_kor_nm:String?
		var ctp_eng_nm:String?

		var full_nm:String?

		var sig_cd:String?
		var sig_kor_nm:String?
		var sig_eng_nm:String?

		var emd_cd:String?
		var emd_kor_nm:String?
		var emd_eng_nm:String?

		var li_cd:String?
		var li_kor_nm:String?
		var li_eng_nm:String?

	}

	struct Feature: Hashable, Codable {
		var type:String
		var properties:Properties
		var id:String
	}

	struct FeatureCollection: Hashable, Codable {
		var type:String
		var bbox:[Float]
		var features:[Feature]
	}

	struct Result: Hashable, Codable {
		var featureCollection:FeatureCollection
	}

	struct Error: Hashable, Codable {
		var level:String
		var code:String
		var text:String
	}
}

struct VWorldResponse: Hashable, Codable {
	var response:VWorldRecvData?
}

extension VWorldRecvData {
	static func makeDefaultValue() -> VWorldRecvData {
		return  VWorldRecvData(
					service: Service(name: "", version: "", operation: "", time: ""),
					status: "",
					record: Record(total: "0", current: "0"),
					page: Page(total: "0", current: "0", size: "0")
				)
	}
}

extension Administrative_SD {
	func toEntity_SiDo(context: NSManagedObjectContext){
		let newItem = Entity_SiDo(context: context)
		newItem.ctprvn_cd = self.ctprvn_cd
		newItem.ctp_kor_nm = self.ctp_kor_nm
		newItem.ctp_eng_nm = self.ctp_eng_nm

		commitTrans(context: context)
	}

	static let list:[MergeSiDoName] =
		 [MergeSiDoName.서울특별시, MergeSiDoName.부산광역시, MergeSiDoName.대구광역시,
			MergeSiDoName.인천광역시, MergeSiDoName.광주광역시, MergeSiDoName.대전광역시,
			MergeSiDoName.울산광역시, MergeSiDoName.세종특별자치시, MergeSiDoName.제주특별자치도,
			MergeSiDoName.경기도, MergeSiDoName.강원도, MergeSiDoName.충청북도, MergeSiDoName.충청남도,
			MergeSiDoName.전라북도, MergeSiDoName.전라남도, MergeSiDoName.경상북도, MergeSiDoName.경상남도]



}

extension Administrative_SGG {
	func toEntity_SiGunGu(context: NSManagedObjectContext){
		let newItem = Entity_SiGunGu(context: context)
		newItem.full_nm = self.full_nm
		newItem.sig_cd = self.sig_cd
		newItem.sig_kor_nm = self.sig_kor_nm
		newItem.sig_eng_nm = self.sig_eng_nm

		commitTrans(context: context)
	}
}

extension Entity_SiDo {
	func toAdministrative_SD() -> Administrative_SD {
		return Administrative_SD(
			id:UUID(),
			ctprvn_cd: self.ctprvn_cd,
			ctp_kor_nm: self.ctp_kor_nm,
			ctp_eng_nm: self.ctp_eng_nm )
	}

}

extension Entity_SiGunGu {
	func toAdministrative_SGG() -> Administrative_SGG {
		return Administrative_SGG(
			id:UUID(),
			full_nm: self.full_nm,
			sig_cd: self.sig_cd,
			sig_kor_nm: self.sig_kor_nm,
			sig_eng_nm: self.sig_eng_nm )
	}
}
