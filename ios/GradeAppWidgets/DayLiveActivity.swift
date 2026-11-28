import ActivityKit
import SwiftUI
import WidgetKit

/// W6 «Мой учебный день» on the lock screen and in the Dynamic Island.
/// Labels are chosen here by the phone's language: a server-started activity
/// carries data only.
@available(iOS 16.2, *)
struct DayLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: DayActivityAttributes.self) { context in
      DayLockView(state: context.state, stale: context.isStale)
        .activityBackgroundTint(Color(UIColor(hex: 0x161820)).opacity(0.9))
        .activitySystemActionForegroundColor(.white)
        .widgetURL(URL(string: "gradeapp://app/go/today"))
    } dynamicIsland: { context in
      let s = context.state
      return DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Text(s.phase == "done" ? dayDone : s.subject).font(G.font(15, .heavy)).lineLimit(1)
        }
        DynamicIslandExpandedRegion(.trailing) {
          if s.phase != "done" {
            Text(timerInterval: Date()...s.boundary, countsDown: true).font(G.font(15, .heavy)).monospacedDigit()
              .frame(maxWidth: 70, alignment: .trailing)
          }
        }
        DynamicIslandExpandedRegion(.bottom) {
          Text(s.line).font(G.font(13, .semibold)).foregroundStyle(.secondary).lineLimit(1)
        }
      } compactLeading: {
        Text(s.phase == "done" ? "✓" : String(s.subject.prefix(4))).font(G.font(13, .heavy))
      } compactTrailing: {
        if s.phase != "done" {
          Text(timerInterval: Date()...s.boundary, countsDown: true).monospacedDigit().frame(maxWidth: 44)
        }
      } minimal: {
        Image(systemName: s.phase == "lesson" ? "book.fill" : "clock.fill")
      }
      .widgetURL(URL(string: "gradeapp://app/go/today"))
    }
  }
}

private let dayDone = trs("Уроки закончились", "Сабақтар бітті", "School's over")

@available(iOS 16.2, *)
private extension DayActivityAttributes.ContentState {
  /// The next moment the picture changes: the bell or the next lesson.
  var boundary: Date { phase == "lesson" ? end : start }

  /// «каб. 204 · дальше Физика в 10:20»
  var line: String {
    var parts: [String] = []
    if !room.isEmpty { parts.append(trs("каб. ", "каб. ", "room ") + room) }
    if phase == "lesson", !nextSubject.isEmpty, let n = nextStartsAt {
      parts.append(trs("дальше ", "келесі ", "next ") + nextSubject + " " + trs("в ", "", "at ") + hm(n))
    } else if phase == "before" || phase == "break" {
      parts.append(trs("в ", "", "at ") + hm(startsAt))
    }
    return parts.joined(separator: " · ")
  }

  func hm(_ t: Int) -> String {
    let f = DateFormatter()
    f.dateFormat = "HH:mm"
    return f.string(from: Date(timeIntervalSince1970: TimeInterval(t)))
  }
}

func trs(_ ru: String, _ kk: String, _ en: String) -> String {
  let lang = Locale.preferredLanguages.first?.prefix(2) ?? "ru"
  return lang == "kk" ? kk : lang == "en" ? en : ru
}

@available(iOS 16.2, *)
private struct DayLockView: View {
  let state: DayActivityAttributes.ContentState
  let stale: Bool

  private var title: String {
    switch state.phase {
    case "lesson": return trs("Сейчас", "Қазір", "Now")
    case "done": return dayDone
    default: return trs("Дальше", "Келесі", "Next")
    }
  }

  var body: some View {
    HStack(alignment: .center) {
      VStack(alignment: .leading, spacing: 3) {
        Text(title.uppercased()).font(G.font(11, .bold)).foregroundStyle(.white.opacity(0.7))
        if state.phase != "done" {
          Text(state.subject).font(G.font(20, .heavy)).foregroundStyle(.white).lineLimit(1)
          Text(state.line).font(G.font(13, .semibold)).foregroundStyle(.white.opacity(0.85)).lineLimit(1)
        }
      }
      Spacer()
      if state.phase != "done" && !stale {
        VStack(alignment: .trailing, spacing: 0) {
          Text((state.phase == "lesson" ? trs("до звонка", "қоңырауға дейін", "until the bell") : trs("начнётся через", "басталуға", "starts in")).uppercased())
            .font(G.font(10, .bold)).foregroundStyle(.white.opacity(0.7))
          Text(timerInterval: Date()...state.boundary, countsDown: true).font(G.font(28, .heavy)).monospacedDigit()
            .foregroundStyle(G.toastAction).multilineTextAlignment(.trailing).frame(maxWidth: 110, alignment: .trailing)
          if state.left > 0 {
            Text(trs("осталось уроков: ", "қалған сабақ: ", "lessons left: ") + "\(state.left)").font(G.font(11, .semibold)).foregroundStyle(.white.opacity(0.7))
          }
        }
      }
    }
    .padding(16)
  }
}
