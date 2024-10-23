import SwiftUI

extension Text {
    func colorTag(_ color:Color) -> some View {
        return self
            .padding(.vertical, 2)
            .padding(.horizontal, 4)
            .foregroundColor(color)
            .background(color.opacity(0.1))
            .cornerRadius(4)
    }
    
    func underLine(_ color:Color) -> some View {
        ZStack{
            VStack{
                Rectangle()
                    .frame(height: 10)
                    .foregroundColor(color)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .padding(.top, 16)
            }
            self
        }
    }
    
    func color(_ color:Color) -> some View {
        self.foregroundColor(color)
    }
    
}
