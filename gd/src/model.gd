
const Dir = preload("dir.gd")

class Model:
  static var n = 10
  static var m = 10
  var i: int
  var j: int

  func _init(i,j):
    self.i=i
    self.j=m - 1 -j

  func move(di, dj):
    i=fposmod(i+di, n)
    j=fposmod(j+dj, m)

  func moveInDir(mdir: Dir.MDir):
    print("moveInDir"+mdir.show())
    if mdir.isJust:
      match mdir.dir:
        Dir.Dir.L: self.move(-1,0)
        Dir.Dir.R: self.move(1,0)
        Dir.Dir.U: self.move(0,1)
        Dir.Dir.D: self.move(0,-1)

  func show() -> String:
    var s: String = ""
    for j in range(m):
      for i in range(n):
        s += ("X" if self.i == i and self.j == (m - 1 - j) else " ") + "|"
      s+="\n"
    return s

