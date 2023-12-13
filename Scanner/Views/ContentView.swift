//
//  ContentView.swift
//  Scanner
//
//  Created by Jack on 29/3/2021.
//

import SwiftUI
import CoreData

struct ContentView: View {

    var body: some View {
        DocumentList()
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
