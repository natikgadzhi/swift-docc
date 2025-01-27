/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2023 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

import XCTest
import Markdown
@testable import SwiftDocC

class ExternalPathHierarchyResolverTests: XCTestCase {
    
    private var originalFeatureFlagsState: FeatureFlags!
    
    override func setUp() {
        super.setUp()
        originalFeatureFlagsState = FeatureFlags.current
        FeatureFlags.current.isExperimentalLinkHierarchySerializationEnabled = true
    }
    
    override func tearDown() {
        FeatureFlags.current = originalFeatureFlagsState
        originalFeatureFlagsState = nil
        super.tearDown()
    }
    
    // These tests resolve absolute symbol links in both a local and external context to verify that external links work the same local links.
    
    func testUnambiguousAbsolutePaths() throws {
        let linkResolvers = try makeLinkResolversForTestBundle(named: "MixedLanguageFrameworkWithLanguageRefinements")
        
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework")
        
        // @objc public enum MyEnum: Int {
        //     case firstCase
        //     case secondCase
        //     public func myEnumFunction() { }
        //     public typealias MyEnumTypeAlias = Int
        //     public var myEnumProperty: MyEnumTypeAlias { 0 }
        // }
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyEnum")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyEnum/firstCase")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyEnum/secondCase")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyEnum/myEnumFunction()")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyEnum/MyEnumTypeAlias")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyEnum/myEnumProperty")
        
        // public struct MyStruct {
        //     public func myStructFunction() { }
        //     public typealias MyStructTypeAlias = Int
        //     public var myStructProperty: MyStructTypeAlias { 0 }
        //     public static var myStructTypeProperty: MyStructTypeAlias { 0 }
        // }
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyStruct")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyStruct/myStructFunction()")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyStruct/MyStructTypeAlias")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyStruct/myStructProperty")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyStruct/myStructTypeProperty")
        
        // @objc public class MyClass: NSObject {
        //     @objc public func myInstanceMethod() { }
        //     @nonobjc public func mySwiftOnlyInstanceMethod() { }
        //     public typealias MyClassTypeAlias = Int
        //     public var myInstanceProperty: MyClassTypeAlias { 0 }
        //     public static var myClassTypeProperty: MyClassTypeAlias { 0 }
        // }
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyClass")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyClass/myInstanceMethod()")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyClass/mySwiftOnlyInstanceMethod()")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyClass/MyClassTypeAlias")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyClass/myInstanceProperty")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyClass/myClassTypeProperty")
        
        // @objc public protocol MyObjectiveCCompatibleProtocol {
        //     func myProtocolMethod()
        //     typealias MyProtocolTypeAlias = MyClass
        //     var myProtocolProperty: MyProtocolTypeAlias { get }
        //     static var myProtocolTypeProperty: MyProtocolTypeAlias { get }
        //     @objc optional func myPropertyOptionalMethod()
        // }
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyObjectiveCCompatibleProtocol")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyObjectiveCCompatibleProtocol/myProtocolMethod()")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyObjectiveCCompatibleProtocol/MyProtocolTypeAlias")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyObjectiveCCompatibleProtocol/myProtocolProperty")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyObjectiveCCompatibleProtocol/myProtocolTypeProperty")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyObjectiveCCompatibleProtocol/myPropertyOptionalMethod()")
        
        // public protocol MySwiftProtocol {
        //     func myProtocolMethod()
        //     associatedtype MyProtocolAssociatedType
        //     typealias MyProtocolTypeAlias = MyStruct
        //     var myProtocolProperty: MyProtocolAssociatedType { get }
        //     static var myProtocolTypeProperty: MyProtocolAssociatedType { get }
        // }
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MySwiftProtocol")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MySwiftProtocol/myProtocolMethod()")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MySwiftProtocol/MyProtocolAssociatedType")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MySwiftProtocol/MyProtocolTypeAlias")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MySwiftProtocol/myProtocolProperty")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MySwiftProtocol/myProtocolTypeProperty")
        
        // public typealias MyTypeAlias = MyStruct
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyTypeAlias")
        
        // public func myTopLevelFunction() { }
        // public var myTopLevelVariable = true
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/myTopLevelFunction()")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/myTopLevelVariable")
       
        // public protocol MyOtherProtocolThatConformToMySwiftProtocol: MySwiftProtocol {
        //     func myOtherProtocolMethod()
        // }
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyOtherProtocolThatConformToMySwiftProtocol")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyOtherProtocolThatConformToMySwiftProtocol/myOtherProtocolMethod()")
        
        // @objcMembers public class MyClassThatConformToMyOtherProtocol: NSObject, MyOtherProtocolThatConformToMySwiftProtocol {
        //     public func myOtherProtocolMethod() { }
        //     public func myProtocolMethod() { }
        //     public typealias MyProtocolAssociatedType = MyStruct
        //     public var myProtocolProperty: MyStruct { .init() }
        //     public class var myProtocolTypeProperty: MyStruct { .init() }
        // }
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyClassThatConformToMyOtherProtocol")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyClassThatConformToMyOtherProtocol/myOtherProtocolMethod()")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyClassThatConformToMyOtherProtocol/myProtocolMethod()")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyClassThatConformToMyOtherProtocol/MyProtocolAssociatedType")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyClassThatConformToMyOtherProtocol/myProtocolProperty")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyClassThatConformToMyOtherProtocol/myProtocolTypeProperty")
        
        // public final class CollisionsWithDifferentCapitalization {
        //     public var something: Int = 0
        //     public var someThing: Int = 0
        // }
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/CollisionsWithDifferentCapitalization")
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework/CollisionsWithDifferentCapitalization/something", 
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/CollisionsWithDifferentCapitalization/something-2c4k6"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework/CollisionsWithDifferentCapitalization/someThing", 
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/CollisionsWithDifferentCapitalization/someThing-90i4h"
        )
        
        // public enum CollisionsWithDifferentKinds {
        //     case something
        //     public var something: String { "" }
        //     public typealias Something = Int
        // }
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/CollisionsWithDifferentKinds")
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework/CollisionsWithDifferentKinds/something-enum.case", 
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/CollisionsWithDifferentKinds/something-swift.enum.case"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework/CollisionsWithDifferentKinds/something-property", 
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/CollisionsWithDifferentKinds/something-swift.property"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework/CollisionsWithDifferentKinds/Something", 
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/CollisionsWithDifferentKinds/Something-swift.typealias"
        )
        
        // public final class CollisionsWithEscapedKeywords {
        //     public subscript() -> Int { 0 }
        //     public func `subscript`() { }
        //     public static func `subscript`() { }
        //
        //     public init() { }
        //     public func `init`() { }
        //     public static func `init`() { }
        // }
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/CollisionsWithEscapedKeywords")
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework/CollisionsWithEscapedKeywords/init()-init",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/CollisionsWithEscapedKeywords/init()-swift.init"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework/CollisionsWithEscapedKeywords/init()-method",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/CollisionsWithEscapedKeywords/init()-swift.method"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework/CollisionsWithEscapedKeywords/init()-type.method",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/CollisionsWithEscapedKeywords/init()-swift.type.method"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework/CollisionsWithEscapedKeywords/subscript()-subscript",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/CollisionsWithEscapedKeywords/subscript()-swift.subscript"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework/CollisionsWithEscapedKeywords/subscript()-method",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/CollisionsWithEscapedKeywords/subscript()-swift.method"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework/CollisionsWithEscapedKeywords/subscript()-type.method",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/CollisionsWithEscapedKeywords/subscript()-swift.type.method"
        )
        
        // public enum CollisionsWithDifferentFunctionArguments {
        //     public func something(argument: Int) -> Int { 0 }
        //     public func something(argument: String) -> Int { 0 }
        // }
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/CollisionsWithDifferentFunctionArguments")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/CollisionsWithDifferentFunctionArguments/something(argument:)-1cyvp")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/CollisionsWithDifferentFunctionArguments/something(argument:)-2vke2")
       
        // public enum CollisionsWithDifferentSubscriptArguments {
        //     public subscript(something: Int) -> Int { 0 }
        //     public subscript(somethingElse: String) -> Int { 0 }
        // }
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/CollisionsWithDifferentSubscriptArguments")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/CollisionsWithDifferentSubscriptArguments/subscript(_:)-4fd0l")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/CollisionsWithDifferentSubscriptArguments/subscript(_:)-757cj")
        
        // @objc(MySwiftClassObjectiveCName)
        // public class MySwiftClassSwiftName: NSObject {
        //     @objc(myPropertyObjectiveCName)
        //     public var myPropertySwiftName: Int { 0 }
        //
        //     @objc(myMethodObjectiveCName)
        //     public func myMethodSwiftName() -> Int { 0 }
        // }
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MySwiftClassSwiftName")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MySwiftClassSwiftName/myPropertySwiftName")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MySwiftClassSwiftName/myMethodSwiftName()")
        
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework/MySwiftClassObjectiveCName",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MySwiftClassSwiftName"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework/MySwiftClassObjectiveCName/myPropertyObjectiveCName",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MySwiftClassSwiftName/myPropertySwiftName"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework/MySwiftClassObjectiveCName/myMethodObjectiveCName",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MySwiftClassSwiftName/myMethodSwiftName()"
        )
        
        // NS_SWIFT_NAME(MyObjectiveCClassSwiftName)
        // @interface MyObjectiveCClassObjectiveCName : NSObject
        //
        // @property (copy, readonly) NSString * myPropertyObjectiveCName NS_SWIFT_NAME(myPropertySwiftName);
        //
        // - (void)myMethodObjectiveCName NS_SWIFT_NAME(myMethodSwiftName());
        // - (void)myMethodWithArgument:(NSString *)argument NS_SWIFT_NAME(myMethod(argument:));
        //
        // @end
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyObjectiveCClassSwiftName")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyObjectiveCClassSwiftName/myPropertySwiftName")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyObjectiveCClassSwiftName/myMethodSwiftName()")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyObjectiveCClassSwiftName/myMethod(argument:)")
        
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework/MyObjectiveCClassObjectiveCName",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MyObjectiveCClassSwiftName"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework/MyObjectiveCClassObjectiveCName/myPropertyObjectiveCName",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MyObjectiveCClassSwiftName/myPropertySwiftName"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework/MyObjectiveCClassObjectiveCName/myMethodObjectiveCName",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MyObjectiveCClassSwiftName/myMethodSwiftName()"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework/MyObjectiveCClassObjectiveCName/myMethodWithArgument:",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MyObjectiveCClassSwiftName/myMethod(argument:)"
        )
        
        // typedef NS_ENUM(NSInteger, MyObjectiveCEnum) {
        //     MyObjectiveCEnumFirst,
        //     MyObjectiveCEnumSecond NS_SWIFT_NAME(secondCaseSwiftName)
        // };
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyObjectiveCEnum")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyObjectiveCEnum/first")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyObjectiveCEnum/secondCaseSwiftName")
        
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework/MyObjectiveCEnum/MyObjectiveCEnumFirst",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MyObjectiveCEnum/first"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework/MyObjectiveCEnum/MyObjectiveCEnumSecond",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MyObjectiveCEnum/secondCaseSwiftName"
        )
        
        // typedef NS_ENUM(NSInteger, MyObjectiveCEnumObjectiveCName) {
        //     MyObjectiveCEnumObjectiveCNameFirst,
        //     MyObjectiveCEnumObjectiveCNameSecond NS_SWIFT_NAME(secondCaseSwiftName)
        // } NS_SWIFT_NAME(MyObjectiveCEnumSwiftName);
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyObjectiveCEnumSwiftName")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyObjectiveCEnumSwiftName/first")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyObjectiveCEnumSwiftName/secondCaseSwiftName")
        
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework/MyObjectiveCEnumObjectiveCName",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MyObjectiveCEnumSwiftName"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework/MyObjectiveCEnumObjectiveCName/MyObjectiveCEnumObjectiveCNameFirst",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MyObjectiveCEnumSwiftName/first"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework/MyObjectiveCEnumObjectiveCName/MyObjectiveCEnumObjectiveCNameSecond",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MyObjectiveCEnumSwiftName/secondCaseSwiftName"
        )
        
        // typedef NS_OPTIONS(NSInteger, MyObjectiveCOption) {
        //     MyObjectiveCOptionNone                                      = 0,
        //     MyObjectiveCOptionFirst                                     = 1 << 0,
        //     MyObjectiveCOptionSecond NS_SWIFT_NAME(secondCaseSwiftName) = 1 << 1
        // };
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyObjectiveCOption")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyObjectiveCOption/first")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyObjectiveCOption/secondCaseSwiftName")
        
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyObjectiveCOption/MyObjectiveCOptionNone")
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework/MyObjectiveCOption/MyObjectiveCOptionFirst",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MyObjectiveCOption/first"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework/MyObjectiveCOption/MyObjectiveCOptionSecond",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MyObjectiveCOption/secondCaseSwiftName"
        )
        
        // typedef NSInteger MyTypedObjectiveCEnum NS_TYPED_ENUM;
        //
        // MyTypedObjectiveCEnum const MyTypedObjectiveCEnumFirst;
        // MyTypedObjectiveCEnum const MyTypedObjectiveCEnumSecond;
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyTypedObjectiveCEnum")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyTypedObjectiveCEnum/first")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyTypedObjectiveCEnum/second")
        
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework/MyTypedObjectiveCEnumFirst",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MyTypedObjectiveCEnum/first"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework/MyTypedObjectiveCEnumSecond",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MyTypedObjectiveCEnum/second"
        )
        
        // typedef NSInteger MyTypedObjectiveCExtensibleEnum NS_TYPED_EXTENSIBLE_ENUM;
        //
        // MyTypedObjectiveCExtensibleEnum const MyTypedObjectiveCExtensibleEnumFirst;
        // MyTypedObjectiveCExtensibleEnum const MyTypedObjectiveCExtensibleEnumSecond;
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyTypedObjectiveCExtensibleEnum")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyTypedObjectiveCExtensibleEnum/first")
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework/MyTypedObjectiveCExtensibleEnum/second")
        
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework/MyTypedObjectiveCExtensibleEnumFirst",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MyTypedObjectiveCExtensibleEnum/first"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework/MyTypedObjectiveCExtensibleEnumSecond",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MyTypedObjectiveCExtensibleEnum/second"
        )
    }
    
    func testAmbiguousPaths() throws {
        let linkResolvers = try makeLinkResolversForTestBundle(named: "MixedLanguageFrameworkWithLanguageRefinements")
        
        // public enum CollisionsWithDifferentKinds {
        //     case something
        //     public var something: String { "" }
        //     public typealias Something = Int
        // }
        try linkResolvers.assertFailsToResolve(
            authoredLink: "/MixedFramework/CollisionsWithDifferentKinds/something",
            errorMessage: "'something' is ambiguous at '/MixedFramework/CollisionsWithDifferentKinds'",
            solutions: [
                .init(summary: "Insert 'enum.case' for\n'case something'", replacement: ("-enum.case", 54, 54)),
                .init(summary: "Insert 'property' for\n'var something: String { get }'", replacement: ("-property", 54, 54)),
            ]
        )
        
        try linkResolvers.assertFailsToResolve(
            authoredLink: "/MixedFramework/CollisionsWithDifferentKinds/something-class",
            errorMessage: "'class' isn't a disambiguation for 'something' at '/MixedFramework/CollisionsWithDifferentKinds'",
            solutions: [
                .init(summary: "Replace 'class' with 'enum.case' for\n'case something'", replacement: ("-enum.case", 54, 60)),
                .init(summary: "Replace 'class' with 'property' for\n'var something: String { get }'", replacement: ("-property", 54, 60)),
            ]
        )
 
        // public final class CollisionsWithEscapedKeywords {
        //     public subscript() -> Int { 0 }
        //     public func `subscript`() { }
        //     public static func `subscript`() { }
        //
        //     public init() { }
        //     public func `init`() { }
        //     public static func `init`() { }
        // }
        
        try linkResolvers.assertFailsToResolve(
            authoredLink: "/MixedFramework/CollisionsWithEscapedKeywords/init()",
            errorMessage: "'init()' is ambiguous at '/MixedFramework/CollisionsWithEscapedKeywords'",
            solutions: [
                .init(summary: "Insert 'method' for\n'func `init`()'", replacement: ("-method", 52, 52)),
                .init(summary: "Insert 'init' for\n'init()'", replacement: ("-init", 52, 52)),
                .init(summary: "Insert 'type.method' for\n'static func `init`()'", replacement: ("-type.method", 52, 52)),
            ]
        )
        try linkResolvers.assertFailsToResolve(
            authoredLink: "/MixedFramework/CollisionsWithEscapedKeywords/init()-abc123",
            errorMessage: "'abc123' isn't a disambiguation for 'init()' at '/MixedFramework/CollisionsWithEscapedKeywords'",
            solutions: [
                .init(summary: "Replace 'abc123' with 'method' for\n'func `init`()'", replacement: ("-method", 52, 59)),
                .init(summary: "Replace 'abc123' with 'init' for\n'init()'", replacement: ("-init", 52, 59)),
                .init(summary: "Replace 'abc123' with 'type.method' for\n'static func `init`()'", replacement: ("-type.method", 52, 59)),
            ]
        )
        // Providing disambiguation will narrow down the suggestions. Note that `()` is missing in the last path component
        try linkResolvers.assertFailsToResolve(
            authoredLink: "/MixedFramework/CollisionsWithEscapedKeywords/init-method",
            errorMessage: "'init-method' doesn't exist at '/MixedFramework/CollisionsWithEscapedKeywords'",
            solutions: [
                .init(summary: "Replace 'init' with 'init()'", replacement: ("init()", 46, 50)), // The disambiguation is not replaced so the suggested link is unambiguous
            ]
        )
        try linkResolvers.assertFailsToResolve(
            authoredLink: "/MixedFramework/CollisionsWithEscapedKeywords/init-init",
            errorMessage: "'init-init' doesn't exist at '/MixedFramework/CollisionsWithEscapedKeywords'",
            solutions: [
                .init(summary: "Replace 'init' with 'init()'", replacement: ("init()", 46, 50)), // The disambiguation is not replaced so the suggested link is unambiguous
            ]
        )
        try linkResolvers.assertFailsToResolve(
            authoredLink: "/MixedFramework/CollisionsWithEscapedKeywords/init-type.method",
            errorMessage: "'init-type.method' doesn't exist at '/MixedFramework/CollisionsWithEscapedKeywords'",
            solutions: [
                .init(summary: "Replace 'init' with 'init()'", replacement: ("init()", 46, 50)), // The disambiguation is not replaced so the suggested link is unambiguous
            ]
        )
        
        try linkResolvers.assertFailsToResolve(
            authoredLink: "/MixedFramework/CollisionsWithEscapedKeywords/subscript()",
            errorMessage: "'subscript()' is ambiguous at '/MixedFramework/CollisionsWithEscapedKeywords'",
            solutions: [
                .init(summary: "Insert 'method' for\n'func `subscript`()'", replacement: ("-method", 57, 57)),
                .init(summary: "Insert 'type.method' for\n'static func `subscript`()'", replacement: ("-type.method", 57, 57)),
                .init(summary: "Insert 'subscript' for\n'subscript() -> Int { get }'", replacement: ("-subscript", 57, 57)),
            ]
        )
        
        // public enum CollisionsWithDifferentFunctionArguments {
        //     public func something(argument: Int) -> Int { 0 }
        //     public func something(argument: String) -> Int { 0 }
        // }
        try linkResolvers.assertFailsToResolve(
            authoredLink: "/MixedFramework/CollisionsWithDifferentFunctionArguments/something(argument:)",
            errorMessage: "'something(argument:)' is ambiguous at '/MixedFramework/CollisionsWithDifferentFunctionArguments'",
            solutions: [
                .init(summary: "Insert '1cyvp' for\n'func something(argument: Int) -> Int'", replacement: ("-1cyvp", 77, 77)),
                .init(summary: "Insert '2vke2' for\n'func something(argument: String) -> Int'", replacement: ("-2vke2", 77, 77)),
            ]
        )
        try linkResolvers.assertFailsToResolve(
            authoredLink: "/documentation/MixedFramework/CollisionsWithDifferentFunctionArguments/something(argument:)",
            errorMessage: "'something(argument:)' is ambiguous at '/MixedFramework/CollisionsWithDifferentFunctionArguments'",
            solutions: [
                .init(summary: "Insert '1cyvp' for\n'func something(argument: Int) -> Int'", replacement: ("-1cyvp", 91, 91)),
                .init(summary: "Insert '2vke2' for\n'func something(argument: String) -> Int'", replacement: ("-2vke2", 91, 91)),
            ]
        )
        try linkResolvers.assertFailsToResolve(
            authoredLink: "/MixedFramework/CollisionsWithDifferentFunctionArguments/something(argument:)-abc123",
            errorMessage: "'abc123' isn't a disambiguation for 'something(argument:)' at '/MixedFramework/CollisionsWithDifferentFunctionArguments'",
            solutions: [
                .init(summary: "Replace 'abc123' with '1cyvp' for\n'func something(argument: Int) -> Int'", replacement: ("-1cyvp", 77, 84)),
                .init(summary: "Replace 'abc123' with '2vke2' for\n'func something(argument: String) -> Int'", replacement: ("-2vke2", 77, 84)),
            ]
        )
        // Providing disambiguation will narrow down the suggestions. Note that `argument` label is missing in the last path component
        try linkResolvers.assertFailsToResolve(
            authoredLink: "/MixedFramework/CollisionsWithDifferentFunctionArguments/something(_:)-1cyvp",
            errorMessage: "'something(_:)-1cyvp' doesn't exist at '/MixedFramework/CollisionsWithDifferentFunctionArguments'",
            solutions: [
                .init(summary: "Replace 'something(_:)' with 'something(argument:)'", replacement: ("something(argument:)", 57, 70)), // The disambiguation is not replaced so the suggested link is unambiguous
            ]
        )
        try linkResolvers.assertFailsToResolve(
            authoredLink: "/MixedFramework/CollisionsWithDifferentFunctionArguments/something(_:)-2vke2",
            errorMessage: "'something(_:)-2vke2' doesn't exist at '/MixedFramework/CollisionsWithDifferentFunctionArguments'",
            solutions: [
                .init(summary: "Replace 'something(_:)' with 'something(argument:)'", replacement: ("something(argument:)", 57, 70)), // The disambiguation is not replaced so the suggested link is unambiguous
            ]
        )
        try linkResolvers.assertFailsToResolve(
            authoredLink: "/MixedFramework/CollisionsWithDifferentFunctionArguments/something(argument:)-method",
            errorMessage: "'something(argument:)-method' is ambiguous at '/MixedFramework/CollisionsWithDifferentFunctionArguments'",
            solutions: [
                .init(summary: "Replace 'method' with '1cyvp' for\n'func something(argument: Int) -> Int'", replacement: ("-1cyvp", 77, 84)),
                .init(summary: "Replace 'method' with '2vke2' for\n'func something(argument: String) -> Int'", replacement: ("-2vke2", 77, 84)),
            ]
        )
        try linkResolvers.assertFailsToResolve(
            authoredLink: "/documentation/MixedFramework/CollisionsWithDifferentFunctionArguments/something(argument:)-method",
            errorMessage: "'something(argument:)-method' is ambiguous at '/MixedFramework/CollisionsWithDifferentFunctionArguments'",
            solutions: [
                .init(summary: "Replace 'method' with '1cyvp' for\n'func something(argument: Int) -> Int'", replacement: ("-1cyvp", 91, 98)),
                .init(summary: "Replace 'method' with '2vke2' for\n'func something(argument: String) -> Int'", replacement: ("-2vke2", 91, 98)),
            ]
        )
        
        // public enum CollisionsWithDifferentSubscriptArguments {
        //     public subscript(something: Int) -> Int { 0 }
        //     public subscript(somethingElse: String) -> Int { 0 }
        // }
        try linkResolvers.assertFailsToResolve(
            authoredLink: "/MixedFramework/CollisionsWithDifferentSubscriptArguments/subscript(_:)",
            errorMessage: "'subscript(_:)' is ambiguous at '/MixedFramework/CollisionsWithDifferentSubscriptArguments'",
            solutions: [
                .init(summary: "Insert '4fd0l' for\n'subscript(something: Int) -> Int { get }'", replacement: ("-4fd0l", 71, 71)),
                .init(summary: "Insert '757cj' for\n'subscript(somethingElse: String) -> Int { get }'", replacement: ("-757cj", 71, 71)),
            ]
        )
        try linkResolvers.assertFailsToResolve(
            authoredLink: "/MixedFramework/CollisionsWithDifferentSubscriptArguments/subscript(_:)-subscript",
            errorMessage: "'subscript(_:)-subscript' is ambiguous at '/MixedFramework/CollisionsWithDifferentSubscriptArguments'",
            solutions: [
                .init(summary: "Replace 'subscript' with '4fd0l' for\n'subscript(something: Int) -> Int { get }'", replacement: ("-4fd0l", 71, 81)),
                .init(summary: "Replace 'subscript' with '757cj' for\n'subscript(somethingElse: String) -> Int { get }'", replacement: ("-757cj", 71, 81)),
            ]
        )
    }
    
    func testRedundantDisambiguations() throws {
        let linkResolvers = try makeLinkResolversForTestBundle(named: "MixedLanguageFrameworkWithLanguageRefinements")
        
        try linkResolvers.assertSuccessfullyResolves(authoredLink: "/MixedFramework")
        
        // @objc public enum MyEnum: Int {
        //     case firstCase
        //     case secondCase
        //     public func myEnumFunction() { }
        //     public typealias MyEnumTypeAlias = Int
        //     public var myEnumProperty: MyEnumTypeAlias { 0 }
        // }
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework-module-9r7pl/MyEnum-enum-1m96o",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MyEnum"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework-module-9r7pl/MyEnum-enum-1m96o/firstCase-enum.case-5ocr4",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MyEnum/firstCase"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework-module-9r7pl/MyEnum-enum-1m96o/secondCase-enum.case-ihyt",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MyEnum/secondCase"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework-module-9r7pl/MyEnum-enum-1m96o/myEnumFunction()-method-2pa9q",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MyEnum/myEnumFunction()"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework-module-9r7pl/MyEnum-enum-1m96o/MyEnumTypeAlias-typealias-5ejt4",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MyEnum/MyEnumTypeAlias"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework-module-9r7pl/MyEnum-enum-1m96o/myEnumProperty-property-6cz2q",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MyEnum/myEnumProperty"
        )
        
        // public struct MyStruct {
        //     public func myStructFunction() { }
        //     public typealias MyStructTypeAlias = Int
        //     public var myStructProperty: MyStructTypeAlias { 0 }
        //     public static var myStructTypeProperty: MyStructTypeAlias { 0 }
        // }
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework-module-9r7pl/MyStruct-struct-23xcd",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MyStruct"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework-module-9r7pl/MyStruct-struct-23xcd/myStructFunction()-method-9p92r",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MyStruct/myStructFunction()"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework-module-9r7pl/MyStruct-struct-23xcd/MyStructTypeAlias-typealias-630hf",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MyStruct/MyStructTypeAlias"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework-module-9r7pl/MyStruct-struct-23xcd/myStructProperty-property-5ywbx",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MyStruct/myStructProperty"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework-module-9r7pl/MyStruct-struct-23xcd/myStructTypeProperty-type.property-8ti6m",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MyStruct/myStructTypeProperty"
        )
        
        // public protocol MySwiftProtocol {
        //     func myProtocolMethod()
        //     associatedtype MyProtocolAssociatedType
        //     typealias MyProtocolTypeAlias = MyStruct
        //     var myProtocolProperty: MyProtocolAssociatedType { get }
        //     static var myProtocolTypeProperty: MyProtocolAssociatedType { get }
        // }
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework-module-9r7pl/MySwiftProtocol-protocol-xmee",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MySwiftProtocol"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework-module-9r7pl/MySwiftProtocol-protocol-xmee/myProtocolMethod()-method-6srz6",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MySwiftProtocol/myProtocolMethod()"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework-module-9r7pl/MySwiftProtocol-protocol-xmee/MyProtocolAssociatedType-associatedtype-33siz",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MySwiftProtocol/MyProtocolAssociatedType"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework-module-9r7pl/MySwiftProtocol-protocol-xmee/MyProtocolTypeAlias-typealias-9rpv6",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MySwiftProtocol/MyProtocolTypeAlias"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework-module-9r7pl/MySwiftProtocol-protocol-xmee/myProtocolProperty-property-qer2",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MySwiftProtocol/myProtocolProperty"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework-module-9r7pl/MySwiftProtocol-protocol-xmee/myProtocolTypeProperty-type.property-8h7hm",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/MySwiftProtocol/myProtocolTypeProperty"
        )
        
        // public func myTopLevelFunction() { }
        // public var myTopLevelVariable = true
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework-module-9r7pl/myTopLevelFunction()-func-55lhl",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/myTopLevelFunction()"
        )
        try linkResolvers.assertSuccessfullyResolves(
            authoredLink: "/MixedFramework-module-9r7pl/myTopLevelVariable-var-520ez",
            to: "doc://org.swift.MixedFramework/documentation/MixedFramework/myTopLevelVariable"
        )
    }
    
    // MARK: Test helpers
    
    struct LinkResolvers {
        let localResolver: PathHierarchyBasedLinkResolver
        let externalResolver: ExternalPathHierarchyResolver
        let context: DocumentationContext
        
        func assertResults(authoredLink: String, verification: (TopicReferenceResolutionResult, String) throws -> Void) throws {
            let unresolvedReference = try XCTUnwrap(ValidatedURL(parsingAuthoredLink: authoredLink).map(UnresolvedTopicReference.init(topicURL:)))
            let rootModule = try XCTUnwrap(context.soleRootModuleReference)
            
            let linkResolver = LinkResolver()
            linkResolver.localResolver = localResolver
            let localResult = linkResolver.resolve(unresolvedReference, in: rootModule, fromSymbolLink: true, context: context)
            let externalResult = externalResolver.resolve(unresolvedReference, fromSymbolLink: true)
            
            try verification(localResult, "local")
            try verification(externalResult, "external")
        }
        
        func assertSuccessfullyResolves(
            authoredLink: String,
            to absoluteReferenceString: String? = nil,
            file: StaticString = #file,
            line: UInt = #line
        ) throws {
            let expectedAbsoluteReferenceString = absoluteReferenceString ?? {
                context.soleRootModuleReference!.url
                    .deletingLastPathComponent() // Remove the module name
                    .appendingPathComponent(authoredLink.trimmingCharacters(in: ["/"])) // Append the authored link, without leading slashes
                    .absoluteString
            }()
            
            try assertResults(authoredLink: authoredLink) { result, label in
                switch result {
                case .success(let resolved):
                    XCTAssertEqual(resolved.absoluteString, expectedAbsoluteReferenceString, label, file: file, line: line)
                case .failure(_, let errorInfo):
                    XCTFail("Unexpectedly failed to resolve \(label) link: \(errorInfo.message) \(errorInfo.solutions.map(\.summary).joined(separator: ", "))", file: file, line: line)
                }
            }
        }
        
        func assertFailsToResolve(
            authoredLink: String,
            errorMessage: String,
            solutions: [Solution],
            file: StaticString = #file,
            line: UInt = #line
        ) throws {
           try assertResults(authoredLink: authoredLink) { result, label in
                switch result {
                case .success:
                    XCTFail("Unexpectedly resolved link with wrong module name for \(label)", file: file, line: line)
                case .failure(_, let errorInfo):
                    XCTAssertEqual(errorInfo.message, errorMessage, label, file: file, line: line)
                    XCTAssertEqual(errorInfo.solutions.count, solutions.count, "Unexpected number of solutions for \(label) link", file: file, line: line)
                    for (actualSolution, expectedSolution) in zip(errorInfo.solutions, solutions) {
                        XCTAssertEqual(actualSolution.summary, expectedSolution.summary, label, file: file, line: line)
                        let replacement = try XCTUnwrap(actualSolution.replacements.first)
                        
                        XCTAssertEqual(replacement.replacement, expectedSolution.replacement.0, label, file: file, line: line)
                        XCTAssertEqual(replacement.range.lowerBound.column, expectedSolution.replacement.1, label, file: file, line: line)
                        XCTAssertEqual(replacement.range.upperBound.column, expectedSolution.replacement.2, label, file: file, line: line)
                    }
                }
            }
        }
        
        struct Solution {
            var summary: String
            var replacement: (String, Int, Int)
        }
    }
    
    private func makeLinkResolversForTestBundle(named testBundleName: String) throws -> LinkResolvers {
        let (bundle, context) = try testBundleAndContext(named: testBundleName)
        let localResolver = try XCTUnwrap(context.linkResolver.localResolver)
        
        let resolverInfo = try localResolver.prepareForSerialization(bundleID: bundle.identifier)
        let resolverData = try JSONEncoder().encode(resolverInfo)
        let roundtripResolverInfo = try JSONDecoder().decode(SerializableLinkResolutionInformation.self, from: resolverData)
        
        var entitySummaries = [LinkDestinationSummary]()
        let converter = DocumentationNodeConverter(bundle: bundle, context: context)
        for reference in context.knownPages {
            let node = try context.entity(with: reference)
            let renderNode = try converter.convert(node, at: nil)
            entitySummaries.append(contentsOf: node.externallyLinkableElementSummaries(context: context, renderNode: renderNode, includeTaskGroups: false))
        }
        
        let externalResolver = ExternalPathHierarchyResolver(
            linkInformation: roundtripResolverInfo,
            entityInformation: entitySummaries
        )
        
        return LinkResolvers(localResolver: localResolver, externalResolver: externalResolver, context: context)
    }
}
