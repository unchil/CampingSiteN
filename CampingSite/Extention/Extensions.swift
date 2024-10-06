//
//  Extensions.swift
//  campsite
//
//  Created by 여운칠 on 2022/09/22.
//

import SwiftUI

extension CLong {

	func formatHHmm() -> String {
		let time = Double(self * CLong(1.000000) )
		let date = Date(timeIntervalSince1970: time)
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "HH:mm"
		return dateFormatter.string(from: date)
	}
}

extension String {

	func getIconImage() -> Image {
		switch (self) {
			case "01d" :  return Image("ic_openweather_01d")
			case "01n" : return Image("ic_openweather_01n")
			case "02d" : return Image("ic_openweather_02d")
			case "02n" : return Image("ic_openweather_02n")
			case "03d" : return Image("ic_openweather_03d")
			case "03n" : return Image("ic_openweather_03n")
			case "04d" : return Image("ic_openweather_04d")
			case "04n" : return Image("ic_openweather_04n")
			case "09d" : return Image("ic_openweather_09n")
			case "09n" : return Image("ic_openweather_09n")
			case "10d" : return Image("ic_openweather_10d")
			case "10n" : return Image("ic_openweather_10n")
			case "11d" : return Image("ic_openweather_11d")
			case "11n" : return Image("ic_openweather_11n")
			case "13d" : return Image("ic_openweather_13d")
			case "13n" : return Image("ic_openweather_13n")
			case "50d" : return Image("ic_openweather_50d")
			case "50n" : return Image("ic_openweather_50n")
			default: return Image("ic_openweather_unknown")
		}
	}

}


extension URL {
	func chkScheme() -> URL {
		if !(["http", "https"].contains(self.scheme?.lowercased())) {
			let appendedLink = "http://" + self.absoluteString
			return URL(string: appendedLink)!
		}else {
			return self
		}
	}
}
