import SwiftUI
import WidgetKit

@main
struct GradeAppWidgets: WidgetBundle {
  var body: some Widget {
    NextLessonWidget()
    DayWidget()
    ChildStatusWidget()
    if #available(iOS 16.2, *) {
      LessonLiveActivity()
    }
  }
}
