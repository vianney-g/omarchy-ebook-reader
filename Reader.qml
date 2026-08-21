import QtQuick
import QtQuick.Controls as QQC
import QtQuick.Window
import QtWebEngine
import Quickshell
import Quickshell.Io
import qs.Commons

Item {
  id: root

  property string helperPath: ""
  property var hostWidget: null
  property bool opened: readerWindow.visible
  property bool starting: false
  property string requestedBookId: ""
  property string requestedTitle: ""
  property string startOutput: ""
  property string errorText: ""
  property string currentUrl: "about:blank"

  function openBook(bookId, title) {
    requestedBookId = String(bookId || "")
    requestedTitle = String(title || "")
    errorText = ""
    readerWindow.visible = true
    readerWindow.raise()
    startOutput = ""
    starting = true
    if (!startProc.running) startProc.running = true
  }

  function closeReader() {
    readerWindow.visible = false
    currentUrl = "about:blank"
    webView.url = currentUrl
    if (hostWidget && typeof hostWidget.refreshSummary === "function") hostWidget.refreshSummary()
  }

  function finishStart(exitCode) {
    starting = false
    var payload = null
    try { payload = JSON.parse(startOutput) } catch (error) {}
    if (exitCode !== 0 || !payload || !payload.ok) {
      errorText = payload && payload.error ? String(payload.error) : "The local reader service could not start."
      return
    }
    var suffix = requestedBookId !== "" ? "?book=" + encodeURIComponent(requestedBookId) : ""
    currentUrl = String(payload.url || "http://127.0.0.1:4189/") + suffix
    webView.url = currentUrl
    webView.forceActiveFocus()
  }

  Process {
    id: startProc
    command: [root.helperPath, "start"]
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: root.startOutput = text }
    stderr: StdioCollector { waitForEnd: true }
    onExited: function(exitCode) { root.finishStart(exitCode) }
  }

  FloatingWindow {
    id: readerWindow
    visible: false
    title: root.requestedTitle !== "" ? root.requestedTitle + " — Leaf Reader" : "Leaf Reader"
    color: "#171717"
    implicitWidth: 1440
    implicitHeight: 900
    minimumSize: Qt.size(720, 540)

    onVisibleChanged: {
      if (visible) webView.forceActiveFocus()
    }

    Shortcut {
      sequence: "Ctrl+Shift+Q"
      context: Qt.ApplicationShortcut
      onActivated: root.closeReader()
    }

    Rectangle {
      id: titleBar
      anchors { top: parent.top; left: parent.left; right: parent.right }
      height: 42
      color: "#171717"
      z: 5

      Row {
        anchors { left: parent.left; leftMargin: 15; verticalCenter: parent.verticalCenter }
        spacing: 9

        Text {
          text: "󰂺"
          color: "#d8a06a"
          font.family: Style.font.family
          font.pixelSize: 17
        }

        Text {
          text: root.requestedTitle !== "" ? root.requestedTitle : "Leaf Reader"
          color: "#e8e5df"
          font.family: Style.font.family
          font.pixelSize: 13
          font.bold: true
          width: Math.min(implicitWidth, readerWindow.width - 250)
          elide: Text.ElideRight
        }
      }

      Row {
        anchors { right: parent.right; rightMargin: 7; verticalCenter: parent.verticalCenter }
        spacing: 2

        component WindowButton: Rectangle {
          property string glyph: ""
          property string tip: ""
          signal clicked()
          width: 34; height: 30; radius: 8
          color: hover.hovered ? "#2b2b2b" : "transparent"
          HoverHandler { id: hover }
          QQC.ToolTip.visible: hover.hovered
          QQC.ToolTip.text: tip
          Text { anchors.centerIn: parent; text: parent.glyph; color: "#d1cec8"; font.pixelSize: 14 }
          TapHandler { onTapped: parent.clicked() }
        }

        WindowButton {
          glyph: "↻"
          tip: "Reload book"
          onClicked: webView.reload()
        }

        WindowButton {
          glyph: readerWindow.visibility === Window.FullScreen ? "❐" : "□"
          tip: readerWindow.visibility === Window.FullScreen ? "Leave fullscreen" : "Fullscreen"
          onClicked: readerWindow.visibility = readerWindow.visibility === Window.FullScreen ? Window.Windowed : Window.FullScreen
        }

        WindowButton {
          glyph: "×"
          tip: "Close reader · Ctrl+Shift+Q"
          onClicked: root.closeReader()
        }
      }

      Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 1
        color: "#2b2b2b"
      }
    }

    WebEngineView {
      id: webView
      anchors { top: titleBar.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
      url: root.currentUrl
      backgroundColor: "#fffdf8"
      focus: true

      settings.javascriptEnabled: true
      settings.localContentCanAccessRemoteUrls: false
      settings.localContentCanAccessFileUrls: false
      settings.javascriptCanOpenWindows: false
      settings.fullScreenSupportEnabled: false
      settings.pdfViewerEnabled: true

      onLoadingChanged: function(info) {
        if (info.status === WebEngineView.LoadFailedStatus)
          root.errorText = info.errorString || "The reader page did not load."
        else if (info.status === WebEngineView.LoadSucceededStatus)
          root.errorText = ""
      }
    }

    Rectangle {
      visible: root.starting || root.errorText !== ""
      anchors { top: titleBar.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
      color: "#fffdf8"
      z: 4

      Column {
        anchors.centerIn: parent
        width: Math.min(500, parent.width - 60)
        spacing: 12

        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          text: "❧"
          color: "#a66c3f"
          font.family: "Georgia"
          font.pixelSize: 54
        }

        Text {
          width: parent.width
          text: root.errorText !== "" ? "This book could not be opened" : "Preparing your reading space…"
          color: "#28231f"
          font.family: "Georgia"
          font.pixelSize: 24
          font.bold: true
          horizontalAlignment: Text.AlignHCenter
          wrapMode: Text.WordWrap
        }

        Text {
          visible: root.errorText !== ""
          width: parent.width
          text: root.errorText
          color: "#7b7169"
          font.family: Style.font.family
          font.pixelSize: 13
          horizontalAlignment: Text.AlignHCenter
          wrapMode: Text.WordWrap
        }
      }
    }
  }
}
