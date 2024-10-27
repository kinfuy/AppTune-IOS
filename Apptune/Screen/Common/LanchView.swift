import SwiftUI

struct LaunchView: View {
  var body: some View {
    GeometryReader(content: { geometry in
      VStack {
        VStack {
            Image("logo")
             .resizable()
             .frame(width: 160, height: 160)
          Text("AppTune")
            .font(.system(size: 24))
        }
        .padding(.bottom, 50)
      }
      .frame(width: geometry.size.width, height: geometry.size.height)
    })

      .enableInjection()
  }

  #if DEBUG
  @ObserveInjection var forceRedraw
  #endif
}

#Preview {
  LaunchView()
}
