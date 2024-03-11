
const Dir = preload("../dir.gd")

# Sum data type (constructior enum * variant)
class CliMsg extends Object:
  # Sum type constructor
  enum Con { JOIN, LEAVE, MOVE, GET_STATE }
  var con: Con             # Select constructor
  var moveDir: Dir.Dir  # MOVE constructor's payload
                           # Other possible constructors' payloads would be here

  # CliMsg construcotrs
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

  # Byte (de)serialization of CliMsg
  static func ser(m: CliMsg) -> PackedByteArray: return var_to_bytes(serArr(m))
  static func des(bs: PackedByteArray) -> CliMsg: return desArr(bytes_to_var(bs))

  # Easier serializaition of CliMSg into intermediate format
  static func serArr(m: CliMsg) -> Array:
    if m.con == Con.MOVE: return [m.con, m.moveDir]
    else:                 return [m.con]

  # Easier deserializaition of CliMSg from intermediate format
  static func desArr(arr: Array) -> CliMsg:
    var m: CliMsg = CliMsg.new()
    m.con = arr[0]
    if arr.size() > 1:
      m.moveDir = arr[1]
    return m

class SrvMsg extends Object:
  var model: Model

  # SrvMsg constructor
  func _init(md: Model): model = md
  func eq(sm: SrvMsg): return model.eq(sm.model)

  func serArr() -> Array: return model.serArr()
  static func desArr(arr: Array) -> SrvMsg: return SrvMsg.new(Model.desArr(arr))
  func show(): return model.show()

class Model extends Object:
  var clientMap: Array[CliInfo]
  func _init(cm: Array[CliInfo]): clientMap = cm
  func eq(st: Model):
    if clientMap.size() != st.clientMap.size(): return false
    for i in range(clientMap.size()):
      if clientMap[i].eq(st.clientMap[i]) == false:
        return false
    return true

  func display() -> String:
    var s: String = ""
    for _j in range(Pos.m-1,-1,-1):
      for _i in range(Pos.n):
        s += ("X" if clientMap.any(func(ci): return ci.pos.i == _i and ci.pos.j == _j) else " ") + "|"
      s+="\n"
    return s

  func serArr() -> Array: return clientMap.map(func (ci): return ci.serArr())
  static func desArr(arr: Array) -> Model:
    var newArr: Array[CliInfo] = []
    for ciSer in arr:
      newArr.push_back(CliInfo.desArr(ciSer))
    return Model.new(newArr)
    #return Model.new(arr.map(CliInfo.desArr)) # This should work

  func show(): return clientMap.reduce(func(s, ci): return s + " " + ci.show(), "")

class CliInfo extends Object:
  var sockAddr: SockAddr
  var pos: Pos
  func _init(sa: SockAddr, p: Pos): sockAddr=sa; pos=p
  func eq(ci: CliInfo): return sockAddr.eq(ci.sockAddr) && pos.eq(ci.pos)

  func serArr() -> Array: return [sockAddr.serArr(), pos.serArr()]
  static func desArr(arr: Array) -> CliInfo: return CliInfo.new(SockAddr.desArr(arr[0]), Pos.desArr(arr[1]))
  func show(): return (sockAddr.show() + " " + pos.show())


# Sum type
class SockAddr extends Object:
  enum Con { SockAddrInet } # Model as sum type with 1 constructor to be compatible with backend that contains multiple constructors
  var con: Con             # Select constructor
  var port: int
  var host: int
  static func sockAddrInet(p: int, h: int): var sa = SockAddr.new(); sa.con=0; sa.port=p; sa.host=h; return sa
  func eq(sa: SockAddr):
    return con == Con.SockAddrInet && sa.con == Con.SockAddrInet && port==sa.port && host ==sa.host
  func serArr() -> Array: return [0, port, host]
  static func desArr(arr: Array) -> SockAddr:
    if arr[0] == 0: return sockAddrInet(arr[1],arr[2])
    return SockAddr.new()

  func show(): return (str(port) + " " + str(host))

class Pos extends Object:
  static var n = 10
  static var m = 10
  var i: int
  var j: int

  func _init(_i,_j): i=_i; j=_j;

  func move(di, dj):
    i=fposmod(i+di, n)
    j=fposmod(j+dj, m)

  func moveInDir(mdir: Dir.MDir):
    if mdir.isJust:
      match mdir.dir:
        Dir.Dir.L: self.move(-1,0)
        Dir.Dir.R: self.move(1,0)
        Dir.Dir.U: self.move(0,1)
        Dir.Dir.D: self.move(0,-1)

  func display() -> String:
    var s: String = ""
    for _j in range(m-1,-1,-1):
      for _i in range(n):
        s += ("X" if i == _i and j == _j else " ") + "|"
      s+="\n"
    return s

  func eq(pos: Pos): return i==pos.i && j ==pos.j

  func serArr() -> Array: return [i, j]
  static func desArr(arr: Array) -> Pos: return Pos.new(arr[0], arr[1])

  func show(): return (str(i) + " " + str(j))

static func arr_to_bytes(arr: Array) -> PackedByteArray:  return var_to_bytes(arr)
static func bytes_to_arr(bs: PackedByteArray) -> Array:  return bytes_to_var(bs)

