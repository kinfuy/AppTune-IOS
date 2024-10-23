
import SwiftUI

struct ToastView: View {
    @Binding var isShow: Bool
    let info: String
    @State private var isShowAnimation: Bool = true
    @State private var duration: Double

    init(isShow: Binding<Bool>, info: String = "", duration: Double = 1.0) {
        _isShow = isShow
        self.info = info
        self.duration = duration
    }

    var body: some View {
        ZStack {
            Text(info)
                .font(Font.title3)
                .foregroundColor(.white)
                .frame(minWidth: 80, alignment: Alignment.center)
                .zIndex(1.0)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(.black)
                        .opacity(0.6)
                )
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                isShowAnimation = false
            }
        }
        .padding()
        .opacity(isShowAnimation ? 1 : 0)
        .edgesIgnoringSafeArea(.all)
        .onChange(of: isShowAnimation){
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeIn(duration: 0.8), {
                    self.isShow = false
                })
            }
        }
    }
}


extension View {
    func toast(isShow: Binding<Bool>, info: String = "", duration: Double = 1.0) -> some View {
        ZStack {
            self
            if isShow.wrappedValue {
                ToastView(isShow: isShow, info: info, duration: duration)
            }
        }
    }
}
