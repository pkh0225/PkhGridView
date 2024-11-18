// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PkhGridView",
    platforms: [
        .iOS(.v11) // iOS 11 이상 지원
    ],
    products: [
        .library(
            name: "PkhGridView",
            targets: ["PkhGridView"]
        ),
    ],
    dependencies: [
        // 외부 종속성 추가 시 여기에 작성
    ],
    targets: [
        .target(
            name: "PkhGridView",
            dependencies: [],
            path: "Sources", // 소스 경로를 명시적으로 설정
            exclude: [],     // 제외할 파일이나 디렉토리 설정
            resources: [],   // 리소스 파일 추가 시 필요
            swiftSettings: [] // Swift 관련 추가 설정
        )
    ]
)
