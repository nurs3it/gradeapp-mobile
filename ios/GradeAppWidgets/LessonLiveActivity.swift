import ActivityKit
import SwiftUI
import WidgetKit

/// W5 «Идёт урок»: lock screen and Dynamic Island. Drawn here, driven by the
/// app (Runner/LiveActivity.swift). No student names, no grades.
@available(iOS 16.2, *)
struct LessonLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: LessonActivityAttributes.self) { context in
      LockView(state: context.state, id: context.attributes.lessonId, stale: context.isStale)
        .activityBackgroundTint(Color(UIColor(hex: 0x161820)).opacity(0.9))
        .activitySystemActionForegroundColor(.white)
        .widgetURL(lessonURL(context.attributes.lessonId))
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          VStack(alignment: .leading) {
            Text(context.state.title).font(G.font(22, .heavy))
            Text(context.state.subject).font(G.font(13, .semibold)).foregroundStyle(.secondary).lineLimit(1)
          }
        }
        DynamicIslandExpandedRegion(.trailing) {
          if context.state.ended {
            Image(systemName: "checkmark.circle.fill").font(.system(size: 26)).foregroundStyle(G.toastAction)
          } else {
            Text(context.state.endsAt, style: .timer).font(G.font(26, .heavy)).foregroundStyle(G.toastAction)
              .monospacedDigit().multilineTextAlignment(.trailing).frame(maxWidth: 90)
          }
        }
        DynamicIslandExpandedRegion(.bottom) {
          VStack(alignment: .leading, spacing: 8) {
            Text(context.state.ended || context.isStale ? context.state.labelEnded : context.state.labelMarked)
              .font(G.font(13, .semibold))
            if !(context.state.ended || context.isStale), let label = context.state.labelAllPresent {
              AllPresentButton(label: label, id: context.attributes.lessonId)
            }
          }
        }
      } compactLeading: {
        Image(systemName: "rectangle.stack.fill").foregroundStyle(G.toastAction)
      } compactTrailing: {
        if context.state.ended {
          Image(systemName: "checkmark").foregroundStyle(G.toastAction)
        } else {
          Text(context.state.endsAt, style: .timer).font(G.font(13, .bold)).foregroundStyle(G.toastAction)
            .monospacedDigit().frame(maxWidth: 48)
        }
      } minimal: {
        ProgressView(timerInterval: context.state.startsAt...context.state.endsAt, countsDown: false, label: { EmptyView() }, currentValueLabel: { EmptyView() })
          .progressViewStyle(.circular).tint(G.toastAction)
      }
      .widgetURL(lessonURL(context.attributes.lessonId))
    }
  }
}

/// `gradeapp://app/lesson/<id>`; with `allPresent` the app also marks the
/// whole class present (the lesson screen's «Все на месте», sent once).
private func lessonURL(_ id: String, allPresent: Bool = false) -> URL? {
  URL(string: "gradeapp://app/lesson/\(id)" + (allPresent ? "?all_present=1" : ""))
}

/// W5 «Все на месте»: opens the app on the lesson and records the roll call.
@available(iOS 16.2, *)
private struct AllPresentButton: View {
  let label: String
  let id: String

  var body: some View {
    if let url = lessonURL(id, allPresent: true) {
      Link(destination: url) {
        Text(label)
          .font(G.font(15, .bold))
          .foregroundStyle(.white)
          .frame(maxWidth: .infinity, minHeight: 36)
          .background(G.brand, in: Capsule())
      }
    }
  }
}

@available(iOS 16.2, *)
private struct LockView: View {
  let state: LessonActivityAttributes.ContentState
  let id: String
  let stale: Bool

  /// Past the bell the activity says the lesson is over even if the app
  /// could not update it (the app may have been closed).
  private var over: Bool { state.ended || stale }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack(alignment: .top) {
        VStack(alignment: .leading, spacing: 2) {
          Text("\(state.title) · \(state.subject)").font(G.font(16, .heavy)).foregroundStyle(.white).lineLimit(1)
          Text(over ? state.labelEnded : state.labelMarked).font(G.font(13, .semibold)).foregroundStyle(.white.opacity(0.8))
        }
        Spacer()
        if !over {
          VStack(alignment: .trailing, spacing: 0) {
            Text(state.labelUntil.uppercased()).font(G.font(11, .bold)).foregroundStyle(.white.opacity(0.7))
            Text(state.endsAt, style: .timer).font(G.font(28, .heavy)).foregroundStyle(G.toastAction)
              .monospacedDigit().multilineTextAlignment(.trailing).frame(maxWidth: 110, alignment: .trailing)
          }
        }
      }
      if !over, let label = state.labelAllPresent {
        AllPresentButton(label: label, id: id)
      }
      if !over {
        ProgressView(timerInterval: state.startsAt...state.endsAt, countsDown: false, label: { EmptyView() }, currentValueLabel: { EmptyView() })
          .progressViewStyle(.linear).tint(G.toastAction)
      }
    }
    .padding(16)
  }
}
