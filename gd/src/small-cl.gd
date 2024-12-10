extends CanvasItem

const Net = preload("net/common.gd")
const Test = preload("net/test.gd")

var model # : Array[Net.SrvMsg.P_SockAddr_Loc_P] = []

const HOST: String = "127.0.0.1"
const PORT: int = 5000

var udp := PacketPeerUDP.new()

func _ready():
  Test.run_tests()

  udp.connect_to_host(HOST, PORT)
  udp.put_packet(Net.CliMsg.ser(Net.CliMsg.JOIN()))

func _input(ev):
  # If there is some movement, send to server
  if ev is InputEventKey and ev.pressed:
    var mdir: Net.MaybeDir = keyToDir(ev.keycode)
    if mdir.con == Net.MaybeDir.Con.Just:
      udp.put_packet(Net.CliMsg.ser(Net.CliMsg.MOVE(mdir.fld_Just_0)))

func _process(dt):
  # If there is some incoming packet from server, process its message
  if udp.get_available_packet_count() > 0:
    var srvMsg:  Net.SrvMsg = Net.SrvMsg.des(udp.get_packet())
    print(srvMsg.display())
    model = srvMsg.model # Override model on server update
    # queue_redraw()

# Interpret key press as a possible movement direction
static func keyToDir(key: Key) -> Net.MaybeDir:
  match key:
    KEY_A: return Net.MaybeDir.Just(Net.Dir.L)
    KEY_D: return Net.MaybeDir.Just(Net.Dir.R)
    KEY_W: return Net.MaybeDir.Just(Net.Dir.U)
    KEY_S: return Net.MaybeDir.Just(Net.Dir.D)
  return Net.MaybeDir.Nothing()

# Visualization of the model
# func _draw():
#   var scale = 50
#   for _j in range(Net.Loc.m):
#     for _i in range(Net.Loc.n):
#       draw_square(scale, Vector2(_i,_j), model.any(func(ci): return ci.snd.i == _i and ci.snd.j == _j))


# # Low-level drawing
# func draw_square(scale: float, v_ :Vector2, chr : bool):
#   var off = Vector2(scale/2,scale/2)
#   var w = 0.95 * scale/2
#   var v = Vector2(v_.x, Net.Loc.n-1-v_.y) * scale
#   draw_polyline([ off + v + Vector2(-w,-w) \
#                 , off + v + Vector2(-w, w) \
#                 , off + v + Vector2( w, w) \
#                 , off + v + Vector2( w,-w) \
#                 , off + v + Vector2(-w,-w) \
#                 ], Color.WHITE if chr else Color.BLACK, 1)
