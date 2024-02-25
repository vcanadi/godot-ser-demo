const Net = preload("common.gd")

# Equality test that compares values with == operator
# Values are displayed with 'str' function
static func eq_test_simple(title, shouldBe, whatIs):
   if shouldBe == whatIs:
     print("TEST " + title + " SUCCESS")
   else:
     print("TEST " + title + " FAILURE!!")
     print("Expecting: " + str(shouldBe))
     print("Got: " + str(whatIs))

# Test that compares by object's custom 'eq' function (since godot's == doesn't compare by value)
# It is assumed that objects being tested have show function (for sensible display of the value)
static func eq_test(title, shouldBe, whatIs):
   if shouldBe.eq(whatIs):
     print("TEST " + title + " SUCCESS")
   else:
     print("TEST " + title + " FAILURE!!")
     print("Expecting: " + shouldBe.show())
     print("Got: " + whatIs.show())

static func run_tests():

  print("SrvMsg (and subtypes) serialization and deserialization tests")
  var c0 = Net.CliInfo.new(Net.SockAddr.sockAddrInet(1,10),Net.Model.new(111,1111))
  var c1 = Net.CliInfo.new(Net.SockAddr.sockAddrInet(2,20),Net.Model.new(222,2222))
  var clients: Array[Net.CliInfo] = [c0, c1]
  var state = Net.State.new(clients)
  var srvMsg = Net.SrvMsg.new(state)
  eq_test_simple("CliInfo ser",[[0,1,10],[111,1111]], c0.serArr())
  eq_test_simple("CliInfo ser",[[0,2,20],[222,2222]], c1.serArr())
  eq_test_simple("State ser",[[[0,1,10],[111,1111]], [[0,2,20],[222,2222]]], state.serArr())
  eq_test_simple("SrvMsg ser",[[[0,1,10],[111,1111]], [[0,2,20],[222,2222]]], srvMsg.serArr())
  eq_test("CliInfo ser/des", c0, Net.CliInfo.desArr(c0.serArr()))
  eq_test("CliInfo ser/des", c1, Net.CliInfo.desArr(c1.serArr()))
  eq_test("State ser/des", state, Net.State.desArr(state.serArr()))
  eq_test("SrvMsg ser/des", srvMsg, Net.SrvMsg.desArr(srvMsg.serArr()))
