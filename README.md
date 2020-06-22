#  DNS
> make DNS query to any DNS sever directly in iOS and MacOS with Swift

## Installation

### CocoaPods
```
pod 'SwiftDNS', '~> 0.3.0'
```

## Quick Start
```swift
DNSService.query(domain: "vincent178.site", queue: .global(), completion: { (rr, err) in
  print(rr!.Answers.map { $0.RData }) // Get ip list 
})
```
You can also make dns query to a custom name server
```swift
DNSService.query(host: "8.8.8.8", domain: "api.disco.goateng.com", queue: .global(), completion: { (rr, err) in
  print(rr!.Answers.map { $0.RData }) // this could be CName list as well
})
```
