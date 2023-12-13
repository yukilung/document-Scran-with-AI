//
//  DocumentList.swift
//  Scanner
//
//  Created by Jack on 30/3/2021.
//

import SwiftUI
import CoreData

struct DocumentList: View {
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(entity: Document.entity(), sortDescriptors: [])
    private var documents: FetchedResults<Document>
    
    @State private var recognizedText = ""
    @State private var showingScanningView = false
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(documents) { document in
                        NavigationLink(destination: DocumentDetail(document: document)) {
                            DocumentRow(document: document)
                        }
                     }
                     .onDelete(perform: documentDelete)
                }
                .listStyle(InsetGroupedListStyle())
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            self.showingScanningView = true
                        }, label: {
                            Text("+")
                            .font(.system(.largeTitle))
                            .frame(width: 77, height: 70)
                            .foregroundColor(Color.white)
                            .padding(.bottom, 7)
                        })
                        .background(Color.blue)
                        .cornerRadius(38.5)
                        .padding()
                        .shadow(color: Color.black.opacity(0.3),
                                radius: 3,
                                x: 3,
                                y: 3)
                    }
                }
            }
            .navigationTitle("Scanner")
            .sheet(isPresented: $showingScanningView) {
                ScanDocumentView(recognizedText: self.$recognizedText)
            }
        }
    }

    private func documentDelete(offsets: IndexSet) {
        withAnimation {
            offsets.map { documents[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    
}


struct DocumentList_Previews: PreviewProvider {
    static var previews: some View {
        DocumentList().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
