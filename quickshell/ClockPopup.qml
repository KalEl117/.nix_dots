pragma ComponentBehavior: Bound
import QtQuick
import Quickshell

PopupWindow {
  id: popup
  required property Item anchorItem
  required property var settings
  property date shownMonth: new Date(new Date().getFullYear(), new Date().getMonth(), 1)
  readonly property var days: buildDays(shownMonth)
  readonly property var weeks: buildWeeks(shownMonth)

  function isoWeek(date) {
    const value = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
    const weekday = value.getUTCDay() || 7;
    value.setUTCDate(value.getUTCDate() + 4 - weekday);
    const yearStart = new Date(Date.UTC(value.getUTCFullYear(), 0, 1));
    return Math.ceil((((value - yearStart) / 86400000) + 1) / 7);
  }

  function buildWeeks(month) {
    const first = new Date(month.getFullYear(), month.getMonth(), 1);
    const offset = (first.getDay() + 6) % 7;
    const firstMonday = new Date(first.getFullYear(), first.getMonth(), 1 - offset);
    const result = [];
    for (let week = 0; week < 6; week++) {
      result.push(isoWeek(new Date(firstMonday.getFullYear(), firstMonday.getMonth(), firstMonday.getDate() + week * 7)));
    }
    return result;
  }

  function buildDays(month) {
    const year = month.getFullYear();
    const number = month.getMonth();
    const first = new Date(year, number, 1);
    const offset = (first.getDay() + 6) % 7;
    const start = new Date(year, number, 1 - offset);
    const today = new Date();
    const result = [];
    for (let i = 0; i < 42; i++) {
      const date = new Date(start.getFullYear(), start.getMonth(), start.getDate() + i);
      result.push({
        day: date.getDate(),
        current: date.getMonth() === number,
        today: date.getFullYear() === today.getFullYear() && date.getMonth() === today.getMonth() && date.getDate() === today.getDate()
      });
    }
    return result;
  }

  function changeMonth(delta) {
    shownMonth = new Date(shownMonth.getFullYear(), shownMonth.getMonth() + delta, 1);
  }

  implicitWidth: 360
  implicitHeight: 410
  color: "transparent"
  grabFocus: true
  anchor {
    item: popup.anchorItem
    edges: Edges.Bottom | Edges.Right
    gravity: Edges.Bottom | Edges.Left
    adjustment: PopupAdjustment.Slide
    margins.top: 8
  }

  SystemClock {
    id: clock
    precision: popup.settings.showSeconds ? SystemClock.Seconds : SystemClock.Minutes
  }

  Rectangle {
    anchors.fill: parent
    color: Theme.base
    radius: Theme.cornerRadius
    border { width: Theme.borderWidth; color: Theme.accent }

    Column {
      anchors { fill: parent; margins: 18 }
      spacing: 12

      Row {
        width: parent.width
        Text {
          width: parent.width - 92
          text: Qt.formatDateTime(clock.date, popup.settings.use24Hour ? (popup.settings.showSeconds ? "HH:mm:ss" : "HH:mm") : (popup.settings.showSeconds ? "hh:mm:ss AP" : "hh:mm AP"))
          color: Theme.accent
          font { family: "Iosevka Nerd Font"; pixelSize: Math.round(25 * Theme.fontScale); bold: true }
        }
        ActionButton { text: "‹"; compact: true; onClicked: popup.changeMonth(-1) }
        Item { width: 6; height: 1 }
        ActionButton { text: "›"; compact: true; onClicked: popup.changeMonth(1) }
      }

      Text {
        width: parent.width
        text: Qt.formatDateTime(popup.shownMonth, "MMMM yyyy")
        color: Theme.text
        horizontalAlignment: Text.AlignHCenter
        font { family: "Iosevka Nerd Font"; pixelSize: Math.round(17 * Theme.fontScale); bold: true }
      }

      Row {
        width: parent.width
        spacing: 2

        Column {
          width: 30
          Text {
            width: 30
            height: 24
            text: "KW"
            color: Theme.accent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font { family: "Iosevka Nerd Font"; pixelSize: Math.round(11 * Theme.fontScale); bold: true }
          }
          Repeater {
            model: popup.weeks
            Text {
              required property int modelData
              width: 30
              height: 32
              text: modelData
              color: Theme.mutedText
              horizontalAlignment: Text.AlignHCenter
              verticalAlignment: Text.AlignVCenter
              font { family: "Iosevka Nerd Font"; pixelSize: Math.round(11 * Theme.fontScale) }
            }
          }
        }

        Rectangle {
          width: 1
          height: 216
          color: Theme.surfaceHover
        }

        Grid {
          width: parent.width - 35
          columns: 7
          spacing: 0
          Repeater {
            model: ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
            Text {
              required property string modelData
              width: 41
              height: 24
              text: modelData
              color: Theme.mutedText
              horizontalAlignment: Text.AlignHCenter
              verticalAlignment: Text.AlignVCenter
              font { family: "Iosevka Nerd Font"; pixelSize: Math.round(12 * Theme.fontScale); bold: true }
            }
          }
          Repeater {
            model: popup.days
            Rectangle {
              required property var modelData
              width: 41
              height: 32
              radius: Theme.controlRadius
              color: modelData.today ? Theme.surfaceHover : "transparent"
              border { width: modelData.today ? 1 : 0; color: Theme.accent }
              Text {
                anchors.centerIn: parent
                text: parent.modelData.day
                color: parent.modelData.today ? Theme.accent : (parent.modelData.current ? Theme.text : Theme.mutedText)
                opacity: parent.modelData.current || parent.modelData.today ? 1 : 0.45
                font { family: "Iosevka Nerd Font"; pixelSize: Math.round(14 * Theme.fontScale); bold: parent.modelData.today }
              }
            }
          }
        }
      }

      Row {
        width: parent.width
        spacing: 8
        ActionButton {
          width: (parent.width - 16) / 3
          text: "Heute"
          onClicked: popup.shownMonth = new Date(new Date().getFullYear(), new Date().getMonth(), 1)
        }
        ActionButton {
          width: (parent.width - 16) / 3
          text: "24 Stunden"
          active: popup.settings.use24Hour
          onClicked: popup.settings.use24Hour = !popup.settings.use24Hour
        }
        ActionButton {
          width: (parent.width - 16) / 3
          text: "Sekunden"
          active: popup.settings.showSeconds
          onClicked: popup.settings.showSeconds = !popup.settings.showSeconds
        }
      }
    }
  }
}
