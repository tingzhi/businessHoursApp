//
//  BusinessHoursSectionHeaderView.swift
//  BusinessHours
//
//  Created by Tingzhi Li on 6/3/24.
//

import SwiftUI

struct BusinessHoursSectionHeaderView: View {
    var headerText: String
    var statusColor: Color
    @Binding var showFullHours: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(headerText)
                        .font(.system(size: 16))
                        .foregroundStyle(.black)
                    
                    Image(systemName: "circle.fill")
                        .resizable()
                        .frame(width: 10, height: 10)
                        .foregroundStyle(statusColor)
                }
                Text("See full hours".uppercased())
                    .font(.system(size: 13))
            }
            
            Spacer()
            
            Button {
                showFullHours.toggle()
            } label: {
                Image(systemName: showFullHours ? "chevron.up" : "chevron.down")
                    .foregroundStyle(.black)
            }
        }
        .padding()
        .listRowInsets(EdgeInsets())
        .background(.regularMaterial)
    }
}

#Preview {
    let headerText = "Open until 8PM"
    let statusColor = Color.green
    let showFullHours = Binding(projectedValue: .constant(true))
    return BusinessHoursSectionHeaderView(headerText: headerText,
                                          statusColor: statusColor,
                                          showFullHours: showFullHours)
}
