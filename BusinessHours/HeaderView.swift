//
//  HeaderView.swift
//  BusinessHours
//
//  Created by Tingzhi Li on 6/3/24.
//

import SwiftUI

struct HeaderView: View {
    
    var headerText: String
    
    var body: some View {
        HStack {
            Text(headerText)
                .font(.system(size: 40, weight: .bold))
                .padding()
            
            Spacer()
        }
    }
}

#Preview {
    let headerText = "BEASTRO by Marshawn Lynch"
    return HeaderView(headerText: headerText)
}
