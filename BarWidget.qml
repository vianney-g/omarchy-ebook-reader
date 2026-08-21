import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "io.github.dlpwaters.ebook-reader"

  readonly property string helperPath: String(Qt.resolvedUrl("ebook-tool")).replace(/^file:\/\//, "")
  property string lastTitle: ""
  property bool readerOpened: readerLoader.item ? readerLoader.item.opened : false

  function inject() {
    var panel = panelLoader.item
    if (panel) {
      if ("bar" in panel) panel.bar = root.bar
      if ("settings" in panel) panel.settings = root.settings
      if ("anchorItem" in panel) panel.anchorItem = button
      if ("hostWidget" in panel) panel.hostWidget = root
      if ("helperPath" in panel) panel.helperPath = root.helperPath
    }
    var reader = readerLoader.item
    if (reader) {
      if ("helperPath" in reader) reader.helperPath = root.helperPath
      if ("hostWidget" in reader) reader.hostWidget = root
    }
  }

  function open() { if (panelLoader.item) panelLoader.item.open() }
  function close() { if (panelLoader.item) panelLoader.item.close() }
  function toggle() { if (panelLoader.item) panelLoader.item.toggle() }
  function openReader(bookId, title) {
    if (!readerLoader.item) return
    readerLoader.item.openBook(String(bookId || ""), String(title || ""))
  }
  function resume() { openReader("", lastTitle) }
  function refreshSummary() {
    if (summaryProc.running) return
    summaryOutput = ""
    summaryProc.running = true
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onBarChanged: inject()
  onSettingsChanged: inject()
  Component.onCompleted: summaryDelay.start()

  property string summaryOutput: ""

  Timer {
    id: summaryDelay
    interval: 120
    onTriggered: root.refreshSummary()
  }

  Process {
    id: summaryProc
    command: [root.helperPath, "library", "--limit", "1"]
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: root.summaryOutput = text }
    onExited: {
      try {
        var payload = JSON.parse(root.summaryOutput)
        if (payload && payload.books && payload.books.length > 0)
          root.lastTitle = String(payload.books[0].title || "")
      } catch (error) {}
    }
  }

  Loader {
    id: panelLoader
    active: true
    source: Qt.resolvedUrl("Panel.qml")
    visible: false
    onLoaded: { root.inject(); Qt.callLater(root.inject) }
  }

  Loader {
    id: readerLoader
    active: true
    source: Qt.resolvedUrl("Reader.qml")
    visible: false
    onLoaded: { root.inject(); Qt.callLater(root.inject) }
  }

  IpcHandler {
    target: "leaf-reader"
    function open() { root.open() }
    function close() { root.close() }
    function toggle() { root.toggle() }
    function resume() { root.resume() }
    function read(bookId: string) { root.openReader(bookId, "") }
    function status(): string {
      return JSON.stringify({ panelOpen: panelLoader.item ? panelLoader.item.opened : false,
        readerOpen: root.readerOpened, lastTitle: root.lastTitle })
    }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰂺"
    active: root.readerOpened || (panelLoader.item ? panelLoader.item.opened : false)
    useActiveColor: true
    tooltipText: root.lastTitle !== "" ? "Leaf Reader · Continue “" + root.lastTitle + "”" : "Leaf Reader"
    onPressed: function(mouseButton) {
      if (mouseButton === Qt.RightButton) root.resume()
      else root.toggle()
    }
  }
}
