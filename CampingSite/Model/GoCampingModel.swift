//
//  GoCampingModel.swift
//  campsite
//
//  Created by 여운칠 on 2022/09/20.
//
import Foundation
import CoreData

enum CheckService:String {
	case Administrative = "Administrative"
	case CampSite = "CampSite"
	case NearCampSite = "NearCampSite"
	case Weather = "Weather"

	var returnFuncName:String {
		switch self {
			case .Administrative:
				return "getVWorldData(context:service:code:)"
			case .CampSite:
				return "getCampSiteList(context:service:urlRequest:)CampSite"
			case .NearCampSite:
				return "getCampSiteList(context:service:urlRequest:)NearCampSite"
			case .Weather:
				return "getCurrentWeather(context:)"
		}
	}

}

enum PreviewContextMenu:Int {
	case HOME_PAGE = 2
	case RESERVATION_PAGE = 3
	case IMAGE = 1
	case DESC = 0

	var title:String {
		switch self {

			case .HOME_PAGE:
				return "홈페이지"
			case .RESERVATION_PAGE:
				return "온라인 예약"
			case .IMAGE:
				return "사진"
			case .DESC:
				return "소개"
		}
	}

	var systemImage:String {
		switch self {
			case .HOME_PAGE:
				return "house"
			case .RESERVATION_PAGE:
				return "heart.text.square"
			case .IMAGE:
				return "photo.on.rectangle"
			case .DESC:
				return "text.justify.leading"
		}
	}
}

struct ItemListParam {
	var sidoName:String
	var sigunguName:String?
	var searchKeyword:String?
	var sidoCode:String?
}

enum GoCampingResponseStatus:String {

	case INVALID_REQUEST_PARAMETER_ERROR = "10"
	case NO_MANDATORY_REQUEST_PARAMETERS_ERROR = "11"
	case TEMPORARILY_DISABLE_THE_SERVICEKEY_ERROR = "21"
	case UNSIGNED_CALL_ERROR = "33"
	case SUCCESS = "200"
	case NORMAL_CODE = "00"
	case DB_ERROR = "02"
	case NODATA_ERROR = "03"
	case SERVICETIMEOUT_ERROR = "05"

	case OK = "0000"


	var message: String {
		switch self {
		case .INVALID_REQUEST_PARAMETER_ERROR :   return "잘못된 요청 파라메터 에러"
		case .NO_MANDATORY_REQUEST_PARAMETERS_ERROR: return "필수 요청 파라메터가 없음"
		case .TEMPORARILY_DISABLE_THE_SERVICEKEY_ERROR: return "일시적으로 사용할수 없는 서비스키"
		case .UNSIGNED_CALL_ERROR :   return "서명되지않은 호출"
		case .SUCCESS: return "성공"
		case .NORMAL_CODE: return "정상"
		case .DB_ERROR :   return "데이터베이스 에러"
		case .NODATA_ERROR: return "데이터 없음 에러"
		case .SERVICETIMEOUT_ERROR: return "서비스 연결 실패 에러"

		case .OK: return "요청 서비스 정상 리턴"
		}
	}
}

enum GoCampingSyncStatus:String {
	case UPDATE = "U"
	case INSERT = "A"
	case DELETE = "D"
	case UNKNOWN = "N"

	var name:String {
		switch self {
			case .UPDATE: return "수정"
			case .INSERT: return "신규"
			case .DELETE: return "삭제"
			case .UNKNOWN: return "오류"
		}
	}
}

enum GoCampingService:String {
	case DEFAULT = "/basedList"
	case LOCATION = "/locationBasedList"
	case SEARCH = "/searchList"
	case IMAGE = "/imageList"
	case SYNC  = "/basedSyncList"
}
enum GoCampingServiceNew:String {
	case DEFAULT = "/basedList?"
	case LOCATION = "/locationBasedList?"
	case SEARCH = "/searchList?"
	case IMAGE = "/imageList?"
	case SYNC  = "/basedSyncList?"
}

// Parameters ( *: required)
struct GoCampingDefaultParam {
	var numOfRows:Int // 한페이지결과수
	var pageNo:Int // 페이지번호
	var MobileOS:String // (*) OS 구분 : IOS (아이폰), AND (안드로이드), WIN (윈도우폰), ETC(기타)
	var MobileApp:String // (*) 서비스명(어플명)
	var serviceKey:String // (*) 인증키(서비스키)
	var _type:String // 응답메세지 형식 : REST방식의 URL호출시 json깂추가(디폴트 응답메세시 형식은XML)
}

extension GoCampingDefaultParam {

	static var syncStatus:[GoCampingSyncStatus] = [
		GoCampingSyncStatus.UPDATE,
		GoCampingSyncStatus.DELETE,
		GoCampingSyncStatus.INSERT
	]

}

struct GoCampingRecvHeader : Hashable, Codable{
	var resultCode:String // API 호출 결과의 상태 코드
	var resultMsg:String // API 호출 결과의 상태
}

extension GoCampingRecvHeader {
	static var responseStatus:[GoCampingResponseStatus] = [
		GoCampingResponseStatus.OK,
		GoCampingResponseStatus.SUCCESS,
		GoCampingResponseStatus.NORMAL_CODE,
		GoCampingResponseStatus.DB_ERROR,
		GoCampingResponseStatus.INVALID_REQUEST_PARAMETER_ERROR,
		GoCampingResponseStatus.NODATA_ERROR,
		GoCampingResponseStatus.NO_MANDATORY_REQUEST_PARAMETERS_ERROR,
		GoCampingResponseStatus.SERVICETIMEOUT_ERROR,
		GoCampingResponseStatus.TEMPORARILY_DISABLE_THE_SERVICEKEY_ERROR,
		GoCampingResponseStatus.UNSIGNED_CALL_ERROR
	]

}

struct CampingSiteData: Identifiable, Equatable {

    static func == (lhs: CampingSiteData, rhs: CampingSiteData) -> Bool {
        lhs.id == rhs.id
    }

	var id: UUID = UUID()

	var contentId:String //콘텐츠 ID
	var facltNm:String //야영장명
	var lineIntro:String //한줄소개
	var intro:String //소개
	var lctCl:String //입지구분
	var animalCmgCl:String //애완동물출입
	var glampInnerFclty:String //글램핑 - 내부시설
	var sbrsCl:String //부대시설
	var eqpmnLendCl:String //캠핑장비대여
	var resveCl:String //예약 구분
	var resveUrl:String //예약 페이지
	var tel:String //전화
	var facltDivNm:String //사업주체.구분
	var induty:String //업종
	var doNm:String //도
	var sigunguNm:String //시군구
	var addr1:String //주소
	var firstImageUrl:String //대표이미지
	var homepage:String //홈페이지
	var latitude:Double  // 위도
	var longitude:Double // 경도

	var isImageListLoaded:Bool?
}



struct GoCampingRecvItem: Hashable, Codable {
	var addr1:String //주소
	var addr2:String //주소상세
	var allar:String //전체면적
	var animalCmgCl:String //애완동물출입
	var autoSiteCo:String //주요시설 자동차야영장
	var bizrno:String //사업자번호
	var brazierCl:String //화로대
	var caravAcmpnyAt:String //개인 카라반 동반 여부(Y:사용, N:미사용)
	var caravInnerFclty:String //카라반 - 내부시설
	var caravSiteCo:String //주요시설 카라반
	var clturEvent:String //자체문화행사명
	var clturEventAt:String //자체문화행사 여부(Y:사용, N:미사용)
	var contentId:String //콘텐츠 ID
	var createdtime:String //등록일
	var direction:String //오시는 길 컨텐츠
	var doNm:String //도
	var eqpmnLendCl:String //캠핑장비대여
	var exprnProgrm:String //체험프로그램명
	var exprnProgrmAt:String //체험프로그램 여부(Y:사용, N:미사용)
	var extshrCo:String //소화기 개수
	var facltDivNm:String //사업주체.구분
	var facltNm:String //야영장명
	var featureNm:String //특징
	var fireSensorCo:String //화재감지기 개수
	var firstImageUrl:String //대표이미지
	var frprvtSandCo:String //방화사 개수
	var frprvtWrppCo:String //방화수 개수
	var glampInnerFclty:String //글램핑 - 내부시설
	var glampSiteCo:String //주요시설 글램핑
	var gnrlSiteCo:String //주요시설 일반야영장
	var homepage:String //홈페이지
	var hvofBgnde:String //휴장기간.휴무기간 시작일
	var hvofEnddle:String //휴장기간.휴무기간 종료일
	var induty:String //업종
	var indvdlCaravSiteCo:String //주요시설 개인 카라반
	var insrncAt:String //영업배상책임보험 가입여부(Y:사용, N:미사용)
	var intro:String //소개
	var lctCl:String //입지구분
	var lineIntro:String //한줄소개
	var manageNmpr:String //상주관리인원
	var manageSttus:String //운영상태.관리상태
	var mangeDivNm:String //운영주체.관리주체 (직영, 위탁)
	var mapX:String //경도(X)
	var mapY:String //위도(Y)
	var mgcDiv:String //운영기관.관리기관
	var modifiedtime:String //수정일
	var operDeCl:String //운영일
	var operPdCl:String //운영기간
	var posblFcltyCl:String //주변이용가능시설
	var posblFcltyEtc:String //주변이용가능시설 기타
	var prmisnDe:String //인허가일자
	var resveCl:String //예약 구분
	var resveUrl:String //예약 페이지
	var sbrsCl:String //부대시설
	var sbrsEtc:String //부대시설 기타
	var sigunguNm:String //시군구
	var siteBottomCl1:String //잔디
	var siteBottomCl2:String //파쇄석
	var siteBottomCl3:String //테크
	var siteBottomCl4:String //자갈
	var siteBottomCl5:String //맨흙
	var sitedStnc:String //사이트간 거리
	var siteMg1Co:String //사이트 크기1 수량
	var siteMg1Vrticl:String //사이트 크기1 세로
	var siteMg1Width:String //사이트 크기1 가로
	var siteMg2Co:String //사이트 크기2 수량
	var siteMg2Vrticl:String //사이트 크기2 세로
	var siteMg2Width:String //사이트 크기2 가로
	var siteMg3Co:String //사이트 크기3 수량
	var siteMg3Vrticl:String //사이트 크기3 세로
	var siteMg3Width:String //사이트 크기3 가로
	var swrmCo:String //샤워실 개수
	var tel:String //전화
	var themaEnvrnCl:String //테마환경
	var toiletCo:String //화장실 개수
	var tooltip:String //툴팁
	var tourEraCl:String //여행시기
	var trlerAcmpnyAt:String //개인 트레일러 동반 여부(Y:사용, N:미사용)
	var trsagntNo:String //관광사업자번호
	var wtrplCo:String //개수대 개수
	var zipcode:String //우편번호

	var syncStatus:String? //콘덴츠 상태
}

struct GoCampingRecvItemImage: Hashable, Codable {
	var contentId:String // 콘텐츠 ID
	var createdtime:String //등록일
	var imageUrl:String //이미지 URL
	var modifiedtime:String // 수정일
	var serialnum:String //이미지 일련번호
}

struct GoCampingRecvBody: Hashable, Codable {
	var items:GoCampingRecvItems
	var numOfRows:Int // 한 페이지의 결과 수
	var pageNo:Int // 현재 조회된 데이터의 페이지 번호
	var totalCount:Int // 전체 데이터의 총 수
}

struct GoCampingRecvItems: Hashable, Codable {
	var item:[GoCampingRecvItem]
}

struct GoCampingRecvBodyImage: Hashable, Codable{
	var items:GoCampingRecvItemsImage?
	var numOfRows:Int // 한 페이지의 결과 수
	var pageNo:Int // 현재 조회된 데이터의 페이지 번호
	var totalCount:Int // 전체 데이터의 총 수
}

struct GoCampingRecvBodyImageEmpty: Hashable, Codable{
	var items:String
	var numOfRows:Int // 한 페이지의 결과 수
	var pageNo:Int // 현재 조회된 데이터의 페이지 번호
	var totalCount:Int // 전체 데이터의 총 수
}

struct GoCampingRecvItemsImage: Hashable, Codable {
	var item:[GoCampingRecvItemImage]
}

struct GoCampingRecvData: Hashable, Codable {
	var header:GoCampingRecvHeader
	var body:GoCampingRecvBody
}

struct GoCampingRecvDataImage: Hashable, Codable {
	var header:GoCampingRecvHeader
	var body:GoCampingRecvBodyImage
}

struct GoCampingRecvDataImageEmpty: Hashable, Codable {
	var header:GoCampingRecvHeader
	var body:GoCampingRecvBodyImageEmpty
}

struct GoCampingResponse : Hashable, Codable{
	var response:GoCampingRecvData?
}

struct GoCampingResponseImage: Hashable, Codable {
	var response:GoCampingRecvDataImage?
}

struct GoCampingResponseImageEmpty: Hashable, Codable {
	var response:GoCampingRecvDataImageEmpty
}

extension GoCampingRecvBodyImageEmpty {
	func toGoCampingRecvBodyImage() -> GoCampingRecvBodyImage {
		return GoCampingRecvBodyImage(numOfRows: self.numOfRows, pageNo: self.pageNo, totalCount: self.totalCount)
	}
}

extension GoCampingResponseImageEmpty {
	func tGoCampingResponseImage() -> GoCampingResponseImage {
		return GoCampingResponseImage(response: GoCampingRecvDataImage(header: self.response.header, body: self.response.body.toGoCampingRecvBodyImage()))
	}
}

extension CampingSiteData {
	static func makeDefaultValue() -> CampingSiteData {
		return CampingSiteData(contentId: "2963", facltNm: "초막골생태공원 느티나무야영장 ", lineIntro: "일반캠핑과 글램핑이 함께하는 공간", intro: "초막골생태공원 느티나무 야영장은 경기도 군포시에 자리 잡고 있다. 군포시청을 기점으로 오금초등학교를 지나 도장터널과 능내터널 거치면 닿는다. 도착까지 걸리는 시간은 약 10분이다. 이곳은 일반캠핑과 글램핑이 함께하는 공간이다. 일반캠핑은 47면을 마련했으며, 전기와 화로 사용이 가능하다. 단, 화로 사용 시 장작은 이용할 수 없으며, 숯만 허용한다. 이는 글램핑도 마찬가지다. 글램핑은 고급형 11면, 일반형 5면을 갖췄다. 고급형은 내부에 침대, 냉난방기, 개수대, 냉장고, TV, 취사도구, 식기류, 화장실, 샤워실 등을 비치했다. 일반형은 냉난방기, 화장실, 샤워실, 개수대를 구비하지 않았다. 매점을 운영하지 않으므로 자동차로 10여 분 거리에 있는 마트를 이용해야 한다.",
								lctCl: "숲,도심", animalCmgCl: "불가능", glampInnerFclty: "침대,TV,에어컨,냉장고,난방기구,취사도구,내부화장실", sbrsCl: "부대시설",
								eqpmnLendCl: "대여장비", resveCl: "온라인실시간예약", resveUrl: "http://www.gunpo.go.kr/cms/content/view/2325.do",
								tel: "031-390-7666", facltDivNm: "지자체", induty: "자동차야영장,글램핑", doNm: "경기도", sigunguNm: "군포시",
								addr1: "경기도 군포시 산본동  919 ", firstImageUrl: "https://gocamping.or.kr/upload/camp/2963/thumb/thumb_720_3546MBYdxSjqEUebEYHSYZBj.jpg",
							   homepage: "http://www.gunpo.go.kr/cms/content/view/2325.do", latitude: 37.386092, longitude: 126.934793)
	}
}

extension GoCampingRecvItem {

	static func makeDefaultValue() -> GoCampingRecvItem {
		return GoCampingRecvItem(
				addr1: "", addr2: "", allar: "", animalCmgCl: "", autoSiteCo: "",
				bizrno: "", brazierCl: "", caravAcmpnyAt: "", caravInnerFclty: "",
				caravSiteCo: "", clturEvent: "", clturEventAt: "", contentId: "",
				createdtime: "", direction: "", doNm: "", eqpmnLendCl: "", exprnProgrm: "",
				exprnProgrmAt: "", extshrCo: "", facltDivNm: "", facltNm: "", featureNm: "",
				fireSensorCo: "", firstImageUrl: "", frprvtSandCo: "", frprvtWrppCo: "",
				glampInnerFclty: "", glampSiteCo: "", gnrlSiteCo: "", homepage: "",
				hvofBgnde: "", hvofEnddle: "", induty: "", indvdlCaravSiteCo: "", insrncAt: "",
				intro: "", lctCl: "", lineIntro: "", manageNmpr: "", manageSttus: "", mangeDivNm: "",
				mapX: "", mapY: "", mgcDiv: "", modifiedtime: "", operDeCl: "", operPdCl: "",
				posblFcltyCl: "", posblFcltyEtc: "", prmisnDe: "", resveCl: "", resveUrl: "", sbrsCl: "",
				sbrsEtc: "", sigunguNm: "", siteBottomCl1: "", siteBottomCl2: "", siteBottomCl3: "",
				siteBottomCl4: "", siteBottomCl5: "", sitedStnc: "", siteMg1Co: "", siteMg1Vrticl: "",
				siteMg1Width: "", siteMg2Co: "", siteMg2Vrticl: "", siteMg2Width: "", siteMg3Co: "",
				siteMg3Vrticl: "", siteMg3Width: "", swrmCo: "", tel: "", themaEnvrnCl: "", toiletCo: "",
				tooltip: "", tourEraCl: "", trlerAcmpnyAt: "", trsagntNo: "", wtrplCo: "", zipcode: "")
	}

	func toEntity_Camp_Site(context: NSManagedObjectContext) {
		let newItem = Entity_Camp_Site(context: context)
		newItem.addr1 = self.addr1
		newItem.addr2 = self.addr2
		newItem.allar = String(self.allar)
		newItem.animalCmgCl = self.animalCmgCl
		newItem.autoSiteCo = String(self.autoSiteCo)
		newItem.bizrno = self.bizrno
		newItem.brazierCl = self.brazierCl
		newItem.caravAcmpnyAt = String(self.caravAcmpnyAt)
		newItem.caravInnerFclty = self.caravInnerFclty
		newItem.caravSiteCo = self.caravSiteCo
		newItem.clturEvent = self.clturEvent
		newItem.clturEventAt = self.clturEventAt
		newItem.contentId = String(self.contentId)
		newItem.createdtime = self.createdtime
		newItem.direction = self.direction
		newItem.doNm = self.doNm
		newItem.eqpmnLendCl = self.eqpmnLendCl
		newItem.exprnProgrm = self.exprnProgrm
		newItem.exprnProgrmAt = String(self.exprnProgrmAt)
		newItem.extshrCo = String(self.extshrCo)
		newItem.facltDivNm = self.facltDivNm
		newItem.facltNm = self.facltNm
		newItem.featureNm = self.featureNm
		newItem.fireSensorCo = String(self.fireSensorCo)
		newItem.firstImageUrl = self.firstImageUrl
		newItem.frprvtSandCo = String(self.frprvtSandCo)
		newItem.frprvtWrppCo = String(self.frprvtWrppCo)
		newItem.glampInnerFclty = self.glampInnerFclty
		newItem.glampSiteCo = String(self.gnrlSiteCo)
		newItem.gnrlSiteCo = String(self.gnrlSiteCo)
		newItem.homepage = self.homepage
		newItem.hvofBgnde = self.hvofBgnde
		newItem.hvofEnddle = self.hvofEnddle
		newItem.induty = self.induty
		newItem.indvdlCaravSiteCo = String(self.indvdlCaravSiteCo)
		newItem.insrncAt = String(self.insrncAt)
		newItem.intro = self.intro
		newItem.lctCl = self.lctCl
		newItem.lineIntro = self.lineIntro
		newItem.manageNmpr = String(self.manageNmpr)
		newItem.manageSttus = self.manageSttus
		newItem.mangeDivNm = self.mangeDivNm
		newItem.mapX = self.mapX
		newItem.mapY = self.mapY
		newItem.mgcDiv = self.mgcDiv
		newItem.modifiedtime = self.modifiedtime
		newItem.operDeCl = self.operDeCl
		newItem.operPdCl = self.operPdCl
		newItem.posblFcltyCl = self.posblFcltyCl
		newItem.posblFcltyEtc = self.posblFcltyEtc
		newItem.prmisnDe = self.prmisnDe
		newItem.resveCl = self.resveCl
		newItem.resveUrl = self.resveUrl
		newItem.sbrsCl = self.sbrsCl
		newItem.sbrsEtc = self.sbrsEtc
		newItem.sigunguNm = self.sigunguNm
		newItem.siteBottomCl1 = String(self.siteBottomCl1)
		newItem.siteBottomCl2 = String(self.siteBottomCl2)
		newItem.siteBottomCl3 = String(self.siteBottomCl3)
		newItem.siteBottomCl4 = String(self.siteBottomCl4)
		newItem.siteBottomCl5 = String(self.siteBottomCl5)
		newItem.sitedStnc = String(self.sitedStnc)
		newItem.siteMg1Co = String(self.siteMg1Co)
		newItem.siteMg1Vrticl = String(self.siteMg1Vrticl)
		newItem.siteMg1Width = String(self.siteMg1Width)
		newItem.siteMg2Co = String(self.siteMg2Co)
		newItem.siteMg2Vrticl = String(self.siteMg2Vrticl)
		newItem.siteMg2Width = String(self.siteMg2Width)
		newItem.siteMg3Co = String(self.siteMg3Co)
		newItem.siteMg3Vrticl = String(self.siteMg3Vrticl)
		newItem.siteMg3Width = String(self.siteMg3Width)
		newItem.swrmCo = String(self.swrmCo)
		newItem.tel = self.tel
		newItem.themaEnvrnCl = self.themaEnvrnCl
		newItem.toiletCo = String(self.toiletCo)
		newItem.tooltip = self.tooltip
		newItem.tourEraCl = self.tourEraCl
		newItem.trlerAcmpnyAt = self.trlerAcmpnyAt
		newItem.trsagntNo = self.trsagntNo
		newItem.wtrplCo = String(self.wtrplCo)
		newItem.zipcode = String(self.zipcode)

		commitTrans(context: context)
	}

	func toEntity_Camp_Site_Near(context: NSManagedObjectContext) {
		let newItem = Entity_Camp_Site_Near(context: context)
		newItem.addr1 = self.addr1
		newItem.addr2 = self.addr2
		newItem.allar = String(self.allar)
		newItem.animalCmgCl = self.animalCmgCl
		newItem.autoSiteCo = String(self.autoSiteCo)
		newItem.bizrno = self.bizrno
		newItem.brazierCl = self.brazierCl
		newItem.caravAcmpnyAt = String(self.caravAcmpnyAt)
		newItem.caravInnerFclty = self.caravInnerFclty
		newItem.caravSiteCo = self.caravSiteCo
		newItem.clturEvent = self.clturEvent
		newItem.clturEventAt = self.clturEventAt
		newItem.contentId = String(self.contentId)
		newItem.createdtime = self.createdtime
		newItem.direction = self.direction
		newItem.doNm = self.doNm
		newItem.eqpmnLendCl = self.eqpmnLendCl
		newItem.exprnProgrm = self.exprnProgrm
		newItem.exprnProgrmAt = String(self.exprnProgrmAt)
		newItem.extshrCo = String(self.extshrCo)
		newItem.facltDivNm = self.facltDivNm
		newItem.facltNm = self.facltNm
		newItem.featureNm = self.featureNm
		newItem.fireSensorCo = String(self.fireSensorCo)
		newItem.firstImageUrl = self.firstImageUrl
		newItem.frprvtSandCo = String(self.frprvtSandCo)
		newItem.frprvtWrppCo = String(self.frprvtWrppCo)
		newItem.glampInnerFclty = self.glampInnerFclty
		newItem.glampSiteCo = String(self.gnrlSiteCo)
		newItem.gnrlSiteCo = String(self.gnrlSiteCo)
		newItem.homepage = self.homepage
		newItem.hvofBgnde = self.hvofBgnde
		newItem.hvofEnddle = self.hvofEnddle
		newItem.induty = self.induty
		newItem.indvdlCaravSiteCo = String(self.indvdlCaravSiteCo)
		newItem.insrncAt = String(self.insrncAt)
		newItem.intro = self.intro
		newItem.lctCl = self.lctCl
		newItem.lineIntro = self.lineIntro
		newItem.manageNmpr = String(self.manageNmpr)
		newItem.manageSttus = self.manageSttus
		newItem.mangeDivNm = self.mangeDivNm
		newItem.mapX = self.mapX
		newItem.mapY = self.mapY
		newItem.mgcDiv = self.mgcDiv
		newItem.modifiedtime = self.modifiedtime
		newItem.operDeCl = self.operDeCl
		newItem.operPdCl = self.operPdCl
		newItem.posblFcltyCl = self.posblFcltyCl
		newItem.posblFcltyEtc = self.posblFcltyEtc
		newItem.prmisnDe = self.prmisnDe
		newItem.resveCl = self.resveCl
		newItem.resveUrl = self.resveUrl
		newItem.sbrsCl = self.sbrsCl
		newItem.sbrsEtc = self.sbrsEtc
		newItem.sigunguNm = self.sigunguNm
		newItem.siteBottomCl1 = String(self.siteBottomCl1)
		newItem.siteBottomCl2 = String(self.siteBottomCl2)
		newItem.siteBottomCl3 = String(self.siteBottomCl3)
		newItem.siteBottomCl4 = String(self.siteBottomCl4)
		newItem.siteBottomCl5 = String(self.siteBottomCl5)
		newItem.sitedStnc = String(self.sitedStnc)
		newItem.siteMg1Co = String(self.siteMg1Co)
		newItem.siteMg1Vrticl = String(self.siteMg1Vrticl)
		newItem.siteMg1Width = String(self.siteMg1Width)
		newItem.siteMg2Co = String(self.siteMg2Co)
		newItem.siteMg2Vrticl = String(self.siteMg2Vrticl)
		newItem.siteMg2Width = String(self.siteMg2Width)
		newItem.siteMg3Co = String(self.siteMg3Co)
		newItem.siteMg3Vrticl = String(self.siteMg3Vrticl)
		newItem.siteMg3Width = String(self.siteMg3Width)
		newItem.swrmCo = String(self.swrmCo)
		newItem.tel = self.tel
		newItem.themaEnvrnCl = self.themaEnvrnCl
		newItem.toiletCo = String(self.toiletCo)
		newItem.tooltip = self.tooltip
		newItem.tourEraCl = self.tourEraCl
		newItem.trlerAcmpnyAt = self.trlerAcmpnyAt
		newItem.trsagntNo = self.trsagntNo
		newItem.wtrplCo = String(self.wtrplCo)
		newItem.zipcode = String(self.zipcode)

		commitTrans(context: context)
	}
}

extension GoCampingRecvItemImage {

	static func makeDefaultValue() -> GoCampingRecvItemImage {
		return GoCampingRecvItemImage(contentId: "", createdtime: "", imageUrl: "", modifiedtime: "", serialnum: "")
	}

	func toEntity_Site_Image(context: NSManagedObjectContext){
		let newItem = Entity_Site_Image(context: context)
		newItem.contentId = self.contentId
		newItem.serialnum = self.serialnum
		newItem.createdtime = self.createdtime
		newItem.modifiedtime = self.modifiedtime
		newItem.imageUrl = self.imageUrl

		commitTrans(context: context)
	}

}

extension Entity_Site_Image {
	func toGoCampingRecvItemImage() -> GoCampingRecvItemImage {
		return GoCampingRecvItemImage(contentId: self.contentId ?? "",
			createdtime: self.createdtime ?? "", imageUrl: self.imageUrl ?? "",
			modifiedtime: self.modifiedtime ?? "", serialnum: self.serialnum ?? "")
	}
}


extension Entity_Camp_Site {

	func toCampingSiteData() -> CampingSiteData {

		let latitude:Double =  Double(self.mapY?.prefix(8) ?? "0" ) ?? 0
		let longitude:Double = Double(self.mapX?.prefix(9) ?? "0") ?? 0

		return CampingSiteData(contentId: self.contentId ?? "", facltNm:  self.facltNm ?? "", lineIntro: self.lineIntro ?? "",
			intro: self.intro ?? "", lctCl: self.lctCl ?? "", animalCmgCl: self.animalCmgCl ?? "",
			glampInnerFclty: self.glampInnerFclty ?? "", sbrsCl: self.sbrsCl ?? "", eqpmnLendCl: self.eqpmnLendCl ?? "",
			resveCl: self.resveCl ?? "", resveUrl: self.resveUrl ?? "", tel: self.tel ?? "", facltDivNm: self.facltDivNm ?? "",
			induty: self.induty ?? "", doNm: self.doNm ?? "", sigunguNm: self.sigunguNm ?? "", addr1: self.addr1 ?? "",
			firstImageUrl: self.firstImageUrl ?? "", homepage: self.homepage ?? "",
							   latitude: latitude , longitude: longitude
			)
	}

	func toGoCampingRecvItem() -> GoCampingRecvItem {
		return GoCampingRecvItem(addr1: self.addr1 ?? "", addr2: self.addr2 ?? "", allar: self.allar ?? "", animalCmgCl: self.animalCmgCl ?? "",
			autoSiteCo: self.autoSiteCo ?? "", bizrno: self.bizrno ?? "", brazierCl: self.brazierCl ?? "",caravAcmpnyAt: self.caravAcmpnyAt ?? "",
			caravInnerFclty: self.caravInnerFclty ?? "", caravSiteCo: self.caravSiteCo ?? "", clturEvent: self.clturEvent ?? "", clturEventAt: self.clturEventAt ?? "",
			contentId: self.contentId ?? "", createdtime: self.createdtime ?? "", direction: self.direction ?? "", doNm: self.doNm ?? "",
			eqpmnLendCl: self.eqpmnLendCl ?? "", exprnProgrm: self.exprnProgrm ?? "", exprnProgrmAt: self.exprnProgrmAt ?? "", extshrCo: self.extshrCo ?? "",
			facltDivNm: self.facltDivNm ?? "", facltNm: self.facltNm ?? "", featureNm: self.featureNm ?? "", fireSensorCo: self.fireSensorCo ?? "",
			firstImageUrl: self.firstImageUrl ?? "", frprvtSandCo: self.frprvtSandCo ?? "", frprvtWrppCo: self.frprvtWrppCo ?? "",
			glampInnerFclty: self.glampInnerFclty ?? "", glampSiteCo: self.glampSiteCo ?? "", gnrlSiteCo: self.gnrlSiteCo ?? "",
			homepage: self.homepage ?? "", hvofBgnde: self.hvofBgnde ?? "", hvofEnddle: self.hvofEnddle ?? "",
			induty: self.induty ?? "", indvdlCaravSiteCo: self.indvdlCaravSiteCo ?? "", insrncAt: self.insrncAt ?? "", intro: self.intro ?? "",
			lctCl: self.lctCl ?? "", lineIntro: self.lineIntro ?? "", manageNmpr: self.manageNmpr ?? "", manageSttus: self.manageSttus ?? "",
			mangeDivNm: self.mangeDivNm ?? "", mapX: self.mapX ?? "", mapY: self.mapY ?? "", mgcDiv: self.mgcDiv ?? "", modifiedtime: self.modifiedtime ?? "",
			operDeCl: self.operDeCl ?? "", operPdCl: self.operPdCl ?? "", posblFcltyCl: self.posblFcltyCl ?? "", posblFcltyEtc: self.posblFcltyEtc ?? "", prmisnDe: self.prmisnDe ?? "",
			resveCl: self.resveCl ?? "", resveUrl: self.resveUrl ?? "", sbrsCl: self.sbrsCl ?? "", sbrsEtc: self.sbrsEtc ?? "", sigunguNm: self.sigunguNm ?? "",
			siteBottomCl1: self.siteBottomCl1 ?? "", siteBottomCl2: self.siteBottomCl2 ?? "", siteBottomCl3: self.siteBottomCl3 ?? "", siteBottomCl4: self.siteBottomCl4 ?? "",
			siteBottomCl5: self.siteBottomCl5 ?? "", sitedStnc: self.sitedStnc ?? "", siteMg1Co: self.siteMg1Co ?? "", siteMg1Vrticl: self.siteMg1Vrticl ?? "",
			siteMg1Width: self.siteMg1Width ?? "", siteMg2Co: self.siteMg2Co ?? "", siteMg2Vrticl: self.siteMg2Vrticl ?? "", siteMg2Width: self.siteMg2Width ?? "", siteMg3Co: self.siteMg3Co ?? "",
			siteMg3Vrticl: self.siteMg3Vrticl ?? "", siteMg3Width: self.siteMg3Width ?? "", swrmCo: self.swrmCo ?? "", tel: self.tel ?? "", themaEnvrnCl: self.themaEnvrnCl ?? "",
			toiletCo: self.toiletCo ?? "", tooltip: self.tooltip ?? "",tourEraCl: self.tourEraCl ?? "", trlerAcmpnyAt: self.trlerAcmpnyAt ?? "", trsagntNo: self.trsagntNo ?? "",
			wtrplCo: self.wtrplCo ?? "", zipcode: self.zipcode ?? "")
	}
}

extension Entity_Camp_Site_Near {

	func toCampingSiteData() -> CampingSiteData {

		let latitude:Double =  Double(self.mapY?.prefix(8) ?? "0" ) ?? 0
		let longitude:Double = Double(self.mapX?.prefix(9) ?? "0") ?? 0

		return CampingSiteData(contentId: self.contentId ?? "", facltNm:  self.facltNm ?? "", lineIntro: self.lineIntro ?? "",
			intro: self.intro ?? "", lctCl: self.lctCl ?? "", animalCmgCl: self.animalCmgCl ?? "",
			glampInnerFclty: self.glampInnerFclty ?? "", sbrsCl: self.sbrsCl ?? "", eqpmnLendCl: self.eqpmnLendCl ?? "",
			resveCl: self.resveCl ?? "", resveUrl: self.resveUrl ?? "", tel: self.tel ?? "", facltDivNm: self.facltDivNm ?? "",
			induty: self.induty ?? "", doNm: self.doNm ?? "", sigunguNm: self.sigunguNm ?? "", addr1: self.addr1 ?? "",
			firstImageUrl: self.firstImageUrl ?? "", homepage: self.homepage ?? "",
			latitude: latitude , longitude: longitude
			)
	}

	func toGoCampingRecvItem() -> GoCampingRecvItem {
		return GoCampingRecvItem(addr1: self.addr1 ?? "", addr2: self.addr2 ?? "", allar: self.allar ?? "", animalCmgCl: self.animalCmgCl ?? "",
			autoSiteCo: self.autoSiteCo ?? "", bizrno: self.bizrno ?? "", brazierCl: self.brazierCl ?? "",caravAcmpnyAt: self.caravAcmpnyAt ?? "",
			caravInnerFclty: self.caravInnerFclty ?? "", caravSiteCo: self.caravSiteCo ?? "", clturEvent: self.clturEvent ?? "", clturEventAt: self.clturEventAt ?? "",
			contentId: self.contentId ?? "", createdtime: self.createdtime ?? "", direction: self.direction ?? "", doNm: self.doNm ?? "",
			eqpmnLendCl: self.eqpmnLendCl ?? "", exprnProgrm: self.exprnProgrm ?? "", exprnProgrmAt: self.exprnProgrmAt ?? "", extshrCo: self.extshrCo ?? "",
			facltDivNm: self.facltDivNm ?? "", facltNm: self.facltNm ?? "", featureNm: self.featureNm ?? "", fireSensorCo: self.fireSensorCo ?? "",
			firstImageUrl: self.firstImageUrl ?? "", frprvtSandCo: self.frprvtSandCo ?? "", frprvtWrppCo: self.frprvtWrppCo ?? "",
			glampInnerFclty: self.glampInnerFclty ?? "", glampSiteCo: self.glampSiteCo ?? "", gnrlSiteCo: self.gnrlSiteCo ?? "",
			homepage: self.homepage ?? "", hvofBgnde: self.hvofBgnde ?? "", hvofEnddle: self.hvofEnddle ?? "",
			induty: self.induty ?? "", indvdlCaravSiteCo: self.indvdlCaravSiteCo ?? "", insrncAt: self.insrncAt ?? "", intro: self.intro ?? "",
			lctCl: self.lctCl ?? "", lineIntro: self.lineIntro ?? "", manageNmpr: self.manageNmpr ?? "", manageSttus: self.manageSttus ?? "",
			mangeDivNm: self.mangeDivNm ?? "", mapX: self.mapX ?? "", mapY: self.mapY ?? "", mgcDiv: self.mgcDiv ?? "", modifiedtime: self.modifiedtime ?? "",
			operDeCl: self.operDeCl ?? "", operPdCl: self.operPdCl ?? "", posblFcltyCl: self.posblFcltyCl ?? "", posblFcltyEtc: self.posblFcltyEtc ?? "", prmisnDe: self.prmisnDe ?? "",
			resveCl: self.resveCl ?? "", resveUrl: self.resveUrl ?? "", sbrsCl: self.sbrsCl ?? "", sbrsEtc: self.sbrsEtc ?? "", sigunguNm: self.sigunguNm ?? "",
			siteBottomCl1: self.siteBottomCl1 ?? "", siteBottomCl2: self.siteBottomCl2 ?? "", siteBottomCl3: self.siteBottomCl3 ?? "", siteBottomCl4: self.siteBottomCl4 ?? "",
			siteBottomCl5: self.siteBottomCl5 ?? "", sitedStnc: self.sitedStnc ?? "", siteMg1Co: self.siteMg1Co ?? "", siteMg1Vrticl: self.siteMg1Vrticl ?? "",
			siteMg1Width: self.siteMg1Width ?? "", siteMg2Co: self.siteMg2Co ?? "", siteMg2Vrticl: self.siteMg2Vrticl ?? "", siteMg2Width: self.siteMg2Width ?? "", siteMg3Co: self.siteMg3Co ?? "",
			siteMg3Vrticl: self.siteMg3Vrticl ?? "", siteMg3Width: self.siteMg3Width ?? "", swrmCo: self.swrmCo ?? "", tel: self.tel ?? "", themaEnvrnCl: self.themaEnvrnCl ?? "",
			toiletCo: self.toiletCo ?? "", tooltip: self.tooltip ?? "",tourEraCl: self.tourEraCl ?? "", trlerAcmpnyAt: self.trlerAcmpnyAt ?? "", trsagntNo: self.trsagntNo ?? "",
			wtrplCo: self.wtrplCo ?? "", zipcode: self.zipcode ?? "")
	}


}
