// https://github.com/Quick/Quick

import Quick
import Nimble
import Alter

class IntegrationTests: QuickSpec {
    override func spec() {
        describe("Manual Keyed Alterable") {
            context("decode from json") {
                it("should decode from json string") {
                    let alterable: ManualKeyedAlterable = try! .from(jsonString: stubKeyedJSONString)
                    assertShouldSameAsStub(for: alterable)
                }
                it("should decode from json data") {
                    let alterable: ManualKeyedAlterable = try! .from(jsonData: stubKeyedJSONData)
                    assertShouldSameAsStub(for: alterable)
                }
                it("should decode from json") {
                    let alterable: ManualKeyedAlterable = try! .from(json: stubKeyedJSON)
                    assertShouldSameAsStub(for: alterable)
                }
                it("should assign value using subscript") {
                    var alterable = ManualKeyedAlterable()
                    let randomAlterable: ManualKeyedAlterable = .randomize()
                    assignUsingSubscript(from: randomAlterable, into: &alterable)
                    alterable.address = randomAlterable.address
                    alterable.item = randomAlterable.item
                    expect(alterable).to(equal(randomAlterable))
                }
                it("should get value using subscript") {
                    let alterable: ManualKeyedAlterable = .randomize()
                    let date: Date? = alterable[mappedKey: "birth_date"]
                    expect(alterable.birthDate).to(equal(date))
                }
                it("should get altered value using subscript") {
                    let alterable: ManualKeyedAlterable = .randomize()
                    let dateStr: String? = alterable[mappedKey: "birth_date"]
                    expect(alterable.$birthDate).to(equal(dateStr))
                }
                it("should not get unknown key using subscript") {
                    let alterable: ManualKeyedAlterable = .randomize()
                    let some: String? = alterable[mappedKey: .random()]
                    expect(some).to(beNil())
                }
                it("should not get unknown value using subscript") {
                    let alterable: ManualKeyedAlterable = .randomize()
                    let some: Int? = alterable[mappedKey: "birth_date"]
                    expect(some).to(beNil())
                }
                it("should throw error when string is not right json") {
                    do {
                        _ = try ManualKeyedAlterable.from(jsonString: stubAutoJSONString)
                        fail("should error")
                    } catch {
                        print("throwing error: \(error.localizedDescription)")
                    }
                }
                it("should throw error when data is not right json") {
                    do {
                        _ = try ManualKeyedAlterable.from(jsonData: stubAutoJSONData)
                        fail("should error")
                    } catch {
                        print("throwing error: \(error.localizedDescription)")
                    }
                }
                it("should throw error when json is not right json") {
                    do {
                        _ = try ManualKeyedAlterable.from(json: stubAutoJSON)
                        fail("should error")
                    } catch {
                        print("throwing error: \(error.localizedDescription)")
                    }
                }
            }
            context("encode to json") {
                it("should encode to json string") {
                    let alterable: ManualKeyedAlterable = .randomize()
                    let string = try! alterable.toJSONString()
                    assertKeyedStringJSON(string, shouldSameWith: alterable)
                }
                it("should encode to json data") {
                    let alterable: ManualKeyedAlterable = .randomize()
                    let data = try! alterable.toJSONData()
                    assertKeyedDataJSON(data, shouldSameWith: alterable)
                }
                it("should encode to json") {
                    let alterable: ManualKeyedAlterable = .randomize()
                    let json = try! alterable.toJSON()
                    assertKeyedJSON(json, shouldSameWith: alterable)
                }
            }
            context("non json") {
                it("should throw error when string is not json") {
                    do {
                        _ = try ManualKeyedAlterable.from(jsonString: .random(length: 1000))
                        fail("should error")
                    } catch {
                        print("throwing error: \(error.localizedDescription)")
                    }
                }
                it("should throw error when data is not json") {
                    let data = String.random(length: 1000).data(using: .utf8)!
                    do {
                        _ = try ManualKeyedAlterable.from(jsonData: data)
                        fail("should error")
                    } catch {
                        print("throwing error: \(error.localizedDescription)")
                    }
                }
                it("should throw error when data is not json") {
                    do {
                        _ = try ManualKeyedAlterable.from(json: [.random(): String.random()])
                        fail("should error")
                    } catch {
                        print("throwing error: \(error.localizedDescription)")
                    }
                }
                it("should encode and decode ordered PropertyList") {
                    let alterable: ManualKeyedAlterable = .randomize()
                    let data = try! PropertyListEncoder().encode(alterable)
                    let decoded = try! PropertyListDecoder().decode(ManualKeyedAlterable.self, from: data)
                    expect(alterable).to(equal(decoded))
                }
            }
        }
        describe("Auto Keyed Alterable") {
            context("decode from json") {
                it("should decode from json string") {
                    let alterable: AutoKeyedAlterable = try! .from(jsonString: stubKeyedJSONString)
                    assertShouldSameAsStub(for: alterable)
                }
                it("should decode from json data") {
                    let alterable: AutoKeyedAlterable = try! .from(jsonData: stubKeyedJSONData)
                    assertShouldSameAsStub(for: alterable)
                }
                it("should decode from json") {
                    let alterable: AutoKeyedAlterable = try! .from(json: stubKeyedJSON)
                    assertShouldSameAsStub(for: alterable)
                }
                it("should assign value using subscript") {
                    var alterable = AutoKeyedAlterable()
                    let randomAlterable: AutoKeyedAlterable = .randomize()
                    assignUsingSubscript(from: randomAlterable, into: &alterable)
                    expect(alterable).to(equal(randomAlterable))
                }
                it("should get value using subscript") {
                    let alterable: AutoKeyedAlterable = .randomize()
                    let date: Date? = alterable[mappedKey: "birth_date"]
                    expect(alterable.birthDate).to(equal(date))
                }
                it("should get altered value using subscript") {
                    let alterable: AutoKeyedAlterable = .randomize()
                    let dateStr: String? = alterable[mappedKey: "birth_date"]
                    expect(alterable.$birthDate).to(equal(dateStr))
                }
                it("should not get unknown key using subscript") {
                    let alterable: AutoKeyedAlterable = .randomize()
                    let some: String? = alterable[mappedKey: .random()]
                    expect(some).to(beNil())
                }
                it("should not get unknown value using subscript") {
                    let alterable: AutoKeyedAlterable = .randomize()
                    let some: Int? = alterable[mappedKey: "birth_date"]
                    expect(some).to(beNil())
                }
                it("should throw error when string is not right json") {
                    do {
                        _ = try AutoKeyedAlterable.from(jsonString: stubAutoJSONString)
                        fail("should error")
                    } catch {
                        print("throwing error: \(error.localizedDescription)")
                    }
                }
                it("should throw error when data is not right json") {
                    do {
                        _ = try AutoKeyedAlterable.from(jsonData: stubAutoJSONData)
                        fail("should error")
                    } catch {
                        print("throwing error: \(error.localizedDescription)")
                    }
                }
                it("should throw error when json is not right json") {
                    do {
                        _ = try AutoKeyedAlterable.from(json: stubAutoJSON)
                        fail("should error")
                    } catch {
                        print("throwing error: \(error.localizedDescription)")
                    }
                }
            }
            context("encode to json") {
                it("should encode to json string") {
                    let alterable: AutoKeyedAlterable = .randomize()
                    let string = try! alterable.toJSONString()
                    assertKeyedStringJSON(string, shouldSameWith: alterable)
                }
                it("should encode to json data") {
                    let alterable: AutoKeyedAlterable = .randomize()
                    let data = try! alterable.toJSONData()
                    assertKeyedDataJSON(data, shouldSameWith: alterable)
                }
                it("should encode to json") {
                    let alterable: AutoKeyedAlterable = .randomize()
                    let json = try! alterable.toJSON()
                    assertKeyedJSON(json, shouldSameWith: alterable)
                }
            }
            context("non json") {
                it("should throw error when string is not json") {
                    do {
                        _ = try AutoKeyedAlterable.from(jsonString: .random(length: 1000))
                        fail("should error")
                    } catch {
                        print("throwing error: \(error.localizedDescription)")
                    }
                }
                it("should throw error when data is not json") {
                    let data = String.random(length: 1000).data(using: .utf8)!
                    do {
                        _ = try AutoKeyedAlterable.from(jsonData: data)
                        fail("should error")
                    } catch {
                        print("throwing error: \(error.localizedDescription)")
                    }
                }
                it("should throw error when data is not json") {
                    do {
                        _ = try AutoKeyedAlterable.from(json: [.random(): String.random()])
                        fail("should error")
                    } catch {
                        print("throwing error: \(error.localizedDescription)")
                    }
                }
                it("should encode and decode into PropertyList") {
                    let alterable: AutoKeyedAlterable = .randomize()
                    let data = try! PropertyListEncoder().encode(alterable)
                    let decoded = try! PropertyListDecoder().decode(AutoKeyedAlterable.self, from: data)
                    expect(alterable).to(equal(decoded))
                }
            }
        }
        describe("Auto Alterable") {
            context("decode from json") {
                it("should decode from json string") {
                    let alterable: AutoAlterable = try! .from(jsonString: stubAutoJSONString)
                    assertShouldSameAsStub(for: alterable)
                }
                it("should decode from json data") {
                    let alterable: AutoAlterable = try! .from(jsonData: stubAutoJSONData)
                    assertShouldSameAsStub(for: alterable)
                }
                it("should decode from json") {
                    let alterable: AutoAlterable = try! .from(json: stubAutoJSON)
                    assertShouldSameAsStub(for: alterable)
                }
                it("should assign value using subscript") {
                    var alterable = AutoAlterable()
                    let randomAlterable: AutoAlterable = .randomize()
                    assignUsingSubscript(from: randomAlterable, into: &alterable)
                    expect(alterable).to(equal(randomAlterable))
                }
                it("should get value using subscript") {
                    let alterable: AutoAlterable = .randomize()
                    let date: Date? = alterable[mappedKey: "birthDate"]
                    expect(alterable.birthDate).to(equal(date))
                }
                it("should get altered value using subscript") {
                    let alterable: AutoAlterable = .randomize()
                    let dateStr: String? = alterable[mappedKey: "birthDate"]
                    expect(alterable.$birthDate).to(equal(dateStr))
                }
                it("should not get unknown key using subscript") {
                    let alterable: AutoAlterable = .randomize()
                    let some: String? = alterable[mappedKey: .random()]
                    expect(some).to(beNil())
                }
                it("should not get unknown value using subscript") {
                    let alterable: AutoAlterable = .randomize()
                    let some: Int? = alterable[mappedKey: "birthDate"]
                    expect(some).to(beNil())
                }
                it("should throw error when string is not right json") {
                    do {
                        _ = try AutoAlterable.from(jsonString: stubKeyedJSONString)
                        fail("should error")
                    } catch {
                        print("throwing error: \(error.localizedDescription)")
                    }
                }
                it("should throw error when data is not right json") {
                    do {
                        _ = try AutoAlterable.from(jsonData: stubKeyedJSONData)
                        fail("should error")
                    } catch {
                        print("throwing error: \(error.localizedDescription)")
                    }
                }
                it("should throw error when json is not right json") {
                    do {
                        _ = try AutoAlterable.from(json: stubKeyedJSON)
                        fail("should error")
                    } catch {
                        print("throwing error: \(error.localizedDescription)")
                    }
                }
            }
            context("encode to json") {
                it("should encode to json string") {
                    let alterable: AutoAlterable = .randomize()
                    let string = try! alterable.toJSONString()
                    assertAutoStringJSON(string, shouldSameWith: alterable)
                }
                it("should encode to json data") {
                    let alterable: AutoAlterable = .randomize()
                    let data = try! alterable.toJSONData()
                    assertAutoDataJSON(data, shouldSameWith: alterable)
                }
                it("should encode to json") {
                    let alterable: AutoAlterable = .randomize()
                    let json = try! alterable.toJSON()
                    assertAutoJSON(json, shouldSameWith: alterable)
                }
            }
            context("non json") {
                it("should throw error when string is not json") {
                    do {
                        _ = try AutoAlterable.from(jsonString: .random(length: 1000))
                        fail("should error")
                    } catch {
                        print("throwing error: \(error.localizedDescription)")
                    }
                }
                it("should throw error when data is not json") {
                    let data = String.random(length: 1000).data(using: .utf8)!
                    do {
                        _ = try AutoAlterable.from(jsonData: data)
                        fail("should error")
                    } catch {
                        print("throwing error: \(error.localizedDescription)")
                    }
                }
                it("should throw error when data is not json") {
                    do {
                        _ = try AutoAlterable.from(json: [.random(): String.random()])
                        fail("should error")
                    } catch {
                        print("throwing error: \(error.localizedDescription)")
                    }
                }
                it("should encode and decode ordered PropertyList") {
                    let alterable: AutoAlterable = .randomize()
                    let data = try! PropertyListEncoder().encode(alterable)
                    let decoded = try! PropertyListDecoder().decode(AutoAlterable.self, from: data)
                    expect(alterable).to(equal(decoded))
                }
            }
        }
    }
}

fileprivate func assignUsingSubscript<Object: Alterable & AlterableThing>(from alterable: Object, into destination: inout Object) {
    let map = try! alterable.toJSON()
    for pair in map {
        destination[mappedKey: pair.key] = pair.value
    }
    destination[mappedKey: "item"] = alterable.item
}

fileprivate func assertShouldSameAsStub(for alterable: AlterableThing) {
    expect(alterable.id).to(equal(673876800))
    expect(alterable.userName).to(equal("username"))
    expect(alterable.firstName).to(equal("First"))
    expect(alterable.lastName).to(equal("Last"))
    expect(alterable.birthDate?.timeIntervalSince1970).to(equal(673808400))
    expect(alterable.lastAccessedTime.timeIntervalSince1970).to(equal(1608854400))
    expect(alterable.trackedAccessedTime[0].timeIntervalSince1970).to(equal(1608854400))
    expect(alterable.trackedAccessedTime[1].timeIntervalSince1970).to(equal(1608854000))
    expect(alterable.trackedAccessedTime[2].timeIntervalSince1970).to(equal(1608850400))
    expect(alterable.trackedAccessedTime[3].timeIntervalSince1970).to(equal(1608804400))
    expect(alterable.trackedAccessedTime[4].timeIntervalSince1970).to(equal(1608054400))
    expect(alterable.relatedData).to(equal(Data(base64Encoded: "YWJjMTIzIT8kKiYoKSctPUB+")))
    expect(alterable.item?.itemId).to(equal(10051991))
    expect(alterable.item?.itemPrice).to(equal(10000000))
    expect(alterable.item?.itemName).to(equal("itemname"))
    expect(alterable.address).to(equal("Jakarta"))
}

fileprivate func assertKeyedDataJSON(_ data: Data, shouldSameWith alterable: AlterableThing) {
    guard let string = String(data: data, encoding: .utf8) else {
        fail()
        return
    }
    assertKeyedStringJSON(string, shouldSameWith: alterable)
}

fileprivate func assertAutoDataJSON(_ data: Data, shouldSameWith alterable: AlterableThing) {
    guard let string = String(data: data, encoding: .utf8) else {
        fail()
        return
    }
    assertAutoStringJSON(string, shouldSameWith: alterable)
}

fileprivate func assertKeyedStringJSON(_ jsonString: String, shouldSameWith alterable: AlterableThing) {
    let birthDate = (alterable as? ManualKeyedAlterable)?.$birthDate ?? (alterable as? AutoKeyedAlterable)?.$birthDate
    let lastAccessedTime = (alterable as? ManualKeyedAlterable)?.$lastAccessedTime ?? (alterable as? AutoKeyedAlterable)?.$lastAccessedTime
    let trackedAccessedTime = (alterable as? ManualKeyedAlterable)?.$trackedAccessedTime ?? (alterable as? AutoKeyedAlterable)?.$trackedAccessedTime
    let relatedData = ((alterable as? ManualKeyedAlterable)?.$relatedData ?? (alterable as? AutoKeyedAlterable)?.$relatedData)?.replacingOccurrences(of: "/", with: "\\/")
    var itemString = "null"
    if let item = alterable.item {
        itemString = "{\"itemName\":\"\(item.itemName)\",\"itemPrice\":\(item.itemPrice),\"itemId\":\(item.itemId)}"
        itemString = itemString.replacingOccurrences(of: ".0", with: "")
    }
    expect(jsonString).to(
        equal(
            "{\"address\":\"\(alterable.address)\","
                + "\"birth_date\":\"\(birthDate ?? "null")\","
                + "\"last_name\":\"\(alterable.lastName ?? "null")\","
                + "\"last_accessed_time\":\(lastAccessedTime ?? 0),"
                + "\"related_data\":\"\(relatedData ?? "")\","
                + "\"identifier\":\(alterable.id),"
                + "\"user_name\":\"\(alterable.userName)\","
                + "\"tracked_accessed_time\":\(trackedAccessedTime?.stringify() ?? "[]"),"
                + "\"item\":\(itemString),"
                + "\"first_name\":\"\(alterable.firstName)\"}"
        )
    )
}

fileprivate func assertAutoStringJSON(_ jsonString: String, shouldSameWith alterable: AlterableThing) {
    let birthDate = (alterable as? AutoAlterable)?.$birthDate
    let lastAccessedTime = (alterable as? AutoAlterable)?.$lastAccessedTime
    let trackedAccessedTime = (alterable as? AutoAlterable)?.$trackedAccessedTime
    let relatedData = (alterable as? AutoAlterable)?.$relatedData.replacingOccurrences(of: "/", with: "\\/")
    var itemString = "null"
    if let item = alterable.item {
        itemString = "{\"itemName\":\"\(item.itemName)\",\"itemPrice\":\(item.itemPrice),\"itemId\":\(item.itemId)}"
        itemString = itemString.replacingOccurrences(of: ".0", with: "")
    }
    expect(jsonString).to(
        equal(
            "{\"address\":\"\(alterable.address)\","
                + "\"firstName\":\"\(alterable.firstName)\","
                + "\"id\":\(alterable.id),"
                + "\"userName\":\"\(alterable.userName)\","
                + "\"birthDate\":\"\(birthDate ?? "null")\","
                + "\"trackedAccessedTime\":\(trackedAccessedTime?.stringify() ?? "[]"),"
                + "\"lastAccessedTime\":\(lastAccessedTime ?? 0),"
                + "\"relatedData\":\"\(relatedData ?? "")\","
                + "\"item\":\(itemString),"
                + "\"lastName\":\"\(alterable.lastName ?? "null")\"}"
        )
    )
}

fileprivate func assertKeyedJSON(_ json: [String: Any], shouldSameWith alterable: AlterableThing) {
    let birthDate = (alterable as? ManualKeyedAlterable)?.$birthDate ?? (alterable as? AutoKeyedAlterable)?.$birthDate
    let lastAccessedTime = (alterable as? ManualKeyedAlterable)?.$lastAccessedTime ?? (alterable as? AutoKeyedAlterable)?.$lastAccessedTime
    let trackedAccessedTime = (alterable as? ManualKeyedAlterable)?.$trackedAccessedTime ?? (alterable as? AutoKeyedAlterable)?.$trackedAccessedTime
    let relatedData = ((alterable as? ManualKeyedAlterable)?.$relatedData ?? (alterable as? AutoKeyedAlterable)?.$relatedData)
    expect(json.count).to(equal(10))
    expect(json["identifier"] as? Int).to(equal(alterable.id))
    expect(json["user_name"] as? String).to(equal(alterable.userName))
    expect(json["first_name"] as? String).to(equal(alterable.firstName))
    expect(json["last_name"] as? String).to(equal(alterable.lastName))
    expect(json["birth_date"] as? String).to(equal(birthDate))
    expect(json["last_accessed_time"] as? Int64).to(equal(lastAccessedTime))
    expect(json["related_data"] as? String).to(equal(relatedData))
    expect(json["address"] as? String).to(equal(alterable.address))
    guard let array = json["tracked_accessed_time"] as? [Int64] else {
        fail()
        return
    }
    expect(array.count).to(equal(trackedAccessedTime?.count))
    for time in array {
        expect(trackedAccessedTime?.contains(time) ?? false).to(beTrue())
    }
    guard let jsonItem = json["item"] as? [String: Any] else {
        expect(alterable.item).to(beNil())
        expect(json["item"]).to(beNil())
        return
    }
    expect(jsonItem["itemId"] as? Int).to(equal(alterable.item?.itemId))
    expect(jsonItem["itemName"] as? String).to(equal(alterable.item?.itemName))
    expect(jsonItem["itemPrice"] as? Double).to(equal(alterable.item?.itemPrice))
}

fileprivate func assertAutoJSON(_ json: [String: Any], shouldSameWith alterable: AlterableThing) {
    let birthDate = (alterable as? AutoAlterable)?.$birthDate
    let lastAccessedTime = (alterable as? AutoAlterable)?.$lastAccessedTime
    let trackedAccessedTime = (alterable as? AutoAlterable)?.$trackedAccessedTime
    let relatedData = (alterable as? AutoAlterable)?.$relatedData
    expect(json.count).to(equal(10))
    expect(json["id"] as? Int).to(equal(alterable.id))
    expect(json["userName"] as? String).to(equal(alterable.userName))
    expect(json["firstName"] as? String).to(equal(alterable.firstName))
    expect(json["lastName"] as? String).to(equal(alterable.lastName))
    expect(json["birthDate"] as? String).to(equal(birthDate))
    expect(json["lastAccessedTime"] as? Int64).to(equal(lastAccessedTime))
    expect(json["relatedData"] as? String).to(equal(relatedData))
    expect(json["address"] as? String).to(equal(alterable.address))
    guard let array = json["trackedAccessedTime"] as? [Int64] else {
        fail()
        return
    }
    expect(array.count).to(equal(trackedAccessedTime?.count))
    for time in array {
        expect(trackedAccessedTime?.contains(time) ?? false).to(beTrue())
    }
    guard let jsonItem = json["item"] as? [String: Any] else {
        expect(alterable.item).to(beNil())
        expect(json["item"]).to(beNil())
        return
    }
    expect(jsonItem["itemId"] as? Int).to(equal(alterable.item?.itemId))
    expect(jsonItem["itemName"] as? String).to(equal(alterable.item?.itemName))
    expect(jsonItem["itemPrice"] as? Double).to(equal(alterable.item?.itemPrice))
}
