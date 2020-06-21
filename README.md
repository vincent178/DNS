#  DNS
> make DNS query to any DNS sever directly in iOS and MacOS with Swift

## Installation

### CocoaPods
```
pod 'SwiftDNS', '~> 0.1.0'
```

## Quick Start
```swift
let ds = DNSService.init()
ds.start()
sleep(1)
ds.query(domain: "vincent178.site", completion: { (rr, err) in
  print(rr!.Answers.map { $0.RData }) // Get ip list 
  ds.stop() // don't forget to stop service
})
```
You can also make dns query to a custom name server
```swift
let ds = DNSService.init(host: "a custom name server")
ds.start()
sleep(1)
ds.query(domain: "api.disco.goateng.com", completion: { (rr, err) in
  print(rr!.Answers.map { $0.RData }) // this could be CName list as well
  ds.stop() // don't forget to stop service
})
```
