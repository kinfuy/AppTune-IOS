import SwiftUI

//主视图
struct GuideView: View {
    @Binding var showGuide:Bool
    @State var pageNumber = 1//当前页的ID
    @State var periousOffset = CGSize(width: UIScreen.main.bounds.width, height: 0)
    @State var offset = CGSize(width: UIScreen.main.bounds.width, height: 0)
    var body:some View {
        //手势滑动,也算是页面里的算法逻辑了。
        let dragGesture = DragGesture()
            .onChanged { value in
                offset.width = periousOffset.width + value.translation.width
            }
            .onEnded { value in
                if abs(value.translation.width) < 30 {
                    offset.width = periousOffset.width//手势滑动超过50才偏移
                }else{
                    if value.translation.width > 0 && pageNumber > 1 {
                        periousOffset.width += UIScreen.main.bounds.width
                        pageNumber -= 1
                        offset.width = periousOffset.width
                    }else if value.translation.width < 0 && pageNumber < 3 {
                        periousOffset.width -= UIScreen.main.bounds.width
                        pageNumber += 1
                        offset.width = periousOffset.width
                    }else{ offset.width = periousOffset.width }
                }
            }
        VStack(alignment: .center){
            //使用横向偏移切换页面
            HStack {
                PageView(
                    imageName:"welcome",
                    title: "欢迎",
                    subTitle: "在生活的点滴间，有很多有趣，有意义的数字，Suka 数字卡片为你留下这些数字瞬间"
                )
                PageView(
                    imageName: "card",
                    title: "卡片集",
                    subTitle: "添加各种类型的卡片，记录日子，统计次数，记录社交媒体变化，记里程碑, 更多有趣的卡片"
                )
                PageView(
                    imageName: "happy",
                    title: "遇见数字",
                    subTitle: "发现生活中的数字故事，与 Suka 一起记录精彩瞬间！"
                )
            }
            .offset(x: offset.width, y: 0)
            .contentShape(Rectangle())
            .gesture(dragGesture)
            .animation(.interpolatingSpring(stiffness: 100, damping: 30), value: offset)
            VStack {
                PageIndicator(pageNumber: $pageNumber)//下面的3个小圆点
                button //底部按钮
            }
            .padding(.bottom, 20)
        }
    }
    var button:some View {
        Button(action: {
            if pageNumber == 3 {
                showGuide = false
            }else{
                periousOffset.width -= UIScreen.main.bounds.width
                pageNumber += 1
                offset.width = periousOffset.width
            }
        }) {
            Text(pageNumber == 3 ? "开启数字之旅" : "下一步")
                .foregroundColor(.white)
                .fontWeight(.heavy)
                .multilineTextAlignment(.trailing)
                .frame(width: 180, height: 48, alignment: .center)
                .background(Color.theme.opacity(0.68))
                .font(.system(size: 18))
                .cornerRadius(25)
        }
        
    }
}

struct PageView: View {
    var imageName:String
    var title:String
    var subTitle = ""
    var slogen = ""
    var body:some View {
        VStack {
            Spacer()
            Image("dog")
                .resizable()
                .frame(width: 180, height: 176, alignment: .center)
            Text(title)
                .font(.system(size: 32))
                .fontWeight(.heavy)
                .foregroundColor(.theme)
                .padding(.top, 30)
            Text(subTitle)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.top, 16)
                .padding(.bottom, 16)
            if slogen != "" {
                Text(slogen)
                    .font(.system(size: 22))
                    .foregroundColor(Color.theme)
            }
            
            Spacer()
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width)
    }
}
//显示下面3个小圆点
struct PageIndicator: View {
    @Binding var pageNumber:Int
    var body:some View {
        HStack {
            ForEach(1..<4){ num in
                circle(num)//显示圆点数量
            }
        }
        .padding(.bottom, 60)
    }
    //定义下面的小圆点
    private func circle(_ num:Int) -> some View {
        Circle()
            .frame(width: 10, height: 10)
            .foregroundColor(pageNumber == num ? Color.theme : .gray)
    }
}


struct test_Previews: PreviewProvider {
    static var previews: some View {
        @State var show = false
        GuideView(showGuide: $show)
    }
}

