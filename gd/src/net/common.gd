
const Dir = preload("../dir.gd")

enum CliMsgType { CLI_JOIN, CLI_LEAVE, CLI_MOVE, CLI_GET_STATE }

class CliMsg:
  var cliMsgType: CliMsgType
  var cliDir: Dir.Dir

  static func join():
    var m = CliMsg.new()
    m.cliMsgType = CliMsgType.CLI_JOIN
    return m

  static func leave():
    var m = CliMsg.new()
    m.cliMsgType = CliMsgType.CLI_LEAVE
    return m

  static func move(dir: Dir.Dir):
    var m = CliMsg.new()
    m.cliMsgType = CliMsgType.CLI_MOVE
    m.cliDir = dir
    return m

  func show() -> String:
    match self.cliMsgType:
      CliMsgType.CLI_JOIN: return "CLI_JOIN"
      CliMsgType.CLI_LEAVE: return "CLI_LEAVE"
      CliMsgType.CLI_MOVE:
        match self.cliDir:
          Dir.Dir.L: return "CLI_MOVE L"
          Dir.Dir.R: return "CLI_MOVE R"
          Dir.Dir.U: return "CLI_MOVE U"
          Dir.Dir.D: return "CLI_MOVE D"
          _: return "ERR"
      CliMsgType.CLI_GET_STATE: return "CLI_GET_STATE"
      _: return "ERR"

  func ser() -> PackedByteArray:
    match self.cliMsgType:
      CliMsgType.CLI_JOIN: return [0]
      CliMsgType.CLI_LEAVE: return [1]
      CliMsgType.CLI_MOVE:
        match self.cliDir:
          Dir.Dir.L: return [2,0]
          Dir.Dir.R: return [2,1]
          Dir.Dir.U: return [2,2]
          Dir.Dir.D: return [2,3]
          _: return [-1]
      CliMsgType.CLI_GET_STATE: return [3]
      _: return [-1]


#class State:
#  var clientMap: Dictionary
#
#  static func empty():
#    var st = State.new()
#    st.clientMap = {}
#
#  func ser() -> PackedByteArray:
#     return [0]

#func des(bs: PackedByteArray) -> State:
#  match bs:
#      [10,75,148,72, var x] ->



