//
//  WeatherView.swift
//  campsite
//
//  Created by 여운칠 on 2022/09/22.
//

import SwiftUI

struct WeatherView: View {


    @Environment(\.managedObjectContext)
    private var viewContext

    @FetchRequest(sortDescriptors:[])
	private var resultSet_CollectTime: FetchedResults<Entity_CollectTime>
	
	@FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Entity_Current_Weather.writetime, ascending: false)])
	private var resultSet_CurrentWeather: FetchedResults<Entity_Current_Weather>

	@StateObject var controller  = WeatherController.controller

	var body: some View {

		VStack(spacing:0) {

			HStack {
				Text("\(self.controller.weatherData.name) / \(self.controller.weatherData.sys.country)")
				Text("\(self.controller.weatherData.weather[0].main):\(self.controller.weatherData.weather[0].description)")
				Text( "\(Int(self.controller.weatherData.main.temp)) ºC" )
			}

			HStack {

				self.controller.weatherData.weather[0].icon.getIconImage()
				.scaleEffect(0.4)
				.frame(width:50, height:50)

				VStack(alignment: .leading){

					Label("일출 \(self.controller.weatherData.sys.sunrise.formatHHmm())", systemImage: "sunrise")
					Label("일몰 \(self.controller.weatherData.sys.sunset.formatHHmm())", systemImage: "sunset")

				}

				VStack(alignment: .leading){
					Label("최저 \(Int(self.controller.weatherData.main.temp_min)) ºC", systemImage: "thermometer.snowflake")
					Label("최고 \(Int(self.controller.weatherData.main.temp_max)) ºC", systemImage: "thermometer.sun")
				}
			}.padding(.horizontal)

		}
		.font(.system(size: 12, weight: .regular, design: .serif))
		.onAppear{
			self.setWeatherInfo()
		}
		.onChange(of: self.controller.locationService.authStatus) { newValue in
			if newValue == .authorizedWhenInUse || newValue == .authorizedAlways {
				self.setWeatherInfo()
			}
		}

	}

	func setWeatherInfo(){
		let _ = self.resultSet_CollectTime.first.map { item in
			self.controller.refreshWeather(beforeTime: item.weather,viewContext: self.viewContext){ _,_ in
				if let result = self.resultSet_CurrentWeather.first, result.writetime != self.controller.weatherData.dt {
					self.controller.weatherData = result.toWeatherData
				}
			}
		}
	}
}





struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView()
    }
}

