//
//  MenuButtonView.swift
//  BusinessHours
//
//  Created by Tingzhi Li on 6/3/24.
//

import SwiftUI

struct MenuButtonView: View {
    var body: some View {
        VStack {
            Image(systemName: "chevron.up")
                .font(.system(size: 18))
                .opacity(0.6)
            Image(systemName: "chevron.up")
                .font(.system(size: 18))
            Text("View Menu")
                .font(.system(size: 23))
                .padding(.top)
        }
        .padding(.top)
    }
}

#Preview {
    MenuButtonView()
}
