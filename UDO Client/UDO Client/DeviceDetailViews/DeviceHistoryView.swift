//
//  DeviceHistoryView.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/6/15.
//

import SwiftUI
import SwiftUICharts

struct historyData: Identifiable {
    var name: String
    var data: [Double]
    var id = UUID()
}

struct DeviceHistoryView: View {
    let styles:[ChartStyle] = [
        ChartStyle(backgroundColor: .white, accentColor: Colors.BorderBlue, gradientColor: GradientColors.blue, textColor: .black, legendTextColor: .black, dropShadowColor: .gray),
        
        ChartStyle(backgroundColor: .white, accentColor: Colors.BorderBlue, gradientColor: GradientColors.prplNeon, textColor: .black, legendTextColor: .black, dropShadowColor: .gray),
        
        ChartStyle(backgroundColor: .white, accentColor: Colors.BorderBlue, gradientColor: GradientColors.orange, textColor: .black, legendTextColor: .black, dropShadowColor: .gray),
        
    ]
    
    init(datas: [String:[Double]]) {
        self.datas = []
        for e in datas {
            let oneHistory = historyData(name: e.key, data: e.value)
            self.datas.append(oneHistory)
        }
        print(self.datas)
    }
    
    var datas: [historyData]
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(self.datas) { history in
                    LineChartView(data: history.data, title: history.name, form: ChartForm.extraLarge, rateValue: 0)
                        .padding()
                        
                }
            }
        }
    }
}

struct DeviceHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        let datas = [
            "Temperature": [14.0,13.0,54.0,62.0,12.5,4.5,7.6,55.5],
            "Humidity": [14.1,23.3,34.5,66.3,22.4,44.6,73.5,5.9],
        ]
        
        return DeviceHistoryView(datas: datas)
    }
}
