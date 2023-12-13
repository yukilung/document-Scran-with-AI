//
//  DocumentDetail.swift
//  Scanner
//
//  Created by Jack on 30/3/2021.
//

import SwiftUI
import LocalAuthentication
import MapKit

struct DocumentDetail: View {
    
    let document: Document
    
    @State private var zoomLevel: CGFloat = 1
    
    @State private var isUnlocked = false
    @State private var blur: Int = 10
    
    @State var organization: String = ""
    @State var address: String = ""
    
    @State private var region = MKCoordinateRegion(
         center: CLLocationCoordinate2D(latitude: 34.011_286, longitude: -116.166_868),
         span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
     )
    
    var body: some View {
        
        ZStack {
            ScrollView {
                Image(uiImage: UIImage(data: document.image!)!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                        .scaleEffect(self.zoomLevel > 1 ? self.zoomLevel : 1)
                    .gesture(MagnificationGesture().onChanged({ (value) in
                        self.zoomLevel = value
                    }).onEnded({ (_) in
                        withAnimation(.spring()) {
                            self.zoomLevel = 1
                        }
                    })
                    .simultaneously(with: TapGesture(count: 2).onEnded({ () in
                        withAnimation {
                            self.zoomLevel = zoomLevel > 1 ? 1 : 4
                        }
                    }))
                    )
                        
                VStack(alignment: .leading) {
                    TextField(document.organization ?? "None", text: $organization)
                        .font(.title)
                    
                    Divider()

                    TextField(document.address ?? "", text: $address)
                        .font(.title2)
                        
                    Map(coordinateRegion: $region)
                        .ignoresSafeArea(edges: .top)
                        .cornerRadius(25)
                        .frame(height: 300)
                }
                .padding()
                .disabled(isUnlocked == false)
            }
            .blur(radius: CGFloat(blur))
            .navigationTitle("Document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                 ToolbarItem() {
                     Button("Update") {
                        if !organization.isEmpty {
                            
                        }
                        if !address.isEmpty {
                            
                        }
                        
                     }
                     .opacity(isUnlocked ? 1 : 0)
                 }
             }
            Button("Unlock") {
                authenticate()
            }
            .opacity(isUnlocked ? 0 : 1)
        }

        
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please authenticate yourself to unlock your places."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in

                DispatchQueue.main.async {
                    if success {
                        isUnlocked = true
                        blur = 0
                    } else {
                        // error
                    }
                }
            }
        } else {
            // no biometrics
        }
    }
    
}

//struct DocumentDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        DocumentDetail()
//    }
//}
