//
//  WeatherModel.swift
//  campsite
//
//  Created by 여운칠 on 2022/09/19.
//

import Foundation
import CoreData
import CoreLocation

struct WeatherData: Hashable, Codable, Identifiable {

	var coord: Coord
	var weather: [Weather]
	var base: String
	var main: Main
	var visibility: Int
	var wind: Wind
	var clouds: Clouds
	var dt:CLong
	var sys: Sys
	var timezone: CLong
	var id: CLong
	var name: String
	var cod: Int
}

	struct Coord: Hashable, Codable {
		var lon: Float
		var lat: Float
	}

	struct Weather: Hashable, Codable {
		var id: Int
		var main: String
		var description: String
		var icon: String
	}

	struct Main: Hashable, Codable {
		var temp: Float
		var feels_like: Float
		var pressure: Float
		var humidity: Float
		var temp_min: Float
		var temp_max: Float
	}

	struct Wind: Hashable, Codable {
		var speed: Float
		var deg: Float
	}

	struct Clouds: Hashable, Codable {
		var all : Int
	}

	struct Sys: Hashable, Codable {
		var country: String
		var sunrise: CLong
		var sunset: CLong
	}


extension WeatherData {

	static func makeDefaultValue() -> WeatherData {
		return  WeatherData(
					coord: Coord(lon: 126.93407, lat: 37.38575)
				   , weather: [Weather(id: 0, main: "unknown", description: "unknown", icon: "01d")]
				   , base: "unknown"
				   , main: Main(temp: 0.0, feels_like: 0.0, pressure: 0, humidity: 0, temp_min: 0.0, temp_max: 0.0)
				   , visibility: 0
				   , wind: Wind(speed: 0.0, deg: 0)
				   , clouds: Clouds(all: 0)
				   , dt: CLong(Date.now.timeIntervalSince1970)
				   , sys: Sys(country: "unknown", sunrise: 0, sunset: 0)
				   , timezone: 32400
				   , id: 0
				   , name: "unknown"
				   , cod: 200)
	}

	func toEntity_Current_Weather(context: NSManagedObjectContext) {

		let newItem = Entity_Current_Weather(context: context)

		newItem.writetime = Int64(self.dt)
		newItem.base = self.base
		newItem.visibility = Int64(self.visibility)
		newItem.timezone = Int64(self.timezone)
		newItem.name = self.name
		newItem.latitude = self.coord.lat
		newItem.longitude = self.coord.lon
		newItem.main = self.weather[0].main
		newItem.desc = self.weather[0].description
		newItem.icon = self.weather[0].icon

		newItem.temp = self.main.temp
		newItem.feels_like = self.main.feels_like
		newItem.pressure = self.main.pressure
		newItem.humidity = self.main.humidity
		newItem.temp_min = self.main.temp_min
		newItem.temp_max = self.main.temp_max

		newItem.speed = self.wind.speed
		newItem.deg = self.wind.deg
		newItem.all = Int64(self.clouds.all)
		newItem.type = 0
		newItem.country = self.sys.country
		newItem.sunrise = Int64(self.sys.sunrise)
		newItem.sunset = Int64(self.sys.sunset)

	commitTrans(context: context)

	}
}

// Parameters ( *: required)
struct OpendWeatherDefaultParam {
	var appid:String //(*) 발급받은 api key
	var units:String // 측량 단위
	var lat:String // (*) 위도
	var lon:String // (*) 경도
}



extension Entity_Current_Weather {

	var toWeatherData: WeatherData {

		let coord = Coord( lon : self.longitude, lat : self.latitude )
		let weathers: [Weather] = [ Weather( id: 0,
									main: self.main!,
									description: self.desc!,
									icon: self.icon!)]

		let main = Main (
			temp: self.temp,
			feels_like: self.feels_like,
			pressure: self.pressure,
			humidity: self.humidity,
			temp_min: self.temp_min,
			temp_max: self.temp_max
		)

		let wind = Wind(speed: self.speed, deg: self.deg)
		let clouds = Clouds( all: Int(self.all))
		let sys = Sys (
			country: self.country!,
			sunrise: CLong(self.sunrise),
			sunset: CLong(self.sunset)
		)

		return WeatherData (coord: coord,
							   weather: weathers,
							   base: self.base!,
							   main: main,
							   visibility: Int(self.visibility),
							   wind: wind,
							   clouds: clouds,
							   dt: CLong(self.writetime),
							   sys: sys,
							   timezone: CLong(self.timezone),
							   id:CLong(0),
							   name: self.name!,
							   cod: 0)
	}
}
