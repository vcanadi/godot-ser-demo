
enum Dir { L,R,U,D}

class MDir:
  var isJust: bool = false
  var dir: Dir
  func show():
    if self.isJust: return ("Just " + str(dir))
    else: return "Nothing"

  static func just(dir: Dir):
    var mdir =  MDir.new()
    mdir.isJust = true
    mdir.dir= dir
    return mdir

  static func nothing():
    return MDir.new()

static func keyToDir(key: Key) -> MDir:
  # print(KEY_A)
  match key:
    KEY_A: return MDir.just(Dir.L)
    KEY_D: return MDir.just(Dir.R)
    KEY_W: return MDir.just(Dir.U)
    KEY_S: return MDir.just(Dir.D)
  return MDir.nothing()

static func dirToMove(dir: Dir) -> Vector2i:
  match dir:
    Dir.L: return Vector2i(-1,0)
    Dir.R: return Vector2i(1,0)
    Dir.U: return Vector2i(0,1)
    Dir.D: return Vector2i(0,-1)
    _:     return Vector2i(0,0)
  return Vector2i(0,0)

static func show(dir: Dir) -> String:
  match dir:
    Dir.L: return "L"
    Dir.R: return "R"
    Dir.U: return "U"
    Dir.D: return "D"
    _:     return ""
