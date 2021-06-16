//
//  MapView.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/6/15.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State var region:MKCoordinateRegion
    
    var body: some View {
        Map(coordinateRegion: $region).disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
    }
    
    init(region:MKCoordinateRegion) {
        print(region)
        self.region = region
    }
    
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        let mapView = MKMapView()
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4))
        
        return MapView(region: region)
    }
}
