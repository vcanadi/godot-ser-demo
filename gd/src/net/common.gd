
const Dir = preload("../dir.gd")

# Sum data type (constructior enum * variant)
class CliMsg:
  # Sum type constructor
  enum Con { JOIN, LEAVE, MOVE, GET_STATE }
  var con: Con             # Select constructor
  var moveDir: Dir.Dir  # MOVE constructor's payload
                           # Other possible constructors' payloads would be here

  # Sum type interface
  static func join()             -> CliMsg: var m = CliMsg.new(); m.con = Con.JOIN; return m
  static func leave()            -> CliMsg: var m = CliMsg.new(); m.con = Con.LEAVE; return m
  static func move(dir: Dir.Dir) -> CliMsg: var m = CliMsg.new(); m.con = Con.MOVE; m.moveDir = dir; return m
  static func getState()         -> CliMsg: var m = CliMsg.new(); m.con = Con.GET_STATE; return m

  func show() -> String:
    match self.con:
     Con.JOIN: return "JOIN"
     Con.LEAVE: return "LEAVE"
     Con.MOVE: return "MOVE " + Dir.show(self.moveDir)
     Con.GET_STATE: return "GET_STATE"
     _: return "ERR"

  # Byte serialization of CliMsg
  static func ser(m: CliMsg) -> PackedByteArray:
    return var_to_bytes(serArr(m))

  # Byte deserialization of CliMsg
  static func des(bs: PackedByteArray) -> CliMsg:
    return desArr(bytes_to_var(bs))

  # Easier serializaition of CliMSg into intermediate format
  static func serArr(m: CliMsg) -> Array:
    if m.con == Con.MOVE:
      return [m.con, m.moveDir]
    else:
      return [m.con]

  # Easier deserializaition of CliMSg from intermediate format
  static func desArr(arr: Array) -> CliMsg:
    var m: CliMsg = CliMsg.new()
    m.con = arr[0]
    if arr.size() > 1:
      m.moveDir = arr[1]
    return m

#class SrvMsg:
#  var state: State
#
#class State:
#  var clientMap: Dictionary
#
#  static func empty():
#    var st = State.new()
#    st.clientMap = {}
#
#  func ser() -> PackedByteArray:
#     return [0]
#
#  func des()

#func des(bs: PackedByteArray) -> State:
#  match bs:
#      [10,75,148,72, var x] ->



