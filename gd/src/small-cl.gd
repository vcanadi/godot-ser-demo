extends CanvasItem

const Net = preload("net/common.gd")
const Test = preload("net/test.gd")

var model: Array[Net.SrvMsg.P_SockAddr_Loc_P] = []

const HOST: String = "127.0.0.1"
const PORT: int = 5000

var udp := PacketPeerUDP.new()

func _ready():
  Test.run_tests()
  # var xss : Array = [[1,2,3],[4,5,6]]
  # print(xss.map(map(func(x):x)))

  udp.connect_to_host(HOST, PORT)
  udp.put_packet(Net.CliMsg.ser(Net.CliMsg.JOIN()))

func _input(ev):
  if ev is InputEventKey and ev.pressed:
    var mdir: Net.MaybeDir = keyToDir(ev.keycode)
    # model ... .moveInDir(mdir) # TODO. Move  this client in the local model
    if mdir.con == Net.MaybeDir.Con.Just:
      # If there is some movement, send to server
      udp.put_packet(Net.CliMsg.ser(Net.CliMsg.MOVE(mdir.fld_Just_0)))

func _process(dt):
  if udp.get_available_packet_count() > 0:
    var bs = udp.get_packet()
    var srvMsg:  Net.SrvMsg = Net.SrvMsg.des(bs)
    # print("Srv rsp: %s" % srvMsg.show())
    print(srvMsg.display())
    model = srvMsg.model # Override model on server update
    queue_redraw()


static func keyToDir(key: Key) -> Net.MaybeDir:
  # print(KEY_A)
  match key:
    KEY_A: return Net.MaybeDir.Just(Net.Dir.L)
    KEY_D: return Net.MaybeDir.Just(Net.Dir.R)
    KEY_W: return Net.MaybeDir.Just(Net.Dir.U)
    KEY_S: return Net.MaybeDir.Just(Net.Dir.D)
  return Net.MaybeDir.Nothing()

# Visualization of the model
func _draw():
  var scale = 50
  for _j in range(Net.Loc.m):
    for _i in range(Net.Loc.n):
      draw_square(scale, Vector2(_i,_j), model.any(func(ci): return ci.snd._mX == _i and ci.snd._mY == _j))


# Low-level drawing
func draw_square(scale: float, v_ :Vector2, chr : bool):
  var off = Vector2(scale/2,scale/2)
  var w = 0.95 * scale/2
  var v = Vector2(v_.x, Net.Loc.n-1-v_.y) * scale
  draw_polyline([ off + v + Vector2(-w,-w) \
                , off + v + Vector2(-w, w) \
                , off + v + Vector2( w, w) \
                , off + v + Vector2( w,-w) \
                , off + v + Vector2(-w,-w) \
                ], Color.WHITE if chr else Color.BLACK, 1)
