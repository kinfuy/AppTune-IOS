import SwiftUI

struct AgentSelector: View {
  let agents: [Agent]
  @Binding var selectedAgents: [Agent]

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 12) {
        ForEach(agents) { agent in
          AgentButton(
            agent: agent,
            isSelected: selectedAgents.contains(where: { $0.id == agent.id })
          ) {
            if let index = selectedAgents.firstIndex(where: { $0.id == agent.id }) {
              selectedAgents.remove(at: index)
            } else {
              selectedAgents.append(agent)
            }
          }
        }
      }
      .padding(.horizontal)
    }
  }
}

private struct AgentButton: View {
  let agent: Agent
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 8) {
        ImgLoader(agent.avatar)
          .cornerRadius(all: 8)
          .frame(width: 24, height: 24)

        Text(agent.name)
          .font(.subheadline)
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
      .cornerRadius(20)
      .overlay(
        RoundedRectangle(cornerRadius: 20)
          .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
      )
    }
    .foregroundColor(isSelected ? .blue : .primary)
  }
}
