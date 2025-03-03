import Foundation
import SwiftUI

@MainActor
class MindViewModel: ObservableObject {
  @Published var messageText = ""
  @Published var messages: [ChatMessage] = []
  @Published var agents: [Agent]
  @Published var isAITyping = false
  @Published var typingRole: Agent? = nil
  @Published var currentStreamingMessage: ChatMessage?
  @Published var displayedContent: String = ""
  @Published var isTypingEffect = false
  private var fullContent: String = ""
  private var currentIndex: Int = 0
  private let typingSpeed: TimeInterval = 0.02  // 打字速度，可以调整

  init(agents: [Agent]) {
    self.agents = agents
    print("🤖 Mind: 初始化完成，激活角色: \(agents.count)个")
  }

  func resetChat() {
    messages.removeAll()
    messageText = ""
  }

  func interruptConversation() {
    isAITyping = false
    typingRole = nil
  }

  func startNewConversation() {
    messages.removeAll()
    messageText = ""
  }

  func sendMessage() {
    guard !messageText.isEmpty else { return }

    let userMessage = ChatMessage(
      role: .user,
      content: messageText,
      timestamp: Date()
    )

    withAnimation {
      messages.append(userMessage)
      messageText = ""
    }

    Task {
      await getAIResponse(to: userMessage)
    }
  }

  @MainActor
  private func startTypingAnimation(for content: String) {
    // 重置状态
    fullContent = content
    currentIndex = 0
    displayedContent = ""

    // 启动打字动画任务
    Task { @MainActor [weak self] in
      guard let self = self else { return }

      while self.currentIndex < self.fullContent.count {
        let index = self.fullContent.index(
          self.fullContent.startIndex,
          offsetBy: self.currentIndex
        )
        self.displayedContent += String(self.fullContent[index])
        self.currentIndex += 1

        try? await Task.sleep(nanoseconds: UInt64(self.typingSpeed * 1_000_000_000))

        // 检查是否应该继续
        guard !Task.isCancelled else { return }
      }
    }
  }

  private func getAIResponse(to userMessage: ChatMessage) async {
    print("🤖 Mind: 开始获取AI响应，用户消息: \(userMessage.content)")
    let current = agents.first!
    let messages = buildMessageHistory(userMessage: userMessage, agent: current)

    isAITyping = true
    withAnimation(.spring(duration: 0.5)) {
      self.typingRole = current
    }

    // 创建一个初始的流式消息
    let streamingMessage = ChatMessage(
      role: .assistant,
      content: "",
      timestamp: Date(),
      agent: current,
      typingState: .loading
    )

    withAnimation {
      self.currentStreamingMessage = streamingMessage
      self.messages.append(streamingMessage)
      self.displayedContent = ""
    }

    API.chatStream(
      config: LLMConfig(
        model: "deepseek-r1-250120",
        messages: messages,
        temperature: current.configuration.temperature,
        maxTokens: current.configuration.maxTokens,
        provider: "volcengine"
      ),
      onReceive: { [weak self] content in
        Task { @MainActor in
          guard let self = self else { return }
          guard !content.isEmpty else {
            print("⚠️ 警告: 收到空消息")
            return
          }

          // 更新流式消息的内容
          self.currentStreamingMessage?.content += content

          if let index = self.messages.firstIndex(where: {
            $0.id == self.currentStreamingMessage?.id
          }) {
            self.messages[index].content += content
            self.messages[index].typingState = .typing
            self.startTypingAnimation(for: self.messages[index].content)
          } else {
            print("⚠️ 警告: 未找到对应的消息索引")
          }
        }
      },
      onError: { [weak self] error in
        Task { @MainActor in
          let errorMessage = ChatMessage(
            role: .assistant,
            content: "抱歉，出现了一个错误：\(error.localizedDescription)\n请稍后重试或联系支持团队。",
            timestamp: Date(),
            agent: current
          )

          withAnimation {
            self?.messages.removeLast()
            self?.messages.append(errorMessage)
            self?.currentStreamingMessage = nil
            self?.isAITyping = false
            self?.typingRole = nil
          }
        }
      },
      onComplete: { [weak self] in
        Task { @MainActor in
          withAnimation(.spring(duration: 0.5)) {
            // 更新当前流式消息的 typingState
            if let currentMessageId = self?.currentStreamingMessage?.id,
              let index = self?.messages.firstIndex(where: { $0.id == currentMessageId })
            {
              self?.messages[index].typingState = .done
            }
            self?.currentStreamingMessage = nil
            self?.isAITyping = false
            self?.typingRole = nil
          }
        }
      }
    )
  }

  private func buildMessageHistory(userMessage: ChatMessage, agent: Agent) -> [LLMMessage] {
    var history: [LLMMessage] = []

    let systemPrompt = """
      作为对话助手，请：
      1. 回答简短精炼，控制在3-4句话内
      2. 使用日常用语，保持对话自然
      3. 适当使用表情符号 😊
      4. 重要内容可以用 Markdown 加粗或标题突出
      5. 如不确定，直接说不知道
      """

    history.append(LLMMessage(role: .system, content: systemPrompt))

    // 添加角色提示语
    history.append(LLMMessage(role: .system, content: agent.prompts.systemPrompt))

    // 保持最近的对话历史
    for message in messages.suffix(2) {
      history.append(LLMMessage(role: message.role, content: message.content))
    }

    return history
  }
}
