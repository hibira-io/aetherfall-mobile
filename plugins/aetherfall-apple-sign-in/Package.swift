// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AetherfallAppleSignIn",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "AetherfallAppleSignIn", targets: ["AetherfallAppleSignInPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "8.0.0")
    ],
    targets: [
        .target(
            name: "AetherfallAppleSignInPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/AetherfallAppleSignInPlugin")
    ]
)
