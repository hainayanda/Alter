# Alter
Alter is framework to make mapping Codable property and key easier.

With Alter, you don't need to create CodingKey to manually mapping.

Alter using propertyWrapper and reflection to achive manual mapping.

![build](https://github.com/nayanda1/Alter/workflows/build/badge.svg)
[![Version](https://img.shields.io/cocoapods/v/Alter.svg?style=flat)](https://cocoapods.org/pods/Alter)
[![License](https://img.shields.io/cocoapods/l/Alter.svg?style=flat)](https://cocoapods.org/pods/Alter)
[![Platform](https://img.shields.io/cocoapods/p/Alter.svg?style=flat)](https://cocoapods.org/pods/Alter)

## Requirements

- Swift 5.0 or higher
- iOS 9.3 or higher

## Installation

Alter is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Alter'
```

## Author

Nayanda Haberty, nayanda1@outlook.com

## License

Alter is available under the MIT license. See the LICENSE file for more info.

## Usage

### Basic Usage

For example, if you need to map User JSON to Swift Object,  you just need to create User class/struct and implement `Alterable protocol` and then mark all the property you need to map to JSON with `@Mapped attributes.`

```swift
struct User: Alterable {
    
    @Mapped
    var name: String = ""
    
    @Mapped
    var userName: String = ""
    
    @Mapped
    var age: Int = 0
}
```

and then you can parse JSON to User Swift Object or vice versa like this

```swift
let user: User = getUserFromSomewhere()

//to JSON
let jsonObject: [String: Any] = try! user.toJSON()
let jsonString: String = try! user.toJSONString()
let jsonData: Data = try! user.toJSONData()

//from JSON
let userFromJSON: User = try! .from(json: jsonObject)
let userFromString: User = try! .from(jsonString: jsonString)
let userFromData: User = try! .from(jsonData: jsonData)
```

The `Alterable` actually just a protocol that conform `Codable`. The only extendable function from Codable is that the Alterable will be use reflection to get all Mapped attributes and using it to do two way mapping.

Since `Alterable` conform `Codable`, you could always do decoder or encoder just like Codable

```swift
let user: User = getUserFromSomewhere()
let propertyListData = try! PropertyListEncoder().encode(alterable)
let decodedPropertyList = try! PropertyListDecoder().decode(User.self, from: propertyListData)

let jsonData = try! JSONEncoder().encode(alterable)
let decodedJsonData = try! JSONDecoder().decode(User.self, from: propertyListData)
```

The real power of Alterable is the mapping feature. If the property name of Decoded data is different with property in Swift object, then you can pass the name of that property at the attribute instead of creating CodingKey enumeration.

```swift
struct User: Alterable {
    
    @Mapped(key: "full_name")
    var fullName: String = ""
    
    @Mapped(key: "user_name")
    var userName: String = ""
    
    @Mapped
    var age: Int = 0
}
```

You could always do decode and encode manually by implement `init(from decoder: Decoder) throws` and `func encode(to encoder: Encoder) throws`. `Alterable` have some extensions to help you decode and encode manually

```swift
struct User: Alterable {
    
    @Mapped(key: "full_name")
    var fullName: String = ""
    
    @Mapped(key: "user_name")
    var userName: String = ""
    
    @Mapped
    var age: Int = 0
    
    var image: UIImage? = nil
    
    required init() {}
    
    init(from decoder: Decoder) throws {
        self.init()
        // this will automatically decode all Mapped properties and return container which you could use to decode property that not mapped
        let container = try decodeMappedProperties(from: decoder)
        // you could decode any type as long is Codable and passing String as a Key
        let base64Image: String = try container.decode(forKey: "image")
        if let imageData: Data = Data(base64Encoded: base64Image) {
            self.image = UIImage(data: imageData)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        // this will automatically encode all Mapped properties and return container which you could use to encode property that not mapped
        var container = try encodeMappedProperties(to: encoder)
        if let base64Image = self.image.pngData()?.base64EncodedString() {
            // you could encode any type as long is Codable and passing String as a Key
            container.encode(value: base64Image, forKey: "address")
        }
    }
}
```

### Manual Mapping

If you use non `Codable` type for property, or maybe you want to represent different data in Swift property other than real property, you could `@AlterMapped` attribute instead of `@Mapped` and pass `TypeAlterer` as converter. With this method, you don't need to implement `init(from decoder: Decoder) throws` and `func encode(to encoder: Encoder) throws` manually. 

```swift
struct User: Alterable {
    
    @Mapped(key: "full_name")
    var fullName: String = ""
    
    @Mapped(key: "user_name")
    var userName: String = ""
    
    @Mapped
    var age: Int = 0
    
    // manual mapping
    @AlterMapped(alterer: Base64ImageAlterer(format: .png))
    var image: UIImage = .init()
    
    // manual mapping with key
    @AlterMapped(key: "birth_date", alterer: StringDateAlterer(pattern: "dd-MM-yyyy"))
    var birthDate: Date = .distantPast
}
```

If your data type is optional, array or both, you can use `optionally` computed property or `forArray` computed property or even the combination of both, since the property is the extension of the `TypeAlterer` protocol. The order of the property call will affect the result of `TypeAlterer` type.

```swift
struct User: Alterable {
    
    @Mapped(key: "full_name")
    var fullName: String = ""
    
    @Mapped(key: "user_name")
    var userName: String = ""
    
    @Mapped
    var age: Int = 0
    
    @AlterMapped(key: "birth_date", alterer: StringDateAlterer(pattern: "dd-MM-yyyy"))
    var birthDate: Date = .distantPast
    
    // optional
    @AlterMapped(alterer: Base64ImageAlterer(format: .png).optionally)
    var image: UIImage? = nil
    
    // array
    @AlterMapped(key: "login_times", alterer: UnixLongDateAlterer().forArray)
    var loginTimes: [Date] = []
    
    // array optional
    @AlterMapped(key: "crashes_times", alterer: UnixLongDateAlterer().forArray.forOptional)
    var crashesTimes: [Date]? = nil
    
    // array of optional
    @AlterMapped(key: "some_times", alterer: UnixLongDateAlterer().forOptional.forArray)
    var someTimes: [Date?] = []
}
```

There are native TypeAlterer from Alter which you could use:
- `UnixLongDateAlterer` which for converting Date into Int64 or vice versa
- `StringDateAlterer` which for converting Date into patterned String or vice versa
- `Base64DataAlterer` which for converting Data into Base64 String or vice versa
- `Base64ImageAlterer` which for converting UIImage into Base64 String or vice versa

If you want to implement your own `TypeAlterer`, just create class or struct that implement `TypeAlterer`. `Value` is the property value type, `AlteredValue` is encoded value, should be implement `Codable`.

```swift
public struct MyOwnDataAlterer: TypeAlterer {
    public typealias Value = Data
    public typealias AlteredValue = String
    
    public init() { }
    
    public func alter(value: Data) -> String {
        value.base64EncodedString()
    }
    
    public func alterBack(value: String) -> Data {
        Data(base64Encoded: value) ?? .init()
    }
}
```

## Extras

Any object that implement Alterable protocol can be treated like Dictionary.

``` swift
let user = User()
user[mappedKey: "user_name"] = "this is username"

// will print "this is username"
print(user.userName)

let userName: String = user[mappedKey: "user_name"] ?? ""

// will print "this is username"
print(userName)
```

The subscript can accept any data as long the data can be cast into property real type or altered type.
