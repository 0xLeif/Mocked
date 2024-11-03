// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

#if os(Windows)
let GUISwiftSettings: [SwiftSetting] = [
  // Instruct the compiler to generate the entry point as `wWinMain`
  // rather than `main` to ensure that the application is correctly
  // marked as a GUI application (Windows subsystem).  This is done
  // by the linker based upon the main entry point.  Simply marking
  // the subsystem is insufficient as the compiler will materialize
  // the entry point as `main`, resulting in an undefined symbol.
  .unsafeFlags([
    "-Xfrontend", "-entry-point-function-name",
    "-Xfrontend", "wWinMain",
  ]),
]
let GUILinkerSettings: [LinkerSetting] = [
]
#endif

#if os(Windows)
let macroTarget: Target = Target.macro(
    name: "MockedMacros",
    dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
    ],
    swiftSettings: GUISwiftSettings,
    linkerSettings: GUILinkerSettings
)
#else
let macroTarget: Target = Target.macro(
    name: "MockedMacros",
    dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
    ]
)
#endif

let package = Package(
    name: "Mocked",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Mocked",
            targets: ["Mocked"]
        ),
        .executable(
            name: "MockedClient",
            targets: ["MockedClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0-latest"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        // Macro implementation that performs the source transformation of a macro.
        macroTarget,

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(name: "Mocked", dependencies: ["MockedMacros"]),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(name: "MockedClient", dependencies: ["Mocked"]),

        // A test target used to develop the macro implementation.
        .testTarget(
            name: "MockedTests",
            dependencies: [
                "MockedMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
