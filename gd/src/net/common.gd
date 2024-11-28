
enum Dir { L,R,U,D}


class MaybeDir extends Object:

  enum Con { Nothing, Just }

  var con: Con

  var fld_Just_0: Dir

  #  Equality check of two MaybeDir
  static func eq(a: MaybeDir, b: MaybeDir) -> bool:
    return a.con==b.con && (a.con==Con.Nothing || a.con==Con.Just && a.fld_Just_0==b.fld_Just_0)


  #  Non-static equality check of two MaybeDir
  func eq1(b: MaybeDir) -> bool:
    return MaybeDir.eq(self, b)


  # Constructor function for sum constructor Nothing
  static func nothing() -> MaybeDir:
    var ret: MaybeDir = MaybeDir.new()
    ret.con = Con.Nothing
    return ret


  # Constructor function for sum constructor Just
  static func just(fld_Just_0: Dir) -> MaybeDir:
    var ret: MaybeDir = MaybeDir.new()
    ret.con = Con.Just
    ret.fld_Just_0 = fld_Just_0
    return ret


  # String representation of type
  func show() -> String:
    match self.con:
      Con.Nothing:   return "Nothing"

      Con.Just:   return "Just"

      _:  return ""



  # Deserialize from binary
  static func des(this: PackedByteArray) -> MaybeDir:
    return desFromArr(bytes_to_var(this))


  # Deserialize from array
  static func desFromArr(arr: Array[Variant]) -> MaybeDir:
    var ret: MaybeDir = MaybeDir.new()
    ret.con = arr[0]
    match ret.con:
      Con.Just:   ret.fld_Just_0 = arr[1]


    return ret


  # Serialize to binary
  static func ser(this: MaybeDir) -> PackedByteArray:
    return var_to_bytes(serToArr(this))


  # Serialize to array
  static func serToArr(this: MaybeDir) -> Array[Variant]:
    match this.con:
      Con.Nothing:   return [ Con.Nothing ]

      Con.Just:   return [ Con.Just, this.fld_Just_0 ]

      _:  return []



class CliMsg extends Object:

  enum Con { JOIN, LEAVE, MOVE, GET_STATE }

  var con: Con

  var fld_MOVE_0: Dir

  #  Equality check of two CliMsg
  static func eq(a: CliMsg, b: CliMsg) -> bool:
    return a.con==b.con && (a.con==Con.JOIN || a.con==Con.LEAVE || a.con==Con.MOVE && a.fld_MOVE_0==b.fld_MOVE_0 || a.con==Con.GET_STATE)


  #  Non-static equality check of two CliMsg
  func eq1(b: CliMsg) -> bool:
    return CliMsg.eq(self, b)


  # Constructor function for sum constructor JOIN
  static func join() -> CliMsg:
    var ret: CliMsg = CliMsg.new()
    ret.con = Con.JOIN
    return ret


  # Constructor function for sum constructor LEAVE
  static func leave() -> CliMsg:
    var ret: CliMsg = CliMsg.new()
    ret.con = Con.LEAVE
    return ret

  # Constructor function for sum constructor MOVE
  static func move(fld_MOVE_0: Dir) -> CliMsg:
    var ret: CliMsg = CliMsg.new()
    ret.con = Con.MOVE
    ret.fld_MOVE_0 = fld_MOVE_0
    return ret


  # Constructor function for sum constructor GET_STATE
  static func get_state() -> CliMsg:
    var ret: CliMsg = CliMsg.new()
    ret.con = Con.GET_STATE
    return ret


  # String representation of type
  func show() -> String:
    match self.con:
      Con.JOIN:   return "JOIN"
      Con.LEAVE:   return "LEAVE"
      Con.MOVE:   return "MOVE"
      Con.GET_STATE:   return "GET_STATE"
      _:  return ""



  # Deserialize from binary
  static func des(this: PackedByteArray) -> CliMsg:
    return desFromArr(bytes_to_var(this))


  # Deserialize from array
  static func desFromArr(arr: Array[Variant]) -> CliMsg:
    var ret: CliMsg = CliMsg.new()
    ret.con = arr[0]
    match ret.con:
      Con.MOVE:   ret.fld_MOVE_0 = arr[1]


    return ret


  # Serialize to binary
  static func ser(this: CliMsg) -> PackedByteArray:
    return var_to_bytes(serToArr(this))


  # Serialize to array
  static func serToArr(this: CliMsg) -> Array[Variant]:
    match this.con:
      Con.JOIN:   return [ Con.JOIN ]

      Con.LEAVE:   return [ Con.LEAVE ]

      Con.MOVE:   return [ Con.MOVE, this.fld_MOVE_0 ]

      Con.GET_STATE:   return [ Con.GET_STATE ]

      _:  return []


class SrvMsg extends Object:

  class P_SockAddr_Pos_P extends Object:

    var fst: SockAddr
    var snd: Loc

    #  Equality check of two P_SockAddr_Pos_P
    static func eq(a: P_SockAddr_Pos_P, b: P_SockAddr_Pos_P) -> bool:
      return SockAddr.eq(a.fst, b.fst) && Loc.eq(a.snd, b.snd)


    #  Non-static equality check of two P_SockAddr_Pos_P
    func eq1(b: P_SockAddr_Pos_P) -> bool:
      return P_SockAddr_Pos_P.eq(self, b)


    # Constructor function for sum constructor P
    static func p(fst: SockAddr, snd: Loc) -> P_SockAddr_Pos_P:
      var ret: P_SockAddr_Pos_P = P_SockAddr_Pos_P.new()
      ret.fst = fst
      ret.snd = snd
      return ret


    # String representation of type
    func show() -> String:
      return "P"


    # Deserialize from array
    static func desFromArr(arr: Array[Variant]) -> P_SockAddr_Pos_P:
      var ret: P_SockAddr_Pos_P = P_SockAddr_Pos_P.new()
      ret.fst = SockAddr.desFromArr(arr[0])
      ret.snd = Loc.desFromArr(arr[1])
      return ret


    # Serialize to array
    static func serToArr(this: P_SockAddr_Pos_P) -> Array[Variant]:
      return [ SockAddr.serToArr(this.fst), Loc.serToArr(this.snd) ]

  var model: Array[P_SockAddr_Pos_P]

  #  Equality check of two SrvMsg
  static func eq(a: SrvMsg, b: SrvMsg) -> bool:
    return a.model.reduce(func(acc,x): return [ acc[0] && P_SockAddr_Pos_P.eq(x, b.model[acc[1]]), acc[1] + 1 ] , [true, 0])[0]


  #  Non-static equality check of two SrvMsg
  func eq1(b: SrvMsg) -> bool:
    return SrvMsg.eq(self, b)


  # Constructor function for sum constructor PUT_STATE
  static func put_state(model: Array[P_SockAddr_Pos_P]) -> SrvMsg:
    var ret: SrvMsg = SrvMsg.new()
    ret.model = model
    return ret


  # String representation of type
  func show() -> String:
    return "PUT_STATE"


  # Deserialize from array
  static func desFromArr(arr: Array[Variant]) -> SrvMsg:
    var ret: SrvMsg = SrvMsg.new()
    ret.model.assign(arr.map(P_SockAddr_Pos_P.desFromArr))
    return ret


  # Serialize to array
  static func serToArr(this: SrvMsg) -> Array[Variant]:
    return this.model.map(func(x): return P_SockAddr_Pos_P.serToArr(x))

  func display() -> String:
    var s: String = ""
    for _j in range(Loc.m-1,-1,-1):
      for _i in range(Loc.n):
        s += ("X" if model.any(func(ci): return ci.snd.i == _i and ci.snd.j == _j) else " ") + "|"
      s+="\n"
    return s




# Sum type
class SockAddr extends Object:
  enum Con { SockAddrInet } # Model as sum type with 1 constructor to be compatible with backend that contains multiple constructors
  var con: Con             # Select constructor
  var port: int
  var host: int
  static func sockAddrInet(p: int, h: int): var sa = SockAddr.new(); sa.con=0; sa.port=p; sa.host=h; return sa
  func eq1(b: SockAddr) -> bool: return SockAddr.eq(self, b)
  static func eq(a: SockAddr, b: SockAddr):
    return a.con == Con.SockAddrInet && b.con == Con.SockAddrInet && a.port==b.port && a.host ==b.host
  static func serToArr(this: SockAddr) -> Array: return [0, this.port, this.host]
  static func desFromArr(arr: Array) -> SockAddr:
    if arr[0] == 0: return sockAddrInet(arr[1],arr[2])
    return SockAddr.new()

  func show(): return (str(port) + " " + str(host))

class Loc extends Object:
  static var n = 10
  static var m = 10
  var i: int
  var j: int
  var extra: int

  func _init(_i,_j): i=_i; j=_j; extra=0;

  func move(di, dj):
    i=fposmod(i+di, n)
    j=fposmod(j+dj, m)

  func moveInDir(mdir: MaybeDir):
    if mdir.con == MaybeDir.Con.Just:
      match mdir.fld_Just_0:
        Dir.L: self.move(-1,0)
        Dir.R: self.move(1,0)
        Dir.U: self.move(0,1)
        Dir.D: self.move(0,-1)

  func display() -> String:
    var s: String = ""
    for _j in range(m-1,-1,-1):
      for _i in range(n):
        s += ("X" if i == _i and j == _j else " ") + "|"
      s+="\n"
    return s

  func eq1(b: Loc) -> bool: return Loc.eq(self, b)
  static func eq(a: Loc, b: Loc): return a.i==b.i && a.j ==b.j

  static func serToArr(this: Loc) -> Array: return [this.i, this.j]
  static func desFromArr(arr: Array) -> Loc: return Loc.new(arr[0], arr[1])

  func show(): return (str(i) + " " + str(j))

static func arr_to_bytes(arr: Array) -> PackedByteArray:  return var_to_bytes(arr)
static func bytes_to_arr(bs: PackedByteArray) -> Array:  return bytes_to_var(bs)
