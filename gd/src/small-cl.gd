extends Node

const Net = preload("net/common.gd")
const Dir = preload("dir.gd")
const M = preload("model.gd")


var model: M.Model = M.Model.new(0,0)

const HOST: String = "127.0.0.1"
const PORT: int = 5000

var udp := PacketPeerUDP.new()

var position: Vector2i = Vector2i(5,0)

class A extends Object:
  var x: bool = false

func _ready():
  udp.connect_to_host(HOST, PORT)
  var msg: Net.CliMsg = Net.CliMsg.join()
  udp.put_packet(msg.ser())
  #print(desDictionary([10,75,148,72,1,0,0,0]).show())

  # var x: float = 1
  # var arr : PackedByteArray = [97,97,0,0,0]
  # var s: String = "a" # arr.get_string_from_utf8()
  var m = [14, "a"]
  # var d: Dir.Dir = Dir.Dir.D
  #var a = A.new()
  print(m)

  print(var_to_bytes(m))
  #var res: int = bytes_to_var(PackedByteArray([2,0,0,0,255,255,255,255,255,255,255,255]))
  #print(res)

var cliMgs: Net.CliMsg

func _input(ev):
  if ev is InputEventKey and ev.pressed:
    var mdir: Dir.MDir = Dir.keyToDir(ev.keycode)
    model.moveInDir(mdir)
    #print(model.show())
    if mdir.isJust:
      #print(Net.CliMsg.move(mdir.dir).show())
      udp.put_packet(Net.CliMsg.move(mdir.dir).ser())

func _process(dt):
  if udp.get_available_packet_count() > 0:
    var ba = udp.get_packet()
    #print("Srv rsp: %s" % ba)


class MDictionary:
  var val: Dictionary
  var isJust: bool = false
  func show():
    if self.isJust: return ("Just " + str(val))
    else: return "Nothing"
  static func just(val): var mval = new(); mval.isJust = true; mval.val= val; return mval
  static func nothing(): return new()

func desDictionary(bs: PackedByteArray) ->  MDictionary:
  if bs.slice(0,4) == PackedByteArray([10,75,148,72]):
    print(bs.slice(4,12))
    var n = bs.decode_u8(5)
    print("n:" + str(n))
    return MDictionary.just({})
  else: return MDictionary.nothing()





