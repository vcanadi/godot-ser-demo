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
   if shouldBe.eq1(whatIs):
     print("TEST " + title + " SUCCESS")
   else:
     print("TEST " + title + " FAILURE!!")
     print("Expecting: " + shouldBe.show())
     print("Got: " + whatIs.show())

static func run_tests():

  print("SrvMsg (and subtypes) serialization and deserialization tests")
  var c0 = Net.SrvMsg.P_SockAddr_Loc_P.P(Net.SockAddr.SockAddrInet(1,10),Net.Loc.Loc(111,1111))
  var c1 = Net.SrvMsg.P_SockAddr_Loc_P.P(Net.SockAddr.SockAddrInet(2,20),Net.Loc.Loc(222,2222))
  var model: Array[Net.SrvMsg.P_SockAddr_Loc_P] = [c0, c1]
  var srvMsg = Net.SrvMsg.PUT_STATE(model)
  eq_test_simple("SrvMsg.P_SockAddr_Loc_P ser",[[0,1,10],[111,1111]], Net.SrvMsg.P_SockAddr_Loc_P.serToArr(c0))
  eq_test_simple("SrvMsg.P_SockAddr_Loc_P ser",[[0,2,20],[222,2222]], Net.SrvMsg.P_SockAddr_Loc_P.serToArr(c1))
  eq_test_simple("SrvMsg ser",[[[0,1,10],[111,1111]], [[0,2,20],[222,2222]]], Net.SrvMsg.serToArr(srvMsg))
  eq_test("SrvMsg.P_SockAddr_Loc_P ser/des", c0, Net.SrvMsg.P_SockAddr_Loc_P.desFromArr(Net.SrvMsg.P_SockAddr_Loc_P.serToArr(c0)))
  eq_test("SrvMsg.P_SockAddr_Loc_P ser/des", c1, Net.SrvMsg.P_SockAddr_Loc_P.desFromArr(Net.SrvMsg.P_SockAddr_Loc_P.serToArr(c1)))
  eq_test("SrvMsg ser/des", srvMsg, Net.SrvMsg.desFromArr(Net.SrvMsg.serToArr(srvMsg)))
