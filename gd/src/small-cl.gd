extends Node

const Net = preload("net/common.gd")
const Test = preload("net/test.gd")

var model: Array[Net.SrvMsg.P_SockAddr_Pos_P] = []

const HOST: String = "127.0.0.1"
const PORT: int = 5000

var udp := PacketPeerUDP.new()

func _ready():
  Test.run_tests()
  # var xss : Array = [[1,2,3],[4,5,6]]
  # print(xss.map(map(func(x):x)))

  udp.connect_to_host(HOST, PORT)
  udp.put_packet(Net.CliMsg.ser(Net.CliMsg.join()))

func _input(ev):
  if ev is InputEventKey and ev.pressed:
    var mdir: Net.MaybeDir = keyToDir(ev.keycode)
    # model ... .moveInDir(mdir) # TODO. Move  this client in the local model
    if mdir.con == Net.MaybeDir.Con.Just:
      # If there is some movement, send to server
      #print(model.display())      # Render local model on key change
      udp.put_packet(Net.CliMsg.ser(Net.CliMsg.move(mdir.fld_Just_0)))

func _process(dt):
  if udp.get_available_packet_count() > 0:
    var bs = udp.get_packet()
    var srvMsg:  Net.SrvMsg = Net.SrvMsg.desFromArr(Net.bytes_to_arr(bs))
    # print("Srv rsp: %s" % srvMsg.show())
    model = srvMsg.model # Override model on server update
    print(srvMsg.display())


static func keyToDir(key: Key) -> Net.MaybeDir:
  # print(KEY_A)
  match key:
    KEY_A: return Net.MaybeDir.just(Net.Dir.L)
    KEY_D: return Net.MaybeDir.just(Net.Dir.R)
    KEY_W: return Net.MaybeDir.just(Net.Dir.U)
    KEY_S: return Net.MaybeDir.just(Net.Dir.D)
  return Net.MaybeDir.nothing()
