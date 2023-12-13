//
//  DocumentRow.swift
//  Scanner
//
//  Created by Jack on 11/5/2021.
//

import SwiftUI

struct DocumentRow: View {

    let document: Document

    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            Image(uiImage: UIImage(data: document.image!)!)
                .resizable()
                .renderingMode(.original)
                .frame(width: 140, height: 180, alignment: .center)
                .cornerRadius(8)
                .scaledToFill()

            VStack(alignment: .leading, spacing: 5, content: {
                Text(document.organization ?? "")
            })
        }
    }
}

//struct DocumentRow_Previews: PreviewProvider {
//    static var previews: some View {
//        DocumentRow()
//            .previewLayout(.sizeThatFits)
//            .padding()
//    }
//}
