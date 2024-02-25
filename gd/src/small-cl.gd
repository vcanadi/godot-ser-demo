extends Node

const Net = preload("net/common.gd")
const Test = preload("net/test.gd")
const Dir = preload("dir.gd")

var state: Net.State = Net.State.new([])

const HOST: String = "127.0.0.1"
const PORT: int = 5000

var udp := PacketPeerUDP.new()

func _ready():
  Test.run_tests()

  udp.connect_to_host(HOST, PORT)
  udp.put_packet(Net.CliMsg.ser(Net.CliMsg.join()))

func _input(ev):
  if ev is InputEventKey and ev.pressed:
    var mdir: Dir.MDir = Dir.keyToDir(ev.keycode)
    # state ... .moveInDir(mdir) # TODO. Move  this client in the local state
    if mdir.isJust:
      # If there is some movement, send to server
      #print(state.display())      # Render local state on key change
      udp.put_packet(Net.CliMsg.ser(Net.CliMsg.move(mdir.dir)))

func _process(dt):
  if udp.get_available_packet_count() > 0:
    var bs = udp.get_packet()
    var srvMsg: Net.SrvMsg = Net.SrvMsg.desArr(Net.bytes_to_arr(bs))
    # print("Srv rsp: %s" % srvMsg.show())
    state = srvMsg.state # Override state on server update
    print(state.display())
