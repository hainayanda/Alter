<p align="center">
  <img width="192" height="192" src="Alter.png"/>
</p>

# Alter
Alter is framework to make mapping Codable property and key easier.

With Alter, you don't need to create CodingKey to manually mapping key and property.

Alter using propertyWrapper and reflection to achive key property mapping.

[![codebeat badge](https://codebeat.co/badges/d68516a9-4105-4afd-882c-46cb5cff413f)](https://codebeat.co/projects/github-com-nayanda1-alter-main)
![build](https://github.com/nayanda1/Alter/workflows/build/badge.svg)
![test](https://github.com/nayanda1/Alter/workflows/test/badge.svg)
[![Version](https://img.shields.io/cocoapods/v/Alter.svg?style=flat)](https://cocoapods.org/pods/Alter)
[![License](https://img.shields.io/cocoapods/l/Alter.svg?style=flat)](https://cocoapods.org/pods/Alter)
[![Platform](https://img.shields.io/cocoapods/p/Alter.svg?style=flat)](https://cocoapods.org/pods/Alter)

## Requirements

- Swift 5.1 or higher
- iOS 10.0 or higher

## Installation

### Cocoapods

Alter is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'Alter'
```

### Swift Package Manager from XCode

- Add it using xcode menu **File > Swift Package > Add Package Dependency**
- Add **https://github.com/nayanda1/Alter.git** as Swift Package url
- Set rules at **version**, with **Up to Next Major** option and put **1.2.7** as its version
- Click next and wait

### Swift Package Manager from Package.swift

Add as your target dependency in **Package.swift**

```swift
dependencies: [
    .package(url: "https://github.com/nayanda1/Alter.git", .upToNextMajor(from: "1.2.7"))
]
```

Use it in your target as `Alter`

```swift
 .target(
    name: "MyModule",
    dependencies: ["Alter"]
)
```

## Author

Nayanda Haberty, nayanda1@outlook.com

## License

Alter is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## Usage

### Basic Usage

For example, if you need to map User JSON to Swift Object,  you just need to create User class/struct and implement `Alterable protocol` and then mark all the property you need to map to JSON with `@Mapped attributes.`

```swift
struct User: Codable, Alterable {
    
    @Mapped
    var name: String = ""
    
    @Mapped
    var userName: String = ""
    
    @Mapped
    var age: Int = 0
}
```

or just use `AlterCodable` which is `typealias` of `Alterable & Codable`:

```swift
struct User: AlterCodable {
    
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

The `Alterable` actually just a simple protocol which will work with full functionality if paired with `Codable`. The only extendable function from `Codable` is that the `Alterable` will be use reflection to get all Mapped attributes and using it to do two way mapping.

```swift
public protocol Alterable
```

Since `AlterCodable` conform `Codable`, you could always do decode using codable decoder or encode using codable encoder just like `Codable`

```swift
let user: User = getUserFromSomewhere()
let propertyListData = try! PropertyListEncoder().encode(user)
let decodedPropertyList = try! PropertyListDecoder().decode(User.self, from: propertyListData)

let jsonData = try! JSONEncoder().encode(user)
let decodedJsonData = try! JSONDecoder().decode(User.self, from: jsonData)
```

The real power of `Alterable` is the mapping feature which eliminate the requirement of enumeration `CodingKey` when doing key mapping manually. If the property name of Decoded data is different with property in Swift object, then you can pass the name of that property at the attribute instead of creating `CodingKey` enumeration. Those properties then will be mapped using those key.

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

You could always do decode and encode manually by implement `init(from:) throws` and `func encode(to:) throws`. `Alterable` have some extensions to help you implement decode and encode manually

```swift
struct User: AlterCodable {
    
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

If you use non `Codable` type for property, or maybe you want to represent different data in Swift property other than real property, you could use `@AlterMapped` attribute instead of `@Mapped` and pass `TypeAlterer` as converter. With this method, you don't need to implement `init(from:) throws` and `func encode(to:) throws` manually. 

```swift
struct User: AlterCodable {
    
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
struct User: AlterCodable {
    
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

### Mutability

In most case we don't want our model to be mutable, But since Alter need the property to be mutable so it could be assigned on object creation, you could just make the setter private.

```swift
struct User: AlterCodable {
    
    @Mapped(key: "full_name")
    private(set) var fullName: String = ""
    
    @Mapped(key: "user_name")
    private(set) var userName: String = ""
    
    @Mapped
    private(set) var age: Int = 0
}
```

There's some extras if you want to have mutable ability to treat Alterable as Dictionary. Any object that implement `MutableAlterable` protocol can be treated like Dictionary.

```swift
struct MutableUser: MutableAlterable {
    @Mapped(key: "user_name")
    var userName: String? = nil
    ...
    ...
    ...
}
```

or by using `MutableAlterCodable` which is `typealias` of `MutableAlterable & Codable`

```swift
struct MutableUser: MutableAlterCodable {
    @Mapped(key: "user_name")
    var userName: String? = nil
    ...
    ...
    ...
}
```

Then you could just treat it like dictionary

``` swift
let user = MutableUser()
user[mappedKey: "user_name"] = "this is username"

// will print "this is username"
print(user.userName)

let userName: String = user[mappedKey: "user_name"] ?? ""

// will print "this is username"
print(userName)
```

The subscript can accept any type as long the type can be cast into property real type or altered type.
