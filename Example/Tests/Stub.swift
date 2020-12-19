//
//  Stub.swift
//  Alter_Tests
//
//  Created by Nayanda Haberty on 18/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

var stubKeyedJSONData: Data = stubKeyedJSONString.data(using: .utf8)!

var stubAutoJSONData: Data = stubAutoJSONString.data(using: .utf8)!

var stubKeyedJSONString: String = """
    {
        "identifier": 673876800,
        "user_name": "username",
        "first_name": "First",
        "last_name": "Last",
        "birth_date": "1991-May-10",
        "last_accessed_time": 1608854400000,
        "related_data": "YWJjMTIzIT8kKiYoKSctPUB+",
        "tracked_accessed_time": [1608854400, 1608854000, 1608850400, 1608804400, 1608054400],
        "address": "Jakarta",
        "item": {
            "itemId": 10051991,
            "itemName": "itemname",
            "itemPrice": 10000000
        }
    }
    """
var stubAutoJSONString: String = """
    {
        "id": 673876800,
        "userName": "username",
        "firstName": "First",
        "lastName": "Last",
        "birthDate": "1991-May-10",
        "lastAccessedTime": 1608854400000,
        "relatedData": "YWJjMTIzIT8kKiYoKSctPUB+",
        "trackedAccessedTime": [1608854400, 1608854000, 1608850400, 1608804400, 1608054400],
        "address": "Jakarta",
        "item": {
            "itemId": 10051991,
            "itemName": "itemname",
            "itemPrice": 10000000
        }
    }
    """

var stubKeyedJSON: [String: Any] = [
    "identifier": 673876800,
    "user_name": "username",
    "first_name": "First",
    "last_name": "Last",
    "birth_date": "1991-May-10",
    "last_accessed_time": 1608854400000,
    "related_data": "YWJjMTIzIT8kKiYoKSctPUB+",
    "tracked_accessed_time": [1608854400, 1608854000, 1608850400, 1608804400, 1608054400],
    "address": "Jakarta",
    "item": [
        "itemId": 10051991,
        "itemName": "itemname",
        "itemPrice": 10000000.0
    ]
]

var stubAutoJSON: [String: Any] = [
    "id": 673876800,
    "userName": "username",
    "firstName": "First",
    "lastName": "Last",
    "birthDate": "1991-May-10",
    "lastAccessedTime": 1608854400000,
    "relatedData": "YWJjMTIzIT8kKiYoKSctPUB+",
    "trackedAccessedTime": [1608854400, 1608854000, 1608850400, 1608804400, 1608054400],
    "address": "Jakarta",
    "item": [
        "itemId": 10051991,
        "itemName": "itemname",
        "itemPrice": 10000000.0
    ]
]
